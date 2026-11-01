extends Node

const main_scene := preload("res://scenes/Main.tscn")
const catalog_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const placed := preload("res://src/game/SourcePlacedBlockState.gd")
const storage := preload("res://src/game/SourceLiquidModuleState.gd")
const consumer := preload("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquid.gd")
const building := preload("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd")
const building_time := preload("res://src/game/SourceBuildingTimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")

class ProbeConsumer extends RefCounted:
	var frame: Dictionary
	var liquid_id: int
	var requests: Array = []
	var generated = consumer.new()

	func update(self_state: Dictionary) -> void:
		var edelta := building_time.edelta(2.0, 1.0, self_state["efficiency"])
		var request = generated.java_method_update_2([liquid_id, 0.5, edelta, 1.0])
		requests.append(request["remove_amount"])
		storage.source_remove_state(frame, liquid_id, request["remove_amount"], [])

func tick(actor: ProbeConsumer, enabled: bool = true, should_consume: bool = true) -> void:
	var amount = storage.source_get_state(actor.frame, actor.liquid_id)["amount"]
	var available = actor.generated.java_method_efficiency_3([amount, 0.5, 2.0, 1.0, 1.0])["efficiency"]
	var state := {"has_consumers": true, "cheating": false, "enabled_state": enabled, "production_valid": true, "should_consume_state": should_consume, "efficiency_scale": 1.0, "non_optional_consumer_results": [{"result": available, "is_power": false}], "optional_consumer_results": [], "update_consumers": [actor]}
	building.new().java_method_update_217([1.0, 0.0, 0.0, false, null, null, false, 0.0, 0.0, true, false, state])

func _ready() -> void:
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
	var index = catalog_state.source_liquid_catalog_state(catalog)
	var expected := {"water": 0, "slag": 1, "oil": 2, "cryofluid": 3, "neoplasm": 4, "arkycite": 5, "gallium": 6, "ozone": 7, "hydrogen": 8, "nitrogen": 9, "cyanogen": 10}
	var catalog_matches: bool = index["liquid_id_by_name"] == expected and index["content_liquid_ids"] == range(11)
	var world_drill: Sprite2D = null
	var world_blocks: Dictionary = game.get("placed_blocks")
	for sprite in world_blocks.values():
		if sprite.get_meta(placed.SOURCE_BLOCK_ID_META_KEY, "") == "mechanical-drill":
			world_drill = sprite
			break
	if world_drill == null:
		push_error("No real placed mechanical drill in campaign slice")
		get_tree().quit(1)
		return
	var owned = world_drill.get_meta(placed.SOURCE_BUILDING_LIQUIDS_META_KEY)
	var live_owned: bool = owned is Dictionary and owned["liquids"].size() == 11 and owned["current"] == 0 and owned["flow"] == null
	var water_id: int = index["liquid_id_by_name"]["water"]
	var actor := ProbeConsumer.new()
	actor.frame = owned
	actor.liquid_id = water_id
	storage.source_reset_state(owned, water_id, 1.25)
	tick(actor)
	var after1 = world_drill.get_meta(placed.SOURCE_BUILDING_LIQUIDS_META_KEY)["liquids"][water_id]
	tick(actor)
	var after2 = world_drill.get_meta(placed.SOURCE_BUILDING_LIQUIDS_META_KEY)["liquids"][water_id]
	tick(actor)
	var consumed: bool = after1 == 0.25 and after2 == 0.0 and actor.requests == [1.0, 0.25] and is_same(owned, world_drill.get_meta(placed.SOURCE_BUILDING_LIQUIDS_META_KEY))
	for flags in [[false, true], [true, false]]:
		storage.source_reset_state(owned, water_id, 0.25)
		actor.requests.clear()
		tick(actor, flags[0], flags[1])
		consumed = consumed and owned["liquids"][water_id] == 0.25 and actor.requests.is_empty()
	var second := Sprite2D.new()
	var second_owned = placed.source_initialize_building_liquids_state(second, true, catalog)["liquids"]
	var independent: bool = second_owned["liquids"] == [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0] and not is_same(owned, second_owned)
	var absent := Sprite2D.new()
	var false_guard: bool = placed.source_initialize_building_liquids_state(absent, false, catalog)["liquids"] == null
	false_guard = false_guard and is_same(placed.source_initialize_building_liquids_state(second, false, catalog)["liquids"], second_owned)
	second.free()
	absent.free()
	var registry_state := registry.canonical_headquarter_registry_state()
	var matches: bool = catalog_matches and live_owned and consumed and independent and false_guard and registry_state.get("errors", []).is_empty() and registry_state.get("one_headquarter_per_ssot", false)
	var proof := {"matches": matches, "catalog_matches": catalog_matches, "liquid_id_by_name": index["liquid_id_by_name"], "live_drill_owned": live_owned, "owned_consumption_matches": consumed, "water_after_ticks": [after1, after2], "independent_buildings": independent, "false_guard_matches": false_guard, "registry_valid": registry_state.get("errors", []).is_empty(), "one_headquarter_per_ssot": registry_state.get("one_headquarter_per_ssot", false)}
	proof_state.write_proof("PlacedLiquidOwnershipProof", proof)
	game.queue_free()
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
