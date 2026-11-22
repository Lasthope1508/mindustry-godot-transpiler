import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LIQUID_TURRET_BUILD = ROOT / 'godot-mindustry/src/game/SourceLiquidTurretBuildState.gd'
SCAN_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LiquidTurretFindTargetScanProof.gd'


class C07LiquidTurretFindTargetScanTests(unittest.TestCase):
    def test_c07_liquid_turret_find_target_scan_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2408']['godot_owner'], 'SourceLiquidTurretBuildState.source_liquid_turret_find_target_scan_state')
        # LiquidTurretBuild.findTarget() extinguish-scan loop
        # (LiquidTurret.java:91-117): the 12 loop exprs only.
        # The shell is already the exact_expr of N1200
        # (`protected void findTarget(){`,
        # `if(extinguish && liquids.current().canExtinguish()){`,
        # `Fire result = null;`, `target = result;`,
        # `return;`, `super.findTarget();` -- plus the class
        # decl and @Override) and is never re-registered
        # here; the `if(result != null){` tail
        # (`target = result;` + `return;`) also stays
        # N1200-owned -- this slice only computes the scan
        # result (fire_result + mindst + result_found). The
        # signature line also hits local N2316
        # (TurretBuild.findTarget) -- it is not registered
        # here either. One GD function on
        # SourceLiquidTurretBuildState.gd next to the N1200
        # shell (`find_target_extinguish_state`).
        self.assertEqual(
            ledger['N2408']['java_method'],
            'LiquidTurretBuild.findTarget()',
        )
        self.assertEqual(
            ledger['N2408']['source_symbols'],
            [
                'source_liquid_turret_find_target_scan_state_result.fire_result',
                'source_liquid_turret_find_target_scan_state_result.mindst',
                'source_liquid_turret_find_target_scan_state_result.result_found',
                'source_liquid_turret_find_target_scan_state_result.tile_x',
                'source_liquid_turret_find_target_scan_state_result.tile_y',
                'source_liquid_turret_find_target_scan_state_result.scan_radius',
                'source_liquid_turret_find_target_scan_state_result.build_x',
                'source_liquid_turret_find_target_scan_state_result.build_y',
                'source_liquid_turret_find_target_scan_state_result.scan_range',
                'source_liquid_turret_find_target_scan_state_result.tilesize',
                'source_liquid_turret_find_target_scan_state_result.team',
                'source_liquid_turret_find_target_scan_state_result.self_build',
            ],
        )
        for name in ledger['N2408']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/LiquidTurret.java',
                })
                self.assertTrue(symbol['godot_owner'].startswith('SourceLiquidTurretBuildState.source_liquid_turret_find_target_scan_state'))
        self.assertEqual(ledger['N2408']['runtime_proof'], '/root/C07LiquidTurretFindTargetScanProof')
        self.assertEqual(
            ledger['N2408']['tests'],
            [
                'test_c07_liquid_turret_find_target_scan_registration',
                'test_all_c07_liquid_turret_find_target_scan_input_evidence_is_exact',
                'test_liquid_turret_find_target_scan_state',
                'test_reference_graph_and_actual_c07_liquid_turret_find_target_scan',
            ],
        )
        self.assertTrue(ledger['N2408']['deferred_exprs'])

    def test_all_c07_liquid_turret_find_target_scan_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2408']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceLiquidTurretBuildState.source_liquid_turret_find_target_scan_state'))
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/LiquidTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2408']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_liquid_turret_find_target_scan_state(self):
        build = LIQUID_TURRET_BUILD.read_text(encoding='utf-8')
        # LiquidTurretBuild.findTarget() (LiquidTurret.java:91-117):
        # the scan loop only -- the shell is N1200-owned (see
        # the registration test) and is NOT re-registered.
        # `range` is named `scan_range` in GD because `range`
        # shadows GDScript's builtin `range()` used by the
        # loop; `tilesize` is Vars.tilesize (8), always
        # positive. World lookups arrive as Callables (the
        # N2395/N2316 precedent): world_tile returns a tile
        # Dictionary {"build": Variant, "build_team":
        # Variant} or null out of bounds, fires_get returns
        # a fire Dictionary or null, fires_has reports
        # Fires.has, dst2 returns the squared distance from
        # the build to the fire.
        self.assertIn('static func source_liquid_turret_find_target_scan_state(build_x: float, build_y: float, scan_range: float, tilesize: float, team: Variant, self_build: Variant, world_tile: Callable, fires_get: Callable, fires_has: Callable, dst2: Callable) -> Dictionary:', build)
        for expr in [
            'int tx = World.toTile(x), ty = World.toTile(y);',
            'float mindst = 0f;',
            'int tr = (int)(range / tilesize);',
            'for(int x = -tr; x <= tr; x++){',
            'for(int y = -tr; y <= tr; y++){',
            'Tile other = world.tile(x + tx, y + ty);',
            'var fire = Fires.get(x + tx, y + ty);',
            'float dst = fire == null ? 0 : dst2(fire);',
            'if(other != null && fire != null && other.build != this && Fires.has(other.x, other.y) && dst <= range * range && (result == null || dst < mindst) && (other.build == null || other.team() == team)){',
            'result = fire;',
            'mindst = dst;',
            'if(result != null){',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, build)
        # The proof's keys drive the pure function with
        # synthetic inputs (no live tick, no render): the
        # scan finds the nearest valid fire, excludes
        # other-team builds, the own tile, finished fires
        # and null tiles, replaces the first candidate with
        # a nearer one, and reports no fire when none.
        proof = SCAN_PROOF.read_text(encoding='utf-8')
        for key in [
            'scan_finds_nearest_valid_fire',
            'scan_mindst_is_nearest_dst',
            'scan_excludes_other_team_build',
            'scan_excludes_self_build_tile',
            'scan_excludes_finished_fire',
            'scan_excludes_null_tile',
            'scan_replaces_first_with_nearer',
            'scan_returns_no_fire_when_none',
            'scan_reports_origin_and_radius',
            'scan_returns_only_twelve_keys',
            'scan_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_liquid_turret_find_target_scan(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LiquidTurretFindTargetScanProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LIQUID_TURRET_FIND_TARGET_SCAN_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'scan_finds_nearest_valid_fire',
            'scan_mindst_is_nearest_dst',
            'scan_excludes_other_team_build',
            'scan_excludes_self_build_tile',
            'scan_excludes_finished_fire',
            'scan_excludes_null_tile',
            'scan_replaces_first_with_nearer',
            'scan_returns_no_fire_when_none',
            'scan_reports_origin_and_radius',
            'scan_returns_only_twelve_keys',
            'scan_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
