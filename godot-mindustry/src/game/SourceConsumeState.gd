extends RefCounted
class_name SourceConsumeState

static func source_cost_multiplier_state(_build: Variant) -> Dictionary:
	return {"multiplier": 1.0}

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_consume_base_source_text_state := preload("res://src/game/SourceConsumeBaseSourceTextState.gd")

const SOURCE_CONSUME_SOURCE_OWNER_KEY := source_consume_base_source_text_state.SOURCE_CONSUME_SOURCE_OWNER_KEY
const SOURCE_CONSUME_SOURCE_KEY := source_consume_base_source_text_state.SOURCE_CONSUME_SOURCE_KEY
const SOURCE_CONSUME_CONSUMERS_KEY := source_consume_base_source_text_state.SOURCE_CONSUME_CONSUMERS_KEY
const SOURCE_CONSUME_OPTIONAL_CONSUMERS_KEY := source_consume_base_source_text_state.SOURCE_CONSUME_OPTIONAL_CONSUMERS_KEY
const SOURCE_CONSUME_NON_OPTIONAL_CONSUMERS_KEY := source_consume_base_source_text_state.SOURCE_CONSUME_NON_OPTIONAL_CONSUMERS_KEY
const SOURCE_CONSUME_UPDATE_CONSUMERS_KEY := source_consume_base_source_text_state.SOURCE_CONSUME_UPDATE_CONSUMERS_KEY
const SOURCE_CONSUME_HAS_CONSUMERS_KEY := source_consume_base_source_text_state.SOURCE_CONSUME_HAS_CONSUMERS_KEY
const SOURCE_CONSUME_CONS_POWER_KEY := source_consume_base_source_text_state.SOURCE_CONSUME_CONS_POWER_KEY
const SOURCE_CONSUME_APPLY_CALLS_KEY := source_consume_base_source_text_state.SOURCE_CONSUME_APPLY_CALLS_KEY
const SOURCE_CONSUME_APPLY_CALL_COUNT_KEY := source_consume_base_source_text_state.SOURCE_CONSUME_APPLY_CALL_COUNT_KEY
const SOURCE_CONSUME_APPLY_CALL_KEY := source_consume_base_source_text_state.SOURCE_CONSUME_APPLY_CALL_KEY
const SOURCE_CONSUME_CONSUMER_KEY := source_consume_base_source_text_state.SOURCE_CONSUME_CONSUMER_KEY
const SOURCE_CONSUME_BLOCK_ARG_KEY := source_consume_base_source_text_state.SOURCE_CONSUME_BLOCK_ARG_KEY
const SOURCE_CONSUME_OPTIONAL_AFTER_KEY := source_consume_base_source_text_state.SOURCE_CONSUME_OPTIONAL_AFTER_KEY
const SOURCE_CONSUME_BOOSTER_AFTER_KEY := source_consume_base_source_text_state.SOURCE_CONSUME_BOOSTER_AFTER_KEY
const SOURCE_CONSUME_RETURN_SELF_KEY := source_consume_base_source_text_state.SOURCE_CONSUME_RETURN_SELF_KEY
const SOURCE_CONSUME_METHOD_KEY := source_consume_base_source_text_state.SOURCE_CONSUME_METHOD_KEY
const SOURCE_CONSUME_UPDATE_AFTER_KEY := source_consume_base_source_text_state.SOURCE_CONSUME_UPDATE_AFTER_KEY
const SOURCE_CONSUME_IGNORED_KEY := source_consume_base_source_text_state.SOURCE_CONSUME_IGNORED_KEY
const SOURCE_CONSUME_EMPTY_BODY_KEY := source_consume_base_source_text_state.SOURCE_CONSUME_EMPTY_BODY_KEY
const SOURCE_CONSUME_BUILD_KEY := source_consume_base_source_text_state.SOURCE_CONSUME_BUILD_KEY
const SOURCE_CONSUME_TABLE_KEY := source_consume_base_source_text_state.SOURCE_CONSUME_TABLE_KEY
const SOURCE_CONSUME_BLOCK_KEY := source_consume_base_source_text_state.SOURCE_CONSUME_BLOCK_KEY
const SOURCE_CONSUME_STATS_KEY := source_consume_base_source_text_state.SOURCE_CONSUME_STATS_KEY
const SOURCE_CONSUME_EFFICIENCY_KEY := source_consume_base_source_text_state.SOURCE_CONSUME_EFFICIENCY_KEY
const SOURCE_CONSUME_EFFICIENCY_MULTIPLIER_KEY := source_consume_base_source_text_state.SOURCE_CONSUME_EFFICIENCY_MULTIPLIER_KEY

