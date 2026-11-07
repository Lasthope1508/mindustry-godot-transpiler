import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"
GENERATED = PROJECT / "src" / "generated"

STATS_BARS_OWNERS = {
    "PortGame.source_block_set_stats_state": "Block.setStats()",
    "PortGame.source_block_add_bar_state": "Block.addBar(String name, Func<T, Bar> sup)",
    "PortGame.source_block_remove_bar_state": "Block.removeBar(String name)",
    "PortGame.source_block_list_bars_state": "Block.listBars()",
    "PortGame.source_block_add_liquid_bar_static_state": "Block.addLiquidBar(Liquid liq)",
    "PortGame.source_block_add_liquid_bar_dynamic_state": "Block.addLiquidBar(Func<T, Liquid> current)",
    "PortGame.source_block_set_bars_state": "Block.setBars()",
    "PortGame.source_block_after_patch_stats_bars_state": "Block.afterPatch()",
}


class BlockStatsBarsSliceTests(unittest.TestCase):
    def test_block_stats_bars_owners_have_complete_canonical_ssot(self):
        ledger = json.loads((GENERATED / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        contracts = json.loads((GENERATED / "source_api_contracts.json").read_text(encoding="utf-8"))["contracts"]
        schemas = json.loads((GENERATED / "source_state_schema.json").read_text(encoding="utf-8"))["schemas"]
        symbols = json.loads((GENERATED / "source_symbol_registry.json").read_text(encoding="utf-8"))["symbols"]
        stats_module = json.loads((GENERATED / "source_modules" / "block_stats_bars.json").read_text(encoding="utf-8"))["block_stats_bars"]

        ledger_by_owner = {entry["godot_owner"]: entry for entry in ledger.values()}
        symbols_by_owner = {}
        for symbol_name, symbol in symbols.items():
            symbols_by_owner.setdefault(symbol["godot_owner"], set()).add(symbol_name)

        self.assertEqual(set(stats_module["methods"]), set(STATS_BARS_OWNERS))
        for owner, java_method in STATS_BARS_OWNERS.items():
            with self.subTest(owner=owner):
                self.assertIn(owner, ledger_by_owner)
                self.assertIn(owner, contracts)
                self.assertTrue(symbols_by_owner.get(owner))
                self.assertEqual(ledger_by_owner[owner]["java_source"], "core/src/mindustry/world/Block.java")
                self.assertEqual(ledger_by_owner[owner]["java_method"], java_method)
                self.assertEqual(contracts[owner]["source_slice"], next(slice_id for slice_id, entry in ledger.items() if entry["godot_owner"] == owner))
                schema_prefix = owner.removeprefix("PortGame.")
                self.assertIn(schema_prefix + "_input", schemas)
                self.assertIn(schema_prefix + "_result", schemas)

    def test_block_stats_bars_source_text_matches_upstream_methods(self):
        source_text = (PROJECT / "src" / "game" / "SourceBlockStatsBarsSourceTextState.gd").read_text(encoding="utf-8")
        upstream = (ROOT / "mindustry-upstream" / "core" / "src" / "mindustry" / "world" / "Block.java").read_text(encoding="utf-8")

        for expression in (
            "public void setStats(){",
            "public <T extends Building> void addBar(String name, Func<T, Bar> sup){",
            "public void removeBar(String name){",
            "public Iterable<Func<Building, Bar>> listBars(){",
            "public void addLiquidBar(Liquid liq){",
            "public <T extends Building> void addLiquidBar(Func<T, Liquid> current){",
            "public void setBars(){",
            "public void afterPatch(){",
            "itemFilter = new boolean[content.items().size];",
            "liquidFilter = new boolean[content.liquids().size];",
            "if(consumeBuilder.size != 0){",
            "for(var consume : consumeBuilder){",
            "consume.apply(this);",
        ):
            with self.subTest(expression=expression):
                self.assertIn(expression, upstream)
                self.assertIn(expression, source_text)

        consume_upstream = (ROOT / "mindustry-upstream" / "core" / "src" / "mindustry" / "world" / "consumers" / "Consume.java").read_text(encoding="utf-8")
        self.assertIn("public void apply(Block block){", consume_upstream)

    def test_liquid_bar_runtime_literals_are_owned_by_source_text(self):
        source_text = (PROJECT / "src" / "game" / "SourceBlockStatsBarsSourceTextState.gd").read_text(encoding="utf-8")
        module = (PROJECT / "src" / "game" / "SourceBlockStatsBarsState.gd").read_text(encoding="utf-8")
        expected = {
            "SOURCE_BLOCK_ADD_LIQUID_BAR_STATIC_NAME_PREFIX": "liquid-",
            "SOURCE_BLOCK_ADD_LIQUID_BAR_DYNAMIC_NAME": "liquid",
            "SOURCE_BLOCK_ADD_LIQUID_BAR_DYNAMIC_EMPTY_TEXT": "bar.liquid",
            "SOURCE_BLOCK_ADD_LIQUID_BAR_DYNAMIC_CLEAR_COLOR": "Color.clear",
        }
        for const_name, literal in expected.items():
            self.assertIn(f'const {const_name} := "{literal}"', source_text)
            self.assertIn(f"const {const_name} := source_block_stats_bars_source_text_state.{const_name}", module)
        self.assertNotIn('var bar_name: String = "liquid-" + liquid_name', module)
        self.assertNotIn('var bar_text: String = "bar.liquid"', module)
        self.assertNotIn('else "Color.clear"', module)

    def test_generated_block_stats_bars_methods_delegate_to_canonical_module(self):
        generated = (PROJECT / "src" / "generated" / "classes" / "mindustry" / "world" / "Block.gd").read_text(
            encoding="utf-8"
        )
        module = (PROJECT / "src" / "game" / "SourceBlockStatsBarsState.gd").read_text(encoding="utf-8")

        self.assertIn(
            'const source_block_stats_bars_state := preload("res://src/game/SourceBlockStatsBarsState.gd")',
            generated,
        )
        expected_delegates = (
            "generated_set_stats_result_state(size_value, synthetic_value, health, armor, buildable_value, requirements_length, build_time, instant_transfer, consumers, has_liquids, liquid_capacity, has_items, item_capacity)",
            "generated_add_bar_result_state(bar_name, bar_supplier, bar_map_before)",
            "generated_remove_bar_result_state(bar_name, bar_map_before)",
            "generated_list_bars_result_state(bar_map)",
            "generated_add_liquid_bar_static_result_state(liquid_name, liquid_unlocked, liquid_amount, liquid_capacity, localized_name, bar_color)",
            "generated_add_liquid_bar_dynamic_result_state(current_liquid, current_amount, liquid_capacity, localized_name, bar_color, empty_threshold)",
            "generated_set_bars_result_state(cons_power_present, has_items, configurable, item_total, item_capacity, unit_cap_modifier, has_liquids, static_liquid_bar_added)",
            "generated_after_patch_result_state(size_value, source_tilesize, content_items_size, content_liquids_size, consume_builder)",
        )
        for delegate in expected_delegates:
            with self.subTest(delegate=delegate):
                self.assertIn("return source_block_stats_bars_state." + delegate, generated)

        self.assertNotIn("var consumer_display_calls: Array = []", generated)
        self.assertNotIn('var bar_name: String = "liquid-" + liquid_name', generated)
        self.assertNotIn("var item_fraction: float = 0.0 if item_capacity == 0", generated)
        self.assertNotIn("var offset_after: float = float((size_value + 1) % 2)", generated)
        self.assertIn(
            "return source_block_stats_bars_state.generated_after_patch_result_state(size_value, source_tilesize, content_items_size, content_liquids_size, consume_builder)",
            generated,
        )
        self.assertIn(
            'const source_consume_module_registry := preload("res://src/game/SourceConsumeModuleRegistry.gd")',
            module,
        )
        self.assertIn(
            "source_consume_module_registry.source_consume_state.consumer_apply_calls(",
            module,
        )
        self.assertNotIn("for consumer in consume_builder:", module)
        for expression in (
            "SOURCE_BLOCK_AFTER_PATCH_ITEM_FILTER_EXPR",
            "SOURCE_BLOCK_AFTER_PATCH_LIQUID_FILTER_EXPR",
            "SOURCE_BLOCK_AFTER_PATCH_CONSUMER_SIZE_GUARD_EXPR",
            "SOURCE_BLOCK_AFTER_PATCH_CONSUMER_LOOP_EXPR",
            "SOURCE_BLOCK_AFTER_PATCH_CONSUMER_APPLY_EXPR",
        ):
            self.assertIn("const " + expression, module)
        for entrypoint in (
            "generated_set_stats_result_state",
            "generated_add_bar_result_state",
            "generated_remove_bar_result_state",
            "generated_list_bars_result_state",
            "generated_add_liquid_bar_static_result_state",
            "generated_add_liquid_bar_dynamic_result_state",
            "generated_set_bars_result_state",
            "generated_after_patch_result_state",
        ):
            self.assertIn("static func " + entrypoint, module)


if __name__ == "__main__":
    unittest.main()
