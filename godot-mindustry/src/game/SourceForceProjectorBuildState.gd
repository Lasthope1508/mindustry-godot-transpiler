extends RefCounted
class_name SourceForceProjectorBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")

# The ForceProjector implementation (ForceProjector.java:30, `public class
# ForceProjector extends Block{`): force-projector (consumePower 4f,
# size 3, radius 101.7f, shieldHealth 750f Blocks override, cooldownNormal 1.5f,
# cooldownLiquid 1.2f, cooldownBrokenBase 0.35f, phaseUseTime 350f,
# phaseRadiusBoost 80f, phaseShieldBoost 400f, sides 6, phaseFabric
# itemConsumer booster, ConsumeCoolant 0.1f). It hasPower=true
# (ForceProjector.java:76, `hasPower = true;`), hasLiquids=true
# and hasItems=true. ForceProjector extends Block, NOT a drill
# or factory, so it cannot reuse an existing frame key; this
# driver uses its own family frame key
# ("source_force_projector_building", the mechanical-pump /
# beam-drill / mend-projector / overdrive-projector precedent), and this slice adds the
# force-projector key to N2142's
# SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back
# finds it. The port has NO SourceForceProjector* files at all
# yet -- no display/runtime state to lean on -- so the missing
# piece is the live power.status -> efficiency driver, which is
# exactly this slice: the warmup fold
# (ForceProjector.java:221, `warmup = Mathf.lerpDelta(warmup, efficiency, 0.1f);`)
# follows the folded efficiency, with radscl following warmup
# (ForceProjector.java:215, `radscl = Mathf.lerpDelta(radscl, broken ? 0f : warmup, 0.05f);`)
# and realRadius folding both
# (ForceProjector.java:280, `return (radius + phaseHeat * phaseRadiusBoost) * radscl;`).
const SOURCE_FORCE_PROJECTOR_BUILD_IMPLEMENTATIONS := ["ForceProjector"]
const SOURCE_FORCE_PROJECTOR_BUILDING_META_KEY := "source_force_projector_building"
# Force-projector def values (Blocks.java:1964-1976, the SINGLE
# def): `shieldHealth = 750f;`, `cooldownNormal = 1.5f;`,
# `cooldownLiquid = 1.2f;`, `cooldownBrokenBase = 0.35f;`,
# `phaseRadiusBoost = 80f;`, `radius = 101.7f;`, `size = 3;`,
# `itemConsumer = consumeItem(Items.phaseFabric).boost();`,
# `consumePower(4f);` -- the DEF wins over the class defaults
# (`public float shieldHealth = 700f;`,
# `public float cooldownNormal = 1.75f;`,
# `public float cooldownLiquid = 1.5f;`, ForceProjector.java:
# 39-41; cooldownBrokenBase 0.35f, radius 101.7f and
# phaseRadiusBoost 80f equal the class values). Class values
# (ForceProjector.java): `public float phaseUseTime = 350f;`
# (:33, the deferred consume cadence -- the driver passes
# consume_tick false until the timer-infra slice lands),
# `public float phaseShieldBoost = 400f;` (:37),
# `public int sides = 6;` (:39),
# `public float shieldRotation = 0f;` (:40),
# `public float coolantConsumption = 0.1f;` (:44),
# `public boolean consumeCoolant = true;` (:45). The catalog
# carries neither shieldHealth nor the cooldowns nor the
# radius for this family, so the driver reads these constants
# (the Separator craftTime precedent). The lerp progresses are
# the Java literals (0.1f phaseHeat / 0.05f radscl / 0.1f
# warmup); the coolant heat-capacity fallback is the no-op
# default for the coolant factor (1 + (0.4 - 0.4) * 0.9) = 1
# (ForceProjector.java:233), NOT the Liquid default
# (`public float heatCapacity = 0.5f;`, Liquid.java:42).
const SOURCE_FORCE_PROJECTOR_SHIELD_HEALTH := 750.0
const SOURCE_FORCE_PROJECTOR_COOLDOWN_NORMAL := 1.5
const SOURCE_FORCE_PROJECTOR_COOLDOWN_LIQUID := 1.2
const SOURCE_FORCE_PROJECTOR_COOLDOWN_BROKEN_BASE := 0.35
const SOURCE_FORCE_PROJECTOR_RADIUS := 101.7
const SOURCE_FORCE_PROJECTOR_PHASE_RADIUS_BOOST := 80.0
const SOURCE_FORCE_PROJECTOR_PHASE_SHIELD_BOOST := 400.0
const SOURCE_FORCE_PROJECTOR_SIDES := 6
const SOURCE_FORCE_PROJECTOR_SHIELD_ROTATION := 0.0
const SOURCE_FORCE_PROJECTOR_PHASE_USE_TIME := 350.0
const SOURCE_FORCE_PROJECTOR_PHASE_HEAT_LERP_PROGRESS := 0.1
const SOURCE_FORCE_PROJECTOR_RADSCL_LERP_PROGRESS := 0.05
const SOURCE_FORCE_PROJECTOR_WARMUP_LERP_PROGRESS := 0.1
const SOURCE_FORCE_PROJECTOR_COOLANT_HEAT_CAPACITY_FALLBACK := 0.4

