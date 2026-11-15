import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FORCE_PROJECTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceForceProjectorBuildState.gd'
FORCE_PROJECTOR_COOLANT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ForceProjectorCoolantProof.gd'
FORCE_PROJECTOR_COOLANT_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ForceProjectorCoolantProof.tscn'

ROW_OWNER = 'SourceForceProjectorBuildState.source_force_projector_coolant_consumer_row_state'
ADVANCE_OWNER = 'SourceForceProjectorBuildState.source_force_projector_update_tile_advance_state'
SYMBOLS = [
    'source_force_projector_coolant_consumer_row_state_result.row',
    'source_force_projector_coolant_consumer_row_state_result.has_coolant_row',
    'source_force_projector_coolant_consumer_row_state_result.consumed_liquid',
    'source_force_projector_update_tile_advance_state_result.coolant_consumed_liquid',
    'source_force_projector_update_tile_advance_state_result.coolant_consumed_amount',
]
JAVA_SOURCES = {
    'source_force_projector_coolant_consumer_row_state_result.row': 'core/src/mindustry/world/consumers/ConsumeLiquidFilter.java',
    'source_force_projector_coolant_consumer_row_state_result.has_coolant_row': 'core/src/mindustry/entities/comp/BuildingComp.java',
    'source_force_projector_coolant_consumer_row_state_result.consumed_liquid': 'core/src/mindustry/world/consumers/ConsumeLiquidFilter.java',
    'source_force_projector_update_tile_advance_state_result.coolant_consumed_liquid': 'core/src/mindustry/world/blocks/defense/ForceProjector.java',
    'source_force_projector_update_tile_advance_state_result.coolant_consumed_amount': 'core/src/mindustry/world/consumers/ConsumeLiquidFilter.java',
}
GODOT_OWNERS = {
    'source_force_projector_coolant_consumer_row_state_result.row': ROW_OWNER,
    'source_force_projector_coolant_consumer_row_state_result.has_coolant_row': ROW_OWNER,
    'source_force_projector_coolant_consumer_row_state_result.consumed_liquid': ROW_OWNER,
    'source_force_projector_update_tile_advance_state_result.coolant_consumed_liquid': ADVANCE_OWNER,
    'source_force_projector_update_tile_advance_state_result.coolant_consumed_amount': ADVANCE_OWNER,
}
PROOF_KEYS = [
    'coolant_row_folds_optional_when_present',
    'filter_rejects_non_coolant',
    'get_consumed_prefers_current_liquid',
    'buildup_scale_uses_current_heat_capacity',
    'live_tick_consumes_coolant_only_when_buildup',
    'no_coolant_no_scale',
]


