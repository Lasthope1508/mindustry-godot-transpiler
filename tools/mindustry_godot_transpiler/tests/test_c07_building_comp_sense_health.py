import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
BUILDING_COMP_SENSE_HEALTH_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BuildingCompSenseHealthProof.gd'

BUILDING_COMP_SENSE_HEALTH_SIGNATURE = 'static func source_building_comp_sense_health_state(health: float) -> Dictionary:'
PROOF_KEYS = [
    'health_full_num',
    'health_damaged_num',
    'health_zero_num',
    'health_fractional_num',
    'health_handled_true',
    'health_value_not_nan',
]


class C07BuildingCompSenseHealthTests(unittest.TestCase):
    def test_c07_building_comp_sense_health_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2512']['godot_owner'], 'SourceTurretBuildState.source_building_comp_sense_health_state')
        # BuildingComp.sense() `health` leg is `case health ->
        # health;` (BuildingComp.java:2101), with `health` the
        # building's current health field (`float health;`,
        # HealthComp.java:11 -- BuildingComp mixes
        # HealthComp). N2284 ported 23 handled legs of
        # BuildingComp.sense (BuildingComp.java:2093-2126) and
        # left dead/health/totalItems/camera*/powerNet*
        # deferred -- health deferred because the live
        # building health is not stamped in the frame (note
        # inside `source_building_comp_sense_state`,
        # SourceTurretBuildState.gd:404). N2511 ported `dead`.
        # This slice ports exactly the `health` leg, next in
        # Java switch order after `dead` (:2098 -> :2101).
        # The live health is passed in as a param (the
        # N2212/N2220 per-def-param precedent): the param is
        # the live input a future frame-stamp slice will
        # supply. `sense_value` is `health` exactly, no
        # clamping, no rounding, no healthf() conversion
        # (`healthf()` is a different accessor,
        # HealthComp.java:20 -- NOT this leg). `handled` is
        # true always (this function IS the health leg; the
        # sensor is fixed `health`, so no `sensor` param)
        # and `sense_value_is_nan` is false always (the leg
        # never yields NaN; the key stays in the wire shape
        # for consistency with N2283/N2284/N2511).
        # Three new result symbols (handled, sense_value,
        # sense_value_is_nan -- the N2283/N2284 sense wire
        # shape). The ported method is BuildingComp.sense, so
        # the java_source is BuildingComp.java and the slice
        # mirrors into the comp shard (561/465 -> 562/466);
        # defense stays 210/209.
        self.assertEqual(
            ledger['N2512']['source_symbols'],
            [
                'source_building_comp_sense_health_state_result.handled',
                'source_building_comp_sense_health_state_result.sense_value',
                'source_building_comp_sense_health_state_result.sense_value_is_nan',
            ],
        )
        for name in ledger['N2512']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/entities/comp/BuildingComp.java')
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_building_comp_sense_health_state')
        self.assertEqual(ledger['N2512']['runtime_proof'], '/root/C07BuildingCompSenseHealthProof')
        self.assertEqual(
            ledger['N2512']['tests'],
            [
                'test_c07_building_comp_sense_health_registration',
                'test_all_c07_building_comp_sense_health_input_evidence_is_exact',
                'test_building_comp_sense_health_state',
                'test_reference_graph_and_actual_c07_building_comp_sense_health',
            ],
        )
        self.assertTrue(ledger['N2512']['deferred_exprs'])

    def test_all_c07_building_comp_sense_health_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2512']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_building_comp_sense_health_state')
        slice_sources = {
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/entities/comp/HealthComp.java',
            'core/src/mindustry/logic/LAccess.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2512']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_building_comp_sense_health_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # BuildingComp.sense() `health` leg
        # (BuildingComp.java:2101): `case health -> health;`
        # -- `health` is the building's current health field
        # (`float health;`, HealthComp.java:11). The pure
        # function returns `health` exactly, no clamping, no
        # rounding, no healthf() conversion (`healthf()` is a
        # different accessor, HealthComp.java:20 -- NOT this
        # leg), with handled true and sense_value_is_nan
        # false always (the N2283/N2284 sense wire shape).
        # There is no driver tick line: the leg is a logic
        # read, not a tick write (the
        # N2206/N2208/N2223/N2283/N2284/N2506/N2507/N2508/N2509/N2510/N2511
        # precedent); the proof calls the pure function
        # directly with synthetic inputs.
        self.assertIn(BUILDING_COMP_SENSE_HEALTH_SIGNATURE, turret)
        for line in [
            'return {"handled": true, "sense_value": health, "sense_value_is_nan": false}',
        ]:
            with self.subTest(line=line):
                self.assertIn(line, turret)
        for expr in [
            'case health -> health;',
            'float health;',
            'public double sense(LAccess sensor){',
            'default -> Float.NaN; //gets converted to null in logic',
            'health,',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The pure function sits immediately AFTER
        # source_building_comp_sense_dead_state and BEFORE
        # source_turret_sense_object_state, mirroring the
        # sense()/senseObject() order in BuildingComp.java
        # (:2093 / :2128) and, inside sense(), dead :2098 ->
        # health :2101. It does NOT modify
        # source_building_comp_sense_state: health stays
        # handled:false in the big dispatch until a later
        # wiring slice connects this leg (same as N2511's
        # dead leg living beside N2284).
        self.assertLess(turret.index('static func source_building_comp_sense_dead_state('), turret.index('static func source_building_comp_sense_health_state('))
        self.assertLess(turret.index('static func source_building_comp_sense_health_state('), turret.index('static func source_turret_sense_object_state('))
        # The proof's keys drive the pure function with
        # synthetic inputs (no live tick: the leg is a logic
        # read of the passed-in live health): full health
        # (100.0) reads 100.0, damaged health (37.5) reads
        # 37.5, zero health reads 0.0, fractional health
        # (12.25) reads 12.25 exactly, handled true, never
        # NaN.
        proof = BUILDING_COMP_SENSE_HEALTH_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_building_comp_sense_health(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BuildingCompSenseHealthProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BUILDING_COMP_SENSE_HEALTH_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
