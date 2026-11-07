extends RefCounted
class_name SourceCampaignBlockLayerRuntimeState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_campaign_map_tile_state := preload("res://src/game/SourceCampaignMapTileState.gd")

const SOURCE_SET_BLOCK_CENTER_ONLY := source_campaign_map_tile_state.SOURCE_SET_BLOCK_CENTER_ONLY
const SOURCE_BLOCK_CONSECUTIVES := source_campaign_map_tile_state.SOURCE_BLOCK_CONSECUTIVES
const KEY_BLOCK_PLACEMENTS := "block_placements"
const KEY_STATIC_BLOCK_BATCHES := "static_block_batches"
const KEY_DYNAMIC_BLOCK_PLACEMENTS := "dynamic_block_placements"
const KEY_KEY := "key"
const KEY_CELL := "cell"

static func campaign_block_layer_plan_state(campaign_map_tile_state: Dictionary) -> Dictionary:
	var static_block_batches := {}
	var dynamic_block_placements := []
	var dynamic_block_name_counts := {}
	var static_block_count := 0
	var dynamic_block_count := 0
	for block_placement in campaign_map_tile_state.get(KEY_BLOCK_PLACEMENTS, []):
		if not (block_placement is Dictionary):
			continue
		if bool(block_placement.get("had_entity", false)):
			dynamic_block_placements.append(block_placement)
			var dynamic_key := str(block_placement.get(KEY_KEY, ""))
			dynamic_block_name_counts[dynamic_key] = int(dynamic_block_name_counts.get(dynamic_key, 0)) + 1
			dynamic_block_count += 1
		else:
			_append_static_batch_cell(static_block_batches, block_placement)
			static_block_count += 1
	return {
		KEY_STATIC_BLOCK_BATCHES: _static_batch_array(static_block_batches),
		KEY_DYNAMIC_BLOCK_PLACEMENTS: dynamic_block_placements,
		"static_block_count": static_block_count,
		"dynamic_block_count": dynamic_block_count,
		"static_block_batch_count": static_block_batches.size(),
		"dynamic_block_name_counts": dynamic_block_name_counts,
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CAMPAIGN_BLOCK_LAYER_RUNTIME_STATE,
		"source": "mindustry.io.SaveVersion.readMap",
		"source_set_block_center_only": SOURCE_SET_BLOCK_CENTER_ONLY,
		"source_block_consecutives": SOURCE_BLOCK_CONSECUTIVES,
	}

static func _append_static_batch_cell(static_block_batches: Dictionary, block_placement: Dictionary) -> void:
	var key := str(block_placement.get(KEY_KEY, ""))
	if key == "":
		return
	if not static_block_batches.has(key):
		static_block_batches[key] = {KEY_KEY: key, "cells": []}
	var batch: Dictionary = static_block_batches[key]
	batch.get("cells", []).append(block_placement.get(KEY_CELL, {}))

static func _static_batch_array(static_block_batches: Dictionary) -> Array:
	var batches := []
	var keys := static_block_batches.keys()
	keys.sort()
	for key in keys:
		batches.append(static_block_batches.get(key, {}))
	return batches
