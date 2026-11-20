import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SOUND_CONTROL_STATE = ROOT / 'godot-mindustry/src/game/SourceSoundControlState.gd'
SOUND_CONTROL_GET_MUSIC_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SoundControlGetMusicProof.gd'


class C07SoundControlGetMusicTests(unittest.TestCase):
    def test_c07_sound_control_get_music_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        # The ledger carries the first getter (boss) as its
        # godot_owner; all three getters share the one N2326
        # entry and java_method lists all three.
        self.assertEqual(ledger['N2326']['godot_owner'], 'SourceSoundControlState.source_sound_control_get_boss_music_state')
        # SoundControl.getBossMusic() / getAmbientMusic() /
        # getDarkMusic() (SoundControl.java:270-284) are the
        # three music-list getters playRandom() reads
        # (SoundControl.java:258-262): each is one pure
        # function on SourceSoundControlState.gd next to the
        # N2299 shouldPlay / isPlaying, N2306 alwaysPlayMusic
        # and N2315 isDark gates. QUIRK, ported verbatim:
        # boss and dark read the SAME state.rules.darkMusic
        # / planet darkMusic in the rules / planet branch
        # (boss has no field of its own there); only the
        # fallback differs -- bossMusic for boss, darkMusic
        # for dark. The shared rules line is byte-identical
        # for boss (:271) and dark (:281). Three new result
        # symbols: boss_music, ambient_music, dark_music. NO
        # audio playback in this slice (0 AudioStreamPlayer
        # in the port).
        self.assertEqual(
            ledger['N2326']['source_symbols'],
            [
                'source_sound_control_get_boss_music_state_result.boss_music',
                'source_sound_control_get_ambient_music_state_result.ambient_music',
                'source_sound_control_get_dark_music_state_result.dark_music',
            ],
        )
        for name in ledger['N2326']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/audio/SoundControl.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceSoundControlState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2326']['runtime_proof'], '/root/C07SoundControlGetMusicProof')
        self.assertEqual(
            ledger['N2326']['tests'],
            [
                'test_c07_sound_control_get_music_registration',
                'test_all_c07_sound_control_get_music_input_evidence_is_exact',
                'test_sound_control_get_music_state',
                'test_reference_graph_and_actual_c07_sound_control_get_music',
            ],
        )
        self.assertTrue(ledger['N2326']['deferred_exprs'])

    def test_all_c07_sound_control_get_music_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2326']['source_symbols']:
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
        for expr in ledger['N2326']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_sound_control_get_music_state(self):
        state = SOUND_CONTROL_STATE.read_text(encoding='utf-8')
        # SoundControl.getBossMusic() / getAmbientMusic() /
        # getDarkMusic() (SoundControl.java:270-284): rules
        # branch (resolved names, nulls removed) else planet
        # branch else the field fallback; boss and dark share
        # the rules / planet darkMusic read, only the fallback
        # differs. Music arrives as its name String; the
        # MusicContainer::get resolution is folded into the
        # caller param, the removeAll null filter is ported.
        self.assertIn('static func source_sound_control_get_boss_music_state(has_rules_dark_music: bool, rules_dark_music: Array, has_planet_dark_music: bool, planet_dark_music: Array, boss_music: Array) -> Dictionary:', state)
        self.assertIn('static func source_sound_control_get_ambient_music_state(has_rules_ambient_music: bool, rules_ambient_music: Array, has_planet_ambient_music: bool, planet_ambient_music: Array, ambient_music: Array) -> Dictionary:', state)
        self.assertIn('static func source_sound_control_get_dark_music_state(has_rules_dark_music: bool, rules_dark_music: Array, has_planet_dark_music: bool, planet_dark_music: Array, dark_music: Array) -> Dictionary:', state)
        self.assertIn('if has_rules_dark_music:', state)
        self.assertIn('if has_planet_dark_music:', state)
        self.assertIn('if has_rules_ambient_music:', state)
        self.assertIn('if has_planet_ambient_music:', state)
        self.assertIn('return {"boss_music": boss_music}', state)
        self.assertIn('return {"ambient_music": ambient_music}', state)
        self.assertIn('return {"dark_music": dark_music}', state)
        for expr in [
            'protected Seq<Music> getBossMusic(){',
            'if(state.rules.darkMusic != null) return state.rules.darkMusic.map(MusicContainer::get).removeAll(m -> m == null);',
            'return state.getPlanet() != null && state.getPlanet().darkMusic != null ? state.getPlanet().darkMusic : bossMusic;',
            'protected Seq<Music> getAmbientMusic(){',
            'if(state.rules.ambientMusic != null) return state.rules.ambientMusic.map(MusicContainer::get).removeAll(m -> m == null);',
            'return state.getPlanet() != null && state.getPlanet().ambientMusic != null ? state.getPlanet().ambientMusic : ambientMusic;',
            'protected Seq<Music> getDarkMusic(){',
            'return state.getPlanet() != null && state.getPlanet().darkMusic != null ? state.getPlanet().darkMusic : darkMusic;',
            'playOnce(getBossMusic().random(lastRandomPlayed));',
            'playOnce(getDarkMusic().random(lastRandomPlayed));',
            'playOnce(getAmbientMusic().random(lastRandomPlayed));',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        # NO audio playback in this slice (0 AudioStreamPlayer
        # in the port): these are pure getters; playback belongs
        # to updateLoops (N2304, held waiting for B).
        self.assertNotIn('AudioStreamPlayer', state)
        # NO real RNG in the ported functions: the getters only
        # select a list; playRandom() picks the track.
        self.assertNotIn('randf()', state)
        self.assertNotIn('randi()', state)
        # The proof's keys drive the pure functions directly
        # with explicit params: rules / planet / fallback for
        # each getter, plus the shared-rules quirk keys.
        proof = SOUND_CONTROL_GET_MUSIC_PROOF.read_text(encoding='utf-8')
        for key in [
            'boss_music_rules',
            'boss_music_rules_all_null',
            'boss_music_planet',
            'boss_music_fallback',
            'ambient_music_rules',
            'ambient_music_planet',
            'ambient_music_fallback',
            'dark_music_rules',
            'dark_music_planet',
            'dark_music_fallback',
            'boss_dark_share_rules',
            'boss_dark_differ_fallback',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_sound_control_get_music(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07SoundControlGetMusicProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SOUND_CONTROL_GET_MUSIC_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'boss_music_rules',
            'boss_music_rules_all_null',
            'boss_music_planet',
            'boss_music_fallback',
            'ambient_music_rules',
            'ambient_music_planet',
            'ambient_music_fallback',
            'dark_music_rules',
            'dark_music_planet',
            'dark_music_fallback',
            'boss_dark_share_rules',
            'boss_dark_differ_fallback',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
