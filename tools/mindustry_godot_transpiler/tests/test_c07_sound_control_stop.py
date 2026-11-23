import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SOUND_CONTROL_STATE = ROOT / 'godot-mindustry/src/game/SourceSoundControlState.gd'
SOUND_CONTROL_STOP_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SoundControlStopProof.gd'


class C07SoundControlStopTests(unittest.TestCase):
    def test_c07_sound_control_stop_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        # SoundControl.stop() (SoundControl.java:118-127)
        # sets silenced, then stops the current track (if
        # any), clears it and zeroes fade. This is a
        # SEPARATE public method from silence() and
        # keepSilent() (N2336 own those) -- stop() is the
        # one update() :165-167 calls when keepSilent is
        # set. YELLOW FLAG (scope batch 8 section 3.3):
        # `silenced = true;` already appears in N2336,
        # `current.stop();` in N2336/N2345, `current = null;`
        # and `fade = 0f;` in N2336/N2339/N2345 -- same
        # text, DIFFERENT method (stop() vs silence() /
        # play()); the registry precedent (N632-N639 vs
        # N1078-N1085) allows identical exact_exprs under
        # different java_methods. NO audio playback in this
        # slice (0 AudioStreamPlayer in the port): the stop
        # is returned as command state, never executed;
        # playback belongs to updateLoops (N2304, held
        # waiting for B). Caller update() is NOT ported here.
        self.assertEqual(ledger['N2352']['godot_owner'], 'SourceSoundControlState.source_sound_control_stop_state')
        self.assertEqual(
            ledger['N2352']['source_symbols'],
            [
                'source_sound_control_stop_state_result.silenced',
                'source_sound_control_stop_state_result.current',
                'source_sound_control_stop_state_result.fade',
                'source_sound_control_stop_state_result.stopped',
                'source_sound_control_stop_state_result.commands',
            ],
        )
        for name in ledger['N2352']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/audio/SoundControl.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceSoundControlState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2352']['runtime_proof'], '/root/C07SoundControlStopProof')
        self.assertEqual(
            ledger['N2352']['tests'],
            [
                'test_c07_sound_control_stop_registration',
                'test_all_c07_sound_control_stop_input_evidence_is_exact',
                'test_sound_control_stop_state',
                'test_reference_graph_and_actual_c07_sound_control_stop',
            ],
        )
        self.assertTrue(ledger['N2352']['deferred_exprs'])

    def test_all_c07_sound_control_stop_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2352']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceSoundControlState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/audio/SoundControl.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2352']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_sound_control_stop_state(self):
        state = SOUND_CONTROL_STATE.read_text(encoding='utf-8')
        # SoundControl.stop() (SoundControl.java:118-127):
        # `public void stop(){` / `silenced = true;` /
        # `if(current != null){` / `current.stop();` /
        # `current = null;` / `fade = 0f;` -- silenced is
        # set unconditionally; the stop, clear and fade
        # reset only run when a track is playing. Music
        # arrives as its name String (the N2287 precedent);
        # has_current folds the null check (the N2306
        # precedent). The stop is returned as one command
        # (`track`, `action` -- the N2345 shape), never
        # executed: NO audio playback in this slice.
        self.assertIn('static func source_sound_control_stop_state(has_current: bool, current: String, fade: float) -> Dictionary:', state)
        self.assertIn('commands.append({"track": current, "action": "stop"})', state)
        self.assertIn('return {"silenced": true, "current": null, "fade": 0.0, "stopped": true, "commands": commands}', state)
        self.assertIn('return {"silenced": true, "current": null, "fade": fade, "stopped": false, "commands": commands}', state)
        for expr in [
            'public void stop(){',
            'silenced = true;',
            'if(current != null){',
            'current.stop();',
            'current = null;',
            'fade = 0f;',
            'protected @Nullable Music current;',
            'protected float fade;',
            'protected boolean silenced, keepSilent;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        # NO audio playback in this slice (0 AudioStreamPlayer
        # in the port): stop only returns command state;
        # playback belongs to updateLoops (N2304, held
        # waiting for B).
        self.assertNotIn('AudioStreamPlayer', state)
        # NO real RNG in the ported function: stopping is
        # pure state + command construction on explicit params.
        self.assertNotIn('randf()', state)
        self.assertNotIn('randi()', state)
        # The proof's keys drive the pure function directly:
        # silenced is always true; a playing track is
        # stopped (one stop command, current cleared, fade
        # zeroed); no track is a no-op for current/fade
        # (fade passes through); the result has exactly
        # five keys.
        proof = SOUND_CONTROL_STOP_PROOF.read_text(encoding='utf-8')
        for key in [
            'stop_silences_always',
            'stop_stops_current_track',
            'stop_clears_current_and_fade',
            'stop_no_track_noop',
            'stop_returns_only_five_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_sound_control_stop(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07SoundControlStopProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SOUND_CONTROL_STOP_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'stop_silences_always',
            'stop_stops_current_track',
            'stop_clears_current_and_fade',
            'stop_no_track_noop',
            'stop_returns_only_five_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
