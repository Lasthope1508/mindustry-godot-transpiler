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
# Geometry.d8edge (arc Geometry.java:35-40), the diagonal edge
# array the light loop offsets along (`public static Point2 d8edge(int i){` with `return d8edge[Mathf.mod(i, 4)];`, Geometry.java:59-61).
const SOURCE_LAUNCH_PAD_D8EDGE := [Vector2i(1, 1), Vector2i(-1, 1), Vector2i(-1, -1), Vector2i(1, -1)]

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
	# Documented limits: (1) power + liquid first pass -- the launch pad's power consumer is static (consumePower 4f, Blocks.java:6797; consumePower 8f, Blocks.java:6809), and the advanced def's oil consumer is static too (consumeLiquid oil 9f/60f, Blocks.java:6808), so the folded efficiency is the min over the *modeled* consumers (power + the advanced def's oil row, N2253; the plain launch-pad has no liquid consumer, so its liquid row is absent). (2) shouldConsume gate LIVE (N2186) -- LaunchPadBuild.shouldConsume() (`return launchCounter < launchTime;`, LaunchPad.java:92-95) is the pure source_launch_pad_should_consume_state gate over the tracked launchCounter; the driver ANDs enabled (BuildingComp.java:755-757, `return enabled;`) and the machinery folds efficiency to 0 when the gate is false (BuildingComp.java:1960/:1992-1994). (3) updateTile advance live (N2238) -- the launchCounter advance, the full-and-timed launch gate, the stacks copy, items.clear and the launchCounter = 0f reset (LaunchPad.java:143-161) advance in the pure function (source_launch_pad_update_tile_advance_state); the LaunchPayload entity creation/application (LaunchPad.java:150-155) still defers as a live entity (descriptor live N2397); the launch sound / effects are live since N2444 (item (10)). (4) Liquid consumer row LIVE (N2253) -- advanced-launch-pad consumes oil 9f/60f (Blocks.java:6808), folded as a required row with is_power false; the plain launch-pad has no liquid consumer (row absent). (5) Two defs, one driver -- launch-pad + advanced-launch-pad share the LaunchPad implementation, so the same driver covers the whole family; the advanced def waits for its own verification slice. (6) acceptItem gate LIVE (N2333) -- LaunchPadBuild.acceptItem() (LaunchPad.java:138-140) is the pure source_launch_pad_accept_item_state gate (total < capacity AND (accept_multiple OR total == 0 OR first == item), first scanned in content-id order); launch-pad accepts multiple items (`acceptMultipleItems = true;`, Blocks.java:6796), advanced-launch-pad keeps the false class default (LaunchPad.java:40). Pure + test + proof only: no intake path calls acceptItem yet, so the driver wiring waits for the frame-items-intake design. (7) Sense rows live (N2389) -- LaunchPadBuild.sense() (LaunchPad.java:98-101) is the pure source_launch_pad_sense_state dispatch (progress -> clampf(launch_counter / launch_time, 0.0, 1.0), other sensors -> the caller-supplied super_value, null = the Float.NaN default branch); pure-only, the tick never calls sense (sense is called by logic, and the logic call site waits for a logic-executor slice). (8) Launch pod result live (N2397) -- the LaunchPayload entity creation (LaunchPad.java:150-155) is the pure source_launch_pad_launch_pod_state descriptor ({stacks, lifetime 120f, team, x, y} from the N2238 launched + launched_stacks, null when not launched, the N2234 spawned_unit precedent); no live entity is created, consume() is a no-op for a LaunchPad (no item consumer; the Consume default trigger is empty, Consume.java:50), and the launch sound / effects are live since N2444 (item (10)). (9) Draw rows live (N2420) -- the draw pure (source_launch_pad_draw_state) models draw() (LaunchPad.java:104-136: the bottom/liquid branch + super.draw() + the light-region progress loop + the shadow/pod pair) + icons() (:79-80: [previewRegion], folded into the draw pure -- icons() takes no args and the SSOT schema validator requires non-empty input keys). Pure-only: the tick never calls draw -- draw is called by the renderer, icons by the atlas, and the call sites wait for renderer/UI slices. (10) Launch FX rows live (N2444) -- the launch sound / effects (launchSound.at(x, y, 1f + Mathf.range(launchSoundPitchRand)) + Fx.launchPod.at(this) + Effect.shake(3f, 3f, this), LaunchPad.java:149/156/158) are the pure source_launch_pad_launch_effect_state (launched + x/y + the caller-supplied pitch_roll in [-0.1, 0.1], no RNG in the pure -- the N2421 precedent): sound_call {sound padLaunch, x, y, pitch 1f + roll} + fx_call {effect launchPod, x, y} + shake_call {intensity 3f, duration 3f, x, y}, all null unless launched. Pure-only: the tick never calls it -- the launch fire (N2238/N2397) owns the launched gate, and the sound/FX call sites wait for audio/effect slices. (11) Config/display rows live (N2466) -- display() (LaunchPad.java:164-177) is the pure source_launch_pad_display_state (destination_label {key "launch.destination", value the "sectors.nonelaunch" bundle token or "[accent]" + name}, null unless campaign && !client && player team; super.display recorded, not a symbol; the pad(4)/wrap/width(200f)/left() layout is UI chrome, not modeled) and shouldShowConfigure (:180-182) + buildConfiguration (:185-203) are the pure source_launch_pad_config_state (show_configure = isCampaign; button_call {icon Icon.upOpen, style Styles.cleari, size 40.0} null unless campaign && !client; deselect_called on the gate-fail early return; destination_after = selected iff campaign && same planet, else prev; refresh_import_rates_called = prev != null && the callback applied). Pure-only: the tick never calls display/config -- the call sites wait for UI slices.
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
	# live since N2444 (driver docstring item (10)); this slice
	# launches silently (the FX pure reports the calls). (4) the launch
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

