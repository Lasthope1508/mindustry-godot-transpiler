extends RefCounted
class_name SourcePayloadUnloaderBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_move_out_payload_state := preload("res://src/game/SourceBlockProducerMoveOutPayloadState.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")
const source_content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const inventory := preload("res://src/game/SourceDrillInventoryRuntimeState.gd")
const source_liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const source_building_liquid_state := preload("res://src/game/SourceBuildingLiquidState.gd")
const source_building_item_dump_state := preload("res://src/game/SourceBuildingItemDumpState.gd")

# The PayloadUnloader implementation (PayloadUnloader.java:8, `public class PayloadUnloader extends PayloadLoader{`): payload-unloader (hasPower = true;, consumePower(2f);, size 3, offloadSpeed 4, maxPowerUnload 80f, Blocks.java:6691-6698). PayloadUnloader sets outputsPower=true, consumesPower=true, outputsLiquid=true, loadPowerDynamic=false, canOverdrive=false (PayloadUnloader.java:15-19), offloadSpeed 4 (PayloadUnloader.java:9), maxPowerUnload 80f (PayloadUnloader.java:11, `public float maxPowerUnload = 80f;`). PayloadUnloader extends PayloadLoader, NOT a drill or factory, so it cannot reuse an existing frame key; this driver uses its own family frame key ("source_payload_unloader_building", the mechanical-pump / beam-drill / mend-projector / overdrive-projector / force-projector / base-shield / regen-projector / constructor / payload-loader precedent), and this slice adds the payload-unloader key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourcePayloadUnloader* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the unload gate (PayloadUnloader.java:69, `if(efficiency > 0.01f && timer(timerLoad, loadTime / efficiency)){`) follows the folded efficiency, with the battery unload (PayloadUnloader.java:98, `float total = payload.build.power.status * cap;`).
const SOURCE_PAYLOAD_UNLOADER_BUILD_IMPLEMENTATIONS := ["PayloadUnloader"]
const SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY := "source_payload_unloader_building"
# The load / unload constants (single def -- payload-unloader; the catalog
# carries no load params): `public float loadTime = 2f;` /
# `public int itemsLoaded = 8;` / `public float liquidsLoaded = 40f;`
# (PayloadLoader.java:22-24, inherited), `public int offloadSpeed = 4;` /
# `public float maxPowerUnload = 80f;` (PayloadUnloader.java:9-11),
# `itemCapacity = 100;` / `liquidCapacity = 100f;`
# (PayloadLoader.java:40-41, inherited), `size = 3;`
# (Blocks.java:6696), `public float payloadSpeed = 0.7f, payloadRotateSpeed = 5f;`
# (PayloadBlock.java:18). loadTime is the load timer cadence
# (live since N2320, source_payload_unloader_load_timer_state)
# and offloadSpeed is the dump loop (live since N2293,
# source_payload_unloader_dump_state); the rest drive the advance.
const SOURCE_PAYLOAD_UNLOADER_LOAD_TIME := 2.0
const SOURCE_PAYLOAD_UNLOADER_ITEMS_LOADED := 8
const SOURCE_PAYLOAD_UNLOADER_LIQUIDS_LOADED := 40.0
const SOURCE_PAYLOAD_UNLOADER_MAX_POWER_UNLOAD := 80.0
const SOURCE_PAYLOAD_UNLOADER_OFFLOAD_SPEED := 4
const SOURCE_PAYLOAD_UNLOADER_ITEM_CAPACITY := 100
const SOURCE_PAYLOAD_UNLOADER_LIQUID_CAPACITY := 100.0
const SOURCE_PAYLOAD_UNLOADER_SIZE := 3
const SOURCE_PAYLOAD_UNLOADER_PAYLOAD_SPEED := 0.7
const SOURCE_PAYLOAD_UNLOADER_PAYLOAD_ROTATE_SPEED := 5.0
# `public int maxBlockSize = 3;` (PayloadLoader.java:25, inherited) -- the
# acceptPayload fits bound (N2296): fits(maxBlockSize) is size() / tilesize
# <= 3 (Payload.java:50-52), i.e. block.size <= 3 for build payloads
# (BuildPayload.java:87, `return build.block.size * tilesize;`).
const SOURCE_PAYLOAD_UNLOADER_MAX_BLOCK_SIZE := 3

