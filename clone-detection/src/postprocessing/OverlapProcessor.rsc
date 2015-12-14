module postprocessing::OverlapProcessor

import Set;
import Domain;

public map[int, set[CloneClass]] cleanOverlappingFragments(map[int, set[CloneClass]] cloneClasses) =
	( key : ({ processCloneClass(cloneClass) | cloneClass <- cloneClasses[key]} - {{}})  |
		key <- cloneClasses);

public CloneClass processCloneClass(CloneClass cloneClass) = 
	cloneClass - {fragment | fragment <- cloneClass, overlapsAllOthers(fragment, cloneClass)};

public bool overlapsAllOthers(loc target, CloneClass cloneClass) =  
	all(fragment <- cloneClass, target == fragment || fragmentsOverlap(target, fragment));

public bool fragmentsOverlap(loc A, loc B) =
	A.uri == B.uri &&
		((B.begin >= A.begin && B.begin <= A.end) ||
		 (B.end >= A.begin && B.end <= A.end) ||
		 (A.begin >= B.begin && A.begin <= B.end) ||
		 (A.end >= B.begin && A.end <= B.end) );