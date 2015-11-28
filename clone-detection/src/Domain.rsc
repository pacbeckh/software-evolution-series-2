module Domain

import lang::java::jdt::m3::AST;

data AnonymousLink = anonymousLink(
	Statement anonymous,
	Statement normal,
	NextLink next
);

data NextLink = aLink(AnonymousLink val) | noLink();

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