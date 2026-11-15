extends RefCounted
class_name SourcePayloadMassDriverBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_move_out_payload_state := preload("res://src/game/SourceBlockProducerMoveOutPayloadState.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")

# The PayloadMassDriver implementation (PayloadMassDriver.java:23, `public class PayloadMassDriver extends PayloadBlock{`): payload-mass-driver (hasPower = true;, consumePower(0.5f);, size 3, reload 130f, chargeTime 90f, range 700f, maxPayloadSize 2.5f, Blocks.java:6617-6627). PayloadMassDriver sets hasPower=true, update=true, solid=true, configurable=true, outputsPayload=true, rotate=true (PayloadMassDriver.java:54-67), range 100f / reload 30f / chargeTime 100f / maxPayloadSize 3 class defaults (PayloadMassDriver.java:24-30, `public float chargeTime = 100f;`). PayloadMassDriver extends PayloadBlock, NOT a drill or factory, so it cannot reuse an existing frame key; this driver uses its own family frame key ("source_payload_mass_driver_building", the mechanical-pump / beam-drill / mend-projector / overdrive-projector / force-projector / base-shield / regen-projector / constructor / payload-loader / payload-unloader precedent), and this slice adds the payload-mass-driver key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourcePayloadMassDriver* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the no-power skip (PayloadMassDriver.java:232, `if(efficiency <= 0f){`) follows the folded efficiency, with the efficiency-scaled rotation (PayloadMassDriver.java:248, `turretRotation = Angles.moveToward(turretRotation, angleTo(currentShooter()), rotateSpeed * efficiency);`) and the efficiency-scaled charge (PayloadMassDriver.java:289, `charge += edelta();`).
const SOURCE_PAYLOAD_MASS_DRIVER_BUILD_IMPLEMENTATIONS := ["PayloadMassDriver"]
const SOURCE_PAYLOAD_MASS_DRIVER_BUILDING_META_KEY := "source_payload_mass_driver_building"
# The payload-mass-driver def/class constants (two defs, Blocks.java:6617-6639):
# payload-mass-driver: `size = 3;` / `reload = 130f;` / `chargeTime = 90f;` /
# `range = 700f;` / `maxPayloadSize = 2.5f;` / `consumePower(0.5f);` (Blocks.java:6617-6628);
# large-payload-mass-driver: `size = 5;` / `reload = 130f;` / `chargeTime = 100f;` /
# `range = 2100f;` / `maxPayloadSize = 4f;` / `consumePower(3f);` (Blocks.java:6629-6639).
# The DEF reload 130f beats the class `public float reload = 30f;` (PayloadMassDriver.java:28);
# class: `public float grabWidth = 8f, grabHeight = 11/4f;` (PayloadMassDriver.java:31),
# `public float payloadSpeed = 0.7f, payloadRotateSpeed = 5f;` (PayloadBlock.java:18).
# `payloadMassDriver = new PayloadMassDriver("payload-mass-driver"){{` (Blocks.java:6617) /
# `largePayloadMassDriver = new PayloadMassDriver("large-payload-mass-driver"){{` (Blocks.java:6629).
# Class fields (PayloadMassDriver.java:24-31): `public float range = 100f;` (class; the DEFs win) /
# `public float rotateSpeed = 5f;` / `public float length = 89 / 8f;` (11.125) / `public float knockback = 5f;` /
# `public float chargeTime = 100f;` (class; the DEFs win: `chargeTime = 90f;` / `chargeTime = 100f;`, Blocks.java:6622/6634) /
# `public float maxPayloadSize = 3;` (class; the DEFs win: `maxPayloadSize = 2.5f;` / `maxPayloadSize = 4f;`, Blocks.java:6624/6636) /
# `public Effect transferEffect = new Effect(11f, 600f, e -> {` (PayloadMassDriver.java:40, lifetime 11f).
const SOURCE_PAYLOAD_MASS_DRIVER_GRAB_WIDTH := 8.0
const SOURCE_PAYLOAD_MASS_DRIVER_PAYLOAD_SPEED := 0.7
const SOURCE_PAYLOAD_MASS_DRIVER_PAYLOAD_ROTATE_SPEED := 5.0
const SOURCE_PAYLOAD_MASS_DRIVER_RELOAD := 130.0
const SOURCE_PAYLOAD_MASS_DRIVER_RANGE := 700.0
const SOURCE_PAYLOAD_MASS_DRIVER_ROTATE_SPEED := 5.0
const SOURCE_PAYLOAD_MASS_DRIVER_LENGTH := 11.125
const SOURCE_PAYLOAD_MASS_DRIVER_KNOCKBACK := 5.0
const SOURCE_PAYLOAD_MASS_DRIVER_TRANSFER_EFFECT_LIFETIME := 11.0
const SOURCE_PAYLOAD_MASS_DRIVER_CHARGE_TIME := 90.0
const SOURCE_PAYLOAD_MASS_DRIVER_CHARGE_TIME_LARGE := 100.0
const SOURCE_PAYLOAD_MASS_DRIVER_RANGE_LARGE := 2100.0
const SOURCE_PAYLOAD_MASS_DRIVER_MAX_PAYLOAD_SIZE := 3.0

