module maintenance::Domain

data EffectiveLine = effectiveLine(int number, str content);

data FileAnalysis = fileAnalysis(int LOC, list[EffectiveLine] lines, loc location);

data ProjectAnalysis = projectAnalysis(int LOC, list[FileAnalysis] files);

alias FileDuplications = map[FileAnalysis,list[int]];

data MaintenanceData = maintenanceData(ProjectAnalysis project, FileDuplications fileDups);