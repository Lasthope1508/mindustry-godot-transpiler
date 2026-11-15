import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BURST_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBurstDrillBuildState.gd'
BURST_DRILL_SHOULD_CONSUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BurstDrillShouldConsumeProof.gd'
BURST_DRILL_SHOULD_CONSUME_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BurstDrillShouldConsumeProof.tscn'


class C07BurstDrillShouldConsumeTests(unittest.TestCase):
    def test_c07_burst_drill_should_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2203']['godot_owner'], 'SourceBurstDrillBuildState.source_burst_drill_should_consume_state')
        # N2149 wired the burst drill's live power.status read but
        # left its shouldConsume gate deferred: BurstDrillBuild
        # HAS a shouldConsume override (BurstDrill.java:128-130,
        # `return items.total() <= itemCapacity - dominantItems
        # && enabled;`) -- the gate needs items/dominant state
        # the tick did not track yet, so the machinery ran with
        # should_consume=true when enabled (the MendProjector
        # suppression precedent). N2203 wires the gate: the
        # driver reads should_consume through the pure
        # source_burst_drill_should_consume_state function (the
        # N2188/N2198 gate precedent), which is the override
        # exactly -- `<=` (NOT `<`) and `itemCapacity -
        # dominantItems` (NOT itemCapacity alone), INCLUDING the
        # enabled check. The override replaces the base-Drill
        # gate (Drill.java:247-249, `return items.total() <
        # itemCapacity && enabled && dominantItem != null;`),
        # which does NOT apply to BurstDrill -- BurstDrill
        # extends Drill (BurstDrill.java:17) and BurstDrillBuild
        # extends DrillBuild (BurstDrill.java:70), so the
        # override wins. The frame is the SHARED drill frame
        # ("source_drill_building"): the drill proximity path
        # binds it at placement with items/dominant_item/
        # dominant_items/enabled already present and sets
        # dominant_items from the ore count (Drill.java:270-277,
        # onProximityUpdate -> countOre -> `dominantItems =
        # returnCount;`), so the burst-drill bind in the tick
        # returns applied=false and the gate reads the shared
        # keys; itemCapacity comes from the block properties
        # (eruption 60, impact 40, Block.java default 10). When
        # the gate is false, updateConsumption forces
        # efficiency to zero (BuildingComp.java:1960, `boolean
        # update = shouldConsume() && productionValid();`, with
        # BuildingComp.java:1992-1994, `if(!update){` /
        # `efficiency = optionalEfficiency = 0f;`), so a full
        # burst drill no longer reads power.status 1.0 while
        # Java efficiency is 0. Two new result symbols: the gate
        # verdict and the items total it read.
        self.assertEqual(
            ledger['N2203']['source_symbols'],
            [
                'source_burst_drill_should_consume_state_result.should_consume',
                'source_burst_drill_should_consume_state_result.items_total',
            ],
        )
        for name in ledger['N2203']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/BurstDrill.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_burst_drill_should_consume_state_result.should_consume': 'SourceBurstDrillBuildState.source_burst_drill_should_consume_state',
                    'source_burst_drill_should_consume_state_result.items_total': 'SourceBurstDrillBuildState.source_burst_drill_should_consume_state',
                }[name])
        self.assertEqual(ledger['N2203']['runtime_proof'], '/root/C07BurstDrillShouldConsumeProof')
        self.assertEqual(
            ledger['N2203']['tests'],
            [
                'test_c07_burst_drill_should_consume_registration',
                'test_all_c07_burst_drill_should_consume_input_evidence_is_exact',
                'test_burst_drill_should_consume_gate_state',
                'test_reference_graph_and_actual_c07_burst_drill_should_consume',
            ],
        )
        self.assertTrue(ledger['N2203']['deferred_exprs'])

    def test_all_c07_burst_drill_should_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2203']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_burst_drill_should_consume_state_result.should_consume': 'SourceBurstDrillBuildState.source_burst_drill_should_consume_state',
                    'source_burst_drill_should_consume_state_result.items_total': 'SourceBurstDrillBuildState.source_burst_drill_should_consume_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/production/BurstDrill.java',
            'core/src/mindustry/world/blocks/production/Drill.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/world/consumers/ConsumePower.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2203']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_burst_drill_should_consume_gate_state(self):
        burst_drill = BURST_DRILL_STATE.read_text(encoding='utf-8')
        # The pure gate is BurstDrillBuild.shouldConsume()
        # exactly (BurstDrill.java:128, `public boolean
        # shouldConsume(){` with `return items.total() <=
        # itemCapacity - dominantItems && enabled;`,
        # BurstDrill.java:129): the burst drill consumes only
        # while its items total fits the remaining capacity
        # AFTER reserving the dominant-items burst AND it is
        # enabled. The `<=` (not `<`) and the `- dominantItems`
        # are the override's whole point -- the base-Drill gate
        # (Drill.java:247-249, `return items.total() <
        # itemCapacity && enabled && dominantItem != null;`)
        # does NOT apply to BurstDrill: BurstDrill extends
        # Drill (BurstDrill.java:17, `public class BurstDrill
        # extends Drill{`) and BurstDrillBuild extends
        # DrillBuild (BurstDrill.java:70, `public class
        # BurstDrillBuild extends DrillBuild{`), so the
        # override wins. The gate reads the SHARED drill frame
        # ("source_drill_building"): the drill proximity path
        # binds it at placement (SourceWorldTerrainRuntimeState
        # calls SourceDrillConsumptionRuntimeState.
        # source_on_proximity_update_state, which binds the
        # full _initial_frame with items/dominant_item/
        # dominant_items/enabled) and sets dominant_items from
        # the ore count (Drill.java:243, `public int
        # dominantItems;`, set at :277, `dominantItems =
        # returnCount;`, via onProximityUpdate -> countOre), so
        # the burst-drill bind in the tick returns
        # applied=false and the gate reads the shared keys.
        # itemCapacity comes from the block properties
        # (eruption `itemCapacity = 60;`, impact `itemCapacity
        # = 40;`, Blocks.java; Block.java:75 default `public
        # int itemCapacity = 10;`). The items total reuses the
        # shared inventory helper (SourceDrillInventoryRuntime-
        # State.items_total), not a second summation. When the
        # gate is false, updateConsumption folds efficiency to
        # 0 (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();`, with
        # BuildingComp.java:1992-1994, `if(!update){` /
        # `efficiency = optionalEfficiency = 0f;`). The power
        # row itself is unchanged (N2149): the pure
        # ConsumePower read (`return build.power.status;`,
        # ConsumePower.java:39) over the stamped frame value,
        # for eruption consumePower 6f and impact consumePower
        # 160f/60f; the burst-drill speed follows the folded
        # efficiency (BurstDrill.java:94, `float speed =
        # Mathf.lerp(1f, liquidBoostIntensity,
        # optionalEfficiency) * efficiency;`). The updateTile
        # burst advance, liquid rows, draw/bars, and the live
        # items fill still wait for their own slices.
        self.assertIn('static func source_burst_drill_should_consume_state', burst_drill)
        self.assertIn('public boolean shouldConsume(){', burst_drill)
        self.assertIn('return items.total() <= itemCapacity - dominantItems && enabled;', burst_drill)
        self.assertIn('return items.total() < itemCapacity && enabled && dominantItem != null;', burst_drill)
        self.assertIn('public int dominantItems;', burst_drill)
        self.assertIn('dominantItems = returnCount;', burst_drill)
        self.assertIn('boolean update = shouldConsume() && productionValid();', burst_drill)
        self.assertIn('if(!update){', burst_drill)
        self.assertIn('efficiency = optionalEfficiency = 0f;', burst_drill)
        self.assertIn('public int itemCapacity = 10;', burst_drill)
        self.assertIn('itemCapacity = 60;', burst_drill)
        self.assertIn('itemCapacity = 40;', burst_drill)
        self.assertIn('public class BurstDrill extends Drill{', burst_drill)
        self.assertIn('public class BurstDrillBuild extends DrillBuild{', burst_drill)
        self.assertIn('return build.power.status;', burst_drill)
        self.assertIn('float speed = Mathf.lerp(1f, liquidBoostIntensity, optionalEfficiency) * efficiency;', burst_drill)
        self.assertIn('preload("res://src/game/SourceDrillInventoryRuntimeState.gd")', burst_drill)
        self.assertIn('source_drill_inventory_runtime_state.items_total(', burst_drill)
        # The driver reads the gate through the pure function
        # (the N2188/N2198 gate precedent) instead of the old
        # `should_consume = enabled` line, and the N2149 power
        # row is preserved.
        self.assertIn('var gate: Dictionary = source_burst_drill_should_consume_state(frame, int(block.properties.get("itemCapacity", 10)))', burst_drill)
        self.assertIn('var should_consume: bool = bool(gate.get("should_consume", false))', burst_drill)
        self.assertIn('static func source_burst_drill_power_status_row_state', burst_drill)
        self.assertIn('static func source_burst_drill_tick_buildings_state', burst_drill)
        # The old driver line (should_consume = enabled alone,
        # the whole line including its line end) is gone.
        self.assertNotIn('\n\t\t\tvar should_consume: bool = bool(frame.get("enabled", true))\n', burst_drill)
        # The proof's keys drive the pure gate (open below the
        # threshold, closed over it, open AT the boundary --
        # the `<=` key -- closed when disabled) plus the live
        # tick (efficiency 0 when the gate is closed, old
        # N2149 behavior kept when the gate is open). There are
        # no progress/burst keys: the updateTile advance
        # (BurstDrill.java:70-125) waits for its own slice, and
        # the live items fill waits with it -- the proof sets
        # frame["items"] directly, like the N2188 proof sets
        # the link directly through the N2197 pure configure.
        # Static checks: the proof preloads the family state
        # file that exists, and the scene file references the
        # proof script that exists.
        proof = BURST_DRILL_SHOULD_CONSUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'gate_open_below_threshold',
            'gate_closed_when_over_threshold',
            'gate_open_at_boundary',
            'gate_closed_when_disabled',
            'efficiency_zero_when_gate_closed',
            'efficiency_kept_when_gate_open',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceBurstDrillBuildState.gd")', proof)
        self.assertIn('write_proof("C07BurstDrillShouldConsumeProof"', proof)
        self.assertTrue(BURST_DRILL_STATE.is_file())
        scene = BURST_DRILL_SHOULD_CONSUME_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07BurstDrillShouldConsumeProof.gd', scene)
        self.assertIn('[node name="C07BurstDrillShouldConsumeProof" type="Node"]', scene)

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
            'gate_open_below_threshold',
            'gate_closed_when_over_threshold',
            'gate_open_at_boundary',
            'gate_closed_when_disabled',
            'efficiency_zero_when_gate_closed',
            'efficiency_kept_when_gate_open',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
