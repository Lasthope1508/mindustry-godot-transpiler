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

static func source_game_loop_has_spawns_state(waves: bool, wave_team_core_count: int, attack_mode: bool, spawn_group_count: int) -> Dictionary:
	# GameState.hasSpawns() (GameState.java:68-70) — whether the
	# map has a spawn point for a wave:
	# return rules.waves && ((rules.waveTeam.cores().size > 0 && rules.attackMode) || rules.spawns.size > 0);
	# Pure predicate over the frame inputs; `rules` is the
	# GameState input param, not an owned schema.
	# `rules.waveTeam.cores()` arrives as the frame input
	# wave_team_core_count (the count, not the cores() call --
	# Team.cores() is a later slice) and `rules.spawns` as
	# spawn_group_count. The call-sites (WaveSpawner.playerNear
	# :59 + eachGroundSpawn :126, UnitComp :772,
	# MinimapRenderer :298, OverlayRenderer :203) belong to
	# their own methods, not this one.
	var result := {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_GAME_LOOP_HAS_SPAWNS_STATE,
		"has_spawns": false,
	}
	result["has_spawns"] = waves and ((wave_team_core_count > 0 and attack_mode) or spawn_group_count > 0)
	return result

# GameState.isCampaign() (GameState.java:72-75) — whether the
# game is a campaign:
# /** Note that being in a campaign does not necessarily mean having a sector. */
# public boolean isCampaign(){
#     return rules.sector != null;
# }
# Pure predicate over the frame inputs. `rules` arrives as its
# fields (rules_sector / rules_planet -- the N2454 precedent);
# rules_planet is received for signature parity with
# getPlanet() and to pin the trap, but the body deliberately
# does NOT consult it: unlike getPlanet() (N2454,
# `return rules.sector != null ? rules.sector.planet :
# rules.planet;`), isCampaign() has NO fallback to
# rules.planet -- sector null is false even when the planet
# is non-null. TWIN-REGISTER (N2474, main thread approved
# explicitly): the literal `return rules.sector != null;` is
# also an exact_expr of N2124, which cites it only as
# dependency evidence for unlockedNowHost() and ports no
# isCampaign function.
static func source_game_state_is_campaign_state(rules_sector: Variant, rules_planet: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_GAME_STATE_IS_CAMPAIGN_STATE, "is_campaign": rules_sector != null}

# GameState 9 accessors (GameState.java:56-117) — boss() :56-58,
# getSector() :81-83, getPlanet() :85-87, isEditor() :89-91,
# isPlaying() :98-100, isGame() :103-105, isMenu() :107-109,
# is(State) :111-113, getState() :115-117:
# return teams.bosses.firstOpt();
# return rules.sector;
# return rules.sector != null ? rules.sector.planet : rules.planet;
# return rules.editor;
# return state == State.playing;
# return state != State.menu;
# return state == State.menu;
# return state == astate;
# return state;
# Pure accessors over the frame inputs. `state` is a private Java
# field, so it arrives as state_name ("paused"/"playing"/"menu",
# GameState.java:119-121); `rules` arrives as its fields
# (rules_sector / rules_planet / rules_editor); `teams.bosses`
# arrives as the bosses Array -- firstOpt() is null when the
# bosses seq is empty. getPlanet() reads sector.planet when
# there is a sector, else rules.planet. isPaused() :93-95 is
# NOT here -- N2123 owns it. isCampaign() :73-75 is N2474
# (twin-registered with explicit main-thread approval; the
# literal `return rules.sector != null;` is also an exact_expr
# of N2124, cited there only as dependency evidence).
# hasSector() :77-79 shares the same literal and stays
# unregistered -- it needs its own twin approval. set(State)
# :60-66 waits for the event-bus decision (batch 43 scope §3).
static func source_game_loop_state_accessors_state(state_name: String, astate_name: String, rules_sector: Variant, rules_planet: Variant, rules_editor: bool, bosses: Array) -> Dictionary:
	var result := {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_GAME_LOOP_STATE_ACCESSORS_STATE,
		"boss": null,
		"sector": null,
		"planet": null,
		"is_editor": false,
		"is_playing": false,
		"is_game": false,
		"is_menu": false,
		"is_state": false,
		"state": "",
	}
	if bosses.size() > 0:
		result["boss"] = bosses[0]
	result["sector"] = rules_sector
	if rules_sector != null:
		result["planet"] = rules_sector.get("planet")
	else:
		result["planet"] = rules_planet
	result["is_editor"] = rules_editor
	result["is_playing"] = state_name == "playing"
	result["is_game"] = state_name != "menu"
	result["is_menu"] = state_name == "menu"
	result["is_state"] = state_name == astate_name
	result["state"] = state_name
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
