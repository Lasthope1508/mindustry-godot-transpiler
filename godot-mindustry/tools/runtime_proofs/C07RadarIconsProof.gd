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

	# --- Radar icons() (N2250):
	# Radar.icons() (`@Override public
	# TextureRegion[] icons(){`,
	# Radar.java:36-37) returns the two loaded
	# regions in order (`return new
	# TextureRegion[]{baseRegion, region};`,
	# Radar.java:38). baseRegion is the block's
	# own base field (`public @Load("@-base")
	# TextureRegion baseRegion;`,
	# Radar.java:21, loaded as name + "-base");
	# region is the inherited block region (`public
	# TextureRegion region;`, Block.java:427 -- the
	# block's own region, the block name). The
	# Block.icons() base (`protected TextureRegion[]
	# icons(){`, Block.java:976-980, the variants /
	# teamRegion fold) and the getGeneratedIcons cache
	# (Block.java:986-988) are deferred -- only the
	# override's two-element return array, base first,
	# is pinned (the N2227 RepairTurret.icons()
	# precedent, itself following the N1232
	# TractorBeamTurret.icons() precedent: the identity
	# pure function
	# source_tractor_beam_turret_icons_state). There is
	# NO driver tick line: icons() is a load-time region
	# accessor, not a per-tick write (the N2217 / N2224
	# lifecycle precedent). The proof calls the pure
	# function directly with the per-def region ids (the
	# N2224/N2225 pattern); region ids ride as strings,
	# as the N2227 proof did with
	# ["repair-point-base", "repair-point"].

	# Radar ("radar", Blocks.java:1988):
	# ["radar-base", "radar"].
	var icons_radar: Dictionary = radar_build_state.source_radar_icons_state("radar-base", "radar")
	var icons_radar_array: Array = icons_radar.get("icons", [])
	proof["icons_radar"] = icons_radar_array == ["radar-base", "radar"]

	# The override returns exactly two regions.
	proof["icons_length_two"] = icons_radar_array.size() == 2

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RadarIconsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
