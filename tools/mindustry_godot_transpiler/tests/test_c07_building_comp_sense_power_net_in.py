import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
BUILDING_COMP_SENSE_POWER_NET_IN_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BuildingCompSensePowerNetInProof.gd'

BUILDING_COMP_SENSE_POWER_NET_IN_SIGNATURE = 'static func source_building_comp_sense_power_net_in_state(power_is_null: bool, last_scaled_power_in: float) -> Dictionary:'
PROOF_KEYS = [
    'power_net_in_null_num',
    'power_net_in_zero_num',
    'power_net_in_some_num',
    'power_net_in_large_num',
    'power_net_in_handled_true',
    'power_net_in_value_not_nan',
]


class C07BuildingCompSensePowerNetInTests(unittest.TestCase):
    def test_c07_building_comp_sense_power_net_in_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2514']['godot_owner'], 'SourceTurretBuildState.source_building_comp_sense_power_net_in_state')
        # BuildingComp.sense() `powerNetIn` leg is `case
        # powerNetIn -> power == null ? 0 : power.graph.getLastScaledPowerIn() * 60;`
        # (BuildingComp.java:2114), with `power` the
        # building's power module (`@Nullable PowerModule
        # power;`, BuildingComp.java:80) and
        # `power.graph.getLastScaledPowerIn()` the graph's
        # last scaled power-in per tick (`public float
        # getLastScaledPowerIn(){`, PowerGraph.java:45-47 --
        # returns float; updated :233 `lastScaledPowerIn =
        # (powerProduced + energyDelta) / Time.delta`). The
        # `* 60` converts the per-tick value to a per-second
        # rate. N2284 ported 23 handled legs of
        # BuildingComp.sense (BuildingComp.java:2093-2126)
        # and left dead/health/totalItems/camera*/powerNet*
        # deferred -- powerNetIn deferred because the live
        # graph values are not stamped in the frame (note
        # inside `source_building_comp_sense_state`,
        # SourceTurretBuildState.gd:404). N2511 ported
        # `dead`, N2512 ported `health`, N2513 ported
        # `totalItems`. This slice ports exactly the
        # `powerNetIn` leg, next in Java switch order after
        # `totalItems` (:2107 -> :2114). powerNetOut /
        # powerNetStored / powerNetCapacity / camera* stay
        # deferred (separate later slices, in Java switch
        # order).
        # The two params are the live input a future
        # frame-stamp slice will supply (the N2212/N2220
        # per-def-param precedent): `power_is_null` is
        # `power == null` (:2114, first branch of the
        # ternary) and `last_scaled_power_in` is
        # `power.graph.getLastScaledPowerIn()`. `sense_value`
        # is 0.0 when power is null, else
        # `last_scaled_power_in * 60.0` exactly (Java
        # `sense()` returns double; the float widens
        # exactly), no clamping, no rounding. `handled` is
        # true always (this function IS the powerNetIn leg;
        # the sensor is fixed `powerNetIn`, so no `sensor`
        # param) and `sense_value_is_nan` is false always
        # (the leg never yields NaN; the key stays in the
        # wire shape for consistency with
        # N2283/N2284/N2511/N2512/N2513).
        # Three new result symbols (handled, sense_value,
        # sense_value_is_nan -- the N2283/N2284 sense wire
        # shape). The ported method is BuildingComp.sense, so
        # the java_source is BuildingComp.java and the slice
        # mirrors into the comp shard (563/467 -> 564/468);
        # defense stays 210/209.
        self.assertEqual(
            ledger['N2514']['source_symbols'],
            [
                'source_building_comp_sense_power_net_in_state_result.handled',
                'source_building_comp_sense_power_net_in_state_result.sense_value',
                'source_building_comp_sense_power_net_in_state_result.sense_value_is_nan',
            ],
        )
        for name in ledger['N2514']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/entities/comp/BuildingComp.java')
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_building_comp_sense_power_net_in_state')
        self.assertEqual(ledger['N2514']['runtime_proof'], '/root/C07BuildingCompSensePowerNetInProof')
        self.assertEqual(
            ledger['N2514']['tests'],
            [
                'test_c07_building_comp_sense_power_net_in_registration',
                'test_all_c07_building_comp_sense_power_net_in_input_evidence_is_exact',
                'test_building_comp_sense_power_net_in_state',
                'test_reference_graph_and_actual_c07_building_comp_sense_power_net_in',
            ],
        )
        self.assertTrue(ledger['N2514']['deferred_exprs'])

    def test_all_c07_building_comp_sense_power_net_in_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2514']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_building_comp_sense_power_net_in_state')
        slice_sources = {
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/power/PowerGraph.java',
            'core/src/mindustry/logic/LAccess.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2514']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_building_comp_sense_power_net_in_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # BuildingComp.sense() `powerNetIn` leg
        # (BuildingComp.java:2114): `case powerNetIn ->
        # power == null ? 0 : power.graph.getLastScaledPowerIn() * 60;`
        # -- `power` is the building's power module
        # (`@Nullable PowerModule power;`,
        # BuildingComp.java:80) and
        # `power.graph.getLastScaledPowerIn()` the graph's
        # last scaled power-in per tick (`public float
        # getLastScaledPowerIn(){`, PowerGraph.java:45-47 --
        # returns float; updated :233 `lastScaledPowerIn =
        # (powerProduced + energyDelta) / Time.delta`). The
        # `* 60` converts the per-tick value to a per-second
        # rate. The pure function returns 0.0 when power is
        # null, else `last_scaled_power_in * 60.0` exactly
        # (Java `sense()` returns double; the float widens
        # exactly), no clamping, no rounding, with handled
        # true and sense_value_is_nan false always (the
        # N2283/N2284 sense wire shape). There is no driver
        # tick line: the leg is a logic read, not a tick
        # write (the
        # N2206/N2208/N2223/N2283/N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513
        # precedent); the proof calls the pure function
        # directly with synthetic inputs.
        self.assertIn(BUILDING_COMP_SENSE_POWER_NET_IN_SIGNATURE, turret)
        for line in [
            'var power_net_in_value: float = 0.0 if power_is_null else last_scaled_power_in * 60.0',
            'return {"handled": true, "sense_value": power_net_in_value, "sense_value_is_nan": false}',
        ]:
            with self.subTest(line=line):
                self.assertIn(line, turret)
        for expr in [
            'case powerNetIn -> power == null ? 0 : power.graph.getLastScaledPowerIn() * 60;',
            'public float getLastScaledPowerIn(){',
            'public double sense(LAccess sensor){',
            'default -> Float.NaN; //gets converted to null in logic',
            'powerNetIn,',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The pure function sits immediately AFTER
        # source_building_comp_sense_total_items_state and
        # BEFORE source_turret_sense_object_state, mirroring
        # the sense()/senseObject() order in
        # BuildingComp.java (:2093 / :2128) and, inside
        # sense(), dead :2098 -> health :2101 -> totalItems
        # :2107 -> powerNetIn :2114. It does NOT modify
        # source_building_comp_sense_state: powerNetIn stays
        # handled:false in the big dispatch until a later
        # wiring slice connects this leg (same as N2511's
        # dead leg, N2512's health leg and N2513's
        # totalItems leg living beside N2284).
        self.assertLess(turret.index('static func source_building_comp_sense_total_items_state('), turret.index('static func source_building_comp_sense_power_net_in_state('))
        self.assertLess(turret.index('static func source_building_comp_sense_power_net_in_state('), turret.index('static func source_turret_sense_object_state('))
        # The proof's keys drive the pure function with
        # synthetic inputs (no live tick: the leg is a logic
        # read of the passed-in live graph value): null power
        # reads 0.0, zero in (0.0) reads 0.0, some in (2.5)
        # reads 150.0 (the * 60 per-second rate), large in
        # (10.0) reads 600.0 exactly, handled true, never
        # NaN.
        proof = BUILDING_COMP_SENSE_POWER_NET_IN_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_building_comp_sense_power_net_in(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BuildingCompSensePowerNetInProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BUILDING_COMP_SENSE_POWER_NET_IN_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
