module transformation::CloneClassCreator

import Map;
import DateTime;
import IO;
import List;
import Relation;
import lang::java::jdt::m3::AST;
import Set;
import ListRelation;

import Domain;
import util::Logging;
import util::Timing;

public map[int, set[CloneClass]] createCloneClasses(map[int, list[LinkPair]] levelResults) {
	logInfo("Transform pairs to start and end locations...");
	map[int, rel[loc,loc]] levelResultsAbsolute = transformLinkPairsToFragments(levelResults);
	
	logInfo("Creating clone classes with equiv rel...");
	map[int, set[CloneClass]] cloneClasses = (k : toEquivalenceFast(levelResultsAbsolute[k]) | k <- levelResultsAbsolute);
	
	return cloneClasses;
}

private set[CloneClass] rawCloneClassToCloneClass(set[rel[loc,loc]] rawCloneClasses) 
	= { asCloneClass(rawCloneClass) | rawCloneClass <- rawCloneClasses};

private CloneClass asCloneClass(rel[loc,loc] rawCloneClass)
	= { mergeLoc(s,e) | <s,e> <- rawCloneClass};

private set[set[loc]] toEquivalenceDefault(rel[loc,loc] rels)
	= groupRangeByDomain((rels + invert(rels)) +);
	

	
private set[set[loc]] toEquivalenceFast(rel[loc,loc] rels) {
	return partitionsForIrreflexiveAsymetricRel(rels);
}


private set[set[&T]] partitionsForIrreflexiveAsymetricRel(rel[&T,&T] rels) {
	int counter = 0;
	map[&T,set[&T]] indexed = index(rels);
	
	set[&T] st = domain(rels) - range(rels);
	set[&T] emp = {};	
	partitionsList = for (s <- st) {
		set[&T] sPath = {s};
		set[&T] last = {s};
		while(true) {
			set[&T] next = emp;
			for (l <- last, indexed[l]?) {
				next += indexed[l];
				sPath += indexed[l];
			}
			if (next == {}) {
				break;
			}
			last = next;
		}
		append sPath;
	}
	set[set[&T]] partitions = toSet(partitionsList);
	
	
	lrel[set[&T],set[&T]] overlappingList;
	overlappingList = for (i <- [0..size(partitionsList)], j <- [i+1 .. size(partitionsList)]) {
		if (!isEmpty(partitionsList[i] & partitionsList[j])) {
			append <partitionsList[i], partitionsList[j]>;
		}
	}
	rel[set[&T],set[&T]] overlapping = toSet(overlappingList); 
	
	if (isEmpty(overlapping)) {
		return partitions;
	} else {
		set[set[&T]] allOverlapping = domain(overlapping) + range(overlapping);
		set[set[&T]] finishedPartitions = partitions - allOverlapping;
		r = {union(item) | item <- partitionsForIrreflexiveAsymetricRel(overlapping)};
		return finishedPartitions + r;
	}
}

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

public void performanceTestToEquivalence(int i, bool fuzzy) {
	lrel[loc,loc] links;
	links = for(int j <- [1..i]) {
		fileName1a = "<j>";
		fileName1b = "<j+1>";
		fileName2a = "<i+j>";
		fileName2b = "<i+j+1>";
		append <|file://foo<fileName1a>|, |file://foo<fileName1b>|>;
		if (fuzzy) {
			append <|file://bar<fileName1a>|, |file://foo<fileName1b>|>;
		}
		append <|file://foo<fileName2a>|, |file://foo<fileName2b>|>;
	}
	linkSet = toSet(links);
	
	set[set[loc]] result1;
	set[set[loc]] result2;
	
	executeDuration("Equiv Fast", () {
		result1 = toEquivalenceFast(linkSet);
	});
	executeDuration("Equiv Normal", () {
		result2 = toEquivalenceDefault(linkSet);
	});
	
	iprintln(size(result2));
	println("Result: <result1 == result2>");
}



