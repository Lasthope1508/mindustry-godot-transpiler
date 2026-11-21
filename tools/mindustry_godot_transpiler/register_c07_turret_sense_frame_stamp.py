"""Register the turret sense frame stamp: the live tick stamps the sense inputs it can supply into the frame (N2520).

BuildingComp.sense() is `public double sense(LAccess sensor){`
(BuildingComp.java:2093-2126). N2519 wired its eight already-ported
legs into the dispatch `source_building_comp_sense_state`, reading
12 frame keys -- but today NONE of them is stamped by any live tick:
the frame keys only exist in tests and proofs. This slice stamps
the 6 keys whose live source already exists in the turret tick
(`source_turret_tick_buildings_state`, TurretBuild.updateTile(),
Turret.java:490), and explicitly leaves the other 6 absent (N2519's
absent-key fallback keeps handled:false for those legs -- no
behavior change there):

- `health`: the sprite meta `source_block_health`
  (SourcePlacedBlockState.gd:45, set at placement :82-86 and
  decremented by damage), `case health -> health;`
  (BuildingComp.java:2101);
- `is_dead`: `health <= 0.0` (the kill trigger `if(health <= 0f
  && !dead()){`, :2170, sets `dead = true;` in killed(), :2243;
  the port-consistent reading,
  SourceBuildingDamageState.gd:40 `"was_dead":
  current_health <= 0.0`);
- `tile_build_is_self`: the constant true -- the tick only
  iterates live placed buildings
  (`source_unique_buildings_state(game)`), so `tile.build ==
  self()` holds (the first conjunct of `isValid()`, `return
  tile.build == self() && !dead();`, :2031);
- `is_control_block`: the constant true -- every turret build
  implements ControlBlock (`public class TurretBuild extends
  ReloadTurretBuild implements ControlBlock{`,
  Turret.java:277);
- `unit_sense_value`: passed in; the tick passes 0.0 today --
  the proxy unit has no player controller attached, so every
  camera* leg reads 0 (`case cameraX, cameraY, cameraWidth,
  cameraHeight -> this instanceof ControlBlock c ?
  c.unit().sense(sensor) : 0;`, :2122, delegating to
  UnitComp.sense :283-286: `case cameraX -> controller
  instanceof Player player ? World.conv(player.con == null ?
  Core.camera.position.x : player.con.viewX) : 0;`).

NOT stamped (deferred, carried below): `items_is_null` /
`items_total` (turret item/ammo inventory is NOT tracked in the
tick/frame yet) and `last_scaled_power_in` /
`last_scaled_power_out` / `last_power_stored` / `last_capacity`
(the port power graph has NO per-graph last-* snapshot and NO
building->graph lookup in the tick; PowerGraph.update :233-234
`lastScaledPowerIn = (powerProduced + energyDelta) / Time.delta;`
`lastScaledPowerOut = powerNeeded / Time.delta;`, :236
`lastPowerStored = getBatteryStored();`).

GREEN decisions (pinned by this slice): (1) ONE pure function on
SourceTurretBuildState.gd,
source_turret_sense_frame_stamp_state(frame, health,
unit_sense_value), placed right after
source_turret_tick_frame_state (mirroring Java order -- the tick
refreshes frame keys, the stamp is part of that refresh). It
writes exactly the 6 keys above and returns the frame (the N2108
tick-frame precedent: one result symbol, `result.frame`). (2)
ONE tick call site in source_turret_tick_buildings_state, right
after the source_turret_tick_frame_state call: health reads the
sprite meta with the block health as fallback (a building with
no damage record is at full health, not dead --
`source_block_metadata_state.block_health_value(block)`, the same
helper the placement path uses,
SourcePlacedBlockState.gd:82), and `unit_sense_value` is 0.0
(documented: no player controller). (3) The 8 leg functions,
the dispatch, the N2519 proof and N2519 tests are UNTOUCHED.
The SenseI pure functions (N2507/N2510) are UNTOUCHED -- the
composition at the caller is a later slice (no LExecutor
instruction loop exists in the port yet). (4) Shard routing:
the ported method is BuildingComp.sense, so the java_source is
BuildingComp.java and the slice mirrors into the comp shard:
comp 569/472 -> 570/473; defense stays 210/209. SSOT expected
after GREEN: symbols +1, Done +1, contracts +1, schema +2,
11707/1748/1681/3153 -> 11708/1749/1682/3155.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_building_comp_sense_wiring import DEFERRED as N2519_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
UNIT_COMP = 'core/src/mindustry/entities/comp/UnitComp.java'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
POWER_GRAPH = 'core/src/mindustry/world/blocks/power/PowerGraph.java'
PROOF = '/root/C07TurretSenseFrameStampProof'
STAMP_OWNER = 'SourceTurretBuildState.source_turret_sense_frame_stamp_state'
TESTS = ['test_c07_turret_sense_frame_stamp_registration', 'test_all_c07_turret_sense_frame_stamp_input_evidence_is_exact', 'test_turret_sense_frame_stamp_state', 'test_reference_graph_and_actual_c07_turret_sense_frame_stamp']
# The slice sources the N2520 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/entities/comp/UnitComp.java',
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/world/blocks/power/PowerGraph.java',
]
EXACT_EXPRS = [
    'public double sense(LAccess sensor){',
    'return tile.build == self() && !dead();',
    'case health -> health;',
    'case cameraX, cameraY, cameraWidth, cameraHeight -> this instanceof ControlBlock c ? c.unit().sense(sensor) : 0;',
    'case cameraX -> controller instanceof Player player ? World.conv(player.con == null ? Core.camera.position.x : player.con.viewX) : 0;',
    'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
    'if(health <= 0f && !dead()){',
    'dead = true;',
    'public void updateTile(){',
    'case totalItems -> items == null ? 0 : items.total();',
    'case powerNetIn -> power == null ? 0 : power.graph.getLastScaledPowerIn() * 60;',
    'lastScaledPowerIn = (powerProduced + energyDelta) / Time.delta;',
    'lastPowerStored = getBatteryStored();',
]

# DEFERRED is carried from the N2519 register script via import --
# never retyped. No entry is dropped: the stamp completes no
# deferred entry (the 8 N2519 WIRED entries describe the dispatch
# wiring, which stays done). New entries below record the 6
# stamped keys as DONE by this slice and the 6 unstamped keys as
# DEFERRED with their reasons (the scope's verbatim reasons).
DEFERRED = N2519_DEFERRED + [
    'Turret sense frame stamp (`health` / `is_dead` / `tile_build_is_self` / `is_control_block` / `unit_sense_value` frame keys) -- STAMPED by this slice (N2520): `source_turret_sense_frame_stamp_state` writes the 6 keys the tick can supply today into the frame (health from the sprite meta `source_block_health`, `is_dead` as `health <= 0.0` -- the kill trigger `if(health <= 0f && !dead()){`, BuildingComp.java:2170, sets `dead = true;` in killed(), :2243 -- `tile_build_is_self` + `is_control_block` as documented constants, `unit_sense_value` passed in as 0.0 today) and the tick calls it right after `source_turret_tick_frame_state`; the N2519-wired dispatch stops reporting handled:false for the dead / health / camera* legs when a live turret ticks.',
    'Turret sense frame stamp `items_is_null` / `items_total` -- DEFERRED: turret item/ammo inventory is NOT tracked in the tick/frame yet (tick comment: item ammo waits for its own slice); the dispatch keeps handled:false for totalItems until the turret-ammo-inventory slice lands (`case totalItems -> items == null ? 0 : items.total();`, BuildingComp.java:2107).',
    'Turret sense frame stamp `last_scaled_power_in` / `last_scaled_power_out` / `last_power_stored` / `last_capacity` -- DEFERRED: the port power graph has NO per-graph last-* snapshot and NO building->graph lookup in the tick (port has per-tick needed/produced/battery totals via `SourcePlacedPowerGraphState.runtime_state`, but not `lastScaledPowerIn/Out`, `lastCapacity`, `lastPowerStored` per graph); waits for the PowerGraph last-values prerequisite slice (PowerGraph.update :233-234 `lastScaledPowerIn = (powerProduced + energyDelta) / Time.delta;` `lastScaledPowerOut = powerNeeded / Time.delta;`, :236 `lastPowerStored = getBatteryStored();`); the dispatch keeps handled:false for powerNet* until then.',
    'Composing the SenseI LAccess leg (N2510) with the dispatch at the caller -- DEFERRED: waits for a logic-executor driver (no LExecutor instruction loop exists in the port yet); the stamped frame is the input that caller will read.',
    'BuildingComp sense() frame stamp `controlled()` live wiring -- DEFERRED: needs a player unit; when it lands, the tick passes the live player camera value as `unit_sense_value` instead of 0.0.',
    'Turret sense frame stamp Windows Godot proof -- debt in GOAL.md section 5, same as N2283-N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515/N2516/N2517/N2518/N2519: the N2520 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=BUILDING_COMP, **extra):
        return backed(typ, source, expr, rule, **extra)

    stamp_inputs = {
        'frame': a('Dictionary', 'public double sense(LAccess sensor){', 'The turret frame (the port Building state) the tick stamps every tick (`public double sense(LAccess sensor){`, BuildingComp.java:2093-2126 -- the dispatch reads the stamped keys from this frame); the stamp writes the 6 keys in place and returns the frame (the N2108 tick-frame precedent).'),
        'health': a('float', 'case health -> health;', 'The building\'s current live health (`case health -> health;`, BuildingComp.java:2101; `float health;`, HealthComp.java:11): read by the tick from the sprite meta `source_block_health` (SourcePlacedBlockState.gd:45, set at placement :82-86 and decremented by damage), with the block health as fallback when the meta is missing; the stamp writes it as `frame["health"]` and derives `frame["is_dead"]` from it (`health <= 0.0`).'),
        'unit_sense_value': a('float', 'case cameraX -> controller instanceof Player player ? World.conv(player.con == null ? Core.camera.position.x : player.con.viewX) : 0;', 'The proxy unit\'s sense result for the camera* sensor (`c.unit().sense(sensor)`, BuildingComp.java:2122): the already-ported unit sense camera leg (`case cameraX -> controller instanceof Player player ? World.conv(player.con == null ? Core.camera.position.x : player.con.viewX) : 0;`, UnitComp.java:283-286, via `SourceUnitSensorState.laccess_state`) -- 0 when the unit controller is not a Player, else `World.conv` of the player view / core camera value; the tick passes 0.0 today (no player controller attached) and the stamp writes it as `frame["unit_sense_value"]`.', source=UNIT_COMP),
    }
    stamp_outputs = {
        'frame': a('Dictionary', 'public double sense(LAccess sensor){', 'The stamped frame, with the 6 live sense keys set (`health`, `is_dead` as `health <= 0.0`, `tile_build_is_self` true, `is_control_block` true, `unit_sense_value` as passed in) plus every key the frame already carried; the other 6 wiring keys stay absent, so the dispatch keeps handled:false for totalItems / powerNet* exactly as N2519 left them (`public double sense(LAccess sensor){`, BuildingComp.java:2093-2126).'),
    }
    return stamp_inputs, stamp_outputs


def verify():
    """Check every EXACT_EXPRS line and every input/output
    java_expr appears verbatim in its upstream source, without
    touching any SSOT JSON. Exit 0 when all are present."""
    upstream = {}
    for source in SLICE_SOURCES:
        upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
    missing = []
    for expr in EXACT_EXPRS:
        if not any(expr in text for text in upstream.values()):
            missing.append(expr)
    inputs_outputs = definitions()
    total = len(EXACT_EXPRS)
    for keys in inputs_outputs:
        total += len(keys)
        for field, meta in keys.items():
            source = meta['java_source']
            text = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
            if meta['java_expr'] not in text:
                missing.append('%s: %s' % (field, meta['java_expr']))
    if missing:
        for expr in missing:
            print('MISSING: %s' % expr)
        print('%d/%d exprs present' % (total - len(missing), total))
        return 1
    print('%d/%d exprs present' % (total, total))
    return 0


def main():
    symbols = {}
    stamp_inputs, stamp_outputs = definitions()

    entries = [
        ('N2520', STAMP_OWNER, 'source_turret_sense_frame_stamp_state', BUILDING_COMP, 'mindustry.entities.comp.BuildingComp.BuildingComp', 'BuildingComp.sense(LAccess)', stamp_inputs, stamp_outputs, True, 'Dictionary'),
    ]
    all_names = []
    for sid, owner, prefix, source, cls, method, inputs, outputs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                if suffix == 'result':
                    symbol = name + '.' + field
                    names.append(symbol)
                    symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed turret sense frame stamp from BuildingComp.java:2093-2126 + Turret.java:277/490 + UnitComp.java:283-286.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed turret sense frame stamp from BuildingComp.java:2093-2126 + Turret.java:277/490 + UnitComp.java:283-286.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: frame.
    by_slice['N2520'] = [
        'source_turret_sense_frame_stamp_state_result.frame',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2520', dict(status='done', java_source=BUILDING_COMP, java_class='mindustry.entities.comp.BuildingComp.BuildingComp', java_method='BuildingComp.sense(LAccess)', godot_owner=STAMP_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2520'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

    source_symbols.upsert_source_symbols(GODOT, symbols)
    source_symbols.write_source_symbol_audit_report(GODOT)

    manifest = json.loads((GODOT / 'src/generated/source_ssot_modules.json').read_text(encoding='utf-8'))
    modules = manifest['modules']
    new_owners = {definition[1] for definition in entries}
    for name, module in modules.items():
        if module.get('canonical_module') == 'api_contracts':
            selected = source_ssot.build_extension_shard(GODOT, name)[module['root_key']]
            if new_owners.intersection(selected):
                optional = module.setdefault('optional_mirror_fields', [])
                if 'return_type' not in optional:
                    optional.append('return_type')
    source_ssot.write_registered_json(GODOT, 'module_manifest', manifest)
    for canonical in ['slice_ledger', 'api_contracts', 'state_schema', 'registry', 'audit_report', 'module_manifest']:
        for name, module in modules.items():
            if module.get('canonical_module') == canonical:
                source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))


if __name__ == '__main__':
    if '--verify' in sys.argv:
        sys.exit(verify())
    main()
