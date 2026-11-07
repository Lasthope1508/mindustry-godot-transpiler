extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_icon_state := preload("res://src/game/SourceBlockIconState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var team_regions := ["derelict-icon", "sharded-icon"]
	var make_icon_regions_bridge := game.generated_block_make_icon_regions_bridge_state()
	var icons_bridge := game.generated_block_icons_bridge_state("duo", 2, "duo-region", true, null, team_regions, 1)
	var get_regions_to_outline_bridge := game.generated_block_get_regions_to_outline_bridge_state(["duo-region"])
	var get_generated_icons_bridge := game.generated_block_get_generated_icons_bridge_state(null, ["duo1", "sharded-icon"])
	var reset_generated_icons_bridge := game.generated_block_reset_generated_icons_bridge_state(["cached-icon"])
	var variant_regions_bridge := game.generated_block_variant_regions_bridge_state(null, "full-icon")
	var create_icons_teams := [{"id": 0, "name": "alpha", "has_palette": true}]
	var create_icons_bridge := game.generated_block_create_icons_bridge_state({}, false, 2, 2, "center", "before", "duo", true, create_icons_teams, "team-region", ["default-team"], [], true, -1, 3, ["duo1", "sharded-icon"], [])
	var direct_source_facades_match: bool = \
		game.source_block_make_icon_regions_state() == source_block_icon_state.make_icon_regions_state() \
		and game.source_block_icons_state("duo", 2, "duo-region", true, null, team_regions, 1) == source_block_icon_state.icons_state("duo", 2, "duo-region", true, null, team_regions, 1) \
		and game.source_block_get_regions_to_outline_state(["duo-region"]) == source_block_icon_state.get_regions_to_outline_state(["duo-region"]) \
		and game.source_block_get_generated_icons_state(null, ["duo1", "sharded-icon"]) == source_block_icon_state.get_generated_icons_state(null, ["duo1", "sharded-icon"]) \
		and game.source_block_reset_generated_icons_state(["cached-icon"]) == source_block_icon_state.reset_generated_icons_state(["cached-icon"]) \
		and game.source_block_variant_regions_state(null, "full-icon") == source_block_icon_state.variant_regions_state(null, "full-icon")
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "BLOCK_ICON_MODULE_PROOF",
		"make_icon_regions_bridge": make_icon_regions_bridge,
		"icons_bridge": icons_bridge,
		"get_regions_to_outline_bridge": get_regions_to_outline_bridge,
		"get_generated_icons_bridge": get_generated_icons_bridge,
		"reset_generated_icons_bridge": reset_generated_icons_bridge,
		"variant_regions_bridge": variant_regions_bridge,
		"create_icons_bridge": create_icons_bridge,
		"direct_source_facades_match": direct_source_facades_match,
		"make_icon_regions_bridge_matches": make_icon_regions_bridge == source_block_icon_state.generated_block_make_icon_regions_bridge_state(),
		"icons_bridge_matches": icons_bridge == source_block_icon_state.generated_block_icons_bridge_state("duo", 2, "duo-region", true, null, team_regions, 1),
		"get_regions_to_outline_bridge_matches": get_regions_to_outline_bridge == source_block_icon_state.generated_block_get_regions_to_outline_bridge_state(["duo-region"]),
		"get_generated_icons_bridge_matches": get_generated_icons_bridge == source_block_icon_state.generated_block_get_generated_icons_bridge_state(null, ["duo1", "sharded-icon"]),
		"reset_generated_icons_bridge_matches": reset_generated_icons_bridge == source_block_icon_state.generated_block_reset_generated_icons_bridge_state(["cached-icon"]),
		"variant_regions_bridge_matches": variant_regions_bridge == source_block_icon_state.generated_block_variant_regions_bridge_state(null, "full-icon"),
		"create_icons_bridge_matches": create_icons_bridge == source_block_icon_state.generated_block_create_icons_bridge_state({}, false, 2, 2, "center", "before", "duo", true, create_icons_teams, "team-region", ["default-team"], [], true, -1, 3, ["duo1", "sharded-icon"], []),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = bool(make_icon_regions_bridge.get("matches", false)) \
		and bool(icons_bridge.get("matches", false)) \
		and bool(get_regions_to_outline_bridge.get("matches", false)) \
		and bool(get_generated_icons_bridge.get("matches", false)) \
		and bool(reset_generated_icons_bridge.get("matches", false)) \
		and bool(variant_regions_bridge.get("matches", false)) \
		and bool(create_icons_bridge.get("matches", false)) \
		and proof["make_icon_regions_bridge_matches"] \
		and proof["icons_bridge_matches"] \
		and proof["get_regions_to_outline_bridge_matches"] \
		and proof["get_generated_icons_bridge_matches"] \
		and proof["reset_generated_icons_bridge_matches"] \
		and proof["variant_regions_bridge_matches"] \
		and proof["create_icons_bridge_matches"] \
		and proof["direct_source_facades_match"] \
		and proof["registry_valid"] \
		and proof["one_headquarter_per_ssot"]
	print("BLOCK_ICON_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BlockIconModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
