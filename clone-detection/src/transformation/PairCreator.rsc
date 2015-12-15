module transformation::PairCreator

import lang::java::jdt::m3::AST;
import List;
import Map;
import ListRelation;
import Set;

import Domain;
import Config;
import logic::PairEvolver;
import util::Logging;

public list[LinkPair] getAllLinkPairs(list[AnonymousLink] links) {
	lrel[list[Statement],AnonymousLink] indexLinkRel = [<collectAnonymousKey(link), link> | link <- links, link@maxWeight >= CONFIG_STATEMENT_WEIGHT_THRESHOLD];
	
	map[list[Statement],list[AnonymousLink]] linkIndex = toMap(indexLinkRel);
	
	logDebug(" \> Link index size <size(linkIndex)>");
	
	list[LinkPair] allPairs = [];
	for(k <- linkIndex, size(linkIndex[k]) > 1) {
		list[LinkPair] pairs = setupLinkPairs(linkIndex[k]);
		allPairs += pairs;
	}
	return allPairs;
}

public list[Statement] collectAnonymousKey(AnonymousLink link) {
	list[Statement] answer = [];
	NextLink next = aLink(link);
	int currentThreshold = CONFIG_STATEMENT_WEIGHT_THRESHOLD;
	while(true) {
		if (aLink(v) := next) {
			answer += v.anonymous;
			next = next.val.next;
			currentThreshold -= v.normal@weight; 
		} else {
			throw "Error";
		}
		
		if (currentThreshold <= 0) {
			return answer;
		}		
	}	
}

public list[LinkPair] setupLinkPairs(list[AnonymousLink] links) {
	return for(int i <- [0 .. size(links)], int j <- [i+1 .. size(links)]) {
		LinkPair linkPair = linkPairWithNext(links[i], links[j]);
		if (linkPair.mappingPossible) {
			append linkPair;
		}
	}
}