extends RefCounted
class_name SourceRadarBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")

# The Radar implementation (Radar.java:17, `public class Radar extends Block{`): radar (consumePower 0.6f, Blocks.java:1994, `consumePower(0.6f);`; size 1, fogRadius 34, Blocks.java:1991). Radar extends Block, NOT a factory or crafter, so no existing driver matches it and no frame key exists for it; this driver uses its own family frame key ("source_radar_building", the launch-pad precedent), and this slice adds the radar key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourceRadar* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the updateTile progress advance (Radar.java:68, `progress += edelta() / discoveryTime;`) advances progress by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`), so a radar with no power would never discover -- its progress would sit frozen as if power.status were 1.0.
const SOURCE_RADAR_BUILD_IMPLEMENTATIONS := ["Radar"]
const SOURCE_RADAR_BUILDING_META_KEY := "source_radar_building"
# The single radar def's fog radius (Blocks.java:1991, `fogRadius = 34;`): the fogRadius() base (Radar.java:56, `return fogRadius * progress * smoothEfficiency;`). The catalog carries no fogRadius property, so the driver passes this def constant.
const SOURCE_RADAR_FOG_RADIUS := 34.0
# The discovery time (Radar.java:18, `public float discoveryTime = 60f * 10f;`): the progress advance divisor (Radar.java:68, `progress += edelta() / discoveryTime;`). A full-efficiency radar discovers in 600 ticks.
const SOURCE_RADAR_DISCOVERY_TIME := 60.0 * 10.0

