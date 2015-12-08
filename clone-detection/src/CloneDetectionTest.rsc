module CloneDetectionTest

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import List;
import IO;

import Domain;
import Config;
import logic::PairEvolver;
import PairCreator;
import TestUtil;
import CloneDetection;

test bool testNestedDuplicates() {
	list[AnonymousLink] links = getLinksForFile("NestedDuplicates.java");
	list[LinkPair] linkPairs = getAllLinkPairs(links);
	printLinkPairs(linkPairs);
	
	map[int, list[LinkPair]] evolvedLinkPairs = evolveLinkPairs(linkPairs);
	
	for(k <- evolvedLinkPairs){
		iprintln(k);
		printEvolvedLinkPairs(evolvedLinkPairs[k]);	
	}
	
	
	map[int, rel[tuple[loc,loc],tuple[loc,loc]]] levelResultsAbsolute = transformLinkPairsToLocs(evolvedLinkPairs);
	
	
	
	map[int, set[set[tuple[loc,loc]]]] cloneClasses = (k : toEquivalence(levelResultsAbsolute[k]) | k <- levelResultsAbsolute);
	
	cleanupCloneClasses(cloneClasses);
	
	//printLinkPairs(linkPairs);
	//iprintln(size(linkPairs));
	return size(links) == 16;
}
