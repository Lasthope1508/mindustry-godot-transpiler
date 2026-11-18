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

	# --- TurretBuild.fogRadius() (N2244):
	# TurretBuild overrides fogRadius (Turret.java:420-423,
	# `public float fogRadius(){` / `return (range +
	# (hasAmmo() ? peekAmmo().rangeChange : 0f)) /
	# tilesize * fogRadiusMultiplier;`) over the
	# BaseTurret def range (BaseTurret.java:21, `public
	# float range = 80f;`) and fogRadiusMultiplier
	# (BaseTurret.java:24, `public float
	# fogRadiusMultiplier = 1f;`), tilesize
	# (Vars.java:135, `public static final int tilesize =
	# 8;`), and the peeked bullet's rangeChange
	# (BulletType.java:157, `public float rangeChange =
	# 0f;`). Unlike range() (Turret.java:342-345),
	# fogRadius() adds rangeChange only when hasAmmo()
	# (Turret.java:698, `public boolean hasAmmo(){`) --
	# the stricter gate (ammo present, enough for a shot,
	# canConsume). The accessor is what the fog system
	# reads (FogControl.java:161,
	# `Mathf.round(build.fogRadius())`;
	# FogRenderer.java:68, `build.fogRadius() *
	# tilesize`); the fog system itself waits for its own
	# slice. There is no driver tick line: fogRadius() is
	# a load-time accessor the fog system reads, not a
	# per-tick write (the N2249 precedent).

	# Default no-ammo radius: range 80.0 / tilesize 8.0
	# * multiplier 1.0 = 10.0.
	var default_no_ammo: Dictionary = turret_build_state.source_turret_fog_radius_state({}, 80.0, false, 0.0, 8.0, 1.0)
	proof["fog_radius_default_no_ammo"] = is_equal_approx(float(default_no_ammo.get("fog_radius", -1.0)), 10.0)

	# Has-ammo adds the ammo rangeChange: (80.0 + 40.0)
	# / 8.0 * 1.0 = 15.0.
	var with_ammo: Dictionary = turret_build_state.source_turret_fog_radius_state({}, 80.0, true, 40.0, 8.0, 1.0)
	proof["fog_radius_with_ammo_range_change"] = is_equal_approx(float(with_ammo.get("fog_radius", -1.0)), 15.0)

	# The multiplier scales: 80.0 / 8.0 * 0.5 = 5.0.
	var half_multiplier: Dictionary = turret_build_state.source_turret_fog_radius_state({}, 80.0, false, 0.0, 8.0, 0.5)
	proof["fog_radius_multiplier_half"] = is_equal_approx(float(half_multiplier.get("fog_radius", -1.0)), 5.0)

	# A negative rangeChange shrinks: (80.0 - 16.0) /
	# 8.0 * 1.0 = 8.0.
	var negative_change: Dictionary = turret_build_state.source_turret_fog_radius_state({}, 80.0, true, -16.0, 8.0, 1.0)
	proof["fog_radius_negative_range_change"] = is_equal_approx(float(negative_change.get("fog_radius", -1.0)), 8.0)

	# A larger range and multiplier grow: (160.0 + 80.0)
	# / 8.0 * 2.0 = 60.0.
	var large: Dictionary = turret_build_state.source_turret_fog_radius_state({}, 160.0, true, 80.0, 8.0, 2.0)
	proof["fog_radius_large_range_multiplier"] = is_equal_approx(float(large.get("fog_radius", -1.0)), 60.0)

	# Has-ammo with zero change equals absent ammo:
	# (80.0 + 0.0) / 8.0 * 1.0 = 10.0.
	var zero_change: Dictionary = turret_build_state.source_turret_fog_radius_state({}, 80.0, true, 0.0, 8.0, 1.0)
	proof["fog_radius_ammo_zero_change"] = is_equal_approx(float(zero_change.get("fog_radius", -1.0)), 10.0)

	# The tilesize param divides: 80.0 / 16.0 * 1.0 =
	# 5.0.
	var tilesize_param: Dictionary = turret_build_state.source_turret_fog_radius_state({}, 80.0, false, 0.0, 16.0, 1.0)
	proof["fog_radius_tilesize_param"] = is_equal_approx(float(tilesize_param.get("fog_radius", -1.0)), 5.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretFogRadiusProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
