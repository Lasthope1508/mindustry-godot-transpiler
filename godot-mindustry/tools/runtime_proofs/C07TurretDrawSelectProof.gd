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

	# --- Pure drawSelect() row (N2334): TurretBuild.drawSelect()
	# (Turret.java:481-488) calls super.drawSelect() (the base
	# BuildingComp.drawSelect(), live as N573 -- NOT re-ported
	# here) then, when the def field drawMinRange is true, draws
	# one dash circle around the building: `Drawf.dashCircle(x,
	# y, minRange(), team.color);` (Turret.java:485). The center
	# is the building world position, the radius is the LIVE
	# minRange() value (N2340 -- the caller passes it in, the
	# field `minRange` is 0f by default, Turret.java:74,
	# "Minimum bullet range. Used for artillery only."), the
	# color is the building team color (passed as a String, the
	# SourceBuildingDrawState draw_team precedent). The proof
	# calls the pure function
	# source_turret_draw_select_state(x, y, draw_min_range,
	# min_range, team_color) directly with synthetic positions
	# and live minRange values; there is no driver-tick key:
	# drawSelect() is selection UI, not tick state. Float
	# comparisons use is_equal_approx (the N2310 write/read
	# precedent for inexact float32 values).

	# drawMinRange true draws the circle with the live radius:
	# minRange 120.0 reads radius 120.0.
	var drawn: Dictionary = turret_build_state.source_turret_draw_select_state(100.0, 200.0, true, 120.0, "ffd37f")
	proof["draw_select_circle_drawn"] = bool(drawn.get("draw_min_range_circle", false)) and is_equal_approx(float(drawn.get("radius", -1.0)), 120.0)

	# drawMinRange false draws no circle: the flag reads false
	# and the radius reads 0.0.
	var hidden: Dictionary = turret_build_state.source_turret_draw_select_state(100.0, 200.0, false, 120.0, "ffd37f")
	proof["draw_select_circle_hidden"] = not bool(hidden.get("draw_min_range_circle", true)) and is_equal_approx(float(hidden.get("radius", -1.0)), 0.0)

	# A live minRange reads its own value: 45.5 stays 45.5.
	var live: Dictionary = turret_build_state.source_turret_draw_select_state(100.0, 200.0, true, 45.5, "ffd37f")
	proof["draw_select_radius_live"] = is_equal_approx(float(live.get("radius", -1.0)), 45.5)

	# A zero live minRange draws a zero-radius circle (the
	# circle is still drawn -- the flag is true).
	var zero: Dictionary = turret_build_state.source_turret_draw_select_state(100.0, 200.0, true, 0.0, "ffd37f")
	proof["draw_select_radius_zero_min_range"] = bool(zero.get("draw_min_range_circle", false)) and is_equal_approx(float(zero.get("radius", -1.0)), 0.0)

	# The circle is centered on the building position.
	var centered: Dictionary = turret_build_state.source_turret_draw_select_state(100.0, 200.0, true, 120.0, "ffd37f")
	proof["draw_select_center"] = Vector2(centered.get("center", Vector2(-1.0, -1.0))) == Vector2(100.0, 200.0)

	# The circle color is the building team color.
	var colored: Dictionary = turret_build_state.source_turret_draw_select_state(100.0, 200.0, true, 120.0, "f25555")
	proof["draw_select_color_team"] = str(colored.get("color", "")) == "f25555"

	# An artillery minRange reads its own value: 250.0 stays
	# 250.0 (minRange is "Used for artillery only.",
	# Turret.java:73).
	var artillery: Dictionary = turret_build_state.source_turret_draw_select_state(100.0, 200.0, true, 250.0, "ffd37f")
	proof["draw_select_radius_artillery"] = is_equal_approx(float(artillery.get("radius", -1.0)), 250.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretDrawSelectProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
