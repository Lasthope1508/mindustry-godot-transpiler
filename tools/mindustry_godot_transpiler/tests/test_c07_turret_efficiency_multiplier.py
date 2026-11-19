import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_EFFICIENCY_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretEfficiencyMultiplierProof.gd'


class C07TurretEfficiencyMultiplierTests(unittest.TestCase):
    def test_c07_turret_efficiency_multiplier_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2265']['godot_owner'], 'SourceTurretBuildState.source_turret_efficiency_multiplier_state')
        # TurretBuild.updateEfficiencyMultiplier() (Turret.java:674-679)
        # overrides BuildingComp's (BuildingComp.java:1932-1935,
        # `float scale = efficiencyScale();` /
        # `efficiency *= scale;` / `optionalEfficiency *= scale;`)
        # with the heat fold:
        # `if(heatRequirement > 0){`
        # `efficiency *= Math.min(Math.max(heatReq / heatRequirement, cheating() ? 1f : 0f), maxHeatEfficiency);`
        # (Turret.java:675-677). The override replaces the base --
        # it does not call super and never touches
        # optionalEfficiency -- and it runs inside
        # updateConsumption() (BuildingComp.java:1949 cheating path
        # / :1996 normal path), which BuildingComp.update() calls
        # BEFORE updateTile() (:2274-2278), so the fold reads the
        # PREVIOUS tick's heatReq: heatReq is only recomputed later
        # in updateTile() (:538-540, N2263). `heatRequirement`
        # defaults to -1 (Turret.java:53, `public float
        # heatRequirement = -1f;`) and duo never sets it
        # (Blocks.java:3257-3331), so the guard is false for duo
        # and efficiency stays at the first-pass value
        # (BuildingComp.java:1946, 1.0 when enabled and
        # production-valid). Only afflict (PowerTurret,
        # `heatRequirement = 20f;`, Blocks.java:5122) and malign
        # (PowerTurret, `heatRequirement = 144f;`,
        # Blocks.java:6240) set a positive requirement among
        # turrets, with `public float maxHeatEfficiency = 3f;`
        # (Turret.java:55) capping the fold. `cheating()` is
        # `public boolean cheating(){` / `return
        # team.rules().cheat;` (TeamComp.java:17-19, N2099 stamps
        # it live on frame["cheating"] every tick), so a cheating
        # team floors the ratio at 1.0 and never loses efficiency
        # to missing heat, while a non-cheating team with no heat
        # folds to 0. This slice is the LIVE frame tick on the
        # new duo driver: one pure function on the shared
        # TurretBuild driver file plus one driver tick in the duo
        # branch BEFORE the N2253 warmup tick (Java order:
        # updateConsumption with the fold, then updateTile's
        # warmup :512-514 -- the warmup lerp reads efficiency as
        # its rate, so the fold must land first). The tick reads
        # the previous tick's frame["heat_req"] (the N2263 stamp),
        # exactly as Java reads the previous tick's heatReq field.
        # One new result symbol: efficiency.
        self.assertEqual(
            ledger['N2265']['source_symbols'],
            [
                'source_turret_efficiency_multiplier_state_result.efficiency',
            ],
        )
        for name in ledger['N2265']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/entities/comp/TeamComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_efficiency_multiplier_state_result.efficiency': 'SourceTurretBuildState.source_turret_efficiency_multiplier_state',
                }[name])
        self.assertEqual(ledger['N2265']['runtime_proof'], '/root/C07TurretEfficiencyMultiplierProof')
        self.assertEqual(
            ledger['N2265']['tests'],
            [
                'test_c07_turret_efficiency_multiplier_registration',
                'test_all_c07_turret_efficiency_multiplier_input_evidence_is_exact',
                'test_turret_efficiency_multiplier_state',
                'test_reference_graph_and_actual_c07_turret_efficiency_multiplier',
            ],
        )
        self.assertTrue(ledger['N2265']['deferred_exprs'])

    def test_all_c07_turret_efficiency_multiplier_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2265']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_efficiency_multiplier_state_result.efficiency': 'SourceTurretBuildState.source_turret_efficiency_multiplier_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/entities/comp/TeamComp.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2265']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_efficiency_multiplier_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # TurretBuild.updateEfficiencyMultiplier()
        # (Turret.java:674-679) folds the heat requirement into
        # efficiency every tick, inside updateConsumption()
        # (BuildingComp.java:1949 / :1996), which
        # BuildingComp.update() calls BEFORE updateTile()
        # (:2274-2278) -- so the fold reads the PREVIOUS tick's
        # heatReq (recomputed only later, :538-540, N2263):
        # `if(heatRequirement > 0){`
        # `efficiency *= Math.min(Math.max(heatReq / heatRequirement, cheating() ? 1f : 0f), maxHeatEfficiency);`
        # (:675-677). The override replaces the base
        # (BuildingComp.java:1932-1935, `float scale =
        # efficiencyScale();` / `efficiency *= scale;` /
        # `optionalEfficiency *= scale;`): it does not call
        # super and never touches optionalEfficiency.
        # `heatRequirement` defaults to -1
        # (`public float heatRequirement = -1f;`, Turret.java:53)
        # and duo never sets it (Blocks.java:3257-3331), so the
        # guard is false for duo and efficiency stays at the
        # first-pass value. Only afflict (PowerTurret,
        # `heatRequirement = 20f;`, Blocks.java:5122) and malign
        # (PowerTurret, `heatRequirement = 144f;`,
        # Blocks.java:6240) set a positive requirement among
        # turrets, with `public float maxHeatEfficiency = 3f;`
        # (Turret.java:55) capping the fold at 3x. `cheating()`
        # is `public boolean cheating(){` / `return
        # team.rules().cheat;` (TeamComp.java:17-19, N2099): a
        # cheating team floors the ratio at 1.0, a non-cheating
        # team with no heat folds to 0. The pure function takes
        # the first-pass efficiency, the requirement, the
        # previous tick's heatReq, the cheating flag and the max
        # and returns the one key `{"efficiency": ..}` -- when
        # the requirement is not positive efficiency is returned
        # unchanged, exactly what Java does by skipping the fold.
        # The driver tick passes the duo catalog requirement
        # -1.0 (never overridden), the frame heat_req (default
        # 0.0, the field default `public float heatReq;`,
        # Turret.java:295), the frame cheating flag (live,
        # N2099) and the class max 3.0, then stamps efficiency
        # back on the frame.
        self.assertIn('static func source_turret_efficiency_multiplier_state(efficiency: float, heat_requirement: float, heat_req: float, cheating: bool, max_heat_efficiency: float) -> Dictionary:', turret)
        self.assertIn('return {"efficiency": efficiency}', turret)
        self.assertIn('if(heatRequirement > 0){', turret)
        self.assertIn('efficiency *= Math.min(Math.max(heatReq / heatRequirement, cheating() ? 1f : 0f), maxHeatEfficiency);', turret)
        self.assertIn('public float heatRequirement = -1f;', turret)
        self.assertIn('public float maxHeatEfficiency = 3f;', turret)
        self.assertIn('public float heatReq;', turret)
        self.assertIn('public boolean cheating(){', turret)
        self.assertIn('return team.rules().cheat;', turret)
        self.assertIn('float scale = efficiencyScale();', turret)
        self.assertIn('efficiency *= scale;', turret)
        self.assertIn('heatRequirement = 20f;', turret)
        self.assertIn('heatRequirement = 144f;', turret)
        # The driver tick lives in the shared TurretBuild driver
        # (SourceTurretBuildState.gd), in the duo branch BEFORE
        # the N2253 warmup tick (Java order: updateConsumption
        # with the fold, then updateTile's warmup :512-514 --
        # the warmup lerp reads efficiency as its rate): it
        # passes the frame efficiency (default 1.0, the enabled
        # + production-valid first pass), the duo catalog
        # requirement -1.0, the previous tick's frame heat_req
        # (default 0.0), the frame cheating flag and the class
        # max 3.0, calls the new pure function, then stamps
        # efficiency back on the frame.
        self.assertIn('var efficiency_multiplier: Dictionary = source_turret_efficiency_multiplier_state(float(frame.get("efficiency", 1.0)), -1.0, float(frame.get("heat_req", 0.0)), bool(frame.get("cheating", false)), 3.0)', turret)
        self.assertIn('frame["efficiency"] = efficiency_multiplier.get("efficiency", 1.0)', turret)
        # The proof's keys drive the fold through the pure
        # function and the real driver (guard off with -1 keeps
        # the value, the duo live case / guard on with the
        # afflict requirement 20 halves efficiency at half heat
        # / a cheating team floors the ratio at 1.0 with no heat
        # / a non-cheating team with no heat folds to 0 / the
        # fold caps at maxHeatEfficiency 3.0 / a zero requirement
        # keeps the value, the guard is strict > / the malign
        # requirement 144 halves 0.8 to 0.4 at half heat / the
        # fold is stamped on the frame after the tick / the duo
        # live tick keeps efficiency 1.0). There is no live
        # heat scan: calculateHeat's proximity walk waits for
        # its own slice (live entity scan, BLOCKED, N2263).
        proof = TURRET_EFFICIENCY_PROOF.read_text(encoding='utf-8')
        for key in [
            'eff_mult_guard_off_keeps_value',
            'eff_mult_guard_on_scales',
            'eff_mult_cheating_floor_one',
            'eff_mult_noncheating_floor_zero',
            'eff_mult_capped_at_max',
            'eff_mult_zero_requirement_keeps',
            'eff_mult_malign_partial',
            'eff_mult_stamped_to_frame',
            'eff_mult_duo_live',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_efficiency_multiplier(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretEfficiencyMultiplierProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_EFFICIENCY_MULTIPLIER_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'eff_mult_guard_off_keeps_value',
            'eff_mult_guard_on_scales',
            'eff_mult_cheating_floor_one',
            'eff_mult_noncheating_floor_zero',
            'eff_mult_capped_at_max',
            'eff_mult_zero_requirement_keeps',
            'eff_mult_malign_partial',
            'eff_mult_stamped_to_frame',
            'eff_mult_duo_live',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
