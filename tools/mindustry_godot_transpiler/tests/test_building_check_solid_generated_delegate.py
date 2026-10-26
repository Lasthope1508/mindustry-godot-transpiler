import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
GENERATED = ROOT / "godot-mindustry/src/generated/classes/mindustry/entities/comp/BuildingComp.gd"


class BuildingCheckSolidGeneratedDelegateTests(unittest.TestCase):
    def test_generated_check_solid_delegates_to_existing_canonical_state(self):
        source = GENERATED.read_text(encoding="utf-8")
        body = source.split("func java_method_checkSolid_172", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("return source_building_core_state.check_solid_state()", body)
        self.assertNotIn('return {"source_owner":', body)
        self.assertNotIn('"checkSolid": false', body)

    def test_check_solid_keeps_existing_canonical_owner(self):
        generated = ROOT / "godot-mindustry/src/generated"
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        self.assertEqual(ledger["N1034"]["godot_owner"], "PortGame.source_building_check_solid_state")
        self.assertEqual(ledger["N1034"]["java_method"], "checkSolid()")

    def test_parity_bridge_wraps_direct_scalar_result_in_existing_contract_shape(self):
        source = (ROOT / "godot-mindustry/src/game/SourceBuildingCoreState.gd").read_text(encoding="utf-8")
        body = source.split("static func generated_check_solid_bridge_state", 1)[1].split("\nstatic func ", 1)[0]
        self.assertIn("if result is bool:", body)
        self.assertIn('"checkSolid": result', body)
        self.assertIn('"canonical": canonical', body)


if __name__ == "__main__":
    unittest.main()
