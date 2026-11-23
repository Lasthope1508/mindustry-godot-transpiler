import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
WAVE_SPAWN_RUNTIME = ROOT / 'godot-mindustry/src/game/SourceWaveSpawnRuntimeState.gd'
GET_SHIELD_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SpawnGroupGetShieldProof.gd'


class C07SpawnGroupGetShieldTests(unittest.TestCase):
    def test_c07_spawn_group_get_shield_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2452']['godot_owner'], 'SourceWaveSpawnRuntimeState.source_spawn_group_get_shield_state')
        # SpawnGroup.getShield(int) (SpawnGroup.java:76-78), one
        # method slice (batch 43 slot 1): exactly the 1 body expr
        # `:77` `return Math.max(shields + shieldScaling*(wave -
        # begin), 0);`. Unlike getSpawned (N2449, registration-only),
        # the formula is NOT live in GD yet (grep `-i shield` in
        # SourceWaveSpawnRuntimeState.gd: 0-hit; grep
        # `get_shield|getShield` in all of src/game/: 0-hit), so
        # this slice writes a NEW GD func
        # source_spawn_group_get_shield_state (the validator only
        # discovers source_*/generated_/tile_ functions -- the
        # N2449 linkage lesson: never register a bare name).
        self.assertEqual(
            ledger['N2452']['java_method'],
            'SpawnGroup.getShield(int)',
        )
        self.assertEqual(
            ledger['N2452']['exact_exprs'],
            [
                'return Math.max(shields + shieldScaling*(wave - begin), 0);',
            ],
        )
        self.assertEqual(
            ledger['N2452']['source_symbols'],
            [
                'source_spawn_group_get_shield_state_result.shield',
            ],
        )
        for name in ledger['N2452']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/game/SpawnGroup.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceWaveSpawnRuntimeState.source_spawn_group_get_shield_state'))
        self.assertEqual(ledger['N2452']['runtime_proof'], '/root/C07SpawnGroupGetShieldProof')
        self.assertEqual(
            ledger['N2452']['tests'],
            [
                'test_c07_spawn_group_get_shield_registration',
                'test_all_c07_spawn_group_get_shield_input_evidence_is_exact',
                'test_spawn_group_get_shield_state',
                'test_reference_graph_and_actual_c07_spawn_group_get_shield',
            ],
        )
        self.assertTrue(ledger['N2452']['deferred_exprs'])

    def test_all_c07_spawn_group_get_shield_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2452']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceWaveSpawnRuntimeState.source_spawn_group_get_shield_state'))
        slice_sources = {
            'core/src/mindustry/game/SpawnGroup.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2452']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_spawn_group_get_shield_state(self):
        wave = WAVE_SPAWN_RUNTIME.read_text(encoding='utf-8')
        # SpawnGroup.getShield(int) (SpawnGroup.java:76-78): the
        # formula is NEW in GD -- this slice adds
        # source_spawn_group_get_shield_state. Java
        # `Math.max(float, int 0)` becomes GD
        # `maxf(shields + shield_scaling * float(wave - begin),
        # 0.0)` (maxf, not maxi, because the left side is a float;
        # wave - begin may be negative -- the formula clamps to 0
        # correctly in that case too).
        self.assertIn('static func source_spawn_group_get_shield_state(shields: float, shield_scaling: float, wave: int, begin: int) -> Dictionary:', wave)
        self.assertIn('maxf(shields + shield_scaling * float(wave - begin), 0.0)', wave)
        # The proof drives the new pure function with synthetic
        # frame inputs (no live tick, no spawner): shields 0 +
        # scaling 0 -> 0; wave == begin -> shields; wave > begin
        # with positive scaling -> formula; wave < begin with
        # positive scaling -> clamp 0; scaling 0 -> shields
        # regardless of wave; exactly 1 result key; a second call
        # on the same inputs yields the same value.
        proof = GET_SHIELD_PROOF.read_text(encoding='utf-8')
        for key in [
            'get_shield_zero_when_no_shields_no_scaling',
            'get_shield_returns_shields_when_wave_equals_begin',
            'get_shield_formula_when_wave_after_begin',
            'get_shield_clamps_to_zero_when_wave_before_begin',
            'get_shield_returns_shields_when_scaling_zero',
            'get_shield_returns_one_key',
            'get_shield_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_spawn_group_get_shield(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07SpawnGroupGetShieldProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SPAWN_GROUP_GET_SHIELD_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'get_shield_zero_when_no_shields_no_scaling',
            'get_shield_returns_shields_when_wave_equals_begin',
            'get_shield_formula_when_wave_after_begin',
            'get_shield_clamps_to_zero_when_wave_before_begin',
            'get_shield_returns_shields_when_scaling_zero',
            'get_shield_returns_one_key',
            'get_shield_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
