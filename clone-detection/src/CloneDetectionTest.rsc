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

test bool testNestedDuplicates() {
	list[AnonymousLink] links = getLinksForFile("NestedDuplicates.java");
	list[LinkPair] linkPairs = getAllLinkPairs(links);
	
	iprintln(size(linkPairs));
	return size(links) == 16;
}
