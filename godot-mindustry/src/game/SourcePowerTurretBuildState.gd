extends RefCounted
class_name SourcePowerTurretBuildState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")

const SOURCE_POWER_TURRET_GENERATED_CLASS := source_turret_source_text_state.SOURCE_POWER_TURRET_GENERATED_CLASS

static func _power_turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_POWER_TURRET_GENERATED_CLASS, generated_method, generated_args, null)

static func get_ammo_fraction_state(power_null: bool, power_status: float) -> Dictionary:
	var ammo_fraction: float = 0.0 if power_null else power_status
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_TURRET_BUILD_GET_AMMO_FRACTION_STATE,
		"inner_class": "public class PowerTurretBuild extends TurretBuild{",
		"method": "public float getAmmoFraction(){",
		"override_expr": "@Override",
		"return_expr": "return power == null ? 0f : power.status;",
		"power_null": power_null,
		"power_status": power_status,
		"ammo_fraction": ammo_fraction,
	}


static func generated_get_ammo_fraction_bridge_state(power_null: bool, power_status: float) -> Dictionary:
	var result = _power_turret_call("java_inner_class_PowerTurretBuild_method_getAmmoFraction_0", [power_null, power_status])
	var canonical = get_ammo_fraction_state(power_null, power_status)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_TURRET_BUILD_GET_AMMO_FRACTION_STATE,
		"generated_owner": "power_turret.PowerTurretBuild.getAmmoFraction",
		"result": result,
		"canonical": canonical,
		"matches": result.get("ammo_fraction", null) == canonical.get("ammo_fraction", null),
	}


static func sense_state(sensor: String, power_null: bool, power_status: float, super_sense_value: float) -> Dictionary:
	var sense_value: float = 0.0
	if sensor == "ammo":
		sense_value = 0.0 if power_null else power_status
	elif sensor == "ammoCapacity":
		sense_value = 1.0
	else:
		sense_value = super_sense_value
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_TURRET_BUILD_SENSE_STATE,
		"inner_class": "public class PowerTurretBuild extends TurretBuild{",
		"method": "public double sense(LAccess sensor){",
		"override_expr": "@Override",
		"switch_return": "return switch(sensor){",
		"ammo_case": "case ammo -> power == null ? 0f : power.status;",
		"ammo_capacity_case": "case ammoCapacity -> 1;",
		"default_case": "default -> super.sense(sensor);",
		"sensor": sensor,
		"power_null": power_null,
		"power_status": power_status,
		"super_sense_value": super_sense_value,
		"sense_value": sense_value,
	}


static func generated_sense_bridge_state(sensor: String, power_null: bool, power_status: float, super_sense_value: float) -> Dictionary:
	var result = _power_turret_call("java_inner_class_PowerTurretBuild_method_sense_1", [sensor, power_null, power_status, super_sense_value])
	var canonical = sense_state(sensor, power_null, power_status, super_sense_value)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_TURRET_BUILD_SENSE_STATE,
		"generated_owner": "power_turret.PowerTurretBuild.sense",
		"result": result,
		"canonical": canonical,
		"matches": result.get("sense_value", null) == canonical.get("sense_value", null),
	}


static func use_ammo_state(shoot_type: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_TURRET_BUILD_USE_AMMO_STATE,
		"inner_class": "public class PowerTurretBuild extends TurretBuild{",
		"method": "public BulletType useAmmo(){",
		"override_expr": "@Override",
		"comment": "//nothing used directly",
		"return_expr": "return shootType;",
		"shoot_type": shoot_type,
	}


static func generated_use_ammo_bridge_state(shoot_type: Variant) -> Dictionary:
	var result = _power_turret_call("java_inner_class_PowerTurretBuild_method_useAmmo_2", [shoot_type])
	var canonical = use_ammo_state(shoot_type)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_TURRET_BUILD_USE_AMMO_STATE,
		"generated_owner": "power_turret.PowerTurretBuild.useAmmo",
		"result": result,
		"canonical": canonical,
		"matches": result.get("shoot_type", null) == canonical.get("shoot_type", null),
	}


static func has_ammo_state() -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_TURRET_BUILD_HAS_AMMO_STATE,
		"inner_class": "public class PowerTurretBuild extends TurretBuild{",
		"method": "public boolean hasAmmo(){",
		"override_expr": "@Override",
		"comment": "//you can always rotate, but never shoot if there's no power",
		"return_expr": "return true;",
		"has_ammo": true,
	}


static func generated_has_ammo_bridge_state() -> Dictionary:
	var result = _power_turret_call("java_inner_class_PowerTurretBuild_method_hasAmmo_3", [])
	var canonical = has_ammo_state()
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_TURRET_BUILD_HAS_AMMO_STATE,
		"generated_owner": "power_turret.PowerTurretBuild.hasAmmo",
		"result": result,
		"canonical": canonical,
		"matches": result.get("has_ammo", null) == canonical.get("has_ammo", null),
	}


static func peek_ammo_state(shoot_type: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_TURRET_BUILD_PEEK_AMMO_STATE,
		"inner_class": "public class PowerTurretBuild extends TurretBuild{",
		"method": "public BulletType peekAmmo(){",
		"override_expr": "@Override",
		"return_expr": "return shootType;",
		"shoot_type": shoot_type,
	}


static func generated_peek_ammo_bridge_state(shoot_type: Variant) -> Dictionary:
	var result = _power_turret_call("java_inner_class_PowerTurretBuild_method_peekAmmo_4", [shoot_type])
	var canonical = peek_ammo_state(shoot_type)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_TURRET_BUILD_PEEK_AMMO_STATE,
		"generated_owner": "power_turret.PowerTurretBuild.peekAmmo",
		"result": result,
		"canonical": canonical,
		"matches": result.get("shoot_type", null) == canonical.get("shoot_type", null),
	}
