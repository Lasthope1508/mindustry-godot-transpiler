import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
UNIT_TYPE_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitTypeState.gd'
UNIT_TYPE_ESTIMATE_DPS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitTypeEstimateDpsProof.gd'


class C07UnitTypeEstimateDpsTests(unittest.TestCase):
    def test_c07_unit_type_estimate_dps_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2533']['godot_owner'], 'SourceUnitTypeState.source_unit_type_estimate_dps_state')
        # estimateDps() is the UnitType read (UnitType.java:1132-1144):
        # `public float estimateDps(){` /
        # `if(dpsEstimate < 0){` /
        # `dpsEstimate = weapons.sumf(Weapon::dps);` /
        # `if(weapons.contains(w -> w.bullet.killShooter)){` /
        # `dpsEstimate /= 15f;` /
        # `return dpsEstimate;`.
        # The cache check is `dpsEstimate < 0` (NOT `>= 0f`):
        # a cached value of 0.0 IS a hit (0 is not < 0), and a
        # negative cache (-1, the `dpsEstimate = -1,` init, or
        # any other negative) recomputes. The suicide leg
        # divides the SAME field that was just summed
        # (`dpsEstimate /= 15f;`), so the divided value is what
        # gets cached -- the pure function returns the divided
        # value through both `estimate_dps` and `cached_dps` on
        # the "computed_suicide" branch. `cached_dps` is the
        # runtime cache (`dpsEstimate = -1,`, UnitType.java:104
        # -- -1 means "not computed yet"; the field doc says "a
        # VERY ROUGH estimate of unit DPS; initialized in
        # init()"). `weapons_dps_sum` is the caller-summed
        # `weapons.sumf(Weapon::dps)` (UnitType.java:1136):
        # Weapon.dps() (Weapon.java:188-190, `(bullet.
        # estimateDPS() / reload) * shoot.shots * 60f`) is NOT
        # ported yet, so the sum arrives as a float param (the
        # N2529 precedent -- the spawn unit DPS was a param
        # until this slice). `has_kill_shooter_weapon` is the
        # caller-side `weapons.contains(w -> w.bullet.
        # killShooter)` guard (UnitType.java:1139): the caller
        # scans the weapons for a bullet with `killShooter`
        # (BulletType.java:105); the function cannot scan
        # weapons from a float param. Three new result symbols:
        # estimate_dps, cached_dps, branch (the N2526 precedent
        # -- every return key is a symbol). The slice mirrors
        # into the type shard; comp stays 572/475.
        self.assertEqual(
            ledger['N2533']['source_symbols'],
            [
                'source_unit_type_estimate_dps_state_result.estimate_dps',
                'source_unit_type_estimate_dps_state_result.cached_dps',
                'source_unit_type_estimate_dps_state_result.branch',
            ],
        )
        for name in ledger['N2533']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/type/UnitType.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceUnitTypeState.source_unit_type_estimate_dps_state')
        self.assertEqual(ledger['N2533']['runtime_proof'], '/root/C07UnitTypeEstimateDpsProof')
        self.assertEqual(
            ledger['N2533']['tests'],
            [
                'test_c07_unit_type_estimate_dps_registration',
                'test_all_c07_unit_type_estimate_dps_input_evidence_is_exact',
                'test_unit_type_estimate_dps_state',
                'test_reference_graph_and_actual_c07_unit_type_estimate_dps',
            ],
        )
        self.assertTrue(ledger['N2533']['deferred_exprs'])

    def test_all_c07_unit_type_estimate_dps_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2533']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceUnitTypeState.source_unit_type_estimate_dps_state')
        slice_sources = {
            'core/src/mindustry/type/UnitType.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2533']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_unit_type_estimate_dps_state(self):
        unit_type = UNIT_TYPE_STATE.read_text(encoding='utf-8')
        # estimateDps() (UnitType.java:1132-1144) for the
        # UnitType family as one pure function, in exact Java
        # order: 1 `cached_dps >= 0.0` -> return the cached
        # value (branch "cached"); 2 otherwise `dps =
        # weapons_dps_sum`; if `has_kill_shooter_weapon` then
        # `dps /= 15.0` and return it with `cached_dps` = the
        # divided value (branch "computed_suicide"); 3
        # otherwise return `dps` with `cached_dps` = `dps`
        # (branch "computed"). The function returns exactly the
        # three keys `estimate_dps`, `cached_dps`, `branch`. NO
        # driver tick call site (the N2528/N2529/N2530/N2531/
        # N2532 precedent): estimateDps() is a read/estimate,
        # not per-tick, and no caller reads it today (the N2529
        # bullet function still takes `spawn_unit_dps` /
        # `despawn_unit_dps` as float params; wiring N2529 ->
        # N2533 is a separate consumer slice; HUD / stats
        # display is C11). `estimateDps()` is also called from
        # `UnitType.init()` (UnitType.java:1129) -- that is a
        # content-init call site, not a per-tick driver, and
        # this slice does not wire init().
        self.assertIn('static func source_unit_type_estimate_dps_state(cached_dps: float, weapons_dps_sum: float, has_kill_shooter_weapon: bool) -> Dictionary:', unit_type)
        self.assertIn('if cached_dps >= 0.0:', unit_type)
        self.assertIn('return {"estimate_dps": cached_dps, "cached_dps": cached_dps, "branch": "cached"}', unit_type)
        self.assertIn('var dps: float = weapons_dps_sum', unit_type)
        self.assertIn('if has_kill_shooter_weapon:', unit_type)
        self.assertIn('dps /= 15.0', unit_type)
        self.assertIn('return {"estimate_dps": dps, "cached_dps": dps, "branch": "computed_suicide"}', unit_type)
        self.assertIn('return {"estimate_dps": dps, "cached_dps": dps, "branch": "computed"}', unit_type)
        self.assertIn('public float estimateDps(){', unit_type)
        self.assertIn('if(dpsEstimate < 0){', unit_type)
        self.assertIn('dpsEstimate = weapons.sumf(Weapon::dps);', unit_type)
        self.assertIn('if(weapons.contains(w -> w.bullet.killShooter)){', unit_type)
        self.assertIn('dpsEstimate /= 15f;', unit_type)
        self.assertIn('return dpsEstimate;', unit_type)
        self.assertIn('dpsEstimate = -1,', unit_type)
        self.assertIn('DORMANT', unit_type)
        # The pure function sits immediately AFTER landed_state
        # (the last pure function in the file) and BEFORE the
        # generated bridges.
        self.assertLess(unit_type.index('static func landed_state('), unit_type.index('static func source_unit_type_estimate_dps_state('))
        self.assertLess(unit_type.index('static func source_unit_type_estimate_dps_state('), unit_type.index('static func generated_create_controller_bridge_state('))
        # NO driver tick call site: the definition is the only
        # occurrence of the function name in this file.
        self.assertEqual(unit_type.count('source_unit_type_estimate_dps_state('), 1)
        # The proof's keys drive the pure function on exact
        # legs: 1 cache hit -> 42.0, cached unchanged (cache
        # wins even with a suicide weapon present); 2 cached
        # 0.0 IS a hit (0 is not < 0) -> 0.0; 3 negative cache
        # -5.0 recomputes -> 30.0; 4 weapons sum 120.0 -> 120.0;
        # 5 fractional sum 37.5 -> 37.5; 6 suicide 150.0 / 15
        # -> 10.0; 7 suicide fraction 100.0 / 15 -> 100/15;
        # 8 Java defaults (dpsEstimate init -1, no weapons) ->
        # 0.0.
        proof = UNIT_TYPE_ESTIMATE_DPS_PROOF.read_text(encoding='utf-8')
        for key in [
            'estimate_dps_cached_hit',
            'estimate_dps_cached_zero',
            'estimate_dps_negative_cached_recomputes',
            'estimate_dps_weapons_sum',
            'estimate_dps_fractional_sum',
            'estimate_dps_suicide',
            'estimate_dps_suicide_fraction',
            'estimate_dps_java_defaults',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_unit_type_estimate_dps(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07UnitTypeEstimateDpsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_UNIT_TYPE_ESTIMATE_DPS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'estimate_dps_cached_hit',
            'estimate_dps_cached_zero',
            'estimate_dps_negative_cached_recomputes',
            'estimate_dps_weapons_sum',
            'estimate_dps_fractional_sum',
            'estimate_dps_suicide',
            'estimate_dps_suicide_fraction',
            'estimate_dps_java_defaults',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
