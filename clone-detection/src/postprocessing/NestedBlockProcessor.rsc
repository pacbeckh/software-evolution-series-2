module postprocessing::NestedBlockProcessor

import List;
import Map;
import Set;
import IO;
import DateTime;


public map[int, set[rel[loc,loc]]] cleanupNestedBlocks(map[int, set[rel[loc,loc]]] input) {
	list[int] sortedKeys = sort(toList(domain(input)));
	
	map[tuple[int,rel[loc,loc]],set[str]] cloneClassLocations
		= (<k,levelCloneClass> : locationsForLevelCloneClass(levelCloneClass) | k <- sortedKeys, levelCloneClass <- input[k]);
	map[set[str], rel[int,rel[loc,loc]]] cloneClassLocationsInvert = invert(cloneClassLocations);
	
	map[int, set[rel[loc,loc]]] answer = ();
	lrel[int,rel[loc,loc]] filteredCloneClassByLevel;
	
	filteredCloneClassByLevel = for (k:<level,cloneClass> <- cloneClassLocations) {
		set[str] locations = cloneClassLocations[k];
		set[rel[loc,loc]] compareWith = {
			cl | set[str] l <- cloneClassLocationsInvert 
			,locations <= l
			,<size, cl> <- cloneClassLocationsInvert[l]
			,size > level
		};
		
		if(!oneContainsChild(cloneClass, compareWith)) {
			append <level, cloneClass>;
		}
	}
	
	for (<level, cloneClass> <- filteredCloneClassByLevel) {
		if (answer[level]?) {
			answer[level] += { cloneClass };
		} else {
			answer[level] = { cloneClass };
		}
	}
	return answer;
}

public set[str] locationsForLevelCloneClass(rel[loc,loc] input) = { lhs.uri | <lhs,_> <- input };

public bool oneContainsChild(rel[loc,loc] child, set[rel[loc,loc]] parents) = 
	any(parent <- parents, containsChild(child, parent)); 

public bool containsChild(rel[loc,loc] child, rel[loc,loc] parent) =
	child == { childElem | childElem <- child, containedBy(childElem, parent) };

public bool containedBy(tuple[loc,loc] item, rel[loc,loc] container) {
	return any(c <- container, isBeginBeforeOrEqual(c[0],item[0]) && isEndBeforeOrEqual(item[1],c[1]));
}

public bool isBeginBeforeOrEqual(loc a, loc b) = a.uri == b.uri && a.begin <= b.begin;

public bool isEndBeforeOrEqual(loc a, loc b) = a.uri == b.uri && a.end <= b.end;
	
