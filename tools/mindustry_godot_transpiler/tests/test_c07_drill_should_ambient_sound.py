import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BURST_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBurstDrillBuildState.gd'
DRILL_SHOULD_AMBIENT_SOUND_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07DrillShouldAmbientSoundProof.gd'


class C07DrillShouldAmbientSoundTests(unittest.TestCase):
    def test_c07_drill_should_ambient_sound_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2305']['godot_owner'], 'SourceBurstDrillBuildState.source_drill_should_ambient_sound_state')
        # DrillBuild.shouldAmbientSound() (Drill.java:252-254,
        # `public boolean shouldAmbientSound(){`) returns
        # `efficiency > 0.01f && items.total() < itemCapacity;`
        # (:253). `efficiency` is the live Building efficiency
        # (`transient float efficiency;`,
        # BuildingComp.java:85); `items.total()` is the cached
        # ItemModule total (`public int total(){` with `return
        # total;`, ItemModule.java:174-175); `itemCapacity` is
        # the per-def capacity (`public int itemCapacity =
        # 10;`, Block.java:75, with `itemCapacity = 40;`,
        # Blocks.java:3078, for impact-drill and
        # `itemCapacity = 60;`, Blocks.java:3107, for
        # eruption-drill). The BuildingComp default delegates
        # to shouldConsume (`public boolean
        # shouldAmbientSound(){` with `return
        # shouldConsume();`, BuildingComp.java:1212-1214) --
        # the Drill override replaces it with the efficiency
        # gate. The gate is read per tick by the ambient-sound
        # live loop (`if(!headless && block.ambientSound !=
        # Sounds.none && shouldAmbientSound()){` with
        # `control.sound.loop(block.ambientSound, self(),
        # block.ambientSoundVolume * ambientVolume());`,
        # BuildingComp.java:2270-2271). This is a Drill-local
        # boolean predicate -- NOT part of the ambient B/C
        # chain (B = RepairTurret driver tick, Windows line;
        # C = SoundControl.updateLoops mixer, N2304 held):
        # it gates the loop call, it is not the loop itself,
        # and it touches no audio playback and no driver tick
        # line. It is distinct from the ambient volume
        # (N2277, `efficiency * (size * size) / 4f`) and from
        # shouldConsume (N2295, which also requires `enabled
        # && dominantItem != null`). One new result symbol:
        # should_ambient_sound.
        self.assertEqual(
            ledger['N2305']['source_symbols'],
            [
                'source_drill_should_ambient_sound_state_result.should_ambient_sound',
            ],
        )
        for name in ledger['N2305']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/Drill.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/world/Block.java',
                    'core/src/mindustry/content/Blocks.java',
                    'core/src/mindustry/world/modules/ItemModule.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.source_drill_should_ambient_sound_state')
        self.assertEqual(ledger['N2305']['runtime_proof'], '/root/C07DrillShouldAmbientSoundProof')
        self.assertEqual(
            ledger['N2305']['tests'],
            [
                'test_c07_drill_should_ambient_sound_registration',
                'test_all_c07_drill_should_ambient_sound_input_evidence_is_exact',
                'test_drill_should_ambient_sound_state',
                'test_reference_graph_and_actual_c07_drill_should_ambient_sound',
            ],
        )
        self.assertTrue(ledger['N2305']['deferred_exprs'])

    def test_all_c07_drill_should_ambient_sound_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2305']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.source_drill_should_ambient_sound_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/production/Drill.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/modules/ItemModule.java',
            'core/src/mindustry/world/blocks/production/BurstDrill.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2305']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_drill_should_ambient_sound_state(self):
        burst_drill = BURST_DRILL_STATE.read_text(encoding='utf-8')
        # DrillBuild.shouldAmbientSound() (Drill.java:252-254,
        # `public boolean shouldAmbientSound(){`) returns
        # `efficiency > 0.01f && items.total() < itemCapacity;`
        # (:253). `efficiency` is the live Building efficiency
        # (`transient float efficiency;`,
        # BuildingComp.java:85); `items.total()` is the cached
        # ItemModule total (`public int total(){` with `return
        # total;`, ItemModule.java:174-175); `itemCapacity` is
        # the per-def capacity (`public int itemCapacity =
        # 10;`, Block.java:75, with `itemCapacity = 40;`,
        # Blocks.java:3078, for impact-drill and
        # `itemCapacity = 60;`, Blocks.java:3107, for
        # eruption-drill). The BuildingComp default delegates
        # to shouldConsume (BuildingComp.java:1212-1214). The
        # gate is read per tick by the ambient-sound live loop
        # (BuildingComp.java:2270-2271). There is NO driver
        # tick line: the gate is a pure predicate the loop
        # reads; the driver side waits for ambient C (N2304).
        self.assertIn('static func source_drill_should_ambient_sound_state(frame: Dictionary, efficiency: float, items_total: int, item_capacity: int) -> Dictionary:', burst_drill)
        self.assertIn('return {"should_ambient_sound": efficiency > 0.01 and items_total < item_capacity}', burst_drill)
        for expr in [
            'public boolean shouldAmbientSound(){',
            'return efficiency > 0.01f && items.total() < itemCapacity;',
            'transient float efficiency;',
            'public int total(){',
            'return total;',
            'public int itemCapacity = 10;',
            'itemCapacity = 40;',
            'itemCapacity = 60;',
            'public class Drill extends Block{',
            'public class DrillBuild extends Building{',
            'public class BurstDrill extends Drill{',
            'public class BurstDrillBuild extends DrillBuild{',
            'return shouldConsume();',
            'if(!headless && block.ambientSound != Sounds.none && shouldAmbientSound()){',
            'control.sound.loop(block.ambientSound, self(), block.ambientSoundVolume * ambientVolume());',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, burst_drill)
        # The proof's keys drive the pure function directly
        # with explicit efficiency / items_total /
        # item_capacity inputs: the gate passes when
        # efficient with room, blocks at efficiency 0,
        # blocks at the 0.01 threshold (strict >), blocks
        # when the store is full, passes at capacity - 1,
        # and the eruption def uses capacity 60.
        proof = DRILL_SHOULD_AMBIENT_SOUND_PROOF.read_text(encoding='utf-8')
        for key in [
            'gate_passes_efficient_with_room',
            'gate_blocks_when_efficiency_zero',
            'gate_blocks_at_threshold',
            'gate_blocks_when_full',
            'gate_passes_at_capacity_minus_one',
            'gate_eruption_def_uses_capacity_60',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_drill_should_ambient_sound(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07DrillShouldAmbientSoundProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_DRILL_SHOULD_AMBIENT_SOUND_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'gate_passes_efficient_with_room',
            'gate_blocks_when_efficiency_zero',
            'gate_blocks_at_threshold',
            'gate_blocks_when_full',
            'gate_passes_at_capacity_minus_one',
            'gate_eruption_def_uses_capacity_60',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
