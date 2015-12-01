module PairCreator

import lang::java::jdt::m3::AST;
import List;
import IO;
import Map;

import Domain;
import Config;
import logic::PairEvolver;


public list[LinkPair] getAllLinkPairs(list[AnonymousLink] links) {
	map[Statement,list[AnonymousLink]] linkIndex = ();
	int i = 0;
	for(link <- links) {
		if(link@maxWeight <= CONFIG_STATEMENT_THRESHOLD) {
			i += 1;
			continue;
		}
		if (linkIndex[link.anonymous]?) {
			linkIndex[link.anonymous] = linkIndex[link.anonymous] + link;
		} else {
			linkIndex[link.anonymous] = [link];
		}
	}
	iprintln("Link index <size(linkIndex)>");
	iprintln("Ignored <i> AnonymousLinks ");
	
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