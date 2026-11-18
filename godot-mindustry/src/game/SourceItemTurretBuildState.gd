extends RefCounted
class_name SourceItemTurretBuildState

const source_turret_ammo_state := preload("res://src/game/SourceTurretAmmoState.gd")
const source_turret_defaults := preload("res://src/game/SourceTurretDefaults.gd")
const source_item_turret_build_io_state := preload("res://src/game/SourceItemTurretBuildIoState.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")

const SOURCE_ITEM_TURRET_BOOTSTRAP_FIRST_AMMO := source_turret_source_text_state.SOURCE_ITEM_TURRET_BOOTSTRAP_FIRST_AMMO
const SOURCE_ITEM_TURRET_GENERATED_CLASS := source_turret_source_text_state.SOURCE_ITEM_TURRET_GENERATED_CLASS
const SOURCE_ITEM_TURRET_CURRENT_AMMO_TYPE_SENSOR := source_turret_source_text_state.SOURCE_ITEM_TURRET_CURRENT_AMMO_TYPE_SENSOR
const SOURCE_ITEM_TURRET_BUILD_INNER_CLASS := source_turret_source_text_state.SOURCE_ITEM_TURRET_BUILD_INNER_CLASS
const SOURCE_TURRET_PRESENTATION_OVERRIDE_EXPR := source_turret_source_text_state.SOURCE_TURRET_PRESENTATION_OVERRIDE_EXPR
const SOURCE_ITEM_TURRET_ON_PROXIMITY_ADDED_METHOD := source_turret_source_text_state.SOURCE_ITEM_TURRET_ON_PROXIMITY_ADDED_METHOD
const SOURCE_ITEM_TURRET_ON_PROXIMITY_ADDED_SUPER_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_ON_PROXIMITY_ADDED_SUPER_EXPR
const SOURCE_ITEM_TURRET_ON_PROXIMITY_ADDED_COMMENT := source_turret_source_text_state.SOURCE_ITEM_TURRET_ON_PROXIMITY_ADDED_COMMENT
const SOURCE_ITEM_TURRET_ON_PROXIMITY_ADDED_GUARD_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_ON_PROXIMITY_ADDED_GUARD_EXPR
const SOURCE_ITEM_TURRET_ON_PROXIMITY_ADDED_HANDLE_ITEM_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_ON_PROXIMITY_ADDED_HANDLE_ITEM_EXPR
const SOURCE_ITEM_TURRET_SENSE_OBJECT_METHOD := source_turret_source_text_state.SOURCE_ITEM_TURRET_SENSE_OBJECT_METHOD
const SOURCE_ITEM_TURRET_SENSE_OBJECT_SWITCH_RETURN := source_turret_source_text_state.SOURCE_ITEM_TURRET_SENSE_OBJECT_SWITCH_RETURN
const SOURCE_ITEM_TURRET_SENSE_OBJECT_CURRENT_AMMO_TYPE_CASE := source_turret_source_text_state.SOURCE_ITEM_TURRET_SENSE_OBJECT_CURRENT_AMMO_TYPE_CASE
const SOURCE_ITEM_TURRET_SENSE_OBJECT_DEFAULT_CASE := source_turret_source_text_state.SOURCE_ITEM_TURRET_SENSE_OBJECT_DEFAULT_CASE
const SOURCE_ITEM_TURRET_GET_AMMO_CONTENT_METHOD := source_turret_source_text_state.SOURCE_ITEM_TURRET_GET_AMMO_CONTENT_METHOD
const SOURCE_ITEM_TURRET_GET_AMMO_CONTENT_RETURN_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_GET_AMMO_CONTENT_RETURN_EXPR
const SOURCE_ITEM_TURRET_GET_AMMO_FRACTION_METHOD := source_turret_source_text_state.SOURCE_ITEM_TURRET_GET_AMMO_FRACTION_METHOD
const SOURCE_ITEM_TURRET_GET_AMMO_FRACTION_RETURN_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_GET_AMMO_FRACTION_RETURN_EXPR
const SOURCE_ITEM_TURRET_ACCEPT_STACK_METHOD := source_turret_source_text_state.SOURCE_ITEM_TURRET_ACCEPT_STACK_METHOD
const SOURCE_ITEM_TURRET_ACCEPT_STACK_TYPE_LOOKUP := source_turret_source_text_state.SOURCE_ITEM_TURRET_ACCEPT_STACK_TYPE_LOOKUP
const SOURCE_ITEM_TURRET_ACCEPT_STACK_NULL_GUARD := source_turret_source_text_state.SOURCE_ITEM_TURRET_ACCEPT_STACK_NULL_GUARD
const SOURCE_ITEM_TURRET_ACCEPT_STACK_RETURN_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_ACCEPT_STACK_RETURN_EXPR
const SOURCE_ITEM_TURRET_HANDLE_STACK_METHOD := source_turret_source_text_state.SOURCE_ITEM_TURRET_HANDLE_STACK_METHOD
const SOURCE_ITEM_TURRET_HANDLE_STACK_LOOP_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_HANDLE_STACK_LOOP_EXPR
const SOURCE_ITEM_TURRET_HANDLE_STACK_HANDLE_ITEM_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_HANDLE_STACK_HANDLE_ITEM_EXPR
const SOURCE_ITEM_TURRET_REMOVE_STACK_METHOD := source_turret_source_text_state.SOURCE_ITEM_TURRET_REMOVE_STACK_METHOD
const SOURCE_ITEM_TURRET_REMOVE_STACK_COMMENT := source_turret_source_text_state.SOURCE_ITEM_TURRET_REMOVE_STACK_COMMENT
const SOURCE_ITEM_TURRET_REMOVE_STACK_RETURN_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_REMOVE_STACK_RETURN_EXPR

static func _item_turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_ITEM_TURRET_GENERATED_CLASS, generated_method, generated_args, null)

static func on_proximity_added_state(has_ammo: bool, cheating: bool, ammo_types_size: int, first_ammo_item: Variant) -> Dictionary:
	var should_handle_first_ammo: bool = (not has_ammo) and cheating and ammo_types_size > 0
	var handle_item_call: Dictionary = {}
	if should_handle_first_ammo:
		handle_item_call = {"call": SOURCE_ITEM_TURRET_BOOTSTRAP_FIRST_AMMO, "source": "this", "item": first_ammo_item}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_ON_PROXIMITY_ADDED_STATE,
		"inner_class": SOURCE_ITEM_TURRET_BUILD_INNER_CLASS,
		"method": SOURCE_ITEM_TURRET_ON_PROXIMITY_ADDED_METHOD,
		"override_expr": SOURCE_TURRET_PRESENTATION_OVERRIDE_EXPR,
		"super_on_proximity_added_expr": SOURCE_ITEM_TURRET_ON_PROXIMITY_ADDED_SUPER_EXPR,
		"comment": SOURCE_ITEM_TURRET_ON_PROXIMITY_ADDED_COMMENT,
		"guard_expr": SOURCE_ITEM_TURRET_ON_PROXIMITY_ADDED_GUARD_EXPR,
		"handle_item_expr": SOURCE_ITEM_TURRET_ON_PROXIMITY_ADDED_HANDLE_ITEM_EXPR,
		"has_ammo": has_ammo,
		"cheating": cheating,
		"ammo_types_size": ammo_types_size,
		"first_ammo_item": first_ammo_item,
		"should_handle_first_ammo": should_handle_first_ammo,
		"handle_item_call": handle_item_call,
		"super_on_proximity_added_called": true,
	}

