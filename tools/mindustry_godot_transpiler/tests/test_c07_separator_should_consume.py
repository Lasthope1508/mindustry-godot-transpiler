import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SEPARATOR_STATE = ROOT / 'godot-mindustry/src/game/SourceSeparatorBuildState.gd'
DRILL_INVENTORY_STATE = ROOT / 'godot-mindustry/src/game/SourceDrillInventoryRuntimeState.gd'
SEPARATOR_SHOULD_CONSUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SeparatorShouldConsumeProof.gd'
SEPARATOR_SHOULD_CONSUME_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SeparatorShouldConsumeProof.tscn'


class C07SeparatorShouldConsumeTests(unittest.TestCase):
    def test_c07_separator_should_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2200']['godot_owner'], 'SourceSeparatorBuildState.source_separator_should_consume_state')
        # N2169 gave the separator its live power.status read --
        # a pure power row over the stamped frame value, folded by
        # the shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) -- but RED-deferred the shouldConsume
        # gate: the port tracked NO items state on the separator
        # frame, so the machinery ran with should_consume=true
        # when enabled (the MendProjector suppression precedent)
        # -- when full power.status reads 1.0 while Java
        # efficiency is 0. SeparatorBuild overrides shouldConsume
        # (Separator.java:92-101): `int total = items.total();`
        # (:93), then -- when the block has a ConsumeItems
        # consumer -- the consItems buffer is subtracted
        # (`for(ItemStack stack : consItems.items){` / `total -=
        # items.get(stack.item);`, :96-97), and `return total <
        # itemCapacity && enabled;` (:100). consItems is found by
        # init() (`consItems = findConsumer(c -> c instanceof
        # ConsumeItems);`, Separator.java:58) from `protected
        # @Nullable ConsumeItems consItems;` (Separator.java:21),
        # so it is null on a def with no consumeItem -- and the
        # separator def has NO consumeItem (Blocks.java:1231-1246),
        # so its consItems is null and nothing is subtracted; only
        # the disassembler consumes scrap
        # (`consumeItem(Items.scrap);`, Blocks.java:1263), so only
        # its held scrap is subtracted. The capacity is the
        # catalog itemCapacity (`public int itemCapacity = 10;`,
        # Block.java:75, the default; disassembler `itemCapacity
        # = 20;`, Blocks.java:1261). N2200 wires the gate into the
        # separator's OWN driver (SourceSeparatorBuildState.gd,
        # frame key "source_separator_building"): the frame gets
        # an `items` key (Dictionary keyed by item name, default
        # {}, the Building.items ItemModule, the factory precedent
        # SourceFactoryBuildState.gd:89-101), the pure gate reads
        # the frame items through the drill inventory helpers
        # (items_total minus item_count per cons item -- reused,
        # not recomputed), and the driver feeds `should_consume =
        # total < itemCapacity && enabled` to the machinery, so a
        # full separator folds efficiency 0 like Java. No live
        # intake fills frame["items"] yet -- the gate reads the
        # frame as-is, and intake waits for its own slice (new
        # deferral). Two new result symbols: the gate and the
        # buffer-adjusted total it reads.
        self.assertEqual(
            ledger['N2200']['source_symbols'],
            [
                'source_separator_should_consume_state_result.should_consume',
                'source_separator_should_consume_state_result.total',
            ],
        )
        for name in ledger['N2200']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/Separator.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_separator_should_consume_state_result.should_consume': 'SourceSeparatorBuildState.source_separator_should_consume_state',
                    'source_separator_should_consume_state_result.total': 'SourceSeparatorBuildState.source_separator_should_consume_state',
                }[name])
        self.assertEqual(ledger['N2200']['runtime_proof'], '/root/C07SeparatorShouldConsumeProof')
        self.assertEqual(
            ledger['N2200']['tests'],
            [
                'test_c07_separator_should_consume_registration',
                'test_all_c07_separator_should_consume_input_evidence_is_exact',
                'test_separator_should_consume_gate_state',
                'test_reference_graph_and_actual_c07_separator_should_consume',
            ],
        )
        self.assertTrue(ledger['N2200']['deferred_exprs'])
        # This slice resolves the N2169 Separator gate
        # deferral, so the gate entry is gone from DEFERRED --
        # while the updateTile advance, liquid slag row,
        # disassembler verification, sense/canDump, draw, and
        # read/write rows stay deferred.
        self.assertFalse(any(entry.startswith('Separator shouldConsume gate (') for entry in ledger['N2200']['deferred_exprs']))

    def test_all_c07_separator_should_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2200']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_separator_should_consume_state_result.should_consume': 'SourceSeparatorBuildState.source_separator_should_consume_state',
                    'source_separator_should_consume_state_result.total': 'SourceSeparatorBuildState.source_separator_should_consume_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/production/Separator.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/consumers/ConsumeItems.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2200']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_separator_should_consume_gate_state(self):
        separator = SEPARATOR_STATE.read_text(encoding='utf-8')
        # The pure gate lives on the separator build state:
        # SeparatorBuild.shouldConsume() (Separator.java:92,
        # `public boolean shouldConsume(){` with `return total <
        # itemCapacity && enabled;`, Separator.java:100) counts
        # `int total = items.total();` (Separator.java:93) minus
        # the consItems buffer (`for(ItemStack stack :
        # consItems.items){` / `total -= items.get(stack.item);`,
        # Separator.java:96-97); consItems is found by init()
        # (`consItems = findConsumer(c -> c instanceof
        # ConsumeItems);`, Separator.java:58) from `protected
        # @Nullable ConsumeItems consItems;` (Separator.java:21),
        # so it is null on a def with no consumeItem -- the
        # separator def has none (Blocks.java:1231-1246), only the
        # disassembler consumes scrap (`consumeItem(Items.scrap);`,
        # Blocks.java:1263). The capacity is the catalog
        # itemCapacity (`public int itemCapacity = 10;`,
        # Block.java:75, the default; disassembler `itemCapacity
        # = 20;`, Blocks.java:1261). SeparatorBuild overrides
        # shouldConsume (Separator.java:75, `public class
        # SeparatorBuild extends Building{`; Separator.java:19,
        # `public class Separator extends Block{`), so the default
        # (`return enabled;`, BuildingComp.java:755-756) does not
        # apply here. When the gate is false updateConsumption
        # forces efficiency to zero (BuildingComp.java:1960,
        # `boolean update = shouldConsume() &&
        # productionValid();` + 1992, `if(!update){`). The total
        # is the drill inventory total
        # (SourceDrillInventoryRuntimeState.items_total, reused
        # through a preload -- not recomputed) minus the held
        # count of each cons item (item_count); the frame carries
        # the Building.items ItemModule (frame["items"],
        # Dictionary keyed by item name, the factory precedent
        # SourceFactoryBuildState.gd:89-101). The updateTile
        # progress advance (Separator.java:133, `if(efficiency >
        # 0){` with `progress +=
        # getProgressIncrease(craftTime);`) follows the folded
        # efficiency and waits for its own slice, as do the
        # liquid slag consumer, the items intake (no live intake
        # fills frame["items"] yet -- the gate reads the frame
        # as-is), and draw/bars.
        self.assertIn('static func source_separator_should_consume_state', separator)
        self.assertIn('total < item_capacity and enabled', separator)
        self.assertIn('inventory.items_total(items)', separator)
        self.assertIn('inventory.item_count(items, str(cons_item_name))', separator)
        self.assertIn('preload("res://src/game/SourceDrillInventoryRuntimeState.gd")', separator)
        self.assertIn('public boolean shouldConsume(){', separator)
        self.assertIn('return total < itemCapacity && enabled;', separator)
        self.assertIn('int total = items.total();', separator)
        self.assertIn('for(ItemStack stack : consItems.items){', separator)
        self.assertIn('total -= items.get(stack.item);', separator)
        self.assertIn('consItems = findConsumer(c -> c instanceof ConsumeItems);', separator)
        self.assertIn('protected @Nullable ConsumeItems consItems;', separator)
        self.assertIn('public int itemCapacity = 10;', separator)
        self.assertIn('itemCapacity = 20;', separator)
        self.assertIn('consumeItem(Items.scrap);', separator)
        self.assertIn('boolean update = shouldConsume() && productionValid();', separator)
        self.assertIn('if(!update){', separator)
        self.assertIn('public class Separator extends Block{', separator)
        self.assertIn('public class SeparatorBuild extends Building{', separator)
        self.assertIn('return enabled;', separator)
        self.assertIn('if(efficiency > 0){', separator)
        self.assertIn('progress += getProgressIncrease(craftTime);', separator)
        self.assertIn('"items": {}', separator)
        self.assertIn('frame["items"]', separator)
        # The driver feeds the live gate to the machinery: the
        # cons item names come from the catalog consumeItem rows
        # (empty for the separator def, [scrap] for the
        # disassembler), the capacity from the catalog
        # itemCapacity (10 default, 20 disassembler), and the
        # gate call feeds should_consume into the fold.
        self.assertIn('static func source_separator_tick_buildings_state', separator)
        self.assertIn('block.properties.get("consumeItem", [])', separator)
        self.assertIn('block.properties.get("itemCapacity", 10)', separator)
        self.assertIn('source_separator_should_consume_state(frame, cons_item_names, item_capacity)', separator)
        self.assertIn('bool(gate.get("should_consume", true))', separator)
        # The documented limits record the gate as live; the old
        # N2169 deferral text is gone. The N2169 power row is
        # preserved.
        self.assertIn('shouldConsume gate live (N2200)', separator)
        self.assertNotIn('runs with should_consume=true when enabled', separator)
        self.assertNotIn('items state is not tracked yet', separator)
        self.assertIn('static func source_separator_power_status_row_state', separator)
        # The proof's keys drive the pure gate (true below
        # capacity, false when full, false when disabled, the
        # consItems buffer subtracted) plus the live tick
        # (efficiency 0 when the gate is false, the N2169 power
        # fold preserved when the gate is true). There are no
        # progress / warmup / offload keys: the updateTile
        # advance (Separator.java:128-166) waits for its own
        # slice, so the efficiency > 0 gate (Separator.java:133)
        # is what the efficiency keys prove. Static checks: the
        # proof preloads the separator state file that exists,
        # and the scene file references the proof script that
        # exists.
        proof = SEPARATOR_SHOULD_CONSUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'gate_true_below_capacity',
            'gate_false_when_full',
            'gate_false_when_disabled',
            'buffer_cons_items_subtracted',
            'efficiency_zero_when_gate_false',
            'efficiency_folds_power_when_gate_true',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceSeparatorBuildState.gd")', proof)
        self.assertIn('separator_build_state.source_separator_should_consume_state(', proof)
        self.assertIn('separator_build_state.source_separator_tick_buildings_state(game, 1.0 / 60.0)', proof)
        self.assertTrue(SEPARATOR_STATE.is_file())
        self.assertTrue(DRILL_INVENTORY_STATE.is_file())
        scene = SEPARATOR_SHOULD_CONSUME_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07SeparatorShouldConsumeProof.gd', scene)
        self.assertTrue(SEPARATOR_SHOULD_CONSUME_PROOF.is_file())

    def test_reference_graph_and_actual_c07_separator_should_consume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07SeparatorShouldConsumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SEPARATOR_SHOULD_CONSUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'gate_true_below_capacity',
            'gate_false_when_full',
            'gate_false_when_disabled',
            'buffer_cons_items_subtracted',
            'efficiency_zero_when_gate_false',
            'efficiency_folds_power_when_gate_true',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
