extends RefCounted
class_name SourceForceProjectorBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")
const source_liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const source_drill_inventory_runtime_state := preload("res://src/game/SourceDrillInventoryRuntimeState.gd")
const source_content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")

# The ForceProjector implementation (ForceProjector.java:30, `public class
# ForceProjector extends Block{`): force-projector (consumePower 4f,
# size 3, radius 101.7f, shieldHealth 750f Blocks override, cooldownNormal 1.5f,
# cooldownLiquid 1.2f, cooldownBrokenBase 0.35f, phaseUseTime 350f,
# phaseRadiusBoost 80f, phaseShieldBoost 400f, sides 6, phaseFabric
# itemConsumer booster, ConsumeCoolant 0.1f). It hasPower=true
# (ForceProjector.java:76, `hasPower = true;`), hasLiquids=true
# and hasItems=true. ForceProjector extends Block, NOT a drill
# or factory, so it cannot reuse an existing frame key; this
# driver uses its own family frame key
# ("source_force_projector_building", the mechanical-pump /
# beam-drill / mend-projector / overdrive-projector precedent), and this slice adds the
# force-projector key to N2142's
# SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back
# finds it. The port has NO SourceForceProjector* files at all
# yet -- no display/runtime state to lean on -- so the missing
# piece is the live power.status -> efficiency driver, which is
# exactly this slice: the warmup fold
# (ForceProjector.java:221, `warmup = Mathf.lerpDelta(warmup, efficiency, 0.1f);`)
# follows the folded efficiency, with radscl following warmup
# (ForceProjector.java:215, `radscl = Mathf.lerpDelta(radscl, broken ? 0f : warmup, 0.05f);`)
# and realRadius folding both
# (ForceProjector.java:280, `return (radius + phaseHeat * phaseRadiusBoost) * radscl;`).
const SOURCE_FORCE_PROJECTOR_BUILD_IMPLEMENTATIONS := ["ForceProjector"]
const SOURCE_FORCE_PROJECTOR_BUILDING_META_KEY := "source_force_projector_building"
# Force-projector def values (Blocks.java:1964-1976, the SINGLE
# def): `shieldHealth = 750f;`, `cooldownNormal = 1.5f;`,
# `cooldownLiquid = 1.2f;`, `cooldownBrokenBase = 0.35f;`,
# `phaseRadiusBoost = 80f;`, `radius = 101.7f;`, `size = 3;`,
# `itemConsumer = consumeItem(Items.phaseFabric).boost();`,
# `consumePower(4f);` -- the DEF wins over the class defaults
# (`public float shieldHealth = 700f;`,
# `public float cooldownNormal = 1.75f;`,
# `public float cooldownLiquid = 1.5f;`, ForceProjector.java:
# 39-41; cooldownBrokenBase 0.35f, radius 101.7f and
# phaseRadiusBoost 80f equal the class values). Class values
# (ForceProjector.java): `public float phaseUseTime = 350f;`
# (:32, the timerUse cadence -- live since N2326, the
# frame-local Interval-equivalent at 350f / timeScale),
# `public float phaseShieldBoost = 400f;` (:37),
# `public int sides = 6;` (:39),
# `public float shieldRotation = 0f;` (:40),
# `public float coolantConsumption = 0.1f;` (:43),
# `public boolean consumeCoolant = true;` (:44). The catalog
# carries neither shieldHealth nor the cooldowns nor the
# radius for this family, so the driver reads these constants
# (the Separator craftTime precedent). The lerp progresses are
# the Java literals (0.1f phaseHeat / 0.05f radscl / 0.1f
# warmup); the coolant heat-capacity fallback is the no-op
# default for the coolant factor (1 + (0.4 - 0.4) * 0.9) = 1
# (ForceProjector.java:233), NOT the Liquid default
# (`public float heatCapacity = 0.5f;`, Liquid.java:42).
const SOURCE_FORCE_PROJECTOR_SHIELD_HEALTH := 750.0
const SOURCE_FORCE_PROJECTOR_COOLDOWN_NORMAL := 1.5
const SOURCE_FORCE_PROJECTOR_COOLDOWN_LIQUID := 1.2
const SOURCE_FORCE_PROJECTOR_COOLDOWN_BROKEN_BASE := 0.35
const SOURCE_FORCE_PROJECTOR_RADIUS := 101.7
const SOURCE_FORCE_PROJECTOR_PHASE_RADIUS_BOOST := 80.0
const SOURCE_FORCE_PROJECTOR_PHASE_SHIELD_BOOST := 400.0
const SOURCE_FORCE_PROJECTOR_SIDES := 6
const SOURCE_FORCE_PROJECTOR_SHIELD_ROTATION := 0.0
# The explosion crash multiplier (ForceProjector.java:45,
# `public float crashDamageMultiplier = 2f;` -- the def does
# not override it, Blocks.java:1964-1976): absorbExplosion
# adds damage * this to buildup (ForceProjector.java:274).
const SOURCE_FORCE_PROJECTOR_CRASH_DAMAGE_MULTIPLIER := 2.0
const SOURCE_FORCE_PROJECTOR_PHASE_USE_TIME := 350.0
const SOURCE_FORCE_PROJECTOR_PHASE_HEAT_LERP_PROGRESS := 0.1
const SOURCE_FORCE_PROJECTOR_RADSCL_LERP_PROGRESS := 0.05
const SOURCE_FORCE_PROJECTOR_WARMUP_LERP_PROGRESS := 0.1
const SOURCE_FORCE_PROJECTOR_COOLANT_HEAT_CAPACITY_FALLBACK := 0.4
# The ConsumeCoolant amount (ForceProjector.java:43,
# `public float coolantConsumption = 0.1f;`, PER FRAME = 6/s;
# the def does not override it) and the filter bounds
# (ConsumeCoolant.java:5, `public float maxTemp = 0.5f,
# maxFlammability = 0.1f;`). The Liquid class default
# heatCapacity (Liquid.java:42, `public float heatCapacity =
# 0.5f;`) fills the catalog prop when the catalog does not
# carry it (the catalog records overrides only -- water
# carries heatCapacity 0.4f, cryofluid 0.9f / temperature
# 0.25f, and nothing else a coolant needs).
const SOURCE_FORCE_PROJECTOR_COOLANT_CONSUMPTION := 0.1
const SOURCE_FORCE_PROJECTOR_COOLANT_MAX_TEMPERATURE := 0.5
const SOURCE_FORCE_PROJECTOR_COOLANT_MAX_FLAMMABILITY := 0.1
const SOURCE_LIQUID_HEAT_CAPACITY_DEFAULT := 0.5

static func _is_force_projector_build_implementation(implementation: String) -> bool:
	return SOURCE_FORCE_PROJECTOR_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_force_projector_is_in_regular_polygon(sides: int, center_x: float, center_y: float, radius: float, rotation: float, point_x: float, point_y: float) -> bool:
	# Intersector.isInRegularPolygon, faithfully ported from
	# Arc (the port has no isInRegularPolygon helper -- grep):
	# `public static boolean isInRegularPolygon(int sides, float cx, float cy, float radius, float rotation, float x, float y){`
	# `s.trns(i * 360f / sides + rotation, radius);`
	# `floatArray.add(cx + s.x, cy + s.y);`
	# `return isInPolygon(floatArray.items, 0, floatArray.size, x, y);`
	# (Intersector.java:111-119), where trns is
	# `public Vec2 trns(float angle, float amount){`
	# `return set(amount, 0).rotate(angle);`
	# (Vec2.java:40-42, degrees -- Vector2.rotated takes
	# radians, hence deg_to_rad) and the test is the
	# float-array isInPolygon ray cast:
	# `public static boolean isInPolygon(float[] polygon, int offset, int count, float x, float y){`
	# `if((yi < y && yj >= y) || (yj < y && yi >= y)){`
	# `if(xi + (y - yi) / (yj - yi) * (polygon[j] - xi) < x) oddNodes = !oddNodes;`
	# (Intersector.java:180-193). The loop-bound trap: Arc
	# fixes n = offset + count - 2 BEFORE the loop and
	# reassigns j = i inside it, so the loop must compare
	# against the FIXED n, not the moving j. The yj != yi
	# guard is the branch condition itself (yi < y <= yj or
	# yj < y <= yi), so the division cannot divide by zero.
	var polygon: Array = []
	for i in range(sides):
		var vertex: Vector2 = Vector2(radius, 0.0).rotated(deg_to_rad(float(i) * 360.0 / float(sides) + rotation))
		polygon.append(center_x + vertex.x)
		polygon.append(center_y + vertex.y)
	var odd_nodes: bool = false
	var n: int = polygon.size() - 2
	var j: int = n
	var i: int = 0
	while i <= n:
		var yi: float = float(polygon[i + 1])
		var yj: float = float(polygon[j + 1])
		if (yi < point_y and yj >= point_y) or (yj < point_y and yi >= point_y):
			var xi: float = float(polygon[i])
			if xi + (point_y - yi) / (yj - yi) * (float(polygon[j]) - xi) < point_x:
				odd_nodes = not odd_nodes
		j = i
		i += 2
	return odd_nodes

