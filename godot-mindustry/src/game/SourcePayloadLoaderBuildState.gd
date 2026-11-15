extends RefCounted
class_name SourcePayloadLoaderBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_move_out_payload_state := preload("res://src/game/SourceBlockProducerMoveOutPayloadState.gd")
const source_liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const source_content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")
const inventory := preload("res://src/game/SourceDrillInventoryRuntimeState.gd")

# The PayloadLoader implementation (PayloadLoader.java:19, `public class PayloadLoader extends PayloadBlock{`): payload-loader (consumePower(2f);, size 3, loadTime 2f, maxPowerConsumption 40f, Blocks.java:6682-6689). PayloadLoader has hasPower = true; (PayloadLoader.java:36), hasItems=true, hasLiquids=true, update=true, outputsPayload=true, size 3, rotate=true (PayloadLoader.java:31-41). PayloadLoader extends PayloadBlock, NOT a drill or factory, so it cannot reuse an existing frame key; this driver uses its own family frame key ("source_payload_loader_building", the mechanical-pump / beam-drill / mend-projector / overdrive-projector / force-projector / base-shield / regen-projector / constructor precedent), and this slice adds the payload-loader key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourcePayloadLoader* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the load gate (PayloadLoader.java:157, `if(efficiency > 0.01f && timer(timerLoad, loadTime / efficiency)){`) follows the folded efficiency, with the battery charge (PayloadLoader.java:202, `float powerInput = power.status * (basePowerUse + maxPowerConsumption);`).
const SOURCE_PAYLOAD_LOADER_BUILD_IMPLEMENTATIONS := ["PayloadLoader"]
const SOURCE_PAYLOAD_LOADER_BUILDING_META_KEY := "source_payload_loader_building"
# Def consts for the updateTile advance (N2231): loadTime 2f,
# itemsLoaded 8, liquidsLoaded 40f, maxBlockSize 3,
# maxPowerConsumption 40f (PayloadLoader.java:22-26), basePowerUse
# 2f (the def consumePower, Blocks.java:6686, via
# `basePowerUse = consPower != null ? consPower.usage : 0f;`,
# PayloadLoader.java:79), size 3 (Blocks.java:6687), payloadSpeed
# 0.7f / payloadRotateSpeed 5f
# (`public float payloadSpeed = 0.7f, payloadRotateSpeed = 5f;`,
# PayloadBlock.java:18). The catalog carries none of these, so
# they arrive as driver consts (the N2220 pump_amount precedent).
# N2319 passes SOURCE_PAYLOAD_LOADER_LOAD_TIME to the load
# timer pure as the interval (the threshold divides it by the
# folded efficiency, PayloadLoader.java:157 -- never by
# timeScale, the N2290 lesson).
const SOURCE_PAYLOAD_LOADER_LOAD_TIME := 2.0
const SOURCE_PAYLOAD_LOADER_ITEMS_LOADED := 8
const SOURCE_PAYLOAD_LOADER_LIQUIDS_LOADED := 40.0
const SOURCE_PAYLOAD_LOADER_MAX_BLOCK_SIZE := 3
const SOURCE_PAYLOAD_LOADER_MAX_POWER_CONSUMPTION := 40.0
const SOURCE_PAYLOAD_LOADER_BASE_POWER_USE := 2.0
const SOURCE_PAYLOAD_LOADER_SIZE := 3
const SOURCE_PAYLOAD_LOADER_PAYLOAD_SPEED := 0.7
const SOURCE_PAYLOAD_LOADER_PAYLOAD_ROTATE_SPEED := 5.0

