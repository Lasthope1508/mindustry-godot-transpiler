extends RefCounted
class_name SourceUnitUpdateState

const SourceUnitDefaults := preload("res://src/game/SourceUnitDefaults.gd")
const SourceWorldDefaults := preload("res://src/game/SourceWorldDefaults.gd")
const SourceMathState := preload("res://src/game/SourceMathState.gd")

static func default_callbacks_state(game: Object) -> Dictionary:
	return {
		"sin_scaled": Callable(game, "source_arc_mathf_sin_scaled"),
		"cos_scaled": Callable(game, "source_arc_mathf_cos_scaled"),
		"vec2_limit": Callable(game, "source_arc_vec2_limit"),
		"vec2_angle": Callable(game, "source_unit_vec2_angle"),
		"angles_move_toward": Callable(game, "source_arc_angles_move_toward"),
		"angles_angle": Callable(game, "source_arc_angles_angle"),
	}

const SOURCE_UNIT_GROUNDED_EPSILON := SourceUnitDefaults.GROUNDED_EPSILON
const SOURCE_UNIT_WOBBLE_SIN_SCL := SourceUnitDefaults.WOBBLE_SIN_SCL
const SOURCE_UNIT_WOBBLE_MAG := SourceUnitDefaults.WOBBLE_MAG
const SOURCE_UNIT_DROWN_HIT_SIZE_DIVISOR := SourceUnitDefaults.DROWN_HIT_SIZE_DIVISOR
const SOURCE_UNIT_DROWN_UPDATE_EFFECT_CHANCE := SourceUnitDefaults.DROWN_UPDATE_EFFECT_CHANCE
const SOURCE_UNIT_DROWN_KILL_THRESHOLD := SourceUnitDefaults.DROWN_KILL_THRESHOLD
const SOURCE_UNIT_DROWN_DRY_DECAY_DIVISOR := SourceUnitDefaults.DROWN_DRY_DECAY_DIVISOR
const SOURCE_UNIT_HEAL_AMOUNT_POSITIVE_THRESHOLD := SourceUnitDefaults.HEAL_AMOUNT_POSITIVE_THRESHOLD
const SOURCE_UNIT_HEAL_TIME_RESET_THRESHOLD := SourceUnitDefaults.HEAL_TIME_RESET_THRESHOLD
const SOURCE_UNIT_HEAL_TIME_RESET_VALUE := SourceUnitDefaults.HEAL_TIME_RESET_VALUE
const SOURCE_UNIT_HEAL_TIME_DECAY_DIVISOR := SourceUnitDefaults.HEAL_TIME_DECAY_DIVISOR
const SOURCE_UNIT_WALK_EFFECT_THRESHOLD_BASE := SourceUnitDefaults.WALK_EFFECT_THRESHOLD_BASE
const SOURCE_UNIT_WALK_EFFECT_THRESHOLD_HIT_SIZE_DIVISOR := SourceUnitDefaults.WALK_EFFECT_THRESHOLD_HIT_SIZE_DIVISOR
const SOURCE_UNIT_FLYING_TRANSITION_LAND_EFFECT_LIQUID_ROTATION := SourceUnitDefaults.FLYING_TRANSITION_LAND_EFFECT_LIQUID_ROTATION
const SOURCE_UNIT_FLYING_TRANSITION_LAND_EFFECT_SOLID_ROTATION := SourceUnitDefaults.FLYING_TRANSITION_LAND_EFFECT_SOLID_ROTATION
const SOURCE_UNIT_FALL_ENGINE_OFFSET_DIVISOR := SourceUnitDefaults.FALL_ENGINE_OFFSET_DIVISOR
const SOURCE_UNIT_FALL_ENGINE_ROTATION_OFFSET := SourceUnitDefaults.FALL_ENGINE_ROTATION_OFFSET
const SOURCE_UNIT_FALL_ENGINE_TRAIL_CHANCE := SourceUnitDefaults.FALL_ENGINE_TRAIL_CHANCE
const SOURCE_UNIT_TRAIL_SCALE_DEFAULT := SourceUnitDefaults.TRAIL_SCALE_DEFAULT
const SOURCE_UNIT_DRAG_FLOOR_FACTOR_DEFAULT := SourceUnitDefaults.DRAG_FLOOR_FACTOR_DEFAULT
const SOURCE_UNIT_FALLING_DRAG_MIN := SourceUnitDefaults.FALLING_DRAG_MIN
const SOURCE_UNIT_FALL_SMOKE_CHANCE := SourceUnitDefaults.FALL_SMOKE_CHANCE
const SOURCE_UNIT_SPAWN_KNOCKBACK_RELATIVE_SIZE_OFFSET := SourceUnitDefaults.SPAWN_KNOCKBACK_RELATIVE_SIZE_OFFSET
const SOURCE_UNIT_SPAWN_KNOCKBACK_STRENGTH_OFFSET := SourceUnitDefaults.SPAWN_KNOCKBACK_STRENGTH_OFFSET
const SOURCE_UNIT_SPAWN_KNOCKBACK_SCALE := SourceUnitDefaults.SPAWN_KNOCKBACK_SCALE
const SOURCE_UNIT_SPAWN_KNOCKBACK_HIT_SIZE_DIVISOR := SourceUnitDefaults.SPAWN_KNOCKBACK_HIT_SIZE_DIVISOR
const SOURCE_UNIT_SOLID_TILE_BOOST_ELEVATION := SourceUnitDefaults.SOLID_TILE_BOOST_ELEVATION
const SOURCE_UNIT_WARP_DST := SourceWorldDefaults.UNIT_WARP_DST
const SOURCE_FINAL_WORLD_BOUNDS := SourceWorldDefaults.FINAL_WORLD_BOUNDS
const SOURCE_UNIT_UPDATE_ABILITIES_FIELD := "Ability[] abilities = {};"
const SOURCE_UNIT_UPDATE_ABILITIES_LOOP := "for(Ability a : abilities){"
const SOURCE_UNIT_UPDATE_ABILITIES_CALL := "a.update(self());"
const SOURCE_UNIT_UPDATE_ABILITIES_ABILITY_UPDATE_METHOD := "public void update(Unit unit){}"
const SOURCE_UNIT_UPDATE_AI_CONTROLLER_FIELD := "private UnitController controller;"
const SOURCE_UNIT_UPDATE_AI_DEAD_IMPORT := "@Import boolean dead, disarmed;"
const SOURCE_UNIT_UPDATE_AI_COMMENT := "//AI only updates on the server"
const SOURCE_UNIT_UPDATE_AI_GUARD := "if(!net.client() && !dead && shouldUpdateController()){"
const SOURCE_UNIT_UPDATE_AI_CONTROLLER_CALL := "controller.updateUnit();"
const SOURCE_UNIT_UPDATE_AI_SHOULD_UPDATE_METHOD := "public boolean shouldUpdateController(){"
const SOURCE_UNIT_UPDATE_AI_SHOULD_UPDATE_DEFAULT := "return true;"
const SOURCE_UNIT_UPDATE_AI_UNIT_CONTROLLER_UPDATE := "default void updateUnit(){"
const SOURCE_UNIT_UPDATE_AI_NET_CLIENT_METHOD := "public boolean client(){"
const SOURCE_UNIT_UPDATE_AI_NET_CLIENT_BODY := "return !server && active;"
const SOURCE_UNIT_UPDATE_BOOSTING_DEFAULT_METHOD := "public void updateBoosting(boolean boost){"
const SOURCE_UNIT_UPDATE_BOOSTING_DEFAULT_CALL := "updateBoosting(boost, false);"
const SOURCE_UNIT_UPDATE_BOOSTING_OVERLOAD_METHOD := "public void updateBoosting(boolean boost, boolean event){"
const SOURCE_UNIT_UPDATE_BOOSTING_GUARD := "if(!type.canBoost || dead) return;"
const SOURCE_UNIT_UPDATE_BOOSTING_SHOULD_BOOST := "boolean shouldBoost = boost || onSolid() || (isFlying() && !canLand());"
const SOURCE_UNIT_UPDATE_BOOSTING_ELEVATION_ASSIGNMENT := "elevation = Mathf.approachDelta(elevation, type.canBoost ? Mathf.num(shouldBoost) : 0f, shouldBoost ? type.riseSpeed : type.descentSpeed);"
const SOURCE_ARC_MATHF_NUM_RETURN := "return b ? 1 : 0;"
const SOURCE_ARC_MATHF_APPROACH_DELTA_METHOD := "public static float approachDelta(float from, float to, float speed){"
const SOURCE_ARC_MATHF_APPROACH_DELTA_RETURN := "return approach(from, to, Time.delta * speed);"
const SOURCE_ARC_MATHF_APPROACH_METHOD := "public static float approach(float from, float to, float speed){"
const SOURCE_ARC_MATHF_APPROACH_RETURN := "return from + Mathf.clamp(to - from, -speed, speed);"
const SOURCE_ARC_MATHF_CLAMP_FLOAT_METHOD := "public static float clamp(float value, float min, float max){"
const SOURCE_ARC_MATHF_CLAMP_FLOAT_RETURN := "return Math.max(Math.min(value, max), min);"
const SOURCE_UNIT_BOOSTING_TARGET_ELEVATION := SourceUnitDefaults.BOOSTING_TARGET_ELEVATION
const SOURCE_UNIT_BOOSTING_BASE_ELEVATION := SourceUnitDefaults.BOOSTING_BASE_ELEVATION
const SOURCE_UNIT_UPDATE_BOOSTING_EVENT_GATE := "if(event){"
const SOURCE_UNIT_UPDATE_BOOSTING_EVENT_FIRE_TRIGGER := "Events.fire(Trigger.unitCommandBoost);"
const SOURCE_EVENT_TYPE_TRIGGER_ENUM := "public enum Trigger{"
const SOURCE_EVENT_TYPE_UNIT_COMMAND_BOOST := "unitCommandBoost,"
const SOURCE_UNIT_FLYING_ELEVATION_MIN := SourceUnitDefaults.FLYING_ELEVATION_MIN
const SOURCE_UNIT_IS_GROUNDED_METHOD := "public boolean isGrounded(){"
const SOURCE_UNIT_IS_GROUNDED_RETURN := "return elevation < 0.001f;"
const SOURCE_UNIT_IS_FLYING_METHOD := "public boolean isFlying(){"
const SOURCE_UNIT_IS_FLYING_RETURN := "return elevation >= 0.09f;"
const SOURCE_UNIT_CHECK_TARGET_METHOD := "public boolean checkTarget(boolean targetAir, boolean targetGround){"
const SOURCE_UNIT_CHECK_TARGET_RETURN := "return (isGrounded() && targetGround) || (isFlying() && targetAir);"
const SOURCE_UNIT_CHECK_TARGET_IS_GROUNDED_CALL := "isGrounded()"
const SOURCE_UNIT_CHECK_TARGET_IS_FLYING_CALL := "isFlying()"
const SOURCE_UNIT_CAN_DROWN_METHOD := "public boolean canDrown(){"
const SOURCE_UNIT_CAN_DROWN_IS_GROUNDED_CALL := "isGrounded()"
const SOURCE_UNIT_CAN_DROWN_TYPE_CAN_DROWN := "type.canDrown"
const SOURCE_UNIT_CAN_DROWN_RETURN := "return isGrounded() && type.canDrown;"
const SOURCE_UNIT_DROWN_FLOOR_METHOD := "public @Nullable Floor drownFloor(){"
const SOURCE_UNIT_DROWN_FLOOR_RETURN := "return floorOn();"
const SOURCE_UNIT_DROWN_FLOOR_FLOOR_ON := "floorOn()"
const SOURCE_UNIT_DROWN_FLOOR_FLOOR_ON_METHOD := "Floor floorOn(){"
const SOURCE_UNIT_DROWN_FLOOR_FLOOR_ON_TILE := "Tile tile = tileOn();"
const SOURCE_UNIT_DROWN_FLOOR_FLOOR_ON_RETURN := "return tile == null || tile.block() != Blocks.air ? (Floor)Blocks.air : tile.floor();"
const SOURCE_UNIT_DROWN_FLOOR_TILE_ON_METHOD := "Tile tileOn(){"
const SOURCE_UNIT_DROWN_FLOOR_TILE_ON_RETURN := "return world.tileWorld(x, y);"
const SOURCE_UNIT_DROWN_FLOOR_FLOOR_CLASS := "public class Floor extends Block{"
const SOURCE_UNIT_MOVE_AT_METHOD := "public void moveAt(Vec2 vector, float acceleration){"
const SOURCE_UNIT_MOVE_AT_TARGET_SET := "Vec2 t = tmp1.set(vector);"
const SOURCE_UNIT_MOVE_AT_DELTA_LIMIT := "tmp2.set(t).sub(vel).limit(acceleration * vector.len() * Time.delta);"
const SOURCE_UNIT_MOVE_AT_VEL_ADD := "vel.add(tmp2);"
const SOURCE_UNIT_MOVE_AT_DEFAULT_ACCEL_METHOD := "public void moveAt(Vec2 vector){"
const SOURCE_UNIT_MOVE_AT_DEFAULT_ACCEL_CALL := "moveAt(vector, type.accel);"
const SOURCE_UNIT_APPROACH_METHOD := "public void approach(Vec2 vector){"
const SOURCE_UNIT_APPROACH_CALL := "vel.approachDelta(vector, type.accel * speed());"
const SOURCE_UNIT_APPROACH_VEC2_APPROACH_DELTA_CALL := "return approach(target, Time.delta * alpha);"
const SOURCE_UNIT_APPROACH_VEC2_APPROACH_METHOD := "public Vec2 approach(Vec2 target, float alpha){"
const SOURCE_UNIT_APPROACH_VEC2_DX_DY := "float dx = x - target.x, dy = y - target.y;"
const SOURCE_UNIT_APPROACH_VEC2_ALPHA2 := "float alpha2 = alpha*alpha;"
const SOURCE_UNIT_APPROACH_VEC2_LEN2 := "float len2 = Mathf.len2(dx, dy);"
const SOURCE_UNIT_APPROACH_VEC2_SCL := "float scl = Mathf.sqrt(alpha2 / len2);"
const SOURCE_UNIT_APPROACH_VEC2_SUB_CALL := "return sub(dx, dy);"
const SOURCE_UNIT_APPROACH_VEC2_SET_CALL := "return set(target);"
const SOURCE_UNIT_ROTATE_MOVE_METHOD := "public void rotateMove(Vec2 vec){"
const SOURCE_UNIT_ROTATE_MOVE_MOTION_CALL := "moveAt(Tmp.v2.trns(rotation, vec.len()));"
const SOURCE_UNIT_ROTATE_MOVE_VEC2_TRNS_RETURN := "return set(amount, 0).rotate(angle);"
const SOURCE_UNIT_ROTATE_MOVE_ROTATION_GATE := "if(!vec.isZero()){"
const SOURCE_UNIT_ROTATE_MOVE_ROTATION_ASSIGNMENT := "rotation = Angles.moveToward(rotation, vec.angle(), type.rotateSpeed * Time.delta * speedMultiplier);"
const SOURCE_UNIT_ROTATE_MOVE_VEC2_IS_ZERO := "return x == 0 && y == 0;"
const SOURCE_UNIT_ROTATE_MOVE_VEC2_ANGLE := "float angle = Mathf.atan2(x, y) * Mathf.radiansToDegrees;"
const SOURCE_UNIT_MOVE_PREF_METHOD := "public void movePref(Vec2 movement){"
const SOURCE_UNIT_MOVE_PREF_OMNI_GATE := "if(type.omniMovement){"
const SOURCE_UNIT_MOVE_PREF_MOVE_AT_CALL := "moveAt(movement);"
const SOURCE_UNIT_MOVE_PREF_ROTATE_MOVE_CALL := "rotateMove(movement);"
const SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_METHOD := "public float floorSpeedMultiplier(){"
const SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_FLOOR_CHOICE := "Floor on = isFlying() || type.hovering ? Blocks.air.asFloor() : floorOn();"
const SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_RETURN := "return (float)Math.pow(on.speedMultiplier, type.floorMultiplier) * speedMultiplier;"
const SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_TYPE_HOVERING := "type.hovering"
const SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_FLOOR_SPEED := "on.speedMultiplier"
const SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_TYPE_FLOOR_MULTIPLIER := "floorMultiplier = 1f,"
const SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_FLOOR_SPEED_DEFAULT := "public float speedMultiplier = 1f;"
const SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_BLOCK_AS_FLOOR := "public Floor asFloor(){"
const SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_SPEED_MULTIPLIER := "speedMultiplier"
const SOURCE_UNIT_UNLOADED_COMMENT := "/** Called when this unit was unloaded from a factory or spawn point. */"
const SOURCE_UNIT_UNLOADED_METHOD := "public void unloaded(){"
const SOURCE_UNIT_UNLOADED_EMPTY_BODY := "public void unloaded(){\n\n    }"
const SOURCE_UNIT_AIM_LOOK_POSITION_METHOD := "public void aimLook(Position pos){"
const SOURCE_UNIT_AIM_LOOK_POSITION_POS_ARG := "pos"
const SOURCE_UNIT_AIM_LOOK_POSITION_AIM_CALL := "aim(pos);"
const SOURCE_UNIT_AIM_LOOK_POSITION_LOOK_AT_CALL := "lookAt(pos);"
const SOURCE_UNIT_AIM_LOOK_XY_METHOD := "public void aimLook(float x, float y){"
const SOURCE_UNIT_AIM_LOOK_XY_X_ARG := "x"
const SOURCE_UNIT_AIM_LOOK_XY_Y_ARG := "y"
const SOURCE_UNIT_AIM_LOOK_XY_AIM_CALL := "aim(x, y);"
const SOURCE_UNIT_AIM_LOOK_XY_LOOK_AT_CALL := "lookAt(x, y);"
const SOURCE_UNIT_LOOK_AT_ANGLE_METHOD := "public void lookAt(float angle){"
const SOURCE_UNIT_LOOK_AT_ANGLE_ROTATION := "rotation = Angles.moveToward(rotation, angle, type.rotateSpeed * Time.delta * speedMultiplier());"
const SOURCE_UNIT_LOOK_AT_ANGLE_ROTATION_SPEED := "type.rotateSpeed * Time.delta * speedMultiplier()"
const SOURCE_UNIT_CONTROLLER_PREDICATES_IS_AI_METHOD := "public boolean isAI(){"
const SOURCE_UNIT_CONTROLLER_PREDICATES_IS_AI_RETURN := "return controller instanceof AIController;"
const SOURCE_UNIT_CONTROLLER_PREDICATES_ALLOW_COMMAND_METHOD := "public boolean allowCommand(){"
const SOURCE_UNIT_CONTROLLER_PREDICATES_COMMAND_AI_RETURN := "return controller instanceof CommandAI;"
const SOURCE_UNIT_CONTROLLER_PREDICATES_IS_COMMANDABLE_METHOD := "public boolean isCommandable(){"
const SOURCE_UNIT_CONTROLLER_PREDICATES_AI_CONTROLLER_CLASS := "public class AIController implements UnitController{"
const SOURCE_UNIT_CONTROLLER_PREDICATES_COMMAND_AI_CLASS := "public class CommandAI extends AIController{"
const SOURCE_UNIT_PLAYER_CONTROLLABLE_METHOD := "public boolean playerControllable(){"
const SOURCE_UNIT_PLAYER_CONTROLLABLE_RETURN := "return type.playerControllable && !(controller instanceof LogicAI ai && ai.controller != null && ai.controller.block.privileged);"
const SOURCE_UNIT_TARGETABLE_METHOD := "public boolean targetable(Team targeter){"
const SOURCE_UNIT_TARGETABLE_UNIT_RETURN := "return type.targetable(self(), targeter);"
const SOURCE_UNIT_TARGETABLE_TYPE_METHOD := "public boolean targetable(Unit unit, Team targeter){"
const SOURCE_UNIT_TARGETABLE_TYPE_RETURN := "return targetable || (vulnerableWithPayloads && unit instanceof Payloadc p && p.hasPayload());"
const SOURCE_UNIT_TARGETABLE_TYPE_TARGETABLE_DEFAULT := "targetable = true,"
const SOURCE_UNIT_TARGETABLE_TYPE_VULNERABLE_WITH_PAYLOADS_DEFAULT := "vulnerableWithPayloads = false,"
const SOURCE_UNIT_TARGETABLE_PAYLOAD_HAS_PAYLOAD_RETURN := "return payloads.size > 0;"
const SOURCE_UNIT_KILLABLE_METHOD := "public boolean killable(){"
const SOURCE_UNIT_KILLABLE_UNIT_RETURN := "return type.killable(self());"
const SOURCE_UNIT_KILLABLE_TYPE_METHOD := "public boolean killable(Unit unit){"
const SOURCE_UNIT_KILLABLE_TYPE_RETURN := "return killable;"
const SOURCE_UNIT_KILLABLE_DEFAULT := "killable = true,"
const SOURCE_UNIT_HITTABLE_METHOD := "public boolean hittable(){"
const SOURCE_UNIT_HITTABLE_UNIT_RETURN := "return type.hittable(self());"
const SOURCE_UNIT_HITTABLE_TYPE_METHOD := "public boolean hittable(Unit unit){"
const SOURCE_UNIT_HITTABLE_TYPE_RETURN := "return hittable || (vulnerableWithPayloads && unit instanceof Payloadc p && p.hasPayload());"
const SOURCE_UNIT_HITTABLE_TYPE_HITTABLE_DEFAULT := "hittable = true,"
const SOURCE_UNIT_HITTABLE_TYPE_VULNERABLE_WITH_PAYLOADS_DEFAULT := "vulnerableWithPayloads = false,"
const SOURCE_UNIT_HITTABLE_PAYLOAD_INSTANCE := "unit instanceof Payloadc p"
const SOURCE_UNIT_HITTABLE_PAYLOAD_HAS_PAYLOAD_RETURN := "return payloads.size > 0;"
const SOURCE_UNIT_HITTABLE_PAYLOAD_HITTABLE := "vulnerableWithPayloads && unit instanceof Payloadc p && p.hasPayload()"
const SOURCE_UNIT_HITTABLE_CALL := "type.hittable(self())"
const SOURCE_UNIT_CAN_TARGET_METHOD := "public boolean canTarget(Teamc other){"
const SOURCE_UNIT_CAN_TARGET_RETURN := "return other != null && (other instanceof Unit u ? u.checkTarget(type.targetAir, type.targetGround) : (other instanceof Building b && type.targetGround));"
const SOURCE_UNIT_CAN_TARGET_UNIT_CHECK_CALL := "u.checkTarget(type.targetAir, type.targetGround)"
const SOURCE_UNIT_CAN_TARGET_BUILDING_CHECK := "other instanceof Building b && type.targetGround"
const SOURCE_UNIT_CAN_TARGET_TYPE_TARGET_AIR := "type.targetAir"
const SOURCE_UNIT_CAN_TARGET_TYPE_TARGET_GROUND := "type.targetGround"
const SOURCE_UNIT_COMMAND_METHOD := "public CommandAI command(){"
const SOURCE_UNIT_COMMAND_AI_GATE := "if(controller instanceof CommandAI ai){"
const SOURCE_UNIT_COMMAND_RETURN := "return ai;"
const SOURCE_UNIT_COMMAND_THROW := "throw new IllegalArgumentException(\"Unit cannot be commanded - check isCommandable() first.\");"
const SOURCE_UNIT_COMMAND_AI_CLASS := "public class CommandAI extends AIController{"
const SOURCE_UNIT_IS_MISSILE_METHOD := "public boolean isMissile(){"
const SOURCE_UNIT_IS_MISSILE_RETURN := "return this instanceof TimedKillc;"
const SOURCE_UNIT_IS_MISSILE_ENTITY_DEF := "public static @EntityDef({Unitc.class, TimedKillc.class}) UnitType missile;"
const SOURCE_UNIT_COUNT_METHOD := "public int count(){"
const SOURCE_UNIT_COUNT_RETURN := "return team.data().countType(type);"
const SOURCE_UNIT_COUNT_TEAM_DATA_METHOD := "public TeamData data(){"
const SOURCE_UNIT_COUNT_TEAM_DATA_RETURN := "return state.teams.get(this);"
const SOURCE_UNIT_COUNT_TYPE_METHOD := "public int countType(UnitType type){"
const SOURCE_UNIT_COUNT_TYPE_RETURN := "return typeCounts == null || typeCounts.length <= type.id ? 0 : typeCounts[type.id];"
const SOURCE_UNIT_CAP_METHOD := "public int cap(){"
const SOURCE_UNIT_CAP_CALL := "return Units.getCap(team);"
const SOURCE_UNIT_CAP_UNITS_GET_CAP_METHOD := "public static int getCap(Team team){"
const SOURCE_UNIT_CAP_UNCAPPED_GATE := "if((team == state.rules.waveTeam && !state.rules.pvp) || (state.isCampaign() && team == state.rules.waveTeam) || state.rules.disableUnitCap || team.ignoreUnitCap){"
const SOURCE_UNIT_CAP_INTEGER_MAX_VALUE := "return Integer.MAX_VALUE;"
const SOURCE_UNIT_CAP_FORMULA := "return Math.max(0, state.rules.unitCapVariable ? state.rules.unitCap + team.data().unitCap : state.rules.unitCap);"
const SOURCE_UNIT_SET_TYPE_METHOD := "public void setType(UnitType type){"
const SOURCE_UNIT_SET_TYPE_ASSIGN_TYPE := "this.type = type;"
const SOURCE_UNIT_SET_TYPE_ASSIGN_MAX_HEALTH := "this.maxHealth = type.health;"
const SOURCE_UNIT_SET_TYPE_ASSIGN_DRAG := "this.drag = type.drag;"
const SOURCE_UNIT_SET_TYPE_ASSIGN_ARMOR := "this.armor = type.armor;"
const SOURCE_UNIT_SET_TYPE_ASSIGN_HIT_SIZE := "this.hitSize = type.hitSize;"
const SOURCE_UNIT_SET_TYPE_SETUP_WEAPONS_GUARD := "if(mounts().length != type.weapons.size) setupWeapons(type);"
const SOURCE_UNIT_SET_TYPE_ABILITIES_GUARD := "if(abilities.length != type.abilities.size || (abilities.length > 0 && abilities[0] instanceof EmptyDataAbility)){"
const SOURCE_UNIT_SET_TYPE_ABILITIES_ARRAY := "abilities = new Ability[type.abilities.size];"
const SOURCE_UNIT_SET_TYPE_ABILITY_COPY := "abilities[i] = type.abilities.get(i).copy();"
const SOURCE_UNIT_SET_TYPE_ABILITY_DATA_CARRY := "abilities[i].data = old[i].data;"
const SOURCE_UNIT_SET_TYPE_CONTROLLER_GUARD := "if(controller == null) controller(type.createController(self()));"
const SOURCE_UNIT_SET_TYPE_UNIT_TYPE_CREATE_CONTROLLER := "public UnitController createController(Unit unit){"
const SOURCE_UNIT_AFTER_SYNC_METHOD := "public void afterSync(){"
const SOURCE_UNIT_AFTER_SYNC_COMMENT := "set up type info after reading"
const SOURCE_UNIT_AFTER_SYNC_SET_TYPE_CALL := "setType(this.type);"
const SOURCE_UNIT_AFTER_SYNC_SET_TYPE_ARG := "this.type"
const SOURCE_UNIT_AFTER_SYNC_CONTROLLER_UNIT_CALL := "controller.unit(self());"
const SOURCE_UNIT_AFTER_SYNC_SELF_ARG := "self()"
const SOURCE_UNIT_AFTER_SYNC_SYNCCOMP_METHOD := "void afterSync(){}"
const SOURCE_UNIT_AFTER_READ_METHOD := "public void afterRead(){"
const SOURCE_UNIT_AFTER_READ_SET_TYPE_CALL := "setType(this.type);"
const SOURCE_UNIT_AFTER_READ_SET_TYPE_ARG := "this.type"
const SOURCE_UNIT_AFTER_READ_CONTROLLER_UNIT_CALL := "controller.unit(self());"
const SOURCE_UNIT_AFTER_READ_SELF_ARG := "self()"
const SOURCE_UNIT_AFTER_READ_RESET_COMMENT := "reset controller state"
const SOURCE_UNIT_AFTER_READ_RESET_GUARD := "if(!(controller instanceof AIController ai && ai.keepState())){"
const SOURCE_UNIT_AFTER_READ_CREATE_CONTROLLER_CALL := "controller(type.createController(self()));"
const SOURCE_UNIT_AFTER_READ_AI_KEEP_STATE_METHOD := "public boolean keepState(){"
const SOURCE_UNIT_AFTER_READ_UNIT_TYPE_CREATE_CONTROLLER_METHOD := "public UnitController createController(Unit unit){"
const SOURCE_UNIT_AFTER_READ_ALL_OVERRIDE := "@Override"
const SOURCE_UNIT_AFTER_READ_ALL_METHOD := "public void afterReadAll(){"
const SOURCE_UNIT_AFTER_READ_ALL_CALL := "controller.afterRead(self());"
const SOURCE_UNIT_AFTER_READ_ALL_SELF_ARG := "self()"
const SOURCE_UNIT_AFTER_READ_ALL_CONTROLLER_AFTER_READ_METHOD := "default void afterRead(Unit unit){"
const SOURCE_UNIT_ADD_METHOD := "public void add(){"
const SOURCE_UNIT_ADD_INITIAL_UPDATE_COUNT := "team.data().updateCount(type, 1);"
const SOURCE_UNIT_ADD_CAP_GUARD := "if(type.useUnitCap && count() > cap() && !spawnedByCore && !dead && !state.rules.editor){"
const SOURCE_UNIT_ADD_UNIT_CAP_DEATH_CALL := "Call.unitCapDeath(self());"
const SOURCE_UNIT_ADD_ROLLBACK_UPDATE_COUNT := "team.data().updateCount(type, -1);"
const SOURCE_UNIT_ADD_TEAM_DATA_UPDATE_COUNT_METHOD := "public void updateCount(UnitType type, int amount){"
const SOURCE_UNIT_ADD_TEAM_DATA_UPDATE_NULL_GUARD := "if(type == null) return;"
const SOURCE_UNIT_ADD_TEAM_DATA_UNIT_COUNT_CLAMP := "unitCount = Math.max(amount + unitCount, 0);"
const SOURCE_UNIT_ADD_TEAM_DATA_TYPE_COUNT_CLAMP := "typeCounts[type.id] = Math.max(amount + typeCounts[type.id], 0);"
const SOURCE_UNIT_ADD_UNIT_CAP_DEATH_METHOD := "public static void unitCapDeath(Unit unit){"
const SOURCE_UNIT_ADD_UNIT_CAP_DEATH_DEAD := "unit.dead = true;"
const SOURCE_UNIT_ADD_USE_UNIT_CAP_DEFAULT := "useUnitCap = true,"
const SOURCE_UNIT_ADD_RULES_EDITOR_DEFAULT := "public boolean editor = false;"
const SOURCE_UNIT_LANDED_SHAKE_THRESHOLD := SourceUnitDefaults.LANDED_SHAKE_THRESHOLD
const SOURCE_UNIT_LANDED_METHOD := "@Override\n    public void landed(){"
const SOURCE_UNIT_LANDED_SHAKE_GUARD := "if(type.mechLandShake > 0f){"
const SOURCE_UNIT_LANDED_SHAKE_CALL := "Effect.shake(type.mechLandShake, type.mechLandShake, this);"
const SOURCE_UNIT_LANDED_TYPE_CALL := "type.landed(self());"
const SOURCE_UNIT_HEAL_OVERRIDE := "@Override\n    public void heal(float amount){"
const SOURCE_UNIT_HEAL_GUARD := "if(health < maxHealth && amount > 0){"
const SOURCE_UNIT_HEAL_WAS_HEALED := "wasHealed = true;"
const SOURCE_UNIT_HEAL_HEALTH_COMP_METHOD := "void heal(float amount){"
const SOURCE_UNIT_HEAL_HEALTH_COMP_ADD := "health += amount;"
const SOURCE_UNIT_HEAL_HEALTH_COMP_CLAMP := "clampHealth();"

