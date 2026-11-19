import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_HEAT_REQ_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretHeatReqProof.gd'


class C07TurretHeatReqTests(unittest.TestCase):
    def test_c07_turret_heat_req_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2263']['godot_owner'], 'SourceTurretBuildState.source_turret_heat_req_state')
        # TurretBuild.updateTile() folds the heat requirement
        # every tick, after the logic-control decay and before
        # the rotate sync:
        # `if(heatRequirement > 0){`
        # `heatReq = calculateHeat(sideHeat);`
        # (Turret.java:538-540). `heatRequirement` defaults to
        # -1 (Turret.java:53, `public float heatRequirement =
        # -1f;`) and duo never sets it (Blocks.java:3257-3331),
        # so the guard is false for duo and heatReq stays at
        # its field default 0 (`public float heatReq;`,
        # Turret.java:295). Only afflict (PowerTurret,
        # `heatRequirement = 20f;`, Blocks.java:5122) and
        # malign (PowerTurret, `heatRequirement = 144f;`,
        # Blocks.java:6240) set a positive requirement among
        # turrets. `calculateHeat(sideHeat)` is
        # `public float calculateHeat(float[] sideHeat){`
        # (BuildingComp.java:406) returning
        # `return calculateHeat(sideHeat, null);` (:407), which
        # fills the per-side array (`Arrays.fill(sideHeat, 0f);`,
        # :411) from the live proximity scan of same-team
        # HeatBlock heaters and returns the total heat. That
        # scan is a live entity scan -- BLOCKED, same class as
        # findTarget -- so the scan itself is deferred and this
        # slice captures only the fold: guard + assign of the
        # scan result, which arrives as the pure function's
        # heat_total / side_heat inputs. This slice is the LIVE
        # frame tick on the new duo driver: one pure function on
        # the shared TurretBuild driver file plus one driver
        # tick in the duo branch AFTER the N2261
        # logicControlTime tick (Java order :534-536 decay,
        # :538-540 heatReq, :542-545 rotate sync) and BEFORE
        # the N2262 rotate sync tick and the aim call. Two new
        # result symbols: heat_req and side_heat.
        self.assertEqual(
            ledger['N2263']['source_symbols'],
            [
                'source_turret_heat_req_state_result.heat_req',
                'source_turret_heat_req_state_result.side_heat',
            ],
        )
        for name in ledger['N2263']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_heat_req_state_result.heat_req': 'SourceTurretBuildState.source_turret_heat_req_state',
                    'source_turret_heat_req_state_result.side_heat': 'SourceTurretBuildState.source_turret_heat_req_state',
                }[name])
        self.assertEqual(ledger['N2263']['runtime_proof'], '/root/C07TurretHeatReqProof')
        self.assertEqual(
            ledger['N2263']['tests'],
            [
                'test_c07_turret_heat_req_registration',
                'test_all_c07_turret_heat_req_input_evidence_is_exact',
                'test_turret_heat_req_state',
                'test_reference_graph_and_actual_c07_turret_heat_req',
            ],
        )
        self.assertTrue(ledger['N2263']['deferred_exprs'])

    def test_all_c07_turret_heat_req_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2263']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_heat_req_state_result.heat_req': 'SourceTurretBuildState.source_turret_heat_req_state',
                    'source_turret_heat_req_state_result.side_heat': 'SourceTurretBuildState.source_turret_heat_req_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2263']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_heat_req_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # TurretBuild.updateTile() (Turret.java:490-560) folds
        # the heat requirement every tick:
        # `if(heatRequirement > 0){`
        # `heatReq = calculateHeat(sideHeat);`
        # (:538-540), after the logic-control decay (:534-536)
        # and before the rotate sync (:542-545).
        # `heatRequirement` defaults to -1
        # (`public float heatRequirement = -1f;`, Turret.java:53)
        # and duo never sets it (Blocks.java:3257-3331), so the
        # guard is false for duo and heatReq stays at its field
        # default 0 (`public float heatReq;`, Turret.java:295).
        # Only afflict (PowerTurret, `heatRequirement = 20f;`,
        # Blocks.java:5122) and malign (PowerTurret,
        # `heatRequirement = 144f;`, Blocks.java:6240) set a
        # positive requirement among turrets.
        # `calculateHeat(sideHeat)` is
        # `public float calculateHeat(float[] sideHeat){`
        # (BuildingComp.java:406) returning
        # `return calculateHeat(sideHeat, null);` (:407), which
        # fills the per-side array (`Arrays.fill(sideHeat, 0f);`,
        # :411) from the live proximity scan of same-team
        # HeatBlock heaters and returns the total heat. That
        # scan is a live entity scan -- BLOCKED, same class as
        # findTarget -- so the scan itself is deferred and the
        # pure function takes the scan result (heat_total and
        # the per-side array) as inputs and applies only the
        # guard + assign. The per-side array field is
        # `public float[] sideHeat = new float[4];`
        # (Turret.java:296). The pure function takes the
        # requirement, the scan total, the per-side array and
        # the current heatReq and returns the two keys:
        # `{"heat_req": .., "side_heat": ..}` -- when the
        # requirement is not positive both are returned
        # unchanged, exactly what Java does by skipping the
        # assignment. The driver tick passes the duo catalog
        # requirement -1.0 (never overridden), the deferred
        # scan total 0.0 (never assigned while the guard is
        # off), the frame side_heat (default four zeros, the
        # field default) and the frame heat_req (default 0.0,
        # the field default), then stamps both keys back on the
        # frame.
        self.assertIn('static func source_turret_heat_req_state(heat_requirement: float, heat_total: float, side_heat: Array, heat_req: float) -> Dictionary:', turret)
        self.assertIn('return {"heat_req": heat_req, "side_heat": side_heat}', turret)
        self.assertIn('if(heatRequirement > 0){', turret)
        self.assertIn('heatReq = calculateHeat(sideHeat);', turret)
        self.assertIn('public float heatRequirement = -1f;', turret)
        self.assertIn('public float heatReq;', turret)
        self.assertIn('public float[] sideHeat = new float[4];', turret)
        self.assertIn('public float calculateHeat(float[] sideHeat){', turret)
        self.assertIn('return calculateHeat(sideHeat, null);', turret)
        self.assertIn('Arrays.fill(sideHeat, 0f);', turret)
        self.assertIn('heatRequirement = 20f;', turret)
        self.assertIn('heatRequirement = 144f;', turret)
        # The driver tick lives in the shared TurretBuild driver
        # (SourceTurretBuildState.gd), in the duo branch AFTER
        # the N2261 logicControlTime tick and BEFORE the N2262
        # rotate sync tick (Java order :534-536 decay, :538-540
        # heatReq, :542-545 rotate sync, :595-596 turnToTarget,
        # :601/:609 updateShooting): it passes the duo catalog
        # requirement -1.0, the deferred scan total 0.0, the
        # frame side_heat and the frame heat_req, calls the new
        # pure function, then stamps both keys back on the
        # frame.
        self.assertIn('var heat_req_state: Dictionary = source_turret_heat_req_state(-1.0, 0.0, frame.get("side_heat", [0.0, 0.0, 0.0, 0.0]), float(frame.get("heat_req", 0.0)))', turret)
        self.assertIn('frame["heat_req"] = heat_req_state.get("heat_req", 0.0)', turret)
        self.assertIn('frame["side_heat"] = heat_req_state.get("side_heat", [0.0, 0.0, 0.0, 0.0])', turret)
        # The proof's keys drive the fold through the pure
        # function and the real driver (guard off with -1 keeps
        # the value, the duo live case / guard on with the
        # afflict requirement 20 assigns the scan total / a
        # zero requirement keeps the value, the guard is strict
        # > / the per-side array is stamped when the guard is
        # on / the per-side array is kept when the guard is off
        # / the malign requirement 144 assigns the total / a
        # partial total assigns as-is / both keys are stamped
        # on the frame after the tick / the duo live tick keeps
        # heat_req 0.0 and side_heat four zeros). There is no
        # live proximity scan: calculateHeat's neighbor walk
        # waits for its own slice (live entity scan, BLOCKED).
        proof = TURRET_HEAT_REQ_PROOF.read_text(encoding='utf-8')
        for key in [
            'heat_req_guard_off_keeps_value',
            'heat_req_guard_on_assigns_total',
            'heat_req_zero_requirement_keeps',
            'heat_req_side_heat_stamped',
            'heat_req_side_heat_kept_when_off',
            'heat_req_malign_total',
            'heat_req_partial_total',
            'heat_req_stamped_to_frame',
            'heat_req_duo_live',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_heat_req(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretHeatReqProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_HEAT_REQ_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'heat_req_guard_off_keeps_value',
            'heat_req_guard_on_assigns_total',
            'heat_req_zero_requirement_keeps',
            'heat_req_side_heat_stamped',
            'heat_req_side_heat_kept_when_off',
            'heat_req_malign_total',
            'heat_req_partial_total',
            'heat_req_stamped_to_frame',
            'heat_req_duo_live',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
