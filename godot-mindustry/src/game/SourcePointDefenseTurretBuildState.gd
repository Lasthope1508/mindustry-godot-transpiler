extends RefCounted
class_name SourcePointDefenseTurretBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")

# The PointDefenseTurret implementation (PointDefenseTurret.java:19,
# `public class PointDefenseTurret extends ReloadTurret{`): segment
# (consumePower 8f, size 2, range 180f, reload 8f, bulletDamage 30f,
# shootLength 5f, hasPower true). The only PointDefenseTurret block
# in the game (Blocks.java:3835-3847). PointDefenseBuild extends
# ReloadTurretBuild, NOT TurretBuild, so the turret driver
# (SourceTurretBuildState.gd) explicitly excludes it and no driver
# ticks it at all: it would rotate and reload as if power.status
# were 1.0. This driver is the point-defense tick. The driver uses
# its own family frame key ("source_point_defense_turret_building",
# the turret precedent); the generic turret frame
# ("source_turret_building") stays untouched, and this slice adds
# the point-defense key to N2142's
# SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back
# finds it.
const SOURCE_POINT_DEFENSE_TURRET_BUILD_IMPLEMENTATIONS := ["PointDefenseTurret"]
const SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY := "source_point_defense_turret_building"
# Segment def values (Blocks.java:3835-3847, the only
# PointDefenseTurret def): `range = 180f;`, `shootLength = 5f;`,
# `bulletDamage = 30f;`, `reload = 8f;` -- the DEF wins over the
# class defaults (`public float bulletDamage = 10f;`,
# `public float shootLength = 3f;`, PointDefenseTurret.java:33-34;
# `reload = 30f;` in the ctor, PointDefenseTurret.java:40; the
# ReloadTurret class default `public float reload = 10f;`,
# ReloadTurret.java:9). The catalog carries neither range nor
# bulletDamage nor reload for this family, so the driver reads
# these constants (the Separator craftTime precedent).
const SOURCE_POINT_DEFENSE_TURRET_RANGE := 180.0
const SOURCE_POINT_DEFENSE_TURRET_BULLET_DAMAGE := 30.0
const SOURCE_POINT_DEFENSE_TURRET_RELOAD := 8.0
# Class values (PointDefenseTurret.java): `rotateSpeed = 20f;`
# (:39), `public float shootCone = 5f;` (:32),
# `coolantMultiplier = 2f;` (:42, over the BaseTurret default
# 5f), `public float retargetTime = 5f;` (:21, the deferred
# retarget cadence -- the driver passes retarget_tick false
# until the timer-infra slice lands), and the rotation field
# default `public float rotation = 90;` (BaseTurret.java:114).
# The coolant capacity fallback is the no-liquid branch of
# updateCooling (ReloadTurret.java:31, `0.4f`).
const SOURCE_POINT_DEFENSE_TURRET_ROTATE_SPEED := 20.0
const SOURCE_POINT_DEFENSE_TURRET_SHOOT_CONE := 5.0
const SOURCE_POINT_DEFENSE_TURRET_COOLANT_MULTIPLIER := 2.0
const SOURCE_POINT_DEFENSE_TURRET_RETARGET_TIME := 5.0
const SOURCE_POINT_DEFENSE_TURRET_ROTATION_DEFAULT := 90.0
const SOURCE_POINT_DEFENSE_TURRET_COOLANT_CAPACITY_FALLBACK := 0.4

