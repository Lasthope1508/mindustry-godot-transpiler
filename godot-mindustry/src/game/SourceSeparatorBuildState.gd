extends RefCounted
class_name SourceSeparatorBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")

# The Separator implementation (Separator.java:19, `public class Separator extends Block{`): separator (consumePower 1.1f, Blocks.java:1243, `consumePower(1.1f);`; size 2, craftTime 35f, Blocks.java:1231-1246) and disassembler (consumePower 4f, Blocks.java:1262, `consumePower(4f);`; size 3, craftTime 15f, itemCapacity 20, Blocks.java:1248-1266). Separator extends Block, NOT a factory or crafter, so no existing driver matches it and no frame key exists for it; this driver uses its own family frame key ("source_separator_building", the payload-deconstructor / unit-assembler-module precedent), and this slice adds the separator key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourceSeparator* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the updateTile progress advance (Separator.java:133, `if(efficiency > 0){` with `progress += getProgressIncrease(craftTime);`) gates on efficiency > 0, so a separator with no power would advance progress as if power.status were 1.0.
const SOURCE_SEPARATOR_BUILD_IMPLEMENTATIONS := ["Separator"]
const SOURCE_SEPARATOR_BUILDING_META_KEY := "source_separator_building"

static func _is_separator_build_implementation(implementation: String) -> bool:
	return SOURCE_SEPARATOR_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_separator_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The separator tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (Separator.java:19, `public class Separator extends Block{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# separator skips consumption like Java's updateConsumption
	# (BuildingComp.java:1944-1945, "everything is valid when
	# cheating"). A team with no rule keeps the false default
	# (Rules.java:328 TeamRule.cheat, default false).
	frame["block_implementation"] = block_implementation
	frame["team_id"] = team_id
	frame["rules_state"] = rules_state
	frame["cheating"] = bool(source_rules_state.source_team_cheating_state(rules_state, team_id).get("cheating", false))
	# Building.enabled (BuildingComp.java:77, `transient boolean
	# enabled = true;`) is what shouldConsume() returns
	# (BuildingComp.java:755-757), so the power graph reads it live
	# for this separator (N2125); the tick preserves a disabled
	# separator instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	return {}

static func source_separator_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the separator frame meta key
	# ("source_separator_building"). A Separator sprite gets an
	# empty frame bound; the live-loop tick fills its keys every
	# tick. Any other block, or an already-bound sprite, binds
	# nothing.
	if block == null or not _is_separator_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_SEPARATOR_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_SEPARATOR_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_SEPARATOR_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_separator_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a separator does not take the early return. The progress advance follows the folded efficiency (Separator.java:133, `if(efficiency > 0){` with `progress += getProgressIncrease(craftTime);`) and the shouldConsume override (Separator.java:92, `public boolean shouldConsume(){` with `return total < itemCapacity && enabled;`, Separator.java:100; default BuildingComp.java:755, `public boolean shouldConsume(){`) -- SeparatorBuild (Separator.java:75, `public class SeparatorBuild extends Building{`) overrides shouldConsume() to return total < itemCapacity && enabled, so the default does not apply here; the gate is deferred (items state is not tracked yet) and the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent). The separator (consumePower 1.1f, Blocks.java:1243, `consumePower(1.1f);`; disassembler consumePower 4f, Blocks.java:1262, `consumePower(4f);`) also consumes liquid slag (separator `consumeLiquid(Liquids.slag, 4f / 60f);`, Blocks.java:1244; disassembler 0.12f, Blocks.java:1264) -- power-only first pass, so the folded efficiency is the min over the *modeled* consumers (power only).
	# Documented limits: (1) power-only first pass -- the separator also consumes liquid slag (4f/60f separator / 0.12f disassembler, Blocks.java:1244/1264), so the folded efficiency is the min over the *modeled* consumers (power only). (2) shouldConsume gate deferred -- SeparatorBuild overrides shouldConsume() to return total < itemCapacity && enabled (Separator.java:92-100, `return total < itemCapacity && enabled;`); items state is not tracked yet, so the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent). (3) No updateTile advance -- progress / warmup / totalProgress / consume() / offload random result item / dump (Separator.java:128-166) wait for their own slices; the proof carries no progress/warmup/offload keys, the efficiency > 0 gate (Separator.java:133, `if(efficiency > 0){`) is what the efficiency keys prove. (4) No sense / canDump / draw / drawLight / icons / drawPlanRegion / read-write / created / shouldAmbientSound rows -- sense (Separator.java:169-172), canDump (Separator.java:175-177), draw (Separator.java:109-111), drawLight (Separator.java:114-117), icons (Separator.java:71-73), drawPlanRegion (Separator.java:66-69), read/write (Separator.java:180-194), created (Separator.java:78-80), shouldAmbientSound (Separator.java:83-85) are logic / presentation / serialization / lifecycle, not tick state. (5) Disassembler variant verification pending -- the same driver covers both defs via the catalog consumePower.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

@warning_ignore("unused_parameter")
static func source_separator_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the separator tick wiring every
	# tick (SeparatorBuild.updateTile(), Separator.java:128,
	# gates on the progress advance (Separator.java:133, `if(efficiency > 0){` with `progress += getProgressIncrease(craftTime);`), so the progress advance follows the folded efficiency; no placed-buildings driver ticks Separator blocks, so this driver is the placed-separator tick): each placed Separator build gets its frame keys refreshed from the live rules, so the frame's cheating flag tracks team.rules().cheat and the consumption machinery skips consumption for a cheating team. The frame is bound at placement; a sprite that somehow lacks one gets it bound here instead of crashing the loop.
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
		if not _is_separator_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_separator_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_separator_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a separator with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the progress advance (Separator.java:133)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a separator does not take the early return. A separator with no power consumer is untouched: the tick models no other consumers yet (the liquid slag consumer waits for its own slice), and there is no shouldConsume gate yet (SeparatorBuild overrides shouldConsume() to return total < itemCapacity && enabled, Separator.java:92-100, but items state is not tracked yet), so the machinery runs with should_consume=true when enabled. productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var should_consume: bool = bool(frame.get("enabled", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_separator_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
