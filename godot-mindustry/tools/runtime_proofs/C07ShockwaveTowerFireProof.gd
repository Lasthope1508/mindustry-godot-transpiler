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

	# --- Pure fire (N2194): ShockwaveTowerBuild.updateTile fires
	# its wave when the reload counter, charged by edelta(),
	# reaches reload (ShockwaveTower.java:73,
	# `if(potentialEfficiency > 0 && (reloadCounter += edelta())
	# >= reload && timer(timerCheck, checkInterval)){`). The
	# charge advance is N2192's job and the ONLY writer of
	# `reload_counter` -- the fire function reads the counter the
	# charge stamped this tick and never re-advances it. On fire
	# with targets (ShockwaveTower.java:81, `if(targets.size >
	# 0){`) Java sets heat 1f (:82, `heat = 1f;`) and resets the
	# counter (:83, `reloadCounter = 0f;`); every tick, heat
	# decays (:104, `heat = Mathf.clamp(heat - Time.delta / reload
	# * cooldownMultiplier);`) against the per-def reload 80f
	# (Blocks.java:2044), overriding the class default `60f *
	# 1.5f` (ShockwaveTower.java:26), and cooldownMultiplier 1f
	# (ShockwaveTower.java:34). The live bullet scan
	# (Groups.bullet.intersect, ShockwaveTower.java:75-79) has NO
	# frame input in the port, so the fire reads an observed
	# `targets_count` key (the N2190 precedent) and absent means
	# no fire, never invented targets. The timer cadence
	# (`timer(timerCheck, checkInterval)`, checkInterval 8f,
	# ShockwaveTower.java:31) is DEFERRED -- the port tracks no
	# per-building Interval timer state (TimerComp.java:10-13).
	# No randomness is involved: absent `reload_counter` starts
	# from deterministic 0.0 (the N2192 precedent, never `randf`
	# in game code), so the scene seeds no RNG.
	# Fire when charged with targets: potential_efficiency 1.0,
	# reload_counter 80.0 (at reload), targets_count 3, heat 0.0
	# -- delta 0.0 so the same-tick heat decay (:104) leaves heat
	# exactly 1.0, as Java does with Time.delta = 0.
	var charged: Dictionary = shockwave_tower_build_state.source_shockwave_tower_fire_state({"potential_efficiency": 1.0, "reload_counter": 80.0, "targets_count": 3, "heat": 0.0}, 0.0)
	proof["fire_when_charged_with_targets"] = bool(charged.get("fired", false)) == true and is_equal_approx(float(charged.get("reload_counter", -1.0)), 0.0) and is_equal_approx(float(charged.get("heat", -1.0)), 1.0)

	# No fire below reload: reload_counter 10.0 with targets --
	# the counter stays 10.0 (Java resets only on a successful
	# fire, :83) and heat stays 0.0.
	var below: Dictionary = shockwave_tower_build_state.source_shockwave_tower_fire_state({"potential_efficiency": 1.0, "reload_counter": 10.0, "targets_count": 3, "heat": 0.0}, 1.0 / 60.0)
	proof["no_fire_below_reload"] = bool(below.get("fired", true)) == false and is_equal_approx(float(below.get("reload_counter", -1.0)), 10.0) and is_equal_approx(float(below.get("heat", -1.0)), 0.0)

	# No fire without targets: reload_counter 80.0 but
	# targets_count 0 -- the counter stays 80.0 (no reset
	# without fire, the N2192 no-reset precedent).
	var no_targets: Dictionary = shockwave_tower_build_state.source_shockwave_tower_fire_state({"potential_efficiency": 1.0, "reload_counter": 80.0, "targets_count": 0, "heat": 0.0}, 1.0 / 60.0)
	proof["no_fire_without_targets"] = bool(no_targets.get("fired", true)) == false and is_equal_approx(float(no_targets.get("reload_counter", -1.0)), 80.0)

	# No fire without a targets_count key: reload_counter 80.0
	# but NO targets_count key at all -- absent means "no
	# observation yet", never invented targets (the N2190
	# precedent); the counter stays 80.0.
	var no_key: Dictionary = shockwave_tower_build_state.source_shockwave_tower_fire_state({"potential_efficiency": 1.0, "reload_counter": 80.0, "heat": 0.0}, 1.0 / 60.0)
	proof["no_fire_without_targets_key"] = bool(no_key.get("fired", true)) == false and is_equal_approx(float(no_key.get("reload_counter", -1.0)), 80.0)

	# Heat decays every tick: heat 1.0, potential_efficiency 0.0
	# (so no fire), delta 80.0 (one full reload of decay) -- heat
	# reaches exactly 0.0 and the counter stays 10.0.
	var decayed: Dictionary = shockwave_tower_build_state.source_shockwave_tower_fire_state({"potential_efficiency": 0.0, "reload_counter": 10.0, "heat": 1.0}, 80.0)
	proof["heat_decays_every_tick"] = bool(decayed.get("fired", true)) == false and is_equal_approx(float(decayed.get("heat", -1.0)), 0.0) and is_equal_approx(float(decayed.get("reload_counter", -1.0)), 10.0)

	# --- Live tick: the shockwave tower is a ShockwaveTower build
	# with a static power consumer (shockwave-tower,
	# consumePower 100f / 60f, Blocks.java:2042), placed live; the tick
	# driver is called directly (as the N2177/N2191/N2192/N2193 proofs
	# do), not simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back itself
	# is already proven by N2142. The driver calls the fire AFTER
	# the N2192 charge (the Java order, updateConsumption runs
	# BEFORE updateTile), reading THIS tick's freshly stamped
	# potential_efficiency and the counter the charge just
	# advanced. Note the interplay this key pins: with
	# reload_counter 80.0 the N2193 shouldConsume gate reads
	# false, so updateConsumption zeroes efficiency -- but
	# potentialEfficiency is the pre-gate min efficiency
	# (BuildingComp.java:1989, assigned BEFORE the `if(!update){`
	# zeroing), so it stays 1.0 at full power and the tower still
	# fires, exactly like Java: the fire condition reads
	# potentialEfficiency, not efficiency.
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

	# Fire resets the counter live: reload_counter=80.0 (at
	# reload), targets_count=3 observed, power 1.0, enabled -- the
	# tick fires, so reload_counter resets to 0.0 and heat is set
	# to 1.0 and then decayed by this tick's delta (1 - (1/60)/80
	# ~= 0.99979), so the heat check is > 0.99, not == 1.0.
	shockwave_tower_frame["reload_counter"] = 80.0
	shockwave_tower_frame["targets_count"] = 3
	shockwave_tower_frame["power_status"] = 1.0
	shockwave_tower_frame["enabled"] = true
	shockwave_tower_build_state.source_shockwave_tower_tick_buildings_state(game, 1.0 / 60.0)
	shockwave_tower_frame = shockwave_tower.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})
	proof["fire_resets_counter_live"] = is_equal_approx(float(shockwave_tower_frame.get("reload_counter", -1.0)), 0.0) and float(shockwave_tower_frame.get("heat", -1.0)) > 0.99

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ShockwaveTowerFireProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
