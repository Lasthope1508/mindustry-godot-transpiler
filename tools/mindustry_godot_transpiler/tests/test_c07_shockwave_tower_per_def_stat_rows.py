import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SHOCKWAVE_TOWER_STATE = ROOT / 'godot-mindustry/src/game/SourceShockwaveTowerBuildState.gd'
SHOCKWAVE_TOWER_PER_DEF_STAT_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ShockwaveTowerPerDefStatRowsProof.gd'
SHOCKWAVE_TOWER_PER_DEF_STAT_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ShockwaveTowerPerDefStatRowsProof.tscn'


class C07ShockwaveTowerPerDefStatRowsTests(unittest.TestCase):
    def test_c07_shockwave_tower_per_def_stat_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2492']['godot_owner'], 'SourceShockwaveTowerBuildState.source_shockwave_tower_per_def_stats_state')
        # The ShockwaveTower tick is live (N2187 gate +
        # N2247 advance + N2318 timer cadence + N2327
        # bullet scan + N2331 cyanogen row) and the
        # sense / warmup / draw / wave-effects rows
        # are live (N2390 / N2356 / N2470) but
        # NOTHING modeled the per-def stat rows as a
        # source-backed pure: the shockwave-tower def
        # (Blocks.java:2038-2044) sets size 3, range
        # 170f, reload 80f and requirements
        # surge-alloy 50 / silicon 150 / oxide 30 /
        # tungsten 100, while the values only existed
        # as constants in the driver header comment.
        # N2492 ports them as ONE pure-only stats
        # pure (the N2304 / N2442 / N2490
        # verification-slice precedent): the def's
        # rows for shockwave-tower, with the CLASS
        # defaults (size 1, range 110f, reload 90f
        # = 60f * 1.5f, no requirements) for an
        # unknown def id (the N2304 fallback
        # precedent). Four new result symbols: the
        # size + range + reload + requirements.
        self.assertEqual(
            ledger['N2492']['source_symbols'],
            [
                'source_shockwave_tower_per_def_stats_state_result.size',
                'source_shockwave_tower_per_def_stats_state_result.range_value',
                'source_shockwave_tower_per_def_stats_state_result.reload_value',
                'source_shockwave_tower_per_def_stats_state_result.requirements',
            ],
        )
        expected_sources = {
            'source_shockwave_tower_per_def_stats_state_result.size': 'core/src/mindustry/content/Blocks.java',
            'source_shockwave_tower_per_def_stats_state_result.range_value': 'core/src/mindustry/content/Blocks.java',
            'source_shockwave_tower_per_def_stats_state_result.reload_value': 'core/src/mindustry/content/Blocks.java',
            'source_shockwave_tower_per_def_stats_state_result.requirements': 'core/src/mindustry/content/Blocks.java',
        }
        for name in ledger['N2492']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], expected_sources[name])
                self.assertTrue(symbol['godot_owner'].startswith('SourceShockwaveTowerBuildState.source_shockwave_tower_'))
        self.assertEqual(ledger['N2492']['runtime_proof'], '/root/C07ShockwaveTowerPerDefStatRowsProof')
        self.assertEqual(
            ledger['N2492']['tests'],
            [
                'test_c07_shockwave_tower_per_def_stat_rows_registration',
                'test_all_c07_shockwave_tower_per_def_stat_rows_input_evidence_is_exact',
                'test_shockwave_tower_per_def_stat_rows_state',
                'test_reference_graph_and_actual_c07_shockwave_tower_per_def_stat_rows',
            ],
        )
        self.assertTrue(ledger['N2492']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #36 (1-based
        # in the merged advances-34 DEFERRED base,
        # 225 entries): the ShockwaveTower per-def
        # stat rows entry is REMOVED -- size / range
        # / reload / requirements are live now as a
        # source-backed pure. Net 225 - 1 = 224.
        # The trigger row and the wave damage
        # application entries STAY.
        self.assertFalse(any(entry.startswith('ShockwaveTower per-def stat rows (') for entry in ledger['N2492']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ShockwaveTower trigger row (') for entry in ledger['N2492']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ShockwaveTower wave damage application on live bullets (') for entry in ledger['N2492']['deferred_exprs']))
        self.assertEqual(len(ledger['N2492']['deferred_exprs']), 224)

    def test_all_c07_shockwave_tower_per_def_stat_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2492']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceShockwaveTowerBuildState.source_shockwave_tower_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/ShockwaveTower.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2492']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_shockwave_tower_per_def_stat_rows_state(self):
        shockwave_tower = SHOCKWAVE_TOWER_STATE.read_text(encoding='utf-8')
        # The per-def stat rows (the VERIFICATION slice:
        # the values are already constants in the driver
        # header -- the N2304 / N2442 / N2490
        # precedent): the single ShockwaveTower def
        # shockwave-tower (Blocks.java:2038-2044) sets
        # size 3, range 170f, reload 80f and
        # requirements surge-alloy 50 / silicon 150 /
        # oxide 30 / tungsten 100. An unknown def id
        # falls back to the CLASS defaults (the N2304
        # fallback precedent): size 1 (Block.java:215),
        # range 110f (ShockwaveTower.java:25), reload
        # 60f * 1.5f = 90f (ShockwaveTower.java:26)
        # and NO requirements (the Block default is
        # the empty array, Block.java:356). The
        # requirements dict is the {item: amount} dict
        # from the def (the SourceAcceleratorBuildState
        # capacities precedent); the catalog carries
        # the same rows as an Array of {item, amount}
        # (content_registry.json, shockwave-tower).
        # Pure-only: the caller reads it; the existing
        # advance + shouldConsume + sense pures are
        # unchanged. Keep each Java expr on ONE comment
        # line (the N2148 lesson: a split line fails
        # this test).
        self.assertIn('static func source_shockwave_tower_per_def_stats_state', shockwave_tower)
        self.assertIn('shockwaveTower = new ShockwaveTower("shockwave-tower"){{', shockwave_tower)
        self.assertIn('requirements(Category.effect, with(Items.surgeAlloy, 50, Items.silicon, 150, Items.oxide, 30, Items.tungsten, 100));', shockwave_tower)
        self.assertIn('size = 3;', shockwave_tower)
        self.assertIn('range = 170f;', shockwave_tower)
        self.assertIn('reload = 80f;', shockwave_tower)
        self.assertIn('public float range = 110f;', shockwave_tower)
        self.assertIn('public float reload = 60f * 1.5f;', shockwave_tower)
        self.assertIn('public int size = 1;', shockwave_tower)
        self.assertIn('public ItemStack[] requirements = {};', shockwave_tower)
        self.assertIn('public class ShockwaveTower extends Block{', shockwave_tower)
        # The documented limits record the per-def stat
        # rows as live.
        self.assertIn('Per-def stat rows live (N2492)', shockwave_tower)
        # The proof's keys drive the per-def stats pure
        # (the shockwave-tower def row, the class
        # fallback for an unknown def id, the size /
        # range values at the def vs the class, the
        # reload at the def vs the class, the
        # requirements dict, and the def rows feeding
        # the N2390 sense pure as live inputs).
        proof = SHOCKWAVE_TOWER_PER_DEF_STAT_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'stats_tower',
            'stats_size_range',
            'stats_reload',
            'stats_requirements',
            'stats_class_fallback',
            'stats_live_input',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceShockwaveTowerBuildState.gd")', proof)
        self.assertTrue(SHOCKWAVE_TOWER_STATE.exists())
        self.assertTrue(SHOCKWAVE_TOWER_PER_DEF_STAT_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07ShockwaveTowerPerDefStatRowsProof.gd', SHOCKWAVE_TOWER_PER_DEF_STAT_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_shockwave_tower_per_def_stat_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ShockwaveTowerPerDefStatRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SHOCKWAVE_TOWER_PER_DEF_STAT_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'stats_tower',
            'stats_size_range',
            'stats_reload',
            'stats_requirements',
            'stats_class_fallback',
            'stats_live_input',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
