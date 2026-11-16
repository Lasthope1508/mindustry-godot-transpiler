extends RefCounted
class_name SourceBaseShieldBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")

# The BaseShield implementation (BaseShield.java:18, `public class
# BaseShield extends Block{`): shield-projector (consumePower 5f,
# size 3, radius 200f default) and large-shield-projector
# (consumePower 5f, size 4, radius 400f, Blocks.java:2060).
# It hasPower=true (BaseShield.java:62, `hasPower = true;`),
# update=true, solid=true, rebuildable=false, canPickup=true.
# BaseShield extends Block, NOT a drill or factory, so it cannot
# reuse an existing frame key; this driver uses its own family
# frame key ("source_base_shield_building", the mechanical-pump /
# beam-drill / mend-projector / overdrive-projector /
# force-projector precedent), and this slice adds the
# base-shield key to N2142's
# SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back
# finds it. The port has NO SourceBaseShield* files at all
# yet -- no display/runtime state to lean on -- so the missing
# piece is the live power.status -> efficiency driver, which is
# exactly this slice: the smooth-radius fold
# (BaseShield.java:89, `smoothRadius = Mathf.lerpDelta(smoothRadius, radius * efficiency, 0.05f);`)
# follows the folded efficiency, with the shield only engaging
# past radius 1 (BaseShield.java:91, `float rad = radius();`).
const SOURCE_BASE_SHIELD_BUILD_IMPLEMENTATIONS := ["BaseShield"]
const SOURCE_BASE_SHIELD_BUILDING_META_KEY := "source_base_shield_building"
# The def radii (the catalog carries no radius for this family --
# the Separator craftTime precedent): the shield-projector keeps
# the class default `public float radius = 200f;`
# (BaseShield.java:20), the large-shield-projector sets
# `radius = 400f;` (Blocks.java:2060). The smooth-radius lerp
# progress is 0.05f (BaseShield.java:89), the shield engages past
# radius 1 (BaseShield.java:93), the enemy scan reaches rad + 10f
# (BaseShield.java:97), a unit is instakilled past hitSize * 1.5f
# (BaseShield.java:43), and the repel overshoots by 0.01f
# (BaseShield.java:50). smoothRadius has no initializer
# (BaseShield.java:85), so its Java default is 0f.
const SOURCE_BASE_SHIELD_RADIUS := 200.0
const SOURCE_BASE_SHIELD_LARGE_RADIUS := 400.0
const SOURCE_BASE_SHIELD_SMOOTH_RADIUS_DEFAULT := 0.0
const SOURCE_BASE_SHIELD_SMOOTH_RADIUS_LERP := 0.05
const SOURCE_BASE_SHIELD_ENGAGE_RADIUS := 1.0
const SOURCE_BASE_SHIELD_NEARBY_MARGIN := 10.0
const SOURCE_BASE_SHIELD_KILL_MULTIPLIER := 1.5
const SOURCE_BASE_SHIELD_REPEL_EPSILON := 0.01

static func _is_base_shield_build_implementation(implementation: String) -> bool:
	return SOURCE_BASE_SHIELD_BUILD_IMPLEMENTATIONS.has(implementation)

static func _base_shield_radius_for_block(block_id: String) -> float:
	# The block radius is a DEF value (the Separator craftTime
	# precedent -- the catalog carries no radius for this
	# family): the shield-projector keeps the class default
	# `public float radius = 200f;` (BaseShield.java:20), the
	# large-shield-projector sets `radius = 400f;`
	# (Blocks.java:2060). Both defs are editorOnly
	# (`requirements(Category.effect, BuildVisibility.editorOnly, with());`,
	# Blocks.java:2049/2057) with `consumePower(5f);`
	# (Blocks.java:2053/2062), size 3 / 4.
	if block_id == "large-shield-projector":
		return SOURCE_BASE_SHIELD_LARGE_RADIUS
	return SOURCE_BASE_SHIELD_RADIUS

