module postprocessing::NestedBlockProcessor

import List;
import Map;
import Set;
import ListRelation;

import Domain;

public map[int, set[CloneClass]] cleanupNestedBlocks(map[int, set[CloneClass]] input) {
	list[int] sortedKeys = sort(toList(domain(input)));
	
	map[tuple[int,CloneClass],set[str]] cloneClassLocations
		= (<k,levelCloneClass> : locationsForLevelCloneClass(levelCloneClass) | k <- sortedKeys, levelCloneClass <- input[k]);
	map[set[str], rel[int,CloneClass]] cloneClassLocationsInvert = invert(cloneClassLocations);
	
	lrel[int,CloneClass] filteredCloneClassByLevel;
	
	filteredCloneClassByLevel = for (k:<level,cloneClass> <- cloneClassLocations) {
		set[str] locations = cloneClassLocations[k];
		set[CloneClass] compareWith = {
			cl | set[str] l <- cloneClassLocationsInvert 
			,locations <= l
			,<size, cl> <- cloneClassLocationsInvert[l]
			,size > level
		};
		
		if(!oneContainsChild(cloneClass, compareWith)) {
			append <level, cloneClass>;
		}
	}
	
	return index(filteredCloneClassByLevel);
}

public set[str] locationsForLevelCloneClass(CloneClass input) = { lhs.uri | lhs <- input };

public bool oneContainsChild(CloneClass child, set[CloneClass] parents) = 
	any(parent <- parents, containsChild(child, parent)); 

public bool containsChild(CloneClass child, CloneClass parent) =
	child == { childElem | childElem <- child, containedBy(childElem, parent) };

public bool containedBy(loc item, CloneClass container) {
	return any(c <- container, c.uri == item.uri, item <= c);
}

public bool isBeginBeforeOrEqual(loc a, loc b) = a.uri == b.uri && a.begin <= b.begin;

public bool isEndBeforeOrEqual(loc a, loc b) = a.uri == b.uri && a.end <= b.end;
	
public loc cloneClassItemWithStartAndEnd(str f, beginLine, endLine) {
	return |file://<f>|(beginLine,endLine-beginLine+1,<beginLine,0>,<endLine,0>);
}
