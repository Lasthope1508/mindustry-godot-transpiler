extends Node

const main_scene := preload("res://scenes/Main.tscn")
const unit_cargo_loader_build_state := preload("res://src/game/SourceUnitCargoLoaderBuildState.gd")
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

	# --- Pure canPlaceOn (N2330): UnitCargoLoader overrides
	# canPlaceOn (UnitCargoLoader.java:65-68, `return
	# super.canPlaceOn(tile, team, rotation) &&
	# Units.canCreate(team, unitType);`) and the Block default
	# returns TRUE (Block.java:606-608, `return true;`), so
	# the UCL placement gate IS the N2322 canCreate verdict
	# (Units.canCreate, Units.java:115-117, over getCap,
	# Units.java:119-126). The pure
	# source_unit_cargo_loader_can_place_on_state composes
	# source_unit_cargo_loader_can_create_state (N2322, via
	# the shared N2140 bridge) and returns {can_place_on} --
	# no duplicated cap math. Java receives tile / team /
	# rotation, but super ignores them (constant true) and
	# canCreate needs only team + unitType, which arrive
	# through the frame can_create_inputs dict, so the pure
	# takes the frame only and needs no tile geometry.
	# canPlaceOn is a placement gate, NOT tick wiring: the
	# driver never calls it each tick, so this proof has no
	# live-tick key -- the live placement call site waits for
	# its own slice. No input stamped (absent, non-dict, or
	# empty) means permissive: can_place_on true (the N2322
	# default, inherited).
	var below: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_can_place_on_state({"can_create_inputs": {"count_type": 3, "unit_cap": 5, "unit_cap_variable": false}})
	var below_zero: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_can_place_on_state({"can_create_inputs": {"count_type": 0, "unit_cap": 1, "unit_cap_variable": false}})
	proof["can_place_on_when_can_create"] = bool(below.get("can_place_on", false)) and bool(below_zero.get("can_place_on", false))

	var at_cap: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_can_place_on_state({"can_create_inputs": {"count_type": 5, "unit_cap": 5, "unit_cap_variable": false}})
	var over_cap: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_can_place_on_state({"can_create_inputs": {"count_type": 9, "unit_cap": 5, "unit_cap_variable": false}})
	proof["cannot_place_on_when_capped"] = bool(at_cap.get("can_place_on", true)) == false and bool(over_cap.get("can_place_on", true)) == false

	var no_inputs: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_can_place_on_state({})
	var empty_inputs: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_can_place_on_state({"can_create_inputs": {}})
	var non_dict_inputs: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_can_place_on_state({"can_create_inputs": 7})
	proof["permissive_default_without_inputs"] = bool(no_inputs.get("can_place_on", false)) and bool(empty_inputs.get("can_place_on", false)) and bool(non_dict_inputs.get("can_place_on", false))

	var banned: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_can_place_on_state({"can_create_inputs": {"count_type": 0, "unit_cap": 5, "unit_cap_variable": false, "is_banned": true}})
	var not_banned: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_can_place_on_state({"can_create_inputs": {"count_type": 0, "unit_cap": 5, "unit_cap_variable": false, "is_banned": false}})
	proof["banned_type_cannot_place"] = bool(banned.get("can_place_on", true)) == false and bool(not_banned.get("can_place_on", false))

	# The !useUnitCap short-circuit (Units.java:116): a type
	# that ignores the unit cap places even past the cap and
	# even banned -- the first disjunct decides.
	var no_cap: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_can_place_on_state({"can_create_inputs": {"use_unit_cap": false, "count_type": 9999, "unit_cap": 0, "is_banned": true}})
	var no_cap_capped: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_can_place_on_state({"can_create_inputs": {"use_unit_cap": false, "count_type": 5, "unit_cap": 5}})
	proof["no_cap_when_unit_cap_unused"] = bool(no_cap.get("can_place_on", false)) and bool(no_cap_capped.get("can_place_on", false))

	# The uncapped branches (Units.java:122-124) return
	# Integer.MAX_VALUE, so even a huge count still places:
	# disableUnitCap, the wave team outside pvp, the wave
	# team in campaign, and team.ignoreUnitCap. The wave
	# team inside pvp stays capped (the first branch needs
	# !pvp and the second needs campaign).
	var disabled: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_can_place_on_state({"can_create_inputs": {"count_type": 9999, "unit_cap": 0, "disable_unit_cap": true}})
	var wave_no_pvp: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_can_place_on_state({"can_create_inputs": {"count_type": 9999, "unit_cap": 0, "is_wave_team": true, "is_pvp": false}})
	var wave_campaign: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_can_place_on_state({"can_create_inputs": {"count_type": 9999, "unit_cap": 0, "is_wave_team": true, "is_pvp": true, "is_campaign": true}})
	var ignored: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_can_place_on_state({"can_create_inputs": {"count_type": 9999, "unit_cap": 0, "ignore_unit_cap": true}})
	var wave_pvp: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_can_place_on_state({"can_create_inputs": {"count_type": 0, "unit_cap": 0, "is_wave_team": true, "is_pvp": true, "is_campaign": false}})
	proof["uncapped_when_unit_cap_disabled"] = bool(disabled.get("can_place_on", false)) and bool(wave_no_pvp.get("can_place_on", false)) and bool(wave_campaign.get("can_place_on", false)) and bool(ignored.get("can_place_on", false)) and bool(wave_pvp.get("can_place_on", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07UnitCargoLoaderCanPlaceOnProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
