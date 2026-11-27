extends Node

const turret_state := preload("res://src/game/SourceTurretBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- ReloadTurretBuild.ammoReloadMultiplier() (N2481):
	# ReloadTurretBuild.ammoReloadMultiplier()
	# (ReloadTurret.java:41-43):
	#     protected float ammoReloadMultiplier(){
	#         return 1f;
	#     }
	# on `public class ReloadTurretBuild extends
	# BaseTurretBuild{` (ReloadTurret.java:25). The override
	# returns the CONSTANT 1f and reads NO state: no ammo,
	# no coolant, no efficiency -- it "turns off" the
	# parent's ammo multiplier entirely. TRAP: a port
	# returning `peekAmmo().reloadMultiplier` is WRONG --
	# that is the PARENT TurretBuild.ammoReloadMultiplier()
	# body (N746, Turret.java:727-729, `return hasAmmo() ?
	# peekAmmo().reloadMultiplier : 1f;`), a different
	# method in a different class. N746 exposes no pure GD
	# function for the parent method (its GD owner is the
	# PortGame-era bridge
	# PortGame.source_turret_reload_seconds_for_ammo), so
	# the cross-trap pins the parent by evaluating its
	# documented ternary from locals below. TRAP: this is
	# NOT baseReloadSpeed() (N2476, ReloadTurret.java:45-47,
	# `return efficiency;`) and NOT canReload() (N2473,
	# :49-51, `return reloadCounter < reload;`) -- the three
	# consecutive methods :41/:45/:49 are three separate
	# slices. The proof calls the pure function with no
	# inputs (no live tick, no game state).

	# The method returns the constant 1f, with no inputs.
	proof["ammo_reload_multiplier_is_one"] = turret_state.source_reload_turret_ammo_reload_multiplier_state().get("ammo_reload_multiplier") == 1.0

	# KEY TRAP: ammo with reloadMultiplier 2.5 still returns
	# 1.0 -- the override never reads the ammo.
	var ammo_high_multiplier := 2.5
	proof["ammo_high_multiplier_still_one"] = ammo_high_multiplier == 2.5 and turret_state.source_reload_turret_ammo_reload_multiplier_state().get("ammo_reload_multiplier") == 1.0

	# Ammo with reloadMultiplier 0.25 still returns 1.0.
	var ammo_low_multiplier := 0.25
	proof["ammo_low_multiplier_still_one"] = ammo_low_multiplier == 0.25 and turret_state.source_reload_turret_ammo_reload_multiplier_state().get("ammo_reload_multiplier") == 1.0

	# With no ammo at all the result is still 1.0 -- the
	# constant does not depend on ammo presence either.
	var has_ammo_none := false
	proof["no_ammo_still_one"] = has_ammo_none == false and turret_state.source_reload_turret_ammo_reload_multiplier_state().get("ammo_reload_multiplier") == 1.0

	# CROSS-TRAP, parent differs: TurretBuild
	# .ammoReloadMultiplier() (N746) returns the loaded
	# ammo's reloadMultiplier, so with ammo at 2.5 the
	# parent formula gives 2.5 while this slice gives 1.0.
	var has_ammo := true
	var parent_with_ammo: float = ammo_high_multiplier if has_ammo else 1.0
	proof["parent_formula_differs_with_ammo"] = parent_with_ammo == 2.5 and turret_state.source_reload_turret_ammo_reload_multiplier_state().get("ammo_reload_multiplier") == 1.0

	# With no ammo the parent formula falls back to 1f, so
	# both agree at 1.0 -- the trap only shows when ammo
	# is loaded with a multiplier != 1.
	var parent_without_ammo: float = ammo_high_multiplier if has_ammo_none else 1.0
	proof["parent_formula_matches_without_ammo"] = parent_without_ammo == 1.0 and turret_state.source_reload_turret_ammo_reload_multiplier_state().get("ammo_reload_multiplier") == 1.0

	# The result has exactly one key.
	proof["returns_only_one_key"] = turret_state.source_reload_turret_ammo_reload_multiplier_state().size() == 1

	# A second call with no input gives the same output.
	proof["idempotent_second_call"] = turret_state.source_reload_turret_ammo_reload_multiplier_state().get("ammo_reload_multiplier") == turret_state.source_reload_turret_ammo_reload_multiplier_state().get("ammo_reload_multiplier")

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ReloadTurretAmmoReloadMultiplierProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
