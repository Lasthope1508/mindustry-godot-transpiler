extends Node

const main_scene := preload("res://scenes/Main.tscn")
const turret_build_state := preload("res://src/game/SourceTurretBuildState.gd")
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

	# --- Turret minRange() artillery minimum (N2282): TurretBuild.minRange()
	# (Turret.java:334-339) returns the def minimum plus the peeked
	# bullet's minRangeChange when ammo is peeked, the bare def minimum
	# otherwise:
	# `public float minRange(){`
	# `if(peekAmmo() != null){`
	# `return minRange + peekAmmo().minRangeChange;`
	# `}`
	# `return minRange;`
	# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
	# (Turret.java:277). The def minimum is the Turret field
	# (Turret.java:74, `public float minRange = 0f;`, "Minimum bullet
	# range. Used for artillery only."); the ammo change is the peeked
	# bullet's minRangeChange (BulletType.java:163,
	# `public float minRangeChange = 0f;`, default 0f). The gate is
	# peekAmmo() != null (Turret.java:693), NOT hasAmmo()
	# (Turret.java:698, which has the ammo-swap side effect) -- so the
	# pure function takes has_ammo as an explicit bool carrying the
	# peekAmmo() null check (the isActive :509 precedent), never calls
	# hasAmmo(). NO driver tick line: minRange() is a read accessor its
	# callers read (drawSelect :485, the shoot life-scale :787), not a
	# per-tick write. The proof calls the pure function with synthetic
	# frames (no live tick: minRange is a pure accessor over three
	# inputs).

	# Ammo adds the change: def minimum 40, peeked ammo, change 10 -> 50.
	var with_ammo: Dictionary = turret_build_state.source_turret_min_range_state({}, 40.0, true, 10.0)
	proof["min_range_with_ammo"] = is_equal_approx(float(with_ammo.get("min_range", -1.0)), 50.0)

	# No ammo returns the bare def minimum: 40, no peeked ammo, change
	# 10 (ignored) -> 40.
	var without_ammo: Dictionary = turret_build_state.source_turret_min_range_state({}, 40.0, false, 10.0)
	proof["min_range_without_ammo"] = is_equal_approx(float(without_ammo.get("min_range", -1.0)), 40.0)

	# Zero def with zero change stays zero: the Turret.java:74 /
	# BulletType.java:163 defaults (0f / 0f).
	var default_zero: Dictionary = turret_build_state.source_turret_min_range_state({}, 0.0, true, 0.0)
	proof["min_range_default_zero"] = is_equal_approx(float(default_zero.get("min_range", -1.0)), 0.0)

	# A negative change lowers the minimum: 40, peeked ammo, change
	# -5 -> 35 (minRangeChange is an unconstrained float).
	var negative: Dictionary = turret_build_state.source_turret_min_range_state({}, 40.0, true, -5.0)
	proof["min_range_negative_change"] = is_equal_approx(float(negative.get("min_range", -1.0)), 35.0)

	# The change is ignored without ammo: 40, no peeked ammo, change
	# 25 -> 40 (the Java fall-through leg, not the peeked leg).
	var ignored: Dictionary = turret_build_state.source_turret_min_range_state({}, 40.0, false, 25.0)
	proof["min_range_change_ignored_without_ammo"] = is_equal_approx(float(ignored.get("min_range", -1.0)), 40.0)

	# Artillery scale: a large def minimum (120) plus the peeked
	# bullet's change (8) -> 128.
	var artillery: Dictionary = turret_build_state.source_turret_min_range_state({}, 120.0, true, 8.0)
	proof["min_range_artillery_scale"] = is_equal_approx(float(artillery.get("min_range", -1.0)), 128.0)

	# The result carries ONLY the one min_range key: no frame echo, no
	# extra state.
	proof["returns_only_one_key"] = with_ammo.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretMinRangeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
