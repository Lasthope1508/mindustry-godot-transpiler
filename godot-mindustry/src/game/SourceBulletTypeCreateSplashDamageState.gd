extends RefCounted
class_name SourceBulletTypeCreateSplashDamageState

const source_bullet_defaults := preload("res://src/game/SourceBulletDefaults.gd")
const source_bullet_runtime := preload("res://src/game/SourceBulletRuntime.gd")

static func damage_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, hit_splash_damage_dispatch_state: Dictionary, damage_multiplier_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_hit_splash_damage_dispatch_state: Dictionary = hit_splash_damage_dispatch_state.duplicate(true)
	var update_damage_multiplier_state: Dictionary = damage_multiplier_state.duplicate(true)
	var hit_x := float(update_hit_splash_damage_dispatch_state.get("x", 0.0))
	var hit_y := float(update_hit_splash_damage_dispatch_state.get("y", 0.0))
	var bullet_team: Variant = update_bullet_state.get("team", null)
	var bullet_absorbed := bool(update_bullet_state.get("absorbed", false))
	var splash_damage_radius := float(update_type_state.get("splashDamageRadius", -1.0))
	var splash_damage := float(update_type_state.get("splashDamage", 0.0))
	var damage_multiplier := float(update_damage_multiplier_state.get("damageMultiplier", 1.0))
	var splash_damage_pierce := bool(update_type_state.get("splashDamagePierce", false))
	var collides_air := bool(update_type_state.get("collidesAir", true))
	var collides_ground := bool(update_type_state.get("collidesGround", true))
	var scaled_splash_damage := bool(update_type_state.get("scaledSplashDamage", false))
	var armor_multiplier := float(update_type_state.get("armorMultiplier", 1.0))
	var splash_damage_gate_passed := splash_damage_radius > 0.0 and not bullet_absorbed
	var damage_amount := splash_damage * damage_multiplier
	var damage_call := {}
	if splash_damage_gate_passed:
		damage_call = {
			"call": "Damage.damage(b.team, x, y, splashDamageRadius, splashDamage * b.damageMultiplier(), splashDamagePierce, collidesAir, collidesGround, scaledSplashDamage, b, armorMultiplier)",
			"team": bullet_team,
			"x": hit_x,
			"y": hit_y,
			"radius": splash_damage_radius,
			"damage": damage_amount,
			"complete": splash_damage_pierce,
			"air": collides_air,
			"ground": collides_ground,
			"scaled": scaled_splash_damage,
			"source": update_bullet_state,
			"armorMult": armor_multiplier,
			"called": true,
		}
	var runtime_state := source_bullet_runtime.create_splash_damage_damage_dispatch_state(bullet_type_state, bullet_state, hit_splash_damage_dispatch_state, damage_multiplier_state)
	runtime_state["bulletType"] = update_type_state
	runtime_state["bullet"] = update_bullet_state
	runtime_state["hitSplashDamageDispatch"] = update_hit_splash_damage_dispatch_state
	runtime_state["damageMultiplierState"] = update_damage_multiplier_state
	runtime_state["x"] = hit_x
	runtime_state["y"] = hit_y
	runtime_state["bulletTeam"] = bullet_team
	runtime_state["bulletAbsorbed"] = bullet_absorbed
	runtime_state["splashDamageRadius"] = splash_damage_radius
	runtime_state["splashDamage"] = splash_damage
	runtime_state["damageMultiplier"] = damage_multiplier
	runtime_state["damageAmount"] = damage_amount
	runtime_state["splashDamagePierce"] = splash_damage_pierce
	runtime_state["collidesAir"] = collides_air
	runtime_state["collidesGround"] = collides_ground
	runtime_state["scaledSplashDamage"] = scaled_splash_damage
	runtime_state["armorMultiplier"] = armor_multiplier
	runtime_state["splashDamageGatePassed"] = splash_damage_gate_passed
	runtime_state["damageCall"] = damage_call
	var source_trace := {
		"splashDamageGateSource": "if(splashDamageRadius > 0 && !b.absorbed)",
		"damageCallSource": "Damage.damage(b.team, x, y, splashDamageRadius, splashDamage * b.damageMultiplier(), splashDamagePierce, collidesAir, collidesGround, scaledSplashDamage, b, armorMultiplier)",
		"statusBoundarySource": "if(status != StatusEffects.none)",
	}
	runtime_state["splashDamageGateSource"] = source_trace.get("splashDamageGateSource", "")
	runtime_state["damageCallSource"] = source_trace.get("damageCallSource", "")
	runtime_state["statusBoundarySource"] = source_trace.get("statusBoundarySource", "")
	return runtime_state

