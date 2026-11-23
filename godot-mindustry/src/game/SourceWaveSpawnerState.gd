extends RefCounted
class_name SourceWaveSpawnerState


const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")


static func source_wave_spawner_count_spawns_state(spawns: Array) -> Dictionary:
	# WaveSpawner.countSpawns() (WaveSpawner.java:49-51): the 1 body expr
	# only -- `return spawns.size;` (:50). `spawns` is the
	# WaveSpawner field `private Seq<Tile> spawns = new Seq<>(false);`
	# (WaveSpawner.java:26); GD takes it as an Array input and does
	# not recompute it from the world (the world-tiles scan belongs
	# to reset(), WaveSpawner.java:217-227, a later slice).
	# spawnEnemies() (WaveSpawner.java:62-110) is NOT in this slice.
	return {"count": spawns.size()}


static func source_wave_spawner_is_spawning_state(spawning: bool, is_client: bool) -> Dictionary:
	# WaveSpawner.isSpawning() (WaveSpawner.java:213-215): the 1 body expr
	# only -- `return spawning && !net.client();` (:214). `spawning` is the
	# WaveSpawner field `private boolean spawning = false;`
	# (WaveSpawner.java:27), set true by spawnEnemies() (:63) and cleared
	# by reset() (:218) / a delayed Time.run (:108); GD takes it as a bool
	# input. `net.client()` is read as-is from the frame input is_client
	# and never resolved here (precedent N2438 checkCampaignStats, same
	# `... && !net.client()` shape; N2123/N2297 micro-accessors).
	# The checkGameState() call-site `spawner.isSpawning();` (:369) is NOT
	# in this slice -- it belongs to checkGameState, a later slice.
	return {"spawning": spawning and not is_client}


static func source_wave_spawner_get_spawns_state(spawns: Array) -> Dictionary:
	# WaveSpawner.getSpawns() (WaveSpawner.java:53-55): the 1 body expr
	# only -- `return spawns;` (:54). `spawns` is the WaveSpawner field
	# `private Seq<Tile> spawns = new Seq<>(false);`
	# (WaveSpawner.java:26), populated by reset() (:217-227, a later
	# slice) from the world-tiles scan; GD takes it as an Array input
	# and does not recompute it from the world (precedent N2442
	# countSpawns, same field; N2123/N2297 micro-accessors). The
	# consumers (BaseBuilderAI :164/:193, Pathfinder :139/:585) call
	# `spawner.getSpawns()` -- NOT in this slice; they belong to
	# BaseBuilderAI/Pathfinder, outside the C07 VM line.
	return {"spawns": spawns}


static func source_wave_spawner_player_near_state(has_spawns: bool, player_dead: bool, spawns: Array, player_pos: Vector2, drop_zone_radius: float, player_team_id: int, wave_team_id: int) -> Dictionary:
	# WaveSpawner.playerNear() (WaveSpawner.java:58-60): the 1 body expr
	# only -- `return state.hasSpawns() && !player.dead() && spawns.contains(g -> Mathf.dst(g.x * tilesize, g.y * tilesize, player.x, player.y) < state.rules.dropZoneRadius && player.team() != state.rules.waveTeam);` (:59).
	# `tilesize` is Vars.tilesize = 8 (Vars.java:135; SourceWorldDefaults.TILESIZE),
	# NOT 32 -- the batch 42 draft said 32, which is wrong; verified from
	# upstream Vars.java:135 + SourceWorldSourceTextState.gd:6.
	# `spawns` is the WaveSpawner field `private Seq<Tile> spawns = new Seq<>(false);`
	# (WaveSpawner.java:26); each element is a tile dict with "x"/"y" TILE
	# coords (precedent SourceBeamDrillBuildState.gd:664 `face_tile.get("x", 0)`),
	# so GD multiplies by TILESIZE to get pixels before the dst check.
	# `has_spawns` is taken as a bool input (precedent spawn_knockback_state;
	# the live hasSpawns() value comes from source_game_loop_has_spawns_state,
	# never called cross-file here). `player.team() != state.rules.waveTeam`
	# does not depend on the spawn tile, so it is hoisted out of the loop --
	# identical result, same short-circuit shape as the Java `&&` chain.
	# The HudFragment call-site `spawner.playerNear()` (HudFragment.java:664)
	# is NOT in this slice -- it belongs to HudFragment, a later slice.
	var player_near := false
	if has_spawns and not player_dead and player_team_id != wave_team_id:
		for spawn_tile in spawns:
			var spawn_px := Vector2(float(spawn_tile.get("x", 0)) * source_world_defaults.TILESIZE, float(spawn_tile.get("y", 0)) * source_world_defaults.TILESIZE)
			if spawn_px.distance_to(player_pos) < drop_zone_radius:
				player_near = true
				break
	return {"player_near": player_near}
