import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SOUND_CONTROL_STATE = ROOT / 'godot-mindustry/src/game/SourceSoundControlState.gd'
SOUND_CONTROL_SETUP_FILTERS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SoundControlSetupFiltersProof.gd'


class C07SoundControlSetupFiltersTests(unittest.TestCase):
    def test_c07_sound_control_setup_filters_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        # SoundControl.setupFilters() (SoundControl.java:70-73)
        # installs the SoundControl filter on sound-bus slot
        # 0 and sets its wet param to 0. The filter field
        # (SoundControl.java:39, `protected AudioFilter
        # filter = new BiquadFilter(){{ set(0, 500, 1); }};`)
        # arrives as an explicit opaque param -- the driver
        # owns the live filter object; this slice never
        # builds one. `Filters.paramWet` is the int constant
        # 0 (arc Filters.java:6, `public static final int
        # paramWet = 0;`), so the param in the command is 0.
        # NO audio playback in this slice (0
        # AudioStreamPlayer in the port): the two sound-bus
        # calls are returned as command state, never
        # executed; playback belongs to updateLoops (N2304,
        # held waiting for B). Callers (constructor :59,
        # update() :149) are NOT ported here.
        self.assertEqual(ledger['N2349']['godot_owner'], 'SourceSoundControlState.source_sound_control_setup_filters_state')
        self.assertEqual(
            ledger['N2349']['source_symbols'],
            [
                'source_sound_control_setup_filters_state_result.commands',
            ],
        )
        for name in ledger['N2349']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/audio/SoundControl.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceSoundControlState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2349']['runtime_proof'], '/root/C07SoundControlSetupFiltersProof')
        self.assertEqual(
            ledger['N2349']['tests'],
            [
                'test_c07_sound_control_setup_filters_registration',
                'test_all_c07_sound_control_setup_filters_input_evidence_is_exact',
                'test_sound_control_setup_filters_state',
                'test_reference_graph_and_actual_c07_sound_control_setup_filters',
            ],
        )
        self.assertTrue(ledger['N2349']['deferred_exprs'])

    def test_all_c07_sound_control_setup_filters_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2349']['source_symbols']:
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
        for expr in ledger['N2349']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_sound_control_setup_filters_state(self):
        state = SOUND_CONTROL_STATE.read_text(encoding='utf-8')
        # SoundControl.setupFilters() (SoundControl.java:70-73):
        # `protected void setupFilters(){` /
        # `Core.audio.soundBus.setFilter(0, filter);` /
        # `Core.audio.soundBus.setFilterParam(0,
        # Filters.paramWet, 0f);` -- installs the filter on
        # sound-bus slot 0, then sets its wet param (the int
        # constant 0, arc Filters.java:6) to 0f. The filter
        # field (SoundControl.java:39) arrives as an explicit
        # opaque param and is echoed into the first command;
        # this slice never builds a filter. NO audio playback
        # in this slice: both sound-bus calls are returned as
        # command state, never executed.
        self.assertIn('static func source_sound_control_setup_filters_state(filter: Variant) -> Dictionary:', state)
        self.assertIn('commands.append({"action": "set_filter", "slot": 0, "filter": filter})', state)
        self.assertIn('commands.append({"action": "set_filter_param", "slot": 0, "param": 0, "value": 0.0})', state)
        self.assertIn('return {"commands": commands}', state)
        for expr in [
            'protected void setupFilters(){',
            'Core.audio.soundBus.setFilter(0, filter);',
            'Core.audio.soundBus.setFilterParam(0, Filters.paramWet, 0f);',
            'protected AudioFilter filter = new BiquadFilter(){{',
            'set(0, 500, 1);',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        # NO audio playback in this slice (0 AudioStreamPlayer
        # in the port): setupFilters only returns command
        # state; playback belongs to updateLoops (N2304, held
        # waiting for B).
        self.assertNotIn('AudioStreamPlayer', state)
        # NO real RNG in the ported function: installing the
        # filter is pure command construction on the explicit
        # filter param.
        self.assertNotIn('randf()', state)
        self.assertNotIn('randi()', state)
        # The proof's keys drive the pure function directly:
        # two commands in Java order, the set_filter first
        # with the filter echoed, the set_filter_param
        # second with param 0 and value 0.0, a second filter
        # echoed unchanged, and a single-key result.
        proof = SOUND_CONTROL_SETUP_FILTERS_PROOF.read_text(encoding='utf-8')
        for key in [
            'setup_filters_issues_two_commands',
            'setup_filters_set_filter_first',
            'setup_filters_set_filter_param_second',
            'setup_filters_filter_echoes_param',
            'setup_filters_returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_sound_control_setup_filters(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07SoundControlSetupFiltersProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SOUND_CONTROL_SETUP_FILTERS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'setup_filters_issues_two_commands',
            'setup_filters_set_filter_first',
            'setup_filters_set_filter_param_second',
            'setup_filters_filter_echoes_param',
            'setup_filters_returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
