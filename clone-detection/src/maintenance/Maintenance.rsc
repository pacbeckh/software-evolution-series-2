module maintenance::Maintenance


import List;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import maintenance::LOC;
import maintenance::Domain;
import maintenance::DuplicationDetection;


public MaintenanceData runMaintenance(M3 m3Model) {
	ProjectAnalysis p = analyseProject(m3Model);
	set[LineRefs] dups = computeDuplications(p);
	map[FileAnalysis,list[int]] agg = aggregateDuplications(dups);
	return maintenanceData(p, agg);
}

public ProjectAnalysis analyseProject(M3 model) {
	set[loc] compilationUnits = { x| <x,_> <- model@containment, isCompilationUnit(x)};
	list[FileAnalysis] files = [analyseFile(c, model) | c <- compilationUnits];
	int totalLoc = (0 | it + file.LOC | file <- files);
	return projectAnalysis(totalLoc, files);
}

public FileAnalysis analyseFile(loc cu, M3 model) {
	list[EffectiveLine] lines = relevantLines(cu);
	
	//TODO CACHING?
	Declaration declaration = createAstFromFile(cu, false, javaVersion="1.6");
	set[loc] classes = {x | <cu1, x> <- model@containment, cu1 == cu, isClass(x)};	
	return fileAnalysis(size(lines), lines, cu);
}