import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
RADAR_STATE = ROOT / 'godot-mindustry/src/game/SourceRadarBuildState.gd'
DEFAULT_CTOR_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RadarDefaultConstructorProof.gd'


class C07RadarDefaultConstructorTests(unittest.TestCase):
    def test_c07_radar_default_constructor_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2404']['godot_owner'], 'SourceRadarBuildState.source_radar_default_constructor_state')
        # Radar(String name) (Radar.java:27-34), one ctor
        # slice (batch 26 slot 2): the 3 literal field
        # defaults only. `super(name);` is already the
        # exact_expr of N2185, `fogRadius = 10;` of
        # N2320/N2321/N2342 -- neither is re-registered
        # here. One GD function on SourceRadarBuildState.gd
        # (the Radar family file); the N2400 Turret ctor
        # precedent (owner
        # `source_turret_default_constructor_state`) and
        # the N2401 BeamDrill ctor precedent for the flags
        # Variant passthrough. The defaults are frame data
        # only; no Draw is ported. Radar was declared
        # 40/40 done at renumber #52 -- that was drawSelect
        # completion; this ctor is the last unported Radar
        # block-level item, reopened by main-thread
        # approval for batch 26.
        self.assertEqual(
            ledger['N2404']['java_method'],
            'Radar(String name)',
        )
        self.assertEqual(
            ledger['N2404']['source_symbols'],
            [
                'source_radar_default_constructor_state_result.update',
                'source_radar_default_constructor_state_result.solid',
                'source_radar_default_constructor_state_result.flags',
                'source_radar_default_constructor_state_result.outline_icon',
                'source_radar_default_constructor_state_result.radar_defaults',
            ],
        )
        for name in ledger['N2404']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/Radar.java',
                })
                self.assertTrue(symbol['godot_owner'].startswith('SourceRadarBuildState.source_radar_default_constructor_state'))
        self.assertEqual(ledger['N2404']['runtime_proof'], '/root/C07RadarDefaultConstructorProof')
        self.assertEqual(
            ledger['N2404']['tests'],
            [
                'test_c07_radar_default_constructor_registration',
                'test_all_c07_radar_default_constructor_input_evidence_is_exact',
                'test_radar_default_constructor_state',
                'test_reference_graph_and_actual_c07_radar_default_constructor',
            ],
        )
        self.assertTrue(ledger['N2404']['deferred_exprs'])

    def test_all_c07_radar_default_constructor_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2404']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceRadarBuildState.source_radar_default_constructor_state'))
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/Radar.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2404']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_radar_default_constructor_state(self):
        radar = RADAR_STATE.read_text(encoding='utf-8')
        # Radar(String name) (Radar.java:27-34): the ctor
        # assigns 3 literal field defaults on the Radar
        # def; the 2 other lines are owned elsewhere (see
        # the registration test) and are NOT re-registered.
        self.assertIn('static func source_radar_default_constructor_state(radar_defaults: Dictionary, block_flags: Variant) -> Dictionary:', radar)
        for expr in [
            'update = solid = true;',
            'flags = EnumSet.of(BlockFlag.hasFogRadius);',
            'outlineIcon = true;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, radar)
        # The proof's keys drive the pure function with
        # synthetic inputs (no live tick, no render): one
        # call returns all 4 ctor values, writes them
        # into the def frame, preserves unrelated frame
        # keys, overwrites stale frame values, passes the
        # flags param through in both shapes, and is
        # idempotent on a second call.
        proof = DEFAULT_CTOR_PROOF.read_text(encoding='utf-8')
        for key in [
            'ctor_defaults_all_four',
            'ctor_returns_only_five_keys',
            'ctor_writes_frame',
            'ctor_preserves_existing_frame_keys',
            'ctor_overwrites_stale_frame_values',
            'ctor_bool_defaults',
            'ctor_flags_passthrough',
            'ctor_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_radar_default_constructor(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RadarDefaultConstructorProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_RADAR_DEFAULT_CONSTRUCTOR_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'ctor_defaults_all_four',
            'ctor_returns_only_five_keys',
            'ctor_writes_frame',
            'ctor_preserves_existing_frame_keys',
            'ctor_overwrites_stale_frame_values',
            'ctor_bool_defaults',
            'ctor_flags_passthrough',
            'ctor_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
