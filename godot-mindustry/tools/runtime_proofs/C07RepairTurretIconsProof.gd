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

	# --- RepairTurret icons() (N2227):
	# RepairTurret.icons() (`@Override public
	# TextureRegion[] icons(){`,
	# RepairTurret.java:101-102) returns the two loaded
	# regions in order (`return new
	# TextureRegion[]{baseRegion, region};`,
	# RepairTurret.java:103). baseRegion is the block's
	# own base field (`public @Load(value = "@-base",
	# fallback = "block-@size") TextureRegion baseRegion;`,
	# RepairTurret.java:47, loaded as name + "-base");
	# region is the inherited block region (`public
	# TextureRegion region;`, Block.java:427 -- the
	# block's own region, the block name). The
	# Block.icons() base (`protected TextureRegion[]
	# icons(){`, Block.java:976-980, the variants /
	# teamRegion fold) and the getGeneratedIcons cache
	# (Block.java:986-988) are deferred -- only the
	# override's two-element return array, base first,
	# is pinned (the N1232 TractorBeamTurret.icons()
	# precedent: the identity pure function
	# source_tractor_beam_turret_icons_state). There is
	# NO driver tick line: icons() is a load-time region
	# accessor, not a per-tick write (the N2217 / N2224
	# lifecycle precedent). The proof calls the pure
	# function directly with the per-def region ids (the
	# N2224/N2225 pattern); region ids ride as strings,
	# as the N1232 proof did with
	# ["tractor-base", "tractor-top"].

	# Repair-point ("repair-point", Blocks.java:6386):
	# ["repair-point-base", "repair-point"].
	var icons_point: Dictionary = repair_turret_build_state.source_repair_turret_icons_state("repair-point-base", "repair-point")
	var icons_point_array: Array = icons_point.get("icons", [])
	proof["icons_repair_point"] = icons_point_array == ["repair-point-base", "repair-point"]

	# Repair-turret ("repair-turret", Blocks.java:6396):
	# ["repair-turret-base", "repair-turret"].
	var icons_turret: Dictionary = repair_turret_build_state.source_repair_turret_icons_state("repair-turret-base", "repair-turret")
	var icons_turret_array: Array = icons_turret.get("icons", [])
	proof["icons_repair_turret"] = icons_turret_array == ["repair-turret-base", "repair-turret"]

	# The override returns exactly two regions.
	proof["icons_length_two"] = icons_point_array.size() == 2 and icons_turret_array.size() == 2

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTurretIconsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
