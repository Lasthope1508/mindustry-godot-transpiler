import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TOWER_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTowerBuildState.gd'
REPAIR_TOWER_PER_DEF_STAT_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTowerPerDefStatRowsProof.gd'
REPAIR_TOWER_PER_DEF_STAT_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTowerPerDefStatRowsProof.tscn'


class C07RepairTowerPerDefStatRowsTests(unittest.TestCase):
    def test_c07_repair_tower_per_def_stat_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2490']['godot_owner'], 'SourceRepairTowerBuildState.source_repair_tower_per_def_stats_state')
        # The RepairTower tick is live (N2227 advance +
        # N2306 live scan + N2250 liquid row) and the
        # draw / stats rows are live (N2428) but NOTHING
        # modeled the per-def stat rows as a
        # source-backed pure: the unit-repair-tower def
        # (Blocks.java:6575-6583) sets size 2, range
        # 100f, healAmount 1.5f and requirements
        # graphite 90 / silicon 90 / tungsten 80, while
        # the values only existed as constants in the
        # driver header comment. N2490 ports them as ONE
        # pure-only stats pure (the N2304 / N2442
        # verification-slice precedent): the def's rows
        # for unit-repair-tower, with the CLASS defaults
        # (size 1, range 80f, healAmount 1f, no
        # requirements) for an unknown def id (the N2304
        # fallback precedent). Four new result symbols:
        # the size + range + heal amount + requirements.
        self.assertEqual(
            ledger['N2490']['source_symbols'],
            [
                'source_repair_tower_per_def_stats_state_result.size',
                'source_repair_tower_per_def_stats_state_result.range_value',
                'source_repair_tower_per_def_stats_state_result.heal_amount',
                'source_repair_tower_per_def_stats_state_result.requirements',
            ],
        )
        expected_sources = {
            'source_repair_tower_per_def_stats_state_result.size': 'core/src/mindustry/content/Blocks.java',
            'source_repair_tower_per_def_stats_state_result.range_value': 'core/src/mindustry/content/Blocks.java',
            'source_repair_tower_per_def_stats_state_result.heal_amount': 'core/src/mindustry/content/Blocks.java',
            'source_repair_tower_per_def_stats_state_result.requirements': 'core/src/mindustry/content/Blocks.java',
        }
        for name in ledger['N2490']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], expected_sources[name])
                self.assertTrue(symbol['godot_owner'].startswith('SourceRepairTowerBuildState.source_repair_tower_'))
        self.assertEqual(ledger['N2490']['runtime_proof'], '/root/C07RepairTowerPerDefStatRowsProof')
        self.assertEqual(
            ledger['N2490']['tests'],
            [
                'test_c07_repair_tower_per_def_stat_rows_registration',
                'test_all_c07_repair_tower_per_def_stat_rows_input_evidence_is_exact',
                'test_repair_tower_per_def_stat_rows_state',
                'test_reference_graph_and_actual_c07_repair_tower_per_def_stat_rows',
            ],
        )
        self.assertTrue(ledger['N2490']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #36 (1-based in
        # the merged advances-33 DEFERRED base, 231
        # entries): the RepairTower per-def stat rows
        # entry is REMOVED -- size / range / healAmount
        # / requirements are live now as a
        # source-backed pure. Net 231 - 1 = 230. The
        # suppression and liquid consumer display rows
        # STAY.
        self.assertFalse(any(entry.startswith('RepairTower per-def stat rows (') for entry in ledger['N2490']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RepairTower suppression rows (') for entry in ledger['N2490']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RepairTower liquid consumer display rows (') for entry in ledger['N2490']['deferred_exprs']))
        self.assertEqual(len(ledger['N2490']['deferred_exprs']), 230)

    def test_all_c07_repair_tower_per_def_stat_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2490']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceRepairTowerBuildState.source_repair_tower_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTower.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2490']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_tower_per_def_stat_rows_state(self):
        repair_tower = REPAIR_TOWER_STATE.read_text(encoding='utf-8')
        # The per-def stat rows (the VERIFICATION slice:
        # the values are already constants in the driver
        # header -- the N2304 / N2442 precedent): the
        # single RepairTower def unit-repair-tower
        # (Blocks.java:6575-6583) sets size 2, range
        # 100f, healAmount 1.5f and requirements
        # graphite 90 / silicon 90 / tungsten 80. An
        # unknown def id falls back to the CLASS
        # defaults (the N2304 fallback precedent): size
        # 1 (Block.java:215), range 80f
        # (RepairTower.java:21), healAmount 1f
        # (RepairTower.java:24) and NO requirements
        # (the Block default is the empty array,
        # Block.java:356). The requirements dict is the
        # {item: amount} dict from the def (the
        # SourceAcceleratorBuildState capacities
        # precedent); the catalog carries the same rows
        # as an Array of {item, amount}
        # (content_registry.json, unit-repair-tower).
        # Pure-only: the caller reads it; the existing
        # advance + shouldConsume pures are unchanged.
        # Keep each Java expr on ONE comment line (the
        # N2148 lesson: a split line fails this test).
        self.assertIn('static func source_repair_tower_per_def_stats_state', repair_tower)
        self.assertIn('unitRepairTower = new RepairTower("unit-repair-tower"){{', repair_tower)
        self.assertIn('requirements(Category.units, with(Items.graphite, 90, Items.silicon, 90, Items.tungsten, 80));', repair_tower)
        self.assertIn('size = 2;', repair_tower)
        self.assertIn('range = 100f;', repair_tower)
        self.assertIn('healAmount = 1.5f;', repair_tower)
        self.assertIn('public float range = 80f;', repair_tower)
        self.assertIn('public float healAmount = 1f;', repair_tower)
        self.assertIn('public int size = 1;', repair_tower)
        self.assertIn('public ItemStack[] requirements = {};', repair_tower)
        self.assertIn('public class RepairTower extends Block{', repair_tower)
        # The documented limits record the per-def stat
        # rows as live.
        self.assertIn('Per-def stat rows live (N2490)', repair_tower)
        # The proof's keys drive the per-def stats pure
        # (the unit-repair-tower def row, the class
        # fallback for an unknown def id, the heal /
        # range values at the def vs the class, the
        # requirements dict, the size, and the def rows
        # feeding the N2428 stats pure as live inputs).
        proof = REPAIR_TOWER_PER_DEF_STAT_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'stats_tower',
            'stats_class_fallback',
            'stats_heal_range',
            'stats_requirements',
            'stats_size',
            'stats_live_input',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceRepairTowerBuildState.gd")', proof)
        self.assertTrue(REPAIR_TOWER_STATE.exists())
        self.assertTrue(REPAIR_TOWER_PER_DEF_STAT_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07RepairTowerPerDefStatRowsProof.gd', REPAIR_TOWER_PER_DEF_STAT_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_repair_tower_per_def_stat_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTowerPerDefStatRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TOWER_PER_DEF_STAT_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'stats_tower',
            'stats_class_fallback',
            'stats_heal_range',
            'stats_requirements',
            'stats_size',
            'stats_live_input',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