static func _is_payload_unloader_build_implementation(implementation: String) -> bool:
	return SOURCE_PAYLOAD_UNLOADER_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_payload_unloader_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The payload-unloader tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (PayloadUnloader.java:8, `public class PayloadUnloader extends PayloadLoader{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# payload-unloader skips consumption like Java's updateConsumption
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
	# for this payload-unloader (N2125); the tick preserves a disabled
	# payload-unloader instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	# The frame carries the held payload (the
	# PayloadBlockBuild.payload field, PayloadBlock.java:92,
	# `public @Nullable T payload;`, default null); the tick
	# preserves a payload already on the frame instead of
	# resetting it -- the live fill (N2279) sets it from the
	# frame incoming_payload input before the advance (the
	# moveInPayload / moveOutPayload advance is live since
	# N2232), so the shouldConsume gate reads the filled frame.
	if not frame.has("payload"):
		frame["payload"] = null
	# The frame carries the incoming payload push (the
	# handlePayload call, PayloadBlock.java:121-127): the
	# pusher (a front build moveOutPayload or a unit drop --
	# neither live in the port yet) supplies {"payload": the
	# payload dict, "source_offset": {"x", "y"}} and the tick
	# applies it before the advance when the N2296 verdict
	# accepts (N2313), then consumes it (an occupied frame
	# keeps it for retry); a frame bound before this slice
	# gets the null default.
	if not frame.has("incoming_payload"):
		frame["incoming_payload"] = null
	# The frame carries the offered payload (the acceptPayload
	# call, PayloadLoader.java:90-101): the pusher offers a
	# payload descriptor (the N2296 contract:
	# is_build_payload / size / block flags) and the tick
	# evaluates the gate against it; a frame bound before
	# this slice gets the null default (no offer).
	if not frame.has("offered_payload"):
		frame["offered_payload"] = null
	# The updateTile advance keys (N2232): a frame bound before
	# this slice gets the Java field defaults instead of
	# crashing the advance -- payVector (0, 0) / payRotation 0f
	# (PayloadBlock.java:94-95), rotation 0
	# (BuildingComp.java:69 `transient int rotation;`), the
	# Building.items ItemModule (frame["items"], Dictionary
	# keyed by item name, the factory precedent), and
	# lastOutputPower 0f (PayloadUnloader.java:33). Liquids
	# sync from the sprite meta each tick (the N2224 Fracker
	# precedent), not here -- this function has no sprite.
	if not frame.has("pay_vector"):
		frame["pay_vector"] = {"x": 0.0, "y": 0.0}
	if not frame.has("pay_rotation"):
		frame["pay_rotation"] = 0.0
	if not frame.has("rotation"):
		frame["rotation"] = 0
	if not frame.has("items"):
		frame["items"] = {}
	if not frame.has("last_output_power"):
		frame["last_output_power"] = 0.0
	# The dump rows (N2293): the dump cursor
	# (`transient int cdump;`, BuildingComp.java:68, default
	# 0) and the dump accumulator (`private transient float
	# dumpAccum;`, BuildingComp.java:99, default 0f) -- a
	# frame bound before this slice gets the Java field
	# defaults instead of crashing the dump.
	if not frame.has("cdump"):
		frame["cdump"] = 0
	if not frame.has("dump_accum"):
		frame["dump_accum"] = 0.0
	# The load timer clock (N2320): the frame-local
	# Interval-equivalent elapsed (frame["timer_load_elapsed"],
	# default 0.0 -- the Java Interval times[] init 0
	# (`times = new float[capacity];`, Interval.java:9)) -- a
	# frame bound before this slice gets the default instead
	# of crashing the timer.
	if not frame.has("timer_load_elapsed"):
		frame["timer_load_elapsed"] = 0.0
	return frame

static func _initial_frame() -> Dictionary:
	# A new PayloadUnloaderBuild starts with no payload (the
	# PayloadBlockBuild.payload field, PayloadBlock.java:92,
	# `public @Nullable T payload;`, default null): the
	# shouldConsume gate (PayloadLoader.java:240-242) reads
	# payload != null, so the frame carries the payload key
	# at its null default. The live fill (N2279) carries the
	# incoming push under the incoming_payload key (default
	# null): the tick applies it before the advance when the
	# frame payload is null and the N2296 verdict accepts
	# (N2313), then consumes it (a rejected push is dropped;
	# an occupied frame keeps it for retry). The updateTile
	# advance (N2232)
	# carries the rest of the build fields with their Java
	# defaults: `public Vec2 payVector = new Vec2();`
	# (PayloadBlock.java:94), `public float payRotation;`
	# (PayloadBlock.java:95, default 0f), `transient int
	# rotation;` (BuildingComp.java:69, default 0), the
	# Building.items ItemModule (frame["items"], Dictionary
	# keyed by item name, default {}), and `public float
	# lastOutputPower = 0f;` (PayloadUnloader.java:33).
	# The acceptPayload gate (N2296) reads the offered
	# payload from the offered_payload key (default null --
	# no offer).
	# The dump rows (N2293) carry the dump cursor
	# (`transient int cdump;`, BuildingComp.java:68, default
	# 0) and the dump accumulator (`private transient float
	# dumpAccum;`, BuildingComp.java:99, default 0f).
	# The load timer clock (N2320) starts at 0.0 (the Java
	# Interval times[] init 0, `times = new float[capacity];`,
	# Interval.java:9).
	# Liquids sync from the sprite meta each tick (the N2224
	# Fracker precedent), not from _initial_frame.
	return {"payload": null, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 0.0, "rotation": 0, "items": {}, "last_output_power": 0.0, "incoming_payload": null, "cdump": 0, "dump_accum": 0.0, "offered_payload": null, "timer_load_elapsed": 0.0}

static func source_payload_unloader_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the payload-unloader frame meta key
	# ("source_payload_unloader_building"). A PayloadUnloader sprite gets a
	# frame bound with the payload key at its null default
	# (frame["payload"] = null, the PayloadBlockBuild.payload
	# field, PayloadBlock.java:92); the live-loop tick fills its
	# other keys every tick. Any other block, or an
	# already-bound sprite, binds nothing.
	if block == null or not _is_payload_unloader_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func _payload_unloader_liquid_current(module_state: Dictionary) -> Variant:
	# `public Liquid current(){` (LiquidModule.java:81-83) with
	# `return current;`: the last received or loaded liquid id,
	# null for a module that never held one (a frame bound
	# before this slice carries no liquids store at all).
	if module_state.is_empty():
		return null
	return module_state.get("current", null)

static func _payload_unloader_liquid_current_amount(module_state: Dictionary) -> float:
	# `public float currentAmount(){` (LiquidModule.java:98-100)
	# with `return liquids[current.id];`: 0.0 when the module
	# has no current liquid or the amounts array does not cover
	# it (a partial fixture).
	var current: Variant = _payload_unloader_liquid_current(module_state)
	if current == null:
		return 0.0
	var amounts: Array = module_state.get("liquids", [])
	var index: int = int(current)
	if index < 0 or index >= amounts.size():
		return 0.0
	return float(amounts[index])

static func _payload_unloader_liquid_add(module_state: Dictionary, liquid_id: int, amount: float) -> Dictionary:
	# LiquidModule.add (LiquidModule.java:110-117):
	# `liquids[liquid.id] += amount;` + `current = liquid;`.
	# Grows the amounts array to cover the id (a partial
	# fixture) and sets current to the added liquid. Mutates
	# the passed dict -- callers pass a duplicate.
	var amounts: Array = (module_state.get("liquids", []) as Array).duplicate()
	while amounts.size() <= liquid_id:
		amounts.append(0.0)
	amounts[liquid_id] = float(amounts[liquid_id]) + amount
	module_state["liquids"] = amounts
	module_state["current"] = liquid_id
	return module_state

static func _payload_unloader_liquid_remove(module_state: Dictionary, liquid_id: int, amount: float) -> Dictionary:
	# LiquidModule.remove (LiquidModule.java:125-128): add with
	# max(-amount, -liquids[liquid.id]) -- capped to prevent
	# negative removal.
	var amounts: Array = module_state.get("liquids", [])
	var held: float = 0.0
	if liquid_id >= 0 and liquid_id < amounts.size():
		held = float(amounts[liquid_id])
	return _payload_unloader_liquid_add(module_state, liquid_id, maxf(-amount, -held))

static func source_payload_unloader_load_timer_state(elapsed: float, source_delta: float, time_scale: float, efficiency: float, load_time: float) -> Dictionary:
	# The frame-local Interval-equivalent for the load timer
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
	# Time.time counts TICKS (arc Time.java:69-80):
	# `timeRaw += delta;`
	# The port has no global tick clock at the driver layer, so
	# the elapsed clock is frame-local (frame["timer_load_
	# elapsed"], accumulated by the tick delta every tick the
	# advance runs, unconditionally -- mirroring Time.time,
	# which grows even while the gate is closed): elapsed +=
	# source_delta unconditionally (source_delta is the
	# UNSCALED Time.delta in ticks -- game_source_delta is
	# seconds * 60, never scaled by timeScale -- so the
	# frame clock mirrors the global Time.time exactly);
	# load_tick = (efficiency > 0.01) and (elapsed >=
	# load_time / efficiency); elapsed_after RESETS to 0.0
	# ONLY when load_tick is true (a reset, not a subtraction
	# like the Fracker accumulator); a non-positive time_scale
	# is a defensive guard (threshold INF, never fires -- see
	# below). The Java call is (PayloadUnloader.java:69):
	# `if(efficiency > 0.01f && timer(timerLoad, loadTime / efficiency)){`
	# with `public final int timerLoad = timers++;`
	# (PayloadLoader.java:20, inherited) and
	# `public float loadTime = 2f;`
	# (PayloadLoader.java:22, inherited) on
	# `public class PayloadUnloader extends PayloadLoader{`
	# (PayloadUnloader.java:8) and
	# `public class PayloadUnloaderBuild extends PayloadLoaderBuild{`
	# (PayloadUnloader.java:32). The threshold divides by
	# EFFICIENCY, not timeScale -- Java passes loadTime /
	# efficiency to timer() and nothing else (the N2290
	# lesson: never invent a / time_scale). The efficiency
	# gate is the Java short-circuit: efficiency <= 0.01
	# means Java never calls timer() (PayloadUnloader.
	# java:69), so no reset happens -- but Time.time keeps
	# growing, so the frame clock accumulates unconditionally
	# and a recovered efficiency fires at once (elapsed
	# already past the threshold). The gate `efficiency >
	# 0.01 and load_tick` already lives in the N2232 advance
	# pure -- this pure only computes load_tick, it does not
	# duplicate the gate. Efficiency <= 0 is the TimerComp
	# infinite rule (threshold +inf, no fire) and the
	# divide-by-zero guard. time_scale stays a parameter
	# (signature stability -- the contract, call sites, and
	# tests keep it) and is still read: a non-positive
	# time_scale never fires, a defensive port guard for a
	# corrupt frame input -- Java timeScale is always
	# positive in practice (the default, BuildingComp.
	# java:98, is
	# `private transient float timeScale = 1f, timeScaleDuration;`
	# applyBoost / applySlowdown take positive intensities,
	# BuildingComp.java:461-478; decay resets it to 1f,
	# BuildingComp.java:2265-2266), so the guard is
	# unreachable in Java-exact play and the threshold is
	# Java-exact at every reachable time_scale. Note the
	# clock still ACCUMULATES at time_scale 0 (source_delta
	# is unscaled) -- only the fire is guarded. The Unloader
	# has NO dynamic power consumer
	# (`loadPowerDynamic = false;`, PayloadUnloader.java:18),
	# so the folded efficiency this timer reads is the
	# power-only fold, exact. Documented deviation (first
	# fire): Java fires (nearly) immediately after placement
	# (the global Time.time is already large vs a fresh
	# Interval times[id] = 0); the frame-local clock delays
	# the first fire by a full interval (loadTime /
	# efficiency ticks). It cannot be fixed without a global
	# clock -- it waits for a timer-infra slice if exact
	# first-fire timing is ever needed.
	var threshold: float = INF if time_scale <= 0.0 or efficiency <= 0.0 else load_time / efficiency
	var accumulated: float = elapsed + source_delta
	var load_tick: bool = efficiency > 0.01 and accumulated >= threshold
	var timer_elapsed_after: float = 0.0 if load_tick else accumulated
	return {"load_tick": load_tick, "timer_elapsed_after": timer_elapsed_after}

static func source_payload_unloader_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float, load_tick: bool, item_order: Array, front: Dictionary) -> Dictionary:
	# The updateTile advance (PayloadUnloaderBuild.updateTile(),
	# PayloadUnloader.java:50-110), the pure frame advance -- the
	# build fields are `public float lastOutputPower = 0f;`
	# (PayloadUnloader.java:33), `public @Nullable T payload;`
	# (PayloadBlock.java:92), `public Vec2 payVector = new Vec2();`
	# (PayloadBlock.java:94) and `public float payRotation;`
	# (PayloadBlock.java:95), and the advance follows the Java
	# lines in order (each exact expr on ONE comment line, the
	# N2148 lesson):
	# `if(payload != null){`
	# `payload.update(null, this);`
	# `lastOutputPower = 0f;`
	# `if(shouldExport()){`
	# `payload.block().breakEffect.at(this, payload.block().size);`
	# `payload = null;`
	# `moveOutPayload();`
	# `}else if(moveInPayload()){`
	# `if(payload.block().hasItems && !full()){`
	# `if(efficiency > 0.01f && timer(timerLoad, loadTime / efficiency)){`
	# `for(int j = 0; j < itemsLoaded && !full(); j++){`
	# `for(int i = 0; i < items.length(); i++){`
	# `if(payload.build.items.get(i) > 0){`
	# `Item item = content.item(i);`
	# `payload.build.items.remove(item, 1);`
	# `items.add(item, 1);`
	# `if(payload.block().hasLiquids && payload.build.liquids.currentAmount() >= 0.01f &&`
	# `(liquids.current() == payload.build.liquids.current() || liquids.currentAmount() <= 0.2f)){`
	# `var liq = payload.build.liquids.current();`
	# `float remaining = liquidCapacity - liquids.currentAmount();`
	# `float flow = Math.min(Math.min(liquidsLoaded * edelta(), remaining), payload.build.liquids.currentAmount());`
	# `liquids.add(liq, flow);`
	# `payload.build.liquids.remove(liq, flow);`
	# `if(hasBattery()){`
	# `float cap = payload.block().consPower.capacity;`
	# `float total = payload.build.power.status * cap;`
	# `float unloaded = Math.min(maxPowerUnload * edelta(), total);`
	# `lastOutputPower = unloaded;`
	# `payload.build.power.status -= unloaded / cap;`
	# `dumpLiquid(liquids.current());`
	# `for(int i = 0; i < offloadSpeed; i++){`
	# `dumpAccumulate();`
	# `return items.total() >= itemCapacity;`
	# `return payload != null && (`
	# `(!payload.block().hasItems || payload.build.items.empty()) &&`
	# `(!payload.block().hasLiquids || payload.build.liquids.currentAmount() <= 0.011f) &&`
	# `(!hasBattery() || payload.build.power.status <= 0.0000001f)`
	# `public float getPowerProduction(){`
	# `return lastOutputPower;`
	# `public int offloadSpeed = 4;`
	# `public float maxPowerUnload = 80f;`
	# `public class PayloadUnloader extends PayloadLoader{`
	# `public class PayloadUnloaderBuild extends PayloadLoaderBuild{`
	# `public final int timerLoad = timers++;`
	# `public float loadTime = 2f;`
	# `public int itemsLoaded = 8;`
	# `public float liquidsLoaded = 40f;`
	# `public boolean hasBattery(){`
	# `return payload != null && payload.block().consPower != null && payload.block().consPower.buffered;`
	# `itemCapacity = 100;`
	# `liquidCapacity = 100f;`
	# `public float payloadSpeed = 0.7f, payloadRotateSpeed = 5f;`
	# `if(payload == null) return false;`
	# `payRotation = Angles.moveToward(payRotation, block.rotate ? rotdeg() : 90f, payloadRotateSpeed * delta());`
	# `payVector.approach(Vec2.ZERO, payloadSpeed * delta());`
	# `return hasArrived();`
	# `return payVector.isZero(0.01f);`
	# `Vec2 dest = Tmp.v1.trns(rotdeg(), size * tilesize/2f);`
	# `payRotation = Angles.moveToward(payRotation, rotdeg(), payloadRotateSpeed * delta());`
	# `payVector.approach(dest, payloadSpeed * delta());`
	# `boolean canDump = front == null || !front.tile.solid();`
	# `boolean canMove = front != null && (front.block.outputsPayload || front.block.acceptsPayload);`
	# `if(payVector.within(dest, 0.001f)){`
	# `if(movePayload(payload)){`
	# `dumpPayload();`
	# `return Time.delta * timeScale;`
	# `return efficiency * delta();`
	# `return rotation * 90;`
	# `updateConsumption();`
	# `if(enabled || !block.noUpdateDisabled){`
	# `consumePower(2f);`
	# `public Liquid current(){`
	# `public float currentAmount(){`
	# `return liquids[current.id];`
	# `liquids[liquid.id] += amount;`
	# `current = liquid;`
	# `public boolean empty(){`
	# `return total == 0;`
	# `public static final int tilesize = 8;`
	# `return len2() < margin;`
	# delta() is `return Time.delta * timeScale;`
	# (BuildingComp.java:1922-1924) and edelta() is `return
	# efficiency * delta();` (BuildingComp.java:1927-1929);
	# moveIn/moveOut use delta(), the liquid flow and the
	# battery unload use edelta(). source_delta is Time.delta
	# in ticks (seconds * 60 through game_source_delta, arc
	# Time.java:26), never raw seconds. rotdeg() is `return
	# rotation * 90;` (BuildingComp.java:582-584) from the
	# frame rotation (BuildingComp.java:69 `transient int
	# rotation;`, default 0). hasArrived is the Arc quirk
	# `return payVector.isZero(0.01f);`
	# (PayloadBlock.java:243) with isZero(margin) = len2() <
	# margin (Vec2.java:679-681) -- NOT margin squared.
	# Payload dict contract (this slice; unify is a later
	# slice): payload = {"block": {"has_items": bool,
	# "has_liquids": bool, "instant_deconstruct": bool,
	# "cons_power_capacity": float or null (null = no
	# consPower), "cons_power_buffered": bool}, "build":
	# {"items": {name: int}, "liquids": the
	# SourceLiquidModuleState shape (amounts array by liquid
	# id + current id + flow null), "power_status": float}}.
	# Own frame items are {name: int} (the factory
	# precedent); own frame liquids use the same module
	# shape, synced from the sprite meta each tick (the N2224
	# Fracker precedent). Scoping decisions, all
	# source-backed: (1) payload.update (PayloadUnloader.
	# java:51-53) and updatePayload (PayloadBlock.java:
	# 174-179) are no-ops -- no live payload entity in the
	# port. (2) The timer cadence is live since N2320
	# (source_payload_unloader_load_timer_state, the
	# frame-local Interval-equivalent, 2f/efficiency): the
	# pure advance takes load_tick and the driver passes the
	# computed tick; the efficiency > 0.01f guard IS modeled
	# here AND in the timer pure (the Java short-circuit).
	# (3) moveIn is ported here (PayloadBlock.java:
	# 186-197); block.rotate is true for PayloadLoader
	# (PayloadLoader.java:45), so the rotation target is
	# rotdeg(). (4) moveOut REUSES the ported helper
	# SourceBlockProducerMoveOutPayloadState
	# .move_out_payload_state through a preload (the N2224
	# precedent): its signature already covers the whole
	# PayloadBlock.java:199-226 body, including the 0.001f
	# arrival epsilon and the pushOutput fraction; the
	# movePayload/dumpPayload APPLICATION defers, so the
	# advance reports payload_moved / payload_dumped and
	# only clears the payload when the helper reports the
	# move succeeded. (5) The item scan runs over item_order
	# -- the catalog item_names_by_id, the content-id order
	# Java iterates (the N2225 precedent); an item name
	# outside the order is never unloaded. (6) The dump is
	# live since N2293 as its own pure
	# (source_payload_unloader_dump_state), wired in the tick
	# AFTER this advance -- Java order
	# (PayloadUnloader.java:105-108 after the moveInPayload
	# branch :57-103); the advance itself still does not
	# dump. (7)
	# lastOutputPower is POWER PRODUCTION
	# (getPowerProduction returns it, PayloadUnloader.java:
	# 44-47): the frame carries it, but the power graph
	# builds producers from the static block property
	# powerProduction, so the graph wiring waits for its own
	# distribution-runtime slice. The function does NOT
	# mutate its input frame: the payload, items, and
	# liquids are duplicated before unloading.
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var delta: float = source_delta * time_scale
	var edelta: float = efficiency * delta
	var payload_in: Variant = frame.get("payload", null)
	var payload: Variant = null
	if payload_in != null:
		payload = (payload_in as Dictionary).duplicate(true)
	var items: Dictionary = (frame.get("items", {}) as Dictionary).duplicate(true)
	var liquids: Dictionary = (frame.get("liquids", {}) as Dictionary).duplicate(true)
	var pay_vector_in: Dictionary = frame.get("pay_vector", {})
	var pay_vector: Dictionary = {"x": float(pay_vector_in.get("x", 0.0)), "y": float(pay_vector_in.get("y", 0.0))}
	var pay_rotation: float = float(frame.get("pay_rotation", 0.0))
	var rotation: int = int(frame.get("rotation", 0))
	var rotdeg: float = float(rotation) * 90.0
	var last_output_power: float = 0.0
	var moved_in: bool = false
	var payload_moved: bool = false
	var payload_dumped: bool = false
	var deconstructed: bool = false
	var items_unloaded: int = 0
	var liquids_unloaded: float = 0.0
	var should_export: bool = false
	if payload != null:
		var payload_block: Dictionary = (payload as Dictionary).get("block", {})
		var payload_build: Dictionary = (payload as Dictionary).get("build", {})
		var payload_items: Dictionary = payload_build.get("items", {})
		var payload_liquids: Dictionary = payload_build.get("liquids", {})
		var has_battery: bool = payload_block.get("cons_power_capacity", null) != null and bool(payload_block.get("cons_power_buffered", false))
		var payload_power_status: float = float(payload_build.get("power_status", 0.0))
		should_export = (not bool(payload_block.get("has_items", false)) or inventory.items_total(payload_items) == 0) and (not bool(payload_block.get("has_liquids", false)) or _payload_unloader_liquid_current_amount(payload_liquids) <= 0.011) and (not has_battery or payload_power_status <= 0.0000001)
	if should_export:
		var export_block: Dictionary = (payload as Dictionary).get("block", {})
		if bool(export_block.get("instant_deconstruct", false)):
			deconstructed = true
			payload = null
		else:
			var moved_out: Dictionary = source_move_out_payload_state.move_out_payload_state(true, float(pay_vector.get("x", 0.0)), float(pay_vector.get("y", 0.0)), pay_rotation, rotdeg, float(SOURCE_PAYLOAD_UNLOADER_SIZE), source_world_defaults.TILESIZE, SOURCE_PAYLOAD_UNLOADER_PAYLOAD_ROTATE_SPEED, SOURCE_PAYLOAD_UNLOADER_PAYLOAD_SPEED, delta, bool(front.get("present", false)), bool(front.get("solid", false)), bool(front.get("outputs_payload", false)), bool(front.get("accepts_payload", false)), bool(front.get("move_payload_result", false)))
			pay_vector = moved_out.get("pay_vector_after", pay_vector)
			pay_rotation = float(moved_out.get("pay_rotation_after", pay_rotation))
			payload_moved = bool(moved_out.get("move_payload_called", false)) and bool(front.get("move_payload_result", false))
			payload_dumped = bool(moved_out.get("dump_payload_called", false))
			if not bool(moved_out.get("payload_after_present", true)):
				payload = null
	elif payload != null:
		pay_rotation = source_math_state.source_angles_move_toward(pay_rotation, rotdeg, SOURCE_PAYLOAD_UNLOADER_PAYLOAD_ROTATE_SPEED * delta)
		pay_vector = source_move_out_payload_state.source_vec2_approach(float(pay_vector.get("x", 0.0)), float(pay_vector.get("y", 0.0)), 0.0, 0.0, SOURCE_PAYLOAD_UNLOADER_PAYLOAD_SPEED * delta)
		var pay_x: float = float(pay_vector.get("x", 0.0))
		var pay_y: float = float(pay_vector.get("y", 0.0))
		moved_in = pay_x * pay_x + pay_y * pay_y < 0.01
		if moved_in:
			var unload_block: Dictionary = (payload as Dictionary).get("block", {})
			var unload_build: Dictionary = (payload as Dictionary).get("build", {})
			if bool(unload_block.get("has_items", false)) and inventory.items_total(items) < SOURCE_PAYLOAD_UNLOADER_ITEM_CAPACITY:
				if efficiency > 0.01 and load_tick:
					var held_items: Dictionary = (unload_build.get("items", {}) as Dictionary).duplicate(true)
					for _j in range(SOURCE_PAYLOAD_UNLOADER_ITEMS_LOADED):
						if inventory.items_total(items) >= SOURCE_PAYLOAD_UNLOADER_ITEM_CAPACITY:
							break
						for item_name in item_order:
							var candidate: String = str(item_name)
							if inventory.item_count(held_items, candidate) > 0:
								var removed: Dictionary = inventory.remove_item_state(held_items, candidate, 1)
								held_items = removed.get(inventory.SOURCE_DRILL_INVENTORY_DRILL_ITEMS_KEY, held_items)
								var added: Dictionary = inventory.add_item_state(items, candidate, 1)
								items = added.get(inventory.SOURCE_DRILL_INVENTORY_DRILL_ITEMS_KEY, items)
								items_unloaded += 1
								break
					unload_build["items"] = held_items
			if bool(unload_block.get("has_liquids", false)):
				var held_liquids: Dictionary = (unload_build.get("liquids", {}) as Dictionary).duplicate(true)
				var payload_current: Variant = _payload_unloader_liquid_current(held_liquids)
				var payload_current_amount: float = _payload_unloader_liquid_current_amount(held_liquids)
				if payload_current != null and payload_current_amount >= 0.01:
					var own_current: Variant = _payload_unloader_liquid_current(liquids)
					var own_current_amount: float = _payload_unloader_liquid_current_amount(liquids)
					if own_current == payload_current or own_current_amount <= 0.2:
						var remaining: float = SOURCE_PAYLOAD_UNLOADER_LIQUID_CAPACITY - own_current_amount
						var flow: float = minf(minf(SOURCE_PAYLOAD_UNLOADER_LIQUIDS_LOADED * edelta, remaining), payload_current_amount)
						liquids = _payload_unloader_liquid_add(liquids, int(payload_current), flow)
						held_liquids = _payload_unloader_liquid_remove(held_liquids, int(payload_current), flow)
						unload_build["liquids"] = held_liquids
						liquids_unloaded = flow
			var unload_has_battery: bool = unload_block.get("cons_power_capacity", null) != null and bool(unload_block.get("cons_power_buffered", false))
			if unload_has_battery:
				var cap: float = float(unload_block.get("cons_power_capacity", 0.0))
				var status: float = float(unload_build.get("power_status", 0.0))
				var total: float = status * cap
				var unloaded: float = minf(SOURCE_PAYLOAD_UNLOADER_MAX_POWER_UNLOAD * edelta, total)
				last_output_power = unloaded
				unload_build["power_status"] = status - unloaded / cap
	return {"payload": payload, "pay_vector": pay_vector, "pay_rotation": pay_rotation, "items": items, "liquids": liquids, "last_output_power": last_output_power, "should_export": should_export, "moved_in": moved_in, "payload_moved": payload_moved, "payload_dumped": payload_dumped, "deconstructed": deconstructed, "items_unloaded": items_unloaded, "liquids_unloaded": liquids_unloaded}