public test bool containsChild1a() = containsChild(
	{< |file://foo|(0,0,<2,0>,<6,0>), |file://foo|(0,0,<10,0>,<14,0>)>},
	{< |file://foo|(0,0,<2,0>,<7,0>), |file://foo|(0,0,<10,0>,<15,0>)> }
);
public test bool containsChild1b() = containsChild(
	{< |file://foo|(0,0,<3,0>,<7,0>), |file://foo|(0,0,<11,0>,<15,0>)>},
	{< |file://foo|(0,0,<2,0>,<7,0>), |file://foo|(0,0,<10,0>,<15,0>)> }
);
public test bool containsChild1c() = containsChild(
	{< |file://foo|(0,0,<3,0>,<6,0>), |file://foo|(0,0,<11,0>,<14,0>)>},
	{< |file://foo|(0,0,<2,0>,<7,0>), |file://foo|(0,0,<10,0>,<15,0>)> }
);

public test bool containsChild2() = !containsChild(
	{< |file://foo|(0,0,<2,0>,<7,0>), |file://foo|(0,0,<10,0>,<15,0>)>},
	{< |file://foo|(0,0,<2,0>,<6,0>), |file://foo|(0,0,<10,0>,<14,0>)>}
);

public test bool containsChild3() = containsChild(
	{< |file://foo|(0,0,<2,0>,<7,0>), |file://foo|(0,0,<10,0>,<15,0>)>},
	{< |file://foo|(0,0,<2,0>,<7,0>), |file://foo|(0,0,<10,0>,<15,0>)>}
);



public test bool testCleanupNestedBlockForSingleBlock() {
	input = ( 6 : { {< |file://foo|(0,0,<2,0>,<7,0>), |file://foo|(0,0,<10,0>,<15,0>)> } } );
	return input == cleanupNestedBlocks(input);
}

public test bool testCleanupNestedBlockForNestedWithTotalOverlapOnStart() {
	six = { {< |file://foo|(0,0,<2,0>,<7,0>), |file://foo|(0,0,<10,0>,<15,0>)> } };
	five = { {< |file://foo|(0,0,<2,0>,<6,0>), |file://foo|(0,0,<10,0>,<14,0>)>} };
	input = ( 
		6 : six,
		5 : five
	);
	return cleanupNestedBlocks(input) == (
		6 : six
	);
}

public test bool testCleanupNestedBlockForNestedWithTotalOverlapOnEnd() {
	six = { {< |file://foo|(0,0,<2,0>,<7,0>), |file://foo|(0,0,<10,0>,<15,0>)> } };
	five = { {< |file://foo|(0,0,<3,0>,<7,0>), |file://foo|(0,0,<11,0>,<15,0>)>} };
	input = ( 
		6 : six,
		5 : five
	);
	return cleanupNestedBlocks(input) == (
		6 : six
	);
}


public test bool testCleanupNestedBlockForNestedWithKeysInBetween() {
	six  = { {< |file://foo|(0,0,<2,0>,<2,10>), |file://foo|(0,0,<7,0>,<7,10>)> } };
	five = { {< |file://bar|(0,0,<1,0>,<1,10>), |file://bar|(0,0,<6,0>,<6,10>)> } };
	four = { {< |file://foo|(0,0,<3,0>,<3,10>),  |file://foo|(0,0,<6,0>,<6,10>)>} };
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
		{< |file://foo|(0,0,<2,0>,<2,10>), |file://foo|(0,0,<7,0>,<7,10>)> },
		{< |file://bar|(0,0,<2,0>,<2,10>), |file://bar|(0,0,<7,0>,<7,10>)> }
	};
	four  = { 
		{< |file://foo|(0,0,<3,0>,<3,10>), |file://foo|(0,0,<6,0>,<6,10>)> },
		{< |file://bar|(0,0,<3,0>,<3,10>), |file://bar|(0,0,<6,0>,<6,10>)> }
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
		<|file://foo|(0,0,<2,0>,<2,10>), |file://foo|(0,0,<7,0>,<7,10>)>,
		<|file://bar|(0,0,<2,0>,<2,10>), |file://bar|(0,0,<7,0>,<7,10>)> 
	} };
	four  = { {
		< |file://foo|(0,0,<3,0>,<3,10>), |file://foo|(0,0,<6,0>,<6,10>)>,
		< |file://otherfile|(0,0,<3,0>,<3,10>), |file://otherfile|(0,0,<6,0>,<6,10>)> 
	} };
	
	input = ( 6 : six, 4 : four);
	return cleanupNestedBlocks(input) == (
		6 : six,
		4 : four
	);
}

public test bool testCleanupWhereOnlyOneFileMatchesClassWithTwoFiles() {
	six  = { {
		<|file://foo|(0,0,<2,0>,<2,10>), |file://foo|(0,0,<7,0>,<7,10>)>,
		<|file://bar|(0,0,<2,0>,<2,10>), |file://bar|(0,0,<7,0>,<7,10>)> 
	} };
	four  = { {
		< |file://foo|(0,0,<3,0>,<3,10>), |file://foo|(0,0,<6,0>,<6,10>)>
	} };
	
	input = ( 6 : six, 4 : four);
	return cleanupNestedBlocks(input) == (
		6 : six
	);
}

public test bool testCleanupWithChain() {
	six = { {
		<|file://foo|(0,0,<2,0>,<2,10>), |file://foo|(0,0,<7,0>,<7,10>)>
	} };
	input = ( 6 : six, 5 : six, 4 : six, 3 : six, 2: six);
	return cleanupNestedBlocks(input) == (
		6 : six
	);
}


public void performanceTestCleanupNestedBlocks(int height, int width, int size) {
	begin = now();
	
	map[int, set[rel[loc,loc]]] input = ();
	for (int i <- [1.. height+1]) {
		set[rel[loc,loc]] level = {};
		for (int j <- [1.. height+1]) {
			levelData = {<|file://foo|(0,0,<2,0>,<2,10 + i>) + "file<j>_<x>", |file://foo|(0,0,<7,0>,<7,10 + i>) + "file<j>_<x>">
					  | x <- [0..size] };
		    level += {levelData};
		}
		input[i] = level;
	}
	
	cleanupNestedBlocks(input);
	end = now();
	Duration duration = end - begin;
	println("<printTime(now())> Took| <duration.minutes>:<duration.seconds>:<duration.milliseconds>");
}