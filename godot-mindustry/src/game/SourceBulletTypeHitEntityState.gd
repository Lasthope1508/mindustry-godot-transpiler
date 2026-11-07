extends RefCounted
class_name SourceBulletTypeHitEntityState

const source_bullet_defaults := preload("res://src/game/SourceBulletDefaults.gd")
const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")

const SOURCE_BULLET_HALF_CIRCLE_DEGREES := source_math_defaults.HALF_CIRCLE_DEGREES

static func entity_damage_cap_state(bullet_type_state: Dictionary, bullet_state: Dictionary, entity_state: Dictionary, hit_entity_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_entity_state: Dictionary = entity_state.duplicate(true)
	var update_hit_entity_state: Dictionary = hit_entity_state.duplicate(true)
	var entity_is_unit := bool(update_entity_state.get("isUnit", false))
	var entity_unit_dead := bool(update_entity_state.get("unitDead", false))
	var was_dead: bool = entity_is_unit and entity_unit_dead
	var entity_is_healthc := bool(update_entity_state.get("isHealthc", false))
	var healthc_gate_passed := entity_is_healthc
	var damage := float(update_bullet_state.get("damage", 0.0))
	var entity_is_shieldc := bool(update_entity_state.get("isShieldc", false))
	var entity_shield := float(update_entity_state.get("shield", 0.0))
	var shield := 0.0
	var max_damage_fraction := float(update_type_state.get("maxDamageFraction", 0.0))
	var entity_max_health := float(update_entity_state.get("maxHealth", 0.0))
	var health := float(update_hit_entity_state.get("health", 0.0))
	var cap := 0.0
	var max_damage_fraction_gate_passed := healthc_gate_passed and max_damage_fraction > 0.0
	if healthc_gate_passed:
		shield = maxf(entity_shield, 0.0) if entity_is_shieldc else 0.0
		cap = entity_max_health * max_damage_fraction + shield
		if max_damage_fraction_gate_passed:
			damage = minf(damage, cap)
			health = minf(health, cap)
		else:
			health += shield
	update_hit_entity_state["health"] = health
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"entity": update_entity_state,
		"hitEntity": update_hit_entity_state,
		"wasDead": was_dead,
		"healthcGatePassed": healthc_gate_passed,
		"damage": damage,
		"shield": shield,
		"maxDamageFraction": max_damage_fraction,
		"maxDamageFractionGatePassed": max_damage_fraction_gate_passed,
		"cap": cap,
		"effectiveHealth": health,
		"lifestealDeferred": true,
		"armorDamageDeferred": true,
		"unitImpulseDeferred": true,
		"pierceDeferred": true,
		"wasDeadSource": "boolean wasDead = entity instanceof Unit u && u.dead",
		"healthcGateSource": "if(entity instanceof Healthc h)",
		"damageSource": "float damage = b.damage",
		"shieldSource": "float shield = entity instanceof Shieldc s ? Math.max(s.shield(), 0f) : 0f",
		"maxDamageFractionGateSource": "if(maxDamageFraction > 0)",
		"capSource": "float cap = h.maxHealth() * maxDamageFraction + shield",
		"damageCapSource": "damage = Math.min(damage, cap)",
		"healthCapCommentSource": "//cap health to effective health for handlePierce to handle it properly",
		"healthCapSource": "health = Math.min(health, cap)",
		"healthShieldSource": "health += shield",
		"lifestealBoundarySource": "if(lifesteal > 0f && b.owner instanceof Healthc o)",
	}