static func _is_point_defense_turret_build_implementation(implementation: String) -> bool:
	return SOURCE_POINT_DEFENSE_TURRET_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_point_defense_turret_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float, turret_range: float, bullet_damage: float, reload: float, building_x: float, building_y: float, bullets: Array, retarget_tick: bool, block_damage_multiplier: float = 1.0, coolant_present: bool = false, coolant_amount: float = 0.0, coolant_efficiency: float = 0.0, heat_capacity: float = SOURCE_POINT_DEFENSE_TURRET_COOLANT_CAPACITY_FALLBACK) -> Dictionary:
	# The updateTile advance (PointDefenseBuild.updateTile(), PointDefenseTurret.java:62-103), the pure frame advance -- the build fields are `public @Nullable Bullet target;` (PointDefenseTurret.java:59), `public float rotation = 90;` (BaseTurret.java:114) and `public float reloadCounter;` (ReloadTurret.java:26), and the advance follows the Java lines in order (each exact expr on ONE comment line, the N2148 lesson):
	# `if(timer(timerTarget, retargetTime)){`
	# `target = Groups.bullet.intersect(x - range, y - range, range*2, range*2).min(b -> b.team != team && b.type().hittable, b -> b.dst2(this));`
	# `if(target != null && !target.isAdded()){`
	# `if(coolant != null){`
	# `updateCooling();`
	# `if(target != null && target.within(this, range) && target.team != team && target.type() != null && target.type().hittable){`
	# `float dest = angleTo(target);`
	# `rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta());`
	# `reloadCounter += edelta();`
	# `if(Angles.within(rotation, dest, shootCone) && reloadCounter >= reload){`
	# `float realDamage = bulletDamage * state.rules.blockDamage(team);`
	# `if(target.damage() > realDamage){`
	# `target.damage(target.damage() - realDamage);`
	# `target.remove();`
	# `reloadCounter = 0;`
	# The retarget is a RECTANGLE intersect (EntityGroup.java:207, `public Seq<T> intersect(float x, float y, float width, float height){`, over the spatial bullet group, GroupDefs.java:9, `@GroupDef(value = Bulletc.class, spatial = true, collide = true) G bullet;`, hitbox overlap against the rect, QuadTree.java, `if(tmp.overlaps(x, y, width, height)){`), NOT a circle -- and the min is over dst2 RAW (no hitSize subtraction, unlike Units.closestEnemy), with Seq.min's `if(val <= min){` (Seq.java:329), so the LAST candidate wins a tie (unlike Units.closest's strict <, the N2226 precedent). The explicit `bullets` list IS the intersect result (the N2226 candidates precedent): the caller supplies the bullets in the rect, and the pure selection applies the min filter (enemy team + hittable) and the raw-dst2 min. Java overwrites the target UNCONDITIONALLY on a timer tick (PointDefenseTurret.java:66), so a retarget tick with no qualifying bullet clears the target to null; retarget_tick false means the timer did not fire and the target is untouched. The TIMER CADENCE itself defers (no timer helper in the port, the N2193 precedent; `public float retargetTime = 5f;`, PointDefenseTurret.java:21), so the driver passes retarget_tick false and an empty list and no live retarget happens. The pooled clear reads the target dict's `added` flag (default true -- a live bullet is added; EntityComp.java:16, `boolean isAdded(){`). Cooling is updateCooling (ReloadTurret.java:28-41): the gate is canReload() (`return reloadCounter < reload;`, ReloadTurret.java:51) && coolant != null && coolant.efficiency > 0 && efficiency > 0 (`if(canReload() && coolant != null && coolant.efficiency(this) > 0 && efficiency > 0){`), the amount is `float amount = coolant.amount * coolant.efficiency(this);` and the charge is `reloadCounter += amount * edelta() * capacity * coolantMultiplier * ammoReloadMultiplier();` with ammoReloadMultiplier() returning 1f (ReloadTurret.java:43-45) and capacity resolved by the caller (the filter / consumes branches, ReloadTurret.java:31, fallback 0.4f). Coolant is NULL for the segment (the def has no ConsumeCoolant consumer, so BaseTurret.init :50-51, `coolant = findConsumer(c -> c instanceof ConsumeCoolant);`, leaves it null) -- the branch never runs live, and the driver passes coolant absent; the explicit coolant params model the branch for a def that has one. The look-at guard's within is STRICT (`return Mathf.dst2(getX(), getY(), x, y) < dst*dst;`, Position.java:44-46): exactly at range is OUT. dest is angleTo, `return Angles.angle(getX(), getY(), other.getX(), other.getY());` (Position.java:12-14), through the shared angle helper; moveToward and within are the shared helpers (Angles.java:38-39 / :19-20). realDamage folds blockDamage(team) (`return blockDamageMultiplier * teams.get(team).blockDamageMultiplier;`, Rules.java:299-301, both multipliers default 1f, Rules.java:113/:367), passed as block_damage_multiplier (default 1.0). The shot does NOT apply damage to the live bullet: damage > realDamage returns target_damage_remaining, otherwise target_removed (Java keeps the target field set -- `target.remove();` only un-adds the bullet, and the pooled clear nulls it next tick). Effects + sound (beamEffect / shootEffect / hitEffect / shootSound, PointDefenseTurret.java:94-99, with the shootLength 5f muzzle offset, Blocks.java:3842) defer. edelta() is `return efficiency * delta();` (BuildingComp.java:1927-1929) with delta() `return Time.delta * timeScale;` (BuildingComp.java:1922-1924); source_delta is Time.delta in ticks (seconds * 60 through game_source_delta, arc Time.java:26), never raw seconds. The target dict contract (the N2212 fixture precedent): x / y (position), team (int; missing = own team, never an enemy), type (null = no type, fails the look-at guard), hittable (default true, BulletType.java:143, `public boolean hittable = true;`), added (default true), damage (the bullet damage pool, BulletComp.java:31, `@Import float x, y, damage, lastX, lastY, time, lifetime;`). Class values: `public float shootCone = 5f;` (PointDefenseTurret.java:32), `public float bulletDamage = 10f;` / `public float shootLength = 3f;` (PointDefenseTurret.java:33-34), `rotateSpeed = 20f;` / `reload = 30f;` / `coolantMultiplier = 2f;` (PointDefenseTurret.java:39-42), `public float reload = 10f;` (ReloadTurret.java:9) -- the segment def wins: `range = 180f;`, `shootLength = 5f;`, `bulletDamage = 30f;`, `reload = 8f;` (Blocks.java:3838-3844).
	var team_id: int = int(frame.get("team_id", source_block_geometry.SOURCE_TEAM_DERELICT_ID))
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var target: Variant = frame.get("target", null)
	var rotation: float = float(frame.get("rotation", SOURCE_POINT_DEFENSE_TURRET_ROTATION_DEFAULT))
	var reload_counter: float = float(frame.get("reload_counter", 0.0))
	var edelta: float = efficiency * source_delta * time_scale
	if retarget_tick:
		var best: Variant = null
		var best_dst2: float = 0.0
		for bullet in bullets:
			if not (bullet is Dictionary):
				continue
			if int(bullet.get("team", team_id)) == team_id:
				continue
			if not bool(bullet.get("hittable", true)):
				continue
			var bullet_dx: float = float(bullet.get("x", 0.0)) - building_x
			var bullet_dy: float = float(bullet.get("y", 0.0)) - building_y
			var bullet_dst2: float = bullet_dx * bullet_dx + bullet_dy * bullet_dy
			if best == null or bullet_dst2 <= best_dst2:
				best = bullet
				best_dst2 = bullet_dst2
		target = best
	if target != null and target is Dictionary and not bool(target.get("added", true)):
		target = null
	if coolant_present and reload_counter < reload and coolant_efficiency > 0.0 and efficiency > 0.0:
		var coolant_charge_amount: float = coolant_amount * coolant_efficiency
		reload_counter += coolant_charge_amount * edelta * heat_capacity * SOURCE_POINT_DEFENSE_TURRET_COOLANT_MULTIPLIER * 1.0
	var target_damage_remaining: Variant = null
	var target_removed: bool = false
	var fired: bool = false
	if target != null and target is Dictionary:
		var target_dx: float = float(target.get("x", 0.0)) - building_x
		var target_dy: float = float(target.get("y", 0.0)) - building_y
		var target_dst2: float = target_dx * target_dx + target_dy * target_dy
		if target_dst2 < turret_range * turret_range and int(target.get("team", team_id)) != team_id and target.get("type", null) != null and bool(target.get("hittable", true)):
			var dest: float = source_math_state.source_angles_angle(building_x, building_y, float(target.get("x", 0.0)), float(target.get("y", 0.0)))
			rotation = source_math_state.source_angles_move_toward(rotation, dest, SOURCE_POINT_DEFENSE_TURRET_ROTATE_SPEED * edelta)
			reload_counter += edelta
			if source_math_state.source_angles_within(rotation, dest, SOURCE_POINT_DEFENSE_TURRET_SHOOT_CONE) and reload_counter >= reload:
				fired = true
				var real_damage: float = bullet_damage * block_damage_multiplier
				var target_damage: float = float(target.get("damage", 0.0))
				if target_damage > real_damage:
					target_damage_remaining = target_damage - real_damage
				else:
					target_removed = true
				reload_counter = 0.0
	return {"target": target, "rotation": rotation, "reload_counter": reload_counter, "target_damage_remaining": target_damage_remaining, "target_removed": target_removed, "fired": fired}

