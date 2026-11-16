import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTurretBuildState.gd'
REPAIR_TURRET_HEAL_ADVANCE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTurretHealAdvanceProof.gd'


class C07RepairTurretHealAdvanceTests(unittest.TestCase):
    def test_c07_repair_turret_heal_advance_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2213']['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_heal_advance_state')
        # N2212 stamped the live target (the acquire) and N2209
        # ported the coolant multiplier the heal multiplies by;
        # this slice is the heal advance itself:
        # RepairPointBuild.updateTile heals the acquired target
        # only when it has efficiency and the beam is aimed at
        # it (`if(target != null && efficiency > 0){` /
        # `float angle = Angles.angle(x, y, target.x +
        # offset.x, target.y + offset.y);` /
        # `if(Angles.angleDist(angle, rotation) < 30f){` /
        # `healed = true;` / `target.heal(repairSpeed *
        # strength * edelta() * multiplier);`,
        # RepairTurret.java:203-207). The rotation slerp
        # (`rotation = Mathf.slerpDelta(rotation, angle, 0.5f
        # * efficiency * timeScale);`,
        # RepairTurret.java:208) and the strength lerp
        # (`strength = Mathf.lerpDelta(strength, healed ? 1f
        # : 0f, 0.08f * Time.delta);`,
        # RepairTurret.java:211) are NOT this slice -- they
        # wait for their own slices (the N2212 handoff
        # deferral: "heal advance, rotation slerp, strength
        # lerp -- separate slices"). One pure function on
        # SourceRepairTurretBuildState.gd, plus one driver tick
        # line that stamps the healed target health live (the
        # N2212 precedent). Four new result symbols: healed +
        # heal_amount + target + target_health.
        self.assertEqual(
            ledger['N2213']['source_symbols'],
            [
                'source_repair_turret_heal_advance_state_result.healed',
                'source_repair_turret_heal_advance_state_result.heal_amount',
                'source_repair_turret_heal_advance_state_result.target',
                'source_repair_turret_heal_advance_state_result.target_health',
            ],
        )
        for name in ledger['N2213']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/units/RepairTurret.java',
                    'core/src/mindustry/entities/comp/HealthComp.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'arc-core/src/arc/math/Angles.java',
                    'core/src/mindustry/content/Blocks.java',
                    'core/src/mindustry/entities/comp/UnitComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_heal_advance_state')
        self.assertEqual(ledger['N2213']['runtime_proof'], '/root/C07RepairTurretHealAdvanceProof')
        self.assertEqual(
            ledger['N2213']['tests'],
            [
                'test_c07_repair_turret_heal_advance_registration',
                'test_all_c07_repair_turret_heal_advance_input_evidence_is_exact',
                'test_repair_turret_heal_advance_state',
                'test_reference_graph_and_actual_c07_repair_turret_heal_advance',
            ],
        )
        self.assertTrue(ledger['N2213']['deferred_exprs'])

    def test_all_c07_repair_turret_heal_advance_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2213']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_heal_advance_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTurret.java',
            'core/src/mindustry/entities/comp/HealthComp.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'arc-core/src/arc/math/Angles.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/entities/comp/UnitComp.java',
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2213']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_turret_heal_advance_state(self):
        repair_turret = REPAIR_TURRET_STATE.read_text(encoding='utf-8')
        # The heal advance lives on the repair-turret build
        # state, next to the N2212 acquire and the N2209
        # coolant multiplier: the gate is `target != null &&
        # efficiency > 0` (RepairTurret.java:203), the aim
        # angle is `Angles.angle(x, y, target.x + offset.x,
        # target.y + offset.y)` (RepairTurret.java:204), the
        # cone is `Angles.angleDist(angle, rotation) < 30f`
        # (RepairTurret.java:205), and the heal itself is
        # `target.heal(repairSpeed * strength * edelta() *
        # multiplier)` (RepairTurret.java:207). edelta() is
        # efficiency * delta() (BuildingComp.java:1927-1928,
        # `return efficiency * delta();`), and delta() is
        # Time.delta * timeScale (BuildingComp.java:1922-1923)
        # -- the driver passes its per-tick seconds as delta,
        # the same `seconds` the N2212 acquire uses, so the
        # pure function reads edelta = efficiency * delta
        # directly. HealthComp.heal(float) adds the amount and
        # clamps (`health += amount;` / `clampHealth();`,
        # HealthComp.java:109-111, with `health =
        # Math.min(health, maxHealth);`,
        # HealthComp.java:104). The frame carries the target
        # dict (already validated by the N2212 acquire, which
        # runs first in the same tick), rotation (Java field
        # default 90, `public float strength, rotation = 90;`,
        # RepairTurret.java:155), strength (Java field default
        # 0), efficiency (folded, absent -> 1.0, the N2174
        # fold), and the beam offset (Vector2.ZERO when there
        # is no target). The angle follows Angles.angle
        # exactly: atan2(dx, dy) in degrees, normalized to
        # [0, 360) (`float ang = Mathf.atan2(x2 - x, y2 - y)
        # * Mathf.radDeg;` / `if(ang < 0) ang += 360f;`,
        # Angles.java:56-58); the distance is the minimal
        # circular distance, always in [0, 180]
        # (`public static float angleDist(float a, float b){`
        # / `a = Mathf.mod(a, 360f);` / `b = Mathf.mod(b,
        # 360f);` / `return Math.min((a - b) < 0 ? a - b + 360
        # : a - b, (b - a) < 0 ? b - a + 360 : b - a);`,
        # Angles.java:23-26), and the cone is STRICT `< 30`
        # (30.0 exactly does not heal). `healed` is set by
        # the angle gate, not by the amount: Java sets
        # `healed = true;` before the heal call, so a
        # strength-0 turret still reports healed with a 0.0
        # amount. The returned target is a DUPLICATE with the
        # healed health -- the input dict is not mutated, so
        # the driver stamps the returned target. Rotation
        # slerp (RepairTurret.java:208) and strength lerp
        # (RepairTurret.java:211) are NOT this slice: rotation
        # and strength are read as-is and left unchanged.
        # UnitComp.heal(float) only sets the wasHealed flag
        # (`public void heal(float amount){` /
        # `wasHealed = true;`, UnitComp.java:623-625) -- the
        # port tracks no wasHealed on unit records, so that
        # side effect is unmodeled; the health increase itself
        # is HealthComp.heal. Per-def repairSpeed:
        # repair-point 0.45f, repair-turret 3f
        # (Blocks.java:6388/6400); class default 0.3f
        # (RepairTurret.java:32) -- the driver resolves it
        # from the block id, the N2209 per-def-param
        # precedent, and passes the N2209 coolant multiplier
        # as `multiplier`.
        self.assertIn('static func source_repair_turret_heal_advance_state(frame: Dictionary, x: float, y: float, repair_speed: float, delta: float, multiplier: float) -> Dictionary:', repair_turret)
        self.assertIn('var target: Variant = frame.get("target", null)', repair_turret)
        self.assertIn('if not (target is Dictionary):', repair_turret)
        self.assertIn('return {"healed": false, "heal_amount": 0.0, "target": null, "target_health": 0.0}', repair_turret)
        self.assertIn('var efficiency: float = float(frame.get("efficiency", 1.0))', repair_turret)
        self.assertIn('var strength: float = float(frame.get("strength", 0.0))', repair_turret)
        self.assertIn('var rotation: float = float(frame.get("rotation", 90.0))', repair_turret)
        self.assertIn('var offset: Vector2 = frame.get("offset", Vector2.ZERO)', repair_turret)
        self.assertIn('if efficiency <= 0.0:', repair_turret)
        self.assertIn('var angle: float = fmod(rad_to_deg(atan2(target_x - x, target_y - y)) + 360.0, 360.0)', repair_turret)
        self.assertIn('var angle_dist: float = abs(fmod(angle - rotation, 360.0))', repair_turret)
        self.assertIn('if angle_dist > 180.0:', repair_turret)
        self.assertIn('angle_dist = 360.0 - angle_dist', repair_turret)
        self.assertIn('if angle_dist >= 30.0:', repair_turret)
        self.assertIn('var edelta: float = efficiency * delta', repair_turret)
        self.assertIn('var heal_amount: float = repair_speed * strength * edelta * multiplier', repair_turret)
        self.assertIn('var healed_target: Dictionary = target.duplicate()', repair_turret)
        self.assertIn('healed_target["health"] = min(health + heal_amount, max_health)', repair_turret)
        self.assertIn('return {"healed": true, "heal_amount": heal_amount, "target": healed_target, "target_health": float(healed_target["health"])}', repair_turret)
        self.assertIn('source_repair_turret_heal_advance_state(frame, sprite.position.x, sprite.position.y, repair_speed, seconds, multiplier)', repair_turret)
        self.assertIn('if(target != null && efficiency > 0){', repair_turret)
        self.assertIn('float angle = Angles.angle(x, y, target.x + offset.x, target.y + offset.y);', repair_turret)
        self.assertIn('if(Angles.angleDist(angle, rotation) < 30f){', repair_turret)
        self.assertIn('healed = true;', repair_turret)
        self.assertIn('target.heal(repairSpeed * strength * edelta() * multiplier);', repair_turret)
        self.assertIn('rotation = Mathf.slerpDelta(rotation, angle, 0.5f * efficiency * timeScale);', repair_turret)
        self.assertIn('strength = Mathf.lerpDelta(strength, healed ? 1f : 0f, 0.08f * Time.delta);', repair_turret)
        self.assertIn('public float strength, rotation = 90;', repair_turret)
        self.assertIn('public float repairSpeed = 0.3f;', repair_turret)
        self.assertIn('void heal(float amount){', repair_turret)
        self.assertIn('health += amount;', repair_turret)
        self.assertIn('clampHealth();', repair_turret)
        self.assertIn('health = Math.min(health, maxHealth);', repair_turret)
        self.assertIn('public float delta(){', repair_turret)
        self.assertIn('return Time.delta * timeScale;', repair_turret)
        self.assertIn('public float edelta(){', repair_turret)
        self.assertIn('return efficiency * delta();', repair_turret)
        self.assertIn('float ang = Mathf.atan2(x2 - x, y2 - y) * Mathf.radDeg;', repair_turret)
        self.assertIn('if(ang < 0) ang += 360f;', repair_turret)
        self.assertIn('return Math.min((a - b) < 0 ? a - b + 360 : a - b, (b - a) < 0 ? b - a + 360 : b - a);', repair_turret)
        self.assertIn('repairSpeed = 0.45f;', repair_turret)
        self.assertIn('repairSpeed = 3f;', repair_turret)
        self.assertIn('wasHealed = true;', repair_turret)
        # The proof's keys drive the heal advance through the
        # pure function directly (the N2209 precedent -- no
        # driver tick line belongs to the pure read, the
        # driver line lands with GREEN): heals when aimed /
        # scales with strength / scales with efficiency /
        # blocked without power / blocked outside the aim cone
        # / clamps at max health / applies the coolant
        # multiplier / flag set even at zero strength. There
        # are no rotation / strength keys: the slerp and the
        # lerp wait for their own slices.
        proof = REPAIR_TURRET_HEAL_ADVANCE_PROOF.read_text(encoding='utf-8')
        for key in [
            'heal_applies_when_aimed',
            'heal_scales_with_strength',
            'heal_scales_with_efficiency',
            'heal_blocked_without_power',
            'heal_blocked_outside_aim_cone',
            'heal_clamps_at_max_health',
            'heal_applies_coolant_multiplier',
            'heal_flag_set_even_at_zero_strength',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_repair_turret_heal_advance(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTurretHealAdvanceProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TURRET_HEAL_ADVANCE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'heal_applies_when_aimed',
            'heal_scales_with_strength',
            'heal_scales_with_efficiency',
            'heal_blocked_without_power',
            'heal_blocked_outside_aim_cone',
            'heal_clamps_at_max_health',
            'heal_applies_coolant_multiplier',
            'heal_flag_set_even_at_zero_strength',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
