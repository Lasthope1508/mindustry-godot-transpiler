import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
BUILDING_COMP_SENSE_WIRING_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BuildingCompSenseWiringProof.gd'

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
    'wiring_dead_alive_num',
    'wiring_dead_dead_num',
    'wiring_dead_not_self_num',
    'wiring_health_num',
    'wiring_total_items_num',
    'wiring_total_items_null_num',
    'wiring_power_net_in_num',
    'wiring_power_net_out_num',
    'wiring_power_net_stored_num',
    'wiring_power_net_capacity_num',
    'wiring_camera_x_num',
    'wiring_camera_y_not_control_num',
    'wiring_dead_absent_fallback',
    'wiring_power_net_in_absent_fallback',
    'wiring_power_net_in_no_power_num',
]


class C07BuildingCompSenseWiringTests(unittest.TestCase):
    def test_c07_building_comp_sense_wiring_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2519']['godot_owner'], 'SourceTurretBuildState.source_building_comp_sense_state')
        # BuildingComp.sense() (`public double sense(LAccess
        # sensor){`, BuildingComp.java:2093-2126) wired its
        # eight already-ported legs into the dispatch:
        # `case dead -> !isValid() ? 1 : 0;` (:2098, N2511),
        # `case health -> health;` (:2101, N2512),
        # `case totalItems -> items == null ? 0 : items.total();`
        # (:2107, N2513), `case powerNetIn -> power == null ? 0 :
        # power.graph.getLastScaledPowerIn() * 60;` (:2114,
        # N2514), `case powerNetOut -> power == null ? 0 :
        # power.graph.getLastScaledPowerOut() * 60;` (:2115,
        # N2515), `case powerNetStored -> power == null ? 0 :
        # power.graph.getLastPowerStored();` (:2116, N2516),
        # `case powerNetCapacity -> power == null ? 0 :
        # power.graph.getLastCapacity();` (:2117, N2517),
        # `case cameraX, cameraY, cameraWidth, cameraHeight ->
        # this instanceof ControlBlock c ? c.unit().sense(sensor)
        # : 0;` (:2122, N2518). The dispatch signature is
        # UNCHANGED (24 params stay 24, the N2235 precedent):
        # the leg inputs arrive as 11 frame keys
        # (`tile_build_is_self`, `is_dead`, `health`,
        # `items_is_null`, `items_total`,
        # `last_scaled_power_in`, `last_scaled_power_out`,
        # `last_power_stored`, `last_capacity`,
        # `is_control_block`, `unit_sense_value` -- plus the
        # existing `has_power` param as `power_is_null =
        # not has_power`). An absent key keeps the OLD
        # behavior exactly (handled:false + NaN, the N2284
        # deferred state); presence is checked with
        # `frame.has(key)`, NOT with a default value, so a
        # present key carrying 0 / false is live input, not
        # absence. A present key delegates to the leg
        # function and returns its result VERBATIM (same
        # 3-key wire shape; the dispatch never re-derives
        # the value -- the leg function IS the Java case).
        # No new pure function is added, so no new result
        # symbols exist: this slice re-registers the three
        # dispatch result symbols (handled, sense_value,
        # sense_value_is_nan -- the N2283/N2284 sense wire
        # shape, first registered by N2284) under its own
        # tests + proof, and the ledger entry lists them.
        self.assertEqual(
            ledger['N2519']['source_symbols'],
            [
                'source_building_comp_sense_state_result.handled',
                'source_building_comp_sense_state_result.sense_value',
                'source_building_comp_sense_state_result.sense_value_is_nan',
            ],
        )
        for name in ledger['N2519']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/entities/comp/BuildingComp.java')
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_building_comp_sense_state')
        self.assertEqual(ledger['N2519']['runtime_proof'], '/root/C07BuildingCompSenseWiringProof')
        self.assertEqual(
            ledger['N2519']['tests'],
            [
                'test_c07_building_comp_sense_wiring_registration',
                'test_all_c07_building_comp_sense_wiring_input_evidence_is_exact',
                'test_building_comp_sense_wiring_state',
                'test_reference_graph_and_actual_c07_building_comp_sense_wiring',
            ],
        )
        self.assertTrue(ledger['N2519']['deferred_exprs'])

    def test_all_c07_building_comp_sense_wiring_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2519']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_building_comp_sense_state')
        slice_sources = {
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/entities/comp/UnitComp.java',
            'core/src/mindustry/logic/LAccess.java',
            'core/src/mindustry/world/blocks/power/PowerGraph.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2519']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_building_comp_sense_wiring_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # The dispatch signature is UNCHANGED (24 params):
        # the leg inputs arrive as 11 frame keys (plus the existing `has_power` param), so every
        # existing caller (N2284 proof + tests, 24 positional
        # args) keeps working untouched.
        self.assertIn(SENSE_SIGNATURE, turret)
        # The 8 leg functions are UNTOUCHED by this slice
        # (same signatures, same bodies as N2511-N2518);
        # only the dispatch gains branches that delegate to
        # them.
        for signature in LEG_SIGNATURES:
            with self.subTest(signature=signature):
                self.assertIn(signature, turret)
        for line in [
            'if sensor == "dead":',
            'if frame.has("tile_build_is_self") and frame.has("is_dead"):',
            'return source_building_comp_sense_dead_state(bool(frame.get("tile_build_is_self")), bool(frame.get("is_dead")))',
            'if sensor == "health":',
            'if frame.has("health"):',
            'return source_building_comp_sense_health_state(float(frame.get("health")))',
            'if sensor == "totalItems":',
            'if frame.has("items_is_null") and frame.has("items_total"):',
            'return source_building_comp_sense_total_items_state(bool(frame.get("items_is_null")), int(frame.get("items_total")))',
            'if frame.has("last_scaled_power_in"):',
            'return source_building_comp_sense_power_net_in_state(not has_power, float(frame.get("last_scaled_power_in")))',
            'if frame.has("last_scaled_power_out"):',
            'return source_building_comp_sense_power_net_out_state(not has_power, float(frame.get("last_scaled_power_out")))',
            'if frame.has("last_power_stored"):',
            'return source_building_comp_sense_power_net_stored_state(not has_power, float(frame.get("last_power_stored")))',
            'if frame.has("last_capacity"):',
            'return source_building_comp_sense_power_net_capacity_state(not has_power, float(frame.get("last_capacity")))',
            'if sensor == "cameraX" or sensor == "cameraY" or sensor == "cameraWidth" or sensor == "cameraHeight":',
            'if frame.has("is_control_block") and frame.has("unit_sense_value"):',
            'return source_building_comp_sense_camera_state(sensor, bool(frame.get("is_control_block")), float(frame.get("unit_sense_value")))',
        ]:
            with self.subTest(line=line):
                self.assertIn(line, turret)
        for expr in [
            'case dead -> !isValid() ? 1 : 0;',
            'case health -> health;',
            'case totalItems -> items == null ? 0 : items.total();',
            'case powerNetIn -> power == null ? 0 : power.graph.getLastScaledPowerIn() * 60;',
            'case powerNetOut -> power == null ? 0 : power.graph.getLastScaledPowerOut() * 60;',
            'case powerNetStored -> power == null ? 0 : power.graph.getLastPowerStored();',
            'case powerNetCapacity -> power == null ? 0 : power.graph.getLastCapacity();',
            'case cameraX, cameraY, cameraWidth, cameraHeight -> this instanceof ControlBlock c ? c.unit().sense(sensor) : 0;',
            'public double sense(LAccess sensor){',
            'default -> Float.NaN; //gets converted to null in logic',
            'return tile.build == self() && !dead();',
            'case cameraX -> controller instanceof Player player ? World.conv(player.con == null ? Core.camera.position.x : player.con.viewX) : 0;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # Branch placement mirrors Java switch order (the
        # dispatch already does): dead after `color` (before
        # `solid`); health after `team` (before `maxHealth`);
        # totalItems after `rotation` (before
        # `totalLiquids`); camera* after `size` (before the
        # final default return -- camera* is the last case
        # before `default`, :2122). Checked inside the
        # dispatch body only (`rotation` also appears in
        # source_turret_sense_state).
        dispatch = turret[turret.index('static func source_building_comp_sense_state('):turret.index('static func source_building_comp_sense_dead_state(')]
        self.assertLess(dispatch.index('if sensor == "color":'), dispatch.index('if sensor == "dead":'))
        self.assertLess(dispatch.index('if sensor == "dead":'), dispatch.index('if sensor == "solid":'))
        self.assertLess(dispatch.index('if sensor == "team":'), dispatch.index('if sensor == "health":'))
        self.assertLess(dispatch.index('if sensor == "health":'), dispatch.index('if sensor == "maxHealth":'))
        self.assertLess(dispatch.index('if sensor == "rotation":'), dispatch.index('if sensor == "totalItems":'))
        self.assertLess(dispatch.index('if sensor == "totalItems":'), dispatch.index('if sensor == "totalLiquids":'))
        self.assertLess(dispatch.index('if sensor == "size":'), dispatch.index('if sensor == "cameraX"'))
        # The existing `has_power == false` -> 0.0 fold stays
        # FIRST and unchanged inside the powerNet branch;
        # the wiring only replaces the `has_power == true`
        # fallthrough with per-leg delegation + the
        # absent-key handled:false fallback.
        self.assertIn('var power_net_value: float = 0.0', dispatch)
        # The proof's keys drive the dispatch with synthetic
        # frames (no live tick: sense is a logic read of the
        # frame + explicit live / catalog params): dead wired
        # (tile self + alive -> 0.0; tile self + dead -> 1.0;
        # tile not self -> 1.0); health wired (250.0 ->
        # 250.0); totalItems wired (items present, total 7 ->
        # 7.0; items null -> 0.0); powerNetIn wired
        # (has_power + last_scaled_power_in 2.5 -> 150.0);
        # powerNetOut wired (has_power + 1.0 -> 60.0);
        # powerNetStored wired (has_power + 500.0 -> 500.0);
        # powerNetCapacity wired (has_power + 1000.0 ->
        # 1000.0); cameraX wired (control block + unit value
        # 12.5 -> 12.5); cameraY not control block -> 0.0;
        # absent-key fallback handled:false for dead (no
        # keys) and for powerNetIn (has_power true, no graph
        # key); has_power=false fold still 0.0 handled:true
        # for powerNetIn.
        proof = BUILDING_COMP_SENSE_WIRING_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_building_comp_sense_wiring(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BuildingCompSenseWiringProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BUILDING_COMP_SENSE_WIRING_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