static func _is_force_projector_build_implementation(implementation: String) -> bool:
	return SOURCE_FORCE_PROJECTOR_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_force_projector_is_in_regular_polygon(sides: int, center_x: float, center_y: float, radius: float, rotation: float, point_x: float, point_y: float) -> bool:
	# Intersector.isInRegularPolygon, faithfully ported from
	# Arc (the port has no isInRegularPolygon helper -- grep):
	# `public static boolean isInRegularPolygon(int sides, float cx, float cy, float radius, float rotation, float x, float y){`
	# `s.trns(i * 360f / sides + rotation, radius);`
	# `floatArray.add(cx + s.x, cy + s.y);`
	# `return isInPolygon(floatArray.items, 0, floatArray.size, x, y);`
	# (Intersector.java:111-119), where trns is
	# `public Vec2 trns(float angle, float amount){`
	# `return set(amount, 0).rotate(angle);`
	# (Vec2.java:40-42, degrees -- Vector2.rotated takes
	# radians, hence deg_to_rad) and the test is the
	# float-array isInPolygon ray cast:
	# `public static boolean isInPolygon(float[] polygon, int offset, int count, float x, float y){`
	# `if((yi < y && yj >= y) || (yj < y && yi >= y)){`
	# `if(xi + (y - yi) / (yj - yi) * (polygon[j] - xi) < x) oddNodes = !oddNodes;`
	# (Intersector.java:180-193). The loop-bound trap: Arc
	# fixes n = offset + count - 2 BEFORE the loop and
	# reassigns j = i inside it, so the loop must compare
	# against the FIXED n, not the moving j. The yj != yi
	# guard is the branch condition itself (yi < y <= yj or
	# yj < y <= yi), so the division cannot divide by zero.
	var polygon: Array = []
	for i in range(sides):
		var vertex: Vector2 = Vector2(radius, 0.0).rotated(deg_to_rad(float(i) * 360.0 / float(sides) + rotation))
		polygon.append(center_x + vertex.x)
		polygon.append(center_y + vertex.y)
	var odd_nodes: bool = false
	var n: int = polygon.size() - 2
	var j: int = n
	var i: int = 0
	while i <= n:
		var yi: float = float(polygon[i + 1])
		var yj: float = float(polygon[j + 1])
		if (yi < point_y and yj >= point_y) or (yj < point_y and yi >= point_y):
			var xi: float = float(polygon[i])
			if xi + (point_y - yi) / (yj - yi) * (float(polygon[j]) - xi) < point_x:
				odd_nodes = not odd_nodes
		j = i
		i += 2
	return odd_nodes

