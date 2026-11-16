extends RefCounted
class_name SourceLaunchPadBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const source_content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const inventory := preload("res://src/game/SourceDrillInventoryRuntimeState.gd")

# The LaunchPad implementation (LaunchPad.java:30, `public class LaunchPad extends Block{`): launch-pad (consumePower 4f, Blocks.java:6797, `consumePower(4f);`; size 3, itemCapacity 100, launchTime 60f * 20, Blocks.java:6790-6797) and advanced-launch-pad (consumePower 8f, Blocks.java:6809, `consumePower(8f);`; size 4, itemCapacity 100, launchTime 60f * 30, liquidCapacity 40f, drawLiquid oil, consumeLiquid oil 9f/60f, Blocks.java:6800-6809). LaunchPad extends Block, NOT a factory or crafter, so no existing driver matches it and no frame key exists for it; this driver uses its own family frame key ("source_launch_pad_building", the wall-crafter precedent), and this slice adds the launch-pad key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourceLaunchPad* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the updateTile launch gate (LaunchPad.java:146, `if((launchCounter += edelta()) >= launchTime && items.total() >= itemCapacity){`) advances launchCounter by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`), so a launch pad with no power would never launch -- its launchCounter would sit frozen as if power.status were 1.0.
const SOURCE_LAUNCH_PAD_BUILD_IMPLEMENTATIONS := ["LaunchPad"]
const SOURCE_LAUNCH_PAD_BUILDING_META_KEY := "source_launch_pad_building"

