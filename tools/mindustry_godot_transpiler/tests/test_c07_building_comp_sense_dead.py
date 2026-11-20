import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
BUILDING_COMP_SENSE_DEAD_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BuildingCompSenseDeadProof.gd'

BUILDING_COMP_SENSE_DEAD_SIGNATURE = 'static func source_building_comp_sense_dead_state(tile_build_is_self: bool, is_dead: bool) -> Dictionary:'
PROOF_KEYS = [
    'dead_tile_not_self_num',
    'dead_is_dead_num',
    'alive_valid_zero',
    'dead_handled_true',
    'dead_value_not_nan',
    'dead_both_invalid_num',
]


class C07BuildingCompSenseDeadTests(unittest.TestCase):
    def test_c07_building_comp_sense_dead_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2511']['godot_owner'], 'SourceTurretBuildState.source_building_comp_sense_dead_state')
        # BuildingComp.sense() `dead` leg is `case dead ->
        # !isValid() ? 1 : 0;` (BuildingComp.java:2098), with
        # `isValid()` `public boolean isValid(){` /
        # `return tile.build == self() && !dead();`
        # (:2030-2032). N2284 ported 23 handled legs of
        # BuildingComp.sense (BuildingComp.java:2093-2126) and
        # left dead/health/totalItems/camera*/powerNet*
        # deferred -- dead deferred because `isValid()` needs
        # tile state not in the frame (note inside
        # `source_building_comp_sense_state`,
        # SourceTurretBuildState.gd:313). This slice ports
        # exactly the `dead` leg, first in Java switch order
        # among the deferred legs. The two `isValid()`
        # conjuncts are passed in as params (the N2212/N2220
        # per-def-param precedent): `tile_build_is_self` is
        # `tile.build == self()` (:2031, first conjunct) and
        # `is_dead` is `dead()` (:2031, second conjunct,
        # negated in `isValid()`). `sense_value` is 0.0 when
        # valid, 1.0 when not valid (`!isValid() ? 1 : 0`,
        # :2098). `handled` is true always (this function IS
        # the dead leg; the sensor is fixed `dead`, so no
        # `sensor` param) and `sense_value_is_nan` is false
        # always (the leg never yields NaN; the key stays in
        # the wire shape for consistency with N2283/N2284).
        # Three new result symbols (handled, sense_value,
        # sense_value_is_nan -- the N2283/N2284 sense wire
        # shape). The ported method is BuildingComp.sense, so
        # the java_source is BuildingComp.java and the slice
        # mirrors into the comp shard (560/464 -> 561/465);
        # defense stays 210/209.
        self.assertEqual(
            ledger['N2511']['source_symbols'],
            [
                'source_building_comp_sense_dead_state_result.handled',
                'source_building_comp_sense_dead_state_result.sense_value',
                'source_building_comp_sense_dead_state_result.sense_value_is_nan',
            ],
        )
        for name in ledger['N2511']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/entities/comp/BuildingComp.java')
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_building_comp_sense_dead_state')
        self.assertEqual(ledger['N2511']['runtime_proof'], '/root/C07BuildingCompSenseDeadProof')
        self.assertEqual(
            ledger['N2511']['tests'],
            [
                'test_c07_building_comp_sense_dead_registration',
                'test_all_c07_building_comp_sense_dead_input_evidence_is_exact',
                'test_building_comp_sense_dead_state',
                'test_reference_graph_and_actual_c07_building_comp_sense_dead',
            ],
        )
        self.assertTrue(ledger['N2511']['deferred_exprs'])

    def test_all_c07_building_comp_sense_dead_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2511']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_building_comp_sense_dead_state')
        slice_sources = {
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/logic/LAccess.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2511']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_building_comp_sense_dead_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # BuildingComp.sense() `dead` leg
        # (BuildingComp.java:2098): `case dead -> !isValid() ?
        # 1 : 0;` -- `isValid()` is `public boolean isValid(){`
        # / `return tile.build == self() && !dead();`
        # (:2030-2032). The pure function computes `is_valid`
        # as the exact `isValid()` body from the two params
        # and returns 0.0 when valid, 1.0 when not valid, with
        # handled true and sense_value_is_nan false always
        # (the N2283/N2284 sense wire shape). There is no
        # driver tick line: the leg is a logic read, not a
        # tick write (the
        # N2206/N2208/N2223/N2283/N2284/N2506/N2507/N2508/N2509/N2510
        # precedent); the proof calls the pure function
        # directly with synthetic inputs.
        self.assertIn(BUILDING_COMP_SENSE_DEAD_SIGNATURE, turret)
        for line in [
            'var is_valid: bool = tile_build_is_self and not is_dead',
            'var dead_value: float = 0.0 if is_valid else 1.0',
            'return {"handled": true, "sense_value": dead_value, "sense_value_is_nan": false}',
        ]:
            with self.subTest(line=line):
                self.assertIn(line, turret)
        for expr in [
            'case dead -> !isValid() ? 1 : 0;',
            'return tile.build == self() && !dead();',
            'public boolean isValid(){',
            'public double sense(LAccess sensor){',
            'default -> Float.NaN; //gets converted to null in logic',
            'dead,',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The pure function sits immediately AFTER
        # source_building_comp_sense_state and BEFORE
        # source_turret_sense_object_state, mirroring the
        # sense()/senseObject() order in BuildingComp.java
        # (:2093 / :2128). It does NOT modify
        # source_building_comp_sense_state: dead stays
        # handled:false in the big dispatch until a later
        # wiring slice connects this leg (same as N2508's
        # Content leg living beside N2284).
        self.assertLess(turret.index('static func source_building_comp_sense_state('), turret.index('static func source_building_comp_sense_dead_state('))
        self.assertLess(turret.index('static func source_building_comp_sense_dead_state('), turret.index('static func source_turret_sense_object_state('))
        # The proof's keys drive the pure function with
        # synthetic inputs (no live tick: the leg is a logic
        # read of the passed-in tile validity): dead when
        # tile.build is not self, dead when is_dead, alive
        # (0.0) when valid, handled true, never NaN, and
        # dead when both inputs are invalid.
        proof = BUILDING_COMP_SENSE_DEAD_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_building_comp_sense_dead(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BuildingCompSenseDeadProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BUILDING_COMP_SENSE_DEAD_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
