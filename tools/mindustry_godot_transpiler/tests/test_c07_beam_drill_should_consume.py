import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BEAM_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBeamDrillBuildState.gd'
DRILL_INVENTORY_STATE = ROOT / 'godot-mindustry/src/game/SourceDrillInventoryRuntimeState.gd'
BEAM_DRILL_SHOULD_CONSUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BeamDrillShouldConsumeProof.gd'
BEAM_DRILL_SHOULD_CONSUME_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BeamDrillShouldConsumeProof.tscn'


class C07BeamDrillShouldConsumeTests(unittest.TestCase):
    def test_c07_beam_drill_should_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2202']['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_should_consume_state')
        # N2155 gave the beam drill its live power.status read --
        # a pure power row over the stamped frame value, folded by
        # the shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) -- but RED-deferred the shouldConsume
        # gate: the port tracked NO items or facing state on any
        # placed-beam-drill frame, so the machinery ran with
        # should_consume=true when enabled -- a plasma-bore with a
        # full item store, or facing no wall ore at all, drilled
        # as if power.status were 1.0 while Java efficiency is 0.
        # BeamDrillBuild.shouldConsume (BeamDrill.java:270-271,
        # `return items.total() < itemCapacity && facingAmount > 0
        # && enabled;`) is a three-way conjunction: the item store
        # under capacity, at least one facing wall-ore tile, and
        # enabled. BeamDrill extends Block (BeamDrill.java:25,
        # `public class BeamDrill extends Block{`), NOT Drill, and
        # BeamDrillBuild extends Building (BeamDrill.java:220,
        # `public class BeamDrillBuild extends Building{`), so the
        # gate lives on the beam-drill family's OWN driver
        # (SourceBeamDrillBuildState.gd, frame key
        # "source_beam_drill_building"), not the drill frame.
        # facingAmount is a plain int field (BeamDrill.java:228,
        # `public int facingAmount;`, Java default 0), recomputed
        # by updateFacing() (BeamDrill.java:375-411, called from
        # updateTile :244 and onProximityUpdate :365): for each
        # of the size facing lasers it walks range tiles along
        # the rotation, takes the first solid tile, and counts it
        # when its wallDrop is mineable (`facingAmount = 0;` then
        # `facingAmount ++;` per mineable facing tile,
        # BeamDrill.java:379/:392). updateConsumption runs BEFORE
        # updateTile (BuildingComp.java:2274-2277), so the gate
        # reads the previous tick's facingAmount -- correct per
        # Java, NOT a bug. The live facing scan waits for its own
        # slice (the facing/laser binding deferral stays); this
        # slice adds the frame key (Java default 0) and the pure
        # gate over it, and the driver feeds the gate to the
        # machinery. itemCapacity comes from the catalog
        # (block.properties["itemCapacity"]): 10 for plasma-bore
        # (the Block.java:75 field default, `public int
        # itemCapacity = 10;`) and 20 for large-plasma-bore
        # (Blocks.java:3062, `itemCapacity = 20;`). Three new
        # result symbols: the gate, the items total it reads, and
        # the facing amount it reads.
        self.assertEqual(
            ledger['N2202']['source_symbols'],
            [
                'source_beam_drill_should_consume_state_result.should_consume',
                'source_beam_drill_should_consume_state_result.items_total',
                'source_beam_drill_should_consume_state_result.facing_amount',
            ],
        )
        for name in ledger['N2202']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/BeamDrill.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_beam_drill_should_consume_state_result.should_consume': 'SourceBeamDrillBuildState.source_beam_drill_should_consume_state',
                    'source_beam_drill_should_consume_state_result.items_total': 'SourceBeamDrillBuildState.source_beam_drill_should_consume_state',
                    'source_beam_drill_should_consume_state_result.facing_amount': 'SourceBeamDrillBuildState.source_beam_drill_should_consume_state',
                }[name])
        self.assertEqual(ledger['N2202']['runtime_proof'], '/root/C07BeamDrillShouldConsumeProof')
        self.assertEqual(
            ledger['N2202']['tests'],
            [
                'test_c07_beam_drill_should_consume_registration',
                'test_all_c07_beam_drill_should_consume_input_evidence_is_exact',
                'test_beam_drill_should_consume_gate_state',
                'test_reference_graph_and_actual_c07_beam_drill_should_consume',
            ],
        )
        self.assertTrue(ledger['N2202']['deferred_exprs'])
        # This slice resolves the N2155 BeamDrill gate
        # deferral, so the gate entry is gone from DEFERRED --
        # while the updateTile advance, the facing/laser binding
        # (the live scan that will fill facing_amount), the
        # liquid rows, and the drillMultipliers rows stay
        # deferred.
        self.assertFalse(any(entry.startswith('BeamDrill shouldConsume gate (') for entry in ledger['N2202']['deferred_exprs']))

    def test_all_c07_beam_drill_should_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2202']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_beam_drill_should_consume_state_result.should_consume': 'SourceBeamDrillBuildState.source_beam_drill_should_consume_state',
                    'source_beam_drill_should_consume_state_result.items_total': 'SourceBeamDrillBuildState.source_beam_drill_should_consume_state',
                    'source_beam_drill_should_consume_state_result.facing_amount': 'SourceBeamDrillBuildState.source_beam_drill_should_consume_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/production/BeamDrill.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/world/modules/ItemModule.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2202']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_beam_drill_should_consume_gate_state(self):
        beam_drill = BEAM_DRILL_STATE.read_text(encoding='utf-8')
        # The pure gate lives on the beam-drill build state:
        # BeamDrillBuild.shouldConsume (BeamDrill.java:270,
        # `public boolean shouldConsume(){` with `return
        # items.total() < itemCapacity && facingAmount > 0 &&
        # enabled;`, BeamDrill.java:271) -- a three-way
        # conjunction over the item store, the facing wall-ore
        # count, and enabled. BeamDrill extends Block
        # (BeamDrill.java:25, `public class BeamDrill extends
        # Block{`), NOT Drill, and BeamDrillBuild extends
        # Building (BeamDrill.java:220, `public class
        # BeamDrillBuild extends Building{`), so the gate lives
        # on the beam-drill family's own driver. facingAmount is
        # a plain int field (BeamDrill.java:228, `public int
        # facingAmount;`, Java default 0), recomputed by
        # updateFacing() (BeamDrill.java:375-411, called from
        # updateTile :244 and onProximityUpdate :365):
        # `facingAmount = 0;` then `facingAmount ++;` per
        # mineable facing tile, where mineable is `if(drop !=
        # null && drop.hardness <= tier && (blockedItems == null
        # || !blockedItems.contains(drop))){`
        # (BeamDrill.java:391). When the gate is false
        # updateConsumption forces efficiency to zero
        # (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();` + 1992,
        # `if(!update){`). updateConsumption runs before
        # updateTile (BuildingComp.java:2274-2277,
        # `updateConsumption();` then `if(enabled ||
        # !block.noUpdateDisabled){` / `updateTile();`), so the
        # gate reads the previous tick's facingAmount -- correct
        # per Java, NOT a bug. itemCapacity comes from the
        # catalog (block.properties["itemCapacity"]): 10 for
        # plasma-bore (the Block.java:75 field default, `public
        # int itemCapacity = 10;`) and 20 for large-plasma-bore
        # (Blocks.java:3062, `itemCapacity = 20;`). The items
        # total reuses the drill inventory helper
        # (SourceDrillInventoryRuntimeState.items_total), it is
        # NOT recomputed a second way. The live facing scan and
        # the production advance that fills frame items wait for
        # their own slices -- the gate reads the current frame.
        self.assertIn('static func source_beam_drill_should_consume_state', beam_drill)
        self.assertIn('items_total < item_capacity and facing_amount > 0 and enabled', beam_drill)
        self.assertIn('public boolean shouldConsume(){', beam_drill)
        self.assertIn('return items.total() < itemCapacity && facingAmount > 0 && enabled;', beam_drill)
        self.assertIn('public class BeamDrill extends Block{', beam_drill)
        self.assertIn('public class BeamDrillBuild extends Building{', beam_drill)
        self.assertIn('public int facingAmount;', beam_drill)
        self.assertIn('facingAmount = 0;', beam_drill)
        self.assertIn('facingAmount ++;', beam_drill)
        self.assertIn('updateFacing();', beam_drill)
        self.assertIn('if(drop != null && drop.hardness <= tier && (blockedItems == null || !blockedItems.contains(drop))){', beam_drill)
        self.assertIn('public int itemCapacity = 10;', beam_drill)
        self.assertIn('itemCapacity = 20;', beam_drill)
        self.assertIn('boolean update = shouldConsume() && productionValid();', beam_drill)
        self.assertIn('if(!update){', beam_drill)
        self.assertIn('updateConsumption();', beam_drill)
        self.assertIn('if(enabled || !block.noUpdateDisabled){', beam_drill)
        self.assertIn('"items": {}', beam_drill)
        self.assertIn('"facing_amount": 0', beam_drill)
        self.assertIn('frame["items"]', beam_drill)
        self.assertIn('frame["facing_amount"]', beam_drill)
        self.assertIn('preload("res://src/game/SourceDrillInventoryRuntimeState.gd")', beam_drill)
        self.assertIn('source_drill_inventory_runtime_state.items_total(', beam_drill)
        # The driver feeds the live gate to the machinery: the
        # gate call with the catalog itemCapacity, the
        # enabled-and-gate fold, and the Java field default 10
        # when the catalog carries no itemCapacity.
        self.assertIn('static func source_beam_drill_tick_buildings_state', beam_drill)
        self.assertIn('source_beam_drill_should_consume_state(frame, int(block.properties.get("itemCapacity", 10)))', beam_drill)
        self.assertIn('bool(gate.get("should_consume", true))', beam_drill)
        # The documented limits record the gate as live; the old
        # N2155 deferral text is gone. The N2155 power row is
        # preserved.
        self.assertIn('shouldConsume gate live (N2202)', beam_drill)
        self.assertNotIn('runs with should_consume=true when enabled', beam_drill)
        self.assertIn('static func source_beam_drill_power_status_row_state', beam_drill)
        # The proof's keys drive the pure gate (true with all
        # three conditions, false when the item store is full,
        # false with no facing ore, false when disabled) plus
        # the live tick (efficiency 0 when the gate is false,
        # the N2155 power fold preserved when the gate is true).
        # There are no facing-scan / warmup / production keys:
        # the facing scan (updateFacing, BeamDrill.java:375-411)
        # and the production advance (BeamDrill.java:253-261)
        # wait for their own slices, so the proof sets
        # facing_amount and items on the frame directly. Static
        # checks: the proof preloads the beam-drill state file
        # that exists, and the scene file references the proof
        # script that exists.
        proof = BEAM_DRILL_SHOULD_CONSUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'gate_true_when_all_three_conditions',
            'gate_false_when_items_full',
            'gate_false_when_no_facing',
            'gate_false_when_disabled',
            'efficiency_zero_when_gate_false',
            'efficiency_folds_power_when_gate_true',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceBeamDrillBuildState.gd")', proof)
        self.assertIn('beam_drill_build_state.source_beam_drill_should_consume_state(', proof)
        self.assertTrue(BEAM_DRILL_STATE.is_file())
        self.assertTrue(DRILL_INVENTORY_STATE.is_file())
        scene = BEAM_DRILL_SHOULD_CONSUME_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07BeamDrillShouldConsumeProof.gd', scene)
        self.assertTrue(BEAM_DRILL_SHOULD_CONSUME_PROOF.is_file())

    def test_reference_graph_and_actual_c07_beam_drill_should_consume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BeamDrillShouldConsumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BEAM_DRILL_SHOULD_CONSUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'gate_true_when_all_three_conditions',
            'gate_false_when_items_full',
            'gate_false_when_no_facing',
            'gate_false_when_disabled',
            'efficiency_zero_when_gate_false',
            'efficiency_folds_power_when_gate_true',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
