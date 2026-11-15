import json
import re
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
OVERDRIVE_PROJECTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceOverdriveProjectorBuildState.gd'
OVERDRIVE_PROJECTOR_BOOSTER_ITEMS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07OverdriveProjectorBoosterItemsProof.gd'
OVERDRIVE_PROJECTOR_BOOSTER_ITEMS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07OverdriveProjectorBoosterItemsProof.tscn'

ROW_OWNER = 'SourceOverdriveProjectorBuildState.source_overdrive_projector_item_consumer_row_state'
SYMBOLS = [
    'source_overdrive_projector_item_consumer_row_state_result.row',
    'source_overdrive_projector_item_consumer_row_state_result.has_item_row',
    'source_overdrive_projector_item_consumer_row_state_result.is_optional',
]
JAVA_SOURCES = {
    'source_overdrive_projector_item_consumer_row_state_result.row': 'core/src/mindustry/world/consumers/ConsumeItems.java',
    'source_overdrive_projector_item_consumer_row_state_result.has_item_row': 'core/src/mindustry/content/Blocks.java',
    'source_overdrive_projector_item_consumer_row_state_result.is_optional': 'core/src/mindustry/world/consumers/Consume.java',
}
GODOT_OWNERS = {name: ROW_OWNER for name in SYMBOLS}
PROOF_KEYS = [
    'projector_row_folds_optional_when_absent',
    'dome_row_folds_min_when_starved',
    'dome_row_needs_both_stacks',
    'dome_row_stops_power_when_starved',
    'use_ready_removes_projector_stack',
    'use_ready_removes_dome_stacks',
]


