package nl.mse.conditional;

import java.util.ArrayList;
import java.util.List;

public class DuplciationInStructuralTraversal {

	public List<String> names(List<List<Object>> objects) {
		List<String> answer = new ArrayList<String>();
		for (List<Object> inner :  objects) {
			for (Object o : inner) {
				answer.add(o.toString());
			}
		}
		return answer;
	}
	
	public int count(List<List<Object>> objects) {
		int i = 0;
		for (List<Object> inner :  objects) {
			for (Object unused : inner) {
				i++;
			}
		}
		return i;
	}
	
}
