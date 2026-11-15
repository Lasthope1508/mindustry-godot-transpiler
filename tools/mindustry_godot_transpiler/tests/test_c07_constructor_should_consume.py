import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
CONSTRUCTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceConstructorBuildState.gd'
CONSTRUCTOR_SHOULD_CONSUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ConstructorShouldConsumeProof.gd'
CONSTRUCTOR_SHOULD_CONSUME_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ConstructorShouldConsumeProof.tscn'


class C07ConstructorShouldConsumeTests(unittest.TestCase):
    def test_c07_constructor_should_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2216']['godot_owner'], 'SourceConstructorBuildState.source_constructor_should_consume_state')
        # N2161 gave the constructor its live power.status read --
        # a pure power row over the stamped frame value, folded by
        # the shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) -- but RED-deferred the shouldConsume
        # gate: the port tracked NO recipe state on the
        # constructor frame, so the machinery ran with
        # should_consume=true when enabled (the MendProjector
        # suppression precedent) -- with no recipe requestedPower
        # is 0 so power.status reads 1.0 while Java efficiency is
        # 0. BlockProducerBuild overrides shouldConsume
        # (BlockProducer.java:102-104): `return
        # super.shouldConsume() && recipe() != null;` -- the gate
        # reads the live recipe AND the enabled flag (`super` is
        # the BuildingComp default `return enabled;`,
        # BuildingComp.java:755-756; PayloadBlockBuild does NOT
        # override shouldConsume, so the gate is really `enabled
        # && recipe() != null`). The field is `public @Nullable
        # Block recipe;` (Constructor.java:59) on ConstructorBuild
        # (`public class ConstructorBuild extends
        # BlockProducerBuild{`, Constructor.java:58); Constructor
        # extends BlockProducer (Constructor.java:19, `public
        # class Constructor extends BlockProducer{`), and
        # BlockProducer is abstract (`public abstract class
        # BlockProducer extends PayloadBlock{`,
        # BlockProducer.java:21) with the abstract recipe
        # (`public abstract @Nullable Block recipe();`,
        # BlockProducer.java:80). N2216 wires the gate into the
        # constructor's OWN driver
        # (SourceConstructorBuildState.gd, frame key
        # "source_constructor_building"): the frame gets a
        # `recipe` key (default null, the Java field default),
        # the pure gate returns `recipe() != null && enabled`
        # plus the null-ness it read, and the driver feeds
        # should_consume to the machinery, so a constructor
        # with no recipe folds efficiency 0 like Java. No live
        # fill sets frame["recipe"] yet -- the gate reads the
        # frame as-is, and the live recipe config fill (config
        # set when canProduce / configClear, Constructor.java:
        # 31-38) waits for its own slice (new deferral).
        # Two new result symbols: the gate and the has_recipe
        # flag it reads.
        self.assertEqual(
            ledger['N2216']['source_symbols'],
            [
                'source_constructor_should_consume_state_result.should_consume',
                'source_constructor_should_consume_state_result.has_recipe',
            ],
        )
        for name in ledger['N2216']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], {
                    'source_constructor_should_consume_state_result.should_consume': 'core/src/mindustry/world/blocks/payloads/BlockProducer.java',
                    'source_constructor_should_consume_state_result.has_recipe': 'core/src/mindustry/world/blocks/payloads/Constructor.java',
                }[name])
                self.assertEqual(symbol['godot_owner'], {
                    'source_constructor_should_consume_state_result.should_consume': 'SourceConstructorBuildState.source_constructor_should_consume_state',
                    'source_constructor_should_consume_state_result.has_recipe': 'SourceConstructorBuildState.source_constructor_should_consume_state',
                }[name])
        self.assertEqual(ledger['N2216']['runtime_proof'], '/root/C07ConstructorShouldConsumeProof')
        self.assertEqual(
            ledger['N2216']['tests'],
            [
                'test_c07_constructor_should_consume_registration',
                'test_all_c07_constructor_should_consume_input_evidence_is_exact',
                'test_constructor_should_consume_gate_state',
                'test_reference_graph_and_actual_c07_constructor_should_consume',
            ],
        )
        self.assertTrue(ledger['N2216']['deferred_exprs'])
        # This slice resolves the N2161 BlockProducer gate
        # deferral, so the gate entry is gone from DEFERRED --
        # while the updateTile advance, dynamic item consumer
        # row, config/filter rows, buildSpeed rows, and payload /
        # draw rows stay deferred.
        self.assertFalse(any(entry.startswith('BlockProducer shouldConsume gate (') for entry in ledger['N2216']['deferred_exprs']))

    def test_all_c07_constructor_should_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2216']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_constructor_should_consume_state_result.should_consume': 'SourceConstructorBuildState.source_constructor_should_consume_state',
                    'source_constructor_should_consume_state_result.has_recipe': 'SourceConstructorBuildState.source_constructor_should_consume_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/payloads/BlockProducer.java',
            'core/src/mindustry/world/blocks/payloads/Constructor.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2216']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_constructor_should_consume_gate_state(self):
        constructor = CONSTRUCTOR_STATE.read_text(encoding='utf-8')
        # The pure gate lives on the constructor build
        # state: BlockProducerBuild.shouldConsume()
        # (BlockProducer.java:102, `public boolean
        # shouldConsume(){` with `return super.shouldConsume()
        # && recipe() != null;`, BlockProducer.java:103) --
        # the gate reads the live recipe AND the enabled flag
        # (`super` is the BuildingComp default `return
        # enabled;`, BuildingComp.java:755-756;
        # PayloadBlockBuild does NOT override shouldConsume,
        # so the gate is really `enabled && recipe() !=
        # null`). The field is `public @Nullable Block
        # recipe;` (Constructor.java:59) on ConstructorBuild
        # (`public class ConstructorBuild extends
        # BlockProducerBuild{`, Constructor.java:58);
        # Constructor extends BlockProducer
        # (Constructor.java:19, `public class Constructor
        # extends BlockProducer{`), and BlockProducer is
        # abstract (`public abstract class BlockProducer
        # extends PayloadBlock{`, BlockProducer.java:21) with
        # the abstract recipe (`public abstract @Nullable
        # Block recipe();`, BlockProducer.java:80). The gate
        # HAS the enabled term via super -- the pure gate
        # reads frame["enabled"] too (the ItemBridge N2188 /
        # RepairTurret N2212 precedent). When the gate is
        # false updateConsumption forces efficiency to zero
        # (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();` + 1992,
        # `if(!update){`). The frame carries the recipe
        # (frame["recipe"], default null for a frame bound
        # before this slice -- the Java field default); no
        # live fill sets it yet -- the config path (config
        # set when canProduce, Constructor.java:32-37,
        # `config(Block.class, (ConstructorBuild tile, Block
        # block) -> {`, plus the progress reset when the
        # recipe changes; configClear clears to null,
        # Constructor.java:31/38, `configClear((
        # ConstructorBuild tile) -> tile.recipe = null);`)
        # is a config advance and waits for its own slice.
        # The produce gate (BlockProducer.java:110, `boolean
        # produce = recipe != null && efficiency > 0 &&
        # payload == null;`) follows the folded efficiency,
        # with the progress advance (BlockProducer.java:113,
        # `progress += buildSpeed * edelta();`). The two defs
        # carry consumePower(2.5f); (constructor,
        # Blocks.java:6663) and consumePower(3f);
        # (large-constructor, Blocks.java:6679).
        self.assertIn('static func source_constructor_should_consume_state', constructor)
        self.assertIn('"should_consume": recipe != null and enabled', constructor)
        self.assertIn('"has_recipe": recipe != null', constructor)
        self.assertIn('public boolean shouldConsume(){', constructor)
        self.assertIn('return super.shouldConsume() && recipe() != null;', constructor)
        self.assertIn('public @Nullable Block recipe;', constructor)
        self.assertIn('public class ConstructorBuild extends BlockProducerBuild{', constructor)
        self.assertIn('public class Constructor extends BlockProducer{', constructor)
        self.assertIn('public abstract class BlockProducer extends PayloadBlock{', constructor)
        self.assertIn('public abstract @Nullable Block recipe();', constructor)
        self.assertIn('return enabled;', constructor)
        self.assertIn('boolean update = shouldConsume() && productionValid();', constructor)
        self.assertIn('if(!update){', constructor)
        self.assertIn('boolean produce = recipe != null && efficiency > 0 && payload == null;', constructor)
        self.assertIn('progress += buildSpeed * edelta();', constructor)
        self.assertIn('config(Block.class, (ConstructorBuild tile, Block block) -> {', constructor)
        self.assertIn('configClear((ConstructorBuild tile) -> tile.recipe = null);', constructor)
        self.assertIn('consumePower(2.5f);', constructor)
        self.assertIn('consumePower(3f);', constructor)
        self.assertIn('"recipe": null', constructor)
        self.assertIn('frame["recipe"]', constructor)
        # The driver feeds the live gate to the machinery: the
        # pure gate reads the frame recipe key and the gate call
        # feeds should_consume into the fold.
        self.assertIn('static func source_constructor_tick_buildings_state', constructor)
        self.assertIn('source_constructor_should_consume_state(frame)', constructor)
        self.assertIn('bool(gate.get("should_consume", true))', constructor)
        # The documented limits record the gate as live; the old
        # N2161 deferral text is gone. The N2161 power row is
        # preserved.
        self.assertIn('shouldConsume gate live (N2216)', constructor)
        self.assertNotIn('runs with should_consume=true when enabled', constructor)
        self.assertNotIn('recipe state is not tracked yet', constructor)
        self.assertIn('static func source_constructor_power_status_row_state', constructor)
        # The proof's keys drive the pure gate (true when a
        # recipe is present and enabled, false when the recipe
        # is null, false when disabled -- the gate HAS the
        # enabled term via super) plus the live tick
        # (efficiency 0 when the gate is false, the N2161
        # power fold preserved when the gate is true) plus
        # the fresh frame default (recipe null on bind).
        # There are no progress / heat / time / moveOutPayload
        # keys: the updateTile advance (BlockProducer.java:
        # 109-131) waits for its own slice, so the produce
        # gate (BlockProducer.java:110) is what the
        # efficiency keys prove. Static checks: the proof
        # preloads the constructor state file that exists,
        # and the scene file references the proof script that
        # exists.
        proof = CONSTRUCTOR_SHOULD_CONSUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'gate_true_when_recipe_present',
            'gate_false_when_recipe_null',
            'gate_false_when_disabled',
            'efficiency_zero_when_gate_false',
            'efficiency_folds_power_when_gate_true',
            'frame_recipe_default_null',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceConstructorBuildState.gd")', proof)
        self.assertIn('constructor_build_state.source_constructor_should_consume_state(', proof)
        self.assertIn('constructor_build_state.source_constructor_tick_buildings_state(game, 1.0 / 60.0)', proof)
        self.assertTrue(CONSTRUCTOR_STATE.is_file())
        scene = CONSTRUCTOR_SHOULD_CONSUME_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07ConstructorShouldConsumeProof.gd', scene)
        self.assertTrue(CONSTRUCTOR_SHOULD_CONSUME_PROOF.is_file())

    def test_reference_graph_and_actual_c07_constructor_should_consume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ConstructorShouldConsumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_CONSTRUCTOR_SHOULD_CONSUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'gate_true_when_recipe_present',
            'gate_false_when_recipe_null',
            'gate_false_when_disabled',
            'efficiency_zero_when_gate_false',
            'efficiency_folds_power_when_gate_true',
            'frame_recipe_default_null',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
