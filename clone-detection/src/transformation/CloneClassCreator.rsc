module transformation::CloneClassCreator

import Map;
import DateTime;
import IO;
import List;
import Relation;
import lang::java::jdt::m3::AST;

import Domain;
import util::Logging;

public map[int, set[CloneClass]] createCloneClasses(map[int, list[LinkPair]] levelResults) {
	logInfo("Transform pairs to start and end locations...");
	map[int, rel[loc,loc]] levelResultsAbsolute = transformLinkPairsToFragments(levelResults);
	
	logInfo("Creating clone classes with equiv rel...");
	map[int, set[CloneClass]] cloneClasses = (k : toEquivalence(levelResultsAbsolute[k]) | k <- levelResultsAbsolute);
	//map[int, set[CloneClass]] cloneClasses = ( k : rawCloneClassToCloneClass(cloneClassesRaw[k]) | k <- cloneClassesRaw);
	
	return cloneClasses;
}

private set[CloneClass] rawCloneClassToCloneClass(set[rel[loc,loc]] rawCloneClasses) 
	= { asCloneClass(rawCloneClass) | rawCloneClass <- rawCloneClasses};

private CloneClass asCloneClass(rel[loc,loc] rawCloneClass)
	= { mergeLoc(s,e) | <s,e> <- rawCloneClass};

private set[set[loc]] toEquivalence(rel[loc,loc] rels)
	= groupRangeByDomain((rels + invert(rels)) +);

private map[int, rel[loc,loc]] transformLinkPairsToFragments(map[int, list[LinkPair]] evolvedLinksPairs)
	= ( k : {linkPairToFragmentPair(l) | l <- evolvedLinksPairs[k]} | k <- evolvedLinksPairs);

private tuple[loc,loc] linkPairToFragmentPair(LinkPair linkPair)
	= <stackToLoc(linkPair.leftStack), stackToLoc(linkPair.rightStack)>;

private loc stackToLoc(list[AnonymousLink] stack)
	= mergeLoc(last(stack).normal@src, head(stack).normal@src);

private loc mergeLoc(loc s, loc e) {
	n = s.end = e.end;
	return n;
}


