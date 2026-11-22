import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_CAN_CONTROL_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretCanControlProof.gd'


class C07TurretCanControlTests(unittest.TestCase):
    def test_c07_turret_can_control_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2530']['godot_owner'], 'SourceTurretBuildState.source_turret_can_control_state')
        # canControl() is the TurretBuild read (Turret.java:376-379):
        # `public boolean canControl(){` /
        # `return playerControllable;`,
        # narrowing the ControlBlock default
        # (ControlBlock.java:15-17):
        # `/** @return whether this block can be controlled at all. */` /
        # `default boolean canControl(){` /
        # `return true;`.
        # `playerControllable` is the block field
        # (`public boolean playerControllable = true;`,
        # Turret.java:97, `/** If true, this turret can be
        # controlled by players. */`). No per-def override in
        # Blocks.java (grep `playerControllable` = 0 results),
        # so the catalog is uniformly true today -- but the
        # function still takes the field as an explicit bool
        # param (the N2526/N2527 param-driven precedent), it
        # never hardcodes the catalog. NOT canControlSelect
        # (BuildingComp.java:677, a different method with a
        # Unit player param, already stubbed as
        # source_building_can_control_select_state) and NOT
        # the Unit-type player_controllable_state. One new
        # result symbol: can_control. The slice mirrors into
        # the defense shard (216/215 -> 217/216); comp stays
        # 572/475.
        self.assertEqual(
            ledger['N2530']['source_symbols'],
            [
                'source_turret_can_control_state_result.can_control',
            ],
        )
        for name in ledger['N2530']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/turrets/Turret.java')
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_can_control_state')
        self.assertEqual(ledger['N2530']['runtime_proof'], '/root/C07TurretCanControlProof')
        self.assertEqual(
            ledger['N2530']['tests'],
            [
                'test_c07_turret_can_control_registration',
                'test_all_c07_turret_can_control_input_evidence_is_exact',
                'test_turret_can_control_state',
                'test_reference_graph_and_actual_c07_turret_can_control',
            ],
        )
        self.assertTrue(ledger['N2530']['deferred_exprs'])

    def test_all_c07_turret_can_control_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2530']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_can_control_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/world/blocks/ControlBlock.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2530']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_can_control_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # canControl() (Turret.java:376-379) for the Turret
        # family as one pure function: `return
        # playerControllable;` -- one bool param, one bool
        # result key `can_control`. The ControlBlock default
        # (ControlBlock.java:15-17) returns true; Turret
        # narrows it to the field. NO driver tick call site
        # (the N2527/N2528 precedent): canControl() is a
        # read predicate, not per-tick, and no caller reads
        # it today (player control / UI is C11).
        self.assertIn('static func source_turret_can_control_state(player_controllable: bool) -> Dictionary:', turret)
        self.assertIn('return {"can_control": player_controllable}', turret)
        self.assertIn('public boolean canControl(){', turret)
        self.assertIn('return playerControllable;', turret)
        self.assertIn('public boolean playerControllable = true;', turret)
        self.assertIn('default boolean canControl(){', turret)
        self.assertIn('/** @return whether this block can be controlled at all. */', turret)
        # The pure function sits immediately AFTER
        # source_turret_estimate_dps_state (N2528) and BEFORE
        # source_turret_can_heal_state.
        self.assertLess(turret.index('static func source_turret_estimate_dps_state('), turret.index('static func source_turret_can_control_state('))
        self.assertLess(turret.index('static func source_turret_can_control_state('), turret.index('static func source_turret_can_heal_state('))
        # NO driver tick call site: canControl() is a read
        # predicate, not per-tick. The tick function must not
        # call the new pure function.
        tick = turret[turret.index('static func source_turret_tick_buildings_state('):]
        self.assertNotIn('source_turret_can_control_state(', tick)
        # The proof's keys drive the pure function on exact
        # legs: 1 true -> true; 2 false -> false; 3 the
        # Turret.java:97 field default true -> true; 4 duo
        # (no Blocks.java override) -> true; 5 the result
        # carries exactly the single `can_control` key; 6
        # the result value is a bool; 7 the ControlBlock
        # default (ControlBlock.java:15-17) is true -- the
        # base the Turret override narrows; 8 the function
        # is param-driven and deterministic (same param,
        # same result, no hidden state).
        proof = TURRET_CAN_CONTROL_PROOF.read_text(encoding='utf-8')
        for key in [
            'can_control_true',
            'can_control_false',
            'can_control_default_true',
            'can_control_duo_true',
            'can_control_single_key',
            'can_control_bool_type',
            'can_control_base_default_true',
            'can_control_param_driven',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_can_control(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretCanControlProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_CAN_CONTROL_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'can_control_true',
            'can_control_false',
            'can_control_default_true',
            'can_control_duo_true',
            'can_control_single_key',
            'can_control_bool_type',
            'can_control_base_default_true',
            'can_control_param_driven',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
