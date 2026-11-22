import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SOUND_CONTROL_STATE = ROOT / 'godot-mindustry/src/game/SourceSoundControlState.gd'
SOUND_CONTROL_UPDATE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SoundControlUpdateProof.gd'

UPDATE_SIGNATURE = 'static func source_sound_control_update_state(is_game: bool, has_dialog: bool, has_current: bool, current: String, current_is_playing: bool, timer_tick: bool, was_playing: bool, filter: Variant, is_paused: bool, keep_silent: bool, silenced: bool, is_menu: bool, planet_shown: bool, has_planet_launch_music: bool, planet_launch_music: String, editor_shown: bool, rules_editor: bool, always_play_music: bool, last_played: int, now_millis: int, music_interval: float, chance_roll: bool, fade: float, should_play: bool, music_vol: int, time_delta: float, fin_time: float, fout_time: float, has_last_random_played: bool, last_random_played: String, play_random: Callable, update_loops: Callable) -> Dictionary:'

# The 30 registered lines of SoundControl.update()
# (SoundControl.java:128-195) -- 28 unique strings; the
# sound-bus play line repeats (:148 + :156) and the editor
# music line repeats (:170 + :176).
EXACT_EXPRS = [
    'boolean paused = state.isGame() && Core.scene.hasDialog();',
    'boolean playing = state.isGame();',
    'if(current != null && !current.isPlaying()){',
    'if(timer.get(1, 30f)){',
    'Core.audio.soundBus.fadeFilterParam(0, Filters.paramWet, paused ? 1f : 0f, 0.4f);',
    'if(playing != wasPlaying){',
    'wasPlaying = playing;',
    'if(playing){',
    'Core.audio.soundBus.play();',
    'setupFilters();',
    'Core.audio.soundBus.stop();',
    'Core.audio.musicBus.play();',
    'Core.audio.soundBus.play();',
    'Core.audio.setPaused(Core.audio.soundBus.id, state.isPaused());',
    'if(keepSilent){',
    'keepSilent = false;',
    'stop();',
    '}else if(state.isMenu()){',
    'if(ui.planet.isShown()){',
    'play(ui.planet.state.planet.launchMusic);',
    '}else if(ui.editor.isShown()){',
    'play(Musics.editor);',
    'play(Musics.menu);',
    '}else if(state.rules.editor){',
    'play(Musics.editor);',
    'silence();',
    '}else if(Time.timeSinceMillis(lastPlayed) > 1000 * musicInterval / 60f){',
    'if(Mathf.chance(musicChance)){',
    'lastPlayed = Time.millis();',
    'updateLoops();',
]

PROOF_KEYS = [
    'update_paused_when_dialog',
    'update_playing_when_game',
    'update_clears_finished_track',
    'update_fade_filter_poll',
    'update_bus_plays_on_start',
    'update_bus_stops_on_pause',
    'update_set_paused_command',
    'update_keep_silent_stops',
    'update_menu_plays_planet_music',
    'update_menu_plays_editor_music',
    'update_menu_plays_menu_music',
    'update_editor_plays_editor_music',
    'update_ingame_silence_then_random',
    'update_interval_random_updates_last_played',
    'update_interval_skipped_when_recent',
    'update_calls_update_loops',
    'update_returns_only_eleven_keys',
]


