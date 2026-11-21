import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
FACTORY_STATE = ROOT / 'godot-mindustry/src/game/SourceFactoryRuntimeState.gd'
GAME_BRIDGE_STATE = ROOT / 'godot-mindustry/src/game/SourcePortGameFactoryStatePortBridge.gd'
POWER_GRAPH_LAST_VALUES_STAMP_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretPowerGraphLastValuesStampProof.gd'

TURRET_POWER_GRAPH_LAST_VALUES_STAMP_SIGNATURE = 'static func source_turret_power_graph_last_values_stamp_state(frame: Dictionary, power_graph_update: Dictionary) -> Dictionary:'
SENSE_SIGNATURE = 'static func source_building_comp_sense_state(frame: Dictionary, sensor: String, tilesize: float, world_x: float, world_y: float, team_color_r: float, team_color_g: float, team_color_b: float, block_solid: bool, block_size: int, max_health: float, range_value: float, has_items: bool, item_capacity: int, has_liquids: bool, liquid_capacity: float, total_liquids: float, has_cons_power: bool, power_capacity: float, power_buffered: bool, has_power: bool, time_scale: float, is_player: bool, payload_count: int) -> Dictionary:'
LEG_SIGNATURES = [
    'static func source_building_comp_sense_dead_state(tile_build_is_self: bool, is_dead: bool) -> Dictionary:',
    'static func source_building_comp_sense_health_state(health: float) -> Dictionary:',
    'static func source_building_comp_sense_total_items_state(items_is_null: bool, items_total: int) -> Dictionary:',
    'static func source_building_comp_sense_power_net_in_state(power_is_null: bool, last_scaled_power_in: float) -> Dictionary:',
    'static func source_building_comp_sense_power_net_out_state(power_is_null: bool, last_scaled_power_out: float) -> Dictionary:',
    'static func source_building_comp_sense_power_net_stored_state(power_is_null: bool, last_power_stored: float) -> Dictionary:',
    'static func source_building_comp_sense_power_net_capacity_state(power_is_null: bool, last_capacity: float) -> Dictionary:',
    'static func source_building_comp_sense_camera_state(sensor: String, is_control_block: bool, unit_sense_value: float) -> Dictionary:',
]
PROOF_KEYS = [
    'stamp_graph_power_net_in_num',
    'stamp_graph_power_net_out_num',
    'stamp_graph_power_net_stored_num',
    'stamp_graph_power_net_capacity_num',
    'stamp_graph_cheat_keeps_scaled_num',
    'stamp_graph_cheat_updates_stored_num',
    'stamp_graph_empty_update_keeps_absent_num',
    'stamp_graph_composed_num',
]


