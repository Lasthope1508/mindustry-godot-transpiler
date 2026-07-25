extends RefCounted
class_name SourceDrillProductionRuntimeState

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
	var output_batch: Dictionary = output_batch_fn.call(raw_progress, drill_delay, dominant_items, items_total, item_capacity)
	var offload_amount := int(output_batch.get("amount", 0))
	var remaining_progress := float(output_batch.get("progress", raw_progress))
	var next_progress_fraction := float(progress_fraction_fn.call(remaining_progress, drill_delay, dominant_items > 0))
	return {
		"raw_progress_before_delta": raw_progress_before_delta,
		"raw_progress": raw_progress,
		"output_batch": output_batch,
		"offload_amount": offload_amount,
		"produced_delta": offload_amount,
		"item_progress": next_progress_fraction,
		"source_owner": "PortGame.source_drill_production_runtime_state",
	}

static func default_callbacks_state(game: Object) -> Dictionary:
	return {
		"output_batch": Callable(game, "source_drill_output_batch"),
		"progress_fraction": Callable(game, "source_drill_progress_fraction"),
	}

static func output_batch(progress: float, delay: float, dominant_items: int, items_total: int, item_capacity: int) -> Dictionary:
	if dominant_items > 0 and progress >= delay and items_total < item_capacity:
		var amount := int(progress / delay)
		return {"amount": amount, "progress": fmod(progress, delay)}
	return {"amount": 0, "progress": progress}

static func progress_fraction(progress: float, delay: float, has_dominant_item: bool) -> float:
	if not has_dominant_item:
		return 0.0
	return clampf(progress / delay, 0.0, 1.0)
