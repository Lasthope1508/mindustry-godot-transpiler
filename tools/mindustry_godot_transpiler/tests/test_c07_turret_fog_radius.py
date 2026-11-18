import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_FOG_RADIUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretFogRadiusProof.gd'


class C07TurretFogRadiusTests(unittest.TestCase):
    def test_c07_turret_fog_radius_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2244']['godot_owner'], 'SourceTurretBuildState.source_turret_fog_radius_state')
        # TurretBuild overrides fogRadius (Turret.java:420-423,
        # `public float fogRadius(){` / `return (range +
        # (hasAmmo() ? peekAmmo().rangeChange : 0f)) /
        # tilesize * fogRadiusMultiplier;`) over the
        # BaseTurret def range (BaseTurret.java:21, `public
        # float range = 80f;`) and fogRadiusMultiplier
        # (BaseTurret.java:24, `public float
        # fogRadiusMultiplier = 1f;`), tilesize
        # (Vars.java:135, `public static final int tilesize
        # = 8;`), and the peeked bullet's rangeChange
        # (BulletType.java:157, `public float rangeChange =
        # 0f;`, default 0f). Unlike range()
        # (Turret.java:342-345, `public float range(){` /
        # `return range + peekAmmo().rangeChange;`), which
        # adds rangeChange whenever peekAmmo() is non-null
        # (Turret.java:693, `public @Nullable BulletType
        # peekAmmo(){`), fogRadius() adds it only when
        # hasAmmo() (Turret.java:698, `public boolean
        # hasAmmo(){`) -- the stricter gate (ammo present,
        # enough for a shot, canConsume). The accessor is
        # what the fog system reads (FogControl.java:161,
        # `Mathf.round(build.fogRadius())`;
        # FogRenderer.java:68, `build.fogRadius() *
        # tilesize`); the fog system itself waits for its
        # own slice. RED decisions (recorded in the
        # register docstring): (1) one pure function on
        # SourceTurretBuildState.gd next to the N2253
        # shouldConsume / N2254 progress / N2255 sense rows,
        # following the N2249 Radar fogRadius() accessor
        # precedent exactly: (frame, range, has_ammo,
        # ammo_range_change, tilesize,
        # fog_radius_multiplier) and one result key
        # `fog_radius`. (2) All live values arrive as
        # explicit params (the N2188 precedent) --
        # the tick frame tracks only cheating / enabled /
        # power_status / efficiency today. (3) Ammo absent
        # preserves the base range: has_ammo false adds 0f
        # (the N2253/N2254 absent-preserves precedent). (4)
        # NO driver line: fogRadius() is a load-time
        # accessor the fog system reads, not a per-tick
        # write (the N2249 precedent); the fog-system
        # callers wait for their own slices. One new result
        # symbol: fog_radius. This slice closes no deferred
        # item: fogRadius() was never a deferred entry of
        # the Turret chain.
        self.assertEqual(
            ledger['N2244']['source_symbols'],
            [
                'source_turret_fog_radius_state_result.fog_radius',
            ],
        )
        for name in ledger['N2244']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                    'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
                    'core/src/mindustry/Vars.java',
                    'core/src/mindustry/entities/bullet/BulletType.java',
                    'core/src/mindustry/game/FogControl.java',
                    'core/src/mindustry/graphics/FogRenderer.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2244']['runtime_proof'], '/root/C07TurretFogRadiusProof')
        self.assertEqual(
            ledger['N2244']['tests'],
            [
                'test_c07_turret_fog_radius_registration',
                'test_all_c07_turret_fog_radius_input_evidence_is_exact',
                'test_turret_fog_radius_state',
                'test_reference_graph_and_actual_c07_turret_fog_radius',
            ],
        )
        self.assertTrue(ledger['N2244']['deferred_exprs'])
        self.assertIn(
            'Turret fogRadius() Windows Godot proof',
            ' '.join(ledger['N2244']['deferred_exprs']),
        )

    def test_all_c07_turret_fog_radius_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2244']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
            'core/src/mindustry/Vars.java',
            'core/src/mindustry/entities/bullet/BulletType.java',
            'core/src/mindustry/game/FogControl.java',
            'core/src/mindustry/graphics/FogRenderer.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2244']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_fog_radius_state(self):
        turret = TURRET_STATE.read_text(encoding='utf-8')
        # TurretBuild.fogRadius() (Turret.java:420-423):
        # `public float fogRadius(){`
        # `return (range + (hasAmmo() ? peekAmmo().rangeChange
        # : 0f)) / tilesize * fogRadiusMultiplier;`
        # over the BaseTurret def range (BaseTurret.java:21,
        # `public float range = 80f;`) and
        # fogRadiusMultiplier (BaseTurret.java:24, `public
        # float fogRadiusMultiplier = 1f;`), tilesize
        # (Vars.java:135, `public static final int tilesize
        # = 8;`), and the peeked bullet's rangeChange
        # (BulletType.java:157, `public float rangeChange =
        # 0f;`). Unlike range() (Turret.java:342-345),
        # fogRadius() adds rangeChange only when hasAmmo()
        # (Turret.java:698, `public boolean hasAmmo(){`).
        # No driver line: fogRadius() is a load-time
        # accessor the fog system reads, not a per-tick
        # write (the N2249 precedent).
        self.assertIn('static func source_turret_fog_radius_state(frame: Dictionary, range: float, has_ammo: bool, ammo_range_change: float, tilesize: float, fog_radius_multiplier: float) -> Dictionary:', turret)
        self.assertIn('return {"fog_radius": (range + (ammo_range_change if has_ammo else 0.0)) / tilesize * fog_radius_multiplier}', turret)
        for expr in [
            'public float fogRadius(){',
            'return (range + (hasAmmo() ? peekAmmo().rangeChange : 0f)) / tilesize * fogRadiusMultiplier;',
            'public float range = 80f;',
            'public float fogRadiusMultiplier = 1f;',
            'public static final int tilesize = 8;',
            'public float rangeChange = 0f;',
            'public boolean hasAmmo(){',
            'public @Nullable BulletType peekAmmo(){',
            'public float range(){',
            'return range + peekAmmo().rangeChange;',
            'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
            'public class BaseTurret extends Block{',
            'Mathf.round(build.fogRadius())',
            'build.fogRadius() * tilesize',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The proof's keys drive the pure function directly
        # with explicit params: the default no-ammo radius
        # is range / tilesize * multiplier; has_ammo adds
        # the ammo rangeChange; the multiplier scales; a
        # negative rangeChange shrinks; a larger range and
        # multiplier grow; has_ammo with zero change equals
        # absent ammo; and the tilesize param divides.
        proof = TURRET_FOG_RADIUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'fog_radius_default_no_ammo',
            'fog_radius_with_ammo_range_change',
            'fog_radius_multiplier_half',
            'fog_radius_negative_range_change',
            'fog_radius_large_range_multiplier',
            'fog_radius_ammo_zero_change',
            'fog_radius_tilesize_param',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_fog_radius(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretFogRadiusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_FOG_RADIUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'fog_radius_default_no_ammo',
            'fog_radius_with_ammo_range_change',
            'fog_radius_multiplier_half',
            'fog_radius_negative_range_change',
            'fog_radius_large_range_multiplier',
            'fog_radius_ammo_zero_change',
            'fog_radius_tilesize_param',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
