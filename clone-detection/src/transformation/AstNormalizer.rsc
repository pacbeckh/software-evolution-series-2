module transformation::AstNormalizer

import lang::java::m3::AST; 
import IO;
import String;
import List;

import Config;

public Declaration normalizeMethods(Declaration declaration) {
	if (!CONFIG_NORMALIZE_STATEMENTS) {
		return declaration;
	}
	
	switch(declaration) {
		case \method(\return, name, parameters, exceptions, impl) :
			return \method(\return,name,parameters,exceptions, normalize(impl));
		case \constructor(name, parameters, exceptions, impl) :
			return \constructor(name, parameters,exceptions, normalize(impl));
	}
	return declaration;
}

public Statement normalize(Statement statement) {
	return visit(statement) {
		case \if(Expression e, Statement s) => 
			\if(e, addBlock(s))
		case \if(Expression e, Statement s1, Statement s2) => 
			\if(e, addBlock(s1), addBlock(s1))
		case \do(Statement s, Expression e) => 
			\do(addBlock(s), e)
		case \foreach(Declaration d, Expression e, Statement s) => 
			\foreach(d, e, addBlock(s))
    	case \for(list[Expression] initializers, Expression condition, list[Expression] updaters, Statement body) => 
    		\for(initializers, condition, updaters, addBlock(body))
    	case \for(list[Expression] initializers, list[Expression] updaters, Statement body) => 
    		\for(initializers, updaters, addBlock(body))
		case \label(str name, Statement body) => 
    		\label(name, addBlock(body))
     	//case \switch(Expression expression, list[Statement] statements) => 
     		//\switch(expression, addBlocks(statements))
		case \catch(Declaration exception, Statement body) => 
			\catch(exception, addBlock(body))
     	case \while(Expression condition, Statement body) => 
     		\while(condition, addBlock(body))
    	case \synchronizedStatement(Expression lock, Statement body) =>
    		\synchronizedStatement(lock, addBlock(body))
		//case \try(Statement body, list[Statement] catchClauses) =>
     		//\try(body, addBlocks(catchClauses))
     	//case \try(Statement body, list[Statement] catchClauses, Statement final) =>
     		//\try(body, addBlocks(catchClauses), addBlock(final))
    	
    	case \infix(Expression lhs, str operator, Expression rhs) => \infix(lhs, "=", \infix( lhs, substring(operator, 0, size(operator) - 1 ), rhs))
    		when operator in ["+=", "*=", "/=", "-=", "%=", "&=", "|=", "^=", "\>\>=", "\<\<=", "\>\>\>="]
    		
    	//TODO: rewrite < and <=
	}
}

public Statement addBlock(Statement statement) = \block(_) := statement ? statement : \block([statement]);
public Statement addBlocks(list[Statement] statements) = [addBlock(statement) | statement <- statements]; 


test bool myTest() {
	normalizeMethods(createAstFromString(|file://Foo|, "class Foo { int foo() { int i = 0; if (i \> 0) i+=1; return i;} void bar() {}} ", true));
	return true;
}

test bool normalizeIfWithExpression() {
	return \if(_,\block([\expressionStatement(null())])) := normalize(\if(\null(), \expressionStatement(\null())));
}

test bool normalizeIfElseWithExpression() {
	return \if(_,\block([\expressionStatement(null())]),\block([\expressionStatement(null())])) 
		:= normalize(\if(\null(), \expressionStatement(\null()), \block([\expressionStatement(null())])));
}

test bool normalizeDoWithExpression() {
	return \do(\block([\expressionStatement(null())]), \null()) 
		:= normalize(\do(\expressionStatement(\null()), \null()));
}

test bool normalizeInfix() {
	return \expressionStatement(\infix(\simpleName("a"),"=", \infix(\simpleName("a"), "\>\>", \simpleName("b"))))
		:= normalize(\expressionStatement(\infix(\simpleName("a"),"\>\>=", \simpleName("b"))));
}

