extends "res://src/game/SourcePortGameFactoryStatePortBridge.gd"

const source_rules_defaults := preload("res://src/game/SourceRulesDefaults.gd")
const source_game_over_core_destroyed_state_script := preload("res://src/game/SourceGameOverCoreDestroyedState.gd")
const source_core_damage_runtime_state := preload("res://src/game/SourceCoreDamageRuntimeState.gd")
const source_core_defaults := preload("res://src/game/SourceCoreDefaults.gd")

var core_inventory := 0
var core_items: Dictionary = {}
var core_item_capacity := 0
var rules_build_cost_multiplier := source_rules_defaults.BUILD_COST_MULTIPLIER_DEFAULT
var core_incinerates := source_core_defaults.RULES_CORE_INCINERATES_DEFAULT
var core_incinerate_non_buildable := source_core_defaults.INCINERATE_NON_BUILDABLE_DEFAULT
var core_max_health := 0.0
var core_health := 0.0
var core_damage_taken_total := 0.0
var game_over := false
var last_game_over_winner := ""
