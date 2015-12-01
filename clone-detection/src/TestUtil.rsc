module TestUtil

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;

private loc projectLoc = |project://hello-world-java|;
//private loc projectLoc = |project://smallsql0.21_src|;

private bool isInitialized = false;
private M3 testM3Model;
	
public M3 getTestM3() {
	if(!isInitialized) {
		testM3Model = createM3FromEclipseProject(projectLoc);
	}
	
	return testM3Model;
}