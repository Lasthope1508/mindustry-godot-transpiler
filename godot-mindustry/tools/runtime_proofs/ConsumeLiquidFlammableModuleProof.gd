extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_consume_liquid_flammable_state := preload("res://src/game/SourceConsumeLiquidFlammableState.gd")
const source_consumer_defaults := preload("res://src/game/SourceConsumerDefaults.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var filtered_liquid_ids := [1, 2]
	var liquid_efficiency_values := [0.25, 1.5]
	var wrapper := game.generated_consume_liquid_flammable_display_bridge_state(true, 0.75, filtered_liquid_ids, liquid_efficiency_values, true)
	var module_bridge := source_consume_liquid_flammable_state.generated_display_bridge_state(true, 0.75, filtered_liquid_ids, liquid_efficiency_values, true, source_time_defaults.TICK_RATE)
	var canonical := source_consume_liquid_flammable_state.display_state(true, 0.75, filtered_liquid_ids, liquid_efficiency_values, true, source_time_defaults.TICK_RATE)
	var display_rows: Array = canonical.get("display_rows", [])
	var expected_first_percent: float = float(liquid_efficiency_values[0]) * source_consumer_defaults.CONSUME_LIQUID_FLAMMABLE_EFFICIENCY_PERCENT_SCALE
	var first_percent: Variant = display_rows[0].get("efficiency_percent", null) if not display_rows.is_empty() else null
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceConsumeLiquidFlammableState",
		"display_bridge_matches": wrapper == module_bridge and bool(wrapper.get("matches", false)),
		"percent_scale_matches": first_percent == expected_first_percent,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["display_bridge_matches"] and proof["percent_scale_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("CONSUME_LIQUID_FLAMMABLE_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/ConsumeLiquidFlammableModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
		proof_file.close()
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