static func source_payload_unloader_handle_payload_state(frame: Dictionary, incoming_payload: Variant) -> Dictionary:
	# The handlePayload intake (PayloadBlockBuild.handlePayload,
	# PayloadBlock.java:121-127), the pure fill -- the Unloader
	# does NOT override handlePayload (grep finds no
	# handlePayload and no exporting flag in
	# PayloadUnloader.java at all; the exporting flag lives
	# only on the Loader, PayloadLoader.java:87, cleared in
	# the Loader override, PayloadLoader.java:104-107), so
	# this is the base method verbatim (each exact expr on
	# ONE comment line, the N2148 lesson):
	# `public void handlePayload(Building source, Payload payload){`
	# `this.payload = (T)payload;`
	# `this.payVector.set(source).sub(this).clamp(-size * tilesize / 2f, -size * tilesize / 2f, size * tilesize / 2f, size * tilesize / 2f);`
	# `this.payRotation = payload.rotation();`
	# `updatePayload();`
	# `public @Nullable T payload;`
	# `public Vec2 payVector = new Vec2();`
	# `public float payRotation;`
	# `public boolean acceptPayload(Building source, Payload payload){`
	# `return this.payload == null;`
	# `public void updatePayload(){`
	# `payload.set(x + payVector.x, y + payVector.y, payRotation);`
	# `default float rotation(){`
	# `return 0f;`
	# `public float rotation(){`
	# `return unit.rotation;`
	# `public Vec2 clamp(float minx, float miny, float maxx, float maxy){`
	# `x = Mathf.clamp(x, minx, maxx);`
	# `y = Mathf.clamp(y, miny, maxy);`
	# `public static final int tilesize = 8;`
	# `size = 3;`
	# `public class PayloadUnloader extends PayloadLoader{`
	# `loadPowerDynamic = false;`
	# `public boolean exporting = false;`
	# `super.handlePayload(source, payload);`
	# `exporting = false;`
	# incoming_payload is the frame input {"payload": the
	# payload dict (the N2232 contract: block flags + build
	# items / liquids module state / power_status, plus a
	# "rotation" key), "source_offset": {"x", "y"}}. The
	# source_offset is the source world position minus this
	# building's world position -- the set(source).sub(this)
	# result: the port has no live building world positions,
	# so the pusher supplies the relative offset and the pure
	# ports the clamp exactly. The clamp is the 4-arg
	# Vec2.clamp (Vec2.java:318-322), component-wise, NOT the
	# length clamp: half is size * tilesize / 2 = 3 * 8 / 2 =
	# 12.0 for the payload-unloader def (Blocks.java:6696).
	# payRotation reads the payload "rotation" with a 0.0
	# default: Payload.rotation() defaults to 0f
	# (Payload.java:55-57), BuildPayload does not override it,
	# and UnitPayload returns unit.rotation
	# (UnitPayload.java:94-96). The intake applies only when
	# the frame payload is null -- the acceptPayload gate
	# (PayloadBlock.java:116-118); a null / malformed
	# incoming, or a frame that already holds a payload,
	# returns the frame values unchanged. updatePayload() is
	# NOT ported: it only positions the live payload entity
	# (payload.set(x + payVector.x, ...)), and the port has
	# no live payload entity (covered by the payload entity
	# update DEFERRED entry). The result carries no exporting
	# key -- the Unloader has no exporting flag. The function
	# does NOT mutate its input frame.
	var payload: Variant = frame.get("payload", null)
	var pay_vector_in: Dictionary = frame.get("pay_vector", {})
	var pay_vector: Dictionary = {"x": float(pay_vector_in.get("x", 0.0)), "y": float(pay_vector_in.get("y", 0.0))}
	var pay_rotation: float = float(frame.get("pay_rotation", 0.0))
	if incoming_payload == null or payload != null or not (incoming_payload is Dictionary):
		return {"payload": payload, "pay_vector": pay_vector, "pay_rotation": pay_rotation}
	var incoming: Dictionary = incoming_payload as Dictionary
	var incoming_dict: Variant = incoming.get("payload", null)
	if incoming_dict == null or not (incoming_dict is Dictionary):
		return {"payload": payload, "pay_vector": pay_vector, "pay_rotation": pay_rotation}
	var offset_raw: Variant = incoming.get("source_offset", null)
	var offset: Dictionary = {}
	if offset_raw is Dictionary:
		offset = offset_raw as Dictionary
	var half: float = float(SOURCE_PAYLOAD_UNLOADER_SIZE) * source_world_defaults.TILESIZE / 2.0
	payload = incoming_dict
	pay_vector = {"x": clampf(float(offset.get("x", 0.0)), -half, half), "y": clampf(float(offset.get("y", 0.0)), -half, half)}
	pay_rotation = float((incoming_dict as Dictionary).get("rotation", 0.0))
	return {"payload": payload, "pay_vector": pay_vector, "pay_rotation": pay_rotation}

