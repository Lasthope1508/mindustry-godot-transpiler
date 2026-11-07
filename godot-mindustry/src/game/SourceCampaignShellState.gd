extends RefCounted
class_name SourceCampaignShellState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

const SOURCE_BUNDLE_PATH := "res://assets/core/assets/bundles/bundle.properties"
const SOURCE_SERPULO_PLANET_SPRITE := "res://assets/core/assets/sprites/planets/serpulo.png"
const SOURCE_EREKIR_PLANET_SPRITE := "res://assets/core/assets/sprites/planets/erekir.png"
const SOURCE_SERPULO_MAP_ROOT := "res://assets/core/assets/maps/serpulo"
const KEY_PLANET_MAP := "planetmap"
const KEY_LAUNCH_CORE := "launchcore"
const KEY_CAMPAIGN_SELECT := "campaign.select"
const KEY_CAMPAIGN_SERPULO := "campaign.serpulo"
const KEY_CAMPAIGN_EREKIR := "campaign.erekir"

static func campaign_shell_state_from_bundle() -> Dictionary:
	return campaign_shell_state(FileAccess.get_file_as_string(SOURCE_BUNDLE_PATH))

static func campaign_shell_state(bundle_text: String) -> Dictionary:
	var bundle_state := bundle_text_state(bundle_text)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CAMPAIGN_SHELL_STATE,
		"bundle_path": SOURCE_BUNDLE_PATH,
		"title": str(bundle_state.get(KEY_CAMPAIGN_SELECT, "")),
		"planet_map_label": str(bundle_state.get(KEY_PLANET_MAP, "")),
		"launch_core_label": str(bundle_state.get(KEY_LAUNCH_CORE, "")),
		"selected_planet_id": "serpulo",
		"planets": planet_choices_state(bundle_state),
	}

static func bundle_text_state(bundle_text: String) -> Dictionary:
	var values := {}
	for raw_line in bundle_text.split("\n"):
		var line := raw_line.strip_edges()
		if line.is_empty() or line.begins_with("#") or not line.contains("="):
			continue
		var parts := line.split("=", true, 1)
		var key := str(parts[0]).strip_edges()
		var value := str(parts[1]).strip_edges().replace("\\n", "\n")
		values[key] = value
	return values

static func planet_choices_state(bundle_state: Dictionary) -> Array:
	return [
		{
			"id": "serpulo",
			"display_name": "Serpulo",
			"description": str(bundle_state.get(KEY_CAMPAIGN_SERPULO, "")),
			"planet_sprite": SOURCE_SERPULO_PLANET_SPRITE,
			"map_root": SOURCE_SERPULO_MAP_ROOT,
			"classic_campaign": true,
		},
		{
			"id": "erekir",
			"display_name": "Erekir",
			"description": str(bundle_state.get(KEY_CAMPAIGN_EREKIR, "")),
			"planet_sprite": SOURCE_EREKIR_PLANET_SPRITE,
			"map_root": "",
			"classic_campaign": false,
		},
	]