static func generated_item_turret_build_on_proximity_added_bridge_state(has_ammo: bool, cheating: bool, ammo_types_size: int, first_ammo_item: Variant) -> Dictionary:
	var result = _item_turret_call("java_inner_class_ItemTurretBuild_method_onProximityAdded_0", [has_ammo, cheating, ammo_types_size, first_ammo_item])
	var canonical = on_proximity_added_state(has_ammo, cheating, ammo_types_size, first_ammo_item)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_ON_PROXIMITY_ADDED_STATE,
		"generated_owner": "item_turret.ItemTurretBuild.onProximityAdded",
		"result": result,
		"canonical": canonical,
		"matches": result.get("handle_item_call", null) == canonical.get("handle_item_call", null) and result.get("should_handle_first_ammo", null) == canonical.get("should_handle_first_ammo", null),
	}

static func sense_object_state(sensor: String, ammo_size: int, peek_item: Variant, super_sense_object_value: Variant) -> Dictionary:
	var sense_object_value: Variant = null
	if sensor == SOURCE_ITEM_TURRET_CURRENT_AMMO_TYPE_SENSOR:
		sense_object_value = peek_item if ammo_size > 0 else null
	else:
		sense_object_value = super_sense_object_value
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_SENSE_OBJECT_STATE,
		"inner_class": SOURCE_ITEM_TURRET_BUILD_INNER_CLASS,
		"method": SOURCE_ITEM_TURRET_SENSE_OBJECT_METHOD,
		"override_expr": SOURCE_TURRET_PRESENTATION_OVERRIDE_EXPR,
		"switch_return_expr": SOURCE_ITEM_TURRET_SENSE_OBJECT_SWITCH_RETURN,
		"current_ammo_type_case": SOURCE_ITEM_TURRET_SENSE_OBJECT_CURRENT_AMMO_TYPE_CASE,
		"default_case": SOURCE_ITEM_TURRET_SENSE_OBJECT_DEFAULT_CASE,
		"sensor": sensor,
		"ammo_size": ammo_size,
		"peek_item": peek_item,
		"super_sense_object_value": super_sense_object_value,
		"sense_object_value": sense_object_value,
	}

static func generated_item_turret_build_sense_object_bridge_state(sensor: String, ammo_size: int, peek_item: Variant, super_sense_object_value: Variant) -> Dictionary:
	var result = _item_turret_call("java_inner_class_ItemTurretBuild_method_senseObject_1", [sensor, ammo_size, peek_item, super_sense_object_value])
	var canonical = sense_object_state(sensor, ammo_size, peek_item, super_sense_object_value)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_SENSE_OBJECT_STATE,
		"generated_owner": "item_turret.ItemTurretBuild.senseObject",
		"result": result,
		"canonical": canonical,
		"matches": result.get("sense_object_value", null) == canonical.get("sense_object_value", null),
	}

static func get_ammo_content_state(ammo_size: int, peek_item: Variant) -> Dictionary:
	var ammo_content: Variant = peek_item if ammo_size > 0 else null
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_GET_AMMO_CONTENT_STATE,
		"inner_class": SOURCE_ITEM_TURRET_BUILD_INNER_CLASS,
		"method": SOURCE_ITEM_TURRET_GET_AMMO_CONTENT_METHOD,
		"override_expr": SOURCE_TURRET_PRESENTATION_OVERRIDE_EXPR,
		"return_expr": SOURCE_ITEM_TURRET_GET_AMMO_CONTENT_RETURN_EXPR,
		"ammo_size": ammo_size,
		"peek_item": peek_item,
		"ammo_content": ammo_content,
	}

static func generated_item_turret_build_get_ammo_content_bridge_state(ammo_size: int, peek_item: Variant) -> Dictionary:
	var result = _item_turret_call("java_inner_class_ItemTurretBuild_method_getAmmoContent_2", [ammo_size, peek_item])
	var canonical = get_ammo_content_state(ammo_size, peek_item)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_GET_AMMO_CONTENT_STATE,
		"generated_owner": "item_turret.ItemTurretBuild.getAmmoContent",
		"result": result,
		"canonical": canonical,
		"matches": result.get("ammo_content", null) == canonical.get("ammo_content", null),
	}

static func get_ammo_fraction_state(total_ammo: float, max_ammo: float) -> Dictionary:
	var ammo_fraction: float = total_ammo / max_ammo
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_GET_AMMO_FRACTION_STATE,
		"inner_class": SOURCE_ITEM_TURRET_BUILD_INNER_CLASS,
		"method": SOURCE_ITEM_TURRET_GET_AMMO_FRACTION_METHOD,
		"override_expr": SOURCE_TURRET_PRESENTATION_OVERRIDE_EXPR,
		"return_expr": SOURCE_ITEM_TURRET_GET_AMMO_FRACTION_RETURN_EXPR,
		"total_ammo": total_ammo,
		"max_ammo": max_ammo,
		"ammo_fraction": ammo_fraction,
	}

static func accept_stack_state(item: Variant, amount: int, max_ammo: float, total_ammo: float, ammo_multiplier: float, ammo_type_null: bool) -> Dictionary:
	var accept_stack: int = 0 if ammo_type_null else min(int((max_ammo - total_ammo) / ammo_multiplier), amount)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_ACCEPT_STACK_STATE,
		"inner_class": SOURCE_ITEM_TURRET_BUILD_INNER_CLASS,
		"method": SOURCE_ITEM_TURRET_ACCEPT_STACK_METHOD,
		"override_expr": SOURCE_TURRET_PRESENTATION_OVERRIDE_EXPR,
		"type_lookup": SOURCE_ITEM_TURRET_ACCEPT_STACK_TYPE_LOOKUP,
		"null_guard": SOURCE_ITEM_TURRET_ACCEPT_STACK_NULL_GUARD,
		"return_expr": SOURCE_ITEM_TURRET_ACCEPT_STACK_RETURN_EXPR,
		"item": item,
		"amount": amount,
		"max_ammo": max_ammo,
		"total_ammo": total_ammo,
		"ammo_multiplier": ammo_multiplier,
		"ammo_type_null": ammo_type_null,
		"accept_stack": accept_stack,
	}

static func handle_stack_state(item: Variant, amount: int) -> Dictionary:
	var handle_item_calls: Array = []
	for _i in range(amount):
		handle_item_calls.append({"call": SOURCE_ITEM_TURRET_HANDLE_STACK_HANDLE_ITEM_EXPR, "source": null, "item": item})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_HANDLE_STACK_STATE,
		"inner_class": SOURCE_ITEM_TURRET_BUILD_INNER_CLASS,
		"method": SOURCE_ITEM_TURRET_HANDLE_STACK_METHOD,
		"override_expr": SOURCE_TURRET_PRESENTATION_OVERRIDE_EXPR,
		"loop_expr": SOURCE_ITEM_TURRET_HANDLE_STACK_LOOP_EXPR,
		"handle_item_expr": SOURCE_ITEM_TURRET_HANDLE_STACK_HANDLE_ITEM_EXPR,
		"item": item,
		"amount": amount,
		"handle_item_calls": handle_item_calls,
		"handle_item_call_count": handle_item_calls.size(),
	}

