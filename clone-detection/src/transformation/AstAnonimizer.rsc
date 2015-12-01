module transformation::AstAnonimizer

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import List;

import Config;
import Domain;

public tuple[Statement,Statement] anonimizeStatement(Statement s) {
	res = visit(s) {
		case \variable(_,dim) => \variable("id0",dim)
		case \variable(_,dim, e) => \variable("id0",dim, e)
		case \simpleName(_) => \simpleName("id0")
		case x:\number(_) => CONFIG_ANONYMOUS_LITERALS ? \simpleName("id0") : x
		case x:\booleanLiteral(_) => CONFIG_ANONYMOUS_LITERALS ? \simpleName("id0") : x
		case x:\stringLiteral(_) => CONFIG_ANONYMOUS_LITERALS ? \simpleName("id0") : x
		case x:\characterLiteral(_) => CONFIG_ANONYMOUS_LITERALS ? \simpleName("id0") : x 
	}
	return <s,res>;
}

public list[AnonymousLink] getAnonimizedStatements(Declaration normalized) {
	list[AnonymousLink] answer = [];
	visit(normalized) {
		case \block(list[Statement] sts): {
			int i = size(sts);
			int weightSum = 0;
			NextLink next = noLink();
			while (i > 0) {
				i -= 1;
				Statement statement = sts[i];
				
				weightSum += statement@weight; 
				
				Statement anon = anonimizeStatement(statement)[1];
				AnonymousLink link = anonymousLink(anon, statement, next);
				link@maxWeight = weightSum;
				
				answer += link;
				next = aLink(link);
			}
		}
	}
	
	return answer;
}