static func source_point_defense_turret_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The point-defense tick wires the frame keys the consumption
	# path reads (the N2148 turret pattern): block_implementation
	# is the block's implementation (PointDefenseTurret.java:19,
	# `public class PointDefenseTurret extends ReloadTurret{`),
	# team_id and rules_state are what Java reads as b.team and
	# state.rules, and cheating is the team's live TeamRule value
	# (TeamComp.cheating(), TeamComp.java:17-19 `return team.rules().cheat;`,
	# read through N2099's helper), so a cheating team's segment
	# skips consumption like Java's updateConsumption
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
	# for this segment (N2125); the tick preserves a disabled
	# segment instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	return {"target": null}

static func source_point_defense_turret_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the point-defense frame meta key
	# ("source_point_defense_turret_building"). A PointDefenseTurret
	# sprite gets a frame bound with the target key defaulting to
	# null (the Java field `public @Nullable Bullet target;`,
	# PointDefenseTurret.java:59, defaults to null); the live-loop
	# tick fills its other keys every tick. Any other block, or an
	# already-bound sprite, binds nothing.
	if block == null or not _is_point_defense_turret_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_point_defense_turret_should_consume_state(frame: Dictionary) -> Dictionary:
	# PointDefenseBuild overrides shouldConsume (PointDefenseTurret.java:105, `public boolean shouldConsume(){` with `return super.shouldConsume() && target != null;`, PointDefenseTurret.java:106): the gate reads the enabled flag through super AND the live bullet target. The field is `public @Nullable Bullet target;` (PointDefenseTurret.java:59) -- the target is a BULLET, not a Unit -- on PointDefenseBuild (`public class PointDefenseBuild extends ReloadTurretBuild{`, PointDefenseTurret.java:58); `super` is the BuildingComp default (`return enabled;`, BuildingComp.java:755-756) -- the chain runs PointDefenseBuild -> ReloadTurretBuild (ReloadTurret.java:25) -> BaseTurretBuild (BaseTurret.java:113) -> Building, and neither ReloadTurret.java nor BaseTurret.java overrides shouldConsume, so the default applies. Turret.TurretBuild.shouldConsume() (Turret.java:364-366, `return isShooting || reloadCounter < reload;`) is NOT in this chain -- PointDefenseTurret extends ReloadTurret (PointDefenseTurret.java:19, `public class PointDefenseTurret extends ReloadTurret{`), not Turret. The gate is `enabled && target != null`, so the pure gate reads both frame keys (the RepairTurret N2212 precedent: the super default is read as an internal frame key): target (frame["target"], default null for a frame bound before this slice -- the Java field default) and enabled (frame["enabled"], default true -- BuildingComp.java:77, `transient boolean enabled = true;`); no live fill sets frame["target"] yet -- the live bullet-target retarget (Groups.bullet scan, PointDefenseTurret.java:66, `target = Groups.bullet.intersect(x - range, y - range, range*2, range*2).min(b -> b.team != team && b.type().hittable, b -> b.dst2(this));`, plus the clear when the bullet is pooled, PointDefenseTurret.java:70, `if(target != null && !target.isAdded()){`) is the updateTile advance (PointDefenseTurret.java:62-103): N2229 ports the retarget selection + pooled clear + rotation / reload advance as a pure function, but the timer cadence + live bullet query wait for the live-fill slice, so no live fill sets frame["target"] yet. When the gate is false updateConsumption forces efficiency to zero (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). The rotation advance (PointDefenseTurret.java:81, `rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta());`) follows the folded efficiency. The only def is segment (Blocks.java:3835-3847): `consumePower(8f);`, `range = 180f;`, `reload = 8f;`, size 2.
	var target: Variant = frame.get("target", null)
	var enabled: bool = bool(frame.get("enabled", true))
	return {"should_consume": enabled and target != null, "has_target": target != null}