class C07SoundControlUpdateTests(unittest.TestCase):
    def test_c07_sound_control_update_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        # SoundControl.update() (SoundControl.java:128-195)
        # is the per-frame dispatcher: finished-track
        # check, fade-filter poll, bus play/stop on the
        # playing transition, setPaused, the keepSilent /
        # menu / editor / ingame legs, and the
        # updateLoops() call last. All state reads arrive
        # as explicit params; the delegates it calls --
        # setupFilters (N2349), stop (N2352), play /
        # silence (N2336) -- are pure static funcs in the
        # same file and are called directly; playRandom
        # (N2347) and updateLoops (N2304, held waiting
        # for B) arrive as Callables because the caller
        # owns the music lists / RNG draw / live mixer.
        # NO audio playback in this slice (0
        # AudioStreamPlayer in the port): bus and
        # playback calls are returned as command state,
        # never executed; playback belongs to updateLoops
        # (N2304, held waiting for B).
        self.assertEqual(ledger['N2411']['godot_owner'], 'SourceSoundControlState.source_sound_control_update_state')
        self.assertEqual(
            ledger['N2411']['source_symbols'],
            [
                'source_sound_control_update_state_result.paused',
                'source_sound_control_update_state_result.playing',
                'source_sound_control_update_state_result.was_playing',
                'source_sound_control_update_state_result.current',
                'source_sound_control_update_state_result.fade',
                'source_sound_control_update_state_result.silenced',
                'source_sound_control_update_state_result.keep_silent',
                'source_sound_control_update_state_result.last_played',
                'source_sound_control_update_state_result.last_random_played',
                'source_sound_control_update_state_result.commands',
                'source_sound_control_update_state_result.update_loops_called',
            ],
        )
        for name in ledger['N2411']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/audio/SoundControl.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceSoundControlState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2411']['runtime_proof'], '/root/C07SoundControlUpdateProof')
        self.assertEqual(
            ledger['N2411']['tests'],
            [
                'test_c07_sound_control_update_registration',
                'test_all_c07_sound_control_update_input_evidence_is_exact',
                'test_sound_control_update_state',
                'test_reference_graph_and_actual_c07_sound_control_update',
            ],
        )
        self.assertTrue(ledger['N2411']['deferred_exprs'])

    def test_all_c07_sound_control_update_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2411']['source_symbols']:
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
        for expr in ledger['N2411']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_sound_control_update_state(self):
        state = SOUND_CONTROL_STATE.read_text(encoding='utf-8')
        # SoundControl.update() (SoundControl.java:128-195):
        # the dispatcher keeps Java order exactly --
        # paused/playing from state.isGame(), the
        # finished-track clear, the 30-tick fade-filter
        # poll, the bus play/stop on the playing
        # transition, setPaused, then exactly one leg:
        # keepSilent (stop), menu (planet / editor /
        # menu music), editor rules, or ingame (silence
        # + alwaysPlayMusic / interval chance +
        # playRandom), and updateLoops() last. The
        # already-owned lines (current = null; / fade =
        # 0f; / silenced = false; / the alwaysPlayMusic
        # leg N2306) are NOT re-registered -- update()
        # only drives them through the delegates and
        # explicit params. Musics.editor / Musics.menu
        # arrive as their asset-stem names "editor" /
        # "menu" (the N2287 precedent). NO audio
        # playback in this slice: bus and playback calls
        # are returned as command state, never executed;
        # playback belongs to updateLoops (N2304, held
        # waiting for B).
        self.assertIn(UPDATE_SIGNATURE, state)
        for expr in EXACT_EXPRS:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        # The delegates are called, not re-ported:
        # setupFilters (N2349), stop (N2352), play /
        # silence (N2336) are direct static calls in the
        # same file; playRandom (N2347) and updateLoops
        # (N2304) arrive as Callables and are .call()ed.
        self.assertIn('source_sound_control_setup_filters_state(filter)', state)
        self.assertIn('source_sound_control_stop_state(', state)
        self.assertIn('source_sound_control_play_state(', state)
        self.assertIn('source_sound_control_silence_state(', state)
        self.assertIn('play_random.call(', state)
        self.assertIn('update_loops.call()', state)
        self.assertNotIn('AudioStreamPlayer', state)
        # NO real RNG in the ported function: the chance
        # roll arrives as an explicit bool param (the
        # N2315 chance-roll precedent).
        self.assertNotIn('randf()', state)
        self.assertNotIn('randi()', state)
        # The proof's keys drive the pure function
        # directly with explicit params: the paused /
        # playing derivation, the finished-track clear,
        # the fade-filter poll, both bus transitions,
        # setPaused, keepSilent stop, the three menu
        # music selections, the editor leg, the ingame
        # silence + random legs (always / interval /
        # skipped), the updateLoops call, and the
        # eleven-key result shape.
        proof = SOUND_CONTROL_UPDATE_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_sound_control_update(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07SoundControlUpdateProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SOUND_CONTROL_UPDATE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
