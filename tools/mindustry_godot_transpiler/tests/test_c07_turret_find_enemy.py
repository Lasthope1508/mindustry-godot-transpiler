import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_FIND_ENEMY_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretFindEnemyProof.gd'


class C07TurretFindEnemyTests(unittest.TestCase):
    def test_c07_turret_find_enemy_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2425']['godot_owner'], 'SourceTurretBuildState.source_turret_find_enemy_state')
        self.assertEqual(ledger['N2425']['java_method'], 'TurretBuild.findEnemy(float)')
        # TurretBuild.findEnemy() (Turret.java:639-649): the else
        # branch binds the peeked ammo and calls Units.bestTarget:
        # `var ammo = peekAmmo();` (:643) and
        # `return Units.bestTarget(team, x, y, range,` (:645, opener
        # of the multi-line call). Everything else in the method is
        # already owned at N2316 (the findEnemy signature, the
        # air-only bestEnemy branch, the `boolean buildings = ...`
        # line :644 and the two predicate lambdas) and is NOT
        # re-registered here. The GD function
        # source_turret_find_enemy_state already exists (N2316):
        # this slice extends it -- it adds no new owner, no new
        # contract and no new schema; the ammo binding arrives as
        # the three ammo flags (ammo_is_null / ammo_target_blocks /
        # ammo_target_missiles) and the bestTarget call is the unit
        # loop plus the building fallback the function already
        # implements. The single result symbol is shared with
        # N2316 (the shared-symbol precedent: building_cursor.*
        # is listed by several slices).
        self.assertEqual(
            ledger['N2425']['exact_exprs'],
            [
                'var ammo = peekAmmo();',
                'return Units.bestTarget(team, x, y, range,',
            ],
        )
        self.assertEqual(
            ledger['N2425']['source_symbols'],
            [
                'source_turret_find_enemy_state_result.target',
            ],
        )
        for name in ledger['N2425']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/entities/Units.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2425']['runtime_proof'], '/root/C07TurretFindEnemyProof')
        self.assertEqual(
            ledger['N2425']['tests'],
            [
                'test_c07_turret_find_enemy_registration',
                'test_all_c07_turret_find_enemy_input_evidence_is_exact',
                'test_turret_find_enemy_state',
                'test_reference_graph_and_actual_c07_turret_find_enemy',
            ],
        )
        self.assertTrue(ledger['N2425']['deferred_exprs'])

    def test_all_c07_turret_find_enemy_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2425']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2425']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_find_enemy_state(self):
        state = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # The findEnemy GD function already exists (N2316); N2425
        # extends it with the ammo binding and the bestTarget call
        # opener, quoted verbatim on their own comment lines (the
        # N2378 precedent: never split an exact expr across lines).
        self.assertIn('static func source_turret_find_enemy_state(frame: Dictionary, team_is_derelict: bool, range: float, target_air: bool, target_ground: bool, target_blocks: bool, ammo_is_null: bool, ammo_target_blocks: bool, ammo_target_missiles: bool, unit_candidates: Array, building_candidates: Array) -> Dictionary:', state)
        for expr in [
            'var ammo = peekAmmo();',
            'return Units.bestTarget(team, x, y, range,',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        # The proof's keys drive the pure function on the two
        # newly-owned behaviours: the ammo binding (a null ammo
        # makes both missiles and buildings true; a non-null ammo
        # with targetBlocks false closes the building fallback)
        # and the bestTarget call (units are checked before
        # buildings, Units.java:284-294).
        proof = TURRET_FIND_ENEMY_PROOF.read_text(encoding='utf-8')
        for key in [
            'ammo_null_missiles_true',
            'ammo_null_buildings_true',
            'ammo_target_blocks_false_no_building',
            'best_target_unit_before_building',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_find_enemy(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretFindEnemyProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_FIND_ENEMY_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'ammo_null_missiles_true',
            'ammo_null_buildings_true',
            'ammo_target_blocks_false_no_building',
            'best_target_unit_before_building',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