static func entity_lifesteal_state(bullet_type_state: Dictionary, bullet_state: Dictionary, entity_state: Dictionary, hit_entity_state: Dictionary, damage_cap_state: Dictionary, owner_health_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_entity_state: Dictionary = entity_state.duplicate(true)
	var update_hit_entity_state: Dictionary = hit_entity_state.duplicate(true)
	var update_damage_cap_state: Dictionary = damage_cap_state.duplicate(true)
	var update_owner_health_state: Dictionary = owner_health_state.duplicate(true)
	var healthc_gate_passed := bool(update_damage_cap_state.get("healthcGatePassed", false))
	var lifesteal := float(update_type_state.get("lifesteal", 0.0))
	var owner_is_healthc := bool(update_owner_health_state.get("isHealthc", false))
	var lifesteal_gate_passed := healthc_gate_passed and lifesteal > 0.0 and owner_is_healthc
	var entity_health := float(update_entity_state.get("health", 0.0))
	var damage := float(update_damage_cap_state.get("damage", update_bullet_state.get("damage", 0.0)))
	var lifesteal_result := 0.0
	if lifesteal_gate_passed:
		lifesteal_result = maxf(minf(entity_health, damage), 0.0)
	var owner_heal_amount := lifesteal_result * lifesteal if lifesteal_gate_passed else 0.0
	var owner_heal_call: Variant = null
	if lifesteal_gate_passed:
		owner_heal_call = {"call": "o.heal(result * lifesteal)", "amount": owner_heal_amount}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"entity": update_entity_state,
		"hitEntity": update_hit_entity_state,
		"damageCap": update_damage_cap_state,
		"ownerHealth": update_owner_health_state,
		"healthcGatePassed": healthc_gate_passed,
		"lifesteal": lifesteal,
		"ownerIsHealthc": owner_is_healthc,
		"lifestealGatePassed": lifesteal_gate_passed,
		"entityHealth": entity_health,
		"damage": damage,
		"lifestealResult": lifesteal_result,
		"ownerHealCalled": lifesteal_gate_passed,
		"ownerHealAmount": owner_heal_amount,
		"ownerHealCall": owner_heal_call,
		"armorDamageDeferred": true,
		"unitImpulseDeferred": true,
		"pierceDeferred": true,
		"healthcGateSource": "if(entity instanceof Healthc h)",
		"lifestealBoundarySource": "if(lifesteal > 0f && b.owner instanceof Healthc o)",
		"lifestealResultSource": "float result = Math.max(Math.min(h.health(), damage), 0)",
		"ownerHealSource": "o.heal(result * lifesteal)",
		"pierceArmorBoundarySource": "if(pierceArmor)",
	}

static func entity_armor_damage_state(bullet_type_state: Dictionary, bullet_state: Dictionary, entity_state: Dictionary, hit_entity_state: Dictionary, damage_cap_state: Dictionary, lifesteal_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_entity_state: Dictionary = entity_state.duplicate(true)
	var update_hit_entity_state: Dictionary = hit_entity_state.duplicate(true)
	var update_damage_cap_state: Dictionary = damage_cap_state.duplicate(true)
	var update_lifesteal_state: Dictionary = lifesteal_state.duplicate(true)
	var healthc_gate_passed := bool(update_damage_cap_state.get("healthcGatePassed", false))
	var damage := float(update_damage_cap_state.get("damage", update_bullet_state.get("damage", 0.0)))
	var pierce_armor := bool(update_type_state.get("pierceArmor", false))
	var armor_multiplier := float(update_type_state.get("armorMultiplier", 1.0))
	var pierce_armor_gate_passed := healthc_gate_passed and pierce_armor
	var armor_multiplier_gate_passed := healthc_gate_passed and not pierce_armor and armor_multiplier != 1.0
	var damage_gate_passed := healthc_gate_passed and not pierce_armor and armor_multiplier == 1.0
	var health_damage_call: Variant = null
	if pierce_armor_gate_passed:
		health_damage_call = {"call": "h.damagePierce(damage)", "damage": damage}
	elif armor_multiplier_gate_passed:
		health_damage_call = {"call": "h.damageArmorMult(damage, armorMultiplier)", "damage": damage, "armorMultiplier": armor_multiplier}
	elif damage_gate_passed:
		health_damage_call = {"call": "h.damage(damage)", "damage": damage}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"entity": update_entity_state,
		"hitEntity": update_hit_entity_state,
		"damageCap": update_damage_cap_state,
		"lifesteal": update_lifesteal_state,
		"healthcGatePassed": healthc_gate_passed,
		"damage": damage,
		"pierceArmor": pierce_armor,
		"armorMultiplier": armor_multiplier,
		"pierceArmorGatePassed": pierce_armor_gate_passed,
		"armorMultiplierGatePassed": armor_multiplier_gate_passed,
		"damageGatePassed": damage_gate_passed,
		"damagePierceCalled": pierce_armor_gate_passed,
		"damageArmorMultCalled": armor_multiplier_gate_passed,
		"damageCalled": damage_gate_passed,
		"healthDamageCall": health_damage_call,
		"unitImpulseDeferred": true,
		"pierceDeferred": true,
		"healthcGateSource": "if(entity instanceof Healthc h)",
		"damageLocalSource": "float damage = b.damage",
		"pierceArmorSource": "if(pierceArmor)",
		"damagePierceSource": "h.damagePierce(damage)",
		"armorMultiplierSource": "}else if(armorMultiplier != 1)",
		"damageArmorMultSource": "h.damageArmorMult(damage, armorMultiplier)",
		"damageSource": "}else{ h.damage(damage); }",
		"unitBoundarySource": "if(entity instanceof Unit unit)",
	}

