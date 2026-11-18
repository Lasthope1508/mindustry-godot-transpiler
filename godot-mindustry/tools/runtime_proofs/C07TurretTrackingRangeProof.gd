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

	# --- TurretBuild.trackingRange() (N2273):
	# TurretBuild.trackingRange() (Turret.java:349-351,
	# `public float trackingRange(){` / `return range()
	# + trackingRange - range;`) over the
	# TurretBuild.range() result (Turret.java:342-345,
	# `public float range(){` / `return range +
	# peekAmmo().rangeChange;` when peekAmmo() is
	# non-null (Turret.java:693, `public @Nullable
	# BulletType peekAmmo(){`), else `return range;`),
	# the Turret def trackingRange field
	# (Turret.java:72, `public float trackingRange =
	# 0f;`) and the BaseTurret def range
	# (BaseTurret.java:21, `public float range = 80f;`).
	# init() clamps the field (Turret.java:217,
	# `trackingRange = Math.max(range, trackingRange);`),
	# so after init trackingRange() >= range(). The
	# range() result arrives as an explicit param (the
	# N2270 precedent): range() itself is not a live
	# SourceTurretBuildState row (the old N739/N740 rows
	# live in PortGame). There is no driver tick line:
	# trackingRange() is a load-time accessor findTarget
	# reads at Turret.java:652 (`float trackRange =
	# trackingRange(), range = range();`), not a per-tick
	# write (the N2268/N2249 accessor precedent).

	# Default field (0f) with no ammo, pre-init: 80.0 +
	# 0.0 - 80.0 = 0.0.
	var default_field_zero: Dictionary = turret_build_state.source_turret_tracking_range_state({}, 80.0, 0.0, 80.0)
	proof["tracking_range_default_field_zero"] = is_equal_approx(float(default_field_zero.get("tracking_range", -1.0)), 0.0)

	# Init-clamped field equals the range: 80.0 + 80.0
	# - 80.0 = 80.0.
	var post_init_clamped: Dictionary = turret_build_state.source_turret_tracking_range_state({}, 80.0, 80.0, 80.0)
	proof["tracking_range_post_init_clamped"] = is_equal_approx(float(post_init_clamped.get("tracking_range", -1.0)), 80.0)

	# A field beyond the range extends it: 80.0 +
	# 120.0 - 80.0 = 120.0.
	var extends_beyond: Dictionary = turret_build_state.source_turret_tracking_range_state({}, 80.0, 120.0, 80.0)
	proof["tracking_range_extends_beyond_range"] = is_equal_approx(float(extends_beyond.get("tracking_range", -1.0)), 120.0)

	# An ammo rangeChange rides the range() result
	# through: 95.0 + 120.0 - 80.0 = 135.0.
	var ammo_change: Dictionary = turret_build_state.source_turret_tracking_range_state({}, 95.0, 120.0, 80.0)
	proof["tracking_range_ammo_range_change"] = is_equal_approx(float(ammo_change.get("tracking_range", -1.0)), 135.0)

	# Ammo alone with a clamped field returns the
	# range() result: 100.0 + 80.0 - 80.0 = 100.0.
	var ammo_only: Dictionary = turret_build_state.source_turret_tracking_range_state({}, 100.0, 80.0, 80.0)
	proof["tracking_range_ammo_only"] = is_equal_approx(float(ammo_only.get("tracking_range", -1.0)), 100.0)

	# Equal values agree: 120.0 + 100.0 - 100.0 =
	# 120.0.
	var equal_all: Dictionary = turret_build_state.source_turret_tracking_range_state({}, 120.0, 100.0, 100.0)
	proof["tracking_range_equal_all"] = is_equal_approx(float(equal_all.get("tracking_range", -1.0)), 120.0)

	# Large values scale: 500.0 + 600.0 - 400.0 =
	# 700.0.
	var large: Dictionary = turret_build_state.source_turret_tracking_range_state({}, 500.0, 600.0, 400.0)
	proof["tracking_range_large_values"] = is_equal_approx(float(large.get("tracking_range", -1.0)), 700.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretTrackingRangeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
