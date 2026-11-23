extends Node

const main_scene := preload("res://scenes/Main.tscn")
const burst_drill_build_state := preload("res://src/game/SourceBurstDrillBuildState.gd")
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

	# --- DrillBuild.shouldConsume() (N2338):
	# DrillBuild.shouldConsume() (Drill.java:247-249,
	# `public boolean shouldConsume(){` with `return
	# items.total() < itemCapacity && enabled &&
	# dominantItem != null;`, :248) is the BASE gate
	# updateConsumption reads (BuildingComp.java:1960,
	# `boolean update = shouldConsume() &&
	# productionValid();` + 1992, `if(!update){` + 1993,
	# `efficiency = optionalEfficiency = 0f;`): items
	# total below the per-def item capacity AND enabled
	# AND a dominant item bound. It is NOT the
	# BurstDrill override (N2295, BurstDrill.java:128-129,
	# `return items.total() <= itemCapacity -
	# dominantItems && enabled;` -- `<=` with the
	# dominant COUNT subtracted, no dominantItem null
	# check). The strict `<` is the observable
	# difference: at items_total == itemCapacity the base
	# gate blocks while the override (with dominant_items
	# 0) would pass. The pure function reads items_total
	# (float, absent -> 0.0) and enabled (bool, absent ->
	# true) from the frame, item_capacity as an explicit
	# param (impact-drill 40, Blocks.java:3078;
	# eruption-drill 60, Blocks.java:3107; Block default
	# 10, Block.java:75) and has_dominant_item as an
	# explicit bool param (the N2341 drawSelect
	# precedent). There is NO driver tick line: the
	# BurstDrill driver calls the N2295 override and this
	# slice ports only the base predicate.

	# Passes below capacity with a dominant item:
	# items_total=9 < 10, enabled, dominant bound.
	var below: Dictionary = burst_drill_build_state.source_drill_should_consume_state({"items_total": 9.0, "enabled": true}, 10.0, true)
	proof["gate_passes_below_capacity_with_dominant"] = bool(below.get("should_consume", false)) == true

	# Blocks AT capacity (strict `<` -- the N2295
	# difference): items_total=10 < 10 is false.
	var at_capacity: Dictionary = burst_drill_build_state.source_drill_should_consume_state({"items_total": 10.0, "enabled": true}, 10.0, true)
	proof["gate_blocks_at_capacity"] = bool(at_capacity.get("should_consume", true)) == false

	# Blocks above capacity: items_total=11 < 10 is
	# false.
	var above: Dictionary = burst_drill_build_state.source_drill_should_consume_state({"items_total": 11.0, "enabled": true}, 10.0, true)
	proof["gate_blocks_above_capacity"] = bool(above.get("should_consume", true)) == false

	# Blocks when disabled: items_total=9 < 10 would
	# pass the bound, but enabled=false.
	var disabled: Dictionary = burst_drill_build_state.source_drill_should_consume_state({"items_total": 9.0, "enabled": false}, 10.0, true)
	proof["gate_blocks_when_disabled"] = bool(disabled.get("should_consume", true)) == false

	# Blocks with no dominant item: items_total=9 < 10
	# and enabled, but has_dominant_item=false -- the
	# `dominantItem != null` check.
	var no_dominant: Dictionary = burst_drill_build_state.source_drill_should_consume_state({"items_total": 9.0, "enabled": true}, 10.0, false)
	proof["gate_blocks_no_dominant_item"] = bool(no_dominant.get("should_consume", true)) == false

	# Absent items_total defaults to 0.0: NO items_total
	# key, capacity 10, enabled, dominant bound -- the
	# bound reads `0 < 10`, so the gate preserves the
	# N2149 behavior (should_consume = enabled and
	# has_dominant_item). This pins the RED
	# absent-default decision: null means "no observation
	# yet", not "full".
	var absent: Dictionary = burst_drill_build_state.source_drill_should_consume_state({"enabled": true}, 10.0, true)
	proof["gate_absent_items_total_defaults_zero"] = bool(absent.get("should_consume", false)) == true

	# Eruption def uses capacity 60: items_total=55 < 60
	# passes, while the same totals against the
	# impact-drill capacity 40 would read 55 < 40 as
	# false. This distinguishes the per-def capacity.
	var eruption: Dictionary = burst_drill_build_state.source_drill_should_consume_state({"items_total": 55.0, "enabled": true}, 60.0, true)
	var eruption_impact_capacity: Dictionary = burst_drill_build_state.source_drill_should_consume_state({"items_total": 55.0, "enabled": true}, 40.0, true)
	proof["gate_eruption_def_uses_capacity_60"] = bool(eruption.get("should_consume", false)) == true and bool(eruption_impact_capacity.get("should_consume", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07DrillShouldConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