const SOURCE_CONSUME_OPTIONAL_METHOD := source_consume_base_source_text_state.SOURCE_CONSUME_OPTIONAL_METHOD
const SOURCE_CONSUME_BOOST_METHOD := source_consume_base_source_text_state.SOURCE_CONSUME_BOOST_METHOD
const SOURCE_CONSUME_UPDATE_FLAG_METHOD := source_consume_base_source_text_state.SOURCE_CONSUME_UPDATE_FLAG_METHOD
const SOURCE_CONSUME_IGNORE_METHOD := source_consume_base_source_text_state.SOURCE_CONSUME_IGNORE_METHOD
const SOURCE_CONSUME_BUILD_METHOD := source_consume_base_source_text_state.SOURCE_CONSUME_BUILD_METHOD
const SOURCE_CONSUME_APPLY_METHOD := source_consume_base_source_text_state.SOURCE_CONSUME_APPLY_METHOD
const SOURCE_CONSUME_TRIGGER_METHOD := source_consume_base_source_text_state.SOURCE_CONSUME_TRIGGER_METHOD
const SOURCE_CONSUME_UPDATE_BUILD_METHOD := source_consume_base_source_text_state.SOURCE_CONSUME_UPDATE_BUILD_METHOD
const SOURCE_CONSUME_DISPLAY_METHOD := source_consume_base_source_text_state.SOURCE_CONSUME_DISPLAY_METHOD
const SOURCE_CONSUME_EFFICIENCY_METHOD := source_consume_base_source_text_state.SOURCE_CONSUME_EFFICIENCY_METHOD
const SOURCE_CONSUME_EFFICIENCY_MULTIPLIER_METHOD := source_consume_base_source_text_state.SOURCE_CONSUME_EFFICIENCY_MULTIPLIER_METHOD

static func classify_consumer_arrays(consume_builder: Array, ignored_key: String, optional_key: String, update_key: String) -> Dictionary:
	var consumers: Array = consume_builder.duplicate()
	var optional_consumers: Array = []
	var non_optional_consumers: Array = []
	var update_consumers: Array = []
	for consumer in consume_builder:
		if not consumer is Dictionary:
			continue
		var ignored: bool = bool(consumer.get(ignored_key, false))
		var optional: bool = bool(consumer.get(optional_key, false))
		if optional and not ignored:
			optional_consumers.append(consumer)
		if not optional and not ignored:
			non_optional_consumers.append(consumer)
		if bool(consumer.get(update_key, true)) and not ignored:
			update_consumers.append(consumer)
	return {
		SOURCE_CONSUME_CONSUMERS_KEY: consumers,
		SOURCE_CONSUME_OPTIONAL_CONSUMERS_KEY: optional_consumers,
		SOURCE_CONSUME_NON_OPTIONAL_CONSUMERS_KEY: non_optional_consumers,
		SOURCE_CONSUME_UPDATE_CONSUMERS_KEY: update_consumers,
		SOURCE_CONSUME_HAS_CONSUMERS_KEY: consumers.size() > 0,
	}

static func first_consumer_with_flag(consume_builder: Array, flag_key: String) -> Variant:
	for consumer in consume_builder:
		if consumer is Dictionary and bool(consumer.get(flag_key, false)):
			return consumer
	return null

static func consumer_apply_calls(consumers: Array, apply_expr: String, block_arg: String) -> Dictionary:
	var apply_calls: Array = []
	for consumer in consumers:
		apply_calls.append({
			SOURCE_CONSUME_APPLY_CALL_KEY: apply_expr,
			SOURCE_CONSUME_CONSUMER_KEY: consumer,
			SOURCE_CONSUME_BLOCK_ARG_KEY: block_arg,
		})
	return {
		SOURCE_CONSUME_APPLY_CALLS_KEY: apply_calls,
		SOURCE_CONSUME_APPLY_CALL_COUNT_KEY: apply_calls.size(),
	}

