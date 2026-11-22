extends Node

const main_scene := preload("res://scenes/Main.tscn")
const bullet_damage_state := preload("res://src/game/SourceBulletTypeDamageState.gd")
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

	# --- BulletType estimateDPS() (N2529): `public float estimateDPS(){` /
	# `if(cachedDps >= 0f) return cachedDps;` /
	# `if(spawnUnit != null){` / `return spawnUnit.estimateDps();` /
	# `if(despawnUnit != null){` / `return despawnUnit.estimateDps();` /
	# `float sum = (damage + splashDamage*0.75f) * (pierce ? pierceCap == -1 ? 2 : Mathf.clamp(pierceCap, 1, 2) : 1f);` /
	# `if(fragBullet != null && fragBullet != this){` /
	# `sum += fragBullet.estimateDPS() * fragBullets / 2f;` /
	# `for(var other : spawnBullets){` / `sum += other.estimateDPS();` /
	# `return cachedDps = sum;`
	# (BulletType.java:414-435). The legs run in exact Java order:
	# the cache hit returns first; the spawnUnit / despawnUnit
	# legs return the unit DPS WITHOUT writing the cache; only
	# the computed leg writes the cache (returned through the
	# `cached_dps` key). `damage` is the BulletType field
	# (`public float damage = 1f;`, BulletType.java:41);
	# `splash_damage` is the field (`public float splashDamage
	# = 0f;`, BulletType.java:109); `pierce` is the field
	# (`public boolean pierce;`, BulletType.java:53);
	# `pierce_cap` is the field (`public int pierceCap = -1;`,
	# BulletType.java:57); `cached_dps` is the runtime cache
	# (`protected float cachedDps = -1;`, BulletType.java:377).
	# `spawn_unit_dps` / `despawn_unit_dps` are float params --
	# UnitType.estimateDps() (UnitType.java:1132-1144) is NOT
	# ported yet. `has_frag_bullet` is the caller-side
	# `fragBullet != this` guard (self-frag passes false).
	# `frag_bullets` is the field (`public int fragBullets =
	# 9;`, BulletType.java:212). `spawn_bullets_dps_sum` is the
	# caller-summed `estimateDPS()` of every `spawnBullets`
	# entry. The proof drives the pure function on exact legs:
	# 1 cache hit -> 42.0, cached unchanged; 2 spawn unit ->
	# 55.0, cached stays -1 (spawn wins over despawn); 3
	# despawn unit -> 33.0, cached stays -1; 4 pierceCap -1 ->
	# x2 (damage 10 -> 20.0); 5 pierceCap clamped 5 -> x2 and
	# 0 -> x1 (damage 10 -> 20.0 / 10.0); 6 no pierce -> x1
	# (damage 10 -> 10.0); 7 frag + splash + spawn bullets:
	# (10 + 4 * 0.75) * 1 + 6 * 9 / 2 + 5 = 45.0, cached 45.0;
	# 8 Java defaults (damage 1, no pierce, no frag, no spawn
	# bullets) -> 1.0.

	# Phase 1: cache hit -> 42.0, cached unchanged, branch
	# "cached" (the `cachedDps >= 0f` leg fires first, even
	# with a spawn unit present).
	var estimate: Dictionary = bullet_damage_state.source_bullet_type_estimate_dps_state(10.0, 0.0, false, -1, 42.0, true, 55.0, false, 0.0, false, 0.0, 9, 0.0)
	proof["estimate_dps_cached_hit"] = is_equal_approx(float(estimate.get("estimate_dps", -1.0)), 42.0) and is_equal_approx(float(estimate.get("cached_dps", -2.0)), 42.0) and String(estimate.get("branch", "")) == "cached"

	# Phase 2: spawn unit -> 55.0, cached stays -1, branch
	# "spawn_unit" (spawn wins over despawn when both are
	# present; Java returns before the cache-write line).
	estimate = bullet_damage_state.source_bullet_type_estimate_dps_state(10.0, 0.0, false, -1, -1.0, true, 55.0, true, 33.0, false, 0.0, 9, 0.0)
	proof["estimate_dps_spawn_unit"] = is_equal_approx(float(estimate.get("estimate_dps", -1.0)), 55.0) and is_equal_approx(float(estimate.get("cached_dps", -2.0)), -1.0) and String(estimate.get("branch", "")) == "spawn_unit"

	# Phase 3: despawn unit -> 33.0, cached stays -1, branch
	# "despawn_unit".
	estimate = bullet_damage_state.source_bullet_type_estimate_dps_state(10.0, 0.0, false, -1, -1.0, false, 0.0, true, 33.0, false, 0.0, 9, 0.0)
	proof["estimate_dps_despawn_unit"] = is_equal_approx(float(estimate.get("estimate_dps", -1.0)), 33.0) and is_equal_approx(float(estimate.get("cached_dps", -2.0)), -1.0) and String(estimate.get("branch", "")) == "despawn_unit"

	# Phase 4: pierceCap -1 -> x2: (10 + 0 * 0.75) * 2 =
	# 20.0, cached 20.0, branch "computed".
	estimate = bullet_damage_state.source_bullet_type_estimate_dps_state(10.0, 0.0, true, -1, -1.0, false, 0.0, false, 0.0, false, 0.0, 9, 0.0)
	proof["estimate_dps_pierce_cap_minus_one"] = is_equal_approx(float(estimate.get("estimate_dps", -1.0)), 20.0) and is_equal_approx(float(estimate.get("cached_dps", -2.0)), 20.0) and String(estimate.get("branch", "")) == "computed"

	# Phase 5: pierceCap clamped: cap 5 -> clamp to 2 ->
	# 20.0; cap 0 -> clamp to 1 -> 10.0.
	estimate = bullet_damage_state.source_bullet_type_estimate_dps_state(10.0, 0.0, true, 5, -1.0, false, 0.0, false, 0.0, false, 0.0, 9, 0.0)
	var clamped_high: bool = is_equal_approx(float(estimate.get("estimate_dps", -1.0)), 20.0)
	estimate = bullet_damage_state.source_bullet_type_estimate_dps_state(10.0, 0.0, true, 0, -1.0, false, 0.0, false, 0.0, false, 0.0, 9, 0.0)
	var clamped_low: bool = is_equal_approx(float(estimate.get("estimate_dps", -1.0)), 10.0)
	proof["estimate_dps_pierce_cap_clamped"] = clamped_high and clamped_low

	# Phase 6: no pierce -> x1: (10 + 0 * 0.75) * 1 = 10.0.
	estimate = bullet_damage_state.source_bullet_type_estimate_dps_state(10.0, 0.0, false, -1, -1.0, false, 0.0, false, 0.0, false, 0.0, 9, 0.0)
	proof["estimate_dps_no_pierce"] = is_equal_approx(float(estimate.get("estimate_dps", -1.0)), 10.0) and is_equal_approx(float(estimate.get("cached_dps", -2.0)), 10.0) and String(estimate.get("branch", "")) == "computed"

	# Phase 7: frag + splash + spawn bullets: (10 + 4 *
	# 0.75) * 1 + 6 * 9 / 2 + 5 = 13 + 27 + 5 = 45.0, cached
	# 45.0, branch "computed".
	estimate = bullet_damage_state.source_bullet_type_estimate_dps_state(10.0, 4.0, false, -1, -1.0, false, 0.0, false, 0.0, true, 6.0, 9, 5.0)
	proof["estimate_dps_frag_and_splash"] = is_equal_approx(float(estimate.get("estimate_dps", -1.0)), 45.0) and is_equal_approx(float(estimate.get("cached_dps", -2.0)), 45.0) and String(estimate.get("branch", "")) == "computed"

	# Phase 8: Java defaults (damage 1, splash 0, no pierce,
	# pierceCap -1, cached -1, no spawn/despawn/frag, no spawn
	# bullets) -> (1 + 0) * 1 = 1.0.
	estimate = bullet_damage_state.source_bullet_type_estimate_dps_state(1.0, 0.0, false, -1, -1.0, false, 0.0, false, 0.0, false, 0.0, 9, 0.0)
	proof["estimate_dps_java_defaults"] = is_equal_approx(float(estimate.get("estimate_dps", -1.0)), 1.0) and is_equal_approx(float(estimate.get("cached_dps", -2.0)), 1.0) and String(estimate.get("branch", "")) == "computed"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BulletTypeEstimateDpsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
