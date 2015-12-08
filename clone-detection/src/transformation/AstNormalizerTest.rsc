module transformation::AstNormalizerTest

import lang::java::jdt::m3::Core;
import lang::java::m3::AST; 
import IO;

import Config;
import TestUtil;

import transformation::AstNormalizer;

test bool eachStatementShouldHaveAWeight(Statement s) = eachStatementHasAWeight(normalize(s));

test bool eachStatementShouldHaveAWeight2() {
	for(m <- methods(getTestM3())) {
		Declaration d = getMethodASTEclipse(m, model = getTestM3());
		
		if(!eachStatementHasAWeight(normalizeMethods(d))) {
			return false;
		}
	}

	return true;
}

private bool eachStatementHasAWeight(node statement){
	visit(statement){
		case Statement s: {
			if(!s@weight?){
				println("No weights for found for: <s>");
				return false;
			}
		}
	}
	return true;
}

test bool normalizeIfWithExpression() {
	return \if(\simpleName("condition"), \block([\expressionStatement(\simpleName("ifblock"))])) 
		== normalize(\if(\simpleName("condition"), \expressionStatement(\simpleName("ifblock"))[@src=|file://a|])[@src=|file://a|]);
}

test bool normalizeIfElseWithExpression() {
	return \if(\simpleName("condition"), \block([\expressionStatement(\simpleName("ifblock"))]), \block([\expressionStatement(\simpleName("elseblock"))])) 
		== normalize(\if(\simpleName("condition"), \expressionStatement(\simpleName("ifblock"))[@src=|file://a|], \block([\expressionStatement(\simpleName("elseblock"))[@src=|file://a|]]))[@src=|file://a|]);
}

test bool normalizeDoWithExpression() {
	return \do(\block([\expressionStatement(null())]), \null()) 
	  	== normalize(\do(\expressionStatement(\null())[@src=|file://a|], \null())[@src=|file://a|]);
}

test bool normalizeInfix() {
	return \expressionStatement(\infix(\simpleName("a"),"=", \infix(\simpleName("a"), "\>\>", \simpleName("b"))))
		== normalize(\expressionStatement(\infix(\simpleName("a"),"\>\>=", \simpleName("b")))[@src=|file://a|]);
}

test bool normalizeInfixLessThan() {
	return \expressionStatement(\infix(\simpleName("b"), "\>", \simpleName("a")))
		== normalize(\expressionStatement(\infix(\simpleName("a"),"\<", \simpleName("b")))[@src=|file://a|]);
}

test bool normalizeInfixLessThanOrEqualTo() {
	return \expressionStatement(\infix(\simpleName("b"), "\>=", \simpleName("a")))
		== normalize(\expressionStatement(\infix(\simpleName("a"),"\<=", \simpleName("b")))[@src=|file://a|]);
}

test bool doNotNormalizeInfixLessThanIfThereAreSideEffects() {
	return \expressionStatement(\infix(\simpleName("a"),"\<=", \arrayAccess(\null(), \methodCall(false, "someMethods", []))))
		== normalize(\expressionStatement(\infix(\simpleName("a"),"\<=", \arrayAccess(\null(), \methodCall(false, "someMethods", []))))[@src=|file://a|]);
}



