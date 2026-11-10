extends RefCounted
class_name SourceUnitFactoryBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerUnitBuildingRegistry.gd")

# Every block whose build is a unit-factory build: the three classes
# that set each consumer's multiplier to Rules.unitCost
# (UnitFactory.java:109, Reconstructor.java:149,
# UnitAssembler.java:175). Their builds run updateTile() every tick
# (UnitFactoryBuild.updateTile(), UnitFactory.java:392;
# ReconstructorBuild.updateTile(), Reconstructor.java:317;
# UnitAssemblerBuild.updateTile(), UnitAssembler.java:429), and each
# of them runs updateConsumption() through the Building update, so
# the live cheating value decides whether the factory consumes.
const SOURCE_UNIT_FACTORY_BUILD_IMPLEMENTATIONS := ["UnitFactory", "Reconstructor", "UnitAssembler"]
const SOURCE_UNIT_FACTORY_BUILDING_META_KEY := "source_unit_factory_building"

static func _is_unit_factory_build_implementation(implementation: String) -> bool:
	return SOURCE_UNIT_FACTORY_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_unit_factory_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The factory tick wires the frame keys the consumption path
	# reads (the N2108 turret pattern): block_implementation is the
	# block's implementation, team_id and rules_state are what Java
	# reads as b.team and state.rules, and cheating is the team's
	# live TeamRule value (TeamComp.cheating(), TeamComp.java:17-19
	# `return team.rules().cheat;`, read through N2099's helper), so
	# a cheating team's factory skips consumption like Java's
	# updateConsumption (BuildingComp.java:1944-1945, "everything is
	# valid when cheating"). A team with no rule keeps the false
	# default (Rules.java:328 TeamRule.cheat, default false).
	frame["block_implementation"] = block_implementation
	frame["team_id"] = team_id
	frame["rules_state"] = rules_state
	frame["cheating"] = bool(source_rules_state.source_team_cheating_state(rules_state, team_id).get("cheating", false))
	return frame

static func _initial_frame() -> Dictionary:
	return {}

static func source_unit_factory_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement through the Tile.setBlock proximity path (the same
	# path that binds the drill, ContinuousLiquidTurret and turret
	# frames). A factory-family sprite gets an empty frame bound;
	# the live-loop tick fills its keys every tick. Any other block,
	# or an already-bound sprite, binds nothing.
	if block == null or not _is_unit_factory_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_UNIT_FACTORY_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_UNIT_FACTORY_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_UNIT_FACTORY_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_unit_factory_update_consumption_state(frame: Dictionary, has_consumers: bool, enabled: bool, production_valid: bool, should_consume: bool, efficiency_scale: float) -> Dictionary:
	# BuildingComp.updateConsumption() (BuildingComp.java:1943-1951):
	# when cheating, everything is valid and consumption is skipped
	# (`if(!block.hasConsumers || cheating()){`, the early return
	# sets potentialEfficiency from enabled and productionValid and
	# efficiency from shouldConsume, with no consumer updated). The
	# shared efficiency machinery already implements that method, so
	# this adapter runs it with the frame's live cheating flag and
	# no bound consumer actors yet (the factory's RuntimeConsumer
	# actors are a later slice, like the ContinuousLiquidTurret
	# binding in N2106): a cheating factory takes the early return
	# and pays nothing, while a non-cheating one runs the machinery
	# over its (still empty) actor list. skipped_consumption is the
	# Java early-return condition itself.
	var cheating := bool(frame.get("cheating", false))
	var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(has_consumers, cheating, enabled, production_valid, should_consume, efficiency_scale, [], [], [], frame)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_UPDATE_CONSUMPTION_STATE,
		"cheating": cheating,
		"skipped_consumption": bool(not has_consumers or cheating),
		"potential_efficiency": float(consumption.get("potential_efficiency", 0.0)),
		"efficiency": float(consumption.get("efficiency", 0.0)),
		"optional_efficiency": float(consumption.get("optional_efficiency", 0.0)),
		"should_consume_power": bool(consumption.get("should_consume_power", false)),
	}

@warning_ignore("unused_parameter")
static func source_unit_factory_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the factory tick wiring every tick
	# (UnitFactoryBuild.updateTile(), UnitFactory.java:392;
	# ReconstructorBuild.updateTile(), Reconstructor.java:317;
	# UnitAssemblerBuild.updateTile(), UnitAssembler.java:429 — each
	# runs updateConsumption through the Building update): each
	# placed factory-family build gets its frame keys refreshed from
	# the live rules, so the frame's cheating flag tracks
	# team.rules().cheat and updateConsumption skips consumption for
	# a cheating team. The frame is bound at placement
	# (source_unit_factory_bind_frame_state); a sprite that somehow
	# lacks one gets it bound here instead of crashing the loop. The
	# frame delta is not consumed by the wiring itself (it only
	# refreshes keys); a later slice that ticks production or
	# consumption reads it.
	var results_by_cell := {}
	var ticked_count := 0
	if game == null:
		return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
	var catalog = game.get("content_catalog")
	if catalog == null:
		return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	for sprite in source_placed_block_state.source_unique_buildings_state(game).get("buildings", []):
		if not is_instance_valid(sprite) or not sprite is Sprite2D:
			continue
		var block_id: String = str(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
		if not blocks_by_id.has(block_id):
			continue
		var block = blocks_by_id[block_id]
		if not _is_unit_factory_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_unit_factory_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_unit_factory_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
