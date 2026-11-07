extends RefCounted
class_name SourceCampaignTerrainLayerRuntimeState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

const KEY_KEY := "key"
const KEY_CELL := "cell"
const KEY_TERRAIN_SPRITES := "terrain_sprites"
const KEY_ORE_SPRITES := "ore_sprites"

static func campaign_terrain_layer_plan_state(terrain_state: Dictionary) -> Dictionary:
	var terrain_batches := {}
	var ore_batches := {}
	for terrain_sprite in terrain_state.get(KEY_TERRAIN_SPRITES, []):
		if terrain_sprite is Dictionary:
			_append_batch_cell(terrain_batches, terrain_sprite)
	for ore_sprite in terrain_state.get(KEY_ORE_SPRITES, []):
		if ore_sprite is Dictionary:
			_append_batch_cell(ore_batches, ore_sprite)
	return {
		"terrain_batches": _batch_array(terrain_batches),
		"ore_batches": _batch_array(ore_batches),
		"terrain_batch_count": terrain_batches.size(),
		"ore_batch_count": ore_batches.size(),
		"terrain_render_node_count": terrain_batches.size() + ore_batches.size(),
		"terrain_count": int(terrain_state.get("terrain_count", 0)),
		"ore_count": int(terrain_state.get("ore_count", 0)),
		"world_cell_count": int(terrain_state.get("world_cell_count", 0)),
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CAMPAIGN_TERRAIN_LAYER_RUNTIME_STATE,
		"source": "mindustry.io.SaveVersion.readMap",
	}

static func _append_batch_cell(batches: Dictionary, sprite_state: Dictionary) -> void:
	var key := str(sprite_state.get(KEY_KEY, ""))
	if key == "":
		return
	if not batches.has(key):
		batches[key] = {KEY_KEY: key, "cells": []}
	var batch: Dictionary = batches[key]
	batch.get("cells", []).append(sprite_state.get(KEY_CELL, {}))

static func _batch_array(batches: Dictionary) -> Array:
	var result := []
	var keys := batches.keys()
	keys.sort()
	for key in keys:
		result.append(batches.get(key, {}))
	return result
