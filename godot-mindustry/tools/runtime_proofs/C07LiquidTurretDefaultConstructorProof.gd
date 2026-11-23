extends Node

const main_scene := preload("res://scenes/Main.tscn")
const liquid_turret_build := preload("res://src/game/SourceLiquidTurretBuildState.gd")
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

	# --- LiquidTurret(String name) (N2406):
	# LiquidTurret(String name) (LiquidTurret.java:22-29). One
	# ctor slice (batch 27 slot 1): the 4 field defaults
	# only. `super(name);` is N2185-owned,
	# `hasLiquids = true;` is
	# N927/N2000/N2179/N2182/N2209-owned -- none is
	# re-registered here. The proof calls the pure function
	# with synthetic inputs (no live tick, no render): one
	# call returns all 4 ctor defaults, writes them into
	# the def frame, preserves unrelated frame keys,
	# overwrites stale frame values, and is idempotent on
	# a second call. The 4 values are Sound/Effect
	# references, so they arrive as explicit Variant params
	# (the N2405 BaseTurret ctor precedent) and pass
	# through: the proof drives them with the string
	# sentinels "loopSpray" / "none" / "none" / "none".
	# The defaults are frame data only; no Draw is ported
	# and the ambient-sound driver (N2304, HELD) is
	# untouched.

	# One call returns all 4 ctor defaults, and nothing
	# else besides the updated frame.
	var fresh: Dictionary = {}
	var result: Dictionary = liquid_turret_build.source_liquid_turret_default_constructor_state(fresh, "loopSpray", "none", "none", "none")
	proof["ctor_defaults_all_four"] = result.get("loop_sound", "") == "loopSpray" and result.get("shoot_sound", "") == "none" and result.get("smoke_effect", "") == "none" and result.get("shoot_effect", "") == "none"
	proof["ctor_returns_only_five_keys"] = result.size() == 5

	# The call writes the 4 defaults into the def frame
	# (in/out): the returned frame is the same frame.
	proof["ctor_writes_frame"] = (result.get("liquid_turret_defaults", {}) as Dictionary) == fresh and fresh.get("loop_sound", "") == "loopSpray" and fresh.get("shoot_sound", "") == "none" and fresh.get("smoke_effect", "") == "none" and fresh.get("shoot_effect", "") == "none"

	# Unrelated frame keys survive the call untouched.
	var kept: Dictionary = {"name": "wave", "range": 70.0}
	var kept_result: Dictionary = liquid_turret_build.source_liquid_turret_default_constructor_state(kept, "loopSpray", "none", "none", "none")
	proof["ctor_preserves_existing_frame_keys"] = kept.get("name", "") == "wave" and kept.get("range", 0.0) == 70.0 and kept_result.get("loop_sound", "") == "loopSpray"

	# Stale frame values are overwritten: the ctor always
	# assigns, it never reads the old value.
	var stale: Dictionary = {"loop_sound": "none", "shoot_sound": "shootDuo", "smoke_effect": "smoke", "shoot_effect": "shoot"}
	var stale_result: Dictionary = liquid_turret_build.source_liquid_turret_default_constructor_state(stale, "loopSpray", "none", "none", "none")
	proof["ctor_overwrites_stale_frame_values"] = stale.get("loop_sound", "") == "loopSpray" and stale.get("shoot_sound", "") == "none" and stale.get("smoke_effect", "") == "none" and stale.get("shoot_effect", "") == "none" and stale_result.get("loop_sound", "") == "loopSpray" and stale_result.get("shoot_sound", "") == "none" and stale_result.get("smoke_effect", "") == "none" and stale_result.get("shoot_effect", "") == "none"

	# The two Sound params pass through: the param values
	# are returned unchanged, in both the string shape and
	# an array shape.
	var arrayed: Dictionary = liquid_turret_build.source_liquid_turret_default_constructor_state({}, ["loopSpray"], ["none"], "none", "none")
	proof["ctor_sounds_passthrough"] = result.get("loop_sound", "") == "loopSpray" and result.get("shoot_sound", "") == "none" and arrayed.get("loop_sound", null) == ["loopSpray"] and arrayed.get("shoot_sound", null) == ["none"]

	# The two Effect params pass through: the param values
	# are returned unchanged, in both the string shape and
	# an array shape.
	var arrayed_effects: Dictionary = liquid_turret_build.source_liquid_turret_default_constructor_state({}, "loopSpray", "none", ["none"], ["none"])
	proof["ctor_effects_passthrough"] = result.get("smoke_effect", "") == "none" and result.get("shoot_effect", "") == "none" and arrayed_effects.get("smoke_effect", null) == ["none"] and arrayed_effects.get("shoot_effect", null) == ["none"]

	# A second call on the same frame yields the same 4
	# values: the ctor is idempotent.
	var second: Dictionary = liquid_turret_build.source_liquid_turret_default_constructor_state(fresh, "loopSpray", "none", "none", "none")
	proof["ctor_idempotent_second_call"] = second.get("loop_sound", "") == "loopSpray" and second.get("shoot_sound", "") == "none" and second.get("smoke_effect", "") == "none" and second.get("shoot_effect", "") == "none" and second.size() == 5

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LiquidTurretDefaultConstructorProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
