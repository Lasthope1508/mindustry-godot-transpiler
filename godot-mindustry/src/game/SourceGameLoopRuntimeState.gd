extends RefCounted
class_name SourceGameLoopRuntimeState

const source_input_defaults := preload("res://src/game/SourceInputDefaults.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

# GameState.isPaused() (GameState.java:93-95): `return state ==
# State.paused;` (the states are paused, playing, menu,
# GameState.java:119-121; the state is set with GameState.set(State),
# GameState.java:60-62). The port keeps the pause as the game's
# `paused` flag. A null game has no pause state, so it reads unpaused.
static func source_game_loop_paused_state(game: Object) -> Dictionary:
	var result := {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_GAME_LOOP_PAUSED_STATE,
		"paused": false,
	}
	if game == null:
		return result
	# Object.get() takes at most 1 argument (the GDScript trap: a
	# 2-arg get() only exists on Dictionary); a game without the
	# flag reads null, which is unpaused like the Java default.
	result["paused"] = bool(game.get("paused"))
	return result

# Logic.isWaitingWave() (Logic.java:605-607) — whether the wave timer
# is paused due to enemies (javadoc :604):
# return (state.rules.waitEnemies || (state.wave >= state.rules.winWave && state.rules.winWave > 0)) && state.enemies > 0;
# Pure predicate over the frame inputs; `state.enemies` is read as-is
# and never counted here (the count leg lives in Logic.update, a
# later slice). The call-site `if(!isWaitingWave())`
# (Logic.java:577, inside update()) belongs to the update()
# driver-tick slice, not this one.
static func source_game_loop_is_waiting_wave_state(wait_enemies: bool, wave: int, win_wave: int, enemies: int) -> Dictionary:
	var result := {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_GAME_LOOP_IS_WAITING_WAVE_STATE,
		"waiting": false,
	}
	result["waiting"] = (wait_enemies or (wave >= win_wave and win_wave > 0)) and enemies > 0
	return result

# Logic.checkCampaignStats() (Logic.java:251-253) — whether
# campaign stats should be recorded:
# return state.isCampaign() && !net.client();
# Pure predicate over the frame inputs; `state.isCampaign()`
# and `net.client()` are read as-is and never resolved here
# (their live reads are later slices). The call-sites
# `if(checkCampaignStats()){` in the Logic ctor
# (Logic.java:163, :196, :206, :212, :223, :232, :239, :245)
# belong to the 16 handler ctor slices, not this one.
static func source_game_loop_check_campaign_stats_state(is_campaign: bool, is_client: bool) -> Dictionary:
	var result := {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_GAME_LOOP_CHECK_CAMPAIGN_STATS_STATE,
		"campaign_stats": false,
	}
	result["campaign_stats"] = is_campaign and not is_client
	return result

# Logic.checkOverlappingPlans() (Logic.java:255-266) — remove
# build plans that overlap the block just placed on a tile:
# TeamData data = team.data();
# Iterator<BlockPlan> it = data.plans.iterator();
# var bounds = tile.block().bounds(tile.x, tile.y, Tmp.r1);
# while(it.hasNext()){
# BlockPlan b = it.next();
# if(bounds.overlaps(b.block.bounds(b.x, b.y, Tmp.r2))){
# b.removed = true;
# it.remove();
# Pure transform over the frame inputs. BlockPlan
# (Teams.java:492-496) is {x, y, rotation, block, config,
# removed}; plans arrive as Dictionaries with "x", "y",
# "bounds" (Rect2) and "removed" (bool). Tmp.r1 / Tmp.r2
# are shared temp rects and are NOT ported — bounds arrive
# as data: tile["bounds"] is the tile block's bounds rect
# and each plan["bounds"] is that plan's block bounds rect.
# Overlapping plans are marked removed = true and listed
# under "removed_plans"; the rest stay under "kept_plans".
# The call-sites `checkOverlappingPlans(event.team,
# event.tile);` (Logic.java:55) and
# `checkOverlappingPlans(e.build.team, e.build.tile);`
# (Logic.java:65) in the Logic ctor belong to the 16
# handler ctor slices, not this one.
static func source_game_loop_check_overlapping_plans_state(team_data: Dictionary, tile: Dictionary) -> Dictionary:
	var result := {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_GAME_LOOP_CHECK_OVERLAPPING_PLANS_STATE,
		"removed_plans": [],
		"kept_plans": [],
	}
	var tile_bounds: Rect2 = tile.get("bounds", Rect2())
	var plans: Array = team_data.get("plans", [])
	for plan in plans:
		var entry: Dictionary = (plan as Dictionary).duplicate()
		var plan_bounds: Rect2 = entry.get("bounds", Rect2())
		if tile_bounds.intersects(plan_bounds):
			entry["removed"] = true
			result["removed_plans"].append(entry)
		else:
			result["kept_plans"].append(entry)
	return result

static func ready(game: Object) -> void:
	# Vars.headless (Vars.java:208-209) via DisplayServer
	# (decision 2026-11-17 ~12:56, Option 1): a headless display
	# server means the game runs on a headless server
	# (ServerLauncher.java:45 sets headless = true). Stamped
	# first so every load step below sees the same value the
	# ambient gate (N657) reads through SourceGameHeadlessState.
	game.set("headless", DisplayServer.get_name() == "headless")
	source_input_defaults.ensure_input_map()
	game.call("load_config")
	game.call("load_content_registry")
	game.call("load_textures")
	game.call("bind_nodes")
	game.call("build_block_palette")
	game.call("build_world")
	game.call("build_hud")
	game.call_deferred("apply_world_viewport_fit")

static func process_tick(game: Object, delta: float, time_runtime: Variant) -> void:
	# Logic.update (Logic.java:507): `if(!state.isPaused())` gates the
	# whole game update — the tick, Time.update and every sim run only
	# while unpaused, so a paused game advances nothing at all.
	if bool(source_game_loop_paused_state(game).get("paused", false)):
		return
	if time_runtime != null:
		time_runtime.update(delta)
	var tick_methods := [
		"simulate_block_time_scales",
		"simulate_factory",
		"simulate_mend_projectors",
		"simulate_overdrive_projectors",
		"simulate_turrets",
		"simulate_bullets",
		"simulate_enemy_units",
		"update_camera",
		"update_hud",
	]
	for method_name in tick_methods:
		if method_name == "update_hud":
			game.call(method_name)
		else:
			game.call(method_name, delta)
