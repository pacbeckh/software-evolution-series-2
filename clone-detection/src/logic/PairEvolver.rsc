module logic::PairEvolver

import List;
import util::Maybe;
import IO;
import lang::java::jdt::m3::AST;

import Domain;
import logic::VariableMapping;
import transformation::StatementVariables;


public LinkPair evolvePair(LinkPair target) {
	int maxWeight = head(target.leftStack)@maxWeight;
	LinkPair subject = target;
	while(true) {
		Maybe[LinkPair] next = evolveLinkPair(subject);
		
		if (nothing() == next) {

			subject@weight = noLink() := head(subject.leftStack).next ? maxWeight :  maxWeight - head(subject.leftStack).next.val@maxWeight;			
			
			return subject;
			
			break;
		} else if (just(p) := next) {
			if(!isMappingPossible(p)) {
				subject@weight = maxWeight - head(subject.leftStack).next.val@maxWeight;
				
				return subject;
			}
			subject = p;
		} 		
	}
}

public bool isMappingPossible(LinkPair p) {
	return p.ltrMappingPossible && p.rtlMappingPossible;
}
 
public Maybe[LinkPair] evolveLinkPair(LinkPair input) {
	NextLink leftNextLink = head(input.leftStack).next;
	NextLink rightNextLink = head(input.rightStack).next;
	
	if (leftNextLink == noLink() || rightNextLink == noLink()) {
		return nothing();
	}
	
	AnonymousLink leftNext = leftNextLink.val;
	AnonymousLink rightNext = rightNextLink.val;
	if (leftNext.anonymous != rightNext.anonymous || pairsOverlap(input, leftNext, rightNext)) {
		return nothing();
	}
	
	return just(evolveLinkPairWithNext(input, leftNext, rightNext));
}

public LinkPair linkPairWithNext(AnonymousLink leftNext, AnonymousLink rightNext) {
	return evolveLinkPairWithNext(
		linkPair([],[], true, (), true, ()),
		leftNext,
		rightNext
	);
}

public LinkPair evolveLinkPairWithNext(LinkPair input, AnonymousLink leftNext, AnonymousLink rightNext) {
	list[str] leftVars = statementToVariables(leftNext.normal);
	list[str] rightVars = statementToVariables(rightNext.normal);
	
	MappingComparison leftComparison = mappingComparison(input.ltrMappingPossible, input.ltrMapping);
	MappingComparison rightComparison = mappingComparison(input.rtlMappingPossible, input.rtlMapping);
	
	if(input.ltrMappingPossible) {
		leftComparison = compareVariables(leftVars, rightVars, input.ltrMapping);
	}
	if(input.rtlMappingPossible) {
		rightComparison = compareVariables(rightVars, leftVars, input.rtlMapping);
	}
	
	return linkPair(
		leftNext + input.leftStack,
		rightNext + input.rightStack,
		leftComparison.success,
		leftComparison.mapping,
		rightComparison.success,
		rightComparison.mapping
	);
}

public bool pairsOverlap(LinkPair input, AnonymousLink leftNext, AnonymousLink rightNext) {
	set[loc] locs = { getLoc(x) | x <- input.leftStack + input.rightStack};
	return (getLoc(leftNext) in locs) || (getLoc(rightNext) in locs); 
}

private loc getLoc(AnonymousLink link) = link.normal@src;
