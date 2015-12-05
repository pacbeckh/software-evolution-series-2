package nl.mse.anonimization;

import java.util.List;

public class Cast {

	public List<String> cast(Object o) {
		return (List<String>) o;
	}

	public int cast2(int i) {
		i += 1;
		return i;
	}

	public Car cast3() {
		Car car = new Car();
		return car;
	}

	static class Car {

	}

}
