module PairCreator

import lang::java::jdt::m3::AST;
import List;
import IO;
import Map;

import Domain;
import Config;
import logic::PairEvolver;


public list[LinkPair] getAllLinkPairs(list[AnonymousLink] links) {
	map[list[Statement],list[AnonymousLink]] linkIndex = ();
	int i = 0;
	for(link <- links) {
		if(link@maxWeight < CONFIG_STATEMENT_WEIGHT_THRESHOLD) {
			i += 1;
			continue;
		}
		list[Statement] key = collectAnonymousKey(link, CONFIG_STATEMENT_WEIGHT_THRESHOLD);
		if (linkIndex[key]?) {
			linkIndex[key] = linkIndex[key] + link;
		} else {
			linkIndex[key] = [link];
		}
	}
	iprintln("Ignored <i> AnonymousLinks ");
	iprintln("Link index size <size(linkIndex)>");
	
	list[LinkPair] allPairs = [];
	for(k <- linkIndex, size(linkIndex[k]) > 1) {
		list[LinkPair] pairs = setupLinkPairs(linkIndex[k]);
		allPairs += pairs;
	}
	return allPairs;
}

public list[Statement] collectAnonymousKey(AnonymousLink link, int threshold) {
	list[Statement] answer = [];
	NextLink next = aLink(link);
	int currentThreshold = threshold;
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
