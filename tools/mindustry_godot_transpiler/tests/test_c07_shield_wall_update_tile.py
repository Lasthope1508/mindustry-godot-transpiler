import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SHIELD_WALL_STATE = ROOT / 'godot-mindustry/src/game/SourceShieldWallBuildState.gd'
SHIELD_WALL_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ShieldWallUpdateTileProof.gd'


class C07ShieldWallUpdateTileTests(unittest.TestCase):
    def test_c07_shield_wall_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2204']['godot_owner'], 'SourceShieldWallBuildState.source_shield_wall_update_tile_state')
        # N2203 closed the damage() half (ShieldWall.java:100-117)
        # with one pure function over the frame keys plus the
        # incoming damage, but left the tick advance unmodeled
        # with a documented limit: updateTile()
        # (ShieldWall.java:74-89) decays breakTimer by Time.delta
        # while broken, regens the shield by regenSpeed * edelta()
        # while whole, decays hit by Time.delta / 10f, and lerps
        # shieldRadius toward broken() ? 0f : 1f -- yet the port
        # stamped none of those keys live, so a shield wall's
        # shield never refilled, its break timer never counted
        # down, its hit flash never faded, and its shield radius
        # never moved after placement. N2204 closes the
        # updateTile advance with one pure function over the
        # frame keys (`shield`, `break_timer`, `hit`,
        # `shield_radius`, `efficiency`,
        # `potential_efficiency`) plus the tick delta, reusing
        # the N2202 broken() coupling instead of re-implementing
        # it, and one driver line that calls it for every ticked
        # shield wall. RED decisions (pinned by this slice, the
        # proof's sixth key): breakTimer is NOT clamped on
        # decay -- Java (`breakTimer -= Time.delta;`,
        # ShieldWall.java:76) lets it go slightly negative, and
        # broken() reads `breakTimer > 0`, so a -0.5 timer is
        # whole; the regen branch is decided on the PRE-update
        # timer (the if/else, ShieldWall.java:75-81), so a timer
        # that crosses zero this tick does NOT regen yet; broken()
        # for the radius lerp is read AFTER the decay, so the
        # pure function evaluates it on the updated timer (via a
        # duplicated frame), never on the stale one. Five new
        # result symbols: the shield, the break timer, the hit
        # flash, the shield radius, and the broken flag the
        # driver re-stamps outside the consumption gate.
        self.assertEqual(
            ledger['N2204']['source_symbols'],
            [
                'source_shield_wall_update_tile_state_result.shield',
                'source_shield_wall_update_tile_state_result.break_timer',
                'source_shield_wall_update_tile_state_result.hit',
                'source_shield_wall_update_tile_state_result.shield_radius',
                'source_shield_wall_update_tile_state_result.broken',
            ],
        )
        for name in ledger['N2204']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/ShieldWall.java',
                    'core/src/mindustry/world/blocks/defense/Wall.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_shield_wall_update_tile_state_result.shield': 'SourceShieldWallBuildState.source_shield_wall_update_tile_state',
                    'source_shield_wall_update_tile_state_result.break_timer': 'SourceShieldWallBuildState.source_shield_wall_update_tile_state',
                    'source_shield_wall_update_tile_state_result.hit': 'SourceShieldWallBuildState.source_shield_wall_update_tile_state',
                    'source_shield_wall_update_tile_state_result.shield_radius': 'SourceShieldWallBuildState.source_shield_wall_update_tile_state',
                    'source_shield_wall_update_tile_state_result.broken': 'SourceShieldWallBuildState.source_shield_wall_update_tile_state',
                }[name])
        self.assertEqual(ledger['N2204']['runtime_proof'], '/root/C07ShieldWallUpdateTileProof')
        self.assertEqual(
            ledger['N2204']['tests'],
            [
                'test_c07_shield_wall_update_tile_registration',
                'test_all_c07_shield_wall_update_tile_input_evidence_is_exact',
                'test_shield_wall_update_tile_state',
                'test_reference_graph_and_actual_c07_shield_wall_update_tile',
            ],
        )
        self.assertTrue(ledger['N2204']['deferred_exprs'])

    def test_all_c07_shield_wall_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2204']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_shield_wall_update_tile_state_result.shield': 'SourceShieldWallBuildState.source_shield_wall_update_tile_state',
                    'source_shield_wall_update_tile_state_result.break_timer': 'SourceShieldWallBuildState.source_shield_wall_update_tile_state',
                    'source_shield_wall_update_tile_state_result.hit': 'SourceShieldWallBuildState.source_shield_wall_update_tile_state',
                    'source_shield_wall_update_tile_state_result.shield_radius': 'SourceShieldWallBuildState.source_shield_wall_update_tile_state',
                    'source_shield_wall_update_tile_state_result.broken': 'SourceShieldWallBuildState.source_shield_wall_update_tile_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/ShieldWall.java',
            'core/src/mindustry/world/blocks/defense/Wall.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2204']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_shield_wall_update_tile_state(self):
        shield_wall = SHIELD_WALL_STATE.read_text(encoding='utf-8')
        # The pure updateTile() advance lives on the shield-wall
        # build state: updateTile() (ShieldWall.java:74, `public
        # void updateTile(){`) decays the break timer by the raw
        # delta while broken (`if(breakTimer > 0){` /
        # `breakTimer -= Time.delta;`, ShieldWall.java:75-76,
        # no clamp -- the timer may go slightly negative and
        # broken() reads `breakTimer > 0`), regens the shield
        # while whole (`shield = Mathf.clamp(shield + regenSpeed
        # * edelta(), 0f, shieldHealth);`, ShieldWall.java:80,
        # keep on ONE comment line, the N2148 shootWarmup lesson:
        # a split line fails this test) with edelta() =
        # efficiency * delta() (BuildingComp.java:1927-1928,
        # `public float edelta(){` with `return efficiency *
        # delta();`, and `public float delta(){` with `return
        # Time.delta * timeScale;`, BuildingComp.java:1922-1923
        # -- timeScale is 1 by default and the port passes the
        # raw tick seconds, the N2190 driver convention), decays
        # the hit flash (`if(hit > 0){` / `hit -= Time.delta /
        # 10f;` / `hit = Math.max(hit, 0f);`,
        # ShieldWall.java:83-86, hit declared in WallBuild,
        # Wall.java:89, `protected float hit;`), and lerps the
        # shield radius toward broken() ? 0f : 1f (`shieldRadius
        # = Mathf.lerpDelta(shieldRadius, broken() ? 0f : 1f,
        # 0.12f);`, ShieldWall.java:88) through the port's
        # canonical lerpDelta
        # (SourceMathState.source_lerp_delta). broken() is the
        # N2202 coupling (ShieldWall.java:91, `public boolean
        # broken(){` with `return breakTimer > 0 ||
        # !canConsume();`, ShieldWall.java:92) over the break
        # timer (ShieldWall.java:45, `public float breakTimer;`,
        # set by ShieldWall.java:110, `breakTimer =
        # breakCooldown;`, breakCooldown 60f * 10f,
        # ShieldWall.java:16) and canConsume()
        # (BuildingComp.java:1917, `public boolean
        # canConsume(){` with `return potentialEfficiency > 0;`,
        # BuildingComp.java:1918) over the potential efficiency
        # (BuildingComp.java:89, `transient float
        # potentialEfficiency;`); the folded efficiency is the
        # transient field (BuildingComp.java:85, `transient
        # float efficiency;`), default 0.0 before the first
        # machinery run. The power row is
        # ConsumePower.efficiency (ConsumePower.java:39,
        # `return build.power.status;`); one def
        # (shielded-wall, `consumePower(3f / 60f);`,
        # Blocks.java:1905; shieldHealth 900f, breakCooldown 60f
        # * 10f, regenSpeed 2f, ShieldWall.java:15-17; `update =
        # true;`, ShieldWall.java:27). The shield wall is its
        # own family (ShieldWall.java:14, `public class
        # ShieldWall extends Wall{`; ShieldWallBuild,
        # ShieldWall.java:43, `public class ShieldWallBuild
        # extends WallBuild{`).
        self.assertIn('static func source_shield_wall_update_tile_state(frame: Dictionary, delta: float) -> Dictionary:', shield_wall)
        # The advance cases, pinned as the pure function's
        # decision structure: the frame carries the shield as
        # `shield` (float, absent defaults to shieldHealth
        # 900.0), the break timer as `break_timer` (float,
        # N2202 default 0.0), the hit flash as `hit` (float,
        # N2203 default 0.0), the shield radius as
        # `shield_radius` (float, absent defaults to 0.0 -- the
        # Java field init, ShieldWall.java:44, `public float
        # shield = shieldHealth, shieldRadius = 0f;`), the
        # folded efficiency as `efficiency` (float, absent
        # defaults to 0.0 -- the transient field default, the
        # N2192 charge precedent) and the live potential
        # efficiency as `potential_efficiency` (float, N2202
        # default 1.0); broken() comes from the N2202 pure
        # function evaluated on the UPDATED break timer, never
        # re-implemented and never read off the stale frame.
        # A broken wall decays its timer and does not regen; a
        # whole wall regens by 2.0 * efficiency * delta clamped
        # to shieldHealth; hit decays by delta / 10f floored at
        # 0.0; the radius lerps toward 0 when broken, 1 when
        # whole, by the port's canonical lerpDelta at 0.12.
        self.assertIn('frame.get("shield", 900.0)', shield_wall)
        self.assertIn('frame.get("break_timer", 0.0)', shield_wall)
        self.assertIn('frame.get("hit", 0.0)', shield_wall)
        self.assertIn('frame.get("shield_radius", 0.0)', shield_wall)
        self.assertIn('frame.get("efficiency", 0.0)', shield_wall)
        self.assertIn('frame.get("potential_efficiency", 1.0)', shield_wall)
        with self.subTest(case='broken wall decays its break timer'):
            self.assertIn('if break_timer > 0.0:', shield_wall)
            self.assertIn('break_timer -= delta', shield_wall)
        with self.subTest(case='whole wall regens by regenSpeed times edelta'):
            self.assertIn('shield = clampf(shield + 2.0 * efficiency * delta, 0.0, 900.0)', shield_wall)
        with self.subTest(case='hit decays by delta over ten floored at zero'):
            self.assertIn('if hit > 0.0:', shield_wall)
            self.assertIn('hit -= delta / 10.0', shield_wall)
            self.assertIn('hit = maxf(hit, 0.0)', shield_wall)
        with self.subTest(case='broken is read off the updated break timer'):
            self.assertIn('advanced_frame["break_timer"] = break_timer', shield_wall)
            self.assertIn('source_shield_wall_broken_state(advanced_frame).get("broken", false)', shield_wall)
        with self.subTest(case='radius lerps toward broken zero or whole one'):
            self.assertIn('source_math_state.source_lerp_delta(shield_radius, 0.0 if broken else 1.0, 0.12, delta)', shield_wall)
        self.assertIn('return {"shield": shield, "break_timer": break_timer, "hit": hit, "shield_radius": shield_radius, "broken": broken}', shield_wall)
        # The driver calls the advance for every ticked shield
        # wall, after the consumption block (updateConsumption
        # runs BEFORE updateTile in Java), stamps the four
        # advanced keys plus broken -- re-stamping broken
        # outside the consumption gate, the N2203 handoff note
        # -- and zeroes potential_efficiency / efficiency for a
        # disabled wall before the call (BuildingComp.java:1955,
        # `if(!enabled){` with `potentialEfficiency =
        # efficiency = optionalEfficiency = 0f;`), so a disabled
        # wall is broken and never regens.
        self.assertIn('var advanced: Dictionary = source_shield_wall_update_tile_state(frame, seconds)', shield_wall)
        self.assertIn('frame["shield"] = advanced.get("shield", 900.0)', shield_wall)
        self.assertIn('frame["break_timer"] = advanced.get("break_timer", 0.0)', shield_wall)
        self.assertIn('frame["hit"] = advanced.get("hit", 0.0)', shield_wall)
        self.assertIn('frame["shield_radius"] = advanced.get("shield_radius", 0.0)', shield_wall)
        self.assertIn('frame["broken"] = advanced.get("broken", false)', shield_wall)
        self.assertIn('frame["potential_efficiency"] = 0.0', shield_wall)
        self.assertIn('frame["efficiency"] = 0.0', shield_wall)
        self.assertIn('public void updateTile(){', shield_wall)
        self.assertIn('if(breakTimer > 0){', shield_wall)
        self.assertIn('breakTimer -= Time.delta;', shield_wall)
        self.assertIn('shield = Mathf.clamp(shield + regenSpeed * edelta(), 0f, shieldHealth);', shield_wall)
        self.assertIn('if(hit > 0){', shield_wall)
        self.assertIn('hit -= Time.delta / 10f;', shield_wall)
        self.assertIn('hit = Math.max(hit, 0f);', shield_wall)
        self.assertIn('shieldRadius = Mathf.lerpDelta(shieldRadius, broken() ? 0f : 1f, 0.12f);', shield_wall)
        self.assertIn('public boolean broken(){', shield_wall)
        self.assertIn('return breakTimer > 0 || !canConsume();', shield_wall)
        self.assertIn('public float breakTimer;', shield_wall)
        self.assertIn('public float shieldHealth = 900f;', shield_wall)
        self.assertIn('public float breakCooldown = 60f * 10f;', shield_wall)
        self.assertIn('public float regenSpeed = 2f;', shield_wall)
        self.assertIn('public float shield = shieldHealth, shieldRadius = 0f;', shield_wall)
        self.assertIn('public class ShieldWall extends Wall{', shield_wall)
        self.assertIn('public class ShieldWallBuild extends WallBuild{', shield_wall)
        self.assertIn('protected float hit;', shield_wall)
        self.assertIn('public boolean canConsume(){', shield_wall)
        self.assertIn('return potentialEfficiency > 0;', shield_wall)
        self.assertIn('transient float potentialEfficiency;', shield_wall)
        self.assertIn('transient float efficiency;', shield_wall)
        self.assertIn('public float edelta(){', shield_wall)
        self.assertIn('return efficiency * delta();', shield_wall)
        self.assertIn('public float delta(){', shield_wall)
        self.assertIn('return Time.delta * timeScale;', shield_wall)
        self.assertIn('if(!enabled){', shield_wall)
        self.assertIn('potentialEfficiency = efficiency = optionalEfficiency = 0f;', shield_wall)
        self.assertIn('return build.power.status;', shield_wall)
        self.assertIn('consumePower(3f / 60f);', shield_wall)
        self.assertIn('update = true;', shield_wall)
        # The proof's keys drive the pure advance (regen when
        # whole / no regen when broken / hit decay / radius lerp
        # toward whole / no regen + radius fall at zero power /
        # timer crossing zero without regen / absent shield
        # defaults to full health) plus the live catalog check.
        # The driver line is what stamps the keys live every
        # tick; the proof calls the pure function directly with
        # synthetic frames and the tick's seconds as delta.
        proof = SHIELD_WALL_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in [
            'shield_regens_when_whole',
            'broken_wall_does_not_regen',
            'hit_decays_to_zero',
            'radius_lerps_toward_whole',
            'no_power_wall_no_regen_radius_falls',
            'break_timer_crosses_zero_no_regen',
            'shield_absent_defaults_full_health',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_shield_wall_update_tile(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ShieldWallUpdateTileProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SHIELD_WALL_UPDATE_TILE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'shield_regens_when_whole',
            'broken_wall_does_not_regen',
            'hit_decays_to_zero',
            'radius_lerps_toward_whole',
            'no_power_wall_no_regen_radius_falls',
            'break_timer_crosses_zero_no_regen',
            'shield_absent_defaults_full_health',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
