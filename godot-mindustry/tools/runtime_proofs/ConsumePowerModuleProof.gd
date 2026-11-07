extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const source_consume_power_state := preload("res://src/game/SourceConsumePowerState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var buffered := false
	var usage := 4.0
	var capacity := 20.0
	var power_status := 0.25
	var should_consume := true
	var block_has_power_before := false
	var block_cons_power_before: Variant = null
	var consume_power_state := game.source_consume_power_requested_power_state(buffered, usage, capacity, power_status, should_consume)
	var requested_bridge := game.generated_consume_power_requested_power_bridge_state(buffered, usage, capacity, power_status, should_consume)
	var apply_bridge := game.generated_consume_power_apply_bridge_state(block_has_power_before, block_cons_power_before, consume_power_state)
	var ignore_bridge := game.generated_consume_power_ignore_bridge_state(true)
	var efficiency_bridge := game.generated_consume_power_efficiency_bridge_state(power_status)
	var display_bridge := game.generated_consume_power_display_bridge_state(buffered, usage, capacity)
	var condition_bridge := game.generated_consume_power_condition_requested_power_bridge_state(9.0, true)
	var dynamic_requested_bridge := game.generated_consume_power_dynamic_requested_power_bridge_state(13.0)
	var dynamic_display_bridge := game.generated_consume_power_dynamic_display_bridge_state(11.0)
	var proof := {
		"module": "SourceConsumePowerState",
		"requested_bridge_matches": requested_bridge == source_consume_power_state.generated_requested_power_bridge_state(buffered, usage, capacity, power_status, should_consume),
		"apply_bridge_matches": apply_bridge == source_consume_power_state.generated_apply_bridge_state(block_has_power_before, block_cons_power_before, consume_power_state),
		"ignore_bridge_matches": ignore_bridge == source_consume_power_state.generated_ignore_bridge_state(true),
		"efficiency_bridge_matches": efficiency_bridge == source_consume_power_state.generated_efficiency_bridge_state(power_status),
		"display_bridge_matches": display_bridge == source_consume_power_state.generated_display_bridge_state(buffered, usage, capacity, source_time_defaults.TICK_RATE),
		"condition_bridge_matches": condition_bridge == source_consume_power_state.generated_condition_requested_power_bridge_state(9.0, true),
		"dynamic_requested_bridge_matches": dynamic_requested_bridge == source_consume_power_state.generated_dynamic_requested_power_bridge_state(13.0),
		"dynamic_display_bridge_matches": dynamic_display_bridge == source_consume_power_state.generated_dynamic_display_bridge_state(11.0, source_time_defaults.TICK_RATE),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["requested_bridge_matches"] and proof["apply_bridge_matches"] and proof["ignore_bridge_matches"] and proof["efficiency_bridge_matches"] and proof["display_bridge_matches"] and proof["condition_bridge_matches"] and proof["dynamic_requested_bridge_matches"] and proof["dynamic_display_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	runtime_proof_state.write_proof("ConsumePowerModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