static func source_payload_unloader_take_payload_state(frame_payload: Variant) -> Dictionary:
	# The takePayload clear (PayloadBlockBuild.takePayload,
	# PayloadBlock.java:145-149), the pure take (each exact
	# expr on ONE comment line, the N2148 lesson):
	# `public Payload takePayload(){`
	# `T t = payload;`
	# `payload = null;`
	# `return t;`
	# `public @Nullable T payload;`
	# The pure is NOT wired live: the unit-pickup path waits
	# for live units, and the move-out clear is already live
	# through the N2232 advance -- the driver must not clear
	# twice. The take returns the held payload and reports
	# the cleared (null) payload after.
	return {"payload_taken": frame_payload, "payload_after": null}

static func source_payload_unloader_dump_state(frame: Dictionary, source_delta: float, time_scale: float, item_order: Array, neighbour_liquid_amounts: Array, neighbour_liquid_capacities: Array, neighbour_accepts_liquid: Array, neighbour_can_dump_liquid: Array, neighbour_accepts_item: Array, neighbour_can_dump_item: Array) -> Dictionary:
	# The dump rows at the END of updateTile
	# (PayloadUnloaderBuild.updateTile(),
	# PayloadUnloader.java:105-108), UNCONDITIONAL -- outside
	# the payload-null check (:52-54) and outside the
	# shouldExport / moveInPayload if-else (:57-103), so they
	# run even when the unloader holds no payload and even
	# when efficiency is 0 (the brief cited :104-110; the
	# dump statements are :105-108, :104 is blank and :109
	# closes the method -- verified by grep). ONE pure covers
	# both rows (each exact expr on ONE comment line, the
	# N2148 lesson):
	# `dumpLiquid(liquids.current());`
	# `for(int i = 0; i < offloadSpeed; i++){`
	# `dumpAccumulate();`
	# `public int offloadSpeed = 4;`
	# `public class PayloadUnloader extends PayloadLoader{`
	# `hasItems = true;` (PayloadLoader.java:37, inherited -- the dump(null) hasItems guard always passes).
	# `itemCapacity = 100;` (PayloadLoader.java:40, inherited).
	# `liquidCapacity = 100f;` (PayloadLoader.java:41, inherited -- the dump fraction denominator).
	# `public Liquid current(){` (LiquidModule.java:81).
	# `return current;` (LiquidModule.java:82).
	# `private Liquid current = content.liquid(0);` (LiquidModule.java:24 -- current is NEVER null in Java; it defaults to liquid 0, so a real store always dumps its current and the <= 0.0001f early return covers the empty store. The pure's null-current guard is only for partial fixtures: a frame bound before this slice carries no liquids store at all).
	# dumpLiquid(Liquid) is the 2f overload
	# (`public void dumpLiquid(Liquid liquid){`, BuildingComp.java:877, with `dumpLiquid(liquid, 2f);`, BuildingComp.java:878), which delegates to the scaling overload (`public void dumpLiquid(Liquid liquid, float scaling){`, BuildingComp.java:881, with `dumpLiquid(liquid, scaling, -1);`, BuildingComp.java:882) and then the output-dir impl (`public void dumpLiquid(Liquid liquid, float scaling, int outputDir){`, BuildingComp.java:886-908):
	# `int dump = this.cdump;` (BuildingComp.java:887).
	# `if(liquids.get(liquid) <= 0.0001f) return;` (BuildingComp.java:889 -- the early return runs BEFORE the loop, so an empty store leaves cdump untouched).
	# `if(!net.client() && state.isCampaign() && team == state.rules.defaultTeam) liquid.unlock();` (BuildingComp.java:891 -- the campaign unlock guard runs inside the shared helper with the scenario-pump defaults (not a client, campaign, default team), but the pure result carries no unlock key -- surfacing + applying it waits for its own slice).
	# `for(int i = 0; i < proximity.size; i++){` (BuildingComp.java:893).
	# `incrementDump(proximity.size);` (BuildingComp.java:894 -- EVERY iteration, before the output-dir filter, so the cursor advances even when no neighbour takes anything; a full scan over N neighbours advances it N times -- a full circle, the N2286 cursor invariant, Java-exact: the cursor only moves in the item phase).
	# `Building other = proximity.get((i + dump) % proximity.size);` (BuildingComp.java:896).
	# `if(outputDir != -1 && (outputDir + rotation) % 4 != relativeTo(other)) continue;` (BuildingComp.java:897 -- outputDir is -1 here, so the filter never skips).
	# `other = other.getLiquidDestination(self(), liquid);` (BuildingComp.java:899 -- the default returns self, `public Building getLiquidDestination(Building from, Liquid liquid){` with `return self();`, BuildingComp.java:980-982, so every listed neighbour is its own destination).
	# `if(other != null && other.block.hasLiquids && canDumpLiquid(other, liquid) && other.liquids != null){` (BuildingComp.java:901).
	# `float ofract = other.liquids.get(liquid) / other.block.liquidCapacity;` (BuildingComp.java:902).
	# `float fract = liquids.get(liquid) / block.liquidCapacity;` (BuildingComp.java:903 -- recomputed per neighbour from the RUNNING amount, after earlier transfers).
	# `if(ofract < fract) transferLiquid(other, (fract - ofract) * block.liquidCapacity / scaling, liquid);` (BuildingComp.java:905 -- scaling 2f, so the transfer is HALF the fraction gap times the capacity; the guard is STRICT: an equal neighbour takes nothing).
	# canDumpLiquid defaults to true
	# (`public boolean canDumpLiquid(Building to, Liquid liquid){` with `return true;`, BuildingComp.java:910-912).
	# transferLiquid (`public void transferLiquid(Building next, float amount, Liquid liquid){`, BuildingComp.java:914-921):
	# `float flow = Math.min(next.block.liquidCapacity - next.liquids.get(liquid), amount);` (BuildingComp.java:915).
	# `if(next.acceptLiquid(self(), liquid)){` (BuildingComp.java:917).
	# `next.handleLiquid(self(), liquid, flow);` (BuildingComp.java:918 -- the liquid neighbour write-back is live since N2380: the advance exposes dump_neighbour_index + dumped_liquid_name and the tick lands the dumped liquid in the handled neighbour frame through the shared N2371 helper).
	# `liquids.remove(liquid, flow);` (BuildingComp.java:919).
	# dumpAccumulate() delegates to dumpAccumulate(null)
	# (`public boolean dumpAccumulate(){` with `return dumpAccumulate(null);`, BuildingComp.java:1048-1050):
	# `public boolean dumpAccumulate(Item item){` (BuildingComp.java:1053-1061).
	# `dumpAccum += delta();` (BuildingComp.java:1055 -- delta() is `return Time.delta * timeScale;`, BuildingComp.java:1922-1924).
	# `while(dumpAccum >= 1f){` (BuildingComp.java:1056 -- the loop may fire dump() MULTIPLE times per call).
	# `res |= dump(item);` (BuildingComp.java:1057 -- the dump is attempted even when an earlier attempt failed).
	# `dumpAccum -=1f;` (BuildingComp.java:1058).
	# dump(null) (`public boolean dump(Item todump){`, BuildingComp.java:1072-1114):
	# `if(!block.hasItems || items.total() == 0 || proximity.size == 0 || (todump != null && !items.has(todump))) return false;` (BuildingComp.java:1073).
	# `var allItems = content.items();` (BuildingComp.java:1076 -- the content-id order, passed in as item_order).
	# `if(other.acceptItem(self(), item) && canDump(other, item)){` (BuildingComp.java:1088 -- neighbours outer, content items inner: for each neighbour from the cdump cursor, the first held item in content order an accepting neighbour takes is handed over).
	# `other.handleItem(self(), item);` (BuildingComp.java:1089 -- the neighbour write-back waits for its own slice, as with the liquid).
	# `items.remove(item, 1);` (BuildingComp.java:1090).
	# incrementDump (`public void incrementDump(int prox){`, BuildingComp.java:1116-1121):
	# `if(prox != 0){` (BuildingComp.java:1118).
	# `cdump = ((cdump + 1) % prox);` (BuildingComp.java:1119).
	# The dump cursor is `transient int cdump;`
	# (BuildingComp.java:68, default 0) and the accumulator
	# `private transient float dumpAccum;`
	# (BuildingComp.java:99, default 0f), both carried on the
	# frame. canDump defaults to true
	# (`public boolean canDump(Building to, Item item){`, BuildingComp.java:1124-1126).
	# The dump itself runs through the shared ports -- the
	# liquid through SourceBuildingLiquidState.
	# dump_liquid_state (which binds transfer_liquid_state,
	# the N2286 precedent) with the shared
	# increment_dump_cursor_state callback, and the item
	# through the shared dump_accumulate_state (the static
	# the bridge source_dump_accumulate_attempt_state
	# delegates to -- the bridge method is an instance
	# method, so the static pure calls the static it wraps)
	# plus the shared dump_item_state routing (the N2281
	# precedent) -- never a hand-rolled routing loop. The
	# loop calls dumpAccumulate() offloadSpeed (4) times per
	# tick, so dumpAccum grows by 4*delta each tick. The
	# neighbour arrays are parallel, in proximity order (the
	# N2286 / N2281 precedent, default [] -- no neighbours,
	# the Java proximity.size == 0 outcome); they list only
	# neighbours with a liquids module for the liquid arrays
	# (the scenario-pump filter), so destination-present and
	# liquids-present are true for every listed neighbour and
	# hasLiquids follows from a positive capacity. The pure
	# does NOT mutate its input frame: the liquids store and
	# the items dict are duplicated before dumping (the N2232
	# precedent), and the liquid removal runs only when the
	# dumped amount is non-zero, so the helper's add never
	# flips the store's "current" key on a no-op (the N2284
	# precedent). N2380: the advance exposes the liquid
	# write-back keys -- dump_neighbour_index (the shared
	# routing's handled_index, the FIRST eligible neighbour
	# whose transfer actually moved liquid, -1 when nothing
	# moved -- a dump that reaches several neighbours reports
	# only the first, so the per-neighbour split waits for its
	# own slice) + dumped_liquid_name (the dumped liquid's
	# catalog name). KEY COLLISION: dumped_liquid is ALREADY a
	# result key and it is the FLOAT amount dumped
	# (BuildingComp.java:905), NOT a name -- this slice does
	# NOT change its meaning and adds the separate
	# dumped_liquid_name String key instead. The name resolves
	# the current liquid id through the liquid_names_by_id
	# frame input (the PayloadLoader precedent: the tick
	# builds the names-by-id array from
	# catalog.get_many("liquid"), index == id, and stamps it
	# on the frame; a fixture without it reads ""). The names
	# ride the frame, not a new parameter, because the N2293
	# test pins the exact tick call string. The name is set
	# whenever a current liquid resolves, even when nothing
	# moved (the Fracker dumped_liquid precedent). The item
	# half (dump_item_state already returns handled_index)
	# waits for its own follow-through slice through the N2353
	# helper.
	var delta: float = source_delta * time_scale
	var cursor: int = int(frame.get("cdump", 0))
	var store: Dictionary = (frame.get("liquids", {}) as Dictionary).duplicate(true)
	var items: Dictionary = (frame.get("items", {}) as Dictionary).duplicate(true)
	var dump_accum: float = float(frame.get("dump_accum", 0.0))
	var dumped_liquid: float = 0.0
	var dump_neighbour_index: int = -1
	var dumped_liquid_name: String = ""
	var current: Variant = _payload_unloader_liquid_current(store)
	if current != null and store.has("liquids") and int(current) >= 0 and int(current) < int(store["liquids"].size()):
		var current_amount: float = float(source_liquid_module_state.source_get_state(store, int(current)).get("amount", 0.0))
		var proximity_size: int = neighbour_liquid_amounts.size()
		var relative_to: Array = []
		var destination_present: Array = []
		var other_has_liquids: Array = []
		var can_dump_liquid: Array = []
		var other_liquids_present: Array = []
		for i in range(proximity_size):
			relative_to.append(i)
			destination_present.append(true)
			other_has_liquids.append(float(neighbour_liquid_capacities[i]) > 0.0)
			can_dump_liquid.append(bool(neighbour_can_dump_liquid[i]))
			other_liquids_present.append(true)
		var dumped: Dictionary = source_building_liquid_state.dump_liquid_state(int(current), 2.0, -1, current_amount, false, true, true, proximity_size, cursor, 0, relative_to, destination_present, other_has_liquids, can_dump_liquid, other_liquids_present, neighbour_liquid_amounts, neighbour_liquid_capacities, neighbour_accepts_liquid, SOURCE_PAYLOAD_UNLOADER_LIQUID_CAPACITY, Callable(source_building_item_dump_state, "increment_dump_cursor_state"))
		var amount_after: float = float(dumped.get("current_liquid_amount_after", current_amount))
		dumped_liquid = current_amount - amount_after
		cursor = int(dumped.get("final_cdump", cursor))
		dump_neighbour_index = int(dumped.get("handled_index", -1))
		var liquid_names_by_id: Array = frame.get("liquid_names_by_id", [])
		if int(current) >= 0 and int(current) < liquid_names_by_id.size():
			dumped_liquid_name = str(liquid_names_by_id[int(current)])
		if dumped_liquid != 0.0:
			var cache_sums: Array = []
			if store.get("flow") != null:
				cache_sums.resize(int(store["liquids"].size()))
				cache_sums.fill(0.0)
			source_liquid_module_state.source_remove_state(store, int(current), dumped_liquid, cache_sums)
	var dumped_items: int = 0
	for _i in range(SOURCE_PAYLOAD_UNLOADER_OFFLOAD_SPEED):
		var attempt: Dictionary = source_building_item_dump_state.dump_accumulate_state(dump_accum, delta)
		dump_accum = float(attempt.get("dump_accum", dump_accum))
		for _a in range(int(attempt.get("dump_attempts", 0))):
			var amounts: Array = []
			for item_id in item_order:
				amounts.append(int(items.get(str(item_id), 0)))
			var result: Dictionary = source_building_item_dump_state.dump_item_state(true, inventory.items_total(items), neighbour_accepts_item.size(), null, false, item_order, amounts, neighbour_accepts_item, neighbour_can_dump_item, cursor)
			cursor = int(result.get("cdump", cursor))
			if bool(result.get("dumped", false)):
				dumped_items += 1
				var amounts_after: Array = result.get("item_amounts_by_index", amounts)
				for j in range(item_order.size()):
					if j < amounts_after.size():
						items[str(item_order[j])] = int(amounts_after[j])
	return {"liquids_after": store, "dumped_liquid": dumped_liquid, "items_after": items, "dumped_items": dumped_items, "cursor_after": cursor, "dump_accum_after": dump_accum, "dump_neighbour_index": dump_neighbour_index, "dumped_liquid_name": dumped_liquid_name}

