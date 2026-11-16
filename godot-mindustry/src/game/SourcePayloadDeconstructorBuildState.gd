extends RefCounted
class_name SourcePayloadDeconstructorBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const inventory := preload("res://src/game/SourceDrillInventoryRuntimeState.gd")
const source_building_item_dump_state := preload("res://src/game/SourceBuildingItemDumpState.gd")
const source_building_item_state := preload("res://src/game/SourceBuildingItemState.gd")
const source_content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")

# The PayloadDeconstructor implementation (PayloadDeconstructor.java:17, `public class PayloadDeconstructor extends PayloadBlock{`): deconstructor (consumePower 3f, Blocks.java:6653; size 5, deconstructSpeed 6f, itemCapacity 250, Blocks.java:6649-6656) and small-deconstructor (consumePower 1f, Blocks.java:6644; size 3, deconstructSpeed 3f, itemCapacity 100, Blocks.java:6640-6647). PayloadDeconstructor sets outputsPayload=false, acceptsPayload=true, update=true, solid=true, size=5, hasItems=true, hasPower=true, itemCapacity=100 (PayloadDeconstructor.java:22-38), deconstructSpeed 2.5f class default (PayloadDeconstructor.java:19, `public float deconstructSpeed = 2.5f;`), maxPayloadSize 4 (PayloadDeconstructor.java:18, `public float maxPayloadSize = 4;`), dumpRate 4 (PayloadDeconstructor.java:20). PayloadDeconstructor extends PayloadBlock, NOT a drill or factory, so it cannot reuse an existing frame key; this driver uses its own family frame key ("source_payload_deconstructor_building", the mechanical-pump / beam-drill / mend-projector / overdrive-projector / force-projector / base-shield / regen-projector / constructor / payload-loader / payload-unloader / payload-mass-driver / unit-cargo-loader precedent), and this slice adds the payload-deconstructor key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourcePayloadDeconstructor* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the progress advance (PayloadDeconstructor.java:142, `float shift = edelta() * deconstructSpeed / deconstructing.buildTime();`) with `progress += shift;` follows the folded efficiency.
const SOURCE_PAYLOAD_DECONSTRUCTOR_BUILD_IMPLEMENTATIONS := ["PayloadDeconstructor"]
const SOURCE_PAYLOAD_DECONSTRUCTOR_BUILDING_META_KEY := "source_payload_deconstructor_building"
# deconstructSpeed is per-def (PayloadDeconstructor.java:19,
# `public float deconstructSpeed = 2.5f;`): deconstructor 6f
# (Blocks.java:6655, `deconstructSpeed = 6f;`), small-deconstructor
# 3f (Blocks.java:6646, `deconstructSpeed = 3f;`). The catalog
# parses no deconstructSpeed property, so the driver reads these
# constants (the separator craftTime precedent).
const SOURCE_DECONSTRUCTOR_DECONSTRUCT_SPEED := 6.0
const SOURCE_SMALL_DECONSTRUCTOR_DECONSTRUCT_SPEED := 3.0
const SOURCE_PAYLOAD_DECONSTRUCTOR_CLASS_DECONSTRUCT_SPEED := 2.5
# Payload movement (PayloadBlock.java:18, `public float
# payloadSpeed = 0.7f, payloadRotateSpeed = 5f;`): the
# deconstructor overrides payloadSpeed to 1f
# (PayloadDeconstructor.java:31, `payloadSpeed = 1f;`);
# payloadRotateSpeed stays the class default 5f.
const SOURCE_PAYLOAD_DECONSTRUCTOR_PAYLOAD_SPEED := 1.0
const SOURCE_PAYLOAD_DECONSTRUCTOR_PAYLOAD_ROTATE_SPEED := 5.0
# The block size (PayloadDeconstructor.java:30,
# `size = 5;`): deconstructor 5 (Blocks.java:6654,
# `size = 5;`), small-deconstructor 3 (Blocks.java:6645,
# `size = 3;`). The handlePayload payVector clamp is
# +/-size*tilesize/2 (PayloadBlock.java:123), so the
# deconstructor clamps to +/-20.0 and the
# small-deconstructor to +/-12.0 (tilesize 8,
# Vars.java:135).
const SOURCE_DECONSTRUCTOR_SIZE := 5
const SOURCE_SMALL_DECONSTRUCTOR_SIZE := 3
# The payRotation target (PayloadDeconstructor.java:121,
# `payRotation = Angles.moveToward(payRotation, 90f,
# payloadRotateSpeed * edelta());`), the speedScl lerpDelta rate
# (PayloadDeconstructor.java:167, `speedScl =
# Mathf.lerpDelta(speedScl, canProgress ? 1f : 0f, 0.1f);`), and
# the finish rounding tolerance (PayloadDeconstructor.java:182,
# `if(Mathf.equal(accum[i], 1f, 0.0001f)){`).
const SOURCE_PAYLOAD_DECONSTRUCTOR_PAY_ROTATION_TARGET := 90.0
const SOURCE_PAYLOAD_DECONSTRUCTOR_SPEED_SCL_LERP_RATE := 0.1
const SOURCE_PAYLOAD_DECONSTRUCTOR_ROUNDING_TOLERANCE := 0.0001
# The dump rate (PayloadDeconstructor.java:20,
# `public int dumpRate = 4;`): neither def overrides it
# (no dumpRate in Blocks.java), so both the deconstructor
# and the small-deconstructor run dumpAccumulate 4 times
# per tick (PayloadDeconstructor.java:111-115).
const SOURCE_PAYLOAD_DECONSTRUCTOR_DUMP_RATE := 4
# The max payload size (PayloadDeconstructor.java:18,
# `public float maxPayloadSize = 4;`): acceptPayload
# (PayloadDeconstructor.java:104-106) fits a payload
# whose size() / tilesize <= maxPayloadSize
# (Payload.java:50-52, `return size() / tilesize <= s;`),
# and acceptUnitPayload
# (PayloadDeconstructor.java:92-95) fits a unit whose
# hitSize / tilesize <= maxPayloadSize. A BuildPayload
# is block.size tiles (BuildPayload.java:86-88,
# `return build.block.size * tilesize;`), so a build
# payload fits when block.size <= 4; a UnitPayload is
# hitSize pixels (UnitPayload.java:99-101,
# `return unit.hitSize;`), so a unit fits when
# hitSize <= 32 (tilesize 8, Vars.java:135). Neither
# def overrides maxPayloadSize.
const SOURCE_PAYLOAD_DECONSTRUCTOR_MAX_PAYLOAD_SIZE := 4.0

