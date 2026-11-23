import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SOUND_CONTROL_STATE = ROOT / 'godot-mindustry/src/game/SourceSoundControlState.gd'
SOUND_CONTROL_IS_DARK_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SoundControlIsDarkProof.gd'


class C07SoundControlIsDarkTests(unittest.TestCase):
    def test_c07_sound_control_is_dark_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2315']['godot_owner'], 'SourceSoundControlState.source_sound_control_is_dark_state')
        # SoundControl.isDark() (SoundControl.java:285-299,
        # `protected boolean isDark(){` / `if(player.team()
        # .data().hasCore() && player.team().data().core()
        # .healthf() < 0.85f){` / `//core damaged -> dark` /
        # `return true;` / `//it may be dark based on wave` /
        # `if(Mathf.chance((float)(Math.log10((state.wave -
        # 17f)/19f) + 1) / 4f)){` / `//dark based on
        # enemies` / `return Mathf.chance(state.enemies /
        # 70f + 0.1f);`) is the dark-music gate: a damaged
        # core (hasCore() and healthf() strictly below
        # 0.85f) reads dark at once, otherwise the wave
        # chance roll decides, then the enemy chance roll.
        # It is the first RNG slice of the Game family: the
        # two Mathf.chance outcomes arrive as explicit bool
        # params (the N2291 precedent for live values, the
        # chance_delta_result precedent for RNG outcomes),
        # so the ported function is pure and never rolls RNG
        # itself. Its caller reads the gate in playRandom()
        # (SoundControl.java:259, `}else if(isDark()){`)
        # and plays a dark track when it is true. One new
        # result symbol: is_dark. NO audio playback in this
        # slice (0 AudioStreamPlayer in the port).
        self.assertEqual(
            ledger['N2315']['source_symbols'],
            [
                'source_sound_control_is_dark_state_result.is_dark',
            ],
        )
        for name in ledger['N2315']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/audio/SoundControl.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceSoundControlState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2315']['runtime_proof'], '/root/C07SoundControlIsDarkProof')
        self.assertEqual(
            ledger['N2315']['tests'],
            [
                'test_c07_sound_control_is_dark_registration',
                'test_all_c07_sound_control_is_dark_input_evidence_is_exact',
                'test_sound_control_is_dark_state',
                'test_reference_graph_and_actual_c07_sound_control_is_dark',
            ],
        )
        self.assertTrue(ledger['N2315']['deferred_exprs'])

    def test_all_c07_sound_control_is_dark_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2315']['source_symbols']:
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
        for expr in ledger['N2315']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_sound_control_is_dark_state(self):
        state = SOUND_CONTROL_STATE.read_text(encoding='utf-8')
        # SoundControl.isDark() (SoundControl.java:285-299):
        # damaged core reads dark at once (strict < 0.85f),
        # otherwise the wave chance roll decides, then the
        # enemy chance roll. The two Mathf.chance outcomes
        # arrive as explicit bool params; the ported
        # function never rolls RNG itself.
        self.assertIn('static func source_sound_control_is_dark_state(has_core: bool, core_healthf: float, wave_chance_roll: bool, enemy_chance_roll: bool) -> Dictionary:', state)
        self.assertIn('if has_core and core_healthf < 0.85:', state)
        self.assertIn('if wave_chance_roll:', state)
        self.assertIn('return {"is_dark": enemy_chance_roll}', state)
        for expr in [
            'protected boolean isDark(){',
            'if(player.team().data().hasCore() && player.team().data().core().healthf() < 0.85f){',
            'if(Mathf.chance((float)(Math.log10((state.wave - 17f)/19f) + 1) / 4f)){',
            'return Mathf.chance(state.enemies / 70f + 0.1f);',
            '}else if(isDark()){',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        # NO audio playback in this slice (0 AudioStreamPlayer
        # in the port): this is a pure gate; playback belongs
        # to updateLoops (N2304, held waiting for B).
        self.assertNotIn('AudioStreamPlayer', state)
        # NO real RNG in the ported function: the two chance
        # outcomes arrive as explicit bool params.
        self.assertNotIn('randf()', state)
        self.assertNotIn('randi()', state)
        # The proof's keys drive the pure function directly
        # with explicit params: damaged core, wave roll,
        # enemy roll, all false, intact core, the 0.85f
        # boundary, no core, and all true.
        proof = SOUND_CONTROL_IS_DARK_PROOF.read_text(encoding='utf-8')
        for key in [
            'is_dark_core_damaged',
            'is_dark_wave_roll',
            'is_dark_enemy_roll',
            'is_dark_all_false',
            'is_dark_core_intact',
            'is_dark_core_boundary',
            'is_dark_no_core',
            'is_dark_all_true',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_sound_control_is_dark(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07SoundControlIsDarkProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SOUND_CONTROL_IS_DARK_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'is_dark_core_damaged',
            'is_dark_wave_roll',
            'is_dark_enemy_roll',
            'is_dark_all_false',
            'is_dark_core_intact',
            'is_dark_core_boundary',
            'is_dark_no_core',
            'is_dark_all_true',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
