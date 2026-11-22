import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
GAME_WAVE = ROOT / 'godot-mindustry/src/game/SourceGameWaveState.gd'
RUN_WAVE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LogicRunWaveProof.gd'


class C07LogicRunWaveTests(unittest.TestCase):
    def test_c07_logic_run_wave_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2437']['godot_owner'], 'SourceGameWaveState.source_game_wave_run_state')
        # Logic.runWave() (Logic.java:319-325), one method slice
        # (batch 37 slot 3): exactly the 4 body exprs. The
        # wavetime formula in play() (Logic.java:272, with
        # initialWaveSpacing + `* 2`) is NOT re-registered
        # here, nor is skipWave() (Logic.java:315-317, a
        # later 1-expr slice once runWave lands) nor
        # `state.stats.wavesLasted = state.wave;` from
        # gameOver() (Logic.java:434, a different method).
        # One GD function on the NEW SourceGameWaveState.gd;
        # the file-new precedent is N2405
        # (SourceBaseTurretDefaults.gd) + N2407
        # (SourceContinuousTurretDefaults.gd). The two
        # call-sites are deferred as data in the returned
        # Dictionary: spawner.spawnEnemies() waits for a
        # WaveSpawner slice (WaveSpawner.java unscanned,
        # 0-hit both ledgers) and Events.fire(new
        # WaveEvent()) waits for an event bus (method
        # Events.on 0-hit both ledgers; no bus in the port).
        self.assertEqual(
            ledger['N2437']['java_method'],
            'Logic.runWave()',
        )
        self.assertEqual(
            ledger['N2437']['source_symbols'],
            [
                'source_game_wave_run_state_result.wave',
                'source_game_wave_run_state_result.wavetime',
                'source_game_wave_run_state_result.spawn_enemies',
                'source_game_wave_run_state_result.fired_event',
            ],
        )
        for name in ledger['N2437']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/core/Logic.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceGameWaveState.source_game_wave_run_state'))
        self.assertEqual(ledger['N2437']['runtime_proof'], '/root/C07LogicRunWaveProof')
        self.assertEqual(
            ledger['N2437']['tests'],
            [
                'test_c07_logic_run_wave_registration',
                'test_all_c07_logic_run_wave_input_evidence_is_exact',
                'test_logic_run_wave_state',
                'test_reference_graph_and_actual_c07_logic_run_wave',
            ],
        )
        self.assertTrue(ledger['N2437']['deferred_exprs'])

    def test_all_c07_logic_run_wave_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2437']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceGameWaveState.source_game_wave_run_state'))
        slice_sources = {
            'core/src/mindustry/core/Logic.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2437']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_logic_run_wave_state(self):
        wave = GAME_WAVE.read_text(encoding='utf-8')
        # Logic.runWave() (Logic.java:319-325): the 4 body
        # exprs only. The play() wavetime formula (:272),
        # skipWave() (:315-317) and the gameOver()
        # wavesLasted line (:434) are NOT in this slice.
        self.assertIn('static func source_game_wave_run_state(wave: int, wave_spacing: float, is_campaign: bool, wave_time_multiplier: float) -> Dictionary:', wave)
        for expr in [
            'spawner.spawnEnemies();',
            'state.wave++;',
            'state.wavetime = state.rules.waveSpacing * (state.isCampaign() ? state.getPlanet().campaignRules.difficulty.waveTimeMultiplier : 1f);',
            'Events.fire(new WaveEvent());',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, wave)
        # The proof's keys drive the pure function with
        # synthetic inputs (no live tick, no spawner, no
        # event bus): one call increments the wave, returns
        # exactly the 4 result keys, computes wavetime
        # from the campaign multiplier (or 1.0 outside
        # campaign), records the two deferred call-sites
        # as data, and is idempotent on a second call.
        proof = RUN_WAVE_PROOF.read_text(encoding='utf-8')
        for key in [
            'run_increments_wave',
            'run_returns_only_four_keys',
            'run_wavetime_campaign',
            'run_wavetime_non_campaign',
            'run_spawn_enemies_true',
            'run_fired_event_wave',
            'run_wavetime_is_float',
            'run_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_logic_run_wave(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LogicRunWaveProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LOGIC_RUN_WAVE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'run_increments_wave',
            'run_returns_only_four_keys',
            'run_wavetime_campaign',
            'run_wavetime_non_campaign',
            'run_spawn_enemies_true',
            'run_fired_event_wave',
            'run_wavetime_is_float',
            'run_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
