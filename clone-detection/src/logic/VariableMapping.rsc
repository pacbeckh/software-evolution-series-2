module logic::VariableMapping

import Domain;
import List;

public tuple[bool,map[str,str],map[str,str]] compareVariables(list[str] leftVars, list[str] rightVars, 
											 map[str, str] ltrMapping, map[str, str] rtlMapping) {
	if (size(leftVars) != size(rightVars)) {
		return <false, ltrMapping, rtlMapping>;
		//mappingComparison(false, mapping);
	}
	
	ltr = ltrMapping;
	rtl = rtlMapping;
	
	for (int i <- [0..size(leftVars)]) {
		lVar = leftVars[i];
		rVar = rightVars[i];
		
		if (ltr[lVar]?) {
			if (ltr[lVar] != rVar) {
				return <false, ltrMapping, rtlMapping>;
				//return mappingComparison(false, m);
			} 
		} else {
			ltr[lVar] = rVar;
		}
		
		if (rtl[rVar]?) {
			if (rtl[rVar] != lVar) {
				return <false, ltrMapping, rtlMapping>;
			} 
		} else {
			rtl[rVar] = lVar;
		}
		
	}
	return <true, ltr, rtl>;
	//return mappingComparison(true, m);
}