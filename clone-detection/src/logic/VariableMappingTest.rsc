module logic::VariableMappingTest

import List;
import logic::VariableMapping;


test bool compareVariablesSameOnSwitchParams(list[str] leftVars, list[str] rightVars, 
											 map[str, str] ltrMapping, map[str, str] rtlMapping) {
	<r, x1, y1> = compareVariables(leftVars, rightVars, ltrMapping, rtlMapping);
	<r, y2, x2> = compareVariables(rightVars, leftVars, rtlMapping, ltrMapping);
	
	return r == r && x1 == x2 && y1 == y2;
}

test bool compareVariablesWithNonIdenticalLengthLists(list[str] leftVars) {
	if (leftVars == []) {
		return true;
	} 
	<r, _, _> = compareVariables(leftVars, tail(leftVars), (), ());
	return r == false;
}

test bool compareVariablesWithCorrectMapping() {
	<r, _, _> = compareVariables(["a", "b", "c"], ["a", "b", "c"], (), ());
	return r == true;
}

test bool compareVariablesWithChangedVars() {
	<r, _, _> = compareVariables(["a", "b", "c"], ["b", "c", "d"], (), ());
	return r == true;
}

test bool compareVariablesWithDoubleMappingLtr() {
	<r, _, _> = compareVariables(["a", "a", "c"], ["b", "c", "d"], (), ());
	return r == false;
}

test bool compareVariablesWithDoubleMappingRtl() {
	<r, _, _> = compareVariables(["a", "b", "c"], ["d", "e", "e"], (), ());
	return r == false;
}