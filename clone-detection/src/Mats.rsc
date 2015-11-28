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

public loc projectLoc = |project://hello-world-java/src/nl/simple|;
public M3 model;

public M3 loadModel() {
	model = createM3FromEclipseProject(projectLoc);
	return model;
}


public void run(M3 model) {
	int i = 1;
	
	set[AnonymousLink] links = {};
	
	for (m <- methods(model)) {
		println("Handle method (<i>): <m.file>, <m>");
		i += 1;
		
		Declaration d = getMethodASTEclipse(m, model = model);
		Declaration normalized = normalizeMethods(d);
		
		links += getAnonimizedStatements(d);
	}
	
	set[LinkPair] allPairs  = getAllLinkPairs(links);	
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
	
	for (k <- levelResults) {
		iprintln("Key: <k>");
		set[LinkPair] levelResult = levelResults[k];
		rel[tuple[loc, loc],tuple[loc, loc]] rels = {<<last(l.leftStack).normal@src, head(l.leftStack).normal@src>, 
						      <last(l.rightStack).normal@src, head(l.rightStack).normal@src>> | l <- levelResult};
		
		iprintln("- Init: <size(rels)>");
		rels += {<r,l> | <l,r> <- rels};
		iprintln("- Invert: <size(rels)>");
		rels = rels+; 
		iprintln("- Trans: <size(rels)>");
		iprintln("- Parts: <size(groupRangeByDomain(rels))>");
	}
}

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
