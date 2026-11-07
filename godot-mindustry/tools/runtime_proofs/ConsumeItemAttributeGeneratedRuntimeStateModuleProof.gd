extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_consume_item_attribute_generated_state := preload("res://src/game/SourceConsumeItemAttributeGeneratedState.gd")
const source_consumer_defaults := preload("res://src/game/SourceConsumerDefaults.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var flammability := 0.7
	var explosiveness := 0.8
	var radioactivity := 0.9
	var charge := 0.6
	var flammable_min := 0.25
	var explosive_min := 0.35
	var radioactive_min := 0.45
	var charged_min := 0.55

	var flammable_multiplier_wrapper := game.generated_consume_item_flammable_item_efficiency_multiplier_bridge_state(flammability)
	var flammable_multiplier_module := source_consume_item_attribute_generated_state.generated_flammable_item_efficiency_multiplier_bridge_state(flammability)
	var flammable_constructor_wrapper := game.generated_consume_item_flammable_constructor_bridge_state(flammable_min)
	var flammable_constructor_module := source_consume_item_attribute_generated_state.generated_flammable_constructor_bridge_state(flammable_min)
	var flammable_default_wrapper := game.generated_consume_item_flammable_default_constructor_bridge_state()
	var flammable_default_module := source_consume_item_attribute_generated_state.generated_flammable_default_constructor_bridge_state(source_consumer_defaults.CONSUME_ITEM_FLAMMABLE_MIN_FLAMMABILITY_DEFAULT)

	var explosive_multiplier_wrapper := game.generated_consume_item_explosive_item_efficiency_multiplier_bridge_state(explosiveness)
	var explosive_multiplier_module := source_consume_item_attribute_generated_state.generated_explosive_item_efficiency_multiplier_bridge_state(explosiveness)
	var explosive_constructor_wrapper := game.generated_consume_item_explosive_constructor_bridge_state(explosive_min)
	var explosive_constructor_module := source_consume_item_attribute_generated_state.generated_explosive_constructor_bridge_state(explosive_min)
	var explosive_default_wrapper := game.generated_consume_item_explosive_default_constructor_bridge_state()
	var explosive_default_module := source_consume_item_attribute_generated_state.generated_explosive_default_constructor_bridge_state(source_consumer_defaults.CONSUME_ITEM_EXPLOSIVE_MIN_CHARGE_DEFAULT)

	var radioactive_multiplier_wrapper := game.generated_consume_item_radioactive_item_efficiency_multiplier_bridge_state(radioactivity)
	var radioactive_multiplier_module := source_consume_item_attribute_generated_state.generated_radioactive_item_efficiency_multiplier_bridge_state(radioactivity)
	var radioactive_constructor_wrapper := game.generated_consume_item_radioactive_constructor_bridge_state(radioactive_min)
	var radioactive_constructor_module := source_consume_item_attribute_generated_state.generated_radioactive_constructor_bridge_state(radioactive_min)
	var radioactive_default_wrapper := game.generated_consume_item_radioactive_default_constructor_bridge_state()
	var radioactive_default_module := source_consume_item_attribute_generated_state.generated_radioactive_default_constructor_bridge_state(source_consumer_defaults.CONSUME_ITEM_RADIOACTIVE_MIN_RADIOACTIVITY_DEFAULT)

	var charged_multiplier_wrapper := game.generated_consume_item_charged_item_efficiency_multiplier_bridge_state(charge)
	var charged_multiplier_module := source_consume_item_attribute_generated_state.generated_charged_item_efficiency_multiplier_bridge_state(charge)
	var charged_constructor_wrapper := game.generated_consume_item_charged_constructor_bridge_state(charged_min)
	var charged_constructor_module := source_consume_item_attribute_generated_state.generated_charged_constructor_bridge_state(charged_min)
	var charged_default_wrapper := game.generated_consume_item_charged_default_constructor_bridge_state()
	var charged_default_module := source_consume_item_attribute_generated_state.generated_charged_default_constructor_bridge_state(source_consumer_defaults.CONSUME_ITEM_CHARGED_MIN_CHARGE_DEFAULT)

	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceConsumeItemAttributeGeneratedState",
		"flammable_multiplier_bridge_matches": flammable_multiplier_wrapper == flammable_multiplier_module and bool(flammable_multiplier_module.get("matches", false)),
		"flammable_constructor_bridge_matches": flammable_constructor_wrapper == flammable_constructor_module and bool(flammable_constructor_module.get("matches", false)),
		"flammable_default_constructor_bridge_matches": flammable_default_wrapper == flammable_default_module and bool(flammable_default_module.get("matches", false)),
		"explosive_multiplier_bridge_matches": explosive_multiplier_wrapper == explosive_multiplier_module and bool(explosive_multiplier_module.get("matches", false)),
		"explosive_constructor_bridge_matches": explosive_constructor_wrapper == explosive_constructor_module and bool(explosive_constructor_module.get("matches", false)),
		"explosive_default_constructor_bridge_matches": explosive_default_wrapper == explosive_default_module and bool(explosive_default_module.get("matches", false)),
		"radioactive_multiplier_bridge_matches": radioactive_multiplier_wrapper == radioactive_multiplier_module and bool(radioactive_multiplier_module.get("matches", false)),
		"radioactive_constructor_bridge_matches": radioactive_constructor_wrapper == radioactive_constructor_module and bool(radioactive_constructor_module.get("matches", false)),
		"radioactive_default_constructor_bridge_matches": radioactive_default_wrapper == radioactive_default_module and bool(radioactive_default_module.get("matches", false)),
		"charged_multiplier_bridge_matches": charged_multiplier_wrapper == charged_multiplier_module and bool(charged_multiplier_module.get("matches", false)),
		"charged_constructor_bridge_matches": charged_constructor_wrapper == charged_constructor_module and bool(charged_constructor_module.get("matches", false)),
		"charged_default_constructor_bridge_matches": charged_default_wrapper == charged_default_module and bool(charged_default_module.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["flammable_multiplier_bridge_matches"] and proof["flammable_constructor_bridge_matches"] and proof["flammable_default_constructor_bridge_matches"] and proof["explosive_multiplier_bridge_matches"] and proof["explosive_constructor_bridge_matches"] and proof["explosive_default_constructor_bridge_matches"] and proof["radioactive_multiplier_bridge_matches"] and proof["radioactive_constructor_bridge_matches"] and proof["radioactive_default_constructor_bridge_matches"] and proof["charged_multiplier_bridge_matches"] and proof["charged_constructor_bridge_matches"] and proof["charged_default_constructor_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("CONSUME_ITEM_ATTRIBUTE_GENERATED_RUNTIME_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("ConsumeItemAttributeGeneratedRuntimeStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