static func source_payload_unloader_accept_payload_state(has_payload: bool, offered_payload: Variant) -> Dictionary:
	# The acceptPayload gate (PayloadLoaderBuild.acceptPayload(),
	# PayloadLoader.java:90-101), inherited verbatim by
	# PayloadUnloaderBuild -- `public class PayloadUnloader extends PayloadLoader{`
	# (PayloadUnloader.java:8) and `public class PayloadUnloaderBuild extends PayloadLoaderBuild{`
	# (PayloadUnloader.java:32), and PayloadUnloader.java has NO
	# acceptPayload at all, so the Unloader inherits the Loader's
	# override, NOT the bare PayloadBlock base gate
	# (PayloadBlock.java:116-118). SCOPE CORRECTION: the brief
	# claimed the base gate and called DEFERRED entry 12's
	# "PayloadLoader.java:90-101, inherited" cite misleading --
	# the cite was CORRECT; the Unloader's gate IS the Loader
	# override, because `public class PayloadLoaderBuild extends PayloadBlockBuild<BuildPayload>{`
	# (PayloadLoader.java:86) overrides acceptPayload and the
	# UnloaderBuild does not. The Unloader accepts payloads but
	# never loose items or liquids -- that is why its dump rows
	# (N2293) move items/liquids OUT only. The gate (each exact
	# expr on ONE comment line, the N2148 lesson):
	# `public boolean acceptPayload(Building source, Payload payload){`
	# `return super.acceptPayload(source, payload) &&`
	# `payload.fits(maxBlockSize) &&`
	# `payload instanceof BuildPayload build && (`
	# `(build.build.block.hasItems && build.block().unloadable && build.block().itemCapacity >= 10 && build.block().size <= maxBlockSize) ||`
	# `(build.build.block.hasLiquids && build.block().liquidCapacity >= 10f) ||`
	# `(build.build.block.consPower != null && build.build.block.consPower.buffered)`
	# `public int maxBlockSize = 3;` (PayloadLoader.java:25, inherited -- the const above).
	# `return this.payload == null;` (PayloadBlock.java:117 -- the super call, the has_payload input).
	# `default boolean fits(float s){` (Payload.java:50) with `return size() / tilesize <= s;` (Payload.java:51); tilesize is `public static final int tilesize = 8;` (Vars.java:135) and a BuildPayload's size() is `return build.block.size * tilesize;` (BuildPayload.java:86-88), so fits(3) is block.size <= 3 for build payloads.
	# `public boolean unloadable = true;` (Block.java:106 -- the default when the descriptor omits it).
	# acceptItem / acceptLiquid are hard-coded false: `public boolean acceptItem(Building source, Item item){` (PayloadUnloader.java:36) and `public boolean acceptLiquid(Building source, Liquid liquid){` (PayloadUnloader.java:41), each with `return false;` (:37, :42).
	# Offered-payload descriptor contract (this slice):
	# offered_payload = {"is_build_payload": bool, "size": float
	# (Payload.size() in pixels -- build block size * tilesize,
	# BuildPayload.java:87; unit hitSize for unit payloads),
	# "block": {"has_items": bool, "unloadable": bool (default
	# true, Block.java:106), "item_capacity": int, "size": int
	# (block size in tiles), "has_liquids": bool,
	# "liquid_capacity": float, "cons_power_capacity": float or
	# null (null = no consPower, the N2232 contract),
	# "cons_power_buffered": bool}}. build.build.block and
	# build.block() are the SAME Block (BuildPayload.block()
	# returns build.block), so one block dict covers both.
	# Missing keys default to the rejecting values
	# (is_build_payload false, no size key = no fits,
	# capacities 0, no consPower) -- except unloadable, whose
	# Java default is true. A null / non-dict offer means no
	# payload is offered: accept_payload is false (Java would
	# NPE on payload.fits(null); the port treats no offer as
	# no acceptance -- the gate answers a question about an
	# offered payload, and with nothing offered there is
	# nothing to accept). The pure does NOT mutate its inputs.
	# The gate is exposed on the frame by the tick AND
	# wired as the N2279 intake guard since N2313 (the tick
	# computes the verdict from the incoming dict itself and
	# applies the push only when it accepts; an occupied
	# frame keeps the push for retry, a rejected push is
	# dropped).
	var accept_item: bool = false
	var accept_liquid: bool = false
	var accept_payload: bool = false
	if not has_payload and offered_payload is Dictionary:
		var offered: Dictionary = offered_payload as Dictionary
		var block: Dictionary = offered.get("block", {})
		var is_build: bool = bool(offered.get("is_build_payload", false))
		var fits: bool = offered.has("size") and float(offered.get("size", 0.0)) / source_world_defaults.TILESIZE <= float(SOURCE_PAYLOAD_UNLOADER_MAX_BLOCK_SIZE)
		var item_container: bool = bool(block.get("has_items", false)) and bool(block.get("unloadable", true)) and int(block.get("item_capacity", 0)) >= 10 and int(block.get("size", 0)) <= SOURCE_PAYLOAD_UNLOADER_MAX_BLOCK_SIZE
		var liquid_container: bool = bool(block.get("has_liquids", false)) and float(block.get("liquid_capacity", 0.0)) >= 10.0
		var battery: bool = block.get("cons_power_capacity", null) != null and bool(block.get("cons_power_buffered", false))
		accept_payload = is_build and fits and (item_container or liquid_container or battery)
	return {"accept_payload": accept_payload, "accept_item": accept_item, "accept_liquid": accept_liquid}

