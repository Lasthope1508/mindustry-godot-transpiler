extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_building_item_dump_state := preload("res://src/game/SourceBuildingItemDumpState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const generated_building_comp_script := preload("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd")
const source_drill_inventory_runtime_state := preload("res://src/game/SourceDrillInventoryRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _building_item_dump_state_method_names() -> Dictionary:
	return {
		source_building_item_dump_state.SOURCE_BUILDING_ITEM_DUMP_INCREMENT_DUMP_CURSOR_METHOD_KEY: "_proof_increment_dump_cursor",
	}

func _ready() -> void:
	var game := PortGameScript.new()
	var cursor_game := PortGameScript.new()
	var cursor_module_game := PortGameScript.new()
	var accum_game := PortGameScript.new()
	var accum_module_game := PortGameScript.new()
	var wrapper := game.source_dump_accumulate_attempt_state(0.25, 0.75)
	var module := source_building_item_dump_state.dump_accumulate_state(0.25, 0.75)
	var wrap_again := game.source_dump_accumulate_attempt_state(1.25, 0.25)
	var module_again := source_building_item_dump_state.dump_accumulate_state(1.25, 0.25)
	var put_wrapper := game.source_building_put_item_state("copper", 4, 1, [false, true, true, false], [false, false, true, true])
	var put_module := source_building_item_dump_state.game_put_item_state(game, "copper", 4, 1, [false, true, true, false], [false, false, true, true])
	var put_direct := source_building_item_dump_state.put_item_state("copper", 4, 1, [false, true, true, false], [false, false, true, true], source_building_item_dump_state.default_callbacks_state(game).get(source_building_item_dump_state.SOURCE_BUILDING_ITEM_DUMP_INCREMENT_DUMP_CURSOR_METHOD_KEY, Callable()))
	var null_scan_wrapper := game.source_building_dump_null_proximity_scan_state(4, 1)
	var null_scan_module := source_building_item_dump_state.game_dump_null_proximity_scan_state(game, 4, 1)
	var null_scan_direct := source_building_item_dump_state.dump_null_proximity_scan_state(4, 1, source_building_item_dump_state.default_callbacks_state(game).get(source_building_item_dump_state.SOURCE_BUILDING_ITEM_DUMP_INCREMENT_DUMP_CURSOR_METHOD_KEY, Callable()))
	cursor_game.drill_dump_cursor = 2
	cursor_module_game.drill_dump_cursor = 2
	var cursor_wrapper := game.source_increment_dump_cursor(2, 4)
	var cursor_module := source_building_item_dump_state.increment_dump_cursor_state(2, 4)
	var cursor_runtime_wrapper := cursor_game.increment_drill_dump(4)
	var cursor_runtime_module := source_building_item_dump_state.increment_dump_cursor_runtime_state(cursor_module_game, 4)
	accum_game.building_dump_accum = 0.75
	accum_module_game.building_dump_accum = 0.75
	var accum_runtime_wrapper := accum_game.step_building_dump_accum(1.5)
	var accum_runtime_module := source_building_item_dump_state.dump_accumulate_runtime_state(accum_module_game, 1.5)
	var generated_comp := generated_building_comp_script.new()
	var generated_put: Variant = generated_comp.java_method_put_103(["copper", 4, 1, [false, true, true, false], [false, false, true, true]])
	var generated_offload_route: Variant = generated_comp.java_method_offload_102(["copper", 1, [{"accepts_item": false, "can_dump": false}, {"accepts_item": true, "can_dump": true}]])
	var generated_offload_fallback: Variant = generated_comp.java_method_offload_102(["lead", 0, [{"accepts_item": false, "can_dump": false}]])
	var generated_produced_default: Variant = generated_comp.java_method_produced_104(["copper"])
	var generated_produced_amount: Variant = generated_comp.java_method_produced_105(["copper", 3, true, true, false])
	var generated_accumulate_default: Variant = generated_comp.java_method_dumpAccumulate_106([0.25, 2.1, [false, true]])
	var generated_accumulate_item: Variant = generated_comp.java_method_dumpAccumulate_107([0.75, 1.4, "lead", [false, true]])
	var generated_guard: Variant = generated_comp.java_method_dump_109([false, 1, 3, "copper", false, ["copper"], [1], [true, false, false], [false, false, false], 1])
	var generated_null_dump: Variant = generated_comp.java_method_dump_109([true, 2, 3, null, true, ["copper", "lead"], [1, 1], [false, false, true], [false, false, true], 1])
	var generated_specific_dump: Variant = generated_comp.java_method_dump_109([true, 2, 3, "lead", true, ["copper", "lead"], [1, 1], [false, true, false], [false, true, false], 1])
	var generated_increment: Variant = generated_comp.java_method_incrementDump_110([2, 4])
	var generated_can_dump: Variant = generated_comp.java_method_canDump_111(["container", "copper"])
	var callbacks := source_building_item_dump_state.default_callbacks_state(game)
	var default_callbacks_match: bool = callbacks.get(source_building_item_dump_state.SOURCE_BUILDING_ITEM_DUMP_INCREMENT_DUMP_CURSOR_METHOD_KEY, Callable()) == Callable(game, source_building_item_dump_state.SOURCE_BUILDING_ITEM_DUMP_INCREMENT_DUMP_CURSOR_METHOD_FALLBACK)
	var override_callbacks := source_building_item_dump_state.default_callbacks_state(self)
	var override_callbacks_match: bool = override_callbacks.get(source_building_item_dump_state.SOURCE_BUILDING_ITEM_DUMP_INCREMENT_DUMP_CURSOR_METHOD_KEY, Callable()) == Callable(self, "_proof_increment_dump_cursor")
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceBuildingItemDumpState",
		"matches": wrapper == module and wrap_again == module_again,
		"module_matches": wrapper == module and wrap_again == module_again,
		"game_put_matches": put_wrapper == put_module and put_module == put_direct,
		"game_null_scan_matches": null_scan_wrapper == null_scan_module and null_scan_module == null_scan_direct,
		"cursor_matches": cursor_wrapper == cursor_module,
		"cursor_runtime_matches": cursor_runtime_wrapper == cursor_runtime_module and cursor_game.drill_dump_cursor == cursor_module_game.drill_dump_cursor,
		"accum_runtime_matches": accum_runtime_wrapper == accum_runtime_module and accum_game.building_dump_accum == accum_module_game.building_dump_accum,
		"generated_accumulate_default_matches": bool(generated_accumulate_default.get("dumped", true)) and generated_accumulate_default.get("item", "not-null") == null and generated_accumulate_default.get("dump_results", []) == [false, true] and is_equal_approx(float(generated_accumulate_default.get("dump_accum", -1.0)), 0.35),
		"generated_accumulate_item_matches": bool(generated_accumulate_item.get("dumped", false)) and generated_accumulate_item.get("item", null) == "lead" and generated_accumulate_item.get("dump_results", []) == [false, true] and is_equal_approx(float(generated_accumulate_item.get("dump_accum", -1.0)), 0.15),
		"generated_produced_default_matches": generated_produced_default.get("item", null) == "copper" and generated_produced_default.get("amount", -1) == 1 and bool(generated_produced_default.get("delegates_to_amount_overload", false)),
		"generated_produced_amount_matches": generated_produced_amount.get("item", null) == "copper" and generated_produced_amount.get("amount", -1) == 3 and bool(generated_produced_amount.get("production_recorded", false)) and bool(generated_produced_amount.get("unlock_called", false)),
		"generated_put_matches": bool(generated_put.get("put", false)) and int(generated_put.get("handled_index", -1)) == 2 and int(generated_put.get("cdump", -1)) == 3,
		"generated_offload_route_matches": int(generated_offload_route.get("routed_count", 0)) == 1 and int(generated_offload_route.get("fallback_count", -1)) == 0 and generated_offload_route.get("source_owner", "") == "port_game.source_offload_to_inventory",
		"generated_offload_fallback_matches": int(generated_offload_fallback.get("fallback_count", 0)) == 1 and int(generated_offload_fallback.get("routed_count", -1)) == 0 and int(generated_offload_fallback.get("item_count", -1)) == 1,
		"generated_guard_matches": not bool(generated_guard.get("dumped", true)) and int(generated_guard.get("cdump", -1)) == 1,
		"generated_null_dump_matches": bool(generated_null_dump.get("dumped", false)) and generated_null_dump.get("handled_item", null) == "copper" and int(generated_null_dump.get("handled_index", -1)) == 2 and int(generated_null_dump.get("cdump", -1)) == 0,
		"generated_specific_dump_matches": bool(generated_specific_dump.get("dumped", false)) and generated_specific_dump.get("handled_item", null) == "lead" and int(generated_specific_dump.get("handled_index", -1)) == 1 and int(generated_specific_dump.get("cdump", -1)) == 2 and generated_specific_dump.get("item_amounts_by_index", []) == [1, 0],
		"generated_increment_matches": int(generated_increment.get("cdump", -1)) == 3,
		"generated_can_dump_matches": bool(generated_can_dump.get("can_dump_item", false)),
		"generated_owner_matches": generated_null_dump.get("source_owner", "") == "port_game.source_building_item_dump_state",
		"default_callbacks_match": default_callbacks_match,
		"override_callbacks_match": override_callbacks_match,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["matches"] = proof["module_matches"] and proof["game_put_matches"] and proof["game_null_scan_matches"] and proof["cursor_matches"] and proof["cursor_runtime_matches"] and proof["accum_runtime_matches"] and proof["default_callbacks_match"] and proof["override_callbacks_match"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	proof["matches"] = proof["matches"] and proof["generated_put_matches"] and proof["generated_offload_route_matches"] and proof["generated_offload_fallback_matches"] and proof["generated_produced_default_matches"] and proof["generated_produced_amount_matches"] and proof["generated_accumulate_default_matches"] and proof["generated_accumulate_item_matches"] and proof["generated_guard_matches"] and proof["generated_null_dump_matches"] and proof["generated_specific_dump_matches"] and proof["generated_increment_matches"] and proof["generated_can_dump_matches"] and proof["generated_owner_matches"]
	print("BUILDING_ITEM_DUMP_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BuildingItemDumpStateModuleProof", proof)
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

func _proof_increment_dump_cursor(current_dump: int, proximity_size: int) -> int:
	return source_building_item_dump_state.increment_dump_cursor_state(current_dump, proximity_size)