static func remove_stack_state(item: Variant, amount: int) -> Dictionary:
	var removed_stack: int = 0
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_REMOVE_STACK_STATE,
		"inner_class": SOURCE_ITEM_TURRET_BUILD_INNER_CLASS,
		"comment": SOURCE_ITEM_TURRET_REMOVE_STACK_COMMENT,
		"method": SOURCE_ITEM_TURRET_REMOVE_STACK_METHOD,
		"override_expr": SOURCE_TURRET_PRESENTATION_OVERRIDE_EXPR,
		"return_expr": SOURCE_ITEM_TURRET_REMOVE_STACK_RETURN_EXPR,
		"item": item,
		"amount": amount,
		"removed_stack": removed_stack,
	}

static func handle_item_state(item: Variant, item_is_pyratite: bool, total_ammo: int, ammo_multiplier: float, ammo_type_null: bool, ammo_entries: Array) -> Dictionary:
	return source_turret_ammo_state.item_turret_build_handle_item_state(item, item_is_pyratite, total_ammo, ammo_multiplier, ammo_type_null, ammo_entries)

static func accept_item_state(item: Variant, total_ammo: int, max_ammo_value: float, ammo_multiplier: float, ammo_type_null: bool) -> Dictionary:
	return source_turret_ammo_state.item_turret_build_accept_item_state(item, total_ammo, max_ammo_value, ammo_multiplier, ammo_type_null)

static func _angle_dist(angle_a: float, angle_b: float) -> float:
	# Angles.angleDist (Angles.java:23-27, `return Math.min((a - b) < 0 ? a - b + 360 : a - b, (b - a) < 0 ? b - a + 360 : b - a);`):
	# the min forward/backward distance after mod 360 (Angles.java:19-21, `return angleDist(a, b) <= margin;`,
	# is Angles.within). Mirrors SourceMathState.source_angles_angle_dist.
	var a: float = fposmod(angle_a, 360.0)
	var b: float = fposmod(angle_b, 360.0)
	var forward: float = a - b + 360.0 if a - b < 0.0 else a - b
	var backward: float = b - a + 360.0 if b - a < 0.0 else b - a
	return minf(forward, backward)

static func _move_toward_angle(angle: float, to: float, speed: float) -> float:
	# Angles.moveToward (Angles.java:38-49, `if(Math.abs(angleDist(angle, to)) < speed) return to;`):
	# returns `to` outright when |angleDist| < speed, otherwise steps +-speed along the shorter arc
	# (angleDist is the min forward/backward distance after mod 360, Angles.java:22-27).
	# Mirrors SourceMathState.source_angles_move_toward.
	if absf(_angle_dist(angle, to)) < speed:
		return to
	angle = fposmod(angle, 360.0)
	to = fposmod(to, 360.0)
	var forward_distance: float = absf(angle - to)
	var backward_distance: float = 360.0 - absf(angle - to)
	if (angle > to) == (backward_distance > forward_distance):
		angle -= speed
	else:
		angle += speed
	return angle

static func _predict_quad(a: float, b: float, c: float) -> Variant:
	# Predict.quad (Predict.java:87-104, `private static Vec2 quad(float a, float b, float c){`):
	# the deterministic quadratic behind Predict.intercept
	# (`public static Vec2 intercept(float srcx, float srcy, float dstx, float dsty, float dstvx, float dstvy, float v){`,
	# Predict.java:28-51): `float a = dstvx * dstvx + dstvy * dstvy - v * v;` /
	# `float b = 2 * (dstvx * tx + dstvy * ty);` / `float c = tx * tx + ty * ty;` /
	# `float disc = b * b - 4 * a * c;` -- the two roots, or null when there is no
	# real solution (the bullet can never catch the target). The caller picks
	# the smallest positive root (`float t = Math.min(t0, t1);` / `if(t < 0) t = Math.max(t0, t1);` /
	# `if(t > 0){`, Predict.java:39-48).
	if absf(a) < 0.000001:
		if absf(b) < 0.000001:
			return [0.0, 0.0] if absf(c) < 0.000001 else null
		return [-c / b, -c / b]
	var disc: float = b * b - 4.0 * a * c
	if disc >= 0.0:
		disc = sqrt(disc)
		a = 2.0 * a
		return [(-b - disc) / a, (-b + disc) / a]
	return null

@warning_ignore("unused_parameter")
static func source_item_turret_validate_target_state(target_is_null: bool, target_same_team_effective: bool, target_health_valid: bool, target_unit_targetable: bool, controlled: bool, logic_controlled: bool) -> Dictionary:
	# validateTarget() (Turret.java:631-633, `return !Units.invalidateTarget(target, canHeal() ? Team.derelict : team, x, y) || controlled() || logicControlled();`):
	# the gate at the top of TurretBuild.updateTile() (`if(!validateTarget()) target = null;`, Turret.java:491)
	# and the aim/shoot branch (`if(validateTarget()){`, Turret.java:573). It calls the no-range overload
	# (`return invalidateTarget(target, team, x, y, Float.MAX_VALUE);`, Units.java:160-162), so the range clause
	# (`(range != Float.MAX_VALUE && !target.within(x, y, range + (target instanceof Sized hb ? hb.hitSize()/2f : 0f))) ||`,
	# Units.java:153) is dead here and the pure function takes NO range param. The four live invalidate clauses
	# (Units.java:151-157) are: target null (`return target == null ||`), same effective team
	# (`(target instanceof Teamc t && t.team() == team) ||`), dead Healthc (`(target instanceof Healthc h && !h.isValid()) ||`),
	# untargetable Unit (`(target instanceof Unit u && !u.targetable(team));`). The effective team is Team.derelict
	# (id 0, `derelict = new Team(0, "derelict", Color.valueOf("4d4e58")),`, Team.java:33) when canHeal()
	# (`return targetHealing && hasAmmo() && peekAmmo().collidesTeam && peekAmmo().heals();`, Turret.java:635-637)
	# and the turret team otherwise; the resolution happens at the driver/test, NOT in the pure function.
	# targetHealing defaults false (`public boolean targetHealing = false;`, Turret.java:95) and duo never sets it
	# (Blocks.java:3257-3324), so for duo the effective team is always the turret team. controlled()
	# (`public boolean controlled(){` / `return unit.isPlayer();`, Turret.java:441-443) and logicControlled()
	# (`public boolean logicControlled(){` / `return logicControlTime > 0;`, Turret.java:445-447) each rescue
	# the verdict even for a null target, exactly as Java's `||` does. findTarget (Turret.java:651-662) is
	# NOT this slice -- it needs the live entity scan and waits for its own slice.
	var invalidate: bool = target_is_null or target_same_team_effective or not target_health_valid or not target_unit_targetable
	var valid: bool = not invalidate or controlled or logic_controlled
	return {"valid": valid, "target_cleared": not valid}