class C07OverdriveProjectorBoosterItemsTests(unittest.TestCase):
    def test_c07_overdrive_projector_booster_items_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2262']['godot_owner'], ROW_OWNER)
        # N2157 proved the live power.status -> efficiency driver
        # and N2194 the updateTile advance for the
        # OverdriveProjector family -- but the tick folded NO
        # item consumer: the overdrive-projector's phaseFabric
        # booster (consumeItem(Items.phaseFabric).boost(),
        # Blocks.java:1948) and the overdrive-dome's
        # phaseFabric + silicon requirement (consumeItems(with(
        # Items.phaseFabric, 1, Items.silicon, 1)),
        # Blocks.java:1961, NO .boost()) were both unmodeled,
        # so a starved projector kept its optionalEfficiency at
        # the min and a starved dome kept efficiency 1.0, and
        # the N2194 use_ready signal fired consume() with no
        # item side effect. N2262 is the ConsumeItems rows: a
        # pure row mirroring ConsumeItems.efficiency
        # (ConsumeItems.java:51-53, BINARY 1/0 -- every stack
        # held at round(amount * multiplier), ItemModule.java:
        # 152-157, or 0), folded per def -- the projector's
        # booster row into the optional pass
        # (BuildingComp.java:1980-1981, capped by the min,
        # BuildingComp.java:1986) and the dome's required row
        # into the first pass (BuildingComp.java:1969-1976,
        # result 0 stops power, BuildingComp.java:1972-1973)
        # -- plus the consume() removal when the advance
        # reports use_ready (OverdriveProjector.java:117-120),
        # per-def stacks clamped to the held count
        # (ItemModule.remove, ItemModule.java:258-263). Three
        # new result symbols: the row, its presence flag, and
        # the optional flag that routes the fold.
        self.assertEqual(ledger['N2262']['source_symbols'], SYMBOLS)
        for name in ledger['N2262']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], JAVA_SOURCES[name])
                self.assertEqual(symbol['godot_owner'], GODOT_OWNERS[name])
        self.assertEqual(ledger['N2262']['runtime_proof'], '/root/C07OverdriveProjectorBoosterItemsProof')
        self.assertEqual(
            ledger['N2262']['tests'],
            [
                'test_c07_overdrive_projector_booster_items_registration',
                'test_all_c07_overdrive_projector_booster_items_input_evidence_is_exact',
                'test_overdrive_projector_booster_items_row_state',
                'test_reference_graph_and_actual_c07_overdrive_projector_booster_items',
            ],
        )
        self.assertTrue(ledger['N2262']['deferred_exprs'])

    def test_all_c07_overdrive_projector_booster_items_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2262']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], GODOT_OWNERS[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumeItems.java',
            'core/src/mindustry/world/consumers/Consume.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/modules/ItemModule.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/world/blocks/defense/OverdriveProjector.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2262']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_overdrive_projector_booster_items_row_state(self):
        overdrive_projector = OVERDRIVE_PROJECTOR_STATE.read_text(encoding='utf-8')
        # The pure item row mirrors ConsumeItems.efficiency
        # (ConsumeItems.java:51-53): BINARY 1/0 -- NOT a ratio
        # like ConsumeLiquid. consumeTriggerValid() base
        # returns false (BuildingComp.java:764-766) and no
        # OverdriveProjector build overrides it, so the row is
        # 1 exactly when the held items satisfy EVERY stack:
        # has(stacks, multiplier) (ItemModule.java:152-157)
        # requires has(stack.item, round(stack.amount *
        # multiplier)) per stack, with has(item, amount) =
        # get(item) >= amount (ItemModule.java:126-128). The
        # multiplier is the 1f default (Consume.java:18) --
        # neither def sets one -- so the demand is the stack
        # amount itself. The counts read through the shared
        # inventory helper over frame["items"] (Dictionary
        # keyed by item name, the factory precedent).
        self.assertIn('static func source_overdrive_projector_item_consumer_row_state', overdrive_projector)
        self.assertIn('return build.consumeTriggerValid() || build.items.has(items, multiplier.get(build)) ? 1f : 0f;', overdrive_projector)
        self.assertIn('public boolean consumeTriggerValid(){', overdrive_projector)
        self.assertIn('return get(item) >= amount;', overdrive_projector)
        self.assertIn('public Floatf<Building> multiplier = b -> 1f;', overdrive_projector)
        self.assertIn('source_drill_inventory.item_count', overdrive_projector)
        self.assertIn('"items": {}', overdrive_projector)
        # Per-def stacks come from the catalog consumeItem
        # property: overdrive-projector 1 phaseFabric, booster
        # (consumeItem(Items.phaseFabric).boost(),
        # Blocks.java:1948; consumeItem(item) = ItemStack(item,
        # 1), Block.java:1167-1168) -- booster =
        # optional(true, true) (Consume.java:33-35) so the row
        # folds the optional pass (BuildingComp.java:1980-1981),
        # capped by the min efficiency (BuildingComp.java:1986);
        # overdrive-dome 1 phaseFabric + 1 silicon, REQUIRED
        # (consumeItems(with(Items.phaseFabric, 1, Items.silicon,
        # 1)), Blocks.java:1961, NO .boost()) -- the row folds
        # the first pass (BuildingComp.java:1969-1976), result 0
        # stops power (BuildingComp.java:1972-1973), and the
        # dome needs BOTH stacks.
        self.assertIn('consumeItem(Items.phaseFabric).boost();', overdrive_projector)
        self.assertIn('consumeItems(with(Items.phaseFabric, 1, Items.silicon, 1));', overdrive_projector)
        self.assertIn('return consumeItem(item, 1);', overdrive_projector)
        self.assertIn('return optional(true, true);', overdrive_projector)
        self.assertIn('for(var cons : block.optionalConsumers){', overdrive_projector)
        self.assertIn('optionalEfficiency = Math.min(optionalEfficiency, cons.efficiency(self()));', overdrive_projector)
        self.assertIn('optionalEfficiency = Math.min(optionalEfficiency, minEfficiency);', overdrive_projector)
        self.assertIn('for(var cons : block.nonOptionalConsumers){', overdrive_projector)
        self.assertIn('minEfficiency = Math.min(minEfficiency, result);', overdrive_projector)
        self.assertIn('shouldConsumePower = false;', overdrive_projector)
        self.assertIn('"is_power": false', overdrive_projector)
        self.assertIn('{"has_item_row": false, "row": {}, "is_optional": false}', overdrive_projector)
        # The tick routes the row by its optional flag: the
        # projector's booster row joins the optional pass, the
        # dome's required row joins the first pass (the fold
        # handles the min + shouldConsumePower). The stacks
        # come from the catalog consumeItem property, read once
        # so the fold and the consume() removal share them.
        self.assertIn('block.properties.get("consumeItem", [])', overdrive_projector)
        self.assertIn('required_results, optional_results, [], frame', overdrive_projector)
        # consume() (OverdriveProjector.java:117-120) fires when
        # the advance reports use_ready: the tick removes the
        # per-def stacks (projector 1 phaseFabric; dome 1
        # phaseFabric + 1 silicon), clamped to the held count
        # (ItemModule.remove, ItemModule.java:258-263) through
        # the shared inventory helper (the Fracker precedent).
        # Only ConsumeItems overrides trigger
        # (ConsumeItems.java:44-48); ConsumePower and
        # ConsumeLiquid keep the base no-op (Consume.java:50),
        # so consume() (BuildingComp.java:1911-1915) removes
        # items only. No removal when use_ready is false.
        self.assertIn('if(useProgress >= useTime){', overdrive_projector)
        self.assertIn('build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));', overdrive_projector)
        self.assertIn('amount = Math.min(amount, items[item.id]);', overdrive_projector)
        self.assertIn('for(Consume cons : block.consumers){', overdrive_projector)
        self.assertIn('cons.trigger(self());', overdrive_projector)
        self.assertIn('public void trigger(Building build){}', overdrive_projector)
        self.assertIn('source_drill_inventory.remove_item_state', overdrive_projector)
        self.assertIn('advance.get("use_ready", false)', overdrive_projector)
        # The documented limits now record the item rows as
        # live (N2262) and the consume() removal as wired, with
        # no live intake filling frame["items"] yet (the
        # Separator precedent).
        self.assertIn('item rows live (N2262)', overdrive_projector)
        self.assertIn('consume() removal wired (N2262)', overdrive_projector)
        self.assertIn('no live intake fills frame["items"] yet', overdrive_projector)
        # The power row and the advance are untouched: the
        # N2157 behaviour (the live power.status fold) and the
        # N2194 behaviour (the updateTile advance + use_ready
        # signal) are preserved by this slice.
        self.assertIn('static func source_overdrive_projector_power_status_row_state', overdrive_projector)
        self.assertIn('return build.power.status;', overdrive_projector)
        self.assertIn('static func source_overdrive_projector_update_tile_advance_state', overdrive_projector)
        self.assertIn('useProgress %= useTime;', overdrive_projector)
        self.assertIn('static func source_overdrive_projector_tick_buildings_state', overdrive_projector)
        # The proof's keys drive the pure rows (dome needs both
        # stacks) plus the live folds (projector optional when
        # absent, dome min + shouldConsumePower when starved)
        # plus the consume() removal per def when use_ready.
        # The proof scene file must exist, and the proof's
        # preloads must point at files that exist (the N2185
        # lesson: an unrun proof scene fails silently on a bad
        # preload).
        self.assertTrue(OVERDRIVE_PROJECTOR_BOOSTER_ITEMS_PROOF_SCENE.is_file())
        proof = OVERDRIVE_PROJECTOR_BOOSTER_ITEMS_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        for preload in re.findall(r'preload\("res://([^"]+)"\)', proof):
            with self.subTest(preload=preload):
                self.assertTrue((ROOT / 'godot-mindustry' / preload).is_file(), preload)

    def test_reference_graph_and_actual_c07_overdrive_projector_booster_items(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07OverdriveProjectorBoosterItemsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_OVERDRIVE_PROJECTOR_BOOSTER_ITEMS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
