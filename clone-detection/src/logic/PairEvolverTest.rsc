module logic::PairEvolverTest

import List;
import Set;
import util::Maybe;
import IO;
import Map;
import lang::java::m3::TypeSymbol;

import Config;
import Domain;
import PairCreator;
import CloneDetection;
import logic::VariableMapping;
import transformation::StatementVariables;
import transformation::AstNormalizer;
import transformation::AstAnonimizer;

import lang::java::jdt::m3::AST;

import logic::PairEvolver;

public TypeSymbol tsInt = lang::java::m3::TypeSymbol::\int();
public Type typeVoid = lang::java::jdt::m3::AST::\void();

test bool testEvolveWithCorrectWeight() {
	int defaultWeight = CONFIG_STATEMENT_WEIGHT_THRESHOLD;
	int defaultLookAhead = CONFIG_PAIR_LOOKAHEAD_WEIGHT_THRESHOLD;
	CONFIG_STATEMENT_WEIGHT_THRESHOLD = 1;
	CONFIG_PAIR_LOOKAHEAD_WEIGHT_THRESHOLD = 1;

	Declaration d = \method(typeVoid, "a", [], [], \block([
		\expressionStatement(\simpleName("s1")[@typ=tsInt])[@src=|file://x1|],
		\expressionStatement(\simpleName("s2")[@typ=tsInt])[@src=|file://x2|],
		\expressionStatement(\simpleName("s3")[@typ=tsInt])[@src=|file://x3|],
		\expressionStatement(\simpleName("s4")[@typ=tsInt])[@src=|file://x4|]
		//\expressionStatement(\simpleName("s5")[@typ=tsInt])[@src=|file://x5|],
		//\expressionStatement(\simpleName("s6")[@typ=tsInt])[@src=|file://x6|],
		//\expressionStatement(\simpleName("s7")[@typ=tsInt])[@src=|file://x7|],
		//\expressionStatement(\simpleName("s8")[@typ=tsInt])[@src=|file://x8|]
	]));
	list[AnonymousLink] anonLinks = getAnonimizedStatements(normalizeMethods(d));
	iprintln(size(anonLinks));
	
	list[LinkPair] linkPairs = getAllLinkPairs(anonLinks);
	for(lp <- linkPairs) {
		iprintln(evolvePair(lp)@weight);
	}
	
	// Should return 3 link pairs: <s3,s2> <s3,s1> <s2,s1>, note that no overlap is allowed.
	result =  
		evolvePair(linkPairs[0])@weight == 1 &&  
		evolvePair(linkPairs[1])@weight == 2 &&
		evolvePair(linkPairs[2])@weight == 1;
		
	CONFIG_STATEMENT_WEIGHT_THRESHOLD = defaultWeight;
	CONFIG_PAIR_LOOKAHEAD_WEIGHT_THRESHOLD = defaultLookAhead;
	
	return result;
}

test bool testEvolve() {
	Declaration d = \method(typeVoid, "a", [], [], \block([
		\expressionStatement(\simpleName("s1")[@typ=tsInt])[@src=|file://x1|],
		\expressionStatement(\simpleName("s2")[@typ=tsInt])[@src=|file://x2|],
		\expressionStatement(\simpleName("s3")[@typ=tsInt])[@src=|file://x3|],
		\expressionStatement(\simpleName("s4")[@typ=tsInt])[@src=|file://x4|],
		\expressionStatement(\simpleName("s5")[@typ=tsInt])[@src=|file://x5|],
		\expressionStatement(\simpleName("s6")[@typ=tsInt])[@src=|file://x6|],
		\expressionStatement(\simpleName("s7")[@typ=tsInt])[@src=|file://x7|],
		\expressionStatement(\simpleName("s8")[@typ=tsInt])[@src=|file://x8|],
		\expressionStatement(\simpleName("s9")[@typ=tsInt])[@src=|file://x9|]
	]));
	
	list[AnonymousLink] anonLinks = getAnonimizedStatements(normalizeMethods(d));
	list[LinkPair] linkPairs = getAllLinkPairs(anonLinks);
	map[int, list[LinkPair]] result = evolveLinkPairs(linkPairs);
	
	// pairs with a weight > 4 are not possible (because overlap);
	return max(domain(result)) == 4 && 
		size(result[4]) == 3; 
}