@warning_ignore("unused_parameter")
static func source_item_turret_bullet_spawn_state(shoot_event: Dictionary, x: float, y: float, target_pos: Variant, barrel_counter: int, shoot_x: float, shoot_y: float, spread: float, barrels: int, barrel_offset: int, mirror: bool, x_spread: float, inaccuracy_draw: float, bullet_speed: float, bullet_damage: float, bullet_lifetime: float, bullet_hit_size: float, range: float) -> Dictionary:
	# TurretBuild.bullet() (Turret.java:779-801, `protected void bullet(BulletType type, float xOffset, float yOffset, float angleOffset, Mover mover){`):
	# one bullet per pattern handler call. shoot() hands the pattern the handler
	# (`pattern.shoot(barrelCounter, (xOffset, yOffset, angle, delay, mover) -> {`, Turret.java:754 --
	# `protected void shoot(BulletType type){`, Turret.java:742 -- with `queuedBullets++;` in shoot(),
	# Turret.java:753, and `queuedBullets --;` at the head of bullet(), Turret.java:780).
	# ShootAlternate picks one barrel per shot (`float index = ((totalShots + i + barrelOffset) % barrels) - (barrels-1)/2f;` /
	# `handler.shoot(index * spread * -Mathf.sign(mirror), 0, 0f, firstShotDelay + shotDelay * i);`,
	# ShootAlternate.java:31-37 -- duo barrels 2 (`public int barrels = 2;`, ShootAlternate.java:8), spread 3.5
	# (`shoot = new ShootAlternate(3.5f);`, Blocks.java:3293), barrelOffset 0 (`public int barrelOffset = 0;`,
	# ShootAlternate.java:10), mirror false (`public boolean mirror = false;`, ShootAlternate.java:12);
	# `Mathf.sign(boolean b)` is `return b ? 1 : -1;` (Mathf.java:203-205), so sign(false) is -1 and
	# -sign(false) is +1: xOffset is index * 3.5, barrel 0 (index -0.5) gives -1.75 and barrel 1 (index +0.5)
	# gives +1.75. Shots 1 (`public int shots = 1;`, ShootPattern.java:9), firstShotDelay 0
	# (`public float firstShotDelay = 0;`, ShootPattern.java:11), shotDelay 0 (`public float shotDelay = 0;`,
	# ShootPattern.java:13), so delay is 0 and bullet() runs at once (`if(delay > 0f){` queues, `else{` calls
	# `bullet(type, xOffset, yOffset, angle, mover);`, Turret.java:759-768). The incrementer runs after
	# pattern.shoot (`}, () -> barrelCounter++);`, Turret.java:770), so bullet() sees the pre-increment
	# barrelCounter, and `if(consumeAmmoOnce){` useAmmo already ran in shoot() (Turret.java:771-776).
	# The early return (`if(dead || (!consumeAmmoOnce && !hasAmmo())) return;`, Turret.java:781) is dead
	# for duo: consumeAmmoOnce is true, and the updateTile hasAmmo gate (Turret.java:548) already guards
	# the shot. `xSpread = Mathf.range(xRand),` (Turret.java:782 -- `public float xRand = 0f;`,
	# Turret.java:68, so xSpread is 0 for duo but stays a param for later defs;
	# `Mathf.range(float range)` is `return random(-range, range);`, Mathf.java:220-222). The origin
	# (`bulletX = x + Angles.trnsx(rotation - 90, shootX + xOffset + xSpread, shootY + yOffset),` /
	# `bulletY = y + Angles.trnsy(rotation - 90, shootX + xOffset + xSpread, shootY + yOffset),`,
	# Turret.java:783-784) is NOT recomputed from x/y here: the N2250 shoot_event already carries
	# bullet_x/bullet_y (`bulletX = x + Angles.trnsx(rotation - 90, shootX, shootY),`, Turret.java:744),
	# and Angles.trnsx/trnsy rotate the (x, y) vector (`return rv.set(x, y).rotate(angle).x;` /
	# `return rv.set(x, y).rotate(angle).y;`, Angles.java:74-80), so the rotation is linear in the offset:
	# bullet_x is shoot_event.bullet_x plus (xOffset + xSpread) rotated by rotation - 90. The angle is
	# (`shootAngle = rotation + angleOffset + Mathf.range(inaccuracy + type.inaccuracy);`, Turret.java:786 --
	# the class default is `public float inaccuracy = 0f;`, Turret.java:58, the duo override is
	# `inaccuracy = 2f;`, Blocks.java:3320, and type inaccuracy is 0f (`public float inaccuracy = 0f;`,
	# BulletType.java:93), so the draw is +-2 degrees; angleOffset is 0 with ShootAlternate). lifeScl is
	# (`float lifeScl = type.scaleLife ? Mathf.clamp((1 + scaleLifetimeOffset) * Mathf.dst(bulletX, bulletY, targetPos.x, targetPos.y) / type.range, minRange() / type.range, range() / type.range) : 1f;`,
	# Turret.java:787 -- `public boolean scaleLife;`, BulletType.java:141, defaults false, and the duo def
	# never sets it, so lifeScl is 1.0 for duo; `public float scaleLifetimeOffset = 0f;`, Turret.java:62).
	# The create is (`handleBullet(type.create(this, team, bulletX, bulletY, shootAngle, -1f, (1f - velocityRnd) + Mathf.random(velocityRnd), lifeScl, null, mover, targetPos.x, targetPos.y), xOffset, yOffset, shootAngle - rotation);`,
	# Turret.java:790 -- `public float velocityRnd = 0f;`, Turret.java:60, so the velocity factor is 1.0;
	# handleBullet is a no-op on TurretBuild (`protected void handleBullet(@Nullable Bullet bullet, float offsetX, float offsetY, float angleOffset){`,
	# Turret.java:818-820)). type.create stamps the live bullet (`bullet.initVel(angle, speed * velocityScl * (velocityScaleRandMin != 1f || velocityScaleRandMax != 1f ? Mathf.random(velocityScaleRandMin, velocityScaleRandMax) : 1f));`,
	# BulletType.java:964 -- initVel is `vel.trns(angle, amount);`, BulletComp.java:329-331, i.e. Vec2.trns is
	# `return set(amount, 0).rotate(angle);`, Vec2.java:40-42, so the velocity is dir(angle) * speed;
	# `bullet.lifetime = lifetime * lifetimeScl * (lifeScaleRandMin != 1f || lifeScaleRandMax != 1f ? Mathf.random(lifeScaleRandMin, lifeScaleRandMax) : 1f);`, BulletType.java:968;
	# `bullet.damage = (damage < 0 ? this.damage : damage) * bullet.damageMultiplier();`, BulletType.java:972;
	# `bullet.hitSize = hitSize;`, BulletType.java:971). Class defaults are shootX 0f / shootY -INF
	# (`public float shootX = 0f, shootY = Float.NEGATIVE_INFINITY;`, Turret.java:66 -- duo shootY 3f,
	# `shootY = 3f;`, Blocks.java:3313), range 160 (`range = 160;`, Blocks.java:3316). Duo ammo is copper
	# `Items.copper,  new BasicBulletType(2.5f, 9){{` (Blocks.java:3260 -- note the double space), graphite
	# `Items.graphite, new BasicBulletType(3.5f, 18){{` (:3270), silicon `Items.silicon, new BasicBulletType(3f, 12){{`
	# (:3282), each with `lifetime = 60f;` in Java; the catalog ammo entries the driver reads carry damage /
	# speed / lifetime (copper 9 / 2.5 / 70.0, graphite 18 / 3.5 / 54.57142857142857, silicon 12 / 3.0 /
	# 58.333333333333336 -- the catalog lifetime is converted from range/speed, NOT the Java 60f, and the
	# driver takes it from ammo_data). BulletType defaults are lifetime 40f (`public float lifetime = 40f;`,
	# BulletType.java:33), hitSize 4 (`public float hitSize = 4;`, BulletType.java:43), speed 1f
	# (`public float speed = 1f;`, BulletType.java:37). The effects/sound
	# (`(shootEffect == null ? type.shootEffect : shootEffect).at(bulletX, bulletY, rotation + angleOffset, type.hitColor);` /
	# `(smokeEffect == null ? type.smokeEffect : smokeEffect).at(bulletX, bulletY, rotation + angleOffset, type.hitColor);` /
	# `(type.shootSound != Sounds.none ? type.shootSound : shootSound).at(bulletX, bulletY, Mathf.random(soundPitchMin, soundPitchMax), shootSoundVolume);`, Turret.java:792-800),
	# recoil/heat/totalShots (`curRecoil = 1f;` / `heat = 1f;` / `totalShots++;`, Turret.java:804-812),
	# queuedBullets when shotDelay > 0, scaleLife=true defs, consumeAmmoOnce=false defs, and findTarget
	# are NOT this slice -- they wait for their own slices. The result is an 11-key dict: `bullet_x` /
	# `bullet_y` (the spawn origin), `shoot_angle` (rotation + inaccuracy_draw, angleOffset 0 with
	# ShootAlternate), `x_offset` (the barrel offset), `velocity` (dir(shoot_angle) * speed * 1.0, Java
	# per-tick units -- the runtime bridge multiplies by TICKS_PER_SECOND 60 for the live dict),
	# `speed` / `damage` / `hit_size` (from ammo_data), `lifetime_remaining` (lifetime * lifeScl, ticks --
	# the bridge divides by 60 for the live dict), `life_scl` (1.0 for duo), `barrel` (the pre-increment
	# barrelCounter -- pattern.shoot runs before the `}, () -> barrelCounter++);` incrementer,
	# Turret.java:770). `target_pos`, `shoot_x`, `shoot_y` and `range` are carried for source-completeness
	# (the lifeScl clamp reads targetPos/range, the shoot_event already includes shootX/shootY) and are
	# unused while the scaleLife branch is dead for duo; the pure function itself never calls randf --
	# `x_spread` and `inaccuracy_draw` are params the driver/test supplies.
	var index: float = float((barrel_counter + barrel_offset) % barrels) - float(barrels - 1) / 2.0
	var mirror_factor: float = -1.0 if mirror else 1.0
	var x_offset: float = index * spread * mirror_factor
	var rotation: float = float(shoot_event.get("rotation", 90.0))
	var angle_rad: float = deg_to_rad(rotation - 90.0)
	var bullet_x: float = float(shoot_event.get("bullet_x", x)) + (x_offset + x_spread) * cos(angle_rad)
	var bullet_y: float = float(shoot_event.get("bullet_y", y)) + (x_offset + x_spread) * sin(angle_rad)
	var shoot_angle: float = rotation + inaccuracy_draw
	var velocity: Vector2 = Vector2(cos(deg_to_rad(shoot_angle)), sin(deg_to_rad(shoot_angle))) * bullet_speed
	var life_scl: float = 1.0
	return {"bullet_x": bullet_x, "bullet_y": bullet_y, "shoot_angle": shoot_angle, "x_offset": x_offset, "velocity": velocity, "speed": bullet_speed, "damage": bullet_damage, "hit_size": bullet_hit_size, "lifetime_remaining": bullet_lifetime * life_scl, "life_scl": life_scl, "barrel": barrel_counter}

