import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TOWER_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTowerBuildState.gd'
REPAIR_TOWER_NEARBY_DRIVER_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTowerNearbyDriverProof.gd'


class C07RepairTowerNearbyDriverTests(unittest.TestCase):
    def test_c07_repair_tower_nearby_driver_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2211']['godot_owner'], 'SourceRepairTowerBuildState.source_repair_tower_tick_buildings_state')
        # N2210 ported the live query that produces the
        # `nearby_damaged_units` observation
        # (source_units_nearby_damaged_count_state, Units.java
        # circle overload `public static void nearby(@Nullable
        # Team team, float x, float y, float radius, Cons<Unit>
        # cons){`, Units.java:445) but wired NO driver tick line
        # to call it (the N2208/N2209 precedent: a query, not a
        # tick write), so the N2190 refresh still reads a stale
        # or absent observation and the N2191 shouldConsume gate
        # still reads a stale or absent `targets_count`. N2211 is
        # the driver integration and nothing else: one tick line
        # in the existing
        # source_repair_tower_tick_buildings_state that calls the
        # N2210 pure function on refresh and stamps
        # `nearby_damaged_units` live on the RepairTower frame,
        # so the refresh block (`if(potentialEfficiency > 0 &&
        # (refresh += Time.delta) >= refreshInterval){` /
        # `targets.clear();` / `refresh = 0f;` /
        # `Units.nearby(team, x, y, range, u -> {` /
        # `if(u.damaged()){` / `targets.add(u);`,
        # RepairTower.java:59-64) consumes a live observation at
        # every expiry. One new result symbol: the driver-stamped
        # observation itself, owned by the tick function (the
        # N2109/N2103 precedent: tick-function result symbols).
        self.assertEqual(
            ledger['N2211']['source_symbols'],
            [
                'source_repair_tower_tick_buildings_state_result.nearby_damaged_units',
            ],
        )
        for name in ledger['N2211']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/units/RepairTower.java')
                self.assertEqual(symbol['godot_owner'], {
                    'source_repair_tower_tick_buildings_state_result.nearby_damaged_units': 'SourceRepairTowerBuildState.source_repair_tower_tick_buildings_state',
                }[name])
        self.assertEqual(ledger['N2211']['runtime_proof'], '/root/C07RepairTowerNearbyDriverProof')
        self.assertEqual(
            ledger['N2211']['tests'],
            [
                'test_c07_repair_tower_nearby_driver_registration',
                'test_all_c07_repair_tower_nearby_driver_input_evidence_is_exact',
                'test_repair_tower_nearby_driver_state',
                'test_reference_graph_and_actual_c07_repair_tower_nearby_driver',
            ],
        )
        self.assertTrue(ledger['N2211']['deferred_exprs'])

    def test_all_c07_repair_tower_nearby_driver_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2211']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_repair_tower_tick_buildings_state_result.nearby_damaged_units': 'SourceRepairTowerBuildState.source_repair_tower_tick_buildings_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTower.java',
            'core/src/mindustry/entities/Units.java',
            'core/src/mindustry/entities/comp/HealthComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2211']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_tower_nearby_driver_state(self):
        repair_tower = REPAIR_TOWER_STATE.read_text(encoding='utf-8')
        # The driver integration calls the N2210 pure query
        # (source_units_nearby_damaged_count_state, the circle
        # overload `public static void nearby(@Nullable Team
        # team, float x, float y, float radius, Cons<Unit>
        # cons){`, Units.java:445, first intersecting the rect
        # (`nearby(team, x - radius, y - radius, radius*2f,
        # radius*2f, unit -> {`, Units.java:446) then keeping
        # only units within the effective radius
        # (`if(unit.within(x, y, radius + unit.hitSize/2f)){`,
        # Units.java:449) and yielding each (`cons.get(unit);`,
        # Units.java:450) to the damaged filter
        # (`if(u.damaged()){`, RepairTower.java:63, over
        # `return health < maxHealth - 0.001f;`,
        # HealthComp.java:48)) and stamps the count as
        # `nearby_damaged_units` on the frame, BEFORE the
        # refresh call, so the refresh block
        # (`if(potentialEfficiency > 0 && (refresh +=
        # Time.delta) >= refreshInterval){`,
        # RepairTower.java:59) consumes the fresh observation
        # when it fires (`targets.clear();` /
        # `refresh = 0f;` / `Units.nearby(team, x, y, range, u
        # -> {` / `targets.add(u);`, RepairTower.java:60-64)
        # and the N2191 gate (`return targets.size > 0;`,
        # RepairTower.java:90) reads a live `targets_count`.
        # RED decisions: the query runs only while
        # potentialEfficiency > 0 (the Java gate,
        # RepairTower.java:59, read from the frame key this
        # tick's updateConsumption just stamped --
        # `potentialEfficiency = efficiency;`,
        # BuildingComp.java:1989 -- so at no power no
        # observation is stamped and the refresh cannot fire
        # anyway); the units list is the frame's `units` key
        # (`frame.get("units", [])`, the N2141/N2144 precedent
        # -- no live units list is stamped on any frame yet, so
        # the count stays 0 until a unit-list slice lands);
        # the centre is the tower's world position
        # (`sprite.position`, the turret-targeting precedent,
        # SourceTurretCombatState.gd:96 -- Java passes the
        # Building's own x, y); the radius is the per-def range
        # (`block.properties.get("range", 80.0)` -- 100f for
        # unit-repair-tower, `range = 100f;`, Blocks.java:6579,
        # falling back to the class default `public float range
        # = 80f;`, RepairTower.java:21); the query runs every
        # powered tick, not only on refresh expiry (Java
        # evaluates it inside the expiry branch -- the stamped
        # count at expiry is the same value Java computes,
        # because the refresh consumes the current tick's
        # observation; the only cost is the per-tick query on
        # non-expiry ticks). The call sits INSIDE the existing
        # `if has_power_consumer and enabled and not cheating:`
        # block, AFTER `apply_update_consumption_state` (the
        # Java order, updateConsumption :2274 before updateTile
        # :2277) and BEFORE the refresh call. The tick's
        # `seconds` is Time.delta (`return efficiency *
        # delta();`, BuildingComp.java:1928); the game object
        # carries the placed buildings (`public final Building
        # newBuilding(){`, Block.java:1002).
        self.assertIn('const source_unit_runtime_state := preload("res://src/game/SourceUnitRuntimeState.gd")', repair_tower)
        self.assertIn('if float(frame.get("potential_efficiency", 0.0)) > 0.0:', repair_tower)
        self.assertIn('source_unit_runtime_state.source_units_nearby_damaged_count_state(frame.get("units", []), team_id, sprite.position.x, sprite.position.y, float(block.properties.get("range", 80.0)))', repair_tower)
        self.assertIn('frame["nearby_damaged_units"] = nearby_result.get("nearby_damaged_units", 0)', repair_tower)
        self.assertIn('if(potentialEfficiency > 0 && (refresh += Time.delta) >= refreshInterval){', repair_tower)
        self.assertIn('targets.clear();', repair_tower)
        self.assertIn('refresh = 0f;', repair_tower)
        self.assertIn('Units.nearby(team, x, y, range, u -> {', repair_tower)
        self.assertIn('if(u.damaged()){', repair_tower)
        self.assertIn('targets.add(u);', repair_tower)
        self.assertIn('return targets.size > 0;', repair_tower)
        self.assertIn('public static void nearby(@Nullable Team team, float x, float y, float radius, Cons<Unit> cons){', repair_tower)
        self.assertIn('if(unit.within(x, y, radius + unit.hitSize/2f)){', repair_tower)
        self.assertIn('public float range = 80f;', repair_tower)
        self.assertIn('potentialEfficiency = efficiency;', repair_tower)
        # Placement: the query call runs after the consumption
        # stamp and before the refresh call.
        self.assertLess(repair_tower.index('apply_update_consumption_state(consumption, frame)'), repair_tower.index('source_units_nearby_damaged_count_state('))
        self.assertLess(repair_tower.index('source_units_nearby_damaged_count_state('), repair_tower.index('source_repair_tower_refresh_targets_state(frame, seconds)'))
        # The proof's keys drive the live driver (stamp /
        # refresh-consume / zero / per-def range / no-power /
        # tower-centred). There are no heal / warmup /
        # totalProgress keys: the heal loop + warmup lerp +
        # totalProgress advance (RepairTower.java:67-86) wait
        # for their own slices.
        proof = REPAIR_TOWER_NEARBY_DRIVER_PROOF.read_text(encoding='utf-8')
        for key in [
            'live_driver_stamps_nearby_count',
            'live_refresh_consumes_stamped_count',
            'live_no_damaged_units_stamps_zero',
            'live_driver_uses_per_def_range',
            'live_count_not_stamped_at_no_power',
            'live_query_centred_on_tower',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_repair_tower_nearby_driver(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTowerNearbyDriverProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TOWER_NEARBY_DRIVER_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'live_driver_stamps_nearby_count',
            'live_refresh_consumes_stamped_count',
            'live_no_damaged_units_stamps_zero',
            'live_driver_uses_per_def_range',
            'live_count_not_stamped_at_no_power',
            'live_query_centred_on_tower',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
