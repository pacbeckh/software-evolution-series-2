module logic::VariableMapping

import Domain;
import List;

public MappingComparison compareVariables(list[str] leftVars, list[str] rightVars, map[str, str] mapping) {
	if (size(leftVars) != size(rightVars)) {
		return mappingComparison(false, mapping);
	}
	int i = 0;
	m = mapping;
	while (i < size(leftVars)) {
		if (m[leftVars[i]]?) {
			if (m[leftVars[i]] != rightVars[i]) {
				return mappingComparison(false, m);
			} 
		} else {
			m[leftVars[i]] = rightVars[i];
		}
		i+=1;
	}
	return mappingComparison(true, m);
}