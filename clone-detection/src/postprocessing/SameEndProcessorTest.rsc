module postprocessing::SameEndProcessorTest


import postprocessing::SameEndProcessor;


test bool testPurgeSmallerClassWithCorrectOverlap() {
	cl6_1 = {
		|file://file1a|(0,30,<0,0>,<2,10>),
		|file://file1b|(0,30,<1,0>,<3,10>)
	};
	cl5_1 = {
		|file://file1a|(10,20,<1,0>,<2,10>),
		|file://file1b|(10,20,<2,0>,<3,10>)
	};
	cl5_2 = {
		|file://file2a|(10,20,<1,0>,<2,10>),
		|file://file2b|(10,20,<2,0>,<3,10>)
	};
	result = cleanupCloneClassesWithSameEnd((
		6 : { cl6_1 },
		5 : { cl5_1, cl5_2}
	));
	
	return result == (
		6 : { cl6_1 },
		5 : { cl5_2}
	);
}

test bool testNotPurgeSmallerClassWithIncorrectOverlap() {
	cl6_1 = {
		|file://file1a|(0,30,<0,0>,<2,10>),
		|file://file1b|(0,30,<1,0>,<3,10>)
	};
	cl5_1 = {
		|file://file1a|(10,20,<1,0>,<2,10>),
		|file://file1b|(10,20,<2,0>,<3,10>),
		|file://file1c|(10,20,<4,0>,<4,10>)
	};
	cl5_2 = {
		|file://file2a|(10,20,<1,0>,<2,10>),
		|file://file2b|(10,20,<2,0>,<3,10>)
	};
	result = cleanupCloneClassesWithSameEnd((
		6 : { cl6_1 },
		5 : { cl5_1, cl5_2}
	));
	
	return result == (
		6 : { cl6_1 },
		5 : { cl5_1, cl5_2}
	);
}