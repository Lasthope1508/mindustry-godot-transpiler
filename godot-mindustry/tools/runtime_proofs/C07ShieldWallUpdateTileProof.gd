extends Node

const main_scene := preload("res://scenes/Main.tscn")
const shield_wall_build_state := preload("res://src/game/SourceShieldWallBuildState.gd")
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

	# --- Pure updateTile advance: the shield wall is a ShieldWall
	# build with a power consumer (shielded-wall, consumePower 3f /
	# 60f = 0.05, Blocks.java:1905); updateTile()
	# (ShieldWall.java:74-89) decays breakTimer by Time.delta
	# while broken, regens the shield by regenSpeed * edelta()
	# while whole, decays hit by Time.delta / 10f, and lerps
	# shieldRadius toward broken() ? 0f : 1f at 0.12 -- so the
	# proof calls the pure function
	# source_shield_wall_update_tile_state(frame, delta) directly
	# with synthetic frames and the tick's seconds as delta (the
	# N2190 driver convention). The frame keys are `shield`
	# (float, absent defaults to shieldHealth 900.0 -- the field
	# init, ShieldWall.java:44), `break_timer` (float, N2202
	# default 0.0), `hit` (float, N2203 default 0.0),
	# `shield_radius` (float, absent defaults to 0.0 -- the field
	# init, ShieldWall.java:44), `efficiency` (float, absent
	# defaults to 0.0 -- the transient field default, the N2192
	# charge precedent) and `potential_efficiency` (float, N2202
	# default 1.0). The regen branch is decided on the PRE-update
	# timer, broken() for the radius lerp is read AFTER the decay
	# (on the updated timer), and the timer is never clamped.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	proof["shield_wall_has_power_consumer"] = bool(blocks_by_id["shielded-wall"].properties.has("consumePower")) and is_equal_approx(float(blocks_by_id["shielded-wall"].properties.get("consumePower", -1.0)), 0.05)

	# Whole wall regens: shield 800 at full power, delta 1.0 --
	# shield = clamp(800 + 2.0 * 1.0 * 1.0, 0, 900) = 802.0, the
	# timer stays 0.0, hit stays 0.0, the radius lerps from 0.0
	# toward 1.0 by 0.12 (the port's canonical lerpDelta), and
	# broken is false (ShieldWall.java:80, 88, 92).
	var whole: Dictionary = shield_wall_build_state.source_shield_wall_update_tile_state({"shield": 800.0, "efficiency": 1.0, "potential_efficiency": 1.0}, 1.0)
	proof["shield_regens_when_whole"] = is_equal_approx(float(whole.get("shield", -1.0)), 802.0) and is_equal_approx(float(whole.get("break_timer", -1.0)), 0.0) and is_equal_approx(float(whole.get("hit", -1.0)), 0.0) and is_equal_approx(float(whole.get("shield_radius", -1.0)), 0.12) and whole.get("broken", true) == false

	# Broken wall does not regen: break_timer 300, shield 800,
	# radius 1.0, full power, delta 1.0 -- the timer decays to
	# 299.0, the shield stays 800.0 (the regen branch is skipped
	# while breakTimer > 0), broken stays true, and the radius
	# lerps from 1.0 toward 0.0 by 0.12 to 0.88
	# (ShieldWall.java:75-81, 88, 92).
	var broken: Dictionary = shield_wall_build_state.source_shield_wall_update_tile_state({"shield": 800.0, "break_timer": 300.0, "shield_radius": 1.0, "efficiency": 1.0, "potential_efficiency": 1.0}, 1.0)
	proof["broken_wall_does_not_regen"] = is_equal_approx(float(broken.get("shield", -1.0)), 800.0) and is_equal_approx(float(broken.get("break_timer", -1.0)), 299.0) and is_equal_approx(float(broken.get("shield_radius", -1.0)), 0.88) and broken.get("broken", false) == true

	# Hit decays to zero: hit 0.05, shield 800, full power, delta
	# 1.0 -- hit -= 1.0 / 10f = -0.05, floored at 0.0 by
	# Math.max(hit, 0f); the shield still regens to 802.0 and the
	# radius still lerps to 0.12 (ShieldWall.java:80, 83-86, 88).
	var hit_decay: Dictionary = shield_wall_build_state.source_shield_wall_update_tile_state({"shield": 800.0, "hit": 0.05, "efficiency": 1.0, "potential_efficiency": 1.0}, 1.0)
	proof["hit_decays_to_zero"] = is_equal_approx(float(hit_decay.get("hit", -1.0)), 0.0) and is_equal_approx(float(hit_decay.get("shield", -1.0)), 802.0) and is_equal_approx(float(hit_decay.get("shield_radius", -1.0)), 0.12)

	# Radius lerps toward whole: radius 0.0, whole wall, delta
	# 1.0 -- the radius lerps from 0.0 toward 1.0 by 0.12, and
	# the absent shield defaults to 900.0 and stays clamped at
	# 900.0 after regen (ShieldWall.java:80, 88).
	var radius: Dictionary = shield_wall_build_state.source_shield_wall_update_tile_state({"shield_radius": 0.0, "efficiency": 1.0, "potential_efficiency": 1.0}, 1.0)
	proof["radius_lerps_toward_whole"] = is_equal_approx(float(radius.get("shield_radius", -1.0)), 0.12) and is_equal_approx(float(radius.get("shield", -1.0)), 900.0) and radius.get("broken", true) == false

	# No-power wall neither regens nor holds its radius: shield
	# 800, radius 1.0, efficiency 0.0, potential_efficiency 0.0,
	# delta 1.0 -- edelta is 0 so the shield stays 800.0,
	# canConsume() is false so broken is true, and the radius
	# lerps from 1.0 toward 0.0 by 0.12 to 0.88 (the N2202 power
	# coupling, ShieldWall.java:92 with BuildingComp.java:1918).
	var no_power: Dictionary = shield_wall_build_state.source_shield_wall_update_tile_state({"shield": 800.0, "shield_radius": 1.0, "efficiency": 0.0, "potential_efficiency": 0.0}, 1.0)
	proof["no_power_wall_no_regen_radius_falls"] = is_equal_approx(float(no_power.get("shield", -1.0)), 800.0) and is_equal_approx(float(no_power.get("shield_radius", -1.0)), 0.88) and no_power.get("broken", false) == true

	# Timer crossing zero does not regen yet: break_timer 0.5,
	# shield 800, full power, delta 1.0 -- the timer decays to
	# -0.5 (Java never clamps it, ShieldWall.java:76), the regen
	# branch was decided on the PRE-update timer (0.5 > 0), so
	# the shield stays 800.0, but broken() reads the UPDATED
	# timer (-0.5, not > 0) with power, so broken is false and
	# the radius lerps from 0.0 toward 1.0 by 0.12
	# (ShieldWall.java:75-81, 88, 92). This pins the Java order:
	# decay first, regen branch on the old timer, broken on the
	# new one.
	var crossing: Dictionary = shield_wall_build_state.source_shield_wall_update_tile_state({"shield": 800.0, "break_timer": 0.5, "efficiency": 1.0, "potential_efficiency": 1.0}, 1.0)
	proof["break_timer_crosses_zero_no_regen"] = is_equal_approx(float(crossing.get("break_timer", -99.0)), -0.5) and is_equal_approx(float(crossing.get("shield", -1.0)), 800.0) and is_equal_approx(float(crossing.get("shield_radius", -1.0)), 0.12) and crossing.get("broken", true) == false

	# Absent shield defaults to full health: an empty frame,
	# delta 1.0 -- the shield defaults to shieldHealth 900.0
	# (ShieldWall.java:44), efficiency defaults to 0.0 so no
	# regen is added, the timer stays 0.0, hit stays 0.0, the
	# radius lerps from 0.0 toward 1.0 by 0.12, and broken is
	# false (potential_efficiency defaults to 1.0).
	var absent_shield: Dictionary = shield_wall_build_state.source_shield_wall_update_tile_state({}, 1.0)
	proof["shield_absent_defaults_full_health"] = is_equal_approx(float(absent_shield.get("shield", -1.0)), 900.0) and is_equal_approx(float(absent_shield.get("break_timer", -1.0)), 0.0) and is_equal_approx(float(absent_shield.get("hit", -1.0)), 0.0) and is_equal_approx(float(absent_shield.get("shield_radius", -1.0)), 0.12) and absent_shield.get("broken", true) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ShieldWallUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
