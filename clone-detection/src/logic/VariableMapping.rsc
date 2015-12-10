module logic::VariableMapping

import Domain;
import List;

public MappingComparison compareVariables(list[str] leftVars, list[str] rightVars, map[str, str] mapping) {
	if (size(leftVars) != size(rightVars)) {
		return mappingComparison(false, mapping);
	}
	m = mapping;
	for (int i <- [0..size(leftVars)]) {
		lVar = leftVars[i];
		rVar = rightVars[i];
		if (m[lVar]?) {
			if (m[lVar] != rVar) {
				return mappingComparison(false, m);
			} 
		} else {
			m[lVar] = rVar;
		}
	}
	return mappingComparison(true, m);
}