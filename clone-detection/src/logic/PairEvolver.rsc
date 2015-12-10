module logic::PairEvolver

import List;
import util::Maybe;
import IO;
import lang::java::jdt::m3::AST;

import Domain;
import logic::VariableMapping;
import transformation::StatementVariables;

public map[Statement,list[str]] varCache = ();

private Maybe[LinkPair] NOTHING = nothing();

public LinkPair evolvePair(LinkPair target) {
	int maxWeight = head(target.leftStack)@maxWeight;
	LinkPair subject = target;
	while(true) {
		Maybe[LinkPair] next = evolveLinkPair(subject);
		
		if (NOTHING == next) {
			subject@weight = noLink() := head(subject.leftStack).next ? maxWeight :  maxWeight - head(subject.leftStack).next.val@maxWeight;			
			return subject;
		} 
		just(p) = next;
		if(!p.mappingPossible) {
			subject@weight = maxWeight - head(subject.leftStack).next.val@maxWeight;
			
			return subject;
		}
		subject = p;
	}
}
 
public Maybe[LinkPair] evolveLinkPair(LinkPair input) {
	NextLink leftNextLink = head(input.leftStack).next;
	NextLink rightNextLink = head(input.rightStack).next;
	
	if (leftNextLink == noLink() || rightNextLink == noLink()) {
		return nothing();
	}
	
	AnonymousLink leftNext = leftNextLink.val;
	AnonymousLink rightNext = rightNextLink.val;
	if (leftNext.anonymous != rightNext.anonymous) {
		return nothing();
	}
	
	return just(evolveLinkPairWithNext(input, leftNext, rightNext));
}

public LinkPair linkPairWithNext(AnonymousLink leftNext, AnonymousLink rightNext) {
	return evolveLinkPairWithNext(
		linkPair([],[], true, (), ()),
		leftNext,
		rightNext
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
public LinkPair evolveLinkPairWithNext(LinkPair input, AnonymousLink leftNext, AnonymousLink rightNext) {
	list[str] leftVars = getVarsForStatement(leftNext.normal);
	list[str] rightVars = getVarsForStatement(rightNext.normal);
	
	<r, ltr, rtl> = compareVariables(leftVars, rightVars, input.ltrMapping, input.rtlMapping);
	
	return linkPair(
		leftNext + input.leftStack,
		rightNext + input.rightStack,
		r,
		ltr,
		rtl
	);
}

private loc getLoc(AnonymousLink link) = link.normal@src;
