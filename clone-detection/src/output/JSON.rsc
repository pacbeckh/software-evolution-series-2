module output::JSON
import IO;
import Set;
import String;
import lang::json::IO;

public str cloneClassesToJSON(loc basePath, map[int, set[set[tuple[loc,loc]]]] cloneClasses) {
	int  counter = 0;
	json = for (weight <- cloneClasses, x <- {getOneFrom(cloneClasses[weight])} ) {
		counter += 1;
		append cloneClassToJSON(basePath, weight, x, counter);
	}
	str output = toJSON(json, true);
	return output;
}


public map[str,value] cloneClassToJSON(loc basePath, int weight, set[tuple[loc,loc]] fragments, int uid) {
	return (
		"uid" : "<uid>",
		"weight" : weight,
		"fragments" : [fragmentToJSON(basePath, fragment) | fragment <- fragments]
	);
}

public map[str,value] fragmentToJSON(loc basePath, tuple[loc,loc] fragment) {
	return (
		"file" : relativePath(basePath, fragment[0]),
		"start" : locToFileLocationJSON(fragment[0], true),
		"end"   : locToFileLocationJSON(fragment[1], false)
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
	
	if (subject.scheme == "file") {
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