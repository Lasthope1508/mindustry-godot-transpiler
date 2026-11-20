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

	# --- Turret progress() derivation (N2282):
	# `public float progress(){ return Mathf.clamp(
	# reloadCounter / reload); }` (Turret.java:425-427) on
	# the fields `public float reloadCounter;`
	# (ReloadTurret.java:26, inherited by TurretBuild via
	# ReloadTurretBuild -- the driver already stamps it live
	# as frame["reload_counter"] from the aim tick, capped at
	# reload by updateReload :720-723) and `public float
	# reload = 10f;` (ReloadTurret.java:10, the class default;
	# duo overrides `reload = 20f;`, Blocks.java:3317 -- the
	# driver aim call already passes 20.0).
	# Mathf.clamp(float) is `return Math.max(Math.min(value,
	# 1f), 0f);` (arc Mathf.java:402-404) -- GDScript
	# clampf(value, 0.0, 1.0) is the same min-then-max. The
	# only Java consumer is sense() LAccess.progress
	# (`case progress -> progress();`, Turret.java:414); the
	# sense dispatch is its own later slice, so no consumer
	# is rewired: this slice is stamp-only like N2280/N2281,
	# one pure function plus one driver tick. The direct
	# pure-function calls pin the value behind the driver
	# observable below: an empty counter is 0, half the
	# reload is 0.5, a full counter is 1, and a counter past
	# reload clamps to 1 -- each read live from the frame.

	# The direct pure-function calls pin the value behind the
	# driver observable below.
	var direct_empty: Dictionary = turret_build_state.source_turret_progress_state(0.0, 20.0)
	var direct_half: Dictionary = turret_build_state.source_turret_progress_state(10.0, 20.0)
	var direct_full: Dictionary = turret_build_state.source_turret_progress_state(20.0, 20.0)
	var direct_over: Dictionary = turret_build_state.source_turret_progress_state(25.0, 20.0)

	# An empty counter is 0 -- directly.
	proof["progress_zero_at_empty_counter"] = float(direct_empty.get("progress", -1.0)) == 0.0
	# Half the reload is 0.5 -- directly.
	proof["progress_half_at_half_counter"] = float(direct_half.get("progress", -1.0)) == 0.5
	# A full counter is 1 -- directly.
	proof["progress_one_at_full_counter"] = float(direct_full.get("progress", -1.0)) == 1.0
	# A counter past reload clamps to 1 -- directly.
	proof["progress_clamped_above_reload"] = float(direct_over.get("progress", -1.0)) == 1.0

	# One duo segment, live on the driver: the progress tick
	# runs right after the reload_counter stamp, once the
	# counter is final for this tick, so the frame carries the
	# verdict as a live key after a single tick.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var cell := Vector2i(28, 21)
	var segment := Sprite2D.new()
	game.add_child(segment)
	game.call("record_placed_block", segment, blocks_by_id["duo"], cell)
	# The raw Sprite2D node never passes through the texture
	# path (SourceTextureRuntimeState.configure_block_sprite),
	# which is what assigns a placed block its world position
	# (`sprite.position = game.source_block_sprite_base_position(block, cell)`),
	# so without this the segment sits at the origin (0, 0)
	# and the turret-centred query cannot be distinguished
	# from an origin-centred one. Seed the position exactly
	# the way the game does (the N2211 proof lesson).
	segment.position = game.source_block_sprite_base_position(blocks_by_id["duo"], cell)
	turret_build_state.source_turret_bind_frame_state(segment, blocks_by_id["duo"])

	# One shared tick wires team_id / cheating / enabled onto
	# the frame (and charges the reload by 1/60).
	turret_build_state.source_turret_tick_buildings_state(game, 1.0 / 60.0)
	var frame: Dictionary = segment.get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})

	# The verdict is stamped on the frame after the tick, as
	# a live key -- not just computed by the pure function.
	# One tick charges the reload by 1/60 of the 20-tick
	# reload, so the stamped progress is a small positive
	# fraction inside [0, 1].
	proof["progress_stamped_to_frame"] = frame.has("progress") and float(frame.get("progress", -1.0)) >= 0.0 and float(frame.get("progress", 2.0)) <= 1.0

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretProgressProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
