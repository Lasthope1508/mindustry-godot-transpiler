import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
MEND_PROJECTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceMendProjectorBuildState.gd'
MEND_PROJECTOR_BOOSTER_ITEMS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MendProjectorBoosterItemsProof.gd'
MEND_PROJECTOR_BOOSTER_ITEMS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MendProjectorBoosterItemsProof.tscn'


class C07MendProjectorBoosterItemsTests(unittest.TestCase):
    def test_c07_mend_projector_booster_items_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2263']['godot_owner'], 'SourceMendProjectorBuildState.source_mend_projector_item_consumer_row_state')
        # N2156 proved the MendProjector family's live power read,
        # N2193 the updateTile advance (smoothEfficiency / heat /
        # charge / phaseHeat) and N2242 the pure heal scan -- but
        # the folded optionalEfficiency was still the power min
        # always: the booster item rows, mender silicon
        # (`consumeItem(Items.silicon).boost();`, Blocks.java:
        # 1929) and mend-projector phaseFabric
        # (`consumeItem(Items.phaseFabric).boost();`, Blocks.java:
        # 1941), were never folded, so a mend projector with no
        # booster items healed as if fully boosted and phaseHeat
        # lerped toward the wrong target. N2263 is the optional
        # ConsumeItems row: the pure item row mirrors
        # ConsumeItems.efficiency (ConsumeItems.java:51-53,
        # `return build.consumeTriggerValid() || build.items.
        # has(items, multiplier.get(build)) ? 1f : 0f;`) -- BINARY
        # 1/0, not a ratio -- and folds into the OPTIONAL pass
        # (BuildingComp.java:1980-1981), capped by minEfficiency
        # (BuildingComp.java:1986). The multiplier is the Consume
        # default 1f (Consume.java:18, `public Floatf<Building>
        # multiplier = b -> 1f;`) -- neither def sets one -- and
        # consumeTriggerValid is the base false (BuildingComp.
        # java:764-766), so the row is 1.0 exactly when every
        # stack is held (ItemModule.java:153-156, `has` is every
        # stack `get(item) >= round(amount * multiplier)`).
        # phaseHeat already lerps toward the folded
        # optionalEfficiency (MendProjector.java:100,
        # `phaseHeat = Mathf.lerpDelta(phaseHeat,
        # optionalEfficiency, 0.1f);`); this slice only supplies
        # the real optionalEfficiency. The timer-gated consume()
        # (MendProjector.java:102-104, useTime 400f) stays
        # deferred -- no removal in this slice. Two new result
        # symbols: the row and its presence flag.
        self.assertEqual(
            ledger['N2263']['source_symbols'],
            [
                'source_mend_projector_item_consumer_row_state_result.row',
                'source_mend_projector_item_consumer_row_state_result.has_item_row',
            ],
        )
        for name in ledger['N2263']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumeItems.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_mend_projector_item_consumer_row_state_result.row': 'SourceMendProjectorBuildState.source_mend_projector_item_consumer_row_state',
                    'source_mend_projector_item_consumer_row_state_result.has_item_row': 'SourceMendProjectorBuildState.source_mend_projector_item_consumer_row_state',
                }[name])
        self.assertEqual(ledger['N2263']['runtime_proof'], '/root/C07MendProjectorBoosterItemsProof')
        self.assertEqual(
            ledger['N2263']['tests'],
            [
                'test_c07_mend_projector_booster_items_registration',
                'test_all_c07_mend_projector_booster_items_input_evidence_is_exact',
                'test_mend_projector_booster_items_row_state',
                'test_reference_graph_and_actual_c07_mend_projector_booster_items',
            ],
        )
        self.assertTrue(ledger['N2263']['deferred_exprs'])

    def test_all_c07_mend_projector_booster_items_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2263']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_mend_projector_item_consumer_row_state_result.row': 'SourceMendProjectorBuildState.source_mend_projector_item_consumer_row_state',
                    'source_mend_projector_item_consumer_row_state_result.has_item_row': 'SourceMendProjectorBuildState.source_mend_projector_item_consumer_row_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumeItems.java',
            'core/src/mindustry/world/consumers/Consume.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/modules/ItemModule.java',
            'core/src/mindustry/world/blocks/defense/MendProjector.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2263']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_mend_projector_booster_items_row_state(self):
        mend_projector = MEND_PROJECTOR_STATE.read_text(encoding='utf-8')
        # The pure item row lives on the mend-projector build
        # state: ConsumeItems.efficiency (ConsumeItems.java:
        # 51-53) over the frame items store, counted through the
        # shared drill inventory helper (SourceDrillInventory
        # RuntimeState.item_count, the Separator precedent) --
        # BINARY 1.0/0.0, not a ratio like ConsumeLiquid. The
        # trigger-valid half is the base false (BuildingComp.
        # java:764-766), so the row is 1.0 exactly when every
        # stack is held (ItemModule.java:153-156, each stack
        # `get(item) >= round(amount * multiplier)`); the
        # multiplier is the Consume default 1f (Consume.java:18)
        # and consumeItem(item) is a single stack of 1
        # (Block.java:1167-1168). The row is NOT power
        # (`"is_power": false`) and folds into the OPTIONAL pass
        # (BuildingComp.java:1980-1981), capped by minEfficiency
        # (BuildingComp.java:1986), so a starved booster row
        # lowers optionalEfficiency -- and phaseHeat with it
        # (MendProjector.java:100) -- never the min efficiency.
        # The timer-gated consume() (MendProjector.java:102-104,
        # useTime 400f) stays deferred: no removal in this slice,
        # and ConsumeItems has no update() to run in the second
        # pass, so consumption only ever happens through that
        # timer-gated consume() call.
        self.assertIn('static func source_mend_projector_item_consumer_row_state', mend_projector)
        self.assertIn('static func _mend_projector_booster_stacks_for_block', mend_projector)
        self.assertIn('return build.consumeTriggerValid() || build.items.has(items, multiplier.get(build)) ? 1f : 0f;', mend_projector)
        self.assertIn('public boolean consumeTriggerValid(){', mend_projector)
        self.assertIn('if(stack.item.id >= items.length || !has(stack.item, Math.round(stack.amount * multiplier))) return false;', mend_projector)
        self.assertIn('return get(item) >= amount;', mend_projector)
        self.assertIn('return optional(true, true);', mend_projector)
        self.assertIn('public Floatf<Building> multiplier = b -> 1f;', mend_projector)
        self.assertIn('public ConsumeItems consumeItem(Item item){', mend_projector)
        self.assertIn('return consumeItem(item, 1);', mend_projector)
        self.assertIn('for(var cons : block.optionalConsumers){', mend_projector)
        self.assertIn('optionalEfficiency = Math.min(optionalEfficiency, cons.efficiency(self()));', mend_projector)
        self.assertIn('optionalEfficiency = Math.min(optionalEfficiency, minEfficiency);', mend_projector)
        self.assertIn('efficiency = minEfficiency;', mend_projector)
        self.assertIn('efficiency = optionalEfficiency = 0f;', mend_projector)
        self.assertIn('consumeItem(Items.silicon).boost();', mend_projector)
        self.assertIn('consumeItem(Items.phaseFabric).boost();', mend_projector)
        self.assertIn('phaseHeat = Mathf.lerpDelta(phaseHeat, optionalEfficiency, 0.1f);', mend_projector)
        self.assertIn('if(optionalEfficiency > 0 && timer(timerUse, useTime / timeScale) && canHeal){', mend_projector)
        self.assertIn('public float useTime = 400f;', mend_projector)
        self.assertIn('other.heal(other.maxHealth() * (healPercent + phaseHeat * phaseBoost) / 100f * efficiency);', mend_projector)
        self.assertIn('build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));', mend_projector)
        # The row shape mirrors the power row (is_power false
        # here); the per-def stacks come from the block id
        # (mender silicon, mend-projector phase-fabric, the
        # Separator per-def helper precedent); the tick folds
        # the row into optional_results, the second array of
        # update_consumption_state; the frame carries the
        # Building.items ItemModule (frame["items"], the factory
        # precedent SourceFactoryBuildState.gd:89-101) with no
        # live intake filling it yet (the Separator precedent).
        self.assertIn('"is_power": false', mend_projector)
        self.assertIn('optional_results', mend_projector)
        self.assertIn('block_id == "mender"', mend_projector)
        self.assertIn('block_id == "mend-projector"', mend_projector)
        self.assertIn('"silicon"', mend_projector)
        self.assertIn('"phase-fabric"', mend_projector)
        self.assertIn('"items": {}', mend_projector)
        self.assertIn('item_count', mend_projector)
        self.assertIn('static func source_mend_projector_tick_buildings_state', mend_projector)
        # The proof's keys drive the pure row (binary per def)
        # plus the fold (optional-only, capped by the min, live
        # tick) and the phaseHeat lerp toward the folded
        # optionalEfficiency. There is no consume/removal key:
        # the timer-gated consume() stays deferred. The scene
        # file exists and the proof preloads scripts that exist.
        proof = MEND_PROJECTOR_BOOSTER_ITEMS_PROOF.read_text(encoding='utf-8')
        for key in [
            'mender_row_binary_silicon',
            'mend_projector_row_binary_phase_fabric',
            'booster_row_folds_optional_only',
            'optional_capped_by_min_efficiency',
            'phase_heat_lerps_toward_optional',
            'live_tick_folds_booster_row',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertTrue(MEND_PROJECTOR_BOOSTER_ITEMS_PROOF_SCENE.exists())
        self.assertIn('SourceMendProjectorBuildState.gd', proof)

    def test_reference_graph_and_actual_c07_mend_projector_booster_items(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07MendProjectorBoosterItemsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_MEND_PROJECTOR_BOOSTER_ITEMS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'mender_row_binary_silicon',
            'mend_projector_row_binary_phase_fabric',
            'booster_row_folds_optional_only',
            'optional_capped_by_min_efficiency',
            'phase_heat_lerps_toward_optional',
            'live_tick_folds_booster_row',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
