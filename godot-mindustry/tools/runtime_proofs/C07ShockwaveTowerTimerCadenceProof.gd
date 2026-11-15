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

	# --- Pure timer cadence (N2200): ShockwaveTowerBuild.updateTile
	# fires its wave only when the reload counter reaches reload AND
	# the per-building timer elapses (ShockwaveTower.java:73,
	# `if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){` with :31, `public float
	# checkInterval = 8f;`, and :23, `public int timerCheck
	# = timers ++;`, over `public int timers = 0;`,
	# Block.java:231). The timer consult is
	# TimerComp.timer (`public boolean timer(int index,
	# float time){` / `if(Float.isInfinite(time)) return
	# false;` / `return timer.get(index, time);`,
	# TimerComp.java:10-13, over `transient Interval timer
	# = new Interval(6);`, TimerComp.java:9), and
	# Interval.get stamps the slot on a due check
	# (`boolean got = check(id, time);` / `if(got)
	# times[id] = Time.time;`, Interval.java:23-24) when the
	# global tick clock has advanced past the interval
	# (`return Time.time - times[id] >= time || Time.time <
	# times[id];`, Interval.java:29, over `times = new
	# float[capacity];`, Interval.java:7 -- fresh slots
	# start at 0) -- and Time.time is a tick clock
	# (`Math.min(Core.graphics.getDeltaTime() * 60f, 3f)`,
	# Time.java:26, with `timeRaw += delta;` / `time =
	# (float)timeRaw;`, Time.java:70-75), so checkInterval
	# 8f is 8 ticks ~= 0.13s in Java, and 8.0 on the port's
	# seconds driver clock (the N2190 refresh / N2192
	# charge precedent). The pure function
	# (source_shockwave_tower_timer_state) takes the frame
	# and the tick delta and returns `{"check_due": bool,
	# "timer_elapsed": float}`: due when the gate is open
	# (potential_efficiency > 0 AND reload_counter >=
	# 80.0, the per-def reload, Blocks.java:2044, `reload =
	# 80f;`) AND the interval elapsed (timer_elapsed >=
	# 8.0); a fresh frame (no `timer_elapsed` key) is due
	# on its first gated consult (a fresh Interval while
	# global Time.time is long past 8); a due check restarts
	# the elapsed clock at 0.0; a closed gate never consumes
	# the due-ness -- the elapsed clock keeps running, so a
	# check that was due while unpowered stays due when
	# power returns. The driver calls the timer AFTER the
	# N2192 charge and BEFORE the N2195 scan, stamps
	# `timer_elapsed` and `timer_check_due`, runs the scan
	# ONLY when the check is due, and the N2194 fire reads
	# `timer_check_due` (absent means due) so it still runs
	# every tick for its heat decay (ShockwaveTower.java:104,
	# `heat = Mathf.clamp(heat - Time.delta / reload *
	# cooldownMultiplier);`) but fires only on a due tick.
	# No RNG.
	# Timer due on a fresh frame: the gate is open
	# (potential_efficiency 1.0, reload_counter 80.0) and
	# the frame carries NO `timer_elapsed` key -- a fresh
	# Interval -- so the check is due and the elapsed clock
	# restarts at 0.0.
	var fresh: Dictionary = shockwave_tower_build_state.source_shockwave_tower_timer_state({"potential_efficiency": 1.0, "reload_counter": 80.0}, 1.0 / 60.0)
	proof["timer_due_on_fresh_frame"] = bool(fresh.get("check_due", false)) == true and float(fresh.get("timer_elapsed", -1.0)) == 0.0

	# Timer not due below the interval: the gate is open
	# but only 3.0s have elapsed since the last due check --
	# one more second (4.0s total) is still below 8.0, so
	# the check is not due and the clock advances by the
	# tick delta instead of restarting.
	var below: Dictionary = shockwave_tower_build_state.source_shockwave_tower_timer_state({"potential_efficiency": 1.0, "reload_counter": 80.0, "timer_elapsed": 3.0}, 1.0)
	proof["timer_not_due_below_interval"] = bool(below.get("check_due", true)) == false and float(below.get("timer_elapsed", 0.0)) > 3.0 and float(below.get("timer_elapsed", 0.0)) < 8.0

	# Timer due at the interval: 7.5s elapsed plus one more
	# second reaches 8.5s >= 8.0 (the Interval.check `>=`),
	# so the check is due and the clock restarts at 0.0.
	var at_interval: Dictionary = shockwave_tower_build_state.source_shockwave_tower_timer_state({"potential_efficiency": 1.0, "reload_counter": 80.0, "timer_elapsed": 7.5}, 1.0)
	proof["timer_due_at_interval"] = bool(at_interval.get("check_due", false)) == true and float(at_interval.get("timer_elapsed", -1.0)) == 0.0

	# Timer gate closed without power: the counter is at
	# reload (80.0) but potential_efficiency is 0.0 -- the
	# first conjunct fails, so the check is not due, and the
	# elapsed clock keeps running (3.0s + 1.0s) instead of
	# restarting, so the due-ness is not consumed.
	var no_power: Dictionary = shockwave_tower_build_state.source_shockwave_tower_timer_state({"potential_efficiency": 0.0, "reload_counter": 80.0, "timer_elapsed": 3.0}, 1.0)
	proof["timer_gate_closed_without_power"] = bool(no_power.get("check_due", true)) == false and float(no_power.get("timer_elapsed", 0.0)) > 3.0

	# Timer gate closed below reload: power is on but the
	# counter is only 10.0 -- the second conjunct fails, so
	# the check is not due and the elapsed clock keeps
	# running instead of restarting.
	var below_reload: Dictionary = shockwave_tower_build_state.source_shockwave_tower_timer_state({"potential_efficiency": 1.0, "reload_counter": 10.0, "timer_elapsed": 3.0}, 1.0)
	proof["timer_gate_closed_below_reload"] = bool(below_reload.get("check_due", true)) == false and float(below_reload.get("timer_elapsed", 0.0)) > 3.0

	# Timer due-ness persists across unpowered ticks: the
	# clock is already past the interval (9.0s) but the
	# gate is closed (no power), so the check is not due
	# AND the clock keeps running (9.0s + 1.0s = 10.0s,
	# not restarted); when power returns with the same
	# elapsed clock, the check is due at once.
	var unpowered: Dictionary = shockwave_tower_build_state.source_shockwave_tower_timer_state({"potential_efficiency": 0.0, "reload_counter": 80.0, "timer_elapsed": 9.0}, 1.0)
	var repowered: Dictionary = shockwave_tower_build_state.source_shockwave_tower_timer_state({"potential_efficiency": 1.0, "reload_counter": 80.0, "timer_elapsed": float(unpowered.get("timer_elapsed", 0.0))}, 1.0 / 60.0)
	proof["timer_due_persists_across_unpowered_ticks"] = bool(unpowered.get("check_due", true)) == false and float(unpowered.get("timer_elapsed", 0.0)) > 9.0 and bool(repowered.get("check_due", false)) == true and float(repowered.get("timer_elapsed", -1.0)) == 0.0

	# --- Live tick: the shockwave tower is a ShockwaveTower build
	# with a static power consumer (shockwave-tower,
	# consumePower 100f / 60f, Blocks.java:2042), placed live; the tick
	# driver is called directly (as the N2177/N2191/N2192/N2193/N2194/
	# N2195/N2196/N2197/N2198/N2199 proofs do), not simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back itself
	# is already proven by N2142. The driver calls the timer
	# AFTER the N2192 charge and BEFORE the N2195 scan, stamps
	# `timer_elapsed` and `timer_check_due`, runs the scan ONLY
	# when the check is due, and the N2194 fire reads
	# `timer_check_due` (absent means due). The tower team is 1
	# (record_placed_block default, SOURCE_TEAM_SHARDED_ID).
	# Three ticks isolate the timer: tick 1 fires on a fresh
	# frame (timer due); tick 2 re-presets the counter to 80.0
	# with the same bullets in range -- only the timer blocks
	# the fire now (elapsed ~1/60s < 8.0); tick 3 clears the
	# observed bullets -- if the scan ran it would stamp
	# targets_count 0, so a stale 2 proves the scan was skipped.
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

	# Tick 1 -- timer due on a fresh frame: observed_bullets
	# stamped on the frame before the tick (the observed-only
	# input, like N2195's targets_count) -- two enemy hittable
	# bullets in range with damage 500 at (324, 168) (tower
	# world (224, 168) + 100) and (224, 68) (tower - 100 y).
	# The reload counter is preset to 80.0 (per-def reload) so
	# the N2194 fire runs this tick: the N2193 shouldConsume
	# gate reads the preset counter as fully charged and zeroes
	# efficiency, but the fire reads potential_efficiency (1.0
	# from the stamped power_status), exactly like Java, so the
	# fire still fires, the wave damage is min(160, 160 * 20 /
	# 2) = 160 (both bullets damaged, 500 > 160, remaining
	# 340), and the timer -- fresh frame, gate open -- is due,
	# so the scan runs and the fire fires.
	shockwave_tower_frame["observed_bullets"] = [
		{"team": 2, "hittable": true, "x": 324.0, "y": 168.0, "damage": 500.0},
		{"team": 2, "hittable": true, "x": 224.0, "y": 68.0, "damage": 500.0},
	]
	shockwave_tower_frame["power_status"] = 1.0
	shockwave_tower_frame["enabled"] = true
	shockwave_tower_frame["reload_counter"] = 80.0
	shockwave_tower_build_state.source_shockwave_tower_tick_buildings_state(game, 1.0 / 60.0)
	shockwave_tower_frame = shockwave_tower.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})
	var fired_tick_1: bool = bool(shockwave_tower_frame.get("fired", false))
	var targets_tick_1: int = int(shockwave_tower_frame.get("targets_count", -1))

	# Tick 2 -- timer NOT due: the counter is re-preset to
	# 80.0 and the same two bullets stay in range, so the
	# gate is open (PE 1.0, counter 80.0) and only the timer
	# blocks -- the elapsed clock is ~1/60s after tick 1's
	# due check, far below 8.0s. The scan is skipped and the
	# fire does not fire.
	shockwave_tower_frame["reload_counter"] = 80.0
	shockwave_tower_frame["power_status"] = 1.0
	shockwave_tower_build_state.source_shockwave_tower_tick_buildings_state(game, 1.0 / 60.0)
	shockwave_tower_frame = shockwave_tower.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})
	var fired_tick_2: bool = bool(shockwave_tower_frame.get("fired", true))
	var targets_tick_2: int = int(shockwave_tower_frame.get("targets_count", -1))

	# Tick 3 -- scan gated on the timer: the observed bullets
	# are cleared (an empty list IS an observation -- a scan
	# that ran would stamp targets_count 0), the counter is
	# re-preset to 80.0, and the timer is still not due
	# (elapsed ~2/60s). The scan is skipped, so targets_count
	# stays at the tick-1 value 2 instead of dropping to 0.
	shockwave_tower_frame["observed_bullets"] = []
	shockwave_tower_frame["reload_counter"] = 80.0
	shockwave_tower_frame["power_status"] = 1.0
	shockwave_tower_build_state.source_shockwave_tower_tick_buildings_state(game, 1.0 / 60.0)
	shockwave_tower_frame = shockwave_tower.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})
	var fired_tick_3: bool = bool(shockwave_tower_frame.get("fired", true))
	var targets_tick_3: int = int(shockwave_tower_frame.get("targets_count", -1))

	proof["live_driver_fire_gated_on_timer"] = fired_tick_1 == true and targets_tick_1 == 2 and fired_tick_2 == false and targets_tick_2 == 2
	proof["live_driver_scan_gated_on_timer"] = fired_tick_3 == false and targets_tick_3 == 2

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ShockwaveTowerTimerCadenceProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
