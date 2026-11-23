extends Node

const main_scene := preload("res://scenes/Main.tscn")
const teams_state := preload("res://src/game/SourceTeamsRuntimeState.gd")
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

	# --- Teams.BlockPlan ctor (N2409):
	# Teams.BlockPlan (Teams.java:497-503). One slice
	# (main-thread decision 2026-11-22, batch 28 slot 2:
	# 3 exprs is enough -- the N2407 2-expr precedent).
	# The proof calls the pure function with synthetic
	# inputs (no live tick): the happy path stores x/y
	# and config, rotation and block pass through, x/y
	# are narrowed to 16-bit signed, null block/config
	# pass through, and the record has exactly five keys.
	# `this.rotation = rotation;` is owned N1770 and
	# `this.block = block;` is owned N1771 -- evidence
	# only, never re-registered. The mutable `removed`
	# field is outside the ctor and is not part of the
	# record.

	# The happy path stores x/y and config.
	var done: Dictionary = teams_state.source_teams_block_plan_state(10, 20, 1, "conveyor", "cfg")
	proof["block_plan_ctor_sets_x_y_config"] = done.get("x", -1) == 10 and done.get("y", -1) == 20 and done.get("config", null) == "cfg"
	proof["block_plan_ctor_returns_only_five_keys"] = done.size() == 5

	# Rotation and block pass through untouched.
	proof["block_plan_ctor_keeps_rotation_and_block"] = done.get("rotation", -1) == 1 and done.get("block", null) == "conveyor"

	# The (short) casts narrow x/y to 16-bit signed:
	# 70000 wraps to 4464, -1 stays -1.
	var narrowed: Dictionary = teams_state.source_teams_block_plan_state(70000, -1, 0, null, null)
	proof["block_plan_ctor_narrows_xy_to_short"] = narrowed.get("x", -1) == 4464 and narrowed.get("y", -1) == -1

	# Null block and null config pass through.
	var nulled: Dictionary = teams_state.source_teams_block_plan_state(3, 4, 2, null, null)
	proof["block_plan_ctor_accepts_null_block_and_config"] = nulled.get("block", "set") == null and nulled.get("config", "set") == null and nulled.get("x", -1) == 3 and nulled.get("y", -1) == 4

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TeamsBlockPlanProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
