import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REGEN_PROJECTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceRegenProjectorBuildState.gd'
REGEN_PROJECTOR_SHOULD_CONSUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RegenProjectorShouldConsumeProof.gd'
REGEN_PROJECTOR_SHOULD_CONSUME_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RegenProjectorShouldConsumeProof.tscn'


class C07RegenProjectorShouldConsumeTests(unittest.TestCase):
    def test_c07_regen_projector_should_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2214']['godot_owner'], 'SourceRegenProjectorBuildState.source_regen_projector_should_consume_state')
        # N2160 gave the regen-projector its live power.status read --
        # a pure power row over the stamped frame value, folded by
        # the shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) -- but RED-deferred the shouldConsume
        # gate: the port tracked NO target state on the
        # regen-projector frame, so the machinery ran with
        # should_consume=true when enabled (the MendProjector
        # suppression precedent) -- while full power.status reads
        # 1.0 while Java efficiency is 0 when no damaged building
        # is in range. RegenProjectorBuild overrides shouldConsume
        # (RegenProjector.java:181-183): `return anyTargets;` --
        # the gate reads ONLY the anyTargets flag: the projector
        # consumes while a damaged building is in range and stops
        # consuming once nothing in range is damaged. The field is
        # `public boolean anyTargets = false;`
        # (RegenProjector.java:112) on RegenProjectorBuild
        # (RegenProjector.java:108, `public class
        # RegenProjectorBuild extends Building{`). N2214 wires the
        # gate into the regen-projector's OWN driver
        # (SourceRegenProjectorBuildState.gd, frame key
        # "source_regen_projector_building"): the frame gets an
        # `any_targets` key (default false, the Java field
        # default), the pure gate returns anyTargets plus the flag
        # it reads, and the driver feeds `should_consume =
        # anyTargets` to the machinery, so a regen-projector with
        # no damaged building in range folds efficiency 0 like
        # Java. No live fill sets frame["any_targets"] yet -- the
        # gate reads the frame as-is, and the targets computation
        # (indexer range query + contains damaged,
        # RegenProjector.java:115-119, 139) waits for its own
        # slice (new deferral). The slice adds NO `targets` frame
        # key: the gate reads anyTargets only, never the targets
        # list itself. Two new result symbols: the gate and the
        # any_targets flag it reads.
        self.assertEqual(
            ledger['N2214']['source_symbols'],
            [
                'source_regen_projector_should_consume_state_result.should_consume',
                'source_regen_projector_should_consume_state_result.any_targets',
            ],
        )
        for name in ledger['N2214']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/RegenProjector.java')
                self.assertEqual(symbol['godot_owner'], {
                    'source_regen_projector_should_consume_state_result.should_consume': 'SourceRegenProjectorBuildState.source_regen_projector_should_consume_state',
                    'source_regen_projector_should_consume_state_result.any_targets': 'SourceRegenProjectorBuildState.source_regen_projector_should_consume_state',
                }[name])
        self.assertEqual(ledger['N2214']['runtime_proof'], '/root/C07RegenProjectorShouldConsumeProof')
        self.assertEqual(
            ledger['N2214']['tests'],
            [
                'test_c07_regen_projector_should_consume_registration',
                'test_all_c07_regen_projector_should_consume_input_evidence_is_exact',
                'test_regen_projector_should_consume_gate_state',
                'test_reference_graph_and_actual_c07_regen_projector_should_consume',
            ],
        )
        self.assertTrue(ledger['N2214']['deferred_exprs'])
        # This slice resolves the N2160 RegenProjector gate
        # deferral, so the gate entry is gone from DEFERRED --
        # while the updateTile advance, liquid hydrogen row,
        # phaseFabric booster row, suppression gate, and mendMap
        # / effect rows stay deferred.
        self.assertFalse(any(entry.startswith('RegenProjector shouldConsume gate (') for entry in ledger['N2214']['deferred_exprs']))

    def test_all_c07_regen_projector_should_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2214']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_regen_projector_should_consume_state_result.should_consume': 'SourceRegenProjectorBuildState.source_regen_projector_should_consume_state',
                    'source_regen_projector_should_consume_state_result.any_targets': 'SourceRegenProjectorBuildState.source_regen_projector_should_consume_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/RegenProjector.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2214']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_regen_projector_should_consume_gate_state(self):
        regen_projector = REGEN_PROJECTOR_STATE.read_text(encoding='utf-8')
        # The pure gate lives on the regen-projector build
        # state: RegenProjectorBuild.shouldConsume()
        # (RegenProjector.java:181, `public boolean
        # shouldConsume(){` with `return anyTargets;`,
        # RegenProjector.java:182) -- the gate reads ONLY the
        # anyTargets flag: consume while a damaged building is
        # in range, stop once nothing in range is damaged. The
        # field is `public boolean anyTargets = false;`
        # (RegenProjector.java:112) on RegenProjectorBuild
        # (RegenProjector.java:108, `public class
        # RegenProjectorBuild extends Building{`);
        # RegenProjector extends Block (RegenProjector.java:20,
        # `public class RegenProjector extends Block{`), so the
        # default (`return enabled;`, BuildingComp.java:755-756)
        # does not apply here. Unlike the Separator/Drill gates
        # this one has NO `&& enabled` -- Java returns the bare
        # flag, so the pure gate does NOT read frame["enabled"]
        # at all (the driver already runs the machinery only
        # when enabled). When the gate is false updateConsumption
        # forces efficiency to zero (BuildingComp.java:1960,
        # `boolean update = shouldConsume() &&
        # productionValid();` + 1992, `if(!update){`). The frame
        # carries the flag (frame["any_targets"], default false
        # for a frame bound before this slice -- the Java field
        # defaults to false); no live fill sets it yet -- the
        # targets computation (indexer range query,
        # RegenProjector.java:115-119, + contains damaged,
        # RegenProjector.java:139) is the updateTile advance
        # (RegenProjector.java:122-179) and waits for its own
        # slice. The heal gate (RegenProjector.java:141,
        # `if(efficiency > 0){`) and the heal amount
        # (RegenProjector.java:147, `float healAmount =
        # Mathf.lerp(1f, optionalMultiplier, optionalEfficiency)
        # * healPercent;`) follow the folded efficiency. The def
        # consumes power 1f (`consumePower(1f);`,
        # Blocks.java:2015) plus liquid hydrogen 1f/60f
        # (`consumeLiquid(Liquids.hydrogen, 1f / 60f);`,
        # Blocks.java:2016) -- the liquid row waits for its own
        # slice. Cite correction: the N2160 driver comment cited
        # the gate at RegenProjector.java:206-208 -- WRONG at
        # this pin (verified by grep: exactly one shouldConsume
        # in the file, at 181-183); N2214 cites 181-183 and the
        # wrong cite is gone from the driver.
        self.assertIn('static func source_regen_projector_should_consume_state', regen_projector)
        self.assertIn('"should_consume": any_targets', regen_projector)
        self.assertIn('"any_targets": any_targets', regen_projector)
        self.assertIn('public boolean shouldConsume(){', regen_projector)
        self.assertIn('return anyTargets;', regen_projector)
        self.assertIn('public boolean anyTargets = false;', regen_projector)
        self.assertIn('public class RegenProjectorBuild extends Building{', regen_projector)
        self.assertIn('public class RegenProjector extends Block{', regen_projector)
        self.assertIn('return enabled;', regen_projector)
        self.assertIn('boolean update = shouldConsume() && productionValid();', regen_projector)
        self.assertIn('if(!update){', regen_projector)
        self.assertIn('if(efficiency > 0){', regen_projector)
        self.assertIn('float healAmount = Mathf.lerp(1f, optionalMultiplier, optionalEfficiency) * healPercent;', regen_projector)
        self.assertIn('consumePower(1f);', regen_projector)
        self.assertIn('consumeLiquid(Liquids.hydrogen, 1f / 60f);', regen_projector)
        self.assertIn('"any_targets": false', regen_projector)
        self.assertIn('frame["any_targets"]', regen_projector)
        # The driver feeds the live gate to the machinery: the
        # pure gate reads the frame any_targets key and the gate
        # call feeds should_consume into the fold.
        self.assertIn('static func source_regen_projector_tick_buildings_state', regen_projector)
        self.assertIn('source_regen_projector_should_consume_state(frame)', regen_projector)
        self.assertIn('bool(gate.get("should_consume", true))', regen_projector)
        # The documented limits record the gate as live; the old
        # N2160 deferral text and the wrong 206-208 cite are
        # gone. The N2160 power row is preserved.
        self.assertIn('shouldConsume gate live (N2214)', regen_projector)
        self.assertNotIn('runs with should_consume=true when enabled', regen_projector)
        self.assertNotIn('RegenProjector.java:206-208', regen_projector)
        self.assertNotIn('RegenProjector.java:207', regen_projector)
        self.assertIn('static func source_regen_projector_power_status_row_state', regen_projector)
        # The proof's keys drive the pure gate (true when a
        # damaged building is in range, false when none is --
        # and independent of enabled) plus the live tick
        # (efficiency 0 when the gate is false, the N2160 power
        # fold preserved when the gate is true) plus the fresh
        # frame default (any_targets false on bind). There are
        # no warmup / heal / target keys: the updateTile advance
        # (RegenProjector.java:122-179) waits for its own slice,
        # so the heal gate (RegenProjector.java:141) is what the
        # efficiency keys prove. Static checks: the proof
        # preloads the regen-projector state file that exists,
        # and the scene file references the proof script that
        # exists.
        proof = REGEN_PROJECTOR_SHOULD_CONSUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'gate_true_when_any_targets',
            'gate_false_when_no_targets',
            'gate_independent_of_enabled',
            'efficiency_zero_when_gate_false',
            'efficiency_folds_power_when_gate_true',
            'frame_any_targets_default_false',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceRegenProjectorBuildState.gd")', proof)
        self.assertIn('regen_projector_build_state.source_regen_projector_should_consume_state(', proof)
        self.assertIn('regen_projector_build_state.source_regen_projector_tick_buildings_state(game, 1.0 / 60.0)', proof)
        self.assertTrue(REGEN_PROJECTOR_STATE.is_file())
        scene = REGEN_PROJECTOR_SHOULD_CONSUME_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07RegenProjectorShouldConsumeProof.gd', scene)
        self.assertTrue(REGEN_PROJECTOR_SHOULD_CONSUME_PROOF.is_file())

    def test_reference_graph_and_actual_c07_regen_projector_should_consume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RegenProjectorShouldConsumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REGEN_PROJECTOR_SHOULD_CONSUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'gate_true_when_any_targets',
            'gate_false_when_no_targets',
            'gate_independent_of_enabled',
            'efficiency_zero_when_gate_false',
            'efficiency_folds_power_when_gate_true',
            'frame_any_targets_default_false',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