class C07TurretPowerGraphLastValuesStampTests(unittest.TestCase):
    def test_c07_turret_power_graph_last_values_stamp_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2522']['godot_owner'], 'SourceTurretBuildState.source_turret_power_graph_last_values_stamp_state')
        # The turret driver tick stamps the live power-graph
        # last-values into the frame, so the N2519-wired dispatch
        # `source_building_comp_sense_state` stops reporting
        # handled:false for the powerNet* legs when a live
        # turret ticks. The stamp copies the owner's snapshot
        # (the `source_factory_update_power_graph_state` return,
        # whose `update` is the `update_state` output) into
        # exactly the 4 graph keys (`last_scaled_power_in` /
        # `last_scaled_power_out` / `last_power_stored` /
        # `last_capacity`) and returns the frame (the N2108
        # tick-frame precedent: one result symbol,
        # `result.frame`), so exactly one new result symbol is
        # registered; the ported method is BuildingComp.sense,
        # so the java_source is BuildingComp.java and the slice
        # mirrors into the comp shard (571/474 -> 572/475);
        # defense stays 210/209.
        self.assertEqual(
            ledger['N2522']['source_symbols'],
            [
                'source_turret_power_graph_last_values_stamp_state_result.frame',
            ],
        )
        for name in ledger['N2522']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/entities/comp/BuildingComp.java')
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_power_graph_last_values_stamp_state')
        self.assertEqual(ledger['N2522']['runtime_proof'], '/root/C07TurretPowerGraphLastValuesStampProof')
        self.assertEqual(
            ledger['N2522']['tests'],
            [
                'test_c07_turret_power_graph_last_values_stamp_registration',
                'test_all_c07_turret_power_graph_last_values_stamp_input_evidence_is_exact',
                'test_turret_power_graph_last_values_stamp_state',
                'test_reference_graph_and_actual_c07_turret_power_graph_last_values_stamp',
            ],
        )
        self.assertTrue(ledger['N2522']['deferred_exprs'])

    def test_all_c07_turret_power_graph_last_values_stamp_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2522']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_power_graph_last_values_stamp_state')
        slice_sources = {
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/world/blocks/power/PowerGraph.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2522']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_power_graph_last_values_stamp_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        factory = FACTORY_STATE.read_text(encoding='utf-8')
        bridge = GAME_BRIDGE_STATE.read_text(encoding='utf-8')
        # The stamp copies the graph update's snapshot into
        # exactly the 4 graph keys and returns the frame (the
        # N2108 tick-frame precedent):
        # - `last_scaled_power_in` / `last_scaled_power_out` /
        #   `last_capacity` come from `update["balance_state"]`
        #   (the `update_balance_state` output,
        #   `lastScaledPowerIn = (powerProduced + energyDelta) /
        #   Time.delta;`, PowerGraph.java:233; `lastScaledPowerOut
        #   = powerNeeded / Time.delta;`, :234; `lastCapacity =
        #   getTotalBatteryCapacity();`, :235);
        # - `last_power_stored` comes from
        #   `update["last_power_stored"]` (top-level on BOTH
        #   branches, `lastPowerStored = getBatteryStored();`,
        #   :236);
        # - a key is stamped ONLY when present in the update:
        #   on the cheat branch `balance_state` is `{}` (Java
        #   returns before :233-236, `PowerGraph.java:217-224`,
        #   so the fields keep their previous values) and the
        #   stamp leaves the scaled/capacity keys untouched, so
        #   the frame keeps the previous tick's values; an
        #   empty `{}` update stamps NOTHING, so the dispatch
        #   keeps handled:false for powerNet* (the N2519
        #   absent-key fallback).
        # The stamp does NOT recompute any formula (the formula
        # lives once in `update_balance_state`,
        # SourcePowerGraphBalanceState.gd:116-119) and does NOT
        # call the graph update. The live loop already runs the
        # update before the turret tick
        # (`simulate_factory`, SourceFactoryRuntimeState.gd:199)
        # and stores its return on the game; the tick reads it
        # from the game (`power_graph_update`, declared in
        # SourcePortGameFactoryStatePortBridge.gd) — the tick
        # must NOT re-run the update (it is NOT idempotent: it
        # writes battery `power_status` back to sprite metas,
        # so a second run would charge/discharge AGAIN) and
        # must NOT recompute from `game_runtime_state` (that
        # would duplicate the formula, and its batteries read
        # status 0.0). The tick signature stays `(game: Object,
        # seconds: float)` and the factory call text stays
        # `source_turret_build_state.
        # source_turret_tick_buildings_state(game, delta)` —
        # both pinned by test_turret_live_loop.py:84-85 (N2108).
        # `power == null` handling stays in the dispatch legs
        # (they return 0.0 when `not has_power`), so stamping
        # graph values for a power-less turret is safe.
        self.assertIn(TURRET_POWER_GRAPH_LAST_VALUES_STAMP_SIGNATURE, turret)
        for line in [
            'var update_state: Dictionary = power_graph_update.get("update", {})',
            'var balance_state: Dictionary = update_state.get("balance_state", {})',
            'if balance_state.has("last_scaled_power_in"):',
            'frame["last_scaled_power_in"] = float(balance_state.get("last_scaled_power_in", 0.0))',
            'if balance_state.has("last_scaled_power_out"):',
            'frame["last_scaled_power_out"] = float(balance_state.get("last_scaled_power_out", 0.0))',
            'if balance_state.has("last_capacity"):',
            'frame["last_capacity"] = float(balance_state.get("last_capacity", 0.0))',
            'if update_state.has("last_power_stored"):',
            'frame["last_power_stored"] = float(update_state.get("last_power_stored", 0.0))',
            'return frame',
            'var power_graph_last_values_stamped: Dictionary = source_turret_power_graph_last_values_stamp_state(frame, power_graph_update if power_graph_update is Dictionary else {})',
        ]:
            with self.subTest(line=line):
                self.assertIn(line, turret)
        for expr in [
            'public double sense(LAccess sensor){',
            'case powerNetIn -> power == null ? 0 : power.graph.getLastScaledPowerIn() * 60;',
            'case powerNetOut -> power == null ? 0 : power.graph.getLastScaledPowerOut() * 60;',
            'case powerNetStored -> power == null ? 0 : power.graph.getLastPowerStored();',
            'case powerNetCapacity -> power == null ? 0 : power.graph.getLastCapacity();',
            'public void update(){',
            'lastScaledPowerIn = (powerProduced + energyDelta) / Time.delta;',
            'lastScaledPowerOut = powerNeeded / Time.delta;',
            'lastCapacity = getTotalBatteryCapacity();',
            'lastPowerStored = getBatteryStored();',
            'public void updateTile(){',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The live loop stores the graph update on the game
        # (the `item_progress` precedent: game-level shared
        # state is a declared var on the PortGame bridge) and
        # the tick reads it from there.
        for line in [
            'var power_graph_update: Dictionary = source_factory_update_power_graph_state(game, delta)',
            'game.set("power_graph_update", power_graph_update)',
        ]:
            with self.subTest(line=line):
                self.assertIn(line, factory)
        self.assertIn('var power_graph_update: Dictionary = {}', bridge)
        # The stamp sits right AFTER the N2521 ammo-items stamp
        # (mirroring Java order -- the tick refreshes frame
        # keys, the stamp is part of that refresh) and BEFORE
        # _initial_frame.
        self.assertLess(turret.index('static func source_turret_ammo_items_stamp_state('), turret.index('static func source_turret_power_graph_last_values_stamp_state('))
        self.assertLess(turret.index('static func source_turret_power_graph_last_values_stamp_state('), turret.index('static func _initial_frame('))
        # The tick call site sits inside
        # source_turret_tick_buildings_state, right after the
        # N2521 ammo-items stamp call, and reads the stored
        # update from the game.
        tick = turret[turret.index('static func source_turret_tick_buildings_state('):]
        self.assertLess(tick.index('var ammo_items_stamped: Dictionary = source_turret_ammo_items_stamp_state(frame, str(block.implementation) == "ItemTurret")'), tick.index('var power_graph_last_values_stamped: Dictionary = source_turret_power_graph_last_values_stamp_state(frame, power_graph_update if power_graph_update is Dictionary else {})'))
        self.assertIn('var power_graph_update: Variant = game.get("power_graph_update")', tick)
        # The 8 leg functions and the dispatch are UNTOUCHED
        # by this slice (same signatures as N2511-N2521).
        self.assertIn(SENSE_SIGNATURE, turret)
        for signature in LEG_SIGNATURES:
            with self.subTest(signature=signature):
                self.assertIn(signature, turret)
        # The proof's keys drive stamp + dispatch end to end
        # (no live tick: the proof calls the stamp directly
        # with synthetic graph updates, then the dispatch): a
        # full update reads powerNetIn 120.0 (= 2.0 * 60),
        # powerNetOut 90.0 (= 1.5 * 60), powerNetStored 250.0
        # and powerNetCapacity 1000.0, all handled:true; a
        # cheat-branch update (empty balance_state, stored
        # 300.0) keeps the previous scaled value (120.0) and
        # updates stored to 300.0; an empty update stamps
        # nothing, so powerNetIn stays handled:false; the
        # sense + ammo + graph stamps compose on one frame
        # (health 250.0, dead 0.0, totalItems 0.0, powerNetIn
        # 120.0, all handled:true).
        proof = POWER_GRAPH_LAST_VALUES_STAMP_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_power_graph_last_values_stamp(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretPowerGraphLastValuesStampProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_POWER_GRAPH_LAST_VALUES_STAMP_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