static func entity_unit_effects_state(bullet_type_state: Dictionary, bullet_state: Dictionary, entity_state: Dictionary, armor_damage: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_entity_state: Dictionary = entity_state.duplicate(true)
	var update_armor_damage_state: Dictionary = armor_damage.duplicate(true)
	var unit_gate_passed := bool(update_entity_state.get("isUnit", false))
	var knockback := float(update_type_state.get("knockback", 0.0))
	var impact := bool(update_type_state.get("impact", false))
	var status = update_type_state.get("status", null)
	var status_duration := float(update_type_state.get("statusDuration", source_bullet_defaults.STATUS_DURATION_DEFAULT))
	var entity_x := float(update_entity_state.get("x", 0.0))
	var entity_y := float(update_entity_state.get("y", 0.0))
	var bullet_x := float(update_bullet_state.get("x", 0.0))
	var bullet_y := float(update_bullet_state.get("y", 0.0))
	var bullet_rotation := float(update_bullet_state.get("rotation", 0.0))
	var impulse_vector := Vector2.ZERO
	if unit_gate_passed:
		var base_vector := Vector2(entity_x - bullet_x, entity_y - bullet_y)
		if base_vector != Vector2.ZERO:
			impulse_vector = base_vector.normalized() * (knockback * 80.0)
	if unit_gate_passed and impact:
		var impulse_length := impulse_vector.length()
		var impact_angle := bullet_rotation + (SOURCE_BULLET_HALF_CIRCLE_DEGREES if knockback < 0.0 else 0.0)
		var impact_state := source_math_state.source_angles_trns_vec(impact_angle, impulse_length, 0.0)
		impulse_vector = Vector2(float(impact_state.get("x", 0.0)), float(impact_state.get("y", 0.0)))
	var impulse_call: Variant = null
	var status_apply_call: Variant = null
	var bullet_damage_event_call: Variant = null
	if unit_gate_passed:
		impulse_call = {"call": "unit.impulse(Tmp.v3)", "vector": {"x": impulse_vector.x, "y": impulse_vector.y}}
		status_apply_call = {"call": "unit.apply(status, statusDuration)", "status": status, "duration": status_duration}
		bullet_damage_event_call = {"call": "Events.fire(bulletDamageEvent.set(unit, b))", "unit": update_entity_state, "bullet": update_bullet_state}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"entity": update_entity_state,
		"armorDamage": update_armor_damage_state,
		"unitGatePassed": unit_gate_passed,
		"knockback": knockback,
		"impact": impact,
		"status": status,
		"statusDuration": status_duration,
		"entityX": entity_x,
		"entityY": entity_y,
		"bulletX": bullet_x,
		"bulletY": bullet_y,
		"bulletRotation": bullet_rotation,
		"impulseVector": {"x": impulse_vector.x, "y": impulse_vector.y},
		"impulseCalled": unit_gate_passed,
		"impulseCall": impulse_call,
		"statusApplyCalled": unit_gate_passed,
		"statusApplyCall": status_apply_call,
		"bulletDamageEventFired": unit_gate_passed,
		"bulletDamageEventCall": bullet_damage_event_call,
		"destroyEventDeferred": true,
		"pierceDeferred": true,
		"unitGateSource": "if(entity instanceof Unit unit)",
		"impulseVectorSource": "Tmp.v3.set(unit).sub(b).nor().scl(knockback * 80f)",
		"impactAngleSource": "if(impact) Tmp.v3.setAngle(b.rotation() + (knockback < 0 ? 180f : 0f))",
		"unitImpulseSource": "unit.impulse(Tmp.v3)",
		"unitApplySource": "unit.apply(status, statusDuration)",
		"bulletDamageEventSource": "Events.fire(bulletDamageEvent.set(unit, b))",
		"destroyEventBoundarySource": "if(!wasDead && entity instanceof Unit unit && unit.dead)",
	}