static func source_force_projector_coolant_filter_state(liquid_props: Dictionary) -> bool:
	# ConsumeCoolant's filter (ConsumeCoolant.java:12, `this.filter = liquid -> liquid.coolant && (this.allowLiquid && !liquid.gas || this.allowGas && liquid.gas) && liquid.temperature <= maxTemp && liquid.flammability < maxFlammability;`, with `public float maxTemp = 0.5f, maxFlammability = 0.1f;` (:5) and `public boolean allowLiquid = true, allowGas = false;` (:6)): a liquid passes when it is a coolant, not a gas, at most room temperature and barely flammable. The catalog carries overrides only, so a missing prop reads the Liquid class default (Liquid.java: `public boolean coolant = true;` :50, `public boolean gas = false;` :28, `public float temperature = 0.5f;` :40, `public float flammability;` :38, 0f when uninitialized). With those defaults + the catalog overrides only water (temp 0.5, flam 0, heatCapacity 0.4f, Liquids.java:13-14) and cryofluid (temp 0.25f, flam 0, heatCapacity 0.9f, Liquids.java:40-42) pass: slag temp 1.0, oil flam 1.2, neoplasm temp 0.54, arkycite flam 0.4, gallium coolant=false, and the four gases are all excluded.
	var coolant: bool = bool(liquid_props.get("coolant", true))
	var gas: bool = bool(liquid_props.get("gas", false))
	var temperature: float = float(liquid_props.get("temperature", 0.5))
	var flammability: float = float(liquid_props.get("flammability", 0.0))
	return coolant and not gas and temperature <= SOURCE_FORCE_PROJECTOR_COOLANT_MAX_TEMPERATURE and flammability < SOURCE_FORCE_PROJECTOR_COOLANT_MAX_FLAMMABILITY

static func source_force_projector_coolant_heat_capacity_state(liquid_props: Dictionary) -> float:
	# The CURRENT liquid's heatCapacity (ForceProjector.java:230, `liquids.current().heatCapacity`): the catalog carries the override (water 0.4f, cryofluid 0.9f, Liquids.java:14/41) and a missing prop reads the Liquid class default (Liquid.java:42, `public float heatCapacity = 0.5f;`). This is NOT the 0.4f no-op fallback: the scale formula subtracts 0.4f, so 0.4f is the no-op value the driver passes only when there is no coolant at all (and the coolant branch cannot run then anyway).
	return float(liquid_props.get("heatCapacity", SOURCE_LIQUID_HEAT_CAPACITY_DEFAULT))

static func source_force_projector_liquid_catalog_props_state(catalog: Object) -> Dictionary:
	# The catalog liquids in content order (the ConsumeLiquidFilter.getConsumed scan order, ConsumeLiquidFilter.java:68-74, `var liqs = content.liquids();` / `for(int i = 0; i < liqs.size; i++){`), with the filter + heatCapacity props per liquid id: the catalog Liquid objects already apply the Java defaults to their typed fields (MindustryLiquid: gas false, temperature 0.5, flammability 0.0, heat_capacity 0.5), and coolant reads the properties override (gallium false, Liquids.java:72) with the Liquid default true (Liquid.java:50).
	var props_by_id := {}
	var liquid_order: Array = []
	var liquid_index := 0
	for liquid in catalog.call("get_many", "liquid"):
		props_by_id[liquid_index] = {"coolant": bool(liquid.properties.get("coolant", true)), "gas": bool(liquid.gas), "temperature": float(liquid.temperature), "flammability": float(liquid.flammability), "heatCapacity": float(liquid.heat_capacity)}
		liquid_order.append(liquid_index)
		liquid_index += 1
	return {"liquid_props_by_id": props_by_id, "liquid_order": liquid_order}

static func source_force_projector_coolant_consumer_row_state(frame: Dictionary, has_coolant_consumer: bool, liquid_props_by_id: Dictionary, liquid_order: Array, amount: float, source_delta: float, time_scale: float, efficiency: float, multiplier: float = 1.0) -> Dictionary:
	# ConsumeLiquidFilter.efficiency (ConsumeLiquidFilter.java:50-55, `float ed = build.edelta();` / `if(ed <= 0.00000001f) return 0f;` / `return liq != null ? Math.min(build.liquids.get(liq) / (amount * ed * multiplier.get(build)), 1f) : 0f;`): NOTE ed is build.edelta() with NO efficiencyScale factor -- unlike ConsumeLiquid.efficiency (ConsumeLiquid.java:42-47, `float ed = build.edelta() * build.efficiencyScale();`). edelta() is `return efficiency * delta();` (BuildingComp.java:1927-1929) and delta() is `return Time.delta * timeScale;` (BuildingComp.java:1922-1924), so ed = efficiency * source_delta * time_scale; in the first pass efficiency is assumed 1f (BuildingComp.java:1965, `efficiency = optionalEfficiency = 1f;`), and the driver re-evaluates with the folded efficiency for the updateTile check (ForceProjector.java:228). getConsumed (ConsumeLiquidFilter.java:63-76) prefers the CURRENT liquid (`if(filter.get(build.liquids.current()) && build.liquids.currentAmount() > 0){`), else the first liquid in content order that passes the filter and has amount > 0 (`if(filter.get(liq) && build.liquids.get(liq) > 0){`), else null -- and efficiency is 0 when getConsumed is null. The filter is ConsumeCoolant's (ConsumeCoolant.java:12), via source_force_projector_coolant_filter_state. The multiplier defaults to 1f (Consume.java:18, `public Floatf<Building> multiplier = b -> 1f;`); the constructor call sets none (ForceProjector.java:85). The row is OPTIONAL (`.boost().update(false);`, ForceProjector.java:85, boost is `return optional(true, true);`, Consume.java:33-35), so the driver folds it into the optional pass (`for(var cons : block.optionalConsumers){`, BuildingComp.java:1979-1981, `optionalEfficiency = Math.min(optionalEfficiency, cons.efficiency(self()));`), NOT the min efficiency -- and update(false) means the second pass never consumes it (BuildingComp.java:1999-2000 runs updateConsumers only); Java consumes by hand in updateTile (ForceProjector.java:227-231). The held amount reads through the shared liquid module helper (SourceLiquidModuleState.source_get_state) over the frame liquids key (the Building.liquids LiquidModule dict, default {} for a frame bound before this slice, amount 0.0 when the store has no entry for the liquid -- Java's liquids.get returns 0.0 for a liquid never added), with the Fracker guard (SourceFrackerBuildState.gd:221, `liquids.has("liquids")` + bounds check). A block with no coolant consumer contributes no row.
	if not has_coolant_consumer:
		return {"has_coolant_row": false, "row": {}, "consumed_liquid": null}
	var liquids: Dictionary = frame.get("liquids", {})
	var consumed_liquid: Variant = null
	if liquids.has("liquids"):
		var current_id: int = int(liquids.get("current", -1))
		if current_id >= 0 and current_id < int(liquids["liquids"].size()) and liquid_props_by_id.has(current_id):
			if source_force_projector_coolant_filter_state(liquid_props_by_id[current_id]) and float(source_liquid_module_state.source_get_state(liquids, current_id).get("amount", 0.0)) > 0.0:
				consumed_liquid = current_id
		if consumed_liquid == null:
			for liquid_id in liquid_order:
				var ordered_id: int = int(liquid_id)
				if ordered_id < 0 or ordered_id >= int(liquids["liquids"].size()) or not liquid_props_by_id.has(ordered_id):
					continue
				if source_force_projector_coolant_filter_state(liquid_props_by_id[ordered_id]) and float(source_liquid_module_state.source_get_state(liquids, ordered_id).get("amount", 0.0)) > 0.0:
					consumed_liquid = ordered_id
					break
	if consumed_liquid == null:
		return {"has_coolant_row": true, "row": {"result": 0.0, "is_power": false}, "consumed_liquid": null}
	var held: float = float(source_liquid_module_state.source_get_state(liquids, int(consumed_liquid)).get("amount", 0.0))
	var ed: float = efficiency * source_delta * time_scale
	if ed <= 0.00000001:
		return {"has_coolant_row": true, "row": {"result": 0.0, "is_power": false}, "consumed_liquid": consumed_liquid}
	var result: float = min(held / (amount * ed * multiplier), 1.0)
	return {"has_coolant_row": true, "row": {"result": result, "is_power": false}, "consumed_liquid": consumed_liquid}

