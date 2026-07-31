extends RefCounted
class_name SourceBuildingDamageState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_damage_defaults := preload("res://src/game/SourceDamageDefaults.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

const SOURCE_DAMAGE_MIN_ARMOR_DAMAGE := source_damage_defaults.MIN_ARMOR_DAMAGE

static func handle_damage_state(amount: float) -> float:
	return amount

static func collision_damage_state(current_health: float, bullet_building_damage: float, block_armor: float, bullet_pierce_armor: bool, bullet_armor_multiplier: float, bullet_block_armor_multiplier: float) -> Dictionary:
	var damage := bullet_building_damage
	var armor := block_armor * bullet_armor_multiplier * bullet_block_armor_multiplier
	if not bullet_pierce_armor:
		damage = max(damage - armor, SOURCE_DAMAGE_MIN_ARMOR_DAMAGE * damage)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_COLLISION_DAMAGE_STATE,
		"current_health": current_health,
		"damage": damage,
		"armor": armor,
		"was_dead": current_health <= 0.0,
		"health": current_health - damage,
		"removed": true,
	}

static func damage_delegate_state(source_team: Variant, damage_amount: float) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_DAMAGE_DELEGATE_STATE, "source_team": source_team, "damage": damage_amount, "delegates_to_damage": true}

static func bullet_damage_state(bullet: Variant, source_team: Variant, damage_amount: float) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_BULLET_DAMAGE_STATE, "bullet": bullet, "source_team": source_team, "damage": damage_amount, "delegates_to_source_damage": true, "fires_bullet_damage_event": true}

static func generated_handle_damage_bridge_state(amount: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_handleDamage_173", [amount], null)
	var canonical = {
		"method": "public float handleDamage(float amount){",
		"amount": amount,
		"handled_damage": handle_damage_state(amount),
	}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_HANDLE_DAMAGE_STATE,
		"generated_owner": "building_comp.java_method_handleDamage_173",
		"result": result,
		"canonical": canonical,
	}

static func generated_collision_bridge_state(current_health: float, bullet_building_damage: float, block_armor: float, bullet_pierce_armor: bool, bullet_armor_multiplier: float, bullet_block_armor_multiplier: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_collision_177", [current_health, bullet_building_damage, block_armor, bullet_pierce_armor, bullet_armor_multiplier, bullet_block_armor_multiplier], null)
	var canonical = collision_damage_state(current_health, bullet_building_damage, block_armor, bullet_pierce_armor, bullet_armor_multiplier, bullet_block_armor_multiplier)
	canonical["method"] = "public boolean collision(Bullet other){"
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_COLLISION_DAMAGE_STATE,
		"generated_owner": "building_comp.java_method_collision_177",
		"result": result,
		"canonical": canonical,
	}

static func generated_damage_delegate_bridge_state(source_team: Variant, damage_amount: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_damage_178", [source_team, damage_amount], null)
	var canonical = damage_delegate_state(source_team, damage_amount)
	canonical["comment"] = "/** Used to handle damage from splash damage for certain types of blocks. */"
	canonical["method"] = "public void damage(@Nullable Team source, float damage){"
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_DAMAGE_DELEGATE_STATE,
		"generated_owner": "building_comp.java_method_damage_178",
		"result": result,
		"canonical": canonical,
	}

static func generated_bullet_damage_bridge_state(bullet: Variant, source_team: Variant, damage_amount: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_damage_179", [bullet, source_team, damage_amount], null)
	var canonical = bullet_damage_state(bullet, source_team, damage_amount)
	canonical["comment"] = "/** Handles splash damage with a bullet source. */"
	canonical["method"] = "public void damage(Bullet bullet, Team source, float damage){"
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_BULLET_DAMAGE_STATE,
		"generated_owner": "building_comp.java_method_damage_179",
		"result": result,
		"canonical": canonical,
	}

static func generated_damage_dead_guard_bridge_state(damage_amount: float, dead_state: bool) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_damage_204", [damage_amount, dead_state], null)
	var canonical = dead_guard_state(dead_state)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_DAMAGE_DEAD_GUARD_STATE,
		"generated_owner": "building_comp.java_method_damage_204",
		"result": result,
		"canonical": canonical,
	}

