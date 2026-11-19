import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
EXTRACTOR = ROOT / 'tools/mindustry_godot_transpiler/mindustry_port/content_registry.py'
REGISTRY_JSON = ROOT / 'godot-mindustry/src/generated/content_registry.json'
TURRET_POWER_HEAT_FOLD_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretPowerHeatFoldProof.gd'


class C07TurretPowerHeatFoldTests(unittest.TestCase):
    def test_c07_turret_power_heat_fold_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2270']['godot_owner'], 'SourceTurretBuildState.source_turret_heat_requirement_state')
        # N2265 added the pure fold function
        # (source_turret_efficiency_multiplier_state,
        # Turret.java:674-679) plus one driver tick in the duo
        # branch with the class defaults (-1.0 / 3.0, guard off)
        # -- but the fold never ran for the two defs that
        # actually need it: afflict and malign are PowerTurrets
        # whose consumption branch is the generic power-consumer
        # branch of source_turret_tick_buildings_state, and the
        # catalog never captured their per-block heatRequirement
        # / maxHeatEfficiency overrides, so the driver had no
        # values to fold with. The fold itself
        # (Turret.java:675-677):
        # `if(heatRequirement > 0){`
        # `efficiency *= Math.min(Math.max(heatReq / heatRequirement, cheating() ? 1f : 0f), maxHeatEfficiency);`
        # runs inside updateEfficiencyMultiplier(), which
        # updateConsumption() calls (BuildingComp.java:1949
        # cheating path / :1996 normal path) BEFORE updateTile()
        # (:2274-2278), so it reads the PREVIOUS tick's heatReq.
        # Only afflict (PowerTurret, `heatRequirement = 20f;`,
        # Blocks.java:5122) and malign (PowerTurret,
        # `heatRequirement = 144f;`, Blocks.java:6240) set a
        # positive requirement among turrets -- and both override
        # the cap: `maxHeatEfficiency = 1f;` (Blocks.java:5123 /
        # :6241), NOT the class default 3f (Turret.java:55). A
        # full-heat afflict folds to 1.0x, never 3.0x -- the
        # N2265 proof's cap-3.0 keys used the class default, not
        # the defs' own cap. This slice is the N2143
        # catalog-capture pattern applied to the turret fold:
        # (1) the emitter captures heatRequirement /
        # maxHeatEfficiency for Turret-family blocks from the
        # block initializer's own assignment (the `range` /
        # `reload` pattern -- only afflict and malign carry them
        # among turrets); (2) one pure read on the block,
        # source_turret_heat_requirement_state(block), returns
        # {heat_requirement, max_heat_efficiency} -- the catalog
        # values when present, the class defaults -1.0 / 3.0
        # (Turret.java:53 `public float heatRequirement = -1f;`,
        # :55 `public float maxHeatEfficiency = 3f;`) otherwise,
        # null-safe; (3) one driver tick in the generic
        # power-consumer consumption branch, right after
        # apply_update_consumption_state stamps the first-pass
        # efficiency, applies the existing fold with the read
        # values and stamps frame["efficiency"] -- Java order
        # (updateConsumption with the fold, then updateTile) and
        # the previous-tick heatReq read are preserved. The live
        # calculateHeat proximity scan still waits for its own
        # slice (live entity scan, BLOCKED, N2263), so
        # frame["heat_req"] stays at its field default 0.0 and a
        # non-cheating afflict / malign with no heat folds to 0
        # -- the faithful no-heater behavior. TurretBuild.
        # canConsume()'s heat gate (Turret.java:623-628,
        # `if(heatRequirement > 0 && heatReq <= 0f) return
        # false;`) waits for its own slice: the driver still has
        # no shouldConsume gate. Two new result symbols:
        # heat_requirement, max_heat_efficiency.
        self.assertEqual(
            ledger['N2270']['source_symbols'],
            [
                'source_turret_heat_requirement_state_result.heat_requirement',
                'source_turret_heat_requirement_state_result.max_heat_efficiency',
            ],
        )
        for name in ledger['N2270']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                    'core/src/mindustry/content/Blocks.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_heat_requirement_state_result.heat_requirement': 'SourceTurretBuildState.source_turret_heat_requirement_state',
                    'source_turret_heat_requirement_state_result.max_heat_efficiency': 'SourceTurretBuildState.source_turret_heat_requirement_state',
                }[name])
        self.assertEqual(ledger['N2270']['runtime_proof'], '/root/C07TurretPowerHeatFoldProof')
        self.assertEqual(
            ledger['N2270']['tests'],
            [
                'test_c07_turret_power_heat_fold_registration',
                'test_all_c07_turret_power_heat_fold_input_evidence_is_exact',
                'test_turret_power_heat_fold_state',
                'test_reference_graph_and_actual_c07_turret_power_heat_fold',
            ],
        )
        self.assertTrue(ledger['N2270']['deferred_exprs'])

    def test_all_c07_turret_power_heat_fold_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2270']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_heat_requirement_state_result.heat_requirement': 'SourceTurretBuildState.source_turret_heat_requirement_state',
                    'source_turret_heat_requirement_state_result.max_heat_efficiency': 'SourceTurretBuildState.source_turret_heat_requirement_state',
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
        for expr in ledger['N2270']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_power_heat_fold_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        extractor = EXTRACTOR.read_text(encoding='utf-8')
        # The pure read lives on the shared TurretBuild driver
        # file (SourceTurretBuildState.gd), after
        # source_turret_queued_bullets_state and before the tick
        # driver, following the N2143 has_upgrade /
        # plan-requirements pattern (block: Object, null-safe):
        # the class defaults (Turret.java:53 `public float
        # heatRequirement = -1f;`, :55 `public float
        # maxHeatEfficiency = 3f;`) when the catalog carries no
        # override, the per-block values otherwise -- afflict
        # 20.0 / 1.0 (Blocks.java:5122-5123,
        # `heatRequirement = 20f;` / `maxHeatEfficiency = 1f;`)
        # and malign 144.0 / 1.0 (Blocks.java:6240-6241,
        # `heatRequirement = 144f;` / `maxHeatEfficiency = 1f;`).
        # Only afflict and malign set a positive requirement
        # among turrets, so every other turret reads the class
        # defaults and the fold guard (`if(heatRequirement >
        # 0){`, Turret.java:675) stays off. The driver feeds the
        # read values into the N2265 fold
        # (`efficiency *= Math.min(Math.max(heatReq /
        # heatRequirement, cheating() ? 1f : 0f),
        # maxHeatEfficiency);`, Turret.java:676). The function
        # returns the two keys `{"heat_requirement": ..,
        # "max_heat_efficiency": ..}`.
        self.assertIn('static func source_turret_heat_requirement_state(block: Object) -> Dictionary:', turret)
        self.assertIn('return {"heat_requirement": heat_requirement, "max_heat_efficiency": max_heat_efficiency}', turret)
        self.assertIn('public float heatRequirement = -1f;', turret)
        self.assertIn('public float maxHeatEfficiency = 3f;', turret)
        self.assertIn('heatRequirement = 20f;', turret)
        self.assertIn('maxHeatEfficiency = 1f;', turret)
        self.assertIn('heatRequirement = 144f;', turret)
        # The extractor captures heatRequirement /
        # maxHeatEfficiency for blocks from the block
        # initializer's own assignment (the `range` / `reload`
        # pattern, N2143): the two keys join the numeric capture
        # list in _block_properties.
        self.assertIn('"heatRequirement"', extractor)
        self.assertIn('"maxHeatEfficiency"', extractor)
        # The regenerated catalog carries the real values, so
        # the driver no longer falls back to -1.0 / 3.0 for
        # either def.
        registry = json.loads(REGISTRY_JSON.read_text(encoding='utf-8'))
        by_id = {block['id']: block for block in registry['blocks']}
        self.assertEqual(by_id['afflict']['properties'].get('heatRequirement'), 20.0)
        self.assertEqual(by_id['afflict']['properties'].get('maxHeatEfficiency'), 1.0)
        self.assertEqual(by_id['malign']['properties'].get('heatRequirement'), 144.0)
        self.assertEqual(by_id['malign']['properties'].get('maxHeatEfficiency'), 1.0)
        # The driver tick lives in the generic power-consumer
        # consumption branch of
        # source_turret_tick_buildings_state, right after
        # apply_update_consumption_state stamps the first-pass
        # efficiency: it reads the per-block requirement / cap
        # from the block, applies the existing N2265 fold with
        # those values (previous tick's frame heat_req, default
        # 0.0; frame cheating flag), then stamps efficiency back
        # on the frame -- Java order (updateConsumption with the
        # fold, then updateTile).
        self.assertIn('var heat_requirement_state: Dictionary = source_turret_heat_requirement_state(block)', turret)
        self.assertIn('var power_heat_fold: Dictionary = source_turret_efficiency_multiplier_state(float(frame.get("efficiency", 1.0)), float(heat_requirement_state.get("heat_requirement", -1.0)), float(frame.get("heat_req", 0.0)), bool(frame.get("cheating", false)), float(heat_requirement_state.get("max_heat_efficiency", 3.0)))', turret)
        self.assertIn('frame["efficiency"] = power_heat_fold.get("efficiency", 1.0)', turret)
        # The proof's keys drive the catalog values (both defs),
        # the read's default + catalog paths, the fold with the
        # defs' own cap 1.0 (never the class default 3.0), and
        # the live afflict tick (no heat -> folds to 0).
        proof = TURRET_POWER_HEAT_FOLD_PROOF.read_text(encoding='utf-8')
        for key in [
            'catalog_afflict_20_1',
            'catalog_malign_144_1',
            'read_default_neg1_3',
            'read_afflict_20_1',
            'read_malign_144_1',
            'fold_afflict_full_heat_1',
            'fold_afflict_half_heat',
            'fold_malign_full_heat_1',
            'fold_malign_partial',
            'fold_afflict_no_heat_zero',
            'fold_afflict_cheating_floor_one',
            'fold_afflict_live',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_power_heat_fold(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretPowerHeatFoldProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_POWER_HEAT_FOLD_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'catalog_afflict_20_1',
            'catalog_malign_144_1',
            'read_default_neg1_3',
            'read_afflict_20_1',
            'read_malign_144_1',
            'fold_afflict_full_heat_1',
            'fold_afflict_half_heat',
            'fold_malign_full_heat_1',
            'fold_malign_partial',
            'fold_afflict_no_heat_zero',
            'fold_afflict_cheating_floor_one',
            'fold_afflict_live',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
