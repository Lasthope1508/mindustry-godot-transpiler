extends Node

const main_scene := preload("res://scenes/Main.tscn")
const unit_runtime_state := preload("res://src/game/SourceUnitRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	var game := main_scene.instantiate()
	add_child(game)
	for iteration in range(4):
		await get_tree().process_frame
	game.call("enter_campaign_playable_slice")
	for iteration in range(4):
		await get_tree().process_frame
	game.set_process(false)
	game.set_physics_process(false)

	# --- Units.canCreate(team, type) (Units.java:115-117):
	# `return !type.useUnitCap || (team.data().countType(type) <
	# getCap(team) && !type.isBanned());` — driven directly on
	# the pure predicate. Deterministic: use_unit_cap,
	# count_type, unit_cap and is_banned are inputs; the mace
	# plan reads cap 10 unless noted.
	var under_cap: Dictionary = unit_runtime_state.source_units_can_create_state(true, 9, 10, false)
	proof["can_create_under_cap"] = bool(under_cap.get("can_create", false)) == true

	# --- at the cap (Units.java:116): count 10 is not < cap 10.
	var at_cap: Dictionary = unit_runtime_state.source_units_can_create_state(true, 10, 10, false)
	proof["can_create_at_cap"] = bool(at_cap.get("can_create", true)) == false

	# --- no cap type (UnitType.java:205, `useUnitCap = true,`
	# default — a type that opts out): count 99 over cap 10
	# still creates.
	var no_cap_type: Dictionary = unit_runtime_state.source_units_can_create_state(false, 99, 10, false)
	proof["can_create_no_cap_type"] = bool(no_cap_type.get("can_create", false)) == true

	# --- banned unit (Rules.java:311-313): count 0 under cap 10
	# still cannot create when banned.
	var banned_unit: Dictionary = unit_runtime_state.source_units_can_create_state(true, 0, 10, true)
	proof["can_create_banned_unit"] = bool(banned_unit.get("can_create", true)) == false

	# --- uncapped wave team (Units.java:119-121): getCap returns
	# Integer.MAX_VALUE, so count 100 is under the cap.
	var uncapped: Dictionary = unit_runtime_state.source_units_can_create_state(true, 100, 2147483647, false)
	proof["can_create_uncapped_wave_team"] = bool(uncapped.get("can_create", false)) == true

	# --- variable cap (Units.java:124): rules.unitCap 10 +
	# teamData.unitCap 5 = 15; count 14 is under it, and the
	# result records the evaluated cap.
	var variable_cap: Dictionary = unit_runtime_state.source_units_can_create_state(true, 14, 15, false)
	proof["can_create_variable_cap"] = bool(variable_cap.get("can_create", false)) == true and int(variable_cap.get("unit_cap", -1)) == 15

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07UnitsCanCreateProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
