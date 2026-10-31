extends Node

const generated_storage := preload("res://src/generated/classes/mindustry/world/modules/LiquidModule.gd")
const generated_liquid := preload("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquid.gd")
const generated_building := preload("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd")
const building_time := preload("res://src/game/SourceBuildingTimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")

class StorageConsumer extends RefCounted:

	var storage: Dictionary
	var cache_sums: Array
	var requests: Array = []
	var module = generated_storage.new()
	var consumer = generated_liquid.new()

	func update(self_state: Dictionary) -> void:
		var edelta := building_time.edelta(2.0, 1.0, self_state["efficiency"])
		var request = consumer.java_method_update_2([1, 0.5, edelta, 1.0])
		requests.append(request["remove_amount"])
		module.java_method_remove_12([storage, 1, request["remove_amount"], cache_sums])

func consumption_frame(actor: StorageConsumer, enabled: bool, should_consume: bool) -> Dictionary:
	var amount = actor.module.java_method_get_8([actor.storage, 1])["amount"]
	var available = actor.consumer.java_method_efficiency_3([amount, 0.5, 2.0, 1.0, 1.0])["efficiency"]
	return {"has_consumers": true, "cheating": false, "enabled_state": enabled, "production_valid": true, "should_consume_state": should_consume, "efficiency_scale": 1.0, "non_optional_consumer_results": [{"result": available, "is_power": false}], "optional_consumer_results": [], "update_consumers": [actor]}

func tick(actor: StorageConsumer, enabled: bool = true, should_consume: bool = true) -> Dictionary:
	var frame := consumption_frame(actor, enabled, should_consume)
	generated_building.new().java_method_update_217([1.0, 0.0, 0.0, false, null, null, false, 0.0, 0.0, true, false, frame])
	return frame

func _ready() -> void:
	var module = generated_storage.new()
	# Independent golden storage values from LiquidModule.java:102-128.
	# method, before, id, amount, flow enabled, cache before, after, current after, cache after
	var cases := [
		["add", [2.0, 3.0], 0, 1.5, false, [], [3.5, 3.0], 0, []],
		["add", [2.0, 3.0], 0, -3.0, false, [], [-1.0, 3.0], 0, []],
		["add", [2.0, 3.0], 0, 0.0, false, [], [2.0, 3.0], 0, []],
		["add", [2.0, 3.0], 0, 1.5, true, [0.5, 4.0], [3.5, 3.0], 0, [2.0, 4.0]],
		["add", [2.0, 3.0], 0, -1.0, true, [0.5, 4.0], [1.0, 3.0], 0, [0.5, 4.0]],
		["remove", [2.0, 3.0], 0, 0.5, false, [], [1.5, 3.0], 0, []],
		["remove", [2.0, 3.0], 0, 2.0, false, [], [0.0, 3.0], 0, []],
		["remove", [2.0, 3.0], 0, 8.0, false, [], [0.0, 3.0], 0, []],
		["remove", [2.0, 3.0], 0, 0.0, false, [], [2.0, 3.0], 0, []],
		["remove", [0.0, 3.0], 0, 8.0, true, [0.5, 4.0], [0.0, 3.0], 0, [0.5, 4.0]],
		["remove", [2.0, 3.0], 0, -1.5, true, [0.5, 4.0], [3.5, 3.0], 0, [2.0, 4.0]],
		["remove", [2.0, 3.0], 1, 1.0, true, [0.5, 4.0], [2.0, 2.0], 1, [0.5, 4.0]],
	]
	var checks: Array = []
	for entry in cases:
		var state := {"liquids": entry[1].duplicate(), "current": 1, "flow": null}
		if entry[4]:
			state["flow"] = []
		var sums: Array = entry[5].duplicate()
		var result = module.call("java_method_" + entry[0] + ("_10" if entry[0] == "add" else "_12"), [state, entry[2], entry[3], sums])
		checks.append({"kind": entry[0], "input": entry.slice(1, 6), "actual": state.duplicate(true), "cache_sums": sums.duplicate(), "matches": state["liquids"] == entry[6] and state["current"] == entry[7] and sums == entry[8] and result == state})
	for id in [0, 1]:
		var state := {"liquids": [2.0, 3.0], "current": 1, "flow": null}
		var result = module.java_method_get_8([state, id])
		checks.append({"kind": "get", "id": id, "actual": result, "matches": result["amount"] == [2.0, 3.0][id] and state == {"liquids": [2.0, 3.0], "current": 1, "flow": null}})
	# Static Java cacheSums is represented by one explicit shared Array, not per-instance defaults.
	var shared: Array = [0.0, 0.0]
	var first := {"liquids": [0.0, 0.0], "current": 0, "flow": []}
	var second := {"liquids": [0.0, 0.0], "current": 0, "flow": []}
	module.java_method_add_10([first, 0, 0.5, shared])
	generated_storage.new().java_method_add_10([second, 1, 0.25, shared])
	checks.append({"kind": "shared_flow_cache", "matches": first["liquids"] == [0.5, 0.0] and second["liquids"] == [0.0, 0.25] and shared == [0.5, 0.25]})
	var actor := StorageConsumer.new()
	actor.storage = {"liquids": [4.0, 1.25], "current": 1, "flow": null}
	actor.cache_sums = []
	var frame1 := tick(actor)
	var after1: Array = actor.storage["liquids"].duplicate()
	var frame2 := tick(actor)
	var after2: Array = actor.storage["liquids"].duplicate()
	var frame3 := tick(actor)
	var composition: bool = frame1["efficiency"] == 1.0 and frame2["efficiency"] == 0.25 and frame3["efficiency"] == 0.0 and after1 == [4.0, 0.25] and after2 == [4.0, 0.0] and actor.storage["liquids"] == [4.0, 0.0] and actor.requests == [1.0, 0.25]
	for enabled_should in [[false, true], [true, false]]:
		actor.storage["liquids"][1] = 0.25
		actor.requests.clear()
		var frame := tick(actor, enabled_should[0], enabled_should[1])
		composition = composition and frame["efficiency"] == 0.0 and actor.storage["liquids"] == [4.0, 0.25] and actor.requests.is_empty()
	var registry_state := registry.canonical_headquarter_registry_state()
	var matches: bool = composition and registry_state.get("errors", []).is_empty() and registry_state.get("one_headquarter_per_ssot", false)
	for check in checks:
		matches = matches and check["matches"]
	var proof := {"matches": matches, "case_count": checks.size(), "checks": checks, "consumption_mutation_matches": composition, "tick_amounts": [after1, after2], "registry_valid": registry_state.get("errors", []).is_empty(), "one_headquarter_per_ssot": registry_state.get("one_headquarter_per_ssot", false)}
	proof_state.write_proof("LiquidModuleStorageProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
