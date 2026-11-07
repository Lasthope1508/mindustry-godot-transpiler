extends RefCounted
class_name SourceDrillDumpRuntimeState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_drill_dump_source_text_state := preload("res://src/game/SourceDrillDumpSourceTextState.gd")

const SOURCE_DRILL_DUMP_INTERVAL_CALLBACK_KEY := source_drill_dump_source_text_state.SOURCE_DRILL_DUMP_INTERVAL_CALLBACK_KEY
const SOURCE_DRILL_DUMP_PREVIEW_RUNTIME_STATE_CALLBACK_KEY := source_drill_dump_source_text_state.SOURCE_DRILL_DUMP_PREVIEW_RUNTIME_STATE_CALLBACK_KEY
const SOURCE_DRILL_DUMP_BLOCK_DUMP_TIME_CALLBACK_KEY := source_drill_dump_source_text_state.SOURCE_DRILL_DUMP_BLOCK_DUMP_TIME_CALLBACK_KEY
const SOURCE_DRILL_DUMP_BLOCK_DUMP_TIME_METHOD_FALLBACK := source_drill_dump_source_text_state.SOURCE_DRILL_DUMP_BLOCK_DUMP_TIME_METHOD_FALLBACK
const SOURCE_DRILL_DUMP_CURRENT_TIMER_KEY := source_drill_dump_source_text_state.SOURCE_DRILL_DUMP_CURRENT_TIMER_KEY
const SOURCE_DRILL_DUMP_SOURCE_DELTA_KEY := source_drill_dump_source_text_state.SOURCE_DRILL_DUMP_SOURCE_DELTA_KEY
const SOURCE_DRILL_DUMP_INTERVAL_KEY := source_drill_dump_source_text_state.SOURCE_DRILL_DUMP_INTERVAL_KEY
const SOURCE_DRILL_DUMP_RUNTIME_STATE_METHOD_KEY := source_drill_dump_source_text_state.SOURCE_DRILL_DUMP_RUNTIME_STATE_METHOD_KEY
const SOURCE_DRILL_DUMP_TIMER_BEFORE_KEY := source_drill_dump_source_text_state.SOURCE_DRILL_DUMP_TIMER_BEFORE_KEY
const SOURCE_DRILL_DUMP_TIMER_KEY := source_drill_dump_source_text_state.SOURCE_DRILL_DUMP_TIMER_KEY
const SOURCE_DRILL_DUMP_SHOULD_DUMP_KEY := source_drill_dump_source_text_state.SOURCE_DRILL_DUMP_SHOULD_DUMP_KEY
const SOURCE_DRILL_DUMP_ATTEMPTS_KEY := source_drill_dump_source_text_state.SOURCE_DRILL_DUMP_ATTEMPTS_KEY
const SOURCE_DRILL_DUMP_INTERVAL_TIMER_GATE := source_drill_dump_source_text_state.SOURCE_DRILL_DUMP_INTERVAL_TIMER_GATE
const SOURCE_DRILL_DUMP_INTERVAL_DUMP_CALL := source_drill_dump_source_text_state.SOURCE_DRILL_DUMP_INTERVAL_DUMP_CALL
const SOURCE_DRILL_DUMP_INTERVAL_TIMER_DUMP_COMMENT := source_drill_dump_source_text_state.SOURCE_DRILL_DUMP_INTERVAL_TIMER_DUMP_COMMENT
const SOURCE_DRILL_DUMP_INTERVAL_TIMER_DUMP_FIELD := source_drill_dump_source_text_state.SOURCE_DRILL_DUMP_INTERVAL_TIMER_DUMP_FIELD
const SOURCE_DRILL_DUMP_INTERVAL_DUMP_TIME_COMMENT := source_drill_dump_source_text_state.SOURCE_DRILL_DUMP_INTERVAL_DUMP_TIME_COMMENT
const SOURCE_DRILL_DUMP_INTERVAL_DUMP_TIME_FIELD := source_drill_dump_source_text_state.SOURCE_DRILL_DUMP_INTERVAL_DUMP_TIME_FIELD

static func default_callbacks_state(game: Object) -> Dictionary:
	return {
		SOURCE_DRILL_DUMP_BLOCK_DUMP_TIME_CALLBACK_KEY: Callable(game, SOURCE_DRILL_DUMP_BLOCK_DUMP_TIME_METHOD_FALLBACK),
	}

static func game_dump_interval(game: Object, block_id: String, time_scale: float) -> float:
	return dump_interval(block_id, time_scale, default_callbacks_state(game).get(SOURCE_DRILL_DUMP_BLOCK_DUMP_TIME_CALLBACK_KEY, Callable()))

static func dump_interval(block_id: String, time_scale: float, block_dump_time_fn: Callable) -> float:
	return float(block_dump_time_fn.call(block_id)) / time_scale

@warning_ignore("shadowed_variable")
static func dump_timer_state(current_timer: float, source_delta: float, dump_interval: float) -> Dictionary:
	var next_timer := current_timer + source_delta
	var should_dump := false
	if dump_interval > 0.0 and next_timer >= dump_interval:
		next_timer -= dump_interval
		should_dump = true
	return {
		SOURCE_DRILL_DUMP_TIMER_BEFORE_KEY: current_timer,
		SOURCE_DRILL_DUMP_SOURCE_DELTA_KEY: source_delta,
		SOURCE_DRILL_DUMP_INTERVAL_KEY: dump_interval,
		SOURCE_DRILL_DUMP_TIMER_KEY: next_timer,
		SOURCE_DRILL_DUMP_SHOULD_DUMP_KEY: should_dump,
		SOURCE_DRILL_DUMP_ATTEMPTS_KEY: 1 if should_dump else 0,
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_DRILL_DUMP_RUNTIME_STATE,
	}
