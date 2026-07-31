extends RefCounted
class_name SourceDrillProductionRuntimeState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

const SOURCE_DRILL_OUTPUT_BATCH_CALLBACK_KEY := "output_batch"
const SOURCE_DRILL_OUTPUT_BATCH_CALLBACK_FALLBACK := "source_drill_output_batch"
const SOURCE_DRILL_PROGRESS_FRACTION_CALLBACK_KEY := "progress_fraction"
const SOURCE_DRILL_PROGRESS_FRACTION_CALLBACK_FALLBACK := "source_drill_progress_fraction"
const SOURCE_DRILL_OUTPUT_BATCH_AMOUNT_KEY := "amount"
const SOURCE_DRILL_OUTPUT_BATCH_PROGRESS_KEY := "progress"
const SOURCE_DRILL_PRODUCTION_RAW_PROGRESS_BEFORE_DELTA_KEY := "raw_progress_before_delta"
const SOURCE_DRILL_PRODUCTION_RAW_PROGRESS_KEY := "raw_progress"
const SOURCE_DRILL_PRODUCTION_OUTPUT_BATCH_KEY := "output_batch"
const SOURCE_DRILL_PRODUCTION_OFFLOAD_AMOUNT_KEY := "offload_amount"
const SOURCE_DRILL_PRODUCTION_PRODUCED_DELTA_KEY := "produced_delta"
const SOURCE_DRILL_PRODUCTION_ITEM_PROGRESS_KEY := "item_progress"
const SOURCE_DRILL_PRODUCTION_SOURCE_OWNER_KEY := "source_owner"

const SOURCE_DRILL_OUTPUT_BATCH_GATE := "if(dominantItems > 0 && progress >= delay && items.total() < itemCapacity){"
const SOURCE_DRILL_OUTPUT_BATCH_AMOUNT := "int amount = (int)(progress / delay);"
const SOURCE_DRILL_OUTPUT_BATCH_PROGRESS_MOD := "progress %= delay;"
const SOURCE_DRILL_PROGRESS_FRACTION_METHOD := "public float progress(){"
const SOURCE_DRILL_PROGRESS_FRACTION_RETURN := "return dominantItem == null ? 0f : Mathf.clamp(progress / getDrillTime(dominantItem));"
const SOURCE_DRILL_PROGRESS_FRACTION_DOMINANT_ITEM_NULL := "dominantItem == null"
const SOURCE_DRILL_PROGRESS_FRACTION_PROGRESS_RATIO := "progress / getDrillTime(dominantItem)"
const SOURCE_DRILL_PROGRESS_FRACTION_MATHF_CLAMP := "return Math.max(Math.min(value, 1f), 0f);"

static func production_state(current_progress_fraction: float, drill_delay: float, output_delta: float, dominant_items: int, items_total: int, item_capacity: int, output_batch_fn: Callable, progress_fraction_fn: Callable) -> Dictionary:
	var raw_progress_before_delta := current_progress_fraction * drill_delay
	var raw_progress := raw_progress_before_delta + output_delta
	@warning_ignore("shadowed_variable")
	var output_batch: Dictionary = output_batch_fn.call(raw_progress, drill_delay, dominant_items, items_total, item_capacity)
	var offload_amount := int(output_batch.get(SOURCE_DRILL_OUTPUT_BATCH_AMOUNT_KEY, 0))
	var remaining_progress := float(output_batch.get(SOURCE_DRILL_OUTPUT_BATCH_PROGRESS_KEY, raw_progress))
	var next_progress_fraction := float(progress_fraction_fn.call(remaining_progress, drill_delay, dominant_items > 0))
	return {
		SOURCE_DRILL_PRODUCTION_RAW_PROGRESS_BEFORE_DELTA_KEY: raw_progress_before_delta,
		SOURCE_DRILL_PRODUCTION_RAW_PROGRESS_KEY: raw_progress,
		SOURCE_DRILL_PRODUCTION_OUTPUT_BATCH_KEY: output_batch,
		SOURCE_DRILL_PRODUCTION_OFFLOAD_AMOUNT_KEY: offload_amount,
		SOURCE_DRILL_PRODUCTION_PRODUCED_DELTA_KEY: offload_amount,
		SOURCE_DRILL_PRODUCTION_ITEM_PROGRESS_KEY: next_progress_fraction,
		SOURCE_DRILL_PRODUCTION_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_DRILL_PRODUCTION_RUNTIME_STATE,
	}

static func game_production_state(game: Object, current_progress_fraction: float, drill_delay: float, output_delta: float, dominant_items: int, items_total: int, item_capacity: int) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return production_state(
		current_progress_fraction,
		drill_delay,
		output_delta,
		dominant_items,
		items_total,
		item_capacity,
		callbacks.get(SOURCE_DRILL_OUTPUT_BATCH_CALLBACK_KEY, Callable()),
		callbacks.get(SOURCE_DRILL_PROGRESS_FRACTION_CALLBACK_KEY, Callable())
	)

static func runtime_method_names(game: Object) -> Dictionary:
	if game.has_method("_drill_production_method_names"):
		var names = game.call("_drill_production_method_names")
		if names is Dictionary:
			return names
	return {}

static func runtime_method_name(method_names: Dictionary, key: String, fallback_name: String) -> String:
	var method_name = method_names.get(key, fallback_name)
	return str(method_name) if method_name != null and str(method_name) != "" else fallback_name

static func default_callbacks_state(game: Object) -> Dictionary:
	var method_names := runtime_method_names(game)
	return {
		SOURCE_DRILL_OUTPUT_BATCH_CALLBACK_KEY: Callable(game, runtime_method_name(method_names, SOURCE_DRILL_OUTPUT_BATCH_CALLBACK_KEY, SOURCE_DRILL_OUTPUT_BATCH_CALLBACK_FALLBACK)),
		SOURCE_DRILL_PROGRESS_FRACTION_CALLBACK_KEY: Callable(game, runtime_method_name(method_names, SOURCE_DRILL_PROGRESS_FRACTION_CALLBACK_KEY, SOURCE_DRILL_PROGRESS_FRACTION_CALLBACK_FALLBACK)),
	}

static func output_batch(progress: float, delay: float, dominant_items: int, items_total: int, item_capacity: int) -> Dictionary:
	if dominant_items > 0 and progress >= delay and items_total < item_capacity:
		var amount := int(progress / delay)
		return {SOURCE_DRILL_OUTPUT_BATCH_AMOUNT_KEY: amount, SOURCE_DRILL_OUTPUT_BATCH_PROGRESS_KEY: fmod(progress, delay)}
	return {SOURCE_DRILL_OUTPUT_BATCH_AMOUNT_KEY: 0, SOURCE_DRILL_OUTPUT_BATCH_PROGRESS_KEY: progress}

static func progress_fraction(progress: float, delay: float, has_dominant_item: bool) -> float:
	if not has_dominant_item:
		return 0.0
	return clampf(progress / delay, 0.0, 1.0)
