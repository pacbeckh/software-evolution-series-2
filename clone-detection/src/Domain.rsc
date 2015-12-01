module Domain

import lang::java::jdt::m3::AST;

anno int Statement @ weight;

anno int AnonymousLink @ maxWeight;
 
data AnonymousLink = anonymousLink(
	Statement anonymous,
	Statement normal,
	NextLink next
);

data NextLink = aLink(AnonymousLink val) | noLink();

anno int LinkPair @ weight;

data LinkPair = linkPair(
	list[AnonymousLink] leftStack,
	list[AnonymousLink] rightStack,
	bool ltrMappingPossible,
	map[str,str] ltrMapping,
	bool rtlMappingPossible,
	map[str,str] rtlMapping
);


data MappingComparison = mappingComparison(
	bool success,
	map[str,str] mapping
);

data CloneFragment = cloneFragement(
	Statement startStatement,
	int length
);