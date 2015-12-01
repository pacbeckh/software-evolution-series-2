module transformation::AstAnonimizerTest

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;

import transformation::AstAnonimizer;
import transformation::AstNormalizer;

import Config;
import Domain;

public test bool shouldAddCorrectMaxWeight(){
	Declaration d = \method(\void(), "a", [], [], \block([
		\expressionStatement(\simpleName("s1")),
		\if(\simpleName("s2"), 
			\block([
				\expressionStatement(\simpleName("s3")),
				\expressionStatement(\simpleName("s4"))
			])
		),
		\expressionStatement(\simpleName("s5"))		
	]));
	
	normalized = normalizeMethods(d);
	
	list[AnonymousLink] result = getAnonimizedStatements(normalized);
	
	return
		//s4 
		result[0]@maxWeight == 1 &&
		//s3
		result[1]@maxWeight == 2 &&
		//s5
		result[2]@maxWeight == 1 &&
		//if 
		result[3]@maxWeight == 4 &&
		//s1
		result[4]@maxWeight == 5;
		
} 



private bool anonimizeEqual(Expression l, Expression r) = anonimizeEqual(expressionStatement(l), expressionStatement(r));
private bool anonimizeEqual(Statement l, Statement r) {
	<_,resultL> = anonimizeStatement(l);
	<_,resultR> = anonimizeStatement(r);
	return resultL == resultR;
}

public test bool compareLabel(str l1, str l2, Statement s) = anonimizeEqual(\label(l2, s), \label(l1, s));
public test bool compareBreak(str l1, str l2) = anonimizeEqual(\break(l1), \break(l2));
public test bool compareVariable(str l1, str l2, int dim) = anonimizeEqual(\variable(l1, dim), \variable(l2, dim));
public test bool compareVariableWithExpr(str l1, str l2, int dim, Expression e) = anonimizeEqual(\variable(l1, dim, e), \variable(l2, dim, e));
public test bool compareSimpleName(str l1, str l2) = anonimizeEqual(\simpleName(l1), \simpleName(l2));
public test bool compareNumber(str n1, str n2) = anonimizeEqual(\number(n1), \number(n2));
public test bool compareBoolenLiteral(bool b1, bool b2) = anonimizeEqual(\booleanLiteral(b1), \booleanLiteral(b2));
public test bool compareBoolenLiteral(str s1, str s2) = anonimizeEqual(\stringLiteral(s1), \stringLiteral(s2));
public test bool compareBoolenLiteral(str s1, str s2) = anonimizeEqual(\characterLiteral(s1), \characterLiteral(s2));
