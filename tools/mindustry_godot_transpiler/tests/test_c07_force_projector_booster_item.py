import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FORCE_PROJECTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceForceProjectorBuildState.gd'
FORCE_PROJECTOR_BOOSTER_ITEM_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ForceProjectorBoosterItemProof.gd'
FORCE_PROJECTOR_BOOSTER_ITEM_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ForceProjectorBoosterItemProof.tscn'

ROW_OWNER = 'SourceForceProjectorBuildState.source_force_projector_item_consumer_row_state'
SYMBOLS = [
    'source_force_projector_item_consumer_row_state_result.row',
    'source_force_projector_item_consumer_row_state_result.has_item_row',
    'source_force_projector_item_consumer_row_state_result.item_valid',
]
JAVA_SOURCES = {
    'source_force_projector_item_consumer_row_state_result.row': 'core/src/mindustry/world/consumers/ConsumeItems.java',
    'source_force_projector_item_consumer_row_state_result.has_item_row': 'core/src/mindustry/entities/comp/BuildingComp.java',
    'source_force_projector_item_consumer_row_state_result.item_valid': 'core/src/mindustry/world/blocks/defense/ForceProjector.java',
}
GODOT_OWNERS = {
    'source_force_projector_item_consumer_row_state_result.row': ROW_OWNER,
    'source_force_projector_item_consumer_row_state_result.has_item_row': ROW_OWNER,
    'source_force_projector_item_consumer_row_state_result.item_valid': ROW_OWNER,
}
PROOF_KEYS = [
    'item_row_binary_one_when_present',
    'item_row_zero_when_absent',
    'optional_folds_min_of_coolant_and_item',
    'phase_valid_follows_item_row',
    'phase_heat_lerps_toward_phase_valid',
    'live_tick_folds_item_row',
]