static func source_payload_unloader_should_consume_state(frame: Dictionary) -> Dictionary:
	# PayloadUnloaderBuild does NOT override shouldConsume (PayloadUnloader.java has no shouldConsume at all; PayloadUnloader extends PayloadLoader, PayloadUnloader.java:8, `public class PayloadUnloader extends PayloadLoader{`, and PayloadUnloaderBuild extends PayloadLoaderBuild, PayloadUnloader.java:32, `public class PayloadUnloaderBuild extends PayloadLoaderBuild{`), so it inherits PayloadLoaderBuild.shouldConsume verbatim (PayloadLoader.java:240, `public boolean shouldConsume(){` with `return payload != null;`, PayloadLoader.java:241): the payload-unloader consumes only while it holds a payload. The default (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`) does NOT apply here. Unlike the Separator/Drill gates this one has NO `&& enabled` -- Java returns the bare payload null check, so the pure gate does NOT read frame["enabled"] at all (the driver already runs the machinery only when enabled). The payload is the PayloadBlockBuild field (`public @Nullable T payload;`, PayloadBlock.java:92), default null, set by handlePayload (`this.payload = (T)payload;`, PayloadBlock.java:122) and cleared by takePayload (PayloadBlock.java:145-149); the frame carries it under the `payload` key (default null for a frame bound before this slice), and the gate reads only its null-ness -- a minimal Dictionary fixture suffices in the proof. The def is payload-unloader (`consumePower(2f);`, Blocks.java:6695; `size = 3;`, Blocks.java:6696); there is no large-payload-unloader. When the gate is false updateConsumption forces efficiency to zero (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). The live fill is live since N2279 -- handlePayload applies the frame incoming_payload input before the advance (the moveInPayload / moveOutPayload advance is live since N2232), so the gate reads the filled frame; takePayload is ported pure but not wired live.
	var payload: Variant = frame.get("payload", null)
	var has_payload: bool = payload != null
	return {"should_consume": has_payload, "has_payload": has_payload}

