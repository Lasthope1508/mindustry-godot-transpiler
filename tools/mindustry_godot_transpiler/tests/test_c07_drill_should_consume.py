import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceDrillConsumptionRuntimeState.gd'
DRILL_SHOULD_CONSUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07DrillShouldConsumeProof.gd'
DRILL_SHOULD_CONSUME_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07DrillShouldConsumeProof.tscn'


class C07DrillShouldConsumeTests(unittest.TestCase):
    def test_c07_drill_should_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2204']['godot_owner'], 'SourceDrillConsumptionRuntimeState.source_drill_should_consume_state')
        # The base-Drill driver has computed the shouldConsume gate
        # inline since the drill live-consumption slice (N2009
        # registered the exact override expr) -- the machinery
        # already ran with should_consume = items.total() <
        # itemCapacity && enabled && dominantItem != null, so no
        # DEFERRED entry ever covered the base-Drill gate (unlike
        # the BurstDrill gate, BurstDrill.java:129, still deferred
        # for N2203, and the BeamDrill gate, BeamDrill.java:270,
        # still deferred for N2202). N2204 formalizes the inline
        # gate as the pure source_drill_should_consume_state
        # function (the N2188/N2198 gate precedent) and wires the
        # driver through it: the override exactly --
        # DrillBuild.shouldConsume (Drill.java:247-248, `return
        # items.total() < itemCapacity && enabled && dominantItem
        # != null;`), INCLUDING the enabled check, unlike the
        # LaunchPad/ShockwaveTower overrides, whose enabled
        # handling lives in updateConsumption
        # (BuildingComp.java:1954-1957, the disabled early
        # return). The gate reads the frame's items (totaled by
        # the shared inventory.items_total helper -- the same
        # read the runtime context already uses for its active
        # key), enabled, and dominant_item (set by
        # onProximityUpdate, Drill.java:275-277, null when no
        # mineable ore sits under the footprint or after pickup,
        # Drill.java:267-268); item_capacity is the block def
        # capacity (block.properties["itemCapacity"], 10 for
        # mechanical/pneumatic/laser, 20 for blast-drill,
        # Blocks.java:2911), passed by the driver -- the frame
        # does not carry it. When the gate is false,
        # updateConsumption forces efficiency to zero
        # (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();`, with
        # BuildingComp.java:1992-1994, `if(!update){` /
        # `efficiency = optionalEfficiency = 0f;`), so a full or
        # ore-less drill no longer reads power.status 1.0 while
        # Java efficiency is 0. The gate is the BASE Drill
        # override only: BurstDrillBuild overrides shouldConsume
        # with its own gate (BurstDrill.java:129, `return
        # items.total() <= itemCapacity - dominantItems &&
        # enabled;` -- `<= itemCapacity - dominantItems`, no
        # dominantItem null check), and the base-Drill driver
        # never ticks BurstDrill implementations (it gates on
        # the base Drill generated class), so eruption-drill /
        # impact-drill never reach this function; their gate is
        # N2203's slice. Two new result symbols: the gate
        # verdict and the dominant item it read.
        self.assertEqual(
            ledger['N2204']['source_symbols'],
            [
                'source_drill_should_consume_state_result.should_consume',
                'source_drill_should_consume_state_result.dominant_item',
            ],
        )
        for name in ledger['N2204']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/Drill.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_drill_should_consume_state_result.should_consume': 'SourceDrillConsumptionRuntimeState.source_drill_should_consume_state',
                    'source_drill_should_consume_state_result.dominant_item': 'SourceDrillConsumptionRuntimeState.source_drill_should_consume_state',
                }[name])
        self.assertEqual(ledger['N2204']['runtime_proof'], '/root/C07DrillShouldConsumeProof')
        self.assertEqual(
            ledger['N2204']['tests'],
            [
                'test_c07_drill_should_consume_registration',
                'test_all_c07_drill_should_consume_input_evidence_is_exact',
                'test_drill_should_consume_gate_state',
                'test_reference_graph_and_actual_c07_drill_should_consume',
            ],
        )
        self.assertTrue(ledger['N2204']['deferred_exprs'])

    def test_all_c07_drill_should_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2204']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_drill_should_consume_state_result.should_consume': 'SourceDrillConsumptionRuntimeState.source_drill_should_consume_state',
                    'source_drill_should_consume_state_result.dominant_item': 'SourceDrillConsumptionRuntimeState.source_drill_should_consume_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/production/Drill.java',
            'core/src/mindustry/world/blocks/production/BurstDrill.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/consumers/ConsumePower.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2204']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_drill_should_consume_gate_state(self):
        drill = DRILL_STATE.read_text(encoding='utf-8')
        # The pure gate is DrillBuild.shouldConsume() exactly
        # (Drill.java:247, `public boolean shouldConsume(){`
        # with `return items.total() < itemCapacity && enabled
        # && dominantItem != null;`, Drill.java:248): the drill
        # consumes only while its item store is below capacity
        # AND it is enabled AND it has a dominant item. The
        # override INCLUDES the enabled check -- unlike the
        # LaunchPad (N2186) and ShockwaveTower (N2187)
        # overrides -- so the pure function reads all three
        # frame inputs: items (the Building.items ItemModule,
        # frame["items"] keyed by item name, totaled by the
        # shared inventory.items_total helper -- the same read
        # the runtime context already uses for its active key),
        # enabled (BuildingComp.java:77, `transient boolean
        # enabled = true;`, the BuildingComp default
        # shouldConsume, BuildingComp.java:755-756, `return
        # enabled;`), and dominant_item (Drill.java:244,
        # `public Item dominantItem;`, set by
        # onProximityUpdate, Drill.java:275-277, `countOre(
        # tile);` / `dominantItem = returnItem;` /
        # `dominantItems = returnCount;`; null when no mineable
        # ore sits under the footprint, Drill.java:223, or after
        # pickup, Drill.java:267-268). item_capacity is the
        # block def capacity (block.properties["itemCapacity"],
        # 10 for mechanical/pneumatic/laser, 20 for blast-drill,
        # Blocks.java:2911, `itemCapacity = 20;`), passed by
        # the driver -- the frame does not carry it. When the
        # gate is false, updateConsumption folds efficiency to
        # 0 (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();`, with
        # BuildingComp.java:1992-1994, `if(!update){` /
        # `efficiency = optionalEfficiency = 0f;`). The gate
        # is the BASE Drill override only: BurstDrill extends
        # Drill (BurstDrill.java:17, `public class BurstDrill
        # extends Drill{`) and BurstDrillBuild extends
        # DrillBuild (BurstDrill.java:70, `public class
        # BurstDrillBuild extends DrillBuild{`), overriding
        # shouldConsume with its own gate (BurstDrill.java:129,
        # `return items.total() <= itemCapacity - dominantItems
        # && enabled;`) -- `<= itemCapacity - dominantItems`,
        # no dominantItem null check -- and the base-Drill
        # driver never ticks BurstDrill implementations (it
        # gates on the base Drill generated class), so
        # eruption-drill / impact-drill never reach this
        # function; their gate is N2203's slice. The power row
        # itself is unchanged (N2147): the pure ConsumePower
        # read (`return build.power.status;`,
        # ConsumePower.java:39) over the stamped frame value,
        # for the laser-drill's static power consumer
        # (`consumePower(1.10f);`, Blocks.java:2895) and the
        # mechanical drill's water booster
        # (`consumeLiquid(Liquids.water, 0.05f).boost();`,
        # Blocks.java:2874). The draw/bars rows (setBars
        # drillspeed bar, Drill.java:114; draw, Drill.java:346)
        # wait for their own slices.
        self.assertIn('static func source_drill_should_consume_state', drill)
        self.assertIn('public boolean shouldConsume(){', drill)
        self.assertIn('return items.total() < itemCapacity && enabled && dominantItem != null;', drill)
        self.assertIn('public int dominantItems;', drill)
        self.assertIn('public Item dominantItem;', drill)
        self.assertIn('countOre(tile);', drill)
        self.assertIn('dominantItem = returnItem;', drill)
        self.assertIn('dominantItems = returnCount;', drill)
        self.assertIn('boolean update = shouldConsume() && productionValid();', drill)
        self.assertIn('if(!update){', drill)
        self.assertIn('efficiency = optionalEfficiency = 0f;', drill)
        self.assertIn('return enabled;', drill)
        self.assertIn('public class BurstDrill extends Drill{', drill)
        self.assertIn('public class BurstDrillBuild extends DrillBuild{', drill)
        self.assertIn('return items.total() <= itemCapacity - dominantItems && enabled;', drill)
        self.assertIn('consumeLiquid(Liquids.water, 0.05f).boost();', drill)
        self.assertIn('consumePower(1.10f);', drill)
        self.assertIn('itemCapacity = 20;', drill)
        self.assertIn('return build.power.status;', drill)
        # The driver reads the gate through the pure function
        # (the N2188/N2198 gate precedent) instead of the old
        # inline line, and the N2147 power row is preserved.
        self.assertIn('var gate: Dictionary = source_drill_should_consume_state(frame, int(block.properties["itemCapacity"]))', drill)
        self.assertIn('var should_consume: bool = bool(gate.get("should_consume", false))', drill)
        self.assertIn('static func source_drill_power_status_row_state', drill)
        # The old driver line (the inline gate, the whole line
        # including its line end) is gone.
        self.assertNotIn('\n\t\tvar should_consume: bool = inventory.items_total(frame["items"]) < block.properties["itemCapacity"] and frame["enabled"] and frame["dominant_item"] != null\n', drill)
        # The proof's keys drive the pure gate (open when items
        # are below capacity with a dominant item and enabled;
        # closed when full, when ore-less, when disabled) plus
        # the live tick (efficiency 0 when the gate is closed,
        # old N2147 behavior kept when the gate is open). There
        # are no draw/bar keys: setBars / draw (Drill.java:114,
        # :346) wait for their own slices, and the BurstDrill
        # gate (BurstDrill.java:129) is N2203's slice -- this
        # proof places a laser-drill, a base Drill.
        # Static checks: the proof preloads the family state
        # file that exists, and the scene file references the
        # proof script that exists.
        proof = DRILL_SHOULD_CONSUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'gate_open_when_items_below_capacity',
            'gate_closed_when_items_full',
            'gate_closed_when_no_dominant_item',
            'gate_closed_when_disabled',
            'efficiency_zero_when_gate_closed',
            'efficiency_kept_when_gate_open',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceDrillConsumptionRuntimeState.gd")', proof)
        self.assertIn('write_proof("C07DrillShouldConsumeProof"', proof)
        self.assertTrue(DRILL_STATE.is_file())
        scene = DRILL_SHOULD_CONSUME_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07DrillShouldConsumeProof.gd', scene)
        self.assertIn('[node name="C07DrillShouldConsumeProof" type="Node"]', scene)

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
            'gate_open_when_items_below_capacity',
            'gate_closed_when_items_full',
            'gate_closed_when_no_dominant_item',
            'gate_closed_when_disabled',
            'efficiency_zero_when_gate_closed',
            'efficiency_kept_when_gate_open',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
