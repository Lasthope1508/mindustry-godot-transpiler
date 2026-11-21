import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_SENSE_FRAME_STAMP_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretSenseFrameStampProof.gd'

TURRET_SENSE_FRAME_STAMP_SIGNATURE = 'static func source_turret_sense_frame_stamp_state(frame: Dictionary, health: float, unit_sense_value: float) -> Dictionary:'
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
    'stamp_full_health_dead_num',
    'stamp_full_health_health_num',
    'stamp_damaged_dead_num',
    'stamp_damaged_health_num',
    'stamp_killed_dead_num',
    'stamp_killed_health_num',
    'stamp_camera_x_no_controller_num',
    'stamp_total_items_absent_fallback',
    'stamp_power_net_in_absent_fallback',
    'stamp_power_net_in_no_power_num',
]


class C07TurretSenseFrameStampTests(unittest.TestCase):
    def test_c07_turret_sense_frame_stamp_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2520']['godot_owner'], 'SourceTurretBuildState.source_turret_sense_frame_stamp_state')
        # The turret driver tick stamps the live sense inputs it
        # CAN supply today into the frame, so the N2519-wired
        # dispatch `source_building_comp_sense_state` stops
        # reporting handled:false for them when a live turret
        # ticks. The dispatch already reads 12 frame keys
        # (N2519); today NONE of them is stamped by any live
        # tick -- the frame keys only exist in tests and
        # proofs. This slice stamps the 6 keys whose live
        # source already exists in the tick (`health`,
        # `is_dead`, `tile_build_is_self`,
        # `is_control_block`, `unit_sense_value` -- plus the
        # `health` key itself, six writes) and explicitly
        # leaves the other 6 absent (`items_is_null` /
        # `items_total` / `last_scaled_power_in` /
        # `last_scaled_power_out` / `last_power_stored` /
        # `last_capacity` -- N2519's absent-key fallback keeps
        # handled:false for those legs). ONE pure function +
        # ONE tick call site (not six slices: one mechanism,
        # one tick, one frame). The stamp function returns
        # the frame itself (the N2108
        # `source_turret_tick_frame_state` precedent: one
        # result symbol, `result.frame`), so exactly one new
        # result symbol is registered; the ported method is
        # BuildingComp.sense, so the java_source is
        # BuildingComp.java and the slice mirrors into the
        # comp shard (569/472 -> 570/473); defense stays
        # 210/209.
        self.assertEqual(
            ledger['N2520']['source_symbols'],
            [
                'source_turret_sense_frame_stamp_state_result.frame',
            ],
        )
        for name in ledger['N2520']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/entities/comp/BuildingComp.java')
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_sense_frame_stamp_state')
        self.assertEqual(ledger['N2520']['runtime_proof'], '/root/C07TurretSenseFrameStampProof')
        self.assertEqual(
            ledger['N2520']['tests'],
            [
                'test_c07_turret_sense_frame_stamp_registration',
                'test_all_c07_turret_sense_frame_stamp_input_evidence_is_exact',
                'test_turret_sense_frame_stamp_state',
                'test_reference_graph_and_actual_c07_turret_sense_frame_stamp',
            ],
        )
        self.assertTrue(ledger['N2520']['deferred_exprs'])

    def test_all_c07_turret_sense_frame_stamp_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2520']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_sense_frame_stamp_state')
        slice_sources = {
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/entities/comp/UnitComp.java',
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/world/blocks/power/PowerGraph.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2520']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_sense_frame_stamp_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # The stamp writes exactly the 6 keys the tick can
        # supply today and returns the frame (the N2108
        # tick-frame precedent):
        # - `health` is the live sprite health (`case health
        # -> health;`, BuildingComp.java:2101);
        # - `is_dead` is `health <= 0.0` (the kill trigger
        # `if(health <= 0f && !dead()){`, :2170, sets `dead =
        # true;` in killed(), :2243; the port-consistent
        # reading, SourceBuildingDamageState.gd:40
        # `"was_dead": current_health <= 0.0`);
        # - `tile_build_is_self` is the constant true (the
        # tick only iterates live placed buildings, so
        # `tile.build == self()` holds -- the first conjunct
        # of `isValid()`, `return tile.build == self() &&
        # !dead();`, :2031);
        # - `is_control_block` is the constant true (every
        # turret build implements ControlBlock, `public class
        # TurretBuild extends ReloadTurretBuild implements
        # ControlBlock{`, Turret.java:277);
        # - `unit_sense_value` is passed in (the tick passes
        # 0.0 today -- no player controller attached, so
        # every camera* leg reads 0, UnitComp.java:283-286).
        # It does NOT touch the other 6 keys: absent keys
        # stay absent, so the dispatch keeps handled:false
        # for totalItems / powerNet* exactly as N2519 left
        # them. The tick call site reads health from the
        # sprite meta (`source_block_health`,
        # SourcePlacedBlockState.gd:45, set at placement
        # :82-86 and decremented by damage) with the block
        # health as fallback (a building with no damage
        # record is at full health, not dead) and passes
        # `unit_sense_value = 0.0`.
        self.assertIn(TURRET_SENSE_FRAME_STAMP_SIGNATURE, turret)
        for line in [
            'frame["health"] = health',
            'frame["is_dead"] = health <= 0.0',
            'frame["tile_build_is_self"] = true',
            'frame["is_control_block"] = true',
            'frame["unit_sense_value"] = unit_sense_value',
            'return frame',
            'var sense_health: float = float(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_HEALTH_META_KEY, source_block_metadata_state.block_health_value(block)))',
            'var stamped: Dictionary = source_turret_sense_frame_stamp_state(frame, sense_health, 0.0)',
        ]:
            with self.subTest(line=line):
                self.assertIn(line, turret)
        for expr in [
            'public double sense(LAccess sensor){',
            'return tile.build == self() && !dead();',
            'case health -> health;',
            'case cameraX, cameraY, cameraWidth, cameraHeight -> this instanceof ControlBlock c ? c.unit().sense(sensor) : 0;',
            'case cameraX -> controller instanceof Player player ? World.conv(player.con == null ? Core.camera.position.x : player.con.viewX) : 0;',
            'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
            'if(health <= 0f && !dead()){',
            'dead = true;',
            'public void updateTile(){',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The stamp sits right AFTER
        # source_turret_tick_frame_state (mirroring Java
        # order -- the tick refreshes frame keys, the stamp
        # is part of that refresh) and BEFORE _initial_frame.
        self.assertLess(turret.index('static func source_turret_tick_frame_state('), turret.index('static func source_turret_sense_frame_stamp_state('))
        self.assertLess(turret.index('static func source_turret_sense_frame_stamp_state('), turret.index('static func _initial_frame('))
        # The tick call site sits inside
        # source_turret_tick_buildings_state, right after the
        # source_turret_tick_frame_state call.
        tick = turret[turret.index('static func source_turret_tick_buildings_state('):]
        self.assertLess(tick.index('var wired: Dictionary = source_turret_tick_frame_state(frame, str(block.implementation), team_id, rules_state)'), tick.index('var stamped: Dictionary = source_turret_sense_frame_stamp_state(frame, sense_health, 0.0)'))
        # The 8 leg functions and the dispatch are UNTOUCHED
        # by this slice (same signatures as N2511-N2519).
        self.assertIn(SENSE_SIGNATURE, turret)
        for signature in LEG_SIGNATURES:
            with self.subTest(signature=signature):
                self.assertIn(signature, turret)
        # The proof's keys drive stamp + dispatch end to end
        # (no live tick: the proof calls the stamp directly
        # with synthetic health, then the dispatch): live duo
        # at full health (250.0 -> dead 0.0, health 250.0);
        # damaged duo (120.0 -> dead 0.0, health 120.0);
        # killed duo (0.0 -> dead 1.0, health 0.0); cameraX
        # on a control block with no player controller -> 0.0
        # handled:true; totalItems still handled:false (keys
        # absent -- inventory not tracked); powerNetIn still
        # handled:false (keys absent -- graph last-values not
        # tracked); has_power=false fold still 0.0
        # handled:true for powerNetIn (N2519 behavior
        # preserved).
        proof = TURRET_SENSE_FRAME_STAMP_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_sense_frame_stamp(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretSenseFrameStampProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_SENSE_FRAME_STAMP_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
