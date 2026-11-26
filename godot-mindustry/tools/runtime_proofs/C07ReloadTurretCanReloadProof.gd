extends Node

const turret_state := preload("res://src/game/SourceTurretBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- ReloadTurretBuild.canReload() (N2473):
	# ReloadTurretBuild.canReload() (ReloadTurret.java:49-51):
	#     return reloadCounter < reload;
	# TRAP: the comparison is STRICT `<` -- counter == reload
	# is false, 0 < 0 is false, and a negative counter is NOT
	# clamped (Java has no Math.max here; capping lives in
	# updateReload, not in canReload). TRAP: this is the gate
	# updateCooling() (N2525) calls first and shouldConsume()
	# (N2291) embeds -- neither slice registers canReload(),
	# so this slice owns the gate itself. The proof calls the
	# pure function with synthetic counter/reload pairs (no
	# live tick, no game state). GDScript float is 64-bit vs
	# Java float 32-bit, but the comparison is exact on these
	# values, so == on the bool result is exact.

	# Below threshold is true.
	var below_result: Dictionary = turret_state.source_reload_turret_can_reload_state(3.0, 10.0)
	proof["below_threshold_true"] = below_result.get("can_reload") == true and below_result.size() == 1

	# A normal cycle just below the threshold is true.
	proof["product_of_normal_cycle"] = turret_state.source_reload_turret_can_reload_state(9.5, 10.0).get("can_reload") == true

	# TRAP: strict `<` -- equal is false (a port that uses
	# `<=` is wrong; this is also the state updateTile relies
	# on to decide whether to fire).
	proof["equal_is_false"] = turret_state.source_reload_turret_can_reload_state(10.0, 10.0).get("can_reload") == false

	# Above threshold is false.
	proof["above_threshold_false"] = turret_state.source_reload_turret_can_reload_state(12.0, 10.0).get("can_reload") == false

	# TRAP: 0 < 0 is false -- not "always reloadable when
	# the counter is 0".
	proof["zero_zero_is_false"] = turret_state.source_reload_turret_can_reload_state(0.0, 0.0).get("can_reload") == false

	# The field defaults (counter 0, reload 10) are true.
	proof["zero_counter_default_reload_true"] = turret_state.source_reload_turret_can_reload_state(0.0, 10.0).get("can_reload") == true

	# TRAP: a negative counter is not clamped -- it passes
	# through as true (Java has no Math.max here).
	proof["negative_counter_not_clamped"] = turret_state.source_reload_turret_can_reload_state(-5.0, 10.0).get("can_reload") == true

	# A fractional counter just below the threshold is true
	# (direct float comparison, no rounding).
	proof["fractional_just_below"] = turret_state.source_reload_turret_can_reload_state(9.999, 10.0).get("can_reload") == true

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ReloadTurretCanReloadProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
