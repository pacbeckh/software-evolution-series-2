module AnonymizeStatements

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

public lrel[Statement,Statement] anonimizeStatatement(Statement s, lrel[Statement,Statement] result) {
	res = visit(s) {
		case \label(_, b) => \break("label0", b)
		case \break(_) => \break("label0")
		case \variable(_,dim) => \variable("id0",dim)
		case \variable(_,dim, e) => \variable("id0",dim, e)
		case \simpleName(_) => \simpleName("id0")
		case \number(_) => \number("0")
		case \booleanLiteral(_) => \booleanLiteral(false)
		case \stringLiteral(_) => \stringLiteral("str0")
		case \characterLiteral(_) => \characterLiteral("c")
	}
	result += <s,res>;
	return result;
}