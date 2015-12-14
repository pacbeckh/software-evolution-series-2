module CloneDetection

import List;
import Set;
import ListRelation;
import Relation;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import Map;

import Domain;
import Config;
import PairCreator;
import logic::PairEvolver;
import maintenance::Maintenance;
import maintenance::Domain;
import output::Store;
import postprocessing::NestedBlockProcessor;
import postprocessing::SameEndProcessor;
import postprocessing::OverlapProcessor;
import transformation::AstNormalizer;
import transformation::AstAnonimizer;
import transformation::CloneClassCreator;
import util::Logging;

//public loc projectLoc = |project://hello-world-java/|;
public loc projectLoc = |project://smallsql0.21_src|;
//public loc projectLoc = |project://hsqldb-2.3.1|;

public M3 loadModel() = createM3FromEclipseProject(projectLoc);

public void mainFunction() {
	logInfo("Loading model");
	M3 model = loadModel();
	mainFunctionWithModel(model);	
}

public void mainFunctionWithModel(M3 model) {
	logInfo("Starting clone detection");

	logInfo("Collecting declarations");	
	lrel[loc,Declaration] declarations = collectDeclarations(model); 
	
	cloneClasses = run(declarations);
	
	logInfo("Starting maintenance");
	MaintenanceData maintenance = runMaintenance(model, declarations);
	
	logInfo("Store files to server");
	storeInServer(projectLoc, cloneClasses, maintenance);
	logInfo("Stored files to server");
}

public map[int, set[CloneClass]] run(lrel[loc,Declaration] declarations) {
	logInfo("Normalize and anonimize statements...");

	
	list[AnonymousLink] links = anonimizeAndNormalize(declarations);
	logDebug(" \> <size(links)> links found");
	
	logInfo("Getting all pairs...");
	list[LinkPair] allPairs = getAllLinkPairs(links);
	
	logDebug(" \> <size(allPairs)> linkpairs found");
	
	logInfo("Evolving pairs to maximal expansion...");
	map[int, set[LinkPair]] levelResults = evolveLinkPairs(allPairs);
	
	map[int, set[CloneClass]] cloneClasses = createCloneClasses(levelResults);
	printNumberOfCloneClasses(cloneClasses);	

	return purgeCloneClasses(cloneClasses);
}

public map[int, set[CloneClass]]  purgeCloneClasses(map[int, set[CloneClass]] cloneClasses) {
	logInfo("Purging overlapping clone classes...");
	cloneClasses = cleanOverlappingFragments(cloneClasses);
	printNumberOfCloneClasses(cloneClasses);
	
	logInfo("Purging clone classes with same endloc...");
	cloneClasses = cleanupCloneClassesWithSameEnd(cloneClasses);
	printNumberOfCloneClasses(cloneClasses);
	
	logInfo("Purge nested clone classes...");
	cloneClasses = cleanupNestedBlocks(cloneClasses);
	printNumberOfCloneClasses(cloneClasses);
	
	logInfo("Done with cleanup!");
	return cloneClasses;
}

public lrel[loc,Declaration] collectDeclarations(M3 model) = [
	<cu,createAstFromFile(cu, true, javaVersion="1.7")> | 
		cu <- files(model@containment), 
			cu.file != "ValidatingResourceBundle.java"
];
		
public void printNumberOfCloneClasses(map[int, set[CloneClass]] input) = 
	logDebug(" \> Got <numberOfCloneClasses(input)> clone classes");
	
public int numberOfCloneClasses(map[int, set[CloneClass]] input) =
	( 0 | it + size(input[k]) | k <- input);

public list[AnonymousLink] anonimizeAndNormalize(lrel[loc,Declaration] declarations){
	list[AnonymousLink] links = [];
	for ( <_,d> <- declarations) {
		links += anonimizeAndNormalizeFile(d);	
	}
	return links;
}

public list[AnonymousLink] anonimizeAndNormalizeFile(Declaration declaration) {
	list[Statement] normalizedStatements = [];
	top-down-break visit(declaration){
		case x:\method(_,_,_,_,s) :
			normalizedStatements += normalize(s);
		case \constructor(_,_,_,s) :
			normalizedStatements += normalize(s);
		case x:\initializer(s) : 
			normalizedStatements += normalize(s);
	}
	
	return concat([getAnonimizedStatements(n) | n <- normalizedStatements]);
}

public map[int, set[LinkPair]] evolveLinkPairs(list[LinkPair] allPairs) {
	set[set[AnonymousLink]] cache = {};
	
	int eob = 0;
	int hits = 0;
	lrel[int,LinkPair] levelListRelation; 
	levelListRelation = for (focus <- allPairs) {
		//Just continue if element in cache
		if ({focus.leftStack[0], focus.rightStack[0]} in cache) {
			hits += 1;
			continue;
		}
		
		LinkPair evolved = evolvePair(focus);
		int w = evolved@weight;
		if (w >= CONFIG_STATEMENT_WEIGHT_THRESHOLD) {
			append <w,evolved>;
		}
		
		//Cache Pair if EndOfBlock
		if (evolved.leftStack[0].next == noLink() || evolved.rightStack[0].next == noLink()) {
			eob += 1;
			cache += { {evolved.leftStack[i],evolved.rightStack[i]} | i <- [0.. (size(evolved.leftStack) - 1)] };			
		}
	}
	logDebug(" \> Cache size: <size(cache)>");
	logDebug(" \> End of blocks reached: <eob>");
	logDebug(" \> Cache hits: <hits>");
	
	return index(levelListRelation);
}
	
