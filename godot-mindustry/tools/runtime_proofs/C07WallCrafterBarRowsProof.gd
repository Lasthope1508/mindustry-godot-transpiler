extends Node

const main_scene := preload("res://scenes/Main.tscn")
const wall_crafter_build_state := preload("res://src/game/SourceWallCrafterBuildState.gd")
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

	# --- SetBars rows (N2465): WallCrafter.setBars()
	# (WallCrafter.java:68-73) adds the "drillspeed"
	# bar after super.setBars() (the shared health /
	# power / items bars, Block.java:696) -- the label
	# is Core.bundle.format("bar.drillspeed",
	# Strings.fixed(e.lastEfficiency * 60 /
	# drillTime, 2)), the color is Pal.ammo, the
	# fraction is e.warmup RAW (the Bar clamps at
	# render, Bar.java:33/:80). Strings.fixed
	# TRUNCATES (arc Strings.java:737), it does NOT
	# round (the N2426 lesson). lastEfficiency /
	# warmup are the build fields (WallCrafter.java:
	# 184) the N2223 advance tracks (lastEfficiency
	# = eff * timeScale * efficiency, :211). drillTime
	# is the class field 150f (:33), overridden by
	# both defs: 110f cliff-crusher (Blocks.java:
	# 3006), 48f large-cliff-crusher (Blocks.java:
	# 3020). The amount formula is the SAME formula
	# as the N2426 drawPlace drillspeed text (60f /
	# drillTime * eff, :131-135), modulo the Java
	# operand order. Pure-only: the tick never calls
	# setBars.

	# --- Bar label: lastEfficiency 2.0 at the
	# cliff-crusher drillTime 110 -- 2 * 60 / 110 =
	# 1.0909... formats "1.09" under the
	# bar.drillspeed key (bar.drillspeed = Drill
	# Speed: {0}/s, bundle.properties:1279).
	var label_bar: Dictionary = wall_crafter_build_state.source_wall_crafter_bar_state(2.0, 110.0, 1.0)
	var label_dict: Dictionary = label_bar.get("label", {})
	proof["bar_label"] = str(label_dict.get("key", "")) == "bar.drillspeed" and str(label_dict.get("amount", "")) == "1.09" and is_equal_approx(float(label_bar.get("drillspeed", -1.0)), 120.0 / 110.0)

	# --- Bar truncation: the N2426 probe (drillTime
	# 60, lastEfficiency 1.099) gives 1.099, which
	# Strings.fixed TRUNCATES to "1.09" where
	# rounding would give "1.10"; lastEfficiency
	# 2.5 at drillTime 48 gives exactly 3.125,
	# which truncates to "3.12" (rounding would
	# give "3.13").
	var trunc_bar: Dictionary = wall_crafter_build_state.source_wall_crafter_bar_state(1.099, 60.0, 1.0)
	var trunc_label: Dictionary = trunc_bar.get("label", {})
	var trunc_bar2: Dictionary = wall_crafter_build_state.source_wall_crafter_bar_state(2.5, 48.0, 1.0)
	var trunc_label2: Dictionary = trunc_bar2.get("label", {})
	proof["bar_truncation"] = str(trunc_label.get("amount", "")) == "1.09" and str(trunc_label2.get("amount", "")) == "3.12" and is_equal_approx(float(trunc_bar2.get("drillspeed", -1.0)), 3.125)

	# --- Bar color: the color token is Pal.ammo on
	# every call (ammo = Color.valueOf("ff8947"),
	# Pal.java:64).
	proof["bar_color"] = str(label_bar.get("color", "")) == "Pal.ammo" and str(trunc_bar.get("color", "")) == "Pal.ammo" and str(trunc_bar2.get("color", "")) == "Pal.ammo"

	# --- Bar fraction warmup: the fraction is the
	# warmup RAW -- 1.5 stays 1.5 (the Bar clamps
	# it at render, Bar.java:33/:80), 0.25 stays
	# 0.25, 1.0 stays 1.0, 0.0 stays 0.0.
	var over_bar: Dictionary = wall_crafter_build_state.source_wall_crafter_bar_state(1.0, 110.0, 1.5)
	var quarter_bar: Dictionary = wall_crafter_build_state.source_wall_crafter_bar_state(1.0, 110.0, 0.25)
	var zero_warmup_bar: Dictionary = wall_crafter_build_state.source_wall_crafter_bar_state(1.0, 110.0, 0.0)
	proof["bar_fraction_warmup"] = is_equal_approx(float(over_bar.get("fraction", -1.0)), 1.5) and is_equal_approx(float(quarter_bar.get("fraction", -1.0)), 0.25) and is_equal_approx(float(label_bar.get("fraction", -1.0)), 1.0) and is_equal_approx(float(zero_warmup_bar.get("fraction", -1.0)), 0.0)

	# --- Bar def values: at lastEfficiency 1.0 the
	# cliff-crusher (drillTime 110) reads 60 / 110
	# = 0.5454... -> "0.54", the large-cliff-crusher
	# (drillTime 48) reads 60 / 48 = 1.25 -> "1.25",
	# and the class default (drillTime 150) reads
	# 60 / 150 = 0.4 -> "0.40".
	var cliff_bar: Dictionary = wall_crafter_build_state.source_wall_crafter_bar_state(1.0, 110.0, 1.0)
	var cliff_label: Dictionary = cliff_bar.get("label", {})
	var large_bar: Dictionary = wall_crafter_build_state.source_wall_crafter_bar_state(1.0, 48.0, 1.0)
	var large_label: Dictionary = large_bar.get("label", {})
	var class_bar: Dictionary = wall_crafter_build_state.source_wall_crafter_bar_state(1.0, 150.0, 1.0)
	var class_label: Dictionary = class_bar.get("label", {})
	proof["bar_def_values"] = str(cliff_label.get("amount", "")) == "0.54" and is_equal_approx(float(cliff_bar.get("drillspeed", -1.0)), 60.0 / 110.0) and str(large_label.get("amount", "")) == "1.25" and is_equal_approx(float(large_bar.get("drillspeed", -1.0)), 1.25) and str(class_label.get("amount", "")) == "0.40" and is_equal_approx(float(class_bar.get("drillspeed", -1.0)), 0.4)

	# --- Bar zero efficiency: lastEfficiency 0
	# formats "0.00" with drillspeed 0.0, whatever
	# the drillTime.
	var zero_bar: Dictionary = wall_crafter_build_state.source_wall_crafter_bar_state(0.0, 110.0, 0.0)
	var zero_label: Dictionary = zero_bar.get("label", {})
	var zero_large_bar: Dictionary = wall_crafter_build_state.source_wall_crafter_bar_state(0.0, 48.0, 1.0)
	var zero_large_label: Dictionary = zero_large_bar.get("label", {})
	proof["bar_zero_efficiency"] = str(zero_label.get("amount", "")) == "0.00" and is_equal_approx(float(zero_bar.get("drillspeed", -1.0)), 0.0) and str(zero_large_label.get("amount", "")) == "0.00" and is_equal_approx(float(zero_large_bar.get("drillspeed", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07WallCrafterBarRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
