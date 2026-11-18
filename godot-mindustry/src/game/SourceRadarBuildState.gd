extends RefCounted
class_name SourceRadarBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")

# The Radar implementation (Radar.java:17, `public class Radar extends Block{`): radar (consumePower 0.6f, Blocks.java:1994, `consumePower(0.6f);`; size 1, fogRadius 34, Blocks.java:1991). Radar extends Block, NOT a factory or crafter, so no existing driver matches it and no frame key exists for it; this driver uses its own family frame key ("source_radar_building", the launch-pad precedent), and this slice adds the radar key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourceRadar* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the updateTile progress advance (Radar.java:68, `progress += edelta() / discoveryTime;`) advances progress by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`), so a radar with no power would never discover -- its progress would sit frozen as if power.status were 1.0.
const SOURCE_RADAR_BUILD_IMPLEMENTATIONS := ["Radar"]
const SOURCE_RADAR_BUILDING_META_KEY := "source_radar_building"
# The per-def discovery time is 600.0 (Radar.java:18, `public float discoveryTime = 60f * 10f;`) and the per-def fog radius is 34.0 (Blocks.java:1991, `fogRadius = 34;`, overriding the class default `fogRadius = 10;`, Radar.java:33); the catalog carries neither, so the driver passes these constants (the N2212 per-def-param precedent).
const SOURCE_RADAR_DISCOVERY_TIME := 600.0
const SOURCE_RADAR_FOG_RADIUS := 34.0

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
	# Documented limits: (1) power-only first pass -- the radar's power consumer is static (consumePower 0.6f, Blocks.java:1994), so the folded efficiency is the min over the *modeled* consumers (power only). (2) No shouldConsume override -- RadarBuild has NO shouldConsume override, so the BuildingComp default (`return enabled;`, BuildingComp.java:755-757) applies; the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent). (3) No updateTile advance -- smoothEfficiency / fogRadius forceUpdate / progress / totalProgress (Radar.java:60-72) wait for their own slices; the proof carries no progress/smooth-efficiency/fog-radius keys, the progress advance (Radar.java:68) is what the efficiency keys prove. (4) One def -- radar is the only Radar def; fogRadius 34 (Blocks.java:1991) and discoveryTime 60f * 10f (Radar.java:18) wait for their own verification slice.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_radar_fog_radius_state(frame: Dictionary, fog_radius: float) -> Dictionary:
	# RadarBuild.fogRadius() (Radar.java:55, `public float fogRadius(){` with `return fogRadius * progress * smoothEfficiency;`, Radar.java:56): the live fog radius is the def fogRadius scaled by the discovery progress and the smoothed efficiency -- 0.0 before discovery (progress 0.0) and the full def radius at progress 1.0 and smooth efficiency 1.0. The def fogRadius is 34 (Blocks.java:1991, `fogRadius = 34;`), overriding the class default 10 (Radar.java:33, `fogRadius = 10;`); fog_radius is an explicit per-def param (the N2212 per-def-param precedent) because the catalog carries no fogRadius. The frame carries `progress` (absent defaults to 0.0 -- `public float progress;`, Radar.java:49) and `smooth_efficiency` (absent defaults to 1.0 -- the Java field init, Radar.java:51, `public float smoothEfficiency = 1f;`). The accessor is what updateTile reads for its force-update check (Radar.java:63, `if(Math.abs(fogRadius() - lastRadius) >= 0.5f){`) and what drawSelect draws (Radar.java:80-82, `Drawf.dashCircle(x, y, fogRadius() * tilesize, Pal.accent);`); the updateTile advance (N2248) and the draw rows wait for their own slices, so no driver tick line lands here -- the accessor is the read its callers share. One def (radar, Radar.java:17, `public class Radar extends Block{`; RadarBuild, Radar.java:48, `public class RadarBuild extends Building{`).
	var progress: float = float(frame.get("progress", 0.0))
	var smooth_efficiency: float = float(frame.get("smooth_efficiency", 1.0))
	var fog_radius_value: float = fog_radius * progress * smooth_efficiency
	return {"fog_radius": fog_radius_value}

