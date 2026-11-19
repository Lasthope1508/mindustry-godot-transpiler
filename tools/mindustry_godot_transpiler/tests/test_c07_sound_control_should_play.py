import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SOUND_CONTROL_STATE = ROOT / 'godot-mindustry/src/game/SourceSoundControlState.gd'
SOUND_CONTROL_SHOULD_PLAY_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SoundControlShouldPlayProof.gd'


class C07SoundControlShouldPlayTests(unittest.TestCase):
    def test_c07_sound_control_should_play_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2299']['godot_owner'], 'SourceSoundControlState.source_sound_control_should_play_state')
        # SoundControl.shouldPlay() (SoundControl.java:369-371,
        # `protected boolean shouldPlay(){` / `return
        # Core.settings.getInt("musicvol") > 0;`) and
        # SoundControl.isPlaying() (SoundControl.java:251-253,
        # `public boolean isPlaying(){` / `return current !=
        # null && current.isPlaying();`) are one-line gates
        # over the current track (SoundControl.java:34,
        # `protected @Nullable Music current;`). shouldPlay is
        # the music gate its caller reads every update
        # (SoundControl.java:304, `if(!shouldPlay()){` --
        # a false gate silences the current track, :305-306);
        # isPlaying is the null-safe current-track check.
        # Both are pure functions on SourceSoundControlState.gd
        # next to the N2287 loop accumulator; every live value
        # arrives as an explicit param (the N2291 precedent):
        # music_vol for shouldPlay (the settings accessor is
        # NOT ported in this slice), has_current +
        # current_is_playing for isPlaying (no Music.play /
        # stop calls). Two new result symbols: should_play
        # and is_playing. NO audio playback in this slice
        # (0 AudioStreamPlayer in the port).
        self.assertEqual(
            ledger['N2299']['source_symbols'],
            [
                'source_sound_control_should_play_state_result.should_play',
                'source_sound_control_is_playing_state_result.is_playing',
            ],
        )
        for name in ledger['N2299']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/audio/SoundControl.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceSoundControlState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2299']['runtime_proof'], '/root/C07SoundControlShouldPlayProof')
        self.assertEqual(
            ledger['N2299']['tests'],
            [
                'test_c07_sound_control_should_play_registration',
                'test_all_c07_sound_control_should_play_input_evidence_is_exact',
                'test_sound_control_should_play_state',
                'test_reference_graph_and_actual_c07_sound_control_should_play',
            ],
        )
        self.assertTrue(ledger['N2299']['deferred_exprs'])

    def test_all_c07_sound_control_should_play_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2299']['source_symbols']:
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
        for expr in ledger['N2299']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_sound_control_should_play_state(self):
        state = SOUND_CONTROL_STATE.read_text(encoding='utf-8')
        # SoundControl.shouldPlay() (SoundControl.java:369-371):
        # `return Core.settings.getInt("musicvol") > 0;` -- the
        # comparison is strict (> 0): a zero or negative music
        # volume reads false, and the caller silences the
        # current track (SoundControl.java:304-306,
        # `if(!shouldPlay()){` + `current.setVolume(0);`).
        # The settings accessor is NOT ported in this slice:
        # music_vol arrives as an explicit int param.
        self.assertIn('static func source_sound_control_should_play_state(music_vol: int) -> Dictionary:', state)
        self.assertIn('return {"should_play": music_vol > 0}', state)
        # SoundControl.isPlaying() (SoundControl.java:251-253):
        # `return current != null && current.isPlaying();` --
        # the null check short-circuits: no current track reads
        # false whatever current_is_playing says. has_current
        # and current_is_playing arrive as explicit params; no
        # Music.play / stop calls in this slice.
        self.assertIn('static func source_sound_control_is_playing_state(has_current: bool, current_is_playing: bool) -> Dictionary:', state)
        self.assertIn('return {"is_playing": has_current and current_is_playing}', state)
        for expr in [
            'public boolean isPlaying(){',
            'return current != null && current.isPlaying();',
            'protected boolean shouldPlay(){',
            'return Core.settings.getInt("musicvol") > 0;',
            'protected @Nullable Music current;',
            'if(!shouldPlay()){',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        # NO audio playback in this slice (0 AudioStreamPlayer
        # in the port): these are pure gates; playback belongs
        # to updateLoops (N2264, held waiting for B).
        self.assertNotIn('AudioStreamPlayer', state)
        # The proof's keys drive both pure functions directly
        # with explicit params: shouldPlay true at a positive
        # volume, false at zero and at a negative volume; a
        # playing current track, no current track, and a
        # stopped current track for isPlaying.
        proof = SOUND_CONTROL_SHOULD_PLAY_PROOF.read_text(encoding='utf-8')
        for key in [
            'should_play_positive',
            'should_play_zero',
            'should_play_negative',
            'is_playing_current_playing',
            'is_playing_no_current',
            'is_playing_current_stopped',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_sound_control_should_play(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07SoundControlShouldPlayProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SOUND_CONTROL_SHOULD_PLAY_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'should_play_positive',
            'should_play_zero',
            'should_play_negative',
            'is_playing_current_playing',
            'is_playing_no_current',
            'is_playing_current_stopped',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
