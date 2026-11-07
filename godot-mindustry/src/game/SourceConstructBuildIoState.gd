extends RefCounted
class_name SourceConstructBuildIoState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_construct_block_source_text_state := preload("res://src/game/SourceConstructBlockSourceTextState.gd")

const SOURCE_CONSTRUCT_BLOCK_SOURCE := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BLOCK_SOURCE
const SOURCE_CONSTRUCT_BUILD_CLASS_EXPR := source_construct_block_source_text_state.SOURCE_CONSTRUCT_BUILD_CLASS_EXPR
const CONSTRUCT_BUILD_CLASS_EXPR := SOURCE_CONSTRUCT_BUILD_CLASS_EXPR

static func progress_state(progress_value: float) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_CONSTRUCT_BUILD_PROGRESS_STATE,
		"source": SOURCE_CONSTRUCT_BLOCK_SOURCE,
		"class_expr": CONSTRUCT_BUILD_CLASS_EXPR,
		"progress_method": "public float progress(){",
		"progress_return_expr": "return progress;",
		"progress": progress_value,
	}

static func version_state() -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_CONSTRUCT_BUILD_VERSION_STATE,
		"source": SOURCE_CONSTRUCT_BLOCK_SOURCE,
		"class_expr": CONSTRUCT_BUILD_CLASS_EXPR,
		"version_method": "public byte version(){",
		"version_return_expr": "return 1;",
		"version": 1,
	}

static func write_state(progress_value: float, previous_block_id: int, current_block_id: int, accumulator: Variant, total_accumulator: Variant, items_left: Variant) -> Dictionary:
	var write_calls: Array = []
	write_calls.append({"op": "super.write", "value": null})
	write_calls.append({"op": "f", "value": progress_value})
	write_calls.append({"op": "s", "value": previous_block_id})
	write_calls.append({"op": "s", "value": current_block_id})
	var accumulator_is_null: bool = accumulator == null
	var accumulator_length: int = -1
	var entry_writes: Array = []
	if accumulator_is_null:
		write_calls.append({"op": "b", "value": -1})
	else:
		accumulator_length = accumulator.size()
		write_calls.append({"op": "b", "value": accumulator_length})
		for i in range(accumulator_length):
			var accumulator_value: float = float(accumulator[i])
			var total_accumulator_value: float = float(total_accumulator[i]) if total_accumulator is Array and i < total_accumulator.size() else 0.0
			var items_left_value: int = int(items_left[i]) if items_left is Array and i < items_left.size() else 0
			write_calls.append({"op": "f", "value": float(accumulator[i])})
			write_calls.append({"op": "f", "value": total_accumulator_value})
			write_calls.append({"op": "i", "value": items_left_value})
			entry_writes.append({
				"index": i,
				"accumulator": accumulator_value,
				"total_accumulator": total_accumulator_value,
				"items_left": items_left_value,
			})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_CONSTRUCT_BUILD_WRITE_STATE,
		"source": SOURCE_CONSTRUCT_BLOCK_SOURCE,
		"class_expr": CONSTRUCT_BUILD_CLASS_EXPR,
		"write_method": "public void write(Writes write){",
		"super_write_expr": "super.write(write);",
		"write_progress_expr": "write.f(progress);",
		"write_previous_expr": "write.s(previous.id);",
		"write_current_expr": "write.s(current.id);",
		"accumulator_null_guard_expr": "if(accumulator == null){",
		"write_null_size_expr": "write.b(-1);",
		"write_size_expr": "write.b(accumulator.length);",
		"write_loop_expr": "for(int i = 0; i < accumulator.length; i++){",
		"write_accumulator_expr": "write.f(accumulator[i]);",
		"write_total_accumulator_expr": "write.f(totalAccumulator[i]);",
		"write_items_left_expr": "write.i(itemsLeft[i]);",
		"progress": progress_value,
		"previous_block_id": previous_block_id,
		"current_block_id": current_block_id,
		"accumulator_is_null": accumulator_is_null,
		"accumulator_length": accumulator_length,
		"entry_writes": entry_writes,
		"write_calls": write_calls,
	}

static func _lookup_content_block(content_blocks: Dictionary, block_id: int) -> Variant:
	if content_blocks.has(block_id):
		return content_blocks.get(block_id, null)
	return content_blocks.get(str(block_id), null)

