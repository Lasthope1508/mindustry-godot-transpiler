import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTurretBuildState.gd'
REPAIR_TURRET_ROTATION_SLERP_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTurretRotationSlerpProof.gd'


class C07RepairTurretRotationSlerpTests(unittest.TestCase):
    def test_c07_repair_turret_rotation_slerp_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2214']['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_rotation_slerp_state')
        # N2213 healed the acquired target; this slice is the
        # rotation slerp on the very next line:
        # RepairPointBuild.updateTile rotates the turret toward
        # the acquired target (`rotation =
        # Mathf.slerpDelta(rotation, angle, 0.5f * efficiency *
        # timeScale);`, RepairTurret.java:209), inside the same
        # `if(target != null && efficiency > 0){` gate
        # (RepairTurret.java:203) but OUTSIDE the aim-cone
        # `if(Angles.angleDist(angle, rotation) < 30f){`
        # (RepairTurret.java:205) -- the cone gates only the
        # heal (RepairTurret.java:206-207), so the turret
        # still turns toward a target outside the cone. The
        # strength lerp (`strength = Mathf.lerpDelta(strength,
        # healed ? 1f : 0f, 0.08f * Time.delta);`,
        # RepairTurret.java:212) is NOT this slice -- it waits
        # for its own slice (the N2213 handoff deferral:
        # "rotation slerp, strength lerp -- separate
        # slices"). One pure function on
        # SourceRepairTurretBuildState.gd, plus one driver tick
        # line that stamps the slerped rotation live (the
        # N2213 precedent). One new result symbol: rotation.
        self.assertEqual(
            ledger['N2214']['source_symbols'],
            [
                'source_repair_turret_rotation_slerp_state_result.rotation',
            ],
        )
        for name in ledger['N2214']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/units/RepairTurret.java',
                    'arc-core/src/arc/math/Mathf.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'arc-core/src/arc/math/Angles.java',
                    'arc-core/src/arc/util/Time.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_rotation_slerp_state')
        self.assertEqual(ledger['N2214']['runtime_proof'], '/root/C07RepairTurretRotationSlerpProof')
        self.assertEqual(
            ledger['N2214']['tests'],
            [
                'test_c07_repair_turret_rotation_slerp_registration',
                'test_all_c07_repair_turret_rotation_slerp_input_evidence_is_exact',
                'test_repair_turret_rotation_slerp_state',
                'test_reference_graph_and_actual_c07_repair_turret_rotation_slerp',
            ],
        )
        self.assertTrue(ledger['N2214']['deferred_exprs'])

    def test_all_c07_repair_turret_rotation_slerp_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2214']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_rotation_slerp_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTurret.java',
            'arc-core/src/arc/math/Mathf.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'arc-core/src/arc/math/Angles.java',
            'arc-core/src/arc/util/Time.java',
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2214']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_turret_rotation_slerp_state(self):
        repair_turret = REPAIR_TURRET_STATE.read_text(encoding='utf-8')
        # The rotation slerp lives on the repair-turret build
        # state, next to the N2213 heal advance: the gate is
        # `target != null && efficiency > 0`
        # (RepairTurret.java:203), the aim angle is
        # `Angles.angle(x, y, target.x + offset.x, target.y +
        # offset.y)` (RepairTurret.java:204), and the slerp
        # itself is `rotation = Mathf.slerpDelta(rotation,
        # angle, 0.5f * efficiency * timeScale);`
        # (RepairTurret.java:209). The cone
        # `if(Angles.angleDist(angle, rotation) < 30f)`
        # (RepairTurret.java:205) gates ONLY the heal
        # (RepairTurret.java:206-207): the slerp line sits
        # after the cone block closes, still inside the
        # `target != null && efficiency > 0` block, so the
        # turret turns toward a target even when the beam is
        # outside the 30-degree cone. Mathf.slerpDelta
        # multiplies its progress by Time.delta and clamps to
        # [0, 1] (`return slerp(fromDegrees, toDegrees,
        # clamp(progress * Time.delta));`,
        # Mathf.java:461), and slerp always takes the shortest
        # circular path (`float delta = ((toDegrees -
        # fromDegrees + 360 + 180) % 360) - 180;` /
        # `return (fromDegrees + delta * progress + 360) %
        # 360;`, Mathf.java:456-457), returning [0, 360).
        # clamp with one argument clamps to [0, 1]
        # (`public static float clamp(float value){` /
        # `return Math.max(Math.min(value, 1f), 0f);`,
        # Mathf.java:402-403). timeScale is the Building's
        # own field (`private transient float timeScale = 1f,
        # timeScaleDuration;`, BuildingComp.java:98), read
        # through `public float timeScale(){` /
        # `return timeScale;` (BuildingComp.java:599-600) --
        # NOT the global Time.timeScale. delta() is
        # Time.delta * timeScale (BuildingComp.java:1922-1923)
        # and Time.delta is the per-frame delta
        # (`public static float delta = 1f;`,
        # Time.java:15) -- the driver passes its per-tick
        # seconds as delta, the same `seconds` the N2212
        # acquire and the N2213 heal use, so the pure
        # function folds it as `0.5 * efficiency *
        # time_scale * delta` and clamps. The frame carries
        # the target dict (already validated by the N2212
        # acquire, which runs first in the same tick),
        # rotation (Java field default 90, `public float
        # strength, rotation = 90;`,
        # RepairTurret.java:155), efficiency (folded, absent
        # -> 1.0, the N2174 fold), and the beam offset
        # (Vector2.ZERO when there is no target). The angle
        # follows Angles.angle exactly: atan2(dx, dy) in
        # degrees, normalized to [0, 360) (`float ang =
        # Mathf.atan2(x2 - x, y2 - y) * Mathf.radDeg;` /
        # `if(ang < 0) ang += 360f;`, Angles.java:56-58).
        # The driver calls the slerp AFTER the N2213 heal in
        # the same tick (the Java order: angle -> cone/heal
        # -> slerp), because the heal reads the pre-slerp
        # rotation for its cone check. The strength lerp
        # (`strength = Mathf.lerpDelta(strength, healed ? 1f
        # : 0f, 0.08f * Time.delta);`,
        # RepairTurret.java:212) is NOT this slice -- it
        # waits for its own slice. time_scale has no live
        # source in the port yet (no frame key stamps it),
        # so the driver passes `frame.get("time_scale",
        # 1.0)` -- the Java default 1f -- and a future
        # timeScale slice only needs to stamp the frame key.
        self.assertIn('static func source_repair_turret_rotation_slerp_state(frame: Dictionary, x: float, y: float, delta: float, time_scale: float) -> Dictionary:', repair_turret)
        self.assertIn('var target: Variant = frame.get("target", null)', repair_turret)
        self.assertIn('if not (target is Dictionary):', repair_turret)
        self.assertIn('return {"rotation": rotation}', repair_turret)
        self.assertIn('var rotation: float = float(frame.get("rotation", 90.0))', repair_turret)
        self.assertIn('var efficiency: float = float(frame.get("efficiency", 1.0))', repair_turret)
        self.assertIn('if efficiency <= 0.0:', repair_turret)
        self.assertIn('var offset: Vector2 = frame.get("offset", Vector2.ZERO)', repair_turret)
        self.assertIn('var angle: float = fmod(rad_to_deg(atan2(target_x - x, target_y - y)) + 360.0, 360.0)', repair_turret)
        self.assertIn('var progress: float = clampf(0.5 * efficiency * time_scale * delta, 0.0, 1.0)', repair_turret)
        self.assertIn('var angle_delta: float = fmod(angle - rotation + 360.0 + 180.0, 360.0) - 180.0', repair_turret)
        self.assertIn('var new_rotation: float = fmod(rotation + angle_delta * progress + 360.0, 360.0)', repair_turret)
        self.assertIn('return {"rotation": new_rotation}', repair_turret)
        self.assertIn('source_repair_turret_rotation_slerp_state(frame, sprite.position.x, sprite.position.y, seconds, float(frame.get("time_scale", 1.0)))', repair_turret)
        self.assertIn('if(target != null && efficiency > 0){', repair_turret)
        self.assertIn('float angle = Angles.angle(x, y, target.x + offset.x, target.y + offset.y);', repair_turret)
        self.assertIn('rotation = Mathf.slerpDelta(rotation, angle, 0.5f * efficiency * timeScale);', repair_turret)
        self.assertIn('strength = Mathf.lerpDelta(strength, healed ? 1f : 0f, 0.08f * Time.delta);', repair_turret)
        self.assertIn('public float strength, rotation = 90;', repair_turret)
        self.assertIn('public static float slerpDelta(float fromDegrees, float toDegrees, float progress){', repair_turret)
        self.assertIn('return slerp(fromDegrees, toDegrees, clamp(progress * Time.delta));', repair_turret)
        self.assertIn('float delta = ((toDegrees - fromDegrees + 360 + 180) % 360) - 180;', repair_turret)
        self.assertIn('return (fromDegrees + delta * progress + 360) % 360;', repair_turret)
        self.assertIn('public static float clamp(float value){', repair_turret)
        self.assertIn('return Math.max(Math.min(value, 1f), 0f);', repair_turret)
        self.assertIn('private transient float timeScale = 1f, timeScaleDuration;', repair_turret)
        self.assertIn('public float timeScale(){', repair_turret)
        self.assertIn('public float delta(){', repair_turret)
        self.assertIn('return Time.delta * timeScale;', repair_turret)
        self.assertIn('public static float delta = 1f;', repair_turret)
        self.assertIn('float ang = Mathf.atan2(x2 - x, y2 - y) * Mathf.radDeg;', repair_turret)
        self.assertIn('if(ang < 0) ang += 360f;', repair_turret)
        # The proof's keys drive the slerp through the pure
        # function directly (the N2213 precedent -- the
        # driver tick line lands with GREEN): turns toward
        # the target / takes the short way across 0/360 /
        # scales with efficiency / scales with time_scale /
        # unchanged without a target / unchanged without
        # power / turns even outside the aim cone / reaches
        # the target when progress clamps to 1. There are no
        # strength keys: the lerp waits for its own slice.
        proof = REPAIR_TURRET_ROTATION_SLERP_PROOF.read_text(encoding='utf-8')
        for key in [
            'rotation_turns_toward_target',
            'rotation_turns_short_way_across_360',
            'rotation_scales_with_efficiency',
            'rotation_scales_with_time_scale',
            'rotation_unchanged_without_target',
            'rotation_unchanged_without_power',
            'rotation_turns_even_outside_cone',
            'rotation_reaches_target_when_progress_clamps',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_repair_turret_rotation_slerp(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTurretRotationSlerpProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TURRET_ROTATION_SLERP_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'rotation_turns_toward_target',
            'rotation_turns_short_way_across_360',
            'rotation_scales_with_efficiency',
            'rotation_scales_with_time_scale',
            'rotation_unchanged_without_target',
            'rotation_unchanged_without_power',
            'rotation_turns_even_outside_cone',
            'rotation_reaches_target_when_progress_clamps',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
