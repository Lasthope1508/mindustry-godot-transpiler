extends Node

const ContentRegistry := preload("res://src/generated/MindustryContentRegistry.gd")
const port_game := preload("res://src/game/PortGame.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := port_game.new()
	game.load_content_registry()
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceContentRegistryRuntimeState",
		"content_catalog_loaded": game.content_catalog != null,
		"content_counts_match": game.content_counts == ContentRegistry.counts(),
		"generated_class_count": game.generated_class_count,
		"all_generated_script_count": game.all_generated_scripts.size(),
		"selected_generated_script_count": game.loaded_generated_scripts.size(),
		"selected_generated_instance_count": game.loaded_generated_instances.size(),
		"load_failures": game.all_generated_load_failures.size(),
		"instance_failures": game.all_generated_instance_failures.size(),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	print("CONTENT_REGISTRY_RUNTIME_MODULE_PROOF " + JSON.stringify(proof))
	await get_tree().create_timer(20.0).timeout