static func is_grounded(elevation_value: float) -> bool:
	return elevation_value < SOURCE_UNIT_GROUNDED_EPSILON

static func is_flying(elevation_value: float) -> bool:
	return elevation_value >= SOURCE_UNIT_FLYING_ELEVATION_MIN

static func check_target_state(elevation_value: float, target_air: bool, target_ground: bool) -> Dictionary:
	var grounded: bool = is_grounded(elevation_value)
	var flying: bool = is_flying(elevation_value)
	return {
		"grounded": grounded,
		"flying": flying,
		"targetable": (grounded and target_ground) or (flying and target_air),
	}

static func can_drown_state(elevation_value: float, type_can_drown: bool) -> Dictionary:
	var grounded: bool = is_grounded(elevation_value)
	return {
		"grounded": grounded,
		"can_drown": grounded and type_can_drown,
	}

static func drown_floor_state(floor_on_value: Variant) -> Variant:
	return floor_on_value

static func wobble_state(current_x: float, current_y: float, source_time: float, source_delta: float, elevation_value: float, unit_id: int, sin_scaled: Callable, cos_scaled: Callable) -> Dictionary:
	var wobble_input := source_time + float(unit_id % 10) * 12.0
	var dx := float(sin_scaled.call(wobble_input, SOURCE_UNIT_WOBBLE_SIN_SCL, SOURCE_UNIT_WOBBLE_MAG)) * source_delta * elevation_value
	var dy := float(cos_scaled.call(wobble_input, SOURCE_UNIT_WOBBLE_SIN_SCL, SOURCE_UNIT_WOBBLE_MAG)) * source_delta * elevation_value
	return {
		"x": current_x + dx,
		"y": current_y + dy,
		"dx": dx,
		"dy": dy,
		"wobble_input": wobble_input,
	}

