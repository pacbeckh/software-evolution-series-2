module CloneDetection

import DateTime;
import IO;
import List;
import Set;
import String;
import ListRelation;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import AnonymizeStatements;

public loc projectLoc = |project://hello-world-java|;
public M3 model;

public M3 loadModel() {
	model = createM3FromEclipseProject(projectLoc);
	return model;
}

public void  mainFunction(model) {
	println("Foo");
	
	lrel[Statement, Statement] normalized = [];
	for (m <- methods(model)) {
		println("Handle method: <m.file>");
		Declaration d = getMethodASTEclipse(m, model = model);
		normalized += normalizeMethod(d);
	}
	
	lrel[Statement,Statement] anonymousRel = [];
	for ( normStatement <- toSet(range(normalized))) {
		anonymousRel += anonimizeStatatement(normStatement);
	}
}


public lrel[Statement,Statement] normalizeMethod(Declaration d) {
	return [];
}