static func source_base_shield_update_tile_advance_state(frame: Dictionary, source_delta: float, shield_radius: float, building_x: float, building_y: float, bullets: Array, enemy_units: Array) -> Dictionary:
	# The updateTile advance (BaseShieldBuild.updateTile(), BaseShield.java:88-99), the pure frame advance -- the build fields are `public boolean broken = false;` (BaseShield.java:83), `public float hit = 0f;` (BaseShield.java:84) and `public float smoothRadius;` (BaseShield.java:85, no initializer, so the Java default is 0f), the block fields are `public float radius = 200f;` (BaseShield.java:20) and `public int sides = 24;` (BaseShield.java:21), and the advance follows the Java lines in order (each exact expr on ONE comment line, the N2148 lesson):
	# `smoothRadius = Mathf.lerpDelta(smoothRadius, radius * efficiency, 0.05f);`
	# `float rad = radius();`
	# `if(rad > 1){`
	# `paramBuild = this;`
	# `Groups.bullet.intersect(x - rad, y - rad, rad * 2f, rad * 2f, bulletConsumer);`
	# `Units.nearbyEnemies(team, x, y, rad + 10f, unitConsumer);`
	# `public float radius(){`
	# `return smoothRadius;`
	# `if(bullet.team != paramBuild.team && bullet.type.absorbable && bullet.within(paramBuild, paramBuild.radius())){`
	# `bullet.absorb();`
	# `//paramBuild.hit = 1f;`
	# `//paramBuild.buildup += bullet.damage;`
	# `float overlapDst = (unit.hitSize/2f + paramBuild.radius()) - unit.dst(paramBuild);`
	# `if(overlapDst > 0){`
	# `if(overlapDst > unit.hitSize * 1.5f){`
	# `unit.kill();`
	# `unit.vel.setZero();`
	# `unit.move(Tmp.v1.set(unit).sub(paramBuild).setLength(overlapDst + 0.01f));`
	# `if(Mathf.chanceDelta(0.12f * Time.delta)){`
	# `broken = read.bool();`
	# The smoothRadius fold is lerpDelta (`return lerp(fromValue, toValue, clamp(progress * Time.delta));`, Mathf.java:430-432, with `return fromValue + (toValue - fromValue) * progress;`, Mathf.java:425-427 -- progress * delta CLAMPED, not the pow form) toward radius * efficiency with the BLOCK radius (the def value, 200f / 400f). rad is radius() = smoothRadius AFTER the fold (BaseShield.java:91/:101-103) -- the SCAN and the absorb / repel checks use the SMOOTH radius, not the block radius field (the scope-correction grep: the bulletConsumer within and the unitConsumer overlapDst both read paramBuild.radius()). The bullet within is STRICT (`return Mathf.dst2(getX(), getY(), x, y) < dst*dst;`, Position.java:44-46): exactly at the radius is OUT. The unit overlap uses the REAL dst (`return Mathf.sqrt(xd * xd + yd * yd);`, Position.java:28-32), not dst2. The repel vector is (unit - build) setLength(overlapDst + 0.01f), and setLength on a ZERO vector stays zero (`return (oldLen2 == 0 || oldLen2 == len2) ? this : scl((float)Math.sqrt(len2 / oldLen2));`, Vec2.java:304-308 -- Vector2.ZERO.normalized() is zero in Godot too), so a unit exactly on the building gets a (0, 0) repel. The instakill boundary is STRICT (overlapDst > hitSize * 1.5f): exactly 1.5x repels. absorb() is `absorbed = true;` + remove() (`public void absorb(){`, BulletComp.java:100-103) and kill() is guarded (`public void kill(){` / `if(dead || net.client() || !killable()) return;`, UnitComp.java:974-978) -- both as PURE RESULTS, never applied to a live bullet or unit. The bullet list IS the Groups.bullet.intersect rect result (`public void intersect(float x, float y, float width, float height, Cons<? super T> out){`, EntityGroup.java:195, over the spatial bullet group, `@GroupDef(value = Bulletc.class, spatial = true, collide = true) G bullet;`, GroupDefs.java:9, QuadTree hitbox overlap); the enemy-unit list IS the Units.nearbyEnemies result (`public static void nearbyEnemies(Team team, float x, float y, float radius, Cons<Unit> cons){`, Units.java:482-487, which filters `if(u.within(x, y, radius + u.hitSize/2f)){`) -- enemy-only by construction, so there is no team check in the advance (the N2230 closestEnemy precedent). The bullet dict contract (the N2212 / N2229 fixture precedent): x / y, team (int; missing = own team, never an enemy), absorbable (default true, `public boolean absorbable = true;`, BulletType.java:147). The unit dict contract: x / y, hit_size (default 0.0, the N2226 repair-turret precedent). The spark chance (`if(Mathf.chanceDelta(0.12f * Time.delta)){`, BaseShield.java:52-53) defers (presentation, no RNG in the pure advance). broken/hit are NEVER set live (grep: broken only at the :83 false init and the :167 save read, `broken = read.bool();`; hit only in the commented-out :33 line) -- so there are no broken/hit frame keys and no buildup anywhere in BaseShield. The defs are `shieldProjector = new BaseShield("shield-projector"){{` (Blocks.java:2048-2054, size 3) and `largeShieldProjector = new BaseShield("large-shield-projector"){{` (Blocks.java:2056-2063, size 4, `radius = 400f;`), both editorOnly with `consumePower(5f);`. source_delta is Time.delta in ticks (`private static Floatp deltaimpl = () -> Math.min(Core.graphics.getDeltaTime() * 60f, 3f);`, arc Time.java:26) through game_source_delta, never raw seconds.
	var team_id: int = int(frame.get("team_id", source_block_geometry.SOURCE_TEAM_DERELICT_ID))
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var smooth_radius: float = float(frame.get("smooth_radius", SOURCE_BASE_SHIELD_SMOOTH_RADIUS_DEFAULT))
	smooth_radius = source_math_state.source_lerp_delta(smooth_radius, shield_radius * efficiency, SOURCE_BASE_SHIELD_SMOOTH_RADIUS_LERP, source_delta)
	var rad: float = smooth_radius
	var absorbed_bullets: Array = []
	var repelled_units: Array = []
	var killed_units: Array = []
	if rad > SOURCE_BASE_SHIELD_ENGAGE_RADIUS:
		for bullet in bullets:
			if not (bullet is Dictionary):
				continue
			if int(bullet.get("team", team_id)) == team_id:
				continue
			if not bool(bullet.get("absorbable", true)):
				continue
			var bullet_dx: float = float(bullet.get("x", 0.0)) - building_x
			var bullet_dy: float = float(bullet.get("y", 0.0)) - building_y
			var bullet_dst2: float = bullet_dx * bullet_dx + bullet_dy * bullet_dy
			if bullet_dst2 < rad * rad:
				absorbed_bullets.append(bullet)
		for unit in enemy_units:
			if not (unit is Dictionary):
				continue
			var hit_size: float = float(unit.get("hit_size", 0.0))
			var unit_dx: float = float(unit.get("x", 0.0)) - building_x
			var unit_dy: float = float(unit.get("y", 0.0)) - building_y
			var unit_dst: float = sqrt(unit_dx * unit_dx + unit_dy * unit_dy)
			var overlap_dst: float = (hit_size / 2.0 + rad) - unit_dst
			if overlap_dst > 0.0:
				if overlap_dst > hit_size * SOURCE_BASE_SHIELD_KILL_MULTIPLIER:
					killed_units.append(unit)
				else:
					var repel_direction: Vector2 = Vector2(unit_dx, unit_dy).normalized()
					var repel_length: float = overlap_dst + SOURCE_BASE_SHIELD_REPEL_EPSILON
					var repel: Vector2 = repel_direction * repel_length
					repelled_units.append({"unit": unit, "repel_x": repel.x, "repel_y": repel.y, "overlap_dst": overlap_dst, "stopped": true})
	return {"smooth_radius": smooth_radius, "absorbed_bullets": absorbed_bullets, "repelled_units": repelled_units, "killed_units": killed_units}