static func _is_payload_mass_driver_build_implementation(implementation: String) -> bool:
	return SOURCE_PAYLOAD_MASS_DRIVER_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_payload_mass_driver_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The payload-mass-driver tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (PayloadMassDriver.java:23, `public class PayloadMassDriver extends PayloadBlock{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# payload-mass-driver skips consumption like Java's updateConsumption
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
	# for this payload-mass-driver (N2125); the tick preserves a disabled
	# payload-mass-driver instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	# A new PayloadDriverBuild starts unlinked and idle: `public int link = -1;` (PayloadMassDriver.java:133),
	# `public float turretRotation = 90;` (PayloadMassDriver.java:134),
	# `public float reloadCounter = 0f, charge = 0f;` (PayloadMassDriver.java:135),
	# `public float targetSize = grabWidth*2f, curSize = targetSize;` (PayloadMassDriver.java:136, 16.0),
	# `public float payLength = 0f, effectDelayTimer = -1f;` (PayloadMassDriver.java:137),
	# `public PayloadDriverBuild lastOther;` (PayloadMassDriver.java:138, null -- the port stores -1),
	# `public boolean loaded;` (PayloadMassDriver.java:139, false),
	# `public boolean charging;` (PayloadMassDriver.java:140, false),
	# `public PayloadDriverState state = idle;` (PayloadMassDriver.java:141),
	# `public Queue<Building> waitingShooters = new Queue<>();` (PayloadMassDriver.java:142, empty),
	# `public Payload recPayload;` (PayloadMassDriver.java:143, null),
	# `public @Nullable T payload;` (PayloadBlock.java:92, null) with
	# `public Vec2 payVector = new Vec2();` (PayloadBlock.java:94, (0, 0)) and
	# `public float payRotation;` (PayloadBlock.java:95, 0f).
	# The frame stores pay_vector as a {"x":, "y":} dict (the N2231
	# precedent -- the N2245 advance reads it that way); the N2246
	# branches read it as a Vector2 (the N2233 precedent), so the
	# tick wiring converts dict -> Vector2 before the branches call
	# and Vector2 -> dict on the write-back (union of the N2245 +
	# N2246 _initial_frame dicts, merged at integration).
	return {"link": -1, "turret_rotation": 90.0, "reload_counter": 0.0, "charge": 0.0, "target_size": 16.0, "cur_size": 16.0, "effect_delay_timer": -1.0, "pay_length": 0.0, "loaded": false, "charging": false, "state": "idle", "waiting_shooters": [], "rec_payload": null, "payload": null, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 0.0, "last_other": -1}

static func source_payload_mass_driver_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the payload-mass-driver frame meta key
	# ("source_payload_mass_driver_building"). A PayloadMassDriver sprite gets an
	# empty frame bound; the live-loop tick fills its keys every
	# tick. Any other block, or an already-bound sprite, binds
	# nothing.
	if block == null or not _is_payload_mass_driver_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_PAYLOAD_MASS_DRIVER_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_PAYLOAD_MASS_DRIVER_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_PAYLOAD_MASS_DRIVER_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func _to_short(value: int) -> int:
	# The Java (short) cast: truncate to the low 16 bits, then sign-extend (Point2.pack/unpack cast through short, arc Point2.java:35-42); GDScript ints are 64-bit, so the wrap is explicit. (N2245 may add the same helper on its branch -- the coordinator dedupes at integration.)
	var truncated: int = value & 0xFFFF
	if truncated >= 0x8000:
		return truncated - 0x10000
	return truncated

static func _point2_pack(x: int, y: int) -> int:
	# Point2.pack (arc Point2.java:40-42, `return (((short)x) << 16) | (((short)y) & 0xFFFF);`).
	return (_to_short(x) << 16) | (_to_short(y) & 0xFFFF)

static func _point2_unpack(pos: int) -> Vector2i:
	# Point2.unpack (arc Point2.java:35-37, `return new Point2((short)(pos >>> 16), (short)(pos & 0xFFFF));`).
	return Vector2i(_to_short(pos >> 16), _to_short(pos & 0xFFFF))

static func _payload_mass_driver_vec2_approach(pay_vector: Vector2, alpha: float) -> Vector2:
	# Vec2.approach(Vec2 target, float alpha) (Vec2.java:525-537),
	# target Vec2.ZERO here (PayloadBlock.java:194,
	# `payVector.approach(Vec2.ZERO, payloadSpeed * delta());`).
	# `float dx = x - target.x, dy = y - target.y;`
	# `float alpha2 = alpha*alpha;`
	# `float len2 = Mathf.len2(dx, dy);`
	# `if(len2 > alpha2){` scales the offset by
	# `Mathf.sqrt(alpha2 / len2)` and subtracts it, else
	# `return set(target);` snaps to the target.
	# (The N2233 deconstructor precedent, same port.)
	var dx: float = pay_vector.x
	var dy: float = pay_vector.y
	var alpha2: float = alpha * alpha
	var len2: float = dx * dx + dy * dy
	if len2 > alpha2:
		var scl: float = sqrt(alpha2 / len2)
		return Vector2(pay_vector.x - dx * scl, pay_vector.y - dy * scl)
	return Vector2.ZERO

static func _payload_mass_driver_move_in_payload(pay_vector: Vector2, pay_rotation: float, rot_deg: float, payload_rotate_speed: float, payload_speed: float, delta: float) -> Dictionary:
	# PayloadBlockBuild.moveInPayload() (PayloadBlock.java:181-197),
	# `public boolean moveInPayload(){` delegating to
	# `public boolean moveInPayload(boolean rotate){` with rotate=true.
	# `if(payload == null) return false;`
	# -- the caller checks the payload first, so this helper only
	# runs with a payload present. `updatePayload();` (:189) sets
	# the live payload position
	# `payload.set(x + payVector.x, y + payVector.y, payRotation);`
	# (PayloadBlock.java:174-177) -- DEFERRED, the port's payload
	# dict carries no position.
	# `payRotation = Angles.moveToward(payRotation, block.rotate ? rotdeg() : 90f, payloadRotateSpeed * delta());`
	# -- PayloadMassDriver has rotate=true (PayloadMassDriver.java:60),
	# so the target is rotdeg() (`return rotation * 90;`, BuildingComp.java:582-584),
	# passed in as rot_deg by the driver.
	# `payVector.approach(Vec2.ZERO, payloadSpeed * delta());`
	# `return hasArrived();`
	# `return payVector.isZero(0.01f);`
	# (PayloadBlock.java:242-244, Vec2.java:679-681)
	# `return len2() < margin;`
	# -- the SQUARED length, not the length.
	var rotated: float = source_math_state.source_angles_move_toward(pay_rotation, rot_deg, payload_rotate_speed * delta)
	var moved: Vector2 = _payload_mass_driver_vec2_approach(pay_vector, payload_speed * delta)
	return {"pay_vector": moved, "pay_rotation": rotated, "arrived": moved.length_squared() < 0.01}

static func _payload_mass_driver_charge_time_for_block(block_id: String) -> float:
	# chargeTime is a per-def field (`public float chargeTime = 100f;`, PayloadMassDriver.java:29):
	# payload-mass-driver 90f (`chargeTime = 90f;`, Blocks.java:6622),
	# large-payload-mass-driver 100f (`chargeTime = 100f;`, Blocks.java:6634).
	# (The N2233 deconstructor per-def helper precedent.)
	if block_id == "large-payload-mass-driver":
		return SOURCE_PAYLOAD_MASS_DRIVER_CHARGE_TIME_LARGE
	return SOURCE_PAYLOAD_MASS_DRIVER_CHARGE_TIME

static func _payload_mass_driver_range_for_block(block_id: String) -> float:
	# range is a per-def field (`public float range = 100f;`, PayloadMassDriver.java:24):
	# payload-mass-driver 700f (`range = 700f;`, Blocks.java:6623),
	# large-payload-mass-driver 2100f (`range = 2100f;`, Blocks.java:6635).
	if block_id == "large-payload-mass-driver":
		return SOURCE_PAYLOAD_MASS_DRIVER_RANGE_LARGE
	return SOURCE_PAYLOAD_MASS_DRIVER_RANGE

static func _payload_mass_driver_frame_pay_vector_as_vec2(frame: Dictionary) -> Vector2:
	# The frame stores pay_vector as a {"x":, "y":} dict (the N2231
	# precedent -- the N2245 advance reads it that way); the N2246
	# branches read it as a Vector2 (the N2233 precedent) -- convert
	# at the boundary (merged at integration). A Vector2 already in
	# the frame passes through; anything else falls back to ZERO.
	var value: Variant = frame.get("pay_vector", {"x": 0.0, "y": 0.0})
	if value is Vector2:
		return value
	if value is Dictionary:
		return Vector2(float(value.get("x", 0.0)), float(value.get("y", 0.0)))
	return Vector2.ZERO

static func _payload_mass_driver_vec2_as_frame_pay_vector(vec: Vector2) -> Dictionary:
	# The reverse conversion: the N2246 branches return pay_vector as
	# a Vector2; the frame stores the dict form.
	return {"x": vec.x, "y": vec.y}

static func source_payload_mass_driver_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a payload-mass-driver does not take the early return. The no-power skip follows the folded efficiency (PayloadMassDriver.java:232, `if(efficiency <= 0f){`), with the efficiency-scaled rotation (PayloadMassDriver.java:248, `turretRotation = Angles.moveToward(turretRotation, angleTo(currentShooter()), rotateSpeed * efficiency);`) and the efficiency-scaled charge (PayloadMassDriver.java:289, `charge += edelta();`) and the shouldConsume default (BuildingComp.java:755, `public boolean shouldConsume(){`) -- PayloadDriverBuild has no shouldConsume override, so the default applies.
	# Documented limits: (1) power-only first pass -- the payload-mass-driver power consumer is static (consumePower 0.5f, Blocks.java:6626; large 3f, Blocks.java:6637), so the folded efficiency is the min over the *modeled* consumers (power only); no dynamic consumer row is involved. (2) shouldConsume gate deferred -- PayloadDriverBuild has no shouldConsume override, so the BuildingComp default applies; the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent). (3) updateTile advance live (N2245) -- the frame/state part (PayloadMassDriver.java:155-234: link refresh / charge discharge / curSize-targetSize / effectDelayTimer state / charging reset / reloadCounter decay / waitingShooters cleanup / idle-accepting-shooting switch / dump) runs every tick after the consumption fold through the pure source_payload_mass_driver_update_tile_advance_state function; State branches live (N2246) -- the accepting + shooting branches (PayloadMassDriver.java:236-332, accepting bail/align, shooting load/fire gate, charge + transfer) run after the advance through the pure source_payload_mass_driver_state_branches_state function; the receive effects/sound/shake, the moveOutPayload world interaction (pushOutput/dumpPayload/movePayload) and the super.updateTile() payload update defer -- see DEFERRED. The power proof carries no link/state/charge keys; the N2245/N2246 proofs carry them. (4) No link/config rows -- link -1, config Point2/Integer, onConfigureBuildTapped, linkValid (PayloadMassDriver.java:64-65, 321-350) are config, not tick state. (5) acceptPayload gate live (N2298) -- PayloadDriverBuild.acceptPayload (PayloadMassDriver.java:462-463, `return super.acceptPayload(source, payload) && payload.size() <= maxPayloadSize * tilesize;`, class maxPayloadSize 3 / tilesize 8, threshold 24; the DEFERRED entry's :317-319 cite was wrong -- that range is the transfer reset) runs every tick through the pure source_payload_mass_driver_accept_payload_state function and exposes the verdict on the frame as accepts_payload from the frame-supplied offered_payload_size (no payload offered -> false); the per-def maxPayloadSize overrides (2.5f / 4f, Blocks.java:6624/6636) wait for their own slice -- see DEFERRED.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func _payload_mass_driver_shooter_valid(record: Dictionary) -> bool:
	# The inline shooter validity (PayloadMassDriver.java:199-202, no shooterValid helper here, unlike
	# MassDriver): `current instanceof PayloadDriverBuild entity &&` /
	# `current.isValid() &&` / `entity.efficiency > 0 && entity.block == block &&` /
	# `entity.link == pos() && within(current, range)`.
	# NOTE: unlike linkValid, the shooter check does NOT check the team. The record is the driver-gathered
	# per-shooter snapshot (is_payload_mass_driver / is_valid / efficiency / same_block / link_equals_self /
	# within_range).
	return bool(record.get("is_payload_mass_driver", false)) and bool(record.get("is_valid", false)) and float(record.get("efficiency", 0.0)) > 0.0 and bool(record.get("same_block", false)) and bool(record.get("link_equals_self", false)) and bool(record.get("within_range", false))

static func source_payload_mass_driver_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float, reload: float, grab_width: float, payload_speed: float, payload_rotate_speed: float, size_value: int, tilesize: float, rotdeg_value: float, tile_pos: int, linked: Dictionary, shooters: Dictionary) -> Dictionary:
	# The updateTile advance PART 1, frame + state switch (PayloadDriverBuild.updateTile(),
	# PayloadMassDriver.java:155-234, `public void updateTile(){`), on
	# `public class PayloadMassDriver extends PayloadBlock{` (PayloadMassDriver.java:23) /
	# `public class PayloadDriverBuild extends PayloadBlockBuild<Payload> implements RotBlock{` (PayloadMassDriver.java:132).
	# Build fields: `public int link = -1;` (PayloadMassDriver.java:133),
	# `public float turretRotation = 90;` (PayloadMassDriver.java:134),
	# `public float reloadCounter = 0f, charge = 0f;` (PayloadMassDriver.java:135),
	# `public float targetSize = grabWidth*2f, curSize = targetSize;` (PayloadMassDriver.java:136),
	# `public float payLength = 0f, effectDelayTimer = -1f;` (PayloadMassDriver.java:137),
	# `public PayloadDriverBuild lastOther;` (PayloadMassDriver.java:138),
	# `public boolean loaded;` (PayloadMassDriver.java:139),
	# `public boolean charging;` (PayloadMassDriver.java:140),
	# `public PayloadDriverState state = idle;` (PayloadMassDriver.java:141),
	# `public Queue<Building> waitingShooters = new Queue<>();` (PayloadMassDriver.java:142).
	# State enum: `idle, accepting, shooting;` (PayloadMassDriver.java:524).
	# Class fields: `public float range = 100f;` (PayloadMassDriver.java:24, the DEF `range = 700f;` /
	# `range = 2100f;`, Blocks.java:6623/6635, wins),
	# `public float reload = 30f;` (PayloadMassDriver.java:28, the DEF `reload = 130f;`, Blocks.java:6621/6633, wins),
	# `public float grabWidth = 8f, grabHeight = 11/4f;` (PayloadMassDriver.java:31).
	# PayloadBlock fields: `public float payloadSpeed = 0.7f, payloadRotateSpeed = 5f;` (PayloadBlock.java:18),
	# `public @Nullable T payload;` (PayloadBlock.java:92),
	# `public Vec2 payVector = new Vec2();` (PayloadBlock.java:94),
	# `public float payRotation;` (PayloadBlock.java:95).
	# Defs: `payloadMassDriver = new PayloadMassDriver("payload-mass-driver"){{` (Blocks.java:6617, size 3,
	# `chargeTime = 90f;`, `maxPayloadSize = 2.5f;`, `consumePower(0.5f);`) /
	# `largePayloadMassDriver = new PayloadMassDriver("large-payload-mass-driver"){{` (Blocks.java:6629, size 5,
	# `maxPayloadSize = 4f;`, `consumePower(3f);`).
	# Java order, step by step. `super.updateTile();` (PayloadMassDriver.java:156) calls PayloadBlock.updateTile
	# (PayloadBlock.java:158-162, `if(payload != null){` / `payload.update(null, this);`) -- the live payload
	# entity update, which defers (the port has no live payload entity yet); part 1 notes the call and advances
	# only the driver frame. `Building link = world.build(this.link);` / `boolean hasLink = linkValid();`
	# (PayloadMassDriver.java:157-158); linkValid (PayloadMassDriver.java:466-468, `protected boolean linkValid(){` with
	# `return link != -1 && world.build(this.link) instanceof PayloadDriverBuild other && other.block == block && other.team == team && within(other, range);`):
	# the linked dict carries the precomputed components (exists / is_payload_mass_driver / same_block / same_team /
	# within_range), the N2237 partner precedent; within is STRICT dst < range (Position.java:44-46, the N2229
	# verification); same_block is the BLOCK-id match -- the two defs are different blocks. The link is a CONFIG
	# link (player set through the config handlers,
	# `config(Point2.class, (PayloadDriverBuild tile, Point2 point) -> tile.link = Point2.pack(point.x + tile.tileX(), point.y + tile.tileY()));` (PayloadMassDriver.java:64)
	# and `config(Integer.class, (PayloadDriverBuild tile, Integer point) -> tile.link = point);` (PayloadMassDriver.java:65)) --
	# the port has no config UI, so link is a frame key (default -1) and live config fill defers.
	# Discharge when charging is not happening (PayloadMassDriver.java:161-164): `if(!charging){` /
	# `charge -= Time.delta * 10f;` / `if(charge < 0) charge = 0f;` -- RAW Time.delta, not edelta, so the
	# discharge runs even at efficiency 0; the charging flag is read BEFORE the :184 reset.
	# curSize + targetSize (PayloadMassDriver.java:166-171): `curSize = Mathf.lerpDelta(curSize, targetSize, 0.05f);`
	# (the lerp runs BEFORE targetSize is recomputed, through the shared source_lerp_delta) then
	# `targetSize = grabWidth*2f;` and `if(payload != null){` / `targetSize = payload.size();` -- payload.size()
	# is `return build.block.size * tilesize;` (BuildPayload.java:86-88), so the payload dict carries "size" in
	# world units.
	# effectDelayTimer (PayloadMassDriver.java:173-183, STATE only): `boolean pos = effectDelayTimer > 0;` /
	# `effectDelayTimer -= Time.delta;` (raw Time.delta again) /
	# `if(effectDelayTimer <= 0 && pos && lastOther != null){` / `reloadCounter = 1f;` -- the effect positioning
	# (`float cx = Angles.trnsx(other.turretRotation, length), cy = Angles.trnsy(other.turretRotation, length);`)
	# and `receiveEffect.at(x - cx/2f, y - cy/2f, turretRotation);` / `Effect.shake(shake, shake, this);` /
	# receiveSound defer (presentation, not state). `charging = false;` (PayloadMassDriver.java:184, the reset --
	# the N2246 shooting branch sets charging true when its fire gate passes). `if(hasLink){` /
	# `this.link = link.pos();` (PayloadMassDriver.java:186-188).
	# Reload, regardless of state (PayloadMassDriver.java:191-192): `reloadCounter -= edelta() / reload;` /
	# `if(reloadCounter < 0) reloadCounter = 0f;` -- edelta, so the decay stalls at no power; NO upper clamp
	# (unlike MassDriver's one-arg Mathf.clamp).
	# `var current = currentShooter();` (PayloadMassDriver.java:194, first of waitingShooters, null when empty --
	# `return waitingShooters.isEmpty() ? null : waitingShooters.first();`, PayloadMassDriver.java:146);
	# `if(current != null &&` / `!(` the inline validity / `)){` / `waitingShooters.removeFirst();`
	# (PayloadMassDriver.java:197-204) -- only the FIRST entry is cleaned, once per tick. waitingShooters is a
	# Queue: the port uses a list keeping insertion order. The validity is the private helper above
	# (PayloadMassDriver.java:199-202).
	# State switch (PayloadMassDriver.java:208-215): `if(state == idle){` /
	# `if(!waitingShooters.isEmpty() && payload == null){` / `state = accepting;` (PayloadMassDriver.java:210-211)
	# else if hasLink `state = shooting;` (PayloadMassDriver.java:212-213). Non-idle states are untouched here.
	# Dump when idle or accepting (PayloadMassDriver.java:218-229):
	# `if((state == idle || state == accepting) && payload != null){` /
	# `if(loaded){` / `payLength -= payloadSpeed * delta();` / `if(payLength <= 0f){` / `loaded = false;` /
	# `payVector.setZero();` / `payRotation = Angles.moveToward(payRotation, turretRotation + 180f, payloadRotateSpeed * delta());`
	# (PayloadMassDriver.java:219-224) -- payLength is NOT clamped at 0, it may go negative for one tick;
	# `}else if(effectDelayTimer <= 0){` / `moveOutPayload();` (PayloadMassDriver.java:226-227).
	# moveOutPayload (PayloadBlock.java:199-228, `public void moveOutPayload(){`) is ported in PURE vector/rotation
	# form only: `Vec2 dest = Tmp.v1.trns(rotdeg(), size * tilesize/2f);` /
	# `payRotation = Angles.moveToward(payRotation, rotdeg(), payloadRotateSpeed * delta());` /
	# `payVector.approach(dest, payloadSpeed * delta());` (PayloadBlock.java:204-207, through the shared
	# source_payload_move_out_dest / source_vec2_approach helpers) -- the front() query + pushOutput +
	# dumpPayload / movePayload (PayloadBlock.java:209-225) defer (no front tile / payload handoff in the port).
	# No-power skip (PayloadMassDriver.java:232-234): `if(efficiency <= 0f){` / `return;` -- everything above
	# already ran; the accepting/shooting branches below (:236-332) belong to N2246 and never run at no power.
	# delta() is `return Time.delta * timeScale;` (BuildingComp.java:1922-1924) and edelta() is
	# `return efficiency * delta();` (BuildingComp.java:1927-1929); source_delta is Time.delta in ticks
	# (seconds * 60 through game_source_delta, arc Time.java:26), never raw seconds; timeScale reads
	# `private transient float timeScale = 1f, timeScaleDuration;` (BuildingComp.java:98); efficiency is
	# `transient float efficiency;` (BuildingComp.java:85), default 0.0; rotdeg is `public float rotdeg(){` with
	# `return rotation * 90;` (BuildingComp.java:582-584). The advance runs after consumption, like Java's
	# Building.update() (BuildingComp.java:2274-2277, `updateConsumption();` then
	# `if(enabled || !block.noUpdateDisabled){` / `updateTile();`), and PayloadMassDriver has
	# `public boolean noUpdateDisabled = false;` (Block.java:170, the default), so Java runs updateTile()
	# even when disabled (the N2231 precedent). Returns the advanced self values; turret_rotation / last_other /
	# payload are read-only in part 1 (written by the N2246 branches / transfer / handlePayload) and are not
	# returned.
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var link: int = int(frame.get("link", -1))
	var charge: float = float(frame.get("charge", 0.0))
	var cur_size: float = float(frame.get("cur_size", grab_width * 2.0))
	var target_size: float = float(frame.get("target_size", grab_width * 2.0))
	var effect_delay_timer: float = float(frame.get("effect_delay_timer", -1.0))
	var charging: bool = bool(frame.get("charging", false))
	var reload_counter: float = float(frame.get("reload_counter", 0.0))
	var waiting_shooters: Array = (frame.get("waiting_shooters", []) as Array).duplicate(true)
	var state: String = str(frame.get("state", "idle"))
	var pay_length: float = float(frame.get("pay_length", 0.0))
	var pay_rotation: float = float(frame.get("pay_rotation", 0.0))
	var pay_vector: Dictionary = (frame.get("pay_vector", {"x": 0.0, "y": 0.0}) as Dictionary).duplicate(true)
	var loaded: bool = bool(frame.get("loaded", false))
	var last_other: int = int(frame.get("last_other", -1))
	var turret_rotation: float = float(frame.get("turret_rotation", 90.0))
	var payload: Variant = frame.get("payload", null)
	var payload_size: float = 0.0
	if payload != null and payload is Dictionary:
		payload_size = float(payload.get("size", 0.0))
	var delta: float = source_delta * time_scale
	var edelta: float = efficiency * delta
	var has_link: bool = link != -1 and bool(linked.get("exists", false)) and bool(linked.get("is_payload_mass_driver", false)) and bool(linked.get("same_block", false)) and bool(linked.get("same_team", false)) and bool(linked.get("within_range", false))
	if not charging:
		charge -= source_delta * 10.0
		if charge < 0.0:
			charge = 0.0
	cur_size = source_math_state.source_lerp_delta(cur_size, target_size, 0.05, source_delta)
	target_size = grab_width * 2.0
	if payload != null:
		target_size = payload_size
	var timer_was_positive: bool = effect_delay_timer > 0.0
	effect_delay_timer -= source_delta
	if effect_delay_timer <= 0.0 and timer_was_positive and last_other != -1:
		reload_counter = 1.0
	charging = false
	if has_link:
		link = int(linked.get("pos", link))
	reload_counter -= edelta / reload
	if reload_counter < 0.0:
		reload_counter = 0.0
	var current: Variant = waiting_shooters[0] if not waiting_shooters.is_empty() else null
	if current != null:
		var current_record: Variant = shooters.get(int(current), null)
		if current_record == null or not _payload_mass_driver_shooter_valid(current_record):
			waiting_shooters.remove_at(0)
	if state == "idle":
		if not waiting_shooters.is_empty() and payload == null:
			state = "accepting"
		elif has_link:
			state = "shooting"
	if (state == "idle" or state == "accepting") and payload != null:
		if loaded:
			pay_length -= payload_speed * delta
			if pay_length <= 0.0:
				loaded = false
				pay_vector = {"x": 0.0, "y": 0.0}
				pay_rotation = source_math_state.source_angles_move_toward(pay_rotation, turret_rotation + 180.0, payload_rotate_speed * delta)
		elif effect_delay_timer <= 0.0:
			var dest: Dictionary = source_move_out_payload_state.source_payload_move_out_dest(rotdeg_value, size_value * tilesize / 2.0)
			pay_rotation = source_math_state.source_angles_move_toward(pay_rotation, rotdeg_value, payload_rotate_speed * delta)
			pay_vector = source_move_out_payload_state.source_vec2_approach(float(pay_vector.get("x", 0.0)), float(pay_vector.get("y", 0.0)), float(dest.get("x", 0.0)), float(dest.get("y", 0.0)), payload_speed * delta)
	return {"link": link, "charge": charge, "cur_size": cur_size, "target_size": target_size, "effect_delay_timer": effect_delay_timer, "charging": charging, "reload_counter": reload_counter, "waiting_shooters": waiting_shooters, "state": state, "pay_length": pay_length, "pay_rotation": pay_rotation, "pay_vector": pay_vector, "loaded": loaded}

static func source_payload_mass_driver_state_branches_state(frame: Dictionary, source_delta: float, time_scale: float, charge_time: float, length: float, knockback: float, rotate_speed: float, payload_speed: float, payload_rotate_speed: float, rot_deg: float, tile_pos: int, self_x: float, self_y: float, linked: Dictionary, shooters: Dictionary) -> Dictionary:
	# The state branches (PayloadDriverBuild.updateTile(), PayloadMassDriver.java:232-332,
	# `public void updateTile(){`, on
	# `public class PayloadMassDriver extends PayloadBlock{` (PayloadMassDriver.java:23) /
	# `public class PayloadDriverBuild extends PayloadBlockBuild<Payload> implements RotBlock{` (PayloadMassDriver.java:132).
	# State enum (PayloadMassDriver.java:523-525): `idle, accepting, shooting;`.
	# currentShooter() (PayloadMassDriver.java:145-147):
	# `return waitingShooters.isEmpty() ? null : waitingShooters.first();`
	# -- the first of waitingShooters, null when empty.
	# No-power return (PayloadMassDriver.java:232-234): `if(efficiency <= 0f){` / `return;` -- the N2245
	# frame/state advance already ran before this; the branches below never run without power.
	# Accepting (PayloadMassDriver.java:236-248): `if(state == accepting){` /
	# `if(currentShooter() == null || payload != null){` / `state = idle;` / `return;` (PayloadMassDriver.java:238-240,
	# bail when nothing shoots at this or a payload is already held) else
	# `if(currentShooter().getPayload() != null){` /
	# `targetSize = recPayload == null ? currentShooter().getPayload().size() : recPayload.size();` (PayloadMassDriver.java:243-244,
	# the shooter payload size, or the recPayload size when recPayload is present; a BuildPayload size is
	# `return build.block.size * tilesize;`, BuildPayload.java:86-88, carried as the payload dict "size") then
	# `turretRotation = Angles.moveToward(turretRotation, angleTo(currentShooter()), rotateSpeed * efficiency);` (PayloadMassDriver.java:248).
	# A missing shooter record means the shooter sprite is gone: Java would rotate toward its stale position
	# for one tick, the port keeps the rotation and targetSize (the N2237 precedent).
	# Shooting (PayloadMassDriver.java:249-270): `}else if(state == shooting){` /
	# `if(!hasLink || (!waitingShooters.isEmpty() && payload == null)){` / `state = idle;` / `return;` (PayloadMassDriver.java:251-253,
	# bail with no link, or when someone wants to shoot at this thing while it holds nothing);
	# `float targetRotation = angleTo(link);` (PayloadMassDriver.java:256);
	# `payRotation = Angles.moveToward(payRotation, turretRotation, payloadRotateSpeed * delta());` (PayloadMassDriver.java:259, every shooting tick);
	# loaded: `float loadLength = length - reloadCounter *knockback;` / `payLength += payloadSpeed * delta();` /
	# `if(payLength >= loadLength){` / `payLength = loadLength;` (PayloadMassDriver.java:261-265, movedOut when the muzzle is reached);
	# not loaded: `}else if(moveInPayload()){` / `payLength = 0f;` / `loaded = true;` (PayloadMassDriver.java:267-269,
	# moveInPayload is PayloadBlock.java:181-197 with rotate=true -- see the helper above).
	# Fire gate (PayloadMassDriver.java:272-294):
	# `if(movedOut && payload != null && link.getPayload() == null){` /
	# `var other = (PayloadDriverBuild)link;` /
	# `if(!other.waitingShooters.contains(this)){` / `other.waitingShooters.addLast(this);` (PayloadMassDriver.java:276-278,
	# the cross-building write-back -- the driver writes the returned partner_waiting_shooters back onto the
	# linked frame, the N2237 precedent) then `if(reloadCounter <= 0){` /
	# `turretRotation = Angles.moveToward(turretRotation, targetRotation, rotateSpeed * efficiency);` (PayloadMassDriver.java:282) /
	# `if(other.currentShooter() == this &&` / `other.state == accepting &&` / `other.reloadCounter <= 0f &&` /
	# `Angles.within(turretRotation, targetRotation, 1f) && Angles.within(other.turretRotation, targetRotation + 180f, 1f)){` (PayloadMassDriver.java:285-288,
	# other.currentShooter() is the first of the UPDATED partner list after the add above, the turret check uses
	# the rotation AFTER this tick's moveToward, and Angles.within is <= -- `return angleDist(a, b) <= margin;`
	# (Arc Angles.java:19-21) -- unlike Angles.near, `return angleDist(a, b) < range;` (Arc Angles.java:29-31, STRICT <),
	# so the port uses the shared source_angles_within with no local helper).
	# Charge + fire (PayloadMassDriver.java:289-332): `charge += edelta();` / `charging = true;` (PayloadMassDriver.java:289-290) /
	# `if(charge >= chargeTime){` (PayloadMassDriver.java:292) /
	# `float cx = Angles.trnsx(turretRotation, length), cy = Angles.trnsy(turretRotation, length);` (PayloadMassDriver.java:294,
	# through the shared source_angles_trns_vec); the effects / sound / shake (:295-301) defer (presentation);
	# `other.recPayload = payload;` / `other.effectDelayTimer = transferEffect.lifetime;` (PayloadMassDriver.java:303-304, lifetime 11f) /
	# `other.handlePayload(this, pay);` (PayloadMassDriver.java:306; PayloadBlock.java:121-124,
	# `this.payload = (T)payload;` plus `this.payRotation = payload.rotation();` -- but the payVector / payRotation
	# writes handlePayload makes are overwritten in the same tick by :307-308 below, so the net transfer is the
	# payload plus the :307-310 values) / `other.lastOther = this;` /
	# `other.payVector.set(-cx, -cy);` / `other.payRotation = turretRotation;` / `other.payLength = length;` / `other.loaded = true;` /
	# `other.updatePayload();` (PayloadMassDriver.java:305-312, updatePayload only positions the live payload object --
	# no frame effect, the port payload dict carries no position) / `other.recPayload = null;` (PayloadMassDriver.java:314,
	# set at :303 and cleared here in the same tick, so recPayload is not a result key) /
	# `if(other.waitingShooters.size != 0 && other.waitingShooters.first() == this){` / `other.waitingShooters.removeFirst();` /
	# `other.state = idle;` (PayloadMassDriver.java:316-319) /
	# `payload = null;` / `payLength = 0f;` / `loaded = false;` / `state = idle;` / `reloadCounter = 1f;` (PayloadMassDriver.java:322-326,
	# the self reset -- the payload LEAVES the self frame the moment it fires). Charge is NOT reset on transfer:
	# Java leaves it >= chargeTime and the N2245 discharge drains it once charging stops.
	# hasLink is linkValid (PayloadMassDriver.java:490-492, `protected boolean linkValid(){` with
	# `return link != -1 && world.build(this.link) instanceof PayloadDriverBuild other && other.block == block && other.team == team && within(other, range);`):
	# the linked dict carries the precomputed components (exists / is_payload_mass_driver / same_block / same_team /
	# within_range), the N2237 partner precedent; same_block is the DEF match (payload-mass-driver vs
	# large-payload-mass-driver are different blocks), unlike the single-def MassDriver. within is STRICT dst2 <
	# range*range (Position.java:44-46, the N2229 verification).
	# delta() is `return Time.delta * timeScale;` (BuildingComp.java:1922-1924) and edelta() is
	# `return efficiency * delta();` (BuildingComp.java:1927-1929); source_delta is Time.delta in ticks
	# (seconds * 60 through game_source_delta, arc Time.java:26), never raw seconds; timeScale reads
	# `private transient float timeScale = 1f, timeScaleDuration;` (BuildingComp.java:98); efficiency is
	# `transient float efficiency;` (BuildingComp.java:85), default 0.0. rotdeg() is `return rotation * 90;`
	# (BuildingComp.java:582-584). The branches run after consumption, like Java's Building.update()
	# (BuildingComp.java:2274-2277, `updateConsumption();` then
	# `if(enabled || !block.noUpdateDisabled){` / `updateTile();`), and PayloadMassDriver has
	# `public boolean noUpdateDisabled = false;` (Block.java:170, the default), so Java runs updateTile()
	# even when disabled (the N2231 precedent). Returns the advanced self values plus the partner
	# write-back (partner_waiting_shooters / partner_state / partner_effect_delay_timer / partner_pay_vector /
	# partner_pay_rotation / partner_pay_length / partner_loaded / partner_payload / partner_last_other) plus
	# the fired flag; the driver writes both frames back. When nothing transfers the partner values echo
	# the linked inputs. (N2246 pure function position: after
	# source_payload_mass_driver_update_tile_advance_state in
	# Java order -- merged at integration, the N2245 function
	# precedes it.)
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var link: int = int(frame.get("link", -1))
	var state: String = str(frame.get("state", "idle"))
	var payload: Variant = frame.get("payload", null)
	var rec_payload: Variant = frame.get("rec_payload", null)
	var target_size: float = float(frame.get("target_size", 16.0))
	var turret_rotation: float = float(frame.get("turret_rotation", 90.0))
	var pay_rotation: float = float(frame.get("pay_rotation", 0.0))
	var pay_length: float = float(frame.get("pay_length", 0.0))
	var loaded: bool = bool(frame.get("loaded", false))
	var pay_vector: Vector2 = frame.get("pay_vector", Vector2.ZERO)
	var charge: float = float(frame.get("charge", 0.0))
	var charging: bool = bool(frame.get("charging", false))
	var reload_counter: float = float(frame.get("reload_counter", 0.0))
	var waiting_shooters: Array = (frame.get("waiting_shooters", []) as Array).duplicate(true)
	var partner_waiting_shooters: Array = (linked.get("waiting_shooters", []) as Array).duplicate(true)
	var partner_state: String = str(linked.get("state", "idle"))
	var partner_effect_delay_timer: float = float(linked.get("effect_delay_timer", -1.0))
	var partner_pay_vector: Vector2 = linked.get("pay_vector", Vector2.ZERO)
	var partner_pay_rotation: float = float(linked.get("pay_rotation", 0.0))
	var partner_pay_length: float = float(linked.get("pay_length", 0.0))
	var partner_loaded: bool = bool(linked.get("loaded", false))
	var partner_payload: Variant = linked.get("payload", null)
	var partner_last_other: Variant = linked.get("last_other", null)
	var fired: bool = false
	var delta: float = source_delta * time_scale
	var edelta: float = efficiency * delta
	var has_link: bool = link != -1 and bool(linked.get("exists", false)) and bool(linked.get("is_payload_mass_driver", false)) and bool(linked.get("same_block", false)) and bool(linked.get("same_team", false)) and bool(linked.get("within_range", false))
	if efficiency > 0.0:
		if state == "accepting":
			var shooter: Variant = waiting_shooters[0] if not waiting_shooters.is_empty() else null
			if shooter == null or payload != null:
				state = "idle"
			else:
				var shooter_record: Variant = shooters.get(int(shooter), null)
				if shooter_record != null:
					var shooter_payload: Variant = shooter_record.get("payload", null)
					if shooter_payload != null:
						if rec_payload == null:
							target_size = float(shooter_payload.get("size", target_size))
						else:
							target_size = float(rec_payload.get("size", target_size))
					var shooter_angle: float = source_math_state.source_angles_angle(self_x, self_y, float(shooter_record.get("x", 0.0)), float(shooter_record.get("y", 0.0)))
					turret_rotation = source_math_state.source_angles_move_toward(turret_rotation, shooter_angle, rotate_speed * efficiency)
		elif state == "shooting":
			if not has_link or (not waiting_shooters.is_empty() and payload == null):
				state = "idle"
			else:
				var target_rotation: float = source_math_state.source_angles_angle(self_x, self_y, float(linked.get("x", 0.0)), float(linked.get("y", 0.0)))
				var moved_out: bool = false
				pay_rotation = source_math_state.source_angles_move_toward(pay_rotation, turret_rotation, payload_rotate_speed * delta)
				if loaded:
					var load_length: float = length - reload_counter * knockback
					pay_length += payload_speed * delta
					if pay_length >= load_length:
						pay_length = load_length
						moved_out = true
				elif payload != null:
					var moved_in: Dictionary = _payload_mass_driver_move_in_payload(pay_vector, pay_rotation, rot_deg, payload_rotate_speed, payload_speed, delta)
					pay_vector = moved_in["pay_vector"]
					pay_rotation = moved_in["pay_rotation"]
					if bool(moved_in["arrived"]):
						pay_length = 0.0
						loaded = true
				if moved_out and payload != null and linked.get("payload", null) == null:
					if not partner_waiting_shooters.has(tile_pos):
						partner_waiting_shooters.append(tile_pos)
					if reload_counter <= 0.0:
						turret_rotation = source_math_state.source_angles_move_toward(turret_rotation, target_rotation, rotate_speed * efficiency)
						var partner_current: Variant = partner_waiting_shooters[0] if not partner_waiting_shooters.is_empty() else null
						if partner_current != null and int(partner_current) == tile_pos and partner_state == "accepting" and float(linked.get("reload_counter", 0.0)) <= 0.0 and source_math_state.source_angles_within(turret_rotation, target_rotation, 1.0) and source_math_state.source_angles_within(float(linked.get("turret_rotation", 90.0)), target_rotation + 180.0, 1.0):
							charge += edelta
							charging = true
							if charge >= charge_time:
								var trns: Dictionary = source_math_state.source_angles_trns_vec(turret_rotation, length, 0.0)
								var cx: float = float(trns.get("x", 0.0))
								var cy: float = float(trns.get("y", 0.0))
								partner_effect_delay_timer = SOURCE_PAYLOAD_MASS_DRIVER_TRANSFER_EFFECT_LIFETIME
								partner_payload = payload
								partner_last_other = tile_pos
								partner_pay_vector = Vector2(-cx, -cy)
								partner_pay_rotation = turret_rotation
								partner_pay_length = length
								partner_loaded = true
								if not partner_waiting_shooters.is_empty() and int(partner_waiting_shooters[0]) == tile_pos:
									partner_waiting_shooters.remove_at(0)
								partner_state = "idle"
								payload = null
								pay_length = 0.0
								loaded = false
								state = "idle"
								reload_counter = 1.0
								fired = true
	return {"state": state, "target_size": target_size, "turret_rotation": turret_rotation, "pay_rotation": pay_rotation, "pay_length": pay_length, "loaded": loaded, "pay_vector": pay_vector, "payload": payload, "charge": charge, "charging": charging, "reload_counter": reload_counter, "partner_waiting_shooters": partner_waiting_shooters, "partner_state": partner_state, "partner_effect_delay_timer": partner_effect_delay_timer, "partner_pay_vector": partner_pay_vector, "partner_pay_rotation": partner_pay_rotation, "partner_pay_length": partner_pay_length, "partner_loaded": partner_loaded, "partner_payload": partner_payload, "partner_last_other": partner_last_other, "fired": fired}

static func source_payload_mass_driver_accept_payload_state(payload_size: float, has_payload: bool) -> Dictionary:
	# PayloadDriverBuild.acceptPayload (PayloadMassDriver.java:462-463), on
	# `public class PayloadMassDriver extends PayloadBlock{` (PayloadMassDriver.java:23) /
	# `public class PayloadDriverBuild extends PayloadBlockBuild<Payload> implements RotBlock{` (PayloadMassDriver.java:132):
	# `public boolean acceptPayload(Building source, Payload payload){`
	# `return super.acceptPayload(source, payload) && payload.size() <= maxPayloadSize * tilesize;`
	# -- the base gate is PayloadBlock.acceptPayload (PayloadBlock.java:116-118):
	# `public boolean acceptPayload(Building source, Payload payload){`
	# `return this.payload == null;`
	# -- the driver accepts only while it holds no payload
	# (`public @Nullable T payload;`, PayloadBlock.java:92). The size gate
	# compares the offered payload size in world units against
	# `public float maxPayloadSize = 3;` (PayloadMassDriver.java:30) times
	# `public static final int tilesize = 8;` (Vars.java:135) -- the
	# class-default threshold is 3 * 8 = 24. A BuildPayload size is
	# `return build.block.size * tilesize;` (BuildPayload.java:86-88), so a
	# size-3 block payload measures 24 and sits exactly on the boundary
	# (the comparison is <=, so the boundary accepts). The offered size is
	# a frame input (there are no live Payload objects in the port);
	# has_payload reads the frame payload. The DEFERRED entry that scoped
	# this slice cited PayloadMassDriver.java:317-319 -- that range is the
	# transfer reset (other.state = idle, :316-319), NOT acceptPayload; the
	# correct cite is :462-463. The per-def maxPayloadSize overrides
	# (`maxPayloadSize = 2.5f;`, Blocks.java:6624, payload-mass-driver;
	# `maxPayloadSize = 4f;`, Blocks.java:6636, large-payload-mass-driver)
	# beat the class default in Java; this pure uses the class default
	# (threshold 24) and the per-def thresholds (20 / 32) wait for their
	# own slice -- see DEFERRED. Note the asymmetry with the
	# Loader/Deconstructor block-size fits checks: the PMD gate is
	# size-based in world units, not in block size.
	var threshold: float = SOURCE_PAYLOAD_MASS_DRIVER_MAX_PAYLOAD_SIZE * source_world_defaults.TILESIZE
	var size_fits: bool = payload_size <= threshold
	var accepts: bool = (not has_payload) and size_fits
	return {"accepts": accepts, "size_fits": size_fits, "threshold": threshold}


@warning_ignore("unused_parameter")
static func source_payload_mass_driver_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the payload-mass-driver tick wiring every
	# tick (PayloadDriverBuild.updateTile(), PayloadMassDriver.java:160,
	# gates on the no-power skip (PayloadMassDriver.java:232, `if(efficiency <= 0f){`) with the efficiency-scaled rotation (PayloadMassDriver.java:248) and the efficiency-scaled charge (PayloadMassDriver.java:289, `charge += edelta();`), so the no-power skip follows the folded efficiency; no placed-buildings driver ticks PayloadMassDriver blocks, so this driver is the placed-payload-mass-driver tick): each placed PayloadMassDriver build gets its frame keys refreshed from the live rules, so the frame's cheating flag tracks team.rules().cheat and the consumption machinery skips consumption for a cheating team. The frame is bound at placement; a sprite that somehow lacks one gets it bound here instead of crashing the loop.
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
		if not _is_payload_mass_driver_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_payload_mass_driver_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_payload_mass_driver_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a payload-mass-driver with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the no-power skip (PayloadMassDriver.java:232)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a payload-mass-driver does not take the early return. A payload-mass-driver with no power consumer is untouched: the tick models no other consumers yet (the dynamic power consumer row waits for its own slice), and there is no shouldConsume gate yet (PayloadDriverBuild has no shouldConsume override, so the BuildingComp default, BuildingComp.java:755, applies, but payload/link state is not tracked yet), so the machinery runs with should_consume=true when enabled. productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var should_consume: bool = bool(frame.get("enabled", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_payload_mass_driver_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		# The updateTile advance part 1 (N2245, PayloadMassDriver.java:155-234) and the
		# state branches (N2246, PayloadMassDriver.java:236-332): run after the
		# consumption fold -- the Java order, `updateConsumption();` then
		# `if(enabled || !block.noUpdateDisabled){` / `updateTile();` (BuildingComp.java:2274-2277) --
		# and WITHOUT an enabled guard: PayloadMassDriver has
		# `public boolean noUpdateDisabled = false;` (Block.java:170, the default), so
		# Java runs updateTile() even when disabled (the N2231 precedent: updateConsumption
		# folds efficiency to 0, so the edelta reload decay stalls and the branches
		# stall with it, while the charge discharge, the effect timer and the state
		# switch still run). The N2245 frame/state wiring runs BETWEEN the consumption
		# fold above and the N2246 branches below (the Java order inside updateTile(),
		# :155-234 before :236-332). The driver gathers the linked building snapshot
		# (the partner sprite through placed_blocks by the unpacked link cell,
		# Point2.unpack, arc Point2.java:35-37; a missing sprite or a partner that is not a
		# PayloadMassDriver fails the block match, the N2237 precedent) and the per-shooter
		# records for every waiting entry (the inline validity, PayloadMassDriver.java:199-202,
		# plus x / y / payload, the accepting angleTo target plus the targetSize source).
		# same_block is the BLOCK-id match -- the two defs are different blocks, so a
		# payload-mass-driver never links a large-payload-mass-driver (linkValid,
		# PayloadMassDriver.java:466-468, `other.block == block`). World coords are cell *
		# tile_size (Vars.tilesize 8, Vars.java:135; the game tile_size when set): both
		# endpoints are odd-sized drivers, so the block offset (Block.java:761, 0 for odd
		# sizes) cancels in the distance. within is STRICT dst < range (Position.java:44-46,
		# the N2229 verification); range reads the per-def helper (700f / 2100f large,
		# Blocks.java:6623/6635); reload / size read the catalog properties with the
		# small-def defaults (Blocks.java:6617-6628). chargeTime reads the per-def helper
		# (90f / 100f large, Blocks.java:6622/6634). rotdeg is `return rotation * 90;`
		# (BuildingComp.java:582-584) from the rotation meta -- the moveInPayload rotate
		# target (PayloadMassDriver has rotate=true). The source delta is Time.delta
		# in ticks: game_source_delta(game, seconds) is seconds * 60 (arc Time.java:26), never
		# raw seconds; timeScale reads live from the sprite meta, default 1.0
		# (BuildingComp.java:98). The pure branches return the advanced self values plus
		# the partner write-back, which the driver writes back to both frames (the N2237
		# precedent). pay_vector converts at the boundary: the frame stores the dict form
		# (N2245, the N2231 precedent), the branches read Vector2 (N2246, the N2233
		# precedent) -- see the conversion helpers below.
		var tile_size_value: Variant = game.get("tile_size")
		var tile_size: float = 8.0 if tile_size_value == null else float(tile_size_value)
		var this_pos: int = _point2_pack(cell.x, cell.y)
		var self_x: float = float(cell.x) * tile_size
		var self_y: float = float(cell.y) * tile_size
		var link_range: float = _payload_mass_driver_range_for_block(block_id)
		var reload_value: float = float(block.properties.get("reload", SOURCE_PAYLOAD_MASS_DRIVER_RELOAD))
		var size_value: int = int(block.properties.get("size", 3))
		var rotdeg_value: float = float(int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_ROTATION_META_KEY, 0))) * 90.0
		var rot_deg: float = rotdeg_value
		var charge_time: float = _payload_mass_driver_charge_time_for_block(block_id)
		var link_value: int = int(frame.get("link", -1))
		var other_cell: Vector2i = _point2_unpack(link_value)
		var placed_blocks_value: Variant = game.get("placed_blocks")
		var placed_blocks: Dictionary = placed_blocks_value if placed_blocks_value is Dictionary else {}
		var other_sprite: Variant = placed_blocks.get(game.call("cell_key", other_cell))
		var other_exists: bool = other_sprite != null and is_instance_valid(other_sprite) and other_sprite is Sprite2D
		var other_is_payload_mass_driver: bool = false
		var other_same_block: bool = false
		var other_teams_match: bool = false
		var other_block: Variant = null
		var partner_frame: Dictionary = {}
		if other_exists:
			var other_block_id: String = str(other_sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
			if blocks_by_id.has(other_block_id):
				other_block = blocks_by_id[other_block_id]
				other_is_payload_mass_driver = _is_payload_mass_driver_build_implementation(str(other_block.implementation))
				other_same_block = other_is_payload_mass_driver and other_block_id == block_id
			var other_team_id: int = int(other_sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
			other_teams_match = other_team_id == team_id
			if other_is_payload_mass_driver:
				var partner_bound: Dictionary = source_payload_mass_driver_bind_frame_state(other_sprite, other_block)
				partner_frame = partner_bound.get("frame", {})
		var other_x: float = float(other_cell.x) * tile_size
		var other_y: float = float(other_cell.y) * tile_size
		var other_within_range: bool = other_exists and source_math_state.source_dst(self_x, self_y, other_x, other_y) < link_range
		var linked: Dictionary = {"exists": other_exists, "pos": link_value, "is_payload_mass_driver": other_is_payload_mass_driver, "same_block": other_same_block, "same_team": other_teams_match, "within_range": other_within_range, "payload": null, "state": "idle", "turret_rotation": 90.0, "reload_counter": 0.0, "effect_delay_timer": -1.0, "pay_vector": Vector2.ZERO, "pay_rotation": 0.0, "pay_length": 0.0, "loaded": false, "last_other": null, "waiting_shooters": [], "x": other_x, "y": other_y}
		if other_exists and other_is_payload_mass_driver:
			linked["payload"] = partner_frame.get("payload", null)
			linked["state"] = str(partner_frame.get("state", "idle"))
			linked["turret_rotation"] = float(partner_frame.get("turret_rotation", 90.0))
			linked["reload_counter"] = float(partner_frame.get("reload_counter", 0.0))
			linked["effect_delay_timer"] = float(partner_frame.get("effect_delay_timer", -1.0))
			linked["pay_vector"] = _payload_mass_driver_frame_pay_vector_as_vec2(partner_frame)
			linked["pay_rotation"] = float(partner_frame.get("pay_rotation", 0.0))
			linked["pay_length"] = float(partner_frame.get("pay_length", 0.0))
			linked["loaded"] = bool(partner_frame.get("loaded", false))
			linked["last_other"] = partner_frame.get("last_other", null)
			linked["waiting_shooters"] = (partner_frame.get("waiting_shooters", []) as Array).duplicate(true)
		var shooters: Dictionary = {}
		for shooter_pos in frame.get("waiting_shooters", []):
			var shooter_cell: Vector2i = _point2_unpack(int(shooter_pos))
			var shooter_sprite: Variant = placed_blocks.get(game.call("cell_key", shooter_cell))
			var shooter_exists: bool = shooter_sprite != null and is_instance_valid(shooter_sprite) and shooter_sprite is Sprite2D
			var shooter_is_payload_mass_driver: bool = false
			var shooter_same_block: bool = false
			var shooter_efficiency: float = 0.0
			var shooter_link: int = -1
			var shooter_payload: Variant = null
			if shooter_exists:
				var shooter_block_id: String = str(shooter_sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
				if blocks_by_id.has(shooter_block_id):
					var shooter_block = blocks_by_id[shooter_block_id]
					shooter_is_payload_mass_driver = _is_payload_mass_driver_build_implementation(str(shooter_block.implementation))
					shooter_same_block = shooter_is_payload_mass_driver and shooter_block_id == block_id
					if shooter_is_payload_mass_driver:
						var shooter_bound: Dictionary = source_payload_mass_driver_bind_frame_state(shooter_sprite, shooter_block)
						var shooter_frame: Dictionary = shooter_bound.get("frame", {})
						shooter_efficiency = float(shooter_frame.get("efficiency", 0.0))
						shooter_link = int(shooter_frame.get("link", -1))
						shooter_payload = shooter_frame.get("payload", null)
			var shooter_x: float = float(shooter_cell.x) * tile_size
			var shooter_y: float = float(shooter_cell.y) * tile_size
			shooters[int(shooter_pos)] = {"is_payload_mass_driver": shooter_is_payload_mass_driver, "is_valid": shooter_exists, "efficiency": shooter_efficiency, "same_block": shooter_same_block, "link_equals_self": shooter_link == this_pos, "within_range": shooter_exists and source_math_state.source_dst(self_x, self_y, shooter_x, shooter_y) < link_range, "x": shooter_x, "y": shooter_y, "payload": shooter_payload}
		var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
		var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
		var advanced: Dictionary = source_payload_mass_driver_update_tile_advance_state(frame, source_delta, time_scale, reload_value, SOURCE_PAYLOAD_MASS_DRIVER_GRAB_WIDTH, SOURCE_PAYLOAD_MASS_DRIVER_PAYLOAD_SPEED, SOURCE_PAYLOAD_MASS_DRIVER_PAYLOAD_ROTATE_SPEED, size_value, tile_size, rotdeg_value, this_pos, linked, shooters)
		frame["link"] = advanced["link"]
		frame["charge"] = advanced["charge"]
		frame["cur_size"] = advanced["cur_size"]
		frame["target_size"] = advanced["target_size"]
		frame["effect_delay_timer"] = advanced["effect_delay_timer"]
		frame["charging"] = advanced["charging"]
		frame["reload_counter"] = advanced["reload_counter"]
		frame["waiting_shooters"] = advanced["waiting_shooters"]
		frame["state"] = advanced["state"]
		frame["pay_length"] = advanced["pay_length"]
		frame["pay_rotation"] = advanced["pay_rotation"]
		frame["pay_vector"] = advanced["pay_vector"]
		frame["loaded"] = advanced["loaded"]
		# The branches read pay_vector as a Vector2 -- convert the
		# dict the advance just wrote back (the frame stores the
		# dict form; the conversion back happens on the write-back
		# below).
		frame["pay_vector"] = _payload_mass_driver_frame_pay_vector_as_vec2(frame)
		var branched: Dictionary = source_payload_mass_driver_state_branches_state(frame, source_delta, time_scale, charge_time, SOURCE_PAYLOAD_MASS_DRIVER_LENGTH, SOURCE_PAYLOAD_MASS_DRIVER_KNOCKBACK, SOURCE_PAYLOAD_MASS_DRIVER_ROTATE_SPEED, SOURCE_PAYLOAD_MASS_DRIVER_PAYLOAD_SPEED, SOURCE_PAYLOAD_MASS_DRIVER_PAYLOAD_ROTATE_SPEED, rot_deg, this_pos, self_x, self_y, linked, shooters)
		frame["state"] = branched["state"]
		frame["target_size"] = branched["target_size"]
		frame["turret_rotation"] = branched["turret_rotation"]
		frame["pay_rotation"] = branched["pay_rotation"]
		frame["pay_length"] = branched["pay_length"]
		frame["loaded"] = branched["loaded"]
		frame["pay_vector"] = _payload_mass_driver_vec2_as_frame_pay_vector(branched["pay_vector"])
		frame["payload"] = branched["payload"]
		frame["charge"] = branched["charge"]
		frame["charging"] = branched["charging"]
		frame["reload_counter"] = branched["reload_counter"]
		if not partner_frame.is_empty():
			partner_frame["waiting_shooters"] = branched["partner_waiting_shooters"]
			partner_frame["state"] = branched["partner_state"]
			partner_frame["effect_delay_timer"] = branched["partner_effect_delay_timer"]
			partner_frame["pay_vector"] = _payload_mass_driver_vec2_as_frame_pay_vector(branched["partner_pay_vector"])
			partner_frame["pay_rotation"] = branched["partner_pay_rotation"]
			partner_frame["pay_length"] = branched["partner_pay_length"]
			partner_frame["loaded"] = branched["partner_loaded"]
			partner_frame["payload"] = branched["partner_payload"]
			partner_frame["last_other"] = branched["partner_last_other"]
		# The acceptPayload gate (N2298, PayloadMassDriver.java:462-463):
		# expose the verdict on the frame as accepts_payload, computed AFTER
		# the branches so it reads the post-tick payload (a payload that just
		# transferred out frees the gate in the same tick). The offered
		# payload size is a frame input (frame["offered_payload_size"], world
		# units -- there are no live Payload objects in the port); no payload
		# offered means nothing to accept, so the verdict defaults false.
		# has_payload is the frame payload (PayloadBlock.java:92,
		# `public @Nullable T payload;`).
		var offered_payload_size: Variant = frame.get("offered_payload_size", null)
		if offered_payload_size == null:
			frame["accepts_payload"] = false
		else:
			var accept_verdict: Dictionary = source_payload_mass_driver_accept_payload_state(float(offered_payload_size), frame.get("payload", null) != null)
			frame["accepts_payload"] = bool(accept_verdict.get("accepts", false))
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