static func entity_unit_destroy_event_state(bullet_state: Dictionary, entity_state: Dictionary, damage_cap_state: Dictionary, unit_effects_state: Dictionary) -> Dictionary:
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_entity_state: Dictionary = entity_state.duplicate(true)
	var update_damage_cap_state: Dictionary = damage_cap_state.duplicate(true)
	var update_unit_effects_state: Dictionary = unit_effects_state.duplicate(true)
	var was_dead := bool(update_damage_cap_state.get("wasDead", false))
	var unit_gate_passed := bool(update_entity_state.get("isUnit", false))
	var unit_dead := bool(update_entity_state.get("unitDead", false))
	var destroy_event_gate_passed := (not was_dead) and unit_gate_passed and unit_dead
	var unit_destroy_event_call: Variant = null
	if destroy_event_gate_passed:
		unit_destroy_event_call = {"call": "Events.fire(new UnitBulletDestroyEvent(unit, b))", "unit": update_entity_state, "bullet": update_bullet_state}
	return {
		"bullet": update_bullet_state,
		"entity": update_entity_state,
		"damageCap": update_damage_cap_state,
		"unitEffects": update_unit_effects_state,
		"wasDead": was_dead,
		"unitGatePassed": unit_gate_passed,
		"unitDead": unit_dead,
		"destroyEventGatePassed": destroy_event_gate_passed,
		"unitDestroyEventFired": destroy_event_gate_passed,
		"unitDestroyEventCall": unit_destroy_event_call,
		"pierceDeferred": true,
		"wasDeadSource": "boolean wasDead = entity instanceof Unit u && u.dead",
		"destroyEventGateSource": "if(!wasDead && entity instanceof Unit unit && unit.dead)",
		"unitDestroyEventSource": "Events.fire(new UnitBulletDestroyEvent(unit, b))",
		"handlePierceBoundarySource": "handlePierce(b, health, entity.x(), entity.y())",
	}

static func entity_handle_pierce_state(bullet_type_state: Dictionary, bullet_state: Dictionary, entity_state: Dictionary, damage_cap_state: Dictionary, unit_destroy_event_state: Dictionary, handle_pierce: Callable) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_entity_state: Dictionary = entity_state.duplicate(true)
	var update_damage_cap_state: Dictionary = damage_cap_state.duplicate(true)
	var update_unit_destroy_event_state: Dictionary = unit_destroy_event_state.duplicate(true)
	var effective_health := float(update_damage_cap_state.get("effectiveHealth", 0.0))
	var entity_x := float(update_entity_state.get("x", 0.0))
	var entity_y := float(update_entity_state.get("y", 0.0))
	var pierce_state := {"initialHealth": effective_health, "x": entity_x, "y": entity_y}
	var handle_pierce_state: Dictionary = handle_pierce.call(update_type_state, update_bullet_state, pierce_state)
	var handle_pierce_call := {
		"call": "handlePierce(b, health, entity.x(), entity.y())",
		"initialHealth": effective_health,
		"x": entity_x,
		"y": entity_y,
	}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"entity": update_entity_state,
		"damageCap": update_damage_cap_state,
		"unitDestroyEvent": update_unit_destroy_event_state,
		"pierce": pierce_state,
		"handlePierce": handle_pierce_state,
		"bulletAfterPierce": handle_pierce_state.get("bullet", update_bullet_state),
		"effectiveHealth": effective_health,
		"entityX": entity_x,
		"entityY": entity_y,
		"handlePierceCalled": true,
		"handlePierceCall": handle_pierce_call,
		"damage": float(handle_pierce_state.get("damage", update_bullet_state.get("damage", 0.0))),
		"removeCalled": bool(handle_pierce_state.get("removeCalled", false)),
		"handlePierceCallSource": "handlePierce(b, health, entity.x(), entity.y())",
		"handlePierceMethodSource": "public void handlePierce(Bullet b, float initialHealth, float x, float y)",
	}
