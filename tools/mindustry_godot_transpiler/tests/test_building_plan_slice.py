import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


class BuildingPlanSliceTests(unittest.TestCase):
    def test_generated_add_plan_overloads_delegate_to_canonical_building_plan_state(self):
        generated = (PROJECT / "src/generated/classes/mindustry/entities/comp/BuildingComp.gd").read_text(encoding="utf-8")
        for method, delegate in (("java_method_addPlan_15", "add_plan_default_state"), ("java_method_addPlan_16", "add_plan_state")):
            body = generated.split("func " + method, 1)[1].split("\nfunc ", 1)[0]
            self.assertIn("source_building_plan_state." + delegate, body)
            self.assertNotIn("return null", body)

    def test_plan_module_retains_source_text_and_source_order(self):
        source_text = (PROJECT / "src/game/SourceBuildingPlanSourceTextState.gd").read_text(encoding="utf-8")
        module = (PROJECT / "src/game/SourceBuildingPlanState.gd").read_text(encoding="utf-8")
        upstream = (ROOT / "mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java").read_text(encoding="utf-8")
        for literal in (
            "public void addPlan(boolean checkPrevious){",
            "addPlan(checkPrevious, false);",
            "if(!ignoreConditions && (!block.rebuildable || (team == state.rules.defaultTeam && state.isCampaign() && !block.isVisible()))) return;",
            "if(self() instanceof ConstructBuild entity){",
            "data.plans.removeIndex(i);",
            "data.plans.addFirst(new BlockPlan(tile.x, tile.y, (short)rotation, toAdd, overrideConfig == null ? config() : overrideConfig));",
        ):
            self.assertIn(literal, upstream)
            self.assertIn(literal, source_text)
        self.assertIn("static func add_plan_default_state", module)
        self.assertIn("static func add_plan_state", module)
        self.assertIn("updated_plans.push_front(new_plan)", module)

    def test_add_plan_slice_has_one_registered_building_owner(self):
        generated = PROJECT / "src/generated"
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))["symbols"]
        contracts = json.loads((generated / "source_api_contracts.json").read_text(encoding="utf-8"))["contracts"]
        owner = "PortGame.source_building_add_plan_state"
        for slice_id in ("N1914", "N1915"):
            self.assertEqual(ledger[slice_id]["godot_owner"], owner)
        self.assertEqual(registry["building_add_plan.method"]["godot_owner"], owner)
        self.assertEqual(contracts[owner]["source_slice"], "N1914")

    def test_building_plan_runtime_proof_covers_replace_and_construct_override(self):
        proof = (PROJECT / "tools/runtime_proofs/BuildingPlanStateModuleProof.gd").read_text(encoding="utf-8")
        for token in ("generated_building_comp_add_plan_default_bridge_state", "generated_building_comp_add_plan_bridge_state", "removed_previous", "construct", "one_headquarter_per_ssot"):
            self.assertIn(token, proof)


if __name__ == "__main__":
    unittest.main()
