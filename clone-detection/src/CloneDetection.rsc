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

import Domain;
import maintenance::Maintenance;
import maintenance::Domain;
import Config;
import logic::PairEvolver;
import PairCreator;
import transformation::AstNormalizer;
import transformation::AstAnonimizer;
import output::Store;

public loc projectLoc = |project://hello-world-java/|;
//public loc projectLoc = |project://smallsql0.21_src|;
//public loc projectLoc = |project://hsqldb-2.3.1|;

public M3 model;

public M3 loadModel() {
	model = createM3FromEclipseProject(projectLoc);
	return model;
}

public void mainFunction() {

	println("<printTime(now())> Loading model");
	M3 model = loadModel();
	
	println("<printTime(now())> Starting clone detection");
	cloneClasses = run(model);
	
	println("<printTime(now())> Starting maintenance");
	MaintenanceData maintenance = runMaintenance(model);
	
	println("<printTime(now())> Store files to server");
	storeInServer(projectLoc, cloneClasses, maintenance);
}

public void runVoid(M3 model) {
	run(model);
}

public map[int, set[set[tuple[loc,loc]]]] run(M3 model) {
	println("<printTime(now())> Normalize and anonimize statements...");
	list[AnonymousLink] links = anonimizeAndNormalize(model);
	iprintln("<size(links)> links found");
	
	println("<printTime(now())> Getting all pairs...");
	list[LinkPair] allPairs = getAllLinkPairs(links);
	//printLinkPairs(allPairs);
	
	iprintln("<size(allPairs)> linkpairs found");
	
	println("<printTime(now())> Evolving pairs to maximal expansion...");
	map[int, list[LinkPair]] levelResults = evolveLinkPairs(allPairs);
	
	//Remove things we are not interested in, stuff below the threshold.
	levelResults = ( levelResults | delete(it,i) | int i <- [1..CONFIG_STATEMENT_WEIGHT_THRESHOLD + 1]);
	
	println("<printTime(now())> Transform pairs to start and end locations...");
	map[int, rel[tuple[loc,loc],tuple[loc,loc]]] levelResultsAbsolute = ();
	for (k <- levelResults) {
		list[LinkPair] levelResult = levelResults[k];
		rel[tuple[loc, loc],tuple[loc, loc]] rels = {<<last(l.leftStack).normal@src, head(l.leftStack).normal@src>, 
						      <last(l.rightStack).normal@src, head(l.rightStack).normal@src>> | l <- levelResult};
		levelResultsAbsolute[k] = rels;
	}
	
	println("<printTime(now())> Creating clone classes with equiv rel...");
	map[int, set[set[tuple[loc,loc]]]] cloneClasses = (k : toEquivalence(levelResultsAbsolute[k]) | k <- levelResultsAbsolute);

	println("<printTime(now())> Purge overlapping clone classes...");
	cloneClasses = cleanupCloneClasses(cloneClasses);
	for (k <- cloneClasses) {
		println("- <k> \> <size(cloneClasses[k])>");
	}
	
	return cloneClasses;
}

// Uses compilationUnits in the m3 + fileAST
public list[AnonymousLink] anonimizeAndNormalize(M3 model){
	list[AnonymousLink] links = [];
	
	for ( <cu,_> <- model@containment, isCompilationUnit(cu), cu.file != "ValidatingResourceBundle.java"){
		links += anonimizeAndNormalizeFile(cu);		
	}
	
	return links;
}

public list[AnonymousLink] anonimizeAndNormalizeFile(loc file) {
	Declaration declaration = createAstFromFile(file, true, javaVersion="1.7");
	
	list[Statement] normalizedStatements = [];
	top-down-break visit(declaration){
		case \method(_,_,_,_,s) : normalizedStatements += normalize(s);
		case \constructor(_,_,_,s) : normalizedStatements += normalize(s);
		case \initializer(s) : normalizedStatements += (CONFIG_INCLUDE_INITIALIZER_BLOCK) ? normalize(s) : [];
	}
	
	return concat([getAnonimizedStatements(n) | n <- normalizedStatements]);
}

public map[int, list[LinkPair]] evolveLinkPairs(list[LinkPair] allPairs) {
	map[int, list[LinkPair]] levelResults = (); 
	for (focus <- allPairs) {
		evolved = evolvePair(focus);
		if (levelResults[evolved@weight]?) {
			levelResults[evolved@weight] += evolved;
		} else {
			levelResults[evolved@weight] = [evolved];
		}
	}
	return levelResults;
}

public map[int, set[set[tuple[loc,loc]]]] cleanupCloneClasses(map[int, set[set[tuple[loc,loc]]]] input) {
	list[int] orderedKeys = reverse(sort(toList(domain(input))));
	set[set[loc]] knownClasses = {};
		
	map[int, set[set[tuple[loc,loc]]]] answer = ();
	
	for (k <-orderedKeys) {
		answer[k] = {};
		for (set[tuple[loc,loc]] clazz <- input[k]) {
			set[loc] ends = {end | <_,end> <- clazz};
			if (ends notin knownClasses) {
				knownClasses += {ends};
				answer[k] += {clazz};
			}
		}
	}
	return answer;
}

public set[set[tuple[loc,loc]]] toEquivalence(rel[tuple[loc,loc],tuple[loc,loc]] rels)
	= groupRangeByDomain((rels + {<r,l> | <l,r> <- rels})+);
	
