package nl.mse.simple;

public class DuplicationWithLastLineDifferent {

	public void foo1(int i) {
		i = i + 1;
		i = i + 2;
		i = i + 3;
		i = i + 4;
		i = i + 5;
		System.out.println(i);;
	}
	
	public int foo2(int i) {
		i = i + 1;
		i = i + 2;
		i = i + 3;
		i = i + 4;
		i = i + 5;
		return i;
	}
}