static func read_state(progress_value: float, previous_block_id: int, current_block_id: int, accumulator_size: int, accumulator_values: Array, total_accumulator_values: Array, items_left_values: Array, revision_value: int, content_blocks: Dictionary, air_block: Variant, build_cost_multiplier: float) -> Dictionary:
	var accumulator_after: Variant = null
	var total_accumulator_after: Variant = null
	var items_left_after: Variant = null
	var entry_reads: Array = []
	if accumulator_size != -1:
		accumulator_after = []
		total_accumulator_after = []
		items_left_after = []
		for i in range(accumulator_size):
			var accumulator_value: float = float(accumulator_values[i]) if i < accumulator_values.size() else 0.0
			var total_accumulator_value: float = float(total_accumulator_values[i]) if i < total_accumulator_values.size() else 0.0
			var items_left_value: int = 0
			if revision_value >= 1:
				items_left_value = int(items_left_values[i]) if i < items_left_values.size() else 0
			accumulator_after.append(accumulator_value)
			total_accumulator_after.append(total_accumulator_value)
			items_left_after.append(items_left_value)
			entry_reads.append({
				"index": i,
				"accumulator": accumulator_value,
				"total_accumulator": total_accumulator_value,
				"items_left": items_left_value,
				"items_left_read": revision_value >= 1,
			})
	var previous_after: Variant = _lookup_content_block(content_blocks, previous_block_id) if previous_block_id != -1 else null
	var current_after: Variant = _lookup_content_block(content_blocks, current_block_id) if current_block_id != -1 else null
	var previous_defaulted_to_air: bool = previous_after == null
	var current_defaulted_to_air: bool = current_after == null
	if previous_defaulted_to_air:
		previous_after = air_block
	if current_defaulted_to_air:
		current_after = air_block
	var current_build_time: float = float(current_after.get("buildTime", 0.0)) if current_after is Dictionary else 0.0
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_CONSTRUCT_BUILD_READ_STATE,
		"source": SOURCE_CONSTRUCT_BLOCK_SOURCE,
		"class_expr": CONSTRUCT_BUILD_CLASS_EXPR,
		"read_method": "public void read(Reads read, byte revision){",
		"super_read_expr": "super.read(read, revision);",
		"read_progress_expr": "progress = read.f();",
		"read_previous_expr": "short pid = read.s();",
		"read_current_expr": "short rid = read.s();",
		"read_accumulator_size_expr": "byte acsize = read.b();",
		"acsize_guard_expr": "if(acsize != -1){",
		"accumulator_alloc_expr": "accumulator = new float[acsize];",
		"total_accumulator_alloc_expr": "totalAccumulator = new float[acsize];",
		"items_left_alloc_expr": "itemsLeft = new int[acsize];",
		"read_loop_expr": "for(int i = 0; i < acsize; i++){",
		"read_accumulator_expr": "accumulator[i] = read.f();",
		"read_total_accumulator_expr": "totalAccumulator[i] = read.f();",
		"revision_items_left_guard_expr": "if(revision >= 1){",
		"read_items_left_expr": "itemsLeft[i] = read.i();",
		"previous_lookup_expr": "if(pid != -1) previous = content.block(pid);",
		"current_lookup_expr": "if(rid != -1) current = content.block(rid);",
		"previous_air_expr": "if(previous == null) previous = Blocks.air;",
		"current_air_expr": "if(current == null) current = Blocks.air;",
		"build_cost_expr": "buildCost = current.buildTime * state.rules.buildCostMultiplier;",
		"progress": progress_value,
		"previous_block_id": previous_block_id,
		"current_block_id": current_block_id,
		"accumulator_size": accumulator_size,
		"revision": revision_value,
		"accumulator_after": accumulator_after,
		"total_accumulator_after": total_accumulator_after,
		"items_left_after": items_left_after,
		"entry_reads": entry_reads,
		"previous": previous_after,
		"current": current_after,
		"previous_defaulted_to_air": previous_defaulted_to_air,
		"current_defaulted_to_air": current_defaulted_to_air,
		"build_cost": current_build_time * build_cost_multiplier,
		"build_cost_multiplier": build_cost_multiplier,
	}
