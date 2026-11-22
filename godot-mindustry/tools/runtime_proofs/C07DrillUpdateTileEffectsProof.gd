extends Node

const main_scene := preload("res://scenes/Main.tscn")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _tick(game: PortGame, update_effect_chance: float, warmup: float, update_effect_roll: float, source_delta: float, size: float, x: float, y: float, was_visible: bool, drill_effect_chance: float, drill_effect_roll: float, drill_effect_rnd: float, dominant_item_color: Variant, update_effect_range_roll_x: float, update_effect_range_roll_y: float, drill_effect_range_roll_x: float, drill_effect_range_roll_y: float, update_effect_at: Callable, drill_effect_at: Callable) -> Dictionary:
	return game.source_drill_update_tile_effects_state(update_effect_chance, warmup, update_effect_roll, source_delta, size, x, y, was_visible, drill_effect_chance, drill_effect_roll, drill_effect_rnd, dominant_item_color, update_effect_range_roll_x, update_effect_range_roll_y, drill_effect_range_roll_x, drill_effect_range_roll_y, update_effect_at, drill_effect_at)


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

	# --- DrillBuild.updateTile() effect legs (N2420):
	# DrillBuild.updateTile() (Drill.java:287-327) -- this
	# slice is ONLY the 3 effect lines:
	# `if(Mathf.chanceDelta(updateEffectChance * warmup))`
	# (:307), `updateEffect.at(x + Mathf.range(size * 2f),
	# y + Mathf.range(size * 2f));` (:308), and
	# `if(wasVisible && Mathf.chanceDelta(drillEffectChance
	# * warmup)) drillEffect.at(x + Mathf.range(
	# drillEffectRnd), y + Mathf.range(drillEffectRnd),
	# dominantItem.color);` (:323). The proof drives the
	# pure function with synthetic frames (no live tick):
	# Drill field defaults updateEffectChance 0.02f /
	# drillEffectChance 0.02f (Drill.java:57, :63), warmup
	# 1.0, source_delta 1.0, size 2.0, x 100.0, y 200.0,
	# drillEffectRnd 3.0. NOT this slice: the
	# items/efficiency gate (N693), `progress %= delay`
	# (N696), `offload(dominantItem)` (N2022).

	var color := Color(0.9, 0.6, 0.2)
	var no_op: Callable = Callable()

	# The update effect fires when its chance roll falls
	# below updateEffectChance * warmup * delta.
	var update_seen: Array = []
	var update_callable: Callable = func(fx: float, fy: float) -> void:
		update_seen.append([fx, fy])
	var fired: Dictionary = _tick(game, 0.02, 1.0, 0.0001, 1.0, 2.0, 100.0, 200.0, true, 0.02, 0.5, 3.0, color, 0.5, 0.5, 0.5, 0.5, update_callable, no_op)
	proof["update_effect_fires_when_roll_below_threshold"] = bool(fired.get("update_effect", false)) and bool(fired.get("update_effect_called", false)) and update_seen == [[100.0, 200.0]]

	# Above the threshold the update effect stays silent
	# and its Callable is never invoked.
	update_seen.clear()
	var silent: Dictionary = _tick(game, 0.02, 1.0, 0.5, 1.0, 2.0, 100.0, 200.0, true, 0.02, 0.5, 3.0, color, 0.5, 0.5, 0.5, 0.5, update_callable, no_op)
	proof["update_effect_silent_when_roll_above_threshold"] = not bool(silent.get("update_effect", true)) and not bool(silent.get("update_effect_called", true)) and update_seen.is_empty()

	# The update offsets scale with size: range rolls 1.0
	# / 0.0 map to +size * 2f / -size * 2f, so size 2.0
	# puts the effect at (104, 196).
	update_seen.clear()
	var sized: Dictionary = _tick(game, 0.02, 1.0, 0.0001, 1.0, 2.0, 100.0, 200.0, true, 0.02, 0.5, 3.0, color, 1.0, 0.0, 0.5, 0.5, update_callable, no_op)
	proof["update_effect_offset_uses_size"] = bool(sized.get("update_effect", false)) and update_seen.size() == 1 and is_equal_approx(float(update_seen[0][0]), 104.0) and is_equal_approx(float(update_seen[0][1]), 196.0) and is_equal_approx(float(sized.get("update_effect_x", -1.0)), 104.0) and is_equal_approx(float(sized.get("update_effect_y", -1.0)), 196.0)

	# Warmup zero zeroes the threshold, so even a tiny
	# roll does not fire the update effect.
	update_seen.clear()
	var cold: Dictionary = _tick(game, 0.02, 0.0, 0.0001, 1.0, 2.0, 100.0, 200.0, true, 0.02, 0.5, 3.0, color, 0.5, 0.5, 0.5, 0.5, update_callable, no_op)
	proof["update_effect_silent_when_warmup_zero"] = not bool(cold.get("update_effect", true)) and update_seen.is_empty()

	# The threshold scales with source_delta: roll 0.015
	# fires at delta 1.0 (0.015 < 0.02) but not at delta
	# 0.5 (0.015 < 0.01 is false).
	update_seen.clear()
	var full_delta: Dictionary = _tick(game, 0.02, 1.0, 0.015, 1.0, 2.0, 100.0, 200.0, true, 0.02, 0.5, 3.0, color, 0.5, 0.5, 0.5, 0.5, update_callable, no_op)
	update_seen.clear()
	var half_delta: Dictionary = _tick(game, 0.02, 1.0, 0.015, 0.5, 2.0, 100.0, 200.0, true, 0.02, 0.5, 3.0, color, 0.5, 0.5, 0.5, 0.5, update_callable, no_op)
	proof["update_effect_threshold_scales_with_source_delta"] = bool(full_delta.get("update_effect", false)) and not bool(half_delta.get("update_effect", true)) and update_seen.is_empty()

	# The drill effect fires only when wasVisible and its
	# own chance roll falls below drillEffectChance *
	# warmup * delta, spawning with the dominant item
	# color.
	var drill_seen: Array = []
	var drill_callable: Callable = func(fx: float, fy: float, fcolor: Variant) -> void:
		drill_seen.append([fx, fy, fcolor])
	var drilled: Dictionary = _tick(game, 0.02, 1.0, 0.5, 1.0, 2.0, 100.0, 200.0, true, 0.02, 0.0001, 3.0, color, 0.5, 0.5, 0.5, 0.5, no_op, drill_callable)
	proof["drill_effect_fires_when_visible_and_roll_below_threshold"] = bool(drilled.get("drill_effect", false)) and bool(drilled.get("drill_effect_called", false)) and drill_seen.size() == 1 and is_equal_approx(float(drill_seen[0][0]), 100.0) and is_equal_approx(float(drill_seen[0][1]), 200.0)

	# Not visible means no drill effect even with a
	# passing roll.
	drill_seen.clear()
	var hidden: Dictionary = _tick(game, 0.02, 1.0, 0.5, 1.0, 2.0, 100.0, 200.0, false, 0.02, 0.0001, 3.0, color, 0.5, 0.5, 0.5, 0.5, no_op, drill_callable)
	proof["drill_effect_silent_when_not_visible"] = not bool(hidden.get("drill_effect", true)) and not bool(hidden.get("drill_effect_called", true)) and drill_seen.is_empty()

	# Above its threshold the drill effect stays silent
	# even when visible.
	drill_seen.clear()
	var unlucky: Dictionary = _tick(game, 0.02, 1.0, 0.5, 1.0, 2.0, 100.0, 200.0, true, 0.02, 0.5, 3.0, color, 0.5, 0.5, 0.5, 0.5, no_op, drill_callable)
	proof["drill_effect_silent_when_roll_above_threshold"] = not bool(unlucky.get("drill_effect", true)) and drill_seen.is_empty()

	# The drill offsets scale with drillEffectRnd: range
	# rolls 1.0 / 0.0 map to +rnd / -rnd, so rnd 3.0 puts
	# the effect at (103, 197).
	drill_seen.clear()
	var ranged: Dictionary = _tick(game, 0.02, 1.0, 0.5, 1.0, 2.0, 100.0, 200.0, true, 0.02, 0.0001, 3.0, color, 0.5, 0.5, 1.0, 0.0, no_op, drill_callable)
	proof["drill_effect_offset_uses_drill_effect_rnd"] = bool(ranged.get("drill_effect", false)) and drill_seen.size() == 1 and is_equal_approx(float(drill_seen[0][0]), 103.0) and is_equal_approx(float(drill_seen[0][1]), 197.0) and is_equal_approx(float(ranged.get("drill_effect_x", -1.0)), 103.0) and is_equal_approx(float(ranged.get("drill_effect_y", -1.0)), 197.0)

	# The drill effect carries the dominant item color,
	# both in the .at call and in the result.
	proof["drill_effect_carries_dominant_item_color"] = drill_seen.size() == 1 and drill_seen[0][2] == color and ranged.get("drill_effect_color") == color

	# The result carries ONLY its own keys.
	proof["returns_only_expected_keys"] = fired.size() == 9 and silent.size() == 9 and drilled.size() == 9

	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07DrillUpdateTileEffectsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
