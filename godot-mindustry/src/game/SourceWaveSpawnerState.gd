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
