extends Node

const main_scene := preload("res://scenes/Main.tscn")
const launch_pad_build_state := preload("res://src/game/SourceLaunchPadBuildState.gd")
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

	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	# --- Launch pod result (N2397): the LaunchPayload
	# entity creation (LaunchPad.java:150-155) reported
	# as a pure descriptor. The launch fire itself is
	# ALREADY LIVE since N2238 (the full-and-timed gate,
	# the stacks copy, items.clear(), the launchCounter
	# = 0f reset, exposing launched + launched_stacks),
	# so this pure consumes the N2238 advance's shape:
	# `LaunchPayload entity = LaunchPayload.create();`
	# + `items.each((item, amount) -> entity.stacks.add(
	# new ItemStack(item, amount)));` + `entity.set(
	# this);` + `entity.lifetime(120f);` + `entity.team(
	# team);` + `entity.add();`. The pod is {stacks,
	# lifetime 120f, team, x, y} when launched, null
	# otherwise (the N2234 spawned_unit precedent -- no
	# live entity is created). consume() (:148) is a
	# no-op for a LaunchPad (no item consumer; the
	# Consume default trigger is empty, Consume.
	# java:50). Sound/FX (launchSound / Fx.launchPod /
	# Effect.shake, :149/156/158) stay deferred.

	# --- Null when not launched: no launch, no pod --
	# even with stacks supplied, a false launched gate
	# reports a null pod (the N2234 null-when-not-
	# spawned precedent), and the launched echo is false.
	var idle: Dictionary = launch_pad_build_state.source_launch_pad_launch_pod_state(false, {"copper": 60, "lead": 40}, 1, 240.0, 180.0)
	var idle_empty: Dictionary = launch_pad_build_state.source_launch_pad_launch_pod_state(false, {}, 1, 240.0, 180.0)
	proof["pod_null_when_not_launched"] = idle.get("pod", {}) == null and bool(idle.get("launched", true)) == false and idle_empty.get("pod", {}) == null and bool(idle_empty.get("launched", true)) == false

	# --- Stacks mirror: the pod stacks are the N2238
	# launched_stacks verbatim -- the items.each copy
	# (zero amounts skipped like ItemModule.each, so a
	# launched pad never carries a zero stack, but the
	# pure maps whatever the advance reports).
	var fired: Dictionary = launch_pad_build_state.source_launch_pad_launch_pod_state(true, {"copper": 60, "lead": 40}, 1, 240.0, 180.0)
	var fired_pod: Dictionary = fired.get("pod", {})
	proof["pod_stacks_mirror"] = bool(fired.get("launched", false)) and fired_pod.get("stacks", {}) == {"copper": 60, "lead": 40} and int(fired_pod.get("stacks", {}).get("copper", -1)) == 60 and int(fired_pod.get("stacks", {}).get("lead", -1)) == 40

	# --- Lifetime: the pod lifetime is the 120f
	# literal (`entity.lifetime(120f);`, LaunchPad.
	# java:153), whatever the stacks, team, or
	# position are.
	var other_pod: Dictionary = launch_pad_build_state.source_launch_pad_launch_pod_state(true, {"silicon": 100}, 2, 16.0, 32.0).get("pod", {})
	proof["pod_lifetime"] = is_equal_approx(float(fired_pod.get("lifetime", -1.0)), 120.0) and is_equal_approx(float(other_pod.get("lifetime", -1.0)), 120.0)

	# --- Team + position: the pod carries the pad's
	# team (`entity.team(team);`) and world position
	# (`entity.set(this);` positions the pod at the
	# pad) -- explicit inputs, passed through
	# untouched.
	proof["pod_team_position"] = int(fired_pod.get("team", -1)) == 1 and is_equal_approx(float(fired_pod.get("x", -1.0)), 240.0) and is_equal_approx(float(fired_pod.get("y", -1.0)), 180.0) and int(other_pod.get("team", -1)) == 2 and is_equal_approx(float(other_pod.get("x", -1.0)), 16.0) and is_equal_approx(float(other_pod.get("y", -1.0)), 32.0)

	# --- Stacks copy: the pod holds a deep copy of
	# the stacks -- mutating the caller's
	# launched_stacks after the call never changes
	# the reported pod.
	var mutable_stacks: Dictionary = {"copper": 60, "lead": 40}
	var copied: Dictionary = launch_pad_build_state.source_launch_pad_launch_pod_state(true, mutable_stacks, 1, 240.0, 180.0)
	mutable_stacks["copper"] = 0
	mutable_stacks["titanium"] = 99
	var copied_pod: Dictionary = copied.get("pod", {})
	proof["pod_stacks_copy"] = copied_pod.get("stacks", {}) == {"copper": 60, "lead": 40} and int(copied_pod.get("stacks", {}).get("copper", -1)) == 60 and not copied_pod.get("stacks", {}).has("titanium")

	# --- Live frame values: a placed launch-pad's
	# frame launches through the N2238 advance and
	# the pod descriptor reads from the live frame.
	# The pad holds a full load (copper 60 + lead 40
	# = 100 = itemCapacity) with launchCounter 1199.0
	# at the driver launchTime stamp 1200f (launch-pad,
	# Blocks.java:6794) and efficiency 1.0; one N2238
	# advance tick (delta 1.0, timeScale 1.0) adds
	# edelta = efficiency * delta * timeScale = 1.0,
	# so the counter reaches 1200f with a full pad --
	# the launch fires, the stacks copy out, the items
	# clear, and the counter resets to 0f. The pod
	# descriptor then reads launched + launched_stacks
	# from that live advance.
	var launch_pad_cell := Vector2i(28, 21)
	var launch_pad := Sprite2D.new()
	game.add_child(launch_pad)
	game.call("record_placed_block", launch_pad, blocks_by_id["launch-pad"], launch_pad_cell)
	launch_pad_build_state.source_launch_pad_bind_frame_state(launch_pad, blocks_by_id["launch-pad"])
	var launch_pad_frame: Dictionary = launch_pad.get_meta(launch_pad_build_state.SOURCE_LAUNCH_PAD_BUILDING_META_KEY, {})
	launch_pad_frame["efficiency"] = 1.0
	launch_pad_frame["launch_counter"] = 1199.0
	launch_pad_frame["launch_time"] = 60.0 * 20.0
	launch_pad_frame["items"] = {"copper": 60, "lead": 40}
	var advanced: Dictionary = launch_pad_build_state.source_launch_pad_update_tile_advance_state(launch_pad_frame, 1.0, 1.0, 100)
	launch_pad_frame["launch_counter"] = float(advanced.get("launch_counter", -1.0))
	launch_pad_frame["items"] = advanced.get("items", {})
	launch_pad_frame["launched"] = bool(advanced.get("launched", false))
	launch_pad_frame["launched_stacks"] = advanced.get("launched_stacks", {})
	var live: Dictionary = launch_pad_build_state.source_launch_pad_launch_pod_state(bool(launch_pad_frame.get("launched", false)), launch_pad_frame.get("launched_stacks", {}), 1, 240.0, 180.0)
	var live_pod: Dictionary = live.get("pod", {})
	proof["pod_live_frame_values"] = bool(advanced.get("launched", false)) and advanced.get("launched_stacks", {}) == {"copper": 60, "lead": 40} and launch_pad_frame.get("items", {"x": 1}) == {} and is_equal_approx(float(launch_pad_frame.get("launch_counter", -1.0)), 0.0) and live.get("pod", null) != null and live_pod.get("stacks", {}) == {"copper": 60, "lead": 40} and is_equal_approx(float(live_pod.get("lifetime", -1.0)), 120.0) and int(live_pod.get("team", -1)) == 1 and is_equal_approx(float(live_pod.get("x", -1.0)), 240.0) and is_equal_approx(float(live_pod.get("y", -1.0)), 180.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LaunchPadPodResultProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