static func status_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_splash_damage_damage_dispatch_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_damage_dispatch_state: Dictionary = create_splash_damage_damage_dispatch_state.duplicate(true)
	var hit_x := float(update_damage_dispatch_state.get("x", 0.0))
	var hit_y := float(update_damage_dispatch_state.get("y", 0.0))
	var bullet_team: Variant = update_bullet_state.get("team", null)
	var splash_damage_radius := float(update_damage_dispatch_state.get("splashDamageRadius", update_type_state.get("splashDamageRadius", -1.0)))
	var status := str(update_type_state.get("status", "none"))
	var status_duration := float(update_type_state.get("statusDuration", source_bullet_defaults.STATUS_DURATION_DEFAULT))
	var collides_air := bool(update_damage_dispatch_state.get("collidesAir", update_type_state.get("collidesAir", true)))
	var collides_ground := bool(update_damage_dispatch_state.get("collidesGround", update_type_state.get("collidesGround", true)))
	var splash_damage_gate_passed := bool(update_damage_dispatch_state.get("splashDamageGatePassed", false))
	var status_gate_passed := splash_damage_gate_passed and status != "none"
	var status_call := {}
	if status_gate_passed:
		status_call = {
			"call": "Damage.status(b.team, x, y, splashDamageRadius, status, statusDuration, collidesAir, collidesGround)",
			"team": bullet_team,
			"x": hit_x,
			"y": hit_y,
			"radius": splash_damage_radius,
			"effect": status,
			"duration": status_duration,
			"air": collides_air,
			"ground": collides_ground,
			"called": true,
		}
	var runtime_state := source_bullet_runtime.create_splash_damage_status_dispatch_state(bullet_type_state, bullet_state, create_splash_damage_damage_dispatch_state, source_bullet_defaults.TICKS_PER_SECOND)
	runtime_state["bulletType"] = update_type_state
	runtime_state["bullet"] = update_bullet_state
	runtime_state["createSplashDamageDamageDispatch"] = update_damage_dispatch_state
	runtime_state["x"] = hit_x
	runtime_state["y"] = hit_y
	runtime_state["bulletTeam"] = bullet_team
	runtime_state["splashDamageRadius"] = splash_damage_radius
	runtime_state["status"] = status
	runtime_state["statusDuration"] = status_duration
	runtime_state["collidesAir"] = collides_air
	runtime_state["collidesGround"] = collides_ground
	runtime_state["splashDamageGatePassed"] = splash_damage_gate_passed
	runtime_state["statusGatePassed"] = status_gate_passed
	runtime_state["statusCall"] = status_call
	var source_trace := {
		"statusGateSource": "if(status != StatusEffects.none)",
		"statusCallSource": "Damage.status(b.team, x, y, splashDamageRadius, status, statusDuration, collidesAir, collidesGround)",
		"healsBoundarySource": "if(heals())",
	}
	runtime_state["statusGateSource"] = source_trace.get("statusGateSource", "")
	runtime_state["statusCallSource"] = source_trace.get("statusCallSource", "")
	runtime_state["healsBoundarySource"] = source_trace.get("healsBoundarySource", "")
	return runtime_state

