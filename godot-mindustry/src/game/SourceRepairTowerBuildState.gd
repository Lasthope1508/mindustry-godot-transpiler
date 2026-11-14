extends RefCounted
class_name SourceRepairTowerBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")

# The RepairTower implementation (RepairTower.java:18, `public class RepairTower extends Block{`): unit-repair-tower (consumePower 1f, Blocks.java:6582, `consumePower(1f);`; consumeLiquid ozone 3f/60f, Blocks.java:6583, `consumeLiquid(Liquids.ozone, 3f / 60f);`; size 2, range 100f, healAmount 1.5f, graphite 90 / silicon 90 / tungsten 80, Blocks.java:6575-6583). RepairTower extends Block, NOT a factory or crafter, so no existing driver matches it and no frame key exists for it; this driver uses its own family frame key ("source_repair_tower_building", the radar precedent), and this slice adds the repair-tower key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourceRepairTower* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the updateTile heal advance (RepairTower.java:78, `target.heal(healAmount * edelta());`) heals by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`), so a repair tower with no power would never heal -- its targets' health would sit frozen as if power.status were 1.0.
const SOURCE_REPAIR_TOWER_BUILD_IMPLEMENTATIONS := ["RepairTower"]
const SOURCE_REPAIR_TOWER_BUILDING_META_KEY := "source_repair_tower_building"

