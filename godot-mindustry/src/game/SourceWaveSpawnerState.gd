extends RefCounted
class_name SourceWaveSpawnerState


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
