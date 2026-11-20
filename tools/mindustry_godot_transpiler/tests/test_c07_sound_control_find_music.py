import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SOUND_CONTROL_STATE = ROOT / 'godot-mindustry/src/game/SourceSoundControlState.gd'
SOUND_CONTROL_FIND_MUSIC_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SoundControlFindMusicProof.gd'


class C07SoundControlFindMusicTests(unittest.TestCase):
    def test_c07_sound_control_find_music_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        # SoundControl.findMusic(String)
        # (SoundControl.java:387-395) is the static music
        # lookup MusicContainer.get() reads
        # (MusicContainer.java:18-24, lazy
        # `SoundControl.findMusic(name)`, null when the asset
        # is not found): a null name reads null, else the
        # first of the five Core.assets.getOrNull branches
        # that hits -- name, name + ".ogg", name + ".mp3",
        # "music/" + name + ".ogg", "music/" + name +
        # ".mp3" -- in exactly that order, else null. One
        # pure static function on SourceSoundControlState.gd
        # next to the N2299 shouldPlay / isPlaying, N2306
        # alwaysPlayMusic, N2315 isDark and N2326 music
        # getters. NO audio playback in this slice (0
        # AudioStreamPlayer in the port): findMusic only
        # resolves a name, playback belongs to updateLoops
        # (N2304, held waiting for B).
        self.assertEqual(ledger['N2331']['godot_owner'], 'SourceSoundControlState.source_sound_control_find_music_state')
        self.assertEqual(
            ledger['N2331']['source_symbols'],
            [
                'source_sound_control_find_music_state_result.found_music',
            ],
        )
        for name in ledger['N2331']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/audio/SoundControl.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceSoundControlState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2331']['runtime_proof'], '/root/C07SoundControlFindMusicProof')
        self.assertEqual(
            ledger['N2331']['tests'],
            [
                'test_c07_sound_control_find_music_registration',
                'test_all_c07_sound_control_find_music_input_evidence_is_exact',
                'test_sound_control_find_music_state',
                'test_reference_graph_and_actual_c07_sound_control_find_music',
            ],
        )
        self.assertTrue(ledger['N2331']['deferred_exprs'])

    def test_all_c07_sound_control_find_music_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2331']['source_symbols']:
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
        for expr in ledger['N2331']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_sound_control_find_music_state(self):
        state = SOUND_CONTROL_STATE.read_text(encoding='utf-8')
        # SoundControl.findMusic(String)
        # (SoundControl.java:387-395): null name reads null,
        # else the first of five Core.assets.getOrNull
        # branches that hits, in exactly this order --
        # name, name + ".ogg", name + ".mp3", "music/" +
        # name + ".ogg", "music/" + name + ".mp3" -- else
        # null. The Core.assets lookup arrives as an
        # explicit Dictionary param (the asset registry:
        # lookup key -> resolved asset name, a missing key
        # reads null, exactly Core.assets.getOrNull): NO
        # audio is loaded in this slice. Music arrives as
        # its resolved name String (the N2287 precedent);
        # the null name arrives as an explicit bool param
        # (the N2306 precedent -- GDScript typed String
        # params cannot take null).
        self.assertIn('static func source_sound_control_find_music_state(has_name: bool, name: String, assets: Dictionary) -> Dictionary:', state)
        self.assertIn('if not has_name:', state)
        self.assertIn('assets.get(name, null)', state)
        self.assertIn('assets.get(name + ".ogg", null)', state)
        self.assertIn('assets.get(name + ".mp3", null)', state)
        self.assertIn('assets.get("music/" + name + ".ogg", null)', state)
        self.assertIn('assets.get("music/" + name + ".mp3", null)', state)
        self.assertIn('return {"found_music": found}', state)
        for expr in [
            'public static @Nullable Music findMusic(String name){',
            'if(name == null) return null;',
            'Music cached = Core.assets.getOrNull(name, Music.class);',
            'if(cached == null) cached = Core.assets.getOrNull(name + ".ogg", Music.class);',
            'if(cached == null) cached = Core.assets.getOrNull(name + ".mp3", Music.class);',
            'if(cached == null) cached = Core.assets.getOrNull("music/" + name + ".ogg", Music.class);',
            'if(cached == null) cached = Core.assets.getOrNull("music/" + name + ".mp3", Music.class);',
            'return cached;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        # NO audio playback in this slice (0 AudioStreamPlayer
        # in the port): this only resolves a name; playback
        # belongs to updateLoops (N2304, held waiting for B).
        self.assertNotIn('AudioStreamPlayer', state)
        # NO real RNG in the ported function: findMusic only
        # walks five registry lookups in order.
        self.assertNotIn('randf()', state)
        self.assertNotIn('randi()', state)
        # The proof's keys drive the pure function directly
        # with explicit params: the null name, one hit per
        # branch, not found, the order pins (.ogg before
        # .mp3, plain before music/, exact first), and the
        # resolved-name return.
        proof = SOUND_CONTROL_FIND_MUSIC_PROOF.read_text(encoding='utf-8')
        for key in [
            'find_music_null_name',
            'find_music_exact',
            'find_music_ogg',
            'find_music_mp3',
            'find_music_music_ogg',
            'find_music_music_mp3',
            'find_music_not_found',
            'find_music_ogg_before_mp3',
            'find_music_plain_before_music_dir',
            'find_music_exact_first',
            'find_music_music_ogg_before_mp3',
            'find_music_plain_ogg_before_music_ogg',
            'find_music_returns_resolved_name',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_sound_control_find_music(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07SoundControlFindMusicProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SOUND_CONTROL_FIND_MUSIC_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'find_music_null_name',
            'find_music_exact',
            'find_music_ogg',
            'find_music_mp3',
            'find_music_music_ogg',
            'find_music_music_mp3',
            'find_music_not_found',
            'find_music_ogg_before_mp3',
            'find_music_plain_before_music_dir',
            'find_music_exact_first',
            'find_music_music_ogg_before_mp3',
            'find_music_plain_ogg_before_music_ogg',
            'find_music_returns_resolved_name',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
