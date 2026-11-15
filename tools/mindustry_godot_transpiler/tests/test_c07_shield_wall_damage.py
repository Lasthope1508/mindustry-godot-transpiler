import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SHIELD_WALL_STATE = ROOT / 'godot-mindustry/src/game/SourceShieldWallBuildState.gd'
SHIELD_WALL_DAMAGE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ShieldWallDamageProof.gd'


class C07ShieldWallDamageTests(unittest.TestCase):
    def test_c07_shield_wall_damage_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2203']['godot_owner'], 'SourceShieldWallBuildState.source_shield_wall_damage_state')
        # N2202 closed the broken() half (ShieldWall.java:91-92,
        # `return breakTimer > 0 || !canConsume();`) with one pure
        # function over the break timer and the live potential
        # efficiency, but left the damage path unmodeled with a
        # documented limit: damage() (ShieldWall.java:100-117)
        # reads broken() to decide how much of the incoming
        # damage the shield absorbs (`float shieldTaken =
        # broken() ? 0f : Math.min(shield, damage);`,
        # ShieldWall.java:102), drops the shield by the absorbed
        # amount, flashes hit when anything was absorbed, sets
        # breakTimer = breakCooldown when the shield breaks, and
        # passes only the leftover damage to super.damage --
        # yet the port had no damage function at all, so a
        # shield wall hit by a bullet would take the full damage
        # straight to building health as if it had no shield.
        # N2203 closes the damage() half with one pure function
        # over the frame keys (`shield`, `hit`, `break_timer`,
        # `potential_efficiency`) plus the incoming damage, reusing
        # the N2202 broken() coupling instead of re-implementing
        # it. RED decisions (pinned by this slice, the proof's
        # fifth key): when the frame carries NO `shield` key,
        # default to shieldHealth 900.0 (the Java field init,
        # ShieldWall.java:44, `public float shield =
        # shieldHealth, shieldRadius = 0f;`, shieldHealth 900f,
        # ShieldWall.java:15) -- absent means "shield never
        # damaged yet", not "shield gone"; when the frame carries
        # NO `hit` key, default to 0.0 (the WallBuild field
        # default, Wall.java:89, `protected float hit;`); the
        # `break_timer` / `potential_efficiency` defaults are the
        # N2202 ones (0.0 / 1.0). The residual damage is
        # returned for the caller; applying it to building health
        # (super.damage, BuildingComp.java:2059-2080) waits for
        # a live damage call site -- no ShieldWall damage caller
        # exists in the port yet. Five new result symbols: the
        # absorbed amount, the shield left, the hit flash, the
        # break timer, and the residual damage.
        self.assertEqual(
            ledger['N2203']['source_symbols'],
            [
                'source_shield_wall_damage_state_result.shield_taken',
                'source_shield_wall_damage_state_result.shield',
                'source_shield_wall_damage_state_result.hit',
                'source_shield_wall_damage_state_result.break_timer',
                'source_shield_wall_damage_state_result.residual_damage',
            ],
        )
        for name in ledger['N2203']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/ShieldWall.java',
                    'core/src/mindustry/world/blocks/defense/Wall.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_shield_wall_damage_state_result.shield_taken': 'SourceShieldWallBuildState.source_shield_wall_damage_state',
                    'source_shield_wall_damage_state_result.shield': 'SourceShieldWallBuildState.source_shield_wall_damage_state',
                    'source_shield_wall_damage_state_result.hit': 'SourceShieldWallBuildState.source_shield_wall_damage_state',
                    'source_shield_wall_damage_state_result.break_timer': 'SourceShieldWallBuildState.source_shield_wall_damage_state',
                    'source_shield_wall_damage_state_result.residual_damage': 'SourceShieldWallBuildState.source_shield_wall_damage_state',
                }[name])
        self.assertEqual(ledger['N2203']['runtime_proof'], '/root/C07ShieldWallDamageProof')
        self.assertEqual(
            ledger['N2203']['tests'],
            [
                'test_c07_shield_wall_damage_registration',
                'test_all_c07_shield_wall_damage_input_evidence_is_exact',
                'test_shield_wall_damage_state',
                'test_reference_graph_and_actual_c07_shield_wall_damage',
            ],
        )
        self.assertTrue(ledger['N2203']['deferred_exprs'])

    def test_all_c07_shield_wall_damage_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2203']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_shield_wall_damage_state_result.shield_taken': 'SourceShieldWallBuildState.source_shield_wall_damage_state',
                    'source_shield_wall_damage_state_result.shield': 'SourceShieldWallBuildState.source_shield_wall_damage_state',
                    'source_shield_wall_damage_state_result.hit': 'SourceShieldWallBuildState.source_shield_wall_damage_state',
                    'source_shield_wall_damage_state_result.break_timer': 'SourceShieldWallBuildState.source_shield_wall_damage_state',
                    'source_shield_wall_damage_state_result.residual_damage': 'SourceShieldWallBuildState.source_shield_wall_damage_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/ShieldWall.java',
            'core/src/mindustry/world/blocks/defense/Wall.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2203']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_shield_wall_damage_state(self):
        shield_wall = SHIELD_WALL_STATE.read_text(encoding='utf-8')
        # The pure damage() coupling lives on the shield-wall
        # build state: damage() (ShieldWall.java:100, `public
        # void damage(float damage){`) absorbs `float
        # shieldTaken = broken() ? 0f : Math.min(shield,
        # damage);` (ShieldWall.java:102) -- broken() is the
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
        # potentialEfficiency;`). The shield drops by the
        # absorbed amount (`shield -= shieldTaken;`,
        # ShieldWall.java:104) from its field init (`public
        # float shield = shieldHealth, shieldRadius = 0f;`,
        # ShieldWall.java:44, shieldHealth 900f,
        # ShieldWall.java:15); anything absorbed flashes hit
        # (`if(shieldTaken > 0){` / `hit = 1f;`,
        # ShieldWall.java:105-106, hit declared in WallBuild,
        # Wall.java:89, `protected float hit;`); a shield
        # driven to zero breaks the wall (`if(shield <=
        # 0.00001f && shieldTaken > 0){` / `breakTimer =
        # breakCooldown;`, ShieldWall.java:109-110); only the
        # leftover damage reaches the building (`if(damage -
        # shieldTaken > 0){` / `super.damage(damage -
        # shieldTaken);`, ShieldWall.java:113-114), and
        # super.damage is BuildingComp.damage(float)
        # (BuildingComp.java:2059, `public void damage(float
        # damage){` with `if(dead()) return;`,
        # BuildingComp.java:2060, `health -=
        # handleDamage(damage);`, BuildingComp.java:2071, and
        # `if(health <= 0){`, BuildingComp.java:2076). The
        # shield regen advance (ShieldWall.java:80, `shield =
        # Mathf.clamp(shield + regenSpeed * edelta(), 0f,
        # shieldHealth);`, keep on ONE comment line, the N2148
        # shootWarmup lesson: a split line fails this test)
        # is what refills the shield between hits; the radius
        # lerp reads broken() (ShieldWall.java:88,
        # `shieldRadius = Mathf.lerpDelta(shieldRadius, broken()
        # ? 0f : 1f, 0.12f);`). The power row is
        # ConsumePower.efficiency (ConsumePower.java:39,
        # `return build.power.status;`); one def
        # (shielded-wall, `consumePower(3f / 60f);`,
        # Blocks.java:1905; regenSpeed 2f,
        # ShieldWall.java:17; `update = true;`,
        # ShieldWall.java:27). The shield wall is its own family
        # (ShieldWall.java:14, `public class ShieldWall extends
        # Wall{`; ShieldWallBuild, ShieldWall.java:43, `public
        # class ShieldWallBuild extends WallBuild{`).
        self.assertIn('static func source_shield_wall_damage_state(frame: Dictionary, damage: float) -> Dictionary:', shield_wall)
        # The damage cases, pinned as the pure function's
        # decision structure: the frame carries the shield as
        # `shield` (float, absent defaults to shieldHealth
        # 900.0), the hit flash as `hit` (float, absent defaults
        # to 0.0), the break timer as `break_timer` (float,
        # N2202 default 0.0) and the live potential efficiency
        # as `potential_efficiency` (float, N2202 default 1.0);
        # broken() comes from the N2202 pure function, never
        # re-implemented. shield_taken is 0 when broken, else
        # min(shield, damage); the shield drops by the absorbed
        # amount; hit flashes to 1.0 only when something was
        # absorbed; a shield driven to zero sets break_timer to
        # breakCooldown (60f * 10f); the residual is damage
        # minus shield_taken, returned for the caller -- no live
        # damage call site applies it to building health yet.
        self.assertIn('frame.get("shield", 900.0)', shield_wall)
        self.assertIn('frame.get("hit", 0.0)', shield_wall)
        self.assertIn('frame.get("break_timer", 0.0)', shield_wall)
        self.assertIn('source_shield_wall_broken_state(frame).get("broken", false)', shield_wall)
        with self.subTest(case='whole wall absorbs partial damage'):
            self.assertIn('0.0 if broken else minf(shield, damage)', shield_wall)
        with self.subTest(case='shield caps the absorbed amount'):
            self.assertIn('shield -= shield_taken', shield_wall)
        with self.subTest(case='absorbed damage flashes hit'):
            self.assertIn('hit = 1.0', shield_wall)
        with self.subTest(case='broken shield sets break timer'):
            self.assertIn('shield <= 0.00001 and shield_taken > 0.0', shield_wall)
            self.assertIn('break_timer = 60.0 * 10.0', shield_wall)
        with self.subTest(case='leftover damage is the residual'):
            self.assertIn('residual_damage = damage - shield_taken', shield_wall)
        self.assertIn('return {"shield_taken": shield_taken, "shield": shield, "hit": hit, "break_timer": break_timer, "residual_damage": residual_damage}', shield_wall)
        self.assertIn('public void damage(float damage){', shield_wall)
        self.assertIn('float shieldTaken = broken() ? 0f : Math.min(shield, damage);', shield_wall)
        self.assertIn('shield -= shieldTaken;', shield_wall)
        self.assertIn('if(shieldTaken > 0){', shield_wall)
        self.assertIn('hit = 1f;', shield_wall)
        self.assertIn('if(shield <= 0.00001f && shieldTaken > 0){', shield_wall)
        self.assertIn('breakTimer = breakCooldown;', shield_wall)
        self.assertIn('if(damage - shieldTaken > 0){', shield_wall)
        self.assertIn('super.damage(damage - shieldTaken);', shield_wall)
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
        self.assertIn('if(dead()) return;', shield_wall)
        self.assertIn('health -= handleDamage(damage);', shield_wall)
        self.assertIn('if(health <= 0){', shield_wall)
        self.assertIn('return build.power.status;', shield_wall)
        self.assertIn('consumePower(3f / 60f);', shield_wall)
        self.assertIn('update = true;', shield_wall)
        self.assertIn('shield = Mathf.clamp(shield + regenSpeed * edelta(), 0f, shieldHealth);', shield_wall)
        self.assertIn('shieldRadius = Mathf.lerpDelta(shieldRadius, broken() ? 0f : 1f, 0.12f);', shield_wall)
        # The proof's keys drive the pure damage coupling
        # (partial absorb / capped absorb + break / broken
        # absorbs nothing / no power absorbs nothing / absent
        # shield defaults to full health) plus the live catalog
        # check. There are no live-tick keys: damage() is
        # event-driven, not a tick, and no live damage call site
        # exists for ShieldWall in the port yet -- the caller
        # wiring waits for its own slice, and the updateTile
        # advance (ShieldWall.java:74-89) owns live stamping of
        # `shield` / `hit` / `break_timer`.
        proof = SHIELD_WALL_DAMAGE_PROOF.read_text(encoding='utf-8')
        for key in [
            'shield_absorbs_partial_damage',
            'shield_absorbs_capped_at_shield',
            'broken_wall_absorbs_nothing',
            'no_power_wall_absorbs_nothing',
            'shield_absent_defaults_full_health',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_shield_wall_damage(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ShieldWallDamageProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SHIELD_WALL_DAMAGE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'shield_absorbs_partial_damage',
            'shield_absorbs_capped_at_shield',
            'broken_wall_absorbs_nothing',
            'no_power_wall_absorbs_nothing',
            'shield_absent_defaults_full_health',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