static func _is_payload_deconstructor_build_implementation(implementation: String) -> bool:
	return SOURCE_PAYLOAD_DECONSTRUCTOR_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_payload_deconstructor_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The payload-deconstructor tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (PayloadDeconstructor.java:17, `public class PayloadDeconstructor extends PayloadBlock{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# payload-deconstructor skips consumption like Java's updateConsumption
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
	# for this payload-deconstructor (N2125); the tick preserves a disabled
	# payload-deconstructor instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	# The frame carries the Payload being deconstructed
	# (frame["deconstructing"], default null -- the Java field
	# is nullable, `public @Nullable Payload deconstructing;`,
	# PayloadDeconstructor.java:52); the tick preserves the
	# deconstructing payload instead of resetting it -- the
	# updateTile advance (N2233) fills it from the frame
	# payload via the moveInPayload intake, and the
	# handlePayload live fill is live since N2291
	# (source_payload_deconstructor_handle_payload_state,
	# through the frame incoming_payload push), so the
	# shouldConsume gate reads a live deconstructing.
	if not frame.has("deconstructing"):
		frame["deconstructing"] = null
	# The acceptance verdicts (N2297): acceptPayload
	# (PayloadDeconstructor.java:104-106) and
	# acceptUnitPayload (PayloadDeconstructor.java:92-95)
	# read the offered payload / unit descriptors from
	# the frame (frame["offered_payload"] /
	# frame["offered_unit"], default null -- no live
	# source offers them yet, so a live deconstructor
	# with no offer reads both verdicts false) plus the
	# frame payload / deconstructing null-ness; the
	# verdicts land on frame["accepts_payload"] /
	# frame["accepts_unit_payload"] for the intake and
	# the unit drop to consult. Since N2308 the intake
	# consults the acceptPayload gate too -- the tick
	# computes the verdict from the incoming dict
	# itself (the incoming dict carries requirements
	# and, since N2308, a block_size key) and applies
	# the push only when it accepts; the offer verdict
	# still governs frame["accepts_payload"] (when both
	# an offer and a push are present, the offer verdict
	# governs the frame key and the intake verdict
	# decides the push alone).
	var has_payload: bool = frame.get("payload", null) != null
	var has_deconstructing: bool = frame.get("deconstructing", null) != null
	var offered_payload: Variant = frame.get("offered_payload", null)
	if offered_payload is Dictionary:
		frame["accepts_payload"] = bool(source_payload_deconstructor_accept_payload_state(offered_payload, has_payload, has_deconstructing).get("accepts", false))
	else:
		frame["accepts_payload"] = false
	var offered_unit: Variant = frame.get("offered_unit", null)
	if offered_unit is Dictionary:
		frame["accepts_unit_payload"] = bool(source_payload_deconstructor_accept_unit_payload_state(offered_unit, has_payload, has_deconstructing).get("accepts", false))
	else:
		frame["accepts_unit_payload"] = false
	return frame

static func _initial_frame() -> Dictionary:
	# A new PayloadDeconstructorBuild starts with no payload
	# being deconstructed (the nullable field, `public
	# @Nullable Payload deconstructing;`,
	# PayloadDeconstructor.java:52, default null): the
	# shouldConsume gate (PayloadDeconstructor.java:219-221)
	# reads only its null-ness, so the frame carries the
	# deconstructing key at null. N2233 extends the frame with
	# the rest of the updateTile state at its Java defaults:
	# the held payload (`public @Nullable T payload;`,
	# PayloadBlock.java:92, null), the accumulation buffer
	# (`public @Nullable float[] accum;`,
	# PayloadDeconstructor.java:53, null), `public float
	# progress;` (PayloadDeconstructor.java:54, 0f), `public
	# float time, speedScl;` (PayloadDeconstructor.java:55,
	# 0f), the items ItemModule (empty), the payload offset
	# (`public Vec2 payVector = new Vec2();`,
	# PayloadBlock.java:94) and `public float payRotation;`
	# (PayloadBlock.java:95, 0f). N2276 extends the frame with
	# the dump state at its Java defaults: the dump
	# accumulator (`private transient float dumpAccum;`,
	# BuildingComp.java:99, 0f) and the dump cursor
	# (`transient int cdump;`, BuildingComp.java:68, 0).
	# N2291 extends the frame with the one-tick incoming
	# payload push (frame["incoming_payload"], default null):
	# the handlePayload intake reads it before the
	# consumption fold and consumes it either way (the N2278
	# Loader precedent); no live source pushes it yet.
	# N2297 extends the frame with the acceptance
	# verdicts (frame["accepts_payload"] /
	# frame["accepts_unit_payload"], default false) and
	# the offered descriptors they read
	# (frame["offered_payload"] / frame["offered_unit"],
	# default null -- no live source offers them yet).
	# N2308 extends the incoming push contract with
	# the block_size key (the payload size in tiles):
	# the intake computes the N2297 acceptPayload
	# verdict from the incoming dict itself, and a
	# push without block_size rejects.
	return {"deconstructing": null, "payload": null, "accum": null, "progress": 0.0, "time": 0.0, "speed_scl": 0.0, "items": {}, "pay_vector": Vector2.ZERO, "pay_rotation": 0.0, "dump_accum": 0.0, "cdump": 0, "incoming_payload": null, "offered_payload": null, "offered_unit": null, "accepts_payload": false, "accepts_unit_payload": false}

static func source_payload_deconstructor_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the payload-deconstructor frame meta key
	# ("source_payload_deconstructor_building"). A PayloadDeconstructor sprite gets a
	# frame bound with the deconstructing key at its Java default null;
	# the live-loop tick fills its other keys every
	# tick. Any other block, or an already-bound sprite, binds
	# nothing.
	if block == null or not _is_payload_deconstructor_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_PAYLOAD_DECONSTRUCTOR_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_PAYLOAD_DECONSTRUCTOR_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_PAYLOAD_DECONSTRUCTOR_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_payload_deconstructor_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a payload-deconstructor does not take the early return. The progress advance follows the folded efficiency (PayloadDeconstructor.java:142, `float shift = edelta() * deconstructSpeed / deconstructing.buildTime();`) with `progress += shift;` and the shouldConsume override (PayloadDeconstructor.java:219-221, `return deconstructing != null && enabled;`, default BuildingComp.java:755, `public boolean shouldConsume(){`) -- PayloadDeconstructorBuild overrides shouldConsume() to return deconstructing != null && enabled, so the default does not apply here; the gate is live since N2210 (the pure gate source_payload_deconstructor_should_consume_state feeds deconstructing != null && enabled to the machinery; when the gate is false updateConsumption forces efficiency to 0, BuildingComp.java:1960 + 1992). The deconstructor (consumePower 3f, Blocks.java:6653, `consumePower(3f);`; small-deconstructor consumePower 1f, Blocks.java:6644, `consumePower(1f);`) has no liquid consumer, so the folded efficiency is the min over the *modeled* consumers (power only).
	# Documented limits: (1) power-only first pass -- the deconstructor has no liquid consumer, so the folded efficiency is the min over the *modeled* consumers (power only). (2) shouldConsume gate live (N2210) -- PayloadDeconstructorBuild overrides shouldConsume() to return deconstructing != null && enabled (PayloadDeconstructor.java:219-221, `return deconstructing != null && enabled;`); the pure gate reads the null-ness of the frame deconstructing payload plus the frame enabled flag and feeds should_consume to the machinery; when the gate is false Java forces efficiency to 0 (BuildingComp.java:1960 + 1992-1994). The updateTile advance (N2233) fills frame["deconstructing"] from the frame payload via the moveInPayload intake; the handlePayload live fill is live since N2291 (source_payload_deconstructor_handle_payload_state, through the frame incoming_payload push). (3) Partial updateTile advance (N2233) -- progress / payRotation / canProgress / accum / speedScl / item transfer / finish deconstruction / moveInPayload intake (PayloadDeconstructor.java:109-204) are live; the dumpAccumulate dump is live since N2276 (see (5)); the puddles liquid dump, the Fx.breakBlock finish effect, and the live payload positioning wait for their own slices. (4) No draw / icons / setBars / read-write rows -- draw (PayloadDeconstructor.java:58-89), icons (PayloadDeconstructor.java:40-42), setBars (PayloadDeconstructor.java:45-49), read/write (PayloadDeconstructor.java:224-252) are presentation / serialization, not tick state; acceptPayload (PayloadDeconstructor.java:104-106) and acceptUnitPayload (PayloadDeconstructor.java:92-95) are live since N2297 (see (7)); handlePayload (PayloadDeconstructor.java:98-101) is live since N2291 (see (6)). (5) Dump rows live (N2276) -- dumpRate 4 (PayloadDeconstructor.java:20) and dumpAccumulate (PayloadDeconstructor.java:111-115) dump through the shared dump_item_state routing; the neighbour acceptItem / canDump arrays are frame inputs (default [] -- no live proximity fill yet). Dump neighbour write-back live since N2368 -- the advance exposes dump_deliveries, one {neighbour_index, item} per successful dump attempt, and the tick lands each dumped item in the neighbour store through the N2353 helper. (6) Live deconstructing fill live (N2291) -- the handlePayload intake (PayloadBlock.java:121-127 + the Deconstructor override PayloadDeconstructor.java:98-101, clearing accum) applies the frame incoming_payload push before the fold when the full acceptPayload gate accepts it (N2308 -- the tick computes the N2297 verdict from the incoming dict itself; a refused push is dropped, still consumed), and the moveInPayload handoff (PayloadDeconstructor.java:197-202, moveInPayload(false), no rotate) is a registered pure (source_payload_deconstructor_move_in_payload_state) called from the N2233 advance's else-if branch; updatePayload() live positioning defers (no live payload entity) and the incoming push has no live source yet (the front moveOutPayload handoff and the unit drop wait for their own slices). (7) Acceptance gates live (N2297) -- acceptPayload (PayloadDeconstructor.java:104-106) and acceptUnitPayload (PayloadDeconstructor.java:92-95) are registered pures (source_payload_deconstructor_accept_payload_state / source_payload_deconstructor_accept_unit_payload_state) wired to frame["accepts_payload"] / frame["accepts_unit_payload"] from the frame offered_payload / offered_unit descriptors (default null -- no live source offers them yet, so both verdicts read false live). (8) Intake full-gate wiring live (N2308) -- the tick computes the N2297 acceptPayload verdict from the incoming dict itself (requirements_length from the N2233 requirements array, block_size from the new incoming-dict key; a push without block_size rejects) and applies the push only when it accepts; the offered-payload verdict still governs frame["accepts_payload"] (when both an offer and a push are present, the offer verdict governs the frame key and the intake verdict decides the push alone). (9) Sense rows live (N2387) -- sense(Content) (PayloadDeconstructor.java:206-210) and sense(LAccess.progress) (PayloadDeconstructor.java:213-216) are registered pures (source_payload_deconstructor_sense_state / source_payload_deconstructor_sense_content_state), pure-only (sense is called by logic, not the tick, and the logic call site waits for a logic-executor slice); progress returns as-is with NO clamp; the content dispatch reads the descriptor kind key (the N2233 contract: kind "build" / "unit") and takes the payload identity as the caller-supplied payload_content_id explicit input (the descriptor carries no identity key, so no live call site can supply it until a payload-contract slice adds one).
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_payload_deconstructor_should_consume_state(frame: Dictionary) -> Dictionary:
	# PayloadDeconstructorBuild.shouldConsume() (PayloadDeconstructor.java:219-221, `public boolean shouldConsume(){` with `return deconstructing != null && enabled;`, PayloadDeconstructor.java:220): the gate reads the nullable field `public @Nullable Payload deconstructing;` (PayloadDeconstructor.java:52), set by the updateTile advance (`deconstructing = payload;`, PayloadDeconstructor.java:199, when moveInPayload succeeds, PayloadDeconstructor.java:197) and cleared on finish (PayloadDeconstructor.java:193). The gate has an `&& enabled` term -- unlike the PayloadLoader / PayloadUnloader gate (`return payload != null;`, PayloadLoader.java:240-242), so a disabled deconstructor with a payload in progress still does not consume. PayloadDeconstructorBuild overrides shouldConsume (PayloadDeconstructor.java:51, `public class PayloadDeconstructorBuild extends PayloadBlockBuild<Payload>{`; PayloadDeconstructor.java:17, `public class PayloadDeconstructor extends PayloadBlock{`), so the default (`return enabled;`, BuildingComp.java:755-756) does not apply here. When the gate is false updateConsumption forces efficiency to zero (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). The frame carries the deconstructing payload (frame["deconstructing"], default null, the Java field nullable); the gate reads only its null-ness, and enabled comes from the frame (tick-preserved, the factory pattern). The updateTile progress advance (PayloadDeconstructor.java:142, `float shift = edelta() * deconstructSpeed / deconstructing.buildTime();` with `progress += shift;`) follows the folded efficiency and is live since N2233 (source_payload_deconstructor_update_tile_advance_state).
	var deconstructing_present: bool = frame.get("deconstructing", null) != null
	var enabled: bool = bool(frame.get("enabled", true))
	return {"should_consume": deconstructing_present and enabled, "deconstructing_present": deconstructing_present}

static func source_payload_deconstructor_sense_state(sensor: String, progress: float, super_value: Variant = null) -> Dictionary:
	# The sense rows (PayloadDeconstructorBuild.sense(), PayloadDeconstructor.java:213-216), the pure logic-sense dispatch -- Java senses, in order (each exact expr on ONE comment line, the N2148 lesson):
	# `public double sense(LAccess sensor){`
	# `if(sensor == LAccess.progress) return progress;`
	# `return super.sense(sensor);`
	# progress is the frame value the N2233 advance tracks
	# (`public float progress;`, PayloadDeconstructor.java:54: progress += shift with shift = edelta() * deconstructSpeed / deconstructing.buildTime(), :142) and Java returns it AS-IS -- NO clamp, unlike the MendProjector clamp (`if(sensor == LAccess.progress) return Mathf.clamp(charge / reload);`, MendProjector.java:127): progress can pass 1f (the advance adds shift, NOT realShift), and the sensed value passes 1f too. super.sense is VERIFIED, not guessed: the BuildingComp switch (BuildingComp.java:2093-2122):
	# `return switch(sensor){`
	# `case health -> health;`
	# `case efficiency -> efficiency;`
	# `default -> Float.NaN; //gets converted to null in logic`
	# covers x / y / color / dead / solid / team / health / maxHealth / efficiency / timescale / range / rotation / totalItems / totalLiquids / totalPower / itemCapacity / liquidCapacity / powerCapacity / powerNetIn / powerNetOut / powerNetStored / powerNetCapacity / enabled / controlled / payloadCount / size / cameraX, cameraY, cameraWidth, cameraHeight, and the default branch is Float.NaN (converted to null in logic). The port ALREADY models that switch (SourceBuildingSenseState: sense_position_state, sense_health_process_state, sense_totals_state, sense_capacity_power_net_state, sense_enabled_controlled_state, sense_payload_size_state, sense_camera_default_state), so the pure takes the caller's super.sense result as super_value (default null = the default branch) instead of re-modeling the switch. sense(Content) is the separate overload (PayloadDeconstructor.java:206-210) modeled by source_payload_deconstructor_sense_content_state below. Pure-only, like the N2383 sense pures: the tick never calls sense (verified: grep `sense` in this driver finds only comment defers) -- sense is called by logic, not the tick, and the logic call site waits for a logic-executor slice (a port-wide concern, not a PayloadDeconstructor deferral).
	var is_progress: bool = sensor == "progress"
	var value: Variant = progress if is_progress else super_value
	return {
		"progress_expr": "if(sensor == LAccess.progress) return progress;",
		"super_expr": "return super.sense(sensor);",
		"sensor": sensor,
		"progress": progress,
		"super_value": super_value,
		"is_progress": is_progress,
		"value": value,
	}

static func source_payload_deconstructor_sense_content_state(deconstructing: Variant, content_id: String, payload_content_id: String, super_value: Variant = null) -> Dictionary:
	# The sense(Content) rows (PayloadDeconstructorBuild.sense(Content), PayloadDeconstructor.java:206-210), the pure logic-sense dispatch -- Java senses, in order (each exact expr on ONE comment line, the N2148 lesson):
	# `public double sense(Content content){`
	# `if(deconstructing instanceof UnitPayload up) return up.unit.type == content ? 1 : 0;`
	# `if(deconstructing instanceof BuildPayload bp) return bp.build.block == content ? 1 : 0;`
	# `return super.sense(content);`
	# The deconstructing descriptor format (VERIFIED before writing this pure): the N2233 payload dict contract (decision 8) -- kind ("build" / "unit"), requirements (ItemStack list of {item, amount}), build_time. kind runs the instanceof dispatch: "unit" is the UnitPayload branch, "build" (the N2233 default for a missing kind) is the BuildPayload branch. The descriptor carries NO identity key -- neither the unit type nor the block is in the frame -- so the equality operand (up.unit.type / bp.build.block) arrives as the caller-supplied payload_content_id explicit input (the N2383 reload_value / super_value precedent): the content id string of the deconstructing payload ("dagger" for a unit type, "conveyor" for a block), compared against the queried content_id. NO descriptor key is invented here; a payload-contract slice that adds identity keys to the descriptor lets the live call site supply payload_content_id from the frame. A null deconstructing falls through to super.sense(content) -- the BuildingComp content switch (BuildingComp.java:2139-2147):
	# `if(content instanceof Item i && items != null) return items.get(i);`
	# `return Float.NaN; //invalid sense`
	# -- already modeled by the port (SourceBuildingSenseState.sense_content_state), so the pure takes the caller's super.sense(content) result as super_value (default null = the invalid-sense branch) instead of re-modeling it. sense(LAccess) is the separate overload (PayloadDeconstructor.java:213-216) modeled by source_payload_deconstructor_sense_state above. Pure-only, like the N2383 sense pures: the tick never calls sense (verified: grep `sense` in this driver finds only comment defers) -- sense is called by logic, not the tick, and the logic call site waits for a logic-executor slice (a port-wide concern, not a PayloadDeconstructor deferral).
	var kind: String = ""
	var is_unit_payload: bool = false
	var value: Variant = super_value
	if deconstructing != null:
		kind = str((deconstructing as Dictionary).get("kind", "build"))
		is_unit_payload = kind == "unit"
		value = 1.0 if payload_content_id == content_id else 0.0
	return {
		"unit_expr": "if(deconstructing instanceof UnitPayload up) return up.unit.type == content ? 1 : 0;",
		"build_expr": "if(deconstructing instanceof BuildPayload bp) return bp.build.block == content ? 1 : 0;",
		"super_expr": "return super.sense(content);",
		"deconstructing_present": deconstructing != null,
		"kind": kind,
		"content_id": content_id,
		"payload_content_id": payload_content_id,
		"super_value": super_value,
		"is_unit_payload": is_unit_payload,
		"value": value,
	}

static func source_payload_deconstructor_accept_payload_state(payload: Dictionary, has_payload: bool, has_deconstructing: bool) -> Dictionary:
	# PayloadDeconstructorBuild.acceptPayload(Building source, Payload payload)
	# (PayloadDeconstructor.java:104-106):
	# `return deconstructing == null && this.payload == null && super.acceptPayload(source, payload) && payload.requirements().length > 0 && payload.fits(maxPayloadSize);`
	# The gate ANDs five terms. `deconstructing == null` reads the nullable field
	# `public @Nullable Payload deconstructing;` (PayloadDeconstructor.java:52):
	# a deconstructor already deconstructing a payload takes no second one.
	# `this.payload == null` reads the held payload (`public @Nullable T payload;`,
	# PayloadBlock.java:92): a deconstructor already holding a payload takes no
	# second one. `super.acceptPayload(source, payload)` is the PayloadBlock base
	# gate (PayloadBlock.java:116-118, `return this.payload == null;`) -- the SAME
	# term as the one before it, so it is REDUNDANT here; the pure ANDs it in
	# again anyway to stay Java-exact (the redundancy is Java's, not ours).
	# `payload.requirements().length > 0` requires deconstructable requirements:
	# a BuildPayload's requirements are its block requirements
	# (`return build.block.requirements;`, BuildPayload.java:66-68) and a
	# UnitPayload's are its unit type total requirements
	# (`return unit.type.getTotalRequirements();`, UnitPayload.java:61-63), so a
	# payload with nothing to deconstruct is refused. `payload.fits(maxPayloadSize)`
	# is the Payload default (`default boolean fits(float s){`, Payload.java:50,
	# `return size() / tilesize <= s;`, Payload.java:51): a BuildPayload is
	# block.size tiles (`return build.block.size * tilesize;`,
	# BuildPayload.java:86-88), so it fits when block.size <= maxPayloadSize (4,
	# PayloadDeconstructor.java:18, `public float maxPayloadSize = 4;`); a
	# UnitPayload is hitSize pixels (`return unit.hitSize;`,
	# UnitPayload.java:99-101), so it fits when hitSize / tilesize <= 4 -- a unit
	# payload offered through this gate supplies ceil(hitSize / tilesize) as its
	# block_size, which preserves the <= comparison exactly (ceil(x) <= 4 iff
	# x <= 4 for integer 4). The payload descriptor carries requirements_length
	# (int) and block_size (int, the payload size in tiles); missing keys default
	# to the rejecting value (no requirements, block_size maxPayloadSize + 1).
	# The source building is not read -- Java ignores it here.
	var deconstructing_empty: bool = not has_deconstructing
	var payload_empty: bool = not has_payload
	var super_accepts: bool = payload_empty
	var requirements_length: int = int(payload.get("requirements_length", 0))
	var block_size: int = int(payload.get("block_size", SOURCE_PAYLOAD_DECONSTRUCTOR_MAX_PAYLOAD_SIZE + 1))
	var has_requirements: bool = requirements_length > 0
	var fits: bool = float(block_size) <= SOURCE_PAYLOAD_DECONSTRUCTOR_MAX_PAYLOAD_SIZE
	return {"accepts": deconstructing_empty and payload_empty and super_accepts and has_requirements and fits, "deconstructing_empty": deconstructing_empty, "payload_empty": payload_empty, "has_requirements": has_requirements, "fits": fits}

static func source_payload_deconstructor_accept_unit_payload_state(unit: Dictionary, has_payload: bool, has_deconstructing: bool) -> Dictionary:
	# PayloadDeconstructorBuild.acceptUnitPayload(Unit unit)
	# (PayloadDeconstructor.java:92-95):
	# `return payload == null && deconstructing == null && unit.type.allowedInPayloads && !unit.spawnedByCore`
	# `&& unit.type.getTotalRequirements().length > 0 && unit.hitSize / tilesize <= maxPayloadSize;`
	# The gate ANDs six terms. `payload == null` reads the held payload
	# (`public @Nullable T payload;`, PayloadBlock.java:92) and
	# `deconstructing == null` the nullable field (`public @Nullable Payload
	# deconstructing;`, PayloadDeconstructor.java:52): a busy deconstructor
	# takes no unit. `unit.type.allowedInPayloads` is the unit-type flag
	# (`allowedInPayloads = true,`, UnitType.java:189, "if false, this unit
	# cannot be moved into payloads"): a type that forbids payloads is
	# refused. `!unit.spawnedByCore` reads the unit flag
	# (`boolean spawnedByCore;`, UnitComp.java:52): a core-spawned unit is refused.
	# `unit.type.getTotalRequirements().length > 0` requires deconstructable
	# requirements (`public ItemStack[] getTotalRequirements(){`,
	# UnitType.java:1323, all items needed to build the unit including
	# reconstructor steps): a unit with nothing to deconstruct is refused.
	# `unit.hitSize / tilesize <= maxPayloadSize` is the UnitPayload fits
	# check inlined: a UnitPayload is hitSize pixels (`return unit.hitSize;`,
	# UnitPayload.java:99-101), so it fits when hitSize / 8 <= 4, i.e.
	# hitSize <= 32 (`public static final int tilesize = 8;`, Vars.java:135).
	# The unit descriptor carries allowed_in_payloads (bool), spawned_by_core
	# (bool), total_requirements_length (int) and hit_size (float, pixels);
	# missing keys default to the rejecting value (not allowed, core-spawned,
	# no requirements, hit_size one tile over the max). The gate is what
	# canControlSelect consults before a player drops a unit on the block
	# (PayloadBlock.java:103-105, `return !unit.spawnedByCore &&
	# unit.type.allowedInPayloads && this.payload == null &&
	# acceptUnitPayload(unit) && unit.tileOn() != null && unit.tileOn().build == this;`).
	var payload_empty: bool = not has_payload
	var deconstructing_empty: bool = not has_deconstructing
	var allowed_in_payloads: bool = bool(unit.get("allowed_in_payloads", false))
	var spawned_by_core: bool = bool(unit.get("spawned_by_core", true))
	var allowed: bool = allowed_in_payloads and not spawned_by_core
	var total_requirements_length: int = int(unit.get("total_requirements_length", 0))
	var hit_size: float = float(unit.get("hit_size", (SOURCE_PAYLOAD_DECONSTRUCTOR_MAX_PAYLOAD_SIZE + 1.0) * source_world_defaults.TILESIZE))
	var has_requirements: bool = total_requirements_length > 0
	var fits: bool = hit_size / source_world_defaults.TILESIZE <= SOURCE_PAYLOAD_DECONSTRUCTOR_MAX_PAYLOAD_SIZE
	return {"accepts": payload_empty and deconstructing_empty and allowed and has_requirements and fits, "allowed": allowed, "has_requirements": has_requirements, "fits": fits}

static func source_payload_deconstructor_handle_payload_state(incoming_payload: Variant, source_x: float, source_y: float, self_x: float, self_y: float, payload_rotation: float, block_size: int, tilesize: float) -> Dictionary:
	# The handlePayload intake (N2291): handlePayload(Building source, Payload payload)
	# (PayloadBlock.java:121-127) on `public class PayloadBlockBuild<T extends Payload> extends Building{` (PayloadBlock.java:91) /
	# `public class PayloadDeconstructorBuild extends PayloadBlockBuild<Payload>{` (PayloadDeconstructor.java:51):
	# `this.payload = (T)payload;` (PayloadBlock.java:122) sets the held payload (the field `public @Nullable T payload;`,
	# PayloadBlock.java:92, default null; the frame key frame["payload"]);
	# this.payVector.set(source).sub(this).clamp(-size * tilesize / 2f, -size * tilesize / 2f, size * tilesize / 2f, size * tilesize / 2f); (PayloadBlock.java:123)
	# sets payVector (the field `public Vec2 payVector = new Vec2();`, PayloadBlock.java:94) to the source offset, clamped per axis
	# to +/-size*tilesize/2 -- Vec2.clamp(minx, miny, maxx, maxy) is `x = Mathf.clamp(x, minx, maxx);` / `y = Mathf.clamp(y, miny, maxy);`
	# (arc Vec2.java:318-322), so each axis clamps independently; `public static final int tilesize = 8;` (Vars.java:135), so size 5
	# (deconstructor, `size = 5;`, Blocks.java:6654) clamps to +/-20.0 and size 3 (small-deconstructor, `size = 3;`, Blocks.java:6645)
	# clamps to +/-12.0; `this.payRotation = payload.rotation();` (PayloadBlock.java:124) records the payload rotation (the field
	# `public float payRotation;`, PayloadBlock.java:95, default 0f; `default float rotation(){` with `return 0f;`, Payload.java:55-57,
	# is the BuildPayload default, so a payload dict without a rotation key reads 0.0); `updatePayload();` (PayloadBlock.java:126) is
	# NOT ported: it only positions the live payload entity (`payload.set(x + payVector.x, y + payVector.y, payRotation);`, PayloadBlock.java:176)
	# and the port has no live payload entity -- payVector/payRotation ARE the record (the N2233 moveIn precedent). The Deconstructor override
	# (PayloadDeconstructor.java:98-101): `super.handlePayload(source, payload);` (PayloadDeconstructor.java:99) then `accum = null;`
	# (PayloadDeconstructor.java:100) -- a fresh intake clears the accumulation buffer (the field `public @Nullable float[] accum;`,
	# PayloadDeconstructor.java:53); the N2233 advance rebuilds it from the requirements when the handoff lands. The pure function sets
	# unconditionally, like Java: the null guard lives in the driver (acceptPayload returns `this.payload == null`, PayloadBlock.java:117)
	# and in acceptPayload itself (PayloadDeconstructor.java:104-106, live since N2297 as source_payload_deconstructor_accept_payload_state + the frame accepts_payload verdict -- the handle pure still sets unconditionally, like Java, and the driver intake gate consults it since N2308, computing the verdict from the incoming dict itself). The pay_vector
	# is a {x, y} dict (the canonical frame, the N2278/N2279 Loader/Unloader precedent); the deconstructor frame keeps Vector2 (the N2233
	# advance + proof pin Vector2), so the tick converts at the boundary.
	var half_size: float = float(block_size) * tilesize / 2.0
	var pay_x: float = clampf(source_x - self_x, -half_size, half_size)
	var pay_y: float = clampf(source_y - self_y, -half_size, half_size)
	return {"payload": incoming_payload, "pay_vector": {"x": pay_x, "y": pay_y}, "pay_rotation": payload_rotation, "accum": null}

static func _deconstructor_vec2_approach(pay_vector: Vector2, alpha: float) -> Vector2:
	# Vec2.approach(Vec2 target, float alpha) (Vec2.java:525-537),
	# target Vec2.ZERO here (PayloadBlock.java:194,
	# `payVector.approach(Vec2.ZERO, payloadSpeed * delta());`).
	# `float dx = x - target.x, dy = y - target.y;`
	# `float alpha2 = alpha*alpha;`
	# `float len2 = Mathf.len2(dx, dy);`
	# `if(len2 > alpha2){` scales the offset by
	# `Mathf.sqrt(alpha2 / len2)` and subtracts it, else
	# `return set(target);` snaps to the target.
	var dx: float = pay_vector.x
	var dy: float = pay_vector.y
	var alpha2: float = alpha * alpha
	var len2: float = dx * dx + dy * dy
	if len2 > alpha2:
		var scl: float = sqrt(alpha2 / len2)
		return Vector2(pay_vector.x - dx * scl, pay_vector.y - dy * scl)
	return Vector2.ZERO

static func _deconstructor_move_in_payload(pay_vector: Vector2, delta: float, payload_speed: float) -> Dictionary:
	# PayloadBlockBuild.moveInPayload(false)
	# (PayloadBlock.java:186-197).
	# `public boolean moveInPayload(boolean rotate){`
	# `if(payload == null) return false;`
	# -- the caller checks the payload first, so this helper only
	# runs with a payload present. `updatePayload();` (:189) sets
	# the live payload position
	# `payload.set(x + payVector.x, y + payVector.y, payRotation);`
	# (PayloadBlock.java:174-177) -- DEFERRED, the port's payload
	# dict carries no position. rotate is false so the rotation
	# branch (:191-193) never runs.
	# `payVector.approach(Vec2.ZERO, payloadSpeed * delta());`
	# `return hasArrived();`
	# `return payVector.isZero(0.01f);`
	# (PayloadBlock.java:242-244, Vec2.java:679-681)
	# `return len2() < margin;`
	# -- the SQUARED length, not the length. The deconstructor
	# payloadSpeed is 1f (PayloadDeconstructor.java:31,
	# `payloadSpeed = 1f;`, overriding the PayloadBlock class
	# default)
	# `public float payloadSpeed = 0.7f, payloadRotateSpeed = 5f;`
	# (PayloadBlock.java:18); the speed arrives as a parameter so
	# the N2291 registered pure can pin the class default too.
	# N2291: the registered pure
	# source_payload_deconstructor_move_in_payload_state calls
	# this helper for the approach + arrival core, then applies
	# the handoff; the N2233 advance calls the pure, not this
	# helper directly.
	var moved: Vector2 = _deconstructor_vec2_approach(pay_vector, payload_speed * delta)
	return {"pay_vector": moved, "arrived": moved.length_squared() < 0.01}

static func source_payload_deconstructor_move_in_payload_state(payload: Variant, pay_vector: Dictionary, accum: Variant, progress: float, delta: float, payload_speed: float) -> Dictionary:
	# The moveInPayload handoff (N2291): the updateTile else-if
	# branch (PayloadDeconstructor.java:197-202),
	# `}else if(moveInPayload(false) && payload != null){`
	# `accum = new float[payload.requirements().length];`
	# `deconstructing = payload;`
	# `payload = null;`
	# `progress = 0f;`
	# -- the handoff runs only when the payload has arrived AND
	# a payload is held (the && short-circuits: moveInPayload
	# itself returns false on a null payload,
	# PayloadBlock.java:186-197). moveInPayload(false)
	# (PayloadBlock.java:186-197): `if(payload == null) return
	# false;` (:187) BEFORE any movement, so a null payload
	# leaves payVector untouched; `updatePayload();` (:189) is
	# NOT ported (it only positions the live payload entity,
	# `payload.set(x + payVector.x, y + payVector.y,
	# payRotation);`, PayloadBlock.java:176, and the port has no
	# live payload entity); rotate is FALSE, so the rotation
	# branch (:191-193) NEVER runs -- the deconstructor
	# never rotates the payload in (unlike the Loader /
	# Unloader moveInPayload(true) default,
	# PayloadBlock.java:181-183); the skipped line is
	# `payRotation = Angles.moveToward(payRotation, block.rotate ? rotdeg() : 90f, payloadRotateSpeed * delta());`
	# `payVector.approach(Vec2.ZERO, payloadSpeed * delta());` (:194) moves the offset toward
	# zero at payloadSpeed * delta() -- delta() is `return
	# Time.delta * timeScale;` (BuildingComp.java:1922-1924),
	# the SCALED delta, NOT edelta() (the N2233 payRotation
	# moveToward uses edelta(); the move-in uses delta()); the
	# deconstructor payloadSpeed is 1f
	# (PayloadDeconstructor.java:31, `payloadSpeed = 1f;`,
	# overriding the PayloadBlock class default `public float
	# payloadSpeed = 0.7f, payloadRotateSpeed = 5f;`,
	# PayloadBlock.java:18), passed as a parameter so the proof
	# can pin both; `return hasArrived();` (:196) with
	# `return payVector.isZero(0.01f);`
	# (PayloadBlock.java:242-244, Vec2.java:679-681, `return
	# len2() < margin;`) -- the SQUARED length against 0.01,
	# so a vector of length 0.09 has already arrived. On
	# arrival the handoff sets deconstructing to the payload
	# (the field `public @Nullable Payload deconstructing;`,
	# PayloadDeconstructor.java:52), clears the held payload
	# (the field `public @Nullable T payload;`,
	# PayloadBlock.java:92), resets progress to 0f (the field
	# `public float progress;`,
	# PayloadDeconstructor.java:54), and rebuilds accum as a
	# zero array the length of the payload requirements (the
	# field `public @Nullable float[] accum;`,
	# PayloadDeconstructor.java:53; the N2233 Array precedent).
	# Before arrival the payload, progress and accum pass
	# through unchanged -- only pay_vector moves. The
	# pay_vector is a {x, y} dict (the canonical frame, the
	# N2278/N2279 precedent); the approach + arrival core runs
	# through _deconstructor_move_in_payload (the N2233
	# Vector2 helper), so this pure converts at the boundary
	# and the advance converts back (the frame keeps Vector2,
	# the N2233 proof pins it).
	if payload == null:
		return {"arrived": false, "pay_vector_after": pay_vector, "deconstructing": null, "payload_after": null, "progress_after": progress, "accum_after": accum}
	var moved: Dictionary = _deconstructor_move_in_payload(Vector2(float(pay_vector.get("x", 0.0)), float(pay_vector.get("y", 0.0))), delta, payload_speed)
	var moved_vector: Vector2 = moved["pay_vector"]
	var pay_vector_after: Dictionary = {"x": moved_vector.x, "y": moved_vector.y}
	if not bool(moved["arrived"]):
		return {"arrived": false, "pay_vector_after": pay_vector_after, "deconstructing": null, "payload_after": payload, "progress_after": progress, "accum_after": accum}
	var payload_dict: Dictionary = payload
	var payload_reqs: Array = payload_dict.get("requirements", [])
	var fresh_accum: Array = []
	for i in range(payload_reqs.size()):
		fresh_accum.append(0.0)
	return {"arrived": true, "pay_vector_after": pay_vector_after, "deconstructing": payload, "payload_after": null, "progress_after": 0.0, "accum_after": fresh_accum}

static func _deconstructor_deconstruct_speed_for_block(block_id: String) -> float:
	# deconstructSpeed is a per-def field
	# (PayloadDeconstructor.java:19, `public float
	# deconstructSpeed = 2.5f;`): deconstructor 6f
	# (Blocks.java:6655, `deconstructSpeed = 6f;`),
	# small-deconstructor 3f (Blocks.java:6646,
	# `deconstructSpeed = 3f;`). The catalog parses no
	# deconstructSpeed property, so the driver reads these
	# constants; an unknown PayloadDeconstructor id falls back
	# to the class default.
	if block_id == "deconstructor":
		return SOURCE_DECONSTRUCTOR_DECONSTRUCT_SPEED
	if block_id == "small-deconstructor":
		return SOURCE_SMALL_DECONSTRUCTOR_DECONSTRUCT_SPEED
	return SOURCE_PAYLOAD_DECONSTRUCTOR_CLASS_DECONSTRUCT_SPEED

static func _deconstructor_size_for_block(block_id: String) -> int:
	# The block size (PayloadDeconstructor.java:30,
	# `size = 5;`): deconstructor 5 (Blocks.java:6654,
	# `size = 5;`), small-deconstructor 3 (Blocks.java:6645,
	# `size = 3;`). The catalog parses no size property for
	# the handlePayload clamp, so the driver reads these
	# constants (the deconstructSpeed precedent above); an
	# unknown PayloadDeconstructor id falls back to the
	# class default 5.
	if block_id == "deconstructor":
		return SOURCE_DECONSTRUCTOR_SIZE
	if block_id == "small-deconstructor":
		return SOURCE_SMALL_DECONSTRUCTOR_SIZE
	return SOURCE_DECONSTRUCTOR_SIZE

static func source_payload_deconstructor_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float, deconstruct_speed: float, item_capacity: int, build_cost_multiplier: float = 1.0, unit_cost_multiplier: float = 1.0) -> Dictionary:
	# The updateTile advance (PayloadDeconstructorBuild.updateTile(),
	# PayloadDeconstructor.java:109-204). The dump
	# (PayloadDeconstructor.java:111-115, dumpRate 4)
	# `public int dumpRate = 4;`
	# (PayloadDeconstructor.java:20) is live since N2276
	# (source_payload_deconstructor_dump_state, wired in the
	# tick BEFORE this advance -- Java order) and runs on
	# delta(), not edelta(). The progress reset:
	# `if(deconstructing == null){`
	# `progress = 0f;`
	# (PayloadDeconstructor.java:117-119). The payRotation
	# moveToward -- NOTE edelta(), NOT delta() as in
	# moveInPayload:
	# `payRotation = Angles.moveToward(payRotation, 90f, payloadRotateSpeed * edelta());`
	# (PayloadDeconstructor.java:121), through the SourceMathState
	# moveToward reuse (Angles.java:38-41)
	# `if(Math.abs(angleDist(angle, to)) < speed) return to;`
	# The deconstruct branch (PayloadDeconstructor.java:123-196):
	# `var reqs = deconstructing.requirements();`
	# `if(accum == null || reqs.length != accum.length){`
	# `accum = new float[reqs.length];`
	# `boolean canProgress = items.total() <= itemCapacity;`
	# `if(ac >= 1f){`
	# `float shift = edelta() * deconstructSpeed / deconstructing.buildTime();`
	# `float realShift = Math.min(shift, 1f - progress);`
	# `progress += shift;`
	# -- NOT realShift: progress can pass 1f, kept exactly as
	# Java. `time += edelta();`
	# `accum[i] += reqs[i].amount * (deconstructing instanceof BuildPayload ? state.rules.buildCostMultiplier : state.rules.unitCost(team)) * realShift;`
	# `speedScl = Mathf.lerpDelta(speedScl, canProgress ? 1f : 0f, 0.1f);`
	# through the SourceMathState lerpDelta reuse
	# (Mathf.java:430-432)
	# `return lerp(fromValue, toValue, clamp(progress * Time.delta));`
	# -- lerpDelta scales by Time.delta, not delta(), so the
	# speedScl lerp uses the unscaled source delta. The transfer:
	# `int taken = Math.min((int)accum[i], itemCapacity - items.total());`
	# `items.add(reqs[i].item, taken);`
	# `accum[i] -= taken;`
	# (PayloadDeconstructor.java:170-176). The finish branch:
	# `if(progress >= 1f){`
	# `if(Mathf.equal(accum[i], 1f, 0.0001f)){`
	# (Mathf.java:554-556, `return Math.abs(a - b) <= tolerance;`)
	# `if(items.total() < itemCapacity){`
	# `items.add(reqs[i].item, 1);`
	# `accum[i] = 0f;`
	# `deconstructing = null;`
	# `accum = null;`
	# (PayloadDeconstructor.java:179-195); the Fx.breakBlock effect
	# (:191) is DEFERRED. The intake branch:
	# `}else if(moveInPayload(false) && payload != null){`
	# `accum = new float[payload.requirements().length];`
	# `deconstructing = payload;`
	# `payload = null;`
	# `progress = 0f;`
	# (PayloadDeconstructor.java:197-201) -- moveInPayload with
	# rotate = FALSE, unlike the Loader / Unloader. N2291
	# registers the move-in + handoff as its own pure
	# (source_payload_deconstructor_move_in_payload_state,
	# approach at payloadSpeed * delta() + the handoff) and
	# this branch calls it, converting the frame Vector2
	# pay_vector to the pure's {x, y} dict at the boundary
	# and back (the frame keeps Vector2, the N2233 proof
	# pins it); the pure delegates the approach + arrival
	# core to _deconstructor_move_in_payload, so the math is
	# unchanged from N2233.
	# delta() is `return Time.delta * timeScale;`
	# (BuildingComp.java:1922-1924), edelta() is
	# `return efficiency * delta();`
	# (BuildingComp.java:1927-1929); source_delta is Time.delta
	# in ticks (seconds * 60 through game_source_delta, arc
	# Time.java:26), never raw seconds. The frame fields default
	# to the Java field defaults (`public @Nullable Payload
	# deconstructing;` PayloadDeconstructor.java:52, `public
	# @Nullable float[] accum;` PayloadDeconstructor.java:53)
	# `public float progress;`
	# `public float time, speedScl;`
	# (PayloadDeconstructor.java:54-55), the held payload
	# (`public @Nullable T payload;`, PayloadBlock.java:92),
	# the payload offset (`public Vec2 payVector = new
	# Vec2();`, PayloadBlock.java:94) and `public float
	# payRotation;` (PayloadBlock.java:95). Payload /
	# deconstructing dict contract (decision 8): kind
	# ("build" / "unit"), requirements (ItemStack list of
	# {item, amount}), build_time. BuildPayload requirements
	# are the block requirements
	# `return build.block.requirements;`
	# (BuildPayload.java:66-68) and its buildTime is the block
	# buildTime
	# `return build.block.buildTime;`
	# (BuildPayload.java:71-73); UnitPayload requirements are
	# the unit type total requirements
	# `return unit.type.getTotalRequirements();`
	# (UnitPayload.java:61-63) and its buildTime is the unit
	# type buildTime
	# `return unit.type.getBuildTime();`
	# (UnitPayload.java:66-68). The multipliers are Rules
	# params at their Java defaults:
	# `public float buildCostMultiplier = 1f;`
	# (Rules.java:115) and
	# `return unitCostMultiplier * teams.get(team).unitCostMultiplier;`
	# (Rules.java:275-276, both multipliers 1f, Rules.java:83/361).
	# Guard, not Java: shift is 0 when build_time <= 0. A
	# contract-valid payload always has a positive buildTime
	# (Block.init computes it from the requirements cost,
	# Block.java:1432-1443, and acceptPayload requires
	# requirements; UnitType likewise, UnitType.java:1343), so
	# the guard only keeps a contract-violating fixture -- like
	# the N2166/N2210 minimal {"block": "conveyor"} dicts --
	# from poisoning the frame with an infinite shift (the
	# N2222 empty-results precedent). Deferred, not done here:
	# the puddles liquid dump at
	# deconstruction start (:147-156, no Puddles model in the
	# port), the moveInPayload live payload positioning
	# (updatePayload, PayloadBlock.java:174-177), and the
	# Fx.breakBlock finish effect (:191).
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var deconstructing: Variant = frame.get("deconstructing", null)
	var payload: Variant = frame.get("payload", null)
	var accum: Variant = frame.get("accum", null)
	var progress: float = float(frame.get("progress", 0.0))
	var time: float = float(frame.get("time", 0.0))
	var speed_scl: float = float(frame.get("speed_scl", 0.0))
	var items: Dictionary = (frame.get("items", {}) as Dictionary).duplicate(true)
	var pay_vector: Vector2 = frame.get("pay_vector", Vector2.ZERO)
	var pay_rotation: float = float(frame.get("pay_rotation", 0.0))
	var delta: float = source_delta * time_scale
	var edelta: float = efficiency * delta
	var finished := false
	if deconstructing == null:
		progress = 0.0
	pay_rotation = source_math_state.source_angles_move_toward(pay_rotation, SOURCE_PAYLOAD_DECONSTRUCTOR_PAY_ROTATION_TARGET, SOURCE_PAYLOAD_DECONSTRUCTOR_PAYLOAD_ROTATE_SPEED * edelta)
	if deconstructing != null:
		var deconstructing_dict: Dictionary = deconstructing
		var reqs: Array = deconstructing_dict.get("requirements", [])
		var accum_array: Array = []
		if accum == null or (accum as Array).size() != reqs.size():
			for i in range(reqs.size()):
				accum_array.append(0.0)
		else:
			accum_array = (accum as Array).duplicate(true)
		var can_progress: bool = inventory.items_total(items) <= item_capacity
		if can_progress:
			for ac in accum_array:
				if float(ac) >= 1.0:
					can_progress = false
					break
		if can_progress:
			var build_time: float = float(deconstructing_dict.get("build_time", 0.0))
			var shift: float = 0.0
			if build_time > 0.0:
				shift = edelta * deconstruct_speed / build_time
			var real_shift: float = minf(shift, 1.0 - progress)
			progress += shift
			time += edelta
			var is_build: bool = str(deconstructing_dict.get("kind", "build")) == "build"
			var multiplier: float = build_cost_multiplier if is_build else unit_cost_multiplier
			for i in range(reqs.size()):
				var req: Dictionary = reqs[i]
				accum_array[i] = float(accum_array[i]) + float(req.get("amount", 0)) * multiplier * real_shift
		speed_scl = source_math_state.source_lerp_delta(speed_scl, 1.0 if can_progress else 0.0, SOURCE_PAYLOAD_DECONSTRUCTOR_SPEED_SCL_LERP_RATE, source_delta)
		for i in range(reqs.size()):
			var req: Dictionary = reqs[i]
			var taken: int = mini(int(accum_array[i]), item_capacity - inventory.items_total(items))
			if taken > 0:
				var added: Dictionary = inventory.add_item_state(items, str(req.get("item", "")), taken)
				items = added.get(inventory.SOURCE_DRILL_INVENTORY_DRILL_ITEMS_KEY, items)
				accum_array[i] = float(accum_array[i]) - float(taken)
		if progress >= 1.0:
			can_progress = true
			for i in range(reqs.size()):
				var req: Dictionary = reqs[i]
				if absf(float(accum_array[i]) - 1.0) <= SOURCE_PAYLOAD_DECONSTRUCTOR_ROUNDING_TOLERANCE:
					if inventory.items_total(items) < item_capacity:
						var added: Dictionary = inventory.add_item_state(items, str(req.get("item", "")), 1)
						items = added.get(inventory.SOURCE_DRILL_INVENTORY_DRILL_ITEMS_KEY, items)
						accum_array[i] = 0.0
					else:
						can_progress = false
						break
			if can_progress:
				deconstructing = null
				finished = true
		accum = null if finished else accum_array
	elif payload != null:
		# N2291: the move-in + handoff runs through the
		# registered pure (PayloadDeconstructor.java:197-202);
		# the frame pay_vector is a Vector2, the pure takes a
		# {x, y} dict, so this branch converts at the
		# boundary in both directions.
		var pay_dict: Dictionary = {"x": pay_vector.x, "y": pay_vector.y}
		var move_in: Dictionary = source_payload_deconstructor_move_in_payload_state(payload, pay_dict, accum, progress, delta, SOURCE_PAYLOAD_DECONSTRUCTOR_PAYLOAD_SPEED)
		var moved_vector: Dictionary = move_in["pay_vector_after"]
		pay_vector = Vector2(float(moved_vector.get("x", 0.0)), float(moved_vector.get("y", 0.0)))
		deconstructing = move_in["deconstructing"]
		payload = move_in["payload_after"]
		progress = move_in["progress_after"]
		accum = move_in["accum_after"]
	return {"progress": progress, "time": time, "speed_scl": speed_scl, "accum": accum, "items": items, "deconstructing": deconstructing, "payload": payload, "pay_vector": pay_vector, "pay_rotation": pay_rotation, "finished": finished}

