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

import AnonymizeStatements;
import Domain;
import logic::PairEvolver;
import transformation::AstNormalizer;
import AnonymizeStatements;

public loc projectLoc = |project://hello-world-java/|;
//public loc projectLoc = |project://smallsql0.21_src|;

public M3 model;

public M3 loadModel() {
	model = createM3FromEclipseProject(projectLoc);
	return model;
}

public void mainFunction() {
	M3 model = loadModel();
	
	println("<printDateTime(now())> Starting clone detection");
	run(model);
}


public void run(M3 model) {
	int i = 1;
	
	list[AnonymousLink] links = [];
	
	println("<printDateTime(now())> Normalize and anonimize statements...");
	for (m <- methods(model)) {
		println("Handle method (<i>): <m.file>, <m>");
		i += 1;

		Declaration d = getMethodASTEclipse(m, model = model);
		Declaration normalized = normalizeMethods(d);
		
		links += getAnonimizedStatements(d);
	}
	iprintln("<size(links)> links found"); 
	
	println("<printDateTime(now())> Getting all pairs...");
	list[LinkPair] allPairs  = getAllLinkPairs(links);
	iprintln("<size(allPairs)> linkpairs found");
	
	println("<printDateTime(now())> Evolving pairs to maximal expansion...");
	map[int, list[LinkPair]] levelResults = (); 
	for (focus <- allPairs) {
		<level, evolved> = evolvePair(focus);
		if (levelResults[level]?) {
			levelResults[level] += evolved;
		} else {
			levelResults[level] = [evolved];
		}
	}
	
	//Remove things we are not interested in. We should use weight here.
	levelResults = delete(delete(levelResults, 1),2);
	
	println("<printDateTime(now())> Transform pairs to start and end locations...");
	map[int, rel[tuple[loc,loc],tuple[loc,loc]]] levelResultsAbsolute = ();
	for (k <- levelResults) {
		list[LinkPair] levelResult = levelResults[k];
		rel[tuple[loc, loc],tuple[loc, loc]] rels = {<<last(l.leftStack).normal@src, head(l.leftStack).normal@src>, 
						      <last(l.rightStack).normal@src, head(l.rightStack).normal@src>> | l <- levelResult};
		levelResultsAbsolute[k] = rels;
	}
	
	println("<printDateTime(now())> Creating clone classes with equiv rel...");
	map[int, set[set[tuple[loc,loc]]]] cloneClasses = (k : toEquivalence(levelResultsAbsolute[k]) | k <- levelResultsAbsolute);

	println("<printDateTime(now())> Purge overlapping clone classes...");
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
	
public list[AnonymousLink] getAnonimizedStatements(Declaration normalized) {
	list[AnonymousLink] answer = [];
	visit(normalized) {
		case \block(list[Statement] sts): {
			int i = size(sts);
			NextLink next = noLink();
			while (i > 0) {
				i-=1;
				Statement anon = anonimizeStatement(sts[i])[1];
				AnonymousLink link = anonymousLink(anon, sts[i], next);
				answer += link;
				next = aLink(link);
			}
			
		}
	}
	return answer;
}


public list[LinkPair] getAllLinkPairs(list[AnonymousLink] links) {
	map[Statement,list[AnonymousLink]] linkIndex = ();
	for(link <- links) {
		if(\expressionStatement(_) := link.normal && link.next == noLink()) {
			//Last expression of block. We dont need those.
			continue;
		}
		if (linkIndex[link.anonymous]?) {
			linkIndex[link.anonymous] = linkIndex[link.anonymous] + link;
		} else {
			linkIndex[link.anonymous] = [link];
		}
	}
	
	list[LinkPair] allPairs = [];
	for(k <- linkIndex, size(linkIndex[k]) > 1) {
		list[LinkPair] pairs = setupLinkPairs(linkIndex[k]);
		allPairs += pairs;
	}
	return allPairs;
}

public list[LinkPair] setupLinkPairs(list[AnonymousLink] links) {
	list[LinkPair] result = [];
	
	for(int i <- [0 .. size(links)], int j <- [i+1 .. size(links)]) {
		LinkPair linkPair = linkPairWithNext(links[i], links[j]);
		if (isMappingPossible(linkPair)) {
			result += linkPair;
		}
	}
	return result;
}
