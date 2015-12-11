module maintenance::Maintenance


import List;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import maintenance::LOC;
import maintenance::Domain;
import maintenance::DuplicationDetection;


public MaintenanceData runMaintenance(M3 m3Model, lrel[loc,Declaration] declarations) {
	ProjectAnalysis p = analyseProject(m3Model, declarations);
	set[LineRefs] dups = computeDuplications(p);
	map[FileAnalysis,list[int]] agg = aggregateDuplications(dups);
	return maintenanceData(p, agg);
}

public ProjectAnalysis analyseProject(M3 model, lrel[loc,Declaration] declarations) {
	list[FileAnalysis] files = [analyseFile(c, model, declaration) | <c, declaration> <- declarations];
	int totalLoc = (0 | it + file.LOC | file <- files);
	return projectAnalysis(totalLoc, files);
}

public FileAnalysis analyseFile(loc cu, M3 model, Declaration declaration) {
	list[EffectiveLine] lines = relevantLines(cu);
	set[loc] classes = {x | <cu1, x> <- model@containment, cu1 == cu, isClass(x)};	
	return fileAnalysis(size(lines), lines, cu);
}