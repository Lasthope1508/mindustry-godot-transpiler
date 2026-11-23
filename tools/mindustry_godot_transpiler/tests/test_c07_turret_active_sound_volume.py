import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_ACTIVE_SOUND_VOLUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretActiveSoundVolumeProof.gd'


class C07TurretActiveSoundVolumeTests(unittest.TestCase):
    def test_c07_turret_active_sound_volume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2346']['godot_owner'], 'SourceTurretBuildState.source_turret_active_sound_volume_state')
        # TurretBuild.activeSoundVolume() (Turret.java:822-824):
        # `public float activeSoundVolume(){`
        # `return shootWarmup;`
        # `}`
        # and TurretBuild.shouldActiveSound() (Turret.java:826-829):
        # `public boolean shouldActiveSound(){`
        # `return shootWarmup > 0.01f && loopSound != Sounds.none;`
        # `}`
        # on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
        # (Turret.java:277). shootWarmup is the TurretBuild field
        # (`public float shootWarmup, charge, warmupHold = 0f;`,
        # Turret.java:286) and arrives as the explicit float
        # shoot_warmup (the updateTile warmup :502 precedent).
        # loopSound is the Turret def field (`public Sound
        # loopSound = Sounds.none;`, Turret.java:128); the
        # `loopSound != Sounds.none` check arrives as the
        # explicit bool has_loop_sound (the minRange has_ammo
        # precedent -- a null/non-none check carried as an
        # explicit bool, GDScript has no Sound object here).
        # NO driver line: both are read accessors/predicates
        # the updateTile() tick reads at :499
        # (`soundLoop.update(x, y, shouldActiveSound(),
        # activeSoundVolume());`) -- wiring waits for the
        # updateTile caller slice (the shouldTurn/isShooting
        # precedent). soundLoop itself (:298) is NOT ported:
        # this slice never touches real audio. Two new result
        # symbols: active_sound_volume, should_active_sound.
        self.assertEqual(
            ledger['N2346']['source_symbols'],
            [
                'source_turret_active_sound_volume_state_result.active_sound_volume',
                'source_turret_should_active_sound_state_result.should_active_sound',
            ],
        )
        for name in ledger['N2346']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2346']['runtime_proof'], '/root/C07TurretActiveSoundVolumeProof')
        self.assertEqual(
            ledger['N2346']['tests'],
            [
                'test_c07_turret_active_sound_volume_registration',
                'test_all_c07_turret_active_sound_volume_input_evidence_is_exact',
                'test_turret_active_sound_volume_state',
                'test_reference_graph_and_actual_c07_turret_active_sound_volume',
            ],
        )
        self.assertTrue(ledger['N2346']['deferred_exprs'])

    def test_all_c07_turret_active_sound_volume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2346']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2346']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_active_sound_volume_state(self):
        turret = TURRET_STATE.read_text(encoding='utf-8')
        # TurretBuild.activeSoundVolume() (Turret.java:822-824)
        # echoes the shootWarmup field; shouldActiveSound()
        # (Turret.java:826-829) is the warmup threshold plus
        # the loopSound check. The frame carries no tracked
        # key for either accessor (the minRange :593 precedent
        # -- the tick frame tracks no warmup/loop-sound state
        # yet), so all live values arrive as explicit params.
        # NO driver line: both are pure accessors, not
        # per-tick writes.
        self.assertIn('static func source_turret_active_sound_volume_state(frame: Dictionary, shoot_warmup: float) -> Dictionary:', turret)
        self.assertIn('return {"active_sound_volume": shoot_warmup}', turret)
        self.assertIn('static func source_turret_should_active_sound_state(frame: Dictionary, shoot_warmup: float, has_loop_sound: bool) -> Dictionary:', turret)
        self.assertIn('return {"should_active_sound": shoot_warmup > 0.01 and has_loop_sound}', turret)
        for expr in [
            'public float activeSoundVolume(){',
            'return shootWarmup;',
            'public boolean shouldActiveSound(){',
            'return shootWarmup > 0.01f && loopSound != Sounds.none;',
            'public float shootWarmup, charge, warmupHold = 0f;',
            'public Sound loopSound = Sounds.none;',
            'public class Turret extends ReloadTurret{',
            'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The proof's keys drive the pure functions with
        # synthetic frames (no live tick: both are pure
        # accessors over explicit params): volume echoes
        # warmup / zero stays zero / warm with a loop sound
        # sounds / cold stays silent / warm without a loop
        # sound stays silent / exactly 0.01 is silent (the
        # Java `>` is strict) / each result carries only its
        # one key.
        proof = TURRET_ACTIVE_SOUND_VOLUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'active_sound_volume_echoes_warmup',
            'active_sound_volume_zero',
            'active_sound_volume_returns_only_one_key',
            'should_active_sound_true',
            'should_active_sound_false_cold',
            'should_active_sound_false_no_loop',
            'should_active_sound_boundary_0_01',
            'should_active_sound_returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_active_sound_volume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretActiveSoundVolumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_ACTIVE_SOUND_VOLUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'active_sound_volume_echoes_warmup',
            'active_sound_volume_zero',
            'active_sound_volume_returns_only_one_key',
            'should_active_sound_true',
            'should_active_sound_false_cold',
            'should_active_sound_false_no_loop',
            'should_active_sound_boundary_0_01',
            'should_active_sound_returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
