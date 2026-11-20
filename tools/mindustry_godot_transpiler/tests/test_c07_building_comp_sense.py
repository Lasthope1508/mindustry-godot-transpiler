import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
BUILDING_COMP_SENSE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BuildingCompSenseProof.gd'

SENSE_SIGNATURE = 'static func source_building_comp_sense_state(frame: Dictionary, sensor: String, tilesize: float, world_x: float, world_y: float, team_color_r: float, team_color_g: float, team_color_b: float, block_solid: bool, block_size: int, max_health: float, range_value: float, has_items: bool, item_capacity: int, has_liquids: bool, liquid_capacity: float, total_liquids: float, has_cons_power: bool, power_capacity: float, power_buffered: bool, has_power: bool, time_scale: float, is_player: bool, payload_count: int) -> Dictionary:'
PROOF_KEYS = [
    'sense_x_converted',
    'sense_y_converted',
    'sense_color_sharded',
    'sense_color_derelict',
    'sense_solid_true',
    'sense_solid_false',
    'sense_team_live',
    'sense_max_health_duo',
    'sense_efficiency_live',
    'sense_timescale_default',
    'sense_range_duo',
    'sense_range_graphite',
    'sense_rotation_live',
    'sense_total_liquids_none',
    'sense_total_liquids_live',
    'sense_total_power_no_consumer',
    'sense_total_power_buffered',
    'sense_total_power_unbuffered',
    'sense_item_capacity_duo',
    'sense_item_capacity_no_items',
    'sense_liquid_capacity_none',
    'sense_liquid_capacity_live',
    'sense_power_capacity_no_consumer',
    'sense_power_capacity_live',
    'sense_power_net_in_no_power',
    'sense_power_net_out_no_power',
    'sense_power_net_stored_no_power',
    'sense_power_net_capacity_no_power',
    'sense_power_net_in_deferred',
    'sense_enabled_true',
    'sense_enabled_false',
    'sense_controlled_false',
    'sense_controlled_player',
    'sense_payload_count_none',
    'sense_size_duo',
    'sense_unhandled_dead',
    'sense_unhandled_health',
    'sense_unhandled_total_items',
    'sense_unhandled_camera_x',
    'sense_unknown_sensor',
]


