module util::Timing

import DateTime;

import util::Logging;

public void executeDuration(str message, void () f) {
	begin = now();
	logDebug("Start with \"<message>\"");
	
	f();
	
	end = now();
	Duration duration = end - begin;
	
	logDebug("Finished with \"<message>\" in: <duration.minutes>:<duration.seconds>:<duration.milliseconds>");
}