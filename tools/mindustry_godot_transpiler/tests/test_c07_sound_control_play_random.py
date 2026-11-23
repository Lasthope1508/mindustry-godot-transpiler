import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SOUND_CONTROL_STATE = ROOT / 'godot-mindustry/src/game/SourceSoundControlState.gd'
SOUND_CONTROL_PLAY_RANDOM_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SoundControlPlayRandomProof.gd'


class C07SoundControlPlayRandomTests(unittest.TestCase):
    def test_c07_sound_control_play_random_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        # SoundControl.playRandom() (SoundControl.java:256-264)
        # picks a random track from the boss list when a boss
        # is present, else from the dark list when isDark(),
        # else from the ambient list, and starts it with
        # playOnce. The three music lists come from the N2326
        # getters (getBossMusic / getDarkMusic /
        # getAmbientMusic) and isDark() is N2315 -- none of
        # them is re-ported here; their results arrive as
        # explicit params. The random draw itself
        # (Seq.random(lastRandomPlayed), arc Seq.java:1007)
        # is RNG: its OUTCOME arrives as the explicit
        # picked_track param (the N2315 chance-roll
        # precedent), so this function is pure and never
        # rolls RNG itself. Music arrives as its name
        # String (the N2287 precedent); null music /
        # current arrive as explicit bool params (the N2306
        # precedent). NO audio playback in this slice
        # (0 AudioStreamPlayer in the port): the
        # setVolume / setLooping / play calls are returned
        # as playback-command state, never executed;
        # playback belongs to updateLoops (N2304, held
        # waiting for B).
        self.assertEqual(ledger['N2347']['godot_owner'], 'SourceSoundControlState.source_sound_control_play_random_state')
        self.assertEqual(
            ledger['N2347']['source_symbols'],
            [
                'source_sound_control_play_random_state_result.current',
                'source_sound_control_play_random_state_result.fade',
                'source_sound_control_play_random_state_result.last_random_played',
                'source_sound_control_play_random_state_result.commands',
                'source_sound_control_play_random_state_result.selected_music',
            ],
        )
        for name in ledger['N2347']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/audio/SoundControl.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceSoundControlState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2347']['runtime_proof'], '/root/C07SoundControlPlayRandomProof')
        self.assertEqual(
            ledger['N2347']['tests'],
            [
                'test_c07_sound_control_play_random_registration',
                'test_all_c07_sound_control_play_random_input_evidence_is_exact',
                'test_sound_control_play_random_state',
                'test_reference_graph_and_actual_c07_sound_control_play_random',
            ],
        )
        self.assertTrue(ledger['N2347']['deferred_exprs'])

    def test_all_c07_sound_control_play_random_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2347']['source_symbols']:
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
        for expr in ledger['N2347']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_sound_control_play_random_state(self):
        state = SOUND_CONTROL_STATE.read_text(encoding='utf-8')
        # SoundControl.playRandom() (SoundControl.java:256-264):
        # `/** Plays a random track.*/` / `public void playRandom(){`
        # / `if(state.boss() != null){` +
        # `playOnce(getBossMusic().random(lastRandomPlayed));`
        # / `}else if(isDark()){` +
        # `playOnce(getDarkMusic().random(lastRandomPlayed));`
        # / `}else{` +
        # `playOnce(getAmbientMusic().random(lastRandomPlayed));`
        # -- the branch order is kept exactly: boss first,
        # then dark, then ambient. The branch selects the
        # list; the random pick from that list is the
        # caller's draw, folded into the has_picked_track /
        # picked_track params; playOnce starts the picked
        # track (N2345) or blocks with state unchanged.
        # state.boss() (GameState.java:56-58, `return
        # teams.bosses.firstOpt();`) is NOT ported here --
        # only its null test arrives as has_boss.
        # isDark() (N2315) and the three getters (N2326)
        # are NOT re-ported here.
        self.assertIn('static func source_sound_control_play_random_state(has_boss: bool, is_dark: bool, boss_music: Array, dark_music: Array, ambient_music: Array, has_picked_track: bool, picked_track: String, has_current: bool, current: String, fade: float, has_last_random_played: bool, last_random_played: String, should_play: bool) -> Dictionary:', state)
        self.assertIn('source_sound_control_play_once_state(has_picked_track, picked_track, has_current, current, fade, has_last_random_played, last_random_played, should_play)', state)
        self.assertIn('if has_boss:', state)
        self.assertIn('elif is_dark:', state)
        self.assertIn('once["selected_music"] = selected_music', state)
        for expr in [
            '/** Plays a random track.*/',
            'public void playRandom(){',
            'if(state.boss() != null){',
            'playOnce(getBossMusic().random(lastRandomPlayed));',
            '}else if(isDark()){',
            'playOnce(getDarkMusic().random(lastRandomPlayed));',
            '}else{',
            'playOnce(getAmbientMusic().random(lastRandomPlayed));',
            'protected @Nullable Music current;',
            'protected float fade;',
            'protected Music lastRandomPlayed;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        # NO audio playback in this slice (0 AudioStreamPlayer
        # in the port): playRandom only selects a list and
        # returns playback-command state; playback belongs
        # to updateLoops (N2304, held waiting for B).
        self.assertNotIn('AudioStreamPlayer', state)
        # NO real RNG in the ported function: the random pick
        # arrives as an explicit param (the N2315 precedent).
        self.assertNotIn('randf()', state)
        self.assertNotIn('randi()', state)
        # The proof's keys drive the pure function directly
        # with explicit params: the three branch selections,
        # boss winning over dark, the playOnce guard legs
        # (blocked by current / null pick / muted), the
        # lastRandomPlayed passthrough, and the empty-list
        # no-pick.
        proof = SOUND_CONTROL_PLAY_RANDOM_PROOF.read_text(encoding='utf-8')
        for key in [
            'boss_branch_selects_boss_list_and_starts',
            'dark_branch_selects_dark_list_and_starts',
            'ambient_branch_selects_ambient_list_and_starts',
            'boss_branch_wins_over_dark',
            'random_blocked_by_current',
            'random_blocked_by_null_pick',
            'random_blocked_when_muted',
            'random_keeps_last_when_blocked',
            'random_empty_list_no_pick',
            'random_pick_excludes_last',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_sound_control_play_random(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07SoundControlPlayRandomProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SOUND_CONTROL_PLAY_RANDOM_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'boss_branch_selects_boss_list_and_starts',
            'dark_branch_selects_dark_list_and_starts',
            'ambient_branch_selects_ambient_list_and_starts',
            'boss_branch_wins_over_dark',
            'random_blocked_by_current',
            'random_blocked_by_null_pick',
            'random_blocked_when_muted',
            'random_keeps_last_when_blocked',
            'random_empty_list_no_pick',
            'random_pick_excludes_last',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
