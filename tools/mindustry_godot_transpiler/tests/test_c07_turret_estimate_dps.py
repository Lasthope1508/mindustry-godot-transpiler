import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_ESTIMATE_DPS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretEstimateDpsProof.gd'


class C07TurretEstimateDpsTests(unittest.TestCase):
    def test_c07_turret_estimate_dps_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2528']['godot_owner'], 'SourceTurretBuildState.source_turret_estimate_dps_state')
        # estimateDps() is the TurretBuild read (Turret.java:329-333):
        # `public float estimateDps(){` /
        # `if(!hasAmmo()) return 0f;` /
        # `return shoot.shots / reload * 60f * (peekAmmo() == null ? 0f : peekAmmo().estimateDPS()) * potentialEfficiency * timeScale;`.
        # `shoot.shots` is the ShootPattern field (`public int
        # shots = 1;`, ShootPattern.java:9 -- the class default;
        # per-def overrides in Blocks.java: salvo 2, ripple 4,
        # smite 2, malign 4, :3402/:3823/:3902/:4064 -- read from
        # the catalog shoot pattern state
        # (`shoot_state.get("shots",
        # SOURCE_SHOOT_PATTERN_SHOTS_DEFAULT)`,
        # SourceWeaponShootPatternState.gd:36) -- NOT hardcoded
        # to 1). `reload` is the per-def reload time (`public
        # float reload = 10f;`, ReloadTurret.java:10, read from
        # the catalog `block.properties` with the 10.0 default,
        # the tick :2665 precedent -- NOT hardcoded to duo).
        # `60f` is the tick rate (`const TICK_RATE := 60.0`,
        # SourceTimeDefaults.gd:4 -- NOT a literal 60 in the
        # function). `potentialEfficiency` is the frame-stamped
        # efficiency fold (`self_state["potential_efficiency"]
        # = consumption_state["potential_efficiency"]`,
        # SourceBuildingEfficiencyState.gd:178; absent folds to
        # 1.0, the N2527 missing-stamp precedent). `timeScale`
        # is the BuildingComp transient field (`private
        # transient float timeScale = 1f, timeScaleDuration;`,
        # BuildingComp.java:98), an explicit float param, NOT
        # read from the frame (the sense precedent). `has_ammo`
        # is a bool param, NOT computed in the function:
        # hasAmmo() MUTATES the ammo stack
        # (`ammo.swap(ammo.size - 1, i);`, Turret.java:703), so
        # it cannot be a pure read (the N2527 precedent). The
        # peek leg (`peekAmmo() == null ? 0f : ...`) arrives as
        # the `has_peek_ammo` bool param (the N2526 precedent)
        # plus the `peek_ammo_dps` float param: the DPS value
        # itself comes from BulletType.estimateDPS()
        # (`public float estimateDPS(){`, BulletType.java:414
        # -- the recursive frag/spawn computation with the
        # cachedDps cache), which is NOT computed in this slice
        # (that is the N2529 follow-up); this slice ports the
        # turret formula with the param. One new result symbol:
        # estimate_dps. The slice mirrors into the defense shard
        # (215/214 -> 216/215); comp stays 572/475.
        self.assertEqual(
            ledger['N2528']['source_symbols'],
            [
                'source_turret_estimate_dps_state_result.estimate_dps',
            ],
        )
        for name in ledger['N2528']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_estimate_dps_state')
        self.assertEqual(ledger['N2528']['runtime_proof'], '/root/C07TurretEstimateDpsProof')
        self.assertEqual(
            ledger['N2528']['tests'],
            [
                'test_c07_turret_estimate_dps_registration',
                'test_all_c07_turret_estimate_dps_input_evidence_is_exact',
                'test_turret_estimate_dps_state',
                'test_reference_graph_and_actual_c07_turret_estimate_dps',
            ],
        )
        self.assertTrue(ledger['N2528']['deferred_exprs'])

    def test_all_c07_turret_estimate_dps_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2528']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_estimate_dps_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/entities/pattern/ShootPattern.java',
            'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
            'core/src/mindustry/entities/bullet/BulletType.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2528']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_estimate_dps_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # estimateDps() (Turret.java:329-333) for the Turret
        # family as one pure function, in exact Java order:
        # 1 `!has_ammo` -> 0.0 (the hasAmmo() leg); 2
        # `peek_ammo_dps` = 0.0 when `!has_peek_ammo` (the
        # `peekAmmo() == null ? 0f` leg); 3 `float(shots) /
        # reload * TICK_RATE * peek_ammo_dps *
        # potential_efficiency * time_scale`, with
        # `potential_efficiency` read from the frame (default
        # 1.0). `shots` is an int param per-def (ShootPattern
        # default 1, Blocks.java per-def overrides) -- NOT
        # hardcoded to 1. `60f` is SourceTimeDefaults.TICK_RATE
        # -- NOT a literal 60. Java has NO divide-by-zero guard
        # for `reload` (every per-def reload > 0) -- parity
        # keeps none. NO driver tick call site (the
        # N2525/N2526/N2527 precedent): estimateDps() is a read
        # function, not per-tick, and no caller reads it today
        # (HUD / stats display is C11).
        self.assertIn('static func source_turret_estimate_dps_state(frame: Dictionary, has_ammo: bool, has_peek_ammo: bool, peek_ammo_dps: float, shots: int, reload: float, time_scale: float) -> Dictionary:', turret)
        self.assertIn('if not has_ammo:', turret)
        self.assertIn('return {"estimate_dps": 0.0}', turret)
        self.assertIn('var ammo_dps: float = peek_ammo_dps if has_peek_ammo else 0.0', turret)
        self.assertIn('var potential_efficiency: float = float(frame.get("potential_efficiency", 1.0))', turret)
        self.assertIn('return {"estimate_dps": float(shots) / reload * source_time_defaults.TICK_RATE * ammo_dps * potential_efficiency * time_scale}', turret)
        self.assertIn('public float estimateDps(){', turret)
        self.assertIn('if(!hasAmmo()) return 0f;', turret)
        self.assertIn('return shoot.shots / reload * 60f * (peekAmmo() == null ? 0f : peekAmmo().estimateDPS()) * potentialEfficiency * timeScale;', turret)
        self.assertIn('public int shots = 1;', turret)
        self.assertIn('public float reload = 10f;', turret)
        self.assertIn('private transient float timeScale = 1f, timeScaleDuration;', turret)
        # The pure function sits immediately AFTER
        # source_turret_status_state (N2527) and BEFORE
        # source_turret_can_heal_state.
        self.assertLess(turret.index('static func source_turret_status_state('), turret.index('static func source_turret_estimate_dps_state('))
        self.assertLess(turret.index('static func source_turret_estimate_dps_state('), turret.index('static func source_turret_can_heal_state('))
        # NO driver tick call site: estimateDps() is a read
        # function, not per-tick. The tick function must not
        # call the new pure function.
        tick = turret[turret.index('static func source_turret_tick_buildings_state('):]
        self.assertNotIn('source_turret_estimate_dps_state(', tick)
        # The proof's keys drive the pure function on exact
        # legs: 1 no ammo -> 0.0; 2 ammo but no peek ammo ->
        # 0.0; 3 shots 2 / reload 10 / dps 30 / potEff 1.0 /
        # timeScale 1.0 -> 360.0; 4 potentialEfficiency 0.5 ->
        # 180.0 (half); 5 timeScale 2.0 -> 720.0 (double); 6
        # shots 4 / reload 200 (foreshadow) / dps 30 -> 36.0;
        # 7 shots 1 / reload 20 (duo) / dps 30 -> 90.0; 8 peek
        # dps 0.0 with ammo -> 0.0.
        proof = TURRET_ESTIMATE_DPS_PROOF.read_text(encoding='utf-8')
        for key in [
            'estimate_dps_zero_no_ammo',
            'estimate_dps_zero_no_peek_ammo',
            'estimate_dps_shots_two_reload_ten',
            'estimate_dps_half_potential_efficiency',
            'estimate_dps_double_time_scale',
            'estimate_dps_shots_four_reload_large',
            'estimate_dps_duo_default',
            'estimate_dps_zero_peek_dps',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_estimate_dps(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretEstimateDpsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_ESTIMATE_DPS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'estimate_dps_zero_no_ammo',
            'estimate_dps_zero_no_peek_ammo',
            'estimate_dps_shots_two_reload_ten',
            'estimate_dps_half_potential_efficiency',
            'estimate_dps_double_time_scale',
            'estimate_dps_shots_four_reload_large',
            'estimate_dps_duo_default',
            'estimate_dps_zero_peek_dps',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