static func source_launch_pad_launch_pod_state(launched: bool, launched_stacks: Dictionary, team_id: int, x: float, y: float) -> Dictionary:
	# The launch pod descriptor (LaunchPadBuild.updateTile(),
	# LaunchPad.java:147-159), the pure pod result -- the
	# launch fire itself is ALREADY LIVE since N2238 (the
	# full-and-timed gate, the stacks copy, items.clear(),
	# the launchCounter = 0f reset, exposing launched +
	# launched_stacks), so this pure does NOT re-implement
	# the fire: it consumes the N2238 advance's launched /
	# launched_stacks shape and reports the LaunchPayload
	# entity creation as a pure descriptor (the N2234
	# spawned_unit precedent -- a live-entity creation
	# reported as a pure result, NO live entity created;
	# the port has no live entity spawn path). The Java
	# lines, in order (each exact expr on ONE comment line,
	# the N2148 lesson):
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
	# The pod stacks are the N2238 launched_stacks (the
	# items.each copy -- `Seq<ItemStack> stacks = new Seq<>();`,
	# LaunchPad.java:230, the LaunchPayloadComp stacks field,
	# LaunchPad.java:227-230 -- zero amounts skipped like
	# ItemModule.each); the lifetime is the 120f literal
	# (`entity.lifetime(120f);`, the Timedc lifetime field,
	# TimedComp.java:10 `float time, lifetime;`); team is the
	# pad's team (`entity.team(team);`); x / y are the pad's
	# world position (`entity.set(this);` positions the pod
	# at the pad). consume() (:148) is a no-op for a
	# LaunchPad, verified: the pad has NO item consumer
	# (only `consumePower(4f);`, Blocks.java:6797, and the
	# advanced def's `consumeLiquid(Liquids.oil, 9f/60f);`,
	# Blocks.java:6808), only ConsumeItems /
	# ConsumeItemDynamic override trigger (ConsumeItems.
	# java:44 `public void trigger(Building build){`), and
	# the Consume default trigger is empty (`public void trigger(Building build){}`,
	# Consume.java:50) -- so the pure owes consume()
	# nothing. entity.add() has no live-entity meaning in
	# the port (no Groups / entity add path), so the pod is
	# reported, never added. The launch sound and effects
	# (launchSound.at + Fx.launchPod + Effect.shake(3f, 3f,
	# this)) are sound/presentation and live since N2444
	# (the launch-effect pure). When
	# launched is false the pod is null (no pod exists --
	# the N2234 null-when-not-spawned precedent). The pod
	# holds a deep copy of the stacks, so mutating the
	# caller's launched_stacks after the call never changes
	# the reported pod. The function does NOT mutate its
	# inputs, and does NOT touch the N2238 advance's result
	# keys (no schema churn on N2238).
	var pod: Variant = null
	if launched:
		pod = {"stacks": (launched_stacks as Dictionary).duplicate(true), "lifetime": 120.0, "team": team_id, "x": x, "y": y}
	return {"pod": pod, "launched": launched}

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

