extends Node

const main_scene := preload("res://scenes/Main.tscn")
const point_defense_turret_build_state := preload("res://src/game/SourcePointDefenseTurretBuildState.gd")
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

	# --- setStats() rows + icons() return array (N2246):
	# PointDefenseTurret.setStats()
	# (PointDefenseTurret.java:51-57, `public void setStats(){`)
	# adds two unconditional stat rows on top of the
	# `super.setStats();` base chain (:53, NOT this slice --
	# the N2224 RepairTurret setStats precedent):
	# `stats.add(Stat.reload, 60f / reload,
	# StatUnit.perSecond);` (:55) and `stats.add(Stat.damage,
	# bulletDamage, StatUnit.none);` (:56). The ReloadTurret
	# booster replace (`if(coolant != null){` /
	# `stats.replace(Stat.booster, StatValues.boosters(reload,
	# coolant.amount, coolantMultiplier, true,
	# coolant::consumes));`, ReloadTurret.java:20-21) is a
	# no-op for segment, which defines NO coolant consumer
	# (Blocks.java:3835-3845, the N2241 precedent).
	# PointDefenseTurret.icons()
	# (PointDefenseTurret.java:46-49, `@Override public
	# TextureRegion[] icons(){`) returns the two loaded
	# regions in order (`return new
	# TextureRegion[]{baseRegion, region};`, :48); baseRegion
	# is the block's own base field (`public @Load(value =
	# "@-base", fallback = "block-@size") TextureRegion
	# baseRegion;`, PointDefenseTurret.java:24) and region is
	# the inherited block region (`public TextureRegion
	# region;`, Block.java:427). The proof calls the pure
	# functions directly with per-def params (no live tick:
	# setStats/icons are display reads).

	# Reload-per-second at the class default: 60 / 30 = 2.0
	# (`reload = 30f;`, PointDefenseTurret.java:40).
	var stats_default: Dictionary = point_defense_turret_build_state.source_point_defense_turret_set_stats_state(30.0, 10.0)
	proof["set_stats_reload_per_second_default"] = is_equal_approx(float(stats_default.get("reload_per_second", -1.0)), 2.0)

	# Reload-per-second at the segment def: 60 / 8 = 7.5
	# (`reload = 8f;`, Blocks.java:3845).
	var stats_segment: Dictionary = point_defense_turret_build_state.source_point_defense_turret_set_stats_state(8.0, 30.0)
	proof["set_stats_reload_per_second_segment"] = is_equal_approx(float(stats_segment.get("reload_per_second", -1.0)), 7.5)

	# Damage at the class default: 10.0 (`public float
	# bulletDamage = 10f;`, PointDefenseTurret.java:33).
	proof["set_stats_damage_default"] = is_equal_approx(float(stats_default.get("damage", -1.0)), 10.0)

	# Damage at the segment def: 30.0 (`bulletDamage =
	# 30f;`, Blocks.java:3844).
	proof["set_stats_damage_segment"] = is_equal_approx(float(stats_segment.get("damage", -1.0)), 30.0)

	# setStats returns ONLY the two PointDefenseTurret-own
	# rows: the super chain (ReloadTurret booster, BaseTurret
	# shootRange, Block base rows) is not re-emitted here.
	proof["set_stats_returns_only_two_rows"] = stats_segment.size() == 2

	# Icons at the segment def: ["segment-base", "segment"]
	# -- baseRegion loads "@-base" (name + "-base"), region
	# is the block's own region (the block name);
	# Blocks.java:3835 (`segment = new
	# PointDefenseTurret("segment"){{`).
	var icons: Dictionary = point_defense_turret_build_state.source_point_defense_turret_icons_state("segment-base", "segment")
	proof["icons_segment"] = icons.get("icons", []) == ["segment-base", "segment"]

	# Icons returns exactly two regions.
	proof["icons_length_two"] = (icons.get("icons", []) as Array).size() == 2

	# Icons returns base first: baseRegion before region.
	proof["icons_base_first"] = (icons.get("icons", []) as Array)[0] == "segment-base"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PointDefenseTurretSetStatsIconsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
