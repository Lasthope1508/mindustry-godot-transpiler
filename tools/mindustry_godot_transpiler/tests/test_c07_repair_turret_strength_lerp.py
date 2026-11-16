import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTurretBuildState.gd'
REPAIR_TURRET_STRENGTH_LERP_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTurretStrengthLerpProof.gd'


class C07RepairTurretStrengthLerpTests(unittest.TestCase):
    def test_c07_repair_turret_strength_lerp_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2215']['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_strength_lerp_state')
        # N2214 slerped the rotation toward the target; this
        # slice is the strength lerp on the next line:
        # RepairPointBuild.updateTile fades the beam strength
        # toward 1 while healing and toward 0 otherwise
        # (`strength = Mathf.lerpDelta(strength, healed ? 1f
        # : 0f, 0.08f * Time.delta);`,
        # RepairTurret.java:212). Unlike the heal and the
        # slerp, the lerp sits OUTSIDE the `if(target !=
        # null && efficiency > 0){` gate
        # (RepairTurret.java:203) -- it runs on EVERY tick,
        # so a turret that stops healing decays its beam
        # back to 0 instead of freezing at full strength.
        # `healed` is the same tick's local (`boolean healed
        # = false;`, RepairTurret.java:200, set true only
        # inside the cone, RepairTurret.java:206), and the
        # N2213 heal stamps it on the frame, so the pure
        # function reads `frame["healed"]`. One pure
        # function on SourceRepairTurretBuildState.gd, plus
        # one driver tick line that stamps the lerped
        # strength live (the N2214 precedent). One new
        # result symbol: strength.
        self.assertEqual(
            ledger['N2215']['source_symbols'],
            [
                'source_repair_turret_strength_lerp_state_result.strength',
            ],
        )
        for name in ledger['N2215']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/units/RepairTurret.java',
                    'arc-core/src/arc/math/Mathf.java',
                    'arc-core/src/arc/util/Time.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_strength_lerp_state')
        self.assertEqual(ledger['N2215']['runtime_proof'], '/root/C07RepairTurretStrengthLerpProof')
        self.assertEqual(
            ledger['N2215']['tests'],
            [
                'test_c07_repair_turret_strength_lerp_registration',
                'test_all_c07_repair_turret_strength_lerp_input_evidence_is_exact',
                'test_repair_turret_strength_lerp_state',
                'test_reference_graph_and_actual_c07_repair_turret_strength_lerp',
            ],
        )
        self.assertTrue(ledger['N2215']['deferred_exprs'])

    def test_all_c07_repair_turret_strength_lerp_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2215']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_strength_lerp_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTurret.java',
            'arc-core/src/arc/math/Mathf.java',
            'arc-core/src/arc/util/Time.java',
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2215']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_turret_strength_lerp_state(self):
        repair_turret = REPAIR_TURRET_STATE.read_text(encoding='utf-8')
        # The strength lerp lives on the repair-turret build
        # state, next to the N2214 rotation slerp: the beam
        # strength fades toward 1 while healing and toward 0
        # otherwise (`strength = Mathf.lerpDelta(strength,
        # healed ? 1f : 0f, 0.08f * Time.delta);`,
        # RepairTurret.java:212). The lerp runs on EVERY
        # tick -- line 212 sits after the `if(target !=
        # null && efficiency > 0){` gate
        # (RepairTurret.java:203) closes, so strength decays
        # toward 0 with no target or no power instead of
        # freezing. `healed` is the same tick's local
        # (`boolean healed = false;`,
        # RepairTurret.java:200, set `healed = true;` only
        # inside the aim cone, RepairTurret.java:206, before
        # the heal `target.heal(repairSpeed * strength *
        # edelta() * multiplier);`, RepairTurret.java:207) --
        # the N2213 heal stamps it on the frame, so the pure
        # function reads `frame["healed"]` (absent -> false,
        # no heal observed). strength is a Java field
        # (`public float strength, rotation = 90;`,
        # RepairTurret.java:155), default 0. Mathf.lerpDelta
        # multiplies its progress by Time.delta and clamps
        # to [0, 1] (`return lerp(fromValue, toValue,
        # clamp(progress * Time.delta));`,
        # Mathf.java:431), and lerp is the plain linear
        # interpolation (`return fromValue + (toValue -
        # fromValue) * progress;`, Mathf.java:426).
        # clamp with one argument clamps to [0, 1]
        # (`public static float clamp(float value){` /
        # `return Math.max(Math.min(value, 1f), 0f);`,
        # Mathf.java:402-403). Time.delta is the per-frame
        # delta (`public static float delta = 1f;`,
        # Time.java:15) -- the driver passes its per-tick
        # seconds as delta, the same `seconds` the N2212
        # acquire, the N2213 heal and the N2214 slerp use, so
        # the pure function folds it as `0.08 * delta` and
        # clamps. The driver calls the lerp AFTER the N2214
        # slerp in the same tick (the Java order: angle ->
        # cone/heal -> slerp -> strength lerp), because the
        # heal reads the pre-lerp strength. This is the
        # FIRST stamp of `frame["strength"]` -- before N2215
        # the N2213 heal read strength 0.0 forever, so no
        # repair turret ever healed anything.
        self.assertIn('static func source_repair_turret_strength_lerp_state(frame: Dictionary, delta: float) -> Dictionary:', repair_turret)
        self.assertIn('var strength: float = float(frame.get("strength", 0.0))', repair_turret)
        self.assertIn('var healed: bool = bool(frame.get("healed", false))', repair_turret)
        self.assertIn('var target_strength: float = 1.0 if healed else 0.0', repair_turret)
        self.assertIn('var progress: float = clampf(0.08 * delta, 0.0, 1.0)', repair_turret)
        self.assertIn('return {"strength": strength + (target_strength - strength) * progress}', repair_turret)
        self.assertIn('source_repair_turret_strength_lerp_state(frame, seconds)', repair_turret)
        self.assertIn('strength = Mathf.lerpDelta(strength, healed ? 1f : 0f, 0.08f * Time.delta);', repair_turret)
        self.assertIn('public float strength, rotation = 90;', repair_turret)
        self.assertIn('public static float lerpDelta(float fromValue, float toValue, float progress){', repair_turret)
        self.assertIn('return lerp(fromValue, toValue, clamp(progress * Time.delta));', repair_turret)
        self.assertIn('public static float lerp(float fromValue, float toValue, float progress){', repair_turret)
        self.assertIn('return fromValue + (toValue - fromValue) * progress;', repair_turret)
        self.assertIn('public static float clamp(float value){', repair_turret)
        self.assertIn('return Math.max(Math.min(value, 1f), 0f);', repair_turret)
        self.assertIn('public static float delta = 1f;', repair_turret)
        self.assertIn('boolean healed = false;', repair_turret)
        self.assertIn('healed = true;', repair_turret)
        self.assertIn('target.heal(repairSpeed * strength * edelta() * multiplier);', repair_turret)
        self.assertIn('if(target != null && efficiency > 0){', repair_turret)
        # The proof's keys drive the lerp through the pure
        # function directly (the N2214 precedent -- the
        # driver tick line lands with GREEN): rises toward 1
        # when healing / decays toward 0 when not healing /
        # rises from 0 when healing / decays from 1 when not
        # healing / scales with delta / clamps progress at 1
        # / unchanged at 1 when healing / unchanged at 0
        # when not healing.
        proof = REPAIR_TURRET_STRENGTH_LERP_PROOF.read_text(encoding='utf-8')
        for key in [
            'strength_rises_toward_one_when_healed',
            'strength_decays_toward_zero_when_not_healed',
            'strength_rises_from_zero_when_healed',
            'strength_decays_from_one_when_not_healed',
            'strength_scales_with_delta',
            'strength_clamps_progress_at_one',
            'strength_unchanged_at_one_when_healed',
            'strength_unchanged_at_zero_when_not_healed',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_repair_turret_strength_lerp(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTurretStrengthLerpProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TURRET_STRENGTH_LERP_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'strength_rises_toward_one_when_healed',
            'strength_decays_toward_zero_when_not_healed',
            'strength_rises_from_zero_when_healed',
            'strength_decays_from_one_when_not_healed',
            'strength_scales_with_delta',
            'strength_clamps_progress_at_one',
            'strength_unchanged_at_one_when_healed',
            'strength_unchanged_at_zero_when_not_healed',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
