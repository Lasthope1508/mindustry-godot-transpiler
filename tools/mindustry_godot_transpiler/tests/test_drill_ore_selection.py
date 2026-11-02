import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]


class DrillOreSelectionTests(unittest.TestCase):
    def test_ore_selection_contracts_and_source_evidence(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        contracts = json.loads((generated / 'source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        for owner in ['SourceDrillRuntimeState.source_can_mine_state', 'SourceDrillRuntimeState.source_count_ore_state']:
            with self.subTest(owner=owner):
                self.assertTrue(owner in contracts, owner)
                self.assertEqual(contracts[owner]['source_slice'], 'N2010')
        source = (ROOT / 'mindustry-upstream/core/src/mindustry/world/blocks/production/Drill.java').read_text()
        for expression in ['if(tile == null || tile.block().isStatic()) return false;', 'int type = Boolean.compare(!item1.lowPriority, !item2.lowPriority);', 'return Integer.compare(item1.id, item2.id);', 'returnItem = itemArray.peek();']:
            self.assertIn(expression, source)

    def test_independent_ore_selection_matrix_in_godot(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/DrillOreSelectionProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=100)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('DRILL_ORE_SELECTION_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