static func _is_repair_tower_build_implementation(implementation: String) -> bool:
	return SOURCE_REPAIR_TOWER_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_repair_tower_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The repair-tower tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (RepairTower.java:18, `public class RepairTower extends Block{`; RepairTowerBuild, RepairTower.java:46, `public class RepairTowerBuild extends Building implements Ranged{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# repair tower skips consumption like Java's updateConsumption
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
	# for this repair tower (N2125); the tick preserves a disabled
	# repair tower instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	return {}

static func source_repair_tower_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the repair-tower frame meta key
	# ("source_repair_tower_building"). A RepairTower sprite gets an
	# empty frame bound; the live-loop tick fills its keys every
	# tick. Any other block, or an already-bound sprite, binds
	# nothing.
	if block == null or not _is_repair_tower_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_REPAIR_TOWER_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_REPAIR_TOWER_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_REPAIR_TOWER_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_repair_tower_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a repair tower does not take the early return. The repair tower's power draw is STATIC, not conditional: `consumePower(1f);` (Blocks.java:6582) registers a plain ConsumePower, so the catalog consumePower 1.0 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. The pure row is still the same ConsumePower read (`return build.power.status;`, ConsumePower.java:39). The updateTile advance follows the folded efficiency: the heal advance (RepairTower.java:78, `target.heal(healAmount * edelta());`) heals by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`), so a repair tower with no power would never heal. RepairTowerBuild overrides shouldConsume (RepairTower.java:89, `public boolean shouldConsume(){` with `return targets.size > 0;`, RepairTower.java:90); updateConsumption forces efficiency to zero when the gate is false (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). RED decision (the PointDefenseTurret N2151 precedent and the RepairTurret N2174 precedent): the port tracks no live target on any placed-building frame, so this slice folds power-only and defers the gate with a documented limit; the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent) -- with no targets requestedPower is 0 so power.status reads 1.0 while Java efficiency is 0; the observable gap is efficiency 1.0 vs 0.0 with no targets. The repair tower is its own family (RepairTower.java:18, `public class RepairTower extends Block{`; RepairTowerBuild, RepairTower.java:46, `public class RepairTowerBuild extends Building implements Ranged{`). Class fields: `static final float refreshInterval = 6f;` (RepairTower.java:19), `public float range = 80f;` (RepairTower.java:21), `public float healAmount = 1f;` (RepairTower.java:24); constructor `update = true;` (RepairTower.java:29), `suppressable = true;` (RepairTower.java:31), `flags = EnumSet.of(BlockFlag.repair);` (RepairTower.java:32). The target refresh itself is gated on potentialEfficiency (RepairTower.java:59, `if(potentialEfficiency > 0 && (refresh += Time.delta) >= refreshInterval){`), and the warmup lerp (RepairTower.java:84, `warmup = Mathf.lerpDelta(warmup, any ? efficiency : 0f, 0.08f);`) follows efficiency. canConsume (BuildingComp.java:1917, `public boolean canConsume(){` with `return potentialEfficiency > 0;`, BuildingComp.java:1918) and the shouldConsume default (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`, BuildingComp.java:756) are the surrounding gates. Single def -- unit-repair-tower only (size 2, range 100f, healAmount 1.5f, graphite 90 / silicon 90 / tungsten 80, Blocks.java:6575-6583). RepairTurret (repair-point / repair-turret) is a different class and NOT covered by this driver.
	# Documented limits: (1) power-only first pass -- the repair tower's static power consumer (consumePower 1f, Blocks.java:6582) is the only modeled consumer, so the folded efficiency is the min over the *modeled* consumers (power only); the ozone liquid consumer (consumeLiquid ozone 3f/60f = 0.05, Blocks.java:6583, `consumeLiquid(Liquids.ozone, 3f / 60f);`) waits for its own slice (the N2174 coolant precedent). (2) shouldConsume gate deferred -- RepairTowerBuild overrides shouldConsume (`return targets.size > 0;`, RepairTower.java:89-91); when the gate is false Java forces efficiency to 0 (BuildingComp.java:1960 + 1992-1994); the driver runs with should_consume=true when enabled (the MendProjector suppression precedent) -- with no targets power.status reads 1.0 while Java efficiency is 0. (3) No updateTile heal advance -- target refresh / heal / warmup lerp / totalProgress advance (RepairTower.java:57-86) wait for their own slices; the proof carries no heal/warmup/target keys, the heal advance (RepairTower.java:78) is what the efficiency keys prove. (4) No suppression modeling -- `suppressable = true` (RepairTower.java:31) and `checkSuppression()` zeroes warmup (RepairTower.java:69-72); the suppression coupling waits for its own slice. (5) Single def -- unit-repair-tower only (size 2, range 100f, healAmount 1.5f, graphite 90 / silicon 90 / tungsten 80); per-def stat values wait for their own verification slice. (6) RepairTurret (repair-point / repair-turret) is a different class and NOT covered by this driver.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

@warning_ignore("unused_parameter")
static func source_repair_tower_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the repair-tower tick wiring every
	# tick (RepairTowerBuild.updateTile(), RepairTower.java:57,
	# advances the heal by the heal advance (RepairTower.java:78, `target.heal(healAmount * edelta());`), so the heal advance follows the folded efficiency; no placed-buildings driver ticks RepairTower blocks, so this driver is the placed-repair-tower tick): each placed RepairTower build gets its frame keys refreshed from the live rules, so the frame's cheating flag tracks team.rules().cheat and the consumption machinery skips consumption for a cheating team. The frame is bound at placement; a sprite that somehow lacks one gets it bound here instead of crashing the loop.
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
		if not _is_repair_tower_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_repair_tower_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_repair_tower_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a repair tower with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the heal advance (RepairTower.java:78, `target.heal(healAmount * edelta());`)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a repair tower does not take the early return. The repair tower's power draw is STATIC: `consumePower(1f);` (Blocks.java:6582) registers a plain ConsumePower, so the catalog consumePower 1.0 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. A repair tower with no power consumer is untouched: the tick models no other consumers yet (the updateTile advance waits for its own slice), and RepairTowerBuild overrides shouldConsume (RepairTower.java:89, `public boolean shouldConsume(){` with `return targets.size > 0;`, RepairTower.java:90) -- RED decision (the PointDefenseTurret N2151 precedent and the RepairTurret N2174 precedent): the port tracks no live target on any placed-building frame, so the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent). productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var should_consume: bool = bool(frame.get("enabled", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_repair_tower_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
