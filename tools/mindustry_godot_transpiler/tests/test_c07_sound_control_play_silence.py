import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SOUND_CONTROL_STATE = ROOT / 'godot-mindustry/src/game/SourceSoundControlState.gd'
SOUND_CONTROL_PLAY_SILENCE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SoundControlPlaySilenceProof.gd'


class C07SoundControlPlaySilenceTests(unittest.TestCase):
    def test_c07_sound_control_play_silence_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        # SoundControl.play(Music) (SoundControl.java:303-353)
        # is the fade state machine the caller drives every
        # frame: shouldPlay() gates it (N2299), current /
        # fade / silenced carry in and out, Time.delta and
        # finTime / foutTime arrive as explicit params, and
        # current.play() / stop() / setVolume() /
        # setLooping() arrive as playback-command state --
        # NO audio playback in this slice (0
        # AudioStreamPlayer in the port). silence()
        # (:374-376) is play(null) and keepSilent()
        # (:197-199) only sets the flag update() consumes --
        # both ride in this one slice, update() itself stays
        # OUT (it also needs playRandom + updateLoops N2304,
        # held waiting for B).
        self.assertEqual(ledger['N2336']['godot_owner'], 'SourceSoundControlState.source_sound_control_play_state')
        self.assertEqual(
            ledger['N2336']['source_symbols'],
            [
                'source_sound_control_play_state_result.current',
                'source_sound_control_play_state_result.fade',
                'source_sound_control_play_state_result.silenced',
                'source_sound_control_play_state_result.commands',
                'source_sound_control_silence_state_result.current',
                'source_sound_control_silence_state_result.fade',
                'source_sound_control_silence_state_result.silenced',
                'source_sound_control_silence_state_result.commands',
                'source_sound_control_keep_silent_state_result.keep_silent',
            ],
        )
        for name in ledger['N2336']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/audio/SoundControl.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceSoundControlState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2336']['runtime_proof'], '/root/C07SoundControlPlaySilenceProof')
        self.assertEqual(
            ledger['N2336']['tests'],
            [
                'test_c07_sound_control_play_silence_registration',
                'test_all_c07_sound_control_play_silence_input_evidence_is_exact',
                'test_sound_control_play_silence_state',
                'test_reference_graph_and_actual_c07_sound_control_play_silence',
            ],
        )
        self.assertTrue(ledger['N2336']['deferred_exprs'])

    def test_all_c07_sound_control_play_silence_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2336']['source_symbols']:
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
        for expr in ledger['N2336']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_sound_control_play_silence_state(self):
        state = SOUND_CONTROL_STATE.read_text(encoding='utf-8')
        # SoundControl.play(Music) (SoundControl.java:303-353):
        # the fade state machine -- !shouldPlay() mutes the
        # current track and zeroes fade; the current track
        # volume is updated every frame from fade *
        # musicvol / 100; a silenced machine returns after
        # that volume update; a null current with a track
        # starts it (looping, volume fade = 0, play);
        # the same track fades in (clamp fade + delta /
        # finTime); another track fades out (clamp fade -
        # delta / foutTime) and at fade <= 0.01 stops, clears
        # current, marks silenced, and starts the scheduled
        # track when one is set. silence() (:374-376) is
        # play(null); keepSilent() (:197-199) only sets the
        # flag. Music arrives as its name String (the N2287
        # precedent); null music / current arrive as explicit
        # bool params (the N2306 precedent -- GDScript typed
        # String params cannot take null).
        self.assertIn('static func source_sound_control_play_state(has_music: bool, music: String, has_current: bool, current: String, fade: float, silenced: bool, should_play: bool, music_vol: int, time_delta: float, fin_time: float, fout_time: float) -> Dictionary:', state)
        self.assertIn('static func source_sound_control_silence_state(has_current: bool, current: String, fade: float, silenced: bool, should_play: bool, music_vol: int, time_delta: float, fin_time: float, fout_time: float) -> Dictionary:', state)
        self.assertIn('static func source_sound_control_keep_silent_state(keep_silent: bool) -> Dictionary:', state)
        self.assertIn('source_sound_control_play_state(false, "", has_current, current, fade, silenced, should_play, music_vol, time_delta, fin_time, fout_time)', state)
        self.assertIn('return {"keep_silent": true}', state)
        self.assertIn('clampf(out_fade + time_delta / fin_time, 0.0, 1.0)', state)
        self.assertIn('clampf(out_fade - time_delta / fout_time, 0.0, 1.0)', state)
        self.assertIn('if out_fade <= 0.01:', state)
        for expr in [
            'protected void play(@Nullable Music music){',
            'if(!shouldPlay()){',
            'current.setVolume(0);',
            'fade = 0f;',
            'current.setVolume(fade * Core.settings.getInt("musicvol") / 100f);',
            'if(silenced){',
            'if(current == null && music != null){',
            'current = music;',
            'current.setLooping(true);',
            'current.setVolume(fade = 0f);',
            'current.play();',
            'silenced = false;',
            '}else if(current == music && music != null){',
            'fade = Mathf.clamp(fade + Time.delta /finTime);',
            '}else if(current != null){',
            'fade = Mathf.clamp(fade - Time.delta /foutTime);',
            'if(fade <= 0.01f){',
            'current.stop();',
            'current = null;',
            'silenced = true;',
            'if(music != null){',
            'protected void silence(){',
            'play(null);',
            'public void keepSilent(){',
            'keepSilent = true;',
            'protected @Nullable Music current;',
            'protected float fade;',
            'protected boolean silenced, keepSilent;',
            'public float finTime = 120f, foutTime = 120f, musicInterval = 3f * Time.toMinutes, musicChance = 0.8f, musicWaveChance = 0.46f;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        # NO audio playback in this slice (0 AudioStreamPlayer
        # in the port): play() only returns playback-command
        # state; playback belongs to updateLoops (N2304,
        # held waiting for B).
        self.assertNotIn('AudioStreamPlayer', state)
        # NO real RNG in the ported functions: the fade
        # machine is pure arithmetic on explicit params.
        self.assertNotIn('randf()', state)
        self.assertNotIn('randi()', state)
        # The proof's keys drive the pure functions directly
        # with explicit params: the muted gate, new-track
        # start, fade in / out, the fade-out stop + restart,
        # the silenced early return, the no-track no-op,
        # silence() as play(null), and keepSilent() setting
        # the flag.
        proof = SOUND_CONTROL_PLAY_SILENCE_PROOF.read_text(encoding='utf-8')
        for key in [
            'play_muted_no_should_play',
            'play_muted_no_current',
            'play_starts_new_track',
            'play_fades_in_same_track',
            'play_fade_in_clamps_at_one',
            'play_fades_out_other_track',
            'play_fade_out_stops_and_starts_new',
            'play_fade_out_stops_no_new_track',
            'play_silenced_returns_after_volume',
            'play_no_current_no_music_keeps_state',
            'silence_fades_out_current',
            'silence_stops_at_zero',
            'silence_no_current_keeps_state',
            'keep_silent_sets_flag',
            'keep_silent_overwrites_true',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_sound_control_play_silence(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07SoundControlPlaySilenceProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SOUND_CONTROL_PLAY_SILENCE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'play_muted_no_should_play',
            'play_muted_no_current',
            'play_starts_new_track',
            'play_fades_in_same_track',
            'play_fade_in_clamps_at_one',
            'play_fades_out_other_track',
            'play_fade_out_stops_and_starts_new',
            'play_fade_out_stops_no_new_track',
            'play_silenced_returns_after_volume',
            'play_no_current_no_music_keeps_state',
            'silence_fades_out_current',
            'silence_stops_at_zero',
            'silence_no_current_keeps_state',
            'keep_silent_sets_flag',
            'keep_silent_overwrites_true',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
