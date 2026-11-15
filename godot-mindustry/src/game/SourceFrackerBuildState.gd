extends RefCounted
class_name SourceFrackerBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const source_content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const source_solid_pump_state := preload("res://src/game/SourceSolidPumpBuildState.gd")
const inventory := preload("res://src/game/SourceDrillInventoryRuntimeState.gd")

# The Fracker implementation (Fracker.java:7, `public class
# Fracker extends SolidPump{`): oil-extractor (consumePower 3f,
# pumpAmount 0.25f, size 3, liquidCapacity 40f, attribute oil,
# itemUseTime 60f, result oil, consumeItem sand, consumeLiquid
# water 0.15f). The only Fracker block in the game
# (Blocks.java:2964-2979). FrackerBuild extends SolidPumpBuild,
# but the N2150 solid-pump driver only ticks the SolidPump
# implementation (SOURCE_SOLID_PUMP_BUILD_IMPLEMENTATIONS is
# ["SolidPump"]), so this driver is the fracker tick. The driver
# uses its own family frame key ("source_fracker_building", the
# turret precedent); the solid-pump per-family frame
# ("source_solid_pump_building") stays untouched, and this slice
# adds the fracker key to N2142's
# SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back
# finds it.
const SOURCE_FRACKER_BUILD_IMPLEMENTATIONS := ["Fracker"]
const SOURCE_FRACKER_BUILDING_META_KEY := "source_fracker_building"
# Def constants for the only Fracker def (oil-extractor,
# Blocks.java:2964-2978): the result liquid is oil
# (`result = Liquids.oil;`, Blocks.java:2966 -- the class
# default is water, `public Liquid result =
# Liquids.water;`, SolidPump.java:22) and the liquid
# capacity is 40f (`liquidCapacity = 40f;`,
# Blocks.java:2971 -- the class default is -1f, `public
# float liquidCapacity = -1f;`, Block.java:77). The catalog
# carries neither property for the oil-extractor, so both
# are def constants (the N2190 fogRadius / N2199
# transportTime precedent).
const SOURCE_FRACKER_RESULT_LIQUID := "oil"
const SOURCE_FRACKER_LIQUID_CAPACITY := 40.0
# The oil-extractor def pump amount (Blocks.java:2969,
# `pumpAmount = 0.25f;`, overriding the Pump class default
# 0.2f, Pump.java:20, `public float pumpAmount = 0.2f;`):
# the driver passes it to the reused N2220 SolidPump pure
# function for super.updateTile() (Fracker.java:37).
const SOURCE_FRACKER_PUMP_AMOUNT := 0.25
# The oil-extractor def item use time (Blocks.java:2974,
# `itemUseTime = 60f;`, overriding the Fracker class default
# 100f, Fracker.java:8, `public float itemUseTime = 100f;`):
# the accumulator threshold at which updateTile consumes
# one sand (Fracker.java:32-35).
const SOURCE_FRACKER_ITEM_USE_TIME := 60.0
# The sand consume item (Blocks.java:2976, `consumeItem(
# Items.sand);`): consume() removes one sand via
# ConsumeItems.trigger (ConsumeItems.java:44-48).
const SOURCE_FRACKER_CONSUME_ITEM := "sand"
# The water consume liquid (Blocks.java:2978,
# `consumeLiquid(Liquids.water, 0.15f);`): 0.15f PER FRAME
# (= 9/s), not /60f -- the def writes the bare number,
# unlike the /60f defs (e.g. nitrogen 10f/60f). The def
# sets no multiplier (Block.java:1127-1129, `return consume(
# new ConsumeLiquid(liquid, amount));`), so the default
# multiplier 1f (Consume.java:18, `public Floatf<Building>
# multiplier = b -> 1f;`) applies.
const SOURCE_FRACKER_CONSUME_LIQUID := "water"
const SOURCE_FRACKER_CONSUME_LIQUID_AMOUNT := 0.15
# Fracker.java:41, the warmup lerpDelta rate `0.02f` (the
# same rate as SolidPump.java:130/134).
const SOURCE_FRACKER_WARMUP_RATE := 0.02