static func source_force_projector_item_consumer_row_state(frame: Dictionary, has_item_consumer: bool, stacks: Array, multiplier: float = 1.0) -> Dictionary:
	# ConsumeItems.efficiency (ConsumeItems.java:51-53, `return build.consumeTriggerValid() || build.items.has(items, multiplier.get(build)) ? 1f : 0f;`): BINARY 1/0 -- NOT a ratio like ConsumeLiquid. consumeTriggerValid() base returns false (BuildingComp.java:764-766, `public boolean consumeTriggerValid(){` / `return false;`, and no ForceProjector override -- grep), so the row is 1.0 only when the frame holds every stack: items.has(ItemStack[], float) (ItemModule.java:153-158, `if(stack.item.id >= items.length || !has(stack.item, Math.round(stack.amount * multiplier))) return false;`) requires EVERY stack to hold round(amount * multiplier), with has(item, amount) = get(item) >= amount (ItemModule.java:126-128, `return get(item) >= amount;`). The count reads through the shared drill inventory helper (SourceDrillInventoryRuntimeState.item_count) over the frame items key (the Building.items ItemModule dict, keyed by item name, default {} for a frame bound before this slice, count 0 when the store has no entry for the item -- Java's items.get returns 0 for an item never added). consumeItem(item) is ItemStack(item, 1) (Block.java:1167-1168, `public ConsumeItems consumeItem(Item item){` / `return consumeItem(item, 1);`), so the force-projector def's single stack is [{"item": "phase-fabric", "amount": 1}] (Blocks.java:1974, `itemConsumer = consumeItem(Items.phaseFabric).boost();`). The multiplier defaults to 1f (Consume.java:18, `public Floatf<Building> multiplier = b -> 1f;`); the def sets none. The row is OPTIONAL (.boost() is `return optional(true, true);`, Consume.java:33-35), so the driver folds it into the optional pass (`for(var cons : block.optionalConsumers){`, BuildingComp.java:1980-1981, `optionalEfficiency = Math.min(optionalEfficiency, cons.efficiency(self()));`), capped by minEfficiency (BuildingComp.java:1986, `optionalEfficiency = Math.min(optionalEfficiency, minEfficiency);`), NOT the min efficiency -- and it never touches shouldConsumePower (BuildingComp.java:1972-1973 runs only over nonOptionalConsumers). phaseValid reads the row DIRECTLY (ForceProjector.java:207, `boolean phaseValid = itemConsumer != null && itemConsumer.efficiency(this) > 0;`), not through optionalEfficiency, so the row also reports item_valid = result > 0 for the advance wiring. The timer-gated consume() (ForceProjector.java:211-213, `if(phaseValid && !broken && timer(timerUse, phaseUseTime / timeScale) && efficiency > 0){` / `consume();`, phaseUseTime 350f, ForceProjector.java:32) is LIVE since N2326: the timer pure (source_force_projector_timer_use_state, the frame-local Interval-equivalent at 350f / timeScale) supplies consume_tick to the advance, and when the advance reports consumed the driver removes the stack through ConsumeItems.trigger (ConsumeItems.java:44-48, `build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));`) via the shared inventory helper -- this row itself still removes nothing (the row is the efficiency read, not the consume). A block with no item consumer contributes no row.
	if not has_item_consumer:
		return {"has_item_row": false, "row": {}, "item_valid": false}
	var items: Dictionary = frame.get("items", {})
	var result: float = 1.0
	for stack in stacks:
		if not (stack is Dictionary):
			continue
		var required: int = int(round(float(stack.get("amount", 0)) * multiplier))
		if source_drill_inventory_runtime_state.item_count(items, str(stack.get("item", ""))) < required:
			result = 0.0
			break
	return {"has_item_row": true, "row": {"result": result, "is_power": false}, "item_valid": result > 0.0}

static func source_force_projector_timer_use_state(elapsed: float, source_delta: float, time_scale: float, duration: float) -> Dictionary:
	# The frame-local Interval-equivalent for the timerUse
	# cadence (TimerComp.timer, TimerComp.java:10-13, each
	# exact expr on ONE comment line, the N2148 lesson):
	# `if(Float.isInfinite(time)) return false;`
	# `return timer.get(index, time);`
	# Interval.get resets times[id] = Time.time on fire
	# (arc Interval.java:20-26):
	# `boolean got = check(id, time);`
	# `if(got) times[id] = Time.time;`
	# and check compares Time.time - times[id] >= time (arc
	# Interval.java:28-30):
	# `return Time.time - times[id] >= time || Time.time < times[id];`
	# Time.time counts TICKS (arc Time.java:75):
	# `timeRaw += delta;`
	# The port has no global tick clock at the driver layer, so
	# the elapsed clock is frame-local (frame["timer_use_
	# elapsed"], accumulated by the tick delta every tick the
	# advance runs, unconditionally -- mirroring Time.time,
	# which grows even while the gate is closed): elapsed +=
	# source_delta unconditionally (source_delta is the
	# UNSCALED Time.delta in ticks -- game_source_delta is
	# seconds * 60, never scaled by timeScale -- so the
	# frame clock mirrors the global Time.time exactly);
	# consume_tick = elapsed >= threshold, where the
	# threshold is duration / time_scale -- Java DIVIDES
	# phaseUseTime by timeScale here (ForceProjector.java:
	# 211), unlike the advances-12 literal timers (the
	# N2290 lesson cuts the other way here: do not invent
	# a literal threshold); timer_elapsed_after RESETS to
	# 0.0 on fire (a reset, not a subtraction like the
	# Fracker accumulator); a non-positive time_scale is a
	# defensive guard (never fires, threshold INF --
	# the clock still accumulates). The Java call is
	# (ForceProjector.java:211-213):
	# `if(phaseValid && !broken && timer(timerUse, phaseUseTime / timeScale) && efficiency > 0){`
	# `consume();`
	# with `public final int timerUse = timers++;`
	# (ForceProjector.java:31) and `public float phaseUseTime = 350f;`
	# (ForceProjector.java:32). The timer ONLY supplies
	# consume_tick -- the gate (phaseValid / !broken /
	# efficiency > 0) stays INSIDE the N2235 advance, so a
	# timer fire alone never consumes. time_scale defaults
	# 1f (BuildingComp.java:98):
	# `private transient float timeScale = 1f, timeScaleDuration;`
	# consume() itself (BuildingComp.java:1911-1915):
	# `for(Consume cons : block.consumers){`
	# `cons.trigger(self());`
	# removes 1 phaseFabric on the single def only:
	# `itemConsumer = consumeItem(Items.phaseFabric).boost();`
	# (Blocks.java:1974; consumeItem(item) is a stack of 1,
	# Block.java:1167-1168) via ConsumeItems.trigger
	# (ConsumeItems.java:44-48):
	# `build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));`
	# clamped by ItemModule.remove (ItemModule.java:258-263):
	# `amount = Math.min(amount, items[item.id]);`
	# ConsumePower / ConsumeCoolant do not override trigger
	# (Consume.java:50, `public void trigger(Building build){}`),
	# so consume() removes nothing for them. Documented
	# deviations: (1) first fire -- Java fires (nearly)
	# immediately after placement when the gate first opens
	# (the global Time.time is already large vs a fresh
	# Interval times[id] = 0); the frame-local clock delays
	# the first fire by a full interval (350f/time_scale).
	# It cannot be fixed without a global clock -- it waits
	# for a timer-infra slice if exact first-fire timing is
	# ever needed. (2) gate-closed reset -- Java
	# short-circuits before timer() when phaseValid / !broken
	# fails, so the Interval keeps its old stamp and fires at
	# once when the gate reopens; the port computes the timer
	# every enabled tick and resets the clock on fire even
	# when the advance gate is closed, so a reopened gate may
	# wait up to a full interval. (3) The clock accumulates
	# on enabled ticks only (the port's enabled-gate
	# pragmatic choice, the N2195 precedent), while Java's
	# Time.time grows even while disabled.
	var threshold: float = INF if time_scale <= 0.0 else duration / time_scale
	var accumulated: float = elapsed + source_delta
	var consume_tick: bool = accumulated >= threshold
	var timer_elapsed_after: float = 0.0 if consume_tick else accumulated
	return {"consume_tick": consume_tick, "timer_elapsed_after": timer_elapsed_after, "threshold": threshold}

