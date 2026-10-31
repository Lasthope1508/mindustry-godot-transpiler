extends SceneTree

# Audit only: independent expectations transcribed from BuildingComp.java:1931-2003.
# Run from the repository with Godot --headless --path godot-mindustry --script <absolute path>.
# Expected script errors below are findings; process exit 0 only means this probe finished.
func _initialize() -> void:
	call_deferred("run_audit")

func record(name: String, actual: Variant, expected: Variant) -> void:
	print("CONSUMPTION_AUDIT " + JSON.stringify({"case": name, "actual": actual, "expected": expected, "matches": actual == expected}))

func run_audit() -> void:
	var canonical = load("res://src/game/SourceBuildingEfficiencyState.gd")
	var generated = load("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd").new()
	for scale in [0.0, 0.5, 1.0, 2.0]:
		var expected := {"potential_efficiency": 1.0, "efficiency": scale, "optional_efficiency": scale, "should_consume_power": true, "returned": true}
		record("initial_scale_" + str(scale), generated.java_method_updateConsumption_194([false, false, true, true, true, scale]), expected)
	record("cheating_scale_2", generated.java_method_updateConsumption_194([true, true, true, true, true, 2.0]), {"potential_efficiency": 1.0, "efficiency": 2.0, "optional_efficiency": 2.0, "should_consume_power": true, "returned": true})
	var rows := [{"result": 0.75}, {"result": 0.5}]
	var non_optional := [{"result": 0.5, "is_power": false}]
	var optional_stage = generated.java_method_updateConsumption_194([true, false, true, true, true, 1.0, non_optional, rows])
	record("dictionary_optional_8_args", optional_stage, {"optional_consumer_results": rows, "optional_efficiency": 0.5})
	print("CONSUMPTION_AUDIT BEGIN dictionary_optional_9_args")
	var efficiency_stage = generated.java_method_updateConsumption_194([true, false, true, true, true, 1.0, non_optional, rows, true])
	record("dictionary_optional_9_args", efficiency_stage, {"min_efficiency": 0.5, "optional_efficiency": 0.5, "update": true, "efficiency": 0.5, "potential_efficiency": 0.5})
	print("CONSUMPTION_AUDIT BEGIN dictionary_optional_11_args")
	var full = generated.java_method_updateConsumption_194([true, false, true, true, true, 1.0, non_optional, rows, true, [{"id": "consumer"}], {"id": "self"}])
	record("dictionary_optional_11_args_returns_dictionary", full is Dictionary, true)
	var alias_rows := [{"efficiency": 0.5, "is_power": false}]
	var isolated = canonical.update_consumption_non_optional_pass_state(alias_rows)
	var composed = generated.java_method_updateConsumption_194([true, false, true, true, true, 1.0, alias_rows, [0.75], true])
	record("non_optional_efficiency_alias_consistency", composed.get("min_efficiency"), isolated.get("min_efficiency"))
	var final_result = generated.java_method_updateConsumption_194([true, false, true, true, false, 2.0, non_optional, [0.75], true, [{"id": "consumer"}], {}])
	print("CONSUMPTION_AUDIT " + JSON.stringify({"case": "numeric_full_no_update_state_surface", "actual": final_result, "missing_upstream_state_fields": ["potential_efficiency", "optional_efficiency", "should_consume_power"], "classification": "stage-output limitation; no proof of live gameplay mutation"}))
	print("CONSUMPTION_AUDIT COMPLETE")
	quit(0)
