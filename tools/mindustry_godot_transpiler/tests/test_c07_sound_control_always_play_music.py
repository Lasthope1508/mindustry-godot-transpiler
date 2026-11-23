import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SOUND_CONTROL_STATE = ROOT / 'godot-mindustry/src/game/SourceSoundControlState.gd'
SOUND_CONTROL_ALWAYS_PLAY_MUSIC_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SoundControlAlwaysPlayMusicProof.gd'


class C07SoundControlAlwaysPlayMusicTests(unittest.TestCase):
    def test_c07_sound_control_always_play_music_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2306']['godot_owner'], 'SourceSoundControlState.source_sound_control_always_play_music_state')
        # SoundControl.alwaysPlayMusic() (SoundControl.java:266-268,
        # `protected boolean alwaysPlayMusic(){` / `return
        # state.rules.alwaysPlayMusic ||
        # Core.settings.getBool("alwaysmusic") ||
        # (state.getPlanet() != null &&
        # state.getPlanet().alwaysPlayMusic);`) is a one-line
        # gate over three bool flags. Its caller reads the gate
        # in update() (SoundControl.java:181-183,
        # `if(alwaysPlayMusic()){` + `if(current == null){` +
        # `playRandom();`) and plays a random track when the
        # gate is true and no current track is set. It is a
        # pure function on SourceSoundControlState.gd next to
        # the N2299 shouldPlay / isPlaying gates; every live
        # value arrives as an explicit param (the N2291
        # precedent): the three flags -- the state.rules /
        # Core.settings / state.getPlanet() accessors are NOT
        # ported in this slice, and the planet null check is
        # folded into the planet flag param. One new result
        # symbol: always_play_music. NO audio playback in
        # this slice (0 AudioStreamPlayer in the port).
        self.assertEqual(
            ledger['N2306']['source_symbols'],
            [
                'source_sound_control_always_play_music_state_result.always_play_music',
            ],
        )
        for name in ledger['N2306']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/audio/SoundControl.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceSoundControlState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2306']['runtime_proof'], '/root/C07SoundControlAlwaysPlayMusicProof')
        self.assertEqual(
            ledger['N2306']['tests'],
            [
                'test_c07_sound_control_always_play_music_registration',
                'test_all_c07_sound_control_always_play_music_input_evidence_is_exact',
                'test_sound_control_always_play_music_state',
                'test_reference_graph_and_actual_c07_sound_control_always_play_music',
            ],
        )
        self.assertTrue(ledger['N2306']['deferred_exprs'])

    def test_all_c07_sound_control_always_play_music_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2306']['source_symbols']:
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
        for expr in ledger['N2306']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_sound_control_always_play_music_state(self):
        state = SOUND_CONTROL_STATE.read_text(encoding='utf-8')
        # SoundControl.alwaysPlayMusic() (SoundControl.java:266-268):
        # `return state.rules.alwaysPlayMusic ||
        # Core.settings.getBool("alwaysmusic") ||
        # (state.getPlanet() != null &&
        # state.getPlanet().alwaysPlayMusic);` -- a plain OR
        # of the three flags: any single true flag reads true
        # and all false reads false. The three flags arrive
        # as explicit bool params; the planet null check is
        # folded into the planet flag param.
        self.assertIn('static func source_sound_control_always_play_music_state(rules_always_play_music: bool, setting_alwaysmusic: bool, planet_always_play_music: bool) -> Dictionary:', state)
        self.assertIn('return {"always_play_music": rules_always_play_music or setting_alwaysmusic or planet_always_play_music}', state)
        for expr in [
            'protected boolean alwaysPlayMusic(){',
            'return state.rules.alwaysPlayMusic || Core.settings.getBool("alwaysmusic") || (state.getPlanet() != null && state.getPlanet().alwaysPlayMusic);',
            'if(alwaysPlayMusic()){',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        # NO audio playback in this slice (0 AudioStreamPlayer
        # in the port): this is a pure gate; playback belongs
        # to updateLoops (N2304, held waiting for B).
        self.assertNotIn('AudioStreamPlayer', state)
        # The proof's keys drive the pure function directly
        # with explicit params: each disjunct true alone, all
        # false, all true, and two true at once.
        proof = SOUND_CONTROL_ALWAYS_PLAY_MUSIC_PROOF.read_text(encoding='utf-8')
        for key in [
            'always_play_rules_true',
            'always_play_setting_true',
            'always_play_planet_true',
            'always_play_all_false',
            'always_play_all_true',
            'always_play_two_true',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_sound_control_always_play_music(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07SoundControlAlwaysPlayMusicProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SOUND_CONTROL_ALWAYS_PLAY_MUSIC_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'always_play_rules_true',
            'always_play_setting_true',
            'always_play_planet_true',
            'always_play_all_false',
            'always_play_all_true',
            'always_play_two_true',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
