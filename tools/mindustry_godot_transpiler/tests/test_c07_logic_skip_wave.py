import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
GAME_WAVE = ROOT / 'godot-mindustry/src/game/SourceGameWaveState.gd'
SKIP_WAVE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LogicSkipWaveProof.gd'


class C07LogicSkipWaveTests(unittest.TestCase):
    def test_c07_logic_skip_wave_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2439']['godot_owner'], 'SourceGameWaveState.source_game_wave_skip_state')
        # Logic.skipWave() (Logic.java:315-317), one method
        # slice (batch 38 slot 2): exactly the 1 body expr
        # `runWave();` (:316). skipWave forwards to
        # runWave() (Logic.java:319-325, owned N2437) -- the
        # runWave body exprs (:320-324) are NOT
        # re-registered here; only the call site is. One GD
        # function on SourceGameWaveState.gd (created by
        # N2437); the forward precedent is N2422
        # (LaserTurretBuild.placed() forwarding to
        # super.placed()).
        self.assertEqual(
            ledger['N2439']['java_method'],
            'Logic.skipWave()',
        )
        self.assertEqual(
            ledger['N2439']['source_symbols'],
            [
                'source_game_wave_skip_state_result.skipped_wave',
                'source_game_wave_skip_state_result.wave',
                'source_game_wave_skip_state_result.wavetime',
                'source_game_wave_skip_state_result.spawn_enemies',
                'source_game_wave_skip_state_result.fired_event',
            ],
        )
        for name in ledger['N2439']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/core/Logic.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceGameWaveState.source_game_wave_skip_state'))
        self.assertEqual(ledger['N2439']['runtime_proof'], '/root/C07LogicSkipWaveProof')
        self.assertEqual(
            ledger['N2439']['tests'],
            [
                'test_c07_logic_skip_wave_registration',
                'test_all_c07_logic_skip_wave_input_evidence_is_exact',
                'test_logic_skip_wave_state',
                'test_reference_graph_and_actual_c07_logic_skip_wave',
            ],
        )
        self.assertTrue(ledger['N2439']['deferred_exprs'])

    def test_all_c07_logic_skip_wave_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2439']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceGameWaveState.source_game_wave_skip_state'))
        slice_sources = {
            'core/src/mindustry/core/Logic.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2439']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_logic_skip_wave_state(self):
        wave = GAME_WAVE.read_text(encoding='utf-8')
        # Logic.skipWave() (Logic.java:315-317): the 1 body
        # expr only -- `runWave();` (:316). The runWave
        # body exprs (:320-324) are owned by N2437 and are
        # NOT re-registered here; the skip func forwards
        # to source_game_wave_run_state and adds
        # skipped_wave: true to the envelope.
        self.assertIn('static func source_game_wave_skip_state(wave: int, wave_spacing: float, is_campaign: bool, wave_time_multiplier: float) -> Dictionary:', wave)
        self.assertIn('runWave();', wave)
        self.assertIn('source_game_wave_run_state(wave, wave_spacing, is_campaign, wave_time_multiplier)', wave)
        # The proof's keys drive the pure function with
        # synthetic inputs (no live tick, no spawner, no
        # event bus): one call increments the wave, returns
        # exactly the 5 result keys with skipped_wave true,
        # computes wavetime from the campaign multiplier
        # (or 1.0 outside campaign), records the two
        # deferred call-sites as data, and is idempotent
        # on a second call.
        proof = SKIP_WAVE_PROOF.read_text(encoding='utf-8')
        for key in [
            'skip_increments_wave',
            'skip_returns_five_keys',
            'skip_skipped_wave_true',
            'skip_wavetime_campaign',
            'skip_wavetime_non_campaign',
            'skip_spawn_enemies_true',
            'skip_fired_event_wave',
            'skip_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_logic_skip_wave(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LogicSkipWaveProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LOGIC_SKIP_WAVE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'skip_increments_wave',
            'skip_returns_five_keys',
            'skip_skipped_wave_true',
            'skip_wavetime_campaign',
            'skip_wavetime_non_campaign',
            'skip_spawn_enemies_true',
            'skip_fired_event_wave',
            'skip_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
