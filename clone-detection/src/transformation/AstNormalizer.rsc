module transformation::AstNormalizer

import lang::java::m3::AST; 
import List;
import String;

import Config;
import Domain;

public Statement normalize(Statement statement) {
	return visit(statement) {
		case z:\if(Expression e, Statement s) => 
			copySrc(z, withWeight(2, \if(e, addBlock(s)), [s]))
		case z:\if(Expression e, Statement s1, Statement s2) =>
			copySrc(z, withWeight(4, \if(e, addBlock(s1), addBlock(s2)), [s1,s2]))
		case z:\do(Statement s, Expression e) =>  
			copySrc(z, withWeight(2, \do(addBlock(s), e), [s]))
		case z:\foreach(Declaration d, Expression e, Statement s) =>
			copySrc(z, withWeight(2, \foreach(d, e, addBlock(s)), [s]))
    	case z:\for(list[Expression] initializers, Expression condition, list[Expression] updaters, Statement body) => 
    		copySrc(z, withWeight(2, \for(initializers, condition, updaters, addBlock(body)), [body]))
    	case z:\for(list[Expression] initializers, list[Expression] updaters, Statement body) => 
    		copySrc(z, withWeight(2, \for(initializers, updaters, addBlock(body)), [body]))
		case z:\label(str name, Statement body) => 
    		copySrc(z, withWeight(2, \label(name, addBlock(body)), [body]))
		case z:\catch(Declaration exception, Statement body) => 
			copySrc(z, withWeight(1, \catch(exception, addBlock(body)), [body]))
     	case z:\while(Expression condition, Statement body) => 
     		copySrc(z, withWeight(2, \while(condition, addBlock(body)), [body]))
    	case z:\synchronizedStatement(Expression lock, Statement body) =>
    		copySrc(z, withWeight(1, \synchronizedStatement(lock, addBlock(body)), [body]))
    		
		case s:\try(Statement body, list[Statement] catchClauses) =>
     		withWeight(1, s, catchClauses)
     	case s:\try(Statement body, list[Statement] catchClauses, Statement final) =>
     		withWeight(2, s, catchClauses + final)
 		case s:\switch(Expression expression, list[Statement] statements) => 
     		withWeight(2, s, statements)
     		
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

private Statement copySrc(Statement source, Statement target) {
	target@src = source@src; 
	return target;
}

private Statement withWeight(b:\block(list[Statement] statements)) {
	b@weight = getWeight(statements);
	return b;
}

private default Statement withWeight(Statement statement) {
	statement@weight = 1;
	return statement;
}

private Statement withWeight(int extraWeight, Statement parent, list[Statement] children) {
	parent@weight = getWeight(children) + 1 + extraWeight;
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