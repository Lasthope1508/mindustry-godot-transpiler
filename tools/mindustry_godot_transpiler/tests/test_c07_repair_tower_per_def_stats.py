import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TOWER_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTowerBuildState.gd'
REPAIR_TOWER_PER_DEF_STATS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTowerPerDefStatsProof.gd'


class C07RepairTowerPerDefStatsTests(unittest.TestCase):
    def test_c07_repair_tower_per_def_stats_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2238']['godot_owner'], 'SourceRepairTowerBuildState.source_repair_tower_per_def_stats_state')
        # The per-def values were already resolved by the driver
        # (healAmount from the block properties, the N2211
        # range precedent) and the catalog (size 2, range 100.0,
        # requirements graphite 90 / silicon 90 / tungsten 80)
        # but never registered as a pure function: the deferred
        # pool entry "RepairTower per-def stat rows (size 2,
        # range 100f, healAmount 1.5f, graphite 90 / silicon 90
        # / tungsten 80, Blocks.java:6575-6583) -- static defs,
        # wait for their own verification slice" is the last
        # open RepairTower stat item (range() is N2228-adjacent
        # via source_repair_tower_range_state, setStats is
        # N2230, ozone the N2229 row; powerUse lives in the
        # catalog consumePower). RED decisions (resolved at RED,
        # recorded in the register docstring): (1) One pure
        # function on the same family file, taking the block id
        # explicitly (per-def static state, not a live frame
        # key -- the N2212 / N2220 / N2235 / N2237 precedent)
        # and returning all three rows, via three new helpers
        # (`_range_for_block_id`, `_heal_amount_for_block_id`,
        # `_size_for_block_id`) -- no duplicated constants, no
        # existing per-def helpers to reuse. (2) There is NO
        # driver tick line: a static read (the N2233 range /
        # N2235 ambient volume / N2237 precedent). (3) The
        # deferred pool entry "RepairTower per-def stat rows"
        # is dropped here and replaced by the N2238
        # Windows-proof debt entry. (4) Requirements are NOT
        # in this slice: the content registry already carries
        # them for unit-repair-tower. (5) Suppression live +
        # targets live list stay BLOCKED. Three new result
        # symbols: range, heal_amount, size.
        self.assertEqual(
            ledger['N2238']['source_symbols'],
            [
                'source_repair_tower_per_def_stats_state_result.range',
                'source_repair_tower_per_def_stats_state_result.heal_amount',
                'source_repair_tower_per_def_stats_state_result.size',
            ],
        )
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTower.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
        }
        for name in ledger['N2238']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], slice_sources)
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTowerBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2238']['runtime_proof'], '/root/C07RepairTowerPerDefStatsProof')
        self.assertEqual(
            ledger['N2238']['tests'],
            [
                'test_c07_repair_tower_per_def_stats_registration',
                'test_all_c07_repair_tower_per_def_stats_input_evidence_is_exact',
                'test_repair_tower_per_def_stats_state',
                'test_reference_graph_and_actual_c07_repair_tower_per_def_stats',
            ],
        )
        self.assertTrue(ledger['N2238']['deferred_exprs'])

    def test_all_c07_repair_tower_per_def_stats_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2238']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTowerBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTower.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2238']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_tower_per_def_stats_state(self):
        repair_tower = REPAIR_TOWER_STATE.read_text(encoding='utf-8')
        # RepairTower per-def stat rows (Blocks.java:6575-6583
        # + class defaults RepairTower.java:21, :24 +
        # Block.java:215): unit-repair-tower range 100f /
        # healAmount 1.5f / size 2; class defaults range 80f /
        # healAmount 1f / size 1. The pure function takes the
        # block id explicitly (per-def static state, not a live
        # frame key) and resolves through three new helpers.
        # No driver tick line: a static read (the N2233 /
        # N2235 / N2237 precedent).
        self.assertIn('static func source_repair_tower_per_def_stats_state(block_id: String) -> Dictionary:', repair_tower)
        self.assertIn('return {"range": _range_for_block_id(block_id), "heal_amount": _heal_amount_for_block_id(block_id), "size": _size_for_block_id(block_id)}', repair_tower)
        self.assertIn('static func _range_for_block_id(block_id: String) -> float:', repair_tower)
        self.assertIn('static func _heal_amount_for_block_id(block_id: String) -> float:', repair_tower)
        self.assertIn('static func _size_for_block_id(block_id: String) -> int:', repair_tower)
        for expr in [
            'public float range = 80f;',
            'public float healAmount = 1f;',
            'public int size = 1;',
            'range = 100f;',
            'healAmount = 1.5f;',
            'size = 2;',
            'public class RepairTower extends Block{',
            'unitRepairTower = new RepairTower("unit-repair-tower"){{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, repair_tower)
        driver_start = repair_tower.index('static func source_repair_tower_tick_buildings_state')
        driver_end = repair_tower.find('\nstatic func ', driver_start + 1)
        driver_body = repair_tower[driver_start:driver_end if driver_end != -1 else len(repair_tower)]
        self.assertNotIn('source_repair_tower_per_def_stats_state', driver_body)
        # The proof's keys drive the pure function with the
        # catalog def, an unknown def and the empty id / has no
        # driver tick line (the proof reads the state script
        # source and greps the driver body -- a runtime check,
        # not a hardcoded true).
        proof = REPAIR_TOWER_PER_DEF_STATS_PROOF.read_text(encoding='utf-8')
        for key in [
            'stats_unit_repair_tower',
            'stats_class_default',
            'stats_empty_defaults',
            'has_no_driver_tick_line',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_repair_tower_per_def_stats(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTowerPerDefStatsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TOWER_PER_DEF_STATS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'stats_unit_repair_tower',
            'stats_class_default',
            'stats_empty_defaults',
            'has_no_driver_tick_line',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