@warning_ignore("unused_parameter")
static func source_item_turret_aim_shoot_state(frame: Dictionary, target: Variant, target_valid: bool, team_id: int, x: float, y: float, delta: float, potential_efficiency: float, shoot_warmup: float, charging: bool, ammo_entries: Array, total_ammo: int, barrel_counter: int, range: float, rotate_speed: float, reload: float, shoot_cone: float, shoot_x: float, shoot_y: float, inaccuracy: float, ammo_per_shot: int, consume_ammo_once: bool, reload_multiplier: float, range_change: float, bullet_speed: float, predict_target: bool, min_warmup: float, always_shooting: bool, cheating: bool, base_reload_speed: float) -> Dictionary:
	# The duo half of TurretBuild.updateTile() (Turret.java:490-615).
	# ItemTurret does NOT override updateTile (`public class ItemTurret extends Turret{`,
	# ItemTurret.java:23 -- it only overrides ammo), so the whole aim / reload / shoot
	# lives here, following the N2240 PointDefense precedent. The reload charges every
	# tick (`reloadCounter += delta() * ammoReloadMultiplier() * baseReloadSpeed();` /
	# `reloadCounter = Math.min(reloadCounter, reload);`, Turret.java:719-724 --
	# reloadWhileCharging defaults true, Turret.java:82, so updateReload always runs;
	# ammoReloadMultiplier is the peeked ammo's reloadMultiplier when there is ammo,
	# else 1f, Turret.java:727-729; baseReloadSpeed is efficiency,
	# ReloadTurret.java:45-47, `return efficiency;`, passed in precomputed).
	# The aim/shoot half runs only with a valid target (`if(validateTarget()){`,
	# Turret.java:573 -- `if(!validateTarget()) target = null;`, Turret.java:491,
	# and validateTarget is `return !Units.invalidateTarget(target, canHeal() ? Team.derelict : team, x, y) || controlled() || logicControlled();`,
	# Turret.java:631-632, passed in as target_valid because Units.invalidateTarget
	# waits for its own slice; a null target, a non-dict target, or target_valid
	# false leaves rotation and reloadCounter at their charged values and shoots
	# nothing). targetPosition (`targetPosition(target);`, Turret.java:581) uses
	# Predict.intercept when `predictTarget && bullet.speed >= 0.01f`
	# (Turret.java:464-465, `if(predictTarget && bullet.speed >= 0.01f){` /
	# `targetPos.set(Predict.intercept(this, pos, offset.x, offset.y, bullet.speed));`,
	# with predictTarget defaulting true
	# (`public boolean predictTarget = true;`, Turret.java:105))
	# -- the intercept is the deterministic quadratic (`float a = dstvx * dstvx + dstvy * dstvy - v * v;` /
	# `float b = 2 * (dstvx * tx + dstvy * ty);` / `float c = tx * tx + ty * ty;` /
	# `float disc = b * b - 4 * a * c;`, Predict.java:33-36/:42/:87-104,
	# `private static Vec2 quad(float a, float b, float c){`), with the target
	# velocity per second and the bullet speed as inputs; otherwise the target
	# position is used as-is. The NaN guard (`if(Float.isNaN(rotation)) rotation = 0;`,
	# Turret.java:583) runs before the turn. canShoot is
	# `canShoot = within(target, range() + (target instanceof Sized hb ? hb.hitSize()/1.9f : 0f));`
	# (Turret.java:585) -- Position.within is dst2 < range*range, STRICT <
	# (Position.java:40-46, `return Mathf.dst2(getX(), getY(), x, y) < dst*dst;`), with
	# range() already including the peeked ammo's rangeChange
	# (`return range + peekAmmo().rangeChange;`, Turret.java:342-346).
	# `angleTo` is Position.angleTo -> Angles.angle
	# (`return Angles.angle(getX(), getY(), other.getX(), other.getY());`,
	# Position.java:12-14), i.e. `Mathf.atan2(x2 - x, y2 - y) * Mathf.radDeg`
	# (`float ang = Mathf.atan2(x2 - x, y2 - y) * Mathf.radDeg;`, Angles.java:56-59)
	# normalized to [0, 360) -- atan2(dx, dy), 0 degrees is +Y, so this writes
	# `rad_to_deg(atan2(tx - x, ty - y))`, never Vector2.angle_to. The dest is
	# computed first (`float targetRot = angleTo(targetPos);`, Turret.java:595),
	# then turnToTarget is `rotation = Angles.moveToward(rotation, targetRot, rotateSpeed * delta() * potentialEfficiency);`
	# (Turret.java:665-667); shouldTurn is `return moveWhileCharging || !charging();`
	# (Turret.java:669-671) and moveWhileCharging defaults true
	# (`public boolean moveWhileCharging = true;`, Turret.java:80), so duo always
	# turns (`if(shouldTurn()){` / `turnToTarget(targetRot);`, Turret.java:597-598).
	# The shoot gate (`if(!alwaysShooting && Angles.angleDist(rotation, targetRot) < shootCone && canShoot){`,
	# Turret.java:599) is STRICT `<` shootCone (not Angles.within `<=`);
	# alwaysShooting defaults false (`public boolean alwaysShooting = false;`,
	# Turret.java:103). updateShooting (`if(reloadCounter >= reload && !charging() && shootWarmup >= minWarmup){`,
	# Turret.java:733) fires shoot(type) then `reloadCounter %= reload;`
	# (Turret.java:738 -- modulo, NOT reset-to-0). shoot() consumes ammo once
	# (`if(consumeAmmoOnce){` / `useAmmo();`, Turret.java:771-773) and advances
	# the barrel (`}, () -> barrelCounter++);`, Turret.java:770); useAmmo is
	# inline here (`if(cheating()) return peekAmmo();` / `entry.amount -= ammoPerShot;` /
	# `if(entry.amount <= 0) ammo.pop();` / `totalAmmo -= ammoPerShot;` /
	# `totalAmmo = Math.max(totalAmmo, 0);`, Turret.java:680-690 -- the same formula
	# as the registered source_turret_use_ammo_state in SourceTurretBuildState.gd,
	# which this comment points at; the stacks are the {"item", "amount"} dicts of
	# SourceTurretAmmoState.selected_turret_ammo_entries / use_ammo_stack_state,
	# peeked from the last stack). `rotation` is the float turret rotation, default 90
	# (`public float rotation = 90;`, BaseTurret.java:114 -- NOT BuildingComp.rotation,
	# the int block rotation), and `reloadCounter` is the float on ReloadTurretBuild
	# (`public float reloadCounter;`, ReloadTurret.java:26). Class defaults are
	# shootCone 8f, minWarmup 0f, inaccuracy 0f, ammoPerShot 1, consumeAmmoOnce true
	# (`public float shootCone = 8f;` / `public float minWarmup = 0f;` /
	# `public float inaccuracy = 0f;` / `public int ammoPerShot = 1;` /
	# `public boolean consumeAmmoOnce = true;`, Turret.java:49/:51/:58/:64/:76);
	# the per-def duo overrides are range 160, rotateSpeed 10, reload 20,
	# shootCone 15, shootY 3, inaccuracy 2 (`range = 160;` / `rotateSpeed = 10f;` /
	# `reload = 20f;` / `shootCone = 15f;` / `shootY = 3f;` / `inaccuracy = 2f;`,
	# Blocks.java:3257-3324), `shoot = new ShootAlternate(3.5f);` with barrels 2
	# (`public int barrels = 2;`, ShootAlternate.java:8 --
	# `float index = ((totalShots + i + barrelOffset) % barrels) - (barrels-1)/2f;`,
	# ShootAlternate.java:16; `public int shots = 1;` / `public float firstShotDelay = 0;`,
	# ShootPattern.java), and ammo copper/graphite/silicon with reloadMultiplier
	# 1.0 (BulletType default, `public float reloadMultiplier = 1f;`, BulletType.java:97) /
	# 0.8 (`reloadMultiplier = 0.8f;`, Blocks.java:3277) / 1.5 (`reloadMultiplier = 1.5f;`,
	# Blocks.java:3290) and rangeChange 0 (BulletType default,
	# `public float rangeChange = 0f;`, BulletType.java:157) / 16 (`rangeChange = 16f;`,
	# Blocks.java:3278) / 0; bullet speed is the BulletType field
	# (`public float speed = 1f;`, BulletType.java:37 -- duo copper 2.5, graphite 3.5,
	# silicon 3). `delta` is the scaled delta (`return Time.delta * timeScale;`,
	# BuildingComp.java:1922-1924); `shoot_warmup` is the warmup 0..1
	# (`return shootWarmup;`, Turret.java:355-357); `charging` is
	# `return queuedBullets > 0 && shoot.firstShotDelay > 0;` (Turret.java:715-717 --
	# duo firstShotDelay is 0, so charging is false live, but the gate is still
	# checked); `team_id` is the validateTarget team (Turret.java:632,
	# `canHeal() ? Team.derelict : team`) passed in for the verdict, and
	# `inaccuracy` is the shot spread in degrees (duo 2f) whose random draw is
	# bullet() spawn detail and waits for its own slice -- both are carried as
	# parameters so the signature stays source-complete. `shootX` defaults 0f
	# (`public float shootX = 0f, shootY = Float.NEGATIVE_INFINITY;`, Turret.java:66).
	# The result is a 10-key dict: `rotation` (after moveToward, unchanged when
	# there is no valid target), `reload_counter` (charged and capped every tick,
	# modulo on a shot), `dest` (the angle to the predicted target position, null
	# without a valid target), `shot` (whether the aim + range + reloaded +
	# not-charging + warmed-up gate fired), `target_pos` (the predicted position
	# dict, null without a valid target), `total_ammo_after` (after the one
	# useAmmo, unchanged when no shot or cheating), `ammo_entries_after` (the
	# stacks after the one useAmmo), `shoot_event` (the bullet-origin dict --
	# `bulletX = x + Angles.trnsx(rotation - 90, shootX, shootY),`, Turret.java:744 --
	# plus rotation and the barrel, null when no shot), `barrel_counter_after`
	# (barrelCounter + 1 on a shot, unchanged otherwise), and `was_shooting`
	# (whether the shoot gate fired this tick -- `wasShooting = false;` at the top
	# of updateTile, Turret.java:517, `wasShooting = true;` inside the gate,
	# Turret.java:600). The bullet() spawn detail (inaccuracy random, lifeScl,
	# effects/sound, recoil/heat/totalShots, Turret.java:776-812),
	# findTarget/validateTarget (Units.invalidateTarget), the warmup lerp advance
	# (Turret.java:502-515), queuedBullets when shotDelay > 0, and the hasAmmo()
	# wrapper (`if(hasAmmo()){`, Turret.java:548 -- the pure function shoots with
	# empty ammo, but useAmmo is guarded so nothing is consumed) are NOT this
	# slice -- they wait for their own slices.
	var rotation: float = float(frame.get("rotation", 90.0))
	var reload_counter: float = float(frame.get("reload_counter", 0.0))
	var ammo_reload_multiplier: float = reload_multiplier if not ammo_entries.is_empty() else 1.0
	reload_counter += delta * ammo_reload_multiplier * base_reload_speed
	reload_counter = minf(reload_counter, reload)
	var total_ammo_after: int = total_ammo
	var ammo_entries_after: Array = ammo_entries.duplicate(true)
	var barrel_counter_after: int = barrel_counter
	if target == null or not (target is Dictionary) or not target_valid:
		return {"rotation": rotation, "reload_counter": reload_counter, "dest": null, "shot": false, "target_pos": null, "total_ammo_after": total_ammo_after, "ammo_entries_after": ammo_entries_after, "shoot_event": null, "barrel_counter_after": barrel_counter_after, "was_shooting": false}
	var target_dict: Dictionary = target
	var predicted_pos: Dictionary = {"x": float(target_dict.get("x", 0.0)), "y": float(target_dict.get("y", 0.0))}
	if predict_target and bullet_speed >= 0.01:
		var tx: float = float(target_dict.get("x", 0.0)) - x
		var ty: float = float(target_dict.get("y", 0.0)) - y
		var dstvx: float = float(target_dict.get("vx", 0.0))
		var dstvy: float = float(target_dict.get("vy", 0.0))
		var a: float = dstvx * dstvx + dstvy * dstvy - bullet_speed * bullet_speed
		var b: float = 2.0 * (dstvx * tx + dstvy * ty)
		var c: float = tx * tx + ty * ty
		var roots: Variant = _predict_quad(a, b, c)
		if roots != null:
			var t: float = minf(float(roots[0]), float(roots[1]))
			if t < 0.0:
				t = maxf(float(roots[0]), float(roots[1]))
			if t > 0.0:
				predicted_pos = {"x": float(target_dict.get("x", 0.0)) + dstvx * t, "y": float(target_dict.get("y", 0.0)) + dstvy * t}
	var target_pos: Dictionary = predicted_pos
	if is_nan(rotation):
		rotation = 0.0
	var hit_size: float = float(target_dict.get("hit_size", 0.0))
	var shoot_range: float = range + range_change + hit_size / 1.9
	var dx: float = float(target_dict.get("x", 0.0)) - x
	var dy: float = float(target_dict.get("y", 0.0)) - y
	var can_shoot: bool = dx * dx + dy * dy < shoot_range * shoot_range
	var dest: float = fmod(rad_to_deg(atan2(float(target_pos.get("x", 0.0)) - x, float(target_pos.get("y", 0.0)) - y)), 360.0)
	rotation = _move_toward_angle(rotation, dest, rotate_speed * delta * potential_efficiency)
	var shot: bool = false
	var shoot_event: Variant = null
	var was_shooting: bool = false
	if not always_shooting:
		if _angle_dist(rotation, dest) < shoot_cone and can_shoot:
			was_shooting = true
	else:
		# `if(alwaysShooting){ wasShooting = true; updateShooting(); }`
		# (Turret.java:606-609 -- the always-shooting branch fires
		# updateShooting without the cone / range gate).
		was_shooting = true
	if was_shooting:
		if reload_counter >= reload and not charging and shoot_warmup >= min_warmup:
			shot = true
			# `bulletX = x + Angles.trnsx(rotation - 90, shootX, shootY),`
			# (Turret.java:744 -- Angles.trnsx/trnsy rotate (shootX, shootY)
			# by rotation - 90, Angles.java:74-80).
			var angle_rad: float = deg_to_rad(rotation - 90.0)
			var bullet_x: float = x + cos(angle_rad) * shoot_x - sin(angle_rad) * shoot_y
			var bullet_y: float = y + sin(angle_rad) * shoot_x + cos(angle_rad) * shoot_y
			shoot_event = {"bullet_x": bullet_x, "bullet_y": bullet_y, "rotation": rotation, "barrel": barrel_counter}
			barrel_counter_after = barrel_counter + 1
			if consume_ammo_once:
				# useAmmo (Turret.java:680-690) inline -- the same formula as
				# the registered source_turret_use_ammo_state in
				# SourceTurretBuildState.gd; cheating returns peekAmmo()
				# without consuming.
				if not cheating:
					if not ammo_entries_after.is_empty():
						var entry: Dictionary = ammo_entries_after[ammo_entries_after.size() - 1]
						entry["amount"] = int(entry.get("amount", 0)) - ammo_per_shot
						if int(entry.get("amount", 0)) <= 0:
							ammo_entries_after.pop_back()
						total_ammo_after = maxi(total_ammo - ammo_per_shot, 0)
			reload_counter = fmod(reload_counter, reload)
	return {"rotation": rotation, "reload_counter": reload_counter, "dest": dest, "shot": shot, "target_pos": target_pos, "total_ammo_after": total_ammo_after, "ammo_entries_after": ammo_entries_after, "shoot_event": shoot_event, "barrel_counter_after": barrel_counter_after, "was_shooting": was_shooting}

