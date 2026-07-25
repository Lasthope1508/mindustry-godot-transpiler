extends RefCounted
class_name SourceDrillDumpRuntimeState

const SOURCE_DRILL_DUMP_INTERVAL_TIMER_GATE := "if(timer(timerDump, dumpTime / timeScale)){"
const SOURCE_DRILL_DUMP_INTERVAL_DUMP_CALL := "dump(dominantItem != null && items.has(dominantItem) ? dominantItem : null);"
const SOURCE_DRILL_DUMP_INTERVAL_TIMER_DUMP_COMMENT := "Dump timer ID."
const SOURCE_DRILL_DUMP_INTERVAL_TIMER_DUMP_FIELD := "protected final int timerDump = timers++;"
const SOURCE_DRILL_DUMP_INTERVAL_DUMP_TIME_COMMENT := "How often to try dumping items in ticks, e.g. 5 = 12 times/sec"
const SOURCE_DRILL_DUMP_INTERVAL_DUMP_TIME_FIELD := "public int dumpTime = 5;"

static func default_callbacks_state(game: Object) -> Dictionary:
	return {
		"block_dump_time": Callable(game, "source_block_dump_time"),
	}

static func dump_interval(block_id: String, time_scale: float, block_dump_time_fn: Callable) -> float:
	return float(block_dump_time_fn.call(block_id)) / time_scale

static func dump_timer_state(current_timer: float, source_delta: float, dump_interval: float) -> Dictionary:
	var next_timer := current_timer + source_delta
	var should_dump := false
	if dump_interval > 0.0 and next_timer >= dump_interval:
		next_timer -= dump_interval
		should_dump = true
	return {
		"drill_dump_timer_before": current_timer,
		"source_delta": source_delta,
		"dump_interval": dump_interval,
		"drill_dump_timer": next_timer,
		"should_dump": should_dump,
		"dump_attempts": 1 if should_dump else 0,
		"source_owner": "PortGame.source_drill_dump_runtime_state",
	}
