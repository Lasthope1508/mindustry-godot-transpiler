extends Node

const main_scene := preload("res://scenes/Main.tscn")
const mend_projector_build_state := preload("res://src/game/SourceMendProjectorBuildState.gd")
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

	# --- MendProjector heal effect rows (N2484):
	# MendBuild.updateTile() heal branch
	# (MendProjector.java:106-122) fires
	# `Fx.healBlockFull.at(other.x, other.y,
	# other.block.size, baseColor, other.block);`
	# (:115) once per healed building -- inside
	# the eachBlock lambda (:112-117), after the
	# heal (:113) + recentlyHealed (:114), before
	# any = true (:116). The heal scan is live
	# since N2242 (the pure
	# source_mend_projector_heal_scan_state), so
	# this pure consumes the caller-supplied healed
	# verdict (a candidate is healed iff damaged
	# && !heal_suppressed && the charge crossed)
	# and reports the effect as a pure call record
	# (the N2469 precedent -- no effect spawned):
	# heal_effect_call {effect "Fx.healBlockFull",
	# x, y, size, color: base_color, block:
	# block_id} when healed is true, null otherwise
	# (the N2397 null-when-absent precedent). The
	# effect is Fx.healBlockFull (`healBlockFull =
	# new Effect(20, e -> {`, Fx.java:2781) and the
	# color is baseColor (`public Color baseColor =
	# Color.valueOf("84f491");`, MendProjector.
	# java:23; neither def overrides it, Blocks.
	# java:1919-1942), carried as the "baseColor"
	# field-name token (the N2373 color-token
	# precedent). The size rides the rotation arg
	# of the .at overload (Effect.java:133); the
	# descriptor key is "size" (mender 1 /
	# mend-projector 2, Blocks.java:1922/1935;
	# shockwave-tower 3, Blocks.java:2040). The
	# mendSound (:119-121) and recentlyHealed
	# (:114) rows defer under their own entries.

	# --- FX fires on heal: healed true at
	# (40, 24) for a size-1 mender records the
	# Fx.healBlockFull call at exactly (40, 24).
	var fired: Dictionary = mend_projector_build_state.source_mend_projector_heal_effect_state(true, 40.0, 24.0, 1, "baseColor", "mender")
	var fired_call: Dictionary = fired.get("heal_effect_call", {})
	proof["fx_on_heal"] = str(fired_call.get("effect", "")) == "Fx.healBlockFull" and is_equal_approx(float(fired_call.get("x", -1.0)), 40.0) and is_equal_approx(float(fired_call.get("y", -1.0)), 24.0) and int(fired_call.get("size", -1)) == 1

	# --- FX is null when not healed: healed
	# false records no call -- even at a
	# different position, so the coords alone
	# never fire the effect (the N2397
	# null-when-absent precedent).
	var idle: Dictionary = mend_projector_build_state.source_mend_projector_heal_effect_state(false, 40.0, 24.0, 1, "baseColor", "mender")
	var idle_moved: Dictionary = mend_projector_build_state.source_mend_projector_heal_effect_state(false, 123.5, -45.25, 2, "baseColor", "mend-projector")
	proof["fx_null_when_not_healed"] = idle.get("heal_effect_call", {}) == null and idle_moved.get("heal_effect_call", {}) == null

	# --- Position: the effect lands at exactly
	# (x, y) -- (123.5, -45.25) here, and
	# (0, 0) at the building center; the pure
	# passes the healed building position through
	# untouched, with no offset or rounding.
	var placed: Dictionary = mend_projector_build_state.source_mend_projector_heal_effect_state(true, 123.5, -45.25, 2, "baseColor", "mend-projector").get("heal_effect_call", {})
	var placed_center: Dictionary = mend_projector_build_state.source_mend_projector_heal_effect_state(true, 0.0, 0.0, 1, "baseColor", "mender").get("heal_effect_call", {})
	proof["fx_position"] = is_equal_approx(float(placed.get("x", -1.0)), 123.5) and is_equal_approx(float(placed.get("y", -1.0)), -45.25) and is_equal_approx(float(placed_center.get("x", -1.0)), 0.0) and is_equal_approx(float(placed_center.get("y", -1.0)), 0.0)

	# --- Size: the block size in tiles rides the
	# call untouched -- 1 for a mender, 2 for a
	# mend-projector, 3 for a shockwave-tower
	# (Blocks.java:1922/1935/2040).
	var sized_1: Dictionary = mend_projector_build_state.source_mend_projector_heal_effect_state(true, 40.0, 24.0, 1, "baseColor", "mender").get("heal_effect_call", {})
	var sized_2: Dictionary = mend_projector_build_state.source_mend_projector_heal_effect_state(true, 40.0, 24.0, 2, "baseColor", "mend-projector").get("heal_effect_call", {})
	var sized_3: Dictionary = mend_projector_build_state.source_mend_projector_heal_effect_state(true, 40.0, 24.0, 3, "baseColor", "shockwave-tower").get("heal_effect_call", {})
	proof["fx_size"] = int(sized_1.get("size", -1)) == 1 and int(sized_2.get("size", -1)) == 2 and int(sized_3.get("size", -1)) == 3

	# --- Color + block: the color is the
	# "baseColor" field-name token (the N2373
	# color-token precedent -- not the hex
	# "84f491", not a Color object) and the block
	# is the healed block id; the effect token is
	# exactly "Fx.healBlockFull" (the N2469
	# "Fx.<name>" call-record convention) -- not
	# the bare "healBlockFull".
	var colored: Dictionary = mend_projector_build_state.source_mend_projector_heal_effect_state(true, 40.0, 24.0, 2, "baseColor", "mend-projector").get("heal_effect_call", {})
	proof["fx_color_block"] = str(colored.get("color", "")) == "baseColor" and str(colored.get("block", "")) == "mend-projector" and str(colored.get("effect", "")) == "Fx.healBlockFull" and str(colored.get("effect", "")) != "healBlockFull"

	# --- Live input: the N2242 heal verdict is
	# the input -- a charged mender (charge 199 +
	# heat 1 * delta 1 = 200 >= reload 200) with
	# one damaged, unsuppressed candidate heals
	# it for 100 * 4 / 100 * 1 = 4.0 (any true)
	# and the effect fires at the candidate
	# position (40, 24); the same tick with a
	# healthy candidate heals nothing (any false,
	# no amounts) and the effect is null.
	var live_frame: Dictionary = {"phase_heat": 0.0, "efficiency": 1.0, "heat": 1.0}
	var live_candidates: Array = [{"damaged": true, "heal_suppressed": false, "max_health": 100.0, "x": 40.0, "y": 24.0, "size": 1, "block": "mender"}]
	var live_scan: Dictionary = mend_projector_build_state.source_mend_projector_heal_scan_state(live_frame, live_candidates, 199.0, 200.0, 40.0, 4.0, 4.0, 20.0, 1.0, 1.0)
	var live_amounts: Array = live_scan.get("heal_amounts", [])
	var live_fx: Dictionary = mend_projector_build_state.source_mend_projector_heal_effect_state(bool(live_scan.get("any", false)), 40.0, 24.0, 1, "baseColor", "mender")
	var live_call: Dictionary = live_fx.get("heal_effect_call", {})
	var live_miss_candidates: Array = [{"damaged": false, "heal_suppressed": false, "max_health": 100.0, "x": 40.0, "y": 24.0, "size": 1, "block": "mender"}]
	var live_miss_scan: Dictionary = mend_projector_build_state.source_mend_projector_heal_scan_state(live_frame, live_miss_candidates, 199.0, 200.0, 40.0, 4.0, 4.0, 20.0, 1.0, 1.0)
	var live_miss_fx: Dictionary = mend_projector_build_state.source_mend_projector_heal_effect_state(bool(live_miss_scan.get("any", true)), 40.0, 24.0, 1, "baseColor", "mender")
	proof["fx_live_input"] = bool(live_scan.get("any", false)) and bool(live_scan.get("scanned", false)) and is_equal_approx(float(live_scan.get("real_range", -1.0)), 40.0) and live_amounts.size() == 1 and is_equal_approx(float(live_amounts[0]), 4.0) and str(live_call.get("effect", "")) == "Fx.healBlockFull" and is_equal_approx(float(live_call.get("x", -1.0)), 40.0) and is_equal_approx(float(live_call.get("y", -1.0)), 24.0) and int(live_call.get("size", -1)) == 1 and str(live_call.get("block", "")) == "mender" and bool(live_miss_scan.get("any", true)) == false and Array(live_miss_scan.get("heal_amounts", [0])).is_empty() and live_miss_fx.get("heal_effect_call", {}) == null

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07MendProjectorHealEffectRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
