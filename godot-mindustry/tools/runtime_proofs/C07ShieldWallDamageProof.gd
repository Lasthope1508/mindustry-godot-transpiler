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

	# --- Pure damage: the shield wall is a ShieldWall build with a
	# power consumer (shielded-wall, consumePower 3f / 60f = 0.05,
	# Blocks.java:1905); damage() is event-driven, not a tick, so
	# the proof calls the pure function
	# source_shield_wall_damage_state(frame, damage) directly with
	# synthetic frames instead of driving the tick. The damage()
	# coupling (N2203, ShieldWall.java:100-117, `float shieldTaken
	# = broken() ? 0f : Math.min(shield, damage);`) reads broken()
	# from the N2202 pure function over the frame keys `shield`
	# (float, absent defaults to shieldHealth 900.0 -- the field
	# init, ShieldWall.java:44), `hit` (float, absent defaults to
	# 0.0 -- the WallBuild field default, Wall.java:89),
	# `break_timer` (float, N2202 default 0.0) and
	# `potential_efficiency` (float, N2202 default 1.0): the
	# shield drops by the absorbed amount, hit flashes to 1.0
	# only when something was absorbed, a shield driven to zero
	# sets break_timer to breakCooldown (60f * 10f), and only the
	# leftover damage is the residual for super.damage
	# (BuildingComp.java:2059-2080).
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	proof["shield_wall_has_power_consumer"] = bool(blocks_by_id["shielded-wall"].properties.has("consumePower")) and is_equal_approx(float(blocks_by_id["shielded-wall"].properties.get("consumePower", -1.0)), 0.05)

	# Whole wall absorbs partial damage: shield 900 at full
	# power, incoming 100 -- shieldTaken is min(900, 100) = 100,
	# the shield drops to 800, hit flashes to 1.0, no break, no
	# residual (ShieldWall.java:102-114).
	var partial: Dictionary = shield_wall_build_state.source_shield_wall_damage_state({"shield": 900.0, "potential_efficiency": 1.0}, 100.0)
	proof["shield_absorbs_partial_damage"] = is_equal_approx(float(partial.get("shield_taken", -1.0)), 100.0) and is_equal_approx(float(partial.get("shield", -1.0)), 800.0) and is_equal_approx(float(partial.get("hit", -1.0)), 1.0) and is_equal_approx(float(partial.get("break_timer", -1.0)), 0.0) and is_equal_approx(float(partial.get("residual_damage", -1.0)), 0.0)

	# Shield caps the absorbed amount and breaks: shield 50 at
	# full power, incoming 100 -- shieldTaken is min(50, 100) =
	# 50, the shield drops to 0, hit flashes to 1.0, the shield
	# was destroyed so break_timer is breakCooldown (60f * 10f
	# = 600.0, ShieldWall.java:109-110), and the leftover 50 is
	# the residual for super.damage (ShieldWall.java:113-114).
	var capped: Dictionary = shield_wall_build_state.source_shield_wall_damage_state({"shield": 50.0, "potential_efficiency": 1.0}, 100.0)
	proof["shield_absorbs_capped_at_shield"] = is_equal_approx(float(capped.get("shield_taken", -1.0)), 50.0) and is_equal_approx(float(capped.get("shield", -1.0)), 0.0) and is_equal_approx(float(capped.get("hit", -1.0)), 1.0) and is_equal_approx(float(capped.get("break_timer", -1.0)), 600.0) and is_equal_approx(float(capped.get("residual_damage", -1.0)), 50.0)

	# Broken wall absorbs nothing: break_timer 300 at full
	# power, shield 900, incoming 100 -- broken() is true, so
	# shieldTaken is 0, the shield stays 900, hit stays 0, the
	# break timer is untouched at 300, and the full 100 is the
	# residual (ShieldWall.java:102, 113-114).
	var broken: Dictionary = shield_wall_build_state.source_shield_wall_damage_state({"shield": 900.0, "break_timer": 300.0, "potential_efficiency": 1.0}, 100.0)
	proof["broken_wall_absorbs_nothing"] = is_equal_approx(float(broken.get("shield_taken", -1.0)), 0.0) and is_equal_approx(float(broken.get("shield", -1.0)), 900.0) and is_equal_approx(float(broken.get("hit", -1.0)), 0.0) and is_equal_approx(float(broken.get("break_timer", -1.0)), 300.0) and is_equal_approx(float(broken.get("residual_damage", -1.0)), 100.0)

	# No-power wall absorbs nothing: shield 900 at zero power,
	# incoming 100 -- the machinery's potential_efficiency 0.0
	# makes canConsume() false, so broken() is true (the N2202
	# power coupling, ShieldWall.java:92 with
	# BuildingComp.java:1918), shieldTaken is 0, and the full
	# 100 is the residual.
	var no_power: Dictionary = shield_wall_build_state.source_shield_wall_damage_state({"shield": 900.0, "potential_efficiency": 0.0}, 100.0)
	proof["no_power_wall_absorbs_nothing"] = is_equal_approx(float(no_power.get("shield_taken", -1.0)), 0.0) and is_equal_approx(float(no_power.get("shield", -1.0)), 900.0) and is_equal_approx(float(no_power.get("residual_damage", -1.0)), 100.0)

	# Absent shield defaults to full health: an empty frame,
	# incoming 100 -- the pure function defaults the shield to
	# shieldHealth 900.0 (ShieldWall.java:44, `public float
	# shield = shieldHealth, shieldRadius = 0f;`), so
	# shieldTaken is 100, the shield drops to 800, hit flashes
	# to 1.0, and there is no residual. This pins the RED
	# absent-default decision: absent means "shield never
	# damaged yet", not "shield gone".
	var absent_shield: Dictionary = shield_wall_build_state.source_shield_wall_damage_state({}, 100.0)
	proof["shield_absent_defaults_full_health"] = is_equal_approx(float(absent_shield.get("shield_taken", -1.0)), 100.0) and is_equal_approx(float(absent_shield.get("shield", -1.0)), 800.0) and is_equal_approx(float(absent_shield.get("hit", -1.0)), 1.0) and is_equal_approx(float(absent_shield.get("residual_damage", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ShieldWallDamageProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
