extends Node

const main_scene := preload("res://scenes/Main.tscn")
const burst_drill_build_state := preload("res://src/game/SourceBurstDrillBuildState.gd")
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

	# --- BurstDrill icons() (N2312):
	# BurstDrill.icons() (`@Override public
	# TextureRegion[] icons(){`,
	# BurstDrill.java:48-49) returns the two loaded
	# regions in order (`return new
	# TextureRegion[]{region, topRegion};`,
	# BurstDrill.java:50). region is the inherited
	# block region (`public TextureRegion region;`,
	# Block.java:427 -- the block's own region, the
	# block name); topRegion is the Drill base field
	# (`public @Load("@-top") TextureRegion topRegion;`,
	# Drill.java:73, loaded as name + "-top"). The
	# Block.icons() base (`protected TextureRegion[]
	# icons(){`, Block.java:976-980, the variants /
	# teamRegion fold) and the getGeneratedIcons cache
	# (Block.java:986-988) are deferred -- only the
	# override's two-element return array, region
	# first, is pinned (the N2250 Radar.icons()
	# precedent, itself following the N2227
	# RepairTurret.icons() precedent: the identity
	# pure function
	# source_tractor_beam_turret_icons_state). There is
	# NO driver tick line: icons() is a load-time region
	# accessor, not a per-tick write (the N2217 / N2224
	# lifecycle precedent). The proof calls the pure
	# function directly with the per-def region ids (the
	# N2224/N2225 pattern); region ids ride as strings,
	# as the N2250 proof did with ["radar-base",
	# "radar"]. Both defs share the function
	# (impact-drill, Blocks.java:3070; eruption-drill,
	# Blocks.java:3093); they differ only in the region
	# name the caller passes.

	# impact-drill ("impact-drill",
	# "impact-drill-top"): ["impact-drill",
	# "impact-drill-top"].
	var icons_impact: Dictionary = burst_drill_build_state.source_burst_drill_icons_state("impact-drill", "impact-drill-top")
	var icons_impact_array: Array = icons_impact.get("icons", [])
	proof["icons_impact_drill"] = icons_impact_array == ["impact-drill", "impact-drill-top"]

	# eruption-drill ("eruption-drill",
	# "eruption-drill-top"): ["eruption-drill",
	# "eruption-drill-top"].
	var icons_eruption: Dictionary = burst_drill_build_state.source_burst_drill_icons_state("eruption-drill", "eruption-drill-top")
	var icons_eruption_array: Array = icons_eruption.get("icons", [])
	proof["icons_eruption_drill"] = icons_eruption_array == ["eruption-drill", "eruption-drill-top"]

	# The override returns exactly two regions.
	proof["icons_length_two"] = icons_impact_array.size() == 2 and icons_eruption_array.size() == 2

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BurstDrillIconsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
