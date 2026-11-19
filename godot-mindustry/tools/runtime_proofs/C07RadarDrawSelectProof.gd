extends Node

const main_scene := preload("res://scenes/Main.tscn")
const radar_build_state := preload("res://src/game/SourceRadarBuildState.gd")
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

	# --- Pure drawSelect() row (N2281): RadarBuild.drawSelect()
	# (Radar.java:80-82) draws one dash circle around the
	# building: `Drawf.dashCircle(x, y, fogRadius() *
	# tilesize, Pal.accent);` (Radar.java:81). The center is
	# the building world position, the radius is the LIVE fog
	# radius (fogRadius(), Radar.java:55-57, `return fogRadius
	# * progress * smoothEfficiency;`) times tilesize (8,
	# Vars.java:135), the color is Pal.accent. The def values
	# are fogRadius 34 (Blocks.java:1991), class default 10
	# (Radar.java:33). The proof calls the pure function
	# source_radar_draw_select_state(x, y, fog_radius,
	# tilesize) directly with synthetic positions and live fog
	# radii; the caller supplies the N2275 fogRadius() result
	# and the tilesize. There are no driver-tick keys:
	# drawSelect() is selection UI, not tick state. Float
	# comparisons use is_equal_approx (the N2310 write/read
	# precedent for inexact float32 values).

	# Full discovery reads the full def radius in world units:
	# 34.0 * 8.0 = 272.0.
	var full: Dictionary = radar_build_state.source_radar_draw_select_state(100.0, 200.0, 34.0, 8.0)
	proof["draw_select_radius_full_discovery"] = is_equal_approx(float(full.get("radius", -1.0)), 272.0)

	# Half discovery reads half the def radius: 17.0 * 8.0 =
	# 136.0.
	var half: Dictionary = radar_build_state.source_radar_draw_select_state(100.0, 200.0, 17.0, 8.0)
	proof["draw_select_radius_half_progress"] = is_equal_approx(float(half.get("radius", -1.0)), 136.0)

	# Before discovery the live fog radius is 0.0, so the
	# circle has zero radius.
	var zero: Dictionary = radar_build_state.source_radar_draw_select_state(100.0, 200.0, 0.0, 8.0)
	proof["draw_select_radius_zero_fog"] = is_equal_approx(float(zero.get("radius", -1.0)), 0.0)

	# Tilesize 1.0 reads the raw fog radius: 34.0 * 1.0 = 34.0
	# -- the tilesize is a real factor, not hardcoded to 8.
	var unit: Dictionary = radar_build_state.source_radar_draw_select_state(100.0, 200.0, 34.0, 1.0)
	proof["draw_select_radius_tilesize_one"] = is_equal_approx(float(unit.get("radius", -1.0)), 34.0)

	# A partial live radius reads its own product: 10.0 * 8.0
	# = 80.0.
	var partial: Dictionary = radar_build_state.source_radar_draw_select_state(100.0, 200.0, 10.0, 8.0)
	proof["draw_select_radius_partial"] = is_equal_approx(float(partial.get("radius", -1.0)), 80.0)

	# The circle is centered on the building position.
	var centered: Dictionary = radar_build_state.source_radar_draw_select_state(100.0, 200.0, 34.0, 8.0)
	proof["draw_select_center"] = Vector2(centered.get("center", Vector2(-1.0, -1.0))) == Vector2(100.0, 200.0)

	# The circle color is Pal.accent.
	var colored: Dictionary = radar_build_state.source_radar_draw_select_state(100.0, 200.0, 34.0, 8.0)
	proof["draw_select_color_accent"] = str(colored.get("color", "")) == "Pal.accent"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RadarDrawSelectProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
