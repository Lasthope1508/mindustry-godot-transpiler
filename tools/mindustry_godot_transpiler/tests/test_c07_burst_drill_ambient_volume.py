import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BURST_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBurstDrillBuildState.gd'
BURST_DRILL_AMBIENT_VOLUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BurstDrillAmbientVolumeProof.gd'


class C07BurstDrillAmbientVolumeTests(unittest.TestCase):
    def test_c07_burst_drill_ambient_volume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2317']['godot_owner'], 'SourceBurstDrillBuildState.source_burst_drill_ambient_volume_state')
        # BurstDrill.ambientVolume() (BurstDrill.java:123-125,
        # `public float ambientVolume(){`) returns
        # `super.ambientVolume() * Mathf.pow(progress(), 4f);`
        # (:124). The super is DrillBuild.ambientVolume
        # (Drill.java:257-259, `return efficiency * (size *
        # size) / 4f;`), NOT ported: the caller passes the
        # already-computed super result as an explicit param
        # (the N2316 explicit-param precedent). progress()
        # is DrillBuild.progress (Drill.java:327-329, `return
        # dominantItem == null ? 0f : Mathf.clamp(progress /
        # getDrillTime(dominantItem));`), also NOT ported for
        # DrillBuild (N700 / N1627 are PortGame game-level
        # progress): the caller passes the already-computed
        # progress as an explicit param. One new result
        # symbol: ambient_volume. Two defs share the
        # function (impact-drill size 4, Blocks.java:3073;
        # eruption-drill size 5, Blocks.java:3096); at
        # efficiency 1 the super is 4.0 vs 6.25, and the
        # caller passes those per-def values. There is NO
        # driver tick line: ambientVolume is read per tick
        # by the ambient-sound live loop
        # (BuildingComp.java:2271, `control.sound.loop(
        # block.ambientSound, self(),
        # block.ambientSoundVolume * ambientVolume());`),
        # whose driver side waits for ambient C (N2264).
        self.assertEqual(
            ledger['N2317']['source_symbols'],
            [
                'source_burst_drill_ambient_volume_state_result.ambient_volume',
            ],
        )
        for name in ledger['N2317']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/BurstDrill.java',
                    'core/src/mindustry/world/blocks/production/Drill.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2317']['runtime_proof'], '/root/C07BurstDrillAmbientVolumeProof')
        self.assertEqual(
            ledger['N2317']['tests'],
            [
                'test_c07_burst_drill_ambient_volume_registration',
                'test_all_c07_burst_drill_ambient_volume_input_evidence_is_exact',
                'test_burst_drill_ambient_volume_state',
                'test_reference_graph_and_actual_c07_burst_drill_ambient_volume',
            ],
        )
        self.assertTrue(ledger['N2317']['deferred_exprs'])

    def test_all_c07_burst_drill_ambient_volume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2317']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/production/BurstDrill.java',
            'core/src/mindustry/world/blocks/production/Drill.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2317']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_burst_drill_ambient_volume_state(self):
        burst_drill = BURST_DRILL_STATE.read_text(encoding='utf-8')
        # BurstDrill.ambientVolume() (BurstDrill.java:123-125,
        # `public float ambientVolume(){`) returns
        # `super.ambientVolume() * Mathf.pow(progress(), 4f);`
        # (:124). The super is DrillBuild.ambientVolume
        # (Drill.java:257-259, `return efficiency * (size *
        # size) / 4f;`), NOT this slice: the caller passes
        # the super result explicitly (the N2316 precedent).
        # progress() is DrillBuild.progress
        # (Drill.java:327-329, `return dominantItem == null
        # ? 0f : Mathf.clamp(progress /
        # getDrillTime(dominantItem));`), also NOT this slice
        # for DrillBuild: the caller passes progress
        # explicitly. `progress` is the DrillBuild field
        # (`public float progress;`, Drill.java:238). The
        # classes are `public class BurstDrill extends
        # Drill{` (BurstDrill.java:17) and `public class
        # Drill extends Block{` (Drill.java:27). There is NO
        # driver tick line: the ambient-sound live loop
        # reads ambientVolume per tick
        # (BuildingComp.java:2271); the driver side waits
        # for ambient C (N2264).
        self.assertIn('static func source_burst_drill_ambient_volume_state(super_ambient_volume: float, progress: float) -> Dictionary:', burst_drill)
        self.assertIn('return {"ambient_volume": ambient_volume}', burst_drill)
        for expr in [
            'public float ambientVolume(){',
            'return super.ambientVolume() * Mathf.pow(progress(), 4f);',
            'return efficiency * (size * size) / 4f;',
            'public float progress(){',
            'return dominantItem == null ? 0f : Mathf.clamp(progress / getDrillTime(dominantItem));',
            'public class BurstDrill extends Drill{',
            'public class Drill extends Block{',
            'public float progress;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, burst_drill)
        # The proof's keys drive the pure function directly
        # with explicit super + progress inputs: progress 0
        # silences the drill, progress 1 passes the super
        # through, progress 0.5 quarters it twice (0.5^4 =
        # 0.0625), and the per-def key pins impact-drill
        # (size 4, super 4.0 at efficiency 1) vs
        # eruption-drill (size 5, super 6.25).
        proof = BURST_DRILL_AMBIENT_VOLUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'ambient_volume_progress_zero',
            'ambient_volume_progress_full',
            'ambient_volume_progress_half',
            'ambient_volume_super_zero',
            'ambient_volume_per_def',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_burst_drill_ambient_volume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BurstDrillAmbientVolumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BURST_DRILL_AMBIENT_VOLUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'ambient_volume_progress_zero',
            'ambient_volume_progress_full',
            'ambient_volume_progress_half',
            'ambient_volume_super_zero',
            'ambient_volume_per_def',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
