module postprocessing::OverlapProcessorTest

import IO;

import Domain;
import postprocessing::OverlapProcessor;

// 1  |
// 2  | |
// 3    | | 
// 4      |
// The middle should be removed
test bool overlap1() {
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
test bool overlap2() {
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
test bool overlap3() {
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
test bool overlap4() {
	f1 = fragment(1,2);
	f2 = fragment(2,3);
	f3 = fragment(4,5);
	
	result = processCloneClass({f1,f2,f3});
	
	return result == {f1,f2,f3}; 
}


test bool testfragmentsOverlap(){
	loc f1start = |file://x|(0,1,<1,0>,<1,10>);
	loc f1end = |file://x|(0,1,<2,0>,<2,10>);
	loc f2start = |file://x|(0,1,<2,11>,<2,100>);
	loc f2end = |file://x|(0,1,<3,0>,<3,1>);
	
	//false because f2 starts after f1 (note the column of the start,end)
	return !fragmentsOverlap(<f1start,f1end>, <f2start,f2end>);
}

test bool testfragmentsOverlap2(){
	loc f1start = |file://x|(0,1,<1,0>,<1,10>);
	loc f1end = |file://x|(0,1,<2,0>,<2,11>);
	loc f2start = |file://x|(0,1,<2,10>,<2,100>);
	loc f2end = |file://x|(0,1,<3,0>,<3,1>);
	
	//true because f1 starts in f2 (note the column of the start,end)
	return fragmentsOverlap(<f1start,f1end>, <f2start,f2end>);
}

test bool testfragmentsOverlap3(){
	loc f1start = |file://x|(0,1,<1,0>,<1,10>);
	loc f1end = |file://x|(0,1,<2,0>,<2,11>);
	
	//true because they are exactly the same
	return fragmentsOverlap(<f1start,f1end>, <f1start,f1end>);
}

test bool testfragmentsOverlap4(){
	loc f1start = |file://x|(0,1,<1,0>,<1,10>);
	loc f1end = |file://x|(0,1,<2,0>,<2,11>);
	loc f2start = f1end;
	loc f2end = |file://x|(0,1,<3,0>,<3,1>);
	
	//true because they start and end at the same statement exactly the same
	return fragmentsOverlap(<f1start,f1end>, <f2start,f2end>);
}

private tuple[loc,loc] fragment(int startLine, int endLine) = <line(startLine), line(endLine)>;

private loc line(int line) = |file://x1|(0,1,<line,0>,<line,100>);
