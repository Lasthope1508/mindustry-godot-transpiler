import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_AMMO_ITEMS_STAMP_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretAmmoItemsStampProof.gd'

TURRET_AMMO_ITEMS_STAMP_SIGNATURE = 'static func source_turret_ammo_items_stamp_state(frame: Dictionary, has_items: bool) -> Dictionary:'
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
    'stamp_item_turret_total_items_zero_num',
    'stamp_no_items_total_items_zero_num',
    'stamp_overwrites_stale_items_total_num',
    'stamp_composed_health_num',
    'stamp_composed_dead_num',
    'stamp_composed_camera_x_num',
    'stamp_killed_total_items_zero_num',
    'stamp_power_net_in_absent_fallback',
]


class C07TurretAmmoItemsStampTests(unittest.TestCase):
    def test_c07_turret_ammo_items_stamp_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2521']['godot_owner'], 'SourceTurretBuildState.source_turret_ammo_items_stamp_state')
        # The turret driver tick stamps the live item inventory
        # into the frame, so the N2519-wired dispatch
        # `source_building_comp_sense_state` stops reporting
        # handled:false for the totalItems leg when a live
        # turret ticks. The stamp writes exactly the 2 items
        # keys (`items_is_null` / `items_total`) and explicitly
        # leaves the 4 graph keys absent (N2519's absent-key
        # fallback keeps handled:false for powerNet*). ONE pure
        # function + ONE tick call site (the N2520 pattern:
        # one mechanism, one tick, one frame). The stamp
        # function returns the frame itself (the N2108
        # `source_turret_tick_frame_state` precedent: one
        # result symbol, `result.frame`), so exactly one new
        # result symbol is registered; the ported method is
        # BuildingComp.sense, so the java_source is
        # BuildingComp.java and the slice mirrors into the
        # comp shard (570/473 -> 571/474); defense stays
        # 210/209.
        self.assertEqual(
            ledger['N2521']['source_symbols'],
            [
                'source_turret_ammo_items_stamp_state_result.frame',
            ],
        )
        for name in ledger['N2521']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/entities/comp/BuildingComp.java')
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_ammo_items_stamp_state')
        self.assertEqual(ledger['N2521']['runtime_proof'], '/root/C07TurretAmmoItemsStampProof')
        self.assertEqual(
            ledger['N2521']['tests'],
            [
                'test_c07_turret_ammo_items_stamp_registration',
                'test_all_c07_turret_ammo_items_stamp_input_evidence_is_exact',
                'test_turret_ammo_items_stamp_state',
                'test_reference_graph_and_actual_c07_turret_ammo_items_stamp',
            ],
        )
        self.assertTrue(ledger['N2521']['deferred_exprs'])

    def test_all_c07_turret_ammo_items_stamp_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2521']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_ammo_items_stamp_state')
        slice_sources = {
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java',
            'core/src/mindustry/world/modules/ItemModule.java',
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/world/blocks/power/PowerGraph.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2521']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_ammo_items_stamp_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # The stamp writes exactly the 2 items keys and returns
        # the frame (the N2108 tick-frame precedent):
        # - `items_is_null` is `not has_items` -- only
        # ItemTurret has an item module (`if(block.hasItems)
        # items = new ItemModule();`, BuildingComp.java:145;
        # `hasItems = true;`, ItemTurret.java:28, the ONLY
        # hasItems set among the 5 ticked implementations);
        # - `items_total` is the constant 0 -- the `items`
        # module is NEVER written for an ItemTurretBuild:
        # `ItemTurretBuild.handleItem` (ItemTurret.java:155-185)
        # overrides `BuildingComp.handleItem` (:860-862,
        # `items.add(item, 1);`) WITHOUT calling super, so it
        # only updates `totalAmmo` (`totalAmmo +=
        # type.ammoMultiplier;`, :168) and the ammo-weighted
        # `ammo` entries; `handleStack` (:141-147) loops
        # `handleItem` and `read()` restores `ammo` +
        # `totalAmmo`, never `items`. The module exists but
        # stays empty, so `items.total()` is 0 always (`case
        # totalItems -> items == null ? 0 : items.total();`,
        # :2107; `public int total(){`, ItemModule.java:174).
        # The port's `turret_ammo_stacks` are the Java `ammo`
        # Seq (ammo-weighted entries), NOT the `items` module
        # -- summing them would invent behavior (a duo with
        # copper 5 + graphite 3 stacks would read 8.0 while
        # Java reads 0.0), so the tick reads NO stacks dict
        # for this stamp. The stamp OVERWRITES any stale
        # `items_total` already on the frame. It does NOT
        # touch the 4 graph keys: absent keys stay absent,
        # so the dispatch keeps handled:false for powerNet*
        # exactly as N2519/N2520 left them. The tick call
        # site passes `str(block.implementation) ==
        # "ItemTurret"` (the file's established
        # implementation-string pattern).
        self.assertIn(TURRET_AMMO_ITEMS_STAMP_SIGNATURE, turret)
        for line in [
            'frame["items_is_null"] = not has_items',
            'frame["items_total"] = 0',
            'return frame',
            'var ammo_items_stamped: Dictionary = source_turret_ammo_items_stamp_state(frame, str(block.implementation) == "ItemTurret")',
        ]:
            with self.subTest(line=line):
                self.assertIn(line, turret)
        for expr in [
            'public double sense(LAccess sensor){',
            'case totalItems -> items == null ? 0 : items.total();',
            'if(block.hasItems) items = new ItemModule();',
            'hasItems = true;',
            'public int total(){',
            'items.add(item, 1);',
            'totalAmmo += type.ammoMultiplier;',
            'public void updateTile(){',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The stamp sits right AFTER the N2520 sense stamp
        # (mirroring Java order -- the tick refreshes frame
        # keys, the stamp is part of that refresh) and BEFORE
        # _initial_frame.
        self.assertLess(turret.index('static func source_turret_sense_frame_stamp_state('), turret.index('static func source_turret_ammo_items_stamp_state('))
        self.assertLess(turret.index('static func source_turret_ammo_items_stamp_state('), turret.index('static func _initial_frame('))
        # The tick call site sits inside
        # source_turret_tick_buildings_state, right after the
        # N2520 sense-stamp call.
        tick = turret[turret.index('static func source_turret_tick_buildings_state('):]
        self.assertLess(tick.index('var stamped: Dictionary = source_turret_sense_frame_stamp_state(frame, sense_health, 0.0)'), tick.index('var ammo_items_stamped: Dictionary = source_turret_ammo_items_stamp_state(frame, str(block.implementation) == "ItemTurret")'))
        # The 8 leg functions and the dispatch are UNTOUCHED
        # by this slice (same signatures as N2511-N2520).
        self.assertIn(SENSE_SIGNATURE, turret)
        for signature in LEG_SIGNATURES:
            with self.subTest(signature=signature):
                self.assertIn(signature, turret)
        # The proof's keys drive stamp + dispatch end to end
        # (no live tick: the proof calls the stamp directly
        # with synthetic has_items, then the dispatch): an
        # ItemTurret reads totalItems 0.0 handled:true (the
        # module exists but is empty -- Java never writes it);
        # a non-ItemTurret reads 0.0 handled:true (items is
        # null); a stale items_total 99 is overwritten to 0.0;
        # the sense + ammo stamps compose (health 250.0, dead
        # 0.0, cameraX 0.0); a killed duo still reads
        # totalItems 0.0 handled:true; powerNetIn still
        # handled:false (graph keys absent -- last-values not
        # tracked).
        proof = TURRET_AMMO_ITEMS_STAMP_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_ammo_items_stamp(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretAmmoItemsStampProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_AMMO_ITEMS_STAMP_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