static func source_payload_deconstructor_dump_state(frame: Dictionary, source_delta: float, time_scale: float, content_item_ids: Array, neighbour_accepts_item: Array, neighbour_can_dump: Array) -> Dictionary:
	# The updateTile dump block (PayloadDeconstructorBuild.updateTile(),
	# PayloadDeconstructor.java:109-204):
	# `if(items.total() > 0){`
	# `for(int i = 0; i < dumpRate; i++){`
	# `dumpAccumulate();`
	# -- dumpRate 4 (`public int dumpRate = 4;`,
	# PayloadDeconstructor.java:20; neither def overrides it),
	# and the block runs BEFORE the deconstructing progress
	# block (:117+), so the dump drains the store the advance
	# filled LAST tick, not the items the advance adds THIS
	# tick. dumpAccumulate() (BuildingComp.java:1048-1050):
	# `public boolean dumpAccumulate(){`
	# `return dumpAccumulate(null);`
	# delegates to dumpAccumulate(null)
	# (BuildingComp.java:1053-1061):
	# `public boolean dumpAccumulate(Item item){`
	# `boolean res = false;`
	# `dumpAccum += delta();`
	# `while(dumpAccum >= 1f){`
	# `res |= dump(item);`
	# `dumpAccum -=1f;`
	# -- the subtraction is UNCONDITIONAL: it runs every while
	# iteration whether or not dump() succeeded, so a failed
	# dump still spends the accum. dump()
	# (BuildingComp.java:1064-1066):
	# `public boolean dump(){`
	# `return dump(null);`
	# delegates to dump(null) (BuildingComp.java:1072-1113):
	# `public boolean dump(Item todump){`
	# `if(!block.hasItems || items.total() == 0 || proximity.size == 0 || (todump != null && !items.has(todump))) return false;`
	# `int dump = this.cdump;`
	# `var allItems = content.items();`
	# `int itemSize = allItems.size;`
	# `if(todump == null){`
	# `Building other = proximity.get((i + dump) % proximity.size);`
	# `if(!items.has(ii)) continue;`
	# `Item item = (Item)itemArray[ii];`
	# `if(other.acceptItem(self(), item) && canDump(other, item)){`
	# `other.handleItem(self(), item);`
	# `items.remove(item, 1);`
	# `incrementDump(proximity.size);`
	# -- neighbours outer, content items inner: for each
	# neighbour from the cdump cursor, the first held item in
	# content order an accepting neighbour takes is handed
	# over, 1 leaves the store, and the cursor advances once
	# per neighbour checked (incrementDump,
	# BuildingComp.java:1116-1120):
	# `public void incrementDump(int prox){`
	# `if(prox != 0){`
	# `cdump = ((cdump + 1) % prox);`
	# The dump fields are Building fields at their Java
	# defaults: `private transient float dumpAccum;`
	# (BuildingComp.java:99, 0f) and `transient int cdump;`
	# (BuildingComp.java:68, 0). delta() is
	# `return Time.delta * timeScale;`
	# (BuildingComp.java:1922-1924) -- NOT edelta(), so the
	# dump cadence ignores efficiency; source_delta is
	# Time.delta in ticks (seconds * 60 through
	# game_source_delta, arc Time.java:26), never raw seconds.
	# The deconstructor has items (`hasItems = true;`,
	# PayloadDeconstructor.java:35), so the hasItems guard
	# always passes. canDump defaults to true
	# (`public boolean canDump(Building to, Item item){`,
	# BuildingComp.java:1124-1126); the neighbour arrays carry
	# the live per-neighbour answers as frame inputs. The dump
	# itself runs through the shared dump(null) port
	# (SourceBuildingItemDumpState.dump_item_state) -- NOT the
	# putItem gate game_put_item_state, which dumps one
	# SPECIFIC item and needs a game object for its increment
	# callbacks, while dumpAccumulate calls dump(null). The
	# shared port reports the handled neighbour
	# (handled_index, the true proximity index
	# (i + dump) % proximity.size) and the handled item
	# (handled_item, the item id string) per attempt; the
	# advance collects them into dump_deliveries -- one
	# {"neighbour_index": ..., "item": ...} dict per
	# successful attempt, in attempt order (empty when
	# nothing dumped) -- so the tick can land each dumped
	# item in its neighbour store through the N2353 helper
	# (other.handleItem(self(), item), BuildingComp.java:1089).
	# A scalar routed index + item would drop every delivery
	# but one: dumpAccumulate can dump MULTIPLE times per
	# frame ("May dump multiple times per frame. Use with
	# care.", BuildingComp.java:1052) and dumpRate 4 runs it
	# 4 times per tick. Index i is ring cell i (the N2353
	# convention): the helper resolves the index through the
	# source_block_proximity_cells_state ring, so the live
	# fill must fill the frame neighbour inputs in ring
	# order. dump_deliveries is a registered symbol of this
	# slice (N2368, the N2360 pattern); the schema/contract
	# fold waits for a later schema-sync slice (the N2367
	# precedent), so the contract keeps its four return keys.
	var items: Dictionary = (frame.get("items", {}) as Dictionary).duplicate(true)
	var dump_accum: float = float(frame.get("dump_accum", 0.0))
	var cursor: int = int(frame.get("cdump", 0))
	var dumped := false
	var dump_deliveries: Array = []
	if inventory.items_total(items) > 0:
		var delta: float = source_delta * time_scale
		for _i in range(SOURCE_PAYLOAD_DECONSTRUCTOR_DUMP_RATE):
			dump_accum += delta
			while dump_accum >= 1.0:
				var amounts: Array = []
				for item_id in content_item_ids:
					amounts.append(int(items.get(str(item_id), 0)))
				var result: Dictionary = source_building_item_dump_state.dump_item_state(true, inventory.items_total(items), neighbour_accepts_item.size(), null, false, content_item_ids, amounts, neighbour_accepts_item, neighbour_can_dump, cursor)
				cursor = int(result.get("cdump", cursor))
				if bool(result.get("dumped", false)):
					dumped = true
					dump_deliveries.append({"neighbour_index": int(result.get("handled_index", -1)), "item": str(result.get("handled_item", ""))})
					var amounts_after: Array = result.get("item_amounts_by_index", amounts)
					for j in range(content_item_ids.size()):
						if j < amounts_after.size():
							items[str(content_item_ids[j])] = int(amounts_after[j])
				dump_accum -= 1.0
	return {"dump_accum_after": dump_accum, "dumped": dumped, "items_after": items, "cursor_after": cursor, "dump_deliveries": dump_deliveries}

