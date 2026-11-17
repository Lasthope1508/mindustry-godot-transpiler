extends Node

const main_scene := preload("res://scenes/Main.tscn")
const repair_turret_build_state := preload("res://src/game/SourceRepairTurretBuildState.gd")
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

	# --- RepairTurret bind stamps block_id (N2236):
	# Placement creates the Building (`public final Building
	# newBuilding(){`, Block.java:1002); the port's frame is
	# that Building state, bound on the sprite at placement.
	# The bind stamps `frame["block_id"] = str(block.id)`,
	# the catalog id string -- repair-point
	# (`repairPoint = new RepairTurret("repair-point"){{`,
	# Blocks.java:6386) and repair-turret (`repairTurret =
	# new RepairTurret("repair-turret"){{`, Blocks.java:6397)
	# -- so the N2235 ambient-sound loop resolves the per-def
	# volume (0.9f / 1.25f, Blocks.java:6393 / :6408) from a
	# live frame through `control.sound.loop(block.
	# ambientSound, self(), block.ambientSoundVolume *
	# ambientVolume());` (BuildingComp.java:2271). No new pure
	# function, no signature change, no driver edit: the
	# driver already calls bind and the stamp rides that call;
	# the already-bound branch returns the frame stamped at
	# its first bind.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	# Bind repair-point: the frame carries "repair-point".
	var sprite_point := Sprite2D.new()
	game.add_child(sprite_point)
	var bound_point: Dictionary = repair_turret_build_state.source_repair_turret_bind_frame_state(sprite_point, blocks_by_id["repair-point"])
	var frame_point: Dictionary = bound_point.get("frame", {})
	proof["bind_frame_repair_point_block_id"] = bool(bound_point.get("applied", false)) and str(frame_point.get("block_id", "")) == "repair-point"

	# Bind repair-turret: the frame carries "repair-turret".
	var sprite_turret := Sprite2D.new()
	game.add_child(sprite_turret)
	var bound_turret: Dictionary = repair_turret_build_state.source_repair_turret_bind_frame_state(sprite_turret, blocks_by_id["repair-turret"])
	var frame_turret: Dictionary = bound_turret.get("frame", {})
	proof["bind_frame_repair_turret_block_id"] = bool(bound_turret.get("applied", false)) and str(frame_turret.get("block_id", "")) == "repair-turret"

	# A second bind keeps the first frame (with its stamp).
	var rebound_point: Dictionary = repair_turret_build_state.source_repair_turret_bind_frame_state(sprite_point, blocks_by_id["repair-point"])
	var reframe_point: Dictionary = rebound_point.get("frame", {})
	proof["bind_already_bound_keeps_block_id"] = bool(rebound_point.get("applied", true)) == false and str(reframe_point.get("block_id", "")) == "repair-point"

	# A non-RepairTurret block binds nothing.
	var other_block = null
	for registered_block in catalog.get_many("block"):
		if str(registered_block.id) != "repair-point" and str(registered_block.id) != "repair-turret":
			other_block = registered_block
			break
	var sprite_other := Sprite2D.new()
	game.add_child(sprite_other)
	var bound_other: Dictionary = repair_turret_build_state.source_repair_turret_bind_frame_state(sprite_other, other_block)
	proof["bind_non_repair_turret_applied_false"] = bool(bound_other.get("applied", true)) == false and Dictionary(bound_other.get("frame", {})).is_empty()

	# Loop volume off a bound repair-point frame is 0.9.
	frame_point["has_target"] = true
	frame_point["efficiency"] = 1.0
	var loop_point: Dictionary = repair_turret_build_state.source_repair_turret_ambient_sound_loop_state(frame_point, false)
	proof["loop_volume_repair_point_bound"] = bool(loop_point.get("should_loop", false)) and absf(float(loop_point.get("volume", -1.0)) - 0.9) < 0.001

	# Loop volume off a bound repair-turret frame at half
	# efficiency is 0.625.
	frame_turret["has_target"] = true
	frame_turret["efficiency"] = 0.5
	var loop_turret: Dictionary = repair_turret_build_state.source_repair_turret_ambient_sound_loop_state(frame_turret, false)
	proof["loop_volume_repair_turret_bound"] = bool(loop_turret.get("should_loop", false)) and absf(float(loop_turret.get("volume", -1.0)) - 0.625) < 0.001

	# Driver tick: a live-placed repair-turret gets its frame
	# bound by the driver, and the frame carries block_id.
	var live_cell := Vector2i(28, 22)
	var live_sprite := Sprite2D.new()
	game.add_child(live_sprite)
	game.call("record_placed_block", live_sprite, blocks_by_id["repair-turret"], live_cell)
	repair_turret_build_state.source_repair_turret_tick_buildings_state(game, 1.0 / 60.0)
	var live_frame: Dictionary = live_sprite.get_meta(repair_turret_build_state.SOURCE_REPAIR_TURRET_BUILDING_META_KEY, {})
	proof["driver_tick_stamps_block_id"] = str(live_frame.get("block_id", "")) == "repair-turret"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTurretBindBlockIdProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
