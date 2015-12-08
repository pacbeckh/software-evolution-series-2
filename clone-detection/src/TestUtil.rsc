module TestUtil

import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import lang::java::m3::Core;

import Domain; 
import List;
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