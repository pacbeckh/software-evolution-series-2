module postprocessing::SameEndProcessor

import Set;
import List;
import Map;

import Domain;

public map[int, set[CloneClass]] cleanupCloneClassesWithSameEnd(map[int, set[CloneClass]] input) {
	list[int] orderedKeys = reverse(sort(toList(domain(input))));
	set[rel[str, tuple[int,int]]] knownClasses = {};
		
	map[int, set[CloneClass]] answer = ();
	
	for (k <-orderedKeys) {
		answer[k] = {};
		for (CloneClass clazz <- input[k]) {
			rel[str, tuple[int,int]] ends = { <l.uri, l.end> | l <- clazz};
			
			if (ends notin knownClasses) {
				knownClasses += {ends};
				answer[k] += {clazz};
			}
		}
	}
	return answer;
}