static func _is_payload_loader_build_implementation(implementation: String) -> bool:
	return SOURCE_PAYLOAD_LOADER_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_payload_loader_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The payload-loader tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (PayloadLoader.java:19, `public class PayloadLoader extends PayloadBlock{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# payload-loader skips consumption like Java's updateConsumption
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
	# for this payload-loader (N2125); the tick preserves a disabled
	# payload-loader instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	# A new PayloadLoaderBuild starts with no payload (the
	# PayloadBlock field, `public @Nullable T payload;`,
	# PayloadBlock.java:92, default null): the shouldConsume
	# gate (PayloadLoader.java:240-242) reads frame["payload"]
	# null-ness, so the frame carries the payload key (null
	# until the N2278 live fill sets it from the frame
	# incoming_payload push; moveInPayload positioning was
	# already live since N2231). N2231 adds the updateTile
	# advance keys with the Java field defaults:
	# `public boolean exporting = false;`
	# (PayloadLoader.java:87), `public Vec2 payVector = new Vec2();`
	# (PayloadBlock.java:94, (0, 0)),
	# `public float payRotation;` (PayloadBlock.java:95, 0f),
	# and the empty Building.items / Building.liquids stores
	# (the Fracker precedent: frame["items"] is a Dictionary
	# keyed by item name, frame["liquids"] the LiquidModule
	# dict synced from the sprite meta each tick). N2270 adds
	# frame["power_usage"] (default 0.0: no payload, so the
	# dynamic lambda charges 0f); the driver re-stamps it
	# every tick at fold time. N2295 adds frame["accepts_payload"]
	# (default false: no payload offered at placement, so no
	# verdict to give); the driver re-stamps it every tick from
	# the frame offered_payload descriptor when present. N2319
	# adds frame["timer_load_elapsed"] (default 0.0: the
	# frame-local Interval-equivalent clock for the load timer
	# cadence, PayloadLoader.java:157; the driver accumulates
	# it every tick and resets it to 0.0 on fire).
	return {
		"payload": null,
		"exporting": false,
		"power_usage": 0.0,
		"accepts_payload": false,
		"timer_load_elapsed": 0.0,
		"pay_vector": {"x": 0.0, "y": 0.0},
		"pay_rotation": 0.0,
		"items": {},
		"liquids": {},
	}

static func source_payload_loader_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the payload-loader frame meta key
	# ("source_payload_loader_building"). A PayloadLoader sprite gets a
	# frame bound with the payload key (null by default) plus the
	# N2231 updateTile advance keys (exporting / pay_vector /
	# pay_rotation / items / liquids, Java field defaults); the live-loop
	# tick fills its other keys every tick. Any other block, or an
	# already-bound sprite, binds nothing.
	if block == null or not _is_payload_loader_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_PAYLOAD_LOADER_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_PAYLOAD_LOADER_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_PAYLOAD_LOADER_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_payload_loader_should_consume_state(frame: Dictionary) -> Dictionary:
	# PayloadLoaderBuild overrides shouldConsume (PayloadLoader.java:240, `public boolean shouldConsume(){` with `return payload != null;`, PayloadLoader.java:241): the payload-loader consumes only while it holds a payload. PayloadLoader extends PayloadBlock (PayloadLoader.java:19, `public class PayloadLoader extends PayloadBlock{`) and PayloadLoaderBuild extends PayloadBlockBuild (PayloadLoader.java:86, `public class PayloadLoaderBuild extends PayloadBlockBuild<BuildPayload>{`; PayloadBlock.java:91, `public class PayloadBlockBuild<T extends Payload> extends Building{`), so the default (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`) does NOT apply here. Unlike the Separator/Drill gates this one has NO `&& enabled` -- Java returns the bare null check, so the pure gate does NOT read frame["enabled"] at all (the driver already runs the machinery only when enabled). The payload is the PayloadBlock field (`public @Nullable T payload;`, PayloadBlock.java:92), set by handlePayload (`this.payload = (T)payload;`, PayloadBlock.java:122; PayloadLoader.java:105, `super.handlePayload(source, payload);`) and cleared by takePayload (`payload = null;`, PayloadBlock.java:147); the frame carries it as frame["payload"] (default null for a frame bound before this slice). The gate reads only null-ness, so the payload value itself is opaque -- a minimal Dictionary fixture stands in for a BuildPayload in the proof. The def is the only payload-loader (payload-loader, `consumePower(2f);`, `size = 3;`, Blocks.java:6682-6689); there is no large-payload-loader. When the gate is false updateConsumption forces efficiency to zero (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). The live fill is live since N2278 (handlePayload intake through the frame incoming_payload push; takePayload is pure + tested, not wired live -- the unit-pickup path waits for live units).
	var payload: Variant = frame.get("payload", null)
	var has_payload: bool = payload != null
	return {"should_consume": has_payload, "has_payload": has_payload}

static func source_payload_loader_dynamic_power_usage_state(should_consume: bool, has_battery: bool, exporting: bool, base_power_use: float, max_power_consumption: float) -> Dictionary:
	# The dynamic power usage value (N2270): init() registers the dynamic consumer (PayloadLoader.java:77-84, `public void init(){` guarded by `if(loadPowerDynamic){` with `public boolean loadPowerDynamic = true;`, PayloadLoader.java:27) with the lambda (PayloadLoader.java:80, keep on ONE comment line, the N2148 shootWarmup lesson: a split line fails the test):
	# consumePowerDynamic(basePowerUse, (PayloadLoaderBuild loader) -> loader.shouldConsume() ? (loader.hasBattery() && !loader.exporting ? maxPowerConsumption + basePowerUse : basePowerUse) : 0f);
	# basePowerUse is consPower.usage = 2f (`basePowerUse = consPower != null ? consPower.usage : 0f;`, PayloadLoader.java:79, from the def `consumePower(2f);`, Blocks.java:6686); the max is the class constant `public float maxPowerConsumption = 40f;` (PayloadLoader.java:26). The graph queries requestedPower (`public float requestedPower(Building entity){` with `return usage.get(entity);`, ConsumePowerDynamic.java:24-25). hasBattery() is `return payload != null && payload.block().consPower != null && payload.block().consPower.buffered;` (PayloadLoader.java:235-237); exporting is the build field (`public boolean exporting = false;`, PayloadLoader.java:87); shouldConsume() is `return payload != null;` (PayloadLoader.java:240-242). Values: !should_consume -> 0.0; has_battery && !exporting -> base + max (42.0 while charging); otherwise base (2.0). charging is true exactly on the charging branch (should_consume && has_battery && !exporting) -- the battery charge itself runs in the N2231 advance (`float powerInput = power.status * (basePowerUse + maxPowerConsumption);`, PayloadLoader.java:202); this function only prices it.
	var charging: bool = should_consume and has_battery and not exporting
	var usage: float = 0.0
	if not should_consume:
		usage = 0.0
	elif charging:
		usage = base_power_use + max_power_consumption
	else:
		usage = base_power_use
	return {"usage": usage, "charging": charging}

static func source_payload_loader_handle_payload_state(incoming_payload: Variant, source_x: float, source_y: float, self_x: float, self_y: float, payload_rotation: float, block_size: int, tilesize: float) -> Dictionary:
	# The handlePayload intake (N2278): handlePayload(Building source, Payload payload)
	# (PayloadBlock.java:121-127) on `public class PayloadBlockBuild<T extends Payload> extends Building{` (PayloadBlock.java:91) /
	# `public class PayloadLoaderBuild extends PayloadBlockBuild<BuildPayload>{` (PayloadLoader.java:86):
	# `this.payload = (T)payload;` (PayloadBlock.java:122) sets the held payload (the field `public @Nullable T payload;`,
	# PayloadBlock.java:92, default null; the frame key frame["payload"]);
	# this.payVector.set(source).sub(this).clamp(-size * tilesize / 2f, -size * tilesize / 2f, size * tilesize / 2f, size * tilesize / 2f); (PayloadBlock.java:123)
	# sets payVector (the field `public Vec2 payVector = new Vec2();`, PayloadBlock.java:94) to the source offset, clamped per axis
	# to +/-size*tilesize/2 -- Vec2.clamp(minx, miny, maxx, maxy) is `x = Mathf.clamp(x, minx, maxx);` / `y = Mathf.clamp(y, miny, maxy);`
	# (arc Vec2.java:318-322), so each axis clamps independently; `public static final int tilesize = 8;` (Vars.java:135), so size 3
	# (the only def, payload-loader, `size = 3;`, Blocks.java:6687) clamps to +/-12.0 and size 4 would clamp to +/-16.0 (there is no
	# large-payload-loader def -- the scope's size-4 note was wrong, caught by the RED grep -- so size 4 is a param case of this pure
	# function, not a def); `this.payRotation = payload.rotation();` (PayloadBlock.java:124) records the payload rotation (the field
	# `public float payRotation;`, PayloadBlock.java:95, default 0f; `default float rotation(){` with `return 0f;`, Payload.java:55-57,
	# is the BuildPayload default, so a payload dict without a rotation key reads 0.0); `updatePayload();` (PayloadBlock.java:126) is
	# NOT ported: it only positions the live payload entity (`payload.set(x + payVector.x, y + payVector.y, payRotation);`, PayloadBlock.java:176)
	# and the port has no live payload entity -- payVector/payRotation ARE the record (the N2231 moveIn precedent). The Loader override
	# (PayloadLoader.java:104-107): `super.handlePayload(source, payload);` (PayloadLoader.java:105) then `exporting = false;`
	# (PayloadLoader.java:106) -- a fresh intake is never exporting (the field `public boolean exporting = false;`, PayloadLoader.java:87);
	# the N2231 advance may set it true again on later ticks. The pure function sets unconditionally, like Java: the null guard lives in
	# the driver (acceptPayload returns `this.payload == null`, PayloadBlock.java:117) and in acceptPayload itself (PayloadLoader.java:90-101,
	# live since N2295 as source_payload_loader_accept_payload_state + the frame accepts_payload verdict -- the handle pure still sets
	# unconditionally, like Java, and the driver intake gate consults it since N2315, computing the verdict from the incoming dict itself).
	# moveInPayload approach was already ported in the N2231 advance and is not ported again here.
	var half_size: float = float(block_size) * tilesize / 2.0
	var pay_x: float = clampf(source_x - self_x, -half_size, half_size)
	var pay_y: float = clampf(source_y - self_y, -half_size, half_size)
	return {"payload": incoming_payload, "pay_vector": {"x": pay_x, "y": pay_y}, "pay_rotation": payload_rotation, "exporting": false}

static func source_payload_loader_take_payload_state(payload: Variant) -> Dictionary:
	# The takePayload clear (N2278): `public Payload takePayload(){` (PayloadBlock.java:145) with `T t = payload;`
	# (PayloadBlock.java:146), `payload = null;` (PayloadBlock.java:147), `return t;` (PayloadBlock.java:148) -- the held payload
	# is returned to the caller and the slot clears (taking from an empty loader returns null). Pure + tested only: the unit-pickup
	# live path (canControlSelect / onControlSelect, PayloadBlock.java:103-113) waits for live units, and the move-out clear is
	# already live through the N2231 advance (movePayload success clears frame["payload"]), so the driver does NOT call this function
	# -- wiring it live would clear twice.
	return {"payload_taken": payload, "payload_after": null}

static func source_payload_loader_accept_payload_state(payload: Dictionary, has_payload: bool) -> Dictionary:
	# The acceptPayload consult gate (N2295): `public boolean acceptPayload(Building source, Payload payload){` (PayloadLoader.java:90-101)
	# on `public class PayloadLoader extends PayloadBlock{` (PayloadLoader.java:19) /
	# `public class PayloadLoaderBuild extends PayloadBlockBuild<BuildPayload>{` (PayloadLoader.java:86) /
	# `public class PayloadBlockBuild<T extends Payload> extends Building{` (PayloadBlock.java:91):
	# `return super.acceptPayload(source, payload) &&` (PayloadLoader.java:91)
	# `payload.fits(maxBlockSize) &&` (PayloadLoader.java:92)
	# `payload instanceof BuildPayload build && (` (PayloadLoader.java:93)
	# (build.build.block.hasItems && build.block().unloadable && build.block().itemCapacity >= 10 && build.block().size <= maxBlockSize) || (PayloadLoader.java:95, the item container)
	# (build.build.block.hasLiquids && build.block().liquidCapacity >= 10f) || (PayloadLoader.java:97, the liquid container)
	# (build.build.block.consPower != null && build.build.block.consPower.buffered) (PayloadLoader.java:99, the battery)
	# super.acceptPayload is `return this.payload == null;` (PayloadBlock.java:116-118), so the base gate is the has_payload param:
	# a loader already holding a payload (the field `public @Nullable T payload;`, PayloadBlock.java:92) accepts nothing. fits is
	# `default boolean fits(float s){` with `return size() / tilesize <= s;` (Payload.java:50-52) and a BuildPayload's size is
	# `return build.block.size * tilesize;` (BuildPayload.java:86-88), so for a BuildPayload fits is block.size <= maxBlockSize
	# (`public int maxBlockSize = 3;`, PayloadLoader.java:25, the driver const SOURCE_PAYLOAD_LOADER_MAX_BLOCK_SIZE). The item branch
	# repeats the size check (build.block().size <= maxBlockSize) even though fits already covers it -- Java has it, so the branch
	# verdict has it too. The descriptor carries the block flags Java reads live: unloadable (`public boolean unloadable = true;`,
	# Block.java:106, default true), itemCapacity (`public int itemCapacity = 10;`, Block.java:75, default 10), liquidCapacity
	# (`public float liquidCapacity = -1f;`, Block.java:77, default -1f), consPower (`public @Nullable ConsumePower consPower;`,
	# Block.java:414) with buffered (`public boolean buffered;`, ConsumePower.java:14). The capacity thresholds are inclusive
	# (>= 10 / >= 10f), so exactly 10 / 10.0 accepts. Missing descriptor keys default to the rejecting value (false / 0): Java
	# always reads a real BuildPayload block, so a partial fixture must NOT accept -- a descriptor missing unloadable rejects even
	# though the real block default is true. For a non-build payload the fits value reads the descriptor block_size (the port has no
	# unit hitSize in the descriptor -- UnitPayload.size() is unit.hitSize, UnitPayload.java:99-101); the verdict rejects regardless
	# through the instanceof gate, so the fits value is inert there. The source Building param is not read by any branch (Java
	# ignores it), so the pure takes no source. handlePayload stays live since N2278; acceptItem/acceptLiquid have no Loader
	# overrides (the base Building ones apply), so they are out of scope.
	var is_build_payload: bool = bool(payload.get("is_build_payload", false))
	var block_size: int = int(payload.get("block_size", 0))
	var fits: bool = block_size <= SOURCE_PAYLOAD_LOADER_MAX_BLOCK_SIZE
	var is_item_container: bool = is_build_payload and bool(payload.get("has_items", false)) and bool(payload.get("unloadable", false)) and int(payload.get("item_capacity", 0)) >= 10 and block_size <= SOURCE_PAYLOAD_LOADER_MAX_BLOCK_SIZE
	var is_liquid_container: bool = is_build_payload and bool(payload.get("has_liquids", false)) and float(payload.get("liquid_capacity", 0.0)) >= 10.0
	var is_battery: bool = is_build_payload and bool(payload.get("has_cons_power", false)) and bool(payload.get("cons_power_buffered", false))
	var accepts: bool = not has_payload and fits and is_build_payload and (is_item_container or is_liquid_container or is_battery)
	return {"accepts": accepts, "fits": fits, "is_item_container": is_item_container, "is_liquid_container": is_liquid_container, "is_battery": is_battery}

static func source_payload_loader_load_timer_state(elapsed: float, source_delta: float, time_scale: float, efficiency: float, load_time: float) -> Dictionary:
	# The frame-local Interval-equivalent for the load timer
	# cadence (N2319): the Java load gate is
	# (PayloadLoader.java:157):
	# `if(efficiency > 0.01f && timer(timerLoad, loadTime / efficiency)){`
	# with `public final int timerLoad = timers++;`
	# (PayloadLoader.java:20) and `public float loadTime = 2f;`
	# (PayloadLoader.java:22), on `public class PayloadLoader extends PayloadBlock{`
	# (PayloadLoader.java:19) / `public class PayloadLoaderBuild extends PayloadBlockBuild<BuildPayload>{`
	# (PayloadLoader.java:86). Inside the gate Java loads items
	# (`boolean acceptedAny = true;` / `acceptedAny = false;`,
	# PayloadLoader.java:156/158) -- that load logic already
	# lives in the N2231 advance; this pure only computes the
	# load_tick the advance takes. TimerComp.timer
	# (TimerComp.java:10-13, each exact expr on ONE comment
	# line, the N2148 lesson):
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
	# elapsed"], accumulated by the tick delta every tick,
	# unconditionally -- mirroring Time.time, which grows even
	# while the gate is closed): elapsed += source_delta
	# unconditionally (source_delta is the UNSCALED Time.delta
	# in ticks -- game_source_delta is seconds * 60, never
	# scaled by timeScale -- so the frame clock mirrors the
	# global Time.time exactly); load_tick = (efficiency >
	# 0.01) and (elapsed >= loadTime / efficiency) -- the
	# threshold divides by EFFICIENCY, not timeScale (the
	# N2290 lesson: Java passes `loadTime / efficiency` to
	# timer(), so the port threshold is load_time /
	# efficiency at every time_scale); elapsed_after RESETS
	# to 0.0 on fire (a reset, not a subtraction like the
	# Fracker accumulator); a non-positive time_scale is a
	# defensive guard (load_tick false -- see below). The
	# Java short-circuit order matters: eff <= 0.01 means
	# timer() is NEVER called (no reset), but Time.time
	# still advances -- so the port accumulates elapsed
	# unconditionally and a recovered efficiency fires at
	# once (the accumulated elapsed is already past the
	# threshold). eff <= 0 is the infinite-time branch
	# (TimerComp.java:11 -- the threshold is +inf, so no
	# fire, and the division by zero is guarded). time_scale
	# stays a parameter (signature stability -- the
	# contract, call sites, and tests keep it) and is still
	# read: a non-positive time_scale never fires, a
	# defensive port guard for a corrupt frame input --
	# Java timeScale is always positive in practice (the
	# default, BuildingComp.java:98, is
	# `private transient float timeScale = 1f, timeScaleDuration;`;
	# applyBoost / applySlowdown take positive intensities,
	# BuildingComp.java:461-478; decay resets it to 1f,
	# BuildingComp.java:2265-2266), so the guard is
	# unreachable in Java-exact play and the threshold is
	# Java-exact at every reachable time_scale. Note the
	# clock still ACCUMULATES at time_scale 0 (source_delta
	# is unscaled) -- only the fire is guarded. The gate
	# `efficiency > 0.01 and load_tick` already lives in
	# the N2231 advance pure (:446); this pure only
	# computes load_tick and never duplicates the gate.
	# Documented deviation (first fire): Java fires
	# (nearly) immediately after placement (the global
	# Time.time is already large vs a fresh Interval
	# times[id] = 0); the frame-local clock delays the
	# first fire by a full interval (2f/efficiency ticks).
	# It cannot be fixed without a global clock -- it
	# waits for a timer-infra slice if exact first-fire
	# timing is ever needed.
	var accumulated: float = elapsed + source_delta
	var threshold: float = INF
	if time_scale > 0.0 and efficiency > 0.01:
		threshold = load_time / efficiency
	var load_tick: bool = accumulated >= threshold
	var timer_elapsed_after: float = 0.0 if load_tick else accumulated
	return {"load_tick": load_tick, "timer_elapsed_after": timer_elapsed_after}

static func source_payload_loader_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float, load_tick: bool, rotdeg_value: float, block_rotate: bool, item_order: Array, liquid_names_by_id: Array, front: Dictionary, move_payload_result: bool, base_power_use: float) -> Dictionary:
	# The updateTile advance (N2231): PayloadLoaderBuild.updateTile()
	# (PayloadLoader.java:148-220), `public void updateTile(){`, on
	# `public class PayloadLoader extends PayloadBlock{` (PayloadLoader.java:19) /
	# `public class PayloadLoaderBuild extends PayloadBlockBuild<BuildPayload>{` (PayloadLoader.java:86) /
	# `public class PayloadBlockBuild<T extends Payload> extends Building{` (PayloadBlock.java:91).
	# Class fields: `public float loadTime = 2f;` (PayloadLoader.java:22),
	# `public int itemsLoaded = 8;` (PayloadLoader.java:23),
	# `public float liquidsLoaded = 40f;` (PayloadLoader.java:24),
	# `public int maxBlockSize = 3;` (PayloadLoader.java:25),
	# `public float maxPowerConsumption = 40f;` (PayloadLoader.java:26),
	# `public float payloadSpeed = 0.7f, payloadRotateSpeed = 5f;` (PayloadBlock.java:18).
	# Ctor: `hasItems = true;` / `hasLiquids = true;` / `rotate = true;` (PayloadLoader.java:36-45).
	# Build fields: `public boolean exporting = false;` (PayloadLoader.java:87),
	# `public @Nullable T payload;` (PayloadBlock.java:92),
	# `public Vec2 payVector = new Vec2();` (PayloadBlock.java:94),
	# `public float payRotation;` (PayloadBlock.java:95, default 0f).
	# Java order, step by step. `super.updateTile();` (PayloadLoader.java:149) is the
	# payload.update (PayloadBlock.java:158-162) -- skipped, no live payload entity.
	# `if(shouldExport()){` / `moveOutPayload();` (PayloadLoader.java:150-151)
	# `}else if(moveInPayload()){` (PayloadLoader.java:152) then the load branches.
	# shouldExport (PayloadLoader.java:227-233): `public boolean shouldExport(){` with
	# `return payload != null && (` then `exporting ||` then
	# `(payload.block().hasLiquids && liquids.currentAmount() >= 0.1f && payload.build.liquids.currentAmount() >= payload.block().liquidCapacity - 0.001f) ||` then
	# `(payload.block().hasItems && items.any() && payload.block().separateItemCapacity && content.items().contains(i -> (payload.build.items.get(i) >= payload.block().itemCapacity) && items.has(i))) ||` then
	# `(hasBattery() && payload.build.power.status >= 0.999999999f));` -- evaluated on the
	# tick-start state, before moveIn/moveOut. `public boolean hasBattery(){` with
	# `return payload != null && payload.block().consPower != null && payload.block().consPower.buffered;` (PayloadLoader.java:235-237).
	# `public boolean separateItemCapacity = false;` (Block.java:73, the default; the
	# payload contract carries the payload block's own value).
	# moveInPayload (PayloadBlock.java:181-197): `public boolean moveInPayload(){` with
	# `return moveInPayload(true);` (PayloadBlock.java:182), then
	# `public boolean moveInPayload(boolean rotate){` with
	# `if(payload == null) return false;` / `updatePayload();` (a no-op here: `payload.set(x + payVector.x, y + payVector.y, payRotation);`
	# sets the live payload entity position and the port has none; payVector/payRotation ARE the record)
	# / `if(rotate){` /
	# `payRotation = Angles.moveToward(payRotation, block.rotate ? rotdeg() : 90f, payloadRotateSpeed * delta());` /
	# `payVector.approach(Vec2.ZERO, payloadSpeed * delta());` / `return hasArrived();`.
	# PayloadLoader DOES rotate (`rotate = true;`, PayloadLoader.java:45 -- the scope's
	# no-rotate claim was wrong, caught by the RED grep), so the moveIn target is
	# rotdeg(); block_rotate arrives as an explicit param (driver passes true) so the
	# Java branch stays visible. `public boolean hasArrived(){` with
	# `return payVector.isZero(0.01f);` (PayloadBlock.java:242-244), and Vec2.isZero is
	# `return len2() < margin;` (arc Vec2.java:679-681) -- the margin compares against
	# the SQUARED length, so arrival is len2 < 0.01, not len < 0.01.
	# moveOutPayload (PayloadBlock.java:199-226): `public void moveOutPayload(){` with
	# `Vec2 dest = Tmp.v1.trns(rotdeg(), size * tilesize/2f);` /
	# `payRotation = Angles.moveToward(payRotation, rotdeg(), payloadRotateSpeed * delta());` /
	# `payVector.approach(dest, payloadSpeed * delta());` / `Building front = front();` /
	# `boolean canDump = front == null || !front.tile.solid();` /
	# `boolean canMove = front != null && (front.block.outputsPayload || front.block.acceptsPayload);` /
	# `if(canDump && !canMove){` /
	# `pushOutput(payload, 1f - (payVector.dst(dest) / (size * tilesize / 2f)));` /
	# `if(payVector.within(dest, 0.001f)){` (Position.within is
	# `return Mathf.dst2(getX(), getY(), x, y) < dst*dst;`, arc Position.java:44-46, so
	# arrival is dst2 < 0.001^2) /
	# `payVector.clamp(-size * tilesize / 2f, -size * tilesize / 2f, size * tilesize / 2f, size * tilesize / 2f);` /
	# `if(canMove){` / `if(movePayload(payload)){` / `payload = null;` /
	# `}else if(canDump){` / `dumpPayload();` -- the WHOLE moveOut branch REUSES the
	# ported SourceBlockProducerMoveOutPayloadState.move_out_payload_state helper
	# through a preload (the N2224 cross-driver precedent): its signature matches
	# this call exactly (same PayloadBlock.moveOutPayload, generic params), it
	# already implements dest / rotation / approach / canDump / canMove / push
	# fraction / arrival / clamp / movePayload / dumpPayload, and the moveIn
	# approach reuses its source_vec2_approach (the arc Vec2.approach formula).
	# `public @Nullable Building front(){` with `int trns = block.size/2 + 1;` and
	# `return nearby(Geometry.d4(rotation).x * trns, Geometry.d4(rotation).y * trns);` (BuildingComp.java:550-553);
	# the front snapshot arrives as an explicit param (driver passes no-front defaults).
	# `public static final int tilesize = 8;` (Vars.java:135).
	# Load items (PayloadLoader.java:154-177): `if(payload.block().hasItems && items.any()){` with
	# `boolean acceptedAny = true;` then
	# `if(efficiency > 0.01f && timer(timerLoad, loadTime / efficiency)){` (the timer
	# cadence is live since N2319 -- the frame-local Interval-equivalent pure
	# source_payload_loader_load_timer_state computes load_tick from the folded
	# efficiency and the driver passes it in) with `acceptedAny = false;` then
	# `for(int j = 0; j < itemsLoaded && items.any(); j++){` then
	# `for(int i = 0; i < items.length(); i++){` (content-id order, the N2225
	# item_names_by_id precedent) then `if(items.get(i) > 0){` then
	# `Item item = content.item(i);` then `if(payload.build.acceptItem(payload.build, item)){` then
	# `payload.build.handleItem(payload.build, item);` / `items.remove(item, 1);` /
	# `acceptedAny = true;` then
	# `}else if(payload.block().separateItemCapacity || payload.block().consumesItem(item)){` with
	# `exporting = true;` then after the loop `if(!acceptedAny){` with `exporting = true;`.
	# `public boolean any(){` with `return total > 0;` (ItemModule.java:178-180).
	# acceptItem: the DEFAULT is `return block.consumesItem(item) && items.get(item) < getMaximumAccepted(item);`
	# (BuildingComp.java:864-866, `public boolean acceptItem(Building source, Item item){`) with
	# `public int getMaximumAccepted(Item item){` / `return block.itemCapacity;` (BuildingComp.java:781-783) --
	# NOT the items.total() gate the scope suggested; `public boolean consumesItem(Item item){` with
	# `return itemFilter[item.id];` (Block.java:774-776). Storage payloads use the open rule
	# `return linkedCore != null ? linkedCore.acceptItem(source, item) : items.get(item) < getMaximumAccepted(item);`
	# (StorageBlock.java:54-56), so the payload contract carries an explicit
	# accept_item_open flag. `public void handleItem(Building source, Item item){` with
	# `items.add(item, 1);` (BuildingComp.java:860-862).
	# Load liquids (PayloadLoader.java:179-196):
	# `if(payload.block().hasLiquids && liquids.currentAmount() >= 0.001f){` with
	# `Liquid liq = liquids.current();` / `float total = liquids.currentAmount();` /
	# `float flow = Math.min(Math.min(liquidsLoaded * edelta(), payload.block().liquidCapacity - payload.build.liquids.get(liq)), total);` /
	# `if(payload.build.acceptLiquid(payload.build, liq)){` /
	# `if(!(payload.block() instanceof LiquidVoid)){` / `payload.build.liquids.add(liq, flow);` /
	# `liquids.remove(liq, flow);` (the remove runs on accept even for a LiquidVoid --
	# it sits OUTSIDE the instanceof check) else `exporting = true;`.
	# `public float currentAmount(){` with `return liquids[current.id];` (LiquidModule.java:98-100);
	# `public float get(Liquid liquid){` with `return liquids[liquid.id];` (LiquidModule.java:102-104);
	# `public void add(Liquid liquid, float amount){` with `liquids[liquid.id] += amount;` and
	# `current = liquid;` (LiquidModule.java:110-114);
	# `public void remove(Liquid liquid, float amount){` with
	# `add(liquid, Math.max(-amount, -liquids[liquid.id]));` (LiquidModule.java:126-129, capped
	# removal -- the shared SourceLiquidModuleState helpers implement it). The default
	# acceptLiquid is `public boolean acceptLiquid(Building source, Liquid liquid){` with
	# `return block.hasLiquids && block.consumesLiquid(liquid);` (BuildingComp.java:868-870,
	# `public boolean consumesLiquid(Liquid liq){`, Block.java:778); liquid-container
	# payloads use the LiquidRouter rule
	# `return (liquids.current() == liquid || liquids.currentAmount() < 0.2f);` (LiquidRouter.java:41-43),
	# so the contract carries accept_liquid_open; a LiquidVoid payload
	# (`public class LiquidVoid extends Block{`, LiquidVoid.java:8) accepts (enabled)
	# but never stores.
	# Load power (PayloadLoader.java:198-217): `if(hasBattery()){` with
	# `float powerInput = power.status * (basePowerUse + maxPowerConsumption);` /
	# `float availableInput = Math.max(powerInput - basePowerUse, 0f);` /
	# `float cap = payload.block().consPower.capacity;` /
	# `payload.build.power.status += availableInput / cap * edelta();` /
	# `if(payload.build.power.status >= 1f){` with `exporting = true;` and
	# `payload.build.power.status = Mathf.clamp(payload.build.power.status);` (clamp 0..1).
	# `basePowerUse = consPower != null ? consPower.usage : 0f;` (PayloadLoader.java:79) is
	# 2f from the def (`consumePower(2f);`, `size = 3;`, Blocks.java:6682-6689).
	# power.status in the port is the stamped frame value (N2162, default 1.0 when
	# unstamped), distinct from the folded efficiency the edelta uses.
	# delta() is `return Time.delta * timeScale;` (BuildingComp.java:1922-1924) and
	# edelta() is `return efficiency * delta();` (BuildingComp.java:1927-1929);
	# source_delta is Time.delta in ticks (seconds * 60 through game_source_delta,
	# arc Time.java:26), never raw seconds; timeScale reads
	# `private transient float timeScale = 1f, timeScaleDuration;` (BuildingComp.java:98);
	# efficiency is `transient float efficiency;` (BuildingComp.java:85), default 0.0.
	# `public float rotdeg(){` with `return rotation * 90;` (BuildingComp.java:582-584).
	# The advance runs after consumption, like Java's Building.update()
	# (BuildingComp.java:2274-2277, `updateConsumption();` then
	# `if(enabled || !block.noUpdateDisabled){` / `updateTile();`), and WITHOUT an
	# enabled guard: PayloadLoader has `public boolean noUpdateDisabled = false;`
	# (Block.java:170, the default), so Java runs updateTile() even when disabled
	# (updateConsumption folds efficiency to 0, so the edelta loads stall while
	# moveIn/moveOut still run on delta). When the gate is false updateConsumption
	# forces efficiency to zero (BuildingComp.java:1960,
	# `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`).
	# The payload dict contract (this slice defines it; unify is a later slice):
	# block flags block_has_items / block_has_liquids / block_separate_item_capacity /
	# block_item_capacity / block_liquid_capacity / block_is_liquid_void /
	# block_consumes_items (Array of item names) / block_consumes_liquids (Array of
	# liquid names) / block_cons_power_buffered / block_cons_power_capacity,
	# accept_item_open / accept_liquid_open (the StorageBlock / LiquidRouter rules),
	# build stores build_items {name: int} / build_liquids {name: float} /
	# build_current_liquid (String, "") / build_power_status (float, 0.0). The
	# loader's own liquids stay in the LiquidModule dict shape (the Fracker
	# precedent): the advance mutates that store in place through the shared module
	# helpers, like the Fracker advance, so the sprite meta store stays in sync.
	# Returns the advanced frame values plus the pure amounts (liquid_flow /
	# power_charged / items_loaded / pushed_output_fraction); the driver writes
	# the frame keys back. The payload is set by handlePayload
	# (`this.payload = (T)payload;`, PayloadBlock.java:122) and cleared by takePayload
	# (`payload = null;`, PayloadBlock.java:147); the live fill is live since N2278
	# (handlePayload intake through the frame incoming_payload push), so a live
	# loader with a pushed payload runs the advance (payload null -> no moveIn, no loads).
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var power_status: float = float(frame.get("power_status", 1.0))
	var exporting: bool = bool(frame.get("exporting", false))
	var pay_vector_value: Variant = frame.get("pay_vector", {})
	var pay_vector: Dictionary = {"x": 0.0, "y": 0.0}
	if pay_vector_value is Dictionary:
		pay_vector = {"x": float(pay_vector_value.get("x", 0.0)), "y": float(pay_vector_value.get("y", 0.0))}
	var pay_rotation: float = float(frame.get("pay_rotation", 0.0))
	var items: Dictionary = (frame.get("items", {}) as Dictionary).duplicate(true)
	var liquids: Dictionary = frame.get("liquids", {})
	var payload_value: Variant = frame.get("payload", null)
	var payload: Variant = null
	if payload_value is Dictionary:
		payload = (payload_value as Dictionary).duplicate(true)
	var has_payload: bool = payload != null
	var delta: float = source_delta * time_scale
	var edelta: float = efficiency * delta
	var loader_current_id: int = -1
	var loader_current_amount: float = 0.0
	if liquids.has("liquids") and liquids.has("current"):
		var liquids_array: Array = liquids.get("liquids", [])
		var current_id: int = int(liquids.get("current", -1))
		if current_id >= 0 and current_id < liquids_array.size():
			loader_current_id = current_id
			loader_current_amount = float(source_liquid_module_state.source_current_amount_state(liquids).get("amount", 0.0))
	var should_export: bool = false
	var has_battery: bool = false
	if has_payload:
		has_battery = bool(payload.get("block_cons_power_buffered", false))
		var payload_build_liquids: Dictionary = payload.get("build_liquids", {})
		var payload_current_liquid: String = str(payload.get("build_current_liquid", ""))
		var payload_current_amount: float = 0.0
		if payload_current_liquid != "":
			payload_current_amount = float(payload_build_liquids.get(payload_current_liquid, 0.0))
		var separate_full: bool = false
		if bool(payload.get("block_has_items", false)) and inventory.items_total(items) > 0 and bool(payload.get("block_separate_item_capacity", false)):
			var payload_build_items: Dictionary = payload.get("build_items", {})
			var payload_item_capacity: int = int(payload.get("block_item_capacity", 0))
			for item_name in item_order:
				var item_key: String = str(item_name)
				if int(payload_build_items.get(item_key, 0)) >= payload_item_capacity and int(items.get(item_key, 0)) > 0:
					separate_full = true
					break
		should_export = exporting or (bool(payload.get("block_has_liquids", false)) and loader_current_amount >= 0.1 and payload_current_amount >= float(payload.get("block_liquid_capacity", 0.0)) - 0.001) or separate_full or (has_battery and float(payload.get("build_power_status", 0.0)) >= 0.999999999)
	var has_arrived: bool = false
	var payload_moved: bool = false
	var payload_dumped: bool = false
	var pushed_output_fraction: Variant = null
	if has_payload and should_export:
		var moved_out: Dictionary = source_move_out_payload_state.move_out_payload_state(true, float(pay_vector.get("x", 0.0)), float(pay_vector.get("y", 0.0)), pay_rotation, rotdeg_value, float(SOURCE_PAYLOAD_LOADER_SIZE), source_world_defaults.TILESIZE, SOURCE_PAYLOAD_LOADER_PAYLOAD_ROTATE_SPEED, SOURCE_PAYLOAD_LOADER_PAYLOAD_SPEED, delta, bool(front.get("present", false)), bool(front.get("solid", false)), bool(front.get("outputs_payload", false)), bool(front.get("accepts_payload", false)), move_payload_result)
		pay_vector = moved_out.get("pay_vector_after", pay_vector)
		pay_rotation = float(moved_out.get("pay_rotation_after", pay_rotation))
		pushed_output_fraction = moved_out.get("pushed_output_fraction", null)
		payload_moved = bool(moved_out.get("move_payload_called", false)) and not bool(moved_out.get("payload_after_present", true))
		payload_dumped = bool(moved_out.get("dump_payload_called", false))
		if not bool(moved_out.get("payload_after_present", true)):
			payload = null
	elif has_payload:
		var target_rotation: float = rotdeg_value if block_rotate else 90.0
		pay_rotation = source_math_state.source_angles_move_toward(pay_rotation, target_rotation, SOURCE_PAYLOAD_LOADER_PAYLOAD_ROTATE_SPEED * delta)
		pay_vector = source_move_out_payload_state.source_vec2_approach(float(pay_vector.get("x", 0.0)), float(pay_vector.get("y", 0.0)), 0.0, 0.0, SOURCE_PAYLOAD_LOADER_PAYLOAD_SPEED * delta)
		var pay_len2: float = float(pay_vector.get("x", 0.0)) * float(pay_vector.get("x", 0.0)) + float(pay_vector.get("y", 0.0)) * float(pay_vector.get("y", 0.0))
		has_arrived = pay_len2 < 0.01
	var items_loaded: int = 0
	var liquid_flow: float = 0.0
	var power_charged: float = 0.0
	if has_arrived and payload != null:
		if bool(payload.get("block_has_items", false)) and inventory.items_total(items) > 0:
			var accepted_any: bool = true
			if efficiency > 0.01 and load_tick:
				accepted_any = false
				var payload_build_items: Dictionary = payload.get("build_items", {})
				var payload_item_capacity: int = int(payload.get("block_item_capacity", 0))
				var payload_consumes_items: Array = payload.get("block_consumes_items", [])
				var accept_item_open: bool = bool(payload.get("accept_item_open", false))
				var separate_capacity: bool = bool(payload.get("block_separate_item_capacity", false))
				for _j in range(SOURCE_PAYLOAD_LOADER_ITEMS_LOADED):
					if inventory.items_total(items) <= 0:
						break
					for item_name in item_order:
						var item_key: String = str(item_name)
						if int(items.get(item_key, 0)) > 0:
							var accepts_item: bool = false
							if accept_item_open:
								accepts_item = int(payload_build_items.get(item_key, 0)) < payload_item_capacity
							else:
								accepts_item = payload_consumes_items.has(item_key) and int(payload_build_items.get(item_key, 0)) < payload_item_capacity
							if accepts_item:
								var handled: Dictionary = inventory.add_item_state(payload_build_items, item_key, 1)
								payload_build_items = handled.get(inventory.SOURCE_DRILL_INVENTORY_DRILL_ITEMS_KEY, payload_build_items)
								var removed: Dictionary = inventory.remove_item_state(items, item_key, 1)
								items = removed.get(inventory.SOURCE_DRILL_INVENTORY_DRILL_ITEMS_KEY, items)
								accepted_any = true
								items_loaded += 1
								break
							elif separate_capacity or payload_consumes_items.has(item_key):
								exporting = true
								break
				payload["build_items"] = payload_build_items
			if not accepted_any:
				exporting = true
		if bool(payload.get("block_has_liquids", false)) and loader_current_amount >= 0.001:
			var liquid_id: int = loader_current_id
			var liquid_name: String = ""
			if liquid_id >= 0 and liquid_id < liquid_names_by_id.size():
				liquid_name = str(liquid_names_by_id[liquid_id])
			if liquid_name != "":
				var total: float = loader_current_amount
				var payload_build_liquids: Dictionary = payload.get("build_liquids", {})
				var flow: float = minf(minf(SOURCE_PAYLOAD_LOADER_LIQUIDS_LOADED * edelta, float(payload.get("block_liquid_capacity", 0.0)) - float(payload_build_liquids.get(liquid_name, 0.0))), total)
				var accepts_liquid: bool = false
				if bool(payload.get("block_is_liquid_void", false)):
					accepts_liquid = true
				elif bool(payload.get("accept_liquid_open", false)):
					var payload_current_liquid: String = str(payload.get("build_current_liquid", ""))
					var payload_current_amount: float = 0.0
					if payload_current_liquid != "":
						payload_current_amount = float(payload_build_liquids.get(payload_current_liquid, 0.0))
					accepts_liquid = payload_current_liquid == liquid_name or payload_current_amount < 0.2
				else:
					var payload_consumes_liquids: Array = payload.get("block_consumes_liquids", [])
					accepts_liquid = bool(payload.get("block_has_liquids", false)) and payload_consumes_liquids.has(liquid_name)
				if accepts_liquid:
					if not bool(payload.get("block_is_liquid_void", false)):
						payload_build_liquids[liquid_name] = float(payload_build_liquids.get(liquid_name, 0.0)) + flow
						payload["build_liquids"] = payload_build_liquids
						payload["build_current_liquid"] = liquid_name
					var cache_sums: Array = []
					cache_sums.resize(int((liquids.get("liquids", []) as Array).size()))
					cache_sums.fill(0.0)
					source_liquid_module_state.source_remove_state(liquids, liquid_id, flow, cache_sums)
					liquid_flow = flow
				else:
					exporting = true
		if has_battery:
			var power_input: float = power_status * (base_power_use + SOURCE_PAYLOAD_LOADER_MAX_POWER_CONSUMPTION)
			var available_input: float = maxf(power_input - base_power_use, 0.0)
			var cap: float = float(payload.get("block_cons_power_capacity", 0.0))
			var status_before: float = float(payload.get("build_power_status", 0.0))
			var status_after: float = status_before + available_input / cap * edelta
			power_charged = status_after - status_before
			if status_after >= 1.0:
				exporting = true
				status_after = clampf(status_after, 0.0, 1.0)
			payload["build_power_status"] = status_after
	return {"should_export": should_export, "has_arrived": has_arrived, "exporting": exporting, "pay_vector": pay_vector, "pay_rotation": pay_rotation, "items": items, "liquids": liquids, "payload": payload, "payload_moved": payload_moved, "payload_dumped": payload_dumped, "liquid_flow": liquid_flow, "power_charged": power_charged, "items_loaded": items_loaded, "pushed_output_fraction": pushed_output_fraction}

static func source_payload_loader_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a payload-loader does not take the early return. The load gate follows the folded efficiency (PayloadLoader.java:157, `if(efficiency > 0.01f && timer(timerLoad, loadTime / efficiency)){`), with the battery charge (PayloadLoader.java:202, `float powerInput = power.status * (basePowerUse + maxPowerConsumption);`) and the shouldConsume default (BuildingComp.java:755, `public boolean shouldConsume(){`) and the shouldConsume override (PayloadLoader.java:241, `return payload != null;`).
	# Documented limits: (1) power-only first pass -- the dynamic power usage value is live (N2270): the pure source_payload_loader_dynamic_power_usage_state function prices the consumePowerDynamic lambda (PayloadLoader.java:80; `public float maxPowerConsumption = 40f;` (PayloadLoader.java:26) + basePowerUse when hasBattery() && !exporting, else basePowerUse, 0f with no payload) and the driver stamps frame power_usage every tick at fold time (before the advance call, so exporting is the previous tick's value), so the folded efficiency is the min over the *modeled* consumers (power only). Graph wiring defers: the port graph builds demand from the static catalog consPower, so the per-building dynamic value waits for a distribution-runtime slice that reads frame power_usage (the N2232 Unloader last_output_power precedent). (2) shouldConsume gate live (N2208) -- PayloadLoaderBuild overrides shouldConsume() to return payload != null (PayloadLoader.java:240-242, `return payload != null;`); the pure gate (source_payload_loader_should_consume_state) feeds should_consume to the machinery from the frame payload key (null by default); the live payload fill is live since N2278 (handlePayload intake through the frame incoming_payload push). (3) updateTile advance live (N2231) -- shouldExport / moveInPayload / moveOutPayload (reused helper) / load items+liquids / battery charge (PayloadLoader.java:148-220) run every tick after the consumption fold through the pure source_payload_loader_update_tile_advance_state function; the load timer cadence live (N2319) -- the frame-local Interval-equivalent pure source_payload_loader_load_timer_state computes load_tick from the folded efficiency (PayloadLoader.java:157, threshold loadTime / efficiency -- 2f ticks at full efficiency, never divided by timeScale) and the driver passes it into the advance after the consumption fold; first-fire deviation: Java fires nearly at once after placement, the frame clock delays the first fire by a full 2f/efficiency interval; the movePayload/dumpPayload application and the live front gather defer (no front infra yet); the N2231 proof carries the load/export/battery keys. (4) acceptPayload rows live (N2295) -- the pure source_payload_loader_accept_payload_state function ports acceptPayload (PayloadLoader.java:90-101): the base gate (super.acceptPayload returns this.payload == null, PayloadBlock.java:116-118) AND payload.fits(maxBlockSize) AND the BuildPayload instanceof AND one of the item-container / liquid-container / battery branches; the driver stamps frame accepts_payload every tick from the frame offered_payload descriptor when present (default: no offer -> accepts false). No live source pushes an offer yet (the front moveOutPayload handoff and the unit drop wait for their own slices); acceptItem/acceptLiquid have no Loader overrides (the base Building ones apply), so they are out of scope. (5) live payload fill live (N2278) -- handlePayload intake (PayloadBlock.java:121-127 + the Loader override PayloadLoader.java:104-107) applies the frame incoming_payload push before the fold when the full acceptPayload gate accepts it (N2315 -- the tick computes the N2295 verdict from the incoming dict itself; a refused push is dropped, still consumed); takePayload is pure + tested only (the unit-pickup path waits for live units); updatePayload() live positioning defers (no live payload entity); the incoming push has no live source yet (the front moveOutPayload handoff and the unit drop wait for their own slices). (6) Intake full-gate wiring live (N2315) -- the tick computes the N2295 acceptPayload verdict from the incoming dict itself (the incoming dict IS the N2295 descriptor; a push without block_size gets the rejecting default maxBlockSize + 1 from the intake, the N2308 missing-block_size precedent, and a non-dict push rejects) and applies the push only when it accepts; the offered-payload verdict still governs frame["accepts_payload"] (when both an offer and a push are present, the offer verdict governs the frame key and the intake verdict decides the push alone).
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

@warning_ignore("unused_parameter")
static func source_payload_loader_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the payload-loader tick wiring every
	# tick (PayloadLoaderBuild.updateTile(), PayloadLoader.java:143,
	# gates on the load gate (PayloadLoader.java:157, `if(efficiency > 0.01f && timer(timerLoad, loadTime / efficiency)){`) and the battery charge (PayloadLoader.java:202, `float powerInput = power.status * (basePowerUse + maxPowerConsumption);`), so the load gate follows the folded efficiency; no placed-buildings driver ticks PayloadLoader blocks, so this driver is the placed-payload-loader tick): each placed PayloadLoader build gets its frame keys refreshed from the live rules, so the frame's cheating flag tracks team.rules().cheat and the consumption machinery skips consumption for a cheating team. The frame is bound at placement; a sprite that somehow lacks one gets it bound here instead of crashing the loop.
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
		if not _is_payload_loader_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_payload_loader_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_payload_loader_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The frame carries the Building.liquids LiquidModule
		# (frame["liquids"]): the live store lives on the
		# sprite meta (source_building_liquids, initialized
		# at placement), so the driver syncs the reference
		# into the frame each tick and the pure advance reads
		# the current liquid / amount from it (the Fracker
		# pattern). frame["items"] is frame-owned (no sprite
		# meta store); nothing fills it live yet.
		frame["liquids"] = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
		# The acceptPayload verdict (N2295, PayloadLoader.java:90-101): acceptPayload is the consult gate the
		# source calls before pushing (movePayload, BuildingComp.java:819-829), so the driver stamps
		# frame["accepts_payload"] BEFORE the N2278 intake below, from the frame-supplied offered-payload
		# descriptor (frame["offered_payload"], the N2295 descriptor contract: is_build_payload / block_size /
		# has_items / unloadable / item_capacity / has_liquids / liquid_capacity / has_cons_power /
		# cons_power_buffered) and the frame payload null-ness at stamp time. No payload offered means no
		# verdict to give: accepts false. No live source pushes an offer yet (the front moveOutPayload handoff
		# and the unit drop wait for their own slices), so a live loader stamps false until then; the intake
		# consults the full gate since N2315 (the pure's has_payload term subsumes the old payload-null
		# guard; acceptPayload returns `this.payload == null`, PayloadBlock.java:117).
		var offered_payload: Variant = frame.get("offered_payload", null)
		if offered_payload is Dictionary:
			var offered_verdict: Dictionary = source_payload_loader_accept_payload_state(offered_payload, frame.get("payload", null) != null)
			frame["accepts_payload"] = bool(offered_verdict.get("accepts", false))
		else:
			frame["accepts_payload"] = false
		# The live payload fill (N2278, handlePayload, PayloadBlock.java:121-127 + the Loader override
		# PayloadLoader.java:104-107): runs BEFORE the consumption fold and the advance call -- Java
		# handlePayload is an external call (the source's moveOutPayload or a unit drop), so it lands
		# before the next tick starts, and the fresh payload consumes on this same tick. The intake reads
		# the frame inputs incoming_payload (the pushed payload dict, or null) / incoming_source_pos
		# ({x, y} world position of the source building) / world_pos ({x, y} world position of this
		# loader): no live source pushes them yet (the front moveOutPayload handoff and the unit drop wait
		# for their own slices), and the port has no live world-position model for placed buildings, so
		# both positions arrive as frame inputs (origin_cell is a cell, sprite.position is unset by
		# placement). The intake applies only when the full Loader acceptPayload gate accepts the push
		# (N2315): Java only ever calls handlePayload after acceptPayload returns true -- the pusher
		# checks first (BuildingComp.java:822-824, `if(next != null && next.build != null && next.build.team == team && next.build.acceptPayload(self(), todump)){` then `next.build.handlePayload(self(), todump);`, and the dumpPayload twin at :844-845, `if(other.acceptPayload(self(), todump)){` then `other.handlePayload(self(), todump);`, and the unit drop at InputHandler.java:667-669, `if(build.acceptPayload(build, unitPay)){` then `build.handlePayload(build, unitPay);`), so the tick computes the N2295 verdict from the incoming dict itself (source_payload_loader_accept_payload_state) and drops a refused push. The push is consumed either way (the N2278 drop; the source keeps its own payload in its own frame and re-pushes on its next moveOutPayload attempt). The incoming dict IS the N2295 descriptor (is_build_payload / block_size / has_items / unloadable / item_capacity / has_liquids / liquid_capacity / has_cons_power / cons_power_buffered); a push without block_size gets the rejecting default (maxBlockSize + 1) from the intake (the N2308 missing-block_size precedent -- the pure defaults block_size to 0, which fits) and a non-dict push rejects too. The offered-payload verdict still governs frame["accepts_payload"] (stamped above, from the offered descriptor): when both an offer and a push are present, the offer verdict governs the frame key and the intake verdict decides the push alone -- the intake never overwrites frame["accepts_payload"]. The rotation reads the incoming dict's rotation key (default 0.0, the Payload.java:55-57
		# default); the size is the driver const (3, the only def) and tilesize is SourceWorldDefaults.
		var incoming_payload: Variant = frame.get("incoming_payload", null)
		if incoming_payload != null:
			# N2315: the intake verdict comes from the N2295
			# pure, computed from the incoming dict itself.
			# The incoming dict IS the N2295 descriptor, so
			# it is passed through (duplicated, so the pure
			# never mutates the frame push); the pure
			# defaults every missing key to the rejecting
			# value EXCEPT block_size, which defaults to 0
			# (fits) -- so a push without block_size gets
			# the rejecting default (maxBlockSize + 1) here,
			# the N2308 missing-block_size precedent. A
			# non-dict push carries no descriptor and
			# rejects too. The pure's has_payload term
			# subsumes the old frame null check, so the
			# verdict IS the guard now; the push is consumed
			# either way (below).
			var intake_accepts: bool = false
			if incoming_payload is Dictionary:
				var incoming_descriptor: Dictionary = incoming_payload.duplicate()
				if not incoming_descriptor.has("block_size"):
					incoming_descriptor["block_size"] = SOURCE_PAYLOAD_LOADER_MAX_BLOCK_SIZE + 1
				intake_accepts = bool(source_payload_loader_accept_payload_state(incoming_descriptor, frame.get("payload", null) != null).get("accepts", false))
			if intake_accepts:
				var incoming_source_value: Variant = frame.get("incoming_source_pos", {})
				var incoming_source: Dictionary = {"x": 0.0, "y": 0.0}
				if incoming_source_value is Dictionary:
					incoming_source = {"x": float(incoming_source_value.get("x", 0.0)), "y": float(incoming_source_value.get("y", 0.0))}
				var world_pos_value: Variant = frame.get("world_pos", {})
				var world_pos: Dictionary = {"x": 0.0, "y": 0.0}
				if world_pos_value is Dictionary:
					world_pos = {"x": float(world_pos_value.get("x", 0.0)), "y": float(world_pos_value.get("y", 0.0))}
				var incoming_rotation: float = 0.0
				if incoming_payload is Dictionary:
					incoming_rotation = float(incoming_payload.get("rotation", 0.0))
				var handled: Dictionary = source_payload_loader_handle_payload_state(incoming_payload, float(incoming_source.get("x", 0.0)), float(incoming_source.get("y", 0.0)), float(world_pos.get("x", 0.0)), float(world_pos.get("y", 0.0)), incoming_rotation, SOURCE_PAYLOAD_LOADER_SIZE, source_world_defaults.TILESIZE)
				frame["payload"] = handled["payload"]
				frame["pay_vector"] = handled["pay_vector"]
				frame["pay_rotation"] = handled["pay_rotation"]
				frame["exporting"] = handled["exporting"]
			frame["incoming_payload"] = null
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a payload-loader with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the load gate (PayloadLoader.java:157)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a payload-loader does not take the early return. A payload-loader with no power consumer is untouched: the tick models no other consumers yet (the dynamic usage value is live since N2270 -- frame power_usage stamped above at fold time -- and only the graph wiring waits for its own slice), and PayloadLoaderBuild overrides shouldConsume() to return payload != null (PayloadLoader.java:240-242) -- N2208 feeds the live gate to the machinery (the pure gate is source_payload_loader_should_consume_state, fed the frame; the gate has no enabled term, Java returns the bare null check, and the outer guard below already runs the machinery only when enabled); the N2162 RED decision is resolved. productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		# The dynamic power usage value (N2270, PayloadLoader.java:80): stamped at fold time, BEFORE the consumption fold and BEFORE the advance call below, so the usage reflects the fold-time state and `exporting` is the previous tick's value -- matching the Java graph query of the live usage (ConsumePowerDynamic.requestedPower returns `return usage.get(entity);`, ConsumePowerDynamic.java:24-25). The stamp sits OUTSIDE the enabled/cheating guard: the lambda reads only shouldConsume (payload != null, PayloadLoader.java:240-242 -- no enabled term) / hasBattery (`return payload != null && payload.block().consPower != null && payload.block().consPower.buffered;`, PayloadLoader.java:235-237) / exporting, so a disabled loader with a payload still prices its draw. The base reads the catalog consumePower (2.0 for payload-loader, `consumePower(2f);`, Blocks.java:6686) with the driver const as fallback; the max is the class constant (`public float maxPowerConsumption = 40f;`, PayloadLoader.java:26); has_battery reads the payload dict's block_cons_power_buffered flag (the N2231 contract). The graph does not read this value yet (graph wiring defers, the N2232 Unloader last_output_power precedent).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer:
			var usage_gate: Dictionary = source_payload_loader_should_consume_state(frame)
			var usage_payload: Variant = frame.get("payload", null)
			var usage_has_battery: bool = usage_payload is Dictionary and bool(usage_payload.get("block_cons_power_buffered", false))
			var usage_base: float = float(block.properties.get("consumePower", SOURCE_PAYLOAD_LOADER_BASE_POWER_USE))
			var usage_state: Dictionary = source_payload_loader_dynamic_power_usage_state(bool(usage_gate.get("should_consume", false)), usage_has_battery, bool(frame.get("exporting", false)), usage_base, SOURCE_PAYLOAD_LOADER_MAX_POWER_CONSUMPTION)
			frame["power_usage"] = usage_state["usage"]
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var gate: Dictionary = source_payload_loader_should_consume_state(frame)
			var should_consume: bool = bool(gate.get("should_consume", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_payload_loader_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		# The updateTile advance (N2231, PayloadLoader.java:148-220): runs after the
		# consumption fold -- the Java order, `updateConsumption();` then
		# `if(enabled || !block.noUpdateDisabled){` / `updateTile();` (BuildingComp.java:2274-2277) --
		# and WITHOUT an enabled guard: PayloadLoader has
		# `public boolean noUpdateDisabled = false;` (Block.java:170, the default), so
		# Java runs updateTile() even when disabled (updateConsumption folds efficiency
		# to 0, so the edelta loads stall while moveIn/moveOut still run on delta).
		# The driver passes the live load_tick (N2319 -- the load timer cadence is live:
		# the frame-local Interval-equivalent pure computes it from the folded
		# efficiency just below), the live rotdeg from the rotation meta (`public float rotdeg(){`
		# with `return rotation * 90;`, BuildingComp.java:582-584), block_rotate true
		# (the ctor value, PayloadLoader.java:45), the catalog item order
		# (item_names_by_id, the content-id order the load loop scans), the liquid
		# names in content-id order (resolving the LiquidModule current id), and
		# no-front defaults (no live front query yet -- the catalog carries no
		# outputsPayload / acceptsPayload flags). The source delta is Time.delta in
		# ticks: game_source_delta(game, seconds) is seconds * 60 (arc Time.java:26),
		# never raw seconds; timeScale reads live from the sprite meta, default 1.0
		# (BuildingComp.java:98). The pure advance returns the advanced frame values,
		# which the driver writes back; with the N2278 live fill the advance runs
		# live once a payload is pushed in (payload null -> no moveIn, no loads).
		var rotdeg_value: float = float(int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_ROTATION_META_KEY, 0))) * 90.0
		var item_order: Array = source_content_registry_runtime_state.source_item_catalog_state(catalog).get("item_names_by_id", [])
		var liquid_names_by_id: Array = []
		for liquid in catalog.get_many("liquid"):
			liquid_names_by_id.append(liquid.id)
		var front: Dictionary = {"present": false, "solid": false, "outputs_payload": false, "accepts_payload": false}
		var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
		var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
		# N2319: the load timer cadence (PayloadLoader.java:157,
		# `if(efficiency > 0.01f && timer(timerLoad, loadTime / efficiency)){`) -- the
		# frame-local clock (frame["timer_load_elapsed"]) accumulates the tick delta
		# every tick after the consumption fold, and the pure computes load_tick from
		# the FOLDED frame efficiency (the same value the advance gate reads, default
		# 0.0 on a fresh frame) and loadTime 2f (SOURCE_PAYLOAD_LOADER_LOAD_TIME):
		# load_tick = (eff > 0.01) and (elapsed >= loadTime / eff), reset to 0 on
		# fire. The timer sits next to the advance call, outside the enabled guard
		# (PayloadLoader has noUpdateDisabled = false, Block.java:170, so Java runs
		# updateTile even when disabled, BuildingComp.java:2276-2277) -- the clock
		# keeps growing while disabled and a recovered efficiency fires at once, the
		# Java short-circuit order (Time.time advances even while timer() is never
		# called). Java folds efficiency to 0 when disabled (the disabled early
		# return, BuildingComp.java:1955-1957); the port fold skips when disabled and
		# leaves the frame value stale, so the timer and the advance gate read the
		# same stale value until the driver-wide disabled-early-return slice lands --
		# a shared pre-existing gap, not a timer deviation. First-fire deviation:
		# Java fires nearly at once after placement; the frame clock delays the first
		# fire by a full 2f/efficiency interval.
		var load_timer: Dictionary = source_payload_loader_load_timer_state(float(frame.get("timer_load_elapsed", 0.0)), source_delta, time_scale, float(frame.get("efficiency", 0.0)), SOURCE_PAYLOAD_LOADER_LOAD_TIME)
		frame["timer_load_elapsed"] = load_timer.get("timer_elapsed_after", 0.0)
		var load_tick: bool = bool(load_timer.get("load_tick", false))
		var advanced: Dictionary = source_payload_loader_update_tile_advance_state(frame, source_delta, time_scale, load_tick, rotdeg_value, true, item_order, liquid_names_by_id, front, false, SOURCE_PAYLOAD_LOADER_BASE_POWER_USE)
		frame["exporting"] = advanced["exporting"]
		frame["pay_vector"] = advanced["pay_vector"]
		frame["pay_rotation"] = advanced["pay_rotation"]
		frame["items"] = advanced["items"]
		frame["liquids"] = advanced["liquids"]
		frame["payload"] = advanced["payload"]
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
