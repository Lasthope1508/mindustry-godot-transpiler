import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTurretBuildState.gd'
REPAIR_TURRET_SET_STATS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTurretSetStatsProof.gd'


class C07RepairTurretSetStatsTests(unittest.TestCase):
    def test_c07_repair_turret_set_stats_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2224']['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_set_stats_state')
        # RepairTurret carries NO sense/config overrides (checked
        # at N2222 RED), and the sense rows are DONE at N2223 --
        # but the class DOES override setStats()
        # (RepairTurret.java:75-84, `public void setStats(){`),
        # the last RepairTurret-level override with no slice.
        # It adds two stat rows unconditionally
        # (`stats.add(Stat.range, repairRadius / tilesize,
        # StatUnit.blocks);` -- RepairTurret.java:77 -- and
        # `stats.add(Stat.repairSpeed, repairSpeed * 60f,
        # StatUnit.perSecond);` -- RepairTurret.java:78) and,
        # only when the def accepts coolant, replaces the
        # booster row (`if(acceptCoolant){` --
        # RepairTurret.java:80 -- `stats.remove(Stat.booster);`
        # -- :81 -- `stats.add(Stat.booster,
        # StatValues.speedBoosters(Core.bundle.get(
        # "bar.strength"), coolantUse, coolantMultiplier, true,
        # this::consumesLiquid));` -- :82). The booster value
        # builder is StatValues.speedBoosters
        # (StatValues.java:506, `public static StatValue
        # speedBoosters(String unit, float amount, float speed,
        # boolean strength, Boolf<Liquid> filter){`).
        # RED decisions (resolved at RED, recorded in the
        # register docstring): (1) One pure function on the
        # same family file N2174 / N2188 / N2209 / N2212-N2215 /
        # N2217 / N2219-N2223 built:
        # source_repair_turret_set_stats_state(repair_radius,
        # repair_speed, accept_coolant, coolant_use,
        # coolant_multiplier, tilesize) returning range_blocks
        # (repairRadius / tilesize), repair_speed_per_second
        # (repairSpeed * 60f), booster_present (acceptCoolant),
        # booster_coolant_use and booster_coolant_multiplier
        # (the speedBoosters amount/speed params). All six
        # params are explicit floats/bool (the N2212 acquire /
        # N2220 draw-place / N2223 sense per-def-param precedent
        # -- repairRadius, repairSpeed, acceptCoolant, coolantUse
        # and coolantMultiplier are per-def static state, not
        # live frame keys: class defaults repairRadius 50f /
        # repairSpeed 0.3f / acceptCoolant false / coolantUse
        # 0.5f / coolantMultiplier 1f, RepairTurret.java:32, :33,
        # :40, :42, :45; repair-point 60f / 0.45f,
        # Blocks.java:6389, :6388; repair-turret 145f / 3f /
        # acceptCoolant true / coolantUse 0.16f /
        # coolantMultiplier 1.6f, Blocks.java:6401, :6400, :6404,
        # :6405, :6406); tilesize is 8 (Vars.java:135, `public
        # static final int tilesize = 8;`). (2) There is NO
        # driver tick line: setStats is a stat-display read, not
        # a tick write (the N2220 draw-select/draw-place
        # precedent); the proof calls the pure function directly
        # with per-def params. (3) The `super.setStats();` leg
        # (RepairTurret.java:76) is Block-level stat work, NOT
        # this slice: the base stats come from Block.setStats
        # (N1696) and are not re-emitted here. Five new result
        # symbols: range_blocks, repair_speed_per_second,
        # booster_present, booster_coolant_use,
        # booster_coolant_multiplier.
        self.assertEqual(
            ledger['N2224']['source_symbols'],
            [
                'source_repair_turret_set_stats_state_result.range_blocks',
                'source_repair_turret_set_stats_state_result.repair_speed_per_second',
                'source_repair_turret_set_stats_state_result.booster_present',
                'source_repair_turret_set_stats_state_result.booster_coolant_use',
                'source_repair_turret_set_stats_state_result.booster_coolant_multiplier',
            ],
        )
        for name in ledger['N2224']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/units/RepairTurret.java',
                    'core/src/mindustry/Vars.java',
                    'core/src/mindustry/content/Blocks.java',
                    'core/src/mindustry/world/meta/StatValues.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2224']['runtime_proof'], '/root/C07RepairTurretSetStatsProof')
        self.assertEqual(
            ledger['N2224']['tests'],
            [
                'test_c07_repair_turret_set_stats_registration',
                'test_all_c07_repair_turret_set_stats_input_evidence_is_exact',
                'test_repair_turret_set_stats_state',
                'test_reference_graph_and_actual_c07_repair_turret_set_stats',
            ],
        )
        self.assertTrue(ledger['N2224']['deferred_exprs'])

    def test_all_c07_repair_turret_set_stats_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2224']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTurret.java',
            'core/src/mindustry/Vars.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/meta/StatValues.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2224']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_turret_set_stats_state(self):
        repair_turret = REPAIR_TURRET_STATE.read_text(encoding='utf-8')
        # RepairTurret.setStats() (RepairTurret.java:75-84,
        # `public void setStats(){`): `super.setStats();`
        # (:76) is Block-level stat work (N1696), NOT this
        # slice; this slice owns the two unconditional rows
        # (`stats.add(Stat.range, repairRadius / tilesize,
        # StatUnit.blocks);` -- :77 -- and
        # `stats.add(Stat.repairSpeed, repairSpeed * 60f,
        # StatUnit.perSecond);` -- :78) and the coolant-gated
        # booster row (`if(acceptCoolant){` -- :80 --
        # `stats.remove(Stat.booster);` -- :81 --
        # `stats.add(Stat.booster, StatValues.speedBoosters(
        # Core.bundle.get("bar.strength"), coolantUse,
        # coolantMultiplier, true, this::consumesLiquid));`
        # -- :82, built by StatValues.speedBoosters,
        # StatValues.java:506). All six params are explicit
        # per-def floats/bool (the N2212 / N2220 / N2223
        # precedent): class defaults repairRadius 50f /
        # repairSpeed 0.3f / acceptCoolant false / coolantUse
        # 0.5f / coolantMultiplier 1f (RepairTurret.java:32,
        # :33, :40, :42, :45); repair-point 60f / 0.45f
        # (Blocks.java:6389, :6388); repair-turret 145f / 3f /
        # acceptCoolant true / coolantUse 0.16f /
        # coolantMultiplier 1.6f (Blocks.java:6401, :6400, :6404,
        # :6405, :6406); tilesize is 8 (Vars.java:135, `public
        # static final int tilesize = 8;`). There is no driver
        # tick line: setStats is a stat-display read, not a
        # tick write (the N2220 precedent).
        self.assertIn('static func source_repair_turret_set_stats_state(repair_radius: float, repair_speed: float, accept_coolant: bool, coolant_use: float, coolant_multiplier: float, tilesize: float) -> Dictionary:', repair_turret)
        self.assertIn('return {"range_blocks": range_blocks, "repair_speed_per_second": repair_speed_per_second, "booster_present": accept_coolant, "booster_coolant_use": coolant_use, "booster_coolant_multiplier": coolant_multiplier}', repair_turret)
        for expr in [
            'public void setStats(){',
            'super.setStats();',
            'stats.add(Stat.range, repairRadius / tilesize, StatUnit.blocks);',
            'stats.add(Stat.repairSpeed, repairSpeed * 60f, StatUnit.perSecond);',
            'if(acceptCoolant){',
            'stats.remove(Stat.booster);',
            'stats.add(Stat.booster, StatValues.speedBoosters(Core.bundle.get("bar.strength"), coolantUse, coolantMultiplier, true, this::consumesLiquid));',
            'public float repairRadius = 50f;',
            'public float repairSpeed = 0.3f;',
            'public boolean acceptCoolant = false;',
            'public float coolantUse = 0.5f;',
            'public float coolantMultiplier = 1f;',
            'public static final int tilesize = 8;',
            'public static StatValue speedBoosters(String unit, float amount, float speed, boolean strength, Boolf<Liquid> filter){',
            'public class RepairTurret extends Block{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, repair_turret)
        # The proof's keys drive the pure function with
        # per-def params (no live tick: setStats is a
        # stat-display read): range + repair speed at the
        # class-default / repair-point / repair-turret defs,
        # and the booster row absent at the default def /
        # present at the repair-turret def.
        proof = REPAIR_TURRET_SET_STATS_PROOF.read_text(encoding='utf-8')
        for key in [
            'set_stats_range_default_radius',
            'set_stats_range_repair_point',
            'set_stats_range_repair_turret',
            'set_stats_repair_speed_default',
            'set_stats_repair_speed_repair_point',
            'set_stats_repair_speed_repair_turret',
            'set_stats_booster_absent_default',
            'set_stats_booster_repair_turret',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_repair_turret_set_stats(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTurretSetStatsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TURRET_SET_STATS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'set_stats_range_default_radius',
            'set_stats_range_repair_point',
            'set_stats_range_repair_turret',
            'set_stats_repair_speed_default',
            'set_stats_repair_speed_repair_point',
            'set_stats_repair_speed_repair_turret',
            'set_stats_booster_absent_default',
            'set_stats_booster_repair_turret',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