static func source_force_projector_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float, building_x: float, building_y: float, bullets: Array, consume_tick: bool, item_consumer_present: bool = false, item_consumer_efficiency: float = 0.0, coolant_present: bool = false, coolant_efficiency: float = 0.0, coolant_heat_capacity: float = SOURCE_FORCE_PROJECTOR_COOLANT_HEAT_CAPACITY_FALLBACK) -> Dictionary:
	# The updateTile advance (ForceBuild.updateTile(), ForceProjector.java:207-268), the pure frame advance -- the build fields are `public boolean broken = true;` (ForceProjector.java:167 -- broken defaults TRUE, a fresh shield starts broken and clears on the first tick once buildup <= 0) and `public float buildup, radscl, hit, warmup, phaseHeat;` (ForceProjector.java:168), and the advance follows the Java lines in order (each exact expr on ONE comment line, the N2148 lesson):
	# `boolean phaseValid = itemConsumer != null && itemConsumer.efficiency(this) > 0;`
	# `phaseHeat = Mathf.lerpDelta(phaseHeat, Mathf.num(phaseValid), 0.1f);`
	# `if(phaseValid && !broken && timer(timerUse, phaseUseTime / timeScale) && efficiency > 0){`
	# `consume();`
	# `radscl = Mathf.lerpDelta(radscl, broken ? 0f : warmup, 0.05f);`
	# `if(Mathf.chanceDelta(buildup / shieldHealth * 0.1f)){`
	# `warmup = Mathf.lerpDelta(warmup, efficiency, 0.1f);`
	# `float scale = !broken ? cooldownNormal : cooldownBrokenBase;`
	# `if(coolantConsumer != null){`
	# `if(coolantConsumer.efficiency(this) > 0){`
	# `coolantConsumer.update(this);`
	# `scale *= (cooldownLiquid * (1f + (liquids.current().heatCapacity - 0.4f) * 0.9f));`
	# `buildup -= delta() * scale;`
	# `if(broken && buildup <= 0){`
	# `broken = false;`
	# `if(buildup >= shieldHealth + phaseShieldBoost * phaseHeat && !broken){`
	# `broken = true;`
	# `buildup = shieldHealth;`
	# `if(hit > 0f){`
	# `hit -= 1f / 5f * Time.delta;`
	# `deflectBullets();`
	# `float realRadius = realRadius();`
	# `if(realRadius > 0 && !broken){`
	# `Groups.bullet.intersect(x - realRadius, y - realRadius, realRadius * 2f, realRadius * 2f, shieldConsumer);`
	# `if(bullet.team != paramEntity.team && bullet.type.absorbable && !bullet.absorbed &&`
	# `Intersector.isInRegularPolygon(paramBlock.sides, paramEntity.x, paramEntity.y, paramEntity.realRadius(), paramBlock.shieldRotation, bullet.x, bullet.y)){`
	# `bullet.absorb();`
	# `paramEntity.hit = 1f;`
	# `paramEntity.buildup += bullet.type.shieldDamage(bullet);`
	# `return (radius + phaseHeat * phaseRadiusBoost) * radscl;`
	# The ORDERING traps: radscl lerps toward the OLD warmup (:216 runs before the warmup update at :222); the broken-set threshold folds the NEW phaseHeat (:210 runs before :243); deflectBullets runs LAST, so absorbed buildup cannot break the shield until the next tick; hit decays (:253-255) BEFORE deflect sets it to 1f. The Arc formulas, not guesses: lerpDelta is `return lerp(fromValue, toValue, clamp(progress * Time.delta));` (Mathf.java:430-432), num is 1 / 0 (Mathf.java:208-210), chanceDelta is rand < d * Time.delta (Mathf.java:236-238, the Fx.reactorsmoke chance defers -- no RNG in the pure advance). delta() is `return Time.delta * timeScale;` (BuildingComp.java:1922-1924) and scales the buildup decay, but the hit decay uses Time.delta DIRECTLY (ForceProjector.java:254), not delta(). source_delta is Time.delta in ticks (seconds * 60 through game_source_delta, arc Time.java:26), never raw seconds. buildup has NO clamp: the decay can take it negative, and a negative buildup clears broken (:239-241). The TIMER CADENCE defers (no timer helper in the port, the N2193 precedent; `public float phaseUseTime = 350f;`, ForceProjector.java:33), so the pure advance takes an explicit consume_tick bool and the driver passes false; the consume() APPLICATION also defers (the frame has no items, the N2193 precedent), so the advance reports it through the pure `consumed` result. The coolant branch is LIVE-CAPABLE, not dead: the constructor adds ConsumeCoolant when consumeCoolant is true -- `consume(coolantConsumer = new ConsumeCoolant(coolantConsumption)).boost().update(false);` (ForceProjector.java:85, class default `public boolean consumeCoolant = true;`, and the def does not override it) -- so coolantConsumer is non-null, unlike N2230's parallax; the driver just cannot supply live coolant state (no liquids store on the frame), so it passes the no-op defaults and the coolant live fill defers. coolantConsumer.update(this) (:232, the actual coolant consumption) defers with the live fill. The explicit `bullets` list IS the Groups.bullet.intersect rect result (the N2229 precedent): the caller supplies the bullets in the 2x realRadius rect (EntityGroup.java:207, `public Seq<T> intersect(float x, float y, float width, float height){`, over the spatial bullet group, GroupDefs.java:9, `@GroupDef(value = Bulletc.class, spatial = true, collide = true) G bullet;`), and the pure advance applies the shieldConsumer filter (enemy team + absorbable + !absorbed + in the regular polygon). The bullet dict contract: x / y, team (int; missing = own team, never an enemy), absorbable (default true, BulletType.java:147, `public boolean absorbable = true;`), absorbed (default false, BulletComp.java:53, `transient boolean absorbed, hit;`), shield_damage (default 0.0 -- shieldDamage(bullet) is `return b.damage() * shieldDamageMultiplier;`, BulletType.java:665-666, multiplier default 1f; the port folds no live bullet damage, so the caller supplies it), id (default: the bullet's index in the list). bullet.absorb() (BulletComp.java:100-101, `absorbed = true;`) is NOT applied to a live bullet: the absorbed list + buildup delta are pure results. Effects / sound / events (Fx.reactorsmoke, shieldBreakEffect, breakSound, Trigger.forceProjectorBreak, absorbEffect, hitSound) defer. absorbExplosion (ForceProjector.java:271-281) is NOT updateTile and is not ported here. The building position comes from the origin cell: Building x/y are tile.drawx()/drawy() (BuildingComp.java:124, `set(tile.drawx(), tile.drawy());`), drawx is `return block().offset + worldx();` (Tile.java:175-176) and drawy is `return block().offset + worldy();` (Tile.java:179-180) with the block offset `offset = ((size + 1) % 2) * tilesize / 2f;` (Block.java:761) -- 0 for the size-3 force-projector. A team with no frame team id defaults to derelict (`derelict = new Team(0, "derelict", Color.valueOf("4d4e58")),`, Team.java:33). The updateTile gate is `if(enabled || !block.noUpdateDisabled){` (BuildingComp.java:2276-2277) with `public boolean noUpdateDisabled = false;` (Block.java:170).
	var team_id: int = int(frame.get("team_id", source_block_geometry.SOURCE_TEAM_DERELICT_ID))
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var phase_heat: float = float(frame.get("phase_heat", 0.0))
	var radscl: float = float(frame.get("radscl", 0.0))
	var warmup: float = float(frame.get("warmup", 0.0))
	var buildup: float = float(frame.get("buildup", 0.0))
	var broken: bool = bool(frame.get("broken", true))
	var hit: float = float(frame.get("hit", 0.0))
	var phase_valid: bool = item_consumer_present and item_consumer_efficiency > 0.0
	phase_heat = source_math_state.source_lerp_delta(phase_heat, 1.0 if phase_valid else 0.0, SOURCE_FORCE_PROJECTOR_PHASE_HEAT_LERP_PROGRESS, source_delta)
	var consumed: bool = false
	if phase_valid and not broken and consume_tick and efficiency > 0.0:
		consumed = true
	radscl = source_math_state.source_lerp_delta(radscl, 0.0 if broken else warmup, SOURCE_FORCE_PROJECTOR_RADSCL_LERP_PROGRESS, source_delta)
	warmup = source_math_state.source_lerp_delta(warmup, efficiency, SOURCE_FORCE_PROJECTOR_WARMUP_LERP_PROGRESS, source_delta)
	if buildup > 0.0:
		var scale: float = SOURCE_FORCE_PROJECTOR_COOLDOWN_BROKEN_BASE if broken else SOURCE_FORCE_PROJECTOR_COOLDOWN_NORMAL
		if coolant_present and coolant_efficiency > 0.0:
			scale *= SOURCE_FORCE_PROJECTOR_COOLDOWN_LIQUID * (1.0 + (coolant_heat_capacity - 0.4) * 0.9)
		buildup -= source_delta * time_scale * scale
	if broken and buildup <= 0.0:
		broken = false
	if buildup >= SOURCE_FORCE_PROJECTOR_SHIELD_HEALTH + SOURCE_FORCE_PROJECTOR_PHASE_SHIELD_BOOST * phase_heat and not broken:
		broken = true
		buildup = SOURCE_FORCE_PROJECTOR_SHIELD_HEALTH
	if hit > 0.0:
		hit -= 1.0 / 5.0 * source_delta
	var real_radius: float = (SOURCE_FORCE_PROJECTOR_RADIUS + phase_heat * SOURCE_FORCE_PROJECTOR_PHASE_RADIUS_BOOST) * radscl
	var absorbed_bullets: Array = []
	var buildup_delta: float = 0.0
	if real_radius > 0.0 and not broken:
		var bullet_index: int = 0
		for bullet in bullets:
			if not (bullet is Dictionary):
				bullet_index += 1
				continue
			if int(bullet.get("team", team_id)) == team_id:
				bullet_index += 1
				continue
			if not bool(bullet.get("absorbable", true)):
				bullet_index += 1
				continue
			if bool(bullet.get("absorbed", false)):
				bullet_index += 1
				continue
			if not source_force_projector_is_in_regular_polygon(SOURCE_FORCE_PROJECTOR_SIDES, building_x, building_y, real_radius, SOURCE_FORCE_PROJECTOR_SHIELD_ROTATION, float(bullet.get("x", 0.0)), float(bullet.get("y", 0.0))):
				bullet_index += 1
				continue
			absorbed_bullets.append(bullet.get("id", bullet_index))
			buildup_delta += float(bullet.get("shield_damage", 0.0))
			hit = 1.0
			bullet_index += 1
	buildup += buildup_delta
	return {"phase_heat": phase_heat, "radscl": radscl, "warmup": warmup, "buildup": buildup, "broken": broken, "hit": hit, "consumed": consumed, "absorbed_bullets": absorbed_bullets, "buildup_delta": buildup_delta, "real_radius": real_radius}

