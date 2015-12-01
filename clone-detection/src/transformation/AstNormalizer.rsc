module transformation::AstNormalizer

import lang::java::m3::AST; 
import IO;
import String;
import List;

import Config;

public Declaration normalizeMethods(Declaration declaration) {
	return visit (declaration) {
		case \method(\return, name, parameters, exceptions, impl) =>
			\method(\return, name, parameters, exceptions, normalize(impl))
		case \constructor(name, parameters, exceptions, impl) =>
			\constructor(name, parameters, exceptions, normalize(impl))
	}
}

anno int Statement @ weight;

public Statement normalize(Statement statement) {
	return visit(statement) {
		case \if(Expression e, Statement s) => 
			withWeight(\if(e, addBlock(s)), [s])
		case \if(Expression e, Statement s1, Statement s2) =>
			withWeight(\if(e, addBlock(s1), addBlock(s2)), [s1,s2])
		case \do(Statement s, Expression e) =>  
			withWeight(\do(addBlock(s), e), [s])
		case \foreach(Declaration d, Expression e, Statement s) =>
			withWeight(\foreach(d, e, addBlock(s)), [s])
    	case \for(list[Expression] initializers, Expression condition, list[Expression] updaters, Statement body) => 
    		withWeight(\for(initializers, condition, updaters, addBlock(body)), [body])
    	case \for(list[Expression] initializers, list[Expression] updaters, Statement body) => 
    		withWeight(\for(initializers, updaters, addBlock(body)), [body])
		case \label(str name, Statement body) => 
    		withWeight(\label(name, addBlock(body)), [body])
		case \catch(Declaration exception, Statement body) => 
			withWeight(\catch(exception, addBlock(body)), [body])
     	case \while(Expression condition, Statement body) => 
     		withWeight(\while(condition, addBlock(body)), [body])
    	case \synchronizedStatement(Expression lock, Statement body) =>
    		withWeight(\synchronizedStatement(lock, addBlock(body)), [body])
    		
		case s:\try(Statement body, list[Statement] catchClauses) =>
     		withWeight(s, catchClauses)
     	case s:\try(Statement body, list[Statement] catchClauses, Statement final) =>
     		withWeight(s, catchClauses + final)
 		case s:\switch(Expression expression, list[Statement] statements) => 
     		withWeight(s, statements)
     		
     	case b:\block(list[Statement] statements) =>
     		withWeight(b)

		case Statement s => withWeight(s)    	
    	
    	//Normalize operands, but only if we are absolutely sure the method has no side effects.
    	case \infix(Expression lhs, str operator, Expression rhs) => 
    		\infix(lhs, "=", \infix( lhs, substring(operator, 0, size(operator) - 1 ), rhs))
	    		when CONFIG_NORMALIZE_STATEMENTS && operator in ["+=", "*=", "/=", "-=", "%=", "&=", "|=", "^=", "\>\>=", "\<\<=", "\>\>\>="] 
    		
		case \infix(Expression lhs, "\<", Expression rhs) => \infix(rhs, "\>", lhs)
    			when CONFIG_NORMALIZE_STATEMENTS && !couldHaveSideEffects(rhs) && !couldHaveSideEffects(lhs)
    		
		case \infix(Expression lhs, "\<=", Expression rhs) => \infix(rhs, "\>=", lhs)
    			when CONFIG_NORMALIZE_STATEMENTS && !couldHaveSideEffects(rhs) && !couldHaveSideEffects(lhs)
	}
}

private Statement withWeight(b:\block(list[Statement] statements)) {
	b@weight = getWeight(statements);
	return b;
}

private default Statement withWeight(Statement statement) {
	statement@weight = 1;
	return statement;
}

private Statement withWeight(Statement parent, list[Statement] children) {
	parent@weight = getWeight(children) + 1;
	return parent;
}

private int getWeight(list[Statement] statements) =	sum([0] + [s@weight | Statement s <- statements]);

private Statement addBlock(Statement statement) {
	return \block(_) := statement ? statement : withWeight(\block([statement]));
}

private bool couldHaveSideEffects(Expression expr) {
	visit(expr) {
		case \methodCall(_,_,_) : return true;
    	case \methodCall(_,_,_,_) : return true;
    	case \assignment(_,_,_) : return true;
    	case \postfix(_,_) : return true;
    	case \prefix(_,_) : return true;
	}
	
	return false;
}