static func player_controllable_state(type_player_controllable: bool, controller_is_logic_ai: bool, logic_controller_exists: bool, logic_controller_block_privileged: bool) -> Dictionary:
	var logic_privileged_blocked := controller_is_logic_ai and logic_controller_exists and logic_controller_block_privileged
	return {
		"method": SOURCE_UNIT_PLAYER_CONTROLLABLE_METHOD,
		"returnExpr": SOURCE_UNIT_PLAYER_CONTROLLABLE_RETURN,
		"playerControllable": type_player_controllable and not logic_privileged_blocked,
		"logicPrivilegedBlocked": logic_privileged_blocked,
		"call": "playerControllable()",
	}

static func targetable_state(type_targetable: bool, type_vulnerable_with_payloads: bool, unit_is_payloadc: bool, unit_has_payload: bool, targeter_id: int) -> Dictionary:
	var payload_targetable := type_vulnerable_with_payloads and unit_is_payloadc and unit_has_payload
	return {
		"method": SOURCE_UNIT_TARGETABLE_METHOD,
		"unitReturn": SOURCE_UNIT_TARGETABLE_UNIT_RETURN,
		"typeMethod": SOURCE_UNIT_TARGETABLE_TYPE_METHOD,
		"typeReturn": SOURCE_UNIT_TARGETABLE_TYPE_RETURN,
		"targetable": type_targetable or payload_targetable,
		"payloadTargetable": payload_targetable,
		"targeter_id": targeter_id,
		"call": "type.targetable(self(), targeter)",
	}

