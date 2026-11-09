extends Node

const main_scene := preload("res://scenes/Main.tscn")
const liquid_state := preload("res://src/game/SourceConsumeLiquidState.gd")
const drill_consumption_state := preload("res://src/game/SourceDrillConsumptionRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")


func _ready() -> void:
	var proof: Dictionary = {}
	var game := main_scene.instantiate()
	add_child(game)
	for iteration in range(4):
		await get_tree().process_frame
	game.call("enter_campaign_playable_slice")
	for iteration in range(4):
		await get_tree().process_frame
	game.set_process(false)
	game.set_physics_process(false)
	var catalog = game.get("content_catalog")
	var block = catalog.get_many("block").filter(func(value): return value.id == "mechanical-drill")[0]
	var drill_sprite: Variant = game.call("block_sprite_at_cell", Vector2i(7, 8))

	# --- null/empty inputs invalidate nothing (no block, no frame). ---
	var null_result: Dictionary = liquid_state.source_invalidate_consumer_cache_state(null, null)
	proof["invalidate_null_block_frame_false"] = null_result.get("bound_rows_invalidated", true) == false and null_result.get("apply_invalidated", true) == false and null_result.get("frame_consumers_before", -1) == 0 and null_result.get("frame_consumers_invalidated", true) == false
	var fake_block := RefCounted.new()
	var empty_result: Dictionary = liquid_state.source_invalidate_consumer_cache_state(fake_block, {})
	proof["invalidate_empty_frame_zero"] = empty_result.get("bound_rows_invalidated", true) == false and empty_result.get("apply_invalidated", true) == false and empty_result.get("frame_consumers_before", -1) == 0 and empty_result.get("frame_consumers_invalidated", true) == false

	# --- the drill tick builds the cached RuntimeConsumer actors. ---
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	var frame: Dictionary = drill_sprite.get_meta(drill_consumption_state.SOURCE_DRILL_BUILDING_META_KEY, {})
	var consumers: Array = frame.get("consumers", [])
	proof["drill_frame_consumer_built"] = consumers.size() == 1 and float(consumers[0].definition.get("amount", -1.0)) == 0.05
	var bound_rows: Array = block.get_meta(liquid_state.SOURCE_BLOCK_LIQUID_CONSUMERS_META_KEY, [])
	proof["block_rows_bound_at_placement"] = block.has_meta(liquid_state.SOURCE_BLOCK_LIQUID_CONSUMERS_META_KEY) and bound_rows.size() == 1 and float(bound_rows[0].get("amount", -1.0)) == 0.05
	proof["block_apply_bound_at_placement"] = block.has_meta(liquid_state.SOURCE_BLOCK_LIQUID_APPLY_META_KEY)

	# --- simulate a reload: the block's consumeBuilder changes, but the
	# caches still hold the old rows until reinitializeConsumers runs. ---
	var old_actor: Variant = consumers[0]
	block.properties["consumeLiquid"][0]["amount"] = 0.1
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	frame = drill_sprite.get_meta(drill_consumption_state.SOURCE_DRILL_BUILDING_META_KEY, {})
	consumers = frame.get("consumers", [])
	proof["stale_actor_keeps_old_amount"] = consumers.size() == 1 and is_same(consumers[0], old_actor) and float(consumers[0].definition.get("amount", -1.0)) == 0.05
	bound_rows = block.get_meta(liquid_state.SOURCE_BLOCK_LIQUID_CONSUMERS_META_KEY, [])
	proof["stale_rows_keep_old_amount"] = bound_rows.size() == 1 and float(bound_rows[0].get("amount", -1.0)) == 0.05

	# --- the invalidation drops both block caches and the frame actors. ---
	var invalidated: Dictionary = liquid_state.source_invalidate_consumer_cache_state(block, frame)
	proof["invalidate_drops_bound_rows"] = invalidated.get("bound_rows_invalidated", false) == true and not block.has_meta(liquid_state.SOURCE_BLOCK_LIQUID_CONSUMERS_META_KEY)
	proof["invalidate_drops_apply"] = invalidated.get("apply_invalidated", false) == true and not block.has_meta(liquid_state.SOURCE_BLOCK_LIQUID_APPLY_META_KEY)
	proof["invalidate_clears_frame_consumers"] = invalidated.get("frame_consumers_before", -1) == 1 and invalidated.get("frame_consumers_invalidated", false) == true and frame.get("consumers", [null]).is_empty()

	# --- the next tick rebinds from the changed builder and rebuilds. ---
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	frame = drill_sprite.get_meta(drill_consumption_state.SOURCE_DRILL_BUILDING_META_KEY, {})
	consumers = frame.get("consumers", [])
	proof["rebuild_uses_new_amount"] = consumers.size() == 1 and float(consumers[0].definition.get("amount", -1.0)) == 0.1
	proof["rebuild_new_actor"] = consumers.size() == 1 and not is_same(consumers[0], old_actor)
	bound_rows = block.get_meta(liquid_state.SOURCE_BLOCK_LIQUID_CONSUMERS_META_KEY, [])
	proof["rebuild_rebinds_rows"] = bound_rows.size() == 1 and float(bound_rows[0].get("amount", -1.0)) == 0.1
	block.properties["consumeLiquid"][0]["amount"] = 0.05

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("ConsumerCacheInvalidationProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
