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

	# --- Drill icons() (N2335):
	# Drill.icons() (`@Override public
	# TextureRegion[] icons(){`,
	# Drill.java:194-195) returns the three loaded
	# regions in order (`return new
	# TextureRegion[]{region, rotatorRegion,
	# topRegion};`, Drill.java:195). region is the
	# inherited block region (`public TextureRegion
	# region;`, Block.java:427 -- the block's own
	# region, the block name); rotatorRegion is the
	# Drill field (`public @Load("@-rotator")
	# TextureRegion rotatorRegion;`, Drill.java:72,
	# loaded as name + "-rotator"); topRegion is the
	# Drill field (`public @Load("@-top") TextureRegion
	# topRegion;`, Drill.java:73, loaded as name +
	# "-top"). The Block.icons() base (`protected
	# TextureRegion[] icons(){`, Block.java:976-980,
	# the variants / teamRegion fold) and the
	# getGeneratedIcons cache (Block.java:986-988)
	# are deferred -- only the override's
	# three-element return array, region first, is
	# pinned (the N2312 BurstDrill.icons() precedent,
	# itself following the N2250 Radar.icons()
	# precedent: the identity pure function
	# source_tractor_beam_turret_icons_state). This
	# slice does NOT touch Turret.icons() (N1159),
	# Radar.icons() (N2288) or BurstDrill.icons()
	# (N2312) -- each class owns its own icons().
	# There is NO driver tick line: icons() is a
	# load-time region accessor, not a per-tick write
	# (the N2217 / N2224 lifecycle precedent). The
	# proof calls the pure function directly with the
	# per-def region ids (the N2224/N2225 pattern);
	# region ids ride as strings, as the N2312 proof
	# did with ["impact-drill", "impact-drill-top"].
	# Both defs share the function (impact-drill,
	# Blocks.java:3070; eruption-drill,
	# Blocks.java:3093); they differ only in the
	# region name the caller passes.

	# impact-drill ("impact-drill",
	# "impact-drill-rotator", "impact-drill-top"):
	# ["impact-drill", "impact-drill-rotator",
	# "impact-drill-top"].
	var icons_impact: Dictionary = burst_drill_build_state.source_drill_icons_state("impact-drill", "impact-drill-rotator", "impact-drill-top")
	var icons_impact_array: Array = icons_impact.get("icons", [])
	proof["icons_impact_drill"] = icons_impact_array == ["impact-drill", "impact-drill-rotator", "impact-drill-top"]

	# eruption-drill ("eruption-drill",
	# "eruption-drill-rotator", "eruption-drill-top"):
	# ["eruption-drill", "eruption-drill-rotator",
	# "eruption-drill-top"].
	var icons_eruption: Dictionary = burst_drill_build_state.source_drill_icons_state("eruption-drill", "eruption-drill-rotator", "eruption-drill-top")
	var icons_eruption_array: Array = icons_eruption.get("icons", [])
	proof["icons_eruption_drill"] = icons_eruption_array == ["eruption-drill", "eruption-drill-rotator", "eruption-drill-top"]

	# The override returns exactly three regions.
	proof["icons_length_three"] = icons_impact_array.size() == 3 and icons_eruption_array.size() == 3

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07DrillIconsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
