extends RefCounted
class_name SourceWeaponsCoreState

const source_weapon_defaults := preload("res://src/game/SourceWeaponDefaults.gd")

const SOURCE_WEAPON_BASE_ROTATION_DEFAULT := source_weapon_defaults.BASE_ROTATION_DEFAULT

static func setup_mounts_state(weapon_states: Array) -> Dictionary:
	var mounts: Array = []
	for index in weapon_states.size():
		var weapon_state: Dictionary = weapon_states[index]
		mounts.append({
			"index": index,
			"weapon": str(weapon_state.get("weapon", "weapon%d" % index)),
			"call": "mounts[i] = def.weapons.get(i).mountType.get(def.weapons.get(i));",
			"constructor": "public WeaponMount(Weapon weapon){",
			"rotation": float(weapon_state.get("baseRotation", SOURCE_WEAPON_BASE_ROTATION_DEFAULT)),
		})
	return {
		"method": "void setupWeapons(UnitType def){",
		"array": "mounts = new WeaponMount[def.weapons.size];",
		"loop": "for(int i = 0; i < mounts.length; i++){",
		"mounts": mounts,
	}

static func set_rotation_state(mount_states: Array, source_rotation: float) -> Dictionary:
	var mounts: Array = []
	for index in mount_states.size():
		var mount_state: Dictionary = mount_states[index]
		mounts.append({
			"index": index,
			"weapon": str(mount_state.get("weapon", "weapon%d" % index)),
			"assignment": "mount.rotation = rotation;",
			"sourceParameter": "rotation",
			"rotation": source_rotation,
		})
	return {
		"method": "void setWeaponRotation(float rotation){",
		"loop": "for(WeaponMount mount : mounts){",
		"mounts": mounts,
	}

static func control_state(mount_states: Array, rotate_value: bool, shoot_value: bool) -> Dictionary:
	var mounts: Array = []
	for index in mount_states.size():
		var mount_state: Dictionary = mount_states[index]
		var controllable := bool(mount_state.get("controllable", true))
		mounts.append({
			"index": index,
			"weapon": str(mount_state.get("weapon", "weapon%d" % index)),
			"controlled": controllable,
			"guard": "if(mount.weapon.controllable){",
			"rotateAssignment": "mount.rotate = rotate;",
			"shootAssignment": "mount.shoot = shoot;",
			"rotate": rotate_value if controllable else bool(mount_state.get("rotate", false)),
			"shoot": shoot_value if controllable else bool(mount_state.get("shoot", false)),
		})
	return {
		"controlMethod": "void controlWeapons(boolean rotate, boolean shoot){",
		"loop": "for(WeaponMount mount : mounts){",
		"isRotate": rotate_value,
		"isShooting": shoot_value,
		"mounts": mounts,
	}

static func control_rotate_shoot_state(mount_states: Array, rotate_shoot: bool) -> Dictionary:
	var weapon_control_state := control_state(mount_states, rotate_shoot, rotate_shoot)
	weapon_control_state["delegate"] = "controlWeapons(rotateShoot, rotateShoot);"
	weapon_control_state["rotateShootMethod"] = "void controlWeapons(boolean rotateShoot){"
	weapon_control_state["rotateShootDelegate"] = "controlWeapons(rotateShoot, rotateShoot);"
	return weapon_control_state

static func aim_state(mount_states: Array, unit_x: float, unit_y: float, target_x: float, target_y: float, aim_dst: float) -> Dictionary:
	var aim_vector := Vector2(target_x, target_y) - Vector2(unit_x, unit_y)
	if aim_vector.length() < aim_dst and aim_vector.length_squared() > 0.0:
		aim_vector = aim_vector.normalized() * aim_dst
	var final_x := aim_vector.x + unit_x
	var final_y := aim_vector.y + unit_y
	var mounts: Array = []
	for index in mount_states.size():
		var mount_state: Dictionary = mount_states[index]
		var controllable := bool(mount_state.get("controllable", true))
		mounts.append({
			"index": index,
			"weapon": str(mount_state.get("weapon", "weapon%d" % index)),
			"controlled": controllable,
			"guard": "mount.weapon.controllable",
			"aimXAssignment": "mount.aimX = x;",
			"aimYAssignment": "mount.aimY = y;",
			"aimX": final_x if controllable else float(mount_state.get("aimX", 0.0)),
			"aimY": final_y if controllable else float(mount_state.get("aimY", 0.0)),
		})
	return {
		"floatMethod": "void aim(float x, float y){",
		"tmp": "Tmp.v1.set(x, y).sub(this.x, this.y);",
		"minDistance": "if(Tmp.v1.len() < type.aimDst) Tmp.v1.setLength(type.aimDst);",
		"zeroVectorSetLength": "return (oldLen2 == 0 || oldLen2 == len2) ? this : scl((float)Math.sqrt(len2 / oldLen2));",
		"aimX": final_x,
		"aimY": final_y,
		"mounts": mounts,
	}