static func source_force_projector_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float, building_x: float, building_y: float, bullets: Array, consume_tick: bool, item_consumer_present: bool = false, item_consumer_efficiency: float = 0.0, coolant_present: bool = false, coolant_efficiency: float = 0.0, coolant_heat_capacity: float = SOURCE_FORCE_PROJECTOR_COOLANT_HEAT_CAPACITY_FALLBACK) -> Dictionary:
	# The updateTile advance (ForceBuild.updateTile(), ForceProjector.java:207-268), the pure frame advance -- the build fields are `public boolean broken = true;` (ForceProjector.java:167 -- broken defaults TRUE, a fresh shield starts broken and clears on the first tick once buildup <= 0) and `public float buildup, radscl, hit, warmup, phaseHeat;` (ForceProjector.java:168), and the advance follows the Java lines in order (each exact expr on ONE comment line, the N2148 lesson):
	# `boolean phaseValid = itemConsumer != null && itemConsumer.efficiency(this) > 0;`
	# `phaseHeat = Mathf.lerpDelta(phaseHeat, Mathf.num(phaseValid), 0.1f);`
	# `if(phaseValid && !broken && timer(timerUse, phaseUseTime / timeScale) && efficiency > 0){`
	# `consume();`
	# `radscl = Mathf.lerpDelta(radscl, broken ? 0f : warmup, 0.05f);`
	# `if(Mathf.chanceDelta(buildup / shieldHealth * 0.1f)){`
	# `warmup = Mathf.lerpDelta(warmup, efficiency, 0.1f);`
	# `if(buildup > 0){`
	# `float scale = !broken ? cooldownNormal : cooldownBrokenBase;`
	# `if(coolantConsumer != null){`
	# `if(coolantConsumer.efficiency(this) > 0){`
	# `coolantConsumer.update(this);`
	# `scale *= (cooldownLiquid * (1f + (liquids.current().heatCapacity - 0.4f) * 0.9f));`
	# `buildup -= delta() * scale;`
	# `if(broken && buildup <= 0){`
	# `broken = false;`
	# `if(buildup >= shieldHealth + phaseShieldBoost * phaseHeat && !broken){`
	# `broken = true;`
	# `buildup = shieldHealth;`
	# `if(hit > 0f){`
	# `hit -= 1f / 5f * Time.delta;`
	# `deflectBullets();`
	# `float realRadius = realRadius();`
	# `if(realRadius > 0 && !broken){`
	# `Groups.bullet.intersect(x - realRadius, y - realRadius, realRadius * 2f, realRadius * 2f, shieldConsumer);`
	# `if(bullet.team != paramEntity.team && bullet.type.absorbable && !bullet.absorbed &&`
	# `Intersector.isInRegularPolygon(paramBlock.sides, paramEntity.x, paramEntity.y, paramEntity.realRadius(), paramBlock.shieldRotation, bullet.x, bullet.y)){`
	# `bullet.absorb();`
	# `paramEntity.hit = 1f;`
	# `paramEntity.buildup += bullet.type.shieldDamage(bullet);`
	# `return (radius + phaseHeat * phaseRadiusBoost) * radscl;`
	# The ORDERING traps: radscl lerps toward the OLD warmup (:216 runs before the warmup update at :222); the broken-set threshold folds the NEW phaseHeat (:210 runs before :243); deflectBullets runs LAST, so absorbed buildup cannot break the shield until the next tick; hit decays (:253-255) BEFORE deflect sets it to 1f. The Arc formulas, not guesses: lerpDelta is `return lerp(fromValue, toValue, clamp(progress * Time.delta));` (Mathf.java:430-432), num is 1 / 0 (Mathf.java:208-210), chanceDelta is rand < d * Time.delta (Mathf.java:236-238, the Fx.reactorsmoke chance defers -- no RNG in the pure advance). delta() is `return Time.delta * timeScale;` (BuildingComp.java:1922-1924) and scales the buildup decay, but the hit decay uses Time.delta DIRECTLY (ForceProjector.java:254), not delta(). source_delta is Time.delta in ticks (seconds * 60 through game_source_delta, arc Time.java:26), never raw seconds. buildup has NO clamp: the decay can take it negative, and a negative buildup clears broken (:239-241). The TIMER CADENCE is live since N2326 (the frame-local Interval-equivalent, source_force_projector_timer_use_state; `public float phaseUseTime = 350f;`, ForceProjector.java:32): the pure advance takes an explicit consume_tick bool and the driver passes the computed tick; the consume() APPLICATION is live too (the driver removes 1 phaseFabric through ConsumeItems.trigger when the advance reports it through the pure `consumed` result; the frame carries items since N2261 but no live intake fills it yet, the Separator precedent). The coolant branch is LIVE-CAPABLE, not dead: the constructor adds ConsumeCoolant when consumeCoolant is true -- `consume(coolantConsumer = new ConsumeCoolant(coolantConsumption)).boost().update(false);` (ForceProjector.java:85, class default `public boolean consumeCoolant = true;`, and the def does not override it) -- so coolantConsumer is non-null, unlike N2230's parallax; the coolant live fill is LIVE since N2258: the driver syncs the liquids store, recomputes the coolant row with the FOLDED efficiency and stamps the coolant inputs onto the frame (coolant_present / coolant_efficiency / coolant_heat_capacity / coolant_liquid_id / coolant_amount), and the advance prefers frame values when present, falling back to the explicit params (the N2235 pure interface, unchanged so the N2235 call keeps its shape). The item live fill is LIVE since N2261: the driver folds the phaseFabric row and stamps the item inputs onto the frame (item_consumer_present / item_consumer_efficiency), and the advance prefers frame values when present, falling back to the explicit params (the N2235 pure interface, unchanged so the N2235 call keeps its shape). coolantConsumer.update(this) (:229, the actual coolant consumption) is reported through the pure `coolant_consumed_liquid` / `coolant_consumed_amount` results (the N2226 heal_amount pattern) and the driver applies the removal to the live liquids store (ConsumeLiquidFilter.update, ConsumeLiquidFilter.java:42-47, `build.liquids.remove(liq, amount * build.edelta() * multiplier.get(build));`, amount = 0.1f * edelta from the folded efficiency * the 1f multiplier). The explicit `bullets` list IS the Groups.bullet.intersect rect result (the N2229 precedent): the caller supplies the bullets in the 2x realRadius rect (EntityGroup.java:207, `public Seq<T> intersect(float x, float y, float width, float height){`, over the spatial bullet group, GroupDefs.java:9, `@GroupDef(value = Bulletc.class, spatial = true, collide = true) G bullet;`), and the pure advance applies the shieldConsumer filter (enemy team + absorbable + !absorbed + in the regular polygon). The bullet dict contract: x / y, team (int; missing = own team, never an enemy), absorbable (default true, BulletType.java:147, `public boolean absorbable = true;`), absorbed (default false, BulletComp.java:53, `transient boolean absorbed, hit;`), shield_damage (default 0.0 -- shieldDamage(bullet) is `return b.damage() * shieldDamageMultiplier;`, BulletType.java:665-666, multiplier default 1f; the port folds no live bullet damage, so the caller supplies it), id (default: the bullet's index in the list). bullet.absorb() (BulletComp.java:100-101, `absorbed = true;`) is NOT applied to a live bullet: the absorbed list + buildup delta are pure results. Effects / sound / events (Fx.reactorsmoke, shieldBreakEffect, breakSound, Trigger.forceProjectorBreak, the shieldConsumer absorbEffect.at(bullet) + hitSound.at) defer. absorbExplosion (ForceProjector.java:269-277) is NOT updateTile -- it is live since N2423 as the pure source_force_projector_absorb_explosion_state (the ExplosionShield method, called from Damage.explode / the unit crash path, not the tick); its absorbEffect.at FX is live since N2482 as the pure-only call record source_force_projector_absorb_effect_state. The building position comes from the origin cell: Building x/y are tile.drawx()/drawy() (BuildingComp.java:124, `set(tile.drawx(), tile.drawy());`), drawx is `return block().offset + worldx();` (Tile.java:175-176) and drawy is `return block().offset + worldy();` (Tile.java:179-180) with the block offset `offset = ((size + 1) % 2) * tilesize / 2f;` (Block.java:761) -- 0 for the size-3 force-projector. A team with no frame team id defaults to derelict (`derelict = new Team(0, "derelict", Color.valueOf("4d4e58")),`, Team.java:33). The updateTile gate is `if(enabled || !block.noUpdateDisabled){` (BuildingComp.java:2276-2277) with `public boolean noUpdateDisabled = false;` (Block.java:170).
	var team_id: int = int(frame.get("team_id", source_block_geometry.SOURCE_TEAM_DERELICT_ID))
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var phase_heat: float = float(frame.get("phase_heat", 0.0))
	var radscl: float = float(frame.get("radscl", 0.0))
	var warmup: float = float(frame.get("warmup", 0.0))
	var buildup: float = float(frame.get("buildup", 0.0))
	var broken: bool = bool(frame.get("broken", true))
	var hit: float = float(frame.get("hit", 0.0))
	# N2258: the coolant inputs resolve from the frame when the
	# driver stamped them (the live fill), else from the
	# explicit params (the N2235 pure interface -- a proof
	# frame carries no coolant keys, so explicit params still
	# drive the branch exactly as before).
	var coolant_present_value: bool = bool(frame.get("coolant_present", coolant_present))
	var coolant_efficiency_value: float = float(frame.get("coolant_efficiency", coolant_efficiency))
	var coolant_heat_capacity_value: float = float(frame.get("coolant_heat_capacity", coolant_heat_capacity))
	var coolant_liquid_id_value: int = int(frame.get("coolant_liquid_id", -1))
	var coolant_amount_value: float = float(frame.get("coolant_amount", 0.0))
	var coolant_consumed_liquid: int = -1
	var coolant_consumed_amount: float = 0.0
	# N2261: the item inputs resolve from the frame when the
	# driver stamped them (the live fill), else from the
	# explicit params (the N2235 pure interface -- a proof
	# frame carries no item keys, so explicit params still
	# drive the branch exactly as before; the N2258 coolant
	# precedent).
	var item_consumer_present_value: bool = bool(frame.get("item_consumer_present", item_consumer_present))
	var item_consumer_efficiency_value: float = float(frame.get("item_consumer_efficiency", item_consumer_efficiency))
	var phase_valid: bool = item_consumer_present_value and item_consumer_efficiency_value > 0.0
	phase_heat = source_math_state.source_lerp_delta(phase_heat, 1.0 if phase_valid else 0.0, SOURCE_FORCE_PROJECTOR_PHASE_HEAT_LERP_PROGRESS, source_delta)
	var consumed: bool = false
	if phase_valid and not broken and consume_tick and efficiency > 0.0:
		consumed = true
	radscl = source_math_state.source_lerp_delta(radscl, 0.0 if broken else warmup, SOURCE_FORCE_PROJECTOR_RADSCL_LERP_PROGRESS, source_delta)
	warmup = source_math_state.source_lerp_delta(warmup, efficiency, SOURCE_FORCE_PROJECTOR_WARMUP_LERP_PROGRESS, source_delta)
	if buildup > 0.0:
		var scale: float = SOURCE_FORCE_PROJECTOR_COOLDOWN_BROKEN_BASE if broken else SOURCE_FORCE_PROJECTOR_COOLDOWN_NORMAL
		if coolant_present_value and coolant_efficiency_value > 0.0:
			scale *= SOURCE_FORCE_PROJECTOR_COOLDOWN_LIQUID * (1.0 + (coolant_heat_capacity_value - 0.4) * 0.9)
			coolant_consumed_liquid = coolant_liquid_id_value
			coolant_consumed_amount = coolant_amount_value * efficiency * source_delta * time_scale
		buildup -= source_delta * time_scale * scale
	if broken and buildup <= 0.0:
		broken = false
	if buildup >= SOURCE_FORCE_PROJECTOR_SHIELD_HEALTH + SOURCE_FORCE_PROJECTOR_PHASE_SHIELD_BOOST * phase_heat and not broken:
		broken = true
		buildup = SOURCE_FORCE_PROJECTOR_SHIELD_HEALTH
	if hit > 0.0:
		hit -= 1.0 / 5.0 * source_delta
	var real_radius: float = (SOURCE_FORCE_PROJECTOR_RADIUS + phase_heat * SOURCE_FORCE_PROJECTOR_PHASE_RADIUS_BOOST) * radscl
	var absorbed_bullets: Array = []
	var buildup_delta: float = 0.0
	if real_radius > 0.0 and not broken:
		var bullet_index: int = 0
		for bullet in bullets:
			if not (bullet is Dictionary):
				bullet_index += 1
				continue
			if int(bullet.get("team", team_id)) == team_id:
				bullet_index += 1
				continue
			if not bool(bullet.get("absorbable", true)):
				bullet_index += 1
				continue
			if bool(bullet.get("absorbed", false)):
				bullet_index += 1
				continue
			if not source_force_projector_is_in_regular_polygon(SOURCE_FORCE_PROJECTOR_SIDES, building_x, building_y, real_radius, SOURCE_FORCE_PROJECTOR_SHIELD_ROTATION, float(bullet.get("x", 0.0)), float(bullet.get("y", 0.0))):
				bullet_index += 1
				continue
			absorbed_bullets.append(bullet.get("id", bullet_index))
			buildup_delta += float(bullet.get("shield_damage", 0.0))
			hit = 1.0
			bullet_index += 1
	buildup += buildup_delta
	return {"phase_heat": phase_heat, "radscl": radscl, "warmup": warmup, "buildup": buildup, "broken": broken, "hit": hit, "consumed": consumed, "absorbed_bullets": absorbed_bullets, "buildup_delta": buildup_delta, "real_radius": real_radius, "coolant_consumed_liquid": coolant_consumed_liquid, "coolant_consumed_amount": coolant_consumed_amount}

