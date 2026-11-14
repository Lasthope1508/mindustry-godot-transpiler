extends RefCounted
class_name SourceRepairTurretBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")

# The RepairTurret implementation (RepairTurret.java:25, `public class RepairTurret extends Block{`): repair-point (powerUse 1f, Blocks.java:6391, `powerUse = 1f;`; repairSpeed 0.45f, repairRadius 60f, Blocks.java:6388-6389) and repair-turret (powerUse 5f, Blocks.java:6402, `powerUse = 5f;`; size 2, repairSpeed 3f, repairRadius 145f, Blocks.java:6398-6401). RepairTurret extends Block, NOT a factory or crafter, so no existing driver matches it and no frame key exists for it; this driver uses its own family frame key ("source_repair_turret_building", the radar precedent), and this slice adds the repair-turret key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourceRepairTurret* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the updateTile heal advance (RepairTurret.java:207, `target.heal(repairSpeed * strength * edelta() * multiplier);`) heals by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`), so a repair turret with no power would never heal -- its target's health would sit frozen as if power.status were 1.0.
const SOURCE_REPAIR_TURRET_BUILD_IMPLEMENTATIONS := ["RepairTurret"]
const SOURCE_REPAIR_TURRET_BUILDING_META_KEY := "source_repair_turret_building"

static func _is_repair_turret_build_implementation(implementation: String) -> bool:
	return SOURCE_REPAIR_TURRET_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_repair_turret_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The repair-turret tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (RepairTurret.java:25, `public class RepairTurret extends Block{`; RepairPointBuild, RepairTurret.java:153, `public class RepairPointBuild extends Building implements Ranged, RotBlock{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# repair turret skips consumption like Java's updateConsumption
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
	# for this repair turret (N2125); the tick preserves a disabled
	# repair turret instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	return {}

static func source_repair_turret_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the repair-turret frame meta key
	# ("source_repair_turret_building"). A RepairTurret sprite gets an
	# empty frame bound; the live-loop tick fills its keys every
	# tick. Any other block, or an already-bound sprite, binds
	# nothing.
	if block == null or not _is_repair_turret_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_REPAIR_TURRET_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_REPAIR_TURRET_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_REPAIR_TURRET_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_repair_turret_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a repair turret does not take the early return. The repair turret's power draw is CONDITIONAL, not static: `consumePowerCond(powerUse, (RepairPointBuild entity) -> entity.target != null);` (RepairTurret.java:89), and ConsumePowerCondition only draws when its condition holds (ConsumePowerCondition.java:17, `return consume.get(entity) ? usage : 0f;`) -- the catalog consumePower None is CORRECT for this family, it records no static consumePower def; the two defs carry powerUse 1f (repair-point, Blocks.java:6391, `powerUse = 1f;`) and 5f (repair-turret, Blocks.java:6402, `powerUse = 5f;`), and the block declares `public float powerUse;` (RepairTurret.java:34) with `hasPower = true;` (RepairTurret.java:60). The pure row is still the same ConsumePower read (`return build.power.status;`, ConsumePower.java:39) -- ConsumePowerCondition does not override efficiency(), so the row folds power.status exactly like the static case. The updateTile advance follows the folded efficiency: the heal advance (RepairTurret.java:207, `target.heal(repairSpeed * strength * edelta() * multiplier);`) heals by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`), so a repair turret with no power would never heal. RepairPointBuild overrides shouldConsume (RepairTurret.java:221, `public boolean shouldConsume(){` with `return target != null && enabled;`, RepairTurret.java:222); updateConsumption forces efficiency to zero when the gate is false (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). RED decision (the PointDefenseTurret N2151 precedent): the port tracks no live target on any placed-building frame, so this slice folds power-only and defers the gate with a documented limit; the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent) -- with no target requestedPower is 0 so power.status reads 1.0 while Java efficiency is 0; the observable gap is efficiency 1.0 vs 0.0 with no target. The repair turret is its own family (RepairTurret.java:25, `public class RepairTurret extends Block{`; RepairPointBuild, RepairTurret.java:153, `public class RepairPointBuild extends Building implements Ranged, RotBlock{`). Two defs (repair-point, `powerUse = 1f;`, Blocks.java:6391; repair-turret, `powerUse = 5f;`, Blocks.java:6402).
	# Documented limits: (1) power-only first pass -- the repair turret's power consumer is conditional (ConsumePowerCondition, target-gated), so the folded efficiency is the min over the *modeled* consumers (power only); the coolant optional consumer (repair-turret only: ConsumeCoolant, acceptCoolant, coolantUse 0.16f, coolantMultiplier 1.6f, Blocks.java:6404-6406) is the second pass and waits for its own slice. (2) shouldConsume gate -- RepairPointBuild overrides shouldConsume (`target != null && enabled`, RepairTurret.java:221-223); when the gate is false Java forces efficiency to 0 (BuildingComp.java:1960 + 1992-1994); the driver runs with should_consume=true when enabled (the MendProjector suppression precedent) and the gate is deferred -- with no target requestedPower is 0 so power.status reads 1.0 while Java efficiency is 0. (3) No updateTile heal advance -- target re-acquire / heal / rotation slerp / strength lerp (RepairTurret.java:187-218) wait for their own slices; the proof carries no heal/strength/rotation/target keys, the heal advance (RepairTurret.java:207) is what the efficiency keys prove. (4) Two defs -- repair-point (powerUse 1f) and repair-turret (powerUse 5f + coolant) share the one driver; repairSpeed / repairRadius / length / beamWidth / pulseRadius per-def values wait for their own verification slice. (5) RepairTower (unit-repair-tower) is a different class and NOT covered by this driver.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

@warning_ignore("unused_parameter")
static func source_repair_turret_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the repair-turret tick wiring every
	# tick (RepairPointBuild.updateTile(), RepairTurret.java:187,
	# advances the heal by the heal advance (RepairTurret.java:207, `target.heal(repairSpeed * strength * edelta() * multiplier);`), so the heal advance follows the folded efficiency; no placed-buildings driver ticks RepairTurret blocks, so this driver is the placed-repair-turret tick): each placed RepairTurret build gets its frame keys refreshed from the live rules, so the frame's cheating flag tracks team.rules().cheat and the consumption machinery skips consumption for a cheating team. The frame is bound at placement; a sprite that somehow lacks one gets it bound here instead of crashing the loop.
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
		if not _is_repair_turret_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_repair_turret_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_repair_turret_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a repair turret with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the heal advance (RepairTurret.java:207)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a repair turret does not take the early return. The driver gate reads the conditional consumer through the catalog: the conditional registration (RepairTurret.java:89, `consumePowerCond(powerUse, (RepairPointBuild entity) -> entity.target != null);`) carries no static consumePower def, so the catalog records consumePower None (CORRECT) but consumesPower true for both defs -- the gate is `block.properties.has("consumePower")` or the catalog consumesPower flag, so a repair turret is ticked while a block with no power consumer at all is untouched: the tick models no other consumers yet (the updateTile advance waits for its own slice), and RepairPointBuild overrides shouldConsume (RepairTurret.java:221, `public boolean shouldConsume(){` with `return target != null && enabled;`, RepairTurret.java:222) -- RED decision (the PointDefenseTurret N2151 precedent): the port tracks no live target on any placed-building frame, so the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent). productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower") or block.properties.get("consumesPower", false))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var should_consume: bool = bool(frame.get("enabled", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_repair_turret_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