static func _launch_pad_mathf_curve(f_value: float, from_value: float, to_value: float) -> float:
	# Mathf.curve(f, from, to) (arc Mathf.java:608-616), Java-exact: 0 below from, 1 above to, linear between.
	# `public static float curve(float f, float from, float to){`
	# `return (f - from) / (to - from);`
	if f_value < from_value:
		return 0.0
	if f_value > to_value:
		return 1.0
	return (f_value - from_value) / (to_value - from_value)

static func source_launch_pad_draw_state(x_value: float, y_value: float, size_value: int, has_liquids: bool, draw_liquid: Variant, liquid_amount: float, liquid_capacity: float, bottom_color: String, liquid_pad: float, items_total: int, item_capacity: int, launch_counter: float, launch_time: float, light_region_found: bool, light_steps: int, light_step: float, light_color: String) -> Dictionary:
	# The draw rows (LaunchPadBuild.draw(), LaunchPad.java:104-136), the pure draw-call dict -- the port never draws for real (the SourceBlockDrawState / SourceBaseTurretDrawState pattern, the N2396 MassDriver precedent: the pure returns the draw calls as data). Java draws, in order (each exact expr on ONE comment line, the N2148 lesson):
	# `if(hasLiquids && drawLiquid != null){`
	# `Draw.color(bottomColor);`
	# `Fill.square(x, y, size * tilesize/2f - liquidPad);`
	# `Draw.color();`
	# `LiquidBlock.drawTiledFrames(block.size, x, y, liquidPad, liquidPad, liquidPad, liquidPad, drawLiquid, liquids.get(drawLiquid) / liquidCapacity);`
	# `super.draw();`
	# `if(lightRegion.found()){`
	# `Draw.color(lightColor);`
	# `float progress = Math.min((float)items.total() / itemCapacity, launchCounter / launchTime);`
	# `for(int i = 0; i < 4; i++){`
	# `for(int j = 0; j < lightSteps; j++){`
	# `float alpha = Mathf.curve(progress, (float)j / lightSteps, (j+1f) / lightSteps);`
	# `float offset = -(j - 1f) * lightStep;`
	# `Draw.color(Pal.metalGrayDark, lightColor, alpha);`
	# `Draw.rect(lightRegion, x + Geometry.d8edge(i).x * offset, y + Geometry.d8edge(i).y * offset, i * 90);`
	# `Draw.reset();`
	# `Drawf.shadow(x, y, size * tilesize);`
	# `Draw.rect(podRegion, x, y);`
	# The def constants (LaunchPad.java:39-47, verify-first -- no def overrides them except drawLiquid / liquidCapacity):
	# `public Color lightColor = Color.valueOf("eab678");`
	# `public float lightStep = 1f;`
	# `public int lightSteps = 3;`
	# `public float liquidPad = 2f;`
	# `public @Nullable Liquid drawLiquid;`
	# `public Color bottomColor = Pal.darkerMetal;`
	# `public TextureRegion[] icons(){`
	# `return new TextureRegion[]{previewRegion};`
	# `public static void drawTiledFrames(int size, float x, float y, float padLeft, float padRight, float padTop, float padBottom, Liquid liquid, float alpha){`
	# `public static void shadow(float x, float y, float rad){`
	# `darkerMetal = Color.valueOf("565666"),`
	# `metalGrayDark = Color.valueOf("6e7080"),`
	# `public static final int tilesize = 8;`
	# The liquid branch is the advanced def only in practice: drawLiquid is null by default (`public @Nullable Liquid drawLiquid;`, LaunchPad.java:46) and only the advanced-launch-pad sets it (`drawLiquid = Liquids.oil;`, Blocks.java:6807, with `liquidCapacity = 40f;`, Blocks.java:6805); the plain launch-pad def (Blocks.java:6790-6797) has no liquid consumer, so hasLiquids is false there and the branch is off. The pure takes has_liquids + draw_liquid as explicit inputs and returns liquid_call null unless BOTH hold (the N2397 null-when-absent precedent). The bottom square half-size is size * tilesize/2f - liquidPad (10.0 for the size-3 pad, 14.0 for the size-4 pad); the tiled-frames call carries all four pads (the 8-arg overload, LiquidBlock.java:39-41, each pad liquidPad) and alpha liquids.get(drawLiquid) / liquidCapacity. The per-tile truncation loop inside drawTiledFrames (LiquidBlock.java:44-72) is the callee's own geometry -- the pure records the CALL, not the tiles (the N2396 record-the-call precedent). The light loop is the progress math: progress is the min of the items fraction and the launch-counter fraction (the N2238 advance tracks launchCounter, the N2389 sense pure reads the same launchCounter / launchTime ratio -- the pure takes items_total / item_capacity / launch_counter / launch_time as explicit params, not the frame, the N2415 precedent). Mathf.curve(f, from, to) is the arc 3-arg form (`public static float curve(float f, float from, float to){`, Mathf.java:608-616: 0 below from, 1 above to, `return (f - from) / (to - from);` between), implemented by the _launch_pad_mathf_curve helper (first use in the port -- no curve helper existed). The edge offsets ride Geometry.d8edge(i) (`public static Point2 d8edge(int i){` with `return d8edge[Mathf.mod(i, 4)];`, Geometry.java:59-61), the arc diagonal array [(1, 1), (-1, 1), (-1, -1), (1, -1)] (Geometry.java:35-40), as the SOURCE_LAUNCH_PAD_D8EDGE const. The color mix is Pal.metalGrayDark ("6e7080", Pal.java:83) -> lightColor ("eab678", LaunchPad.java:39) by alpha; bottomColor is Pal.darkerMetal ("565666", Pal.java:35). lightSteps 3 / lightStep 1f / liquidPad 2f are class defaults (LaunchPad.java:42-45) with NO def override on either def, so the loop is 4 x 3 = 12 calls for both defs -- the pure still takes them as explicit params (def-agnostic, the N2383 precedent). icons() (LaunchPad.java:79-80) returns {previewRegion} -- folded into the draw pure as the icon_regions result key: icons() takes no args and the SSOT schema validator requires non-empty input keys, so a zero-arg pure cannot register (the N2396 precedent). previewRegion is the `@-preview` region with fallback `@` (LaunchPad.java:38). super.draw() is Block/Building draw (NOT modeled here -- the pure records the call, the N2396 drawPlace precedent). Drawf.shadow (Drawf.java:350-352) is the circle-shadow rect at radius size * tilesize (24.0 / 32.0). tilesize is the Java constant 8.0 (`public static final int tilesize = 8;`, Vars.java:135 -- NEVER the game tile_size 32, the N2375 lesson). Two defs: launch-pad size 3 / itemCapacity 100 / launchTime 60f * 20 (Blocks.java:6792-6794), advanced-launch-pad size 4 / itemCapacity 100 / launchTime 60f * 30 (Blocks.java:6802-6804). Pure-only: the tick never calls draw -- draw is called by the renderer, icons by the atlas, and the call sites wait for renderer/UI slices.
	var liquid_call: Variant = null
	if has_liquids and draw_liquid != null:
		liquid_call = {
			"call": "LiquidBlock.drawTiledFrames(block.size, x, y, liquidPad, liquidPad, liquidPad, liquidPad, drawLiquid, liquids.get(drawLiquid) / liquidCapacity);",
			"bottom_color": bottom_color,
			"square_half_size": float(size_value) * 8.0 / 2.0 - liquid_pad,
			"size": size_value,
			"x": x_value,
			"y": y_value,
			"pad_left": liquid_pad,
			"pad_right": liquid_pad,
			"pad_top": liquid_pad,
			"pad_bottom": liquid_pad,
			"liquid": str(draw_liquid),
			"alpha": liquid_amount / liquid_capacity,
		}
	var super_draw_call: Dictionary = {
		"call": "super.draw();",
	}
	var light_progress: Variant = null
	var light_calls: Array = []
	if light_region_found:
		light_progress = minf(float(items_total) / float(item_capacity), launch_counter / launch_time)
		for i in range(4):
			for j in range(light_steps):
				var alpha: float = _launch_pad_mathf_curve(float(light_progress), float(j) / float(light_steps), float(j + 1) / float(light_steps))
				var offset: float = -(float(j) - 1.0) * light_step
				var edge: Vector2i = SOURCE_LAUNCH_PAD_D8EDGE[i]
				light_calls.append({
					"i": i,
					"j": j,
					"alpha": alpha,
					"offset": offset,
					"x": x_value + float(edge.x) * offset,
					"y": y_value + float(edge.y) * offset,
					"rotation": float(i * 90),
					"progress": float(light_progress),
					"color_from": "6e7080",
					"color_to": light_color,
				})
	var shadow_call: Dictionary = {
		"call": "Drawf.shadow(x, y, size * tilesize);",
		"x": x_value,
		"y": y_value,
		"radius": float(size_value) * 8.0,
	}
	var pod_call: Dictionary = {
		"call": "Draw.rect(podRegion, x, y);",
		"region": "podRegion",
		"x": x_value,
		"y": y_value,
	}
	return {
		"liquid_expr": "LiquidBlock.drawTiledFrames(block.size, x, y, liquidPad, liquidPad, liquidPad, liquidPad, drawLiquid, liquids.get(drawLiquid) / liquidCapacity);",
		"super_expr": "super.draw();",
		"light_expr": "Draw.rect(lightRegion, x + Geometry.d8edge(i).x * offset, y + Geometry.d8edge(i).y * offset, i * 90);",
		"shadow_expr": "Drawf.shadow(x, y, size * tilesize);",
		"pod_expr": "Draw.rect(podRegion, x, y);",
		"icons_expr": "return new TextureRegion[]{previewRegion};",
		"x": x_value,
		"y": y_value,
		"size": size_value,
		"has_liquids": has_liquids,
		"draw_liquid": draw_liquid,
		"light_region_found": light_region_found,
		"light_progress": light_progress,
		"liquid_call": liquid_call,
		"super_draw_call": super_draw_call,
		"light_calls": light_calls,
		"shadow_call": shadow_call,
		"pod_call": pod_call,
		"icon_regions": ["previewRegion"],
	}

