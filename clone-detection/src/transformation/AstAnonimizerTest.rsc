module transformation::AstAnonimizerTest

import lang::java::m3::TypeSymbol;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import Config;
import Domain;
import transformation::AstAnonimizer;
import transformation::AstNormalizer;

public test bool shouldAddCorrectMaxWeight(){
	Statement s = \block([
		\expressionStatement(\simpleName("s1")[@typ=\int()])[@src=|file://foo|],
		\if(\simpleName("s2")[@typ=\int()], 
			\block([
				\expressionStatement(\simpleName("s3")[@typ=\int()])[@src=|file://foo|],
				\expressionStatement(\simpleName("s4")[@typ=\int()])[@src=|file://foo|]
			])[@src=|file://foo|]
		)[@src=|file://foo|],
		\expressionStatement(\simpleName("s5")[@typ=\int()])[@src=|file://foo|]	
	])[@src=|file://foo|];
	
	normalized = normalize(s);
	//
	list[AnonymousLink] result = getAnonimizedStatements(normalized);
	
	return
		//s4 
		result[0]@maxWeight == 1 &&
		//s3
		result[1]@maxWeight == 2 &&
		//s5
		result[2]@maxWeight == 1 &&
		//if  + 2
		result[3]@maxWeight == 6 &&
		//s1
		result[4]@maxWeight == 7;
		
} 


public TypeSymbol typeSymbolInt = lang::java::m3::TypeSymbol::\int();
public Type typeInt = lang::java::jdt::m3::AST::\int();

public test bool maintainTypeInformation(){
	input = \expressionStatement(\simpleName("i")[@typ=typeSymbolInt]);
	expected = \expressionStatement(\cast(typeInt,\simpleName("id0")));
	
	return anonimizeStatement(input, ()) == expected;
}


// Car car = new Car() -> Car id0 = new Car();
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
	
	return anonimizeStatement(input, ()) == expected;	
}

// Context: Object o;
// return (List<String>) o => return (List id0) 
public test bool preventDoubleCast() {
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
	    
	return anonimizeStatement(input, ()) == expected;
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
	
	return anonimizeStatement(input, ()) == expected;
}

// java.io.File file; => java.io.File id0
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
	    \simpleType(
			\qualifiedName(
				\qualifiedName(
					\simpleName("java")[@typ=\unresolved()],
					\simpleName("io")[@typ=\unresolved()]
				)[@typ=\unresolved()],
				\simpleName("File")[@typ=\class(|java+class:///java/io/File|,[])]
			)[@typ=\class(|java+class:///java/io/File|,[])]
		),
		[\variable("id0", 0)]
	));
	
	//Statement expected = \declarationStatement(\variables(
	//    \simpleType(\simpleName("java.io.File")),
	//	[\variable("id0", 0)]
	//));
	
	return anonimizeStatement(input, ()) == expected;
}

// Context: x is of type PreparedStatement
// x.setInt(1,1);
public test bool shouldHandleMethodInvocation() {
	Statement input = \expressionStatement(\methodCall(
	    false,
	    \simpleName("x")[
	      @typ=\interface(|java+interface:///java/sql/PreparedStatement|,[])
	    ],
	    "setInt",
	    [
	      \number("1")[@typ=\int()],
	      \number("1")[@typ=\int()]
	    ]
    )[@typ=\void()]);
    
    Statement expected = \expressionStatement(\methodCall(
	    false,
	    \cast(
	      \simpleType(\simpleName("PreparedStatement")),
	      \simpleName("id0")),
	    "setInt",
	    [
	      cast(typeInt,simpleName("id0")),
	      cast(typeInt,simpleName("id0"))
	    ])
    );
    
	return anonimizeStatement(input, ()) == expected;
}

// throw SmallSQLException.createFromException( e ); => throw ((SmallSQLException) id0).createFromException((Exception) e)
public test bool shouldAnonimizeStaticCalls() {
	Statement input = \throw(\methodCall(
	    false,
	    \simpleName("SmallSQLException")[@typ=\class(|java+class:///smallsql/database/SmallSQLException|,[])],
	    "createFromException",
	    [
			\simpleName("e")[@typ=\class(|java+class:///java/lang/Exception|,[])]
		])[@typ=\class(|java+class:///java/sql/SQLException|,[])]
	);
	
	Statement expected = \throw(\methodCall(
	    false,
	    \cast(
			\simpleType(\simpleName("SmallSQLException")),
			\simpleName("id0")),
	    "createFromException",
	    [
			\cast(
				\simpleType(\simpleName("Exception")),
				\simpleName("id0"))
		])[@typ=\class(|java+class:///java/sql/SQLException|,[])]
	);
	
	return anonimizeStatement(input, ()) == expected;
}

