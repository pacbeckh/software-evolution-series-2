module Mats

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

//public loc projectLoc = |project://hello-world-java/src/nl/simple|;
public loc projectLoc = |project://smallsql0.21_src|;

public void mainFunction() {
	println("<printDateTime(modelStart)> Obtaining M3 Model");
	M3 model = createM3FromEclipseProject(projectLoc);
	
	println("<printDateTime(now())> Starting clone detection");
	run(model);
}


public void run(M3 model) {
	int i = 1;
	
	set[AnonymousLink] links = {};
	
	println("<printDateTime(now())> Normalize and anonimize statements...");
	for (m <- methods(model)) {
		//println("Handle method (<i>): <m.file>, <m>");
		i += 1;
		
		Declaration d = getMethodASTEclipse(m, model = model);
		Declaration normalized = normalizeMethods(d);
		
		links += getAnonimizedStatements(d);
	}
	
	println("<printDateTime(now())> Getting all pairs...");
	set[LinkPair] allPairs  = getAllLinkPairs(links);	
	
	println("<printDateTime(now())> Evolving pairs to maximal expansion...");
	map[int, set[LinkPair]] levelResults = (); 
	for (focus <- allPairs) {
		<level, evolved> = evolvePair(focus);
		if (levelResults[level]?) {
			levelResults[level] += evolved;
		} else {
			levelResults[level] = {evolved};
		}
	}
	
	//Remove things we are not interested in. We should use weight here.
	levelResults = delete(delete(levelResults, 1),2);
	
	println("<printDateTime(now())> Transform pairs to start and end locations...");
	map[int, rel[tuple[loc,loc],tuple[loc,loc]]] levelResultsAbsolute = ();
	for (k <- levelResults) {
		set[LinkPair] levelResult = levelResults[k];
		rel[tuple[loc, loc],tuple[loc, loc]] rels = {<<last(l.leftStack).normal@src, head(l.leftStack).normal@src>, 
						      <last(l.rightStack).normal@src, head(l.rightStack).normal@src>> | l <- levelResult};
		levelResultsAbsolute[k] = rels;
	}
	
	println("<printDateTime(now())> Creating clone classes with equiv rel...");
	map[int, set[set[tuple[loc,loc]]]] cloneClasses = (k : toEquivalence(levelResultsAbsolute[k]) | k <- levelResultsAbsolute);
	//for (k <- cloneClasses) {
	//	iprintln("- <k> \> <size(cloneClasses[k])>");
	//}
	
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
	
public set[AnonymousLink] getAnonimizedStatements(Declaration normalized) {
	set[AnonymousLink] answer = {};
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


public set[LinkPair] getAllLinkPairs(set[AnonymousLink] links) {
	map[Statement,set[AnonymousLink]] linkIndex = ();
	for(link <- links) {
		if(\expressionStatement(_) := link.normal && link.next ==noLink()) {
			//Last expression of block. We dont need those.
			continue;
		}
		if (linkIndex[link.anonymous]?) {
			linkIndex[link.anonymous] = linkIndex[link.anonymous] + link;
		} else {
			linkIndex[link.anonymous] = {link};
		}
	}
	
	set[LinkPair] allPairs = {};
	for(k <- linkIndex, size(linkIndex[k]) > 1) {
		set[LinkPair] pairs = setupLinkPairs(linkIndex[k]);
		allPairs += pairs;
	}
	return allPairs;
}

public set[LinkPair] setupLinkPairs(set[AnonymousLink] links) {
	list[AnonymousLink] linkList = toList(links);
	set[LinkPair] result = {};
	
	for(int i <- [0 .. size(linkList)], int j <- [i+1 .. size(linkList)]) {
		LinkPair linkPair = linkPairWithNext(linkList[i], linkList[j]);
		if (linkPair.ltrMappingPossible || linkPair.rtlMappingPossible) {
			result += linkPair;
		}
	}
	return result;
}
