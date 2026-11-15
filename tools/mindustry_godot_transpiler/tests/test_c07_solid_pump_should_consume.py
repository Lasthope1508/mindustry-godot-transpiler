import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SOLID_PUMP_STATE = ROOT / 'godot-mindustry/src/game/SourceSolidPumpBuildState.gd'
LIQUID_MODULE_STATE = ROOT / 'godot-mindustry/src/game/SourceLiquidModuleState.gd'
SOLID_PUMP_SHOULD_CONSUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SolidPumpShouldConsumeProof.gd'
SOLID_PUMP_SHOULD_CONSUME_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SolidPumpShouldConsumeProof.tscn'


class C07SolidPumpShouldConsumeTests(unittest.TestCase):
    def test_c07_solid_pump_should_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2206']['godot_owner'], 'SourceSolidPumpBuildState.source_solid_pump_should_consume_state')
        # N2150 gave the solid pump its live power.status read --
        # a pure power row over the stamped frame value, folded by
        # the shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) -- but RED-deferred the shouldConsume
        # gate: the port tracked NO liquid state on the
        # placed-building frame, so the machinery ran with
        # should_consume=true when enabled (the MendProjector
        # suppression precedent) -- a water-extractor with a full
        # liquid store kept consuming power while Java efficiency
        # is 0. SolidPumpBuild overrides shouldConsume
        # (SolidPump.java:117-119, `return liquids.get(result) <
        # liquidCapacity - 0.01f;`), so the default
        # (BuildingComp.java:755, `return enabled;`) does NOT
        # apply here -- and unlike the Pump/Separator/Drill gates
        # this one has NO `&& enabled`: the pure gate must mirror
        # Java exactly and NOT add an enabled term (the driver
        # already runs the machinery only when enabled, so the
        # live path still respects disabled). N2206 wires the gate
        # into the solid pump's OWN driver
        # (SourceSolidPumpBuildState.gd, frame key
        # "source_solid_pump_building"): the driver refreshes the
        # frame's `liquids` key from the sprite meta each tick
        # (the Building.liquids LiquidModule, initialized at
        # placement through SourcePlacedBlockState), the pure gate
        # reads the result amount through the shared liquid
        # module helper (SourceLiquidModuleState.source_get_state
        # -- reused, not re-implemented), and the driver feeds
        # `should_consume` to the machinery, so a full
        # water-extractor folds efficiency 0 like Java. The
        # result liquid is water (the Java field default, `public
        # Liquid result = Liquids.water;`, SolidPump.java:22, set
        # explicitly by the def, `result = Liquids.water;`,
        # Blocks.java:2922) and the capacity is the def constant
        # 40f (`liquidCapacity = 40f;`, Blocks.java:2925) -- the
        # catalog carries NEITHER property for the
        # water-extractor (the N2190 fogRadius / N2199
        # transportTime def-constant precedent); the class
        # default is -1f (`public float liquidCapacity = -1f;`,
        # Block.java:77) but every pump def sets it explicitly.
        # Two new result symbols: the gate and the result amount
        # it reads.
        self.assertEqual(
            ledger['N2206']['source_symbols'],
            [
                'source_solid_pump_should_consume_state_result.should_consume',
                'source_solid_pump_should_consume_state_result.result_amount',
            ],
        )
        for name in ledger['N2206']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/production/SolidPump.java')
                self.assertEqual(symbol['godot_owner'], {
                    'source_solid_pump_should_consume_state_result.should_consume': 'SourceSolidPumpBuildState.source_solid_pump_should_consume_state',
                    'source_solid_pump_should_consume_state_result.result_amount': 'SourceSolidPumpBuildState.source_solid_pump_should_consume_state',
                }[name])
        self.assertEqual(ledger['N2206']['runtime_proof'], '/root/C07SolidPumpShouldConsumeProof')
        self.assertEqual(
            ledger['N2206']['tests'],
            [
                'test_c07_solid_pump_should_consume_registration',
                'test_all_c07_solid_pump_should_consume_input_evidence_is_exact',
                'test_solid_pump_should_consume_gate_state',
                'test_reference_graph_and_actual_c07_solid_pump_should_consume',
            ],
        )
        self.assertTrue(ledger['N2206']['deferred_exprs'])
        # This slice resolves the N2150 SolidPump gate
        # deferral, so the gate entry is gone from DEFERRED --
        # while the updateTile advance, the water-attribute /
        # validTiles / boost fraction rows, and the new frame
        # liquids intake deferral stay deferred.
        self.assertFalse(any(entry.startswith('SolidPump shouldConsume gate (') for entry in ledger['N2206']['deferred_exprs']))

    def test_all_c07_solid_pump_should_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2206']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_solid_pump_should_consume_state_result.should_consume': 'SourceSolidPumpBuildState.source_solid_pump_should_consume_state',
                    'source_solid_pump_should_consume_state_result.result_amount': 'SourceSolidPumpBuildState.source_solid_pump_should_consume_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/production/SolidPump.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2206']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_solid_pump_should_consume_gate_state(self):
        solid_pump = SOLID_PUMP_STATE.read_text(encoding='utf-8')
        # The pure gate lives on the solid-pump build state:
        # SolidPumpBuild overrides shouldConsume
        # (SolidPump.java:117, `public boolean shouldConsume(){`
        # with `return liquids.get(result) < liquidCapacity -
        # 0.01f;`, SolidPump.java:118) -- SolidPump extends Pump
        # (SolidPump.java:21, `public class SolidPump extends
        # Pump{`) and SolidPumpBuild extends PumpBuild
        # (SolidPump.java:89, `public class SolidPumpBuild
        # extends PumpBuild{`), so the default
        # (BuildingComp.java:755, `public boolean shouldConsume(){`
        # with `return enabled;`) does NOT apply here. The gate
        # has NO `&& enabled` -- unlike the Pump gate, Java
        # returns the bare capacity comparison, so the pure gate
        # must NOT read frame["enabled"] at all. The result
        # liquid is water (the Java field default, `public
        # Liquid result = Liquids.water;`, SolidPump.java:22, set
        # explicitly by the def, `result = Liquids.water;`,
        # Blocks.java:2922) and the capacity is the def constant
        # 40f (`liquidCapacity = 40f;`, Blocks.java:2925) -- the
        # catalog carries neither property for the
        # water-extractor; the class default is -1f (`public
        # float liquidCapacity = -1f;`, Block.java:77) but every
        # pump def sets it explicitly. When the gate is false
        # updateConsumption forces efficiency to zero
        # (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();` + 1992,
        # `if(!update){`). The frame carries a `liquids` key (the
        # Building.liquids LiquidModule state dict, default {},
        # refreshed from the sprite meta each tick by the
        # driver); the amount comes from the shared liquid module
        # helper (SourceLiquidModuleState.source_get_state,
        # reused through a preload, NOT re-implemented), with the
        # result liquid id resolved by the driver from the liquid
        # catalog (liquid_id_by_name). No live intake fills the
        # liquids store yet -- the pump advance is the updateTile
        # advance (SolidPump.java:121-141), which waits for its
        # own slice; the gate reads the store as-is.
        self.assertIn('static func source_solid_pump_should_consume_state', solid_pump)
        self.assertIn('public boolean shouldConsume(){', solid_pump)
        self.assertIn('return liquids.get(result) < liquidCapacity - 0.01f;', solid_pump)
        self.assertIn('public class SolidPump extends Pump{', solid_pump)
        self.assertIn('public class SolidPumpBuild extends PumpBuild{', solid_pump)
        self.assertIn('public Liquid result = Liquids.water;', solid_pump)
        self.assertIn('result = Liquids.water;', solid_pump)
        self.assertIn('liquidCapacity = 40f;', solid_pump)
        self.assertIn('public float liquidCapacity = -1f;', solid_pump)
        self.assertIn('boolean update = shouldConsume() && productionValid();', solid_pump)
        self.assertIn('if(!update){', solid_pump)
        self.assertIn('"liquids": {}', solid_pump)
        self.assertIn('preload("res://src/game/SourceLiquidModuleState.gd")', solid_pump)
        self.assertIn('preload("res://src/game/SourceContentRegistryRuntimeState.gd")', solid_pump)
        self.assertIn('source_liquid_module_state.source_get_state(', solid_pump)
        self.assertIn('SOURCE_BUILDING_LIQUIDS_META_KEY', solid_pump)
        self.assertIn('liquid_id_by_name', solid_pump)
        # The driver feeds the live gate to the machinery: the
        # gate call with the resolved result id and the def
        # capacity constant, and the gate result folded into
        # should_consume. The pure gate takes the frame plus the
        # result liquid id and the capacity -- it does NOT take
        # enabled, and the driver does not AND enabled into the
        # gate result (the outer tick guard already runs the
        # machinery only when enabled).
        self.assertIn('static func source_solid_pump_tick_buildings_state', solid_pump)
        self.assertIn('source_solid_pump_should_consume_state(frame, result_liquid_id, SOURCE_SOLID_PUMP_LIQUID_CAPACITY)', solid_pump)
        self.assertIn('bool(gate.get("should_consume", true))', solid_pump)
        # The documented limits record the gate as live; the old
        # N2150 deferral text is gone. The N2150 power row is
        # preserved.
        self.assertIn('shouldConsume gate live (N2206)', solid_pump)
        self.assertNotIn('runs with should_consume=true when enabled', solid_pump)
        self.assertIn('static func source_solid_pump_power_status_row_state', solid_pump)
        # The shared liquid module helper exists and reads an
        # amount by liquid id (the gate reuses it, it does not
        # re-implement the module read).
        liquid_module = LIQUID_MODULE_STATE.read_text(encoding='utf-8')
        self.assertIn('static func source_get_state(self_state: Dictionary, liquid_id: int) -> Dictionary:', liquid_module)
        # The proof's keys drive the pure gate (true below
        # capacity, false at capacity, INDEPENDENT of enabled --
        # the no-enabled point) plus the live tick (efficiency 0
        # when the gate is false, the N2150 power fold preserved
        # when the gate is true, and the def constant: result
        # water / capacity 40f -- a full oil store does not gate
        # while water below capacity still consumes). There are
        # no warmup / time / validTiles keys: the updateTile
        # advance (SolidPump.java:121-141) waits for its own
        # slice, so the speed fold (SolidPump.java:127) is what
        # the efficiency keys prove. Static checks: the proof
        # preloads the family state file that exists, and the
        # scene file references the proof script that exists.
        proof = SOLID_PUMP_SHOULD_CONSUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'gate_true_below_capacity',
            'gate_false_at_capacity',
            'gate_ignores_enabled',
            'efficiency_zero_when_gate_false',
            'efficiency_folds_power_when_gate_true',
            'def_constant_water_capacity_forty',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceSolidPumpBuildState.gd")', proof)
        self.assertTrue(SOLID_PUMP_STATE.is_file())
        scene = SOLID_PUMP_SHOULD_CONSUME_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07SolidPumpShouldConsumeProof.gd', scene)
        self.assertTrue(SOLID_PUMP_SHOULD_CONSUME_PROOF.is_file())

    def test_reference_graph_and_actual_c07_solid_pump_should_consume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07SolidPumpShouldConsumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SOLID_PUMP_SHOULD_CONSUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'gate_true_below_capacity',
            'gate_false_at_capacity',
            'gate_ignores_enabled',
            'efficiency_zero_when_gate_false',
            'efficiency_folds_power_when_gate_true',
            'def_constant_water_capacity_forty',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