static func heal_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_splash_damage_status_dispatch_state: Dictionary, nearby_blocks_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_status_dispatch_state: Dictionary = create_splash_damage_status_dispatch_state.duplicate(true)
	var update_nearby_blocks_state: Dictionary = nearby_blocks_state.duplicate(true)
	var hit_x := float(update_status_dispatch_state.get("x", 0.0))
	var hit_y := float(update_status_dispatch_state.get("y", 0.0))
	var bullet_team: Variant = update_bullet_state.get("team", null)
	var splash_damage_radius := float(update_status_dispatch_state.get("splashDamageRadius", update_type_state.get("splashDamageRadius", -1.0)))
	var splash_damage_gate_passed := bool(update_status_dispatch_state.get("splashDamageGatePassed", false))
	var heal_percent := float(update_type_state.get("healPercent", 0.0))
	var heal_amount := float(update_type_state.get("healAmount", 0.0))
	var heal_color: Variant = update_type_state.get("healColor", "Pal.heal")
	var heal_effect: Variant = update_type_state.get("healEffect", "Fx.healBlockFull")
	var heals := heal_percent > 0.0 or heal_amount > 0.0
	var heal_gate_passed := splash_damage_gate_passed and heals
	var nearby_blocks: Array = update_nearby_blocks_state.get("blocks", [])
	var each_block_call := {}
	var heal_applications: Array = []
	if heal_gate_passed:
		each_block_call = {
			"call": "indexer.eachBlock(b.team, x, y, splashDamageRadius, Building::damaged, other -> {...})",
			"team": bullet_team,
			"x": hit_x,
			"y": hit_y,
			"radius": splash_damage_radius,
			"predicate": "Building::damaged",
			"called": true,
		}
		for raw_block in nearby_blocks:
			if not raw_block is Dictionary:
				continue
			var other: Dictionary = raw_block.duplicate(true)
			if not bool(other.get("damaged", false)):
				continue
			var other_x := float(other.get("x", 0.0))
			var other_y := float(other.get("y", 0.0))
			var other_block: Variant = other.get("block", null)
			var other_max_health := float(other.get("maxHealth", 0.0))
			var heal_applied_amount := heal_percent / source_bullet_defaults.HEAL_PERCENT_DIVISOR * other_max_health + heal_amount
			heal_applications.append({
				"other": other,
				"healAppliedAmount": heal_applied_amount,
				"healEffectCall": {
					"call": "healEffect.at(other.x, other.y, 0f, healColor, other.block)",
					"effect": heal_effect,
					"x": other_x,
					"y": other_y,
					"rotation": 0.0,
					"color": heal_color,
					"block": other_block,
				},
				"otherHealCall": {
					"call": "other.heal(healPercent / 100f * other.maxHealth() + healAmount)",
					"amount": heal_applied_amount,
				},
			})
	var runtime_state := source_bullet_runtime.create_splash_damage_heal_dispatch_state(bullet_type_state, bullet_state, create_splash_damage_status_dispatch_state, nearby_blocks_state)
	runtime_state["bulletType"] = update_type_state
	runtime_state["bullet"] = update_bullet_state
	runtime_state["createSplashDamageStatusDispatch"] = update_status_dispatch_state
	runtime_state["nearbyBlocks"] = update_nearby_blocks_state
	runtime_state["x"] = hit_x
	runtime_state["y"] = hit_y
	runtime_state["bulletTeam"] = bullet_team
	runtime_state["splashDamageRadius"] = splash_damage_radius
	runtime_state["splashDamageGatePassed"] = splash_damage_gate_passed
	runtime_state["healPercent"] = heal_percent
	runtime_state["healAmount"] = heal_amount
	runtime_state["healColor"] = heal_color
	runtime_state["healEffect"] = heal_effect
	runtime_state["heals"] = heals
	runtime_state["healGatePassed"] = heal_gate_passed
	runtime_state["eachBlockCall"] = each_block_call
	runtime_state["healApplications"] = heal_applications
	var source_trace := {
		"healsGateSource": "if(heals())",
		"eachBlockCallSource": "indexer.eachBlock(b.team, x, y, splashDamageRadius, Building::damaged, other -> {...})",
		"healEffectCallSource": "healEffect.at(other.x, other.y, 0f, healColor, other.block)",
		"otherHealCallSource": "other.heal(healPercent / 100f * other.maxHealth() + healAmount)",
		"makeFireBoundarySource": "if(makeFire)",
	}
	runtime_state["healsGateSource"] = source_trace.get("healsGateSource", "")
	runtime_state["eachBlockCallSource"] = source_trace.get("eachBlockCallSource", "")
	runtime_state["healEffectCallSource"] = source_trace.get("healEffectCallSource", "")
	runtime_state["otherHealCallSource"] = source_trace.get("otherHealCallSource", "")
	runtime_state["makeFireBoundarySource"] = source_trace.get("makeFireBoundarySource", "")
	return runtime_state