static func killable_state(type_killable: bool) -> Dictionary:
	return {
		"killable": type_killable,
		"call": "type.killable(self())",
	}

static func hittable_state(type_hittable: bool, type_vulnerable_with_payloads: bool, unit_is_payloadc: bool, unit_has_payload: bool) -> Dictionary:
	var payload_hittable := type_vulnerable_with_payloads and unit_is_payloadc and unit_has_payload
	return {
		"hittable": type_hittable or payload_hittable,
		"payloadHittable": payload_hittable,
		"call": SOURCE_UNIT_HITTABLE_CALL,
	}

static func after_sync_state(type_id: int, controller_exists: bool) -> Dictionary:
	return {
		"type_id": type_id,
		"controller_exists": controller_exists,
		"call_order": ["setType", "controller.unit"],
		"setType_arg": SOURCE_UNIT_AFTER_SYNC_SET_TYPE_ARG,
		"controllerUnitArg": SOURCE_UNIT_AFTER_SYNC_SELF_ARG,
	}

static func after_read_state(type_id: int, controller_is_ai_controller: bool, ai_keep_state: bool, controller_exists: bool) -> Dictionary:
	var reset_controller := not (controller_is_ai_controller and ai_keep_state)
	return {
		"type_id": type_id,
		"controller_exists": controller_exists,
		"controllerIsAIController": controller_is_ai_controller,
		"aiKeepState": ai_keep_state,
		"resetController": reset_controller,
		"call_order": ["setType", "controller.unit", "controller(type.createController)"] if reset_controller else ["setType", "controller.unit"],
		"setType_arg": SOURCE_UNIT_AFTER_READ_SET_TYPE_ARG,
		"controllerUnitArg": SOURCE_UNIT_AFTER_READ_SELF_ARG,
		"createControllerArg": SOURCE_UNIT_AFTER_READ_SELF_ARG,
	}

static func after_read_all_state(controller_exists: bool) -> Dictionary:
	return {
		"controller_exists": controller_exists,
		"call": SOURCE_UNIT_AFTER_READ_ALL_CALL,
		"afterReadArg": SOURCE_UNIT_AFTER_READ_ALL_SELF_ARG,
	}

static func add_state(type_use_unit_cap: bool, count_after_add: int, cap_value: int, spawned_by_core: bool, dead: bool, rules_editor: bool) -> Dictionary:
	var over_cap := type_use_unit_cap and count_after_add > cap_value and not spawned_by_core and not dead and not rules_editor
	var rollback_update_count: Variant = null
	if over_cap:
		rollback_update_count = {"call": SOURCE_UNIT_ADD_ROLLBACK_UPDATE_COUNT, "amount": -1}
	return {
		"initialUpdateCount": {"call": SOURCE_UNIT_ADD_INITIAL_UPDATE_COUNT, "amount": 1},
		"guard": {
			"typeUseUnitCap": type_use_unit_cap,
			"countAfterAdd": count_after_add,
			"cap": cap_value,
			"spawnedByCore": spawned_by_core,
			"dead": dead,
			"rulesEditor": rules_editor,
		},
		"unitCapDeath": over_cap,
		"rollbackUpdateCount": rollback_update_count,
		"call_order": ["team.data().updateCount(+1)", "Call.unitCapDeath", "team.data().updateCount(-1)"] if over_cap else ["team.data().updateCount(+1)"],
	}

static func move_at_state(vel_x: float, vel_y: float, vector_x: float, vector_y: float, acceleration: float, source_delta: float, vec2_limit: Callable) -> Dictionary:
	var vel := Vector2(vel_x, vel_y)
	var target := Vector2(vector_x, vector_y)
	var delta: Vector2 = vec2_limit.call(target - vel, acceleration * target.length() * source_delta)
	var next_vel := vel + delta
	return {
		"method": SOURCE_UNIT_MOVE_AT_METHOD,
		"targetSet": SOURCE_UNIT_MOVE_AT_TARGET_SET,
		"deltaLimit": SOURCE_UNIT_MOVE_AT_DELTA_LIMIT,
		"velAdd": SOURCE_UNIT_MOVE_AT_VEL_ADD,
		"vel_x": next_vel.x,
		"vel_y": next_vel.y,
		"delta_x": delta.x,
		"delta_y": delta.y,
		"target_x": target.x,
		"target_y": target.y,
		"limit": acceleration * target.length() * source_delta,
	}

static func move_at_default_accel_state(vector_x: float, vector_y: float, type_accel: float) -> Dictionary:
	return {
		"method": SOURCE_UNIT_MOVE_AT_DEFAULT_ACCEL_METHOD,
		"source": SOURCE_UNIT_MOVE_AT_DEFAULT_ACCEL_CALL,
		"vector": {"x": vector_x, "y": vector_y},
		"acceleration": type_accel,
		"call": "moveAt",
	}

static func approach_state(vel_x: float, vel_y: float, vector_x: float, vector_y: float, type_accel: float, speed_value: float, source_delta: float) -> Dictionary:
	var vel := Vector2(vel_x, vel_y)
	var target := Vector2(vector_x, vector_y)
	var alpha := source_delta * type_accel * speed_value
	var diff := vel - target
	var alpha2 := alpha * alpha
	var len2 := diff.length_squared()
	var next_vel := Vector2.ZERO
	if len2 > alpha2:
		var scl := sqrt(alpha2 / len2)
		next_vel = vel - diff * scl
	else:
		next_vel = target
	return {
		"alpha": alpha,
		"vel_x": next_vel.x,
		"vel_y": next_vel.y,
		"target_x": target.x,
		"target_y": target.y,
	}

static func rotate_move_motion_state(unit_rotation_degrees: float, vec_x: float, vec_y: float) -> Dictionary:
	var amount := Vector2(vec_x, vec_y).length()
	var movement_state := SourceMathState.source_angles_trns_vec(unit_rotation_degrees, amount, 0.0)
	var movement := Vector2(float(movement_state.get("x", 0.0)), float(movement_state.get("y", 0.0)))
	return {
		"method": SOURCE_UNIT_ROTATE_MOVE_METHOD,
		"moveAtCall": SOURCE_UNIT_ROTATE_MOVE_MOTION_CALL,
		"vec2Trns": SOURCE_UNIT_ROTATE_MOVE_VEC2_TRNS_RETURN,
		"call": "moveAt",
		"movement": {"x": movement.x, "y": movement.y},
		"amount": amount,
	}

static func rotate_move_rotation_state(current_rotation: float, vec_x: float, vec_y: float, type_rotate_speed: float, speed_multiplier_value: float, source_delta: float, vec2_angle: Callable, angles_move_toward: Callable) -> Dictionary:
	var vector_is_zero := vec_x == 0.0 and vec_y == 0.0
	var target_rotation := float(vec2_angle.call(vec_x, vec_y)) if not vector_is_zero else current_rotation
	var next_rotation := current_rotation
	if not vector_is_zero:
		next_rotation = float(angles_move_toward.call(current_rotation, target_rotation, type_rotate_speed * source_delta * speed_multiplier_value))
	return {
		"gate": SOURCE_UNIT_ROTATE_MOVE_ROTATION_GATE,
		"rotationAssignment": SOURCE_UNIT_ROTATE_MOVE_ROTATION_ASSIGNMENT,
		"vec2IsZero": SOURCE_UNIT_ROTATE_MOVE_VEC2_IS_ZERO,
		"vec2Angle": SOURCE_UNIT_ROTATE_MOVE_VEC2_ANGLE,
		"vector_is_zero": vector_is_zero,
		"target_rotation": target_rotation,
		"rotation": next_rotation,
	}