static func generated_item_turret_build_get_ammo_fraction_bridge_state(total_ammo: float, max_ammo: float) -> Dictionary:
	var result = _item_turret_call("java_inner_class_ItemTurretBuild_method_getAmmoFraction_3", [total_ammo, max_ammo])
	var canonical = get_ammo_fraction_state(total_ammo, max_ammo)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_GET_AMMO_FRACTION_STATE,
		"generated_owner": "item_turret.ItemTurretBuild.getAmmoFraction",
		"result": result,
		"canonical": canonical,
		"matches": result.get("ammo_fraction", null) == canonical.get("ammo_fraction", null),
	}

static func generated_item_turret_build_get_ammo_fraction_default_bridge_state(total_ammo: float) -> Dictionary:
	var result = _item_turret_call("java_inner_class_ItemTurretBuild_method_getAmmoFraction_3", [total_ammo])
	var canonical = get_ammo_fraction_state(total_ammo, source_turret_defaults.MAX_AMMO_DEFAULT)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_GET_AMMO_FRACTION_STATE,
		"generated_owner": "item_turret.ItemTurretBuild.getAmmoFraction",
		"result": result,
		"canonical": canonical,
		"defaulted_args": ["max_ammo"],
		"max_ammo": source_turret_defaults.MAX_AMMO_DEFAULT,
		"ammo_fraction": total_ammo / source_turret_defaults.MAX_AMMO_DEFAULT,
		"matches": result.get("ammo_fraction", null) == canonical.get("ammo_fraction", null),
	}

