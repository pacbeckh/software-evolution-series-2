module Domain

import lang::java::jdt::m3::AST;

anno int Statement @ weight;

anno int AnonymousLink @ maxWeight;
 
alias CloneClass = set[loc];

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
	bool mappingPossible,
	map[str,str] ltrMapping,
	map[str,str] rtlMapping
);

data CloneFragment = cloneFragement(
	Statement startStatement,
	int length
);