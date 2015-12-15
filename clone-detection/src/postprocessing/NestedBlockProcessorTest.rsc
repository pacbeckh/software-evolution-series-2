module postprocessing::NestedBlockProcessorTest

import util::Timing;
import postprocessing::NestedBlockProcessor;


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