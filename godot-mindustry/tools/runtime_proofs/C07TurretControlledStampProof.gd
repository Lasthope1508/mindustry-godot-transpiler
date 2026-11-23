extends Node

const main_scene := preload("res://scenes/Main.tscn")
const turret_build_state := preload("res://src/game/SourceTurretBuildState.gd")
const item_turret_build_state := preload("res://src/game/SourceItemTurretBuildState.gd")
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

	# --- Turret controlled() frame stamp (N2523):
	# `public boolean controlled(){ return unit.isPlayer(); }`
	# (Turret.java:441-443) on the unit `public BlockUnitc
	# unit = (BlockUnitc)UnitTypes.block.create(team);` (:291).
	# It rescues validateTarget (`return
	# !Units.invalidateTarget(target, canHeal() ? Team.derelict
	# : team, x, y) || controlled() || logicControlled();`,
	# :631-633, N2251), picks the player branch of isShooting
	# (`isShooting = alwaysShooting || (unit.controller()
	# instanceof Player ? unit.isShooting() : logicControlled()
	# ? logicShooting : target != null);`, :492, N2277) and
	# gates the warmup hold (`if(warmupTarget > 0 &&
	# !controlled()){` / `warmupHold = 1f;`, :503, N2253) --
	# but the driver validate / isShooting / warmup calls
	# passed `bool(frame.get("controlled", false))` while
	# frame["controlled"] was NEVER stamped anywhere. This
	# slice ports the one-line Java method as a pure stamp
	# function and stamps it live right before the validate
	# call (the N2278 logicControlled precedent). The tick
	# reads the `unit_is_player` frame input (absent today:
	# the port has NO player unit, so unit.isPlayer() is false
	# for every live turret, the N2520 unit_sense_value = 0.0
	# precedent).

	# The direct pure-function calls pin the value behind the
	# driver observables below.
	var direct_false: Dictionary = turret_build_state.source_turret_controlled_stamp_state({}, false)
	var direct_true: Dictionary = turret_build_state.source_turret_controlled_stamp_state({}, true)

	# A non-player unit is not controlled -- directly.
	proof["controlled_stamp_false"] = direct_false.has("controlled") and bool(direct_false.get("controlled", true)) == false
	# A player unit is controlled -- directly.
	proof["controlled_stamp_true"] = direct_true.has("controlled") and bool(direct_true.get("controlled", false)) == true

	# One duo segment, live on the driver: the stamp tick runs
	# right after the N2278 logic_controlled stamp and right
	# before the validateTarget call, so the frame carries a
	# live controlled key after a single tick (false today --
	# no player unit in the port).
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

	turret_build_state.source_turret_tick_buildings_state(game, 1.0 / 60.0)
	var frame: Dictionary = segment.get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})

	# The controlled key is stamped on the frame after the
	# tick, as a live key -- not just computed by the pure
	# function. This duo has no player unit, so the stamped
	# value is false; stamping true on the same frame and
	# feeding it to the validate verdict rescues an
	# otherwise-invalid target (a dead-Healthc target, :631-633),
	# proving the validate call reads the stamped key -- while
	# the same verdict without controlled stays invalid.
	var tick_stamped: bool = frame.has("controlled") and bool(frame.get("controlled", true)) == false
	var stamped: Dictionary = turret_build_state.source_turret_controlled_stamp_state(frame, true)
	var stamped_true: bool = bool(stamped.get("controlled", false)) == true
	var rescued: Dictionary = item_turret_build_state.source_item_turret_validate_target_state(false, false, false, true, bool(stamped.get("controlled", false)), false)
	var unrescued: Dictionary = item_turret_build_state.source_item_turret_validate_target_state(false, false, false, true, false, false)
	proof["controlled_stamp_composed_validate"] = tick_stamped and stamped_true and bool(rescued.get("valid", false)) == true and bool(unrescued.get("valid", true)) == false

	# The player branch of isShooting (:492) reads the stamped
	# key: a controlled turret with a shooting player is
	# shooting even with no target, while the same call with
	# the key false is not shooting without a target.
	var shooting_player: Dictionary = turret_build_state.source_turret_is_shooting_state(false, true, true, false, false, false)
	var shooting_no_player: Dictionary = turret_build_state.source_turret_is_shooting_state(false, false, true, false, false, false)
	proof["controlled_is_shooting_player_branch"] = bool(shooting_player.get("is_shooting", false)) == true and bool(shooting_no_player.get("is_shooting", true)) == false

	# The :503 warmup hold is skipped for a controlled turret:
	# with a positive warmup target (shooting and consuming),
	# a controlled turret keeps warmup_hold at 0, while the
	# same call uncontrolled sets the hold (1.0 minus one
	# tick of decay at warmupMaintainTime 1.0). Merge
	# 2026-11-23: the remote 11-arg source_turret_warmup_state
	# (dropped N2253) is rewired to the kept local N2308
	# source_turret_update_tile_warmup_state -- can_consume
	# true arrives as potential_efficiency 1.0, heat 0.0.
	var warmup_controlled: Dictionary = turret_build_state.source_turret_update_tile_warmup_state({}, true, 1.0, false, true, 0.0, 0.0, false, 0.1, 1.0, 1.0, 1.0 / 60.0, 0.0, 0.0)
	var warmup_uncontrolled: Dictionary = turret_build_state.source_turret_update_tile_warmup_state({}, true, 1.0, false, false, 0.0, 0.0, false, 0.1, 1.0, 1.0, 1.0 / 60.0, 0.0, 0.0)
	proof["controlled_warmup_hold_skipped"] = float(warmup_controlled.get("warmup_hold", -1.0)) == 0.0 and float(warmup_uncontrolled.get("warmup_hold", 0.0)) > 0.9

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretControlledStampProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