static func aim_position_state(mount_states: Array, unit_x: float, unit_y: float, position_x: float, position_y: float, aim_dst: float) -> Dictionary:
	var weapon_aim_state := aim_state(mount_states, unit_x, unit_y, position_x, position_y, aim_dst)
	weapon_aim_state["positionMethod"] = "void aim(Position pos){"
	weapon_aim_state["positionDelegate"] = "aim(pos.getX(), pos.getY());"
	return weapon_aim_state

static func can_shoot_state(disarmed_value: bool) -> Dictionary:
	var can_shoot := not disarmed_value
	return {
		"canShootMethod": "boolean canShoot(){",
		"return": "return !disarmed;",
		"disarmed": disarmed_value,
		"canShoot": can_shoot,
	}

static func remove_continuous_bullet_cleanup_state(mount_states: Array, unit_id: int) -> Dictionary:
	var mounts: Array = []
	for index in mount_states.size():
		var mount_state: Dictionary = mount_states[index]
		var bullet_state: Dictionary = mount_state.get("bullet", {})
		var has_bullet := not bullet_state.is_empty()
		var owns_bullet := has_bullet and int(bullet_state.get("owner", -1)) == unit_id
		var continuous := bool(mount_state.get("continuous", false))
		var cleanup := continuous and has_bullet and owns_bullet
		var result_bullet = null
		var bullet_time = null
		if has_bullet:
			bullet_time = float(bullet_state.get("lifetime", 0.0)) - 10.0
			if not cleanup:
				bullet_time = float(bullet_state.get("time", 0.0))
				result_bullet = {
					"owner": int(bullet_state.get("owner", -1)),
					"time": bullet_time,
					"lifetime": float(bullet_state.get("lifetime", 0.0)),
				}
		mounts.append({
			"index": index,
			"weapon": str(mount_state.get("weapon", "weapon%d" % index)),
			"guard": "if(mount.weapon.continuous && mount.bullet != null && mount.bullet.owner == self()){",
			"continuous": continuous,
			"hadBullet": has_bullet,
			"ownsBullet": owns_bullet,
			"cleanup": cleanup,
			"timeAssignment": "mount.bullet.time = mount.bullet.lifetime - 10f;",
			"clearAssignment": "mount.bullet = null;",
			"bulletTime": bullet_time,
			"bullet": result_bullet,
		})
	return {
		"removeMethod": "public void remove(){",
		"loop": "for(WeaponMount mount : mounts){",
		"unit": unit_id,
		"mounts": mounts,
	}

static func remove_sound_stop_state(mount_states: Array) -> Dictionary:
	var mounts: Array = []
	for index in mount_states.size():
		var mount_state: Dictionary = mount_states[index]
		var has_sound := bool(mount_state.get("sound", false))
		var stop_call = null
		if has_sound:
			stop_call = {
				"call": "mount.sound.stop();",
				"method": "public void stop(){",
				"idGuard": "if(id != -1){",
				"effects": ["Core.audio.stop(id);", "id = -1;", "volume = 0f;"],
			}
		mounts.append({
			"index": index,
			"weapon": str(mount_state.get("weapon", "weapon%d" % index)),
			"guard": "if(mount.sound != null){",
			"hasSound": has_sound,
			"stopCall": stop_call,
		})
	return {
		"loop": "for(WeaponMount mount : mounts){",
		"mounts": mounts,
	}

static func update_dispatch_state(mount_states: Array, unit_id: int) -> Dictionary:
	var dispatches: Array = []
	for index in mount_states.size():
		var mount_state: Dictionary = mount_states[index]
		dispatches.append({
			"index": index,
			"weapon": str(mount_state.get("weapon", "weapon%d" % index)),
			"unit": unit_id,
			"call": "mount.weapon.update(self(), mount);",
			"unitArg": "self()",
			"mountArg": "mount",
			"weaponUpdateMethod": "public void update(Unit unit, WeaponMount mount){",
		})
	return {
		"updateComment": "/** Update shooting and rotation for this unit. */",
		"updateOverride": "@Override\n    public void update(){",
		"loop": "for(WeaponMount mount : mounts){",
		"mountsField": "@SyncLocal WeaponMount[] mounts = {};",
		"dispatches": dispatches,
	}
