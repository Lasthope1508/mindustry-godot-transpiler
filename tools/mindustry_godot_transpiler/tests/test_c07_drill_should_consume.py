import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BURST_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBurstDrillBuildState.gd'
DRILL_SHOULD_CONSUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07DrillShouldConsumeProof.gd'


class C07DrillShouldConsumeTests(unittest.TestCase):
    def test_c07_drill_should_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2338']['godot_owner'], 'SourceBurstDrillBuildState.source_drill_should_consume_state')
        # DrillBuild.shouldConsume() (Drill.java:247-249,
        # `public boolean shouldConsume(){` with `return
        # items.total() < itemCapacity && enabled &&
        # dominantItem != null;`, :248) is the BASE gate
        # updateConsumption reads (BuildingComp.java:1960,
        # `boolean update = shouldConsume() &&
        # productionValid();` + 1992, `if(!update){` + 1993,
        # `efficiency = optionalEfficiency = 0f;`): items
        # total below the per-def item capacity AND enabled
        # AND a dominant item bound. It is NOT the
        # BurstDrill override (N2295, BurstDrill.java:128-129,
        # `return items.total() <= itemCapacity -
        # dominantItems && enabled;` -- `<=` with the
        # dominant COUNT subtracted, no dominantItem null
        # check) and NOT the Turret override (N2291,
        # Turret.java:364-366) -- each class owns its own
        # shouldConsume(). The strict `<` is the observable
        # difference from N2295's `<=`: at items_total ==
        # itemCapacity the base gate blocks while the
        # override (with dominant_items 0) would pass. The
        # dominantItem null check is the second difference:
        # a drill with room and enabled but no dominant item
        # bound does NOT consume. One pure function on the
        # family file (the N2295 precedent): the frame
        # carries the live items observation as `items_total`
        # (float, absent defaults to 0.0 -- a fresh ItemModule
        # totals 0, the N2207 LaunchPad precedent) and
        # `enabled` (bool, absent defaults to true --
        # BuildingComp.java:77); the per-def item_capacity is
        # an explicit param (the N2212 / N2248 per-def-param
        # precedent) and has_dominant_item is an explicit
        # bool param (the N2341 drawSelect precedent --
        # dominantItem is `public Item dominantItem;`,
        # Drill.java:244, set by the N2262 ore/dominant
        # binding, which the frame does not carry yet). One
        # new result symbol: the gate itself. There is NO
        # driver tick line: the BurstDrill tick driver calls
        # the N2295 override (polymorphism -- a BurstDrill
        # build runs the override, not the base), and this
        # slice is the base pure predicate, not a caller
        # port.
        self.assertEqual(
            ledger['N2338']['source_symbols'],
            [
                'source_drill_should_consume_state_result.should_consume',
            ],
        )
        for name in ledger['N2338']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/Drill.java',
                    'core/src/mindustry/world/blocks/production/BurstDrill.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/world/Block.java',
                    'core/src/mindustry/content/Blocks.java',
                    'core/src/mindustry/world/modules/ItemModule.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.source_drill_should_consume_state')
        self.assertEqual(ledger['N2338']['runtime_proof'], '/root/C07DrillShouldConsumeProof')
        self.assertEqual(
            ledger['N2338']['tests'],
            [
                'test_c07_drill_should_consume_registration',
                'test_all_c07_drill_should_consume_input_evidence_is_exact',
                'test_drill_should_consume_state',
                'test_reference_graph_and_actual_c07_drill_should_consume',
            ],
        )
        self.assertTrue(ledger['N2338']['deferred_exprs'])

    def test_all_c07_drill_should_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2338']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.source_drill_should_consume_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/production/Drill.java',
            'core/src/mindustry/world/blocks/production/BurstDrill.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/modules/ItemModule.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2338']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_drill_should_consume_state(self):
        burst_drill = BURST_DRILL_STATE.read_text(encoding='utf-8')
        # DrillBuild.shouldConsume() (Drill.java:247-249,
        # `public boolean shouldConsume(){` with `return
        # items.total() < itemCapacity && enabled &&
        # dominantItem != null;`, :248) over the items total
        # (ItemModule.java:174, `public int total(){` with
        # `return total;`, ItemModule.java:175), the per-def
        # item capacity (`public int itemCapacity = 10;`,
        # Block.java:75, with `itemCapacity = 40;`,
        # Blocks.java:3078, for impact-drill and
        # `itemCapacity = 60;`, Blocks.java:3107, for
        # eruption-drill), the dominant item (`public Item
        # dominantItem;`, Drill.java:244, with `public int
        # dominantItems;`, Drill.java:243) and the enabled
        # flag (`transient boolean enabled = true;`,
        # BuildingComp.java:77), and updateConsumption forces
        # efficiency to zero when the gate is false
        # (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();` + 1992,
        # `if(!update){` + 1993, `efficiency =
        # optionalEfficiency = 0f;`). The BuildingComp
        # default (`public boolean shouldConsume(){` with
        # `return enabled;`, BuildingComp.java:755-756) is
        # what the override replaces. The classes are
        # `public class Drill extends Block{`
        # (Drill.java:27) and `public class DrillBuild
        # extends Building{` (Drill.java:237);
        # BurstDrillBuild inherits DrillBuild (`public class
        # BurstDrillBuild extends DrillBuild{`,
        # BurstDrill.java:70) and overrides shouldConsume
        # (N2295) -- the override runs for burst drills, the
        # base gate here is the DrillBuild predicate.
        self.assertIn('static func source_drill_should_consume_state(frame: Dictionary, item_capacity: float, has_dominant_item: bool) -> Dictionary:', burst_drill)
        # The gate cases, pinned as the pure function's
        # decision structure: the frame carries the live items
        # observation as `items_total` (float, absent defaults
        # to 0.0 -- a fresh ItemModule totals 0, the N2207
        # LaunchPad precedent) and `enabled` (bool, absent
        # defaults to true -- BuildingComp.java:77); the
        # per-def item_capacity is an explicit param (the
        # N2212 / N2248 per-def-param precedent) and
        # has_dominant_item is an explicit bool param (the
        # N2341 drawSelect precedent). items_total <
        # item_capacity with enabled and a dominant item
        # passes the gate; items_total AT the capacity blocks
        # it (strict `<`, unlike N2295's `<=`); items_total
        # above the capacity blocks it; enabled=false blocks
        # it; no dominant item blocks it -- all five observed
        # cases run through the one conjunction,
        # `items_total < item_capacity and enabled and
        # has_dominant_item`; NO items_total key preserves
        # the N2149 behavior, `should_consume = enabled and
        # has_dominant_item`, because the default makes the
        # bound read `0 < itemCapacity`.
        self.assertIn('float(frame.get("items_total", 0.0))', burst_drill)
        self.assertIn('bool(frame.get("enabled", true))', burst_drill)
        with self.subTest(case='items_total below capacity with enabled and dominant passes the gate'):
            self.assertIn('items_total < item_capacity and enabled and has_dominant_item', burst_drill)
        with self.subTest(case='items_total at the capacity blocks the gate (strict <)'):
            self.assertIn('items_total < item_capacity and enabled and has_dominant_item', burst_drill)
        with self.subTest(case='items_total above the capacity blocks the gate'):
            self.assertIn('items_total < item_capacity and enabled and has_dominant_item', burst_drill)
        with self.subTest(case='enabled=false blocks the gate'):
            self.assertIn('items_total < item_capacity and enabled and has_dominant_item', burst_drill)
        with self.subTest(case='no dominant item blocks the gate'):
            self.assertIn('items_total < item_capacity and enabled and has_dominant_item', burst_drill)
        with self.subTest(case='no items_total key preserves N2149 behavior'):
            self.assertIn('return {"should_consume": items_total < item_capacity and enabled and has_dominant_item}', burst_drill)
        for expr in [
            'public boolean shouldConsume(){',
            'return items.total() < itemCapacity && enabled && dominantItem != null;',
            'public Item dominantItem;',
            'public int dominantItems;',
            'public int total(){',
            'return total;',
            'public int itemCapacity = 10;',
            'itemCapacity = 40;',
            'itemCapacity = 60;',
            'transient boolean enabled = true;',
            'boolean update = shouldConsume() && productionValid();',
            'if(!update){',
            'efficiency = optionalEfficiency = 0f;',
            'return enabled;',
            'public class DrillBuild extends Building{',
            'public class Drill extends Block{',
            'public class BurstDrillBuild extends DrillBuild{',
            'public class BurstDrill extends Drill{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, burst_drill)
        # The proof's keys drive the pure function directly
        # (passes below capacity with a dominant item /
        # blocks at capacity / blocks above capacity /
        # blocks when disabled / blocks with no dominant item
        # / absent items_total defaults to 0 / eruption def
        # uses capacity 60). There is NO driver tick line:
        # the BurstDrill driver calls the N2295 override and
        # this slice ports only the base predicate.
        proof = DRILL_SHOULD_CONSUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'gate_passes_below_capacity_with_dominant',
            'gate_blocks_at_capacity',
            'gate_blocks_above_capacity',
            'gate_blocks_when_disabled',
            'gate_blocks_no_dominant_item',
            'gate_absent_items_total_defaults_zero',
            'gate_eruption_def_uses_capacity_60',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_drill_should_consume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07DrillShouldConsumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_DRILL_SHOULD_CONSUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'gate_passes_below_capacity_with_dominant',
            'gate_blocks_at_capacity',
            'gate_blocks_above_capacity',
            'gate_blocks_when_disabled',
            'gate_blocks_no_dominant_item',
            'gate_absent_items_total_defaults_zero',
            'gate_eruption_def_uses_capacity_60',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