static func source_force_projector_absorb_explosion_state(broken: bool, ex: float, ey: float, damage: float, sides: int, building_x: float, building_y: float, real_radius: float, shield_rotation: float, hit: float, crash_damage_multiplier: float = SOURCE_FORCE_PROJECTOR_CRASH_DAMAGE_MULTIPLIER) -> Dictionary:
	# ForceBuild.absorbExplosion() (ForceProjector.java:269-277), the ExplosionShield method -- `public class ForceBuild extends Building implements Ranged, ExplosionShield{` (ForceProjector.java:164), the interface `boolean absorbExplosion(float x, float y, float damage);` (ExplosionShield.java:6) -- called from explosion handling, NOT from updateTile: Damage.explode (`s.absorbExplosion(x, y, damagePerWave)`, Damage.java:113) and the unit crash path (`s.absorbExplosion(x, y, crashDamage)`, UnitComp.java:906). So there is NO tick wiring -- pure-only, like the draw rows. The Java lines, in order (each exact expr on ONE comment line, the N2148 lesson):
	# `public boolean absorbExplosion(float ex, float ey, float damage){`
	# `boolean absorb = !broken && Intersector.isInRegularPolygon(sides, x, y, realRadius(), shieldRotation, ex, ey);`
	# `absorbEffect.at(ex, ey);`
	# `hit = 1f;`
	# `buildup += damage * crashDamageMultiplier;`
	# `return absorb;`
	# `public float crashDamageMultiplier = 2f;`
	# `public Effect absorbEffect = Fx.absorb;`
	# `return (radius + phaseHeat * phaseRadiusBoost) * radscl;`
	# The gate (:270) is the SAME polygon test deflectBullets uses, so the pure REUSEs the N2235 source_force_projector_is_in_regular_polygon port instead of porting it twice (the Arc formulas: vertices via Vec2.trns at i * 360f / sides + rotation, Intersector.java:111-119, tested with the float-array isInPolygon ray cast, Intersector.java:180-193). real_radius is an EXPLICIT input: the caller supplies the N2235 advance's real_radius result (`return (radius + phaseHeat * phaseRadiusBoost) * radscl;`, ForceProjector.java:280). Java sets hit to 1f ONLY when absorb (:273) and grows buildup by damage * crashDamageMultiplier ONLY when absorb (:274, `public float crashDamageMultiplier = 2f;`, ForceProjector.java:45, the def does not override it); when the gate is false Java touches neither field. So the pure reports hit_value (1f on absorb, the incoming hit otherwise) PLUS a hit_set flag (true only on absorb -- without it a hit already at 1f would be indistinguishable from a fresh set, and the caller would not know whether to stamp the frame). The caller applies the results (hit = hit_value, buildup += buildup_delta, the N2235 consumed-flag precedent: the pure reports, the driver writes). The absorbEffect.at call (:272, `public Effect absorbEffect = Fx.absorb;`, ForceProjector.java:49) is FX -- it is live since N2482 as the pure-only call record source_force_projector_absorb_effect_state, which consumes this pure's absorb result; this pure itself is unchanged by N2482.
	var absorb: bool = not broken and source_force_projector_is_in_regular_polygon(sides, building_x, building_y, real_radius, shield_rotation, ex, ey)
	var hit_set: bool = absorb
	var hit_value: float = 1.0 if absorb else hit
	var buildup_delta: float = damage * crash_damage_multiplier if absorb else 0.0
	return {"absorb": absorb, "hit_value": hit_value, "hit_set": hit_set, "buildup_delta": buildup_delta}

