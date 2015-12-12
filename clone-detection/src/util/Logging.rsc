module util::Logging

import IO;
import DateTime;

public void logInfo(str message) {
	println("INFO  | <printTime(now())> | <message>");
}

public void logDebug(str message) {
	println("DEBUG | <printTime(now())> | <message>");
}

public void logWarn(str message) {
	println("WARN  | <printTime(now())> | <message>");
}