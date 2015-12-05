package nl.mse.anonimization;

public class Initializer {

	private int i;

	{
		i = 1;
		i %= 2;
		i += 1;
		i += 2;
		i += 500123123;
		System.out.println(i);
	}

	{
		i = 1;
		i = i % 2;
		i = i + 1;
		i = i + 2;
		i = i + 1;
		System.err.println(i);
	}

}
