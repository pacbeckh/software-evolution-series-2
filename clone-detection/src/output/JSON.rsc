module output::JSON


import IO;
import Set;
import String;
import lang::json::IO;

import maintenance::Domain;
import Domain;

public str cloneClassesToJSON(loc basePath, map[int, set[CloneClass]] cloneClasses) {
	int  counter = 0;
	json = for (weight <- cloneClasses, x <- cloneClasses[weight] ) {
		counter += 1;
		append cloneClassToJSON(basePath, weight, x, counter);
	}
	str output = toJSON(json, true);
	return output;
}

public str maintenanceToJSON(loc base, MaintenanceData maintenance) {
	map[FileAnalysis,list[int]] maintenanceDups = maintenance.fileDups;
	dups = for (k <- maintenanceDups) {
		append (
			"file" : relativePath(base, k.location),
			"lines" :maintenanceDups[k]
		);
	}  
	
	value json = (
		"project" : projectAnalysisToJSON(base, maintenance.project),
		"duplications" : dups
	);
	str output = toJSON(json, true);
	return output;
}

public value projectAnalysisToJSON(loc base, ProjectAnalysis project) {
	return (
		"LOC" : project.LOC,
		"files" : [ fileAnalysisToJSON(base, file) | file <- project.files ]
	);
	iprintln(project);
	return 1;
}

public value fileAnalysisToJSON(loc base, FileAnalysis fileAnalysis) = (
	"LOC" : fileAnalysis.LOC,
	"file" : relativePath(base, fileAnalysis.location),
	"lines" : [effectiveLineToJSON(line) | line <- fileAnalysis.lines]
);

public value effectiveLineToJSON(EffectiveLine ef) = ("number" : ef.number,"content" : ef.content);


public map[str,value] cloneClassToJSON(loc basePath, int weight, CloneClass clazz, int uid) {
	return (
		"uid" : "<uid>",
		"weight" : weight,
		"fragments" : [fragmentToJSON(basePath, fragment) | fragment <- clazz]
	);
}

public map[str,value] fragmentToJSON(loc basePath, loc fragment) {
	return (
		"file" : relativePath(basePath, fragment),
		"start" : locToFileLocationJSON(fragment, true),
		"end"   : locToFileLocationJSON(fragment, false)
	);
}
 
public str relativePath(loc base, loc subject) {
	str baseString;
	str subjectString;
	if (base.scheme == "project") {
		baseString = base.authority + base.path;
	} else {
		iprintln("WARN: (JSON.rsc) We have a problem determining the base string");
	}

	if (subject.scheme == "file" || subject.scheme == "java+compilationUnit") {
		subjectString = subject.path;
	} else {
		iprintln("WARN: (JSON.rsc) We have a problem determining the subject string");
	}
	
	if (/^<match:.*<baseString>>/ := subjectString) {
		return replaceFirst(subjectString, match, "");
	}
	
	iprintln("We have a problem detecting locations");
	iprintln(baseString);
	iprintln(subjectString);
	
	return "foo";
}
public value locToFileLocationJSON(loc l, bool getStart) {
	if(getStart) {
		return ("line" : l.begin.line, "col": l.begin.column);
	} else {
		return ("line" : l.end.line, "col": l.end.column);
	}
	
}