static func source_base_shield_supplied_bullets_state(candidates: Array, rad: float, building_x: float, building_y: float) -> Dictionary:
	# The live bullet scan (Groups.bullet.intersect(x - rad, y - rad, rad * 2f, rad * 2f, bulletConsumer), BaseShield.java:96), the RECT broad phase only -- the narrow check is the N2236 advance's job (the bulletConsumer filter: enemy team + absorbable + STRICT within radius(), BaseShield.java:27-37), so this pure filters on the RECT alone and never looks at team or absorbable. The intersect runs over the spatial bullet group (`public void intersect(float x, float y, float width, float height, Cons<? super T> out){`, EntityGroup.java:195, the consumer overload, QuadTree hitbox overlap; `@GroupDef(value = Bulletc.class, spatial = true, collide = true) G bullet;`, GroupDefs.java:9) -- the port tests bullet CENTERS against the rect [x +/- rad, y +/- rad], INCLUSIVE (the N2277 precedent: a bullet at the rect corner (rad, rad) is IN even though it sits outside the radius circle), and the hitbox-overlap refinement waits for its own slice. A candidate without x/y has no center to test and is EXCLUDED; a non-dict candidate is skipped. The scan runs only when rad > 1 (`if(rad > 1){`, BaseShield.java:93) -- the gate lives at the TICK, not in this pure.
	var bullets: Array = []
	for candidate in candidates:
		if not (candidate is Dictionary):
			continue
		if not candidate.has("x") or not candidate.has("y"):
			continue
		if absf(float(candidate.get("x", 0.0)) - building_x) <= rad and absf(float(candidate.get("y", 0.0)) - building_y) <= rad:
			bullets.append(candidate)
	return {"bullets": bullets}

