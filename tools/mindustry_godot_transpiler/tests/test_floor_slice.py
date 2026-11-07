import re
import unittest
from pathlib import Path

from mindustry_port import source_parity

ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


class FloorSliceTests(unittest.TestCase):
    def test_floor_method_block_is_generated_and_delegated(self):
        source = (PROJECT / "src/generated/classes/mindustry/world/blocks/environment/Floor.gd").read_text(encoding="utf-8")
        self.assertIn('const source_floor_state := preload("res://src/game/SourceFloorState.gd")', source)
        for name, index in (("getDisplayIcon", 2), ("getDisplayName", 3), ("drawBase", 5), ("drawMain", 6), ("drawOverlay", 10), ("variant", 8), ("checkAutotileSame", 7), ("icons", 11), ("floorChanged", 12), ("shouldIndex", 13), ("updateRender", 14), ("renderUpdate", 15), ("hasSurface", 16), ("isDeep", 17), ("drawNonLayer", 18), ("drawBlended", 20), ("realBlendId", 21), ("edges", 22), ("edge", 23), ("doEdge", 24), ("damages", 25)):
            body = re.search(rf"func java_method_{name}_{index}\(_args: Array = \[\]\) -> Variant:\n(?P<body>.*?)(?=\nfunc |\Z)", source, re.S)
            self.assertIsNotNone(body)
            self.assertIn("source_floor_state.", body.group("body"))
            self.assertNotIn("return null", body.group("body"))

    def test_floor_source_text_and_registry_are_canonical(self):
        import json

        text = (PROJECT / "src/game/SourceFloorSourceTextState.gd").read_text(encoding="utf-8")
        for literal in ("Floor.java", "return !isLiquid && !solid;", "return drownTime > 0;", "return damageTaken > 0f"):
            self.assertIn(literal, text)
        generated = PROJECT / "src/generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        for symbol in ("floor.should_index", "floor.update_render", "floor.render_update", "floor.has_surface", "floor.is_deep", "floor.damages"):
            self.assertEqual(registry["symbols"][symbol]["source_slice"], "N1785")
            self.assertEqual(registry["symbols"][symbol]["java_source"], "core/src/mindustry/world/blocks/environment/Floor.java")
        self.assertEqual(ledger["slices"]["N1785"]["status"], "done")

    def test_floor_edge_cluster_preserves_upstream_blend_contract(self):
        source_text = (PROJECT / "src/game/SourceFloorSourceTextState.gd").read_text(encoding="utf-8")
        state = (PROJECT / "src/game/SourceFloorState.gd").read_text(encoding="utf-8")
        bridge = (PROJECT / "src/game/SourceBlockRuntimePortBridge.gd").read_text(encoding="utf-8")
        for literal in (
            'const REAL_BLEND_ID_RETURN := "return -((tile.overlay().blendId) | (tile.floor().blendId << 15));"',
            'const EDGES_RETURN := "return blendGroup.asFloor().edges;"',
            'const EDGE_RETURN := "return edges(x, y)[rx][2 - ry];"',
            'const DO_EDGE_RETURN := "return (other.realBlendId(otherTile) > realBlendId(tile) || edges(tile.x, tile.y) == null);"',
        ):
            self.assertIn(literal, source_text)
        for function_name in ("real_blend_id_state", "edges_state", "edge_state", "do_edge_state"):
            self.assertIn(f"static func {function_name}", state)
            self.assertIn(f"func source_floor_{function_name.removesuffix('_state')}_state", bridge)
        self.assertIn("int(tile_floor_blend_id) << 15", state)
        self.assertIn("2 - ry", state)
        self.assertIn("other_real_blend_id > self_real_blend_id or not edges_present", state)

    def test_floor_edge_cluster_is_registered_as_one_canonical_slice(self):
        import json

        generated = PROJECT / "src/generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        for symbol in ("floor.real_blend_id", "floor.edges", "floor.edge", "floor.do_edge"):
            entry = registry["symbols"][symbol]
            self.assertEqual(entry["source_slice"], "N1786")
            self.assertEqual(entry["java_source"], "core/src/mindustry/world/blocks/environment/Floor.java")
        self.assertEqual(ledger["slices"]["N1786"]["status"], "done")
        self.assertEqual(ledger["slices"]["N1786"]["godot_owner"], "PortGame.source_floor_state")

    def test_floor_render_cluster_preserves_source_call_plan(self):
        source_text = (PROJECT / "src/game/SourceFloorSourceTextState.gd").read_text(encoding="utf-8")
        state = (PROJECT / "src/game/SourceFloorState.gd").read_text(encoding="utf-8")
        for literal in (
            'const DRAW_NON_LAYER_CLEAR_DIRS := "Arrays.fill(dirs, 0);"',
            'const DRAW_NON_LAYER_GUARD := "if(other != null && other.floor().drawEdgeOut && other.floor().cacheLayer == layer && other.floor().edges(tile.x, tile.y) != null){"',
            'const DRAW_NON_LAYER_CALL := "drawBlended(tile, false);"',
            'const DRAW_BLENDED_SORT := "blenders.sort(a -> a.id + (tile.floor() != this && a == tile.floor() ? 99999 : 0));"',
            'const DRAW_BLENDED_RESOLVE := "Floor ob = (this == tile.floor() || other.overlay() == Blocks.air ? other.floor() : other.overlay());"',
            'const DRAW_BLENDED_CALL := "Draw.rect(region, tile.worldx(), tile.worldy());"',
        ):
            self.assertIn(literal, source_text)
        self.assertIn("static func draw_non_layer_state", state)
        self.assertIn("static func draw_blended_state", state)
        self.assertIn("draw_blended_state(blenders, neighbors, dirs, true, false)", state)

    def test_floor_render_cluster_is_registered_as_one_canonical_slice(self):
        import json

        generated = PROJECT / "src/generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        for symbol in ("floor.draw_non_layer", "floor.draw_blended"):
            entry = registry["symbols"][symbol]
            self.assertEqual(entry["source_slice"], "N1787")
            self.assertEqual(entry["java_source"], "core/src/mindustry/world/blocks/environment/Floor.java")
        self.assertEqual(ledger["slices"]["N1787"]["status"], "done")
        self.assertEqual(ledger["slices"]["N1787"]["godot_owner"], "PortGame.source_floor_state")

    def test_floor_draw_edges_reuses_do_edge_and_draw_blended_contracts(self):
        source_text = (PROJECT / "src/game/SourceFloorSourceTextState.gd").read_text(encoding="utf-8")
        state = (PROJECT / "src/game/SourceFloorState.gd").read_text(encoding="utf-8")
        bridge = (PROJECT / "src/game/SourceBlockRuntimePortBridge.gd").read_text(encoding="utf-8")
        for literal in (
            'const DRAW_EDGES_CACHE_LAYER := "CacheLayer realCache = tile.floor().cacheLayer;"',
            'const DRAW_EDGES_RESOLVE := "Floor ob = (this == tile.floor() || other.overlay() == Blocks.air ? other.floor() : other.overlay());"',
            'const DRAW_EDGES_GUARD := "if(ob.drawEdgeOut && doEdge(tile, other, ob) && other.floor().cacheLayer == realCache && ob.edges(tile.x, tile.y) != null){"',
            'const DRAW_EDGES_CALL := "drawBlended(tile, true);"',
        ):
            self.assertIn(literal, source_text)
        self.assertIn("static func draw_edges_state", state)
        self.assertIn("do_edge_state", state)
        self.assertIn("draw_blended_state(blenders, neighbors, dirs, tile_floor_is_this, true)", state)
        self.assertIn("func source_floor_draw_edges_state", bridge)

    def test_floor_draw_edges_is_registered_as_one_canonical_slice(self):
        import json

        generated = PROJECT / "src/generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        entry = registry["symbols"]["floor.draw_edges"]
        self.assertEqual(entry["source_slice"], "N1788")
        self.assertEqual(entry["java_source"], "core/src/mindustry/world/blocks/environment/Floor.java")
        self.assertEqual(ledger["slices"]["N1788"]["status"], "done")

    def test_floor_draw_base_dispatches_through_canonical_floor_renderer_contracts(self):
        source_text = (PROJECT / "src/game/SourceFloorSourceTextState.gd").read_text(encoding="utf-8")
        state = (PROJECT / "src/game/SourceFloorState.gd").read_text(encoding="utf-8")
        bridge = (PROJECT / "src/game/SourceBlockRuntimePortBridge.gd").read_text(encoding="utf-8")
        for literal in (
            'const METHOD_DRAW_BASE := "public void drawBase(Tile tile){"',
            'const DRAW_BASE_MAIN_CALL := "drawMain(tile);"',
            'const DRAW_BASE_EDGE_GUARD := "if(drawEdgeIn){"',
            'const DRAW_BASE_EDGES_CALL := "drawEdges(tile);"',
            'const DRAW_BASE_OVERLAY_CALL := "drawOverlay(tile);"',
            'const DRAW_BASE_LIQUID_OVERLAY_GUARD := "if(tile.overlay() != Blocks.air && tile.floor() == this && isLiquid){"',
            'const DRAW_BASE_ALPHA_CALL := "Draw.alpha(1f - overlayAlpha);"',
            'const DRAW_BASE_COLOR_CALL := "Draw.color();"',
        ):
            self.assertIn(literal, source_text)
        self.assertIn("static func draw_base_state", state)
        self.assertIn("draw_edges_called", state)
        self.assertIn("func source_floor_draw_base_state", bridge)

    def test_floor_draw_base_is_registered_as_one_canonical_slice(self):
        import json

        generated = PROJECT / "src/generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        entry = registry["symbols"]["floor.draw_base"]
        self.assertEqual(entry["source_slice"], "N1789")
        self.assertEqual(entry["java_source"], "core/src/mindustry/world/blocks/environment/Floor.java")
        self.assertEqual(ledger["slices"]["N1789"]["status"], "done")

    def test_floor_draw_overlay_reuses_draw_base_dependency(self):
        source_text = (PROJECT / "src/game/SourceFloorSourceTextState.gd").read_text(encoding="utf-8")
        state = (PROJECT / "src/game/SourceFloorState.gd").read_text(encoding="utf-8")
        bridge = (PROJECT / "src/game/SourceBlockRuntimePortBridge.gd").read_text(encoding="utf-8")
        for literal in (
            'const METHOD_DRAW_OVERLAY := "public void drawOverlay(Tile tile){"',
            'const DRAW_OVERLAY_GUARD := "if(floor != Blocks.air && floor != this){"',
            'const DRAW_OVERLAY_CALL := "floor.drawBase(tile);"',
        ):
            self.assertIn(literal, source_text)
        self.assertIn("static func draw_overlay_state", state)
        self.assertIn("draw_base_called", state)
        self.assertIn("func source_floor_draw_overlay_state", bridge)

    def test_floor_draw_overlay_is_registered_as_one_canonical_slice(self):
        import json

        generated = PROJECT / "src/generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        entry = registry["symbols"]["floor.draw_overlay"]
        self.assertEqual(entry["source_slice"], "N1790")
        self.assertEqual(entry["java_source"], "core/src/mindustry/world/blocks/environment/Floor.java")
        self.assertEqual(ledger["slices"]["N1790"]["status"], "done")

    def test_floor_variant_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_floor_variant_source"))
        report = source_parity.verify_floor_variant_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/environment/Floor.java")
        self.assertEqual(report["missing"], [])

    def test_floor_variant_reuses_canonical_random_seed_math(self):
        state = (PROJECT / "src/game/SourceFloorState.gd").read_text(encoding="utf-8")
        source_text = (PROJECT / "src/game/SourceFloorSourceTextState.gd").read_text(encoding="utf-8")
        self.assertIn("source_math_state.random_seed_int(packed_position, 0, bounded_max)", state)
        self.assertIn("Point2.pack(x, y)", source_text)
        self.assertIn("Math.max(0, max - 1)", source_text)

    def test_floor_check_autotile_same_uses_selected_layer_and_guard(self):
        source_text = (PROJECT / "src/game/SourceFloorSourceTextState.gd").read_text(encoding="utf-8")
        state = (PROJECT / "src/game/SourceFloorState.gd").read_text(encoding="utf-8")
        bridge = (PROJECT / "src/game/SourceBlockRuntimePortBridge.gd").read_text(encoding="utf-8")
        for literal in (
            'const METHOD_CHECK_AUTOTILE_SAME := "public boolean checkAutotileSame(Tile tile, @Nullable Tile other){"',
            'const CHECK_AUTOTILE_SAME_RETURN := "return other != null && (this == tile.floor() ? other.floor() : other.overlay()).blendGroup == blendGroup;"',
        ):
            self.assertIn(literal, source_text)
        self.assertIn("static func check_autotile_same_state", state)
        self.assertIn("other_floor_matches if tile_floor_is_this else other_overlay_matches", state)
        self.assertIn("func source_floor_check_autotile_same_state", bridge)

    def test_floor_check_autotile_same_is_registered_as_one_canonical_slice(self):
        import json

        generated = PROJECT / "src/generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        entry = registry["symbols"]["floor.check_autotile_same"]
        self.assertEqual(entry["source_slice"], "N1792")
        self.assertEqual(entry["java_source"], "core/src/mindustry/world/blocks/environment/Floor.java")
        self.assertEqual(ledger["slices"]["N1792"]["status"], "done")

    def test_floor_icons_uses_canonical_atlas_fallback(self):
        source_text = (PROJECT / "src/game/SourceFloorSourceTextState.gd").read_text(encoding="utf-8")
        state = (PROJECT / "src/game/SourceFloorState.gd").read_text(encoding="utf-8")
        bridge = (PROJECT / "src/game/SourceBlockRuntimePortBridge.gd").read_text(encoding="utf-8")
        for literal in (
            'const METHOD_ICONS := "public TextureRegion[] icons(){"',
            'const ICONS_RETURN := "return new TextureRegion[]{Core.atlas.find(Core.atlas.has(name) ? name : name + \\\"1\\\")};"',
        ):
            self.assertIn(literal, source_text)
        self.assertIn("static func icons_state", state)
        self.assertIn('icon_name := name_value if atlas_has_name else name_value + "1"', state)
        self.assertIn("func source_floor_icons_state", bridge)

    def test_floor_icons_is_registered_as_one_canonical_slice(self):
        import json

        generated = PROJECT / "src/generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        entry = registry["symbols"]["floor.icons"]
        self.assertEqual(entry["source_slice"], "N1793")
        self.assertEqual(entry["java_source"], "core/src/mindustry/world/blocks/environment/Floor.java")
        self.assertEqual(ledger["slices"]["N1793"]["status"], "done")

    def test_floor_changed_is_source_backed_no_op(self):
        source_text = (PROJECT / "src/game/SourceFloorSourceTextState.gd").read_text(encoding="utf-8")
        state = (PROJECT / "src/game/SourceFloorState.gd").read_text(encoding="utf-8")
        bridge = (PROJECT / "src/game/SourceBlockRuntimePortBridge.gd").read_text(encoding="utf-8")
        self.assertIn('const METHOD_FLOOR_CHANGED := "public void floorChanged(Tile tile){}"', source_text)
        self.assertIn("static func floor_changed_state", state)
        self.assertIn('result["no_op"] = true', state)
        self.assertIn("func source_floor_floor_changed_state", bridge)

    def test_floor_changed_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_floor_changed_source"))
        report = source_parity.verify_floor_changed_source(ROOT / "mindustry-upstream")
        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/environment/Floor.java")
        self.assertEqual(report["missing"], [])

    def test_floor_changed_is_registered_as_one_canonical_slice(self):
        import json

        generated = PROJECT / "src/generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        entry = registry["symbols"]["floor.floor_changed"]
        self.assertEqual(entry["source_slice"], "N1794")
        self.assertEqual(entry["java_source"], "core/src/mindustry/world/blocks/environment/Floor.java")
        self.assertEqual(ledger["slices"]["N1794"]["status"], "done")

    def test_floor_display_queries_use_liquid_drop_override(self):
        source_text = (PROJECT / "src/game/SourceFloorSourceTextState.gd").read_text(encoding="utf-8")
        state = (PROJECT / "src/game/SourceFloorState.gd").read_text(encoding="utf-8")
        bridge = (PROJECT / "src/game/SourceBlockRuntimePortBridge.gd").read_text(encoding="utf-8")
        self.assertIn('const METHOD_GET_DISPLAY_ICON := "public TextureRegion getDisplayIcon(Tile tile){"', source_text)
        self.assertIn('const METHOD_GET_DISPLAY_NAME := "public String getDisplayName(Tile tile){"', source_text)
        self.assertIn('const GET_DISPLAY_ICON_RETURN := "return liquidDrop == null ? super.getDisplayIcon(tile) : liquidDrop.uiIcon;"', source_text)
        self.assertIn('const GET_DISPLAY_NAME_RETURN := "return liquidDrop == null ? super.getDisplayName(tile) : liquidDrop.localizedName;"', source_text)
        self.assertIn("static func get_display_icon_state", state)
        self.assertIn("static func get_display_name_state", state)
        self.assertIn("func source_floor_get_display_icon_state", bridge)
        self.assertIn("func source_floor_get_display_name_state", bridge)

    def test_floor_display_queries_are_registered_as_one_canonical_slice(self):
        import json

        generated = PROJECT / "src/generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        for symbol in ("floor.get_display_icon", "floor.get_display_name"):
            self.assertEqual(registry["symbols"][symbol]["source_slice"], "N1795")
            self.assertEqual(registry["symbols"][symbol]["java_source"], "core/src/mindustry/world/blocks/environment/Floor.java")
        self.assertEqual(ledger["slices"]["N1795"]["status"], "done")

    def test_floor_display_queries_match_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_floor_display_queries_source"))
        report = source_parity.verify_floor_display_queries_source(ROOT / "mindustry-upstream")
        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/environment/Floor.java")
        self.assertEqual(report["missing"], [])

    def test_floor_draw_main_has_source_backed_three_branch_call_plan(self):
        source_text = (PROJECT / "src/game/SourceFloorSourceTextState.gd").read_text(encoding="utf-8")
        state = (PROJECT / "src/game/SourceFloorState.gd").read_text(encoding="utf-8")
        bridge = (PROJECT / "src/game/SourceBlockRuntimePortBridge.gd").read_text(encoding="utf-8")
        for literal in (
            'const METHOD_DRAW_MAIN := "public void drawMain(Tile tile){"',
            'const DRAW_MAIN_TILING_GUARD := "if(tilingVariants > 0){"',
            'const DRAW_MAIN_AUTOTILE_GUARD := "}else if(autotile){"',
            'const DRAW_MAIN_AUTOTILE_INDEX := "int bit = TileBitmask.values[bits];"',
            'const DRAW_MAIN_ALPHA_RESET := "Draw.alpha(1f);"',
        ):
            self.assertIn(literal, source_text)
        self.assertIn("static func draw_main_state", state)
        self.assertIn('branch = "tiling"', state)
        self.assertIn('branch = "autotile"', state)
        self.assertIn("source_math_state.random_seed_int", state)
        self.assertIn("func source_floor_draw_main_state", bridge)

        proof = (PROJECT / "tools/runtime_proofs/FloorModuleProof.gd").read_text(encoding="utf-8")
        for proof_field in ("draw_main_tiling", "draw_main_autotile_mid", "draw_main_variant", "generated_draw_main"):
            self.assertIn(proof_field, proof)
        self.assertIn('draw_main_tiling.get("branch", "") == "tiling"', proof)
        self.assertIn('draw_main_autotile_mid.get("autotile_bit", -1)) == 13', proof)
        self.assertIn('draw_main_variant.get("branch", "") == "variant"', proof)
        self.assertIn('generated_draw_main.get("matches", false)', proof)

    def test_floor_draw_main_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_floor_draw_main_source"))
        report = source_parity.verify_floor_draw_main_source(ROOT / "mindustry-upstream")
        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/environment/Floor.java")
        self.assertEqual(report["missing"], [])

    def test_floor_draw_main_is_registered_as_one_canonical_slice(self):
        import json

        generated = PROJECT / "src/generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        entry = registry["symbols"]["floor.draw_main"]
        self.assertEqual(entry["source_slice"], "N1796")
        self.assertEqual(entry["java_source"], "core/src/mindustry/world/blocks/environment/Floor.java")
        self.assertEqual(ledger["slices"]["N1796"]["status"], "done")


if __name__ == "__main__":
    unittest.main()
