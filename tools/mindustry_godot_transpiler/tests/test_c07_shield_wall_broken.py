import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SHIELD_WALL_STATE = ROOT / 'godot-mindustry/src/game/SourceShieldWallBuildState.gd'
SHIELD_WALL_BROKEN_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ShieldWallBrokenProof.gd'


class C07ShieldWallBrokenTests(unittest.TestCase):
    def test_c07_shield_wall_broken_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2202']['godot_owner'], 'SourceShieldWallBuildState.source_shield_wall_broken_state')
        # N2175 folded the shield wall's live power.status into
        # the min efficiency (BuildingComp.java:1969-1976,
        # ConsumePower.efficiency is build.power.status) in its
        # own driver, and its updateTile regen advance
        # (ShieldWall.java:80, `shield = Mathf.clamp(shield +
        # regenSpeed * edelta(), 0f, shieldHealth);`) regens by
        # edelta() (BuildingComp.java:1927-1929, `return
        # efficiency * delta();`), so a shield wall with no power
        # would never regen -- but N2175 left the broken()
        # coupling unmodeled with a documented limit: broken()
        # (ShieldWall.java:92, `return breakTimer > 0 ||
        # !canConsume();`) with canConsume()
        # (BuildingComp.java:1917-1919, `return
        # potentialEfficiency > 0;`) means a powerless shield
        # wall is broken and absorbs nothing, yet the port
        # stamped no broken flag at all -- the shield radius
        # lerp (ShieldWall.java:88, `shieldRadius =
        # Mathf.lerpDelta(shieldRadius, broken() ? 0f : 1f,
        # 0.12f);`) and the damage path (ShieldWall.java:102,
        # `float shieldTaken = broken() ? 0f : Math.min(shield,
        # damage);`) had no broken value to read. N2202 closes
        # the broken() half with one pure function over two
        # frame keys (`break_timer`, float, and
        # `potential_efficiency`, float, stamped by the N2175
        # machinery via apply_update_consumption_state): the
        # coupling is the same expression over the observed
        # break timer and the live potential efficiency.
        # RED decisions (pinned by this slice, the proof's
        # fourth/fifth keys): when the frame carries NO
        # `break_timer` key, default to 0.0 (no break in
        # progress) -- the future updateTile-advance slice
        # owns live stamping of break_timer (breakTimer decay,
        # ShieldWall.java:75-76, and `breakTimer =
        # breakCooldown;`, ShieldWall.java:110, on shield
        # break); when the frame carries NO
        # `potential_efficiency` key, default to 1.0 (not
        # broken by power) -- the N2175 null-folds-to-1.0
        # precedent and the N2201 absent-preserves-behavior
        # precedent: Java's field default is 0.0
        # (BuildingComp.java:89, `transient float
        # potentialEfficiency;`), but updateConsumption runs
        # before updateTile every tick in live play, so
        # broken() is only ever evaluated with a fresh
        # potentialEfficiency, and absent means "no machinery
        # run yet", not "no power" -- defaulting absent to 0
        # would mark every shield wall broken before its first
        # tick, a live regression against N2175 GREEN. One new
        # result symbol: the broken flag itself.
        self.assertEqual(
            ledger['N2202']['source_symbols'],
            [
                'source_shield_wall_broken_state_result.broken',
            ],
        )
        for name in ledger['N2202']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/ShieldWall.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_shield_wall_broken_state_result.broken': 'SourceShieldWallBuildState.source_shield_wall_broken_state',
                }[name])
        self.assertEqual(ledger['N2202']['runtime_proof'], '/root/C07ShieldWallBrokenProof')
        self.assertEqual(
            ledger['N2202']['tests'],
            [
                'test_c07_shield_wall_broken_registration',
                'test_all_c07_shield_wall_broken_input_evidence_is_exact',
                'test_shield_wall_broken_state',
                'test_reference_graph_and_actual_c07_shield_wall_broken',
            ],
        )
        self.assertTrue(ledger['N2202']['deferred_exprs'])

    def test_all_c07_shield_wall_broken_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2202']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_shield_wall_broken_state_result.broken': 'SourceShieldWallBuildState.source_shield_wall_broken_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/ShieldWall.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2202']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_shield_wall_broken_state(self):
        shield_wall = SHIELD_WALL_STATE.read_text(encoding='utf-8')
        # The pure broken() coupling lives on the shield-wall
        # build state: broken() (ShieldWall.java:91, `public
        # boolean broken(){` with `return breakTimer > 0 ||
        # !canConsume();`, ShieldWall.java:92) over the break
        # timer (ShieldWall.java:45, `public float breakTimer;`,
        # decayed by ShieldWall.java:75-76, `if(breakTimer >
        # 0){` / `breakTimer -= Time.delta;`, and set by
        # ShieldWall.java:110, `breakTimer = breakCooldown;`,
        # when the shield breaks, breakCooldown 60f * 10f,
        # ShieldWall.java:16) and canConsume()
        # (BuildingComp.java:1917, `public boolean
        # canConsume(){` with `return potentialEfficiency > 0;`,
        # BuildingComp.java:1918) over the potential efficiency
        # (BuildingComp.java:89, `transient float
        # potentialEfficiency;`, assigned by
        # BuildingComp.java:1989, `potentialEfficiency =
        # efficiency;`, zeroed when disabled by
        # BuildingComp.java:1955, `potentialEfficiency =
        # efficiency = optionalEfficiency = 0f;`, and set to
        # enabled && productionValid when cheating or without
        # consumers by BuildingComp.java:1946,
        # `potentialEfficiency = enabled && productionValid() ?
        # 1f : 0f;`). The shield regen advance
        # (ShieldWall.java:80, `shield = Mathf.clamp(shield +
        # regenSpeed * edelta(), 0f, shieldHealth);`, keep on
        # ONE comment line, the N2148 shootWarmup lesson: a
        # split line fails this test) regens by edelta(), and
        # edelta() is efficiency * delta
        # (BuildingComp.java:1927-1929, `return efficiency *
        # delta();`); the shield radius lerp reads broken()
        # (ShieldWall.java:88, `shieldRadius =
        # Mathf.lerpDelta(shieldRadius, broken() ? 0f : 1f,
        # 0.12f);`) and the damage path reads it too
        # (ShieldWall.java:102, `float shieldTaken = broken() ?
        # 0f : Math.min(shield, damage);`). The power row is
        # ConsumePower.efficiency (ConsumePower.java:39,
        # `return build.power.status;`), folded by the first
        # pass (BuildingComp.java:1969-1976) into the min
        # efficiency; a missing stamp folds to 1.0 before the
        # first graph update, the assembler fold
        # (UnitAssembler.java:469, `float powerStatus = !enabled
        # ? 0f : power == null ? 1f : power.status;`), and the
        # power consumer counts toward hasConsumers
        # (Block.java:1449, `hasConsumers = consumers.length >
        # 0;`). The updateConsumption gate
        # (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();` + 1992,
        # `if(!update){`) forces efficiency to zero when the
        # gate is false. ShieldWallBuild has NO shouldConsume
        # override, so the BuildingComp default
        # (BuildingComp.java:755, `public boolean
        # shouldConsume(){` with `return enabled;`,
        # BuildingComp.java:756) applies. The shield wall is
        # its own family (ShieldWall.java:14, `public class
        # ShieldWall extends Wall{`; ShieldWallBuild,
        # ShieldWall.java:43, `public class ShieldWallBuild
        # extends WallBuild{`). One def (shielded-wall,
        # `consumePower(3f / 60f);`, Blocks.java:1905;
        # shieldHealth 900f, breakCooldown 60f * 10f, regenSpeed
        # 2f, ShieldWall.java:15-17; `public float shield =
        # shieldHealth, shieldRadius = 0f;`,
        # ShieldWall.java:44; `update = true;`,
        # ShieldWall.java:27).
        self.assertIn('static func source_shield_wall_broken_state', shield_wall)
        # The broken cases, pinned as the pure function's
        # decision structure: the frame carries the break timer
        # as `break_timer` (float) and the live potential
        # efficiency as `potential_efficiency` (float, stamped
        # by the N2175 machinery); the function reads
        # break_timer with a 0.0 default, so an absent key
        # means "no break in progress", and
        # potential_efficiency with a 1.0 default, so an absent
        # key means "no machinery run yet", not "no power".
        # break_timer>0 breaks the wall (broken true);
        # break_timer=0 with potential_efficiency=0 breaks it
        # (broken true -- the power coupling: no power =
        # broken); break_timer=0 with potential_efficiency>0
        # leaves it whole (broken false) -- all observed cases
        # run through the one disjunction, `break_timer > 0.0
        # or not can_consume_state(potential_efficiency)`,
        # where can_consume_state is the canonical
        # BuildingComp.canConsume() model
        # (SourceBuildingEfficiencyState.gd:84-85,
        # `potential_efficiency > 0.0`).
        self.assertIn('frame.get("break_timer", 0.0)', shield_wall)
        self.assertIn('frame.get("potential_efficiency", 1.0)', shield_wall)
        with self.subTest(case='break_timer>0 breaks the wall'):
            self.assertIn('break_timer > 0.0 or not source_building_efficiency_state.can_consume_state(potential_efficiency)', shield_wall)
        with self.subTest(case='potential_efficiency=0 breaks the wall'):
            self.assertIn('can_consume_state(potential_efficiency)', shield_wall)
        with self.subTest(case='powered wall with no break timer is whole'):
            self.assertIn('break_timer > 0.0 or not source_building_efficiency_state.can_consume_state(potential_efficiency)', shield_wall)
        with self.subTest(case='absent break_timer defaults to zero'):
            self.assertIn('frame.get("break_timer", 0.0)', shield_wall)
        with self.subTest(case='absent potential_efficiency folds to one'):
            self.assertIn('frame.get("potential_efficiency", 1.0)', shield_wall)
        self.assertIn('return {"broken": broken}', shield_wall)
        # The driver stamps the broken flag after the
        # consumption machinery (one line, inside the
        # consumption block, the N2201 precedent), so the
        # flag reads the fresh potential_efficiency the
        # machinery just stamped.
        self.assertIn('frame["broken"] = bool(source_shield_wall_broken_state(frame).get("broken", false))', shield_wall)
        self.assertIn('public boolean broken(){', shield_wall)
        self.assertIn('return breakTimer > 0 || !canConsume();', shield_wall)
        self.assertIn('public float breakTimer;', shield_wall)
        self.assertIn('if(breakTimer > 0){', shield_wall)
        self.assertIn('breakTimer -= Time.delta;', shield_wall)
        self.assertIn('breakTimer = breakCooldown;', shield_wall)
        self.assertIn('public boolean canConsume(){', shield_wall)
        self.assertIn('return potentialEfficiency > 0;', shield_wall)
        self.assertIn('transient float potentialEfficiency;', shield_wall)
        self.assertIn('potentialEfficiency = enabled && productionValid() ? 1f : 0f;', shield_wall)
        self.assertIn('potentialEfficiency = efficiency = optionalEfficiency = 0f;', shield_wall)
        self.assertIn('potentialEfficiency = efficiency;', shield_wall)
        self.assertIn('shield = Mathf.clamp(shield + regenSpeed * edelta(), 0f, shieldHealth);', shield_wall)
        self.assertIn('shieldRadius = Mathf.lerpDelta(shieldRadius, broken() ? 0f : 1f, 0.12f);', shield_wall)
        self.assertIn('float shieldTaken = broken() ? 0f : Math.min(shield, damage);', shield_wall)
        self.assertIn('public float shieldHealth = 900f;', shield_wall)
        self.assertIn('public float breakCooldown = 60f * 10f;', shield_wall)
        self.assertIn('public float regenSpeed = 2f;', shield_wall)
        self.assertIn('public float shield = shieldHealth, shieldRadius = 0f;', shield_wall)
        self.assertIn('public class ShieldWall extends Wall{', shield_wall)
        self.assertIn('public class ShieldWallBuild extends WallBuild{', shield_wall)
        self.assertIn('return build.power.status;', shield_wall)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', shield_wall)
        self.assertIn('hasConsumers = consumers.length > 0;', shield_wall)
        self.assertIn('return enabled;', shield_wall)
        self.assertIn('boolean update = shouldConsume() && productionValid();', shield_wall)
        self.assertIn('if(!update){', shield_wall)
        self.assertIn('return efficiency * delta();', shield_wall)
        self.assertIn('consumePower(3f / 60f);', shield_wall)
        self.assertIn('update = true;', shield_wall)
        # The proof's keys drive the pure coupling (broken on
        # break timer / broken on no power / whole when powered
        # / absent potential_efficiency folds to one / absent
        # break_timer defaults to zero) plus the live tick
        # (the driver stamps the flag from the fresh machinery
        # potential_efficiency). There are no damage / regen /
        # shieldRadius keys: the damage path
        # (ShieldWall.java:101-117) and the updateTile advance
        # (ShieldWall.java:74-89) wait for their own slices,
        # and the future updateTile slice owns live stamping
        # of `break_timer`.
        proof = SHIELD_WALL_BROKEN_PROOF.read_text(encoding='utf-8')
        for key in [
            'broken_when_break_timer_positive',
            'broken_when_no_power',
            'not_broken_when_powered',
            'broken_absent_potential_efficiency_folds_one',
            'broken_absent_break_timer_defaults_zero',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_shield_wall_broken(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ShieldWallBrokenProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SHIELD_WALL_BROKEN_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'broken_when_break_timer_positive',
            'broken_when_no_power',
            'not_broken_when_powered',
            'broken_absent_potential_efficiency_folds_one',
            'broken_absent_break_timer_defaults_zero',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
