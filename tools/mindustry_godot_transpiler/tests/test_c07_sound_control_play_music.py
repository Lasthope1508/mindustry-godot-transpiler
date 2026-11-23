import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SOUND_CONTROL_STATE = ROOT / 'godot-mindustry/src/game/SourceSoundControlState.gd'
SOUND_CONTROL_PLAY_MUSIC_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SoundControlPlayMusicProof.gd'


class C07SoundControlPlayMusicTests(unittest.TestCase):
    def test_c07_sound_control_play_music_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        # SoundControl.playMusic(Music, boolean) (SoundControl.java:243-249)
        # stops the current track when interrupt is set, then
        # delegates to playOnce. SoundControl.playOnce(Music)
        # (SoundControl.java:355-367) starts a track once and
        # only once: it does nothing when a track is already
        # playing, when the music is null, or when shouldPlay()
        # (N2299) is false; otherwise it saves the track as
        # lastRandomPlayed, sets fade to 1, and issues the
        # setVolume / setLooping / play commands. Music
        # arrives as its name String (the N2287 precedent);
        # null music / current arrive as explicit bool params
        # (the N2306 precedent). NO audio playback in this
        # slice (0 AudioStreamPlayer in the port): the
        # stop / setVolume / setLooping / play calls are
        # returned as playback-command state, never executed;
        # playback belongs to updateLoops (N2304, held
        # waiting for B).
        self.assertEqual(ledger['N2345']['godot_owner'], 'SourceSoundControlState.source_sound_control_play_music_state')
        self.assertEqual(
            ledger['N2345']['source_symbols'],
            [
                'source_sound_control_play_music_state_result.current',
                'source_sound_control_play_music_state_result.fade',
                'source_sound_control_play_music_state_result.last_random_played',
                'source_sound_control_play_music_state_result.commands',
                'source_sound_control_play_once_state_result.current',
                'source_sound_control_play_once_state_result.fade',
                'source_sound_control_play_once_state_result.last_random_played',
                'source_sound_control_play_once_state_result.commands',
            ],
        )
        for name in ledger['N2345']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/audio/SoundControl.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceSoundControlState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2345']['runtime_proof'], '/root/C07SoundControlPlayMusicProof')
        self.assertEqual(
            ledger['N2345']['tests'],
            [
                'test_c07_sound_control_play_music_registration',
                'test_all_c07_sound_control_play_music_input_evidence_is_exact',
                'test_sound_control_play_music_state',
                'test_reference_graph_and_actual_c07_sound_control_play_music',
            ],
        )
        self.assertTrue(ledger['N2345']['deferred_exprs'])

    def test_all_c07_sound_control_play_music_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2345']['source_symbols']:
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
        for expr in ledger['N2345']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_sound_control_play_music_state(self):
        state = SOUND_CONTROL_STATE.read_text(encoding='utf-8')
        # SoundControl.playMusic(Music, boolean) (SoundControl.java:243-249):
        # interrupt + a current track stops it and clears
        # current, then playOnce(music) runs. playOnce
        # (:355-367): the guard `current != null || music ==
        # null || !shouldPlay()` returns with state
        # unchanged; otherwise lastRandomPlayed = music,
        # fade = 1f, current = music, and the track is
        # started with setVolume(1f), setLooping(false),
        # play() -- in exactly that order. shouldPlay()
        # (N2299) arrives as the explicit should_play bool
        # param and is NOT re-ported here. Music arrives as
        # its name String (the N2287 precedent); null music /
        # current arrive as explicit bool params (the N2306
        # precedent -- GDScript typed String params cannot
        # take null).
        self.assertIn('static func source_sound_control_play_music_state(has_music: bool, music: String, interrupt: bool, has_current: bool, current: String, fade: float, has_last_random_played: bool, last_random_played: String, should_play: bool) -> Dictionary:', state)
        self.assertIn('static func source_sound_control_play_once_state(has_music: bool, music: String, has_current: bool, current: String, fade: float, has_last_random_played: bool, last_random_played: String, should_play: bool) -> Dictionary:', state)
        self.assertIn('source_sound_control_play_once_state(has_music, music, out_current != null, out_current if out_current != null else "", fade, has_last_random_played, last_random_played, should_play)', state)
        self.assertIn('if interrupt and has_current:', state)
        self.assertIn('commands.append({"track": current, "action": "stop"})', state)
        self.assertIn('if has_current or not has_music or not should_play:', state)
        self.assertIn('out_last = music', state)
        self.assertIn('out_fade = 1.0', state)
        self.assertIn('out_current = music', state)
        self.assertIn('commands.append({"track": music, "action": "set_volume", "value": 1.0})', state)
        self.assertIn('commands.append({"track": music, "action": "set_looping", "value": false})', state)
        self.assertIn('commands.append({"track": music, "action": "play"})', state)
        self.assertIn('return {"current": out_current, "fade": out_fade, "last_random_played": out_last, "commands": commands}', state)
        for expr in [
            'public void playMusic(@Nullable Music music, boolean interrupt){',
            'if(interrupt && current != null){',
            'current.stop();',
            'current = null;',
            'playOnce(music);',
            'protected void playOnce(Music music){',
            'if(current != null || music == null || !shouldPlay()) return; //do not interrupt already-playing tracks',
            'lastRandomPlayed = music;',
            'fade = 1f;',
            'current = music;',
            'current.setVolume(1f);',
            'current.setLooping(false);',
            'current.play();',
            'protected @Nullable Music current;',
            'protected float fade;',
            'protected Music lastRandomPlayed;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        # NO audio playback in this slice (0 AudioStreamPlayer
        # in the port): playMusic / playOnce only return
        # playback-command state; playback belongs to
        # updateLoops (N2304, held waiting for B).
        self.assertNotIn('AudioStreamPlayer', state)
        # NO real RNG in the ported functions: the start-once
        # decision is pure arithmetic on explicit params.
        self.assertNotIn('randf()', state)
        self.assertNotIn('randi()', state)
        # The proof's keys drive the pure functions directly
        # with explicit params: playOnce starting a track,
        # the three guard legs, the lastRandomPlayed
        # passthrough, and playMusic interrupting, blocking,
        # stopping-only, and delegating.
        proof = SOUND_CONTROL_PLAY_MUSIC_PROOF.read_text(encoding='utf-8')
        for key in [
            'play_once_starts_new_track',
            'play_once_blocked_by_current',
            'play_once_blocked_by_null_music',
            'play_once_blocked_when_muted',
            'play_once_keeps_last_when_blocked',
            'play_music_interrupt_stops_and_starts',
            'play_music_no_interrupt_blocked_by_current',
            'play_music_interrupt_no_current_starts',
            'play_music_interrupt_null_music_stops_only',
            'play_music_interrupt_no_current_null_music_noop',
            'play_music_muted_blocks_start',
            'play_music_interrupt_keeps_last_when_no_music',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_sound_control_play_music(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07SoundControlPlayMusicProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SOUND_CONTROL_PLAY_MUSIC_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'play_once_starts_new_track',
            'play_once_blocked_by_current',
            'play_once_blocked_by_null_music',
            'play_once_blocked_when_muted',
            'play_once_keeps_last_when_blocked',
            'play_music_interrupt_stops_and_starts',
            'play_music_no_interrupt_blocked_by_current',
            'play_music_interrupt_no_current_starts',
            'play_music_interrupt_null_music_stops_only',
            'play_music_interrupt_no_current_null_music_noop',
            'play_music_muted_blocks_start',
            'play_music_interrupt_keeps_last_when_no_music',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
