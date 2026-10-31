import json
import shutil
import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
GENERATED = ROOT / "godot-mindustry/src/generated/classes/mindustry/world/consumers/ConsumeLiquid.gd"


class ConsumeLiquidGeneratedDelegateTests(unittest.TestCase):
    def body(self, method):
        return GENERATED.read_text(encoding="utf-8").split(f"func java_method_{method}", 1)[1].split("\nfunc ", 1)[0]

    def test_consume_liquid_update_has_one_canonical_formula_owner(self):
        body = self.body("update_2")
        self.assertIn("return source_consume_liquid_state.update_state(liquid_id, amount, build_edelta, multiplier_get_build)", body)
        self.assertNotIn("amount * build_edelta", body)
        self.assertNotIn('"remove_amount":', body)

    def test_consume_liquid_efficiency_has_one_canonical_formula_owner(self):
        body = self.body("efficiency_3")
        self.assertIn("return source_consume_liquid_state.efficiency_state(build_liquids_get, amount, build_edelta, build_efficiency_scale, multiplier_get_build)", body)
        for fragment in ("min(", " / ", "ed_guard", "required_liquid_amount"):
            with self.subTest(fragment=fragment):
                self.assertNotIn(fragment, body)

    def test_consume_liquid_golden_runtime_and_building_composition(self):
        godot = shutil.which("Godot_v4.6.2-stable_win64_console.exe") or shutil.which("godot")
        if not godot:
            self.skipTest("Godot unavailable; native MCP proof remains required")
        run = subprocess.run([godot, "--headless", "--path", str(ROOT / "godot-mindustry"), "--scene", "tools/runtime_proofs/ConsumeLiquidCanonicalProof.tscn", "--quit-after", "5"], capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=60)
        output = run.stdout + run.stderr
        self.assertEqual(run.returncode, 0, output)
        self.assertNotIn("ERROR:", output)
        self.assertNotIn("SCRIPT ERROR", output)
        records = [json.loads(line.split(" ", 1)[1]) for line in output.splitlines() if line.startswith("CONSUME_LIQUID_CANONICAL_PROOF ")]
        self.assertEqual(len(records), 1, output)
        self.assertTrue(records[0]["matches"], records[0])
        self.assertTrue(records[0]["building_composition_matches"])
        self.assertGreaterEqual(records[0]["case_count"], 16)