static func source_force_projector_absorb_effect_state(absorb: bool, ex: float, ey: float) -> Dictionary:
	# The absorbExplosion absorbEffect FX row (ForceBuild.absorbExplosion(), ForceProjector.java:269-277) -- the gate / hit / buildup are live since N2423 as the pure source_force_projector_absorb_explosion_state, so this pure does NOT recompute the gate: it consumes the caller-supplied absorb verdict (the N2423 pure's absorb result key) and reports the effect as a pure call record (the N2469 precedent -- the port spawns no effect; the effect call site waits for its own slice). The absorbEffect.at FX is live since N2482 as this pure-only call record. The Java lines, in order (each exact expr on ONE comment line, the N2148 lesson):
	# `public boolean absorbExplosion(float ex, float ey, float damage){`
	# `boolean absorb = !broken && Intersector.isInRegularPolygon(sides, x, y, realRadius(), shieldRotation, ex, ey);`
	# `if(absorb){`
	# `absorbEffect.at(ex, ey);`
	# `return absorb;`
	# `public Effect absorbEffect = Fx.absorb;`
	# `absorb = new Effect(12, e -> {`
	# `paramBlock.hitSound.at(bullet.x, bullet.y, 1f + Mathf.range(0.1f), paramBlock.hitSoundVolume);`
	# `paramBlock.absorbEffect.at(bullet);`
	# The effect is Fx.absorb (`public Effect absorbEffect = Fx.absorb;`, ForceProjector.java:49; `absorb = new Effect(12, e -> {`, Fx.java:1356) and the single force-projector def does NOT override it (Blocks.java:1964-1976, verified by grep -- no absorbEffect line in the def). The call record uses the N2469 "Fx.<name>" form ({effect: "Fx.absorb", ex, ey} -- not the N2470 "token" key form; the position is the explosion position (ex, ey), passed through untouched). The 12-tick renderer body is the callee presentation -- the pure records the CALL (the N2396 precedent). The shieldConsumer bullet path is a DIFFERENT call site (ForceProjector.java:64-65, `paramBlock.hitSound.at(bullet.x, bullet.y, 1f + Mathf.range(0.1f), paramBlock.hitSoundVolume);` + `paramBlock.absorbEffect.at(bullet);`, hitSound = Sounds.shieldHit, ForceProjector.java:47, hitSoundVolume 0.12f, :48): it fires per absorbed BULLET in deflectBullets, not per explosion, so it defers under its own new entry, not this pure. When absorb is false the call is null (the N2397 null-when-absent precedent). Pure-only: the tick never calls it -- absorbExplosion is explosion handling (Damage.explode / the unit crash path), not updateTile, and the N2423 pure is unchanged by this slice.
	var absorb_effect_call: Variant = null
	if absorb:
		absorb_effect_call = {"effect": "Fx.absorb", "ex": ex, "ey": ey}
	return {"absorb_effect_call": absorb_effect_call}

static func source_force_projector_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The force-projector tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (ForceProjector.java:30, `public class ForceProjector extends Block{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# force projector skips consumption like Java's updateConsumption
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
	# for this force projector (N2125); the tick preserves a disabled
	# force projector instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	# A new ForceBuild starts with an empty liquids module
	# (the Building.liquids LiquidModule, frame["liquids"],
	# the Fracker precedent): the coolant row (N2258) reads
	# the held coolant from it, and the tick syncs the live
	# sprite store into it each tick. The items module
	# (the Building.items ItemModule, frame["items"], the
	# Separator precedent) starts empty too: the phaseFabric
	# item row (N2261) reads the held fabric from it, and no
	# live intake fills it yet. The timerUse clock
	# (frame["timer_use_elapsed"], N2326) starts at 0.0: the
	# frame-local Interval-equivalent accumulates it every
	# enabled tick (the first-fire deviation -- Java fires
	# nearly at once after placement, the frame clock waits
	# a full 350f/time_scale interval).
	return {"phase_heat": 0.0, "radscl": 0.0, "warmup": 0.0, "buildup": 0.0, "broken": true, "hit": 0.0, "liquids": {}, "items": {}, "timer_use_elapsed": 0.0}

static func source_force_projector_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the force-projector frame meta key
	# ("source_force_projector_building"). A ForceProjector sprite gets a
	# frame bound seeded with the Java field defaults (phaseHeat /
	# radscl / warmup / buildup 0, broken TRUE, hit 0 --
	# ForceProjector.java:167-168); the live-loop tick fills its
	# other keys every tick. Any other block, or an already-bound
	# sprite, binds nothing.
	if block == null or not _is_force_projector_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_FORCE_PROJECTOR_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_FORCE_PROJECTOR_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_FORCE_PROJECTOR_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_force_projector_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40,
	# `return build.power.status;`): the power consumer's
	# efficiency is the building's live power.status, and the
	# first pass folds it into the min efficiency
	# (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`).
	# The graph update stamps
	# frame["power_status"] each tick (N2142); a missing stamp
	# folds to 1.0 before the first graph update, the assembler
	# fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`).
	# A block with no power consumer contributes no row. The
	# power consumer counts toward hasConsumers
	# (Block.java:1449, `hasConsumers = consumers.length > 0;`),
	# so a force projector does not take the early return. The
	# warmup follows the folded efficiency
	# (ForceProjector.java:221, `warmup = Mathf.lerpDelta(warmup, efficiency, 0.1f);`), with the radscl gate
	# (ForceProjector.java:215, `radscl = Mathf.lerpDelta(radscl, broken ? 0f : warmup, 0.05f);`) and the real-radius fold
	# (ForceProjector.java:280, `return (radius + phaseHeat * phaseRadiusBoost) * radscl;`) and the phase-heat gate
	# (ForceProjector.java:209, `phaseHeat = Mathf.lerpDelta(phaseHeat, Mathf.num(phaseValid), 0.1f);`) and the consume gate
	# (ForceProjector.java:211, `if(phaseValid && !broken && timer(timerUse, phaseUseTime / timeScale) && efficiency > 0){`).
	# Documented limits: (1) coolant row live (N2258) -- the
	# ConsumeCoolant 0.1f row (ForceProjector.java:43-44, :85;
	# cooldownLiquid 1.2f, Blocks.java:1971) folds into the
	# optional pass (source_force_projector_coolant_consumer_row_state,
	# ConsumeLiquidFilter.efficiency, ConsumeLiquidFilter.java:50-55)
	# with the manual updateTile consume
	# (ForceProjector.java:227-231) reported through the
	# advance's pure coolant_consumed results and applied by
	# the driver; phaseFabric booster item row live (N2261) --
	# the ConsumeItems 1 phaseFabric row (Blocks.java:1974,
	# `itemConsumer = consumeItem(Items.phaseFabric).boost();`,
	# binary 1.0/0.0, ConsumeItems.efficiency,
	# ConsumeItems.java:51-53) folds into the optional pass
	# (source_force_projector_item_consumer_row_state) and
	# wires item_consumer_present / item_consumer_efficiency
	# live into the advance (phaseValid, ForceProjector.java:207);
	# optionalEfficiency is now COMPLETE (min over coolant +
	# item, BuildingComp.java:1980-1981, capped by
	# minEfficiency, BuildingComp.java:1986) and the folded
	# efficiency is the min over the *modeled* non-optional
	# consumers (power only). Still deferred: no live intake
	# fills frame["items"] yet (the Separator precedent -- the
	# row reads the frame as-is, so a live force projector
	# with no intake folds the item row 0).
	# timerUse cadence + consume() application live (N2326):
	# the timer-gated consume() (ForceProjector.java:211-213,
	# phaseUseTime 350f, ForceProjector.java:32) fires on the
	# frame-local Interval-equivalent (350f / timeScale) and
	# the driver removes 1 phaseFabric when the advance
	# reports consumed.
	# (2) No shouldConsume gate -- ForceBuild has no
	# shouldConsume override, so the default
	# (BuildingComp.java:755-757, `return enabled;`) applies;
	# the machinery runs with should_consume=true when
	# enabled. (3) updateTile advance live (N2235) -- phaseValid /
	# phaseHeat / consume() gate / radscl / warmup / buildup /
	# broken / deflectBullets (ForceProjector.java:207-268) now
	# advance in source_force_projector_update_tile_advance_state,
	# with the coolant live fill live since N2258 (the driver
	# stamps the re-evaluated coolant inputs onto the frame)
	# and the timer cadence + consume() application live since
	# N2326 (the driver passes the computed consume_tick and
	# removes 1 phaseFabric when the advance reports consumed);
	# the live bullet scan stays deferred (the live-fill
	# entry). (4) Phase-radius / phase-shield folds live (N2235)
	# -- realRadius (ForceProjector.java:280,
	# `return (radius + phaseHeat * phaseRadiusBoost) * radscl;`)
	# is the advance's real_radius result and the broken
	# threshold folds shieldHealth + phaseShieldBoost * phaseHeat
	# (ForceProjector.java:244); the shield bar (setBars,
	# ForceProjector.java:104) still waits for its own slice.
	# (5) absorbExplosion live (N2423) --
	# ForceBuild.absorbExplosion()
	# (ForceProjector.java:269-277, the ExplosionShield
	# method, called from Damage.explode / the unit crash
	# path, NOT updateTile) now runs as the pure
	# source_force_projector_absorb_explosion_state with
	# explicit inputs (broken, ex, ey, damage, sides,
	# building x/y, real_radius, shield_rotation, hit,
	# crash_damage_multiplier 2f), REUSING the N2235
	# isInRegularPolygon port; the absorbEffect.at FX is
	# live since N2482 as the pure-only call record
	# source_force_projector_absorb_effect_state
	# (absorb_effect_call {effect "Fx.absorb", ex, ey},
	# null when the N2423 absorb verdict is false).
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

