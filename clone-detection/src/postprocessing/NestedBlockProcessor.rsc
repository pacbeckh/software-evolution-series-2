module postprocessing::NestedBlockProcessor

import List;
import Map;
import Set;
import IO;

public map[int, set[set[tuple[loc,loc]]]] cleanupNestedBlocks(map[int, set[set[tuple[loc,loc]]]] input) {
	list[int] sortedKeys = sort(toList(domain(input)));
	map[int, set[set[tuple[loc,loc]]]] answer = ();
	for (i <- [0.. size(sortedKeys)]) {
		int currentKey = sortedKeys[i];
		
		set[set[tuple[loc,loc]]] spectrum = {};
		for (j <- [i+1.. size(sortedKeys)]) {
			spectrum += input[sortedKeys[j]];
		}
		
		answer[currentKey] = filterByContainment(input[currentKey], spectrum);
	}
	return answer;
}

public set[set[tuple[loc,loc]]] filterByContainment(set[set[tuple[loc,loc]]] children, set[set[tuple[loc,loc]]] parents) {
	set[set[tuple[loc,loc]]] toRemove = {};
	for (child <- children) {
		for (parent <- parents) {
			if (containsChild(child, parent)) {
				toRemove += {child};
				break;
			}
		}
	}
	
	return children - toRemove;
}
public bool containsChild(set[tuple[loc,loc]] child, set[tuple[loc,loc]] parent) {
	return child == { childElem | childElem <- child, containedBy(childElem, parent) };
}

public bool containedBy(tuple[loc,loc] item, set[tuple[loc,loc]] container) {
	for (c <- container) {
		if (isBeginBeforeOrEqual(c[0],item[0]) && isEndBeforeOrEqual(item[1],c[1])) {
			return true;
		}
	}
	return false;
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
		6 : six,
		5 : {}
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
		6 : six,
		5 : {}
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
		5 : five,
		4 : {}
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
		6 : six,
		4 : {}
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
		6 : six,
		4 : {}
	);
}

public test bool testCleanupWithChain() {
	six = { {
		<|file://foo|(0,0,<2,0>,<2,10>), |file://foo|(0,0,<7,0>,<7,10>)>
	} };
	input = ( 6 : six, 5 : six, 4 : six, 3 : six, 2: six);
	return cleanupNestedBlocks(input) == (
		6 : six,
		5 : {},
		4 : {},
		3 : {},
		2 : {}
	);
}
