extends RefCounted
class_name SourceWallCrafterBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const inventory := preload("res://src/game/SourceDrillInventoryRuntimeState.gd")

# The WallCrafter implementation (WallCrafter.java:25, `public class WallCrafter extends Block{`): cliff-crusher (consumePower 11 / 60f, Blocks.java:3004, `consumePower(11 / 60f);`; size 2, drillTime 110f, Blocks.java:3006-3007) and large-cliff-crusher (consumePower 1f, Blocks.java:3018, `consumePower(1f);`; size 3, drillTime 48f, Blocks.java:3020-3021). WallCrafter extends Block, NOT a factory or crafter, so no existing driver matches it and no frame key exists for it; this driver uses its own family frame key ("source_wall_crafter_building", the separator precedent), and this slice adds the wall-crafter key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourceWallCrafter* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the updateTile warmup fold (WallCrafter.java:193, `warmup = Mathf.approachDelta(warmup, Mathf.num(efficiency > 0), 1f / 40f);`) gates on efficiency > 0, so a wall crafter with no power would warm up as if power.status were 1.0.
const SOURCE_WALL_CRAFTER_BUILD_IMPLEMENTATIONS := ["WallCrafter"]
const SOURCE_WALL_CRAFTER_BUILDING_META_KEY := "source_wall_crafter_building"
# WallCrafter.java:193 warmup speed `1f / 40f` in
# `warmup = Mathf.approachDelta(warmup, Mathf.num(efficiency > 0), 1f / 40f);`
# -- the approachDelta rate.
const SOURCE_WALL_CRAFTER_WARMUP_SPEED := 1.0 / 40.0
# WallCrafter.java:35, `public float liquidBoostIntensity = 1.6f;`
# and WallCrafter.java:47, `public float itemBoostIntensity = 1.6f;`
# -- the class boost intensities; neither def overrides them.
const SOURCE_WALL_CRAFTER_LIQUID_BOOST_INTENSITY := 1.6
const SOURCE_WALL_CRAFTER_ITEM_BOOST_INTENSITY := 1.6
# WallCrafter.java:33, `public float drillTime = 150f;` -- the
# class drillTime default; the defs override it (110f / 48f,
# Blocks.java:3006/:3020), so the driver reads drillTime from
# the catalog per def and uses this only when the catalog
# carries no drillTime.
const SOURCE_WALL_CRAFTER_DRILL_TIME_DEFAULT := 150.0

