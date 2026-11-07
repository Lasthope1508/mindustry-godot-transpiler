import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
import sys

sys.path.insert(0, str(ROOT / "tools" / "mindustry_godot_transpiler"))

from mindustry_port.emitter import emit_gdscript_classes


class BuildingApplySlowdownSliceTests(unittest.TestCase):
    def test_source_formula_and_generated_delegate_are_present(self):
        upstream = (ROOT / "mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java").read_text(encoding="utf-8")
        state = (ROOT / "godot-mindustry/src/game/SourceBuildingTimeState.gd").read_text(encoding="utf-8")
        generated = (ROOT / "godot-mindustry/src/generated/classes/mindustry/entities/comp/BuildingComp.gd").read_text(encoding="utf-8")

        for expression in (
            "if(intensity <= this.timeScale + 0.001f){",
            "timeScaleDuration = Math.max(timeScaleDuration, duration);",
            "timeScale = Math.min(timeScale, intensity);",
        ):
            self.assertIn(expression, upstream)
        self.assertIn("static func apply_slowdown_state(", state)
        body = generated.split("func java_method_applySlowdown_25", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("source_building_time_state.apply_slowdown_state", body)
        self.assertNotIn("return null", body)
        self.assertIn("func generated_building_comp_apply_slowdown_bridge_state(", (ROOT / "godot-mindustry/src/game/SourceBuildingTimePortBridge.gd").read_text(encoding="utf-8"))

    def test_emitter_generates_apply_slowdown_from_source_method(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source = root / "core/src/mindustry/entities/comp/BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """package mindustry.entities.comp;
public class BuildingComp{
    public void applySlowdown(float intensity, float duration){
        if(intensity <= this.timeScale + 0.001f){
            timeScaleDuration = Math.max(timeScaleDuration, duration);
        }
        timeScale = Math.min(timeScale, intensity);
    }
}
""",
                encoding="utf-8",
            )
            output = root / "godot/src/generated/classes"
            emit_gdscript_classes(root / "core/src", output)
            generated = (output / "mindustry/entities/comp/BuildingComp.gd").read_text(encoding="utf-8")

        self.assertIn('const source_building_time_state := preload("res://src/game/SourceBuildingTimeState.gd")', generated)
        self.assertIn("func java_method_applySlowdown_0(_args: Array = []) -> Variant:", generated)
        self.assertIn("return source_building_time_state.apply_slowdown_state", generated)


if __name__ == "__main__":
    unittest.main()
