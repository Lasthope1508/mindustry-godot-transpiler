extends Node

const source_playable_content_defaults := preload("res://src/game/SourcePlayableContentDefaults.gd")
const source_playable_scenario_defaults := preload("res://src/game/SourcePlayableScenarioDefaults.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _has_unique_strings(values: Array[String]) -> bool:
	var seen := {}
	for value in values:
		if seen.has(value):
			return false
		seen[value] = true
	return true

func _ready() -> void:
	var expected_content_ids := {
		"ITEM_COPPER": "copper",
		"BLOCK_STONE_FLOOR": "stone_floor",
		"BLOCK_ORE_COPPER": "ore_copper",
		"BLOCK_MECHANICAL_DRILL": "mechanical-drill",
		"BLOCK_CONVEYOR": "conveyor",
		"BLOCK_ROUTER": "router",
		"BLOCK_JUNCTION": "junction",
		"BLOCK_CORE_SHARD": "core-shard",
		"BLOCK_DUO": "duo",
		"BLOCK_COPPER_WALL": "copper-wall",
	}
	var content_ids := {
		"ITEM_COPPER": source_playable_content_defaults.ITEM_COPPER,
		"BLOCK_STONE_FLOOR": source_playable_content_defaults.BLOCK_STONE_FLOOR,
		"BLOCK_ORE_COPPER": source_playable_content_defaults.BLOCK_ORE_COPPER,
		"BLOCK_MECHANICAL_DRILL": source_playable_content_defaults.BLOCK_MECHANICAL_DRILL,
		"BLOCK_CONVEYOR": source_playable_content_defaults.BLOCK_CONVEYOR,
		"BLOCK_ROUTER": source_playable_content_defaults.BLOCK_ROUTER,
		"BLOCK_JUNCTION": source_playable_content_defaults.BLOCK_JUNCTION,
		"BLOCK_CORE_SHARD": source_playable_content_defaults.BLOCK_CORE_SHARD,
		"BLOCK_DUO": source_playable_content_defaults.BLOCK_DUO,
		"BLOCK_COPPER_WALL": source_playable_content_defaults.BLOCK_COPPER_WALL,
	}
	var scenario_content_ids := {
		"ITEM_COPPER": source_playable_scenario_defaults.ITEM_COPPER,
		"BLOCK_STONE_FLOOR": source_playable_scenario_defaults.BLOCK_STONE_FLOOR,
		"BLOCK_ORE_COPPER": source_playable_scenario_defaults.BLOCK_ORE_COPPER,
		"BLOCK_MECHANICAL_DRILL": source_playable_scenario_defaults.BLOCK_MECHANICAL_DRILL,
		"BLOCK_CONVEYOR": source_playable_scenario_defaults.BLOCK_CONVEYOR,
		"BLOCK_ROUTER": source_playable_scenario_defaults.BLOCK_ROUTER,
		"BLOCK_JUNCTION": source_playable_scenario_defaults.BLOCK_JUNCTION,
		"BLOCK_CORE_SHARD": source_playable_scenario_defaults.BLOCK_CORE_SHARD,
		"BLOCK_DUO": source_playable_scenario_defaults.BLOCK_DUO,
		"BLOCK_COPPER_WALL": source_playable_scenario_defaults.BLOCK_COPPER_WALL,
	}
	var expected_selected_classes: Array[String] = ["Items", "Blocks", "UnitTypes", "Damage"]
	var selected_classes := source_playable_content_defaults.selected_generated_class_names()
	var scenario_selected_classes := source_playable_scenario_defaults.selected_generated_class_names()
	var expected_pinned_blocks: Array[String] = [
		source_playable_content_defaults.BLOCK_CONVEYOR,
		source_playable_content_defaults.BLOCK_ROUTER,
		source_playable_content_defaults.BLOCK_JUNCTION,
		source_playable_content_defaults.BLOCK_MECHANICAL_DRILL,
		source_playable_content_defaults.BLOCK_DUO,
		source_playable_content_defaults.BLOCK_COPPER_WALL,
	]
	var pinned_blocks := source_playable_content_defaults.pinned_build_block_ids()
	var scenario_pinned_blocks := source_playable_scenario_defaults.pinned_build_block_ids()
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourcePlayableContentDefaults",
		"content_ids_match": content_ids == expected_content_ids,
		"scenario_aliases_match": scenario_content_ids == content_ids,
		"selected_classes_match": selected_classes == expected_selected_classes and scenario_selected_classes == selected_classes,
		"pinned_blocks_match": pinned_blocks == expected_pinned_blocks and scenario_pinned_blocks == pinned_blocks,
		"selected_classes_unique": _has_unique_strings(selected_classes),
		"pinned_blocks_unique": _has_unique_strings(pinned_blocks),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["matches"] = proof["content_ids_match"] and proof["scenario_aliases_match"] and proof["selected_classes_match"] and proof["pinned_blocks_match"] and proof["selected_classes_unique"] and proof["pinned_blocks_unique"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("PLAYABLE_CONTENT_DEFAULTS_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/PlayableContentDefaultsModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
