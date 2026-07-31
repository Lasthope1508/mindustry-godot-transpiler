extends RefCounted
class_name SourceBulletTypeHitTileState

const source_bullet_defaults := preload("res://src/game/SourceBulletDefaults.gd")
const source_bullet_runtime := preload("res://src/game/SourceBulletRuntime.gd")

const SOURCE_BULLET_HEAL_SOUND_PITCH_RANGE := source_bullet_defaults.HEAL_SOUND_PITCH_RANGE

static func heals_state(bullet_type_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var heal_percent := float(update_type_state.get("healPercent", 0.0))
	var heal_amount := float(update_type_state.get("healAmount", 0.0))
	var heals := heal_percent > 0.0 or heal_amount > 0.0
	return {
		"bulletType": update_type_state,
		"healPercent": heal_percent,
		"healAmount": heal_amount,
		"heals": heals,
		"healsReturnSource": "return healPercent > 0 || healAmount > 0",
	}

static func test_collision_state(bullet_type_state: Dictionary, bullet_state: Dictionary, tile_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_tile_state: Dictionary = tile_state.duplicate(true)
	var heals_result := heals_state(update_type_state)
	var heals := bool(heals_result.get("heals", false))
	var tile_team = update_tile_state.get("team", null)
	var bullet_team = update_bullet_state.get("team", null)
	var tile_healthf := float(update_tile_state.get("healthf", 0.0))
	var collides_tile: bool = not heals or tile_team != bullet_team or tile_healthf < 1.0
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"tile": update_tile_state,
		"heals": heals,
		"tileTeam": tile_team,
		"bulletTeam": bullet_team,
		"tileHealthf": tile_healthf,
		"collides": collides_tile,
		"testCollisionReturnSource": "return !heals() || tile.team != bullet.team || tile.healthf() < 1f",
	}

static func hit_tile_fire_state(bullet_type_state: Dictionary, bullet_state: Dictionary, build_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_build_state: Dictionary = build_state.duplicate(true)
	var make_fire := bool(update_type_state.get("makeFire", false))
	var build_team = update_build_state.get("team", null)
	var bullet_team = update_bullet_state.get("team", null)
	var fire_gate_passed: bool = make_fire and build_team != bullet_team
	var build_tile = update_build_state.get("tile", null)
	var fires_create_call: Variant = null
	if fire_gate_passed:
		fires_create_call = {"call": "Fires.create(build.tile)", "tile": build_tile}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"build": update_build_state,
		"makeFire": make_fire,
		"buildTeam": build_team,
		"bulletTeam": bullet_team,
		"fireGatePassed": fire_gate_passed,
		"fireCreated": fire_gate_passed,
		"firesCreateCall": fires_create_call,
		"hitTileFireGateSource": "if(makeFire && build.team != b.team)",
		"firesCreateSource": "Fires.create(build.tile)",
		"healBranchBoundarySource": "if(heals() && build.team == b.team && !(build.block instanceof ConstructBlock))",
	}

static func hit_tile_heal_state(bullet_type_state: Dictionary, bullet_state: Dictionary, build_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_build_state: Dictionary = build_state.duplicate(true)
	var heals_result := heals_state(update_type_state)
	var heals := bool(heals_result.get("heals", false))
	var build_team = update_build_state.get("team", null)
	var bullet_team = update_bullet_state.get("team", null)
	var block_is_construct := bool(update_build_state.get("blockIsConstructBlock", false))
	var heal_gate_passed: bool = heals and build_team == bullet_team and not block_is_construct
	var build_max_health := float(update_build_state.get("maxHealth", 0.0))
	var heal_percent := float(update_type_state.get("healPercent", 0.0))
	var heal_amount := float(update_type_state.get("healAmount", 0.0))
	var heal_applied_amount := heal_percent / source_bullet_defaults.HEAL_PERCENT_DIVISOR * build_max_health + heal_amount
	var heal_color := str(update_type_state.get("healColor", "Pal.heal"))
	var heal_sound_volume := float(update_type_state.get("healSoundVolume", 1.0))
	var build_x := float(update_build_state.get("x", 0.0))
	var build_y := float(update_build_state.get("y", 0.0))
	var build_block = update_build_state.get("block", null)
	var heal_effect_call: Variant = null
	var build_heal_call: Variant = null
	var heal_sound_call: Variant = null
	if heal_gate_passed:
		heal_effect_call = {"call": "healEffect.at(build.x, build.y, 0f, healColor, build.block)", "x": build_x, "y": build_y, "rotation": 0.0, "color": heal_color, "block": build_block}
		build_heal_call = {"call": "build.heal(healPercent / 100f * build.maxHealth + healAmount)", "amount": heal_applied_amount}
		heal_sound_call = {"call": "healSound.at(build, 1f + Mathf.range(0.1f), healSoundVolume)", "pitchBase": 1.0, "pitchRange": SOURCE_BULLET_HEAL_SOUND_PITCH_RANGE, "volume": heal_sound_volume}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"build": update_build_state,
		"heals": heals,
		"buildTeam": build_team,
		"bulletTeam": bullet_team,
		"blockIsConstructBlock": block_is_construct,
		"healGatePassed": heal_gate_passed,
		"healAppliedAmount": heal_applied_amount,
		"healed": heal_gate_passed,
		"hitCalled": heal_gate_passed,
		"healEffectCall": heal_effect_call,
		"buildHealCall": build_heal_call,
		"healSoundCall": heal_sound_call,
		"enemyDirectBranchDeferred": true,
		"pierceDeferred": true,
		"hitTileHealGateSource": "if(heals() && build.team == b.team && !(build.block instanceof ConstructBlock))",
		"healEffectSource": "healEffect.at(build.x, build.y, 0f, healColor, build.block)",
		"healAmountSource": "healPercent / 100f * build.maxHealth + healAmount",
		"healSoundSource": "healSound.at(build, 1f + Mathf.range(0.1f), healSoundVolume)",
		"hitCallSource": "hit(b)",
		"deferredBranchSource": "}else if(build.team != b.team && direct){",
		"pierceSource": "handlePierce(b, initialHealth, x, y)",
	}

static func hit_tile_enemy_direct_state(bullet_type_state: Dictionary, bullet_state: Dictionary, build_state: Dictionary, hit_tile_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_build_state: Dictionary = build_state.duplicate(true)
	var update_hit_tile_state: Dictionary = hit_tile_state.duplicate(true)
	var direct := bool(update_hit_tile_state.get("direct", false))
	var build_team = update_build_state.get("team", null)
	var bullet_team = update_bullet_state.get("team", null)
	var enemy_direct_gate_passed: bool = build_team != bullet_team and direct
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"build": update_build_state,
		"hitTile": update_hit_tile_state,
		"direct": direct,
		"buildTeam": build_team,
		"bulletTeam": bullet_team,
		"enemyDirectGatePassed": enemy_direct_gate_passed,
		"hitCalled": enemy_direct_gate_passed,
		"lifestealDeferred": true,
		"pierceDeferred": true,
		"hitTileEnemyDirectGateSource": "}else if(build.team != b.team && direct)",
		"enemyHitCallSource": "hit(b)",
		"lifestealBoundarySource": "if(lifesteal > 0f && b.owner instanceof Healthc o)",
		"pierceSource": "handlePierce(b, initialHealth, x, y)",
	}

static func hit_tile_lifesteal_state(bullet_type_state: Dictionary, bullet_state: Dictionary, build_state: Dictionary, hit_tile_state: Dictionary, owner_health_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_build_state: Dictionary = build_state.duplicate(true)
	var update_hit_tile_state: Dictionary = hit_tile_state.duplicate(true)
	var update_owner_health_state: Dictionary = owner_health_state.duplicate(true)
	var direct := bool(update_hit_tile_state.get("direct", false))
	var build_team = update_build_state.get("team", null)
	var bullet_team = update_bullet_state.get("team", null)
	var enemy_direct_gate_passed: bool = build_team != bullet_team and direct
	var lifesteal := float(update_type_state.get("lifesteal", 0.0))
	var damage := float(update_type_state.get("damage", 0.0))
	var build_health := float(update_build_state.get("health", 0.0))
	var owner_is_healthc := bool(update_owner_health_state.get("isHealthc", false))
	var lifesteal_gate_passed: bool = lifesteal > 0.0 and owner_is_healthc
	var lifesteal_result := maxf(minf(build_health, damage), 0.0)
	var owner_heal_called := enemy_direct_gate_passed and lifesteal_gate_passed
	var owner_heal_amount := lifesteal_result * lifesteal if owner_heal_called else 0.0
	var owner_heal_call = null
	if owner_heal_called:
		owner_heal_call = {
			"call": "o.heal(result * lifesteal)",
			"amount": owner_heal_amount,
		}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"build": update_build_state,
		"hitTile": update_hit_tile_state,
		"ownerHealth": update_owner_health_state,
		"direct": direct,
		"buildTeam": build_team,
		"bulletTeam": bullet_team,
		"enemyDirectGatePassed": enemy_direct_gate_passed,
		"lifesteal": lifesteal,
		"damage": damage,
		"buildHealth": build_health,
		"ownerIsHealthc": owner_is_healthc,
		"lifestealGatePassed": lifesteal_gate_passed,
		"lifestealResult": lifesteal_result if owner_heal_called else 0.0,
		"ownerHealCalled": owner_heal_called,
		"ownerHealAmount": owner_heal_amount,
		"ownerHealCall": owner_heal_call,
		"pierceDeferred": true,
		"lifestealBoundarySource": "if(lifesteal > 0f && b.owner instanceof Healthc o)",
		"lifestealResultSource": "float result = Math.max(Math.min(build.health, damage), 0)",
		"ownerHealSource": "o.heal(result * lifesteal)",
		"pierceSource": "handlePierce(b, initialHealth, x, y)",
	}

static func handle_pierce_state(bullet_type_state: Dictionary, bullet_state: Dictionary, pierce_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_pierce_state: Dictionary = pierce_state.duplicate(true)
	var pierce_damage_factor := float(update_type_state.get("pierceDamageFactor", 0.0))
	var remove_after_pierce := bool(update_type_state.get("removeAfterPierce", false))
	var initial_health := float(update_pierce_state.get("initialHealth", 0.0))
	var x := float(update_pierce_state.get("x", 0.0))
	var y := float(update_pierce_state.get("y", 0.0))
	var bullet_damage := float(update_bullet_state.get("damage", 0.0))
	var zero_pierce_damage_factor := absf(pierce_damage_factor) <= 0.000001
	var sub := 0.0 if zero_pierce_damage_factor else maxf(initial_health * pierce_damage_factor, 0.0)
	var damage_subtract := bullet_damage if is_nan(sub) else minf(bullet_damage, sub)
	var next_damage := bullet_damage - damage_subtract
	var remove_gate_passed := remove_after_pierce and next_damage <= 0.0
	update_bullet_state["damage"] = next_damage
	if remove_gate_passed:
		update_bullet_state["hit"] = true
		update_bullet_state["removed"] = true
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"pierce": update_pierce_state,
		"pierceDamageFactor": pierce_damage_factor,
		"removeAfterPierce": remove_after_pierce,
		"initialHealth": initial_health,
		"x": x,
		"y": y,
		"zeroPierceDamageFactor": zero_pierce_damage_factor,
		"sub": sub,
		"damageBefore": bullet_damage,
		"damageSubtract": damage_subtract,
		"damage": next_damage,
		"removeGatePassed": remove_gate_passed,
		"hit": bool(update_bullet_state.get("hit", false)),
		"removeCalled": bool(update_bullet_state.get("removed", false)),
		"subSource": "float sub = Mathf.zero(pierceDamageFactor) ? 0f : Math.max(initialHealth * pierceDamageFactor, 0)",
		"damageSubtractSource": "b.damage -= Float.isNaN(sub) ? b.damage : Math.min(b.damage, sub)",
		"removeAfterPierceSource": "if(removeAfterPierce && b.damage <= 0)",
		"hitAssignmentSource": "b.hit = true",
		"removeCallSource": "b.remove()",
	}
