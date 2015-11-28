module Mats

import DateTime;
import IO;
import List;
import Set;
import String;
import ListRelation;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import Map;
import util::Maybe;

import AnonymizeStatements;
import Domain;

public loc projectLoc = |project://hello-world-java/src/nl/simple|;
public M3 model;

public M3 loadModel() {
	model = createM3FromEclipseProject(projectLoc);
	return model;
}


public void run(M3 model) {
	int i = 1;
	
	set[AnonymousLink] links = {};
	
	for (m <- methods(model)
		//, m.file == "foo2(int)"
		//, /\/DuplicationWithOneLineRemoved\// := m.path
	) {
		println("Handle method (<i>): <m.file>, <m>");
		i += 1;
		
		Declaration d = getMethodASTEclipse(m, model = model);
		Declaration normalized = normalizeMethod(d);
		
		links += getAnonimizedStatements(d);
	}
	
	map[Statement,set[AnonymousLink]] linkIndex = ();
	for(link <- links) {
		if (linkIndex[link.anonymous]?) {
			linkIndex[link.anonymous] = linkIndex[link.anonymous] + link;
		} else {
			linkIndex[link.anonymous] = {link};
		}
	}
	
	iprintln(size(links));
	iprintln(size(domain(linkIndex)));
	set[LinkPair] allPairs = {};
	for(k <- linkIndex) {
		println("Key with size: <size(linkIndex[k])>");
		if (size(linkIndex[k]) > 1) {
			println("Build pairs for key with size: <size(linkIndex[k])>");
			set[LinkPair] pairs = setupLinkPairs(linkIndex[k]);
			println("- Pairs: <size(pairs)>");
			allPairs += pairs;
		}
	}
	
	//LinkPair focus = head(toList(allPairs));
	
	map[int, set[LinkPair]] levelResults = ();
	 
	for (focus <- allPairs) {
		int level = 0;
		println("Focus:");
		println(" - left: <head(focus.leftStack).normal@src>");
		println(" - right: <head(focus.rightStack).normal@src>");
		
		LinkPair subject = focus;
		while(subject.ltrMappingPossible || subject.rtlMappingPossible) {
			level+=1;
			println("\> Level <level>");
			Maybe[LinkPair] next = evolveLinkPair(subject);
			if (nothing() == next) {
				if (levelResults[level]?) {
					levelResults[level] += subject;
				} else {
					levelResults[level] = {subject};
				}
				break;
			} else if (just(p) := next) {
				if(!p.ltrMappingPossible && !p.rtlMappingPossible) {
					if (levelResults[level]?) {
						levelResults[level] += subject;
					} else {
						levelResults[level] = {subject};
					}
				}
				subject = p;
			} 
			
		}
	}
	iprintln([k | k <- levelResults]);
	for (k <- levelResults) {
		println("<k> -\> <size(levelResults[k])>"); 
	}
	//iprintln("All pairs <size(allPairs)>");
	
}

public Declaration normalizeMethod(Declaration d) {
	return d;
}


public set[AnonymousLink] getAnonimizedStatements(Declaration normalized) {
	set[AnonymousLink] answer = {};
	visit(normalized) {
		case \block(list[Statement] sts): {
			int i = size(sts);
			NextLink next = noLink();
			while (i > 0) {
				i-=1;
				Statement anon = anonimizeStatement(sts[i])[1];
				AnonymousLink link = anonymousLink(anon, sts[i], next);
				answer += link;
				next = aLink(link);
			}
			
		}
	}
	return answer;
}

public set[LinkPair] setupLinkPairs(set[AnonymousLink] links) {
	list[AnonymousLink] linkList = toList(links);
	set[LinkPair] result = {};
	
	for(int i <- [0 .. size(linkList)]) {
		for(int j <- [i+1 .. size(linkList)]) {
			//println("<i> -\> <j>");
			
			LinkPair linkPair = createParameterizedPair(linkList[i], linkList[j]);
			if (linkPair.ltrMappingPossible || linkPair.rtlMappingPossible) {
				//println("- Is Pair");
				result += linkPair;
			}
		}
	}
	return result;
}


public Maybe[LinkPair] evolveLinkPair(LinkPair input) {
	NextLink leftNextLink = head(input.leftStack).next;
	NextLink rightNextLink = head(input.rightStack).next;
	
	if (leftNextLink == noLink() || rightNextLink == noLink()) {
		return nothing();
	}
	
	AnonymousLink leftNext = leftNextLink.val;
	AnonymousLink rightNext = rightNextLink.val;
	list[str] leftVars = getVariables(leftNext.normal);
	list[str] rightVars = getVariables(rightNext.normal);
	
	MappingComparison leftComparison = mappingComparison(input.ltrMappingPossible, input.ltrMapping);
	MappingComparison rightComparison = mappingComparison(input.rtlMappingPossible, input.rtlMapping);
	
	if(input.ltrMappingPossible) {
		leftComparison = compareVariables(leftVars, rightVars, input.ltrMapping);
	}
	if(input.rtlMappingPossible) {
		rightComparison = compareVariables(rightVars, leftVars, input.rtlMapping);
	}
	
	return just(linkPair(
		leftNext + input.leftStack,
		rightNext + input.rightStack,
		leftComparison.success,
		leftComparison.mapping,
		rightComparison.success,
		rightComparison.mapping
	));
}

public LinkPair createParameterizedPair(AnonymousLink left, AnonymousLink right) {
	list[str] leftVars = getVariables(left.normal);
	list[str] rightVars = getVariables(right.normal);
	
	MappingComparison leftResult = compareVariables(leftVars, rightVars, ());
	MappingComparison rightResult = compareVariables(rightVars, leftVars, ());
	
	return linkPair(
		[left],
		[right],
		leftResult.success,
		leftResult.mapping,
		rightResult.success,
		rightResult.mapping
	);
}

public MappingComparison compareVariables(list[str] leftVars, list[str] rightVars, map[str, str] mapping) {
	if (size(leftVars) != size(rightVars)) {
		return mappingComparison(false, mapping);
	}
	int i = 0;
	m = mapping;
	while (i < size(leftVars)) {
		if (m[leftVars[i]]?) {
			if (m[leftVars[i]] != rightVars[i]) {
				//println("Problem on \"<leftVars[i]>\" -\> \"<rightVars[i]>\"");
				return mappingComparison(false, m);
			} 
			//else {
				//println("We are good on \"<leftVars[i]>\" -\> \"<rightVars[i]>\"");
			//}
		} else {
			//println("Assign m on \"<leftVars[i]>\" -\> \"<rightVars[i]>\"");
			m[leftVars[i]] = rightVars[i];
		}
		//iprintln("I <i>");
		i+=1;
	}
	//iprintln(m);
	return mappingComparison(true, m);
}

public list[str] getVariables(Statement s) {
	list[str] result = [];
	top-down visit(s) {
		case \variable(x,_): {result += x;}
		case \variable(x,_,_): {result += x;}
		case \simpleName(x): {result += x;}
		case \number(x): {result += x;}
		case \booleanLiteral(x): {result += x;}
		case \stringLiteral(x): {result += x;}
		case \characterLiteral(x): {result += x;} 
	}
	
	return result;
} 
