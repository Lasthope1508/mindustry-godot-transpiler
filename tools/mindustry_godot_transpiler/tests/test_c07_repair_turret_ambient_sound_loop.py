import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTurretBuildState.gd'
REPAIR_TURRET_AMBIENT_SOUND_LOOP_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTurretAmbientSoundLoopProof.gd'


class C07RepairTurretAmbientSoundLoopTests(unittest.TestCase):
    def test_c07_repair_turret_ambient_sound_loop_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2222']['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_ambient_sound_loop_state')
        # N2221 captured when the turret plays its ambient sound
        # (shouldAmbientSound() = target != null && efficiency
        # > 0f) and what status it reports -- but nothing in the
        # port captured the live-loop call that actually loops
        # the sound each tick: BuildingComp.update() runs
        # `if(!headless && block.ambientSound != Sounds.none
        # && shouldAmbientSound()){` then
        # `control.sound.loop(block.ambientSound, self(),
        # block.ambientSoundVolume * ambientVolume());`
        # (BuildingComp.java:2270-2271, inside `public void
        # update(){`, BuildingComp.java:2262). The sound is
        # `Sounds.beamHeal` and its volume scale is `1f`
        # (RepairTurret.java:66-67, `ambientSound =
        # Sounds.beamHeal;` / `ambientSoundVolume = 1f;`,
        # set in the RepairTurret constructor, so both defs
        # share them), the Block defaults they override are
        # `public Sound ambientSound = Sounds.none;` and
        # `public float ambientSoundVolume = 0.05f;`
        # (Block.java:351, :353), and ambientVolume() is the
        # folded efficiency (BuildingComp.java:2015-2017,
        # `public float ambientVolume(){` / `return
        # efficiency;`). RED decisions (resolved at RED,
        # recorded in the register docstring): (1) One pure
        # function on the same family file N2174 / N2188 /
        # N2209 / N2212-N2215 / N2217 / N2219-N2221 built,
        # returning the loop decision (bool), the sound
        # (String) and the loop volume (float). (2) The gate
        # reuses the N2221 pure function
        # source_repair_turret_should_ambient_sound_state for
        # the shouldAmbientSound() leg (target + efficiency);
        # headless arrives as an explicit bool param (the
        # SourceBlockGeometry precedent -- the port has no
        # game-level headless flag yet). (3) The sound and
        # volume are per-class consts
        # SOURCE_REPAIR_TURRET_AMBIENT_SOUND ("beamHeal") and
        # SOURCE_REPAIR_TURRET_AMBIENT_SOUND_VOLUME (1.0);
        # volume is ambientSoundVolume * ambientVolume() =
        # 1.0 * efficiency, with efficiency read from the
        # frame (absent folds to 1.0, the N2174 missing-stamp
        # precedent). (4) There is NO driver tick line: the
        # loop call is a sound side effect
        # (control.sound.loop) with no sink in the port yet,
        # and nothing consumes an ambient-loop stamp -- the
        # driver tick line + sound-loop sink wait for a
        # game-level headless-source slice. Three new result
        # symbols: loop should_loop, sound, volume.
        self.assertEqual(
            ledger['N2222']['source_symbols'],
            [
                'source_repair_turret_ambient_sound_loop_state_result.should_loop',
                'source_repair_turret_ambient_sound_loop_state_result.sound',
                'source_repair_turret_ambient_sound_loop_state_result.volume',
            ],
        )
        for name in ledger['N2222']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/units/RepairTurret.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/world/Block.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2222']['runtime_proof'], '/root/C07RepairTurretAmbientSoundLoopProof')
        self.assertEqual(
            ledger['N2222']['tests'],
            [
                'test_c07_repair_turret_ambient_sound_loop_registration',
                'test_all_c07_repair_turret_ambient_sound_loop_input_evidence_is_exact',
                'test_repair_turret_ambient_sound_loop_state',
                'test_reference_graph_and_actual_c07_repair_turret_ambient_sound_loop',
            ],
        )
        self.assertTrue(ledger['N2222']['deferred_exprs'])

    def test_all_c07_repair_turret_ambient_sound_loop_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2222']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTurret.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2222']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_turret_ambient_sound_loop_state(self):
        repair_turret = REPAIR_TURRET_STATE.read_text(encoding='utf-8')
        # BuildingComp.update() loops the ambient sound each
        # tick (BuildingComp.java:2270-2271, inside `public
        # void update(){`, BuildingComp.java:2262):
        # if(!headless && block.ambientSound != Sounds.none && shouldAmbientSound()){
        # control.sound.loop(block.ambientSound, self(), block.ambientSoundVolume * ambientVolume());
        # The sound is `Sounds.beamHeal` and its volume scale
        # is `1f` (RepairTurret.java:66-67), the Block
        # defaults they override are `public Sound
        # ambientSound = Sounds.none;` and `public float
        # ambientSoundVolume = 0.05f;` (Block.java:351, :353),
        # and ambientVolume() is the folded efficiency
        # (BuildingComp.java:2015-2017). The gate reuses the
        # N2221 shouldAmbientSound() pure function; headless
        # is an explicit bool param; efficiency absent folds
        # to 1.0. There is no driver tick line: the loop call
        # is a sound side effect with no sink in the port yet.
        self.assertIn('static func source_repair_turret_ambient_sound_loop_state(frame: Dictionary, headless: bool) -> Dictionary:', repair_turret)
        self.assertIn('const SOURCE_REPAIR_TURRET_AMBIENT_SOUND := "beamHeal"', repair_turret)
        self.assertIn('const SOURCE_REPAIR_TURRET_AMBIENT_SOUND_VOLUME := 1.0', repair_turret)
        self.assertIn('return {"should_loop": should_loop, "sound": SOURCE_REPAIR_TURRET_AMBIENT_SOUND, "volume": volume}', repair_turret)
        for expr in [
            'if(!headless && block.ambientSound != Sounds.none && shouldAmbientSound()){',
            'control.sound.loop(block.ambientSound, self(), block.ambientSoundVolume * ambientVolume());',
            'ambientSound = Sounds.beamHeal;',
            'ambientSoundVolume = 1f;',
            'public float ambientVolume(){',
            'return efficiency;',
            'public Sound ambientSound = Sounds.none;',
            'public float ambientSoundVolume = 0.05f;',
            'return target != null && efficiency > 0f;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, repair_turret)
        # The proof's keys drive the pure function with
        # synthetic frames (no live tick: the loop decision is
        # a read of the frame + the explicit headless param):
        # loop true with a target, efficiency and a headed
        # game / loop false headless / loop false with no
        # target / loop false with zero efficiency / loop
        # volume at half efficiency / loop volume with the
        # efficiency key absent (folds to 1.0).
        proof = REPAIR_TURRET_AMBIENT_SOUND_LOOP_PROOF.read_text(encoding='utf-8')
        for key in [
            'loop_true_target_efficiency_headed',
            'loop_false_headless',
            'loop_false_no_target',
            'loop_false_zero_efficiency',
            'loop_volume_half_efficiency',
            'loop_volume_default_efficiency',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_repair_turret_ambient_sound_loop(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTurretAmbientSoundLoopProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TURRET_AMBIENT_SOUND_LOOP_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'loop_true_target_efficiency_headed',
            'loop_false_headless',
            'loop_false_no_target',
            'loop_false_zero_efficiency',
            'loop_volume_half_efficiency',
            'loop_volume_default_efficiency',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