static func source_launch_pad_launch_effect_state(launched: bool, x: float, y: float, pitch_roll: float) -> Dictionary:
	# The launch sound / FX rows (LaunchPadBuild.updateTile(), LaunchPad.java:147-159), the pure launch-effect rows -- the launch fire itself is ALREADY LIVE since N2238 (the full-and-timed gate, the stacks copy, items.clear(), the launchCounter = 0f reset, exposing launched + launched_stacks) and the pod descriptor since N2397, so this pure does NOT re-implement the fire: it consumes the N2238 advance's launched gate and reports the launch sound + effect + shake as pure call records (the N2396 record-the-call precedent -- the port plays no sound, spawns no effect, shakes no camera; the audio/effect call sites wait for their own slices). The Java lines, in order (each exact expr on ONE comment line, the N2148 lesson):
	# `if((launchCounter += edelta()) >= launchTime && items.total() >= itemCapacity){`
	# `launchSound.at(x, y, 1f + Mathf.range(launchSoundPitchRand));`
	# `Fx.launchPod.at(this);`
	# `Effect.shake(3f, 3f, this);`
	# The sound is the block field (`public Sound launchSound = Sounds.padLaunch;`, LaunchPad.java:34) -- the Sounds class is build-generated (mindustry.gen.Sounds, no gen/ dir in the upstream checkout), but the token is exact: the asset is core/assets/sounds/block/padLaunch.ogg. The pitch is 1f + Mathf.range(launchSoundPitchRand) with the class default (`public float launchSoundPitchRand = 0.1f;`, LaunchPad.java:33, no def override on either def), and Mathf.range(r) is the arc uniform roll in [-r, r] (`public static float range(float range){` with `return random(-range, range);`, arc Mathf.java:220-222) -- so the pitch roll is an ALREADY-ROLLED caller-supplied input in [-0.1, 0.1] and the pure never rolls (NO RNG in pures, the N2421 precedent). The effect is Fx.launchPod (`launchPod = new Effect(50, e -> {`, Fx.java:2747), fired at the pad (`.at(this)` positions the effect at the pad's x/y). The shake is Effect.shake(3f, 3f, this) -- the Position overload (`public static void shake(float intensity, float duration, Position loc){`, Effect.java:210-212) delegates to (`public static void shake(float intensity, float duration, float x, float y){`, Effect.java:201), so the first arg is the intensity and the second the duration, both 3f; the camera-distance falloff inside the x/y overload (Effect.java:204-207) is the callee's own behavior -- the pure records the CALL params at the pad position, not the falloff result. When launched is false all three calls are null (no launch, no sound/FX -- the N2397 null-when-absent precedent). The pod creation (LaunchPad.java:150-155) is NOT ported again (live since N2238/N2397) and the launchCounter reset is NOT this slice's (the N2238 advance owns it). The function does NOT mutate its inputs, and does NOT touch the N2238/N2397 result keys (no schema churn).
	var sound_call: Variant = null
	var fx_call: Variant = null
	var shake_call: Variant = null
	if launched:
		sound_call = {"sound": "padLaunch", "x": x, "y": y, "pitch": 1.0 + pitch_roll}
		fx_call = {"effect": "launchPod", "x": x, "y": y}
		shake_call = {"intensity": 3.0, "duration": 3.0, "x": x, "y": y}
	return {"sound_call": sound_call, "fx_call": fx_call, "shake_call": shake_call}

