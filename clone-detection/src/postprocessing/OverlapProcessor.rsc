module postprocessing::OverlapProcessor

import IO;
import Set;
import Domain;

public map[int, set[CloneClass]] cleanOverlappingFragments(map[int, set[CloneClass]] cloneClasses) {
	for (key <- cloneClasses) {
		cloneClasses[key] = { processCloneClass(cloneClass) | cloneClass <- cloneClasses[key]} - {{}};	
	}
	
	return cloneClasses;
}

public CloneClass processCloneClass(CloneClass cloneClass) = 
	cloneClass - {fragment | fragment <- cloneClass, overlapsAllOthers(fragment, cloneClass)};

private bool overlapsAllOthers(loc target, CloneClass cloneClass) = 
	all(fragment <- cloneClass, target == fragment || fragmentsOverlap(target, fragment));

bool fragmentsOverlap(loc A, loc B) {
	return A.uri == B.uri &&
		((B.begin <= A.begin && A.end <= B .end) 
			|| (A.begin <= B.begin && B.begin <= A.end));
}