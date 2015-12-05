package nl.mse.anonimization;

public class Nesting {

	public void foo() {
		if(true) {
			if(true){
				if(true){
					if(true) {
						if(true) {
							System.out.println("test");
						}
					}
				}
			}
		}
		
	}

}
