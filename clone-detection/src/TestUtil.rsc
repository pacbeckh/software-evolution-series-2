module TestUtil

import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import lang::java::m3::Core;

import Domain; 
import List;
import IO;
import CloneDetection;

private loc projectLoc = |project://hello-world-java|;

private bool isInitialized = false;
private M3 testM3Model;
	
public M3 getTestM3() {
	if(!isInitialized) {
		testM3Model = createM3FromEclipseProject(projectLoc);
	}
	
	return testM3Model;
}

public list[AnonymousLink] getLinksForFile(str fileName) {
	return head([anonimizeAndNormalizeFile(cu) |<cu,_> <- getTestM3()@containment, isCompilationUnit(cu), cu.file==fileName]);
}

public void printLinkPairs(list[LinkPair] pairs){
	for(pair <- pairs){
		leftLoc = head(pair.leftStack).normal@src;
		rightLoc = head(pair.rightStack).normal@src;
		
		println("Pair from <leftLoc.file>:<leftLoc.begin> to <rightLoc.file>:<rightLoc.begin>");
	}
}

public void printEvolvedLinkPairs(list[LinkPair] pairs){
	for(pair <- pairs){
		leftStart = last(pair.leftStack).normal@src;
		rightStart= last(pair.rightStack).normal@src;
		
		leftEnd = head(pair.leftStack).normal@src;
		rightEnd = head(pair.rightStack).normal@src;
		
		println("<leftStart.file>:<leftStart.begin.line> to <leftEnd.begin.line> | Is a pair With | <rightStart.file>:<rightStart.begin.line> to <rightEnd.begin.line>");
		
	}
}