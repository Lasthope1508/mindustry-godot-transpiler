extends Node

const main_scene := preload("res://scenes/Main.tscn")
const drill_build_state := preload("res://src/game/SourceBurstDrillBuildState.gd")
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

	# --- Drill.canPlaceOn() + setBars() + drawPlanConfig() (N2330):
	# Drill.canPlaceOn() (Drill.java:126-137,
	# `public boolean canPlaceOn(Tile tile, Team team,
	# int rotation){`): `if(isMultiblock()){`
	# (:127) with `for(Tile other : tile.
	# getLinkedTilesAs(this, tempTiles)){` (:128)
	# and `if(canMine(other)){` (:129) then
	# `return true;` (:130), else `return false;`
	# (:133); the single-tile leg is `return
	# canMine(tile);` (:135). isMultiblock() is
	# `public boolean isMultiblock(){` with
	# `return size > 1;` (Block.java:1014-1016).
	# Drill.setBars() (Drill.java:114-121,
	# `public void setBars(){`): `super.setBars();`
	# (:115, Block.setBars, Block.java:696-746) then
	# `addBar("drillspeed", (DrillBuild e) ->`
	# (:117) with `new Bar(() -> Core.bundle.
	# format("bar.drillspeed", Strings.fixed(
	# e.lastDrillSpeed * 60 * e.timeScale(), 2)),
	# () -> Pal.ammo, () -> e.warmup));` (:118).
	# The bundle value is `bar.drillspeed = Drill
	# Speed: {0}/s` (bundle.properties:1279); the
	# fixed text is Strings.fixedBuilder truncation
	# at 2 decimals (arc Strings.java:729-760).
	# Pal.ammo is `ammo = Color.valueOf("ff8947"),`
	# (Pal.java:64). Drill.drawPlanConfig()
	# (Drill.java:100-111, `public void
	# drawPlanConfig(BuildPlan plan, Eachable
	# <BuildPlan> list){`): `if(!plan.worldContext)
	# return;`, `Tile tile = plan.tile();`,
	# `if(tile == null) return;`, `countOre(tile);`,
	# `if(returnItem == null || !drawMineItem)
	# return;`, `Draw.tint(returnItem.color);`,
	# `Draw.rect(itemRegion, plan.drawx(),
	# plan.drawy());`, `Draw.color();`. canMine()
	# and countOre() are N2010 -- NOT this slice:
	# the caller passes the already-computed
	# results. There is NO driver tick line:
	# canPlaceOn is a placement predicate, setBars
	# is a load-time bar spec, and drawPlanConfig
	# is per-frame plan render state.

	# Per-def inputs (Blocks.java:2865-2915):
	# mechanical/pneumatic-drill `size = 2;`,
	# laser-drill `size = 3;`, blast-drill
	# `size = 4;` -- every Drill def is multiblock
	# (`return size > 1;`). Class defaults
	# (Drill.java:47,51,74,239,241): `protected
	# @Nullable Item returnItem;`, `public boolean
	# drawMineItem = true;`, `public @Load(value =
	# "@-item", fallback = "drill-item-@size")
	# TextureRegion itemRegion;`, `public float
	# warmup;`, `public float lastDrillSpeed;`.
	var item_color := Color("d8a24a")
	var ammo_color := Color("ff8947")

	# canPlaceOn multiblock: true on the first
	# minable linked tile, false when none mines,
	# false with no linked tiles at all.
	var multi_hit: Dictionary = drill_build_state.source_drill_can_place_on_state({}, true, [false, true, false], false)
	var multi_miss: Dictionary = drill_build_state.source_drill_can_place_on_state({}, true, [false, false], true)
	var multi_empty: Dictionary = drill_build_state.source_drill_can_place_on_state({}, true, [], true)
	proof["can_place_on_multiblock"] = bool(multi_hit.get("can_place_on", false)) == true and bool(multi_miss.get("can_place_on", true)) == false and bool(multi_empty.get("can_place_on", true)) == false

	# canPlaceOn single-tile: the tile_can_mine
	# leg, straight through.
	var single_yes: Dictionary = drill_build_state.source_drill_can_place_on_state({}, false, [], true)
	var single_no: Dictionary = drill_build_state.source_drill_can_place_on_state({}, false, [true, true], false)
	proof["can_place_on_single"] = bool(single_yes.get("can_place_on", false)) == true and bool(single_no.get("can_place_on", true)) == false

	# setBars text: lastDrillSpeed 0.5 at timeScale
	# 1 gives rate 30 -> "Drill Speed: 30.00/s";
	# lastDrillSpeed 0.12365 gives rate 7.419 ->
	# truncated "Drill Speed: 7.41/s" (round would
	# give 7.42); lastDrillSpeed 0 gives
	# "Drill Speed: 0.00/s".
	var bars: Dictionary = drill_build_state.source_drill_set_bars_state({}, {}, 0.5, 1.0, 0.75)
	var bars_trunc: Dictionary = drill_build_state.source_drill_set_bars_state({}, {}, 0.12365, 1.0, 0.25)
	var bars_zero: Dictionary = drill_build_state.source_drill_set_bars_state({}, {}, 0.0, 1.0, 0.0)
	proof["set_bars_text"] = String(bars.get("bar_text", "")) == "Drill Speed: 30.00/s" and String(bars_trunc.get("bar_text", "")) == "Drill Speed: 7.41/s" and String(bars_zero.get("bar_text", "")) == "Drill Speed: 0.00/s"

	# setBars spec: key "drillspeed", Pal.ammo
	# color "ff8947", fraction is the warmup.
	var bars_color: Color = bars.get("bar_color", Color.BLACK)
	proof["set_bars_spec"] = String(bars.get("bar_key", "")) == "drillspeed" and bars_color.is_equal_approx(ammo_color) and is_equal_approx(float(bars.get("bar_fraction", -1.0)), 0.75) and is_equal_approx(float(bars_trunc.get("bar_fraction", -1.0)), 0.25)

	# drawPlanConfig visible: worldContext + tile
	# + returnItem + drawMineItem, tinted in the
	# return item color, rect at the plan draw
	# position.
	var plan: Dictionary = drill_build_state.source_drill_draw_plan_config_state({}, true, true, "copper", item_color, true, "mechanical-drill-item", 100.0, 200.0)
	var plan_rect: Dictionary = plan.get("item_rect", {})
	var plan_tint: Color = plan.get("tint_color", Color.BLACK)
	proof["draw_plan_config_visible"] = bool(plan.get("visible", false)) == true and plan_tint.is_equal_approx(item_color) and String(plan_rect.get("region", "")) == "mechanical-drill-item" and is_equal_approx(float(plan_rect.get("x", -1.0)), 100.0) and is_equal_approx(float(plan_rect.get("y", -1.0)), 200.0)

	# drawPlanConfig hidden: each guard leg hides
	# it -- no worldContext, no tile, no return
	# item, drawMineItem off.
	var no_context: Dictionary = drill_build_state.source_drill_draw_plan_config_state({}, false, true, "copper", item_color, true, "mechanical-drill-item", 100.0, 200.0)
	var no_tile: Dictionary = drill_build_state.source_drill_draw_plan_config_state({}, true, false, "copper", item_color, true, "mechanical-drill-item", 100.0, 200.0)
	var no_item: Dictionary = drill_build_state.source_drill_draw_plan_config_state({}, true, true, null, item_color, true, "mechanical-drill-item", 100.0, 200.0)
	var no_draw: Dictionary = drill_build_state.source_drill_draw_plan_config_state({}, true, true, "copper", item_color, false, "mechanical-drill-item", 100.0, 200.0)
	proof["draw_plan_config_hidden"] = bool(no_context.get("visible", true)) == false and no_context.get("tint_color", {}) == null and no_context.get("item_rect", {}) == null and bool(no_tile.get("visible", true)) == false and no_tile.get("tint_color", {}) == null and no_tile.get("item_rect", {}) == null and bool(no_item.get("visible", true)) == false and no_item.get("tint_color", {}) == null and no_item.get("item_rect", {}) == null and bool(no_draw.get("visible", true)) == false and no_draw.get("tint_color", {}) == null and no_draw.get("item_rect", {}) == null

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07DrillCanPlaceOnSetBarsDrawPlanConfigProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
