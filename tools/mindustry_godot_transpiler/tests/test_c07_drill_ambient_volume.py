import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BURST_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBurstDrillBuildState.gd'
DRILL_AMBIENT_VOLUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07DrillAmbientVolumeProof.gd'


class C07DrillAmbientVolumeTests(unittest.TestCase):
    def test_c07_drill_ambient_volume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2277']['godot_owner'], 'SourceBurstDrillBuildState.source_drill_ambient_volume_state')
        # DrillBuild.ambientVolume() (Drill.java:257-259,
        # `public float ambientVolume(){`) returns
        # `efficiency * (size * size) / 4f;` (:258).
        # `efficiency` is the live Building efficiency
        # (`transient float efficiency;`,
        # BuildingComp.java:85), carried on the frame
        # (absent defaults to 0.0 -- the N2258 liquid-rows
        # frame-key precedent). `size` is the block size in
        # tiles (`public int size = 1;`, Block.java:215),
        # a per-def param passed explicitly (the N2212
        # per-def-param precedent): impact-drill size 4
        # (Blocks.java:3073), eruption-drill size 5
        # (Blocks.java:3096). At efficiency 1 the super is
        # 4.0 vs 6.25 -- the exact values N2271 takes as its
        # explicit super input. This slice CLOSES the
        # super-leg deferred entry N2271 carried. One new
        # result symbol: ambient_volume. There is NO driver
        # tick line: ambientVolume is read per tick by the
        # ambient-sound live loop (BuildingComp.java:2271,
        # `control.sound.loop(block.ambientSound, self(),
        # block.ambientSoundVolume * ambientVolume());`),
        # whose driver side waits for ambient C (N2264).
        self.assertEqual(
            ledger['N2277']['source_symbols'],
            [
                'source_drill_ambient_volume_state_result.ambient_volume',
            ],
        )
        for name in ledger['N2277']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/Drill.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/world/Block.java',
                    'core/src/mindustry/content/Blocks.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2277']['runtime_proof'], '/root/C07DrillAmbientVolumeProof')
        self.assertEqual(
            ledger['N2277']['tests'],
            [
                'test_c07_drill_ambient_volume_registration',
                'test_all_c07_drill_ambient_volume_input_evidence_is_exact',
                'test_drill_ambient_volume_state',
                'test_reference_graph_and_actual_c07_drill_ambient_volume',
            ],
        )
        self.assertTrue(ledger['N2277']['deferred_exprs'])

    def test_all_c07_drill_ambient_volume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2277']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/production/Drill.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2277']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_drill_ambient_volume_state(self):
        burst_drill = BURST_DRILL_STATE.read_text(encoding='utf-8')
        # DrillBuild.ambientVolume() (Drill.java:257-259,
        # `public float ambientVolume(){`) returns
        # `efficiency * (size * size) / 4f;` (:258).
        # `efficiency` is the live Building efficiency
        # (`transient float efficiency;`,
        # BuildingComp.java:85), carried on the frame
        # (absent defaults to 0.0). `size` is the block
        # size in tiles (`public int size = 1;`,
        # Block.java:215), passed explicitly per def.
        # The classes are `public class Drill extends
        # Block{` (Drill.java:27) and `public class
        # DrillBuild extends Building{` (Drill.java:237).
        # The defs are `impactDrill = new
        # BurstDrill("impact-drill"){{`
        # (Blocks.java:3070, size 4, Blocks.java:3073)
        # and `eruptionDrill = new
        # BurstDrill("eruption-drill"){{`
        # (Blocks.java:3093, size 5, Blocks.java:3096).
        # There is NO driver tick line: the ambient-sound
        # live loop reads ambientVolume per tick
        # (BuildingComp.java:2271); the driver side waits
        # for ambient C (N2264).
        self.assertIn('static func source_drill_ambient_volume_state(frame: Dictionary, size: int) -> Dictionary:', burst_drill)
        self.assertIn('return {"ambient_volume": ambient_volume}', burst_drill)
        for expr in [
            'public float ambientVolume(){',
            'return efficiency * (size * size) / 4f;',
            'transient float efficiency;',
            'public int size = 1;',
            'public class Drill extends Block{',
            'public class DrillBuild extends Building{',
            'impactDrill = new BurstDrill("impact-drill"){{',
            'eruptionDrill = new BurstDrill("eruption-drill"){{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, burst_drill)
        # The proof's keys drive the pure function directly
        # with frame efficiency + explicit size inputs:
        # efficiency 0 silences the drill, efficiency 1
        # with size 4 gives 4.0, efficiency 0.5 with size
        # 4 gives 2.0, the Block default size 1 gives
        # 0.25, and the per-def key pins impact-drill
        # (size 4) vs eruption-drill (size 5) at
        # efficiency 1 (4.0 vs 6.25) and 0.5 (2.0 vs 3.125).
        proof = DRILL_AMBIENT_VOLUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'ambient_volume_efficiency_zero',
            'ambient_volume_efficiency_full',
            'ambient_volume_efficiency_half',
            'ambient_volume_size_one',
            'ambient_volume_per_def',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_drill_ambient_volume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07DrillAmbientVolumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_DRILL_AMBIENT_VOLUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'ambient_volume_efficiency_zero',
            'ambient_volume_efficiency_full',
            'ambient_volume_efficiency_half',
            'ambient_volume_size_one',
            'ambient_volume_per_def',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
