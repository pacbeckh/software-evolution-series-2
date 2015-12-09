module CloneDetection

import DateTime;
import IO;
import List;
import Set;
import String;
import ListRelation;
import Relation;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import Map;
import util::Maybe;

import util::Logging;
import util::Timing;
import Domain;
import maintenance::Maintenance;
import maintenance::Domain;
import Config;
import logic::PairEvolver;
import PairCreator;
import transformation::AstNormalizer;
import transformation::AstAnonimizer;
import output::Store;
import postprocessing::NestedBlockProcessor;
import postprocessing::SameEndProcessor;
import postprocessing::OverlapProcessor;
import transformation::CloneClassCreator;

//public loc projectLoc = |project://hello-world-java/|;
//public loc projectLoc = |project://smallsql0.21_src|;
public loc projectLoc = |project://hsqldb-2.3.1|;

public M3 model;

public M3 loadModel() {
	model = createM3FromEclipseProject(projectLoc);
	return model;
}

public void mainFunction() {
	logInfo("Loading model");
	M3 model = loadModel();
	mainFunctionWithModel(model);	
}

public void mainFunctionWithModel(M3 model) {
	logInfo("Starting clone detection");
	cloneClasses = run(model);
	
	logInfo("Starting maintenance");
	MaintenanceData maintenance = runMaintenance(model);
	
	logInfo("Store files to server");
	storeInServer(projectLoc, cloneClasses, maintenance);
	logInfo("Stored files to server");
}

public void runVoid(M3 model) {
	run(model);
}

public map[int, set[CloneClass]] run(M3 model) {
	logInfo("Normalize and anonimize statements...");
	list[AnonymousLink] links = anonimizeAndNormalize(model);
	iprintln("<size(links)> links found");
	
	logInfo("Getting all pairs...");
	list[LinkPair] allPairs = getAllLinkPairs(links);
	
	iprintln("<size(allPairs)> linkpairs found");
	
	logInfo("Evolving pairs to maximal expansion...");
	map[int, list[LinkPair]] levelResults = evolveLinkPairs(allPairs);
	
	//Remove things we are not interested in, stuff below the threshold.
	levelResults = ( levelResults | delete(it,i) | int i <- [1..CONFIG_STATEMENT_WEIGHT_THRESHOLD]);
	
	map[int, set[CloneClass]] cloneClasses = createCloneClasses(levelResults);
	
	println(" \> Got <numberOfCloneClasses(cloneClasses)> clone classes");

	logInfo("Purging clone classes with same endloc...");
	cloneClasses = cleanupCloneClassesWithSameEnd(cloneClasses);
	println(" \> Got <numberOfCloneClasses(cloneClasses)> clone classes");
	
	logInfo("Purging overlapping clone classes...");
	cloneClasses = cleanOverlappingFragments(cloneClasses);
	println(" \> Got <numberOfCloneClasses(cloneClasses)> clone classes");
	
	logInfo("Purge nested clone classes...");
	cloneClasses = cleanupNestedBlocks(cloneClasses);
	println(" \> Got <numberOfCloneClasses(cloneClasses)> clone classes");
	
	logInfo("Done with cleanup!");
	return cloneClasses;
}

public int numberOfCloneClasses(map[int, set[CloneClass]] input) {
	return ( 0 | it + size(input[k]) | k <- input);
}

// Uses compilationUnits in the m3 + fileAST
public list[AnonymousLink] anonimizeAndNormalize(M3 model){
	list[AnonymousLink] links = [];
	
	for ( cu <- files(model@containment), cu.file != "ValidatingResourceBundle.java") {
		links += anonimizeAndNormalizeFile(cu);	
	}
	
	return links;
}

public list[AnonymousLink] anonimizeAndNormalizeFile(loc file) {
	Declaration declaration = createAstFromFile(file, true, javaVersion="1.7");
	
	list[Statement] normalizedStatements = [];
	top-down-break visit(declaration){
		case x:\method(_,_,_,_,s) :
			normalizedStatements += normalize(s);
		case \constructor(_,_,_,s) :
			normalizedStatements += normalize(s);
		case x:\initializer(s) : 
			normalizedStatements += (CONFIG_INCLUDE_INITIALIZER_BLOCK) ? normalize(s) : [];
	}
	
	return concat([getAnonimizedStatements(n) | n <- normalizedStatements]);
}

public map[int, list[LinkPair]] evolveLinkPairs(list[LinkPair] allPairs) {
	map[int, list[LinkPair]] levelResults = ();
	map[value,value] cache = ();
	
	int eob = 0;
	int hits = 0; 
	for (focus <- allPairs) {
		//Just continue if element in cache
		if (cache[{head(focus.leftStack), head(focus.rightStack)}]?) {
			hits += 1;
			continue;
		}
		
		LinkPair evolved = evolvePair(focus);
		if (levelResults[evolved@weight]?) {
			levelResults[evolved@weight] += evolved;
		} else {
			levelResults[evolved@weight] = [evolved];
		}
		
		//Cache Pair if EndOfBlock
		if (head(evolved.leftStack).next == noLink() || head(evolved.rightStack).next == noLink()) {
			eob += 1;
			for (i <- [0..size(evolved.leftStack)]) {
				cache[{evolved.leftStack[i],evolved.rightStack[i]}] = evolved; 
			}
		}
	}
	println(" \> Cache size: <size(cache)>");
	println(" \> EOB: <eob>");
	println(" \> Hits: <hits>");
	return levelResults;
}
	
