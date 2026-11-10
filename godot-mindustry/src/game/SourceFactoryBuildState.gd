extends RefCounted
class_name SourceFactoryBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")

# Every block whose build is a GenericCrafterBuild: the class itself
# (GenericCrafter.java:23 `public class GenericCrafter extends
# Block{`) and the three that extend it (AttributeCrafter extends
# GenericCrafter, AttributeCrafter.java:11; HeatCrafter extends
# GenericCrafter, HeatCrafter.java:11; HeatProducer extends
# GenericCrafter, HeatProducer.java:12). AttributeCrafterBuild does
# not override updateTile, and HeatCrafterBuild/HeatProducerBuild call
# super.updateTile() first (HeatCrafter.java:48-51,
# HeatProducer.java:46-47), so GenericCrafterBuild.updateTile()
# (GenericCrafter.java:235) is the tick for all of them. The other
# production blocks are NOT here: Separator, Incinerator and
# WallCrafter extend Block directly, SingleBlockProducer extends
# BlockProducer, and the drills/pumps have their own drivers.
const SOURCE_FACTORY_BUILD_IMPLEMENTATIONS := ["GenericCrafter", "AttributeCrafter", "HeatCrafter", "HeatProducer"]
const SOURCE_FACTORY_BUILDING_META_KEY := "source_factory_building"

static func _is_factory_build_implementation(implementation: String) -> bool:
	return SOURCE_FACTORY_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_factory_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The factory tick wires the frame keys the consumption path reads
	# (the N2108 turret pattern): block_implementation is the block's
	# implementation (GenericCrafter.java:23, `public class
	# GenericCrafter extends Block{`), team_id and rules_state are what
	# Java reads as b.team and state.rules, and cheating is the team's
	# live TeamRule value (TeamComp.cheating(), TeamComp.java:17-19
	# `return team.rules().cheat;`, read through N2099's helper), so a
	# cheating team's factory counts everything as valid like Java's
	# updateConsumption (BuildingComp.java:1944-1945, "everything is
	# valid when cheating", `if(!block.hasConsumers || cheating()){`).
	# A team with no rule keeps the false default (Rules.java:328
	# TeamRule.cheat, default false).
	frame["block_implementation"] = block_implementation
	frame["team_id"] = team_id
	frame["rules_state"] = rules_state
	frame["cheating"] = bool(source_rules_state.source_team_cheating_state(rules_state, team_id).get("cheating", false))
	return frame

static func _initial_frame() -> Dictionary:
	return {}

static func source_factory_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement through the Tile.setBlock proximity path (the same
	# path that binds the drill, ContinuousLiquidTurret and turret
	# frames). A factory-family sprite gets an empty frame bound; the
	# live-loop tick fills its keys every tick. Any other block, or an
	# already-bound sprite, binds nothing.
	if block == null or not _is_factory_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_FACTORY_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_FACTORY_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_FACTORY_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

@warning_ignore("unused_parameter")
static func source_factory_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the factory tick wiring every tick
	# (GenericCrafterBuild.updateTile(), GenericCrafter.java:235, runs
	# after updateConsumption through Building.update(),
	# BuildingComp.java:2262-2274; AttributeCrafterBuild does not
	# override updateTile, and HeatCrafterBuild/HeatProducerBuild call
	# super.updateTile() first): each placed factory-family build
	# gets its frame keys refreshed from the live rules, so the
	# frame's cheating flag tracks team.rules().cheat and the
	# updateConsumption cheat branch can fire for a cheating team.
	# The frame is bound at placement (source_factory_bind_frame_state);
	# a sprite that somehow lacks one gets it bound here instead of
	# crashing the loop. The frame delta is not consumed by the wiring
	# itself (it only refreshes keys); a later slice that ticks
	# crafting progress or consumption reads it.
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
		if not _is_factory_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_factory_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_factory_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
