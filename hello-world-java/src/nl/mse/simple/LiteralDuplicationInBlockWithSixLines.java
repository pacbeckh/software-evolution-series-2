package nl.mse.simple;

public class LiteralDuplicationInBlockWithSixLines {

	public int foo1(int i) {
		i = i + 1;
		i = i + 2;
		i = i + 3;
		i = i + 4;
		i = i + 5;
		return i;
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