@warning_ignore("unused_parameter")
static func source_payload_deconstructor_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the payload-deconstructor tick wiring every
	# tick (PayloadDeconstructorBuild.updateTile(), PayloadDeconstructor.java:109,
	# gates on the progress advance (PayloadDeconstructor.java:142, `float shift = edelta() * deconstructSpeed / deconstructing.buildTime();`) with `progress += shift;`, so the progress advance follows the folded efficiency; no placed-buildings driver ticks PayloadDeconstructor blocks, so this driver is the placed-payload-deconstructor tick): each placed PayloadDeconstructor build gets its frame keys refreshed from the live rules, so the frame's cheating flag tracks team.rules().cheat and the consumption machinery skips consumption for a cheating team. The frame is bound at placement; a sprite that somehow lacks one gets it bound here instead of crashing the loop.
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
		if not _is_payload_deconstructor_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_payload_deconstructor_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_payload_deconstructor_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The live deconstructing fill (N2291, handlePayload, PayloadBlock.java:121-127 + the Deconstructor override
		# PayloadDeconstructor.java:98-101): runs BEFORE the consumption fold and the advance call -- Java
		# handlePayload is an external call (the source's moveOutPayload or a unit drop), so it lands
		# before the next tick starts, and the fresh payload moves in on this same tick (the N2233 advance
		# hands it to deconstructing when it arrives). The intake reads the frame inputs incoming_payload
		# (the pushed payload dict, or null) / incoming_source_pos ({x, y} world position of the source
		# building) / world_pos ({x, y} world position of this deconstructor): no live source pushes them
		# yet (the front moveOutPayload handoff and the unit drop wait for their own slices), and the port
		# has no live world-position model for placed buildings, so both positions arrive as frame inputs
		# (origin_cell is a cell, sprite.position is unset by placement). The intake applies only when the
		# full Deconstructor acceptPayload gate accepts the push (N2308): Java only ever calls
		# handlePayload after acceptPayload returns true -- the pusher checks first
		# (BuildingComp.java:822-824, `if(next != null && next.build != null && next.build.team == team && next.build.acceptPayload(self(), todump)){` then `next.build.handlePayload(self(), todump);`, and the dumpPayload twin at :844-845, `if(other.acceptPayload(self(), todump)){` then `other.handlePayload(self(), todump);`), so the tick computes the N2297 verdict from the incoming dict itself (source_payload_deconstructor_accept_payload_state) and drops a refused push. The push is consumed either way (the N2278 Loader precedent; the N2279 Unloader keeps it
		# for a retry -- the divergence is documented). The incoming dict carries its requirements as the
		# N2233 array (the intake derives requirements_length from its length) and gains the block_size
		# key (the payload size in tiles); a push without block_size rejects (the pure defaults it to
		# maxPayloadSize + 1) and a non-dict push rejects too. The offered-payload verdict still governs
		# frame["accepts_payload"] (tick_frame_state, from the offered descriptor): when both an offer
		# and a push are present, the offer verdict governs the frame key and the intake verdict decides
		# the push alone -- the intake never overwrites frame["accepts_payload"]. The rotation reads the incoming
		# dict's rotation key (default 0.0, the Payload.java:55-57 default); the size is the per-def
		# constant (5 deconstructor / 3 small-deconstructor) and tilesize is SourceWorldDefaults. The
		# handle pure returns the pay_vector as a {x, y} dict (the canonical frame, the N2278/N2279
		# precedent); the frame keeps Vector2 (the N2233 advance + proof pin Vector2), so the tick
		# converts at this boundary.
		var incoming_payload: Variant = frame.get("incoming_payload", null)
		if incoming_payload != null:
			# N2308: the intake verdict comes from the N2297
			# pure, computed from the incoming dict itself.
			# The incoming dict carries its requirements as
			# the N2233 array, so requirements_length is the
			# array length; block_size rides the new
			# incoming-dict key and is left out when absent,
			# so the pure defaults it to maxPayloadSize + 1
			# and the verdict REJECTS. A non-dict push
			# carries neither key and rejects too. The pure's
			# payload_empty / deconstructing_empty terms
			# subsume the old frame null check, so the
			# verdict IS the guard now; the push is consumed
			# either way (below).
			var intake_accepts: bool = false
			if incoming_payload is Dictionary:
				var incoming_reqs: Array = incoming_payload.get("requirements", [])
				var incoming_descriptor: Dictionary = {"requirements_length": incoming_reqs.size()}
				if incoming_payload.has("block_size"):
					incoming_descriptor["block_size"] = incoming_payload.get("block_size")
				intake_accepts = bool(source_payload_deconstructor_accept_payload_state(incoming_descriptor, frame.get("payload", null) != null, frame.get("deconstructing", null) != null).get("accepts", false))
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
				var handled: Dictionary = source_payload_deconstructor_handle_payload_state(incoming_payload, float(incoming_source.get("x", 0.0)), float(incoming_source.get("y", 0.0)), float(world_pos.get("x", 0.0)), float(world_pos.get("y", 0.0)), incoming_rotation, _deconstructor_size_for_block(block_id), source_world_defaults.TILESIZE)
				frame["payload"] = handled["payload"]
				var handled_vector: Dictionary = handled["pay_vector"]
				frame["pay_vector"] = Vector2(float(handled_vector.get("x", 0.0)), float(handled_vector.get("y", 0.0)))
				frame["pay_rotation"] = handled["pay_rotation"]
				frame["accum"] = handled["accum"]
			frame["incoming_payload"] = null
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a payload-deconstructor with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the progress advance (PayloadDeconstructor.java:142)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a payload-deconstructor does not take the early return. A payload-deconstructor with no power consumer is untouched: the tick models no other consumers yet (the deconstructor has no liquid consumer), and PayloadDeconstructorBuild overrides shouldConsume() to return deconstructing != null && enabled (PayloadDeconstructor.java:219-221) -- N2210 feeds the live gate to the machinery (the pure gate is source_payload_deconstructor_should_consume_state, fed the frame); the N2166 RED decision is resolved. productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var gate: Dictionary = source_payload_deconstructor_should_consume_state(frame)
			var should_consume: bool = bool(frame.get("enabled", true)) and bool(gate.get("should_consume", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_payload_deconstructor_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		# N2233: the updateTile advance runs after consumption,
		# like Java's Building.update() (BuildingComp.java:2274
		# updateConsumption(), then the updateTile gate
		# `if(enabled || !block.noUpdateDisabled){` at
		# BuildingComp.java:2276-2277; noUpdateDisabled defaults
		# false, Block.java:170,
		# `public boolean noUpdateDisabled = false;`),
		# so a disabled deconstructor freezes its progress /
		# payRotation. The source delta is Time.delta in ticks:
		# game_source_delta(game, seconds) is seconds * 60 (arc
		# Time.java:26), never raw seconds. timeScale reads live
		# from the sprite meta, default 1.0 (BuildingComp.java:98
		# `private transient float timeScale = 1f, timeScaleDuration;`).
		# deconstructSpeed is the per-def constant (6f
		# deconstructor / 3f small-deconstructor); the capacity
		# comes from the catalog itemCapacity
		# `itemCapacity = 250;`
		# (deconstructor, Blocks.java:6652) /
		# `itemCapacity = 100;`
		# (small-deconstructor, Blocks.java:6643) with the ctor
		# default 100. The multipliers read live from the rules:
		# buildCostMultiplier from the rules dict at its Java
		# default 1f when the port's rules shape does not carry
		# it yet (Rules.java:115), unitCost(team) through the
		# existing SourceRulesRuntimeState helper.
		if bool(frame.get("enabled", true)):
			var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
			var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
			# N2276: the dump runs BEFORE the progress advance
			# (Java order: the updateTile dump block,
			# PayloadDeconstructor.java:111-115, runs before
			# the deconstructing progress block, :117+), so the
			# dump drains the store the advance filled LAST
			# tick. The content item ids are the catalog order
			# Java iterates (content.items()), through the
			# payload-loader / payload-unloader precedent
			# (SourceContentRegistryRuntimeState.
			# source_item_catalog_state); the neighbour
			# acceptItem / canDump arrays are frame inputs
			# (default [] -- no neighbours, the Java
			# proximity.size == 0 outcome) until a live
			# proximity fill lands.
			var content_item_ids: Array = source_content_registry_runtime_state.source_item_catalog_state(catalog).get("item_names_by_id", [])
			var neighbour_accepts: Array = frame.get("dump_neighbour_accepts", [])
			var neighbour_can_dump: Array = frame.get("dump_neighbour_can_dump", [])
			var dumped: Dictionary = source_payload_deconstructor_dump_state(frame, source_delta, time_scale, content_item_ids, neighbour_accepts, neighbour_can_dump)
			frame["dump_accum"] = dumped["dump_accum_after"]
			frame["items"] = dumped["items_after"]
			frame["cdump"] = dumped["cursor_after"]
			# N2368: the dump neighbour write-back -- the
			# advance exposed one delivery per successful dump
			# attempt (dump_deliveries, in attempt order), so
			# the tick lands each dumped item in its neighbour
			# store through the shared helper
			# (other.handleItem(self(), item),
			# BuildingComp.java:1089), right after the advance
			# write-back above (Java order: handleItem runs
			# inside dump(), :1089, before the next attempt).
			# A failed write-back (no sprite / no frame / no
			# items store / full belt) drops the item -- the
			# routing already decided, so there is no fallback
			# to the deconstructor's own store (the N2353
			# precedent). The size is the catalog size (the
			# deconstructor is 5, the small-deconstructor 3);
			# the size-5 ring has 20 cells, ring 0 offset
			# (-3, -1).
			for delivery in dumped.get("dump_deliveries", []):
				var delivery_entry: Dictionary = delivery
				var delivery_index: int = int(delivery_entry.get("neighbour_index", -1))
				var delivery_item: String = str(delivery_entry.get("item", ""))
				if delivery_index >= 0 and not delivery_item.is_empty():
					source_building_item_state.source_neighbour_item_write_back_state(game, cell, int(block.properties.get("size", 1)), delivery_index, delivery_item, 1)
			var deconstruct_speed: float = _deconstructor_deconstruct_speed_for_block(block_id)
			var item_capacity: int = int(block.properties.get("itemCapacity", 100))
			var rules_dict: Dictionary = rules_state if rules_state is Dictionary else {}
			var build_cost_multiplier: float = float(rules_dict.get("buildCostMultiplier", 1.0))
			var unit_cost_multiplier: float = float(source_rules_state.source_unit_cost_state(rules_dict, team_id).get("unit_cost", 1.0))
			var advanced: Dictionary = source_payload_deconstructor_update_tile_advance_state(frame, source_delta, time_scale, deconstruct_speed, item_capacity, build_cost_multiplier, unit_cost_multiplier)
			frame["progress"] = advanced["progress"]
			frame["time"] = advanced["time"]
			frame["speed_scl"] = advanced["speed_scl"]
			frame["accum"] = advanced["accum"]
			frame["items"] = advanced["items"]
			frame["deconstructing"] = advanced["deconstructing"]
			frame["payload"] = advanced["payload"]
			frame["pay_vector"] = advanced["pay_vector"]
			frame["pay_rotation"] = advanced["pay_rotation"]
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
