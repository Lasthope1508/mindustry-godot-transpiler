import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LASER_TURRET_BRIDGE = ROOT / 'godot-mindustry/src/game/SourceLaserTurretBuildPortBridge.gd'
LASER_TURRET_SET_STATS_INIT_PROGRESS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LaserTurretSetStatsInitProgressProof.gd'


class C07LaserTurretSetStatsInitProgressTests(unittest.TestCase):
    def test_c07_laser_turret_set_stats_init_progress_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2386']['godot_owner'], 'PortGame.source_laser_turret_build_set_stats_state')
        # LaserTurret.setStats()+init() + LaserTurretBuild
        # .progress() gộp (LaserTurret.java:26-33 + :36-43 +
        # :110-112): setStats drops the booster stat row
        # and, when a coolant consumer exists, adds an
        # input row with the boosters spec (reload,
        # coolant.amount, coolantMultiplier, baseReload
        # false, this::consumesLiquid); init resolves
        # the coolant consumer with findConsumer when
        # it is still null; progress() is 1 -
        # clamp(reloadCounter / reload). The three
        # methods share one concern (LaserTurret
        # coolant+reload setup and progress) and each
        # carries only one distinguishing expr, so they
        # are one slice (grouping approved by the main
        # thread; N2330/N2367/N2381/N2384 precedent).
        # The three distinguishing exprs are
        # `stats.add(Stat.input, StatValues.boosters
        # (reload, coolant.amount, coolantMultiplier,
        # false, this::consumesLiquid));`,
        # `coolant = findConsumer(c -> c instanceof
        # ConsumeLiquidBase);` and
        # `return 1f - Mathf.clamp(reloadCounter /
        # reload);` (0 hits in both ledgers at probe
        # time). The shared lines `super.setStats();`,
        # `stats.remove(Stat.booster);`,
        # `if(coolant != null){`, `super.init();`,
        # `if(coolant == null){` and the method headers
        # are evidence only, never the sole
        # distinguishing expr. `return bullets.any();`
        # (shouldActiveSound) is NOT registered here --
        # it belongs to a later ContinuousTurret slot.
        # NO driver line: three pure functions the
        # setup/tick reads, not per-tick writes. Four
        # new result symbols: stats, coolant,
        # coolant_found, progress.
        self.assertEqual(
            ledger['N2386']['java_method'],
            'LaserTurret.setStats(); LaserTurret.init(); LaserTurretBuild.progress()',
        )
        self.assertEqual(
            ledger['N2386']['source_symbols'],
            [
                'source_laser_turret_build_set_stats_state_result.stats',
                'source_laser_turret_build_init_state_result.coolant',
                'source_laser_turret_build_init_state_result.coolant_found',
                'source_laser_turret_build_progress_state_result.progress',
            ],
        )
        for name in ledger['N2386']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/LaserTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2386']['runtime_proof'], '/root/C07LaserTurretSetStatsInitProgressProof')
        self.assertEqual(
            ledger['N2386']['tests'],
            [
                'test_c07_laser_turret_set_stats_init_progress_registration',
                'test_all_c07_laser_turret_set_stats_init_progress_input_evidence_is_exact',
                'test_laser_turret_set_stats_init_progress_state',
                'test_reference_graph_and_actual_c07_laser_turret_set_stats_init_progress',
            ],
        )
        self.assertTrue(ledger['N2386']['deferred_exprs'])

    def test_all_c07_laser_turret_set_stats_init_progress_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2386']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/LaserTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2386']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_laser_turret_set_stats_init_progress_state(self):
        bridge = LASER_TURRET_BRIDGE.read_text(encoding='utf-8')
        # LaserTurret.setStats() (LaserTurret.java:26-33):
        # drop the booster stat row; when coolant exists,
        # add an input row with the boosters spec
        # (reload, coolant.amount, coolantMultiplier,
        # baseReload false, this::consumesLiquid).
        # LaserTurret.init() (LaserTurret.java:36-43):
        # when coolant is null, resolve it with
        # findConsumer(c -> c instanceof
        # ConsumeLiquidBase) -- the found consumer
        # arrives as an explicit param. LaserTurretBuild
        # .progress() (LaserTurret.java:110-112): 1 -
        # clamp(reloadCounter / reload). `stats` arrives
        # as an explicit Array of row dicts (the N2384
        # setStats precedent) and is never mutated --
        # the returned rows are fresh. `coolant` is
        # `ConsumeLiquidBase` (BaseTurret.java:34) as a
        # Dictionary {amount} or null. `coolantMultiplier`
        # is a LaserTurret field with default 1f
        # (LaserTurret.java:22). `this::consumesLiquid`
        # is Block.consumesLiquid (Block.java:778) as an
        # explicit Callable. NO driver line.
        self.assertIn('static func source_laser_turret_build_set_stats_state(stats: Array, coolant: Variant, reload: float, coolant_multiplier: float, consumes_liquid: Callable) -> Dictionary:', bridge)
        self.assertIn('static func source_laser_turret_build_init_state(coolant: Variant, found_consumer: Variant) -> Dictionary:', bridge)
        self.assertIn('static func source_laser_turret_build_progress_state(reload_counter: float, reload: float) -> Dictionary:', bridge)
        self.assertIn('return {"stats": rows}', bridge)
        self.assertIn('return {"coolant": resolved_coolant, "coolant_found": coolant_found}', bridge)
        self.assertIn('return {"progress": progress}', bridge)
        for expr in [
            'public void setStats(){',
            'super.setStats();',
            'stats.remove(Stat.booster);',
            'if(coolant != null){',
            'stats.add(Stat.input, StatValues.boosters(reload, coolant.amount, coolantMultiplier, false, this::consumesLiquid));',
            'public void init(){',
            'super.init();',
            'if(coolant == null){',
            'coolant = findConsumer(c -> c instanceof ConsumeLiquidBase);',
            'public float progress(){',
            'return 1f - Mathf.clamp(reloadCounter / reload);',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, bridge)
        # The proof's keys drive the pure functions with
        # synthetic inputs (no live tick): setStats
        # drops the booster row and adds the input row
        # only with coolant / init resolves the coolant
        # from the finder only when it is null / progress
        # is 1 - clamp(reloadCounter / reload) / each
        # result carries only its expected keys.
        proof = LASER_TURRET_SET_STATS_INIT_PROGRESS_PROOF.read_text(encoding='utf-8')
        for key in [
            'set_stats_removes_booster',
            'set_stats_adds_input_row_with_coolant',
            'set_stats_skips_input_row_without_coolant',
            'set_stats_inputs_unmutated',
            'init_uses_found_consumer_when_coolant_null',
            'init_keeps_existing_coolant',
            'init_stays_null_when_nothing_found',
            'progress_clamps_reload_fraction',
            'returns_only_expected_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_laser_turret_set_stats_init_progress(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LaserTurretSetStatsInitProgressProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LASER_TURRET_SET_STATS_INIT_PROGRESS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'set_stats_removes_booster',
            'set_stats_adds_input_row_with_coolant',
            'set_stats_skips_input_row_without_coolant',
            'set_stats_inputs_unmutated',
            'init_uses_found_consumer_when_coolant_null',
            'init_keeps_existing_coolant',
            'init_stays_null_when_nothing_found',
            'progress_clamps_reload_fraction',
            'returns_only_expected_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
