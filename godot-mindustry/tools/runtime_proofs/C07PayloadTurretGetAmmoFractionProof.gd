extends Node

const main_scene := preload("res://scenes/Main.tscn")
const bridge := preload("res://src/game/SourcePayloadAmmoTurretBuildPortBridge.gd")
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

	# --- PayloadTurretBuild.getAmmoFraction() (N2487):
	# PayloadTurretBuild.getAmmoFraction()
	# (PayloadAmmoTurret.java:159-162) returns the
	# precomputed totalAmmo over maxAmmo (3, the
	# PayloadAmmoTurret ctor default) as a float fraction:
	# `@Override`
	# `public float getAmmoFraction(){`
	# `return (float)totalAmmo / maxAmmo;`
	# `}`
	# on `public class PayloadTurretBuild extends TurretBuild{`
	# (PayloadAmmoTurret.java:94). The body is the SAME
	# expression as ItemTurretBuild.getAmmoFraction()
	# (N1181) -- a GENERIC LITERAL (the N2479 precedent),
	# NOT a twin-register. The displayBars lambda (N2381,
	# PayloadAmmoTurret.java:174) repeats the same
	# arithmetic inside a Bar spec -- it is a DIFFERENT
	# method. totalAmmo is a precomputed input, refreshed
	# only by updateTile (N2381). NO divide-by-zero guard:
	# Java float division by zero yields Infinity. NO
	# clamp: a totalAmmo above maxAmmo passes through
	# above 1.0. NO driver tick line: a pure accessor.
	# The proof calls the pure function with synthetic
	# scalar inputs (no live tick).

	# Full ammo (3 of 3) is exactly 1.0.
	var full: Dictionary = bridge.source_payload_ammo_turret_build_get_ammo_fraction_state(3.0, 3.0)
	proof["ammo_fraction_full"] = is_equal_approx(float(full.get("ammo_fraction", -1.0)), 1.0)

	# Partial ammo (1 of 3) is one third.
	var partial: Dictionary = bridge.source_payload_ammo_turret_build_get_ammo_fraction_state(1.0, 3.0)
	proof["ammo_fraction_partial"] = is_equal_approx(float(partial.get("ammo_fraction", -1.0)), 1.0 / 3.0)

	# Empty ammo (0 of 3) is exactly 0.0.
	var empty: Dictionary = bridge.source_payload_ammo_turret_build_get_ammo_fraction_state(0.0, 3.0)
	proof["ammo_fraction_empty"] = is_equal_approx(float(empty.get("ammo_fraction", -1.0)), 0.0)

	# Overfull ammo (4 of 3) is NOT clamped: it passes
	# through above 1.0.
	var overfull: Dictionary = bridge.source_payload_ammo_turret_build_get_ammo_fraction_state(4.0, 3.0)
	proof["ammo_fraction_overfull_unclamped"] = is_equal_approx(float(overfull.get("ammo_fraction", -1.0)), 4.0 / 3.0)

	# Zero maxAmmo divides to Infinity with no guard --
	# Java float division by zero yields Infinity, and
	# GDScript float division by zero yields INF the
	# same way (the N1181 deferred precedent).
	var zero_max: Dictionary = bridge.source_payload_ammo_turret_build_get_ammo_fraction_state(2.0, 0.0)
	proof["ammo_fraction_zero_max_ammo_infinity"] = is_inf(float(zero_max.get("ammo_fraction", 0.0)))

	# Cross-pin with the displayBars lambda (N2381,
	# PayloadAmmoTurret.java:174): the Bar spec carries
	# the same fraction for the same inputs.
	var display_bars: Dictionary = bridge.source_payload_ammo_turret_build_display_bars_state([], 2, 3)
	var fraction_again: Dictionary = bridge.source_payload_ammo_turret_build_get_ammo_fraction_state(2.0, 3.0)
	proof["ammo_fraction_matches_display_bars_lambda"] = is_equal_approx(float(display_bars.get("ammo_fraction", -1.0)), float(fraction_again.get("ammo_fraction", -2.0)))

	# Calling twice with the same inputs gives the same
	# result: the function is pure and reads no state.
	var first_call: Dictionary = bridge.source_payload_ammo_turret_build_get_ammo_fraction_state(2.0, 3.0)
	var second_call: Dictionary = bridge.source_payload_ammo_turret_build_get_ammo_fraction_state(2.0, 3.0)
	proof["ammo_fraction_idempotent"] = is_equal_approx(float(first_call.get("ammo_fraction", -1.0)), float(second_call.get("ammo_fraction", -2.0)))

	# The result carries EXACTLY the one key.
	proof["ammo_fraction_returns_only_one_key"] = full.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadTurretGetAmmoFractionProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
