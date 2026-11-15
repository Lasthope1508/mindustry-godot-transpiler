import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FRACKER_STATE = ROOT / 'godot-mindustry/src/game/SourceFrackerBuildState.gd'
LIQUID_MODULE_STATE = ROOT / 'godot-mindustry/src/game/SourceLiquidModuleState.gd'
FRACKER_SHOULD_CONSUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07FrackerShouldConsumeProof.gd'
FRACKER_SHOULD_CONSUME_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07FrackerShouldConsumeProof.tscn'


class C07FrackerShouldConsumeTests(unittest.TestCase):
    def test_c07_fracker_should_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2207']['godot_owner'], 'SourceFrackerBuildState.source_fracker_should_consume_state')
        # N2153 gave the fracker its live power.status read --
        # a pure power row over the stamped frame value, folded by
        # the shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) -- but RED-deferred the shouldConsume
        # gate: the port tracked NO liquid state on any
        # placed-building frame, so the machinery ran with
        # should_consume=true when enabled (the MendProjector
        # suppression precedent) -- a fracker with a full oil
        # store kept consuming power while Java efficiency is 0.
        # FrackerBuild does NOT override shouldConsume
        # (Fracker.java has no shouldConsume at all; Fracker
        # extends SolidPump, Fracker.java:7, and FrackerBuild
        # extends SolidPumpBuild, Fracker.java:26), so it
        # inherits SolidPumpBuild.shouldConsume verbatim
        # (SolidPump.java:117-119, `return liquids.get(result) <
        # liquidCapacity - 0.01f;`) -- and unlike the
        # Separator/Drill gates this one has NO `&& enabled`:
        # the pure gate must mirror Java exactly and NOT add an
        # enabled term (the driver already runs the machinery
        # only when enabled, so the live path still respects
        # disabled). N2207 wires the gate into the fracker's OWN
        # driver (SourceFrackerBuildState.gd, frame key
        # "source_fracker_building", the N2198 inherited-gate
        # precedent): the frame gets a `liquids` key (the
        # Building.liquids LiquidModule dict, synced from the
        # sprite meta store each tick), the pure gate reads the
        # result amount through the shared liquid module helper
        # (SourceLiquidModuleState.source_get_state -- reused,
        # not re-implemented), and the driver feeds
        # `should_consume` to the machinery, so a full
        # oil-extractor folds efficiency 0 like Java. The
        # result liquid is oil for the only Fracker def
        # (Blocks.java:2966, `result = Liquids.oil;` -- the
        # class default is water, SolidPump.java:22) and the
        # capacity is 40f (Blocks.java:2971, `liquidCapacity =
        # 40f;` -- the class default is -1f, Block.java:77);
        # the catalog carries NEITHER property for the
        # oil-extractor, so both arrive as def constants
        # (the N2190 fogRadius / N2199 transportTime precedent).
        # Two new result symbols: the gate and the result
        # amount it reads.
        self.assertEqual(
            ledger['N2207']['source_symbols'],
            [
                'source_fracker_should_consume_state_result.should_consume',
                'source_fracker_should_consume_state_result.result_amount',
            ],
        )
        for name in ledger['N2207']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/production/SolidPump.java')
                self.assertEqual(symbol['godot_owner'], 'SourceFrackerBuildState.source_fracker_should_consume_state')
        self.assertEqual(ledger['N2207']['runtime_proof'], '/root/C07FrackerShouldConsumeProof')
        self.assertEqual(
            ledger['N2207']['tests'],
            [
                'test_c07_fracker_should_consume_registration',
                'test_all_c07_fracker_should_consume_input_evidence_is_exact',
                'test_fracker_should_consume_gate_state',
                'test_reference_graph_and_actual_c07_fracker_should_consume',
            ],
        )
        self.assertTrue(ledger['N2207']['deferred_exprs'])
        # This slice resolves the N2153 Fracker gate deferral,
        # so the gate entry is gone from DEFERRED -- while the
        # updateTile advance, the sand/water second consumers,
        # and the water-attribute / validTiles / boost fraction
        # rows stay deferred.
        self.assertFalse(any(entry.startswith('Fracker shouldConsume gate (') for entry in ledger['N2207']['deferred_exprs']))

    def test_all_c07_fracker_should_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2207']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceFrackerBuildState.source_fracker_should_consume_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/production/SolidPump.java',
            'core/src/mindustry/world/blocks/production/Fracker.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2207']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_fracker_should_consume_gate_state(self):
        fracker = FRACKER_STATE.read_text(encoding='utf-8')
        # The pure gate lives on the fracker build state:
        # FrackerBuild does NOT override shouldConsume
        # (Fracker.java has no shouldConsume at all; Fracker
        # extends SolidPump, Fracker.java:7, `public class
        # Fracker extends SolidPump{`, and FrackerBuild extends
        # SolidPumpBuild, Fracker.java:26, `public class
        # FrackerBuild extends SolidPumpBuild{`), so it inherits
        # SolidPumpBuild.shouldConsume verbatim
        # (SolidPump.java:117, `public boolean shouldConsume(){`
        # with `return liquids.get(result) < liquidCapacity -
        # 0.01f;`, SolidPump.java:118) -- and the default
        # (BuildingComp.java:755, `public boolean
        # shouldConsume(){` with `return enabled;`) does NOT
        # apply either. The gate has NO `&& enabled` -- unlike
        # the Separator/Drill gates, Java returns the bare
        # capacity comparison, so the pure gate must NOT read
        # frame["enabled"] at all. The result liquid is oil for
        # the only Fracker def (the class default is water,
        # `public Liquid result = Liquids.water;`,
        # SolidPump.java:22, overridden by the def, `result =
        # Liquids.oil;`, Blocks.java:2966) and the capacity is
        # the def constant 40f (`liquidCapacity = 40f;`,
        # Blocks.java:2971; the class default is -1f, `public
        # float liquidCapacity = -1f;`, Block.java:77) -- the
        # catalog carries neither property for the
        # oil-extractor. When the gate is false
        # updateConsumption forces efficiency to zero
        # (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();` + 1992,
        # `if(!update){`). The frame carries a `liquids` key
        # (the Building.liquids LiquidModule dict, default {},
        # synced from the sprite meta store each tick by the
        # driver); the amount comes from the shared liquid
        # module helper (SourceLiquidModuleState.
        # source_get_state, reused through a preload, NOT
        # re-implemented) with the result liquid's catalog id,
        # resolved by the driver through the content registry
        # (liquid_id_by_name, the factory precedent). No live
        # intake fills the oil store yet -- the pump advance is
        # the updateTile advance (Fracker.java:30-44 /
        # SolidPump.java:121-141), which waits for its own
        # slice; the gate reads the frame as-is.
        self.assertIn('static func source_fracker_should_consume_state', fracker)
        self.assertIn('public boolean shouldConsume(){', fracker)
        self.assertIn('return liquids.get(result) < liquidCapacity - 0.01f;', fracker)
        self.assertIn('public class Fracker extends SolidPump{', fracker)
        self.assertIn('public class FrackerBuild extends SolidPumpBuild{', fracker)
        self.assertIn('public Liquid result = Liquids.water;', fracker)
        self.assertIn('result = Liquids.oil;', fracker)
        self.assertIn('liquidCapacity = 40f;', fracker)
        self.assertIn('public float liquidCapacity = -1f;', fracker)
        self.assertIn('boolean update = shouldConsume() && productionValid();', fracker)
        self.assertIn('if(!update){', fracker)
        self.assertIn('"liquids": {}', fracker)
        self.assertIn('preload("res://src/game/SourceLiquidModuleState.gd")', fracker)
        self.assertIn('source_liquid_module_state.source_get_state(', fracker)
        self.assertIn('preload("res://src/game/SourceContentRegistryRuntimeState.gd")', fracker)
        self.assertIn('liquid_id_by_name', fracker)
        # The driver feeds the live gate to the machinery: the
        # gate call with the resolved result id and the def
        # capacity constant, and the gate result folded into
        # should_consume. The pure gate takes the frame plus
        # the result id and the capacity -- it does NOT take
        # enabled, and the driver does not AND enabled into the
        # gate result (the outer tick guard already runs the
        # machinery only when enabled).
        self.assertIn('static func source_fracker_tick_buildings_state', fracker)
        self.assertIn('source_fracker_should_consume_state(frame, result_liquid_id, SOURCE_FRACKER_LIQUID_CAPACITY)', fracker)
        self.assertIn('bool(gate.get("should_consume", true))', fracker)
        # The documented limits record the gate as live; the old
        # N2153 deferral text is gone. The N2153 power row is
        # preserved.
        self.assertIn('shouldConsume gate live (N2207)', fracker)
        self.assertNotIn('runs with should_consume=true when enabled', fracker)
        self.assertIn('static func source_fracker_power_status_row_state', fracker)
        # The shared liquid module helper exists and reads an
        # amount by liquid id (the gate reuses it, it does not
        # re-implement the module read).
        liquid_module = LIQUID_MODULE_STATE.read_text(encoding='utf-8')
        self.assertIn('static func source_get_state(self_state: Dictionary, liquid_id: int) -> Dictionary:', liquid_module)
        # The proof's keys drive the pure gate (true below
        # capacity, false at capacity, INDEPENDENT of enabled --
        # the no-enabled point) plus the live tick (efficiency 0
        # when the gate is false, the N2153 power fold preserved
        # when the gate is true, and the def constants: result
        # oil, not water, and capacity 40f with the -0.01f
        # epsilon). There are no warmup / accumulator / pump
        # keys: the updateTile advance (Fracker.java:30-44 /
        # SolidPump.java:121-141) waits for its own slice, so
        # the accumulator/speed fold (Fracker.java:38,
        # SolidPump.java:121) is what the efficiency keys prove.
        # Static checks: the proof preloads the family state
        # file that exists, and the scene file references the
        # proof script that exists.
        proof = FRACKER_SHOULD_CONSUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'gate_true_below_capacity',
            'gate_false_at_capacity',
            'gate_ignores_enabled',
            'efficiency_zero_when_gate_false',
            'efficiency_folds_power_when_gate_true',
            'def_constant_oil_capacity_forty',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceFrackerBuildState.gd")', proof)
        self.assertTrue(FRACKER_STATE.is_file())
        scene = FRACKER_SHOULD_CONSUME_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07FrackerShouldConsumeProof.gd', scene)
        self.assertTrue(FRACKER_SHOULD_CONSUME_PROOF.is_file())

    def test_reference_graph_and_actual_c07_fracker_should_consume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07FrackerShouldConsumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_FRACKER_SHOULD_CONSUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'gate_true_below_capacity',
            'gate_false_at_capacity',
            'gate_ignores_enabled',
            'efficiency_zero_when_gate_false',
            'efficiency_folds_power_when_gate_true',
            'def_constant_oil_capacity_forty',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
