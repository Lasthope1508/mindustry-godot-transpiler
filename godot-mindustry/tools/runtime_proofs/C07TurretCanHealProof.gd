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

	# --- Turret canHeal() derivation (N2281):
	# `protected boolean canHeal(){ return targetHealing &&
	# hasAmmo() && peekAmmo().collidesTeam && peekAmmo().heals(); }`
	# (Turret.java:635-637) on the fields `public boolean
	# targetHealing = false;` (Turret.java:95 -- duo never sets
	# it, grep Blocks.java duo 3257-3331: no hit), `public
	# boolean collidesTeam = false;` (BulletType.java:127 --
	# the duo ammo catalog has no collidesTeam key) and
	# `public boolean heals(){ return healPercent > 0 ||
	# healAmount > 0; }` (BulletType.java:447-449 -- duo ammo
	# never sets healPercent / healAmount, so heals() is false
	# for duo). Both Java consumers (validateTarget :632 and
	# findTarget :660) need a live entity scan, so no consumer
	# is rewired: this slice is stamp-only like N2280, one pure
	# function plus one driver tick. The direct pure-function
	# calls pin the value behind the driver observable below:
	# all four clauses true heals, while any one clause false
	# does not -- each clause read live from the frame.

	# The direct pure-function calls pin the value behind the
	# driver observable below.
	var direct_all: Dictionary = turret_build_state.source_turret_can_heal_state(true, true, true, true)
	var direct_no_target_healing: Dictionary = turret_build_state.source_turret_can_heal_state(false, true, true, true)
	var direct_no_ammo: Dictionary = turret_build_state.source_turret_can_heal_state(true, false, true, true)
	var direct_no_collides_team: Dictionary = turret_build_state.source_turret_can_heal_state(true, true, false, true)
	var direct_no_heals: Dictionary = turret_build_state.source_turret_can_heal_state(true, true, true, false)

	# All four clauses true heals -- directly.
	proof["can_heal_true_all_clauses"] = bool(direct_all.get("can_heal", false)) == true
	# Not targetHealing never heals -- directly.
	proof["can_heal_false_when_not_target_healing"] = bool(direct_no_target_healing.get("can_heal", true)) == false
	# No ammo never heals -- directly.
	proof["can_heal_false_when_no_ammo"] = bool(direct_no_ammo.get("can_heal", true)) == false
	# Ammo that does not collide with its team never heals -- directly.
	proof["can_heal_false_when_ammo_not_collides_team"] = bool(direct_no_collides_team.get("can_heal", true)) == false
	# Ammo that does not heal never heals -- directly.
	proof["can_heal_false_when_ammo_not_heals"] = bool(direct_no_heals.get("can_heal", true)) == false

	# One duo segment, live on the driver: the can_heal tick
	# runs right before the logic_controlled tick, before the
	# validateTarget call, so the frame carries the verdict as
	# a live key after a single tick.
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
	# This duo never sets targetHealing and its ammo never
	# collides with its team or heals, so the stamped verdict
	# is false.
	proof["can_heal_stamped_to_frame"] = frame.has("can_heal") and bool(frame.get("can_heal", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretCanHealProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