static func aim_look_position_state(pos_x: float, pos_y: float) -> Dictionary:
	return {
		"target": {"x": pos_x, "y": pos_y},
		"aim_call": "aim(Position)",
		"look_at_call": "lookAt(Position)",
		"call_order": ["aim", "lookAt"],
	}

static func aim_look_xy_state(target_x: float, target_y: float) -> Dictionary:
	return {
		"target": {"x": target_x, "y": target_y},
		"aim_call": "aim(float, float)",
		"look_at_call": "lookAt(float, float)",
		"call_order": ["aim", "lookAt"],
	}

static func look_at_angle_state(current_rotation: float, target_angle: float, type_rotate_speed: float, speed_multiplier_value: float, source_delta: float, angles_move_toward: Callable) -> Dictionary:
	var rotation_speed := type_rotate_speed * source_delta * speed_multiplier_value
	var next_rotation := float(angles_move_toward.call(current_rotation, target_angle, rotation_speed))
	return {
		"method": SOURCE_UNIT_LOOK_AT_ANGLE_METHOD,
		"source": SOURCE_UNIT_LOOK_AT_ANGLE_ROTATION,
		"target_angle": target_angle,
		"rotation_speed": rotation_speed,
		"rotation": next_rotation,
	}

static func look_at_position_state(current_rotation: float, unit_x: float, unit_y: float, target_x: float, target_y: float, type_rotate_speed: float, speed_multiplier_value: float, source_delta: float, angles_angle: Callable, angles_move_toward: Callable) -> Dictionary:
	var target_angle := float(angles_angle.call(unit_x, unit_y, target_x, target_y))
	var angle_state := look_at_angle_state(current_rotation, target_angle, type_rotate_speed, speed_multiplier_value, source_delta, angles_move_toward)
	return {
		"call": "lookAt(angleTo(pos))",
		"target": {"x": target_x, "y": target_y},
		"target_angle": angle_state["target_angle"],
		"rotation_speed": angle_state["rotation_speed"],
		"rotation": angle_state["rotation"],
	}

static func look_at_xy_state(current_rotation: float, unit_x: float, unit_y: float, target_x: float, target_y: float, type_rotate_speed: float, speed_multiplier_value: float, source_delta: float, angles_angle: Callable, angles_move_toward: Callable) -> Dictionary:
	var target_angle := float(angles_angle.call(unit_x, unit_y, target_x, target_y))
	var angle_state := look_at_angle_state(current_rotation, target_angle, type_rotate_speed, speed_multiplier_value, source_delta, angles_move_toward)
	return {
		"call": "lookAt(angleTo(x, y))",
		"target": {"x": target_x, "y": target_y},
		"target_angle": angle_state["target_angle"],
		"rotation_speed": angle_state["rotation_speed"],
		"rotation": angle_state["rotation"],
	}

static func controller_predicates_state(controller_is_ai_controller: bool, controller_is_command_ai: bool) -> Dictionary:
	return {
		"is_ai": controller_is_ai_controller,
		"allow_command": controller_is_command_ai,
		"is_commandable": controller_is_command_ai,
	}

static func can_target_state(other_exists: bool, other_is_unit: bool, other_unit_check_target_result: bool, other_is_building: bool, type_target_air: bool, type_target_ground: bool) -> Dictionary:
	if not other_exists:
		return {"branch": "null", "can_target": false}
	if other_is_unit:
		return {
			"branch": "unit",
			"can_target": other_unit_check_target_result,
			"unit_check_target_air": type_target_air,
			"unit_check_target_ground": type_target_ground,
		}
	return {
		"branch": "building" if other_is_building else "other",
		"can_target": other_is_building and type_target_ground,
	}

static func command_state(controller_is_command_ai: bool) -> Dictionary:
	if controller_is_command_ai:
		return {
			"returned_command_ai": true,
			"throws": false,
			"exception_type": "",
			"message": "",
		}
	return {
		"returned_command_ai": false,
		"throws": true,
		"exception_type": "IllegalArgumentException",
		"message": "Unit cannot be commanded - check isCommandable() first.",
	}

static func is_missile_state(unit_is_timed_killc: bool) -> Dictionary:
	return {
		"is_missile": unit_is_timed_killc,
		"instanceof": "TimedKillc",
	}

static func count_state(team_data_count_type_result: int, type_id: int) -> Dictionary:
	return {
		"count": team_data_count_type_result,
		"type_id": type_id,
		"call": "team.data().countType(type)",
	}

static func cap_state(team_is_wave_team: bool, rules_pvp: bool, state_is_campaign: bool, rules_disable_unit_cap: bool, team_ignore_unit_cap: bool, rules_unit_cap_variable: bool, rules_unit_cap: int, team_data_unit_cap: int) -> Dictionary:
	if (team_is_wave_team and not rules_pvp) or (state_is_campaign and team_is_wave_team) or rules_disable_unit_cap or team_ignore_unit_cap:
		return {
			"cap": 2147483647,
			"uncapped": true,
			"call": "Units.getCap(team)",
		}
	if rules_unit_cap_variable:
		return {
			"cap": max(0, rules_unit_cap + team_data_unit_cap),
			"uncapped": false,
			"call": "Units.getCap(team)",
		}
	return {
		"cap": max(0, rules_unit_cap),
		"uncapped": false,
		"call": "Units.getCap(team)",
	}

static func set_type_state(type_id: int, type_health: float, type_drag: float, type_armor: float, type_hit_size: float, mounts_length: int, type_weapons_size: int, abilities_length: int, type_abilities_size: int, first_ability_is_empty_data_ability: bool, controller_is_null: bool) -> Dictionary:
	return {
		"method": SOURCE_UNIT_SET_TYPE_METHOD,
		"assignType": SOURCE_UNIT_SET_TYPE_ASSIGN_TYPE,
		"assignMaxHealth": SOURCE_UNIT_SET_TYPE_ASSIGN_MAX_HEALTH,
		"assignDrag": SOURCE_UNIT_SET_TYPE_ASSIGN_DRAG,
		"assignArmor": SOURCE_UNIT_SET_TYPE_ASSIGN_ARMOR,
		"assignHitSize": SOURCE_UNIT_SET_TYPE_ASSIGN_HIT_SIZE,
		"setupWeaponsGuard": SOURCE_UNIT_SET_TYPE_SETUP_WEAPONS_GUARD,
		"abilitiesGuard": SOURCE_UNIT_SET_TYPE_ABILITIES_GUARD,
		"abilitiesArray": SOURCE_UNIT_SET_TYPE_ABILITIES_ARRAY,
		"abilityCopy": SOURCE_UNIT_SET_TYPE_ABILITY_COPY,
		"abilityDataCarry": SOURCE_UNIT_SET_TYPE_ABILITY_DATA_CARRY,
		"controllerGuard": SOURCE_UNIT_SET_TYPE_CONTROLLER_GUARD,
		"unitTypeCreateControllerMethod": SOURCE_UNIT_SET_TYPE_UNIT_TYPE_CREATE_CONTROLLER,
		"assigned_type_id": type_id,
		"maxHealth": type_health,
		"drag": type_drag,
		"armor": type_armor,
		"hitSize": type_hit_size,
		"setupWeapons": mounts_length != type_weapons_size,
		"refreshAbilities": abilities_length != type_abilities_size or (abilities_length > 0 and first_ability_is_empty_data_ability),
		"createController": controller_is_null,
		"call": "setType(UnitType type)",
	}

static func drowning_state(floor_exists: bool, floor_is_liquid: bool, floor_drown_time: float, can_drown_value: bool, current_drown_time: float, source_delta: float, hit_size: float, type_drown_time_multiplier: float, chance_delta_result: bool, net_client: bool) -> Dictionary:
	var can_drown_on_floor := floor_exists and floor_is_liquid and floor_drown_time > 0.0 and can_drown_value
	var drown_time_before_clamp := current_drown_time
	var drown_increment := 0.0
	var effect_call: Variant = null
	var kill_unit := false
	var event_call: Variant = null
	var last_drown_floor_set := false
	if can_drown_on_floor:
		last_drown_floor_set = true
		drown_increment = source_delta / (hit_size / SOURCE_UNIT_DROWN_HIT_SIZE_DIVISOR * type_drown_time_multiplier * floor_drown_time)
		drown_time_before_clamp += drown_increment
		if chance_delta_result:
			effect_call = {
				"call": "floor.drownUpdateEffect.at(x, y, hitSize, floor.mapColor)",
				"chance": "Mathf.chanceDelta(0.05f)",
				"chanceValue": SOURCE_UNIT_DROWN_UPDATE_EFFECT_CHANCE,
			}
		kill_unit = drown_time_before_clamp >= SOURCE_UNIT_DROWN_KILL_THRESHOLD and not net_client
		if kill_unit:
			event_call = {"event": "Events.fire(new UnitDrownEvent(self()))"}
	else:
		drown_time_before_clamp -= source_delta / SOURCE_UNIT_DROWN_DRY_DECAY_DIVISOR
	var clamped_drown_time: float = clampf(drown_time_before_clamp, 0.0, 1.0)
	return {
		"canDrownOnFloor": can_drown_on_floor,
		"lastDrownFloorSet": last_drown_floor_set,
		"drownIncrement": drown_increment,
		"drownTimeBeforeClamp": drown_time_before_clamp,
		"drownTime": clamped_drown_time,
		"effectCall": effect_call,
		"kill": kill_unit,
		"eventCall": event_call,
		"netClient": net_client,
	}

static func type_hook_state() -> Dictionary:
	return {
		"call": "type.update(self())",
		"arg": "self()",
		"unitTypeHook": "public void update(Unit unit)",
		"order": "first statement in UnitComp.update()",
	}

static func landed_state(type_mech_land_shake: float) -> Dictionary:
	var shake := type_mech_land_shake > SOURCE_UNIT_LANDED_SHAKE_THRESHOLD
	var shake_call: Variant = null
	if shake:
		shake_call = {
			"call": SOURCE_UNIT_LANDED_SHAKE_CALL.trim_suffix(";"),
			"intensity": type_mech_land_shake,
			"duration": type_mech_land_shake,
			"locArg": "this",
		}
	return {
		"shake": shake,
		"shakeCall": shake_call,
		"typeLanded": {"call": SOURCE_UNIT_LANDED_TYPE_CALL.trim_suffix(";"), "arg": "self()"},
		"call_order": ["Effect.shake", "type.landed"] if shake else ["type.landed"],
	}

