import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BUILD_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildTurretBuildState.gd'
BUILD_TURRET_PER_DEF_STAT_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BuildTurretPerDefStatRowsProof.gd'
BUILD_TURRET_PER_DEF_STAT_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BuildTurretPerDefStatRowsProof.tscn'


class C07BuildTurretPerDefStatRowsTests(unittest.TestCase):
    def test_c07_build_turret_per_def_stat_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2499']['godot_owner'], 'SourceBuildTurretBuildState.source_build_turret_per_def_stats_state')
        # The BuildTurret tick is live (N2184 power +
        # N2215 shouldConsume + N2243 sync/warmup +
        # N2244 plan logic + N2251 liquid + N2272
        # updateBuildLogic + N2431 draw + N2437 sense
        # + N2451 warmup/stats) but NOTHING modeled
        # the per-def stat rows as a source-backed
        # pure: the build-tower def
        # (Blocks.java:1997-2006) sets size 3, range
        # 200f, buildSpeed 1.5f and requirements
        # silicon 150 / oxide 40 / thorium 60, while
        # the values only existed as constants in the
        # driver header comment. N2499 ports them as
        # ONE pure-only stats pure (the N2304 / N2442
        # / N2489 / N2490 / N2498 verification-slice
        # precedent): the def's rows for build-tower,
        # with the CLASS defaults (size 1, range 80f,
        # buildSpeed 1f, no requirements) for an
        # unknown def id (the N2304 fallback
        # precedent). Four new result symbols: the
        # size + range + build speed + requirements.
        self.assertEqual(
            ledger['N2499']['source_symbols'],
            [
                'source_build_turret_per_def_stats_state_result.size',
                'source_build_turret_per_def_stats_state_result.range_value',
                'source_build_turret_per_def_stats_state_result.build_speed',
                'source_build_turret_per_def_stats_state_result.requirements',
            ],
        )
        expected_sources = {
            'source_build_turret_per_def_stats_state_result.size': 'core/src/mindustry/content/Blocks.java',
            'source_build_turret_per_def_stats_state_result.range_value': 'core/src/mindustry/content/Blocks.java',
            'source_build_turret_per_def_stats_state_result.build_speed': 'core/src/mindustry/content/Blocks.java',
            'source_build_turret_per_def_stats_state_result.requirements': 'core/src/mindustry/content/Blocks.java',
        }
        for name in ledger['N2499']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], expected_sources[name])
                self.assertTrue(symbol['godot_owner'].startswith('SourceBuildTurretBuildState.source_build_turret_'))
        self.assertEqual(ledger['N2499']['runtime_proof'], '/root/C07BuildTurretPerDefStatRowsProof')
        self.assertEqual(
            ledger['N2499']['tests'],
            [
                'test_c07_build_turret_per_def_stat_rows_registration',
                'test_all_c07_build_turret_per_def_stat_rows_input_evidence_is_exact',
                'test_build_turret_per_def_stat_rows_state',
                'test_reference_graph_and_actual_c07_build_turret_per_def_stat_rows',
            ],
        )
        self.assertTrue(ledger['N2499']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #61 (1-based in
        # the merged advances-35 DEFERRED base, 218
        # entries): the BuildTurret per-def stat rows
        # entry is REMOVED -- size / range /
        # buildSpeed / requirements are live now as a
        # source-backed pure. Net 218 - 1 = 217. The
        # suppression, unit and read/write rows STAY.
        self.assertFalse(any(entry.startswith('BuildTurret per-def stat rows (') for entry in ledger['N2499']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BuildTurret suppression rows (') for entry in ledger['N2499']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BuildTurret unit rows (') for entry in ledger['N2499']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BuildTurret read/write rows (') for entry in ledger['N2499']['deferred_exprs']))
        self.assertEqual(len(ledger['N2499']['deferred_exprs']), 217)

    def test_all_c07_build_turret_per_def_stat_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2499']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceBuildTurretBuildState.source_build_turret_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/BuildTurret.java',
            'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2499']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_build_turret_per_def_stat_rows_state(self):
        build_turret = BUILD_TURRET_STATE.read_text(encoding='utf-8')
        # The per-def stat rows (the VERIFICATION slice:
        # the values are already constants in the driver
        # header -- the N2304 / N2442 / N2489 / N2490 /
        # N2498 precedent): the single BuildTurret def
        # build-tower (Blocks.java:1997-2006) sets size
        # 3, range 200f, buildSpeed 1.5f and
        # requirements silicon 150 / oxide 40 /
        # thorium 60. An unknown def id falls back to
        # the CLASS defaults (the N2304 fallback
        # precedent): size 1 (Block.java:215), range
        # 80f -- the range field lives on BaseTurret,
        # NOT on Block or BuildTurret
        # (`public float range = 80f;`,
        # BaseTurret.java:21; `public class
        # BuildTurret extends BaseTurret{`,
        # BuildTurret.java:27; `public class
        # BaseTurret extends Block{`,
        # BaseTurret.java:20) -- buildSpeed 1f
        # (BuildTurret.java:33) and NO requirements
        # (the Block default is the empty array,
        # Block.java:356). The requirements dict is
        # the {item: amount} dict from the def (the
        # N2490 precedent); the catalog carries the
        # same rows as an Array of {item, amount}
        # (content_registry.json, build-tower). The
        # result key is range_value, NOT range
        # (`range` shadows the GDScript builtin, the
        # N2493 precedent). Pure-only: the caller
        # reads it; the existing pures are unchanged.
        # Keep each Java expr on ONE comment line (the
        # N2148 lesson: a split line fails this test).
        self.assertIn('static func source_build_turret_per_def_stats_state', build_turret)
        self.assertIn('buildTower = new BuildTurret("build-tower"){{', build_turret)
        self.assertIn('requirements(Category.effect, with(Items.silicon, 150, Items.oxide, 40, Items.thorium, 60));', build_turret)
        self.assertIn('range = 200f;', build_turret)
        self.assertIn('size = 3;', build_turret)
        self.assertIn('buildSpeed = 1.5f;', build_turret)
        self.assertIn('public float buildSpeed = 1f;', build_turret)
        self.assertIn('public float range = 80f;', build_turret)
        self.assertIn('public int size = 1;', build_turret)
        self.assertIn('public ItemStack[] requirements = {};', build_turret)
        self.assertIn('public class BuildTurret extends BaseTurret{', build_turret)
        self.assertIn('public class BaseTurret extends Block{', build_turret)
        # The documented limits record the per-def stat
        # rows as live.
        self.assertIn('Per-def stat rows live (N2499)', build_turret)
        # The proof's keys drive the per-def stats pure
        # (the build-tower def row, the size + range
        # values at the def vs the class, the build
        # speed at the def vs the class, the
        # requirements dict, the class fallback for an
        # unknown def id, and the def rows feeding the
        # N2451 stats pure as live inputs).
        proof = BUILD_TURRET_PER_DEF_STAT_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'stats_turret',
            'stats_size_range',
            'stats_build_speed',
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
        self.assertIn('preload("res://src/game/SourceBuildTurretBuildState.gd")', proof)
        self.assertTrue(BUILD_TURRET_STATE.exists())
        self.assertTrue(BUILD_TURRET_PER_DEF_STAT_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07BuildTurretPerDefStatRowsProof.gd', BUILD_TURRET_PER_DEF_STAT_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_build_turret_per_def_stat_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BuildTurretPerDefStatRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BUILD_TURRET_PER_DEF_STAT_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'stats_turret',
            'stats_size_range',
            'stats_build_speed',
            'stats_requirements',
            'stats_class_fallback',
            'stats_live_input',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
