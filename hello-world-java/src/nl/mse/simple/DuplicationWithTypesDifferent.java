package nl.mse.simple;

public class DuplicationWithTypesDifferent {
	
	public String foo1(String a) {
		a = a + "1";
		a = a + "2";
		a = a + "3";
		a = a + "4";
		a = a + "5";
		return a;
	}
	
	public int foo2(int a) {
		a = a + 1;
		a = a + 2;
		a = a + 3;
		a = a + 4;
		a = a + 5;
		return a;
	}
}
