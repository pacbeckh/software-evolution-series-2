module logic::PairEvolverTest

import List;
import util::Maybe;
import IO;

import Domain;
import PairCreator;
import logic::VariableMapping;
import transformation::StatementVariables;
import transformation::AstNormalizer;
import transformation::AstAnonimizer;

import lang::java::jdt::m3::AST;

import logic::PairEvolver;


test bool testEvolveWithCorrectWeight() {

	Declaration d = \method(\void(), "a", [], [], \block([
		\expressionStatement(\simpleName("s1")),
		\expressionStatement(\simpleName("s2")),
		\expressionStatement(\simpleName("s3")),
		\expressionStatement(\null())
	]));
	list[AnonymousLink] anonLinks = getAnonimizedStatements(normalizeMethods(d));
	//iprintln(anonLinks);
	
	list[LinkPair] linkPairs = getAllLinkPairs(anonLinks);
	iprintln(evolvePair(linkPairs[2])@weight);
	
	// Should return 3 link pairs: <s3,s2> <s3,s1> <s2,s1>
	return 
		evolvePair(linkPairs[0])@weight == 1 &&
		evolvePair(linkPairs[1])@weight == 1 &&
		evolvePair(linkPairs[2])@weight == 2;
}