static func _is_fracker_build_implementation(implementation: String) -> bool:
	return SOURCE_FRACKER_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_fracker_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The fracker tick wires the frame keys the consumption
	# path reads (the N2148 turret pattern): block_implementation
	# is the block's implementation (Fracker.java:7, `public
	# class Fracker extends SolidPump{`), team_id and rules_state
	# are what Java reads as b.team and state.rules, and cheating
	# is the team's live TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's fracker
	# skips consumption like Java's updateConsumption
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
	# for this fracker (N2125); the tick preserves a disabled
	# fracker instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	# The frame carries the Building.items ItemModule
	# (frame["items"], Dictionary keyed by item name, the factory
	# precedent SourceFactoryBuildState.gd:89-101, the Separator
	# N2222 precedent); the tick preserves the held items instead
	# of resetting them -- no live intake fills them yet, so the
	# consume() in the updateTile advance (N2224) reads the frame
	# as-is.
	if not frame.has("items"):
		frame["items"] = {}
	return frame

static func _initial_frame() -> Dictionary:
	# The frame carries the Building.liquids LiquidModule
	# (frame["liquids"], a Dictionary in the
	# SourceLiquidModuleState shape, default {}): the
	# shouldConsume gate reads the result amount from it
	# (SolidPump.java:118, `return liquids.get(result) <
	# liquidCapacity - 0.01f;`). The driver syncs the live
	# sprite-meta store into the frame each tick; the pump
	# advance (N2224) fills it each tick from the updateTile
	# advance (Fracker.java:30-44 / SolidPump.java:121-141);
	# the gate reads the store as-is. The frame also carries
	# the Building.items ItemModule (frame["items"], Dictionary
	# keyed by item name, default {}): the fracker has items
	# (`hasItems = true;`, Fracker.java:11) and consume()
	# removes one sand from it (Fracker.java:33); no live
	# intake fills the items yet, so the advance reads the
	# frame as-is.
	return {"liquids": {}, "items": {}}

static func source_fracker_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the fracker frame meta key
	# ("source_fracker_building"). A Fracker sprite gets a
	# frame bound with the liquids + items keys ({} by default);
	# the live-loop tick fills its other keys every tick. Any other
	# block, or an already-bound sprite, binds nothing.
	if block == null or not _is_fracker_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_FRACKER_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_FRACKER_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_FRACKER_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_fracker_should_consume_state(frame: Dictionary, result_liquid: int, liquid_capacity: float) -> Dictionary:
	# FrackerBuild does NOT override shouldConsume (Fracker.java has no shouldConsume at all; Fracker extends SolidPump, Fracker.java:7, `public class Fracker extends SolidPump{`, and FrackerBuild extends SolidPumpBuild, Fracker.java:26, `public class FrackerBuild extends SolidPumpBuild{`), so it inherits SolidPumpBuild.shouldConsume verbatim (SolidPump.java:117, `public boolean shouldConsume(){` with `return liquids.get(result) < liquidCapacity - 0.01f;`, SolidPump.java:118): the fracker consumes only while its held result amount is below the liquid capacity minus 0.01f. The default (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`) does NOT apply here. Unlike the Separator/Drill gates this one has NO `&& enabled` -- Java returns the bare capacity comparison, so the pure gate does NOT read frame["enabled"] at all (the driver already runs the machinery only when enabled). The result liquid arrives as its catalog id (resolved by the driver from liquid_id_by_name with the def constant "oil", `result = Liquids.oil;`, Blocks.java:2966; the class default is water, `public Liquid result = Liquids.water;`, SolidPump.java:22) and the capacity as the def constant 40f (`liquidCapacity = 40f;`, Blocks.java:2971; the class default is -1f, `public float liquidCapacity = -1f;`, Block.java:77) -- the catalog carries neither property for the oil-extractor. The amount comes from the shared liquid module helper (SourceLiquidModuleState.source_get_state, reused through a preload, NOT re-implemented) over the frame liquids key (the Building.liquids LiquidModule dict, default {} for a frame bound before this slice, amount 0.0 when the store has no entry for the result -- Java's liquids.get returns 0.0 for a liquid never added). When the gate is false updateConsumption forces efficiency to zero (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`).
	var liquids: Dictionary = frame.get("liquids", {})
	var result_amount: float = 0.0
	if liquids.has("liquids") and result_liquid >= 0 and result_liquid < int(liquids["liquids"].size()):
		result_amount = float(source_liquid_module_state.source_get_state(liquids, result_liquid).get("amount", 0.0))
	return {"should_consume": result_amount < liquid_capacity - 0.01, "result_amount": result_amount}

