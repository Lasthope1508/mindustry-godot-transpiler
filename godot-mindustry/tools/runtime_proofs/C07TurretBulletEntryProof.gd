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

	# --- TurretBuild.BulletEntry ctor (N2410):
	# BulletEntry(Bullet bullet, float x, float y,
	# float rotation, float life) (Turret.java:867-873).
	# One ctor slice (batch 28 slot 3): the 2 unowned
	# field assignments only. `this.x = x;` and
	# `this.y = y;` are N1115-owned and `this.rotation
	# = rotation;` is N1770-owned -- none of the three
	# is re-registered here. The proof calls the pure
	# function with synthetic inputs (no live tick, no
	# render): one call returns all 5 record fields,
	# returns only those 5 keys, passes the bullet ref
	# through unchanged, keeps life a float, and is
	# idempotent on a second call with the same args.
	# The bullet arrives as an opaque Variant ref (a
	# Dictionary sentinel here -- the real Bullet object
	# is a Java-side ref the port never inspects).

	# One call returns all 5 record fields, and
	# nothing else besides the record.
	var bullet: Dictionary = {"id": 7, "kind": "standard"}
	var result: Dictionary = turret_build_state.source_turret_bullet_entry_state(bullet, 12.5, -3.25, 90.0, 4.5)
	proof["ctor_fields_all_five"] = result.get("bullet", {}) == bullet and result.get("x", 0.0) == 12.5 and result.get("y", 0.0) == -3.25 and result.get("rotation", 0.0) == 90.0 and result.get("life", 0.0) == 4.5
	proof["ctor_returns_only_five_keys"] = result.size() == 5

	# The bullet ref passes through unchanged: the
	# record keeps the same object the caller passed
	# in, it is never copied or rebuilt.
	proof["ctor_bullet_passthrough"] = result.get("bullet", {}) == bullet and (result.get("bullet", {}) as Dictionary).get("id", 0) == 7

	# Life is the float 4.5 (the laser driver's
	# shootDuration), not an int and not 0.0.
	proof["ctor_life_float"] = result.get("life", 0.0) == 4.5 and typeof(result.get("life", 0)) == TYPE_FLOAT

	# A second call with the same args yields the
	# same record: the ctor is a pure function.
	var second: Dictionary = turret_build_state.source_turret_bullet_entry_state(bullet, 12.5, -3.25, 90.0, 4.5)
	proof["ctor_idempotent_second_call"] = second == result and second.size() == 5

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretBulletEntryProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
