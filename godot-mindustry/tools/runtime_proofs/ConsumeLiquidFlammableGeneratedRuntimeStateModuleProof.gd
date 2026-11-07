extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_consume_liquid_flammable_generated_state := preload("res://src/game/SourceConsumeLiquidFlammableGeneratedState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const source_consumer_defaults := preload("res://src/game/SourceConsumerDefaults.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var filtered_liquid_ids := [1, 2]
	var liquid_efficiency_values := [0.25, 1.5]
	var min_flammability := 0.35
	var amount := 0.75
	var liquid_flammability := 0.8

	var display_wrapper := game.generated_consume_liquid_flammable_display_bridge_state(true, amount, filtered_liquid_ids, liquid_efficiency_values, true)
	var display_module := source_consume_liquid_flammable_generated_state.generated_display_bridge_state(true, amount, filtered_liquid_ids, liquid_efficiency_values, true, source_time_defaults.TICK_RATE)
	var multiplier_wrapper := game.generated_consume_liquid_flammable_liquid_efficiency_multiplier_bridge_state(liquid_flammability)
	var multiplier_module := source_consume_liquid_flammable_generated_state.generated_liquid_efficiency_multiplier_bridge_state(liquid_flammability)
	var constructor_wrapper := game.generated_consume_liquid_flammable_constructor_bridge_state(min_flammability, amount)
	var constructor_module := source_consume_liquid_flammable_generated_state.generated_constructor_bridge_state(min_flammability, amount)
	var amount_constructor_wrapper := game.generated_consume_liquid_flammable_amount_constructor_bridge_state(amount)
	var amount_constructor_module := source_consume_liquid_flammable_generated_state.generated_amount_constructor_bridge_state(amount, source_consumer_defaults.CONSUME_LIQUID_FLAMMABLE_MIN_FLAMMABILITY_DEFAULT)
	var default_constructor_wrapper := game.generated_consume_liquid_flammable_default_constructor_bridge_state()
	var default_constructor_module := source_consume_liquid_flammable_generated_state.generated_default_constructor_bridge_state(source_consumer_defaults.CONSUME_LIQUID_FLAMMABLE_AMOUNT_DEFAULT, source_consumer_defaults.CONSUME_LIQUID_FLAMMABLE_MIN_FLAMMABILITY_DEFAULT)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceConsumeLiquidFlammableGeneratedState",
		"display_bridge_matches": display_wrapper == display_module and bool(display_module.get("matches", false)),
		"liquid_efficiency_multiplier_bridge_matches": multiplier_wrapper == multiplier_module and bool(multiplier_module.get("matches", false)),
		"constructor_bridge_matches": constructor_wrapper == constructor_module and bool(constructor_module.get("matches", false)),
		"amount_constructor_bridge_matches": amount_constructor_wrapper == amount_constructor_module and bool(amount_constructor_module.get("matches", false)),
		"default_constructor_bridge_matches": default_constructor_wrapper == default_constructor_module and bool(default_constructor_module.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["display_bridge_matches"] and proof["liquid_efficiency_multiplier_bridge_matches"] and proof["constructor_bridge_matches"] and proof["amount_constructor_bridge_matches"] and proof["default_constructor_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("CONSUME_LIQUID_FLAMMABLE_GENERATED_RUNTIME_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("ConsumeLiquidFlammableGeneratedRuntimeStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

