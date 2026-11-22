extends Node

const main_scene := preload("res://scenes/Main.tscn")
const unit_type_state := preload("res://src/game/SourceUnitTypeState.gd")
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

	# --- UnitType weapons.sumf(Weapon::dps) (N2536):
	# `public float estimateDps(){` /
	# `dpsEstimate = weapons.sumf(Weapon::dps);` /
	# `return dpsEstimate;`
	# (UnitType.java:1132-1144). `weapons` is
	# `public Seq<Weapon> weapons = new Seq<>();`
	# (UnitType.java:288). Each element of `weapons_dps` is
	# the caller-computed per-weapon dps from
	# `source_weapon_dps_state` (N2534, Weapon.dps(),
	# Weapon.java:188-190); this function does NOT call
	# Weapon.dps() directly. The total starts at 0.0, so an
	# empty weapons Seq sums to 0.0. The single return key is
	# `weapons_dps_sum`.
	# The proof drives the pure function on exact legs:
	# 1 empty weapons -> 0.0; 2 single weapon 60.0 -> 60.0;
	# 3 two weapons 30.0 + 60.0 -> 90.0; 4 fractional 12.5 +
	# 25.0 -> 37.5; 5 with a zero-dps weapon 0.0 + 45.0 ->
	# 45.0; 6 four weapons of 60.0 -> 240.0; 7 large 500.0 +
	# 500.0 -> 1000.0; 8 small fractions 0.5 + 0.25 + 0.25 ->
	# 1.0.

	# Phase 1: empty weapons -> 0.0.
	var summed: Dictionary = unit_type_state.source_unit_type_weapons_dps_sum_state([])
	proof["weapons_dps_sum_empty"] = is_equal_approx(float(summed.get("weapons_dps_sum", -1.0)), 0.0)

	# Phase 2: single weapon 60.0 -> 60.0.
	summed = unit_type_state.source_unit_type_weapons_dps_sum_state([60.0])
	proof["weapons_dps_sum_single"] = is_equal_approx(float(summed.get("weapons_dps_sum", -1.0)), 60.0)

	# Phase 3: two weapons 30.0 + 60.0 -> 90.0.
	summed = unit_type_state.source_unit_type_weapons_dps_sum_state([30.0, 60.0])
	proof["weapons_dps_sum_two"] = is_equal_approx(float(summed.get("weapons_dps_sum", -1.0)), 90.0)

	# Phase 4: fractional 12.5 + 25.0 -> 37.5.
	summed = unit_type_state.source_unit_type_weapons_dps_sum_state([12.5, 25.0])
	proof["weapons_dps_sum_fractional"] = is_equal_approx(float(summed.get("weapons_dps_sum", -1.0)), 37.5)

	# Phase 5: with a zero-dps weapon 0.0 + 45.0 -> 45.0.
	summed = unit_type_state.source_unit_type_weapons_dps_sum_state([0.0, 45.0])
	proof["weapons_dps_sum_with_zero"] = is_equal_approx(float(summed.get("weapons_dps_sum", -1.0)), 45.0)

	# Phase 6: four weapons of 60.0 -> 240.0.
	summed = unit_type_state.source_unit_type_weapons_dps_sum_state([60.0, 60.0, 60.0, 60.0])
	proof["weapons_dps_sum_many"] = is_equal_approx(float(summed.get("weapons_dps_sum", -1.0)), 240.0)

	# Phase 7: large 500.0 + 500.0 -> 1000.0.
	summed = unit_type_state.source_unit_type_weapons_dps_sum_state([500.0, 500.0])
	proof["weapons_dps_sum_large"] = is_equal_approx(float(summed.get("weapons_dps_sum", -1.0)), 1000.0)

	# Phase 8: small fractions 0.5 + 0.25 + 0.25 -> 1.0.
	summed = unit_type_state.source_unit_type_weapons_dps_sum_state([0.5, 0.25, 0.25])
	proof["weapons_dps_sum_small_fractions"] = is_equal_approx(float(summed.get("weapons_dps_sum", -1.0)), 1.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07UnitTypeWeaponsDpsSumProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
