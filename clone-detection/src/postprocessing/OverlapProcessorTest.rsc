module postprocessing::OverlapProcessorTest

import Domain;
import postprocessing::OverlapProcessor;

test bool shouldRemoveEmptyResults() {
	input = (1: {{fragment(1,2), fragment(2,3)}});
	return cleanOverlappingFragments(input) == (1:{});
}

// 1  |
// 2  | |
// 3    | | 
// 4      |
// The middle should be removed
test bool testOverlap1() {
	f1 = fragment(1,2);
	f2 = fragment(2,3);
	f3 = fragment(3,4);
	
	return {f1,f3} == processCloneClass({f1,f2,f3}); 
}


// 1  |
// 2  | |
// 3    | |
// 4	  | | 
// 5        |
// None should be removed
test bool testOverlap2() {
	f1 = fragment(1,2);
	f2 = fragment(2,3);
	f3 = fragment(3,4);
	f4 = fragment(4,5);
	
	return {f1,f2,f3,f4} == processCloneClass({f1,f2,f3,f4}); 
}

// 1  |
// 2  | |
// 3    |
// All should be removed
test bool testOverlap3() {
	f1 = fragment(1,2);
	f2 = fragment(2,3);
	
	result = processCloneClass({f1,f2});
	
	return result == {}; 
}


// 1  |
// 2  | |
// 3    |
// 4  |
// 5  |  
// Nonde should be removed
test bool testOverlap4() {
	f1 = fragment(1,2);
	f2 = fragment(2,3);
	f3 = fragment(4,5);
	
	result = processCloneClass({f1,f2,f3});
	
	return result == {f1,f2,f3}; 
}

test bool testOverlaps() {
	return fragmentsOverlap(
		|file://x|(0,1,<2,0>,<3,100>),
		|file://x|(0,1,<1,0>,<2,100>)
	);
}

test bool testFragmentsOverlap(){
	loc f1 = |file://x|(0,1,<1,0>,<2,10>);
	loc f2 = |file://x|(0,1,<2,11>,<3,1>);
	
	// false because f2 starts after f1 (note the column of the start,end)
	return !fragmentsOverlap(f1, f2);
}

test bool testFragmentsOverlap2(){
	loc f1 = |file://x|(0,1,<1,0>,<2,11>);
	loc f2 = |file://x|(0,1,<2,10>,<3,1>);
	
	// true because f1 starts in f2 (note the column of the start,end)
	return fragmentsOverlap(f1, f2);
}

test bool testFragmentsOverlap3(){
	loc f1 = |file://x|(0,1,<1,0>,<2,11>);
	// true because they are exactly the same
	return fragmentsOverlap(f1, f1);
}

test bool testFragmentsOverlap4(){
	// true because they start and end at the same statement exactly the same
	return fragmentsOverlap(
		fragment("x", 1, 2),
		fragment("x", 2, 3)
	);
}

test bool testFragmentsOverlapDifferentFiles(){
	return !fragmentsOverlap(
		fragment("x", 1, 2),
		fragment("y", 1, 2)
	);
}

public loc fragment(int startLine, int endLine) = fragment("x", startLine, endLine);

public loc fragment(str file, int startLine, int endLine) = |file://<file>|(0,1,<startLine,0>,<endLine,100>);
