module transformation::CloneClassCreator

import Map;
import DateTime;
import IO;
import List;
import Relation;
import lang::java::jdt::m3::AST;

import Domain;

public map[int, set[CloneClass]] createCloneClasses(map[int, list[LinkPair]] levelResults) {
	println("<printTime(now())> Transform pairs to start and end locations...");
	map[int, rel[tuple[loc,loc],tuple[loc,loc]]] levelResultsAbsolute = transformLinkPairsToLocs(levelResults);
	
	println("<printTime(now())> Creating clone classes with equiv rel...");
	map[int, set[set[tuple[loc,loc]]]] cloneClassesRaw = (k : toEquivalence(levelResultsAbsolute[k]) | k <- levelResultsAbsolute);
	map[int, set[CloneClass]] cloneClasses = ( k : rawCloneClassToCloneClass(cloneClassesRaw[k]) | k <- cloneClassesRaw);
	
	return cloneClasses;
}

public set[CloneClass] rawCloneClassToCloneClass(set[rel[loc,loc]] rawCloneClasses) 
	= { asCloneClass(rawCloneClass) | rawCloneClass <- rawCloneClasses};

public CloneClass asCloneClass(rel[loc,loc] rawCloneClass)
	= { mergeLoc(s,e) | <s,e> <- rawCloneClass};

public loc mergeLoc(loc s, loc e) {
	n = s.end = e.end;
	return n;
}

public set[set[tuple[loc,loc]]] toEquivalence(rel[tuple[loc,loc],tuple[loc,loc]] rels)
	= groupRangeByDomain((rels + invert(rels)) +);


public map[int, rel[tuple[loc,loc],tuple[loc,loc]]] transformLinkPairsToLocs(map[int, list[LinkPair]] evolvedLinksPairs){
	map[int, rel[tuple[loc,loc],tuple[loc,loc]]] result = ();
	for (k <- evolvedLinksPairs) {
		list[LinkPair] levelResult = evolvedLinksPairs[k];
		rel[tuple[loc, loc],tuple[loc, loc]] rels = {<<last(l.leftStack).normal@src, head(l.leftStack).normal@src>, 
						      <last(l.rightStack).normal@src, head(l.rightStack).normal@src>> | l <- levelResult};
		result[k] = rels;
	}
	
	return result;
}


