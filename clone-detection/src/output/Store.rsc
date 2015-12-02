module output::Store

import IO;

import output::JSON;

public void storeInServer(loc l, map[int, set[set[tuple[loc,loc]]]] cloneClasses) {
	for (f <- |project://clone-detection/output|.ls) {
		remove(f);
	}
	str json = cloneClassesToJSON(l, cloneClasses);
	copyDirectory(l, |project://clone-detection/output/files|);
	writeFile(|project://clone-detection/output/clones.json|, json);
		
}