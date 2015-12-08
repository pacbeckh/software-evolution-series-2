package nl.mse.nesting;

public class NestedBlock {

	public int function1(int i) {
		int j = 10;
		int m = j * i;
		
		if (j < i) {
			m = m + 1;
			m = m * 2;
			m = m - 3;
			m = m / 4;
			m = m % 5;
			m = m + 6;
		}
		return m + j;
	}
	
	public int function2(int i) {
		int j = 10;
		int m = j * i;
		
		if (j < i) {
			m = m + 1;
			m = m * 2;
			m = m - 3;
			m = m / 4;
			m = m % 5;
			m = m + 6;
		}
		return m + j;
	}
}
