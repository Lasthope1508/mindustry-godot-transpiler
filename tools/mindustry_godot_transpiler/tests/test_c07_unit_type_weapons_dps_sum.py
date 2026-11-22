import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
UNIT_TYPE_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitTypeState.gd'
UNIT_TYPE_WEAPONS_DPS_SUM_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitTypeWeaponsDpsSumProof.gd'


class C07UnitTypeWeaponsDpsSumTests(unittest.TestCase):
    def test_c07_unit_type_weapons_dps_sum_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2536']['godot_owner'], 'SourceUnitTypeState.source_unit_type_weapons_dps_sum_state')
        # The wiring leg of UnitType.estimateDps()
        # (UnitType.java:1132-1144):
        # `public float estimateDps(){` /
        # `dpsEstimate = weapons.sumf(Weapon::dps);` /
        # `return dpsEstimate;`.
        # `weapons` is `public Seq<Weapon> weapons = new Seq<>();`
        # (UnitType.java:288). The sum is over one dps value per
        # weapon, each computed by the caller with
        # `source_weapon_dps_state` (N2534, Weapon.dps(),
        # Weapon.java:188-190, `(bullet.estimateDPS() / reload) *
        # shoot.shots * 60f`): this function does NOT call
        # Weapon.dps() directly (the N2528/N2529/N2533
        # param-driven precedent -- calling it here would force
        # the 13 bullet params into the UnitType signature).
        # `weapons_dps` is an Array of floats (one per weapon);
        # an empty Seq sums to 0.0 (arc Seq.sumf starts from 0).
        # One new result symbol: weapons_dps_sum (the N2526
        # precedent -- every return key is a symbol). The slice
        # mirrors into the type shard; comp stays 572/475.
        self.assertEqual(
            ledger['N2536']['source_symbols'],
            [
                'source_unit_type_weapons_dps_sum_state_result.weapons_dps_sum',
            ],
        )
        for name in ledger['N2536']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/type/UnitType.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceUnitTypeState.source_unit_type_weapons_dps_sum_state')
        self.assertEqual(ledger['N2536']['runtime_proof'], '/root/C07UnitTypeWeaponsDpsSumProof')
        self.assertEqual(
            ledger['N2536']['tests'],
            [
                'test_c07_unit_type_weapons_dps_sum_registration',
                'test_all_c07_unit_type_weapons_dps_sum_input_evidence_is_exact',
                'test_unit_type_weapons_dps_sum_state',
                'test_reference_graph_and_actual_c07_unit_type_weapons_dps_sum',
            ],
        )
        self.assertTrue(ledger['N2536']['deferred_exprs'])

    def test_all_c07_unit_type_weapons_dps_sum_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2536']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceUnitTypeState.source_unit_type_weapons_dps_sum_state')
        slice_sources = {
            'core/src/mindustry/type/UnitType.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2536']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_unit_type_weapons_dps_sum_state(self):
        unit_type = UNIT_TYPE_STATE.read_text(encoding='utf-8')
        # The sumf leg of estimateDps() (UnitType.java:1136)
        # for the UnitType family as one pure function: total
        # starts at 0.0 (an empty weapons Seq sums to 0.0),
        # each per-weapon dps value is added, and the single
        # return key is `weapons_dps_sum`. NO driver tick call
        # site (the N2528/N2529/N2530/N2531/N2532/N2533/N2534/
        # N2535 precedent): the sum is a read/estimate, not
        # per-tick, and no caller reads it today (N2533 still
        # takes `weapons_dps_sum` as a float param; the consumer
        # that calls this sum and passes it into
        # `source_unit_type_estimate_dps_state` is a later slice;
        # C11 HUD / stats display is C11).
        self.assertIn('static func source_unit_type_weapons_dps_sum_state(weapons_dps: Array) -> Dictionary:', unit_type)
        self.assertIn('var total: float = 0.0', unit_type)
        self.assertIn('total += float(value)', unit_type)
        self.assertIn('return {"weapons_dps_sum": total}', unit_type)
        self.assertIn('public float estimateDps(){', unit_type)
        self.assertIn('dpsEstimate = weapons.sumf(Weapon::dps);', unit_type)
        self.assertIn('public Seq<Weapon> weapons = new Seq<>();', unit_type)
        self.assertIn('return dpsEstimate;', unit_type)
        self.assertIn('DORMANT', unit_type)
        # The pure function sits immediately AFTER
        # source_unit_type_estimate_dps_state (the last pure
        # function in the file) and BEFORE the generated
        # bridges.
        self.assertLess(unit_type.index('static func source_unit_type_estimate_dps_state('), unit_type.index('static func source_unit_type_weapons_dps_sum_state('))
        self.assertLess(unit_type.index('static func source_unit_type_weapons_dps_sum_state('), unit_type.index('static func generated_create_controller_bridge_state('))
        # NO driver tick call site: the definition is the only
        # occurrence of the function name in this file.
        self.assertEqual(unit_type.count('source_unit_type_weapons_dps_sum_state('), 1)
        # The proof's keys drive the pure function on exact
        # legs: 1 empty weapons -> 0.0; 2 single weapon 60.0 ->
        # 60.0; 3 two weapons 30.0 + 60.0 -> 90.0; 4 fractional
        # 12.5 + 25.0 -> 37.5; 5 with a zero-dps weapon 0.0 +
        # 45.0 -> 45.0; 6 four weapons of 60.0 -> 240.0; 7 large
        # 500.0 + 500.0 -> 1000.0; 8 small fractions 0.5 + 0.25
        # + 0.25 -> 1.0.
        proof = UNIT_TYPE_WEAPONS_DPS_SUM_PROOF.read_text(encoding='utf-8')
        for key in [
            'weapons_dps_sum_empty',
            'weapons_dps_sum_single',
            'weapons_dps_sum_two',
            'weapons_dps_sum_fractional',
            'weapons_dps_sum_with_zero',
            'weapons_dps_sum_many',
            'weapons_dps_sum_large',
            'weapons_dps_sum_small_fractions',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_unit_type_weapons_dps_sum(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07UnitTypeWeaponsDpsSumProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_UNIT_TYPE_WEAPONS_DPS_SUM_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'weapons_dps_sum_empty',
            'weapons_dps_sum_single',
            'weapons_dps_sum_two',
            'weapons_dps_sum_fractional',
            'weapons_dps_sum_with_zero',
            'weapons_dps_sum_many',
            'weapons_dps_sum_large',
            'weapons_dps_sum_small_fractions',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