class C07ForceProjectorCoolantTests(unittest.TestCase):
    def test_c07_force_projector_coolant_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2258']['godot_owner'], ROW_OWNER)
        # N2158 proved the force-projector's live power read and
        # N2235 its updateTile advance -- but the coolant branch
        # of the advance ran on no-op defaults: the constructor
        # adds a ConsumeCoolant consumer (ForceProjector.java:85,
        # `consume(coolantConsumer = new ConsumeCoolant(
        # coolantConsumption)).boost().update(false);`, amount
        # 0.1f per frame, ForceProjector.java:43), and a force
        # projector with a full coolant store cooled its buildup
        # at the plain rate. N2258 is the ConsumeCoolant row:
        # the pure row mirrors ConsumeLiquidFilter.efficiency
        # (ConsumeLiquidFilter.java:50-55, `float ed = build.
        # edelta();` -- NOTE no efficiencyScale factor, unlike
        # ConsumeLiquid) with the getConsumed preference
        # (ConsumeLiquidFilter.java:63-76, current liquid first,
        # then content order) and the ConsumeCoolant filter
        # (ConsumeCoolant.java:12, coolant + non-gas + temp <=
        # 0.5 + flammability < 0.1 -- only water and cryofluid
        # pass with the Liquid defaults + catalog overrides),
        # folded by the shared machinery into the OPTIONAL pass
        # (BuildingComp.java:1979-1981); update(false) keeps it
        # out of the second pass, so Java consumes by hand in
        # updateTile (ForceProjector.java:227-231, inside
        # `if(buildup > 0){`, with the efficiency re-evaluated
        # at the folded value and the scale from the CURRENT
        # liquid's heatCapacity, ForceProjector.java:230). The
        # advance reports the consumption through two new pure
        # results (the N2226 heal_amount pattern) and the
        # driver applies the removal to the live liquids store.
        # Five new result symbols: the row, its presence flag,
        # the consumed liquid, and the advance's two
        # consumption results.
        self.assertEqual(ledger['N2258']['source_symbols'], SYMBOLS)
        for name in ledger['N2258']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], JAVA_SOURCES[name])
                self.assertEqual(symbol['godot_owner'], GODOT_OWNERS[name])
        self.assertEqual(ledger['N2258']['runtime_proof'], '/root/C07ForceProjectorCoolantProof')
        self.assertEqual(
            ledger['N2258']['tests'],
            [
                'test_c07_force_projector_coolant_registration',
                'test_all_c07_force_projector_coolant_input_evidence_is_exact',
                'test_force_projector_coolant_consumer_row_state',
                'test_reference_graph_and_actual_c07_force_projector_coolant',
            ],
        )
        self.assertTrue(ledger['N2258']['deferred_exprs'])
        # This slice resolves the ForceProjector coolant rows
        # deferral, so that entry is gone from DEFERRED; nothing
        # new defers. DEFERRED goes 293 - 1 = 292 entries. (The
        # live-fill entry keeps its coolant wording until the
        # coordinator trims it at integration.)
        self.assertEqual(len(ledger['N2258']['deferred_exprs']), 292)
        self.assertFalse(any(entry.startswith('ForceProjector coolant rows (') for entry in ledger['N2258']['deferred_exprs']))

    def test_all_c07_force_projector_coolant_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2258']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], GODOT_OWNERS[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumeCoolant.java',
            'core/src/mindustry/world/consumers/ConsumeLiquidFilter.java',
            'core/src/mindustry/world/consumers/Consume.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/defense/ForceProjector.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/content/Liquids.java',
            'core/src/mindustry/type/Liquid.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2258']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_force_projector_coolant_consumer_row_state(self):
        force_projector = FORCE_PROJECTOR_STATE.read_text(encoding='utf-8')
        # The pure coolant row mirrors
        # ConsumeLiquidFilter.efficiency
        # (ConsumeLiquidFilter.java:50-55): ed is edelta() with
        # NO efficiencyScale factor (unlike ConsumeLiquid,
        # ConsumeLiquid.java:42-47), ed <= 1e-8 returns 0,
        # otherwise the held amount of the getConsumed liquid
        # over the per-frame demand, capped at 1 -- and 0 when
        # getConsumed is null. In the first pass efficiency is
        # assumed 1f (BuildingComp.java:1965), so edelta is
        # delta() = source_delta * time_scale
        # (BuildingComp.java:1922-1929); the driver re-evaluates
        # with the folded efficiency for the updateTile check
        # (ForceProjector.java:228).
        self.assertIn('static func source_force_projector_coolant_consumer_row_state', force_projector)
        self.assertIn('static func source_force_projector_coolant_filter_state', force_projector)
        self.assertIn('float ed = build.edelta();', force_projector)
        self.assertIn('if(ed <= 0.00000001f) return 0f;', force_projector)
        self.assertIn('return liq != null ? Math.min(build.liquids.get(liq) / (amount * ed * multiplier.get(build)), 1f) : 0f;', force_projector)
        self.assertIn('float ed = build.edelta() * build.efficiencyScale();', force_projector)
        self.assertIn('build.liquids.remove(liq, amount * build.edelta() * multiplier.get(build));', force_projector)
        self.assertIn('public Floatf<Building> multiplier = b -> 1f;', force_projector)
        self.assertIn('efficiency = optionalEfficiency = 1f;', force_projector)
        # The filter is ConsumeCoolant's (ConsumeCoolant.java:12)
        # with the Liquid class defaults for props the catalog
        # does not carry (coolant true, gas false, temp 0.5,
        # flammability 0): only water and cryofluid pass.
        self.assertIn('this.filter = liquid -> liquid.coolant && (this.allowLiquid && !liquid.gas || this.allowGas && liquid.gas) && liquid.temperature <= maxTemp && liquid.flammability < maxFlammability;', force_projector)
        self.assertIn('public float maxTemp = 0.5f, maxFlammability = 0.1f;', force_projector)
        self.assertIn('public boolean allowLiquid = true, allowGas = false;', force_projector)
        self.assertIn('public boolean coolant = true;', force_projector)
        self.assertIn('public boolean gas = false;', force_projector)
        self.assertIn('public float temperature = 0.5f;', force_projector)
        self.assertIn('public float flammability;', force_projector)
        # getConsumed prefers the current liquid, then the first
        # liquid in content order that passes the filter and has
        # amount > 0 (ConsumeLiquidFilter.java:63-76).
        self.assertIn('if(filter.get(build.liquids.current()) && build.liquids.currentAmount() > 0){', force_projector)
        self.assertIn('if(filter.get(liq) && build.liquids.get(liq) > 0){', force_projector)
        self.assertIn('var liqs = content.liquids();', force_projector)
        # The row is OPTIONAL (.boost(), Consume.java:33-35) and
        # folds into the optional pass (BuildingComp.java:
        # 1979-1981), not the min efficiency; update(false)
        # keeps it out of the second pass (BuildingComp.java:
        # 1999-2000), so Java consumes by hand in updateTile
        # (ForceProjector.java:227-231) inside `if(buildup > 0){`
        # with the scale from the CURRENT liquid's heatCapacity
        # (ForceProjector.java:230). The amount is the 0.1f
        # class default (ForceProjector.java:43), per frame.
        self.assertIn('"is_power": false', force_projector)
        self.assertIn('for(var cons : block.optionalConsumers){', force_projector)
        self.assertIn('optionalEfficiency = Math.min(optionalEfficiency, cons.efficiency(self()));', force_projector)
        self.assertIn('return optional(true, true);', force_projector)
        self.assertIn('if(buildup > 0){', force_projector)
        self.assertIn('if(coolantConsumer.efficiency(this) > 0){', force_projector)
        self.assertIn('coolantConsumer.update(this);', force_projector)
        self.assertIn('scale *= (cooldownLiquid * (1f + (liquids.current().heatCapacity - 0.4f) * 0.9f));', force_projector)
        self.assertIn('public float coolantConsumption = 0.1f;', force_projector)
        self.assertIn('SOURCE_FORCE_PROJECTOR_COOLANT_CONSUMPTION := 0.1', force_projector)
        self.assertIn('{"has_coolant_row": false, "row": {}, "consumed_liquid": null}', force_projector)
        # The heatCapacity of the CURRENT liquid reads from the
        # catalog props with the Liquid class default 0.5f
        # (Liquid.java:42) -- NOT the 0.4f no-op fallback, which
        # the driver passes only when there is no coolant at all.
        self.assertIn('public float heatCapacity = 0.5f;', force_projector)
        self.assertIn('SOURCE_FORCE_PROJECTOR_COOLANT_HEAT_CAPACITY_FALLBACK := 0.4', force_projector)
        # The held amount reads through the shared liquid module
        # helper over the frame liquids key, with the Fracker
        # guard; the tick syncs the live sprite store into the
        # frame BEFORE the fold (Fracker:361), and the removal
        # after the advance goes through the same helper (the
        # N2226 heal_amount pattern: the advance reports the
        # pure consumption, the driver applies it).
        self.assertIn('source_liquid_module_state.source_get_state', force_projector)
        self.assertIn('frame["liquids"] = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})', force_projector)
        self.assertIn('source_liquid_module_state.source_remove_state', force_projector)
        self.assertIn('"liquids": {}', force_projector)
        self.assertIn('required_results, optional_results, [], frame', force_projector)
        self.assertIn('frame["coolant_efficiency"]', force_projector)
        self.assertIn('frame["coolant_heat_capacity"]', force_projector)
        self.assertIn('"coolant_consumed_liquid": coolant_consumed_liquid', force_projector)
        self.assertIn('"coolant_consumed_amount": coolant_consumed_amount', force_projector)
        # The documented limits now record the coolant row as
        # live and the phaseFabric booster item row as still
        # deferred, with optionalEfficiency incomplete until it
        # lands (Java mins over BOTH optional rows).
        self.assertIn('coolant row live (N2258)', force_projector)
        self.assertIn('phaseFabric booster item row', force_projector)
        # The proof's keys drive the pure row (optional fold /
        # filter rejects / getConsumed preference) plus the
        # advance scale (current heatCapacity, no coolant no
        # scale) plus the live tick (removal only when buildup).
        proof = FORCE_PROJECTOR_COOLANT_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads must point at files that exist
        # (the N2185 lesson: an unrun proof scene fails
        # silently on a bad preload).
        for line in proof.splitlines():
            if 'preload("res://' in line:
                res_path = line.split('preload("res://', 1)[1].split('"', 1)[0]
                with self.subTest(preload=res_path):
                    self.assertTrue((ROOT / 'godot-mindustry' / res_path).is_file(), res_path)
        scene = FORCE_PROJECTOR_COOLANT_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07ForceProjectorCoolantProof.gd', scene)

    def test_reference_graph_and_actual_c07_force_projector_coolant(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ForceProjectorCoolantProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_FORCE_PROJECTOR_COOLANT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
