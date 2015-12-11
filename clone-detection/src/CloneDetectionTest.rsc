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
import transformation::CloneClassCreator;
import postprocessing::SameEndProcessor;

test bool testNestedDuplicates() {
	list[AnonymousLink] links = getLinksForFile("NestedDuplicates.java");
	list[LinkPair] linkPairs = getAllLinkPairs(links);
	
	map[int, set[LinkPair]] evolvedLinkPairs = evolveLinkPairs(linkPairs);
	map[int, set[CloneClass]] cloneClasses = createCloneClasses(evolvedLinkPairs);
	
	cleanupCloneClassesWithSameEnd(cloneClasses);
	
	return size(links) == 16;
}
