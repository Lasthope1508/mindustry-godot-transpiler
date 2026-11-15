extends RefCounted
class_name SourcePayloadMassDriverBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")

# The PayloadMassDriver implementation (PayloadMassDriver.java:23, `public class PayloadMassDriver extends PayloadBlock{`): payload-mass-driver (hasPower = true;, consumePower(0.5f);, size 3, reload 130f, chargeTime 90f, range 700f, maxPayloadSize 2.5f, Blocks.java:6617-6627). PayloadMassDriver sets hasPower=true, update=true, solid=true, configurable=true, outputsPayload=true, rotate=true (PayloadMassDriver.java:54-67), range 100f / reload 30f / chargeTime 100f / maxPayloadSize 3 class defaults (PayloadMassDriver.java:24-30, `public float chargeTime = 100f;`). PayloadMassDriver extends PayloadBlock, NOT a drill or factory, so it cannot reuse an existing frame key; this driver uses its own family frame key ("source_payload_mass_driver_building", the mechanical-pump / beam-drill / mend-projector / overdrive-projector / force-projector / base-shield / regen-projector / constructor / payload-loader / payload-unloader precedent), and this slice adds the payload-mass-driver key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourcePayloadMassDriver* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the no-power skip (PayloadMassDriver.java:232, `if(efficiency <= 0f){`) follows the folded efficiency, with the efficiency-scaled rotation (PayloadMassDriver.java:248, `turretRotation = Angles.moveToward(turretRotation, angleTo(currentShooter()), rotateSpeed * efficiency);`) and the efficiency-scaled charge (PayloadMassDriver.java:289, `charge += edelta();`).
const SOURCE_PAYLOAD_MASS_DRIVER_BUILD_IMPLEMENTATIONS := ["PayloadMassDriver"]
const SOURCE_PAYLOAD_MASS_DRIVER_BUILDING_META_KEY := "source_payload_mass_driver_building"
# The payload-mass-driver def/class constants (PayloadMassDriver.java:24-31):
# `public float range = 100f;` (class; the DEFs win: `range = 700f;` / `range = 2100f;`, Blocks.java:6623/6635) /
# `public float rotateSpeed = 5f;` / `public float length = 89 / 8f;` (11.125) / `public float knockback = 5f;` /
# `public float reload = 30f;` (class; the DEFs win: `reload = 130f;`, Blocks.java:6621/6633) /
# `public float chargeTime = 100f;` (class; the DEFs win: `chargeTime = 90f;` / `chargeTime = 100f;`, Blocks.java:6622/6634) /
# `public float maxPayloadSize = 3;` (class; the DEFs win: `maxPayloadSize = 2.5f;` / `maxPayloadSize = 4f;`, Blocks.java:6624/6636) /
# `public float grabWidth = 8f, grabHeight = 11/4f;` (targetSize starts at grabWidth*2f = 16) /
# `public Effect transferEffect = new Effect(11f, 600f, e -> {` (PayloadMassDriver.java:40, lifetime 11f) /
# `payloadMassDriver = new PayloadMassDriver("payload-mass-driver"){{` (Blocks.java:6617, `consumePower(0.5f);`) /
# `largePayloadMassDriver = new PayloadMassDriver("large-payload-mass-driver"){{` (Blocks.java:6629, `consumePower(3f);`).
# PayloadBlock class constants: `public float payloadSpeed = 0.7f, payloadRotateSpeed = 5f;` (PayloadBlock.java:18).
const SOURCE_PAYLOAD_MASS_DRIVER_ROTATE_SPEED := 5.0
const SOURCE_PAYLOAD_MASS_DRIVER_LENGTH := 11.125
const SOURCE_PAYLOAD_MASS_DRIVER_KNOCKBACK := 5.0
const SOURCE_PAYLOAD_MASS_DRIVER_PAYLOAD_SPEED := 0.7
const SOURCE_PAYLOAD_MASS_DRIVER_PAYLOAD_ROTATE_SPEED := 5.0
const SOURCE_PAYLOAD_MASS_DRIVER_TRANSFER_EFFECT_LIFETIME := 11.0
const SOURCE_PAYLOAD_MASS_DRIVER_CHARGE_TIME := 90.0
const SOURCE_PAYLOAD_MASS_DRIVER_CHARGE_TIME_LARGE := 100.0
const SOURCE_PAYLOAD_MASS_DRIVER_RANGE := 700.0
const SOURCE_PAYLOAD_MASS_DRIVER_RANGE_LARGE := 2100.0

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
	# `public float targetSize = grabWidth*2f, curSize = targetSize;` (PayloadMassDriver.java:136, grabWidth 8f so 16.0),
	# `public float payLength = 0f, effectDelayTimer = -1f;` (PayloadMassDriver.java:137),
	# `public PayloadDriverBuild lastOther;` (PayloadMassDriver.java:138, null),
	# `public boolean loaded;` (PayloadMassDriver.java:139, false),
	# `public boolean charging;` (PayloadMassDriver.java:140, false),
	# `public PayloadDriverState state = idle;` (PayloadMassDriver.java:141),
	# `public Queue<Building> waitingShooters = new Queue<>();` (PayloadMassDriver.java:142, empty),
	# `public Payload recPayload;` (PayloadMassDriver.java:143, null),
	# `public @Nullable T payload;` (PayloadBlock.java:92, null),
	# `public Vec2 payVector = new Vec2();` (PayloadBlock.java:94, ZERO),
	# `public float payRotation;` (PayloadBlock.java:95, 0f).
	# N2246 seeds every key its branches read; N2245 owns cur_size / effect_delay_timer / last_other --
	# the coordinator unions the two _initial_frame dicts at integration (this branch has no N2245 yet).
	return {"link": -1, "turret_rotation": 90.0, "reload_counter": 0.0, "charge": 0.0, "target_size": 16.0, "pay_length": 0.0, "loaded": false, "charging": false, "state": "idle", "waiting_shooters": [], "rec_payload": null, "payload": null, "pay_vector": Vector2.ZERO, "pay_rotation": 0.0}

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

