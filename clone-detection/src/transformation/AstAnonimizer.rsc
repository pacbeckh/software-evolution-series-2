module transformation::AstAnonimizer

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import List;

import Config;
import Domain;

public tuple[Statement,Statement] anonimizeStatement(Statement s) {
	iprintln("--------INPUT-------");
	iprintln(s);
	iprintln("-------/INPUT-------");
	
	res = visit(s) {
		case x:\variable(_,dim) : {
			iprintln("Found variable");
			//Only variables spotted so far were inside a declaration: Car <car> = new Car().
			insert \variable("id0",dim);		
		}
		case x:\variable(_,dim, e) : {
			iprintln("Found variable");
			//Only variables spotted so far were inside a declaration: Car <car> = new Car().
			insert \variable("id0",dim,e);		
		}
		case x:\simpleName(a) => \cast(toType(x@typ), \simpleName("id0"))
			when x@typ != \unresolved() 
		
		case x:\qualifiedName(\simpleName(s1), \simpleName(s2)) : {
			insert \simpleName("<s1>.<s2>");
		}
		case x:\qualifiedName(\simpleName(s1), \cast(\simpleType(\simpleName(s2)),_)) : {
			insert \simpleName("<s1>.<s2>");
		}
		case x:\qualifiedName(\cast(\simpleType(\simpleName(s1)),_), \cast(\simpleType(\simpleName(s2)),_)) : {
			insert \simpleName("<s1>.<s2>");
		}
		
		case Expression x => \cast(toType(x@typ), \simpleName("id0"))
			when CONFIG_ANONYMOUS_LITERALS &&  
				(\number(_) := x || \booleanLiteral(_) := x || \stringLiteral(_) := x || \characterLiteral(_) := x)
		 
		 case x:\qualifiedType(_, _) :{
		 	iprintln("Found qualifiedType");
		 	throw "";
		 }
		 case x:\unionType(_) : {
		 	iprintln("Found unionType");
		 	throw "";
		 }
		 case x:\upperbound(Type \type): {
		 	iprintln("Found upperbound");
		 	throw "";
		 }
		 case x:\lowerbound(Type \type): {
		 	iprintln("Found lowerbound");
		 	throw "";
		 }
		 
		 
		// Clean up double cast
		case x:\cast(t, \cast(t2, e)) => \cast(t,e)		
		// Clean up double simpletype
		case x:\simpleType(\cast(Type t, _)) => t
		
	}
	
	println("--------RESULT--------");
	iprintln(res);
	iprintln("-------/RESULT-------");
	
	return <s,res>;
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

public list[AnonymousLink] getAnonimizedStatements(Declaration normalized) {
	list[AnonymousLink] answer = [];
	visit(normalized) {
		case \block(list[Statement] sts): {
			int i = size(sts);
			int weightSum = 0;
			NextLink next = noLink();
			while (i > 0) {
				i -= 1;
				Statement statement = sts[i];
				
				weightSum += statement@weight; 
				
				Statement anon = anonimizeStatement(statement)[1];
				AnonymousLink link = anonymousLink(anon, statement, next);
				link@maxWeight = weightSum;
				
				answer += link;
				next = aLink(link);
			}
		}
	}
	
	return answer;
}