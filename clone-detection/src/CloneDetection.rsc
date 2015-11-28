module CloneDetection

import DateTime;
import IO;
import List;
import Set;
import String;
import ListRelation;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import Map;

import AnonymizeStatements;
import DataFlowFlattener;

public loc projectLoc = |project://hello-world-java/src/nl/simple|;
public M3 model;

public M3 loadModel() {
	model = createM3FromEclipseProject(projectLoc);
	return model;
}

public data StatementPointer = statementPointer(loc l, Statement s);
 
public void  mainFunction(model) {
	println("Foo");
	
	lrel[Statement, Statement] normalized = [];
	int i = 1;
	for (m <- methods(model), m.file == "foo2(int)", /\/DuplicationWithOneLineRemoved\// := m.path) {
		println("Handle method (<i>): <m.file>, <m>");
		i += 1;
		Declaration d = getMethodASTEclipse(m, model = model);
		normalized += normalizeMethod(d);
	}
	
	lrel[Statement,Statement] anonymousRel = [];
	for ( normStatement <- toSet(range(normalized))) {
		anonymousRel += anonimizeStatement(normStatement);
	}
	
	lrel[Statement, Statement] whole = invert(anonymousRel) o invert(normalized);
	iprintln(size(whole));
	map[Statement,set[Statement]] wholeIndex = index(whole);
	iprintln((k@src: getOneFrom(wholeIndex[k])@src | k <- wholeIndex));
	
	return;
	invert(anonymousRel);
	for (rhs <- range(anonymousRel)) {
		list[StatementNode] l = flatten(rhs);
		if (size(l) > 1) {
			//iprintln(l);
			iprintln(size(l));
			iprintln(l);
		}
		//return;
	}
}


public lrel[Statement,Statement] normalizeMethod(Declaration d) {
	lrel[Statement,Statement] r = [];
	visit(d) {
		case Statement s:
			r += <s,s>;
	}
	return r;
}