static func make_fire_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_splash_damage_heal_dispatch_state: Dictionary, nearby_blocks_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_heal_dispatch_state: Dictionary = create_splash_damage_heal_dispatch_state.duplicate(true)
	var update_nearby_blocks_state: Dictionary = nearby_blocks_state.duplicate(true)
	var hit_x := float(update_heal_dispatch_state.get("x", 0.0))
	var hit_y := float(update_heal_dispatch_state.get("y", 0.0))
	var bullet_team: Variant = update_bullet_state.get("team", null)
	var splash_damage_radius := float(update_heal_dispatch_state.get("splashDamageRadius", update_type_state.get("splashDamageRadius", -1.0)))
	var splash_damage_gate_passed := bool(update_heal_dispatch_state.get("splashDamageGatePassed", false))
	var make_fire := bool(update_type_state.get("makeFire", false))
	var make_fire_gate_passed := splash_damage_gate_passed and make_fire
	var nearby_blocks: Array = update_nearby_blocks_state.get("blocks", [])
	var each_block_call := {}
	var fire_applications: Array = []
	if make_fire_gate_passed:
		each_block_call = {
			"call": "indexer.eachBlock(null, x, y, splashDamageRadius, other -> other.team != b.team, other -> Fires.create(other.tile))",
			"team": null,
			"x": hit_x,
			"y": hit_y,
			"radius": splash_damage_radius,
			"predicate": "other.team != b.team",
			"called": true,
		}
		for raw_block in nearby_blocks:
			if not raw_block is Dictionary:
				continue
			var other: Dictionary = raw_block.duplicate(true)
			if other.get("team", null) == bullet_team:
				continue
			var other_tile: Variant = other.get("tile", null)
			fire_applications.append({
				"other": other,
				"firesCreateCall": {
					"call": "Fires.create(other.tile)",
					"tile": other_tile,
				},
			})
	var runtime_state := source_bullet_runtime.create_splash_damage_make_fire_dispatch_state(bullet_type_state, bullet_state, create_splash_damage_heal_dispatch_state, nearby_blocks_state)
	runtime_state["bulletType"] = update_type_state
	runtime_state["bullet"] = update_bullet_state
	runtime_state["createSplashDamageHealDispatch"] = update_heal_dispatch_state
	runtime_state["nearbyBlocks"] = update_nearby_blocks_state
	runtime_state["x"] = hit_x
	runtime_state["y"] = hit_y
	runtime_state["bulletTeam"] = bullet_team
	runtime_state["splashDamageRadius"] = splash_damage_radius
	runtime_state["splashDamageGatePassed"] = splash_damage_gate_passed
	runtime_state["makeFire"] = make_fire
	runtime_state["makeFireGatePassed"] = make_fire_gate_passed
	runtime_state["eachBlockCall"] = each_block_call
	runtime_state["fireApplications"] = fire_applications
	var source_trace := {
		"makeFireGateSource": "if(makeFire)",
		"eachBlockCallSource": "indexer.eachBlock(null, x, y, splashDamageRadius, other -> other.team != b.team, other -> Fires.create(other.tile))",
		"firesCreateCallSource": "Fires.create(other.tile)",
		"createFragsBoundarySource": "public void createFrags(Bullet b, float x, float y){",
	}
	runtime_state["makeFireGateSource"] = source_trace.get("makeFireGateSource", "")
	runtime_state["eachBlockCallSource"] = source_trace.get("eachBlockCallSource", "")
	runtime_state["firesCreateCallSource"] = source_trace.get("firesCreateCallSource", "")
	runtime_state["createFragsBoundarySource"] = source_trace.get("createFragsBoundarySource", "")
	return runtime_state
