import tempfile
import unittest
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "tools" / "mindustry_godot_transpiler"))

from mindustry_port.emitter import emit_gdscript_classes


class BuildingMoveForwardSliceTests(unittest.TestCase):
    def test_emitter_delegates_move_forward_to_canonical_item_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source = root / "core" / "src" / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public boolean moveForward(Item item){ return false; }
}
""",
                encoding="utf-8",
            )
            output = root / "godot" / "src" / "generated" / "classes"
            emit_gdscript_classes(root / "core" / "src", output)
            emitted = (output / "mindustry" / "entities" / "comp" / "BuildingComp.gd").read_text(encoding="utf-8")

        self.assertIn('const source_building_item_state := preload("res://src/game/SourceBuildingItemState.gd")', emitted)
        self.assertIn("func java_method_moveForward_0(_args: Array = []) -> Variant:", emitted)
        self.assertIn("source_building_item_state.move_forward_accept_state(has_front, same_team, front_accepts)", emitted)
        self.assertIn("source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_MOVE_FORWARD_STATE", emitted)
        self.assertNotIn("func java_method_moveForward_0(_args: Array = []) -> Variant:\n\treturn null", emitted)

    def test_building_registry_owns_move_forward_bridge(self):
        registry = ROOT / "godot-mindustry" / "src" / "game" / "SourceRuntimeOwnerBuildingRegistry.gd"
        source = registry.read_text(encoding="utf-8")
        self.assertIn(
            'const PORT_GAME_SOURCE_BUILDING_MOVE_FORWARD_STATE := "port_game.source_building_move_forward_state"',
            source,
        )

    def test_runtime_proof_calls_generated_move_forward_method(self):
        proof = ROOT / "godot-mindustry" / "tools" / "runtime_proofs" / "BuildingItemStateModuleProof.gd"
        source = proof.read_text(encoding="utf-8")
        self.assertIn("generated_building_comp_script.new().java_method_moveForward_112", source)
        self.assertIn('"generated_move_forward_matches"', source)


if __name__ == "__main__":
    unittest.main()