static func generated_damage_block_health_scale_bridge_state(damage_amount: float, health: float, block_health_multiplier: float, source_time: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_damage_204", [damage_amount, false, health, block_health_multiplier, source_time], null)
	var canonical = block_health_scale_state(damage_amount, health, block_health_multiplier, source_time)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_DAMAGE_BLOCK_HEALTH_SCALE_STATE,
		"generated_owner": "building_comp.java_method_damage_204",
		"result": result,
		"canonical": canonical,
	}

static func generated_damage_handle_damage_gate_bridge_state(damage_amount: float, health: float, block_health_multiplier: float, source_time: float, net_client: bool, handled_damage: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_damage_204", [damage_amount, false, health, block_health_multiplier, source_time, net_client, handled_damage], null)
	var block_health_canonical = block_health_scale_state(damage_amount, health, block_health_multiplier, source_time)
	var canonical = handle_damage_gate_state(net_client, health, float(block_health_canonical["damage"]), handled_damage)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_DAMAGE_HANDLE_DAMAGE_GATE_STATE,
		"generated_owner": "building_comp.java_method_damage_204",
		"result": result,
		"canonical": canonical,
	}

static func generated_damage_health_changed_call_bridge_state(damage_amount: float, health: float, block_health_multiplier: float, source_time: float, net_client: bool, handled_damage: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_damage_204", [damage_amount, false, health, block_health_multiplier, source_time, net_client, handled_damage], null)
	var canonical = health_changed_call_state()
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_DAMAGE_HEALTH_CHANGED_CALL_STATE,
		"generated_owner": "building_comp.java_method_damage_204",
		"result": result,
		"canonical": canonical,
	}

static func generated_damage_destroy_gate_bridge_state(damage_amount: float, health: float, block_health_multiplier: float, source_time: float, net_client: bool, handled_damage: float, self_state := {}) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_damage_204", [damage_amount, false, health, block_health_multiplier, source_time, net_client, handled_damage, self_state], null)
	var block_health_canonical = block_health_scale_state(damage_amount, health, block_health_multiplier, source_time)
	var handle_gate_canonical = handle_damage_gate_state(net_client, health, float(block_health_canonical["damage"]), handled_damage)
	var canonical = destroy_gate_state(float(handle_gate_canonical["health"]), self_state)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_DAMAGE_DESTROY_GATE_STATE,
		"generated_owner": "building_comp.java_method_damage_204",
		"result": result,
		"canonical": canonical,
	}

static func dead_guard_state(dead_state: bool) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_DAMAGE_DEAD_GUARD_STATE, "returned": dead_state, "continues": not dead_state}

static func block_health_scale_state(damage_amount: float, health: float, block_health_multiplier: float, source_time: float) -> Dictionary:
	if is_zero_approx(block_health_multiplier):
		return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_DAMAGE_BLOCK_HEALTH_SCALE_STATE, "damage": health + 1.0, "last_damage_time": source_time}
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_DAMAGE_BLOCK_HEALTH_SCALE_STATE, "damage": damage_amount / block_health_multiplier, "last_damage_time": source_time}

static func handle_damage_gate_state(net_client: bool, health: float, damage_amount: float, handled_damage: float) -> Dictionary:
	if not net_client:
		return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_DAMAGE_HANDLE_DAMAGE_GATE_STATE, "health": health - handled_damage, "damage": damage_amount, "handle_damage_called": true}
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_DAMAGE_HANDLE_DAMAGE_GATE_STATE, "health": health, "damage": damage_amount, "handle_damage_called": false}

static func health_changed_call_state() -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_DAMAGE_HEALTH_CHANGED_CALL_STATE, "health_changed": true}

static func destroy_gate_state(health: float, self_state := {}) -> Dictionary:
	if health <= 0.0:
		return {
			"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_DAMAGE_DESTROY_GATE_STATE,
			"destroy_gate": "if(health <= 0){",
			"build_destroyed_call": "Call.buildDestroyed(self());",
			"build_destroyed_called": true,
			"build_destroyed": self_state,
		}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_DAMAGE_DESTROY_GATE_STATE,
		"destroy_gate": "if(health <= 0){",
		"build_destroyed_call": "Call.buildDestroyed(self());",
		"build_destroyed_called": false,
		"build_destroyed": null,
	}
