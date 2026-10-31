extends Node

# Independent golden expectations from BuildingComp.java:1931-2003.
# This proof intentionally does not use production helpers to build expected values.
const generated_class := preload("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")

class ProbeConsumer extends RefCounted:
	var id: int
	var events: Array
	func _init(value: int, target: Array) -> void:
		id = value
		events = target
	func update(self_state: Dictionary) -> void:
		events.append([id, self_state["efficiency"], self_state["optional_efficiency"], self_state["potential_efficiency"], self_state["should_consume_power"]])

func _ready() -> void:
	var generated = generated_class.new()
	var cases := [
		# name, hasConsumers, cheating, enabled, productionValid, shouldConsume, scale, nonOptional, optional, expected [potential, efficiency, optional, power, count]
		["initial_scale_zero", false, false, true, true, true, 0.0, [], [], [1.0, 0.0, 0.0, true, 0]],
		["initial_scale_half", false, false, true, true, true, 0.5, [], [], [1.0, 0.5, 0.5, true, 0]],
		["initial_scale_one", false, false, true, true, true, 1.0, [], [], [1.0, 1.0, 1.0, true, 0]],
		["initial_scale_two", false, false, true, true, true, 2.0, [], [], [1.0, 2.0, 2.0, true, 0]],
		["cheating", true, true, true, true, true, 2.0, [], [], [1.0, 2.0, 2.0, true, 0]],
		["initial_no_consume", false, false, true, true, false, 2.0, [], [], [1.0, 0.0, 0.0, true, 0]],
		["initial_invalid", false, false, true, false, true, 2.0, [], [], [0.0, 0.0, 0.0, true, 0]],
		["initial_disabled", false, false, false, true, true, 2.0, [], [], [0.0, 0.0, 0.0, true, 0]],
		["disabled_consumers", true, false, false, true, true, 2.0, [], [], [0.0, 0.0, 0.0, false, 0]],
		["dictionary_composition", true, false, true, true, true, 2.0, [{"result": 0.5, "is_power": false}], [{"result": 0.75}, {"result": 0.25}], [0.5, 1.0, 0.5, true, 2]],
		["optional_clamp", true, false, true, true, true, 1.0, [{"result": 0.5, "is_power": false}], [{"result": 0.75}], [0.5, 0.5, 0.5, true, 2]],
		["should_consume_false", true, false, true, true, false, 2.0, [{"result": 0.5}], [{"result": 0.25}], [0.5, 0.0, 0.0, true, 0]],
		["production_invalid", true, false, true, false, true, 2.0, [{"result": 0.5}], [{"result": 0.25}], [0.5, 0.0, 0.0, true, 0]],
		["scale_zero_no_dispatch", true, false, true, true, true, 0.0, [{"result": 0.5}], [{"result": 0.25}], [0.5, 0.0, 0.0, true, 0]],
		["empty_consumer_results", true, false, true, true, true, 1.0, [], [], [1.0, 1.0, 1.0, true, 2]],
		["power_starved", true, false, true, true, true, 1.0, [{"result": 0.0, "is_power": true}], [], [0.0, 0.0, 0.0, true, 0]],
		["non_power_starved", true, false, true, true, true, 1.0, [{"result": 0.0, "is_power": false}], [], [0.0, 0.0, 0.0, false, 0]],
		["power_threshold", true, false, true, true, true, 1.0, [{"result": 0.0000001, "is_power": false}], [], [0.0000001, 0.0000001, 0.0000001, false, 2]],
		["above_power_threshold", true, false, true, true, true, 1.0, [{"result": 0.0000002, "is_power": false}], [], [0.0000002, 0.0000002, 0.0000002, true, 2]],
		["canonical_result_precedence", true, false, true, true, true, 1.0, [{"result": 0.5, "efficiency": 0.0}], [{"result": 0.25, "efficiency": 1.0}], [0.5, 0.5, 0.25, true, 2]],
		["legacy_numeric_and_efficiency_alias", true, false, true, true, true, 1.0, [{"efficiency": 0.5}], [0.75], [0.5, 0.5, 0.5, true, 2]],
	]
	var checks := []
	for entry in cases:
		var events := []
		var consumers := [ProbeConsumer.new(1, events), ProbeConsumer.new(2, events)]
		var self_state := {"has_consumers": entry[1], "cheating": entry[2], "enabled_state": entry[3], "production_valid": entry[4], "should_consume_state": entry[5], "efficiency_scale": entry[6], "non_optional_consumer_results": entry[7], "optional_consumer_results": entry[8], "update_consumers": consumers}
		var result = generated.java_method_updateConsumption_194([entry[1], entry[2], entry[3], entry[4], entry[5], entry[6], entry[7], entry[8], true, consumers, self_state])
		var expected: Array = entry[9]
		var state_matches := result is Dictionary
		for index in range(4):
			var key: String = ["potential_efficiency", "efficiency", "optional_efficiency", "should_consume_power"][index]
			state_matches = state_matches and result.has(key) and result.get(key) == expected[index]
		state_matches = state_matches and result.get("update_count", -1) == expected[4]
		var traces_match: bool = result is Dictionary and result.get("updated_consumers", []).size() == expected[4]
		if traces_match and expected[4] > 0:
			for index in range(consumers.size()):
				traces_match = traces_match and result["updated_consumers"][index]["consumer"] == consumers[index] and is_same(result["updated_consumers"][index]["self"], self_state)
		# Legacy update() with a complete frame must apply fields before actual consumer dispatch.
		generated.java_method_update_217([1.0, 0.0, 0.0, false, null, null, false, 0.0, 0.0, entry[3], false, self_state])
		var applied_matches := true
		for index in range(4):
			applied_matches = applied_matches and self_state.get(["potential_efficiency", "efficiency", "optional_efficiency", "should_consume_power"][index]) == expected[index]
		var expected_events := []
		if expected[4] > 0:
			expected_events = [[1, expected[1], expected[2], expected[0], expected[3]], [2, expected[1], expected[2], expected[0], expected[3]]]
		checks.append({"case": entry[0], "state_matches": state_matches, "traces_match": traces_match, "applied_matches": applied_matches, "dispatch_matches": events == expected_events})
	var boundary = generated.java_method_updateConsumption_194([true, false, true, true, true, 1.0, [{"result": 0.5}], [{"result": 0.75}], true])
	var registry_state := registry.canonical_headquarter_registry_state()
	var matches: bool = boundary is Dictionary and boundary.get("potential_efficiency") == 0.5 and boundary.get("optional_efficiency") == 0.5
	for check in checks:
		matches = matches and check.state_matches and check.traces_match and check.applied_matches and check.dispatch_matches
	matches = matches and bool(registry_state.get("one_headquarter_per_ssot", false)) and registry_state.get("errors", []).is_empty()
	var proof := {"matches": matches, "checks": checks, "case_count": cases.size(), "registry_valid": registry_state.get("errors", []).is_empty(), "one_headquarter_per_ssot": registry_state.get("one_headquarter_per_ssot", false)}
	runtime_proof_state.write_proof("BuildingConsumptionCanonicalProof", proof)
	# Native MCP runs stay alive for debug-output inspection; the harness stops them explicitly.
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(runtime_proof_state.exit_code(proof))
