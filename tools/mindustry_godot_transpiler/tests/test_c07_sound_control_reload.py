import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SOUND_CONTROL_STATE = ROOT / 'godot-mindustry/src/game/SourceSoundControlState.gd'
SOUND_CONTROL_RELOAD_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SoundControlReloadProof.gd'


class C07SoundControlReloadTests(unittest.TestCase):
    def test_c07_sound_control_reload_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        # SoundControl.reload() (SoundControl.java:75-91)
        # resets current / fade, rebuilds the three music
        # lists from the Musics fields, assigns the uiBus to
        # every Sound asset whose file sits in the "ui"
        # folder, and fires a MusicRegisterEvent. current /
        # fade arrive as explicit params and are carried out
        # reset (null / 0), the same in/out shape as the
        # play state machine (N2336); the asset enumeration
        # (Core.assets.getAll) and the file-name resolution
        # (Fi.get(getAssetFileName)) arrive folded into one
        # explicit Dictionary param (sound name -> parent
        # folder name) and the `equals("ui")` check IS
        # ported; Events.fire is evidence only, the event
        # system is NOT ported; NO audio playback in this
        # slice (0 AudioStreamPlayer in the port).
        self.assertEqual(ledger['N2339']['godot_owner'], 'SourceSoundControlState.source_sound_control_reload_state')
        self.assertEqual(
            ledger['N2339']['source_symbols'],
            [
                'source_sound_control_reload_state_result.current',
                'source_sound_control_reload_state_result.fade',
                'source_sound_control_reload_state_result.ambient_music',
                'source_sound_control_reload_state_result.dark_music',
                'source_sound_control_reload_state_result.boss_music',
                'source_sound_control_reload_state_result.ui_bus_sounds',
            ],
        )
        for name in ledger['N2339']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/audio/SoundControl.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceSoundControlState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2339']['runtime_proof'], '/root/C07SoundControlReloadProof')
        self.assertEqual(
            ledger['N2339']['tests'],
            [
                'test_c07_sound_control_reload_registration',
                'test_all_c07_sound_control_reload_input_evidence_is_exact',
                'test_sound_control_reload_state',
                'test_reference_graph_and_actual_c07_sound_control_reload',
            ],
        )
        self.assertTrue(ledger['N2339']['deferred_exprs'])

    def test_all_c07_sound_control_reload_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2339']['source_symbols']:
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
        for expr in ledger['N2339']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_sound_control_reload_state(self):
        state = SOUND_CONTROL_STATE.read_text(encoding='utf-8')
        # SoundControl.reload() (SoundControl.java:75-91):
        # current = null; fade = 0f; the three music lists
        # are rebuilt from the Musics fields in exactly
        # this order; every Sound asset whose file parent
        # folder is "ui" gets the uiBus; a
        # MusicRegisterEvent is fired. Music arrives as its
        # name String (the N2287 precedent); the old
        # current / fade arrive as explicit params and are
        # overwritten unconditionally, exactly as Java
        # ignores them (the keepSilent precedent, N2336).
        self.assertIn('static func source_sound_control_reload_state(has_current: bool, current: String, fade: float, sound_parents: Dictionary) -> Dictionary:', state)
        self.assertIn('return {"current": null, "fade": 0.0, "ambient_music": ambient_music, "dark_music": dark_music, "boss_music": boss_music, "ui_bus_sounds": ui_bus_sounds}', state)
        self.assertIn('["game1", "game3", "game6", "game8", "game9", "fine"]', state)
        self.assertIn('["game2", "game5", "game7", "game4"]', state)
        self.assertIn('["boss1", "boss2", "game2", "game5"]', state)
        for expr in [
            'protected void reload(){',
            'current = null;',
            'fade = 0f;',
            'ambientMusic = Seq.with(Musics.game1, Musics.game3, Musics.game6, Musics.game8, Musics.game9, Musics.fine);',
            'darkMusic = Seq.with(Musics.game2, Musics.game5, Musics.game7, Musics.game4);',
            'bossMusic = Seq.with(Musics.boss1, Musics.boss2, Musics.game2, Musics.game5);',
            'for(var sound : Core.assets.getAll(Sound.class, new Seq<>())){',
            'var file = Fi.get(Core.assets.getAssetFileName(sound));',
            'if(file.parent().name().equals("ui")){',
            'sound.setBus(uiBus);',
            'Events.fire(new MusicRegisterEvent());',
            'protected @Nullable Music current;',
            'protected float fade;',
            'public Seq<Music> ambientMusic = Seq.with();',
            'public Seq<Music> darkMusic = Seq.with();',
            'public Seq<Music> bossMusic = Seq.with();',
            'public AudioBus uiBus = new AudioBus();',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        # NO audio playback in this slice (0 AudioStreamPlayer
        # in the port): reload() only returns state + the
        # bus-assignment list; playback belongs to
        # updateLoops (N2304, held waiting for B).
        self.assertNotIn('AudioStreamPlayer', state)
        # NO real RNG in the ported function: reload() is
        # pure assignment on explicit params.
        self.assertNotIn('randf()', state)
        self.assertNotIn('randi()', state)
        # The proof's keys drive the pure function directly
        # with explicit params: the current / fade reset,
        # the three music lists in order, the ui-folder
        # bus assignment, the empty registry, the
        # case-sensitive "ui" match, and input immutability.
        proof = SOUND_CONTROL_RELOAD_PROOF.read_text(encoding='utf-8')
        for key in [
            'reload_resets_current_and_fade',
            'reload_sets_ambient_music',
            'reload_sets_dark_music',
            'reload_sets_boss_music',
            'reload_assigns_ui_folder_sounds',
            'reload_ignores_other_folders',
            'reload_empty_sound_registry',
            'reload_no_current_still_null',
            'reload_ui_match_is_case_sensitive',
            'reload_does_not_mutate_inputs',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_sound_control_reload(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07SoundControlReloadProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SOUND_CONTROL_RELOAD_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'reload_resets_current_and_fade',
            'reload_sets_ambient_music',
            'reload_sets_dark_music',
            'reload_sets_boss_music',
            'reload_assigns_ui_folder_sounds',
            'reload_ignores_other_folders',
            'reload_empty_sound_registry',
            'reload_no_current_still_null',
            'reload_ui_match_is_case_sensitive',
            'reload_does_not_mutate_inputs',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
