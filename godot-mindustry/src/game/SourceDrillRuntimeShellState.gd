extends RefCounted
class_name SourceDrillRuntimeShellState

static func runtime_state(drill_context: Dictionary, drill_callbacks: Dictionary, schema: Dictionary) -> Dictionary:
	var active := bool(drill_context.get(str(schema.get("context_active", "")), false))
	var cell_x := int(drill_context.get(str(schema.get("context_cell_x", "")), 0))
	var cell_y := int(drill_context.get(str(schema.get("context_cell_y", "")), 0))
	var block_id := str(drill_context.get(str(schema.get("context_block_id", "")), ""))
	var item_id := str(drill_context.get(str(schema.get("context_item_id", "")), ""))
	var dominant_items := int(drill_context.get(str(schema.get("context_dominant_items", "")), 0))
	var items_total := int(drill_context.get(str(schema.get("context_items_total", "")), 0))
	var item_capacity := int(drill_context.get(str(schema.get("context_item_capacity", "")), 0))
	var current_warmup := float(drill_context.get(str(schema.get("context_current_warmup", "")), 0.0))
	var current_time_drilled := float(drill_context.get(str(schema.get("context_current_time_drilled", "")), 0.0))
	var current_last_speed := float(drill_context.get(str(schema.get("context_current_last_speed", "")), 0.0))
	var current_progress_fraction := float(drill_context.get(str(schema.get("context_current_progress_fraction", "")), 0.0))
	var seconds := float(drill_context.get(str(schema.get("context_seconds", "")), 0.0))
	var source_delta := float(drill_context.get(str(schema.get("context_source_delta", "")), 0.0))
	var time_scale := float(drill_context.get(str(schema.get("context_time_scale", "")), 1.0))
	var speed := float(drill_context.get(str(schema.get("context_speed", "")), 1.0))
	var warmup_speed_fn: Callable = drill_callbacks.get(str(schema.get("callback_warmup_speed", "")), Callable())
	var warmup_state_fn: Callable = drill_callbacks.get(str(schema.get("callback_warmup_state", "")), Callable())
	var inactive_warmup_state_fn: Callable = drill_callbacks.get(str(schema.get("callback_inactive_warmup_state", "")), Callable())
	var time_drilled_delta_fn: Callable = drill_callbacks.get(str(schema.get("callback_time_drilled_delta", "")), Callable())
	var last_speed_for_cell_fn: Callable = drill_callbacks.get(str(schema.get("callback_last_speed_for_cell", "")), Callable())
	var delay_fn: Callable = drill_callbacks.get(str(schema.get("callback_delay", "")), Callable())
	var output_delta_for_cell_fn: Callable = drill_callbacks.get(str(schema.get("callback_output_delta_for_cell", "")), Callable())
	var production_state_fn: Callable = drill_callbacks.get(str(schema.get("callback_production_state", "")), Callable())
	var warmup_speed := float(warmup_speed_fn.call(block_id))
	@warning_ignore("shadowed_variable")
	var time_drilled_delta := 0.0
	var drill_time_drilled := current_time_drilled
	var drill_last_speed := current_last_speed
	var drill_warmup := current_warmup
	@warning_ignore("shadowed_variable")
	var drill_delay := 0.0
	@warning_ignore("shadowed_variable")
	var output_delta := 0.0
	var production_state: Dictionary = {}
	var offload_amount := 0
	var produced_delta := 0
	var item_progress := current_progress_fraction
	if active:
		time_drilled_delta = float(time_drilled_delta_fn.call(current_warmup, seconds, time_scale))
		drill_time_drilled = current_time_drilled + time_drilled_delta
		drill_last_speed = float(last_speed_for_cell_fn.call(cell_x, cell_y, item_id, dominant_items, current_warmup, speed))
		drill_warmup = float(warmup_state_fn.call(current_warmup, speed, warmup_speed, source_delta))
		drill_delay = float(delay_fn.call(block_id, item_id))
		output_delta = float(output_delta_for_cell_fn.call(cell_x, cell_y, dominant_items, seconds, drill_warmup, speed))
		production_state = production_state_fn.call(current_progress_fraction, drill_delay, output_delta, dominant_items, items_total, item_capacity)
		offload_amount = int(production_state.get(str(schema.get("production_offload_amount", "")), 0))
		produced_delta = int(production_state.get(str(schema.get("production_produced_delta", "")), offload_amount))
		item_progress = float(production_state.get(str(schema.get("production_item_progress", "")), current_progress_fraction))
	else:
		var inactive_warmup := float(inactive_warmup_state_fn.call(current_warmup, warmup_speed, source_delta))
		drill_last_speed = 0.0
		drill_warmup = inactive_warmup
	return {
		str(schema.get("result_active", "")): active,
		str(schema.get("result_warmup_before", "")): current_warmup,
		str(schema.get("result_warmup", "")): drill_warmup,
		str(schema.get("result_last_speed_before", "")): current_last_speed,
		str(schema.get("result_last_speed", "")): drill_last_speed,
		str(schema.get("result_time_drilled_before", "")): current_time_drilled,
		str(schema.get("result_time_drilled_delta", "")): time_drilled_delta,
		str(schema.get("result_time_drilled", "")): drill_time_drilled,
		str(schema.get("result_delay", "")): drill_delay,
		str(schema.get("result_output_delta", "")): output_delta,
		str(schema.get("result_production_state", "")): production_state,
		str(schema.get("production_offload_amount", "")): offload_amount,
		str(schema.get("production_produced_delta", "")): produced_delta,
		str(schema.get("production_item_progress", "")): item_progress,
		str(schema.get("result_source_owner", "")): schema.get("source_owner", ""),
	}
