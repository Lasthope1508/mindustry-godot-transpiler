import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
BUILDING_COMP_SENSE_TOTAL_ITEMS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BuildingCompSenseTotalItemsProof.gd'

BUILDING_COMP_SENSE_TOTAL_ITEMS_SIGNATURE = 'static func source_building_comp_sense_total_items_state(items_is_null: bool, items_total: int) -> Dictionary:'
PROOF_KEYS = [
    'total_items_null_num',
    'total_items_empty_num',
    'total_items_some_num',
    'total_items_large_num',
    'total_items_handled_true',
    'total_items_value_not_nan',
]


class C07BuildingCompSenseTotalItemsTests(unittest.TestCase):
    def test_c07_building_comp_sense_total_items_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2513']['godot_owner'], 'SourceTurretBuildState.source_building_comp_sense_total_items_state')
        # BuildingComp.sense() `totalItems` leg is `case
        # totalItems -> items == null ? 0 : items.total();`
        # (BuildingComp.java:2107), with `items` the
        # building's item module (`@Nullable ItemModule
        # items;`, BuildingComp.java:81) and `items.total()`
        # its total item count (`public int total(){`,
        # ItemModule.java:174 -- returns int). N2284 ported
        # 23 handled legs of BuildingComp.sense
        # (BuildingComp.java:2093-2126) and left
        # dead/health/totalItems/camera*/powerNet*
        # deferred -- totalItems deferred because the live
        # inventory total is not stamped in the frame (note
        # inside `source_building_comp_sense_state`,
        # SourceTurretBuildState.gd:404). N2511 ported
        # `dead`, N2512 ported `health`. This slice ports
        # exactly the `totalItems` leg, next in Java switch
        # order after `health` (:2101 -> :2107).
        # The two params are the live input a future
        # frame-stamp slice will supply (the N2212/N2220
        # per-def-param precedent): `items_is_null` is
        # `items == null` (:2107, first branch of the
        # ternary) and `items_total` is `items.total()`.
        # `sense_value` is 0.0 when items is null, else
        # `float(items_total)` exactly (Java `sense()`
        # returns double; the int widens exactly), no
        # clamping, no rounding. `handled` is true always
        # (this function IS the totalItems leg; the sensor
        # is fixed `totalItems`, so no `sensor` param) and
        # `sense_value_is_nan` is false always (the leg
        # never yields NaN; the key stays in the wire shape
        # for consistency with N2283/N2284/N2511/N2512).
        # Three new result symbols (handled, sense_value,
        # sense_value_is_nan -- the N2283/N2284 sense wire
        # shape). The ported method is BuildingComp.sense, so
        # the java_source is BuildingComp.java and the slice
        # mirrors into the comp shard (562/466 -> 563/467);
        # defense stays 210/209.
        self.assertEqual(
            ledger['N2513']['source_symbols'],
            [
                'source_building_comp_sense_total_items_state_result.handled',
                'source_building_comp_sense_total_items_state_result.sense_value',
                'source_building_comp_sense_total_items_state_result.sense_value_is_nan',
            ],
        )
        for name in ledger['N2513']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/entities/comp/BuildingComp.java')
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_building_comp_sense_total_items_state')
        self.assertEqual(ledger['N2513']['runtime_proof'], '/root/C07BuildingCompSenseTotalItemsProof')
        self.assertEqual(
            ledger['N2513']['tests'],
            [
                'test_c07_building_comp_sense_total_items_registration',
                'test_all_c07_building_comp_sense_total_items_input_evidence_is_exact',
                'test_building_comp_sense_total_items_state',
                'test_reference_graph_and_actual_c07_building_comp_sense_total_items',
            ],
        )
        self.assertTrue(ledger['N2513']['deferred_exprs'])

    def test_all_c07_building_comp_sense_total_items_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2513']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_building_comp_sense_total_items_state')
        slice_sources = {
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/modules/ItemModule.java',
            'core/src/mindustry/logic/LAccess.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2513']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_building_comp_sense_total_items_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # BuildingComp.sense() `totalItems` leg
        # (BuildingComp.java:2107): `case totalItems ->
        # items == null ? 0 : items.total();` -- `items` is
        # the building's item module (`@Nullable ItemModule
        # items;`, BuildingComp.java:81) and `items.total()`
        # its total item count (`public int total(){`,
        # ItemModule.java:174 -- returns int). The pure
        # function returns 0.0 when items is null, else
        # `float(items_total)` exactly (Java `sense()`
        # returns double; the int widens exactly), no
        # clamping, no rounding, with handled true and
        # sense_value_is_nan false always (the N2283/N2284
        # sense wire shape). There is no driver tick line:
        # the leg is a logic read, not a tick write (the
        # N2206/N2208/N2223/N2283/N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512
        # precedent); the proof calls the pure function
        # directly with synthetic inputs.
        self.assertIn(BUILDING_COMP_SENSE_TOTAL_ITEMS_SIGNATURE, turret)
        for line in [
            'var total_items_value: float = 0.0 if items_is_null else float(items_total)',
            'return {"handled": true, "sense_value": total_items_value, "sense_value_is_nan": false}',
        ]:
            with self.subTest(line=line):
                self.assertIn(line, turret)
        for expr in [
            'case totalItems -> items == null ? 0 : items.total();',
            'public int total(){',
            'public double sense(LAccess sensor){',
            'default -> Float.NaN; //gets converted to null in logic',
            'totalItems,',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The pure function sits immediately AFTER
        # source_building_comp_sense_health_state and BEFORE
        # source_turret_sense_object_state, mirroring the
        # sense()/senseObject() order in BuildingComp.java
        # (:2093 / :2128) and, inside sense(), dead :2098 ->
        # health :2101 -> totalItems :2107. It does NOT modify
        # source_building_comp_sense_state: totalItems stays
        # handled:false in the big dispatch until a later
        # wiring slice connects this leg (same as N2511's
        # dead leg and N2512's health leg living beside
        # N2284).
        self.assertLess(turret.index('static func source_building_comp_sense_health_state('), turret.index('static func source_building_comp_sense_total_items_state('))
        self.assertLess(turret.index('static func source_building_comp_sense_total_items_state('), turret.index('static func source_turret_sense_object_state('))
        # The proof's keys drive the pure function with
        # synthetic inputs (no live tick: the leg is a logic
        # read of the passed-in live inventory total): null
        # items reads 0.0, empty items (total 0) reads 0.0,
        # some items (25) reads 25.0, large total (1000)
        # reads 1000.0 exactly, handled true, never NaN.
        proof = BUILDING_COMP_SENSE_TOTAL_ITEMS_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_building_comp_sense_total_items(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BuildingCompSenseTotalItemsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BUILDING_COMP_SENSE_TOTAL_ITEMS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
