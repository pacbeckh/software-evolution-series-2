module CloneDetection

import DateTime;
import IO;
import List;
import Set;
import String;
import Set;
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
	list[list[Statement]]  total = [];
	
	for (m <- methods(model)) {
		println("Handle method: <m.file>");
		Declaration d = getMethodASTEclipse(m, model = model);
		x = handleRootBlocks(d);
		total += x;
	}
}

public list[list[Statement]]  handleRootBlocks(Declaration d) {
	list[list[Statement]] l = [];
	top-down-break visit(d) {
		case b: \block(list[Statement] statements):
			l += [doSomeWithBlock(b)]; 
	}
	int c = 0;
	visit (d) {
		case Statement s: c+=1;
	}
	iprintln("Count: <c>");
	return l;
}

public list[Statement] doSomeWithBlock(x:\block(list[Statement] statements)) {
	println("Block <x@src>");
	list[lrel[Statement,Statement]] hashes = [rewriteStatement(s) | s <- statements];
	//iprintln(hashes);
	//hashes@block = x;
	return [ rhs | x <- hashes, <lhs,rhs> <- x];
}

anno loc Statement@origin;

public lrel[Statement,Statement] rewriteStatement(Statement s) = anonimizeStatatement(s, []);