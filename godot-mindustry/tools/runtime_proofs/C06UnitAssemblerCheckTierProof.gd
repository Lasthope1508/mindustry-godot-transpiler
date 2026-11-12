extends Node

const main_scene := preload("res://scenes/Main.tscn")
const factory_build_state := preload("res://src/game/SourceUnitFactoryBuildState.gd")
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

	# --- checkTier: UnitAssemblerBuild.checkTier()
	# (UnitAssembler.java:363-377) sorts the attached modules by
	# tier, climbs while each module is the current max or one above
	# it, stops at the first tier gap, and stores the result in
	# currentTier (UnitAssembler.java:326). The port carries the
	# modules as the frame's `modules` list of ints, the same
	# minimal-frame convention as the N2129 `blocks` dict. ---
	var empty: Dictionary = factory_build_state.source_unit_factory_assembler_check_tier_state({"modules": []})
	proof["check_tier_no_modules_zero"] = int(empty.get("current_tier", -1)) == 0 and Array(empty.get("module_tiers", [-1])) == [] and bool(empty.get("tier_gap", true)) == false

	# --- One tier-1 module climbs to 1. ---
	var single: Dictionary = factory_build_state.source_unit_factory_assembler_check_tier_state({"modules": [1]})
	proof["check_tier_single_tier_one"] = int(single.get("current_tier", -1)) == 1 and Array(single.get("module_tiers", [])) == [1] and bool(single.get("tier_gap", true)) == false

	# --- Sequential tiers 1 then 2 climb to 2. ---
	var sequential: Dictionary = factory_build_state.source_unit_factory_assembler_check_tier_state({"modules": [1, 2]})
	proof["check_tier_sequential_one_two"] = int(sequential.get("current_tier", -1)) == 2 and Array(sequential.get("module_tiers", [])) == [1, 2] and bool(sequential.get("tier_gap", true)) == false

	# --- A gap stops the climb: 3 is neither max 1 nor max + 1 2,
	# so the tier stays 1 and tier_gap is true. ---
	var gap: Dictionary = factory_build_state.source_unit_factory_assembler_check_tier_state({"modules": [1, 3]})
	proof["check_tier_gap_stops_climb"] = int(gap.get("current_tier", -1)) == 1 and Array(gap.get("module_tiers", [])) == [1, 3] and bool(gap.get("tier_gap", false)) == true

	# --- Unsorted input is sorted first: [2, 1] climbs to 2. ---
	var unsorted: Dictionary = factory_build_state.source_unit_factory_assembler_check_tier_state({"modules": [2, 1]})
	proof["check_tier_unsorted_input_sorted"] = int(unsorted.get("current_tier", -1)) == 2 and Array(unsorted.get("module_tiers", [])) == [1, 2] and bool(unsorted.get("tier_gap", true)) == false

	# --- A duplicate tier is the current max, so the climb
	# continues past it: [1, 1, 2] climbs to 2. ---
	var duplicate: Dictionary = factory_build_state.source_unit_factory_assembler_check_tier_state({"modules": [1, 1, 2]})
	proof["check_tier_duplicate_tier"] = int(duplicate.get("current_tier", -1)) == 2 and Array(duplicate.get("module_tiers", [])) == [1, 1, 2] and bool(duplicate.get("tier_gap", true)) == false

	# --- A gap after two: [1, 2, 4] climbs to 2, then 4 is
	# neither max 2 nor max + 1 3, so the tier stays 2. ---
	var gap_after_two: Dictionary = factory_build_state.source_unit_factory_assembler_check_tier_state({"modules": [1, 2, 4]})
	proof["check_tier_gap_after_two"] = int(gap_after_two.get("current_tier", -1)) == 2 and Array(gap_after_two.get("module_tiers", [])) == [1, 2, 4] and bool(gap_after_two.get("tier_gap", false)) == true

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C06UnitAssemblerCheckTierProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
