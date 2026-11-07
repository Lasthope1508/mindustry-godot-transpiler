import unittest
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "tools" / "mindustry_godot_transpiler"))

from mindustry_port import source_symbols

PROJECT = ROOT / "godot-mindustry"


class PuddlesDepositSliceTests(unittest.TestCase):
    def test_puddles_deposit_module_is_source_backed_and_registered(self):
        source_text = PROJECT / "src" / "game" / "SourcePuddlesSourceTextState.gd"
        state = PROJECT / "src" / "game" / "SourcePuddlesDepositState.gd"
        bridge = PROJECT / "src" / "game" / "SourcePuddlesPortBridge.gd"
        proof = PROJECT / "tools" / "runtime_proofs" / "PuddlesDepositModuleProof.gd"

        self.assertTrue(source_text.exists())
        self.assertTrue(state.exists())
        self.assertTrue(bridge.exists())
        self.assertTrue(proof.exists())
        self.assertIn("class_name SourcePuddlesSourceTextState", source_text.read_text(encoding="utf-8"))
        state_source = state.read_text(encoding="utf-8")
        self.assertIn("class_name SourcePuddlesDepositState", state_source)
        self.assertIn('const source_puddles_source_text_state := preload("res://src/game/SourcePuddlesSourceTextState.gd")', state_source)
        self.assertIn("static func deposit_tile_liquid_state", state_source)
        self.assertIn('const source_puddles_reaction_state := preload("res://src/game/SourcePuddlesReactionState.gd")', state_source)
        self.assertIn("different_liquid_reaction", state_source)
        self.assertIn("static func deposit_tile_liquid_state", bridge.read_text(encoding="utf-8"))
        self.assertIn("PuddlesDepositModuleProof", proof.read_text(encoding="utf-8"))

        registry = source_symbols.load_source_symbol_registry(PROJECT)
        audit = source_symbols.audit_godot_source_symbol_coverage(PROJECT, registry)
        symbol = source_symbols.source_symbol(registry, "puddles_deposit_tile_liquid.method")

        self.assertEqual(symbol["godot_owner"], "PortGame.source_puddles_deposit_tile_liquid_state")
        self.assertEqual(symbol["java_source"], "core/src/mindustry/entities/Puddles.java")
        self.assertNotIn("port_game.source_puddles_deposit_tile_liquid_state", audit["legacyUnregisteredOwners"])

    def test_puddles_deposit_runtime_semantics_cover_canonical_safe_branches(self):
        state = (PROJECT / "src" / "game" / "SourcePuddlesDepositState.gd").read_text(encoding="utf-8")

        source_text = (PROJECT / "src" / "game" / "SourcePuddlesSourceTextState.gd").read_text(encoding="utf-8")
        self.assertIn('const TILE_NULL_GUARD := "if(tile == null) return;"', source_text)
        self.assertIn('const FLOOR_SOLID_GUARD := "if(tile.floor().solid) return;"', source_text)
        self.assertIn('const SERVER_GUARD := "if(!Vars.net.client()){"', source_text)
        self.assertIn('const CREATE_AMOUNT := "puddle.amount = Math.min(amount, maxLiquid);"', source_text)
        self.assertIn('const SAME_LIQUID_ACCEPTING := "p.accepting = Math.max(amount, p.accepting);"', source_text)
        self.assertIn("const MAX_LIQUID_DEFAULT := source_puddles_source_text_state.MAX_LIQUID_DEFAULT", state)

    def test_puddles_bridge_is_on_the_port_game_root_chain(self):
        root_bridge = (PROJECT / "src" / "game" / "SourcePortGameRootStatePortBridge.gd").read_text(encoding="utf-8")
        bridge = (PROJECT / "src" / "game" / "SourcePuddlesPortBridge.gd").read_text(encoding="utf-8")
        self.assertIn('extends "res://src/game/SourcePortGameBuildProjectorStatePortBridge.gd"', root_bridge)
        self.assertIn("func source_puddles_deposit_tile_liquid_state", root_bridge)
        self.assertIn("source_puddles_deposit_state.deposit_tile_liquid_state", bridge)

    def test_puddles_reaction_branches_are_source_backed(self):
        source_text = (PROJECT / "src" / "game" / "SourcePuddlesSourceTextState.gd").read_text(encoding="utf-8")
        reaction = (PROJECT / "src" / "game" / "SourcePuddlesReactionState.gd").read_text(encoding="utf-8")
        for literal in (
            "BOIL_GUARD",
            "SPACE_GUARD",
            "FLOOR_LIQUID_REACTION_GUARD",
            "REACT_FIRE_GUARD",
            "REACT_COLD_ON_HOT_GUARD",
            "REACT_HOT_ON_COLD_GUARD",
            "REACT_DEST_CALL",
        ):
            self.assertIn("const " + literal, source_text)
        self.assertIn("static func react_puddle_state", reaction)
        self.assertIn('"fires_create_called"', reaction)
        self.assertIn('"steam_effect_called"', reaction)


if __name__ == "__main__":
    unittest.main()
