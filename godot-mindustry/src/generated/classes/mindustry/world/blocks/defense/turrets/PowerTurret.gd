# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/defense/turrets/PowerTurret.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.defense.turrets"
const JAVA_KIND := "class"
const JAVA_NAME := "PowerTurret"
const JAVA_EXTENDS := "Turret"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "shootType", "type": "BulletType"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "PowerTurret", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "limitRange", "parameters": [{"name": "margin", "type": "float", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_setStats_0(_args: Array = []) -> Variant:
	var shoot_type: Variant = _args[0] if _args.size() > 0 else null
	var object_map_call: Dictionary = {"call": "ObjectMap.of(this, shootType)", "owner": "this", "shoot_type": shoot_type}
	var ammo_values_call: Dictionary = {"call": "StatValues.ammo(ObjectMap.of(this, shootType))", "object_map_call": object_map_call}
	var stats_add_call: Dictionary = {"call": "stats.add(Stat.ammo, StatValues.ammo(ObjectMap.of(this, shootType)));", "stat": "Stat.ammo", "ammo_values_call": ammo_values_call}
	return {"source_owner": "PortGame.source_power_turret_set_stats_state", "method": "public void setStats(){", "override_expr": "@Override", "super_set_stats_expr": "super.setStats();", "stats_add_expr": "stats.add(Stat.ammo, StatValues.ammo(ObjectMap.of(this, shootType)));", "shoot_type": shoot_type, "super_set_stats_called": true, "stats_add_called": true, "object_map_call": object_map_call, "ammo_values_call": ammo_values_call, "stats_add_call": stats_add_call}

func java_method_limitRange_1(_args: Array = []) -> Variant:
	var shoot_type: Variant = _args[0] if _args.size() > 0 else null
	var margin: float = float(_args[1] if _args.size() > 1 else 0.0)
	var limit_range_call: Dictionary = {"call": "limitRange(shootType, margin);", "shoot_type": shoot_type, "margin": margin}
	return {"source_owner": "PortGame.source_power_turret_limit_range_state", "method": "public void limitRange(float margin){", "dispatch_expr": "limitRange(shootType, margin);", "shoot_type": shoot_type, "margin": margin, "limit_range_called": true, "limit_range_call": limit_range_call}

func java_inner_class_PowerTurretBuild_method_getAmmoFraction_0(_args: Array = []) -> Variant:
	var power_null: bool = bool(_args[0] if _args.size() > 0 else true)
	var power_status: float = float(_args[1] if _args.size() > 1 else 0.0)
	var ammo_fraction: float = 0.0 if power_null else power_status
	return {"source_owner": "PortGame.source_power_turret_build_get_ammo_fraction_state", "inner_class": "public class PowerTurretBuild extends TurretBuild{", "method": "public float getAmmoFraction(){", "override_expr": "@Override", "return_expr": "return power == null ? 0f : power.status;", "power_null": power_null, "power_status": power_status, "ammo_fraction": ammo_fraction}

func java_inner_class_PowerTurretBuild_method_sense_1(_args: Array = []) -> Variant:
	var sensor: String = str(_args[0] if _args.size() > 0 else "")
	var power_null: bool = bool(_args[1] if _args.size() > 1 else true)
	var power_status: float = float(_args[2] if _args.size() > 2 else 0.0)
	var super_sense_value: float = float(_args[3] if _args.size() > 3 else 0.0)
	var sense_value: float = 0.0
	if sensor == "ammo":
		sense_value = 0.0 if power_null else power_status
	elif sensor == "ammoCapacity":
		sense_value = 1.0
	else:
		sense_value = super_sense_value
	return {"source_owner": "PortGame.source_power_turret_build_sense_state", "inner_class": "public class PowerTurretBuild extends TurretBuild{", "method": "public double sense(LAccess sensor){", "override_expr": "@Override", "switch_return": "return switch(sensor){", "ammo_case": "case ammo -> power == null ? 0f : power.status;", "ammo_capacity_case": "case ammoCapacity -> 1;", "default_case": "default -> super.sense(sensor);", "sensor": sensor, "power_null": power_null, "power_status": power_status, "super_sense_value": super_sense_value, "sense_value": sense_value}

func java_inner_class_PowerTurretBuild_method_useAmmo_2(_args: Array = []) -> Variant:
	var shoot_type: Variant = _args[0] if _args.size() > 0 else null
	return {"source_owner": "PortGame.source_power_turret_build_use_ammo_state", "inner_class": "public class PowerTurretBuild extends TurretBuild{", "method": "public BulletType useAmmo(){", "override_expr": "@Override", "comment": "//nothing used directly", "return_expr": "return shootType;", "shoot_type": shoot_type}

func java_inner_class_PowerTurretBuild_method_hasAmmo_3(_args: Array = []) -> Variant:
	return {"source_owner": "PortGame.source_power_turret_build_has_ammo_state", "inner_class": "public class PowerTurretBuild extends TurretBuild{", "method": "public boolean hasAmmo(){", "override_expr": "@Override", "comment": "//you can always rotate, but never shoot if there's no power", "return_expr": "return true;", "has_ammo": true}

func java_inner_class_PowerTurretBuild_method_peekAmmo_4(_args: Array = []) -> Variant:
	var shoot_type: Variant = _args[0] if _args.size() > 0 else null
	return {"source_owner": "PortGame.source_power_turret_build_peek_ammo_state", "inner_class": "public class PowerTurretBuild extends TurretBuild{", "method": "public BulletType peekAmmo(){", "override_expr": "@Override", "return_expr": "return shootType;", "shoot_type": shoot_type}