static func source_base_shield_supplied_enemy_units_state(candidates: Array, rad: float, building_x: float, building_y: float, team_id: int) -> Dictionary:
	# The live enemy-unit scan (Units.nearbyEnemies(team, x, y, rad + 10f, unitConsumer), BaseShield.java:97), the nearbyEnemies radius overload (`public static void nearbyEnemies(Team team, float x, float y, float radius, Cons<Unit> cons){`, Units.java:482-488): the rect scan (`nearbyEnemies(team, x - radius, y - radius, radius * 2f, radius * 2f, u -> {`, Units.java:483) is enemy-only by construction, then the filter (`if(u.within(x, y, radius + u.hitSize/2f)){`, Units.java:484) admits a unit whose center is STRICTLY within radius + hitSize/2 of the building (`return Mathf.dst2(getX(), getY(), x, y) < dst*dst;`, Position.java:44-46): exactly at the range is OUT. The BaseShield call passes rad + 10f, so the scan range here is rad + 10 + hitSize/2 (the 10f margin is SOURCE_BASE_SHIELD_NEARBY_MARGIN). The advance checks no team (the N2230 closestEnemy precedent) -- this scan is the ONLY team filter: a unit without a team is its own team (never an enemy). A unit without x/y is EXCLUDED; a unit without hit_size defaults to 0.0 (the N2226 repair-turret precedent). The unitConsumer overlapDst / kill / repel (BaseShield.java:38-56) is the N2236 advance's job; this pure only filters. The scan runs only when rad > 1 (`if(rad > 1){`, BaseShield.java:93) -- the gate lives at the TICK, not in this pure.
	var enemy_units: Array = []
	for unit in candidates:
		if not (unit is Dictionary):
			continue
		if int(unit.get("team", team_id)) == team_id:
			continue
		if not unit.has("x") or not unit.has("y"):
			continue
		var hit_size: float = float(unit.get("hit_size", 0.0))
		var scan_range: float = rad + SOURCE_BASE_SHIELD_NEARBY_MARGIN + hit_size / 2.0
		var unit_dx: float = float(unit.get("x", 0.0)) - building_x
		var unit_dy: float = float(unit.get("y", 0.0)) - building_y
		var unit_dst2: float = unit_dx * unit_dx + unit_dy * unit_dy
		if unit_dst2 < scan_range * scan_range:
			enemy_units.append(unit)
	return {"enemy_units": enemy_units}