static func source_point_defense_turret_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40,
	# `return build.power.status;`): the power consumer's
	# efficiency is the building's live power.status, and the
	# first pass folds it into the min efficiency
	# (BuildingComp.java:1969-1976, `for(var cons : block.
	# nonOptionalConsumers){` / `minEfficiency = Math.min(
	# minEfficiency, result);`). The graph update stamps
	# frame["power_status"] each tick (N2142); a missing stamp
	# folds to 1.0 before the first graph update, the assembler
	# fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`).
	# A block with no power consumer contributes no row. The
	# power consumer counts toward hasConsumers
	# (Block.java:1449, `hasConsumers = consumers.length > 0;`),
	# so a segment does not take the early return. The
	# point-defense rotation and reload follow the folded
	# efficiency through edelta (BuildingComp.java:1928, `return efficiency * delta();`,
	# PointDefenseTurret.java:81, `rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta());`).
	# Documented limits: (1) power-only first pass -- segment
	# has no other consumers; the folded efficiency is the min
	# over the *modeled* consumers (power only). (2)
	# shouldConsume gate live (N2217) -- PointDefenseBuild.
	# shouldConsume() (PointDefenseTurret.java:105-107, `return
	# super.shouldConsume() && target != null;`); when the gate
	# is false Java forces efficiency to 0 (BuildingComp.java:
	# 1960 + 1992-1994); the pure gate reads the frame target
	# key (default null) plus enabled and feeds should_consume
	# to the machinery; no live fill sets frame["target"] yet
	# (N2229: the retarget selection + pooled clear are live as
	# a pure function; the timer cadence + live bullet query
	# wait for the live-fill slice).
	# (3) updateTile advance live (N2229) -- the retarget
	# selection / pooled clear / rotation / reloadCounter /
	# shot outcome (PointDefenseTurret.java:62-103) run on the
	# frame; the timer cadence (no timer helper, no live bullet
	# query -- the driver passes retarget_tick false and no
	# bullets), the damage application on the live bullet, the
	# coolant live fill (the segment def has no ConsumeCoolant
	# consumer), and the beam / hit / shoot effects + shootSound
	# wait for the live-fill slice.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