static func _is_wall_crafter_build_implementation(implementation: String) -> bool:
	return SOURCE_WALL_CRAFTER_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_wall_crafter_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The wall-crafter tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (WallCrafter.java:25, `public class WallCrafter extends Block{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# wall crafter skips consumption like Java's updateConsumption
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
	# for this wall crafter (N2125); the tick preserves a disabled
	# wall crafter instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	# The frame carries the Building.items ItemModule
	# (frame["items"], a Dictionary keyed by item name, the
	# drill/factory precedent): WallCrafter has items
	# (WallCrafter.java:58, `hasItems = true;`), and the
	# shouldConsume gate reads the output count from it
	# (WallCrafter.java:227, `return items.get(output) < itemCapacity;`).
	# The offload intake is live (N2223, the updateTile advance,
	# WallCrafter.java:213-215); the timerDump dump intake
	# (WallCrafter.java:220-222) waits for its own slice.
	return {"items": {}}

static func source_wall_crafter_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the wall-crafter frame meta key
	# ("source_wall_crafter_building"). A WallCrafter sprite gets a
	# frame bound with the items key ({} by default); the live-loop
	# tick fills its other keys every tick. Any other block, or an
	# already-bound sprite, binds nothing.
	if block == null or not _is_wall_crafter_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_WALL_CRAFTER_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_WALL_CRAFTER_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_WALL_CRAFTER_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_wall_crafter_should_consume_state(frame: Dictionary, output_item: String, item_capacity: int) -> Dictionary:
	# WallCrafterBuild overrides shouldConsume (WallCrafter.java:226, `public boolean shouldConsume(){` with `return items.get(output) < itemCapacity;`, WallCrafter.java:227): the wall crafter consumes only while its output store holds less than the item capacity. WallCrafter extends Block (WallCrafter.java:25, `public class WallCrafter extends Block{`) and WallCrafterBuild extends Building (WallCrafter.java:183, `public class WallCrafterBuild extends Building{`), so the default (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`) does NOT apply here. Unlike the Separator/Drill gates this one has NO `&& enabled` -- Java returns the bare capacity comparison, so the pure gate does NOT read frame["enabled"] at all (the driver already runs the machinery only when enabled). The output item is sand for both defs (the Java field default, `public Item output = Items.sand;`, WallCrafter.java:43, set explicitly by both defs, `output = Items.sand;`, Blocks.java:3009/:3024) and the capacity is the catalog itemCapacity (10 for the cliff-crusher, the Java field default, `public int itemCapacity = 10;`, Block.java:75; 20 for the large-cliff-crusher, `itemCapacity = 20;`, Blocks.java:3031) -- both arrive as parameters from the driver, which reads them from the catalog. The count comes from the shared inventory helper (SourceDrillInventoryRuntimeState.item_count, reused through a preload, NOT re-implemented) over the frame items key (a Dictionary keyed by item name, default {} for a frame bound before this slice). When the gate is false updateConsumption forces efficiency to zero (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`).
	var items: Dictionary = frame.get("items", {})
	var output_count: int = inventory.item_count(items, output_item)
	return {"should_consume": output_count < item_capacity, "output_count": output_count}

static func source_wall_crafter_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a wall crafter does not take the early return. The updateTile advance follows the folded efficiency (WallCrafter.java:193, `warmup = Mathf.approachDelta(warmup, Mathf.num(efficiency > 0), 1f / 40f);` with `lastEfficiency = eff * timeScale * efficiency;`, WallCrafter.java:211) and the shouldConsume override (WallCrafter.java:226, `public boolean shouldConsume(){` with `return items.get(output) < itemCapacity;`, WallCrafter.java:227; default BuildingComp.java:755, `public boolean shouldConsume(){`) -- WallCrafterBuild (WallCrafter.java:183, `public class WallCrafterBuild extends Building{`) overrides shouldConsume() to return items.get(output) < itemCapacity, so the default does not apply here; the shouldConsume gate is live (N2201) -- the pure gate (source_wall_crafter_should_consume_state) feeds should_consume to the machinery from the frame items count and the catalog output/capacity. The cliff-crusher (consumePower 11 / 60f, Blocks.java:3004, `consumePower(11 / 60f);`; large-cliff-crusher consumePower 1f, Blocks.java:3018, `consumePower(1f);`) also consumes liquid hydrogen as a booster on the large def (`consumeLiquid(Liquids.hydrogen, 1f / 60f);`, Blocks.java:3028; liquidBoostIntensity 1.6f, WallCrafter.java:35) and a graphite item booster (Blocks.java:3030; itemBoostIntensity 1.6f, WallCrafter.java:47; boostItemUseTime 60f/0.75f, Blocks.java:3032) -- power-only first pass, so the folded efficiency is the min over the *modeled* consumers (power only).
	# Documented limits: (1) power-only first pass -- the large-cliff-crusher also consumes liquid hydrogen as a booster (1f/60f, Blocks.java:3028) and a graphite item booster (Blocks.java:3030), so the folded efficiency is the min over the *modeled* consumers (power only). (2) shouldConsume gate live (N2201) -- WallCrafterBuild overrides shouldConsume() to return items.get(output) < itemCapacity (WallCrafter.java:226-228, `return items.get(output) < itemCapacity;`); the pure gate reads the frame items count via the shared inventory helper, with the output item and capacity from the catalog; the offload intake is live (N2223), the timerDump dump still waits. (3) updateTile advance live (N2223) -- warmup / eff / lastEfficiency / time / totalTime / offload advance each tick (WallCrafter.java:193-218); still deferred: the live getEfficiency fill (WallCrafter.java:141-180, the advance reads the frame input efficiency_factor, default 0.0), the timerUse booster consume (WallCrafter.java:207-209) and the timerDump dump (WallCrafter.java:220-222, no timer helper in the port), the offload neighbor routing (BuildingComp.java:1001-1013, the port offloads to own inventory only), the updateEffect chance (WallCrafter.java:196-205), and the disabled early return (BuildingComp.java:1954-1957, the advance runs only when enabled). Until the getEfficiency fill lands a live cliff-crusher never accumulates time. (4) No attribute-efficiency / setBars / draw / icons / drawPlanRegion / drawPlace rows -- see DEFERRED. (5) Large-cliff-crusher variant verification pending -- the same driver covers both defs via the catalog consumePower.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_wall_crafter_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float, drill_time: float, output_item: String, item_capacity: int) -> Dictionary:
	# The updateTile advance (WallCrafterBuild.updateTile(),
	# WallCrafter.java:187-223):
	# `warmup = Mathf.approachDelta(warmup, Mathf.num(efficiency > 0), 1f / 40f);`
	# (WallCrafter.java:193), `float eff = getEfficiency(tile.x, tile.y, rotation, dest -> {`
	# (WallCrafter.java:196) with `Mathf.lerp(1f, liquidBoostIntensity, hasLiquidBooster ? optionalEfficiency : 0f)`
	# and `(itemValid ? itemBoostIntensity : 1f)` (WallCrafter.java:205),
	# `boolean itemValid = itemConsumer != null && itemConsumer.efficiency(this) > 0;`
	# (WallCrafter.java:191), `lastEfficiency = eff * timeScale * efficiency;`
	# (WallCrafter.java:211), `if(cons && (time += edelta() * eff) >= drillTime){`
	# (WallCrafter.java:213) with `offload(output);` and `time %= drillTime;`
	# (WallCrafter.java:214-215), `totalTime += edelta() * warmup * (eff <= 0f ? 0f : 1f);`
	# (WallCrafter.java:218). The build fields are
	# `public float time, warmup, totalTime, lastEfficiency;`
	# (WallCrafter.java:184); the class drillTime is
	# `public float drillTime = 150f;` (WallCrafter.java:33) while the
	# defs override it (110f / 48f, Blocks.java:3006/:3020), so
	# drill_time arrives as a parameter from the driver, which
	# reads it from the catalog. The boost intensities are the
	# class defaults `public float liquidBoostIntensity = 1.6f;`
	# (WallCrafter.java:35) and `public float itemBoostIntensity = 1.6f;`
	# (WallCrafter.java:47); neither def overrides them. The Arc
	# formulas, not guesses: approachDelta(from, to, speed) =
	# approach(from, to, Time.delta * speed) with approach =
	# from + clamp(to - from, -speed, speed), lerp = from +
	# (to - from) * progress, num(b) = b ? 1 : 0
	# (Mathf.java:208, 415-425). source_delta is Time.delta in
	# ticks (seconds * 60 through game_source_delta, arc
	# Time.java:26); edelta() = efficiency * delta() with
	# delta() = Time.delta * timeScale (BuildingComp.java:1922-1929).
	# efficiency and optionalEfficiency default 0.0, the Java
	# field defaults (BuildingComp.java:85 `transient float
	# efficiency;` / :87 `transient float optionalEfficiency;`);
	# warmup / time / totalTime default 0.0, the Java
	# build-field defaults (WallCrafter.java:184). The live
	# getEfficiency scan (WallCrafter.java:141-180) has no
	# helper in the port, so the base efficiency arrives as
	# the frame input efficiency_factor (default 0.0, the scan
	# result with no adjacent solid tiles); item_valid
	# (default false) and has_liquid_booster (default false)
	# are frame inputs too. hasLiquidBooster is false for both
	# defs: `hasLiquidBooster = findConsumer(f -> f instanceof ConsumeLiquidBase && f.booster) != null;`
	# (WallCrafter.java:106) and the large def's hydrogen
	# consumer is not .boost() (Blocks.java:3028), so the
	# liquid lerp term is 1.0 live. cons is the N2201 pure
	# gate over the frame items (WallCrafter.java:227,
	# `return items.get(output) < itemCapacity;`); Java
	# short-circuits the time advance on cons, so with a full
	# store time does NOT advance at all, while totalTime
	# still advances (no cons guard) using the already-updated
	# warmup. Deferred, not done here: the timerUse booster
	# consume (WallCrafter.java:207-209) and the timerDump dump
	# (WallCrafter.java:220-222, no timer helper in the port),
	# the offload neighbor routing (BuildingComp.java:1001-1013
	# -- the shared inventory helper falls back to the own
	# inventory, the handleItem path, BuildingComp.java:1014/
	# :860-861), the updateEffect chance (WallCrafter.java:
	# 196-205), and the disabled early return
	# (BuildingComp.java:1954-1957, the driver gates the
	# advance on enabled). Until the getEfficiency fill lands
	# a live cliff-crusher never accumulates time.
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var optional_efficiency: float = float(frame.get("optional_efficiency", 0.0))
	var efficiency_factor: float = float(frame.get("efficiency_factor", 0.0))
	var item_valid: bool = bool(frame.get("item_valid", false))
	var has_liquid_booster: bool = bool(frame.get("has_liquid_booster", false))
	var warmup: float = float(frame.get("warmup", 0.0))
	var time: float = float(frame.get("time", 0.0))
	var total_time: float = float(frame.get("total_time", 0.0))
	var items: Dictionary = frame.get("items", {})
	var target: float = 1.0 if efficiency > 0.0 else 0.0
	var step: float = source_delta * SOURCE_WALL_CRAFTER_WARMUP_SPEED
	var next_warmup: float = warmup + clampf(target - warmup, -step, step)
	var liquid_multiplier: float = lerpf(1.0, SOURCE_WALL_CRAFTER_LIQUID_BOOST_INTENSITY, optional_efficiency if has_liquid_booster else 0.0)
	var item_multiplier: float = SOURCE_WALL_CRAFTER_ITEM_BOOST_INTENSITY if item_valid else 1.0
	var eff: float = efficiency_factor * liquid_multiplier * item_multiplier
	var edelta: float = efficiency * source_delta * time_scale
	var last_efficiency: float = eff * time_scale * efficiency
	var gate: Dictionary = source_wall_crafter_should_consume_state(frame, output_item, item_capacity)
	var cons: bool = bool(gate.get("should_consume", true))
	var next_time: float = time
	var next_items: Dictionary = items
	var offloaded: bool = false
	if cons:
		next_time = time + edelta * eff
		if next_time >= drill_time:
			var offload_state: Dictionary = inventory.offload_item_state(items, output_item)
			next_items = offload_state.get(inventory.SOURCE_DRILL_INVENTORY_DRILL_ITEMS_KEY, items)
			next_time = fmod(next_time, drill_time)
			offloaded = true
	var next_total_time: float = total_time + edelta * next_warmup * (0.0 if eff <= 0.0 else 1.0)
	return {"warmup": next_warmup, "eff": eff, "last_efficiency": last_efficiency, "time": next_time, "total_time": next_total_time, "offloaded": offloaded, "items": next_items}

@warning_ignore("unused_parameter")
static func source_wall_crafter_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the wall-crafter tick wiring every
	# tick (WallCrafterBuild.updateTile(), WallCrafter.java:187,
	# gates on the warmup fold (WallCrafter.java:193, `warmup = Mathf.approachDelta(warmup, Mathf.num(efficiency > 0), 1f / 40f);`), so the warmup advance follows the folded efficiency; no placed-buildings driver ticks WallCrafter blocks, so this driver is the placed-wall-crafter tick): each placed WallCrafter build gets its frame keys refreshed from the live rules, so the frame's cheating flag tracks team.rules().cheat and the consumption machinery skips consumption for a cheating team. The frame is bound at placement; a sprite that somehow lacks one gets it bound here instead of crashing the loop.
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
		if not _is_wall_crafter_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_wall_crafter_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_wall_crafter_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a wall crafter with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the warmup fold (WallCrafter.java:193)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a wall crafter does not take the early return. A wall crafter with no power consumer is untouched: the tick models no other consumers yet (the liquid hydrogen + graphite boosters wait for their own slices), and WallCrafterBuild overrides shouldConsume() to return items.get(output) < itemCapacity (WallCrafter.java:226-228) -- N2201 feeds the live gate to the machinery (the pure gate is source_wall_crafter_should_consume_state, fed the frame plus the catalog output item and itemCapacity); the N2170 RED decision is resolved. The gate has no enabled term (Java returns the bare capacity comparison); the outer guard below already runs the machinery only when enabled. productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var output_item: String = str(block.properties.get("output", "sand"))
			var item_capacity: int = int(block.properties.get("itemCapacity", 10))
			var gate: Dictionary = source_wall_crafter_should_consume_state(frame, output_item, item_capacity)
			var should_consume: bool = bool(gate.get("should_consume", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_wall_crafter_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		# N2223: the updateTile advance runs after consumption,
		# like Java's Building.update() (BuildingComp.java:2274
		# updateConsumption(), then the updateTile gate
		# `if(enabled || !block.noUpdateDisabled){` at
		# BuildingComp.java:2276-2277; noUpdateDisabled defaults
		# false, Block.java:170, so Java runs updateTile even
		# when disabled -- in Java a disabled wall crafter's
		# warmup DECAYS toward 0 (efficiency is zeroed by the
		# disabled early return, BuildingComp.java:1954-1957)
		# and time freezes (edelta() is 0). The port keeps the
		# enabled gate below as a pragmatic choice (the N2195
		# coordinator-fix precedent): the driver skips the
		# consumption fold when disabled, so the frame
		# efficiency goes stale and running the advance on it
		# would charge warmup/time from a stale efficiency.
		# The driver-wide disabled-early-return slice
		# (deferred in the N2223 register) removes this gate
		# for all families. super.updateTile() is an empty
		# no-op (BuildingComp.java:2010-2012), so the driver
		# owes it nothing. The source delta is Time.delta in
		# ticks: game_source_delta(game, seconds) is seconds *
		# 60 (arc Time.java:26), never raw seconds. timeScale
		# reads live from the sprite meta, default 1.0
		# (BuildingComp.java:98 `private transient float
		# timeScale = 1f, timeScaleDuration;`). drillTime /
		# output / itemCapacity come from the catalog per def
		# (cliff-crusher 110f / sand / 10, large 48f / sand /
		# 20; Blocks.java:3006/:3020/:3009/:3023/:3031).
		if bool(frame.get("enabled", true)):
			var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
			var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
			var drill_time: float = float(block.properties.get("drillTime", SOURCE_WALL_CRAFTER_DRILL_TIME_DEFAULT))
			var advance_output_item: String = str(block.properties.get("output", "sand"))
			var advance_item_capacity: int = int(block.properties.get("itemCapacity", 10))
			var advanced: Dictionary = source_wall_crafter_update_tile_advance_state(frame, source_delta, time_scale, drill_time, advance_output_item, advance_item_capacity)
			frame["warmup"] = advanced["warmup"]
			frame["eff"] = advanced["eff"]
			frame["last_efficiency"] = advanced["last_efficiency"]
			frame["time"] = advanced["time"]
			frame["total_time"] = advanced["total_time"]
			frame["offloaded"] = advanced["offloaded"]
			frame["items"] = advanced["items"]
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
