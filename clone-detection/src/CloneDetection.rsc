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
import Config;
import logic::PairEvolver;
import PairCreator;
import transformation::AstNormalizer;
import transformation::AstAnonimizer;
import output::Store;

//public loc projectLoc = |project://hello-world-java/|;
public loc projectLoc = |project://smallsql0.21_src|;

public M3 model;

public M3 loadModel() {
	model = createM3FromEclipseProject(projectLoc);
	return model;
}

public void mainFunction() {

	println("<printTime(now())> Loading model");
	M3 model = loadModel();
	
	println("<printTime(now())> Starting clone detection");
	run(model);
	
	println("<printTime(now())> Store files to server");
	storeInServer(projectLoc);
}


public void run(M3 model) {
	list[AnonymousLink] links = [];
	
	println("<printTime(now())> Normalize and anonimize statements...");
	int methodIndex = 1;
	for (m <- methods(model), contains(m.path, "DuplicationWithFirstLineDifferent")) {
		println("Handle method (<methodIndex>): <m.file>, <m>");
		methodIndex += 1;

		Declaration d = getMethodASTEclipse(m, model = model);
		Declaration normalized = normalizeMethods(d);
		links += getAnonimizedStatements(normalized);
		
	}
	
	iprintln("<size(links)> links found");
	
	println("<printTime(now())> Getting all pairs...");
	list[LinkPair] allPairs  = getAllLinkPairs(links);
	//printLinkPairs(allPairs);
	
	iprintln("<size(allPairs)> linkpairs found");
	
	println("<printTime(now())> Evolving pairs to maximal expansion...");
	map[int, list[LinkPair]] levelResults = (); 
	for (focus <- allPairs) {
		evolved = evolvePair(focus);
		if (levelResults[evolved@weight]?) {
			levelResults[evolved@weight] += evolved;
		} else {
			levelResults[evolved@weight] = [evolved];
		}
	}
	
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
	
private void printLinkPairs(list[LinkPair] pairs){
	for(pair <- pairs){
		println("Pair from <head(pair.leftStack).normal@src> = <head(pair.rightStack).normal@src>");
	}
}
