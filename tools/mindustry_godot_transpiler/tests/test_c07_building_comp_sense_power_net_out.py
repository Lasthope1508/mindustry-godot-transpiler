import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
BUILDING_COMP_SENSE_POWER_NET_OUT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BuildingCompSensePowerNetOutProof.gd'

BUILDING_COMP_SENSE_POWER_NET_OUT_SIGNATURE = 'static func source_building_comp_sense_power_net_out_state(power_is_null: bool, last_scaled_power_out: float) -> Dictionary:'
PROOF_KEYS = [
    'power_net_out_null_num',
    'power_net_out_zero_num',
    'power_net_out_some_num',
    'power_net_out_large_num',
    'power_net_out_handled_true',
    'power_net_out_value_not_nan',
]


class C07BuildingCompSensePowerNetOutTests(unittest.TestCase):
    def test_c07_building_comp_sense_power_net_out_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2515']['godot_owner'], 'SourceTurretBuildState.source_building_comp_sense_power_net_out_state')
        # BuildingComp.sense() `powerNetOut` leg is `case
        # powerNetOut -> power == null ? 0 : power.graph.getLastScaledPowerOut() * 60;`
        # (BuildingComp.java:2115), with `power` the
        # building's power module (`@Nullable PowerModule
        # power;`, BuildingComp.java:80) and
        # `power.graph.getLastScaledPowerOut()` the graph's
        # last scaled power-out per tick (`public float
        # getLastScaledPowerOut(){`, PowerGraph.java:49-51 --
        # returns float; updated :234 `lastScaledPowerOut =
        # powerNeeded / Time.delta`). The
        # `* 60` converts the per-tick value to a per-second
        # rate. N2284 ported 23 handled legs of
        # BuildingComp.sense (BuildingComp.java:2093-2126)
        # and left dead/health/totalItems/camera*/powerNet*
        # deferred -- powerNetOut deferred because the live
        # graph values are not stamped in the frame (note
        # inside `source_building_comp_sense_state`,
        # SourceTurretBuildState.gd:404). N2511 ported
        # `dead`, N2512 ported `health`, N2513 ported
        # `totalItems`, N2514 ported `powerNetIn`. This slice
        # ports exactly the
        # `powerNetOut` leg, next in Java switch order after
        # `powerNetIn` (:2114 -> :2115). powerNetStored /
        # powerNetCapacity / camera* stay deferred (separate later slices, in Java switch
        # order).
        # The two params are the live input a future
        # frame-stamp slice will supply (the N2212/N2220
        # per-def-param precedent): `power_is_null` is
        # `power == null` (:2115, first branch of the
        # ternary) and `last_scaled_power_out` is
        # `power.graph.getLastScaledPowerOut()`. `sense_value`
        # is 0.0 when power is null, else
        # `last_scaled_power_out * 60.0` exactly (Java
        # `sense()` returns double; the float widens
        # exactly), no clamping, no rounding. `handled` is
        # true always (this function IS the powerNetOut leg;
        # the sensor is fixed `powerNetOut`, so no `sensor`
        # param) and `sense_value_is_nan` is false always
        # (the leg never yields NaN; the key stays in the
        # wire shape for consistency with
        # N2283/N2284/N2511/N2512/N2513/N2514).
        # Three new result symbols (handled, sense_value,
        # sense_value_is_nan -- the N2283/N2284 sense wire
        # shape). The ported method is BuildingComp.sense, so
        # the java_source is BuildingComp.java and the slice
        # mirrors into the comp shard (564/468 -> 565/469);
        # defense stays 210/209.
        self.assertEqual(
            ledger['N2515']['source_symbols'],
            [
                'source_building_comp_sense_power_net_out_state_result.handled',
                'source_building_comp_sense_power_net_out_state_result.sense_value',
                'source_building_comp_sense_power_net_out_state_result.sense_value_is_nan',
            ],
        )
        for name in ledger['N2515']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/entities/comp/BuildingComp.java')
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_building_comp_sense_power_net_out_state')
        self.assertEqual(ledger['N2515']['runtime_proof'], '/root/C07BuildingCompSensePowerNetOutProof')
        self.assertEqual(
            ledger['N2515']['tests'],
            [
                'test_c07_building_comp_sense_power_net_out_registration',
                'test_all_c07_building_comp_sense_power_net_out_input_evidence_is_exact',
                'test_building_comp_sense_power_net_out_state',
                'test_reference_graph_and_actual_c07_building_comp_sense_power_net_out',
            ],
        )
        self.assertTrue(ledger['N2515']['deferred_exprs'])

    def test_all_c07_building_comp_sense_power_net_out_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2515']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_building_comp_sense_power_net_out_state')
        slice_sources = {
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/power/PowerGraph.java',
            'core/src/mindustry/logic/LAccess.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2515']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_building_comp_sense_power_net_out_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # BuildingComp.sense() `powerNetOut` leg
        # (BuildingComp.java:2115): `case powerNetOut ->
        # power == null ? 0 : power.graph.getLastScaledPowerOut() * 60;`
        # -- `power` is the building's power module
        # (`@Nullable PowerModule power;`,
        # BuildingComp.java:80) and
        # `power.graph.getLastScaledPowerOut()` the graph's
        # last scaled power-out per tick (`public float
        # getLastScaledPowerOut(){`, PowerGraph.java:49-51 --
        # returns float; updated :234 `lastScaledPowerOut =
        # powerNeeded / Time.delta`). The
        # `* 60` converts the per-tick value to a per-second
        # rate. The pure function returns 0.0 when power is
        # null, else `last_scaled_power_out * 60.0` exactly
        # (Java `sense()` returns double; the float widens
        # exactly), no clamping, no rounding, with handled
        # true and sense_value_is_nan false always (the
        # N2283/N2284 sense wire shape). There is no driver
        # tick line: the leg is a logic read, not a tick
        # write (the
        # N2206/N2208/N2223/N2283/N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514
        # precedent); the proof calls the pure function
        # directly with synthetic inputs.
        self.assertIn(BUILDING_COMP_SENSE_POWER_NET_OUT_SIGNATURE, turret)
        for line in [
            'var power_net_out_value: float = 0.0 if power_is_null else last_scaled_power_out * 60.0',
            'return {"handled": true, "sense_value": power_net_out_value, "sense_value_is_nan": false}',
        ]:
            with self.subTest(line=line):
                self.assertIn(line, turret)
        for expr in [
            'case powerNetOut -> power == null ? 0 : power.graph.getLastScaledPowerOut() * 60;',
            'public float getLastScaledPowerOut(){',
            'public double sense(LAccess sensor){',
            'default -> Float.NaN; //gets converted to null in logic',
            'powerNetOut,',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The pure function sits immediately AFTER
        # source_building_comp_sense_power_net_in_state and
        # BEFORE source_turret_sense_object_state, mirroring
        # the sense()/senseObject() order in
        # BuildingComp.java (:2093 / :2128) and, inside
        # sense(), dead :2098 -> health :2101 -> totalItems
        # :2107 -> powerNetIn :2114 -> powerNetOut :2115. It
        # does NOT modify
        # source_building_comp_sense_state: powerNetOut stays
        # handled:false in the big dispatch until a later
        # wiring slice connects this leg (same as N2511's
        # dead leg, N2512's health leg, N2513's totalItems
        # leg and N2514's powerNetIn leg living beside
        # N2284).
        self.assertLess(turret.index('static func source_building_comp_sense_power_net_in_state('), turret.index('static func source_building_comp_sense_power_net_out_state('))
        self.assertLess(turret.index('static func source_building_comp_sense_power_net_out_state('), turret.index('static func source_turret_sense_object_state('))
        # The proof's keys drive the pure function with
        # synthetic inputs (no live tick: the leg is a logic
        # read of the passed-in live graph value): null power
        # reads 0.0, zero out (0.0) reads 0.0, some out (2.5)
        # reads 150.0 (the * 60 per-second rate), large out
        # (10.0) reads 600.0 exactly, handled true, never
        # NaN.
        proof = BUILDING_COMP_SENSE_POWER_NET_OUT_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_building_comp_sense_power_net_out(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BuildingCompSensePowerNetOutProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BUILDING_COMP_SENSE_POWER_NET_OUT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
