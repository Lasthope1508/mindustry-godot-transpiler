import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BUILD_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildTurretBuildState.gd'
WARMUP_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BuildTurretWarmupProof.gd'

PROOF_KEYS = [
    'warmup_one_point_five_passes_through',
    'warmup_zero_is_zero',
    'warmup_half_passes_through',
    'warmup_negative_passes_through',
    'parent_warmup_differs',
    'parent_warmup_matches_when_equal',
    'returns_only_one_key',
    'idempotent_second_call',
]


class C07BuildTurretWarmupTests(unittest.TestCase):
    def test_c07_build_turret_warmup_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2482']['godot_owner'], 'SourceBuildTurretBuildState.source_build_turret_warmup_state')
        # BuildTurretBuild.warmup() (BuildTurret.java:254-255):
        #     return warmup;
        # on `public class BuildTurretBuild extends
        # BaseTurretBuild implements ControlBlock, RotBlock{`
        # (BuildTurret.java:92). The field `public float
        # warmup;` (BuildTurret.java:96) is lerped by
        # updateTile every tick (`warmup =
        # Mathf.lerpDelta(warmup, unit.activelyBuilding() ?
        # efficiency : 0f, 0.1f);`, :136-137) and read by
        # draw() for the glow (`Drawf.additive(glowRegion,
        # heatColor, warmup, ...);`, :247) -- this slice is
        # ONLY the accessor: return the field whole, no
        # clamp, no floor. TRAP: a port clamping to [0, 1]
        # is wrong -- warmup follows efficiency, and
        # efficiency > 1 passes through whole (proof pins
        # 1.5 -> 1.5). TRAP: this is NOT
        # TurretBuild.warmup() (N2297, Turret.java:354-356,
        # `return shootWarmup;`) -- a different field
        # (`shootWarmup`, Turret.java:1592) in the parent
        # class; the two can differ. One input (the
        # precomputed warmup field) + one output.
        self.assertEqual(
            ledger['N2482']['java_method'],
            'BuildTurretBuild.warmup()',
        )
        self.assertEqual(
            ledger['N2482']['source_symbols'],
            [
                'source_build_turret_warmup_state_input.warmup',
                'source_build_turret_warmup_state_result.warmup',
            ],
        )
        for name in ledger['N2482']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/BuildTurret.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceBuildTurretBuildState.source_build_turret_warmup_state'))
        self.assertEqual(ledger['N2482']['runtime_proof'], '/root/C07BuildTurretWarmupProof')
        self.assertEqual(
            ledger['N2482']['tests'],
            [
                'test_c07_build_turret_warmup_registration',
                'test_all_c07_build_turret_warmup_input_evidence_is_exact',
                'test_build_turret_warmup_state',
                'test_reference_graph_and_actual_c07_build_turret_warmup',
            ],
        )
        self.assertTrue(ledger['N2482']['deferred_exprs'])

    def test_all_c07_build_turret_warmup_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2482']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceBuildTurretBuildState.source_build_turret_warmup_state'))
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/BuildTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2482']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_build_turret_warmup_state(self):
        build_turret = BUILD_TURRET_STATE.read_text(encoding='utf-8')
        # BuildTurretBuild.warmup() (BuildTurret.java:254-255):
        #     return warmup;
        # TRAP: a port clamping the field to [0, 1] is wrong
        # -- warmup follows efficiency and 1.5 passes through.
        # TRAP: a port returning `shootWarmup` (the
        # TurretBuild.warmup() body, N2297) is wrong -- this
        # reads the BuildTurretBuild field `warmup`.
        self.assertIn('static func source_build_turret_warmup_state(warmup: float) -> Dictionary:', build_turret)
        self.assertIn('return {"warmup": warmup}', build_turret)
        # Function order follows Java order: warmup()
        # (:254-255) comes after shouldConsume() (:229-230,
        # N2201, source_build_turret_should_consume_state)
        # and after canControl (:103-105, N2480) /
        # buildRotation (:107-110, N2477), and before read()
        # (:266-278, N2429,
        # source_build_turret_read_plans_state), so the new
        # function sits after should_consume and before
        # read_plans in this file.
        self.assertLess(
            build_turret.index('static func source_build_turret_should_consume_state('),
            build_turret.index('static func source_build_turret_warmup_state('),
        )
        self.assertLess(
            build_turret.index('static func source_build_turret_warmup_state('),
            build_turret.index('static func source_build_turret_read_plans_state('),
        )
        # The proof drives the pure function with the
        # precomputed warmup field (no live tick, no game
        # state): the key trap case is warmup = 1.5, which
        # must pass through unclamped; the cross-trap pins
        # the parent TurretBuild.warmup() (N2297), which
        # reads a different field (shootWarmup) -- the two
        # differ when the fields differ and agree when they
        # coincide; the result has exactly one key; a second
        # call with the same input gives the same output.
        proof = WARMUP_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_build_turret_warmup(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BuildTurretWarmupProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BUILD_TURRET_WARMUP_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
