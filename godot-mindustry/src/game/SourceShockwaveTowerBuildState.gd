extends RefCounted
class_name SourceShockwaveTowerBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")

# The ShockwaveTower implementation (ShockwaveTower.java:22, `public class ShockwaveTower extends Block{`): shockwave-tower (consumePower 100f / 60f, Blocks.java:2042, `consumePower(100f / 60f);`; consumeLiquids cyanogen 1.5f / 60f, Blocks.java:2041, `consumeLiquids(LiquidStack.with(Liquids.cyanogen, 1.5f / 60f));`; size 3, range 170f, reload 80f, surge-alloy 50 / silicon 150 / oxide 30 / tungsten 100, Blocks.java:2038-2044). ShockwaveTower extends Block, NOT a factory or crafter, so no existing driver matches it and no frame key exists for it; this driver uses its own family frame key ("source_shockwave_tower_building", the radar precedent), and this slice adds the shockwave-tower key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourceShockwaveTower* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the updateTile fire gate (ShockwaveTower.java:73, `if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){`) charges its reload counter by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`), so a shockwave tower with no power would never charge and never fire its wave -- its reload counter would sit frozen as if power.status were 1.0.
const SOURCE_SHOCKWAVE_TOWER_BUILD_IMPLEMENTATIONS := ["ShockwaveTower"]
const SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY := "source_shockwave_tower_building"

