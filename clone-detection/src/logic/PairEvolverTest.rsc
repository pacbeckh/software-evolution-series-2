module logic::PairEvolverTest

import List;
import Set;
import Map;
import lang::java::m3::TypeSymbol;

import Config;
import Domain;
import PairCreator;
import CloneDetection;
import transformation::AstNormalizer;
import transformation::AstAnonimizer;

import lang::java::jdt::m3::AST;

import logic::PairEvolver;

public TypeSymbol tsInt = lang::java::m3::TypeSymbol::\int();
public Type typeVoid = lang::java::jdt::m3::AST::\void();

test bool testEvolveWithCorrectWeight() {
	CONFIG_STATEMENT_WEIGHT_THRESHOLD = 2;
	CONFIG_PAIR_LOOKAHEAD_WEIGHT_THRESHOLD = 2;

	Statement s = \block([
		\expressionStatement(\simpleName("s1")[@typ=tsInt])[@src=|file://x1|],
		\expressionStatement(\simpleName("s2")[@typ=tsInt])[@src=|file://x2|],
		\expressionStatement(\simpleName("s3")[@typ=tsInt])[@src=|file://x3|],
		\expressionStatement(\simpleName("s4")[@typ=tsInt])[@src=|file://x4|]
	]);
	list[AnonymousLink] anonLinks = getAnonimizedStatements(normalize(s));
	
	list[LinkPair] linkPairs = getAllLinkPairs(anonLinks);
	
	// Should return 3 link pairs: <s3,s2> <s3,s1> <s2,s1>.
	return 
		evolvePair(linkPairs[0])@weight == 2 &&  
		evolvePair(linkPairs[1])@weight == 2 &&
		evolvePair(linkPairs[2])@weight == 3;
}