static func generated_item_turret_build_accept_stack_bridge_state(item: Variant, amount: int, max_ammo: float, total_ammo: float, ammo_multiplier: float, ammo_type_null: bool) -> Dictionary:
	var result = _item_turret_call("java_inner_class_ItemTurretBuild_method_acceptStack_4", [item, amount, max_ammo, total_ammo, ammo_multiplier, ammo_type_null])
	var canonical = accept_stack_state(item, amount, max_ammo, total_ammo, ammo_multiplier, ammo_type_null)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_ACCEPT_STACK_STATE,
		"generated_owner": "item_turret.ItemTurretBuild.acceptStack",
		"result": result,
		"canonical": canonical,
		"matches": result.get("accept_stack", null) == canonical.get("accept_stack", null),
	}

static func generated_item_turret_build_accept_stack_default_bridge_state(item: Variant, amount: int) -> Dictionary:
	var result = _item_turret_call("java_inner_class_ItemTurretBuild_method_acceptStack_4", [item, amount])
	var canonical = accept_stack_state(item, amount, source_turret_defaults.MAX_AMMO_DEFAULT, 0.0, 1.0, false)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_ACCEPT_STACK_STATE,
		"generated_owner": "item_turret.ItemTurretBuild.acceptStack",
		"result": result,
		"canonical": canonical,
		"defaulted_args": ["max_ammo", "total_ammo", "ammo_multiplier", "ammo_type_null"],
		"max_ammo": source_turret_defaults.MAX_AMMO_DEFAULT,
		"accept_stack": min(int(source_turret_defaults.MAX_AMMO_DEFAULT), amount),
		"matches": result.get("accept_stack", null) == canonical.get("accept_stack", null),
	}