class C07BuildingCompSenseTests(unittest.TestCase):
    def test_c07_building_comp_sense_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2284']['godot_owner'], 'SourceTurretBuildState.source_building_comp_sense_state')
        # super.sense() is `public double sense(LAccess
        # sensor){ return switch(sensor){ case x ->
        # World.conv(x); case y -> World.conv(y); case color
        # -> Color.toDoubleBits(team.color.r, team.color.g,
        # team.color.b, 1f); case dead -> !isValid() ? 1 : 0;
        # case solid -> block.solid || checkSolid() ? 1 : 0;
        # case team -> team.id; case health -> health; case
        # maxHealth -> maxHealth; case efficiency ->
        # efficiency; case timescale -> timeScale; case range
        # -> this instanceof Ranged r ? r.range() / tilesize
        # : 0; case rotation -> rotation; case totalItems ->
        # items == null ? 0 : items.total(); case
        # totalLiquids -> liquids == null ? 0 :
        # liquids.currentAmount(); case totalPower -> power
        # == null || block.consPower == null ? 0 :
        # power.status * (block.consPower.buffered ?
        # block.consPower.capacity : 1f); case itemCapacity
        # -> block.hasItems ? block.itemCapacity : 0; case
        # liquidCapacity -> block.hasLiquids ?
        # block.liquidCapacity : 0; case powerCapacity ->
        # block.consPower != null ? block.consPower.capacity
        # : 0f; case powerNetIn -> power == null ? 0 :
        # power.graph.getLastScaledPowerIn() * 60; case
        # powerNetOut -> power == null ? 0 :
        # power.graph.getLastScaledPowerOut() * 60; case
        # powerNetStored -> power == null ? 0 :
        # power.graph.getLastPowerStored(); case
        # powerNetCapacity -> power == null ? 0 :
        # power.graph.getLastCapacity(); case enabled ->
        # enabled ? 1 : 0; case controlled -> this instanceof
        # ControlBlock c && c.isControlled() ?
        # GlobalVars.ctrlPlayer : 0; case payloadCount ->
        # (getPayloads() != null ? getPayloads().total() : 0)
        # + (getPayload() != null ? 1 : 0); case size ->
        # block.size; case cameraX, cameraY, cameraWidth,
        # cameraHeight -> this instanceof ControlBlock c ?
        # c.unit().sense(sensor) : 0; default -> Float.NaN;
        # }; }` (BuildingComp.java:2093-2126). 23 of the 30
        # sensors are implemented here (see the scope file
        # docs/superpowers/handoffs/hidden_files/n2284-scope.md
        # for the case-by-case liveness); dead / health /
        # totalItems / cameraX / cameraY / cameraWidth /
        # cameraHeight stay deferred and report handled=false
        # + NaN, as do powerNet* legs when has_power is true
        # (the graph is not live in the frame). There is NO
        # driver tick line: sense is a logic read, not a tick
        # write (the N2206/N2208/N2223/N2283 precedent); the
        # proof calls the pure function directly with
        # synthetic frames, and the logic-processor dispatch
        # hook is its own later slice. Three new result
        # symbols: handled, sense_value, sense_value_is_nan.
        self.assertEqual(
            ledger['N2284']['source_symbols'],
            [
                'source_building_comp_sense_state_result.handled',
                'source_building_comp_sense_state_result.sense_value',
                'source_building_comp_sense_state_result.sense_value_is_nan',
            ],
        )
        for name in ledger['N2284']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_building_comp_sense_state')
        self.assertEqual(ledger['N2284']['runtime_proof'], '/root/C07BuildingCompSenseProof')
        self.assertEqual(
            ledger['N2284']['tests'],
            [
                'test_c07_building_comp_sense_registration',
                'test_all_c07_building_comp_sense_input_evidence_is_exact',
                'test_building_comp_sense_state',
                'test_reference_graph_and_actual_c07_building_comp_sense',
            ],
        )
        self.assertTrue(ledger['N2284']['deferred_exprs'])

    def test_all_c07_building_comp_sense_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2284']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_building_comp_sense_state')
        slice_sources = {
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
            'core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/core/World.java',
            'core/src/mindustry/Vars.java',
            'core/src/mindustry/logic/LAccess.java',
            'core/src/mindustry/game/Team.java',
            'core/src/mindustry/logic/GlobalVars.java',
            'core/src/mindustry/graphics/Pal.java',
            'core/src/mindustry/world/blocks/ControlBlock.java',
            'arc-core/src/arc/graphics/Color.java',
        }
        upstream = {}
        for source in slice_sources:
            base = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (base / source).read_text(encoding='utf-8')
        for expr in ledger['N2284']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_building_comp_sense_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # super.sense() (BuildingComp.java:2093-2126)
        # dispatches the BuildingComp cases over live frame
        # keys (team_id / efficiency / rotation / enabled /
        # power_status), explicit params for values with no
        # frame key (world_x / world_y, team color, time_scale,
        # is_player, payload_count, range_value) and catalog
        # params (block_solid, block_size, max_health,
        # item_capacity, liquid_capacity, power_capacity,
        # has_items / has_liquids / has_cons_power /
        # power_buffered / has_power). The sensor spellings
        # are the LAccess enum names. The pure function
        # returns the N2206/N2208/N2223/N2283 sense wire shape
        # (handled + sense_value + sense_value_is_nan).
        # There is no driver tick line: sense is a logic read,
        # not a tick write.
        self.assertIn(SENSE_SIGNATURE, turret)
        for line in [
            'return {"handled": true, "sense_value": x_value, "sense_value_is_nan": false}',
            'return {"handled": true, "sense_value": y_value, "sense_value_is_nan": false}',
            'return {"handled": true, "sense_value": color_value, "sense_value_is_nan": false}',
            'return {"handled": true, "sense_value": solid_value, "sense_value_is_nan": false}',
            'return {"handled": true, "sense_value": team_value, "sense_value_is_nan": false}',
            'return {"handled": true, "sense_value": max_health_value, "sense_value_is_nan": false}',
            'return {"handled": true, "sense_value": efficiency_value, "sense_value_is_nan": false}',
            'return {"handled": true, "sense_value": timescale_value, "sense_value_is_nan": false}',
            'return {"handled": true, "sense_value": range_tiles, "sense_value_is_nan": false}',
            'return {"handled": true, "sense_value": rotation_value, "sense_value_is_nan": false}',
            'return {"handled": true, "sense_value": total_liquids_value, "sense_value_is_nan": false}',
            'return {"handled": true, "sense_value": total_power_value, "sense_value_is_nan": false}',
            'return {"handled": true, "sense_value": item_capacity_value, "sense_value_is_nan": false}',
            'return {"handled": true, "sense_value": liquid_capacity_value, "sense_value_is_nan": false}',
            'return {"handled": true, "sense_value": power_capacity_value, "sense_value_is_nan": false}',
            'return {"handled": true, "sense_value": power_net_value, "sense_value_is_nan": false}',
            'return {"handled": true, "sense_value": enabled_value, "sense_value_is_nan": false}',
            'return {"handled": true, "sense_value": controlled_value, "sense_value_is_nan": false}',
            'return {"handled": true, "sense_value": payload_count_value, "sense_value_is_nan": false}',
            'return {"handled": true, "sense_value": size_value, "sense_value_is_nan": false}',
            'return {"handled": false, "sense_value": null, "sense_value_is_nan": true}',
        ]:
            with self.subTest(line=line):
                self.assertIn(line, turret)
        for expr in [
            'public double sense(LAccess sensor){',
            'case x -> World.conv(x);',
            'case y -> World.conv(y);',
            'case color -> Color.toDoubleBits(team.color.r, team.color.g, team.color.b, 1f);',
            'case dead -> !isValid() ? 1 : 0;',
            'case solid -> block.solid || checkSolid() ? 1 : 0;',
            'case team -> team.id;',
            'case health -> health;',
            'case maxHealth -> maxHealth;',
            'case efficiency -> efficiency;',
            'case timescale -> timeScale;',
            'case range -> this instanceof Ranged r ? r.range() / tilesize : 0;',
            'case rotation -> rotation;',
            'case totalItems -> items == null ? 0 : items.total();',
            'case totalLiquids -> liquids == null ? 0 : liquids.currentAmount();',
            'case totalPower -> power == null || block.consPower == null ? 0 : power.status * (block.consPower.buffered ? block.consPower.capacity : 1f);',
            'case itemCapacity -> block.hasItems ? block.itemCapacity : 0;',
            'case liquidCapacity -> block.hasLiquids ? block.liquidCapacity : 0;',
            'case powerCapacity -> block.consPower != null ? block.consPower.capacity : 0f;',
            'case powerNetIn -> power == null ? 0 : power.graph.getLastScaledPowerIn() * 60;',
            'case powerNetOut -> power == null ? 0 : power.graph.getLastScaledPowerOut() * 60;',
            'case powerNetStored -> power == null ? 0 : power.graph.getLastPowerStored();',
            'case powerNetCapacity -> power == null ? 0 : power.graph.getLastCapacity();',
            'case enabled -> enabled ? 1 : 0;',
            'case controlled -> this instanceof ControlBlock c && c.isControlled() ? GlobalVars.ctrlPlayer : 0;',
            'case payloadCount -> (getPayloads() != null ? getPayloads().total() : 0) + (getPayload() != null ? 1 : 0);',
            'case size -> block.size;',
            'case cameraX, cameraY, cameraWidth, cameraHeight -> this instanceof ControlBlock c ? c.unit().sense(sensor) : 0;',
            'default -> Float.NaN; //gets converted to null in logic',
            'return tile.build == self() && !dead();',
            'public boolean checkSolid(){',
            'public float rotation = 90;',
            'public static float conv(float coord){',
            'return coord / tilesize;',
            'public static final int tilesize = 8;',
            'transient boolean enabled = true;',
            'transient float efficiency;',
            'private transient float timeScale = 1f, timeScaleDuration;',
            'maxHealth(block.health);',
            'health = 250;',
            'range = 160;',
            'rangeChange = 16f;',
            'public int itemCapacity = 10;',
            'public int size = 1;',
            'public float liquidCapacity = -1f;',
            'solid = true;',
            'public class BaseTurretBuild extends Building implements Ranged, RotBlock{',
            'public float range(){',
            'return range + peekAmmo().rangeChange;',
            'hasItems = true;',
            'public static final int ctrlProcessor = 1, ctrlPlayer = 2, ctrlCommand = 3;',
            'public Unit unit(){',
            'public BlockUnitc unit = (BlockUnitc)UnitTypes.block.create(team);',
            'return unit().isPlayer();',
            'public @Nullable Payload getPayload(){',
            'public @Nullable PayloadSeq getPayloads(){',
            'accent = Color.valueOf("ffd37f"),',
            'derelict = new Team(0, "derelict", Color.valueOf("4d4e58")),',
            'sharded = new Team(1, "sharded", Pal.accent.cpy(), Color.valueOf("ffd37f"), Color.valueOf("eab678"), Color.valueOf("d4816b")),',
            'coolant = consumeCoolant(0.1f);',
            'public static double toDoubleBits(float r, float g, float b, float a){',
            'return Double.longBitsToDouble(Color.rgba8888(r, g, b, a) & 0x00000000_ffffffffL);',
            'public static int rgba8888(float r, float g, float b, float a){',
            'return ((int)(r * 255) << 24) | ((int)(g * 255) << 16) | ((int)(b * 255) << 8) | (int)(a * 255);',
            'x,',
            'y,',
            'color("to");',
            'dead,',
            'solid,',
            'team,',
            'health,',
            'maxHealth,',
            'efficiency,',
            'timescale,',
            'range,',
            'rotation,',
            'totalItems,',
            'totalLiquids,',
            'totalPower,',
            'itemCapacity,',
            'liquidCapacity,',
            'powerCapacity,',
            'powerNetStored,',
            'powerNetCapacity,',
            'powerNetIn,',
            'powerNetOut,',
            'enabled("to"),',
            'controlled,',
            'payloadCount,',
            'size,',
            'cameraX,',
            'cameraY,',
            'cameraWidth,',
            'cameraHeight,',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The pure function sits immediately AFTER
        # source_turret_sense_state, since Java order is
        # Turret.sense default -> super.sense, and BEFORE
        # source_turret_progress_state.
        self.assertLess(turret.index('static func source_turret_sense_state('), turret.index('static func source_building_comp_sense_state('))
        self.assertLess(turret.index('static func source_building_comp_sense_state('), turret.index('static func source_turret_progress_state('))
        # The proof's keys drive the pure function with
        # synthetic frames (no live tick: sense is a logic
        # read of the frame + explicit live / catalog params):
        # x/y converted through World.conv, color through
        # arc toDoubleBits for sharded + derelict, solid
        # true/false, team live, maxHealth duo, efficiency
        # live, timescale default, range duo/graphite,
        # rotation live, totalLiquids none/live, totalPower
        # no-consumer/buffered/unbuffered, itemCapacity
        # duo/no-items, liquidCapacity none/live,
        # powerCapacity no-consumer/live, powerNet* no-power
        # plus the has_power deferred leg, enabled
        # true/false, controlled false/player, payloadCount
        # none, size duo, and the unhandled sensors.
        proof = BUILDING_COMP_SENSE_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_building_comp_sense(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BuildingCompSenseProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BUILDING_COMP_SENSE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