static func heal_state(current_health: float, max_health: float, amount: float, current_was_healed: bool) -> Dictionary:
	var next_health := current_health + amount
	next_health = min(next_health, max_health)
	if is_nan(next_health):
		next_health = 0.0
	var set_was_healed := next_health < max_health and amount > SOURCE_UNIT_HEAL_AMOUNT_POSITIVE_THRESHOLD
	return {
		"guard": {"healthLessThanMax": next_health < max_health, "amountPositive": amount > SOURCE_UNIT_HEAL_AMOUNT_POSITIVE_THRESHOLD},
		"health": next_health,
		"healthDelta": next_health - current_health,
		"healthCompAdd": SOURCE_UNIT_HEAL_HEALTH_COMP_ADD,
		"healthCompClamp": SOURCE_UNIT_HEAL_HEALTH_COMP_CLAMP,
		"healthCompHeal": SOURCE_UNIT_HEAL_HEALTH_COMP_METHOD,
		"wasHealed": true if set_was_healed else current_was_healed,
		"setWasHealed": set_was_healed,
		"healthMutationSource": "HealthComp.heal(float amount)",
		"override": SOURCE_UNIT_HEAL_OVERRIDE,
	}

static func heal_time_state(was_healed_value: bool, current_heal_time: float, source_delta: float) -> Dictionary:
	var reset_heal_time := was_healed_value and current_heal_time <= SOURCE_UNIT_HEAL_TIME_RESET_THRESHOLD
	var heal_time := SOURCE_UNIT_HEAL_TIME_RESET_VALUE if reset_heal_time else current_heal_time
	heal_time -= source_delta / SOURCE_UNIT_HEAL_TIME_DECAY_DIVISOR
	return {
		"healTime": heal_time,
		"wasHealed": false,
		"resetHealTime": reset_heal_time,
		"decay": source_delta / SOURCE_UNIT_HEAL_TIME_DECAY_DIVISOR,
		"order": ["updateDrowning", "healTime gate", "healTime decay", "wasHealed reset"],
	}

static func captured_sector_death_state(team_is_only_ai: bool, state_is_campaign: bool, sector_is_captured: bool) -> Dictionary:
	var kill_unit := team_is_only_ai and state_is_campaign and sector_is_captured
	return {
		"guard": {"team.isOnlyAI()": team_is_only_ai, "state.isCampaign()": state_is_campaign, "state.getSector().isCaptured()": sector_is_captured},
		"kill": kill_unit,
		"call": "kill()" if kill_unit else "",
	}

static func sound_loop_state(headless_value: bool, type_loop_sound: String, type_loop_sound_volume: float, type_move_sound: String, type_move_sound_volume: float, type_move_sound_pitch_min: float, type_move_sound_pitch_max: float, velocity_x: float, velocity_y: float, type_speed: float) -> Dictionary:
	var sound_enabled := not headless_value
	var velocity_len := sqrt(velocity_x * velocity_x + velocity_y * velocity_y)
	var progress := clampf(velocity_len / type_speed, 0.0, 1.0) if type_speed != 0.0 else 1.0
	var pitch := type_move_sound_pitch_min + (type_move_sound_pitch_max - type_move_sound_pitch_min) * progress
	var loop_sound_call: Variant = null
	var move_sound_call: Variant = null
	if sound_enabled:
		loop_sound_call = {
			"call": "control.sound.loop(type.loopSound, this, type.loopSoundVolume)",
			"sound": type_loop_sound,
			"volume": type_loop_sound_volume,
		}
		if type_move_sound != "Sounds.none":
			move_sound_call = {
				"call": "control.sound.loop(type.moveSound, this, type.moveSoundVolume * progress, pitch)",
				"sound": type_move_sound,
				"progress": progress,
				"volume": type_move_sound_volume * progress,
				"pitch": pitch,
			}
	return {
		"soundEnabled": sound_enabled,
		"velocityLen": velocity_len,
		"progress": progress,
		"pitch": pitch,
		"loopSound": loop_sound_call,
		"moveSound": move_sound_call,
	}

static func unsupported_env_state(type_supports_env: bool, dead_value: bool) -> Dictionary:
	var env_death := not type_supports_env and not dead_value
	var unit_env_death_call: Variant = null
	var update_count_call: Variant = null
	if env_death:
		unit_env_death_call = {
			"call": "Call.unitEnvDeath(self())",
		}
		update_count_call = {
			"call": "team.data().updateCount(type, -1)",
			"amount": -1,
		}
	return {
		"envDeath": env_death,
		"guard": {"!type.supportsEnv(state.rules.env)": not type_supports_env, "!dead": not dead_value},
		"unitEnvDeath": unit_env_death_call,
		"updateCount": update_count_call,
		"callOrder": ["Call.unitEnvDeath(self())", "team.data().updateCount(type, -1)"] if env_death else [],
	}

static func abilities_loop_state(ability_ids: Array) -> Dictionary:
	var updates := []
	for ability_id in ability_ids:
		updates.append({
			"call": SOURCE_UNIT_UPDATE_ABILITIES_CALL,
			"ability": ability_id,
		})
	return {
		"abilitiesField": SOURCE_UNIT_UPDATE_ABILITIES_FIELD,
		"loop": SOURCE_UNIT_UPDATE_ABILITIES_LOOP,
		"updateCall": SOURCE_UNIT_UPDATE_ABILITIES_CALL,
		"abilityUpdateMethod": SOURCE_UNIT_UPDATE_ABILITIES_ABILITY_UPDATE_METHOD,
		"updates": updates,
		"updateCount": updates.size(),
	}

static func trail_position_state(trail_exists: bool, type_trail_length: int, type_use_engine_elevation: bool, elevation_value: float, type_engine_offset: float, x_value: float, y_value: float, source_rotation_degrees: float) -> Dictionary:
	var trail_scale := elevation_value if type_use_engine_elevation else SOURCE_UNIT_TRAIL_SCALE_DEFAULT
	var offset := type_engine_offset / SOURCE_UNIT_FALL_ENGINE_OFFSET_DIVISOR + type_engine_offset / SOURCE_UNIT_FALL_ENGINE_OFFSET_DIVISOR * trail_scale
	var angle := source_rotation_degrees + SOURCE_UNIT_FALL_ENGINE_ROTATION_OFFSET
	var position_state := SourceMathState.source_angles_trns_vec(angle, offset, 0.0)
	var cx := x_value + float(position_state.get("x", 0.0))
	var cy := y_value + float(position_state.get("y", 0.0))
	if not trail_exists:
		return {
			"trailExists": false,
			"scale": trail_scale,
			"offset": offset,
			"position": {"x": cx, "y": cy},
			"lengthSet": null,
			"trailUpdate": null,
		}
	return {
		"trailExists": true,
		"scale": trail_scale,
		"offset": offset,
		"position": {"x": cx, "y": cy},
		"lengthSet": {"call": "trail.length = type.trailLength", "length": type_trail_length},
		"trailUpdate": {"call": "trail.update(cx, cy)", "x": cx, "y": cy},
	}

static func drag_formula_state(type_drag: float, grounded_value: bool, floor_drag_multiplier: float, unit_drag_multiplier: float, rules_drag_multiplier: float) -> Dictionary:
	var floor_factor := floor_drag_multiplier if grounded_value else SOURCE_UNIT_DRAG_FLOOR_FACTOR_DEFAULT
	var unit_drag := type_drag * floor_factor * unit_drag_multiplier * rules_drag_multiplier
	return {
		"drag": unit_drag,
		"floorFactor": floor_factor,
		"grounded": grounded_value,
		"formula": "type.drag * (isGrounded() ? floorOn().dragMultiplier : 1f) * dragMultiplier * state.rules.dragMultiplier",
		"inputs": {
			"type.drag": type_drag,
			"floorOn().dragMultiplier": floor_drag_multiplier,
			"dragMultiplier": unit_drag_multiplier,
			"state.rules.dragMultiplier": rules_drag_multiplier,
		},
	}

static func falling_drag_state(dead_value: bool, health_value: float, current_drag: float) -> Dictionary:
	var guard := dead_value or health_value <= 0.0
	var next_drag := SOURCE_UNIT_FALLING_DRAG_MIN if guard else current_drag
	return {
		"guard": guard,
		"drag": next_drag,
		"call": "drag = 0.01f" if guard else "",
		"source": "if(dead || health <= 0){",
	}

static func falling_smoke_state(dead_value: bool, health_value: float, chance_delta_result: bool, unit_x: float, unit_y: float, hit_size: float, tmp_v1_x: float, tmp_v1_y: float) -> Dictionary:
	var falling_guard := dead_value or health_value <= 0.0
	var effect_call: Variant = null
	if falling_guard and chance_delta_result:
		effect_call = {
			"call": "type.fallEffect.at(x + Tmp.v1.x, y + Tmp.v1.y)",
			"x": unit_x + tmp_v1_x,
			"y": unit_y + tmp_v1_y,
			"tmp": {"call": "Tmp.v1.rnd(Mathf.range(hitSize))", "x": tmp_v1_x, "y": tmp_v1_y},
			"range": {"call": "Mathf.range(hitSize)", "hitSize": hit_size},
		}
	return {
		"fallingGuard": falling_guard,
		"chance": {"call": "Mathf.chanceDelta(0.1)", "result": chance_delta_result, "chanceValue": SOURCE_UNIT_FALL_SMOKE_CHANCE},
		"effect": effect_call,
	}

static func falling_engine_trail_state(dead_value: bool, health_value: float, chance_delta_result: bool, unit_x: float, unit_y: float, source_rotation_degrees: float, elevation_value: float, type_engine_offset: float, type_engine_size: float, engine_range_value: float, x_range_value: float, y_range_value: float, random_rotation_value: float) -> Dictionary:
	var falling_guard := dead_value or health_value <= 0.0
	var offset := type_engine_offset / SOURCE_UNIT_FALL_ENGINE_OFFSET_DIVISOR + type_engine_offset / SOURCE_UNIT_FALL_ENGINE_OFFSET_DIVISOR * elevation_value
	var angle := source_rotation_degrees + SOURCE_UNIT_FALL_ENGINE_ROTATION_OFFSET
	var effect_call: Variant = null
	if falling_guard and chance_delta_result:
		var position_state := SourceMathState.source_angles_trns_vec(angle, offset, 0.0)
		effect_call = {
			"call": "type.fallEngineEffect.at(x + Angles.trnsx(rotation + 180, offset) + Mathf.range(range), y + Angles.trnsy(rotation + 180, offset) + Mathf.range(range), Mathf.random())",
			"x": unit_x + float(position_state.get("x", 0.0)) + x_range_value,
			"y": unit_y + float(position_state.get("y", 0.0)) + y_range_value,
			"rotation": random_rotation_value,
			"range": {"call": "Mathf.range(type.engineSize)", "value": engine_range_value, "type.engineSize": type_engine_size},
			"xRange": {"call": "Mathf.range(range)", "value": x_range_value},
			"yRange": {"call": "Mathf.range(range)", "value": y_range_value},
			"offset": offset,
		}
	return {
		"fallingGuard": falling_guard,
		"chance": {"call": "Mathf.chanceDelta(0.2)", "result": chance_delta_result, "chanceValue": SOURCE_UNIT_FALL_ENGINE_TRAIL_CHANCE},
		"angle": angle,
		"offset": offset,
		"effect": effect_call,
	}