static func source_payload_unloader_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a payload-unloader does not take the early return. The unload gate follows the folded efficiency (PayloadUnloader.java:69, `if(efficiency > 0.01f && timer(timerLoad, loadTime / efficiency)){`), with the battery unload (PayloadUnloader.java:98, `float total = payload.build.power.status * cap;`) and the shouldConsume default (BuildingComp.java:755, `public boolean shouldConsume(){`) and the shouldConsume override inherited from PayloadLoaderBuild (PayloadLoader.java:241, `return payload != null;`); the gate is live since N2209 (the pure gate source_payload_unloader_should_consume_state feeds payload != null to the machinery; when the gate is false updateConsumption forces efficiency to 0, BuildingComp.java:1960 + 1992).
	# Documented limits: (1) power-only first pass -- PayloadUnloader has NO dynamic power consumer: `loadPowerDynamic = false` (PayloadUnloader.java:18), so `init()` never registers the ConsumePowerDynamic lambda (PayloadLoader.java:77-84, guarded by `if(loadPowerDynamic){` at :78); the static consumePower(2f) def (Blocks.java:6695) is the only power consumer, so the folded efficiency is the min over the *modeled* consumers (power only) and the power-only fold is EXACT. (An earlier docstring + DEFERRED entry claimed an inherited dynamic consumer -- WRONG, corrected at wave power-launch-build integration, 2026-11-15.) (2) shouldConsume gate live (N2209) -- PayloadUnloaderBuild inherits shouldConsume() to return payload != null (PayloadLoader.java:240-242); the pure gate (source_payload_unloader_should_consume_state) feeds should_consume to the machinery from the frame payload key (default null). The live payload fill live (N2279) -- handlePayload applies the frame incoming_payload input before the advance (gated by the N2296 verdict since N2313 -- a refused push is dropped, still consumed; an occupied frame keeps the push for retry), so a live payload-unloader with a pushed payload consumes the same tick; takePayload is ported pure but NOT wired live (the unit-pickup path waits for live units), and the live incoming source (front moveOutPayload push / unit drop) waits for its own slice, so until then incoming_payload is a frame input. (3) shouldExport gate live (N2232) -- shouldExport() (PayloadUnloader.java:116-122) runs in the pure advance over the frame payload (items empty / liquids <= 0.011f / battery status <= 0.0000001f). (4) updateTile advance live (N2232) -- moveInPayload / moveOutPayload (reused helper) / unload items+liquids / battery unload / lastOutputPower (PayloadUnloader.java:50-110) run on the frame; the timer cadence live (N2320) -- the frame-local Interval (2f/efficiency) passes the computed load_tick into the advance (first-fire deviation: Java fires (nearly) immediately after placement; the frame clock delays the first fire by a full interval); the movePayload/dumpPayload application and the live front query wait for their own slices. The dump rows live (N2293) -- source_payload_unloader_dump_state, dumpLiquid(current) 2f + offloadSpeed x dumpAccumulate() at the end of updateTile, PayloadUnloader.java:105-108, unconditional -- outside the payload-null check and the shouldExport/moveInPayload branches. The dump neighbour write-back (liquid half) is live since N2380 (the advance exposes dump_neighbour_index + dumped_liquid_name and the tick lands the dumped liquid in the handled neighbour frame through the shared N2371 helper); the item half waits for its own follow-through slice. (5) acceptPayload rows live (N2296) -- the Unloader inherits the Loader's acceptPayload override (PayloadLoader.java:90-101: base null gate + fits(maxBlockSize) + BuildPayload container branches), NOT the bare PayloadBlock base gate (PayloadBlock.java:116-118) -- PayloadUnloaderBuild extends PayloadLoaderBuild (PayloadUnloader.java:32), so the Loader override applies; the pure gate (source_payload_unloader_accept_payload_state) exposes accepts_payload / accepts_item / accepts_liquid on the frame from the offered-payload frame input (default null, no offer), and acceptItem/acceptLiquid are hard false (PayloadUnloader.java:35-44); the gate is wired as the intake guard since N2313 (see (7)) and no live source offers a payload yet. (6) Battery unload live (N2232), power-production graph wiring deferred -- getPowerProduction returns lastOutputPower (PayloadUnloader.java:46-48; lastOutputPower 0f, PayloadUnloader.java:33) and the battery unload (PayloadUnloader.java:94-102) fills frame last_output_power each tick, but the power graph builds producers from the static block property powerProduction, so the dynamic value waits for a distribution-runtime slice; the dump rows are live since N2293 (see (4)). (7) Intake full-gate wiring live (N2313) -- the tick builds the N2296 descriptor from the incoming dict itself (is_build_payload / size on the payload dict, the block flags on its block dict; missing keys reject) and applies the push only when the verdict accepts; occupancy KEEPS the push for next tick (the N2279 keep-for-retry, preserved -- unlike the N2308 Deconstructor drop), descriptor rejection DROPS it (consumed); the offered-payload verdict still governs frame["accepts_payload"] (when both an offer and a push are present, the offer verdict governs the frame key and the intake verdict decides the push alone -- the intake never overwrites frame["accepts_payload"]).
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

