import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
WAVE_SPAWN_RUNTIME = ROOT / 'godot-mindustry/src/game/SourceWaveSpawnRuntimeState.gd'
GET_SPAWNED_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SpawnGroupGetSpawnedProof.gd'


class C07SpawnGroupGetSpawnedTests(unittest.TestCase):
    def test_c07_spawn_group_get_spawned_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2449']['godot_owner'], 'SourceWaveSpawnRuntimeState.spawned_for_wave_state')
        # SpawnGroup.getSpawned(int) (SpawnGroup.java:67-73), one
        # method slice (batch 42 slot 1): exactly the 3 body exprs
        # `:68` `if(spacing == 0) spacing = 1;`, `:69`
        # `if(wave < begin || wave > end || (wave - begin) %
        # spacing != 0){`, `:72` `return Math.min(unitAmount +
        # (int)(((wave - begin) / spacing) / unitScaling), max);`.
        # `:70` `return 0;` is a generic literal already owned by
        # 11 slices (N1184/N1414/N1635/N524/N949/N1802/N1885/
        # N2286/N2322/N2245/N2249) and is NOT registered here.
        # Registration-only (precedent N2427/N2430/N2432-N2434):
        # the formula is already LIVE in
        # SourceWaveSpawnRuntimeState.spawned_for_wave_state
        # (:16-40) -- no GD change in this slice. The godot_owner
        # follows the N2447 ClassName.func_name convention; the
        # runtime "source_owner" value inside the returned dict
        # comes from the registry const
        # SOURCE_WAVE_SPAWNED_FOR_WAVE_STATE
        # (SourceRuntimeOwnerGameplayRegistry.gd:175, lowercase
        # value "source_wave_spawn_runtime_state.
        # spawned_for_wave_state").
        self.assertEqual(
            ledger['N2449']['java_method'],
            'SpawnGroup.getSpawned(int)',
        )
        self.assertEqual(
            ledger['N2449']['exact_exprs'],
            [
                'if(spacing == 0) spacing = 1;',
                'if(wave < begin || wave > end || (wave - begin) % spacing != 0){',
                'return Math.min(unitAmount + (int)(((wave - begin) / spacing) / unitScaling), max);',
            ],
        )
        self.assertEqual(
            ledger['N2449']['source_symbols'],
            [
                'source_wave_spawned_for_wave_state_result.spacing',
                'source_wave_spawned_for_wave_state_result.eligible',
                'source_wave_spawned_for_wave_state_result.spawned',
            ],
        )
        for name in ledger['N2449']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/game/SpawnGroup.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceWaveSpawnRuntimeState.spawned_for_wave_state'))
        self.assertEqual(ledger['N2449']['runtime_proof'], '/root/C07SpawnGroupGetSpawnedProof')
        self.assertEqual(
            ledger['N2449']['tests'],
            [
                'test_c07_spawn_group_get_spawned_registration',
                'test_all_c07_spawn_group_get_spawned_input_evidence_is_exact',
                'test_spawn_group_get_spawned_state',
                'test_reference_graph_and_actual_c07_spawn_group_get_spawned',
            ],
        )
        self.assertTrue(ledger['N2449']['deferred_exprs'])

    def test_all_c07_spawn_group_get_spawned_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2449']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceWaveSpawnRuntimeState.spawned_for_wave_state'))
        slice_sources = {
            'core/src/mindustry/game/SpawnGroup.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2449']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_spawn_group_get_spawned_state(self):
        wave = WAVE_SPAWN_RUNTIME.read_text(encoding='utf-8')
        # SpawnGroup.getSpawned(int) (SpawnGroup.java:67-73): the
        # formula is already LIVE in spawned_for_wave_state
        # (:16-40) -- this slice registers it only, no GD change.
        # The 2 const strings keep :69 and :72 verbatim; :68 lives
        # as the non-mutating `max(1, spacing)` clamp (:19); the
        # eligible predicate (:25) is the exact negation of :69 and
        # spawned (:28-29) is the :72 formula with spawned = 0 when
        # not eligible (equivalent to :70).
        self.assertIn('static func spawned_for_wave_state(group: Dictionary, wave_zero: int) -> Dictionary:', wave)
        self.assertIn('const SOURCE_SPAWN_GROUP_GET_SPAWNED_BEGIN_END_EXPR := "if(wave < begin || wave > end || (wave - begin) % spacing != 0){"', wave)
        self.assertIn('const SOURCE_SPAWN_GROUP_GET_SPAWNED_AMOUNT_EXPR := "return Math.min(unitAmount + (int)(((wave - begin) / spacing) / unitScaling), max);"', wave)
        self.assertIn('var spacing: int = max(1, int(group.get("spacing", SPAWN_GROUP_SPACING_DEFAULT)))', wave)
        self.assertIn('var eligible: bool = wave_zero >= begin and wave_zero <= end and (wave_zero - begin) % spacing == 0', wave)
        self.assertIn('spawned = min(unit_amount + int((float(wave_zero - begin) / float(spacing)) / unit_scaling), max_amount)', wave)
        # The proof drives the existing pure function with synthetic
        # frame inputs (no live tick, no spawner): wave < begin ->
        # 0; wave > end -> 0; (wave-begin) % spacing != 0 -> 0;
        # spacing == 0 treated as spacing 1; valid wave -> :72
        # formula (unitScaling + max clamp); the returned spacing
        # is the effective spacing after :68.
        proof = GET_SPAWNED_PROOF.read_text(encoding='utf-8')
        for key in [
            'get_spawned_zero_when_wave_below_begin',
            'get_spawned_zero_when_wave_above_end',
            'get_spawned_zero_when_wave_not_multiple',
            'get_spawned_spacing_zero_treated_as_one',
            'get_spawned_valid_wave_formula',
            'get_spawned_eligible_true_when_valid',
            'get_spawned_max_clamp',
            'get_spawned_unit_scaling',
            'get_spawned_returns_effective_spacing',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_spawn_group_get_spawned(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07SpawnGroupGetSpawnedProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SPAWN_GROUP_GET_SPAWNED_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'get_spawned_zero_when_wave_below_begin',
            'get_spawned_zero_when_wave_above_end',
            'get_spawned_zero_when_wave_not_multiple',
            'get_spawned_spacing_zero_treated_as_one',
            'get_spawned_valid_wave_formula',
            'get_spawned_eligible_true_when_valid',
            'get_spawned_max_clamp',
            'get_spawned_unit_scaling',
            'get_spawned_returns_effective_spacing',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
