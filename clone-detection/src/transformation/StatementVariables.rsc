module transformation::StatementVariables

import lang::java::jdt::m3::AST;

public list[str] statementToVariables(Statement s) {
	list[str] result = [];
	top-down visit(s) {
		case \variable(x,_): {result += x;}
		case \variable(x,_,_): {result += x;}
		case \simpleName(x): {result += x;}
		case \number(x): {result += x;}
		case \booleanLiteral(x): {result += "<x>";}
		case \stringLiteral(x): {result += x;}
		case \characterLiteral(x): {result += x;} 
	}
	
	return result;
} 