static func generated_item_turret_build_handle_stack_bridge_state(item: Variant, amount: int) -> Dictionary:
	var result = _item_turret_call("java_inner_class_ItemTurretBuild_method_handleStack_5", [item, amount])
	var canonical = handle_stack_state(item, amount)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_HANDLE_STACK_STATE,
		"generated_owner": "item_turret.ItemTurretBuild.handleStack",
		"result": result,
		"canonical": canonical,
		"matches": result.get("handle_item_calls", []) == canonical.get("handle_item_calls", []),
	}

static func generated_item_turret_build_remove_stack_bridge_state(item: Variant, amount: int) -> Dictionary:
	var result = _item_turret_call("java_inner_class_ItemTurretBuild_method_removeStack_6", [item, amount])
	var canonical = remove_stack_state(item, amount)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_REMOVE_STACK_STATE,
		"generated_owner": "item_turret.ItemTurretBuild.removeStack",
		"result": result,
		"canonical": canonical,
		"matches": result.get("removed_stack", null) == canonical.get("removed_stack", null),
	}

static func generated_item_turret_build_handle_item_bridge_state(item: Variant, item_is_pyratite: bool, total_ammo: int, ammo_multiplier: float, ammo_type_null: bool, ammo_entries: Array) -> Dictionary:
	var result = _item_turret_call("java_inner_class_ItemTurretBuild_method_handleItem_7", [item, item_is_pyratite, total_ammo, ammo_multiplier, ammo_type_null, ammo_entries])
	var canonical = handle_item_state(item, item_is_pyratite, total_ammo, ammo_multiplier, ammo_type_null, ammo_entries)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_HANDLE_ITEM_STATE,
		"generated_owner": "item_turret.ItemTurretBuild.handleItem",
		"result": result,
		"canonical": canonical,
		"matches": result.get("total_ammo_after", null) == canonical.get("total_ammo_after", null)
			and result.get("ammo_entries_after", []) == canonical.get("ammo_entries_after", [])
			and result.get("flame_ammo_event_fired", null) == canonical.get("flame_ammo_event_fired", null)
			and result.get("resupply_turret_event_fired", null) == canonical.get("resupply_turret_event_fired", null)
			and result.get("type_null_returned", null) == canonical.get("type_null_returned", null)
			and result.get("entry_found", null) == canonical.get("entry_found", null)
			and result.get("entry_added", null) == canonical.get("entry_added", null)
			and result.get("swapped", null) == canonical.get("swapped", null),
	}

static func generated_item_turret_build_accept_item_bridge_state(item: Variant, total_ammo: int, max_ammo: float, ammo_multiplier: float, ammo_type_null: bool) -> Dictionary:
	var result = _item_turret_call("java_inner_class_ItemTurretBuild_method_acceptItem_8", [item, total_ammo, max_ammo, ammo_multiplier, ammo_type_null])
	var canonical = accept_item_state(item, total_ammo, max_ammo, ammo_multiplier, ammo_type_null)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_ACCEPT_ITEM_STATE,
		"generated_owner": "item_turret.ItemTurretBuild.acceptItem",
		"result": result,
		"canonical": canonical,
		"matches": result.get("accept_item", null) == canonical.get("accept_item", null),
	}

static func generated_item_turret_build_accept_item_default_bridge_state(item: Variant) -> Dictionary:
	var result = _item_turret_call("java_inner_class_ItemTurretBuild_method_acceptItem_8", [item])
	var canonical = accept_item_state(item, 0, source_turret_defaults.MAX_AMMO_DEFAULT, 0.0, false)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_ACCEPT_ITEM_STATE,
		"generated_owner": "item_turret.ItemTurretBuild.acceptItem",
		"result": result,
		"canonical": canonical,
		"defaulted_args": ["total_ammo", "max_ammo", "ammo_multiplier", "ammo_type_null"],
		"max_ammo": source_turret_defaults.MAX_AMMO_DEFAULT,
		"accept_item": result.get("accept_item", null),
		"matches": result.get("accept_item", null) == canonical.get("accept_item", null),
	}

static func version_state() -> Dictionary:
	return source_item_turret_build_io_state.version_state()

static func write_state(ammo_entries: Array) -> Dictionary:
	return source_item_turret_build_io_state.write_state(ammo_entries)

static func read_state(revision: int, max_ammo: int, read_entries: Array) -> Dictionary:
	return source_item_turret_build_io_state.read_state(revision, max_ammo, read_entries)

static func generated_version_bridge_state() -> Dictionary:
	return source_item_turret_build_io_state.generated_version_bridge_state()

static func generated_write_bridge_state(ammo_entries: Array) -> Dictionary:
	return source_item_turret_build_io_state.generated_write_bridge_state(ammo_entries)

static func generated_read_bridge_state(revision: int, max_ammo: int, read_entries: Array) -> Dictionary:
	return source_item_turret_build_io_state.generated_read_bridge_state(revision, max_ammo, read_entries)
