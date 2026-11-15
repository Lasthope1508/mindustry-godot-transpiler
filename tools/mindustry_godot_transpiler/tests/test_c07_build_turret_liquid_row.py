import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BUILD_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildTurretBuildState.gd'
BUILD_TURRET_LIQUID_ROW_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BuildTurretLiquidRowProof.gd'
BUILD_TURRET_LIQUID_ROW_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BuildTurretLiquidRowProof.tscn'
CONTENT_REGISTRY = ROOT / 'godot-mindustry/src/generated/MindustryContentRegistry.gd'


class C07BuildTurretLiquidRowTests(unittest.TestCase):
    def test_c07_build_turret_liquid_row_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2251']['godot_owner'], 'SourceBuildTurretBuildState.source_build_turret_liquid_consumer_row_state')
        # N2184 folded the power row only: the build tower also
        # consumes nitrogen (consumeLiquid nitrogen 3f/60f,
        # Blocks.java:2006), so the folded efficiency was the
        # min over the modeled consumers (power only) while Java
        # folds the liquid row too (ConsumeLiquid.efficiency,
        # ConsumeLiquid.java:42-47). N2251 adds the pure liquid
        # row (source_build_turret_liquid_consumer_row_state),
        # folds it into the first pass next to the power row,
        # and removes amount * edelta * multiplier on the
        # second pass (ConsumeLiquid.update,
        # ConsumeLiquid.java:37-39, only when update &&
        # efficiency > 0, BuildingComp.java:1999-2003) with the
        # edelta from the FOLDED efficiency. Two new result
        # symbols, in the N2184 power-row order: row first,
        # then has_liquid_row.
        self.assertEqual(
            ledger['N2251']['source_symbols'],
            [
                'source_build_turret_liquid_consumer_row_state_result.row',
                'source_build_turret_liquid_consumer_row_state_result.has_liquid_row',
            ],
        )
        self.assertEqual(symbols['source_build_turret_liquid_consumer_row_state_result.row']['java_source'], 'core/src/mindustry/world/consumers/ConsumeLiquid.java')
        self.assertEqual(symbols['source_build_turret_liquid_consumer_row_state_result.has_liquid_row']['java_source'], 'core/src/mindustry/entities/comp/BuildingComp.java')
        for name in ledger['N2251']['source_symbols']:
            with self.subTest(symbol=name):
                self.assertEqual(symbols[name]['godot_owner'], 'SourceBuildTurretBuildState.source_build_turret_liquid_consumer_row_state')
        self.assertEqual(ledger['N2251']['runtime_proof'], '/root/C07BuildTurretLiquidRowProof')
        self.assertEqual(
            ledger['N2251']['tests'],
            [
                'test_c07_build_turret_liquid_row_registration',
                'test_all_c07_build_turret_liquid_row_input_evidence_is_exact',
                'test_build_turret_liquid_consumer_row_state',
                'test_reference_graph_and_actual_c07_build_turret_liquid_row',
            ],
        )
        self.assertTrue(ledger['N2251']['deferred_exprs'])
        # This slice resolves the BuildTurret liquid consumer
        # row deferral, so that entry is gone from DEFERRED --
        # while a new live-nitrogen-intake entry carries the
        # deferred liquid delivery (no live intake fills the
        # frame liquids store yet, so a live tower with no
        # intake reads 0 nitrogen and folds efficiency 0).
        self.assertFalse(any(entry.startswith('BuildTurret liquid consumer row (') for entry in ledger['N2251']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BuildTurret live nitrogen intake (') for entry in ledger['N2251']['deferred_exprs']))

    def test_all_c07_build_turret_liquid_row_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2251']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBuildTurretBuildState.source_build_turret_liquid_consumer_row_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/BuildTurret.java',
            'core/src/mindustry/world/consumers/ConsumeLiquid.java',
            'core/src/mindustry/world/consumers/Consume.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/modules/LiquidModule.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2251']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_build_turret_liquid_consumer_row_state(self):
        build_turret = BUILD_TURRET_STATE.read_text(encoding='utf-8')
        # The pure liquid row lives on the build-turret build
        # state: ConsumeLiquid.efficiency
        # (ConsumeLiquid.java:42-47, `float ed = build.edelta()
        # * build.efficiencyScale();` / `if(ed <= 0.00000001f)
        # return 0f;` / `//there can be more liquid than
        # necessary, so cap at 1` / `return Math.min(build.
        # liquids.get(liquid) / (amount * ed * multiplier.
        # get(build)), 1f);`). In the first pass efficiency is
        # assumed 1f (`//assume efficiency is 1 for the
        # calculations below`, BuildingComp.java:1964), so
        # edelta is source_delta * time_scale (delta() is
        # `return Time.delta * timeScale;`,
        # BuildingComp.java:1923; edelta() is `return
        # efficiency * delta();`, BuildingComp.java:1928).
        # The liquid amount reads through the shared liquid
        # module helper (SourceLiquidModuleState.
        # source_get_state) with the Fracker guard (the store
        # has a "liquids" key and the id is in bounds), so a
        # missing store reads 0.0 like Java's liquids.get
        # (`return liquids[liquid.id];`,
        # LiquidModule.java:103). The multiplier defaults to
        # 1f (`public Floatf<Building> multiplier = b -> 1f;`,
        # Consume.java:18) and the build-tower def sets none
        # (`consumeLiquid(Liquids.nitrogen, 3f / 60f);`,
        # Blocks.java:2006 -- a plain call, no multiplier).
        # The row shape mirrors the power row: {"has_liquid_row":
        # bool, "row": {"result": float, "is_power": false}} --
        # the fold sets shouldConsumePower=false when a
        # non-power row reads <= 1e-7 (BuildingComp.java:1972,
        # `if(cons != block.consPower && result <= 0.0000001f){`
        # / `shouldConsumePower = false;`).
        self.assertIn('static func source_build_turret_liquid_consumer_row_state', build_turret)
        self.assertIn('source_liquid_module_state.source_get_state(liquids, liquid_id)', build_turret)
        self.assertIn('var edelta: float = source_delta * time_scale', build_turret)
        self.assertIn('var ed: float = edelta * efficiency_scale', build_turret)
        self.assertIn('if ed <= 0.00000001:', build_turret)
        self.assertIn('minf(liquid_amount / (amount * ed * multiplier), 1.0)', build_turret)
        self.assertIn('"has_liquid_row": false', build_turret)
        self.assertIn('"has_liquid_row": true', build_turret)
        self.assertIn('"is_power": false', build_turret)
        self.assertIn('multiplier: float = 1.0', build_turret)
        self.assertIn('float ed = build.edelta() * build.efficiencyScale();', build_turret)
        self.assertIn('if(ed <= 0.00000001f) return 0f;', build_turret)
        self.assertIn('return Math.min(build.liquids.get(liquid) / (amount * ed * multiplier.get(build)), 1f);', build_turret)
        self.assertIn('public Floatf<Building> multiplier = b -> 1f;', build_turret)
        self.assertIn('consumeLiquid(Liquids.nitrogen, 3f / 60f);', build_turret)
        # The def constants: nitrogen, 3f/60f per frame.
        self.assertIn('const SOURCE_BUILD_TURRET_LIQUID := "nitrogen"', build_turret)
        self.assertIn('const SOURCE_BUILD_TURRET_LIQUID_AMOUNT := 3.0 / 60.0', build_turret)
        # The frame gains the liquids key (the Building.liquids
        # LiquidModule dict, default {}).
        self.assertIn('"liquids": {}', build_turret)
        # The driver syncs the live sprite-meta liquids store
        # into the frame BEFORE the fold (the Fracker:327
        # precedent), resolves the nitrogen id from the liquid
        # catalog, folds the liquid row into required_results
        # next to the power row, and removes amount * edelta *
        # multiplier after apply_update_consumption_state --
        # direct removal, because the AdjacentFactory
        # updates-array precedent runs RuntimeConsumer actors
        # with an update() method and this driver has no
        # actors. The removal edelta comes from the FOLDED
        # efficiency (not the first-pass 1f), and only runs
        # when update && efficiency > 0 (BuildingComp.java:
        # 1999-2003). source_remove_state caps at the held
        # amount (LiquidModule.java:126-127, `//cap to prevent
        # negative removal`).
        self.assertIn('frame["liquids"] = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})', build_turret)
        self.assertIn('var liquid_id_by_name: Dictionary = source_content_registry_runtime_state.source_liquid_catalog_state(catalog).get("liquid_id_by_name", {})', build_turret)
        self.assertIn('var has_liquid_consumer: bool = bool(block.properties.has("consumeLiquid"))', build_turret)
        self.assertIn('var nitrogen_id: int = int(liquid_id_by_name.get(SOURCE_BUILD_TURRET_LIQUID, -1))', build_turret)
        self.assertIn('source_build_turret_liquid_consumer_row_state(frame, has_liquid_consumer, nitrogen_id, SOURCE_BUILD_TURRET_LIQUID_AMOUNT, source_delta, time_scale, float(frame.get("efficiency_scale", 1.0)))', build_turret)
        self.assertIn('required_results.append(liquid_row.get("row", {}))', build_turret)
        self.assertIn('var folded_edelta: float = float(frame.get("efficiency", 0.0)) * source_delta * time_scale', build_turret)
        self.assertIn('source_liquid_module_state.source_remove_state(liquids_store, nitrogen_id, SOURCE_BUILD_TURRET_LIQUID_AMOUNT * folded_edelta, cache_sums)', build_turret)
        self.assertIn('build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));', build_turret)
        self.assertIn('if(update && efficiency > 0){', build_turret)
        # The power-row documented limits now say the liquid
        # row is live (N2251) instead of waiting for its own
        # slice.
        self.assertIn('liquid row live (N2251)', build_turret)
        self.assertIn('Liquid row live (N2251)', build_turret)
        # The N2184 power row, the N2215 gate, and the N2243 /
        # N2244 advances are preserved.
        self.assertIn('static func source_build_turret_power_status_row_state', build_turret)
        self.assertIn('static func source_build_turret_should_consume_state', build_turret)
        self.assertIn('static func source_build_turret_update_tile_advance_state', build_turret)
        self.assertIn('static func source_build_turret_plan_logic_state', build_turret)
        self.assertIn('shouldConsume gate live (N2215)', build_turret)
        # The catalog carries the build-tower liquid consumer:
        # nitrogen 0.05 per frame (3f/60f).
        registry = CONTENT_REGISTRY.read_text(encoding='utf-8')
        self.assertIn('"consumeLiquid": [{"amount": 0.05, "liquid": "nitrogen"}]', registry)
        # The proof's keys drive the pure row and the live
        # tick: the row folds below 1 when starved, caps at 1
        # when full, zeroes when edelta is 0, zeroes without
        # liquid, the live tick folds the liquid row into the
        # efficiency, and the live tick removes liquid when
        # running. Static checks: the proof preloads the
        # build-turret state file that exists, and the scene
        # file references the proof script that exists.
        proof = BUILD_TURRET_LIQUID_ROW_PROOF.read_text(encoding='utf-8')
        for key in [
            'row_folds_below_one_when_starved',
            'row_caps_at_one_when_full',
            'row_zeroes_when_edelta_zero',
            'row_zeroes_without_liquid',
            'live_tick_folds_liquid_row',
            'live_tick_removes_liquid_when_running',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceBuildTurretBuildState.gd")', proof)
        self.assertIn('build_turret_build_state.source_build_turret_liquid_consumer_row_state(', proof)
        self.assertTrue(BUILD_TURRET_STATE.is_file())
        scene = BUILD_TURRET_LIQUID_ROW_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07BuildTurretLiquidRowProof.gd', scene)
        self.assertTrue(BUILD_TURRET_LIQUID_ROW_PROOF.is_file())

    def test_reference_graph_and_actual_c07_build_turret_liquid_row(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BuildTurretLiquidRowProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BUILD_TURRET_LIQUID_ROW_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'row_folds_below_one_when_starved',
            'row_caps_at_one_when_full',
            'row_zeroes_when_edelta_zero',
            'row_zeroes_without_liquid',
            'live_tick_folds_liquid_row',
            'live_tick_removes_liquid_when_running',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
