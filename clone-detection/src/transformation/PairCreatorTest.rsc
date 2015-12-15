module transformation::PairCreatorTest

import transformation::PairCreator;

import lang::java::jdt::m3::AST;
import List;
import Map;

import Domain;
import Config;
import logic::PairEvolver;
import util::Logging;
import IO;

test bool getAllLinkPairsEmpty() {
	return getAllLinkPairs([]) == [];
}

test bool testSetupLinkPairs(Statement s, int i) {
	AnonymousLink link = anonymousLink(
		s,
		s,
		|foo://bar|,
		noLink()
	);
	input = [link | _ <- [0..(i % 10)]];
	result = setupLinkPairs(input);
	return size(input) * (size(input) - 1) / 2 == size(result);
}

test bool collectAnonymousKeyForLinkWithThreshold(Statement s) {
	s@weight = CONFIG_STATEMENT_WEIGHT_THRESHOLD;
	link = anonymousLink(
		s,
		s,
		|foo://bar|,
		noLink()
	);
	
	return [s] == collectAnonymousKey(link);
}
