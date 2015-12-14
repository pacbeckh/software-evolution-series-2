module output::Store

import IO;

import Domain;
import output::JSON;
import maintenance::Domain;

public void storeInServer(loc l, map[int, set[CloneClass]] cloneClasses, MaintenanceData maintenance) {
	for (f <- |project://clone-detection/output|.ls) {
		remove(f);
	}
	
	str json = cloneClassesToJSON(l, cloneClasses);
	str mainDups = maintenanceToJSON(l, maintenance);
	
	copyDirectory(l, |project://clone-detection/output/files|);
	writeFile(|project://clone-detection/output/clones.json|, json);
	writeFile(|project://clone-detection/output/maintenance.json|, mainDups);
	remove(|project://clone-detection/output/files/bin|);
}