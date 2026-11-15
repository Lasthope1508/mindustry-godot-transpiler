extends Node

const main_scene := preload("res://scenes/Main.tscn")
const shockwave_tower_build_state := preload("res://src/game/SourceShockwaveTowerBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	var game := main_scene.instantiate()
	add_child(game)
	for iteration in range(4):
		await get_tree().process_frame
	game.call("enter_campaign_playable_slice")
	for iteration in range(4):
		await get_tree().process_frame
	game.set_process(false)
	game.set_physics_process(false)

	# --- Pure use event (N2199): ShockwaveTowerBuild.updateTile
	# fires its wave when the reload counter reaches reload with
	# targets observed (ShockwaveTower.java:73, `if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){` with :81, `if(targets.size > 0){`), then applies the wave damage (`float waveDamage = Math.min(bulletDamage, bulletDamage * falloffCount / targets.size);`, ShockwaveTower.java:87) and loops the targets (`for(var target : targets){`, ShockwaveTower.java:89), and EVERY target gets its hit effect at its own position (`hitEffect.at(target.x, target.y, waveColor);`, ShockwaveTower.java:95, over `public Effect hitEffect = Fx.hitSquaresColor;`, ShockwaveTower.java:35) -- and then, inside the same fire gate, the tower fires the shockwaveTowerUse event when its team is the default team (`if(team == state.rules.defaultTeam){` / `Events.fire(Trigger.shockwaveTowerUse);`, ShockwaveTower.java:98-99, over `shockwaveTowerUse,` in the Trigger enum, EventType.java:28, and `public Team defaultTeam = Team.sharded;`, Rules.java:205 -- sharded is id 1, Team.java:34, `sharded = new Team(1, "sharded", Pal.accent.cpy(), Color.valueOf("ffd37f"), Color.valueOf("eab678"), Color.valueOf("d4816b")),`). The port fires no real event (no Events / Trigger bus is wired), so the pure function stamps the trigger name instead of firing it. The function reads the frame's `fired` key (the N2194 fire result, stamped on the frame by the GREEN driver alongside `reload_counter` / `heat`) and its `team_id` key (already stamped by the tick wiring from the sprite team meta). The frame's `rules_state` carries no defaultTeam key, so the comparison uses the Java Rules default (sharded, id 1), a documented limit: a custom rules defaultTeam override is not modeled. The driver calls the event AFTER the N2198 hit effect and ONLY when the fire fired (the Java order :89-95 before :98-99).
	# Event fires on a fire tick for the default team: the
	# frame records a fire (fired true) and the tower team is
	# sharded (team_id 1, SOURCE_TEAM_SHARDED_ID).
	var default_fired: Dictionary = shockwave_tower_build_state.source_shockwave_tower_use_event_state({"team_id": 1, "fired": true})
	proof["event_fires_on_fire_for_default_team"] = bool(default_fired.get("event_fired", false)) == true and String(default_fired.get("event", "")) == "shockwaveTowerUse"

	# Event silent for another team: the frame records a fire
	# (fired true) but the tower team is crux (team_id 2) --
	# event is null, event_fired is false, so the driver stamps
	# nothing.
	var other_fired: Dictionary = shockwave_tower_build_state.source_shockwave_tower_use_event_state({"team_id": 2, "fired": true})
	proof["event_silent_for_other_team"] = bool(other_fired.get("event_fired", true)) == false and other_fired.get("event", "shockwaveTowerUse") == null

	# Event silent without a fire: the tower team is the
	# default team (team_id 1) but the frame records no fire
	# (fired false) -- the event lives inside the fire gate in
	# Java (:81-100), so a charged-but-unfired tick fires
	# nothing.
	var default_unfired: Dictionary = shockwave_tower_build_state.source_shockwave_tower_use_event_state({"team_id": 1, "fired": false})
	proof["event_silent_without_fire"] = bool(default_unfired.get("event_fired", true)) == false and default_unfired.get("event", "shockwaveTowerUse") == null

	# Absent keys fire nothing: the frame carries NO `fired`
	# key and NO `team_id` key at all -- event is null,
	# event_fired is false -- and a frame that records a fire
	# but carries no team is equally silent (the N2190
	# precedent: absent means "no observation yet", never a
	# fabricated event).
	var absent: Dictionary = shockwave_tower_build_state.source_shockwave_tower_use_event_state({})
	var absent_no_team: Dictionary = shockwave_tower_build_state.source_shockwave_tower_use_event_state({"fired": true})
	proof["absent_keys_fire_nothing"] = bool(absent.get("event_fired", true)) == false and absent.get("event", "shockwaveTowerUse") == null and bool(absent_no_team.get("event_fired", true)) == false and absent_no_team.get("event", "shockwaveTowerUse") == null

	# --- Live tick: the shockwave tower is a ShockwaveTower build
	# with a static power consumer (shockwave-tower,
	# consumePower 100f / 60f, Blocks.java:2042), placed live; the tick
	# driver is called directly (as the N2177/N2191/N2192/N2193/N2194/
	# N2195/N2196/N2197/N2198 proofs do), not simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back itself
	# is already proven by N2142. The driver calls the event
	# AFTER the N2198 hit effect and ONLY when the fire fired
	# (the Java order :89-95 before :98-99), deriving the tower world
	# position from the placement cell (cell (28, 21), size 3,
	# tilesize 8, offset 0 -- world (224, 168)) and stamping
	# frame["shockwave_tower_use_event"] only when the event reports one.
	# The tower team is 1 (record_placed_block default,
	# SOURCE_TEAM_SHARDED_ID).
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var shockwave_tower_cell := Vector2i(28, 21)
	var shockwave_tower := Sprite2D.new()
	game.add_child(shockwave_tower)
	game.call("record_placed_block", shockwave_tower, blocks_by_id["shockwave-tower"], shockwave_tower_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	shockwave_tower_build_state.source_shockwave_tower_bind_frame_state(shockwave_tower, blocks_by_id["shockwave-tower"])
	var shockwave_tower_frame: Dictionary = shockwave_tower.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})

	# Live driver stamps the event only on fire:
	# observed_bullets stamped on the frame before the tick (the
	# observed-only input, like N2195's targets_count) -- two
	# enemy hittable bullets in range with damage 500 at
	# (324, 168) (tower world (224, 168) + 100) and (224, 68)
	# (tower - 100 y). The reload counter is preset to 80.0
	# (per-def reload) so the N2194 fire runs this tick: the
	# N2193 shouldConsume gate reads the preset counter as fully
	# charged and zeroes efficiency, but the fire reads
	# potential_efficiency (1.0 from the stamped power_status),
	# exactly like Java, so the fire still fires, the wave damage
	# is min(160, 160 * 20 / 2) = 160 (both bullets damaged, 500
	# > 160, remaining 340), the hit effects stamp one
	# Fx.hitSquaresColor descriptor per bullet at (324, 168) and
	# (224, 68), and -- the tower team is the default team (1) --
	# the use event stamps frame["shockwave_tower_use_event"] =
	# "shockwaveTowerUse".
	shockwave_tower_frame["observed_bullets"] = [
		{"team": 2, "hittable": true, "x": 324.0, "y": 168.0, "damage": 500.0},
		{"team": 2, "hittable": true, "x": 224.0, "y": 68.0, "damage": 500.0},
	]
	shockwave_tower_frame["power_status"] = 1.0
	shockwave_tower_frame["enabled"] = true
	shockwave_tower_frame["reload_counter"] = 80.0
	shockwave_tower_build_state.source_shockwave_tower_tick_buildings_state(game, 1.0 / 60.0)
	shockwave_tower_frame = shockwave_tower.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})
	proof["live_driver_stamps_event_on_fire"] = String(shockwave_tower_frame.get("shockwave_tower_use_event", "")) == "shockwaveTowerUse"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ShockwaveTowerUseEventProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
