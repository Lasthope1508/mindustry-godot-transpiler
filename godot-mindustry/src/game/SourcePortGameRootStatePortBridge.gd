extends "res://src/game/SourcePortGameBuildProjectorStatePortBridge.gd"

const source_puddles_deposit_state := preload("res://src/game/SourcePuddlesDepositState.gd")

func source_puddles_deposit_tile_liquid_state(tile: Variant, liquid: Variant, amount: float, existing_puddle: Variant = null, floor_solid: bool = false, net_client: bool = false, max_liquid: float = source_puddles_deposit_state.MAX_LIQUID_DEFAULT, context: Dictionary = {}) -> Dictionary:
	return source_puddles_deposit_state.deposit_tile_liquid_state(tile, liquid, amount, existing_puddle, floor_solid, net_client, max_liquid, context)

const source_content_registry_source_text_state := preload("res://src/game/SourceContentRegistrySourceTextState.gd")
const CONTENT_CATALOG_SCRIPT := source_content_registry_source_text_state.CONTENT_CATALOG_SCRIPT
const CONTENT_REGISTRY := source_content_registry_source_text_state.CONTENT_REGISTRY
const GENERATED_CLASS_REGISTRY := source_content_registry_source_text_state.GENERATED_CLASS_REGISTRY
var ContentRegistry := load(CONTENT_REGISTRY)
var generated_class_registry := load(GENERATED_CLASS_REGISTRY)
const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")
const source_world_viewport := preload("res://src/game/SourceWorldViewport.gd")
const source_input_defaults := preload("res://src/game/SourceInputDefaults.gd")
const source_ui_defaults := preload("res://src/game/SourceUiDefaults.gd")
const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
var content_catalog_script := load(CONTENT_CATALOG_SCRIPT)

var tile_size := 0
var config: Dictionary = {}
var textures: Dictionary = {}
var block_texture_cache: Dictionary = {}
var content_counts: Dictionary = {"items": 0, "liquids": 0, "blocks": 0, "units": 0}
var generated_class_count := 0
var loaded_generated_scripts: Dictionary = {}
var loaded_generated_class_names: Array[String] = []
var loaded_generated_instances: Dictionary = {}
var loaded_generated_instance_names: Array[String] = []
var all_generated_scripts: Dictionary = {}
var all_generated_instances: Dictionary = {}
var all_generated_load_failures: Array[String] = []
var all_generated_instance_failures: Array[String] = []
var content_catalog: RefCounted
var hud_label: Label
var campaign_shell_root: Control
var campaign_shell_visible := true
var campaign_shell_entered_playable := false
# Whether the game is paused (Java: GameState.state == State.paused,
# GameState.java:93-95 `isPaused()`; the state is set with
# GameState.set(State), GameState.java:60-62). Logic.update
# (Logic.java:507) skips the whole game update while paused; the live
# loop reads this flag at the top of every process_tick.
var paused := false
var campaign_selected_sector_id := ""
var campaign_launched_sector: Dictionary = {}
var campaign_launch_context: Dictionary = {}
var camera: Camera2D
# The live game rules (Java: Vars.state.rules, GameState.java:35
# `public Rules rules = new Rules()`). Created once per game with the
# Rules defaults; the drill tick and the unit factories' multiplier
# callbacks all read this same Dictionary, so mutations are live.
var rules_state: Dictionary = source_rules_state.source_game_rules_state({})["rules"]
var drill_pos := source_playable_scenario_defaults.DRILL_POS
var core_pos := source_playable_scenario_defaults.CORE_POS
var duo_pos := source_playable_scenario_defaults.DUO_POS
