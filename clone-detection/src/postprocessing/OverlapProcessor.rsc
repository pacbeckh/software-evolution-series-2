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

public bool overlapsAllOthers(loc target, CloneClass cloneClass) {  
	r = all(fragment <- cloneClass, target == fragment || fragmentsOverlap(target, fragment));
	return r;
}

public bool fragmentsOverlap(loc A, loc B) {
	return A.uri == B.uri &&
		((B.begin >= A.begin && B.begin <= A.end) ||
		 (B.end >= A.begin && B.end <= A.end) ||
		 (A.begin >= B.begin && A.begin <= B.end) ||
		 (A.end >= B.begin && A.end <= B.end) );
}