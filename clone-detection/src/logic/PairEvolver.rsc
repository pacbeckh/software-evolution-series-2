module logic::PairEvolver

import List;
import util::Maybe;

import Domain;
import logic::VariableMapping;
import transformation::StatementVariables;


public tuple[int, LinkPair] evolvePair(LinkPair target) {
	int level = 0;	
	LinkPair subject = target;
	while(true) {
		level+=1;
		Maybe[LinkPair] next = evolveLinkPair(subject);
		if (nothing() == next) {
			return <level, subject>;
			break;
		} else if (just(p) := next) {
			if(!isMappingPossible(p)) {
				return <level, subject>;
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
	if (leftNext.anonymous != rightNext.anonymous) {
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
