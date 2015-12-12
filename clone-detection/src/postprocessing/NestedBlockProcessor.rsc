module postprocessing::NestedBlockProcessor

import List;
import Map;
import Set;
import ListRelation;

import Domain;
import util::Timing;

public map[int, set[CloneClass]] cleanupNestedBlocks(map[int, set[CloneClass]] input) {
	list[int] sortedKeys = sort(toList(domain(input)));
	
	map[tuple[int,CloneClass],set[str]] cloneClassLocations
		= (<k,levelCloneClass> : locationsForLevelCloneClass(levelCloneClass) | k <- sortedKeys, levelCloneClass <- input[k]);
	map[set[str], rel[int,CloneClass]] cloneClassLocationsInvert = invert(cloneClassLocations);
	
	lrel[int,CloneClass] filteredCloneClassByLevel;
	
	filteredCloneClassByLevel = for (k:<level,cloneClass> <- cloneClassLocations) {
		set[str] locations = cloneClassLocations[k];
		set[CloneClass] compareWith = {
			cl | set[str] l <- cloneClassLocationsInvert 
			,locations <= l
			,<size, cl> <- cloneClassLocationsInvert[l]
			,size > level
		};
		
		if(!oneContainsChild(cloneClass, compareWith)) {
			append <level, cloneClass>;
		}
	}
	
	return index(filteredCloneClassByLevel);
}

public set[str] locationsForLevelCloneClass(CloneClass input) = { lhs.uri | lhs <- input };

public bool oneContainsChild(CloneClass child, set[CloneClass] parents) = 
	any(parent <- parents, containsChild(child, parent)); 

public bool containsChild(CloneClass child, CloneClass parent) =
	child == { childElem | childElem <- child, containedBy(childElem, parent) };

public bool containedBy(loc item, CloneClass container) {
	return any(c <- container, c.uri == item.uri, item <= c);
}

public bool isBeginBeforeOrEqual(loc a, loc b) = a.uri == b.uri && a.begin <= b.begin;

public bool isEndBeforeOrEqual(loc a, loc b) = a.uri == b.uri && a.end <= b.end;
	
public loc cloneClassItemWithStartAndEnd(str f, beginLine, endLine) {
	return |file://<f>|(beginLine,endLine-beginLine+1,<beginLine,0>,<endLine,0>);
}

public test bool containsChild1a() = containsChild(
	{ cloneClassItemWithStartAndEnd("foo", 2, 14) },
	{ cloneClassItemWithStartAndEnd("foo", 2, 15) }
);
public test bool containsChild1b() = containsChild(
	{ cloneClassItemWithStartAndEnd("foo", 3, 15) },
	{ cloneClassItemWithStartAndEnd("foo", 2, 15) }
);
public test bool containsChild1c() = containsChild(
	{ cloneClassItemWithStartAndEnd("foo", 3, 14) },
	{ cloneClassItemWithStartAndEnd("foo", 2, 15) }
);

public test bool containsChild2() = !containsChild(
	{ cloneClassItemWithStartAndEnd("foo", 2, 15) },
	{ cloneClassItemWithStartAndEnd("foo", 2, 14) }
);

public test bool containsChild3() = containsChild(
	{ cloneClassItemWithStartAndEnd("foo", 2, 15) },
	{ cloneClassItemWithStartAndEnd("foo", 2, 15) }
);

public test bool testCleanupNestedBlockForSingleBlock() {
	input = ( 6 : { { cloneClassItemWithStartAndEnd("foo", 2, 10) } } );
	return input == cleanupNestedBlocks(input);
}

public test bool testCleanupNestedBlockForNestedWithTotalOverlapOnStart() {
	six =  { { cloneClassItemWithStartAndEnd("foo", 2, 10) } };
	five = { { cloneClassItemWithStartAndEnd("foo", 2, 9)} };
	input = ( 
		6 : six,
		5 : five
	);
	return cleanupNestedBlocks(input) == (
		6 : six
	);
}

public test bool testCleanupNestedBlockForNestedWithTotalOverlapOnEnd() {
	six = { { cloneClassItemWithStartAndEnd("foo",2,15) } };
	five = { { cloneClassItemWithStartAndEnd("foo",3,15) } };
	input = ( 
		6 : six,
		5 : five
	);
	return cleanupNestedBlocks(input) == (
		6 : six
	);
}


public test bool testCleanupNestedBlockForNestedWithKeysInBetween() {
	six  = { {cloneClassItemWithStartAndEnd("foo", 2, 7) } };
	five = { {cloneClassItemWithStartAndEnd("bar", 1, 6) } };
	four = { {cloneClassItemWithStartAndEnd("foo", 3, 6) } };
	input = ( 
		6 : six,
		5 : five,
		4 : four
	);
	return cleanupNestedBlocks(input) == (
		6 : six,
		5 : five
	);
}

public test bool testCleanupNestedBlockMultipleFiles() {
	
	six  = {
		{ cloneClassItemWithStartAndEnd("foo", 2, 7) },
		{ cloneClassItemWithStartAndEnd("bar", 2, 7) }
	};
	four  = {
		{ cloneClassItemWithStartAndEnd("foo", 3, 6) },
		{ cloneClassItemWithStartAndEnd("bar", 3, 6) } 
	};
	
	input = ( 
		6 : six,
		4 : four
	);
	return cleanupNestedBlocks(input) == (
		6 : six
	);
}

public test bool testCleanupNestedBlockPartialOverlap() {
	six  = { {
		cloneClassItemWithStartAndEnd("foo", 2, 7),
		cloneClassItemWithStartAndEnd("bar", 2, 7)
	} };
	four  = { {
		cloneClassItemWithStartAndEnd("foo", 3, 6),
		cloneClassItemWithStartAndEnd("other", 3, 6) 
	} };
	
	input = ( 6 : six, 4 : four);
	return cleanupNestedBlocks(input) == (
		6 : six,
		4 : four
	);
}

public test bool testCleanupWhereOnlyOneFileMatchesClassWithTwoFiles() {
	six  = { {
		cloneClassItemWithStartAndEnd("foo", 2, 7),
		cloneClassItemWithStartAndEnd("bar", 2, 7)
	} };
	four  = { {
		cloneClassItemWithStartAndEnd("foo", 3, 6)
	} };
	
	input = ( 6 : six, 4 : four);
	return cleanupNestedBlocks(input) == (
		6 : six
	);
}

public test bool testCleanupWithChain() {
	six = { {
		cloneClassItemWithStartAndEnd("foo", 2, 7)
	} };
	input = ( 6 : six, 5 : six, 4 : six, 3 : six, 2: six);
	return cleanupNestedBlocks(input) == (
		6 : six
	);
}


public void performanceTestCleanupNestedBlocks(int height, int width, int size) {
	map[int, set[CloneClass]] input = ();
	for (int i <- [1.. height+1]) {
		set[CloneClass] level = {};
		for (int j <- [1.. height+1]) {
			levelData = {cloneClassItemWithStartAndEnd("file<j>_<x>", 2 + i, 7 + i)
					  | x <- [0..size] };
		    level += {levelData};
		}
		input[i] = level;
	}
	
	executeDuration("Performance Test Cleanup Nested Blocks", () {
		cleanupNestedBlocks(input);
	});
}