static func optional_state(optional_value: bool, boost_value: bool) -> Dictionary:
	return {
		SOURCE_CONSUME_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_OPTIONAL_STATE,
		SOURCE_CONSUME_OPTIONAL_AFTER_KEY: optional_value,
		SOURCE_CONSUME_BOOSTER_AFTER_KEY: boost_value,
		SOURCE_CONSUME_RETURN_SELF_KEY: true,
		SOURCE_CONSUME_METHOD_KEY: SOURCE_CONSUME_OPTIONAL_METHOD,
	}

static func boost_state() -> Dictionary:
	return {
		SOURCE_CONSUME_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_BOOST_STATE,
		SOURCE_CONSUME_OPTIONAL_AFTER_KEY: true,
		SOURCE_CONSUME_BOOSTER_AFTER_KEY: true,
		SOURCE_CONSUME_RETURN_SELF_KEY: true,
		SOURCE_CONSUME_METHOD_KEY: SOURCE_CONSUME_BOOST_METHOD,
	}

static func update_flag_state(update_value: bool) -> Dictionary:
	return {
		SOURCE_CONSUME_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_UPDATE_FLAG_STATE,
		SOURCE_CONSUME_UPDATE_AFTER_KEY: update_value,
		SOURCE_CONSUME_RETURN_SELF_KEY: true,
		SOURCE_CONSUME_METHOD_KEY: SOURCE_CONSUME_UPDATE_FLAG_METHOD,
	}

static func ignore_state() -> Dictionary:
	return {
		SOURCE_CONSUME_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_IGNORE_STATE,
		SOURCE_CONSUME_IGNORED_KEY: false,
		SOURCE_CONSUME_METHOD_KEY: SOURCE_CONSUME_IGNORE_METHOD,
	}

static func build_state(build: Variant, table: Variant) -> Dictionary:
	return {
		SOURCE_CONSUME_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_BUILD_STATE,
		SOURCE_CONSUME_EMPTY_BODY_KEY: true,
		SOURCE_CONSUME_BUILD_KEY: build,
		SOURCE_CONSUME_TABLE_KEY: table,
		SOURCE_CONSUME_METHOD_KEY: SOURCE_CONSUME_BUILD_METHOD,
	}

static func apply_state(block: Variant) -> Dictionary:
	return {
		SOURCE_CONSUME_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_APPLY_STATE,
		SOURCE_CONSUME_EMPTY_BODY_KEY: true,
		SOURCE_CONSUME_BLOCK_KEY: block,
		SOURCE_CONSUME_METHOD_KEY: SOURCE_CONSUME_APPLY_METHOD,
	}

static func trigger_state(build: Variant) -> Dictionary:
	return {
		SOURCE_CONSUME_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_TRIGGER_STATE,
		SOURCE_CONSUME_EMPTY_BODY_KEY: true,
		SOURCE_CONSUME_BUILD_KEY: build,
		SOURCE_CONSUME_METHOD_KEY: SOURCE_CONSUME_TRIGGER_METHOD,
	}

static func update_build_state(build: Variant) -> Dictionary:
	return {
		SOURCE_CONSUME_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_UPDATE_BUILD_STATE,
		SOURCE_CONSUME_EMPTY_BODY_KEY: true,
		SOURCE_CONSUME_BUILD_KEY: build,
		SOURCE_CONSUME_METHOD_KEY: SOURCE_CONSUME_UPDATE_BUILD_METHOD,
	}

static func display_state(stats: Variant) -> Dictionary:
	return {
		SOURCE_CONSUME_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_DISPLAY_STATE,
		SOURCE_CONSUME_EMPTY_BODY_KEY: true,
		SOURCE_CONSUME_STATS_KEY: stats,
		SOURCE_CONSUME_METHOD_KEY: SOURCE_CONSUME_DISPLAY_METHOD,
	}

static func efficiency_state() -> Dictionary:
	return {
		SOURCE_CONSUME_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_EFFICIENCY_STATE,
		SOURCE_CONSUME_EFFICIENCY_KEY: 1.0,
		SOURCE_CONSUME_METHOD_KEY: SOURCE_CONSUME_EFFICIENCY_METHOD,
	}

static func efficiency_multiplier_state() -> Dictionary:
	return {
		SOURCE_CONSUME_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_EFFICIENCY_MULTIPLIER_STATE,
		SOURCE_CONSUME_EFFICIENCY_MULTIPLIER_KEY: 1.0,
		SOURCE_CONSUME_METHOD_KEY: SOURCE_CONSUME_EFFICIENCY_MULTIPLIER_METHOD,
	}
