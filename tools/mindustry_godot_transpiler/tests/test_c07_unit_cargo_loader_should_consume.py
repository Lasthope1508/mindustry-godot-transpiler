import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
UNIT_CARGO_LOADER_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitCargoLoaderBuildState.gd'
UNIT_CARGO_LOADER_SHOULD_CONSUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitCargoLoaderShouldConsumeProof.gd'
UNIT_CARGO_LOADER_SHOULD_CONSUME_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitCargoLoaderShouldConsumeProof.tscn'


class C07UnitCargoLoaderShouldConsumeTests(unittest.TestCase):
    def test_c07_unit_cargo_loader_should_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2211']['godot_owner'], 'SourceUnitCargoLoaderBuildState.source_unit_cargo_loader_should_consume_state')
        # N2165 gave the unit-cargo-loader its live power.status read --
        # a pure power row over the stamped frame value, folded by
        # the shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) -- but RED-deferred the shouldConsume
        # gate: the port tracked NO unit state on the
        # unit-cargo-loader frame, so the machinery ran with
        # should_consume=true when enabled (the MendProjector
        # suppression precedent) -- when full power.status reads
        # 1.0 while Java efficiency is 0. UnitTransportSourceBuild
        # overrides shouldConsume (UnitCargoLoader.java:141-143):
        # `return unit == null;` -- the gate is INVERTED: the
        # loader consumes while it has NO unit yet (still building
        # one) and stops consuming once a unit waits to be loaded.
        # The field is `public @Nullable Unit unit;`
        # (UnitCargoLoader.java:89) on UnitTransportSourceBuild
        # (`public class UnitTransportSourceBuild extends Building
        # implements UnitTetherBlock{`, UnitCargoLoader.java:84).
        # N2211 wires the gate into the unit-cargo-loader's OWN
        # driver (SourceUnitCargoLoaderBuildState.gd, frame key
        # "source_unit_cargo_loader_building"): the frame gets a
        # `unit` key (default null, the Java field nullable), the
        # pure gate returns `unit == null` plus the null-ness it
        # read, and the driver feeds `should_consume = unit ==
        # null` to the machinery, so a loader with a unit waiting
        # folds efficiency 0 like Java. No live fill sets
        # frame["unit"] yet -- the gate reads the frame as-is, and
        # the unit spawn / readUnitId fill waits for its own slice
        # (new deferral). Two new result symbols: the gate and the
        # has_unit flag it reads.
        self.assertEqual(
            ledger['N2211']['source_symbols'],
            [
                'source_unit_cargo_loader_should_consume_state_result.should_consume',
                'source_unit_cargo_loader_should_consume_state_result.has_unit',
            ],
        )
        for name in ledger['N2211']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/units/UnitCargoLoader.java')
                self.assertEqual(symbol['godot_owner'], {
                    'source_unit_cargo_loader_should_consume_state_result.should_consume': 'SourceUnitCargoLoaderBuildState.source_unit_cargo_loader_should_consume_state',
                    'source_unit_cargo_loader_should_consume_state_result.has_unit': 'SourceUnitCargoLoaderBuildState.source_unit_cargo_loader_should_consume_state',
                }[name])
        self.assertEqual(ledger['N2211']['runtime_proof'], '/root/C07UnitCargoLoaderShouldConsumeProof')
        self.assertEqual(
            ledger['N2211']['tests'],
            [
                'test_c07_unit_cargo_loader_should_consume_registration',
                'test_all_c07_unit_cargo_loader_should_consume_input_evidence_is_exact',
                'test_unit_cargo_loader_should_consume_gate_state',
                'test_reference_graph_and_actual_c07_unit_cargo_loader_should_consume',
            ],
        )
        self.assertTrue(ledger['N2211']['deferred_exprs'])
        # This slice resolves the N2165 UnitCargoLoader gate
        # deferral, so the gate entry is gone from DEFERRED --
        # while the updateTile advance, liquid nitrogen row, unit
        # spawn rows, canPlaceOn, bars, draw, and read/write rows
        # stay deferred.
        self.assertFalse(any(entry.startswith('UnitCargoLoader shouldConsume gate (') for entry in ledger['N2211']['deferred_exprs']))

    def test_all_c07_unit_cargo_loader_should_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2211']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_unit_cargo_loader_should_consume_state_result.should_consume': 'SourceUnitCargoLoaderBuildState.source_unit_cargo_loader_should_consume_state',
                    'source_unit_cargo_loader_should_consume_state_result.has_unit': 'SourceUnitCargoLoaderBuildState.source_unit_cargo_loader_should_consume_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/units/UnitCargoLoader.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2211']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_unit_cargo_loader_should_consume_gate_state(self):
        unit_cargo_loader = UNIT_CARGO_LOADER_STATE.read_text(encoding='utf-8')
        # The pure gate lives on the unit-cargo-loader build
        # state: UnitTransportSourceBuild.shouldConsume()
        # (UnitCargoLoader.java:141, `public boolean
        # shouldConsume(){` with `return unit == null;`,
        # UnitCargoLoader.java:142) -- the gate is INVERTED:
        # consume while NO unit is held (still building one),
        # stop once a unit waits to be loaded. The field is
        # `public @Nullable Unit unit;`
        # (UnitCargoLoader.java:89) on UnitTransportSourceBuild
        # (`public class UnitTransportSourceBuild extends
        # Building implements UnitTetherBlock{`,
        # UnitCargoLoader.java:84); UnitCargoLoader extends
        # Block (UnitCargoLoader.java:23, `public class
        # UnitCargoLoader extends Block{`), so the default
        # (`return enabled;`, BuildingComp.java:755-756) does
        # not apply here. Unlike the Separator/Drill gates this
        # one has NO `&& enabled` -- Java returns the bare
        # null check, so the pure gate does NOT read
        # frame["enabled"] at all (the driver already runs the
        # machinery only when enabled). When the gate is false
        # updateConsumption forces efficiency to zero
        # (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();` + 1992,
        # `if(!update){`). The frame carries the unit
        # (frame["unit"], default null for a frame bound before
        # this slice -- the Java field is nullable); no live
        # fill sets it yet -- the unit spawn / readUnitId fill
        # is the updateTile advance (UnitCargoLoader.java:92-125)
        # and waits for its own slice. The warmup fold
        # (UnitCargoLoader.java:105, `warmup =
        # Mathf.approachDelta(warmup, efficiency, 1f / 60f);`)
        # and the build advance (UnitCargoLoader.java:109,
        # `buildProgress += edelta() / unitBuildTime;`) follow
        # the folded efficiency; the unit build takes
        # unitBuildTime 60f * 8f (`public float unitBuildTime =
        # 60f * 8f;`, UnitCargoLoader.java:24-25). The def
        # consumes power 8f/60f (`consumePower(8f / 60f);`,
        # Blocks.java:2276) plus liquid nitrogen 10f/60f
        # (`consumeLiquid(Liquids.nitrogen, 10f / 60f);`,
        # Blocks.java:2279) -- the liquid row waits for its own
        # slice.
        self.assertIn('static func source_unit_cargo_loader_should_consume_state', unit_cargo_loader)
        self.assertIn('"should_consume": unit == null', unit_cargo_loader)
        self.assertIn('"has_unit": unit != null', unit_cargo_loader)
        self.assertIn('public boolean shouldConsume(){', unit_cargo_loader)
        self.assertIn('return unit == null;', unit_cargo_loader)
        self.assertIn('public @Nullable Unit unit;', unit_cargo_loader)
        self.assertIn('public class UnitTransportSourceBuild extends Building implements UnitTetherBlock{', unit_cargo_loader)
        self.assertIn('public class UnitCargoLoader extends Block{', unit_cargo_loader)
        self.assertIn('return enabled;', unit_cargo_loader)
        self.assertIn('boolean update = shouldConsume() && productionValid();', unit_cargo_loader)
        self.assertIn('if(!update){', unit_cargo_loader)
        self.assertIn('warmup = Mathf.approachDelta(warmup, efficiency, 1f / 60f);', unit_cargo_loader)
        self.assertIn('buildProgress += edelta() / unitBuildTime;', unit_cargo_loader)
        self.assertIn('public float unitBuildTime = 60f * 8f;', unit_cargo_loader)
        self.assertIn('consumePower(8f / 60f);', unit_cargo_loader)
        self.assertIn('consumeLiquid(Liquids.nitrogen, 10f / 60f);', unit_cargo_loader)
        self.assertIn('"unit": null', unit_cargo_loader)
        self.assertIn('frame["unit"]', unit_cargo_loader)
        # The driver feeds the live gate to the machinery: the
        # pure gate reads the frame unit key and the gate call
        # feeds should_consume into the fold.
        self.assertIn('static func source_unit_cargo_loader_tick_buildings_state', unit_cargo_loader)
        self.assertIn('source_unit_cargo_loader_should_consume_state(frame)', unit_cargo_loader)
        self.assertIn('bool(gate.get("should_consume", true))', unit_cargo_loader)
        # The documented limits record the gate as live; the old
        # N2165 deferral text is gone. The N2165 power row is
        # preserved.
        self.assertIn('shouldConsume gate live (N2211)', unit_cargo_loader)
        self.assertNotIn('runs with should_consume=true when enabled', unit_cargo_loader)
        self.assertNotIn('unit state is not tracked yet', unit_cargo_loader)
        self.assertIn('static func source_unit_cargo_loader_power_status_row_state', unit_cargo_loader)
        # The proof's keys drive the pure gate (true when unit
        # is null, false when a unit is held -- the INVERTED
        # gate -- and independent of enabled) plus the live tick
        # (efficiency 0 when the gate is false, the N2165 power
        # fold preserved when the gate is true) plus the fresh
        # frame default (unit null on bind). There are no
        # warmup / progress / spawn / liquid keys: the updateTile
        # advance (UnitCargoLoader.java:92-125) waits for its
        # own slice, so the warmup fold (UnitCargoLoader.java:105)
        # is what the efficiency keys prove. Static checks: the
        # proof preloads the unit-cargo-loader state file that
        # exists, and the scene file references the proof script
        # that exists.
        proof = UNIT_CARGO_LOADER_SHOULD_CONSUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'gate_true_when_unit_null',
            'gate_false_when_unit_present',
            'gate_independent_of_enabled',
            'efficiency_zero_when_gate_false',
            'efficiency_folds_power_when_gate_true',
            'frame_unit_default_null',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceUnitCargoLoaderBuildState.gd")', proof)
        self.assertIn('unit_cargo_loader_build_state.source_unit_cargo_loader_should_consume_state(', proof)
        self.assertIn('unit_cargo_loader_build_state.source_unit_cargo_loader_tick_buildings_state(game, 1.0 / 60.0)', proof)
        self.assertTrue(UNIT_CARGO_LOADER_STATE.is_file())
        scene = UNIT_CARGO_LOADER_SHOULD_CONSUME_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07UnitCargoLoaderShouldConsumeProof.gd', scene)
        self.assertTrue(UNIT_CARGO_LOADER_SHOULD_CONSUME_PROOF.is_file())

    def test_reference_graph_and_actual_c07_unit_cargo_loader_should_consume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07UnitCargoLoaderShouldConsumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_UNIT_CARGO_LOADER_SHOULD_CONSUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'gate_true_when_unit_null',
            'gate_false_when_unit_present',
            'gate_independent_of_enabled',
            'efficiency_zero_when_gate_false',
            'efficiency_folds_power_when_gate_true',
            'frame_unit_default_null',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
