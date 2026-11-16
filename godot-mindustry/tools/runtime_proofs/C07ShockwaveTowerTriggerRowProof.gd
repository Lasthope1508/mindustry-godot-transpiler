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

	# --- Trigger row (N2505): the team event at
	# the end of the fire branch
	# (ShockwaveTower.java:98-99) reported as a
	# pure call record. The STATE is ALREADY LIVE
	# since N2247 (the fire gate + bullet scan +
	# wave damage + fire reset + heat decay), so
	# this pure consumes the caller-evaluated fired
	# gate (the N2247 fire verdict) and the
	# caller-evaluated team gate (team == state.
	# rules.defaultTeam, `public Team defaultTeam
	# = Team.sharded;`, Rules.java:205): `if(
	# targets.size > 0){` + `for(var target :
	# targets){` + `hitEffect.at(target.x, target.
	# y, waveColor);` + `if(team == state.rules.
	# defaultTeam){` + `Events.fire(Trigger.
	# shockwaveTowerUse);`. The trigger is the LAST
	# statement of the fire branch, AFTER the wave
	# damage loop (:89-96). The enum value is
	# VERIFIED: `public enum Trigger{`
	# (EventType.java:20) carries
	# `shockwaveTowerUse,` (EventType.java:28), so
	# the event token is the exact "Trigger.
	# shockwaveTowerUse". When either gate fails
	# the call is null (the N2397 null-when-absent
	# precedent). NO event is fired -- the
	# event-dispatch call site waits for an event
	# slice.

	# --- Trigger on fire: fired with the default
	# team records the call -- the event token is
	# Trigger.shockwaveTowerUse.
	var on_fire: Dictionary = shockwave_tower_build_state.source_shockwave_tower_trigger_state(true, true)
	var on_fire_call: Dictionary = on_fire.get("trigger_call", {})
	proof["trigger_on_fire"] = on_fire.get("trigger_call", {}) != null and str(on_fire_call.get("event", "")) == "Trigger.shockwaveTowerUse"

	# --- Trigger null when not fired: no fire, no
	# call -- even for the default team (the N2397
	# null-when-absent precedent).
	var not_fired: Dictionary = shockwave_tower_build_state.source_shockwave_tower_trigger_state(false, true)
	proof["trigger_null_when_not_fired"] = not_fired.get("trigger_call", {}) == null

	# --- Trigger null when not default team: a
	# fire by any other team records no call -- the
	# trigger fires ONLY for the default team
	# (ShockwaveTower.java:98).
	var not_default: Dictionary = shockwave_tower_build_state.source_shockwave_tower_trigger_state(true, false)
	proof["trigger_null_when_not_default_team"] = not_default.get("trigger_call", {}) == null

	# --- Trigger event token: the recorded event
	# is the FULL enum token "Trigger.
	# shockwaveTowerUse" -- not the bare enum value
	# "shockwaveTowerUse" and not a shortened
	# token -- and the call dict carries exactly
	# the one event key.
	var token_call: Dictionary = shockwave_tower_build_state.source_shockwave_tower_trigger_state(true, true).get("trigger_call", {})
	proof["trigger_event_token"] = token_call.size() == 1 and str(token_call.get("event", "")) == "Trigger.shockwaveTowerUse" and str(token_call.get("event", "")) != "shockwaveTowerUse"

	# --- Trigger gate shape: the full 2x2 truth
	# table -- the call records ONLY when fired AND
	# is_default_team; every other combination is
	# null.
	var gate_both: Dictionary = shockwave_tower_build_state.source_shockwave_tower_trigger_state(true, true)
	var gate_fired_only: Dictionary = shockwave_tower_build_state.source_shockwave_tower_trigger_state(true, false)
	var gate_team_only: Dictionary = shockwave_tower_build_state.source_shockwave_tower_trigger_state(false, true)
	var gate_neither: Dictionary = shockwave_tower_build_state.source_shockwave_tower_trigger_state(false, false)
	proof["trigger_gate_shape"] = gate_both.get("trigger_call", {}) != null and gate_fired_only.get("trigger_call", {}) == null and gate_team_only.get("trigger_call", {}) == null and gate_neither.get("trigger_call", {}) == null

	# --- Trigger live input: the fired verdict
	# composed LIVE from the family's own pures --
	# the N2390 sense pure reads a counter that
	# crosses the reload threshold (120.0 / 80.0
	# = 1.5, the bare ratio, NO clamp), and the
	# N2247 advance fires on that counter with one
	# enemy hittable bullet and the timer ready.
	# The live fired verdict feeds the trigger pure
	# with is_default_team true (call recorded)
	# vs false (null).
	var live_sense: Dictionary = shockwave_tower_build_state.source_shockwave_tower_sense_state("progress", 120.0, 80.0)
	var live_progress: float = float(live_sense.get("value", 0.0))
	var live_frame: Dictionary = {"team_id": 1, "potential_efficiency": 1.0, "reload_counter": 120.0, "heat": 0.0, "targets": []}
	var live_bullets: Array = [{"x": 0.0, "y": 0.0, "team": 2, "hittable": true, "damage": 10.0}]
	var live_advanced: Dictionary = shockwave_tower_build_state.source_shockwave_tower_update_tile_advance_state(live_frame, 1.0, 80.0, 160.0, 20.0, 1.0, live_bullets, true)
	var live_fired: bool = bool(live_advanced.get("fired", false))
	var live_default: Dictionary = shockwave_tower_build_state.source_shockwave_tower_trigger_state(live_fired, true)
	var live_other_team: Dictionary = shockwave_tower_build_state.source_shockwave_tower_trigger_state(live_fired, false)
	var live_default_call: Dictionary = live_default.get("trigger_call", {})
	proof["trigger_live_input"] = is_equal_approx(live_progress, 1.5) and live_progress >= 1.0 and live_fired and live_default.get("trigger_call", {}) != null and str(live_default_call.get("event", "")) == "Trigger.shockwaveTowerUse" and live_other_team.get("trigger_call", {}) == null

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ShockwaveTowerTriggerRowProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