static func source_payload_mass_driver_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a payload-mass-driver does not take the early return. The no-power skip follows the folded efficiency (PayloadMassDriver.java:232, `if(efficiency <= 0f){`), with the efficiency-scaled rotation (PayloadMassDriver.java:248, `turretRotation = Angles.moveToward(turretRotation, angleTo(currentShooter()), rotateSpeed * efficiency);`) and the efficiency-scaled charge (PayloadMassDriver.java:289, `charge += edelta();`) and the shouldConsume default (BuildingComp.java:755, `public boolean shouldConsume(){`) -- PayloadDriverBuild has no shouldConsume override, so the default applies.
	# Documented limits: (1) power-only first pass -- the payload-mass-driver power consumer is static (consumePower 0.5f, Blocks.java:6626; large 3f, Blocks.java:6637), so the folded efficiency is the min over the *modeled* consumers (power only); no dynamic consumer row is involved. (2) shouldConsume gate deferred -- PayloadDriverBuild has no shouldConsume override, so the BuildingComp default applies; the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent). (3) State branches live (N2246) -- the accepting + shooting branches (PayloadMassDriver.java:232-342, accepting bail/align, shooting load/fire gate, charge + transfer) run every tick after the consumption fold through the pure source_payload_mass_driver_state_branches_state function; the frame/state advance (link refresh / charge discharge / curSize lerp / effectDelayTimer / reload decay / shooter cleanup / state switch / dump, PayloadMassDriver.java:155-234) is N2245's slice and wires between the fold and the branches at integration. The N2164 power proof carries no link/state/charge keys; the N2246 proof carries them. (4) No link/config rows -- link -1, config Point2/Integer, onConfigureBuildTapped, linkValid (PayloadMassDriver.java:64-65, 321-350) are config, not tick state. (5) No acceptPayload rows -- acceptPayload fits maxPayloadSize (PayloadMassDriver.java:317-319) is payload acceptance, not tick state.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_payload_mass_driver_state_branches_state(frame: Dictionary, source_delta: float, time_scale: float, charge_time: float, length: float, knockback: float, rotate_speed: float, payload_speed: float, payload_rotate_speed: float, rot_deg: float, tile_pos: int, self_x: float, self_y: float, linked: Dictionary, shooters: Dictionary) -> Dictionary:
	# The state branches (PayloadDriverBuild.updateTile(), PayloadMassDriver.java:232-342,
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
	# Charge + fire (PayloadMassDriver.java:289-342): `charge += edelta();` / `charging = true;` (PayloadMassDriver.java:289-290) /
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
	# the linked inputs. (N2246 pure function position: after source_payload_mass_driver_power_status_row_state
	# in this branch -- N2245's advance function does not exist here yet; the coordinator orders N2245's
	# function before this one at integration.)
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
		# The state branches (N2246, PayloadMassDriver.java:232-342): run after the
		# consumption fold -- the Java order, `updateConsumption();` then
		# `if(enabled || !block.noUpdateDisabled){` / `updateTile();` (BuildingComp.java:2274-2277) --
		# and WITHOUT an enabled guard: PayloadMassDriver has
		# `public boolean noUpdateDisabled = false;` (Block.java:170, the default), so
		# Java runs updateTile() even when disabled (the N2231 precedent: updateConsumption
		# folds efficiency to 0, so the branches stall while the N2245 frame/state advance
		# still runs). INTEGRATION MARKER: the N2245 frame/state wiring goes BETWEEN the
		# consumption fold above and these branches (the Java order inside updateTile(),
		# :155-234 before :232-342); this branch has no N2245 yet, so the branches sit
		# right after the fold. The driver gathers the linked building snapshot (the
		# partner sprite through placed_blocks by the unpacked link cell, Point2.unpack,
		# arc Point2.java:35-37; a missing sprite or a partner that is not a
		# PayloadMassDriver fails the block match, the N2237 precedent) and the
		# per-shooter records for every waiting entry (x / y / payload, the accepting
		# angleTo target plus the targetSize source). World coords are cell *
		# tile_size (Vars.tilesize 8, Vars.java:135; the game tile_size when set).
		# within is STRICT dst < range (Position.java:44-46, the N2229 verification);
		# range reads the per-def helper (700f / 2100f large, Blocks.java:6623/6635).
		# same_block is the DEF match (the partner block id must equal this block id --
		# payload-mass-driver vs large-payload-mass-driver are different blocks),
		# unlike the single-def MassDriver. chargeTime reads the per-def helper
		# (90f / 100f large, Blocks.java:6622/6634). rot_deg is the sprite rotation
		# meta times 90 (`return rotation * 90;`, BuildingComp.java:582-584) -- the
		# moveInPayload rotate target (PayloadMassDriver has rotate=true). The source
		# delta is Time.delta in ticks: game_source_delta(game, seconds) is seconds *
		# 60 (arc Time.java:26), never raw seconds; timeScale reads live from the
		# sprite meta, default 1.0 (BuildingComp.java:98). The pure branches return
		# the advanced self values plus the partner write-back, which the driver
		# writes back to both frames (the N2237 precedent).
		var tile_size_value: Variant = game.get("tile_size")
		var tile_size: float = 8.0 if tile_size_value == null else float(tile_size_value)
		var this_pos: int = _point2_pack(cell.x, cell.y)
		var self_x: float = float(cell.x) * tile_size
		var self_y: float = float(cell.y) * tile_size
		var link_range: float = _payload_mass_driver_range_for_block(block_id)
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
				other_same_block = other_block_id == block_id
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
			linked["pay_vector"] = partner_frame.get("pay_vector", Vector2.ZERO)
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
			var shooter_payload: Variant = null
			if shooter_exists:
				var shooter_block_id: String = str(shooter_sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
				if blocks_by_id.has(shooter_block_id):
					var shooter_block = blocks_by_id[shooter_block_id]
					if _is_payload_mass_driver_build_implementation(str(shooter_block.implementation)):
						var shooter_bound: Dictionary = source_payload_mass_driver_bind_frame_state(shooter_sprite, shooter_block)
						var shooter_frame: Dictionary = shooter_bound.get("frame", {})
						shooter_payload = shooter_frame.get("payload", null)
			var shooter_x: float = float(shooter_cell.x) * tile_size
			var shooter_y: float = float(shooter_cell.y) * tile_size
			shooters[int(shooter_pos)] = {"x": shooter_x, "y": shooter_y, "payload": shooter_payload}
		var rot_deg: float = float(sprite.get_meta(source_block_geometry.SOURCE_BUILD_ROTATION_META_KEY, 0)) * 90.0
		var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
		var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
		var branched: Dictionary = source_payload_mass_driver_state_branches_state(frame, source_delta, time_scale, charge_time, SOURCE_PAYLOAD_MASS_DRIVER_LENGTH, SOURCE_PAYLOAD_MASS_DRIVER_KNOCKBACK, SOURCE_PAYLOAD_MASS_DRIVER_ROTATE_SPEED, SOURCE_PAYLOAD_MASS_DRIVER_PAYLOAD_SPEED, SOURCE_PAYLOAD_MASS_DRIVER_PAYLOAD_ROTATE_SPEED, rot_deg, this_pos, self_x, self_y, linked, shooters)
		frame["state"] = branched["state"]
		frame["target_size"] = branched["target_size"]
		frame["turret_rotation"] = branched["turret_rotation"]
		frame["pay_rotation"] = branched["pay_rotation"]
		frame["pay_length"] = branched["pay_length"]
		frame["loaded"] = branched["loaded"]
		frame["pay_vector"] = branched["pay_vector"]
		frame["payload"] = branched["payload"]
		frame["charge"] = branched["charge"]
		frame["charging"] = branched["charging"]
		frame["reload_counter"] = branched["reload_counter"]
		if not partner_frame.is_empty():
			partner_frame["waiting_shooters"] = branched["partner_waiting_shooters"]
			partner_frame["state"] = branched["partner_state"]
			partner_frame["effect_delay_timer"] = branched["partner_effect_delay_timer"]
			partner_frame["pay_vector"] = branched["partner_pay_vector"]
			partner_frame["pay_rotation"] = branched["partner_pay_rotation"]
			partner_frame["pay_length"] = branched["partner_pay_length"]
			partner_frame["loaded"] = branched["partner_loaded"]
			partner_frame["payload"] = branched["partner_payload"]
			partner_frame["last_other"] = branched["partner_last_other"]
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