static func source_fracker_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40,
	# `return build.power.status;`): the power consumer's
	# efficiency is the building's live power.status, and the
	# first pass folds it into the min efficiency
	# (BuildingComp.java:1969-1976, `for(var cons : block.
	# nonOptionalConsumers){` / `minEfficiency = Math.min(
	# minEfficiency, result);`). The graph update stamps
	# frame["power_status"] each tick (N2142); a missing stamp
	# folds to 1.0 before the first graph update, the assembler
	# fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`).
	# A block with no power consumer contributes no row. The
	# power consumer counts toward hasConsumers
	# (Block.java:1449, `hasConsumers = consumers.length > 0;`),
	# so a fracker does not take the early return. The fracker
	# accumulator follows the folded efficiency
	# (Fracker.java:38, `accumulator += delta() * efficiency;`),
	# and its super.updateTile() runs the solid-pump speed fold
	# (SolidPump.java:121, `float maxPump = Math.min(liquidCapacity - typeLiquid(), pumpAmount * delta() * fraction * efficiency);`).
	# Documented limits: (1) power + liquid first pass -- the
	# liquid row live (N2255): the water consumer (0.15f per
	# frame, Blocks.java:2978) folds into the min efficiency
	# with the power row, and the second pass removes amount
	# * edelta * multiplier each tick (ConsumeLiquid.java:
	# 37-39). The item (sand) consumer (Blocks.java:2976)
	# and the water-attribute / validTiles / boost fraction
	# (SolidPump.java:118, 137-147, inherited via
	# super.updateTile()) wait for their own slices, so the
	# folded efficiency is the min over the *modeled*
	# consumers (power + water). (2) shouldConsume gate live (N2207)
	# -- FrackerBuild inherits
	# SolidPumpBuild.shouldConsume() (SolidPump.java:117-119,
	# `return liquids.get(result) < liquidCapacity - 0.01f;`);
	# the pure gate (source_fracker_should_consume_state)
	# feeds should_consume to the machinery from the frame
	# liquids amount for the def result (oil) and the def
	# capacity (40f). The pump advance (N2224) fills the oil
	# store each tick (the updateTile advance,
	# Fracker.java:30-44 / SolidPump.java:121-141). (3)
	# updateTile advance live (N2224) -- accumulator /
	# itemUseTime consume / super.updateTile()
	# (Fracker.java:30-44) and warmup / pumpTime / lastPump /
	# maxPump / fraction (SolidPump.java:121-141, via the
	# reused N2220 pure function) advance each tick from
	# explicit fraction inputs (frame valid_tiles / boost /
	# attribute_env, default 0f); still deferred: the
	# else-branch dumpLiquid(result) (Fracker.java:43), the
	# sand intake (nothing fills frame["items"] live yet),
	# and the live onProximityUpdate fill
	# (SolidPump.java:150-159).
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_fracker_liquid_consumer_row_state(frame: Dictionary, has_liquid_consumer: bool, liquid_id: int, amount: float, source_delta: float, time_scale: float, efficiency_scale: float, multiplier: float = 1.0) -> Dictionary:
	# ConsumeLiquid.efficiency (ConsumeLiquid.java:42-47):
	# `float ed = build.edelta() * build.efficiencyScale();`
	# `if(ed <= 0.00000001f) return 0f;`
	# `return Math.min(build.liquids.get(liquid) / (amount * ed * multiplier.get(build)), 1f);`
	# The first pass assumes efficiency 1f (BuildingComp.java:1965, `efficiency = optionalEfficiency = 1f;`), so edelta() = delta() = Time.delta * timeScale (`return Time.delta * timeScale;`, BuildingComp.java:1922-1924; `return efficiency * delta();`, BuildingComp.java:1927-1929 -- with efficiency 1f the two coincide). The def sets no multiplier (Block.java:1127-1129, `return consume(new ConsumeLiquid(liquid, amount));`), so the default multiplier 1f applies (`public Floatf<Building> multiplier = b -> 1f;`, Consume.java:18); the multiplier stays an explicit parameter (default 1.0) so the formula stays Java-exact. The liquid amount comes from the shared liquid module helper (SourceLiquidModuleState.source_get_state, reused through a preload, NOT re-implemented) over the frame liquids key, with the N2207 gate guard (frame has "liquids", id in bounds; amount 0.0 when the store has no entry for the liquid -- Java's liquids.get returns 0.0 for a liquid never added). The row shape mirrors the power row: {"has_liquid_row": bool, "row": {"result": float, "is_power": false}} -- is_power false, so the shared fold sets shouldConsumePower=false when the row is <= 1e-7 (BuildingComp.java:1972-1973, `if(cons != block.consPower && result <= 0.0000001f){` / `shouldConsumePower = false;`). A block with no liquid consumer contributes no row (the N2253 launch-pad precedent: launch-pad has no liquid consumer, advanced-launch-pad has oil).
	if not has_liquid_consumer:
		return {"has_liquid_row": false, "row": {}}
	var liquids: Dictionary = frame.get("liquids", {})
	var liquid_amount: float = 0.0
	if liquids.has("liquids") and liquid_id >= 0 and liquid_id < int(liquids["liquids"].size()):
		liquid_amount = float(source_liquid_module_state.source_get_state(liquids, liquid_id).get("amount", 0.0))
	var edelta: float = source_delta * time_scale
	var ed: float = edelta * efficiency_scale
	var result: float = 0.0
	if ed > 0.00000001:
		result = minf(liquid_amount / (amount * ed * multiplier), 1.0)
	return {"has_liquid_row": true, "row": {"result": result, "is_power": false}}