static func source_launch_pad_display_state(is_campaign: bool, is_client: bool, is_player_team: bool, destination: Variant) -> Dictionary:
	# The display rows (LaunchPadBuild.display(), LaunchPad.java:164-177), the pure destination-label state -- Java, in order (each exact expr on ONE comment line, the N2148 lesson):
	# `super.display(table);`
	# `if(!state.isCampaign() || net.client() || team != player.team()) return;`
	# `Sector dest = state.rules.sector == null ? null : state.rules.sector.info.destination;`
	# `return Core.bundle.format("launch.destination",`
	# `dest == null || !dest.hasBase() ? Core.bundle.get("sectors.nonelaunch") :`
	# `"[accent]" + dest.name());`
	# The gate is campaign AND not a net client AND the pad's team is the player's team (:167); when it fails the label row never renders (destination_label null). The destination is caller-supplied (the sector state is not in the driver, the N2435 precedent): null when there is no sector or no destination (`state.rules.sector == null ? null : state.rules.sector.info.destination`, :171; the destination field is `public @Nullable Sector destination;`, SectorInfo.java:51-52), else a Dict {name, has_base} (hasBase() is Sector.java:135). The label is a Dict {key, value} because Java calls Core.bundle.format with an argument (the N2450 precedent -- the UI composes the rendered string): the key is "launch.destination" (`launch.destination = Destination: {0}`, bundle.properties:875) and the value is the BUNDLE TOKEN "sectors.nonelaunch" (`sectors.nonelaunch = [lightgray]none (sun)`, bundle.properties:921) when the destination is null or has no base, else "[accent]" + name -- NOT the localized text. The super.display(table) call is recorded, not a symbol (the N2374/N2396 precedent -- the base Building display rows are the callee's own content). The pad(4)/wrap/width(200f)/left() layout is UI chrome -- not modeled. Pure-only: display runs from the UI, and the call site waits for a UI slice.
	var destination_label: Variant = null
	if is_campaign and not is_client and is_player_team:
		var value: String = "sectors.nonelaunch"
		if destination != null:
			var dest: Dictionary = destination
			if bool(dest.get("has_base", false)):
				value = "[accent]" + str(dest.get("name", ""))
		destination_label = {"key": "launch.destination", "value": value}
	return {"destination_label": destination_label}

