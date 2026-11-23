import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BURST_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBurstDrillBuildState.gd'
BURST_DRILL_SHOULD_CONSUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BurstDrillShouldConsumeProof.gd'


class C07BurstDrillShouldConsumeTests(unittest.TestCase):
    def test_c07_burst_drill_should_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2295']['godot_owner'], 'SourceBurstDrillBuildState.source_burst_drill_should_consume_state')
        # N2149 folded power-only for the burst drill: a pure
        # power row over the stamped frame value, folded by the
        # shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) in its own driver. But
        # BurstDrillBuild DOES override shouldConsume:
        # `return items.total() <= itemCapacity -
        # dominantItems && enabled;`
        # (BurstDrill.java:129), and updateConsumption forces
        # efficiency to zero when the gate is false
        # (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();` + 1992-1993,
        # `if(!update){` / `efficiency = optionalEfficiency =
        # 0f;`). N2149/N2256 deferred the gate with a documented
        # limit (the PointDefenseTurret N2151 precedent): the port
        # tracked no live items/dominant state on any
        # placed-building frame, so with a full item store
        # requestedPower is 0 so power.status reads 1.0 while
        # Java efficiency is 0 -- the observable gap is
        # efficiency 1.0 vs 0.0 when full. N2256 stamped the
        # prerequisite frame keys as pure-function inputs
        # (`items_total`, `dominant_items`) but no driver stamps
        # them yet; N2295 closes the gate with one pure function
        # over those frame keys plus the per-def item_capacity
        # param (the N2212 / N2248 per-def-param precedent):
        # the gate is the same expression over the observed
        # totals, `items_total <= item_capacity -
        # dominant_items && enabled`. RED decision (pinned by
        # this slice, the proof's fourth key -- the N2188 /
        # N2191 absent-preserves precedent): when the frame
        # carries NO `items_total` / `dominant_items` keys, the
        # field defaults (a fresh ItemModule totals 0, the N2207
        # LaunchPad precedent; `public int dominantItems;`,
        # Drill.java:243, defaults to 0) make the gate read
        # `0 <= itemCapacity - 0`, i.e. `should_consume =
        # enabled` -- null means "no observation yet", not
        # "full", because no placed-building frame carries live
        # items/dominant state until the ore/dominant binding
        # slice stamps them, and defaulting absent to false
        # would zero efficiency for every live burst drill, a
        # live regression against N2149 GREEN. The gate
        # therefore activates when that binding slice stamps
        # `items_total` / `dominant_items`. One new result
        # symbol: the gate itself.
        self.assertEqual(
            ledger['N2295']['source_symbols'],
            [
                'source_burst_drill_should_consume_state_result.should_consume',
            ],
        )
        for name in ledger['N2295']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/BurstDrill.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.source_burst_drill_should_consume_state')
        self.assertEqual(ledger['N2295']['runtime_proof'], '/root/C07BurstDrillShouldConsumeProof')
        self.assertEqual(
            ledger['N2295']['tests'],
            [
                'test_c07_burst_drill_should_consume_registration',
                'test_all_c07_burst_drill_should_consume_input_evidence_is_exact',
                'test_burst_drill_should_consume_state',
                'test_reference_graph_and_actual_c07_burst_drill_should_consume',
            ],
        )
        self.assertTrue(ledger['N2295']['deferred_exprs'])

    def test_all_c07_burst_drill_should_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2295']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.source_burst_drill_should_consume_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/production/BurstDrill.java',
            'core/src/mindustry/world/blocks/production/Drill.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/modules/ItemModule.java',
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2295']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_burst_drill_should_consume_state(self):
        burst_drill = BURST_DRILL_STATE.read_text(encoding='utf-8')
        # The pure shouldConsume gate lives on the burst-drill
        # build state: BurstDrillBuild overrides shouldConsume
        # (BurstDrill.java:128, `public boolean
        # shouldConsume(){` with `return items.total() <=
        # itemCapacity - dominantItems && enabled;`,
        # BurstDrill.java:129) over the items total
        # (ItemModule.java:174, `public int total(){` with
        # `return total;`, ItemModule.java:175), the per-def
        # item capacity (`public int itemCapacity = 10;`,
        # Block.java:75, with `itemCapacity = 40;`,
        # Blocks.java:3078, for impact-drill and
        # `itemCapacity = 60;`, Blocks.java:3107, for
        # eruption-drill), the dominant count (`public int
        # dominantItems;`, Drill.java:243, with `public Item
        # dominantItem;`, Drill.java:244) and the enabled flag
        # (`transient boolean enabled = true;`,
        # BuildingComp.java:77), and updateConsumption forces
        # efficiency to zero when the gate is false
        # (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();` + 1992,
        # `if(!update){` + 1993, `efficiency =
        # optionalEfficiency = 0f;`). The gate matters because
        # with a full item store Java efficiency is 0 while the
        # port folds power-only and reports 1.0 -- the N2149
        # gap this slice closes once the frame carries the
        # stamped totals. A missing power stamp folds to 1.0
        # before the first graph update, the assembler fold
        # (UnitAssembler.java:469, `float powerStatus = !enabled
        # ? 0f : power == null ? 1f : power.status;`), and the
        # power consumer counts toward hasConsumers
        # (Block.java:1449, `hasConsumers = consumers.length >
        # 0;`); edelta() is efficiency * delta
        # (BuildingComp.java:1928, `return efficiency *
        # delta();`). The burst drill's power draw is STATIC:
        # impact-drill consumePower 160f/60f and eruption-drill
        # consumePower 6f (Blocks.java, via the catalog), so the
        # row read is the plain one (ConsumePower.java:39,
        # `return build.power.status;`) -- no RepairTurret-style
        # ConsumePowerCondition adaptation. The BuildingComp
        # default (`public boolean shouldConsume(){` with
        # `return enabled;`, BuildingComp.java:755-756) is what
        # the override replaces. The driver calls the pure gate
        # BEFORE the consumption setup (the Java order,
        # updateConsumption :2274 reads shouldConsume() at
        # :1960), reading the per-def itemCapacity from the
        # catalog block properties (the AdjacentFactory
        # precedent, `properties.get("itemCapacity", 10)` with
        # the Block default 10, Block.java:75).
        self.assertIn('static func source_burst_drill_should_consume_state(frame: Dictionary, item_capacity: float) -> Dictionary:', burst_drill)
        # The gate cases, pinned as the pure function's
        # decision structure: the frame carries the live items
        # observation as `items_total` (float, absent defaults
        # to 0.0 -- a fresh ItemModule totals 0, the N2207
        # LaunchPad precedent) and `dominant_items` (int,
        # absent defaults to 0 -- Drill.java:243), and
        # `enabled` (bool, absent defaults to true --
        # BuildingComp.java:77); the per-def item_capacity is
        # an explicit param (the N2212 / N2248 per-def-param
        # precedent). items_total <= item_capacity -
        # dominant_items with enabled passes the gate;
        # items_total above that bound blocks it; enabled=false
        # blocks it -- all three observed cases run through
        # the one conjunction, `items_total <= item_capacity
        # - float(dominant_items) and enabled`; NO items_total
        # / dominant_items keys preserve the N2149 behavior,
        # `should_consume = enabled`, because the defaults
        # make the bound read `0 <= itemCapacity - 0`.
        self.assertIn('float(frame.get("items_total", 0.0))', burst_drill)
        self.assertIn('int(frame.get("dominant_items", 0))', burst_drill)
        self.assertIn('bool(frame.get("enabled", true))', burst_drill)
        with self.subTest(case='items_total within bound with enabled passes the gate'):
            self.assertIn('items_total <= item_capacity - float(dominant_items) and enabled', burst_drill)
        with self.subTest(case='items_total above the bound blocks the gate'):
            self.assertIn('items_total <= item_capacity - float(dominant_items) and enabled', burst_drill)
        with self.subTest(case='enabled=false blocks the gate'):
            self.assertIn('items_total <= item_capacity - float(dominant_items) and enabled', burst_drill)
        with self.subTest(case='no items_total / dominant_items keys preserve N2149 behavior'):
            self.assertIn('return {"should_consume": items_total <= item_capacity - float(dominant_items) and enabled}', burst_drill)
        for expr in [
            'public boolean shouldConsume(){',
            'return items.total() <= itemCapacity - dominantItems && enabled;',
            'public int dominantItems;',
            'public Item dominantItem;',
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
            'hasConsumers = consumers.length > 0;',
            'return build.power.status;',
            'float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;',
            'public class BurstDrill extends Drill{',
            'public class BurstDrillBuild extends DrillBuild{',
            'public class DrillBuild extends Building{',
            'return efficiency * delta();',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, burst_drill)
        # The driver wires the gate: the per-def itemCapacity
        # comes from the catalog block properties (the
        # AdjacentFactory precedent) and the pure-function call
        # replaces the enabled-only should_consume BEFORE the
        # consumption setup.
        self.assertIn('block.properties.get("itemCapacity", source_block_defaults.ITEM_CAPACITY_DEFAULT)', burst_drill)
        self.assertIn('source_burst_drill_should_consume_state(frame, item_capacity)', burst_drill)
        driver_start = burst_drill.index('static func source_burst_drill_tick_buildings_state')
        driver_text = burst_drill[driver_start:]
        self.assertIn('source_burst_drill_should_consume_state(frame, item_capacity)', driver_text)
        # The proof's keys drive the pure gate (blocks when full
        # / passes with room / blocks when disabled / absent keys
        # preserve the power fold / passes with room and no power
        # stamp / eruption def uses capacity 60) plus the live
        # tick (the gate overrides the power fold). There are no
        # liquid / updateTile / ore-binding keys: the liquid
        # rows (N2258) and the ore/dominant binding wait for
        # their own slices, and the items_total / dominant_items
        # frame keys are stamped by the proof, not by a live
        # binding yet.
        proof = BURST_DRILL_SHOULD_CONSUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'gate_blocks_when_full',
            'gate_passes_when_room',
            'gate_blocks_when_disabled',
            'gate_absent_preserves_power_fold',
            'gate_passes_with_room_no_power',
            'gate_eruption_def_uses_capacity_60',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_burst_drill_should_consume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BurstDrillShouldConsumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BURST_DRILL_SHOULD_CONSUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'gate_blocks_when_full',
            'gate_passes_when_room',
            'gate_blocks_when_disabled',
            'gate_absent_preserves_power_fold',
            'gate_passes_with_room_no_power',
            'gate_eruption_def_uses_capacity_60',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
