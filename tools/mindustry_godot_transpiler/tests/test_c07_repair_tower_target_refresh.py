import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TOWER_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTowerBuildState.gd'
REPAIR_TOWER_TARGET_REFRESH_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTowerTargetRefreshProof.gd'


class C07RepairTowerTargetRefreshTests(unittest.TestCase):
    def test_c07_repair_tower_target_refresh_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2190']['godot_owner'], 'SourceRepairTowerBuildState.source_repair_tower_refresh_targets_state')
        # N2176 folded the repair tower's live power.status into the
        # min efficiency, but the tower's shouldConsume gate
        # (`return targets.size > 0;`, RepairTower.java:89-91) reads
        # the target list -- and the refresh block is the ONLY
        # writer of `targets` (RepairTower.java:59-66,
        # `if(potentialEfficiency > 0 && (refresh += Time.delta)
        # >= refreshInterval){` / `targets.clear();` /
        # `refresh = 0f;` / `Units.nearby(team, x, y, range, u ->
        # {` / `if(u.damaged()){` / `targets.add(u);`): until a
        # slice stamps a live targets count, no gate slice can read
        # one. N2190 is that prerequisite slice and nothing else:
        # one pure function
        # (source_repair_tower_refresh_targets_state) over the
        # frame keys `refresh` (seconds accumulated),
        # `targets_count` (stamped on refresh expiry when an
        # observation exists), `nearby_damaged_units` (the
        # observation channel, stamped by the future live-units
        # query slice, NOT this one) and `potential_efficiency`
        # (already stamped every tick by the N2176 driver via
        # apply_update_consumption_state), gated on the single
        # boolean from the Java line (potentialEfficiency > 0)
        # plus the accumulated delta reaching the interval
        # (`static final float refreshInterval = 6f;`,
        # RepairTower.java:19). The timer advance needs no
        # per-def values (range/healAmount are irrelevant to the
        # timer), no second subsystem input, and its driver file
        # is dedicated. Four new result symbols: the refresh flag,
        # the accumulated timer, the stamped count, and its
        # presence flag.
        self.assertEqual(
            ledger['N2190']['source_symbols'],
            [
                'source_repair_tower_refresh_targets_state_result.refreshed',
                'source_repair_tower_refresh_targets_state_result.refresh',
                'source_repair_tower_refresh_targets_state_result.targets_count',
                'source_repair_tower_refresh_targets_state_result.has_targets_count',
            ],
        )
        for name in ledger['N2190']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/units/RepairTower.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/entities/Units.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_repair_tower_refresh_targets_state_result.refreshed': 'SourceRepairTowerBuildState.source_repair_tower_refresh_targets_state',
                    'source_repair_tower_refresh_targets_state_result.refresh': 'SourceRepairTowerBuildState.source_repair_tower_refresh_targets_state',
                    'source_repair_tower_refresh_targets_state_result.targets_count': 'SourceRepairTowerBuildState.source_repair_tower_refresh_targets_state',
                    'source_repair_tower_refresh_targets_state_result.has_targets_count': 'SourceRepairTowerBuildState.source_repair_tower_refresh_targets_state',
                }[name])
        self.assertEqual(ledger['N2190']['runtime_proof'], '/root/C07RepairTowerTargetRefreshProof')
        self.assertEqual(
            ledger['N2190']['tests'],
            [
                'test_c07_repair_tower_target_refresh_registration',
                'test_all_c07_repair_tower_target_refresh_input_evidence_is_exact',
                'test_repair_tower_refresh_targets_state',
                'test_reference_graph_and_actual_c07_repair_tower_target_refresh',
            ],
        )
        self.assertTrue(ledger['N2190']['deferred_exprs'])

    def test_all_c07_repair_tower_target_refresh_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2190']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_repair_tower_refresh_targets_state_result.refreshed': 'SourceRepairTowerBuildState.source_repair_tower_refresh_targets_state',
                    'source_repair_tower_refresh_targets_state_result.refresh': 'SourceRepairTowerBuildState.source_repair_tower_refresh_targets_state',
                    'source_repair_tower_refresh_targets_state_result.targets_count': 'SourceRepairTowerBuildState.source_repair_tower_refresh_targets_state',
                    'source_repair_tower_refresh_targets_state_result.has_targets_count': 'SourceRepairTowerBuildState.source_repair_tower_refresh_targets_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/entities/Units.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2190']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_tower_refresh_targets_state(self):
        repair_tower = REPAIR_TOWER_STATE.read_text(encoding='utf-8')
        # The pure target refresh lives on the repair-tower build
        # state: the refresh block (RepairTower.java:59-66,
        # `if(potentialEfficiency > 0 && (refresh += Time.delta)
        # >= refreshInterval){`) clears the targets, resets the
        # timer and re-queries the nearby damaged units
        # (`Units.nearby(team, x, y, range, u -> {` /
        # `if(u.damaged()){` / `targets.add(u);`); the query
        # itself is NOT this slice (see the RED decisions below),
        # the pure function consumes the observed count, it does
        # not produce it. The interval is the class constant
        # (`static final float refreshInterval = 6f;`,
        # RepairTower.java:19). Java inits the timer randomly
        # (`public float refresh = Mathf.random(refreshInterval);`,
        # RepairTower.java:47) -- the port takes the deterministic
        # 0.0 start, a documented deviation pinned in the proof;
        # no `randf` in the pure function (determinism; the
        # C06DefenseProof lesson: seeded RNG only in proof scenes,
        # never in game code). The gate reads the
        # potentialEfficiency stamped by THIS tick's
        # updateConsumption (BuildingComp.java:2263-2277,
        # updateConsumption() runs BEFORE updateTile()), and the
        # port mirror sets `potential_efficiency := efficiency`
        # (the min) before the `if not update` zeroing
        # (SourceBuildingEfficiencyState.gd:129-137), so
        # potentialEfficiency is the pre-gate min efficiency
        # (power.status fold) and stays 1.0 with full power even
        # when shouldConsume is false (no targets) -- the tower
        # therefore keeps refreshing with no targets; it only
        # stops when power is gone or it is disabled
        # (BuildingComp.java:1946, `potentialEfficiency = enabled
        # && productionValid() ? 1f : 0f;` + 1955, the disabled
        # branch zeroes all three). RED decisions: absent
        # `refresh` -> 0.0 (timer starts at 0; first refresh after
        # exactly 6s of powered operation); absent
        # `potential_efficiency` -> 0.0 (Java field default,
        # BuildingComp.java:89, `transient float
        # potentialEfficiency;`) -- no advance before the first
        # consumption stamp, which also makes the first live tick
        # a no-advance tick, pinned in the proof; absent
        # `nearby_damaged_units` at expiry -> the timer refreshes
        # but `targets_count` is NOT stamped (no observation yet --
        # the N2188 `has_target` precedent), so the follow-up
        # shouldConsume gate must treat an absent `targets_count`
        # as "no observation" and preserve the N2176 power-only
        # behavior. The driver call sits INSIDE the existing `if
        # has_power_consumer and enabled and not cheating:` block,
        # AFTER `apply_update_consumption_state` -- the Java order
        # (updateConsumption :2274 before updateTile :2277). The
        # driver writes `frame["refresh"]` from the result every
        # call, and `frame["targets_count"]` only when
        # `has_targets_count` is true. `delta` is the tick's
        # `seconds` (Time.delta). The effective query radius
        # (range + hitSize/2 per unit, Units.java:449-451,
        # `if(unit.within(x, y, radius + unit.hitSize/2f)){`)
        # belongs to the future live-units query slice, which
        # stamps `nearby_damaged_units` from `Units.nearby(team,
        # x, y, range, ...)` (Units.java:445, `public static void
        # nearby(@Nullable Team team, float x, float y, float
        # radius, Cons<Unit> cons){`). Single def --
        # unit-repair-tower only (size 2, range 100f, healAmount
        # 1.5f, Blocks.java:6575-6583); RepairTurret
        # (repair-point / repair-turret) is a different class and
        # NOT covered by this driver.
        self.assertIn('static func source_repair_tower_refresh_targets_state(frame: Dictionary, delta: float) -> Dictionary:', repair_tower)
        self.assertIn('SOURCE_REPAIR_TOWER_REFRESH_INTERVAL := 6.0', repair_tower)
        self.assertIn('static final float refreshInterval = 6f;', repair_tower)
        self.assertIn('public float refresh = Mathf.random(refreshInterval);', repair_tower)
        self.assertIn('if(potentialEfficiency > 0 && (refresh += Time.delta) >= refreshInterval){', repair_tower)
        self.assertIn('targets.clear();', repair_tower)
        self.assertIn('refresh = 0f;', repair_tower)
        self.assertIn('Units.nearby(team, x, y, range, u -> {', repair_tower)
        self.assertIn('if(u.damaged()){', repair_tower)
        self.assertIn('targets.add(u);', repair_tower)
        self.assertIn('return targets.size > 0;', repair_tower)
        self.assertIn('potentialEfficiency = efficiency;', repair_tower)
        self.assertIn('if(unit.within(x, y, radius + unit.hitSize/2f)){', repair_tower)
        self.assertIn('public static void nearby(@Nullable Team team, float x, float y, float radius, Cons<Unit> cons){', repair_tower)
        self.assertIn('source_repair_tower_refresh_targets_state(frame, seconds)', repair_tower)
        self.assertIn('frame["refresh"]', repair_tower)
        self.assertIn('frame["targets_count"]', repair_tower)
        self.assertIn('"nearby_damaged_units"', repair_tower)
        self.assertIn('"potential_efficiency"', repair_tower)
        self.assertIn('"refreshed"', repair_tower)
        self.assertIn('"has_targets_count"', repair_tower)
        # The proof's keys drive the pure refresh (gate-closed /
        # accumulate-below-interval / cross-interval-resets-and-
        # stamps-count / expiry-without-observation-leaves-count-
        # unstamped) plus the live tick (accumulates at full power,
        # frozen at no power, first tick no advance). There are no
        # heal / warmup / totalProgress / Units.nearby-query /
        # shouldConsume keys: the heal loop + warmup lerp +
        # totalProgress advance (RepairTower.java:67-86), the live
        # query (RepairTower.java:61-65) and the shouldConsume gate
        # (RepairTower.java:89-91) wait for their own slices.
        proof = REPAIR_TOWER_TARGET_REFRESH_PROOF.read_text(encoding='utf-8')
        for key in [
            'refresh_gate_closed_at_zero_efficiency',
            'refresh_accumulates_below_interval',
            'refresh_crosses_interval_resets_and_stamps_count',
            'refresh_expiry_without_observation_leaves_count_unstamped',
            'live_refresh_accumulates_at_full_power',
            'live_refresh_frozen_at_no_power',
            'live_first_tick_no_advance',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_repair_tower_target_refresh(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTowerTargetRefreshProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TOWER_TARGET_REFRESH_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'refresh_gate_closed_at_zero_efficiency',
            'refresh_accumulates_below_interval',
            'refresh_crosses_interval_resets_and_stamps_count',
            'refresh_expiry_without_observation_leaves_count_unstamped',
            'live_refresh_accumulates_at_full_power',
            'live_refresh_frozen_at_no_power',
            'live_first_tick_no_advance',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
