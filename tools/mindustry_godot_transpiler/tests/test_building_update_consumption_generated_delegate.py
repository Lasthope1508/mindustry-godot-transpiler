import json
import shutil
import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
GENERATED = ROOT / "godot-mindustry/src/generated/classes/mindustry/entities/comp/BuildingComp.gd"


class BuildingUpdateConsumptionGeneratedDelegateTests(unittest.TestCase):
    def test_consumption_complete_contract_and_row_schema_are_registered(self):
        root = ROOT / "godot-mindustry/src/generated"
        contracts = json.loads((root / "source_api_contracts.json").read_text(encoding="utf-8"))["contracts"]
        schemas = json.loads((root / "source_state_schema.json").read_text(encoding="utf-8"))["schemas"]
        for method in ("update_consumption", "apply_update_consumption"):
            self.assertIn(f"PortGame.source_building_{method}_state", contracts)
        fields = schemas["source_building_update_consumption_result"]["keys"]
        self.assertTrue({"efficiency", "optional_efficiency", "potential_efficiency", "should_consume_power", "updated_consumers", "update_count"} <= fields.keys())
        self.assertEqual(schemas["source_building_consumer_efficiency_row"]["keys"]["efficiency"]["alias_of"], "source_building_consumer_efficiency_row.result")

    def test_consumption_runtime_matrix_against_java_expectations(self):
        godot = shutil.which("Godot_v4.6.2-stable_win64_console.exe") or shutil.which("godot")
        if not godot:
            self.skipTest("Godot executable unavailable; native MCP proof remains an acceptance requirement")
        run = subprocess.run([godot, "--headless", "--path", str(ROOT / "godot-mindustry"), "--scene", "tools/runtime_proofs/BuildingConsumptionCanonicalProof.tscn", "--quit-after", "5"], capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=60)
        output = run.stdout + run.stderr
        self.assertEqual(run.returncode, 0, output)
        self.assertNotIn("SCRIPT ERROR", output)
        self.assertNotIn("ERROR:", output)
        records = [line.split(" ", 1)[1] for line in output.splitlines() if line.startswith("BUILDING_CONSUMPTION_CANONICAL_PROOF ")]
        self.assertEqual(len(records), 1, output)
        proof = json.loads(records[0])
        self.assertTrue(proof["matches"], proof)
        self.assertGreaterEqual(proof["case_count"], 20)

    def test_complete_path_has_one_domain_owner_and_no_inline_behavior(self):
        body = self._body()
        self.assertIn("source_building_efficiency_state.update_consumption_state(", body)
        for duplicate in ("for consumer in", "for result in", "min(", "var multiplied", "var updated_consumers", "if not update:"):
            with self.subTest(duplicate=duplicate):
                self.assertNotIn(duplicate, body)

    def test_second_pass_expected_never_uses_actual_efficiency(self):
        helper = (ROOT / "godot-mindustry/src/game/SourceBuildingEfficiencyState.gd").read_text(encoding="utf-8")
        body = helper.split("static func generated_update_consumption_second_pass_bridge_state", 1)[1].split("\nstatic func ", 1)[0]
        self.assertNotIn('result.get("efficiency"', body)

    def _body(self) -> str:
        source = GENERATED.read_text(encoding="utf-8")
        return source.split("func java_method_updateConsumption_194", 1)[1].split("\nfunc ", 1)[0]

    def test_initial_and_disabled_branches_use_canonical_state(self):
        body = self._body()
        self.assertIn(
            "return source_building_efficiency_state.update_consumption_initial_state(has_consumers, cheating, enabled_state, production_valid, should_consume_state, efficiency_scale)",
            body,
        )
        self.assertIn(
            "return source_building_efficiency_state.update_consumption_disabled_state(enabled_state)",
            body,
        )
        self.assertNotIn('"source_owner": "port_game.source_building_update_consumption_initial_state"', body)
        self.assertNotIn('"source_owner": "port_game.source_building_update_consumption_disabled_state"', body)

    def test_setup_branch_uses_canonical_state(self):
        body = self._body()
        self.assertIn("if _args.size() <= 6:", body)
        self.assertIn(
            "return source_building_efficiency_state.update_consumption_setup_state(should_consume_state, production_valid)",
            body,
        )
        self.assertNotIn('"source_owner": "port_game.source_building_update_consumption_setup_state"', body)

    def test_non_optional_branch_uses_canonical_state(self):
        body = self._body()
        self.assertIn("if _args.size() <= 7:", body)
        self.assertIn(
            "return source_building_efficiency_state.update_consumption_non_optional_pass_state(non_optional_consumer_results)",
            body,
        )
        self.assertNotIn('"source_owner": "port_game.source_building_update_consumption_non_optional_pass_state"', body)

    def test_optional_branch_uses_canonical_state(self):
        body = self._body()
        self.assertIn("if _args.size() <= 8:", body)
        self.assertIn(
            "return source_building_efficiency_state.update_consumption_optional_pass_state(optional_consumer_results)",
            body,
        )
        self.assertNotIn('"source_owner": "port_game.source_building_update_consumption_optional_pass_state"', body)

    def test_efficiency_branch_uses_canonical_state(self):
        body = self._body()
        self.assertIn("if _args.size() <= 8:", body)
        self.assertIn(
            "return source_building_efficiency_state.update_consumption_efficiency_state(min_efficiency, optional_efficiency, update)",
            body,
        )
        self.assertNotIn('"source_owner": "port_game.source_building_update_consumption_efficiency_state"', body)

    def test_second_pass_uses_canonical_state(self):
        body = self._body()
        self.assertIn(
            "return source_building_efficiency_state.update_consumption_state(has_consumers, cheating, enabled_state, production_valid, should_consume_state, efficiency_scale, non_optional_consumer_results, optional_consumer_results, update_consumers, self_state)",
            body,
        )
        self.assertNotIn('"source_owner": "port_game.source_building_update_consumption_second_pass_state"', body)


if __name__ == "__main__":
    unittest.main()
