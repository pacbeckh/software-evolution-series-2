module transformation::AstAnonimizerTest

import lang::java::m3::TypeSymbol;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;

import transformation::AstAnonimizer;
import transformation::AstNormalizer;

import Config;
import Domain;

public test bool shouldAddCorrectMaxWeight(){
	Declaration d = lang::java::jdt::m3::AST::\method(lang::java::jdt::m3::AST::\void(), "a", [], [], \block([
		\expressionStatement(\simpleName("s1")[@typ=\int()])[@src=|file://foo|],
		\if(\simpleName("s2")[@typ=\int()], 
			\block([
				\expressionStatement(\simpleName("s3")[@typ=\int()])[@src=|file://foo|],
				\expressionStatement(\simpleName("s4")[@typ=\int()])[@src=|file://foo|]
			])[@src=|file://foo|]
		)[@src=|file://foo|],
		\expressionStatement(\simpleName("s5")[@typ=\int()])[@src=|file://foo|]	
	])[@src=|file://foo|]);
	
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


public TypeSymbol typeSymbolInt = lang::java::m3::TypeSymbol::\int();
public Type typeInt = lang::java::jdt::m3::AST::\int();

public test bool maintainTypeInformation(){
	input = \expressionStatement(\simpleName("i")[@typ=typeSymbolInt]);
	expected = \expressionStatement(\cast(typeInt,\simpleName("id0")));
	
	<_,anonimized> = anonimizeStatement(input);
	return anonimized == expected;
}


// Car car = new Car() -> Car id0 => new Car();
public test bool maintainTypeInformation2() {
	Statement input = \declarationStatement(\variables(
    \simpleType(simpleName("Car")[@typ=\class(|java+class:///nl/mse/anon/Cast/Car|,[])]),
    [
		\variable("car",0,
			\newObject(
				\simpleType(\simpleName("Car")[@typ=class(|java+class:///nl/mse/anon/Cast/Car|,[])]),[]
			)[@typ=\class(|java+class:///nl/mse/anon/Cast/Car|,[])]
		)[@typ=\class(|java+class:///nl/mse/anon/Cast/Car|,[])]
	]));
	
	Statement expected = declarationStatement(variables(
    simpleType(simpleName("Car")),
    [
    	variable("id0",0, 
        	\newObject(
          		\simpleType(\simpleName("Car")),
          	[])
    	)
	]));
	
	<_,anonimized> = anonimizeStatement(input);
	return anonimized == expected;
}

// Context: Object o;
// return (List<String>) o => return (List id0) 
public test bool removedDoubleCast() {
	Statement input = \return(
		\cast(
			\parameterizedType(
				\simpleType(\simpleName("List")[@typ=\interface(|java+interface:///java/util/List|,[\class(|java+class:///java/lang/String|,[])])])
			),
			\simpleName("o")[@typ=\object()]
    	)[@typ=\interface(|java+interface:///java/util/List|,[\class(|java+class:///java/lang/String|,[])])]
 	);

 	Statement expected = \return(
 		\cast(
    		\parameterizedType(simpleType(simpleName("List"))
    		),
	    	simpleName("id0")));
	    
	<_,anonimized> = anonimizeStatement(input);
	return anonimized == expected;
}

//int k = 10 shoud become: < int id0 = (int) id0 > and NOT  < int (int) id0 = (int) id0 >
public test bool varsShouldNotHaveExtraTypeInformation(){
	Statement input = \declarationStatement(\variables(
	    typeInt,
	    [\variable(
				"k",0,\number("10")[@typ=\int()]
		)[@typ=\int()]]
	));
	
	Statement expected = \declarationStatement(\variables(
	    typeInt,
	    [\variable(
	        "id0",0,cast(typeInt,simpleName("id0"))
		)]
	));
	
	<_,anonimized> = anonimizeStatement(input);
	return anonimized == expected;
}

public test bool shouldHandleQualifiedNames() {
	Statement input = \declarationStatement(\variables(
	    \simpleType(
			\qualifiedName(
				\qualifiedName(
					\simpleName("java")[@typ=\unresolved()],
					\simpleName("io")[@typ=\unresolved()]
				)[@typ=\unresolved()],
				\simpleName("File")[@typ=\class(|java+class:///java/io/File|,[])]
			)[@typ=\class(|java+class:///java/io/File|,[])]
		),
		[\variable("file", 0)[@typ=\class(|java+class:///java/io/File|,[])]]
	));
	
	Statement expected = \declarationStatement(\variables(
	    \simpleType(\simpleName("java.io.File")),
		[\variable("id0", 0)]
	));
	
	<_,anonimized> = anonimizeStatement(input);
	return anonimized == expected;
}

//private bool anonimizeEqual(Expression l, Expression r) = anonimizeEqual(expressionStatement(l), expressionStatement(r));
//private bool anonimizeEqual(Statement l, Statement r) {
//	<_,resultL> = anonimizeStatement(l);
//	<_,resultR> = anonimizeStatement(r);
//	return resultL == resultR;
//}
//
//public test bool compareLabel(str l1, str l2, Statement s) = anonimizeEqual(\label(l2, s), \label(l1, s));
//public test bool compareBreak(str l1, str l2) = anonimizeEqual(\break(l1), \break(l2));
//public test bool compareVariable(str l1, str l2, int dim) = anonimizeEqual(\variable(l1, dim), \variable(l2, dim));
//public test bool compareVariableWithExpr(str l1, str l2, int dim, Expression e) = anonimizeEqual(\variable(l1, dim, e), \variable(l2, dim, e));
//public test bool compareSimpleName(str l1, str l2) = anonimizeEqual(\simpleName(l1), \simpleName(l2));
//public test bool compareNumber(str n1, str n2) = anonimizeEqual(\number(n1), \number(n2));
//public test bool compareBoolenLiteral(bool b1, bool b2) = anonimizeEqual(\booleanLiteral(b1), \booleanLiteral(b2));
//public test bool compareBoolenLiteral(str s1, str s2) = anonimizeEqual(\stringLiteral(s1), \stringLiteral(s2));
//public test bool compareBoolenLiteral(str s1, str s2) = anonimizeEqual(\characterLiteral(s1), \characterLiteral(s2));