static func source_radar_progress_state(frame: Dictionary) -> Dictionary:
	# RadarBuild.progress() (Radar.java:93, `public float progress(){` with `return progress;`, Radar.java:94) overrides the base BuildingComp.progress() for Radar: the discovery-progress accessor returns the frame's progress (the Java field `public float progress;`, Radar.java:49, init 0.0), advanced by updateTile (Radar.java:68, `progress += edelta() / discoveryTime;`, clamped Radar.java:69, `progress = Mathf.clamp(progress);`, N2248) and read by fogRadius() (Radar.java:56, `return fogRadius * progress * smoothEfficiency;`, N2249). The logic-dispatch hook that reads it waits for its own slice (the N2255 sense precedent), and the write/read persistence (Radar.java:101, `write.f(progress);` / Radar.java:108, `progress = read.f();`) is its own slice -- so no driver tick line lands here: the accessor is the read its callers share. One def (radar, Radar.java:17, `public class Radar extends Block{`; RadarBuild, Radar.java:48, `public class RadarBuild extends Building{`).
	return {"progress": float(frame.get("progress", 0.0))}

static func source_radar_icons_state(base_region: Variant, region: Variant) -> Dictionary:
	# Radar.icons() (Radar.java:36-39):
	# @Override
	# public TextureRegion[] icons(){
	# return new TextureRegion[]{baseRegion, region};
	# }
	# This slice pins ONLY the override's two-element return array, base first. baseRegion is the block's own base field (Radar.java:21): `public @Load("@-base") TextureRegion baseRegion;` -- loaded as name + "-base". region is the inherited block region (Block.java:427): `public TextureRegion region;` -- the block's own region, the block name. The Block.icons() base (`protected TextureRegion[] icons(){`, Block.java:976-980, the variants/teamRegion fold) is NOT this slice: Radar overrides it. The getGeneratedIcons cache (`public TextureRegion[] getGeneratedIcons(){`, Block.java:986, `return generatedIcons == null ? (generatedIcons = icons()) : generatedIcons;`, Block.java:987) is likewise deferred -- only the override's return array is pinned (the N2227 RepairTurret.icons() precedent, itself following the N1232 TractorBeamTurret.icons() precedent: "TextureRegion internals and inherited region loading remain deferred; explicit inputs carry baseRegion and region field values", pinned as the identity pure function source_tractor_beam_turret_icons_state).
	# The class (Radar.java:17): `public class Radar extends Block{`.
	# Per-def region ids: radar ("radar", Blocks.java:1988) -> ["radar-base", "radar"].
	# There is no driver tick line: icons() is a load-time region accessor, not a per-tick write (the N2217 read/write + N2224 setStats lifecycle precedent).
	var icons: Array = [base_region, region]
	return {"icons": icons}

