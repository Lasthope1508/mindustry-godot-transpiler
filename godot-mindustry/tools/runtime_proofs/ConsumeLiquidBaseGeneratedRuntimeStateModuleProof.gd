extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_consume_liquid_base_generated_state := preload("res://src/game/SourceConsumeLiquidBaseGeneratedState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var amount := 1.25
	var block_has_liquids_before := false
	var liquid := {"id": "water"}

	var constructor_wrapper := game.generated_consume_liquid_base_constructor_bridge_state(amount)
	var constructor_module := source_consume_liquid_base_generated_state.generated_constructor_bridge_state(amount)
	var apply_wrapper := game.generated_consume_liquid_base_apply_bridge_state(block_has_liquids_before)
	var apply_module := source_consume_liquid_base_generated_state.generated_apply_bridge_state(block_has_liquids_before)
	var consumes_wrapper := game.generated_consume_liquid_base_abstract_consumes_bridge_state(liquid)
	var consumes_module := source_consume_liquid_base_generated_state.generated_abstract_consumes_bridge_state(liquid)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceConsumeLiquidBaseGeneratedState",
		"constructor_bridge_matches": constructor_wrapper == constructor_module and bool(constructor_module.get("matches", false)),
		"apply_bridge_matches": apply_wrapper == apply_module and bool(apply_module.get("matches", false)),
		"abstract_consumes_bridge_matches": consumes_wrapper == consumes_module and bool(consumes_module.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["constructor_bridge_matches"] and proof["apply_bridge_matches"] and proof["abstract_consumes_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("CONSUME_LIQUID_BASE_GENERATED_RUNTIME_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("ConsumeLiquidBaseGeneratedRuntimeStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