@warning_ignore("unused_parameter")
static func source_payload_unloader_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the payload-unloader tick wiring every
	# tick (PayloadUnloaderBuild.updateTile(), PayloadUnloader.java:50,
	# gates on the unload gate (PayloadUnloader.java:69, `if(efficiency > 0.01f && timer(timerLoad, loadTime / efficiency)){`) and the battery unload (PayloadUnloader.java:98, `float total = payload.build.power.status * cap;`), so the unload gate follows the folded efficiency; no placed-buildings driver ticks PayloadUnloader blocks, so this driver is the placed-payload-unloader tick): each placed PayloadUnloader build gets its frame keys refreshed from the live rules, so the frame's cheating flag tracks team.rules().cheat and the consumption machinery skips consumption for a cheating team. The frame is bound at placement; a sprite that somehow lacks one gets it bound here instead of crashing the loop.
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
	var item_order: Array = source_content_registry_runtime_state.source_item_catalog_state(catalog).get("item_names_by_id", [])
	# N2380: the liquid names by id (the PayloadLoader
	# precedent -- catalog.get_many("liquid") in catalog
	# order, index == id, the liquid_id_by_name inverse), so
	# the dump advance can resolve the dumped current liquid
	# id to its catalog name through the frame input.
	var liquid_names_by_id: Array = []
	for liquid in catalog.get_many("liquid"):
		liquid_names_by_id.append(liquid.id)
	for sprite in source_placed_block_state.source_unique_buildings_state(game).get("buildings", []):
		if not is_instance_valid(sprite) or not sprite is Sprite2D:
			continue
		var block_id: String = str(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
		if not blocks_by_id.has(block_id):
			continue
		var block = blocks_by_id[block_id]
		if not _is_payload_unloader_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_payload_unloader_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_payload_unloader_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The frame carries the Building.rotation (BuildingComp.
		# java:69 `transient int rotation;`, default 0) for the
		# moveIn/moveOut rotdeg() (BuildingComp.java:582-584
		# `return rotation * 90;`): the runtime stores it on
		# the sprite meta at placement (the factory precedent),
		# and sprites placed before the meta existed read as
		# rotation 0. The frame carries the Building.liquids
		# LiquidModule (frame["liquids"]): the live store lives
		# on the sprite meta (source_building_liquids,
		# initialized at placement), so the driver syncs the
		# reference into the frame each tick (the N2224
		# Fracker precedent) and the advance reads the result
		# amount from it.
		frame["rotation"] = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_ROTATION_META_KEY, 0))
		frame["liquids"] = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
		# N2279: the handlePayload intake runs before the
		# consumption fold and the advance -- handlePayload is
		# an external call (the pusher's moveOutPayload or a
		# unit drop), so it lands before this tick, and the
		# newly-arrived payload feeds shouldConsume (payload
		# != null) the same tick. The intake applies only when
		# the full acceptPayload gate accepts the push (N2313):
		# Java only ever calls handlePayload after acceptPayload
		# returns true -- the pusher checks first
		# (BuildingComp.java:822-824, `if(next != null && next.build != null && next.build.team == team && next.build.acceptPayload(self(), todump)){` then `next.build.handlePayload(self(), todump);`, and the dumpPayload twin at :844-845, `if(other.acceptPayload(self(), todump)){` then `other.handlePayload(self(), todump);`), so the tick computes the N2296 verdict from the incoming dict itself (source_payload_unloader_accept_payload_state) and applies the push only when it accepts. The incoming payload dict gains the is_build_payload / size keys (the N2296 descriptor contract); a push without them rejects (the pure defaults is_build_payload to false and fits to false without a size) and a non-dict push rejects too. Occupancy and rejection differ: an input that arrives while a payload is held STAYS for a later tick (the N2279 keep-for-retry, preserved -- the verdict is only evaluated when the frame is empty), while a rejected push is DROPPED, still consumed -- a non-container / oversize / non-BuildPayload push would retry forever. The offered-payload verdict still governs frame["accepts_payload"] (from the offered descriptor, below): when both an offer and a push are present, the offer verdict governs the frame key and the intake verdict decides the push alone -- the intake never overwrites frame["accepts_payload"]. The push source is not live yet, so incoming_payload is a frame input until a front-push / unit-drop slice lands. takePayload is NOT wired live (the unit-pickup path waits for live units; the move-out clear is already live through the N2232 advance).
		var incoming: Variant = frame.get("incoming_payload", null)
		if incoming != null:
			# N2313: occupancy KEEPS the push for retry --
			# the verdict is only evaluated when the frame
			# is empty; a rejected push is consumed
			# (dropped) instead.
			if frame.get("payload", null) == null:
				# The intake verdict comes from the N2296
				# pure, computed from the incoming dict
				# itself. The incoming payload dict carries
				# the N2296 descriptor keys (is_build_payload
				# / size on the payload, the block flags on
				# its block dict); missing keys default to
				# the rejecting values inside the pure
				# (is_build_payload false, no size = no fits,
				# capacities 0), so a push without them
				# rejects -- as does a non-dict push, which
				# carries neither. The pure's has_payload
				# term reads the frame (false here -- the
				# frame is empty by the branch above).
				var intake_accepts: bool = false
				if incoming is Dictionary:
					var incoming_payload_dict: Variant = (incoming as Dictionary).get("payload", null)
					if incoming_payload_dict is Dictionary:
						var incoming_descriptor: Dictionary = {"is_build_payload": bool((incoming_payload_dict as Dictionary).get("is_build_payload", false)), "block": (incoming_payload_dict as Dictionary).get("block", {})}
						if (incoming_payload_dict as Dictionary).has("size"):
							incoming_descriptor["size"] = (incoming_payload_dict as Dictionary).get("size")
						intake_accepts = bool(source_payload_unloader_accept_payload_state(frame.get("payload", null) != null, incoming_descriptor).get("accept_payload", false))
				if intake_accepts:
					var handled: Dictionary = source_payload_unloader_handle_payload_state(frame, incoming)
					frame["payload"] = handled["payload"]
					frame["pay_vector"] = handled["pay_vector"]
					frame["pay_rotation"] = handled["pay_rotation"]
				frame["incoming_payload"] = null
		# N2296: the acceptPayload gate runs every tick, after
		# the intake -- acceptPayload is an external call (the
		# pusher asks whether the offered payload may land),
		# so the tick evaluates it against the filled frame
		# payload and the offered-payload frame input
		# (default null -- no offer) and exposes all three
		# verdicts on the frame. The gate ALSO drives the
		# intake since N2313 (the intake above computes the
		# same pure's verdict from the incoming dict itself)
		# -- but the intake verdict never overwrites these
		# frame keys: the offer verdict governs
		# frame["accepts_payload"] and the intake verdict
		# decides the push alone. accept_item /
		# accept_liquid are hard false
		# (PayloadUnloader.java:35-44) -- the Unloader
		# accepts payloads but never loose items or liquids.
		var has_payload: bool = frame.get("payload", null) != null
		var offered_payload: Variant = frame.get("offered_payload", null)
		var accepts: Dictionary = source_payload_unloader_accept_payload_state(has_payload, offered_payload)
		frame["accepts_payload"] = accepts["accept_payload"]
		frame["accepts_item"] = accepts["accept_item"]
		frame["accepts_liquid"] = accepts["accept_liquid"]
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a payload-unloader with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the unload gate (PayloadUnloader.java:69)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a payload-unloader does not take the early return. A payload-unloader with no power consumer is untouched: the tick models no other consumers yet (there is NO dynamic power consumer row -- loadPowerDynamic is false, PayloadUnloader.java:18), and PayloadUnloaderBuild inherits shouldConsume() to return payload != null (PayloadLoader.java:240-242) -- N2209 feeds the live gate to the machinery (the pure gate is source_payload_unloader_should_consume_state, fed the frame payload key); the N2163 RED decision is resolved. The gate has no enabled term (Java returns the bare payload null check); the outer guard below already runs the machinery only when enabled. productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var gate: Dictionary = source_payload_unloader_should_consume_state(frame)
			var should_consume: bool = bool(gate.get("should_consume", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_payload_unloader_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		# N2232: the updateTile advance runs after consumption,
		# like Java's Building.update() (BuildingComp.java:2274
		# `updateConsumption();`, then the updateTile gate
		# `if(enabled || !block.noUpdateDisabled){` at
		# BuildingComp.java:2276-2277; noUpdateDisabled defaults
		# false, Block.java:170, so Java runs updateTile even
		# when disabled -- the port keeps the enabled gate
		# below as a pragmatic choice (the N2195
		# coordinator-fix precedent): the driver skips the
		# consumption fold when disabled, so the frame
		# efficiency goes stale and running the advance on it
		# would unload from a stale efficiency. The driver-wide
		# disabled-early-return slice removes this gate for all
		# families. The source delta is Time.delta in ticks:
		# game_source_delta(game, seconds) is seconds * 60
		# (arc Time.java:26), never raw seconds. timeScale
		# reads live from the sprite meta, default 1.0
		# (BuildingComp.java:98 `private transient float
		# timeScale = 1f, timeScaleDuration;`). N2320: the
		# load timer cadence (PayloadUnloader.java:69,
		# `if(efficiency > 0.01f && timer(timerLoad, loadTime
		# / efficiency)){`) -- the frame-local clock
		# (frame["timer_load_elapsed"]) accumulates the tick
		# delta every tick the advance runs, and the computed
		# load_tick reaches the advance; the threshold divides
		# by the folded frame efficiency, never by timeScale
		# (the N2290 lesson). The clock runs only while
		# enabled (the same pragmatic gate as the advance
		# itself -- Java runs updateTile even when disabled,
		# BuildingComp.java:2276-2277); the driver-wide
		# disabled-early-return slice removes this gate for
		# all families. First-fire deviation: Java fires
		# nearly at once after placement; the frame clock
		# delays the first fire by a full interval
		# (2f/efficiency ticks). The item order is the
		# catalog item_names_by_id (the N2225 content-id
		# order). The front flags arrive as explicit
		# params (no live neighbor query), so the driver passes
		# front-absent: a live payload-unloader never moves its
		# payload into a front building until a live-front slice
		# lands. The advanced liquids store is written back to
		# the sprite meta (the pure advance returns a duplicate,
		# it does not mutate the synced store in place).
		if bool(frame.get("enabled", true)):
			var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
			var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
			var front: Dictionary = {"present": false, "solid": false, "outputs_payload": false, "accepts_payload": false, "move_payload_result": false}
			var load_timer: Dictionary = source_payload_unloader_load_timer_state(float(frame.get("timer_load_elapsed", 0.0)), source_delta, time_scale, float(frame.get("efficiency", 0.0)), SOURCE_PAYLOAD_UNLOADER_LOAD_TIME)
			frame["timer_load_elapsed"] = load_timer.get("timer_elapsed_after", 0.0)
			var load_tick: bool = bool(load_timer.get("load_tick", false))
			var advanced: Dictionary = source_payload_unloader_update_tile_advance_state(frame, source_delta, time_scale, load_tick, item_order, front)
			frame["payload"] = advanced["payload"]
			frame["pay_vector"] = advanced["pay_vector"]
			frame["pay_rotation"] = advanced["pay_rotation"]
			frame["items"] = advanced["items"]
			frame["liquids"] = advanced["liquids"]
			sprite.set_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, advanced["liquids"])
			frame["last_output_power"] = advanced["last_output_power"]
			frame["should_export"] = advanced["should_export"]
			frame["moved_in"] = advanced["moved_in"]
			frame["payload_moved"] = advanced["payload_moved"]
			frame["payload_dumped"] = advanced["payload_dumped"]
			frame["deconstructed"] = advanced["deconstructed"]
			frame["items_unloaded"] = advanced["items_unloaded"]
			frame["liquids_unloaded"] = advanced["liquids_unloaded"]
			# N2293: the dump rows run at the END of updateTile,
			# after the advance (PayloadUnloader.java:105-108,
			# after the moveInPayload branch :57-103),
			# UNCONDITIONAL -- outside the payload-null check
			# (:52-54) and the shouldExport / moveInPayload
			# if-else, so they run even when the unloader holds
			# no payload and even when efficiency is 0 (the dump
			# reads no efficiency). They still sit inside the
			# driver's enabled gate like the advance (the N2195
			# precedent -- see above). The neighbour arrays are
			# frame inputs (default [] -- no neighbours, the Java
			# proximity.size == 0 outcome); the live proximity
			# scan + the ITEM neighbour write-back wait for
			# their own slices (the LIQUID neighbour write-back
			# is live since N2380, below). The dumped liquids
			# store is written back to the sprite meta (the pure
			# returns a duplicate, it does not mutate the synced
			# store in place); the dumped items leave the frame
			# store without landing in any neighbour store yet.
			frame["liquid_names_by_id"] = liquid_names_by_id
			var dump_neighbour_liquid_amounts: Array = frame.get("dump_neighbour_liquid_amounts", [])
			var dump_neighbour_liquid_capacities: Array = frame.get("dump_neighbour_liquid_capacities", [])
			var dump_neighbour_accepts_liquid: Array = frame.get("dump_neighbour_accepts_liquid", [])
			var dump_neighbour_can_dump_liquid: Array = frame.get("dump_neighbour_can_dump_liquid", [])
			var dump_neighbour_accepts_item: Array = frame.get("dump_neighbour_accepts_item", [])
			var dump_neighbour_can_dump_item: Array = frame.get("dump_neighbour_can_dump_item", [])
			var dumped: Dictionary = source_payload_unloader_dump_state(frame, source_delta, time_scale, item_order, dump_neighbour_liquid_amounts, dump_neighbour_liquid_capacities, dump_neighbour_accepts_liquid, dump_neighbour_can_dump_liquid, dump_neighbour_accepts_item, dump_neighbour_can_dump_item)
			frame["liquids"] = dumped["liquids_after"]
			sprite.set_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, dumped["liquids_after"])
			frame["items"] = dumped["items_after"]
			frame["cdump"] = dumped["cursor_after"]
			frame["dump_accum"] = dumped["dump_accum_after"]
			frame["dumped_liquid"] = dumped["dumped_liquid"]
			frame["dumped_items"] = dumped["dumped_items"]
			# N2380: the liquid neighbour write-back -- the
			# shared source_neighbour_liquid_write_back_state
			# helper (N2371) lands the dumped liquid in the
			# handled neighbour's store (dumpLiquid's
			# next.handleLiquid, BuildingComp.java:918) after
			# the dump write-back above, when something dumped.
			# The handled index is a ring index (index i is
			# ring cell i, the N2353 convention), so the live
			# fill must fill the frame neighbour inputs in ring
			# order; the tick reads the origin_cell meta inline
			# as dump_cell (cell is bound after the enabled
			# block, the N2363 note) and the catalog size. The
			# dumped amount reads from the dumped_liquid FLOAT
			# key (the N2293 amount, NOT a name -- the name
			# rides the new dumped_liquid_name key). A failed
			# write-back (no sprite / no frame / no liquids
			# store) drops the liquid -- the routing already
			# decided, so there is no fallback to the
			# unloader's own store (the N2353 precedent). A dump
			# that reaches several neighbours lands the total
			# in the first handled one -- the per-neighbour
			# split waits for its own slice. The ITEM half waits
			# for its own follow-through slice (N2353 helper).
			if float(dumped.get("dumped_liquid", 0.0)) > 0.0:
				var dump_index: int = int(dumped.get("dump_neighbour_index", -1))
				if dump_index >= 0:
					var dump_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
					source_building_liquid_state.source_neighbour_liquid_write_back_state(game, dump_cell, int(block.properties.get("size", 1)), dump_index, str(dumped.get("dumped_liquid_name", "")), float(dumped.get("dumped_liquid", 0.0)))
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