static func source_force_projector_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The force-projector tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (ForceProjector.java:30, `public class ForceProjector extends Block{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# force projector skips consumption like Java's updateConsumption
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
	# for this force projector (N2125); the tick preserves a disabled
	# force projector instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	return {"phase_heat": 0.0, "radscl": 0.0, "warmup": 0.0, "buildup": 0.0, "broken": true, "hit": 0.0}

static func source_force_projector_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the force-projector frame meta key
	# ("source_force_projector_building"). A ForceProjector sprite gets a
	# frame bound seeded with the Java field defaults (phaseHeat /
	# radscl / warmup / buildup 0, broken TRUE, hit 0 --
	# ForceProjector.java:167-168); the live-loop tick fills its
	# other keys every tick. Any other block, or an already-bound
	# sprite, binds nothing.
	if block == null or not _is_force_projector_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_FORCE_PROJECTOR_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_FORCE_PROJECTOR_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_FORCE_PROJECTOR_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_force_projector_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40,
	# `return build.power.status;`): the power consumer's
	# efficiency is the building's live power.status, and the
	# first pass folds it into the min efficiency
	# (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`).
	# The graph update stamps
	# frame["power_status"] each tick (N2142); a missing stamp
	# folds to 1.0 before the first graph update, the assembler
	# fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`).
	# A block with no power consumer contributes no row. The
	# power consumer counts toward hasConsumers
	# (Block.java:1449, `hasConsumers = consumers.length > 0;`),
	# so a force projector does not take the early return. The
	# warmup follows the folded efficiency
	# (ForceProjector.java:221, `warmup = Mathf.lerpDelta(warmup, efficiency, 0.1f);`), with the radscl gate
	# (ForceProjector.java:215, `radscl = Mathf.lerpDelta(radscl, broken ? 0f : warmup, 0.05f);`) and the real-radius fold
	# (ForceProjector.java:280, `return (radius + phaseHeat * phaseRadiusBoost) * radscl;`) and the phase-heat gate
	# (ForceProjector.java:209, `phaseHeat = Mathf.lerpDelta(phaseHeat, Mathf.num(phaseValid), 0.1f);`) and the consume gate
	# (ForceProjector.java:211, `if(phaseValid && !broken && timer(timerUse, phaseUseTime / timeScale) && efficiency > 0){`).
	# Documented limits: (1) power-only first pass -- the
	# phaseFabric booster item row (Blocks.java:1974) and the
	# ConsumeCoolant 0.1f coolant rows (ForceProjector.java:69-71)
	# wait for their own slices, so the folded efficiency is
	# the min over the *modeled* consumers (power only).
	# (2) No shouldConsume gate -- ForceBuild has no
	# shouldConsume override, so the default
	# (BuildingComp.java:755-757, `return enabled;`) applies;
	# the machinery runs with should_consume=true when
	# enabled. (3) updateTile advance live (N2235) -- phaseValid /
	# phaseHeat / consume() gate / radscl / warmup / buildup /
	# broken / deflectBullets (ForceProjector.java:207-268) now
	# advance in source_force_projector_update_tile_advance_state;
	# the timer cadence + consume() application + live bullet
	# scan + coolant live fill stay deferred (the live-fill
	# entry). (4) Phase-radius / phase-shield folds live (N2235)
	# -- realRadius (ForceProjector.java:280,
	# `return (radius + phaseHeat * phaseRadiusBoost) * radscl;`)
	# is the advance's real_radius result and the broken
	# threshold folds shieldHealth + phaseShieldBoost * phaseHeat
	# (ForceProjector.java:244); the shield bar (setBars,
	# ForceProjector.java:104) still waits for its own slice.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

