module AnonymizeStatements

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;

public tuple[Statement,Statement] anonimizeStatement(Statement s) {
	res = visit(s) {
		case \label(_, b) => \label("label0", b)
		case \break(_) => \break("label0")
		case \variable(_,dim) => \variable("id0",dim)
		case \variable(_,dim, e) => \variable("id0",dim, e)
		case \simpleName(_) => \simpleName("id0")
		case \number(_) => \number("0")
		case \booleanLiteral(_) => \booleanLiteral(false)
		case \stringLiteral(_) => \stringLiteral("str0")
		case \characterLiteral(_) => \characterLiteral("c")
	}
	return <s,res>;
}


//Test Code
public bool anonimizeEqual(Expression l, Expression r) = anonimizeEqual(expressionStatement(l), expressionStatement(r));
public bool anonimizeEqual(Statement l, Statement r) {
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