static func source_fracker_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float, result_liquid_id: int, liquid_capacity: float, pump_amount: float, item_use_time: float) -> Dictionary:
	# The updateTile advance (FrackerBuild.updateTile(),
	# Fracker.java:30-44). Fracker extends SolidPump
	# (Fracker.java:7, `public class Fracker extends SolidPump{`)
	# and FrackerBuild extends SolidPumpBuild (Fracker.java:26,
	# `public class FrackerBuild extends SolidPumpBuild{`), so
	# the frame shares the SolidPumpBuild keys (warmup /
	# pumpTime / lastPump / validTiles / boost,
	# SolidPump.java:90-94) plus the Fracker accumulator
	# (`public float accumulator;`, Fracker.java:27). The
	# fracker has items (`hasItems = true;`, Fracker.java:11).
	# The item use time is the def constant 60f
	# (`itemUseTime = 60f;`, Blocks.java:2974), overriding the
	# class default 100f (`public float itemUseTime = 100f;`,
	# Fracker.java:8). The result liquid is oil (`result =
	# Liquids.oil;`, Blocks.java:2966) and the capacity the
	# def constant 40f (`liquidCapacity = 40f;`,
	# Blocks.java:2971; the class default is -1f, `public
	# float liquidCapacity = -1f;`, Block.java:77).
	# pumpAmount arrives as a parameter (the driver passes the
	# def constant 0.25f, `pumpAmount = 0.25f;`,
	# Blocks.java:2969, overriding the Pump class default,
	# `public float pumpAmount = 0.2f;`, Pump.java:20)
	# because the advance REUSES the N2220 SolidPump pure
	# function for super.updateTile() (Fracker.java:37) -- it
	# does NOT copy the SolidPump logic (the N2221
	# cross-driver preload precedent). Each Java expr below
	# stays on ONE comment line (the N2148 lesson):
	# `if(efficiency > 0){` (Fracker.java:31).
	# `if(accumulator >= itemUseTime){` (Fracker.java:32 -- an `if`, not a `while`: at most one consume per tick).
	# `consume();` (Fracker.java:33 -- `public void consume(){` with `for(Consume cons : block.consumers){` / `cons.trigger(self());`, BuildingComp.java:1911-1915: only ConsumeItems overrides trigger, `build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));`, ConsumeItems.java:44-48; the oil-extractor consumes one sand, `consumeItem(Items.sand);`, Blocks.java:2976, via `consumeItem(item)` -> `return consumeItem(item, 1);`, Block.java:1167-1168, and `return consume(new ConsumeItems(new ItemStack[]{new ItemStack(item, amount)}));`, Block.java:1171-1172, with the default multiplier `public Floatf<Building> multiplier = b -> 1f;`, Consume.java:18; ConsumePower and ConsumeLiquid keep the base no-op `public void trigger(Building build){}`, Consume.java:50. The removal clamps like Java, `amount = Math.min(amount, items[item.id]);`, ItemModule.java:258-263, through the shared inventory helper, the N2222 Separator precedent).
	# `accumulator -= itemUseTime;` (Fracker.java:34).
	# `super.updateTile();` (Fracker.java:37 -- the N2220 pure function: `float fraction = Math.max(validTiles + boost + (attribute == null ? 0 : attribute.env()), 0);` (SolidPump.java:124), `if(efficiency > 0 && typeLiquid() < liquidCapacity - 0.001f){` (SolidPump.java:126), `float maxPump = Math.min(liquidCapacity - typeLiquid(), pumpAmount * delta() * fraction * efficiency);` (SolidPump.java:127), `liquids.add(result, maxPump);` (SolidPump.java:128), `lastPump = maxPump / Time.delta;` (SolidPump.java:129), `warmup = Mathf.lerpDelta(warmup, 1f, 0.02f);` (SolidPump.java:130), `warmup = Mathf.lerpDelta(warmup, 0f, 0.02f);` (SolidPump.java:134), `lastPump = 0f;` (SolidPump.java:135), `pumpTime += warmup * edelta();` (SolidPump.java:138), `dumpLiquid(result);` (SolidPump.java:140 -- DEFERRED, covered by the N2220 entry)).
	# `accumulator += delta() * efficiency;` (Fracker.java:38 -- AFTER super.updateTile(), so the consume check above reads last tick's accumulator).
	# `warmup = Mathf.lerpDelta(warmup, 0f, 0.02f);` (Fracker.java:41 -- the else branch decays warmup ITSELF; it does NOT call super.updateTile(), so pumpTime also stands still).
	# `lastPump = 0f;` (Fracker.java:42).
	# `dumpLiquid(result);` (Fracker.java:43 -- DEFERRED, needs neighbor liquid transfer).
	# The Arc formula, not a guess: lerpDelta(from, to,
	# progress) = lerp(from, to, clamp(progress * Time.delta))
	# with lerp = from + (to - from) * progress and clamp(value)
	# = clamp(value, 0, 1) (Mathf.java:401-404, 425-432); it
	# scales by RAW Time.delta, so timeScale touches neither
	# the warmup lerp nor lastPump. delta() = Time.delta *
	# timeScale (`return Time.delta * timeScale;`,
	# BuildingComp.java:1922-1924) and edelta() = efficiency *
	# delta() (`return efficiency * delta();`,
	# BuildingComp.java:1927-1929). source_delta is Time.delta
	# in ticks (seconds * 60 through game_source_delta, arc
	# Time.java:26), never raw seconds (the N2186/N2187/N2191
	# lesson: raw seconds run 60x slow). efficiency defaults
	# 0.0, the Java field default (BuildingComp.java:85
	# `transient float efficiency;`); accumulator / warmup /
	# pumpTime default 0.0, the Java build-field defaults
	# (Fracker.java:27, SolidPump.java:90-91). The fraction
	# inputs are explicit frame keys (valid_tiles / boost /
	# attribute_env, default 0f), read by the reused super
	# advance: the live onProximityUpdate fill
	# (SolidPump.java:150-159) waits for its own slice.
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var accumulator: float = float(frame.get("accumulator", 0.0))
	var warmup: float = float(frame.get("warmup", 0.0))
	var pump_time: float = float(frame.get("pump_time", 0.0))
	var items: Dictionary = (frame.get("items", {}) as Dictionary).duplicate(true)
	var delta: float = source_delta * time_scale
	var max_pump: float = 0.0
	var last_pump: float = 0.0
	var fraction: float = 0.0
	var next_warmup: float = warmup
	var next_pump_time: float = pump_time
	if efficiency > 0.0:
		if accumulator >= item_use_time:
			var removed: Dictionary = inventory.remove_item_state(items, SOURCE_FRACKER_CONSUME_ITEM, 1)
			items = removed.get(inventory.SOURCE_DRILL_INVENTORY_DRILL_ITEMS_KEY, items)
			accumulator -= item_use_time
		var advanced: Dictionary = source_solid_pump_state.source_solid_pump_update_tile_advance_state(frame, source_delta, time_scale, result_liquid_id, liquid_capacity, pump_amount)
		next_warmup = float(advanced["warmup"])
		next_pump_time = float(advanced["pump_time"])
		last_pump = float(advanced["last_pump"])
		max_pump = float(advanced["max_pump"])
		fraction = float(advanced["fraction"])
		accumulator += delta * efficiency
	else:
		next_warmup = lerpf(warmup, 0.0, clampf(SOURCE_FRACKER_WARMUP_RATE * source_delta, 0.0, 1.0))
		last_pump = 0.0
	return {"accumulator": accumulator, "warmup": next_warmup, "pump_time": next_pump_time, "last_pump": last_pump, "max_pump": max_pump, "fraction": fraction, "items": items}