class C07ForceProjectorBoosterItemTests(unittest.TestCase):
    def test_c07_force_projector_booster_item_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2261']['godot_owner'], ROW_OWNER)
        # N2158 proved the force-projector's live power read,
        # N2235 its updateTile advance and N2258 its coolant
        # row -- but the advance's phaseValid ran on no-op
        # item defaults: the def sets a phaseFabric booster
        # item consumer (Blocks.java:1974, `itemConsumer =
        # consumeItem(Items.phaseFabric).boost();`) and
        # phaseValid reads it directly (ForceProjector.java:207,
        # `boolean phaseValid = itemConsumer != null &&
        # itemConsumer.efficiency(this) > 0;`), so a force
        # projector holding phaseFabric never heated its phase.
        # N2261 is the ConsumeItems row: the pure row mirrors
        # ConsumeItems.efficiency (ConsumeItems.java:51-53,
        # `return build.consumeTriggerValid() ||
        # build.items.has(items, multiplier.get(build)) ? 1f :
        # 0f;` -- BINARY 1/0, not a ratio like ConsumeLiquid;
        # consumeTriggerValid() base returns false,
        # BuildingComp.java:764-766, and no ForceProjector
        # override exists, so the row is 1.0 only when the
        # frame holds every stack: items.has(ItemStack[],
        # float), ItemModule.java:153-158, requires EVERY stack
        # to hold round(amount * multiplier)), folded by the
        # shared machinery into the OPTIONAL pass
        # (BuildingComp.java:1980-1981, capped by
        # minEfficiency, BuildingComp.java:1986) beside the
        # coolant row -- optionalEfficiency is COMPLETE now --
        # and wired live into the advance through the frame
        # (item_consumer_present / item_consumer_efficiency,
        # the N2258 coolant precedent; the N2235 call shape is
        # unchanged). The timer-gated consume()
        # (ForceProjector.java:211-213, phaseUseTime 350f)
        # still defers, so the driver keeps passing
        # consume_tick false and this slice removes nothing.
        # Three new result symbols: the row, its presence flag,
        # and the item_valid the advance reads.
        self.assertEqual(ledger['N2261']['source_symbols'], SYMBOLS)
        for name in ledger['N2261']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], JAVA_SOURCES[name])
                self.assertEqual(symbol['godot_owner'], GODOT_OWNERS[name])
        self.assertEqual(ledger['N2261']['runtime_proof'], '/root/C07ForceProjectorBoosterItemProof')
        self.assertEqual(
            ledger['N2261']['tests'],
            [
                'test_c07_force_projector_booster_item_registration',
                'test_all_c07_force_projector_booster_item_input_evidence_is_exact',
                'test_force_projector_item_consumer_row_state',
                'test_reference_graph_and_actual_c07_force_projector_booster_item',
            ],
        )
        self.assertTrue(ledger['N2261']['deferred_exprs'])
        # This slice resolves the ForceProjector booster item
        # row deferral and adds one new deferral (the live
        # items intake: no live intake fills frame["items"]
        # yet), so DEFERRED goes 293 - 1 + 1 = 293 entries.
        self.assertEqual(len(ledger['N2261']['deferred_exprs']), 293)
        self.assertFalse(any(entry.startswith('ForceProjector booster item row (') for entry in ledger['N2261']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ForceProjector live items intake (') for entry in ledger['N2261']['deferred_exprs']))

    def test_all_c07_force_projector_booster_item_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2261']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], GODOT_OWNERS[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumeItems.java',
            'core/src/mindustry/world/consumers/Consume.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/defense/ForceProjector.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/modules/ItemModule.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2261']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_force_projector_item_consumer_row_state(self):
        force_projector = FORCE_PROJECTOR_STATE.read_text(encoding='utf-8')
        # The pure item row mirrors ConsumeItems.efficiency
        # (ConsumeItems.java:51-53): BINARY 1/0 -- 1.0 only when
        # the frame holds every stack (items.has(ItemStack[],
        # float), ItemModule.java:153-158, round(amount *
        # multiplier) per stack; has(item, amount) =
        # get(item) >= amount, ItemModule.java:126-128), 0.0
        # otherwise. consumeTriggerValid() base returns false
        # (BuildingComp.java:764-766) and no ForceProjector
        # override exists, so the trigger half never fires.
        # The count reads through the shared drill inventory
        # helper over the frame items key.
        self.assertIn('static func source_force_projector_item_consumer_row_state', force_projector)
        self.assertIn('return build.consumeTriggerValid() || build.items.has(items, multiplier.get(build)) ? 1f : 0f;', force_projector)
        self.assertIn('public boolean consumeTriggerValid(){', force_projector)
        self.assertIn('if(stack.item.id >= items.length || !has(stack.item, Math.round(stack.amount * multiplier))) return false;', force_projector)
        self.assertIn('return get(item) >= amount;', force_projector)
        self.assertIn('source_drill_inventory_runtime_state.item_count', force_projector)
        self.assertIn('{"has_item_row": false, "row": {}, "item_valid": false}', force_projector)
        # The single stack is 1 phaseFabric: consumeItem(item)
        # is ItemStack(item, 1) (Block.java:1167-1168) and the
        # def sets it (Blocks.java:1974). The multiplier is the
        # 1f default (Consume.java:18); the def sets none.
        self.assertIn('itemConsumer = consumeItem(Items.phaseFabric).boost();', force_projector)
        self.assertIn('public ConsumeItems consumeItem(Item item){', force_projector)
        self.assertIn('return consumeItem(item, 1);', force_projector)
        self.assertIn('public Floatf<Building> multiplier = b -> 1f;', force_projector)
        self.assertIn('[{"item": "phase-fabric", "amount": 1}]', force_projector)
        # The row is OPTIONAL (.boost(), Consume.java:33-35)
        # and folds into the optional pass (BuildingComp.java:
        # 1980-1981), capped by minEfficiency
        # (BuildingComp.java:1986) -- never the min efficiency,
        # never shouldConsumePower (BuildingComp.java:1972-1973
        # runs only over nonOptionalConsumers). The tick
        # appends it to the optional_results array the coolant
        # row already uses (N2258), and the frame seeds an
        # empty items dict (the Separator precedent).
        self.assertIn('"is_power": false', force_projector)
        self.assertIn('for(var cons : block.optionalConsumers){', force_projector)
        self.assertIn('optionalEfficiency = Math.min(optionalEfficiency, cons.efficiency(self()));', force_projector)
        self.assertIn('optionalEfficiency = Math.min(optionalEfficiency, minEfficiency);', force_projector)
        self.assertIn('return optional(true, true);', force_projector)
        self.assertIn('if bool(item_row.get("has_item_row", false)):', force_projector)
        self.assertIn('optional_results.append(item_row.get("row", {}))', force_projector)
        self.assertIn('required_results, optional_results, [], frame', force_projector)
        self.assertIn('"items": {}', force_projector)
        # phaseValid reads the row DIRECTLY
        # (ForceProjector.java:207), not through
        # optionalEfficiency, so the row reports item_valid
        # and the driver stamps the item inputs onto the frame
        # (the N2258 coolant precedent -- the N2235 call shape
        # is unchanged, the N2235 sibling test pins it); the
        # advance prefers frame values when present, falling
        # back to the explicit params. The timer-gated
        # consume() (ForceProjector.java:211-213, phaseUseTime
        # 350f, ForceProjector.java:32) still defers, so the
        # driver keeps passing consume_tick false.
        self.assertIn('boolean phaseValid = itemConsumer != null && itemConsumer.efficiency(this) > 0;', force_projector)
        self.assertIn('phaseHeat = Mathf.lerpDelta(phaseHeat, Mathf.num(phaseValid), 0.1f);', force_projector)
        self.assertIn('if(phaseValid && !broken && timer(timerUse, phaseUseTime / timeScale) && efficiency > 0){', force_projector)
        self.assertIn('public float phaseUseTime = 350f;', force_projector)
        self.assertIn('build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));', force_projector)
        self.assertIn('frame["item_consumer_present"]', force_projector)
        self.assertIn('frame["item_consumer_efficiency"]', force_projector)
        self.assertIn('frame.get("item_consumer_present", item_consumer_present)', force_projector)
        self.assertIn('frame.get("item_consumer_efficiency", item_consumer_efficiency)', force_projector)
        self.assertIn('source_force_projector_update_tile_advance_state(frame, source_delta, time_scale, advance_building_x, advance_building_y, [], false)', force_projector)
        # The documented limits now record the phaseFabric row
        # as live and optionalEfficiency as complete (min over
        # coolant + item), with the live intake + the timer
        # consume still deferred.
        self.assertIn('phaseFabric booster item row live (N2261)', force_projector)
        self.assertIn('optionalEfficiency is now COMPLETE', force_projector)
        # The proof's keys drive the pure row (binary 1 when
        # present / 0 when absent) plus the optional fold (min
        # of coolant and item) plus the advance (phaseValid
        # follows the row, phaseHeat lerps toward it) plus the
        # live tick (the fold + the phaseHeat follow the live
        # fabric row).
        proof = FORCE_PROJECTOR_BOOSTER_ITEM_PROOF.read_text(encoding='utf-8')
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
        scene = FORCE_PROJECTOR_BOOSTER_ITEM_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07ForceProjectorBoosterItemProof.gd', scene)

    def test_reference_graph_and_actual_c07_force_projector_booster_item(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ForceProjectorBoosterItemProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_FORCE_PROJECTOR_BOOSTER_ITEM_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
