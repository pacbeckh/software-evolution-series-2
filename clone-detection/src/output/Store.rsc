module output::Store

import IO;

public void storeInServer(loc l) {
	for (f <- |project://clone-detection/output|.ls) {
		remove(f);
	}
	copyDirectory(l, |project://clone-detection/output/files|);
		
}