static func source_launch_pad_config_state(is_campaign: bool, is_client: bool, selected_sector: Variant, current_sector: Variant, prev_destination: Variant) -> Dictionary:
	# The config rows (LaunchPadBuild.shouldShowConfigure(), LaunchPad.java:180-182 + buildConfiguration(), LaunchPad.java:185-203), the pure config fold -- Java, in order (each exact expr on ONE comment line, the N2148 lesson):
	# `return state.isCampaign();`
	# `public void buildConfiguration(Table table){`
	# `if(!state.isCampaign() || net.client()){`
	# `deselect();`
	# `table.button(Icon.upOpen, Styles.cleari, () -> {`
	# `ui.planet.showSelect(state.rules.sector, other -> {`
	# `if(state.isCampaign() && other.planet == state.rules.sector.planet){`
	# `var prev = state.rules.sector.info.destination;`
	# `state.rules.sector.info.destination = other;`
	# `if(prev != null){`
	# `prev.info.refreshImportRates(state.getPlanet());`
	# `}).size(40f);`
	# show_configure is shouldShowConfigure (:181): campaign only -- folded into this pure as a result key (the Player param is ignored by Java). The button is a CALL record (the N2443 picker precedent -- the UI is NOT ported): {icon "Icon.upOpen" (LaunchPad.java:191, used across the UI), style "Styles.cleari" (Styles.java:89/337), size 40.0}, null unless campaign && !client (:186). deselect_called is the early-return deselect (:187) when the gate FAILS; the click-time deselect (:201) is part of the button_call record, not a separate key. The select callback (:192-199) re-checks isCampaign and the planet match -- the pure REUSES the one is_campaign input for both the build gate and the callback re-check (one evaluation moment; a click-time campaign change is a UI-timing concern, not a pure concern). The client gate lives on the button, not the callback -- Java's callback (:193) checks only campaign + planet. selected_sector / current_sector are null-or-Dicts {planet} (caller-supplied, the N2435 precedent); the planet compares by token (the N2225 precedent -- Java compares Planet references, `other.planet == state.rules.sector.planet`, :193). A null selection (dialog dismissed, the listener never fires) or a null current sector (Java would NPE on state.rules.sector.planet) applies nothing: destination_after stays prev_destination and no refresh fires. destination_after is the selected sector iff campaign && the planets match, else prev_destination. refresh_import_rates_called is (prev != null && the callback applied): Java's only condition inside the callback is `if(prev != null){` (:196) -- a same-sector re-selection still refreshes in Java (the assignment runs, prev != null), so "destination changed" means the callback applied, not value-inequality. Pure-only: buildConfiguration runs from the configure UI and the select callback from the planet dialog -- the call sites wait for UI slices. Config/display rows live (N2466).
	var show_configure: bool = is_campaign
	var button_call: Variant = null
	var deselect_called: bool = false
	if is_campaign and not is_client:
		button_call = {"icon": "Icon.upOpen", "style": "Styles.cleari", "size": 40.0}
	else:
		deselect_called = true
	var selection_applied: bool = false
	if is_campaign and selected_sector != null and current_sector != null:
		var selected: Dictionary = selected_sector
		var current: Dictionary = current_sector
		selection_applied = str(selected.get("planet", "")) == str(current.get("planet", ""))
	var destination_after: Variant = selected_sector if selection_applied else prev_destination
	var refresh_import_rates_called: bool = prev_destination != null and selection_applied
	return {
		"show_configure": show_configure,
		"button_call": button_call,
		"deselect_called": deselect_called,
		"destination_after": destination_after,
		"refresh_import_rates_called": refresh_import_rates_called,
	}

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
