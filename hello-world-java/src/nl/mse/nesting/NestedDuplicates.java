package nl.mse.nesting;

public class NestedDuplicates {

	int page;
	void createStorePage(int value) {
		page >>= 1;
		page >>= 2;
		page >>= 3;
		page >>= 4;
		page >>= 5;
		page >>= 6;
		page >>= 7;
		page = value;
	}

	int result;
	void long2bytes(int value) {
		result >>= 1;
		result >>= 2;
		result >>= 3;
		result >>= 4;
		result >>= 5;
		result >>= 6;
		result >>= 7;
		result = value;
	}
}
