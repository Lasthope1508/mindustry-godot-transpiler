import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_FOG_RADIUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretFogRadiusProof.gd'


class C07TurretFogRadiusTests(unittest.TestCase):
    def test_c07_turret_fog_radius_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2531']['godot_owner'], 'SourceTurretBuildState.source_turret_fog_radius_state')
        # fogRadius() is the TurretBuild read (Turret.java:420-422):
        # `public float fogRadius(){` /
        # `return (range + (hasAmmo() ? peekAmmo().rangeChange : 0f)) / tilesize * fogRadiusMultiplier;`
        # -- it uses the `range` FIELD plus the peeked ammo
        # rangeChange when hasAmmo() is true; it does NOT
        # call range() (Turret.java:343-347), though the
        # value equals range() when hasAmmo is true and
        # peekAmmo is non-null. `tilesize` is
        # `public static final int tilesize = 8;`
        # (Vars.java:135) and `fogRadiusMultiplier` is the
        # block field `public float fogRadiusMultiplier = 1f;`
        # (BaseTurret.java:24), with the one per-def
        # override `fogRadiusMultiplier = 0.4f;`
        # (Blocks.java:5627, scathe). `rangeChange` is the
        # BulletType field `public float rangeChange = 0f;`
        # (BulletType.java:157). `range` is the block field
        # `public float range = 80f;` (BaseTurret.java:21).
        # NOT the block-init fogRadius (BaseTurret.java:59,
        # `fogRadius = Math.max(Mathf.round(range / tilesize * fogRadiusMultiplier), fogRadius);`)
        # -- that is a field init at block level, not the
        # TurretBuild.fogRadius() override. One new result
        # symbol: fog_radius. The slice mirrors into the
        # defense shard (217/216 -> 218/217); comp stays
        # 572/475.
        self.assertEqual(
            ledger['N2531']['source_symbols'],
            [
                'source_turret_fog_radius_state_result.fog_radius',
            ],
        )
        for name in ledger['N2531']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/turrets/Turret.java')
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_fog_radius_state')
        self.assertEqual(ledger['N2531']['runtime_proof'], '/root/C07TurretFogRadiusProof')
        self.assertEqual(
            ledger['N2531']['tests'],
            [
                'test_c07_turret_fog_radius_registration',
                'test_all_c07_turret_fog_radius_input_evidence_is_exact',
                'test_turret_fog_radius_state',
                'test_reference_graph_and_actual_c07_turret_fog_radius',
            ],
        )
        self.assertTrue(ledger['N2531']['deferred_exprs'])

    def test_all_c07_turret_fog_radius_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2531']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_fog_radius_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
            'core/src/mindustry/Vars.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/entities/bullet/BulletType.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2531']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_fog_radius_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # fogRadius() (Turret.java:420-422) for the Turret
        # family as one pure function: `(range + (hasAmmo()
        # ? peekAmmo().rangeChange : 0f)) / tilesize *
        # fogRadiusMultiplier` -- five params, one float
        # result key `fog_radius`. `hasAmmo()` MUTATES the
        # ammo stack (`ammo.swap(ammo.size - 1, i);`,
        # Turret.java:703), so it is a bool param, not
        # computed in the function (the N2527/N2528
        # precedent). `peek_ammo_range_change` is a float
        # param: the BulletType.rangeChange value itself
        # (BulletType.java:157). `tilesize` is the
        # Vars.java:135 constant, an explicit int param.
        # `fog_radius_multiplier` is the BaseTurret.java:24
        # field, an explicit float param, never hardcoded
        # (scathe overrides it to 0.4f in Blocks.java:5627).
        # NO driver tick call site (the N2528/N2530
        # precedent): fogRadius() is a read, not per-tick,
        # and no caller reads it today (fog-of-war / draw
        # logic is a later slice).
        self.assertIn('static func source_turret_fog_radius_state(range_value: float, has_ammo: bool, peek_ammo_range_change: float, tilesize: int, fog_radius_multiplier: float) -> Dictionary:', turret)
        self.assertIn('return {"fog_radius": (range_value + (peek_ammo_range_change if has_ammo else 0.0)) / float(tilesize) * fog_radius_multiplier}', turret)
        self.assertIn('public float fogRadius(){', turret)
        self.assertIn('return (range + (hasAmmo() ? peekAmmo().rangeChange : 0f)) / tilesize * fogRadiusMultiplier;', turret)
        self.assertIn('public static final int tilesize = 8;', turret)
        self.assertIn('public float fogRadiusMultiplier = 1f;', turret)
        self.assertIn('public float rangeChange = 0f;', turret)
        self.assertIn('public float range = 80f;', turret)
        self.assertIn('fogRadiusMultiplier = 0.4f;', turret)
        # The pure function sits immediately AFTER
        # source_turret_can_control_state (N2530) and BEFORE
        # source_turret_can_heal_state.
        self.assertLess(turret.index('static func source_turret_can_control_state('), turret.index('static func source_turret_fog_radius_state('))
        self.assertLess(turret.index('static func source_turret_fog_radius_state('), turret.index('static func source_turret_can_heal_state('))
        # NO driver tick call site: fogRadius() is a read,
        # not per-tick. The tick function must not call the
        # new pure function.
        tick = turret[turret.index('static func source_turret_tick_buildings_state('):]
        self.assertNotIn('source_turret_fog_radius_state(', tick)
        # The proof's keys drive the pure function on exact
        # legs: 1 has ammo, range 180 + rangeChange 40 ->
        # (180+40)/8*1 = 27.5; 2 no ammo, same range and
        # rangeChange -> 180/8*1 = 22.5; 3 the BaseTurret
        # default range 80, no ammo, multiplier 1 ->
        # 80/8*1 = 10.0; 4 the scathe multiplier 0.4f,
        # range 240 -> 240/8*0.4 = 12.0; 5 the result
        # carries exactly the single `fog_radius` key; 6
        # the result value is a float; 7 rangeChange is
        # ignored when hasAmmo is false (range 80, rc 100
        # -> 80/8*1 = 10.0); 8 the function is param-driven
        # and deterministic (same params, same result, no
        # hidden state).
        proof = TURRET_FOG_RADIUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'fog_radius_ammo',
            'fog_radius_no_ammo',
            'fog_radius_default',
            'fog_radius_scathe_multiplier',
            'fog_radius_single_key',
            'fog_radius_float_type',
            'fog_radius_range_change_ignored',
            'fog_radius_param_driven',
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
            'fog_radius_ammo',
            'fog_radius_no_ammo',
            'fog_radius_default',
            'fog_radius_scathe_multiplier',
            'fog_radius_single_key',
            'fog_radius_float_type',
            'fog_radius_range_change_ignored',
            'fog_radius_param_driven',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
