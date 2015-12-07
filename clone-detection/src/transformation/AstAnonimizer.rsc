module transformation::AstAnonimizer

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import List;
import Map;
import Set;


import Config;
import Domain;


public list[AnonymousLink] getAnonimizedStatements(Statement normalized) {
	map[loc, Statement] anonCache = ();
	
	list[AnonymousLink] answer = [];
	visit(normalized) {
		case b:\block(list[Statement] sts): {
			int i = size(sts);
			int weightSum = 0;
			NextLink next = noLink();
			while (i > 0) {
				i -= 1;
				Statement statement = sts[i];
				
				weightSum += statement@weight; 
				
				Statement anon = anonimizeStatement(statement, anonCache);
				anonCache += (statement@src : anon); 
				
				AnonymousLink link = anonymousLink(anon, statement, next);
				link@maxWeight = weightSum;
				
				answer += link;
				next = aLink(link);
			}
		}
	}
	
	return answer;
}

public Statement anonimizeStatement(Statement statement, map[loc, Statement] anonCache) {
	//iprintln("--------INPUT-------");
	//iprintln(statement);
	//iprintln("-------/INPUT-------");
	
	res = top-down-break visit(statement) {
		case Statement s => anonCache[s@src] when s@src? && anonCache[s@src]?
		case Expression e => anonimizeExpression(e)
		case Type t => anonimizeType(t)
	}
	
	//println("--------RESULT--------");
	//iprintln(res);
	//iprintln("-------/RESULT-------");
	
	return res;
}

private Type anonimizeType(Type t) {
	return top-down-break visit(t) {
		case x:\simpleType(_) => x 
		case x:\qualifiedType(_, _) :	throw "Unhandled Type: qualifiedType";
		case x:\unionType(_) : 			throw "Unhandled Type: unionType";
		case x:\upperbound(Type \type): throw "Unhandled Type: upperbound";
		case x:\lowerbound(Type \type): throw "Unhandled Type: lowerbound";
	}
}

private Expression anonimizeExpression(Expression expression) {
	return top-down-break visit(expression) {
		case Type t : anonimizeType(t);
	
		case x:\variable(_, dim) => \variable("id0", dim)
		case x:\variable(_, dim, e) => \variable("id0",dim, anonimizeExpression(e))
		case x:\simpleName(a) =>\cast(toType(x@typ), \simpleName("id0"))
		
		case Expression x => \cast(toType(x@typ), \simpleName("id0"))
			when CONFIG_ANONYMOUS_LITERALS &&  
				(\number(_) := x || \booleanLiteral(_) := x || \stringLiteral(_) := x || \characterLiteral(_) := x)
		 
		// Prevent double cast
		case \cast(t, simpleName(s)) => \cast(t, simpleName("id0"))
		
		// Keep qualifiedNames intact
		case x:\qualifiedName(_,_) => x
	}
}

private Type toType(\array(TypeSymbol component, int dimension)) = \arrayType(toType(component));
private Type toType(\class(loc decl, list[TypeSymbol] _)) = \simpleType(\simpleName(decl.file));
private Type toType(\interface(loc decl, list[TypeSymbol] _)) = \simpleType(\simpleName(decl.file));
private Type toType(\object()) = \simpleType(\simpleName("Object"));
private Type toType(\int()) = \int();
private Type toType(\float()) = \float();
private Type toType(\double()) = \double();
private Type toType(\short()) = \short();
private Type toType(\boolean()) = \boolean();
private Type toType(\char()) = \char();
private Type toType(\byte()) = \byte();
private Type toType(\long()) = \long();
private Type toType(\void()) = \void();
private Type toType(\null()) = \null();

private default Type toType(TypeSymbol t) {
	throw "unhandled type <t>";
}