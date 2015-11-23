package nl.mse.conditional;

public class DuplicationOutsideOfIf {

	public int foo1(int i) {
		int k = 10;
		int j;
		if (k < i) {
			j = i + 1;
		} else {
			j = i - 1;
		}
		return j;
	}
	
	//k = 6 and i is renamed to m
	public int foo2(int m) {
		int k = 6;
		int j;
		if (k < m) {
			j = m + 1;
		} else {
			j = m - 1;
		}
		return j;
	}
}
