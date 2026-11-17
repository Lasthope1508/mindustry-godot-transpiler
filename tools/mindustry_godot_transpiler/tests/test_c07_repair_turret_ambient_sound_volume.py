import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTurretBuildState.gd'
REPAIR_TURRET_AMBIENT_SOUND_VOLUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTurretAmbientSoundVolumeProof.gd'


class C07RepairTurretAmbientSoundVolumeTests(unittest.TestCase):
    def test_c07_repair_turret_ambient_sound_volume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2235']['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_ambient_sound_volume_state')
        # N2222 pinned the 1.0 class default
        # (RepairTurret.java:67, `ambientSoundVolume = 1f;`)
        # for both defs, but Blocks.java overrides it per def:
        # repair-point 0.9f (Blocks.java:6393) and
        # repair-turret 1.25f (Blocks.java:6408), so the
        # ambient-sound loop (BuildingComp.java:2270-2271,
        # `control.sound.loop(block.ambientSound, self(),
        # block.ambientSoundVolume * ambientVolume());`)
        # used 1.0 for both defs -- wrong against the
        # catalog. RED decisions (resolved at RED, recorded
        # in the register docstring): (1) One pure function
        # on the same family file, taking the block id
        # explicitly (per-def static state, not a live frame
        # key -- the N2212 / N2220 precedent) and returning
        # the per-def volume (0.9 / 1.25, class default 1.0
        # fallback for an unknown def). (2) The loop keeps
        # its two-arg signature (the N2222 test pins it
        # verbatim), resolving the volume through the new
        # function from `frame.get("block_id", "")` (the
        # AdjacentFactory / Factory / UnitFactory precedent
        # for reading block_id off the frame); a frame with
        # no block_id falls back to the 1.0 class default, so
        # the N2222 tests stay green unchanged. (3) There is
        # NO driver tick line: the volume is a catalog read
        # and the loop itself has no driver call yet (the
        # N2222 sound side effect with no sink); live
        # repair-turret frames do not stamp block_id yet, so
        # the per-def volume activates when the caller
        # supplies the frame's block_id -- stamping it at
        # bind is its own later slice. (4) The N2234
        # DEFERRED entry "RepairTurret per-def
        # ambientSoundVolume correction" is RESOLVED here
        # and replaced by the N2235 Windows-proof debt
        # entry. One new result symbol:
        # ambient_sound_volume.
        self.assertEqual(
            ledger['N2235']['source_symbols'],
            [
                'source_repair_turret_ambient_sound_volume_state_result.ambient_sound_volume',
            ],
        )
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTurret.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/Block.java',
        }
        for name in ledger['N2235']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], slice_sources)
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2235']['runtime_proof'], '/root/C07RepairTurretAmbientSoundVolumeProof')
        self.assertEqual(
            ledger['N2235']['tests'],
            [
                'test_c07_repair_turret_ambient_sound_volume_registration',
                'test_all_c07_repair_turret_ambient_sound_volume_input_evidence_is_exact',
                'test_repair_turret_ambient_sound_volume_state',
                'test_reference_graph_and_actual_c07_repair_turret_ambient_sound_volume',
            ],
        )
        self.assertTrue(ledger['N2235']['deferred_exprs'])

    def test_all_c07_repair_turret_ambient_sound_volume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2235']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTurret.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2235']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_turret_ambient_sound_volume_state(self):
        repair_turret = REPAIR_TURRET_STATE.read_text(encoding='utf-8')
        # Blocks.java overrides the RepairTurret class
        # default `ambientSoundVolume = 1f;`
        # (RepairTurret.java:67) per def: repair-point 0.9f
        # (Blocks.java:6393) and repair-turret 1.25f
        # (Blocks.java:6408). The loop multiplies that
        # volume by ambientVolume() (BuildingComp.java:2271,
        # `control.sound.loop(block.ambientSound, self(),
        # block.ambientSoundVolume * ambientVolume());`,
        # gated by BuildingComp.java:2270). An unknown def
        # falls back to the 1.0 class default. The loop
        # keeps its two-arg signature and resolves the
        # volume from `frame.get("block_id", "")`, so a
        # frame with no block_id keeps the old 1.0 behavior.
        # There is no driver tick line: the volume is a
        # catalog read (the N2223 sense / N2230 setStats
        # precedent).
        self.assertIn('static func source_repair_turret_ambient_sound_volume_state(block_id: String) -> Dictionary:', repair_turret)
        self.assertIn('return {"ambient_sound_volume": 0.9}', repair_turret)
        self.assertIn('return {"ambient_sound_volume": 1.25}', repair_turret)
        self.assertIn('return {"ambient_sound_volume": SOURCE_REPAIR_TURRET_AMBIENT_SOUND_VOLUME}', repair_turret)
        self.assertIn('static func source_repair_turret_ambient_sound_loop_state(frame: Dictionary, headless: bool) -> Dictionary:', repair_turret)
        self.assertIn('source_repair_turret_ambient_sound_volume_state(str(frame.get("block_id", "")))', repair_turret)
        for expr in [
            'ambientSoundVolume = 0.9f;',
            'ambientSoundVolume = 1.25f;',
            'ambientSoundVolume = 1f;',
            'control.sound.loop(block.ambientSound, self(), block.ambientSoundVolume * ambientVolume());',
            'if(!headless && block.ambientSound != Sounds.none && shouldAmbientSound()){',
            'repairPoint = new RepairTurret("repair-point"){{',
            'repairTurret = new RepairTurret("repair-turret"){{',
            'public class RepairTurret extends Block{',
            'public float ambientSoundVolume = 0.05f;',
            'public float ambientVolume(){',
            'return efficiency;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, repair_turret)
        driver_start = repair_turret.index('static func source_repair_turret_tick_buildings_state')
        driver_end = repair_turret.find('\nstatic func ', driver_start + 1)
        driver_body = repair_turret[driver_start:driver_end if driver_end != -1 else len(repair_turret)]
        self.assertNotIn('source_repair_turret_ambient_sound_volume_state', driver_body)
        self.assertNotIn('source_repair_turret_ambient_sound_loop_state', driver_body)
        # The proof's keys drive the pure function with the
        # two catalog block ids and the unknown-def fallback,
        # plus the loop volumes per def, the no-block-id
        # backward-compat case, and the no-driver-tick-line
        # check (the proof reads the state script source and
        # greps the driver body -- a runtime check, not a
        # hardcoded true).
        proof = REPAIR_TURRET_AMBIENT_SOUND_VOLUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'volume_repair_point_0_9',
            'volume_repair_turret_1_25',
            'volume_unknown_fallback_1_0',
            'loop_volume_repair_point',
            'loop_volume_repair_turret',
            'loop_volume_no_block_id_fallback',
            'has_no_driver_tick_line',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_repair_turret_ambient_sound_volume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTurretAmbientSoundVolumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TURRET_AMBIENT_SOUND_VOLUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'volume_repair_point_0_9',
            'volume_repair_turret_1_25',
            'volume_unknown_fallback_1_0',
            'loop_volume_repair_point',
            'loop_volume_repair_turret',
            'loop_volume_no_block_id_fallback',
            'has_no_driver_tick_line',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