static func source_base_shield_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The base-shield tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (BaseShield.java:18, `public class BaseShield extends Block{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# base shield skips consumption like Java's updateConsumption
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
	# for this base shield (N2125); the tick preserves a disabled
	# base shield instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	return {"smooth_radius": 0.0}

static func source_base_shield_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the base-shield frame meta key
	# ("source_base_shield_building"). A BaseShield sprite gets a
	# frame bound with the smooth radius defaulting to 0.0 (the
	# Java field `public float smoothRadius;`,
	# BaseShield.java:85, has no initializer); the live-loop tick
	# fills its other keys every tick. Any other block, or an
	# already-bound sprite, binds nothing.
	if block == null or not _is_base_shield_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_BASE_SHIELD_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_BASE_SHIELD_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_BASE_SHIELD_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_base_shield_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
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
	# so a base shield does not take the early return. The
	# smooth radius follows the folded efficiency
	# (BaseShield.java:89, `smoothRadius = Mathf.lerpDelta(smoothRadius, radius * efficiency, 0.05f);`), with the shield only engaging past radius 1
	# (BaseShield.java:91, `float rad = radius();`) and the default radius
	# (BaseShield.java:20, `public float radius = 200f;`) and the large radius
	# (Blocks.java:2060, `radius = 400f;`) and the shouldConsume default
	# (BuildingComp.java:755, `public boolean shouldConsume(){`).
	# Documented limits: (1) power-only first pass -- BaseShield has
	# no item or liquid consumers at all, so the folded efficiency is
	# the min over the *modeled* consumers (power only) with nothing
	# else to defer. (2) No shouldConsume gate -- BaseShieldBuild has no
	# shouldConsume override, so the default
	# (BuildingComp.java:755-757, `return enabled;`) applies;
	# the machinery runs with should_consume=true when
	# enabled. (3) updateTile advance live (N2236) --
	# smoothRadius / bullet absorb / unit repel
	# (BaseShield.java:88-99) advance each tick as pure results;
	# broken/hit are never set live (broken only from the save
	# read, BaseShield.java:167; hit only in the commented-out
	# line :33), so there are no broken/hit keys; the live
	# bullet + enemy-unit scans live (N2328) -- the tick filters
	# the frame bullet_candidates / enemy_unit_candidates
	# (default [], the live Groups.bullet / Units queries still
	# defer) and passes the scanned lists into the advance, so a
	# live shield absorbs / repels from supplied candidates; the
	# absorb/repel/kill APPLICATION onto live bullets/units
	# waits for its own slice. (4) No drawShield rows -- shieldColor / animateShields / sides 24 /
	# hit alpha (BaseShield.java:125-147) are presentation, not state.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

@warning_ignore("unused_parameter")
static func source_base_shield_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the base-shield tick wiring every
	# tick (BaseShieldBuild.updateTile(), BaseShield.java:88,
	# gates on the smooth-radius fold (BaseShield.java:89,
	# `smoothRadius = Mathf.lerpDelta(smoothRadius, radius * efficiency, 0.05f);`) and the shield only engages past radius 1
	# (BaseShield.java:91, `float rad = radius();`), so the
	# smooth-radius fold follows the folded efficiency; no
	# placed-buildings driver ticks BaseShield blocks, so this
	# driver is the placed-base-shield tick): each placed
	# BaseShield build gets its frame keys refreshed from the
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
		if not _is_base_shield_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_base_shield_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_base_shield_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a base shield with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the smooth-radius fold (BaseShield.java:89)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449,
		# `hasConsumers = consumers.length > 0;`), so a base
		# shield does not take the early return. A base shield with
		# no power consumer is untouched: the tick models no other
		# consumers yet (BaseShield has no item or liquid consumers
		# at all), and there is no shouldConsume gate yet
		# (BaseShieldBuild has no shouldConsume override; the default
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
			var power_row: Dictionary = source_base_shield_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		# N2236: the updateTile advance runs after consumption,
		# like Java's Building.update() (BuildingComp.java:2274
		# `updateConsumption();`, then the updateTile gate
		# `if(enabled || !block.noUpdateDisabled){` at
		# BuildingComp.java:2276-2277; noUpdateDisabled defaults
		# false, `public boolean noUpdateDisabled = false;`
		# (Block.java:170), so Java runs updateTile even when
		# disabled -- in Java a disabled shield's smoothRadius
		# decays toward 0 (efficiency is zeroed by the disabled
		# early return, BuildingComp.java:1954-1957). The port
		# keeps the enabled gate below as a pragmatic choice
		# (the N2195 coordinator-fix precedent): the driver
		# skips the consumption fold when disabled, so the frame
		# efficiency goes stale and running the advance on it
		# would fold the smooth radius from a stale efficiency.
		# The driver-wide disabled-early-return slice (deferred
		# in the N2236 register) removes this gate for all
		# families. super.updateTile() is an empty no-op
		# (BuildingComp.java:2010-2012), so the driver owes it
		# nothing. The source delta is Time.delta in ticks:
		# game_source_delta(game, seconds) is seconds * 60 (arc
		# Time.java:26), never raw seconds. The block radius
		# comes from the def (200f / 400f -- the catalog carries
		# no radius). The building position comes from the
		# origin cell: Building x/y are tile.drawx()/drawy()
		# (BuildingComp.java:124, `set(tile.drawx(), tile.drawy());`),
		# drawx is block.offset + tile.worldx() (Tile.java:175-176,
		# `return block().offset + worldx();` /
		# `return block().offset + worldy();`) with the block
		# offset `offset = ((size + 1) % 2) * tilesize / 2f;`
		# (Block.java:761) -- 0 for the size-3 shield-projector,
		# 4 for the size-4 large-shield-projector. N2328: the
		# driver no longer passes EMPTY bullet and enemy-unit
		# lists -- the tick runs the two scan pures over the
		# frame bullet_candidates / enemy_unit_candidates
		# (default [], the live Groups.bullet / Units queries
		# still defer) and passes the filtered lists into the
		# advance. The rad problem (BaseShield.java:89-93): rad
		# is radius() = smoothRadius AFTER the lerpDelta fold
		# (`smoothRadius = Mathf.lerpDelta(smoothRadius, radius
		# * efficiency, 0.05f);`, :89; `float rad = radius();`,
		# :91), but the tick needs rad BEFORE the advance call
		# to run the scans -- so the tick computes scan_rad
		# with the SAME shared helper + const the advance uses
		# (source_math_state.source_lerp_delta, progress *
		# Time.delta CLAMPED, `return lerp(fromValue, toValue,
		# clamp(progress * Time.delta));`, Mathf.java:430-432),
		# deterministic, the same result the advance computes
		# inside. The rad > 1 gate (`if(rad > 1){`, :93) lives
		# at the TICK: scan_rad <= 1 skips both scans and the
		# advance gets empty lists.
		# Building.enabled is `transient boolean enabled = true;`
		# (BuildingComp.java:77) and the folded efficiency reads
		# `transient float efficiency;` (BuildingComp.java:85).
		if bool(frame.get("enabled", true)):
			var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
			var advance_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
			var advance_block_size: int = int(block.properties.get("size", 1))
			var advance_block_offset: float = float((advance_block_size + 1) % 2) * source_world_defaults.TILESIZE / 2.0
			var advance_building_x: float = source_block_geometry.tile_drawx_state(advance_cell.x, source_world_defaults.TILESIZE, advance_block_offset)
			var advance_building_y: float = source_block_geometry.tile_drawy_state(advance_cell.y, source_world_defaults.TILESIZE, advance_block_offset)
			var advance_shield_radius: float = _base_shield_radius_for_block(block_id)
			var scan_rad: float = source_math_state.source_lerp_delta(float(frame.get("smooth_radius", SOURCE_BASE_SHIELD_SMOOTH_RADIUS_DEFAULT)), advance_shield_radius * float(frame.get("efficiency", 0.0)), SOURCE_BASE_SHIELD_SMOOTH_RADIUS_LERP, source_delta)
			var scanned_bullets: Array = []
			var scanned_enemy_units: Array = []
			if scan_rad > SOURCE_BASE_SHIELD_ENGAGE_RADIUS:
				scanned_bullets = source_base_shield_supplied_bullets_state(frame.get("bullet_candidates", []), scan_rad, advance_building_x, advance_building_y).get("bullets", [])
				scanned_enemy_units = source_base_shield_supplied_enemy_units_state(frame.get("enemy_unit_candidates", []), scan_rad, advance_building_x, advance_building_y, team_id).get("enemy_units", [])
			var advanced: Dictionary = source_base_shield_update_tile_advance_state(frame, source_delta, advance_shield_radius, advance_building_x, advance_building_y, scanned_bullets, scanned_enemy_units)
			frame["smooth_radius"] = advanced["smooth_radius"]
			frame["absorbed_bullets"] = advanced["absorbed_bullets"]
			frame["repelled_units"] = advanced["repelled_units"]
			frame["killed_units"] = advanced["killed_units"]
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
