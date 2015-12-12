module logic::PairEvolver

import List;
import util::Maybe;
import lang::java::jdt::m3::AST;

import Domain;
import logic::VariableMapping;
import transformation::StatementVariables;

public map[Statement,list[str]] varCache = ();

private Maybe[LinkPair] NOTHING = nothing();

public LinkPair evolvePair(LinkPair target) {
	int maxWeight = target.leftStack[0]@maxWeight;
	LinkPair subject = target;
	while(true) {
		Maybe[LinkPair] next = evolveLinkPair(subject);
		
		if (NOTHING == next) {
			subject@weight = noLink() := subject.leftStack[0].next ? maxWeight :  maxWeight - subject.leftStack[0].next.val@maxWeight;			
			return subject;
		}
		p = next.val;
		
		if(!p.mappingPossible) {
			subject@weight = maxWeight - subject.leftStack[0].next.val@maxWeight;
			
			return subject;
		}
		subject = p;
	}
}
 
public Maybe[LinkPair] evolveLinkPair(LinkPair input) {
	NextLink leftNextLink = input.leftStack[0].next;
	NextLink rightNextLink = input.rightStack[0].next;
	
	if (leftNextLink == noLink() || rightNextLink == noLink()) {
		return nothing();
	}
	
	AnonymousLink leftNext = leftNextLink.val;
	AnonymousLink rightNext = rightNextLink.val;
	if (leftNext.anonymous != rightNext.anonymous) {
		return nothing();
	}
	
	list[str] leftVars = getVarsForStatement(leftNext.normal);
	list[str] rightVars = getVarsForStatement(rightNext.normal);
	
	<r, ltr, rtl> = compareVariables(leftVars, rightVars, input.ltrMapping, input.rtlMapping);
	
	return just(linkPair(
		leftNext + input.leftStack,
		rightNext + input.rightStack,
		r,
		ltr,
		rtl
	));
}

public LinkPair linkPairWithNext(AnonymousLink leftNext, AnonymousLink rightNext) {
	list[str] leftVars = getVarsForStatement(leftNext.normal);
	list[str] rightVars = getVarsForStatement(rightNext.normal);
	
	<r, ltr, rtl> = compareVariables(leftVars, rightVars, (), ());
	
	return linkPair(
		[leftNext],
		[rightNext],
		r,
		ltr,
		rtl
	);
}

public list[str] getVarsForStatement(Statement s) {
	if (varCache[s]?) {
		return varCache[s];
	}
	list[str] vars = statementToVariables(s);
	varCache[s] = vars;
	return vars;
}
