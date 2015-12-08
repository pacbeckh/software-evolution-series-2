module postprocessing::OverlapProcessor

import IO;
import List;

public map[int, set[set[tuple[loc,loc]]]] processOverlap(map[int, set[set[tuple[loc,loc]]]] cloneClasses) {
	for(key <- cloneClasses){
		cloneClasses[key] = { procesCloneClass(cloneClass) | cloneClass <- cloneClasses[key]};
	}
	
	return cloneClasses;
}

public set[tuple[loc,loc]] processCloneClass(set[tuple[loc,loc]] cloneClass) = 
	cloneClass - {fragment | fragment <- cloneClass, overlapsAllOthers(fragment, cloneClass)};

private bool overlapsAllOthers(tuple[loc,loc] target, set[tuple[loc,loc]] cloneClass) = 
	all(fragment <- cloneClass, target == fragment || fragmentsOverlap(target, fragment));

bool fragmentsOverlap(<startA, endA>, <startB, endB>) = 
	(startB.begin <= startA.begin && startA.end <= endB.end) || (startA.begin <= startB.begin && startB.begin <= endA.end);