static func source_fracker_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the fracker tick wiring every tick
	# (FrackerBuild.updateTile(), Fracker.java:30, gates on
	# `if(efficiency > 0){` and runs super.updateTile(), so the
	# accumulator and the solid-pump speed read the folded
	# efficiency; the solid-pump driver never ticks Fracker
	# implementations, so this driver is the fracker tick):
	# each placed Fracker build gets its frame keys refreshed
	# from the live rules, so the frame's cheating flag tracks
	# team.rules().cheat and the consumption machinery skips
	# consumption for a cheating team. The frame is bound at
	# placement; a sprite that somehow lacks one gets it bound
	# here instead of crashing the loop.
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
	var liquid_id_by_name: Dictionary = source_content_registry_runtime_state.source_liquid_catalog_state(catalog).get("liquid_id_by_name", {})
	for sprite in source_placed_block_state.source_unique_buildings_state(game).get("buildings", []):
		if not is_instance_valid(sprite) or not sprite is Sprite2D:
			continue
		var block_id: String = str(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
		if not blocks_by_id.has(block_id):
			continue
		var block = blocks_by_id[block_id]
		if not _is_fracker_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_fracker_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_fracker_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The frame carries the Building.liquids LiquidModule
		# (frame["liquids"]): the live store lives on the
		# sprite meta (source_building_liquids, initialized
		# at placement), so the driver syncs the reference
		# into the frame each tick BEFORE the fold, and the
		# pure gate reads the result amount from it while the
		# pure liquid row (N2255) reads the water amount.
		frame["liquids"] = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a fracker with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the accumulator fold (Fracker.java:38)
		# and the super.updateTile() speed fold
		# (SolidPump.java:121) follow it. The power consumer
		# counts toward hasConsumers (Block.java:1449,
		# `hasConsumers = consumers.length > 0;`), so a fracker
		# does not take the early return. A fracker with no power
		# consumer is untouched: the tick models the power +
		# water consumers (N2255 folds the liquid row into the
		# first pass); the item consumer and the
		# water-attribute / validTiles / boost fraction wait for
		# their own slices, and FrackerBuild inherits
		# SolidPumpBuild.shouldConsume() (`return
		# liquids.get(result) < liquidCapacity - 0.01f;`,
		# SolidPump.java:117-119) -- N2207 feeds the live gate
		# to the machinery (the pure gate is
		# source_fracker_should_consume_state, fed the frame
		# plus the resolved result id and the def capacity);
		# the N2153 RED decision is resolved. The gate has no
		# enabled term (Java returns the bare capacity
		# comparison); the outer guard below already runs the
		# machinery only when enabled.
		# productionValid is the canonical true default
		# (SourceBuildingAccessState.production_valid_state()).
		# The source delta is Time.delta in ticks and timeScale
		# reads live from the sprite meta (see the N2224 advance
		# comment below); both are computed once here because
		# the liquid row's first pass needs them too, and the
		# advance below reuses them.
		var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
		var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var result_liquid_id: int = int(liquid_id_by_name.get(SOURCE_FRACKER_RESULT_LIQUID, -1))
			var gate: Dictionary = source_fracker_should_consume_state(frame, result_liquid_id, SOURCE_FRACKER_LIQUID_CAPACITY)
			var should_consume: bool = bool(gate.get("should_consume", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_fracker_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			# The liquid consumer reads live since N2255: a
			# fracker with a liquid consumer folds the pure
			# liquid row into the first pass (ConsumeLiquid.
			# efficiency, ConsumeLiquid.java:42-47), so the
			# folded efficiency is the min over power + water
			# and the shared fold stops power draw when the
			# liquid row is <= 1e-7. The water id resolves
			# from the catalog with the def constant "water"
			# (`consumeLiquid(Liquids.water, 0.15f);`,
			# Blocks.java:2978 -- 0.15f per frame, = 9/s).
			var water_liquid_id: int = int(liquid_id_by_name.get(SOURCE_FRACKER_CONSUME_LIQUID, -1))
			var has_liquid_consumer: bool = bool(block.properties.has("consumeLiquid"))
			var liquid_row: Dictionary = source_fracker_liquid_consumer_row_state(frame, has_liquid_consumer, water_liquid_id, SOURCE_FRACKER_CONSUME_LIQUID_AMOUNT, source_delta, time_scale, float(frame.get("efficiency_scale", 1.0)))
			if bool(liquid_row.get("has_liquid_row", false)):
				required_results.append(liquid_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
			# Second pass (N2255): ConsumeLiquid.update removes
			# `build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));`
			# (ConsumeLiquid.java:37-39), only when update &&
			# efficiency > 0 (`if(update && efficiency > 0){`,
			# BuildingComp.java:1999, with `for(var cons : block.updateConsumers){` / `cons.update(self());` at :2000-2001), and edelta comes from the FOLDED efficiency (`return efficiency * delta();`, BuildingComp.java:1927-1929 -- NOT the first-pass 1f assumption). The AdjacentFactory updates-array precedent (SourceAdjacentFactoryBuildState.gd:382) does not fit: it passes bound RuntimeConsumer actors with update(self_state) methods (N2115/N2116), and this driver is pure-function based with no consumer actors -- so the removal is direct, through the shared liquid module helper (the PayloadLoader source_remove_state precedent), which clamps exactly like Java's LiquidModule.remove (`add(liquid, Math.max(-amount, -liquids[liquid.id]));`, LiquidModule.java:125-128). The multiplier is the default 1f (Consume.java:18), so the removal is amount * folded edelta.
			if should_consume and valid and float(frame.get("efficiency", 0.0)) > 0.0 and has_liquid_consumer and water_liquid_id >= 0:
				var liquids_store: Dictionary = frame.get("liquids", {})
				if liquids_store.has("liquids") and water_liquid_id < int(liquids_store["liquids"].size()):
					var folded_edelta: float = float(frame.get("efficiency", 0.0)) * source_delta * time_scale
					var remove_amount: float = SOURCE_FRACKER_CONSUME_LIQUID_AMOUNT * folded_edelta
					var cache_sums: Array = []
					if liquids_store.get("flow") != null:
						cache_sums.resize(int(liquids_store["liquids"].size()))
						cache_sums.fill(0.0)
					source_liquid_module_state.source_remove_state(liquids_store, water_liquid_id, remove_amount, cache_sums)
		# N2224: the updateTile advance runs after consumption,
		# like Java's Building.update() (BuildingComp.java:2274,
		# `updateConsumption();`, then the updateTile gate
		# `if(enabled || !block.noUpdateDisabled){` at
		# BuildingComp.java:2276-2278; noUpdateDisabled defaults
		# false, Block.java:170, `public boolean noUpdateDisabled = false;`),
		# so a disabled fracker freezes its accumulator /
		# warmup / pumpTime. The source delta is Time.delta in
		# ticks: game_source_delta(game, seconds) is seconds * 60
		# (arc Time.java:26), never raw seconds -- computed once
		# above the consumption block (the liquid row's first
		# pass needs it too) and reused here. timeScale reads
		# live from the sprite meta, default 1.0
		# (BuildingComp.java:98 `private transient float timeScale = 1f, timeScaleDuration;`).
		# The advance reuses the N2220 SolidPump pure function
		# for super.updateTile() (Fracker.java:37) with the
		# oil-extractor pump amount 0.25f (Blocks.java:2969),
		# and removes one sand through the shared inventory
		# helper when the accumulator reaches the def item use
		# time 60f (Blocks.java:2974). The advance mutates the
		# frame liquids store in place (the module dict is a
		# reference to the sprite meta store) and returns the
		# advanced scalars + items, which the driver writes back
		# to the frame.
		if bool(frame.get("enabled", true)):
			var advance_result_id: int = int(liquid_id_by_name.get(SOURCE_FRACKER_RESULT_LIQUID, -1))
			var advanced: Dictionary = source_fracker_update_tile_advance_state(frame, source_delta, time_scale, advance_result_id, SOURCE_FRACKER_LIQUID_CAPACITY, SOURCE_FRACKER_PUMP_AMOUNT, SOURCE_FRACKER_ITEM_USE_TIME)
			frame["accumulator"] = advanced["accumulator"]
			frame["warmup"] = advanced["warmup"]
			frame["pump_time"] = advanced["pump_time"]
			frame["last_pump"] = advanced["last_pump"]
			frame["max_pump"] = advanced["max_pump"]
			frame["fraction"] = advanced["fraction"]
			frame["items"] = advanced["items"]
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
