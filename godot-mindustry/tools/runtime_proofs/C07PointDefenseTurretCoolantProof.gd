extends Node

const main_scene := preload("res://scenes/Main.tscn")
const point_defense_turret_build_state := preload("res://src/game/SourcePointDefenseTurretBuildState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _liquid_rows() -> Array:
	# Synthetic liquid rows in content order (the N2241
	# synthetic-inputs precedent): the catalog cannot supply
	# these rows, its liquid entries carry heatCapacity only, and
	# coolant / gas / temperature / flammability are Java class
	# defaults (Liquid.java:50 `public boolean coolant = true;` /
	# :28 `public boolean gas = false;` / :40 `public float
	# temperature = 0.5f;` / :38 `public float flammability;`
	# (0f)). Water passes the filter (temperature 0.5, flammability
	# 0.0); slag fails on temperature 1.0; oil fails on
	# flammability 1.2; ozone fails as a gas.
	return [
		{"id": 0, "name": "water", "coolant": true, "gas": false, "temperature": 0.5, "flammability": 0.0, "heat_capacity": 0.5},
		{"id": 1, "name": "slag", "coolant": true, "gas": false, "temperature": 1.0, "flammability": 0.0, "heat_capacity": 0.5},
		{"id": 2, "name": "oil", "coolant": true, "gas": false, "temperature": 0.5, "flammability": 1.2, "heat_capacity": 0.5},
		{"id": 3, "name": "ozone", "coolant": true, "gas": true, "temperature": 0.5, "flammability": 0.0, "heat_capacity": 0.5},
	]


func _liquids(amounts: Array, current: int) -> Dictionary:
	# The live liquids dict in the SourceLiquidModuleState shape
	# ({"liquids": Array[float] by liquid id, "current": int id,
	# "flow": null}).
	return {"liquids": amounts, "current": current, "flow": null}


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

	# --- PointDefenseTurret live coolant (N2248): the
	# ConsumeCoolant filter (ConsumeCoolant.java:14,
	# `liquid.coolant && (this.allowLiquid && !liquid.gas ||
	# this.allowGas && liquid.gas) && liquid.temperature <=
	# maxTemp && liquid.flammability < maxFlammability`,
	# defaults allowLiquid=true, allowGas=false) over the live
	# liquids dict, then the ConsumeLiquidFilter getConsumed pick
	# (ConsumeLiquidFilter.java:63-79, current liquid first if
	# the filter passes and its amount is > 0, else the first
	# liquid in content order passing the filter with amount >
	# 0), the efficiency (ConsumeLiquidFilter.java:50-56,
	# `min(liquids.get(liq) / (amount * ed * multiplier), 1f)`,
	# 0 when ed <= 1e-8 or no liquid), the update removal
	# (ConsumeLiquidFilter.java:44-49, `liquids.remove(liq,
	# amount * edelta * multiplier)` -- the consumer amount
	# field, NOT the efficiency-scaled local amount), the
	# consumed liquid's heatCapacity (ReloadTurret.java:30, the
	# ConsumeLiquidFilter filter branch), and the coolEffect
	# chance key (`Mathf.chance(0.06 * amount)`,
	# ReloadTurret.java:35, a random visual -- the pure function
	# returns the chance, it never rolls, the N2240 precedent).
	# One segment, sequential phases: 1 water passes the filter,
	# 2 slag fails on temperature 1.0, 3 oil fails on flammability
	# 1.2, 4 ozone fails as a gas, 5 the current liquid wins even
	# when it is not first in content order, 6 the fallback picks
	# the first passing liquid in content order, 7 a partial
	# efficiency fraction, 8 zero efficiency with no coolant
	# liquid, 9 removal is amount * edelta * multiplier, 10 the
	# coolEffect chance is 0.06 * amount * efficiency, 11 the
	# edelta guard at 1e-8 returns 0, 12 the driver stays a no-op
	# for a segment with no catalog coolant consumer (reload
	# counter unchanged, liquids meta untouched).
	var rows: Array = _liquid_rows()

	# Phase 1: water passes the filter -- current water with
	# amount 5.0 is consumed, efficiency saturates at 1.0.
	var coolant: Dictionary = point_defense_turret_build_state.source_point_defense_turret_coolant_state(_liquids([5.0, 0.0, 0.0, 0.0], 0), rows, 1.0, 1.0, 1.0)
	proof["coolant_filter_passes_water"] = str(coolant.get("consumed_liquid", "")) == "water" and int(coolant.get("consumed_index", -1)) == 0 and int(coolant.get("checked_liquids", -1)) == 1 and float(coolant.get("coolant_efficiency", -1.0)) == 1.0 and float(coolant.get("heat_capacity", -1.0)) == 0.5

	# Phase 2: slag fails on temperature 1.0 -- current slag is
	# rejected and no other liquid has an amount, so nothing is
	# consumed (all five filter evaluations counted).
	coolant = point_defense_turret_build_state.source_point_defense_turret_coolant_state(_liquids([0.0, 5.0, 0.0, 0.0], 1), rows, 1.0, 1.0, 1.0)
	proof["coolant_filter_rejects_hot_liquid"] = coolant.get("consumed_liquid", "water") == null and int(coolant.get("consumed_index", 0)) == -1 and int(coolant.get("checked_liquids", -1)) == 5 and float(coolant.get("coolant_efficiency", -1.0)) == 0.0

	# Phase 3: oil fails on flammability 1.2 -- same shape as
	# the hot-liquid phase, nothing consumed.
	coolant = point_defense_turret_build_state.source_point_defense_turret_coolant_state(_liquids([0.0, 0.0, 5.0, 0.0], 2), rows, 1.0, 1.0, 1.0)
	proof["coolant_filter_rejects_flammable_liquid"] = coolant.get("consumed_liquid", "water") == null and int(coolant.get("consumed_index", 0)) == -1 and int(coolant.get("checked_liquids", -1)) == 5 and float(coolant.get("coolant_efficiency", -1.0)) == 0.0

	# Phase 4: ozone fails as a gas (allowGas=false) -- nothing
	# consumed.
	coolant = point_defense_turret_build_state.source_point_defense_turret_coolant_state(_liquids([0.0, 0.0, 0.0, 5.0], 3), rows, 1.0, 1.0, 1.0)
	proof["coolant_filter_rejects_gas"] = coolant.get("consumed_liquid", "water") == null and int(coolant.get("consumed_index", 0)) == -1 and int(coolant.get("checked_liquids", -1)) == 5 and float(coolant.get("coolant_efficiency", -1.0)) == 0.0

	# Phase 5: the current liquid wins even when it is not first
	# in content order -- rows [slag, water], current water:
	# only the current row is evaluated.
	var swapped_rows: Array = [rows[1], rows[0]]
	coolant = point_defense_turret_build_state.source_point_defense_turret_coolant_state(_liquids([5.0, 5.0, 0.0, 0.0], 0), swapped_rows, 1.0, 1.0, 1.0)
	proof["coolant_prefers_current_liquid"] = str(coolant.get("consumed_liquid", "")) == "water" and int(coolant.get("consumed_index", -1)) == 0 and int(coolant.get("checked_liquids", -1)) == 1

	# Phase 6: the fallback picks the first passing liquid in
	# content order -- rows [slag, water, oil], current slag
	# (fails the filter): slag, then slag again, then water.
	var fallback_rows: Array = [rows[1], rows[0], rows[2]]
	coolant = point_defense_turret_build_state.source_point_defense_turret_coolant_state(_liquids([5.0, 5.0, 0.0, 0.0], 1), fallback_rows, 1.0, 1.0, 1.0)
	proof["coolant_falls_back_to_first_passing_liquid"] = str(coolant.get("consumed_liquid", "")) == "water" and int(coolant.get("consumed_index", -1)) == 0 and int(coolant.get("checked_liquids", -1)) == 3

	# Phase 7: a partial efficiency fraction -- water 0.5
	# against amount 1.0 * edelta 1.0 * multiplier 1.0.
	coolant = point_defense_turret_build_state.source_point_defense_turret_coolant_state(_liquids([0.5, 0.0, 0.0, 0.0], 0), rows, 1.0, 1.0, 1.0)
	proof["coolant_efficiency_partial_fraction"] = float(coolant.get("coolant_efficiency", -1.0)) == 0.5

	# Phase 8: zero efficiency with no coolant liquid -- every
	# amount is 0, so nothing is consumed.
	coolant = point_defense_turret_build_state.source_point_defense_turret_coolant_state(_liquids([0.0, 0.0, 0.0, 0.0], 0), rows, 1.0, 1.0, 1.0)
	proof["coolant_efficiency_zero_without_liquid"] = coolant.get("consumed_liquid", "water") == null and float(coolant.get("coolant_efficiency", -1.0)) == 0.0 and float(coolant.get("remove_amount", -1.0)) == 0.0

	# Phase 9: removal is amount * edelta * multiplier -- the
	# consumer amount field, NOT the efficiency-scaled local
	# amount: 0.2 * 1.0 * 1.0.
	coolant = point_defense_turret_build_state.source_point_defense_turret_coolant_state(_liquids([5.0, 0.0, 0.0, 0.0], 0), rows, 0.2, 1.0, 1.0)
	proof["coolant_removes_live_amount"] = float(coolant.get("remove_amount", -1.0)) == 0.2

	# Phase 10: the coolEffect chance is 0.06 * amount *
	# efficiency -- water 2.0 saturates efficiency at 1.0, so
	# the chance is 0.06 * 1.0 * 1.0.
	coolant = point_defense_turret_build_state.source_point_defense_turret_coolant_state(_liquids([2.0, 0.0, 0.0, 0.0], 0), rows, 1.0, 1.0, 1.0)
	proof["coolant_cool_effect_chance"] = float(coolant.get("coolant_efficiency", -1.0)) == 1.0 and float(coolant.get("cool_effect_chance", -1.0)) == 0.06

	# Phase 11: the edelta guard at 1e-8 returns 0 -- edelta
	# 0.000000001 is below the `if(ed <= 0.00000001f)` guard.
	coolant = point_defense_turret_build_state.source_point_defense_turret_coolant_state(_liquids([5.0, 0.0, 0.0, 0.0], 0), rows, 1.0, 0.000000001, 1.0)
	proof["coolant_edelta_guard_zero"] = float(coolant.get("coolant_efficiency", -1.0)) == 0.0 and float(coolant.get("cool_effect_chance", -1.0)) == 0.0

	# Phase 12: the driver stays a no-op for a segment with no
	# catalog coolant consumer -- the tick leaves the seeded
	# reload counter untouched and the sprite liquids meta
	# untouched (the driver never reads it for point defense).
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var cell := Vector2i(28, 21)
	var segment := Sprite2D.new()
	game.add_child(segment)
	game.call("record_placed_block", segment, blocks_by_id["segment"], cell)
	segment.position = game.source_block_sprite_base_position(blocks_by_id["segment"], cell)
	point_defense_turret_build_state.source_point_defense_turret_bind_frame_state(segment, blocks_by_id["segment"])
	var frame: Dictionary = segment.get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})
	frame["power_status"] = 1.0
	frame["reload_counter"] = 3.0
	segment.set_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, _liquids([5.0, 0.0, 0.0, 0.0], 0))
	point_defense_turret_build_state.source_point_defense_turret_tick_buildings_state(game, 1.0 / 60.0)
	frame = segment.get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})
	var liquids_after: Dictionary = segment.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	var amounts_after: Array = liquids_after.get("liquids", [])
	proof["driver_noop_without_catalog_coolant"] = float(frame.get("reload_counter", -1.0)) == 3.0 and int(liquids_after.get("current", -1)) == 0 and amounts_after.size() == 4 and float(amounts_after[0]) == 5.0

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PointDefenseTurretCoolantProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