static func source_radar_update_tile_state(frame: Dictionary, delta: float, discovery_time: float, fog_radius: float) -> Dictionary:
	# RadarBuild.updateTile advances the radar's discovery state every tick (Radar.java:60, `public void updateTile(){`): `smoothEfficiency = Mathf.lerpDelta(smoothEfficiency, efficiency, 0.05f);` (Radar.java:61) lerps the smoothed efficiency toward the folded efficiency; `if(Math.abs(fogRadius() - lastRadius) >= 0.5f){` (Radar.java:63) with `Vars.fogControl.forceUpdate(team, this);` (Radar.java:64) and `lastRadius = fogRadius();` (Radar.java:65) forces a fog update when the live fog radius moved by half a tile or more; `progress += edelta() / discoveryTime;` (Radar.java:68) with `progress = Mathf.clamp(progress);` (Radar.java:69) advances discovery by edelta() over the discovery time, clamped to [0, 1]; `totalProgress += efficiency * edelta();` (Radar.java:71) tracks the efficiency-weighted tick count. edelta() is efficiency * delta (BuildingComp.java:1927-1929, `public float edelta(){` with `return efficiency * delta();`, and `public float delta(){` with `return Time.delta * timeScale;`, BuildingComp.java:1922-1923 -- timeScale is 1 by default and the port passes the raw tick seconds, the N2190 driver convention). The fog radius read is fogRadius() (Radar.java:55, `public float fogRadius(){` with `return fogRadius * progress * smoothEfficiency;`, Radar.java:56): the def fogRadius is 34 (Blocks.java:1991, `fogRadius = 34;`), overriding the class default 10 (Radar.java:33, `fogRadius = 10;`). The discovery time is 600f (Radar.java:18, `public float discoveryTime = 60f * 10f;`). The frame carries `smooth_efficiency` (absent defaults to 1.0 -- the Java field init, Radar.java:51, `public float smoothEfficiency = 1f;`), `progress` (absent defaults to 0.0 -- `public float progress;`, Radar.java:49), `last_radius` (absent defaults to 0.0 -- `public float lastRadius = 0f;`, Radar.java:50), `total_progress` (absent defaults to 0.0 -- `public float totalProgress;`, Radar.java:52) and `efficiency` (absent defaults to 0.0 -- the transient field default, BuildingComp.java:85, `transient float efficiency;`, the N2192/N2204 precedent). The fog-radius check uses the NEW smoothed efficiency and the OLD progress (Java order: the lerp :61 runs before the check :63-66, the progress advance :68 runs after). `force_update` is the observable flag: the actual FogControl call (`public void forceUpdate(Team team, Building build){`, FogControl.java:177) waits for its own fog slice -- the port has no fog system to call into. A disabled radar never advances because updateConsumption zeroes the efficiencies first (`if(!enabled){` with `potentialEfficiency = efficiency = optionalEfficiency = 0f;`, BuildingComp.java:1954-1955), so the driver zeroes efficiency before the call (the N2204 precedent). One def (radar, Radar.java:17, `public class Radar extends Block{`; RadarBuild, Radar.java:48, `public class RadarBuild extends Building{`). The lerp is the port's frame-rate independent delta-scaled helper (SourceMathState.source_lerp_delta, the SourceBlockProducerBuildUpdateState precedent; arc Mathf.lerpDelta is `return lerp(fromValue, toValue, clamp(progress * Time.delta));` and Mathf.clamp one-arg clamps to [0, 1], the GDScript spelling is clampf(value, 0.0, 1.0)).
	var smooth_efficiency: float = float(frame.get("smooth_efficiency", 1.0))
	var efficiency: float = float(frame.get("efficiency", 0.0))
	smooth_efficiency = source_math_state.source_lerp_delta(smooth_efficiency, efficiency, 0.05, delta)
	var progress: float = float(frame.get("progress", 0.0))
	var fog_radius_value: float = fog_radius * progress * smooth_efficiency
	var last_radius: float = float(frame.get("last_radius", 0.0))
	var force_update: bool = absf(fog_radius_value - last_radius) >= 0.5
	if force_update:
		last_radius = fog_radius_value
	var edelta: float = efficiency * delta
	progress += edelta / discovery_time
	progress = clampf(progress, 0.0, 1.0)
	var total_progress: float = float(frame.get("total_progress", 0.0))
	total_progress += efficiency * edelta
	return {"smooth_efficiency": smooth_efficiency, "fog_radius": fog_radius_value, "force_update": force_update, "last_radius": last_radius, "progress": progress, "total_progress": total_progress}

@warning_ignore("unused_parameter")
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
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a radar does not take the early return. A radar with no power consumer is untouched: the tick models no other consumers yet (the updateTile advance waits for its own slice), and RadarBuild has NO shouldConsume override -- the BuildingComp default (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`, BuildingComp.java:756) applies, so the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent). productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
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
		# The updateTile advance runs for every ticked radar, after the consumption block (updateConsumption runs BEFORE updateTile in Java, Radar.java:60, `public void updateTile(){`, so the advance reads this tick's freshly stamped efficiency): a disabled radar never advances, so its efficiency is zeroed first (`if(!enabled){` with `potentialEfficiency = efficiency = optionalEfficiency = 0f;`, BuildingComp.java:1954-1955), and the force_update flag is stamped for the future fog-control slice (the N2204 LaunchPad precedent). The per-def discoveryTime is 600.0 (Radar.java:18, `public float discoveryTime = 60f * 10f;`) and fogRadius is 34.0 (Blocks.java:1991, `fogRadius = 34;`, overriding the class default `fogRadius = 10;`, Radar.java:33).
		if not bool(frame.get("enabled", true)):
			frame["efficiency"] = 0.0
		var advanced: Dictionary = source_radar_update_tile_state(frame, seconds, SOURCE_RADAR_DISCOVERY_TIME, SOURCE_RADAR_FOG_RADIUS)
		frame["smooth_efficiency"] = advanced.get("smooth_efficiency", 1.0)
		frame["fog_radius"] = advanced.get("fog_radius", 0.0)
		frame["force_update"] = advanced.get("force_update", false)
		frame["last_radius"] = advanced.get("last_radius", 0.0)
		frame["progress"] = advanced.get("progress", 0.0)
		frame["total_progress"] = advanced.get("total_progress", 0.0)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