@warning_ignore("unused_parameter")
static func source_force_projector_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the force-projector tick wiring every
	# tick (ForceBuild.updateTile(), ForceProjector.java:207,
	# gates on the warmup fold (ForceProjector.java:221,
	# `warmup = Mathf.lerpDelta(warmup, efficiency, 0.1f);`) and folds the
	# real radius (ForceProjector.java:280,
	# `return (radius + phaseHeat * phaseRadiusBoost) * radscl;`), so the
	# warmup fold follows the folded efficiency; no
	# placed-buildings driver ticks ForceProjector blocks, so this
	# driver is the placed-force-projector tick): each placed
	# ForceProjector build gets its frame keys refreshed from the
	# live rules, so the frame's cheating flag tracks
	# team.rules().cheat and the consumption machinery skips
	# consumption for a cheating team. The frame is bound at
	# placement; a sprite that somehow lacks one gets it bound
	# here instead of crashing the loop.
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
		if not _is_force_projector_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_force_projector_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_force_projector_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a force projector with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the warmup fold (ForceProjector.java:221)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449,
		# `hasConsumers = consumers.length > 0;`), so a force
		# projector does not take the early return. A force projector with
		# no power consumer is untouched: the tick models no other
		# consumers yet (the phaseFabric booster item row and the
		# ConsumeCoolant 0.1f coolant rows wait for their
		# own slices), and there is no shouldConsume gate yet
		# (ForceBuild has no shouldConsume override; the default
		# BuildingComp.java:755-757 `return enabled;` applies),
		# so the machinery runs with should_consume=true when enabled.
		# productionValid is the canonical true default
		# (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var should_consume: bool = bool(frame.get("enabled", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_force_projector_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		# N2235: the updateTile advance runs after consumption,
		# like Java's Building.update() (BuildingComp.java:2274
		# updateConsumption(), then the updateTile gate
		# `if(enabled || !block.noUpdateDisabled){` at
		# BuildingComp.java:2276-2277; noUpdateDisabled defaults
		# false, `public boolean noUpdateDisabled = false;`
		# (Block.java:170), so Java runs updateTile even when
		# disabled -- in Java a disabled force projector's
		# warmup still lerps toward its zeroed efficiency
		# (BuildingComp.java:1954-1957). The port keeps the
		# enabled gate below as a pragmatic choice (the N2195
		# coordinator-fix precedent): the driver skips the
		# consumption fold when disabled, so the frame
		# efficiency goes stale and running the advance on it
		# would lerp warmup / phaseHeat from a stale
		# efficiency. The driver-wide disabled-early-return
		# slice (deferred in the N2229 register) removes this
		# gate for all families.
		# super.updateTile() is an empty no-op
		# (BuildingComp.java:2010-2012), so the driver owes it
		# nothing. The source delta is Time.delta in ticks:
		# game_source_delta(game, seconds) is seconds * 60 (arc
		# Time.java:26), never raw seconds. timeScale reads
		# live from the sprite meta, default 1.0
		# (BuildingComp.java:98 `private transient float
		# timeScale = 1f, timeScaleDuration;`). The building
		# position comes from the origin cell: Building x/y
		# are tile.drawx()/drawy() (BuildingComp.java:124,
		# `set(tile.drawx(), tile.drawy());`), drawx is
		# block.offset + tile.worldx() (Tile.java:175-176) with
		# the block offset `offset = ((size + 1) % 2) * tilesize / 2f;`
		# (Block.java:761) -- 0 for the size-3 force-projector.
		# The driver passes consume_tick false and an EMPTY
		# bullet list: no timer helper and no live bullet query
		# exist in the port, so no live consume or deflect
		# happens (the live fill stays deferred); the item /
		# coolant inputs are all default no-op (no items /
		# liquids store on the frame), so phaseHeat decays
		# toward 0 live and the coolant branch never runs.
		if bool(frame.get("enabled", true)):
			var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
			var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
			var advance_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
			var advance_block_size: int = int(block.properties.get("size", 1))
			var advance_block_offset: float = float((advance_block_size + 1) % 2) * source_world_defaults.TILESIZE / 2.0
			var advance_building_x: float = source_block_geometry.tile_drawx_state(advance_cell.x, source_world_defaults.TILESIZE, advance_block_offset)
			var advance_building_y: float = source_block_geometry.tile_drawy_state(advance_cell.y, source_world_defaults.TILESIZE, advance_block_offset)
			var advanced: Dictionary = source_force_projector_update_tile_advance_state(frame, source_delta, time_scale, advance_building_x, advance_building_y, [], false)
			frame["phase_heat"] = advanced["phase_heat"]
			frame["radscl"] = advanced["radscl"]
			frame["warmup"] = advanced["warmup"]
			frame["buildup"] = advanced["buildup"]
			frame["broken"] = advanced["broken"]
			frame["hit"] = advanced["hit"]
			frame["consumed"] = advanced["consumed"]
			frame["absorbed_bullets"] = advanced["absorbed_bullets"]
			frame["buildup_delta"] = advanced["buildup_delta"]
			frame["real_radius"] = advanced["real_radius"]
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
