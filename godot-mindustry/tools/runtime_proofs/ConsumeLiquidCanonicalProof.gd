extends Node

# Golden values transcribed from ConsumeLiquid.java:41-52 and BuildingComp.java:1943-2003.
# The expected results never call the canonical helper or reuse generated output.
const generated_liquid := preload("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquid.gd")
const generated_building := preload("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd")
const building_time := preload("res://src/game/SourceBuildingTimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")

class LiquidConsumer extends RefCounted:

	var generated = generated_liquid.new()
	var removal_amounts: Array = []

	func update(self_state: Dictionary) -> void:
		var edelta := building_time.edelta(2.0, 1.0, self_state["efficiency"])
		var result = generated.java_method_update_2([7, 0.5, edelta, 1.0])
		removal_amounts.append(result["remove_amount"])

func _ready() -> void:
	var generated = generated_liquid.new()
	# available, amount, edelta, scale, multiplier, expected efficiency
	var efficiency_cases := [
		[0.0, 0.5, 2.0, 1.0, 1.0, 0.0],
		[0.25, 0.5, 2.0, 1.0, 1.0, 0.25],
		[1.0, 0.5, 2.0, 1.0, 1.0, 1.0],
		[10.0, 0.5, 2.0, 1.0, 1.0, 1.0],
		[1.0, 0.5, 0.0, 1.0, 1.0, 0.0],
		[1.0, 0.5, -1.0, 1.0, 1.0, 0.0],
		[1.0, 0.5, 1.0, 0.0, 1.0, 0.0],
		[1.0, 0.5, 0.00000001, 1.0, 1.0, 0.0],
		[0.00000001, 0.5, 0.00000002, 1.0, 1.0, 1.0],
		[0.25, 0.5, 2.0, 2.0, 0.5, 0.25],
		[0.5, 0.5, 2.0, 1.0, 2.0, 0.25],
	]
	var checks := []
	for entry in efficiency_cases:
		var result = generated.java_method_efficiency_3(entry.slice(0, 5))
		checks.append({"kind": "efficiency", "input": entry.slice(0, 5), "expected": entry[5], "actual": result["efficiency"], "matches": result["efficiency"] == entry[5]})
	# liquid_id, amount, edelta, multiplier, expected removal amount
	var update_cases := [
		[7, 0.5, 2.0, 1.0, 1.0],
		[7, 0.5, 0.5, 1.0, 0.25],
		[7, 0.5, 2.0, 2.0, 2.0],
		[9, 0.0, 2.0, 1.0, 0.0],
		[7, 0.5, 0.0, 1.0, 0.0],
		[7, 0.5, 2.0, 0.0, 0.0],
	]
	for entry in update_cases:
		var result = generated.java_method_update_2(entry.slice(0, 4))
		checks.append({"kind": "update", "input": entry.slice(0, 4), "expected": entry[4], "actual": result["remove_amount"], "matches": result["remove_amount"] == entry[4] and result["liquid_id"] == entry[0]})
	# Exercise evaluated liquid availability -> complete BuildingComp state -> consumer update.
	# This checks the resource-removal amount contract; LiquidModule storage mutation remains deferred.
	var available = generated.java_method_efficiency_3([0.25, 0.5, 2.0, 1.0, 1.0])
	var actor := LiquidConsumer.new()
	var self_state := {"has_consumers": true, "cheating": false, "enabled_state": true, "production_valid": true, "should_consume_state": true, "efficiency_scale": 1.0, "non_optional_consumer_results": [{"result": available["efficiency"], "is_power": false}], "optional_consumer_results": [], "update_consumers": [actor]}
	generated_building.new().java_method_update_217([1.0, 0.0, 0.0, false, null, null, false, 0.0, 0.0, true, false, self_state])
	var composition_matches: bool = self_state.get("efficiency") == 0.25 and self_state.get("potential_efficiency") == 0.25 and self_state.get("optional_efficiency") == 0.25 and self_state.get("should_consume_power") == true and actor.removal_amounts == [0.25]
	var registry_state := registry.canonical_headquarter_registry_state()
	var matches: bool = composition_matches and registry_state.get("errors", []).is_empty() and registry_state.get("one_headquarter_per_ssot", false)
	for check in checks:
		matches = matches and check["matches"]
	var proof := {"matches": matches, "case_count": checks.size(), "checks": checks, "building_composition_matches": composition_matches, "registry_valid": registry_state.get("errors", []).is_empty(), "one_headquarter_per_ssot": registry_state.get("one_headquarter_per_ssot", false)}
	proof_state.write_proof("ConsumeLiquidCanonicalProof", proof)
	# MCP runs remain alive for debug-output inspection and are stopped by the caller.
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