@warning_ignore("unused_parameter")
static func source_force_projector_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the force-projector tick wiring every
	# tick (ForceBuild.updateTile(), ForceProjector.java:207,
	# gates on the warmup fold (ForceProjector.java:221,
	# `warmup = Mathf.lerpDelta(warmup, efficiency, 0.1f);`) and folds the
	# real radius (ForceProjector.java:280,
	# `return (radius + phaseHeat * phaseRadiusBoost) * radscl;`), so the
	# warmup fold follows the folded efficiency; no
	# placed-buildings driver ticks ForceProjector blocks, so this
	# driver is the placed-force-projector tick): each placed
	# ForceProjector build gets its frame keys refreshed from the
	# live rules, so the frame's cheating flag tracks
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
	var liquid_catalog_props: Dictionary = source_force_projector_liquid_catalog_props_state(catalog)
	var liquid_props_by_id: Dictionary = liquid_catalog_props.get("liquid_props_by_id", {})
	var liquid_order: Array = liquid_catalog_props.get("liquid_order", [])
	for sprite in source_placed_block_state.source_unique_buildings_state(game).get("buildings", []):
		if not is_instance_valid(sprite) or not sprite is Sprite2D:
			continue
		var block_id: String = str(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
		if not blocks_by_id.has(block_id):
			continue
		var block = blocks_by_id[block_id]
		if not _is_force_projector_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_force_projector_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_force_projector_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The frame carries the Building.liquids LiquidModule
		# (frame["liquids"]): the live store lives on the
		# sprite meta (source_building_liquids, initialized
		# at placement), so the driver syncs the reference
		# into the frame each tick BEFORE the fold, and the
		# pure coolant row reads the held coolant from it (the
		# Fracker:623 precedent).
		frame["liquids"] = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
		# N2261: the phaseFabric booster item row is pure over
		# the frame items (ConsumeItems.efficiency,
		# ConsumeItems.java:51-53, binary 1.0/0.0 -- no
		# efficiency input, unlike the coolant row), so the
		# driver computes it once here: the consumption fold
		# below appends it to the optional pass, and the
		# advance fill stamps it onto the frame (phaseValid
		# reads itemConsumer.efficiency DIRECTLY,
		# ForceProjector.java:207, independent of the fold --
		# so it stays live even when the fold is skipped for a
		# cheating team). The single stack is 1 phaseFabric
		# (Blocks.java:1974, `itemConsumer =
		# consumeItem(Items.phaseFabric).boost();`;
		# consumeItem(item) is ItemStack(item, 1),
		# Block.java:1167-1168). No live intake fills
		# frame["items"] yet (the Separator precedent), so the
		# row reads the frame as-is.
		var item_row: Dictionary = source_force_projector_item_consumer_row_state(frame, true, [{"item": "phase-fabric", "amount": 1}])
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a force projector with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the warmup fold (ForceProjector.java:221)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449,
		# `hasConsumers = consumers.length > 0;`), so a force
		# projector does not take the early return. A force projector with
		# no power consumer is untouched: the ConsumeCoolant
		# 0.1f row (N2258) and the phaseFabric booster item
		# row (N2261) fold in the same block; there is no
		# shouldConsume gate yet
		# (ForceBuild has no shouldConsume override; the default
		# BuildingComp.java:755-757 `return enabled;` applies),
		# so the machinery runs with should_consume=true when enabled.
		# productionValid is the canonical true default
		# (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var should_consume: bool = bool(frame.get("enabled", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_force_projector_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			# N2258: the ConsumeCoolant row folds into the
			# OPTIONAL pass (ConsumeCoolant.java:12 filter,
			# ConsumeLiquidFilter.efficiency,
			# ConsumeLiquidFilter.java:50-55). The consumer
			# exists because consumeCoolant is true
			# (ForceProjector.java:44 class default, the def
			# does not override it) and the constructor adds
			# it (ForceProjector.java:84-85); the amount is
			# the 0.1f class default (ForceProjector.java:43),
			# PER FRAME. In the first pass efficiency is
			# assumed 1f (BuildingComp.java:1965), so the
			# row's edelta is source_delta * time_scale.
			# update(false) means the second pass never
			# consumes this row -- the manual updateTile
			# consume below does. The optionalEfficiency is
			# complete since N2261: the phaseFabric booster
			# item row (Blocks.java:1974) folds beside it,
			# and Java mins over BOTH optional rows
			# (BuildingComp.java:1980-1981).
			var tick_source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
			var tick_time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
			var coolant_row: Dictionary = source_force_projector_coolant_consumer_row_state(frame, true, liquid_props_by_id, liquid_order, SOURCE_FORCE_PROJECTOR_COOLANT_CONSUMPTION, tick_source_delta, tick_time_scale, 1.0)
			var optional_results: Array = []
			if bool(coolant_row.get("has_coolant_row", false)):
				optional_results.append(coolant_row.get("row", {}))
			# N2261: the phaseFabric booster item row folds
			# into the SAME optional pass (.boost() is
			# `return optional(true, true);`, Consume.java:33-35;
			# the optional pass, BuildingComp.java:1980-1981,
			# mins over BOTH optional rows, capped by
			# minEfficiency, BuildingComp.java:1986) -- the
			# row is binary (ConsumeItems.efficiency,
			# ConsumeItems.java:51-53), so a fabric-less
			# force projector folds optionalEfficiency 0.
			if bool(item_row.get("has_item_row", false)):
				optional_results.append(item_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, optional_results, [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		# N2235: the updateTile advance runs after consumption,
		# like Java's Building.update() (BuildingComp.java:2274
		# updateConsumption(), then the updateTile gate
		# `if(enabled || !block.noUpdateDisabled){` at
		# BuildingComp.java:2276-2277; noUpdateDisabled defaults
		# false, `public boolean noUpdateDisabled = false;`
		# (Block.java:170), so Java runs updateTile even when
		# disabled -- in Java a disabled force projector's
		# warmup still lerps toward its zeroed efficiency
		# (BuildingComp.java:1954-1957). The port keeps the
		# enabled gate below as a pragmatic choice (the N2195
		# coordinator-fix precedent): the driver skips the
		# consumption fold when disabled, so the frame
		# efficiency goes stale and running the advance on it
		# would lerp warmup / phaseHeat from a stale
		# efficiency. The driver-wide disabled-early-return
		# slice (deferred in the N2229 register) removes this
		# gate for all families.
		# super.updateTile() is an empty no-op
		# (BuildingComp.java:2010-2012), so the driver owes it
		# nothing. The source delta is Time.delta in ticks:
		# game_source_delta(game, seconds) is seconds * 60 (arc
		# Time.java:26), never raw seconds. timeScale reads
		# live from the sprite meta, default 1.0
		# (BuildingComp.java:98 `private transient float
		# timeScale = 1f, timeScaleDuration;`). The building
		# position comes from the origin cell: Building x/y
		# are tile.drawx()/drawy() (BuildingComp.java:124,
		# `set(tile.drawx(), tile.drawy());`), drawx is
		# block.offset + tile.worldx() (Tile.java:175-176) with
		# the block offset `offset = ((size + 1) % 2) * tilesize / 2f;`
		# (Block.java:761) -- 0 for the size-3 force-projector.
		# The driver passes the computed consume_tick (N2326)
		# and an EMPTY bullet list: no live bullet query exists
		# in the port, so no live deflect happens (the live
		# fill stays deferred); the consume() application is
		# live -- the driver removes 1 phaseFabric when the
		# advance reports consumed. The item
		# inputs are LIVE since N2261 (the stamp below writes
		# the folded row onto the frame before the call, the
		# N2258 coolant precedent -- phaseHeat follows the
		# live fabric row now, though no live intake fills
		# frame["items"] yet). The coolant inputs are LIVE
		# since N2258 (the recompute below stamps them onto
		# the frame before the call).
		if bool(frame.get("enabled", true)):
			var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
			var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
			var advance_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
			var advance_block_size: int = int(block.properties.get("size", 1))
			var advance_block_offset: float = float((advance_block_size + 1) % 2) * source_world_defaults.TILESIZE / 2.0
			var advance_building_x: float = source_block_geometry.tile_drawx_state(advance_cell.x, source_world_defaults.TILESIZE, advance_block_offset)
			var advance_building_y: float = source_block_geometry.tile_drawy_state(advance_cell.y, source_world_defaults.TILESIZE, advance_block_offset)
			# N2258: the coolant live fill -- Java re-evaluates
			# coolantConsumer.efficiency(this) in updateTile
			# (ForceProjector.java:228) with the FOLDED
			# efficiency (not the 1f the fold assumed), and
			# scales with the CURRENT liquid's heatCapacity
			# (ForceProjector.java:230, `liquids.current().heatCapacity`),
			# not the consumed liquid's. The driver recomputes
			# the pure row with the folded frame efficiency
			# and stamps the coolant inputs onto the frame;
			# the advance prefers frame values when present
			# and falls back to its explicit params (the
			# N2235 pure interface, unchanged so the N2235
			# call keeps its shape). When there is no coolant
			# the heatCapacity stays the 0.4f no-op fallback
			# (the scale factor is 1 then, and the branch
			# cannot run with efficiency 0 anyway).
			var folded_coolant_row: Dictionary = source_force_projector_coolant_consumer_row_state(frame, true, liquid_props_by_id, liquid_order, SOURCE_FORCE_PROJECTOR_COOLANT_CONSUMPTION, source_delta, time_scale, float(frame.get("efficiency", 0.0)))
			var folded_coolant_consumed: Variant = folded_coolant_row.get("consumed_liquid", null)
			frame["coolant_present"] = true
			frame["coolant_efficiency"] = float(folded_coolant_row.get("row", {}).get("result", 0.0))
			var current_liquid_id: int = int(frame.get("liquids", {}).get("current", -1))
			if folded_coolant_consumed == null or not liquid_props_by_id.has(current_liquid_id):
				frame["coolant_heat_capacity"] = SOURCE_FORCE_PROJECTOR_COOLANT_HEAT_CAPACITY_FALLBACK
			else:
				frame["coolant_heat_capacity"] = source_force_projector_coolant_heat_capacity_state(liquid_props_by_id[current_liquid_id])
			frame["coolant_liquid_id"] = -1 if folded_coolant_consumed == null else int(folded_coolant_consumed)
			frame["coolant_amount"] = SOURCE_FORCE_PROJECTOR_COOLANT_CONSUMPTION
			# N2261: the item live fill -- Java reads
			# itemConsumer.efficiency(this) DIRECTLY for
			# phaseValid (ForceProjector.java:207), not
			# through optionalEfficiency, and the row is
			# efficiency-independent (binary has-check), so
			# no re-evaluation is needed: the driver stamps
			# the folded row's presence + result onto the
			# frame and the advance prefers frame values when
			# present, falling back to its explicit params
			# (the N2235 pure interface, unchanged so the
			# N2235 call keeps its shape -- the N2258
			# coolant precedent). The timer-gated consume()
			# (ForceProjector.java:211-213, phaseUseTime
			# 350f) is live since N2326: the timer below
			# computes consume_tick from
			# frame["timer_use_elapsed"] and the driver
			# removes 1 phaseFabric when the advance
			# reports consumed.
			frame["item_consumer_present"] = bool(item_row.get("has_item_row", false))
			frame["item_consumer_efficiency"] = float(item_row.get("row", {}).get("result", 0.0))
			# N2326: the timerUse cadence -- the frame-local
			# Interval-equivalent (source_force_projector_
			# timer_use_state) runs BEFORE the advance call:
			# the frame clock frame["timer_use_elapsed"]
			# accumulates the tick delta every enabled tick
			# (unconditionally -- mirroring Time.time, arc
			# Time.java:75) and fires at 350f / timeScale
			# (ForceProjector.java:211-213, phaseUseTime
			# 350f); the computed consume_tick reaches the
			# advance, whose gate (phaseValid / !broken /
			# efficiency > 0) still decides whether anything
			# is consumed. The clock resets to 0.0 on fire
			# even when the gate is closed (the documented
			# gate-closed-reset deviation -- Java
			# short-circuits before timer() and keeps its
			# old stamp). Bullets stay [] (no live bullet
			# query -- the live bullet scan still defers).
			var timer_use: Dictionary = source_force_projector_timer_use_state(float(frame.get("timer_use_elapsed", 0.0)), source_delta, time_scale, SOURCE_FORCE_PROJECTOR_PHASE_USE_TIME)
			frame["timer_use_elapsed"] = timer_use.get("timer_elapsed_after", 0.0)
			var consume_tick: bool = bool(timer_use.get("consume_tick", false))
			var advanced: Dictionary = source_force_projector_update_tile_advance_state(frame, source_delta, time_scale, advance_building_x, advance_building_y, [], consume_tick)
			frame["phase_heat"] = advanced["phase_heat"]
			frame["radscl"] = advanced["radscl"]
			frame["warmup"] = advanced["warmup"]
			frame["buildup"] = advanced["buildup"]
			frame["broken"] = advanced["broken"]
			frame["hit"] = advanced["hit"]
			frame["consumed"] = advanced["consumed"]
			frame["absorbed_bullets"] = advanced["absorbed_bullets"]
			frame["buildup_delta"] = advanced["buildup_delta"]
			frame["real_radius"] = advanced["real_radius"]
			frame["coolant_consumed_liquid"] = advanced["coolant_consumed_liquid"]
			frame["coolant_consumed_amount"] = advanced["coolant_consumed_amount"]
			# N2326: the timer-gated consume() application
			# (ForceProjector.java:211-213, `if(phaseValid &&
			# !broken && timer(timerUse, phaseUseTime /
			# timeScale) && efficiency > 0){ consume(); }`):
			# when the advance reports consumed, consume()
			# removes 1 phaseFabric through
			# ConsumeItems.trigger (ConsumeItems.java:44-48,
			# `build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));`)
			# -- the single stack is 1 phaseFabric
			# (Blocks.java:1974, `itemConsumer =
			# consumeItem(Items.phaseFabric).boost();`;
			# consumeItem(item) is ItemStack(item, 1),
			# Block.java:1167-1168), and the removal goes
			# through the shared inventory helper, clamped
			# to the held count like ItemModule.remove
			# (ItemModule.java:258-263, `amount = Math.min(amount, items[item.id]);`).
			# The removal reads frame["items"] as-is (no live
			# intake fills it yet, the Separator precedent).
			if bool(advanced.get("consumed", false)):
				var timer_items: Dictionary = (frame.get("items", {}) as Dictionary).duplicate(true)
				var timer_removed: Dictionary = source_drill_inventory_runtime_state.remove_item_state(timer_items, "phase-fabric", 1)
				frame["items"] = timer_removed.get(source_drill_inventory_runtime_state.SOURCE_DRILL_INVENTORY_DRILL_ITEMS_KEY, timer_items)
			# N2258: the manual updateTile consume
			# (ForceProjector.java:229, `coolantConsumer.update(this);`
			# -- ConsumeLiquidFilter.update, ConsumeLiquidFilter.java:42-47,
			# `build.liquids.remove(liq, amount * build.edelta() * multiplier.get(build));`).
			# update(false) (ForceProjector.java:85) keeps this row
			# out of the second pass, so the removal happens here,
			# only when the advance reports it consumed (buildup > 0
			# on entry + the re-evaluated coolant efficiency > 0,
			# ForceProjector.java:223/228) -- the heal_amount
			# pattern (N2226): the advance reports the pure
			# consumption, the driver applies it to the live
			# store through the shared liquid module helper
			# (SourceLiquidModuleState.source_remove_state,
			# clamped at the held amount like Java's
			# LiquidModule.remove, with a fresh cache_sums
			# sized to the store, the PayloadLoader precedent).
			# frame["liquids"] is the live sprite store by
			# reference, so the removal lands on it.
			if int(advanced.get("coolant_consumed_liquid", -1)) >= 0 and float(advanced.get("coolant_consumed_amount", 0.0)) > 0.0:
				var coolant_store: Dictionary = frame.get("liquids", {})
				if coolant_store.has("liquids") and int(advanced["coolant_consumed_liquid"]) < int(coolant_store["liquids"].size()):
					var coolant_cache_sums: Array = []
					coolant_cache_sums.resize(int(coolant_store["liquids"].size()))
					coolant_cache_sums.fill(0.0)
					source_liquid_module_state.source_remove_state(coolant_store, int(advanced["coolant_consumed_liquid"]), float(advanced["coolant_consumed_amount"]), coolant_cache_sums)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