static func _is_radar_build_implementation(implementation: String) -> bool:
	return SOURCE_RADAR_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_radar_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The radar tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (Radar.java:17, `public class Radar extends Block{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# radar skips consumption like Java's updateConsumption
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
	# for this radar (N2125); the tick preserves a disabled
	# radar instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	return {}

static func source_radar_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the radar frame meta key
	# ("source_radar_building"). A Radar sprite gets an
	# empty frame bound; the live-loop tick fills its keys every
	# tick. Any other block, or an already-bound sprite, binds
	# nothing.
	if block == null or not _is_radar_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_RADAR_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_RADAR_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_RADAR_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_radar_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a radar does not take the early return. The updateTile advance follows the folded efficiency: the progress advance (Radar.java:68, `progress += edelta() / discoveryTime;`) advances progress by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`), so a radar with no power would never discover; the smooth-efficiency lerp (Radar.java:61, `smoothEfficiency = Mathf.lerpDelta(smoothEfficiency, efficiency, 0.05f);`) and the total-progress advance (Radar.java:71, `totalProgress += efficiency * edelta();`) follow the folded efficiency too. RadarBuild has NO shouldConsume override, so the BuildingComp default (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`, BuildingComp.java:756) applies; the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent). The radar is its own family (Radar.java:17, `public class Radar extends Block{`; RadarBuild, Radar.java:48, `public class RadarBuild extends Building{`). One def (radar, `consumePower(0.6f);`, Blocks.java:1994; fogRadius 34, Blocks.java:1991; discoveryTime 60f * 10f, Radar.java:18; rotateSpeed 2f, Radar.java:19).
	# Documented limits: (1) power-only first pass -- the radar's power consumer is static (consumePower 0.6f, Blocks.java:1994), so the folded efficiency is the min over the *modeled* consumers (power only). (2) No shouldConsume override -- RadarBuild has NO shouldConsume override, so the BuildingComp default (`return enabled;`, BuildingComp.java:755-757) applies; the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent). (3) updateTile advance done (N2190) -- smoothEfficiency / progress / totalProgress / lastRadius (Radar.java:60-72) advance every tick via source_radar_update_tile_state; the fogControl.forceUpdate call (`Vars.fogControl.forceUpdate(team, this);`, Radar.java:64) waits for its own fog slice (the advance tracks the `if(Math.abs(fogRadius() - lastRadius) >= 0.5f){` condition + the `lastRadius = fogRadius();` write only), and sense / read-write wait for their own slices (draw / drawSelect / icons / drawPlace live since N2427, see (5); canPickup / progress() live since N2479, see (7)). (4) One def -- radar is the only Radar def; fogRadius 34 (Blocks.java:1991) and discoveryTime 60f * 10f (Radar.java:18) are consumed by the N2190 advance; rotateSpeed 2f (Radar.java:19) and the glow defs (glowColor Pal.turretHeat, glowScl 5f, glowMag 0.6f, Radar.java:24-25) are caller-supplied inputs to the N2427 draw pure. (5) Draw rows live (N2427) -- the draw pure (source_radar_draw_state) models draw() (:85-90: base rect + region rect rotated rotateSpeed * totalProgress + additive glow on Layer.blockAdditive, absin Java-exact through the shared helper at the DOUBLED scale glow_scl * 2f) + drawSelect (:80-82: dash circle on the LIVE fogRadius() method radius) + icons() (:37-39: [baseRegion, region], folded into the draw pure -- icons() takes no args and the SSOT schema validator requires non-empty input keys) + drawPlace (:42-46: dash circle on the DEF fogRadius field radius at x * tilesize + offset). Pure-only: the tick never calls draw -- draw is called by the renderer, drawSelect/drawPlace by the UI, icons by the atlas, and the call sites wait for renderer/UI slices. (6) Fog radius accessor live (N2474) -- source_radar_fog_radius_state computes fogRadius() (Radar.java:55-57) as a pure-only accessor; the update_tile advance (N2190) still computes fog_radius_now inline and the draw pure (N2427) still takes fog_radius_live as a caller-supplied input, so the caller wiring that feeds this pure's output into them waits for its own slice (the fogControl.forceUpdate call itself is #123). (7) CanPickup / progress rows live (N2479) -- source_radar_can_pickup_progress_state computes canPickup() (Radar.java:75-77, false unconditionally) + progress() (Radar.java:93-95, returns the build progress field) as a pure-only accessor; the caller (pickup/UI path) reads it, no tick wiring; the frame progress key is advanced + clamped [0, 1] by the N2190 advance (Radar.java:68-69) -- the pure itself does not clamp. (8) Discovery/glow rows live (N2503) -- source_radar_discovery_glow_rows_state returns the static defs (discoveryTime 60f * 10f, rotateSpeed 2f, glowColor Pal.turretHeat, glowScl 5f, glowMag 0.6f, Radar.java:18-19/:24-25) for the radar def, with the class defaults for an unknown def id; the def does NOT override any of them (Blocks.java:1988-1995), so the def row equals the class row. Pure-only: the caller (the N2427 draw pure's caller, the N2190 advance's caller) reads it; the existing pures are unchanged.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_radar_update_tile_state(frame: Dictionary, efficiency: float, edelta: float, source_delta: float, fog_radius: float, discovery_time: float) -> Dictionary:
	# RadarBuild.updateTile() (Radar.java:60-72), in Java order. Build fields (Radar.java:49-52): `public float progress;` `public float lastRadius = 0f;` `public float smoothEfficiency = 1f;` `public float totalProgress;` -- the frame carries them as smooth_efficiency (default 1.0), progress (0.0), total_progress (0.0), last_radius (0.0). (1) The smooth-efficiency lerp FIRST: `smoothEfficiency = Mathf.lerpDelta(smoothEfficiency, efficiency, 0.05f);` (Radar.java:61), with lerpDelta's exact formula `return lerp(fromValue, toValue, clamp(progress * Time.delta));` (arc Mathf.java:430-432) through the shared SourceMathState.source_lerp_delta helper; source_delta is Time.delta in 60fps ticks. (2) The fog-radius change check against the NEW smooth efficiency and the CURRENT progress: `if(Math.abs(fogRadius() - lastRadius) >= 0.5f){` (Radar.java:63), where fogRadius() is `return fogRadius * progress * smoothEfficiency;` (Radar.java:56); the lastRadius write `lastRadius = fogRadius();` (Radar.java:65) is tracked, while the call `Vars.fogControl.forceUpdate(team, this);` (Radar.java:64) waits for its own fog slice -- this function only reports force_update_needed. (3) The progress advance `progress += edelta() / discoveryTime;` (Radar.java:68) with `public float discoveryTime = 60f * 10f;` (Radar.java:18), then the clamp `progress = Mathf.clamp(progress);` (Radar.java:69) to [0, 1] (`return Math.max(Math.min(value, 1f), 0f);`, arc Mathf.java:402-404). (4) The total-progress advance `totalProgress += efficiency * edelta();` (Radar.java:71). edelta is `return efficiency * delta();` (BuildingComp.java:1927-1929), delta is `return Time.delta * timeScale;` (BuildingComp.java:1922-1924) with `private transient float timeScale = 1f, timeScaleDuration;` (BuildingComp.java:98), and Time.delta is `private static Floatp deltaimpl = () -> Math.min(Core.graphics.getDeltaTime() * 60f, 3f);` (arc Time.java:26). The def fogRadius is `fogRadius = 34;` (Blocks.java:1991). The radar is its own family (Radar.java:17, `public class Radar extends Block{`; RadarBuild, Radar.java:48, `public class RadarBuild extends Building{`). One def (radar, `consumePower(0.6f);`, Blocks.java:1994).
	var smooth_efficiency_before: float = float(frame.get("smooth_efficiency", 1.0))
	var progress_before: float = float(frame.get("progress", 0.0))
	var total_progress_before: float = float(frame.get("total_progress", 0.0))
	var last_radius_before: float = float(frame.get("last_radius", 0.0))
	var smooth_efficiency: float = source_math_state.source_lerp_delta(smooth_efficiency_before, efficiency, 0.05, source_delta)
	var fog_radius_now: float = fog_radius * progress_before * smooth_efficiency
	var force_update_needed: bool = absf(fog_radius_now - last_radius_before) >= 0.5
	var last_radius: float = fog_radius_now if force_update_needed else last_radius_before
	var progress: float = clampf(progress_before + edelta / discovery_time, 0.0, 1.0)
	var total_progress: float = total_progress_before + efficiency * edelta
	return {"advance": {"smooth_efficiency": smooth_efficiency, "progress": progress, "total_progress": total_progress, "last_radius": last_radius}, "force_update_needed": force_update_needed}

static func source_radar_fog_radius_state(fog_radius_field: float, progress: float, smooth_efficiency: float) -> Dictionary:
	# RadarBuild.fogRadius() (Radar.java:55-57), the
	# pure-only accessor -- the port's first
	# source-backed fogRadius() (the N2190 advance
	# computes it inline as fog_radius_now and the
	# N2427 draw pure takes it as the caller-supplied
	# fog_radius_live input; neither exposes the
	# accessor itself):
	# `public float fogRadius(){`
	# `return fogRadius * progress * smoothEfficiency;`
	# Java-exact multiplication order: the field times
	# progress times smoothEfficiency, evaluated left
	# to right. The field is:
	# `public int fogRadius = -1;`
	# (Block.java:348); the Radar constructor sets the
	# class default:
	# `fogRadius = 10;`
	# (Radar.java:33 -- a constructor assignment, NOT
	# a field declaration and NOT a def-block
	# assignment) and the single radar def overrides
	# it to:
	# `fogRadius = 34;`
	# (Blocks.java:1991). No other Radar def exists,
	# so no other def overrides the field; the pure
	# takes the field as an input so either value
	# works. The build fields are:
	# `public float progress;`
	# `public float lastRadius = 0f;`
	# `public float smoothEfficiency = 1f;`
	# (Radar.java:49-51) -- progress +
	# smoothEfficiency ride the frame under the same
	# key names (progress / smooth_efficiency) since
	# the N2190 advance, and lastRadius rides as
	# last_radius. The updateTile gate:
	# `if(Math.abs(fogRadius() - lastRadius) >= 0.5f){`
	# (Radar.java:63) with the write:
	# `lastRadius = fogRadius();`
	# (Radar.java:65) is what consumes this pure's
	# value. Wiring note for the next agent: this pure
	# computes the SAME quantity the update_tile pure
	# computes inline as fog_radius_now (N2190) and
	# the draw pure takes as fog_radius_live (N2427)
	# -- the caller wires this pure's output into them
	# later; pure-only here, no tick wiring (the tick
	# never calls this pure). canPickup :75-77 +
	# progress() :93-95 are live since N2479 and
	# the forceUpdate CALL
	# (`Vars.fogControl.forceUpdate(team, this);`,
	# Radar.java:64) is #123 -- not in scope.
	var fog_radius: float = fog_radius_field * progress * smooth_efficiency
	return {"fog_radius": fog_radius}

static func source_radar_can_pickup_progress_state(progress: float) -> Dictionary:
	# RadarBuild.canPickup() (Radar.java:75-77) +
	# progress() (Radar.java:93-95), the pure-only
	# accessors -- the port's first source-backed
	# canPickup / progress() (the N2190 advance
	# tracks the progress FIELD on the frame but
	# neither accessor itself):
	# `public boolean canPickup(){`
	# `return false;`
	# Unconditionally false, whatever the progress
	# -- the base BuildingComp.canPickup() returns
	# block.canPickup (BuildingComp.java:1838-1840,
	# default true, Block.java:176), so the
	# override is what makes a radar unpickupable.
	# `public float progress(){`
	# `return progress;`
	# The build field:
	# `public float progress;`
	# (Radar.java:49) -- tracked on the frame under
	# the same key name (progress) since the N2190
	# advance; the base BuildingComp.progress()
	# returns 0f (BuildingComp.java:617-619), so
	# the override is what exposes the discovery
	# fraction. The field is advanced by:
	# `progress += edelta() / discoveryTime;`
	# (Radar.java:68) and clamped by:
	# `progress = Mathf.clamp(progress);`
	# (Radar.java:69) to [0, 1] -- the clamp lives
	# in updateTile, NOT in progress(), so this
	# pure itself does NOT clamp: it returns its
	# input as-is. Wiring note for the next agent:
	# the caller (pickup/UI path) reads this pure;
	# pure-only here, no tick wiring (the tick
	# never calls this pure). The forceUpdate CALL
	# (`Vars.fogControl.forceUpdate(team, this);`,
	# Radar.java:64) is #123 and the read/write
	# rows (Radar.java:98-110) are #32 -- neither
	# is in scope.
	return {"can_pickup": false, "progress": progress}

static func source_radar_discovery_glow_rows_state(def_id: String) -> Dictionary:
	# The discovery/glow static defs (the VERIFICATION
	# slice: the values are already constants in this
	# driver's header -- the N2304 / N2442 / N2489 /
	# N2490 / N2498 precedent): the def's
	# discoveryTime / rotateSpeed / glowColor /
	# glowScl / glowMag for radar, the single Radar
	# def (Blocks.java:1988-1995), with the CLASS
	# defaults for an unknown def id (the N2304
	# fallback precedent). The class fields (each
	# exact expr on ONE comment line, the N2148
	# lesson):
	# `public float discoveryTime = 60f * 10f;`
	# `public float rotateSpeed = 2f;`
	# `public Color glowColor = Pal.turretHeat;`
	# `public float glowScl = 5f, glowMag = 0.6f;`
	# (Radar.java:18-19, :24-25). Radar extends Block
	# (`public class Radar extends Block{`,
	# Radar.java:17). The def block:
	# `radar = new Radar("radar"){{`
	# (Blocks.java:1988) sets only
	# `fogRadius = 34;`
	# (Blocks.java:1991) + consumers
	# (`consumePower(0.6f);`, Blocks.java:1994) --
	# it does NOT override discoveryTime /
	# rotateSpeed / glow, so the def row EQUALS the
	# class row here; the class row is the fallback
	# for an unknown def id. The glow color rides
	# as a String TOKEN ("Pal.turretHeat", the
	# N2469 token precedent -- SSOT has no Color
	# type, the MendProjector precedent):
	# `turretHeat = Color.valueOf("ab3400"),`
	# (Pal.java:52 -- 6-digit hex, so alpha 1.0);
	# the alpha Java reads (glowColor.a) rides as
	# the separate glow_alpha float input of the
	# N2427 draw pure. The consumers are already
	# live and UNCHANGED: the N2190 advance
	# divides by discoveryTime
	# (`progress += edelta() / discoveryTime;`,
	# Radar.java:68 -- a full-efficiency radar
	# discovers in 600 ticks) and the N2427 draw
	# pure models the additive glow
	# (`Drawf.additive(glowRegion, glowColor, glowColor.a * (1f - glowMag + Mathf.absin(glowScl, glowMag)), x, y, rotateSpeed * totalProgress, Layer.blockAdditive);`,
	# Radar.java:89) with rotateSpeed / glow as
	# caller-supplied inputs. Pure-only: the
	# caller (the N2427 draw pure's caller, the
	# N2190 advance's caller) reads it; the
	# existing pures are unchanged.
	if def_id == "radar":
		return {
			"discovery_time": 60.0 * 10.0,
			"rotate_speed": 2.0,
			"glow_color": "Pal.turretHeat",
			"glow_scl": 5.0,
			"glow_mag": 0.6,
		}
	return {
		"discovery_time": 60.0 * 10.0,
		"rotate_speed": 2.0,
		"glow_color": "Pal.turretHeat",
		"glow_scl": 5.0,
		"glow_mag": 0.6,
	}

static func source_radar_draw_state(x_value: float, y_value: float, rotate_speed: float, total_progress: float, glow_color: String, glow_alpha: float, glow_mag: float, glow_scl: float, time_value: float, fog_radius: float, fog_radius_live: float, offset: float, size_value: int, tile_x: int, tile_y: int) -> Dictionary:
	# The draw rows (RadarBuild.draw(), Radar.java:85-90),
	# the pure draw-call dict -- the port never draws for
	# real (the N2396 MassDriver precedent: the pure
	# returns the draw calls as data). Java draws, in
	# order (each exact expr on ONE comment line, the
	# N2148 lesson):
	# `Draw.rect(baseRegion, x, y);`
	# `Draw.rect(region, x, y, rotateSpeed * totalProgress);`
	# `Drawf.additive(glowRegion, glowColor, glowColor.a * (1f - glowMag + Mathf.absin(glowScl, glowMag)), x, y, rotateSpeed * totalProgress, Layer.blockAdditive);`
	# The glow is the 7-arg additive overload:
	# `public static void additive(TextureRegion region, Color color, float alpha, float x, float y, float rotation, float layer){`
	# (Drawf.java:183) -- the pure models the CALL args
	# (alpha = glowColor.a * (1f - glowMag + absin)),
	# not the callee internals (Drawf.java:184-191
	# re-applies color.a inside). The glow absin is the
	# 2-arg form:
	# `return absin(Time.time, scl, mag);`
	# (Mathf.java:74-75, arc) over the 3-arg form:
	# `return (sin(in, scl * 2f, mag) + mag) / 2f;`
	# (Mathf.java:78-80, arc) -- Java-exact through the
	# shared helper at the DOUBLED scale (helper(v, s)
	# == Java absin(v, s / 2f), the N2372/N2382 lesson),
	# so the pure passes glow_scl * 2f (10f at the class
	# default glowScl 5f). drawSelect (Radar.java:80-82)
	# dashes the LIVE radius:
	# `Drawf.dashCircle(x, y, fogRadius() * tilesize, Pal.accent);`
	# where fogRadius() is the method:
	# `public float fogRadius(){`
	# `return fogRadius * progress * smoothEfficiency;`
	# (Radar.java:55-57) -- while drawPlace
	# (Radar.java:42-46) dashes the DEF radius:
	# `public void drawPlace(int x, int y, int rotation, boolean valid){`
	# `super.drawPlace(x, y, rotation, valid);`
	# `Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, fogRadius * tilesize, Pal.accent);`
	# over the FIELD `public int fogRadius = -1;`
	# (Block.java:348, def 34, Blocks.java:1991). Method
	# vs field, verified first: they differ whenever
	# progress * smoothEfficiency < 1, so the pure takes
	# BOTH radii as separate inputs (fog_radius the def
	# field, fog_radius_live the method value the N2190
	# advance already computes as fog_radius_now). The
	# dash circle itself is:
	# `public static void dashCircle(float x, float y, float rad, Color color){`
	# (Drawf.java:398). icons() (Radar.java:37-39):
	# `public TextureRegion[] icons(){`
	# `return new TextureRegion[]{baseRegion, region};`
	# rides this pure as icon_regions -- icons() takes
	# no args and the SSOT schema validator requires
	# non-empty input keys (the N2396 precedent).
	# outlineIcon = true (Radar.java:30) is a Block flag
	# consumed by the icon OUTLINE machinery
	# (SourceBlockIconState), not by icons() itself, so
	# it is not part of this pure. The defs are
	# `public float rotateSpeed = 2f;`
	# `public Color glowColor = Pal.turretHeat;`
	# `public float glowScl = 5f, glowMag = 0.6f;`
	# `public @Load("@-base") TextureRegion baseRegion;`
	# `public @Load("@-glow") TextureRegion glowRegion;`
	# (Radar.java:19/21-25, no def override -- the radar
	# def, Blocks.java:1989-1995, sets only
	# `fogRadius = 34;` / consumers; the class fogRadius
	# default is 10, Radar.java:31). glowColor is
	# Pal.turretHeat:
	# `turretHeat = Color.valueOf("ab3400"),`
	# (Pal.java:52 -- 6-digit hex, so alpha 1.0). The
	# color rides as a String token (SSOT has no Color
	# type, the MendProjector precedent), so the alpha
	# Java reads (glowColor.a) rides as the separate
	# glow_alpha float input. tilesize is the Java
	# constant 8.0:
	# `public static final int tilesize = 8;`
	# (Vars.java:135 -- NEVER the game tile_size 32,
	# the N2375 lesson). The offset is the Block
	# offset:
	# `offset = ((size + 1) % 2) * tilesize / 2f;`
	# (Block.java:761 -- 0 for the size-1 radar,
	# `public int size = 1;`, Block.java:215),
	# caller-supplied because Block.offset is set at
	# load time; the pure records size + offset in the
	# place call. super.drawPlace is Block.drawPlace
	# (drawPotentialLinks + drawOverlay,
	# SourceBlockDrawState) and is NOT modeled here:
	# the pure records that the super call happens, not
	# its content (the BaseTurret draw_place
	# precedent). drawPlace takes tile coords (ints)
	# separately from the world coords: the building
	# does not exist yet at placement time. Time.time
	# is caller-supplied as time_value (the N2396/N2372
	# convention -- draw never runs in the tick, so the
	# tick never stamps it). Pure-only: the tick never
	# calls draw -- draw is called by the renderer,
	# drawSelect/drawPlace by the UI, icons by the
	# atlas, and the call sites wait for renderer/UI
	# slices.
	var tile_size: float = 8.0
	var rotation: float = rotate_speed * total_progress
	var glow_absin: float = source_math_state.source_absin(time_value, glow_scl * 2.0, glow_mag)
	var glow_alpha_value: float = glow_alpha * (1.0 - glow_mag + glow_absin)
	var base_call: Dictionary = {
		"call": "Draw.rect(baseRegion, x, y);",
		"region": "baseRegion",
		"x": x_value,
		"y": y_value,
	}
	var region_call: Dictionary = {
		"call": "Draw.rect(region, x, y, rotateSpeed * totalProgress);",
		"region": "region",
		"x": x_value,
		"y": y_value,
		"rotation": rotation,
	}
	var glow_call: Dictionary = {
		"call": "Drawf.additive(glowRegion, glowColor, glowColor.a * (1f - glowMag + Mathf.absin(glowScl, glowMag)), x, y, rotateSpeed * totalProgress, Layer.blockAdditive);",
		"region": "glowRegion",
		"color": glow_color,
		"alpha": glow_alpha_value,
		"absin": glow_absin,
		"x": x_value,
		"y": y_value,
		"rotation": rotation,
		"z": "Layer.blockAdditive",
	}
	var select_call: Dictionary = {
		"call": "Drawf.dashCircle(x, y, fogRadius() * tilesize, Pal.accent);",
		"x": x_value,
		"y": y_value,
		"radius": fog_radius_live * tile_size,
		"color": "Pal.accent",
	}
	var place_call: Dictionary = {
		"call": "Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, fogRadius * tilesize, Pal.accent);",
		"super_call": "super.drawPlace(x, y, rotation, valid);",
		"tile_x": tile_x,
		"tile_y": tile_y,
		"center_x": float(tile_x) * tile_size + offset,
		"center_y": float(tile_y) * tile_size + offset,
		"radius": fog_radius * tile_size,
		"color": "Pal.accent",
		"size": size_value,
		"offset": offset,
	}
	return {
		"rotation": rotation,
		"glow_absin": glow_absin,
		"glow_alpha_value": glow_alpha_value,
		"base_call": base_call,
		"region_call": region_call,
		"glow_call": glow_call,
		"select_call": select_call,
		"place_call": place_call,
		"icon_regions": ["baseRegion", "region"],
	}

static func source_radar_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the radar tick wiring every
	# tick (RadarBuild.updateTile(), Radar.java:60,
	# advances progress by the progress advance (Radar.java:68, `progress += edelta() / discoveryTime;`), so the progress advance follows the folded efficiency; no placed-buildings driver ticks Radar blocks, so this driver is the placed-radar tick): each placed Radar build gets its frame keys refreshed from the live rules, so the frame's cheating flag tracks team.rules().cheat and the consumption machinery skips consumption for a cheating team. The frame is bound at placement; a sprite that somehow lacks one gets it bound here instead of crashing the loop.
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
		if not _is_radar_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_radar_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_radar_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a radar with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the progress advance (Radar.java:68)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a radar does not take the early return. A radar with no power consumer skips the consumption fold: the tick models no other consumers yet, and RadarBuild has NO shouldConsume override -- the BuildingComp default (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`, BuildingComp.java:756) applies, so the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent). productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()). The updateTile advance (N2190) runs below for every ticked radar, after the fold, following the folded frame efficiency.
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var should_consume: bool = bool(frame.get("enabled", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_radar_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		# The updateTile advance (N2190) runs every tick for each
		# placed radar, after the consumption fold, in Java order
		# (Radar.java:60-72): the driver passes seconds * TICK_RATE
		# as the source delta (the N2093 pump precedent; arc
		# Time.java:26 scales the frame delta to 60fps ticks) and
		# edelta = efficiency * delta with timeScale 1f
		# (BuildingComp.java:98, the default). The advance follows
		# the folded frame efficiency, 1.0 before the first fold
		# (BuildingComp.java:1965, "assume efficiency is 1"). The
		# fogRadius def constant (34.0, Blocks.java:1991) stands in
		# for the catalog, which carries no fogRadius property.
		var source_delta: float = seconds * source_time_defaults.TICK_RATE
		var advance_efficiency: float = float(frame.get("efficiency", 1.0))
		var advance_edelta: float = advance_efficiency * source_delta
		var advance: Dictionary = source_radar_update_tile_state(frame, advance_efficiency, advance_edelta, source_delta, SOURCE_RADAR_FOG_RADIUS, SOURCE_RADAR_DISCOVERY_TIME)
		var advanced: Dictionary = advance.get("advance", {})
		frame["smooth_efficiency"] = advanced.get("smooth_efficiency", frame.get("smooth_efficiency", 1.0))
		frame["progress"] = advanced.get("progress", frame.get("progress", 0.0))
		frame["total_progress"] = advanced.get("total_progress", frame.get("total_progress", 0.0))
		frame["last_radius"] = advanced.get("last_radius", frame.get("last_radius", 0.0))
		frame["force_update_needed"] = advance.get("force_update_needed", false)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