static func _is_shockwave_tower_build_implementation(implementation: String) -> bool:
	return SOURCE_SHOCKWAVE_TOWER_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_shockwave_tower_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The shockwave-tower tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (ShockwaveTower.java:22, `public class ShockwaveTower extends Block{`; ShockwaveTowerBuild, ShockwaveTower.java:66, `public class ShockwaveTowerBuild extends Building{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# shockwave tower skips consumption like Java's updateConsumption
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
	# for this shockwave tower (N2125); the tick preserves a disabled
	# shockwave tower instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	return {}

static func source_shockwave_tower_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the shockwave-tower frame meta key
	# ("source_shockwave_tower_building"). A ShockwaveTower sprite gets an
	# empty frame bound; the live-loop tick fills its keys every
	# tick. Any other block, or an already-bound sprite, binds
	# nothing.
	if block == null or not _is_shockwave_tower_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_shockwave_tower_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a shockwave tower does not take the early return. The shockwave tower's power draw is STATIC, not conditional: `consumePower(100f / 60f);` (Blocks.java:2042) registers a plain ConsumePower, so the catalog consumePower 1.6666666666666667 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. The pure row is still the same ConsumePower read (`return build.power.status;`, ConsumePower.java:39). The updateTile fire gate follows the folded efficiency: the reload charge (ShockwaveTower.java:73, `if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){`) charges by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`), so a shockwave tower with no power would never charge and never fire its wave. ShockwaveTowerBuild overrides shouldConsume (ShockwaveTower.java:121, `public boolean shouldConsume(){` with `return reloadCounter < reload;`, ShockwaveTower.java:122); updateConsumption forces efficiency to zero when the gate is false (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). RED decision (the PointDefenseTurret N2151 precedent and the RepairTurret N2174 / RepairTower N2176 precedents): the port tracks no live reload counter on any placed-building frame, so this slice folds power-only and defers the gate with a documented limit; the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent) -- when fully reloaded power.status reads 1.0 while Java efficiency is 0; the observable gap is efficiency 1.0 vs 0.0 when fully reloaded. The shockwave tower is its own family (ShockwaveTower.java:22, `public class ShockwaveTower extends Block{`; ShockwaveTowerBuild, ShockwaveTower.java:66, `public class ShockwaveTowerBuild extends Building{`). Class fields: `public int timerCheck = timers ++;` (ShockwaveTower.java:23), `public float range = 110f;` (ShockwaveTower.java:25), `public float reload = 60f * 1.5f;` (ShockwaveTower.java:26), `public float bulletDamage = 160;` (ShockwaveTower.java:27), `public float falloffCount = 20f;` (ShockwaveTower.java:28), `public float shake = 2f;` (ShockwaveTower.java:29), `public float checkInterval = 8f;` (ShockwaveTower.java:31), `public float cooldownMultiplier = 1f;` (ShockwaveTower.java:34); constructor `update = true;` (ShockwaveTower.java:46), `solid = true;` (ShockwaveTower.java:47). Build fields: `public float reloadCounter = Mathf.random(reload);` (ShockwaveTower.java:67), `public float heat = 0f;` (ShockwaveTower.java:68). The wave damage line (ShockwaveTower.java:87, `float waveDamage = Math.min(bulletDamage, bulletDamage * falloffCount / targets.size);`) and the heat decay (ShockwaveTower.java:104, `heat = Mathf.clamp(heat - Time.delta / reload * cooldownMultiplier);`) follow the fire gate. canConsume (BuildingComp.java:1917, `public boolean canConsume(){` with `return potentialEfficiency > 0;`, BuildingComp.java:1918) and the shouldConsume default (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`, BuildingComp.java:756) are the surrounding gates. sense(LAccess.progress) returns `reloadCounter / reload` (ShockwaveTower.java:110, `if(sensor == LAccess.progress) return reloadCounter / reload;`) and warmup() returns heat (ShockwaveTower.java:117, `return heat;`) -- both wait for their own slices. Single def -- shockwave-tower only (size 3, range 170f, reload 80f, surge-alloy 50 / silicon 150 / oxide 30 / tungsten 100, Blocks.java:2038-2044). RepairTower (unit-repair-tower) is a different class and NOT covered by this driver.
	# Documented limits: (1) power-only first pass -- the shockwave tower's static power consumer (consumePower 100f/60f, Blocks.java:2042) is the only modeled consumer, so the folded efficiency is the min over the *modeled* consumers (power only); the cyanogen liquid consumer (consumeLiquids cyanogen 1.5f/60f = 0.025, Blocks.java:2041, `consumeLiquids(LiquidStack.with(Liquids.cyanogen, 1.5f / 60f));`) waits for its own slice (the N2174 coolant / N2176 ozone precedent). (2) shouldConsume gate deferred -- ShockwaveTowerBuild overrides shouldConsume (`return reloadCounter < reload;`, ShockwaveTower.java:121-122); when the gate is false Java forces efficiency to 0 (BuildingComp.java:1960 + 1992-1994); the driver runs with should_consume=true when enabled (the MendProjector suppression precedent) -- when fully reloaded power.status reads 1.0 while Java efficiency is 0. (3) No updateTile wave advance -- reloadCounter charge / bullet scan / wave damage / heat / cooldown (ShockwaveTower.java:73-104) wait for their own slices; the proof carries no wave/heat/target keys, the reload charge (ShockwaveTower.java:73) is what the efficiency keys prove. (4) No sense/warmup modeling -- `sense(LAccess.progress)` (:110) and `warmup()` returning heat (:117) wait for their own slices. (5) Single def -- shockwave-tower only (size 3, range 170f, reload 80f, surge-alloy 50 / silicon 150 / oxide 30 / tungsten 100); per-def stat values wait for their own verification slice. (6) No draw modeling -- heatRegion / shape draw (:126-134) wait for their own slices.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

@warning_ignore("unused_parameter")
static func source_shockwave_tower_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the shockwave-tower tick wiring every
	# tick (ShockwaveTowerBuild.updateTile(), ShockwaveTower.java:73,
	# charges the reload counter by the reload charge (ShockwaveTower.java:73, `if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){`), so the reload charge follows the folded efficiency; no placed-buildings driver ticks ShockwaveTower blocks, so this driver is the placed-shockwave-tower tick): each placed ShockwaveTower build gets its frame keys refreshed from the live rules, so the frame's cheating flag tracks team.rules().cheat and the consumption machinery skips consumption for a cheating team. The frame is bound at placement; a sprite that somehow lacks one gets it bound here instead of crashing the loop.
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
		if not _is_shockwave_tower_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_shockwave_tower_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_shockwave_tower_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a shockwave tower with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the reload charge (ShockwaveTower.java:73, `if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){`)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a shockwave tower does not take the early return. The shockwave tower's power draw is STATIC: `consumePower(100f / 60f);` (Blocks.java:2042) registers a plain ConsumePower, so the catalog consumePower 1.6666666666666667 is present and the plain radar gate (block.properties.has("consumePower")) works -- no RepairTurret-style `or consumesPower` adaptation is needed. A shockwave tower with no power consumer is untouched: the tick models no other consumers yet (the updateTile advance waits for its own slice), and ShockwaveTowerBuild overrides shouldConsume (ShockwaveTower.java:121, `public boolean shouldConsume(){` with `return reloadCounter < reload;`, ShockwaveTower.java:122) -- RED decision (the PointDefenseTurret N2151 precedent and the RepairTurret N2174 / RepairTower N2176 precedents): the port tracks no live reload counter on any placed-building frame, so the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent). productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var should_consume: bool = bool(frame.get("enabled", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_shockwave_tower_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