static func _is_launch_pad_build_implementation(implementation: String) -> bool:
	return SOURCE_LAUNCH_PAD_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_launch_pad_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The launch-pad tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (LaunchPad.java:30, `public class LaunchPad extends Block{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# launch pad skips consumption like Java's updateConsumption
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
	# for this launch pad (N2125); the tick preserves a disabled
	# launch pad instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	# LaunchPadBuild.launchCounter (LaunchPad.java:84, `public float launchCounter;`) is the updateTile state: the launch gate (LaunchPad.java:146, `if((launchCounter += edelta()) >= launchTime && items.total() >= itemCapacity){`) advances it by edelta() and resets it on launch, and shouldConsume() (LaunchPad.java:92, `public boolean shouldConsume(){` with `return launchCounter < launchTime;`, LaunchPad.java:94) reads it live; the tick preserves the counter across ticks instead of resetting it, the factory pattern (SourceFactoryBuildState.gd:927), and a fresh frame starts at the Java field default 0f. The frame items (the Building.items ItemModule, a Dictionary keyed by item name, the factory precedent SourceFactoryBuildState.gd:89-101) are preserved the same way -- the launch clears them through the advance, never through the tick wiring.
	frame["launch_counter"] = float(frame.get("launch_counter", 0.0))
	frame["items"] = frame.get("items", {})
	return frame

static func _initial_frame() -> Dictionary:
	# The fresh frame binds the Java build-field defaults:
	# `public float launchCounter;` (LaunchPad.java:84, 0f) and
	# the empty ItemModule (no items held at placement). The
	# frame inputs (launch_time / efficiency) are NOT bound
	# here: launch_time is stamped per-def by the driver (the
	# catalog carries no launchTime) and the advance reads it
	# with the frame.get default 1.0 (the class default,
	# LaunchPad.java:32); efficiency is stamped by the
	# consumption fold and the advance reads it with the
	# frame.get default 0.0 (BuildingComp.java:85 `transient
	# float efficiency;`). The liquids store starts empty (the
	# Building.liquids LiquidModule, default {} -- the tick
	# syncs the live store from the sprite meta before the
	# fold, N2253); a pad with no liquid consumer never fills
	# it.
	return {"launch_counter": 0.0, "items": {}, "liquids": {}}

static func source_launch_pad_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the launch-pad frame meta key
	# ("source_launch_pad_building"). A LaunchPad sprite gets a
	# frame bound with the updateTile state keys
	# (launch_counter 0.0 / items {}, the Java build-field
	# defaults, LaunchPad.java:84 -- N2238); the live-loop tick
	# fills its other keys every tick. Any other block, or an
	# already-bound sprite, binds nothing.
	if block == null or not _is_launch_pad_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_LAUNCH_PAD_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_LAUNCH_PAD_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_LAUNCH_PAD_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_launch_pad_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a launch pad does not take the early return. The updateTile advance follows the folded efficiency: the launch gate (LaunchPad.java:146, `if((launchCounter += edelta()) >= launchTime && items.total() >= itemCapacity){`) advances launchCounter by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`), so a launch pad with no power would never launch. LaunchPadBuild HAS a shouldConsume override (LaunchPad.java:92, `public boolean shouldConsume(){` with `return launchCounter < launchTime;`, LaunchPad.java:94) -- N2186 wires the gate: the pure source_launch_pad_should_consume_state gate reads the tracked launchCounter, the driver ANDs enabled (the BuildingComp default, BuildingComp.java:755-757, `return enabled;`, is what the driver uses), and the machinery folds efficiency to 0 when the gate is false (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();`, with BuildingComp.java:1992-1994, `if(!update){` / `efficiency = optionalEfficiency = 0f;`). The launch pad is its own family (LaunchPad.java:30, `public class LaunchPad extends Block{`; LaunchPadBuild, LaunchPad.java:83, `public class LaunchPadBuild extends Building{`). Two defs share the implementation (launch-pad, `consumePower(4f);`, Blocks.java:6797; advanced-launch-pad, `consumePower(8f);`, Blocks.java:6809), so the same driver covers the whole family; the advanced def also consumes liquid oil -- the liquid row is LIVE since N2253 (source_launch_pad_liquid_consumer_row_state, oil 9f/60f, Blocks.java:6808).
	# Documented limits: (1) power + liquid first pass -- the launch pad's power consumer is static (consumePower 4f, Blocks.java:6797; consumePower 8f, Blocks.java:6809), and the advanced def's oil consumer is static too (consumeLiquid oil 9f/60f, Blocks.java:6808), so the folded efficiency is the min over the *modeled* consumers (power + the advanced def's oil row, N2253; the plain launch-pad has no liquid consumer, so its liquid row is absent). (2) shouldConsume gate LIVE (N2186) -- LaunchPadBuild.shouldConsume() (`return launchCounter < launchTime;`, LaunchPad.java:92-95) is the pure source_launch_pad_should_consume_state gate over the tracked launchCounter; the driver ANDs enabled (BuildingComp.java:755-757, `return enabled;`) and the machinery folds efficiency to 0 when the gate is false (BuildingComp.java:1960/:1992-1994). (3) updateTile advance live (N2238) -- the launchCounter advance, the full-and-timed launch gate, the stacks copy, items.clear and the launchCounter = 0f reset (LaunchPad.java:143-161) advance in the pure function (source_launch_pad_update_tile_advance_state); the LaunchPayload entity creation/application (LaunchPad.java:150-155) and the launch sound / effects (launchSound / Fx.launchPod / Effect.shake, LaunchPad.java:149/156/158) still defer. (4) Liquid consumer row LIVE (N2253) -- advanced-launch-pad consumes oil 9f/60f (Blocks.java:6808), folded as a required row with is_power false; the plain launch-pad has no liquid consumer (row absent). (5) Two defs, one driver -- launch-pad + advanced-launch-pad share the LaunchPad implementation, so the same driver covers the whole family; the advanced def waits for its own verification slice. (6) acceptItem gate LIVE (N2333) -- LaunchPadBuild.acceptItem() (LaunchPad.java:138-140) is the pure source_launch_pad_accept_item_state gate (total < capacity AND (accept_multiple OR total == 0 OR first == item), first scanned in content-id order); launch-pad accepts multiple items (`acceptMultipleItems = true;`, Blocks.java:6796), advanced-launch-pad keeps the false class default (LaunchPad.java:40). Pure + test + proof only: no intake path calls acceptItem yet, so the driver wiring waits for the frame-items-intake design. (7) Sense rows live (N2389) -- LaunchPadBuild.sense() (LaunchPad.java:98-101) is the pure source_launch_pad_sense_state dispatch (progress -> clampf(launch_counter / launch_time, 0.0, 1.0), other sensors -> the caller-supplied super_value, null = the Float.NaN default branch); pure-only, the tick never calls sense (sense is called by logic, and the logic call site waits for a logic-executor slice).
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_launch_pad_liquid_consumer_row_state(frame: Dictionary, has_liquid_consumer: bool, liquid_id: int, amount: float, source_delta: float, time_scale: float, efficiency_scale: float, multiplier: float = 1.0) -> Dictionary:
	# ConsumeLiquid.efficiency (ConsumeLiquid.java:42-47), the
	# pure liquid row -- each exact expr on ONE comment line,
	# the N2148 lesson:
	# `float ed = build.edelta() * build.efficiencyScale();`
	# `if(ed <= 0.00000001f) return 0f;`
	# `return Math.min(build.liquids.get(liquid) / (amount * ed * multiplier.get(build)), 1f);`
	# The first pass folds it into the min efficiency
	# (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`); a starved non-power row also stops the power draw (`if(cons != block.consPower && result <= 0.0000001f){` / `shouldConsumePower = false;`, BuildingComp.java:1972-1973), which the shared fold does from is_power false. In the first pass efficiency is assumed 1f (BuildingComp.java:1964-1965), so edelta is delta() = source_delta * time_scale (`return efficiency * delta();`, BuildingComp.java:1927-1929, with `return Time.delta * timeScale;`, BuildingComp.java:1922-1924); source_delta is Time.delta in ticks (seconds * 60 through game_source_delta, arc Time.java:26), never raw seconds. The held amount comes from the shared liquid module helper (SourceLiquidModuleState.source_get_state, reused through a preload, NOT re-implemented) over the frame liquids key (the Building.liquids LiquidModule dict), with the Fracker guard (frame liquids has the "liquids" array + the id in bounds -- SourceFrackerBuildState.gd:279): a frame with no store reads 0.0, like Java's liquids.get for a liquid never added (`public float get(Liquid liquid){` with `return liquids[liquid.id];`, LiquidModule.java:102-104). The multiplier defaults to 1f (`public Floatf<Building> multiplier = b -> 1f;`, Consume.java:18); the advanced def sets none (Blocks.java:6800-6809). ONLY the advanced-launch-pad has this consumer (`consumeLiquid(Liquids.oil, 9f/60f);`, Blocks.java:6808; the plain launch-pad def, Blocks.java:6790-6797, has no liquid consumer), so a block with no liquid consumer contributes no row -- the has_power_row pattern. The second-pass removal (`build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));`, ConsumeLiquid.java:37-39, only when `update && efficiency > 0`, BuildingComp.java:1999-2002, with edelta from the FOLDED efficiency) runs in the driver after the fold, through source_remove_state (`public void remove(Liquid liquid, float amount){` with `add(liquid, Math.max(-amount, -liquids[liquid.id]));`, LiquidModule.java:125-128); the function does NOT mutate its input frame.
	if not has_liquid_consumer:
		return {"has_liquid_row": false, "row": {}}
	var liquids: Dictionary = frame.get("liquids", {})
	var liquid_amount: float = 0.0
	if liquids.has("liquids") and liquid_id >= 0 and liquid_id < int(liquids["liquids"].size()):
		liquid_amount = float(source_liquid_module_state.source_get_state(liquids, liquid_id).get("amount", 0.0))
	var ed: float = source_delta * time_scale * efficiency_scale
	if ed <= 0.00000001:
		return {"has_liquid_row": true, "row": {"result": 0.0, "is_power": false}}
	var result: float = minf(liquid_amount / (amount * ed * multiplier), 1.0)
	return {"has_liquid_row": true, "row": {"result": result, "is_power": false}}

static func source_launch_pad_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float, item_capacity: int) -> Dictionary:
	# The updateTile advance (LaunchPadBuild.updateTile(),
	# LaunchPad.java:143-161), the pure frame advance -- the
	# build class is `public class LaunchPadBuild extends Building{`
	# (LaunchPad.java:83) on `public class LaunchPad extends Block{`
	# (LaunchPad.java:30), the counter field is `public float launchCounter;`
	# (LaunchPad.java:84, 0f) and the threshold field is
	# `public float launchTime = 1f;` (LaunchPad.java:32, the
	# class default; the defs override it -- launch-pad
	# `launchTime = 60f * 20;`, Blocks.java:6794, advanced-
	# launch-pad `launchTime = 60f * 30;`, Blocks.java:6804).
	# The advance follows the Java lines in order (each exact
	# expr on ONE comment line, the N2148 lesson):
	# `if((launchCounter += edelta()) >= launchTime && items.total() >= itemCapacity){`
	# `consume();`
	# `launchSound.at(x, y, 1f + Mathf.range(launchSoundPitchRand));`
	# `LaunchPayload entity = LaunchPayload.create();`
	# `items.each((item, amount) -> entity.stacks.add(new ItemStack(item, amount)));`
	# `entity.set(this);`
	# `entity.lifetime(120f);`
	# `entity.team(team);`
	# `entity.add();`
	# `Fx.launchPod.at(this);`
	# `items.clear();`
	# `Effect.shake(3f, 3f, this);`
	# `launchCounter = 0f;`
	# edelta() is `return efficiency * delta();`
	# (BuildingComp.java:1927-1929) with delta()
	# `return Time.delta * timeScale;`
	# (BuildingComp.java:1922-1924); source_delta is
	# Time.delta in ticks (seconds * 60 through
	# game_source_delta, arc Time.java:26), never raw
	# seconds. efficiency defaults 0.0, the Java field
	# default (BuildingComp.java:85 `transient float efficiency;`);
	# timeScale reads live from the sprite meta, default 1.0
	# (BuildingComp.java:98 `private transient float timeScale = 1f, timeScaleDuration;`).
	# items.total() is `public int total(){` with
	# `return total;` (ItemModule.java:174-176) over the
	# ItemModule; the port's items dict is keyed by item name
	# (the factory precedent, SourceFactoryBuildState.gd:
	# 89-101) and its total is the drill inventory total
	# (inventory.items_total, the Separator precedent).
	# itemCapacity is the catalog value (both defs
	# `itemCapacity = 100;`, Blocks.java:6793/6803); the
	# Block class default is `public int itemCapacity = 10;`
	# (Block.java:75). Scoping decisions, all source-backed:
	# (1) consume() triggers every consumer
	# (`for(Consume cons : block.consumers){` /
	# `cons.trigger(self());`, BuildingComp.java:1911-1915),
	# but only ConsumeItems / ConsumeItemDynamic remove
	# anything -- the launch-pad def has NO item consumer
	# (only `consumePower(4f);`, Blocks.java:6797),
	# ConsumePower has no trigger override, and the Consume
	# default trigger is empty (`public void trigger(Building build){}`,
	# Consume.java:50), so consume() is a no-op for items
	# here; the advanced def's `consumeLiquid(Liquids.oil, 9f/60f);`
	# (Blocks.java:6808) has no trigger override either, so
	# consume() is a no-op for liquids too -- the pure
	# advance owes consume() nothing. (2) the LaunchPayload
	# entity creation/application (LaunchPayload.create() +
	# entity.set(this) + lifetime(120f) + team + add()) has no
	# live entity in the port, so the launch is reported as
	# the pure result launched_stacks (the N2234 spawned_unit
	# precedent): the items.each stacks copy
	# (`Seq<ItemStack> stacks = new Seq<>();`,
	# LaunchPad.java:230) plus the launched bool; the live
	# entity creation/application defers. The stacks copy
	# skips zero amounts, like ItemModule.each
	# (`public void each(ItemConsumer cons){` with
	# `if(items[i] != 0){`, ItemModule.java:100-106). (3) the
	# launch sound and effects (launchSound.at + Fx.launchPod
	# + Effect.shake(3f, 3f, this)) are sound/presentation and
	# defer; this slice launches silently. (4) the launch
	# clears the items (`public void clear(){`,
	# ItemModule.java:281-284) and resets the counter to 0f;
	# the reset reopens the shouldConsume gate
	# (`public boolean shouldConsume(){` with
	# `return launchCounter < launchTime;`, LaunchPad.java:
	# 92-95) the NEXT tick -- consumption runs first, so the
	# gate reads the pre-advance counter. The defs share the
	# implementation: launch-pad (size 3, itemCapacity 100,
	# launchTime 60f * 20, `acceptMultipleItems = true;`,
	# `consumePower(4f);`, Blocks.java:6790-6797) and
	# advanced-launch-pad (size 4, itemCapacity 100,
	# launchTime 60f * 30, liquidCapacity 40f, consumeLiquid
	# oil 9f/60f, `consumePower(8f);`, Blocks.java:6800-6809).
	# The function does NOT mutate its input frame.
	var launch_counter: float = float(frame.get("launch_counter", 0.0))
	var launch_time: float = float(frame.get("launch_time", 1.0))
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var items: Dictionary = (frame.get("items", {}) as Dictionary).duplicate(true)
	var edelta: float = efficiency * source_delta * time_scale
	launch_counter += edelta
	var launched: bool = false
	var launched_stacks: Dictionary = {}
	if launch_counter >= launch_time and inventory.items_total(items) >= item_capacity:
		launched = true
		for item_name in items:
			if int(items[item_name]) != 0:
				launched_stacks[item_name] = int(items[item_name])
		items = {}
		launch_counter = 0.0
	return {"launched": launched, "launched_stacks": launched_stacks, "launch_counter": launch_counter, "items": items}
static func source_launch_pad_should_consume_state(frame: Dictionary) -> Dictionary:
	# LaunchPadBuild.shouldConsume() (LaunchPad.java:92, `public boolean shouldConsume(){` with `return launchCounter < launchTime;`, LaunchPad.java:94): the pad consumes only while its launchCounter is below launchTime. The override has NO enabled check -- enabled is handled separately by updateConsumption (BuildingComp.java:1954-1957, the disabled early return) and by the driver gate, the WallCrafter precedent -- so this pure function reads only the counter and the threshold: launchCounter is the build field (LaunchPad.java:84, `public float launchCounter;`, default 0f), launchTime is the block field (LaunchPad.java:32, `public float launchTime = 1f;`, the class default when the driver has not stamped the def value: launch-pad `launchTime = 60f * 20;`, Blocks.java:6794; advanced-launch-pad `launchTime = 60f * 30;`, Blocks.java:6804). A missing counter reads 0.0 (fresh build); a missing threshold reads the class default 1f. When the gate is false, updateConsumption folds efficiency to 0 (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();`, with BuildingComp.java:1992-1994, `if(!update){` / `efficiency = optionalEfficiency = 0f;`), so the pad draws no power while its counter sits full.
	var launch_counter: float = float(frame.get("launch_counter", 0.0))
	var launch_time: float = float(frame.get("launch_time", 1.0))
	return {"should_consume": launch_counter < launch_time, "launch_counter": launch_counter}

static func source_launch_pad_sense_state(sensor: String, launch_counter: float, launch_time: float, super_value: Variant = null) -> Dictionary:
	# The sense rows (LaunchPadBuild.sense(), LaunchPad.java:98-101), the pure logic-sense dispatch -- Java senses, in order (each exact expr on ONE comment line, the N2148 lesson):
	# `public double sense(LAccess sensor){`
	# `if(sensor == LAccess.progress) return Mathf.clamp(launchCounter / launchTime);`
	# `return super.sense(sensor);`
	# launchCounter is the frame value the N2238 advance tracks
	# (`public float launchCounter;`, LaunchPad.java:84: launchCounter += edelta() with the reset to 0f on launch, :146/161); launch_time is the per-def explicit input (launch-pad 60f * 20, advanced-launch-pad 60f * 30, Blocks.java:6794/6804; the class default is `public float launchTime = 1f;`, LaunchPad.java:32) -- the pure stays def-agnostic (the N2383 precedent), and the driver already stamps it per def every tick (1200f / 1800f, any other LaunchPad id keeps the class default 1f). Mathf.clamp(value) clamps to [0, 1] (arc Mathf.java:401-404, `return Math.max(Math.min(value, 1f), 0f);`), so the pure uses clampf(launch_counter / launch_time, 0.0, 1.0): a counter past the launchTime reads 1.0, a negative counter reads 0.0, and a zero launchTime reads 1.0 for a positive counter (launchCounter / 0f is +Infinity, clamped to 1f, exactly like Java) -- and the class-default edge reads 0.0 (launchCounter 0 at launchTime 1f). The same formula drives the progress bar (LaunchPad.java:70, `() -> Mathf.clamp(build.launchCounter / launchTime)`), so sense and the bar agree. super.sense is VERIFIED, not guessed: the BuildingComp switch (BuildingComp.java:2093-2122):
	# `return switch(sensor){`
	# `case health -> health;`
	# `case efficiency -> efficiency;`
	# `default -> Float.NaN; //gets converted to null in logic`
	# covers x / y / color / dead / solid / team / health / maxHealth / efficiency / timescale / range / rotation / totalItems / totalLiquids / totalPower / itemCapacity / liquidCapacity / powerCapacity / powerNetIn / powerNetOut / powerNetStored / powerNetCapacity / enabled / controlled / payloadCount / size / cameraX, cameraY, cameraWidth, cameraHeight, and the default branch is Float.NaN (converted to null in logic). The port ALREADY models that switch (SourceBuildingSenseState: sense_position_state, sense_health_process_state, sense_totals_state, sense_capacity_power_net_state, sense_enabled_controlled_state, sense_payload_size_state, sense_camera_default_state), so the pure takes the caller's super.sense result as super_value (default null = the default branch) instead of re-modeling the switch. senseObject / sense(Content) are separate overloads (BuildingComp.java:2124+) and are NOT modeled here. Pure-only, like the N2383 sense pures: the tick never calls sense (verified: grep `sense` in this driver finds no call site at all) -- sense is called by logic, not the tick, and the logic call site waits for a logic-executor slice (a port-wide concern, not a LaunchPad deferral).
	var is_progress: bool = sensor == "progress"
	var value: Variant = clampf(launch_counter / launch_time, 0.0, 1.0) if is_progress else super_value
	return {
		"progress_expr": "if(sensor == LAccess.progress) return Mathf.clamp(launchCounter / launchTime);",
		"super_expr": "return super.sense(sensor);",
		"sensor": sensor,
		"launch_counter": launch_counter,
		"launch_time": launch_time,
		"super_value": super_value,
		"is_progress": is_progress,
		"value": value,
	}

static func _launch_pad_first_item(items: Dictionary, item_order: Array) -> Variant:
	# ItemModule.first() (ItemModule.java:182-189, `public @Nullable Item first(){` with `for(int i = 0; i < items.length; i++){` / `if(items[i] > 0){` / `return content.item(i);`): scans the item slots in content-id order and returns the first with a count above zero, null when none is held. The port's items dict is keyed by item name (the factory precedent), so the scan runs over item_order -- the catalog item_names_by_id, the content-id order Java iterates (the N2225 take() precedent, the StackRouter _stack_router_first_item mirror). An item name outside the order is never picked: Java cannot hold a non-content item. An EMPTY order picks nothing: no content order is known, so the port cannot pick faithfully (the driver always passes the catalog order).
	for candidate in item_order:
		if inventory.item_count(items, str(candidate)) > 0:
			return str(candidate)
	return null

static func source_launch_pad_accept_item_state(frame: Dictionary, item: String, item_capacity: int, accept_multiple_items: bool, item_order: Array) -> Dictionary:
	# LaunchPadBuild.acceptItem (LaunchPad.java:138, `public boolean acceptItem(Building source, Item item){` with `return items.total() < itemCapacity && (acceptMultipleItems || items.total() == 0 || items.first() == item);`, LaunchPad.java:139): the intake gate -- a pad accepts the offered item only while it holds less than itemCapacity AND (it accepts multiple items OR it is empty OR the offered item is its first item). acceptMultipleItems is a field on LaunchPad itself (`public boolean acceptMultipleItems = false;`, LaunchPad.java:40), NOT on StorageBlock: the launch-pad def sets it (`acceptMultipleItems = true;`, Blocks.java:6796) and the advanced-launch-pad keeps the false default, so a plain pad takes any item while an advanced pad takes only its first item once it holds one. Both defs carry `itemCapacity = 100;` (Blocks.java:6793/6803); the Block class default is `public int itemCapacity = 10;` (Block.java:75). items.total() is `public int total(){` with `return total;` (ItemModule.java:174-176) over the ItemModule; the port's items dict is keyed by item name (the factory precedent, SourceFactoryBuildState.gd:89-101) and its total is the drill inventory total (inventory.items_total, the Separator precedent). items.first() is `public @Nullable Item first(){` (ItemModule.java:182-189, `for(int i = 0; i < items.length; i++){` / `if(items[i] > 0){` / `return content.item(i);` -- content-id order, via _launch_pad_first_item, the StackRouter precedent); the item compares by name string (the N2225 precedent -- Java compares Item references). A null first never equals the offered item (Java's `items.first() == item` is false when first() is null), and the total == 0 term accepts an empty pad anyway. The function does NOT mutate its input frame. There is no driver call site yet: no intake path calls acceptItem, so the pure is live but unwired -- the wiring waits for the frame-items-intake design (deferred in the N2333 register).
	var items: Dictionary = frame.get("items", {})
	var total: int = inventory.items_total(items)
	var first_item: Variant = _launch_pad_first_item(items, item_order)
	var accepts: bool = total < item_capacity and (accept_multiple_items or total == 0 or (first_item != null and str(first_item) == item))
	return {"accepts": accepts}

@warning_ignore("unused_parameter")
static func source_launch_pad_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the launch-pad tick wiring every
	# tick (LaunchPadBuild.updateTile(), LaunchPad.java:143,
	# gates on the launch gate (LaunchPad.java:146, `if((launchCounter += edelta()) >= launchTime && items.total() >= itemCapacity){`), so the launchCounter advance follows the folded efficiency; no placed-buildings driver ticks LaunchPad blocks, so this driver is the placed-launch-pad tick): each placed LaunchPad build gets its frame keys refreshed from the live rules, so the frame's cheating flag tracks team.rules().cheat and the consumption machinery skips consumption for a cheating team. The frame is bound at placement; a sprite that somehow lacks one gets it bound here instead of crashing the loop.
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
		if not _is_launch_pad_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_launch_pad_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_launch_pad_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# launchTime is a per-def block field the catalog does not carry (the registry entry holds consumePower / itemCapacity / size but no launchTime), so the driver stamps it from the block id every tick: launch-pad `launchTime = 60f * 20;` (Blocks.java:6794), advanced-launch-pad `launchTime = 60f * 30;` (Blocks.java:6804); any other LaunchPad id keeps the class default `public float launchTime = 1f;` (LaunchPad.java:32).
		var launch_time: float = 1.0
		if block_id == "launch-pad":
			launch_time = 60.0 * 20.0
		elif block_id == "advanced-launch-pad":
			launch_time = 60.0 * 30.0
		frame["launch_time"] = launch_time
		# The frame carries the Building.liquids LiquidModule
		# (frame["liquids"]): the live store lives on the
		# sprite meta (source_building_liquids, initialized
		# at placement for a block with a liquid consumer --
		# record_placed_block binds + applies consumeLiquid,
		# then initializes the store), so the driver syncs
		# the reference into the frame each tick BEFORE the
		# fold and the pure liquid row reads the oil amount
		# from it (the Fracker:327 precedent). A pad with no
		# liquid store (the plain launch-pad) syncs {} and
		# the row reads 0.0 -- but the plain def has no
		# liquid consumer, so its row is absent anyway.
		frame["liquids"] = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a launch pad with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the launch gate (LaunchPad.java:146)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a launch pad does not take the early return. A launch pad with no power consumer is untouched: the liquid row is live since N2253 (it folds beside the power row below) and the updateTile advance is live since N2238 (it runs after this fold, below), and LaunchPadBuild HAS a shouldConsume override (LaunchPad.java:92, `public boolean shouldConsume(){` with `return launchCounter < launchTime;`, LaunchPad.java:94) -- N2186 wires the gate through the pure source_launch_pad_should_consume_state function, ANDed with enabled (the BuildingComp default, BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`, BuildingComp.java:756, is what the driver uses). productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var gate: Dictionary = source_launch_pad_should_consume_state(frame)
			var should_consume: bool = bool(frame.get("enabled", true)) and bool(gate.get("should_consume", false))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_launch_pad_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			# N2253: the liquid row folds beside the power row.
			# The consumer comes from the catalog consumeLiquid
			# row (advanced-launch-pad only: amount 0.15 =
			# 9f/60f, liquid oil, Blocks.java:6808); the plain
			# launch-pad carries no consumeLiquid row, so its
			# liquid row is absent. The oil id resolves from
			# the liquid catalog (liquid_id_by_name, the
			# FactoryBuildState:917 precedent). The source
			# delta is Time.delta in ticks: game_source_delta
			# is seconds * 60 (arc Time.java:26), never raw
			# seconds; timeScale reads live from the sprite
			# meta, default the game default 1.0
			# (BuildingComp.java:98). The multiplier is the
			# Consume default 1f (Consume.java:18) -- the def
			# sets none.
			var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
			var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
			var liquid_id_by_name: Dictionary = source_content_registry_state.source_liquid_catalog_state(catalog).get("liquid_id_by_name", {})
			var consume_liquid_rows: Array = block.properties.get("consumeLiquid", [])
			var liquid_row: Dictionary = {"has_liquid_row": false, "row": {}}
			var liquid_amount_per_frame: float = 0.0
			var oil_id: int = -1
			if not consume_liquid_rows.is_empty():
				var liquid_row_def: Dictionary = consume_liquid_rows[0]
				oil_id = int(liquid_id_by_name.get(str(liquid_row_def.get("liquid", "")), -1))
				liquid_amount_per_frame = float(liquid_row_def.get("amount", 0.0))
				liquid_row = source_launch_pad_liquid_consumer_row_state(frame, true, oil_id, liquid_amount_per_frame, source_delta, time_scale, float(frame.get("efficiency_scale", 1.0)), 1.0)
			if bool(liquid_row.get("has_liquid_row", false)):
				required_results.append(liquid_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
			# N2253 second pass: ConsumeLiquid.update removes
			# the oil (`build.liquids.remove(liquid, amount *
			# build.edelta() * multiplier.get(build));`,
			# ConsumeLiquid.java:37-39), only when `update &&
			# efficiency > 0` (BuildingComp.java:1999-2002),
			# with edelta from the FOLDED efficiency
			# (`return efficiency * delta();`,
			# BuildingComp.java:1927-1929). Direct removal
			# after the fold -- NOT the updates array: the
			# machinery's second pass only records update
			# consumers in updated_consumers, it never calls
			# update on them (SourceAdjacentFactoryBuildState
			# :382 passes actors for bookkeeping only), so an
			# actor would remove no oil. The removal goes
			# through the shared liquid module helper with a
			# fresh cache_sums array (the PayloadLoader
			# precedent); frame["liquids"] is the sprite meta
			# reference, so the store updates in place.
			if bool(liquid_row.get("has_liquid_row", false)) and bool(setup.get("update", false)) and float(frame.get("efficiency", 0.0)) > 0.0 and oil_id >= 0:
				var folded_edelta: float = float(frame.get("efficiency", 0.0)) * source_delta * time_scale
				var remove_amount: float = liquid_amount_per_frame * folded_edelta * 1.0
				var liquids_store: Dictionary = frame.get("liquids", {})
				if liquids_store.has("liquids") and oil_id < int(liquids_store["liquids"].size()):
					var cache_sums: Array = []
					cache_sums.resize(int(liquids_store["liquids"].size()))
					cache_sums.fill(0.0)
					source_liquid_module_state.source_remove_state(liquids_store, oil_id, remove_amount, cache_sums)
		# N2238: the updateTile advance runs after consumption,
		# like Java's Building.update() (BuildingComp.java:2274
		# `updateConsumption();`, then the updateTile gate
		# `if(enabled || !block.noUpdateDisabled){` at
		# BuildingComp.java:2276-2277 with `updateTile();`;
		# noUpdateDisabled defaults
		# false, Block.java:170, so Java runs updateTile even
		# when disabled -- in Java a disabled launch pad's
		# counter freezes (efficiency is zeroed by the
		# disabled early return, BuildingComp.java:1954-1957)
		# and edelta() is 0. The port keeps the enabled gate
		# below as a pragmatic choice (the N2195 coordinator-fix
		# precedent): the driver skips the consumption fold when
		# disabled, so the frame efficiency goes stale and
		# running the advance on it would charge the counter
		# from a stale efficiency. The driver-wide
		# disabled-early-return slice (deferred in the N2238
		# register) removes this gate for all families.
		# super.updateTile() is an empty no-op
		# (BuildingComp.java:2010-2012), so the driver owes it
		# nothing. The source delta is Time.delta in ticks:
		# game_source_delta(game, seconds) is seconds * 60
		# (arc Time.java:26), never raw seconds. timeScale
		# reads live from the sprite meta, default the game
		# default 1.0 (BuildingComp.java:98 `private transient
		# float timeScale = 1f, timeScaleDuration;`).
		# itemCapacity comes from the catalog (both defs 100);
		# the Block class default 10 (Block.java:75) applies
		# when the catalog is silent. A pad with no power
		# consumer or a cheating team never folds efficiency,
		# so the advance reads the stale/absent frame
		# efficiency (0.0 default) and its counter freezes --
		# the disabled / cheating / no-power advance waits for
		# its own slice (deferred in the N2238 register). The
		# gate reads the pre-advance counter (consumption runs
		# first), so a launch reopens the shouldConsume gate
		# the NEXT tick -- and a launch needs the counter at
		# launchTime (1200f / 1800f) with a full pad, so a
		# single tick never launches from a fresh frame.
		if bool(frame.get("enabled", true)):
			var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
			var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
			var item_capacity: int = int(block.properties.get("itemCapacity", 10))
			var advanced: Dictionary = source_launch_pad_update_tile_advance_state(frame, source_delta, time_scale, item_capacity)
			frame["launch_counter"] = float(advanced.get("launch_counter", 0.0))
			frame["items"] = advanced.get("items", {})
			frame["launched"] = bool(advanced.get("launched", false))
			frame["launched_stacks"] = advanced.get("launched_stacks", {})
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
