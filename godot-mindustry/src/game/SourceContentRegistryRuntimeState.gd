extends RefCounted
class_name SourceContentRegistryRuntimeState

const content_catalog_script := preload("res://src/mindustry/content/ContentCatalog.gd")
const ContentRegistry := preload("res://src/generated/MindustryContentRegistry.gd")
const generated_class_registry := preload("res://src/generated/GeneratedClassRegistry.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_playable_scenario_defaults := preload("res://src/game/SourcePlayableScenarioDefaults.gd")

static func load_content_registry(game: Object) -> void:
	var loaded_content_catalog = content_catalog_script.new()
	var content_counts: Dictionary = loaded_content_catalog.counts()
	game.set("content_catalog", loaded_content_catalog)
	game.set("content_counts", content_counts)
	game.set("generated_class_count", generated_class_registry.count())
	load_all_generated_scripts(game)
	load_selected_generated_scripts(game)
	if content_counts != ContentRegistry.counts():
		push_error("Generated registry counts do not match loaded content catalog")

static func load_all_generated_scripts(game: Object) -> void:
	var generated_state := source_generated_class_runtime.load_all_classes(generated_class_registry.all_classes())
	game.set("all_generated_scripts", generated_state.get("scripts", {}))
	game.set("all_generated_instances", generated_state.get("instances", {}))
	var all_generated_load_failures: Array = game.get("all_generated_load_failures")
	all_generated_load_failures.clear()
	all_generated_load_failures.assign(generated_state.get("load_failures", []))
	var all_generated_instance_failures: Array = game.get("all_generated_instance_failures")
	all_generated_instance_failures.clear()
	all_generated_instance_failures.assign(generated_state.get("instance_failures", []))

static func load_selected_generated_scripts(game: Object) -> void:
	var selected_state := source_generated_class_runtime.load_selected_classes(source_playable_scenario_defaults.selected_generated_class_names(), generated_class_registry.all_classes())
	game.set("loaded_generated_scripts", selected_state.get("scripts", {}))
	var loaded_generated_class_names: Array = game.get("loaded_generated_class_names")
	loaded_generated_class_names.clear()
	loaded_generated_class_names.assign(selected_state.get("class_names", []))
	game.set("loaded_generated_instances", selected_state.get("instances", {}))
	var loaded_generated_instance_names: Array = game.get("loaded_generated_instance_names")
	loaded_generated_instance_names.clear()
	loaded_generated_instance_names.assign(selected_state.get("instance_names", []))
	for java_name in selected_state.get("missing_classes", []):
		push_error("Generated class missing from registry: " + str(java_name))
	for java_name in selected_state.get("load_failures", []):
		push_error("Generated class script failed to load: " + str(java_name))
	for java_name in selected_state.get("instance_failures", []):
		push_error("Generated class script failed to instantiate: " + str(java_name))
