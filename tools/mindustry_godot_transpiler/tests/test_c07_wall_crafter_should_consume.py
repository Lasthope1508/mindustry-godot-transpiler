import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
WALL_CRAFTER_STATE = ROOT / 'godot-mindustry/src/game/SourceWallCrafterBuildState.gd'
DRILL_INVENTORY_STATE = ROOT / 'godot-mindustry/src/game/SourceDrillInventoryRuntimeState.gd'
WALL_CRAFTER_SHOULD_CONSUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WallCrafterShouldConsumeProof.gd'
WALL_CRAFTER_SHOULD_CONSUME_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WallCrafterShouldConsumeProof.tscn'


class C07WallCrafterShouldConsumeTests(unittest.TestCase):
    def test_c07_wall_crafter_should_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2201']['godot_owner'], 'SourceWallCrafterBuildState.source_wall_crafter_should_consume_state')
        # N2170 gave the wall crafter its live power.status read --
        # a pure power row over the stamped frame value, folded by
        # the shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) -- but RED-deferred the shouldConsume
        # gate: the port tracked NO items state on any
        # placed-building frame, so the machinery ran with
        # should_consume=true when enabled (the MendProjector
        # suppression precedent) -- a wall crafter with a full
        # output store kept consuming power while Java efficiency
        # is 0. WallCrafterBuild overrides shouldConsume
        # (WallCrafter.java:226-228, `return items.get(output) <
        # itemCapacity;`), so the default (BuildingComp.java:755,
        # `return enabled;`) does NOT apply here -- and unlike
        # the Separator/Drill gates this one has NO `&& enabled`:
        # the pure gate must mirror Java exactly and NOT add an
        # enabled term (the driver already runs the machinery
        # only when enabled, so the live path still respects
        # disabled). N2201 wires the gate into the wall
        # crafter's OWN driver (SourceWallCrafterBuildState.gd,
        # frame key "source_wall_crafter_building"): the frame
        # gets an `items` key (Dictionary keyed by item name,
        # default {}, the drill/factory precedent), the pure
        # gate reads the output count through the shared
        # inventory helper (SourceDrillInventoryRuntimeState.
        # item_count -- reused, not re-implemented), and the
        # driver feeds `should_consume` to the machinery, so a
        # full cliff-crusher folds efficiency 0 like Java. The
        # output item comes from the catalog
        # (block.properties["output"], "sand" for both defs --
        # the Java field default, `public Item output =
        # Items.sand;`, WallCrafter.java:43, set explicitly by
        # both defs, Blocks.java:3009/:3024) and the capacity
        # from the catalog too (block.properties["itemCapacity"],
        # 10 for the cliff-crusher -- the Java field default,
        # `public int itemCapacity = 10;`, Block.java:75 -- and
        # 20 for the large-cliff-crusher, Blocks.java:3031).
        # Two new result symbols: the gate and the output count
        # it reads.
        self.assertEqual(
            ledger['N2201']['source_symbols'],
            [
                'source_wall_crafter_should_consume_state_result.should_consume',
                'source_wall_crafter_should_consume_state_result.output_count',
            ],
        )
        for name in ledger['N2201']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/WallCrafter.java',
                    'core/src/mindustry/world/Block.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_wall_crafter_should_consume_state_result.should_consume': 'SourceWallCrafterBuildState.source_wall_crafter_should_consume_state',
                    'source_wall_crafter_should_consume_state_result.output_count': 'SourceWallCrafterBuildState.source_wall_crafter_should_consume_state',
                }[name])
        self.assertEqual(ledger['N2201']['runtime_proof'], '/root/C07WallCrafterShouldConsumeProof')
        self.assertEqual(
            ledger['N2201']['tests'],
            [
                'test_c07_wall_crafter_should_consume_registration',
                'test_all_c07_wall_crafter_should_consume_input_evidence_is_exact',
                'test_wall_crafter_should_consume_gate_state',
                'test_reference_graph_and_actual_c07_wall_crafter_should_consume',
            ],
        )
        self.assertTrue(ledger['N2201']['deferred_exprs'])
        # This slice resolves the N2170 WallCrafter gate
        # deferral, so the gate entry is gone from DEFERRED --
        # while the updateTile advance, boosters, attribute /
        # efficiency rows, setBars, and draw rows stay deferred.
        self.assertFalse(any(entry.startswith('WallCrafter shouldConsume gate (') for entry in ledger['N2201']['deferred_exprs']))

    def test_all_c07_wall_crafter_should_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2201']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_wall_crafter_should_consume_state_result.should_consume': 'SourceWallCrafterBuildState.source_wall_crafter_should_consume_state',
                    'source_wall_crafter_should_consume_state_result.output_count': 'SourceWallCrafterBuildState.source_wall_crafter_should_consume_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/production/WallCrafter.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2201']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_wall_crafter_should_consume_gate_state(self):
        wall_crafter = WALL_CRAFTER_STATE.read_text(encoding='utf-8')
        # The pure gate lives on the wall-crafter build state:
        # WallCrafterBuild overrides shouldConsume
        # (WallCrafter.java:226, `public boolean shouldConsume(){`
        # with `return items.get(output) < itemCapacity;`,
        # WallCrafter.java:227) -- WallCrafter extends Block
        # (WallCrafter.java:25, `public class WallCrafter extends
        # Block{`) and WallCrafterBuild extends Building
        # (WallCrafter.java:183, `public class WallCrafterBuild
        # extends Building{`), so the default
        # (BuildingComp.java:755, `public boolean shouldConsume(){`
        # with `return enabled;`) does NOT apply here. The gate
        # has NO `&& enabled` -- unlike the Separator/Drill
        # gates, Java returns the bare capacity comparison, so
        # the pure gate must NOT read frame["enabled"] at all.
        # The output item is sand for both defs (the Java field
        # default, `public Item output = Items.sand;`,
        # WallCrafter.java:43, set explicitly by both defs,
        # `output = Items.sand;`, Blocks.java:3009/:3024) and
        # the capacity is the catalog itemCapacity (10 for the
        # cliff-crusher, the Java field default, `public int
        # itemCapacity = 10;`, Block.java:75; 20 for the
        # large-cliff-crusher, `itemCapacity = 20;`,
        # Blocks.java:3031). When the gate is false
        # updateConsumption forces efficiency to zero
        # (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();` + 1992,
        # `if(!update){`). The frame carries an `items` key
        # (Dictionary keyed by item name, default {}, the
        # drill/factory precedent -- the Building.items
        # ItemModule); the count comes from the shared
        # inventory helper (SourceDrillInventoryRuntimeState.
        # item_count, reused through a preload, NOT
        # re-implemented). No live intake fills frame["items"]
        # yet -- the offload/dump intake is the updateTile
        # advance (WallCrafter.java:213-222), which waits for
        # its own slice; the gate reads the frame as-is.
        self.assertIn('static func source_wall_crafter_should_consume_state', wall_crafter)
        self.assertIn('public boolean shouldConsume(){', wall_crafter)
        self.assertIn('return items.get(output) < itemCapacity;', wall_crafter)
        self.assertIn('public class WallCrafter extends Block{', wall_crafter)
        self.assertIn('public class WallCrafterBuild extends Building{', wall_crafter)
        self.assertIn('public Item output = Items.sand;', wall_crafter)
        self.assertIn('public int itemCapacity = 10;', wall_crafter)
        self.assertIn('output = Items.sand;', wall_crafter)
        self.assertIn('itemCapacity = 20;', wall_crafter)
        self.assertIn('boolean update = shouldConsume() && productionValid();', wall_crafter)
        self.assertIn('if(!update){', wall_crafter)
        self.assertIn('"items": {}', wall_crafter)
        self.assertIn('preload("res://src/game/SourceDrillInventoryRuntimeState.gd")', wall_crafter)
        self.assertIn('inventory.item_count(', wall_crafter)
        self.assertIn('block.properties.get("output", "sand")', wall_crafter)
        self.assertIn('block.properties.get("itemCapacity", 10)', wall_crafter)
        # The driver feeds the live gate to the machinery: the
        # gate call with the catalog output/capacity, and the
        # gate result folded into should_consume. The pure gate
        # takes the frame plus the two catalog values -- it does
        # NOT take enabled, and the driver does not AND enabled
        # into the gate result (the outer tick guard already
        # runs the machinery only when enabled).
        self.assertIn('static func source_wall_crafter_tick_buildings_state', wall_crafter)
        self.assertIn('source_wall_crafter_should_consume_state(frame, output_item, item_capacity)', wall_crafter)
        self.assertIn('bool(gate.get("should_consume", true))', wall_crafter)
        # The documented limits record the gate as live; the old
        # N2170 deferral text is gone. The N2170 power row is
        # preserved.
        self.assertIn('shouldConsume gate live (N2201)', wall_crafter)
        self.assertNotIn('runs with should_consume=true when enabled', wall_crafter)
        self.assertIn('static func source_wall_crafter_power_status_row_state', wall_crafter)
        # The shared inventory helper exists and counts by item
        # name (the gate reuses it, it does not re-implement
        # item_count).
        inventory = DRILL_INVENTORY_STATE.read_text(encoding='utf-8')
        self.assertIn('static func item_count(items: Dictionary, item_id: String) -> int:', inventory)
        # The proof's keys drive the pure gate (true below
        # capacity, false at capacity, INDEPENDENT of enabled --
        # the no-enabled point) plus the live tick (efficiency 0
        # when the gate is false, the N2170 power fold preserved
        # when the gate is true, and the large def's capacity 20
        # read from the catalog). There are no warmup / time /
        # offload keys: the updateTile advance (WallCrafter.java:
        # 187-223) waits for its own slice, so the warmup fold
        # (WallCrafter.java:193) is what the efficiency keys
        # prove. Static checks: the proof preloads the family
        # state file that exists, and the scene file references
        # the proof script that exists.
        proof = WALL_CRAFTER_SHOULD_CONSUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'gate_true_below_capacity',
            'gate_false_at_capacity',
            'gate_ignores_enabled',
            'efficiency_zero_when_gate_false',
            'efficiency_folds_power_when_gate_true',
            'large_def_capacity_twenty',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceWallCrafterBuildState.gd")', proof)
        self.assertTrue(WALL_CRAFTER_STATE.is_file())
        scene = WALL_CRAFTER_SHOULD_CONSUME_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07WallCrafterShouldConsumeProof.gd', scene)
        self.assertTrue(WALL_CRAFTER_SHOULD_CONSUME_PROOF.is_file())

    def test_reference_graph_and_actual_c07_wall_crafter_should_consume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07WallCrafterShouldConsumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_WALL_CRAFTER_SHOULD_CONSUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'gate_true_below_capacity',
            'gate_false_at_capacity',
            'gate_ignores_enabled',
            'efficiency_zero_when_gate_false',
            'efficiency_folds_power_when_gate_true',
            'large_def_capacity_twenty',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