static func falling_descent_state(dead_value: bool, health_value: float, elevation_value: float, type_fall_speed: float, source_delta: float, is_grounded_value: bool, max_health: float, type_wreck_health_multiplier: float, unit_id: int) -> Dictionary:
	var falling_guard := dead_value or health_value <= 0.0
	var next_elevation := elevation_value
	if falling_guard:
		next_elevation -= type_fall_speed * source_delta
	var wreck_health_threshold := -max_health * type_wreck_health_multiplier
	var destroy_call: Variant = null
	if falling_guard and (is_grounded_value or health_value <= wreck_health_threshold):
		destroy_call = {
			"call": "Call.unitDestroy(id)",
			"id": unit_id,
		}
	return {
		"fallingGuard": falling_guard,
		"elevationBefore": elevation_value,
		"elevation": next_elevation,
		"descent": {"call": "elevation -= type.fallSpeed * Time.delta", "type.fallSpeed": type_fall_speed, "Time.delta": source_delta},
		"grounded": is_grounded_value,
		"wreckHealthThreshold": wreck_health_threshold,
		"destroy": destroy_call,
	}

static func tile_unit_on_any_state(tile_exists: bool, tile_build_exists: bool, unit_id: int) -> Dictionary:
	var guard := tile_exists and tile_build_exists
	var callback: Variant = null
	if guard:
		callback = {
			"call": "tile.build.unitOnAny(self())",
			"unit": unit_id,
		}
	return {
		"guard": guard,
		"tileExists": tile_exists,
		"tileBuildExists": tile_build_exists,
		"unitOnAny": callback,
	}

static func tile_unit_on_state(tile_exists: bool, is_grounded_value: bool, type_hovering: bool, tile_build_exists: bool, unit_id: int) -> Dictionary:
	var guard := tile_exists and is_grounded_value and not type_hovering
	var callback: Variant = null
	if guard and tile_build_exists:
		callback = {
			"call": "tile.build.unitOn(self())",
			"unit": unit_id,
		}
	return {
		"guard": guard,
		"tileExists": tile_exists,
		"isGrounded": is_grounded_value,
		"typeHovering": type_hovering,
		"tileBuildExists": tile_build_exists,
		"unitOn": callback,
	}

static func floor_damage_state(tile_exists: bool, is_grounded_value: bool, type_hovering: bool, floor_damage_taken: float, source_delta: float, hit_time: float, hit_duration: float) -> Dictionary:
	var guard := tile_exists and is_grounded_value and not type_hovering
	var damage_call: Variant = null
	if guard and floor_damage_taken > 0.0:
		var scaled_damage := floor_damage_taken * source_delta
		var with_effect := hit_time <= -10.0 + hit_duration
		damage_call = {
			"call": "damageContinuous(floor.damageTaken)",
			"floor.damageTaken": floor_damage_taken,
			"Time.delta": source_delta,
			"scaledDamage": scaled_damage,
			"withEffect": with_effect,
		}
	return {
		"guard": guard,
		"tileExists": tile_exists,
		"isGrounded": is_grounded_value,
		"typeHovering": type_hovering,
		"damage": damage_call,
	}

static func solid_tile_response_state(tile_exists: bool, can_pass_on_value: bool, type_can_boost: bool, current_elevation: float, net_client_value: bool, headless_value: bool, is_remote_value: bool, unit_id: int) -> Dictionary:
	var guard := tile_exists and not can_pass_on_value
	var next_elevation := current_elevation
	var kill_call: Variant = null
	if guard and type_can_boost:
		next_elevation = SOURCE_UNIT_SOLID_TILE_BOOST_ELEVATION
	elif guard and (not net_client_value) and not ((not headless_value) and is_remote_value):
		kill_call = {
			"call": "kill()",
			"unit": unit_id,
		}
	return {
		"guard": guard,
		"canPassOn": can_pass_on_value,
		"typeCanBoost": type_can_boost,
		"elevation": next_elevation,
		"netClient": net_client_value,
		"headless": headless_value,
		"isRemote": is_remote_value,
		"kill": kill_call,
	}

static func ai_controller_server_gate_state(net_client_value: bool, dead_value: bool, should_update_controller_value: bool, unit_id: int) -> Dictionary:
	var guard := (not net_client_value) and (not dead_value) and should_update_controller_value
	var controller_update: Variant = null
	if guard:
		controller_update = {
			"call": SOURCE_UNIT_UPDATE_AI_CONTROLLER_CALL,
			"unit": unit_id,
		}
	return {
		"controllerField": SOURCE_UNIT_UPDATE_AI_CONTROLLER_FIELD,
		"deadImport": SOURCE_UNIT_UPDATE_AI_DEAD_IMPORT,
		"comment": SOURCE_UNIT_UPDATE_AI_COMMENT,
		"guardSource": SOURCE_UNIT_UPDATE_AI_GUARD,
		"controllerUpdateCall": SOURCE_UNIT_UPDATE_AI_CONTROLLER_CALL,
		"shouldUpdateMethod": SOURCE_UNIT_UPDATE_AI_SHOULD_UPDATE_METHOD,
		"shouldUpdateDefault": SOURCE_UNIT_UPDATE_AI_SHOULD_UPDATE_DEFAULT,
		"unitControllerUpdate": SOURCE_UNIT_UPDATE_AI_UNIT_CONTROLLER_UPDATE,
		"netClientMethod": SOURCE_UNIT_UPDATE_AI_NET_CLIENT_METHOD,
		"netClientBody": SOURCE_UNIT_UPDATE_AI_NET_CLIENT_BODY,
		"guard": guard,
		"netClient": net_client_value,
		"dead": dead_value,
		"shouldUpdateController": should_update_controller_value,
		"controllerUpdate": controller_update,
	}

static func invalid_controller_reset_state(controller_is_valid_value: bool, unit_id: int) -> Dictionary:
	var guard := not controller_is_valid_value
	var reset_controller: Variant = null
	if guard:
		reset_controller = {
			"call": "resetController()",
			"effect": "controller(type.createController(self()))",
			"unit": unit_id,
		}
	return {
		"guard": guard,
		"controllerIsValid": controller_is_valid_value,
		"resetController": reset_controller,
	}

static func spawned_core_despawn_state(spawned_by_core_value: bool, is_player_value: bool, dead_value: bool, unit_id: int) -> Dictionary:
	var guard := spawned_by_core_value and (not is_player_value) and (not dead_value)
	var despawn_call: Variant = null
	if guard:
		despawn_call = {
			"call": "Call.unitDespawn(self())",
			"effect": "Fx.unitDespawn.at(unit.x, unit.y, 0, unit)",
			"remove": "unit.remove()",
			"unit": unit_id,
		}
	return {
		"guard": guard,
		"spawnedByCore": spawned_by_core_value,
		"isPlayer": is_player_value,
		"dead": dead_value,
		"despawn": despawn_call,
	}

static func boosting_default_event_state(boost: bool) -> Dictionary:
	return {
		"method": SOURCE_UNIT_UPDATE_BOOSTING_DEFAULT_METHOD,
		"delegateCall": SOURCE_UNIT_UPDATE_BOOSTING_DEFAULT_CALL,
		"overloadMethod": SOURCE_UNIT_UPDATE_BOOSTING_OVERLOAD_METHOD,
		"boost": boost,
		"event": false,
	}

static func boosting_guard_state(type_can_boost: bool, dead_state: bool, elevation_value: float) -> Dictionary:
	var returned: bool = (not type_can_boost) or dead_state
	return {
		"overloadMethod": SOURCE_UNIT_UPDATE_BOOSTING_OVERLOAD_METHOD,
		"guard": SOURCE_UNIT_UPDATE_BOOSTING_GUARD,
		"returned": returned,
		"can_update_boosting": not returned,
		"elevation": elevation_value,
	}

static func boosting_should_boost_state(boost: bool, on_solid_result: bool, elevation_value: float, can_land_result: bool) -> Dictionary:
	var flying: bool = is_flying(elevation_value)
	var should_boost: bool = boost or on_solid_result or (flying and not can_land_result)
	return {
		"shouldBoostSource": SOURCE_UNIT_UPDATE_BOOSTING_SHOULD_BOOST,
		"isFlyingReturn": SOURCE_UNIT_IS_FLYING_RETURN,
		"flying": flying,
		"should_boost": should_boost,
	}

static func boosting_elevation_state(current_elevation: float, type_can_boost: bool, should_boost: bool, type_rise_speed: float, type_descent_speed: float, source_delta: float) -> Dictionary:
	var target_elevation: float = SOURCE_UNIT_BOOSTING_TARGET_ELEVATION if should_boost else SOURCE_UNIT_BOOSTING_BASE_ELEVATION
	if not type_can_boost:
		target_elevation = SOURCE_UNIT_BOOSTING_BASE_ELEVATION
	var speed: float = type_rise_speed if should_boost else type_descent_speed
	var next_elevation: float = SourceMathState.source_approach_delta(current_elevation, target_elevation, speed, source_delta)
	return {
		"elevationAssignment": SOURCE_UNIT_UPDATE_BOOSTING_ELEVATION_ASSIGNMENT,
		"target_elevation": target_elevation,
		"speed": speed,
		"elevation": next_elevation,
		"mathfNumMethod": SourceMathState.SOURCE_ARC_MATHF_NUM_METHOD,
		"mathfNumReturn": SOURCE_ARC_MATHF_NUM_RETURN,
		"mathfApproachDeltaMethod": SOURCE_ARC_MATHF_APPROACH_DELTA_METHOD,
		"mathfApproachDeltaReturn": SOURCE_ARC_MATHF_APPROACH_DELTA_RETURN,
		"mathfApproachMethod": SOURCE_ARC_MATHF_APPROACH_METHOD,
		"mathfApproachReturn": SOURCE_ARC_MATHF_APPROACH_RETURN,
		"mathfClampFloatMethod": SOURCE_ARC_MATHF_CLAMP_FLOAT_METHOD,
		"mathfClampFloatReturn": SOURCE_ARC_MATHF_CLAMP_FLOAT_RETURN,
	}

