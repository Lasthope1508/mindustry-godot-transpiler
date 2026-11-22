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

	# --- UnitType estimateDps() (N2533): `public float estimateDps(){` /
	# `if(dpsEstimate < 0){` /
	# `dpsEstimate = weapons.sumf(Weapon::dps);` /
	# `if(weapons.contains(w -> w.bullet.killShooter)){` /
	# `dpsEstimate /= 15f;` /
	# `return dpsEstimate;`
	# (UnitType.java:1132-1144). The cache check is
	# `dpsEstimate < 0`: a cached 0.0 IS a hit (0 is not <
	# 0), and a negative cache (-1, the `dpsEstimate = -1,`
	# init, UnitType.java:104) recomputes. The suicide leg
	# divides the SAME field that was just summed, so the
	# divided value is what gets cached (returned through
	# both `estimate_dps` and `cached_dps` on the
	# "computed_suicide" branch). `cached_dps` is the runtime
	# cache (`dpsEstimate = -1,`, UnitType.java:104 -- -1
	# means "not computed yet"). `weapons_dps_sum` is the
	# caller-summed `weapons.sumf(Weapon::dps)` -- Weapon.dps()
	# (Weapon.java:188-190) is NOT ported yet.
	# `has_kill_shooter_weapon` is the caller-side
	# `weapons.contains(w -> w.bullet.killShooter)` guard.
	# The proof drives the pure function on exact legs:
	# 1 cache hit -> 42.0, cached unchanged (cache wins even
	# with a suicide weapon present); 2 cached 0.0 IS a hit
	# -> 0.0; 3 negative cache -5.0 recomputes -> 30.0; 4
	# weapons sum 120.0 -> 120.0; 5 fractional sum 37.5 ->
	# 37.5; 6 suicide 150.0 / 15 -> 10.0; 7 suicide fraction
	# 100.0 / 15 -> 100/15; 8 Java defaults (dpsEstimate init
	# -1, no weapons) -> 0.0.

	# Phase 1: cache hit -> 42.0, cached unchanged, branch
	# "cached" (the `dpsEstimate < 0` check fails first, even
	# with a suicide weapon present).
	var estimate: Dictionary = unit_type_state.source_unit_type_estimate_dps_state(42.0, 120.0, true)
	proof["estimate_dps_cached_hit"] = is_equal_approx(float(estimate.get("estimate_dps", -1.0)), 42.0) and is_equal_approx(float(estimate.get("cached_dps", -2.0)), 42.0) and String(estimate.get("branch", "")) == "cached"

	# Phase 2: cached 0.0 IS a hit (0 is not < 0) -> 0.0,
	# cached unchanged, branch "cached".
	estimate = unit_type_state.source_unit_type_estimate_dps_state(0.0, 120.0, false)
	proof["estimate_dps_cached_zero"] = is_equal_approx(float(estimate.get("estimate_dps", -1.0)), 0.0) and is_equal_approx(float(estimate.get("cached_dps", -2.0)), 0.0) and String(estimate.get("branch", "")) == "cached"

	# Phase 3: negative cache -5.0 recomputes (it is < 0)
	# -> 30.0, cached 30.0, branch "computed".
	estimate = unit_type_state.source_unit_type_estimate_dps_state(-5.0, 30.0, false)
	proof["estimate_dps_negative_cached_recomputes"] = is_equal_approx(float(estimate.get("estimate_dps", -1.0)), 30.0) and is_equal_approx(float(estimate.get("cached_dps", -2.0)), 30.0) and String(estimate.get("branch", "")) == "computed"

	# Phase 4: weapons sum 120.0 -> 120.0, cached 120.0,
	# branch "computed".
	estimate = unit_type_state.source_unit_type_estimate_dps_state(-1.0, 120.0, false)
	proof["estimate_dps_weapons_sum"] = is_equal_approx(float(estimate.get("estimate_dps", -1.0)), 120.0) and is_equal_approx(float(estimate.get("cached_dps", -2.0)), 120.0) and String(estimate.get("branch", "")) == "computed"

	# Phase 5: fractional sum 37.5 -> 37.5, cached 37.5,
	# branch "computed".
	estimate = unit_type_state.source_unit_type_estimate_dps_state(-1.0, 37.5, false)
	proof["estimate_dps_fractional_sum"] = is_equal_approx(float(estimate.get("estimate_dps", -1.0)), 37.5) and is_equal_approx(float(estimate.get("cached_dps", -2.0)), 37.5) and String(estimate.get("branch", "")) == "computed"

	# Phase 6: suicide 150.0 / 15 -> 10.0, cached 10.0,
	# branch "computed_suicide".
	estimate = unit_type_state.source_unit_type_estimate_dps_state(-1.0, 150.0, true)
	proof["estimate_dps_suicide"] = is_equal_approx(float(estimate.get("estimate_dps", -1.0)), 10.0) and is_equal_approx(float(estimate.get("cached_dps", -2.0)), 10.0) and String(estimate.get("branch", "")) == "computed_suicide"

	# Phase 7: suicide fraction 100.0 / 15 -> 100/15,
	# cached 100/15, branch "computed_suicide".
	estimate = unit_type_state.source_unit_type_estimate_dps_state(-1.0, 100.0, true)
	proof["estimate_dps_suicide_fraction"] = is_equal_approx(float(estimate.get("estimate_dps", -1.0)), 100.0 / 15.0) and is_equal_approx(float(estimate.get("cached_dps", -2.0)), 100.0 / 15.0) and String(estimate.get("branch", "")) == "computed_suicide"

	# Phase 8: Java defaults (dpsEstimate init -1, no
	# weapons, no suicide) -> 0.0, cached 0.0, branch
	# "computed".
	estimate = unit_type_state.source_unit_type_estimate_dps_state(-1.0, 0.0, false)
	proof["estimate_dps_java_defaults"] = is_equal_approx(float(estimate.get("estimate_dps", -1.0)), 0.0) and is_equal_approx(float(estimate.get("cached_dps", -2.0)), 0.0) and String(estimate.get("branch", "")) == "computed"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07UnitTypeEstimateDpsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