@warning_ignore("unused_parameter")
static func source_point_defense_turret_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the point-defense tick wiring every tick
	# (PointDefenseBuild.updateTile(), PointDefenseTurret.java:62,
	# reads the folded efficiency for its rotation and reload; the
	# turret driver never ticks PointDefenseTurret implementations,
	# so this driver is the point-defense tick): each placed
	# PointDefenseTurret build gets its frame keys refreshed from
	# the live rules, so the frame's cheating flag tracks
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
		if not _is_point_defense_turret_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_point_defense_turret_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_point_defense_turret_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2151 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a segment with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the edelta fold (PointDefenseTurret.java:81-82)
		# follows it. The power consumer counts toward hasConsumers
		# (Block.java:1449, `hasConsumers = consumers.length > 0;`),
		# so a segment does not take the early return. A segment
		# with no power consumer is untouched: the tick models no
		# other consumers yet (the updateTile advance is live,
		# N2229, wired below after the consumption fold), and
		# PointDefenseBuild overrides
		# shouldConsume (PointDefenseTurret.java:105, `public
		# boolean shouldConsume(){` with `return super.
		# shouldConsume() && target != null;`,
		# PointDefenseTurret.java:106) -- N2217 feeds the live
		# gate to the machinery (the pure gate is source_point_
		# defense_turret_should_consume_state, fed the frame);
		# the N2151 RED decision is resolved. The gate reads the
		# enabled flag through super (the BuildingComp default,
		# `return enabled;`, BuildingComp.java:755-756), so the
		# pure gate reads frame["enabled"] too (the RepairTurret
		# N2212 precedent); the outer guard below already runs
		# the machinery only when enabled. productionValid is
		# the canonical true default (SourceBuildingAccessState.
		# production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var gate: Dictionary = source_point_defense_turret_should_consume_state(frame)
			var should_consume: bool = bool(gate.get("should_consume", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_point_defense_turret_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		# N2229: the updateTile advance runs after consumption,
		# like Java's Building.update() (BuildingComp.java:2274
		# updateConsumption(), then the updateTile gate
		# `if(enabled || !block.noUpdateDisabled){` at
		# BuildingComp.java:2276-2277; noUpdateDisabled defaults
		# false, `public boolean noUpdateDisabled = false;`
		# (Block.java:170), so Java runs updateTile even when
		# disabled -- in Java a disabled segment's rotation
		# freezes and its reloadCounter stops charging
		# (efficiency is zeroed by the disabled early return,
		# BuildingComp.java:1954-1957, so edelta() is 0). The
		# port keeps the enabled gate below as a pragmatic
		# choice (the N2195 coordinator-fix precedent): the
		# driver skips the consumption fold when disabled, so
		# the frame efficiency goes stale and running the
		# advance on it would charge rotation/reload from a
		# stale efficiency. The driver-wide
		# disabled-early-return slice (deferred in the N2229
		# register) removes this gate for all families.
		# super.updateTile() is an empty no-op
		# (BuildingComp.java:2010-2012), so the driver owes it
		# nothing. The source delta is Time.delta in ticks:
		# game_source_delta(game, seconds) is seconds * 60 (arc
		# Time.java:26), never raw seconds. timeScale reads
		# live from the sprite meta, default 1.0
		# (BuildingComp.java:98 `private transient float
		# timeScale = 1f, timeScaleDuration;`). Range /
		# bulletDamage / reload come from the segment def
		# constants (180f / 30f / 8f, Blocks.java:3838-3844 --
		# the catalog carries none of them). The building
		# position comes from the origin cell: Building x/y
		# are tile.drawx()/drawy() (BuildingComp.java:124,
		# `set(tile.drawx(), tile.drawy());`), drawx is
		# block.offset + tile.worldx() (Tile.java:175-176) with
		# the block offset `offset = ((size + 1) % 2) * tilesize / 2f;`
		# (Block.java:761) -- 4 for the size-2 segment. The
		# driver passes retarget_tick false and an EMPTY bullet
		# list: no timer helper and no live bullet query exist
		# in the port, so no live retarget happens (the live
		# fill stays deferred); only the pooled clear /
		# rotation / reload / shot lines run live. Coolant is
		# absent (the segment def has no ConsumeCoolant
		# consumer) and blockDamageMultiplier defaults to 1.0.
		if bool(frame.get("enabled", true)):
			var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
			var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
			var advance_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
			var advance_block_size: int = int(block.properties.get("size", 1))
			var advance_block_offset: float = float((advance_block_size + 1) % 2) * source_world_defaults.TILESIZE / 2.0
			var advance_building_x: float = source_block_geometry.tile_drawx_state(advance_cell.x, source_world_defaults.TILESIZE, advance_block_offset)
			var advance_building_y: float = source_block_geometry.tile_drawy_state(advance_cell.y, source_world_defaults.TILESIZE, advance_block_offset)
			var advanced: Dictionary = source_point_defense_turret_update_tile_advance_state(frame, source_delta, time_scale, SOURCE_POINT_DEFENSE_TURRET_RANGE, SOURCE_POINT_DEFENSE_TURRET_BULLET_DAMAGE, SOURCE_POINT_DEFENSE_TURRET_RELOAD, advance_building_x, advance_building_y, [], false)
			frame["target"] = advanced["target"]
			frame["rotation"] = advanced["rotation"]
			frame["reload_counter"] = advanced["reload_counter"]
			frame["target_damage_remaining"] = advanced["target_damage_remaining"]
			frame["target_removed"] = advanced["target_removed"]
			frame["fired"] = advanced["fired"]
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