static func boosting_event_state(event: bool) -> Dictionary:
	return {
		"eventGate": SOURCE_UNIT_UPDATE_BOOSTING_EVENT_GATE,
		"fireTrigger": SOURCE_UNIT_UPDATE_BOOSTING_EVENT_FIRE_TRIGGER,
		"triggerEnum": SOURCE_EVENT_TYPE_TRIGGER_ENUM,
		"unitCommandBoost": SOURCE_EVENT_TYPE_UNIT_COMMAND_BOOST,
		"event_fired": event,
		"trigger": "unitCommandBoost" if event else "",
	}

static func spawn_knockback_state(team_is_wave_team: bool, state_has_spawns_value: bool, net_client_value: bool, is_local_value: bool, hittable_value: bool, drop_zone_radius: float, hit_size: float, unit_x: float, unit_y: float, spawns: Array, source_delta: float) -> Dictionary:
	var guard := (not team_is_wave_team) and state_has_spawns_value and ((not net_client_value) or is_local_value) and hittable_value
	var relative_size := drop_zone_radius + hit_size / SOURCE_UNIT_SPAWN_KNOCKBACK_HIT_SIZE_DIVISOR + SOURCE_UNIT_SPAWN_KNOCKBACK_RELATIVE_SIZE_OFFSET
	var knockbacks := []
	if guard:
		for spawn in spawns:
			var spawn_x := float(spawn.get("x", 0.0))
			var spawn_y := float(spawn.get("y", 0.0))
			var dx := unit_x - spawn_x
			var dy := unit_y - spawn_y
			var distance := sqrt(dx * dx + dy * dy)
			var within_spawn := distance * distance < relative_size * relative_size
			if within_spawn:
				var strength := SOURCE_UNIT_SPAWN_KNOCKBACK_STRENGTH_OFFSET + SOURCE_UNIT_SPAWN_KNOCKBACK_RELATIVE_SIZE_OFFSET - distance / relative_size
				var knockback_scale := SOURCE_UNIT_SPAWN_KNOCKBACK_SCALE * source_delta
				var length_factor := strength / distance if distance != 0.0 else 0.0
				knockbacks.append({
					"call": "velAddNet(Tmp.v1.set(this).sub(spawn.worldx(), spawn.worldy()).setLength(0.1f + 1f - dst(spawn) / relativeSize).scl(0.45f * Time.delta))",
					"spawn": {"x": spawn_x, "y": spawn_y},
					"distance": distance,
					"strength": strength,
					"velocity": {"x": dx * length_factor * knockback_scale, "y": dy * length_factor * knockback_scale},
				})
	return {
		"guard": guard,
		"relativeSize": relative_size,
		"knockbacks": knockbacks,
	}

static func bounds_state(type_bounded: bool, world_unit_height: float, world_unit_width: float, rules_limit_map_area: bool, team_is_ai: bool, rules_limit_x: int, rules_limit_y: int, rules_limit_width: int, rules_limit_height: int, current_x: float, current_y: float, elevation_value: float, net_client: bool, is_local: bool, source_delta: float) -> Dictionary:
	var next_x := current_x
	var next_y := current_y
	var bot := 0.0
	var left := 0.0
	var top := world_unit_height
	var right := world_unit_width
	var dx := 0.0
	var dy := 0.0
	var vel_add_net: Variant = null
	var can_apply_net_local := false
	var grounded: bool = is_grounded(elevation_value)
	var use_limited_area := rules_limit_map_area and not team_is_ai
	if not type_bounded:
		return {
			"bounded": false,
			"x": next_x,
			"y": next_y,
			"velAddNet": vel_add_net,
			"grounded": grounded,
			"kill": false,
		}
	if use_limited_area:
		bot = float(rules_limit_y) * SourceWorldDefaults.TILESIZE
		left = float(rules_limit_x) * SourceWorldDefaults.TILESIZE
		top = float(rules_limit_height) * SourceWorldDefaults.TILESIZE + bot
		right = float(rules_limit_width) * SourceWorldDefaults.TILESIZE + left
	if (not net_client) or is_local:
		can_apply_net_local = true
		if next_x < left:
			dx += (-(next_x - left) / SOURCE_UNIT_WARP_DST)
		if next_y < bot:
			dy += (-(next_y - bot) / SOURCE_UNIT_WARP_DST)
		if next_x > right - SourceWorldDefaults.TILESIZE:
			dx -= (next_x - (right - SourceWorldDefaults.TILESIZE)) / SOURCE_UNIT_WARP_DST
		if next_y > top - SourceWorldDefaults.TILESIZE:
			dy -= (next_y - (top - SourceWorldDefaults.TILESIZE)) / SOURCE_UNIT_WARP_DST
		vel_add_net = {"x": dx * source_delta, "y": dy * source_delta}
		var margin := SourceWorldDefaults.TILESIZE * 1.0
		next_x = clampf(next_x, left - margin, right - SourceWorldDefaults.TILESIZE + margin)
		next_y = clampf(next_y, bot - margin, top - SourceWorldDefaults.TILESIZE + margin)
	if grounded:
		next_x = clampf(next_x, left, right - SourceWorldDefaults.TILESIZE)
		next_y = clampf(next_y, bot, top - SourceWorldDefaults.TILESIZE)
	var kill_unit := next_x < -SOURCE_FINAL_WORLD_BOUNDS + left or next_y < -SOURCE_FINAL_WORLD_BOUNDS + bot or next_x >= right + SOURCE_FINAL_WORLD_BOUNDS or next_y >= top + SOURCE_FINAL_WORLD_BOUNDS
	return {
		"bounded": true,
		"limits": {"bot": bot, "left": left, "top": top, "right": right, "limitedArea": use_limited_area},
		"canApplyNetLocal": can_apply_net_local,
		"dx": dx,
		"dy": dy,
		"velAddNet": vel_add_net,
		"grounded": grounded,
		"x": next_x,
		"y": next_y,
		"kill": kill_unit,
	}

static func nan_health_state(current_health: float) -> Dictionary:
	var health_is_nan := is_nan(current_health)
	return {
		"guard": "Float.isNaN(health)",
		"health": 0.0 if health_is_nan else current_health,
		"kill": health_is_nan,
	}

static func flying_transition_state(is_flying_value: bool, was_flying_value: bool, tile_exists: bool, floor_is_liquid: bool, tile_floor_color: String) -> Dictionary:
	var changed := is_flying_value != was_flying_value
	var land_effect: Variant = null
	if changed and was_flying_value and tile_exists:
		land_effect = {
			"call": "Fx.unitLand.at(x, y, floor.isLiquid ? 1f : 0.5f, tile.getFloorColor())",
			"rotation": SOURCE_UNIT_FLYING_TRANSITION_LAND_EFFECT_LIQUID_ROTATION if floor_is_liquid else SOURCE_UNIT_FLYING_TRANSITION_LAND_EFFECT_SOLID_ROTATION,
			"color": tile_floor_color,
		}
	return {
		"changed": changed,
		"landEffect": land_effect,
		"wasFlying": is_flying_value,
	}

static func walk_effect_state(type_hovering: bool, elevation_value: float, type_emit_walk_effect: bool, type_emit_walk_sound: bool, current_splash_timer: float, delta_x: float, delta_y: float, hit_size_value: float, tile_exists: bool, tile_floor_color: String, floor_map_color: String, floor_walk_sound_pitch_min: float, floor_walk_sound_pitch_max: float, floor_walk_sound_volume: float, random_pitch_value: float) -> Dictionary:
	var grounded := is_grounded(elevation_value)
	var gate := (not type_hovering) and grounded and type_emit_walk_effect
	var distance := sqrt(delta_x * delta_x + delta_y * delta_y)
	var threshold := SOURCE_UNIT_WALK_EFFECT_THRESHOLD_BASE + hit_size_value / SOURCE_UNIT_WALK_EFFECT_THRESHOLD_HIT_SIZE_DIVISOR
	var splash_timer := current_splash_timer
	var walk_effect: Variant = null
	var walk_sound: Variant = null
	if gate:
		splash_timer += distance
		if splash_timer >= threshold:
			walk_effect = {
				"call": "floor.walkEffect.at(x, y, hitSize() / 8f, tile != null ? tile.getFloorColor() : floor.mapColor)",
				"rotation": hit_size_value / SOURCE_UNIT_WALK_EFFECT_THRESHOLD_HIT_SIZE_DIVISOR,
				"color": tile_floor_color if tile_exists else floor_map_color,
			}
			splash_timer = 0.0
			if type_emit_walk_sound:
				walk_sound = {
					"call": "floor.walkSound.at(x, y, Mathf.random(floor.walkSoundPitchMin, floor.walkSoundPitchMax), floor.walkSoundVolume)",
					"pitch": random_pitch_value,
					"pitchMin": floor_walk_sound_pitch_min,
					"pitchMax": floor_walk_sound_pitch_max,
					"volume": floor_walk_sound_volume,
				}
	return {
		"grounded": grounded,
		"gate": gate,
		"distance": distance,
		"threshold": threshold,
		"splashTimer": splash_timer,
		"walkEffect": walk_effect,
		"walkSound": walk_sound,
	}

static func move_pref_state(type_omni_movement: bool, movement_x: float, movement_y: float) -> Dictionary:
	return {
		"method": SOURCE_UNIT_MOVE_PREF_METHOD,
		"omniGate": SOURCE_UNIT_MOVE_PREF_OMNI_GATE,
		"moveAtCall": SOURCE_UNIT_MOVE_PREF_MOVE_AT_CALL,
		"rotateMoveCall": SOURCE_UNIT_MOVE_PREF_ROTATE_MOVE_CALL,
		"movement": {"x": movement_x, "y": movement_y},
		"call": "moveAt" if type_omni_movement else "rotateMove",
	}

static func floor_speed_multiplier_state(elevation_value: float, type_hovering: bool, floor_on_speed_multiplier: float, type_floor_multiplier: float, speed_multiplier_value: float) -> Dictionary:
	var flying: bool = is_flying(elevation_value)
	var uses_air_floor: bool = flying or type_hovering
	var on_speed_multiplier: float = 1.0 if uses_air_floor else floor_on_speed_multiplier
	var result: float = pow(on_speed_multiplier, type_floor_multiplier) * speed_multiplier_value
	return {
		"flying": flying,
		"uses_air_floor": uses_air_floor,
		"on_speed_multiplier": on_speed_multiplier,
		"speed_multiplier": result,
	}

static func unloaded_state(unit_state: Variant) -> Variant:
	return unit_state
