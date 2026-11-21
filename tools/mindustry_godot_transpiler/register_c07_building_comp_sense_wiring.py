"""Register the BuildingComp.sense() wiring: connect the 8 ported legs into the dispatch (N2519).

BuildingComp.sense() is `public double sense(LAccess sensor){`
(BuildingComp.java:2093-2126). N2284 ported the dispatch
`source_building_comp_sense_state` with 23 handled legs and left
dead / health / totalItems / camera* / powerNet* deferred
(handled:false + NaN). N2511 ported `dead`, N2512 `health`, N2513
`totalItems`, N2514 `powerNetIn`, N2515 `powerNetOut`, N2516
`powerNetStored`, N2517 `powerNetCapacity`, N2518 camera* -- each
as its own pure function living beside the dispatch. This slice
wires all eight legs into the dispatch: the signature is UNCHANGED
(24 params stay 24, the N2235 precedent -- the dispatch already
mixes frame keys with explicit params, and every existing caller
calls it with 24 positional args), and the leg inputs arrive as
11 frame keys (`tile_build_is_self`, `is_dead`, `health`,
`items_is_null`, `items_total`, `last_scaled_power_in`,
`last_scaled_power_out`, `last_power_stored`, `last_capacity`,
`is_control_block`, `unit_sense_value` -- plus the existing
`has_power` param as `power_is_null = not has_power`). An absent
key keeps the OLD behavior exactly (handled:false + NaN, the N2284
deferred state); presence is checked with `frame.has(key)`, NOT
with a default value, so a present key carrying 0 / false is live
input, not absence. A present key delegates to the leg function
and returns its result VERBATIM (same 3-key wire shape; the
dispatch never re-derives the value -- the leg function IS the
Java case). Branch placement mirrors Java switch order: dead after
`color` (before `solid`); health after `team` (before
`maxHealth`); totalItems after `rotation` (before
`totalLiquids`); powerNet* replaces the `has_power == true`
fallthrough inside the existing powerNet branch (the
`has_power == false` -> 0.0 fold stays FIRST and unchanged);
camera* after `size` (before the final default return).

GREEN decisions (pinned by this slice): (1) No new pure function
is added, so no new result symbols exist: this slice re-registers
the three dispatch result symbols (handled, sense_value,
sense_value_is_nan -- the N2283/N2284 sense wire shape, first
registered by N2284) under its own tests + proof, keeping their
java_source / java_expr / godot_owner identical so the N2284
registration + evidence tests stay green untouched. The ledger
entry lists those three symbols. (2) The dispatch contract (same
owner key, so the catalog count is unchanged -- the contract is
re-pointed at N2519 with the same 24 params, not duplicated) and
the dispatch input schema (same schema name, same 24 keys -- the
`frame` key rule now documents the 12 wiring keys, the `sensor`
key rule now says all 30 sensors resolve when their live input is
present) are patched in place, not replaced. (3) There is NO
driver tick line: wiring the dispatch is a pure composition step
(the N2206/N2208/N2223/N2283/N2284/N2506-N2518 precedent); the
proof calls the dispatch directly with synthetic frames, and
stamping the 12 live values into the frame from a live tick, and
wiring the dispatch into a live logic-executor driver tick (logic
executor not yet in driver), remain separate later slices.
(4) Shard routing: the ported method is BuildingComp.sense, so
the java_source is BuildingComp.java and the slice mirrors into
the comp shard: comp slices 568 -> 569; comp contracts stay 472
(the dispatch contract already lived there under N2284 -- this
slice re-points it, it does not add a second contract for the
same owner). Defense stays 210/209. SSOT expected after GREEN:
symbols +0, Done +1, contracts +0, schema +0, 11707/1747/1681/3153
-> 11707/1748/1681/3153.
"""
import copy
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_building_comp_sense_camera import DEFERRED as N2518_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
UNIT_COMP = 'core/src/mindustry/entities/comp/UnitComp.java'
LACCESS = 'core/src/mindustry/logic/LAccess.java'
POWER_GRAPH = 'core/src/mindustry/world/blocks/power/PowerGraph.java'
PROOF = '/root/C07BuildingCompSenseWiringProof'
DISPATCH_OWNER = 'SourceTurretBuildState.source_building_comp_sense_state'
TESTS = ['test_c07_building_comp_sense_wiring_registration', 'test_all_c07_building_comp_sense_wiring_input_evidence_is_exact', 'test_building_comp_sense_wiring_state', 'test_reference_graph_and_actual_c07_building_comp_sense_wiring']
# The slice sources the N2519 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/entities/comp/UnitComp.java',
    'core/src/mindustry/logic/LAccess.java',
    'core/src/mindustry/world/blocks/power/PowerGraph.java',
]
EXACT_EXPRS = [
    'public double sense(LAccess sensor){',
    'case dead -> !isValid() ? 1 : 0;',
    'case health -> health;',
    'case totalItems -> items == null ? 0 : items.total();',
    'case powerNetIn -> power == null ? 0 : power.graph.getLastScaledPowerIn() * 60;',
    'case powerNetOut -> power == null ? 0 : power.graph.getLastScaledPowerOut() * 60;',
    'case powerNetStored -> power == null ? 0 : power.graph.getLastPowerStored();',
    'case powerNetCapacity -> power == null ? 0 : power.graph.getLastCapacity();',
    'case cameraX, cameraY, cameraWidth, cameraHeight -> this instanceof ControlBlock c ? c.unit().sense(sensor) : 0;',
    'default -> Float.NaN; //gets converted to null in logic',
    'return tile.build == self() && !dead();',
    'case cameraX -> controller instanceof Player player ? World.conv(player.con == null ? Core.camera.position.x : player.con.viewX) : 0;',
]

# DEFERRED is carried from the N2518 register script via import --
# never retyped. The eight "stays handled:false in
# `source_building_comp_sense_state` until a later wiring slice
# connects this leg" entries (exactly 8 in the whole pool --
# dead, health, totalItems, powerNetIn, powerNetOut,
# powerNetStored, powerNetCapacity, camera*) are dropped here --
# the wiring is DONE by this slice (N2519). Every other entry is
# carried verbatim (the N2211/N2228 lesson -- never retype the
# pool).
DEFERRED = [e for e in N2518_DEFERRED if 'handled:false' not in e] + [
    'BuildingComp sense() dead leg (`case dead -> !isValid() ? 1 : 0;`, BuildingComp.java:2098) -- WIRED by this slice (N2519): the dispatch reads the `tile_build_is_self` + `is_dead` frame keys when present (`return tile.build == self() && !dead();`, :2031, the two `isValid()` conjuncts) and delegates to `source_building_comp_sense_dead_state`, returning its result verbatim (1.0 when not valid, 0.0 when valid); absent keys keep the N2284 fallback handled:false + NaN.',
    'BuildingComp sense() health leg (`case health -> health;`, BuildingComp.java:2101) -- WIRED by this slice (N2519): the dispatch reads the `health` frame key when present (`float health;`, HealthComp.java:11) and delegates to `source_building_comp_sense_health_state`, returning its result verbatim; absent key keeps the N2284 fallback handled:false + NaN.',
    'BuildingComp sense() totalItems leg (`case totalItems -> items == null ? 0 : items.total();`, BuildingComp.java:2107) -- WIRED by this slice (N2519): the dispatch reads the `items_is_null` + `items_total` frame keys when present (`@Nullable ItemModule items;`, BuildingComp.java:81; `public int total(){`, ItemModule.java:174) and delegates to `source_building_comp_sense_total_items_state`, returning its result verbatim (0.0 when items is null, else `float(items_total)`); absent keys keep the N2284 fallback handled:false + NaN.',
    'BuildingComp sense() powerNetIn leg (`case powerNetIn -> power == null ? 0 : power.graph.getLastScaledPowerIn() * 60;`, BuildingComp.java:2114) -- WIRED by this slice (N2519): the dispatch keeps the `has_power == false` -> 0.0 fold first and, when `has_power` is true, reads the `last_scaled_power_in` frame key when present (`public float getLastScaledPowerIn(){`, PowerGraph.java:45-47) and delegates to `source_building_comp_sense_power_net_in_state` with `power_is_null = not has_power`, returning its result verbatim (`last_scaled_power_in * 60.0`); absent key keeps the N2284 fallback handled:false + NaN.',
    'BuildingComp sense() powerNetOut leg (`case powerNetOut -> power == null ? 0 : power.graph.getLastScaledPowerOut() * 60;`, BuildingComp.java:2115) -- WIRED by this slice (N2519): the dispatch keeps the `has_power == false` -> 0.0 fold first and, when `has_power` is true, reads the `last_scaled_power_out` frame key when present (`public float getLastScaledPowerOut(){`, PowerGraph.java:49-51) and delegates to `source_building_comp_sense_power_net_out_state` with `power_is_null = not has_power`, returning its result verbatim (`last_scaled_power_out * 60.0`); absent key keeps the N2284 fallback handled:false + NaN.',
    'BuildingComp sense() powerNetStored leg (`case powerNetStored -> power == null ? 0 : power.graph.getLastPowerStored();`, BuildingComp.java:2116) -- WIRED by this slice (N2519): the dispatch keeps the `has_power == false` -> 0.0 fold first and, when `has_power` is true, reads the `last_power_stored` frame key when present (`public float getLastPowerStored(){`, PowerGraph.java:73-75) and delegates to `source_building_comp_sense_power_net_stored_state` with `power_is_null = not has_power`, returning its result verbatim (NO `* 60` -- an absolute amount, battery charge); absent key keeps the N2284 fallback handled:false + NaN.',
    'BuildingComp sense() powerNetCapacity leg (`case powerNetCapacity -> power == null ? 0 : power.graph.getLastCapacity();`, BuildingComp.java:2117) -- WIRED by this slice (N2519): the dispatch keeps the `has_power == false` -> 0.0 fold first and, when `has_power` is true, reads the `last_capacity` frame key when present (`public float getLastCapacity(){`, PowerGraph.java:53-54) and delegates to `source_building_comp_sense_power_net_capacity_state` with `power_is_null = not has_power`, returning its result verbatim (NO `* 60` -- an absolute amount, total battery capacity); absent key keeps the N2284 fallback handled:false + NaN.',
    'BuildingComp sense() cameraX/cameraY/cameraWidth/cameraHeight legs (`case cameraX, cameraY, cameraWidth, cameraHeight -> this instanceof ControlBlock c ? c.unit().sense(sensor) : 0;`, BuildingComp.java:2122) -- WIRED by this slice (N2519): the dispatch reads the `is_control_block` + `unit_sense_value` frame keys when present and delegates to `source_building_comp_sense_camera_state`, passing `sensor` through (the sensor-specific selection already happened inside the unit sense call, `case cameraX -> controller instanceof Player player ? World.conv(player.con == null ? Core.camera.position.x : player.con.viewX) : 0;`, UnitComp.java:283-286), returning its result verbatim (0.0 when not a control block, else `unit_sense_value`); absent keys keep the N2284 fallback handled:false + NaN.',
    'BuildingComp sense() wiring Windows Godot proof -- debt in GOAL.md section 5, same as N2283-N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515/N2516/N2517/N2518: the N2519 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=BUILDING_COMP, **extra):
        return backed(typ, source, expr, rule, **extra)

    # The 11 frame keys the wiring reads (N2235 precedent --
    # frame keys are documented on the dispatch `frame` input,
    # not as new explicit params, so the 24-param signature
    # stays unchanged). Each key's java_expr is the Java case
    # line it feeds.
    wiring_inputs = {
        'tile_build_is_self': a('bool', 'return tile.build == self() && !dead();', 'Whether `tile.build == self()` (`return tile.build == self() && !dead();`, BuildingComp.java:2031, first conjunct of `isValid()`): the `dead` leg reads it from the frame (`frame.has("tile_build_is_self")`) only when present with `is_dead`; absent key keeps the N2284 handled:false fallback.'),
        'is_dead': a('bool', 'return tile.build == self() && !dead();', 'Whether `dead()` (`return tile.build == self() && !dead();`, BuildingComp.java:2031, second conjunct of `isValid()`, negated): the `dead` leg reads it from the frame (`frame.has("is_dead")`) only when present with `tile_build_is_self`; absent key keeps the N2284 handled:false fallback.'),
        'health': a('float', 'case health -> health;', 'The building\'s current health (`case health -> health;`, BuildingComp.java:2101; `float health;`, HealthComp.java:11): the `health` leg reads it from the frame (`frame.has("health")`) only when present; absent key keeps the N2284 handled:false fallback.'),
        'items_is_null': a('bool', 'case totalItems -> items == null ? 0 : items.total();', 'Whether `items == null` (`case totalItems -> items == null ? 0 : items.total();`, BuildingComp.java:2107, first branch of the ternary; `@Nullable ItemModule items;`, BuildingComp.java:81): the `totalItems` leg reads it from the frame only when present with `items_total`; absent key keeps the N2284 handled:false fallback.'),
        'items_total': a('int', 'case totalItems -> items == null ? 0 : items.total();', 'The `items.total()` count (`case totalItems -> items == null ? 0 : items.total();`, BuildingComp.java:2107; `public int total(){`, ItemModule.java:174 -- returns int): the `totalItems` leg reads it from the frame (cast to int) only when present with `items_is_null`; absent key keeps the N2284 handled:false fallback.'),
        'last_scaled_power_in': a('float', 'case powerNetIn -> power == null ? 0 : power.graph.getLastScaledPowerIn() * 60;', 'The graph\'s last scaled power-in per tick (`case powerNetIn -> power == null ? 0 : power.graph.getLastScaledPowerIn() * 60;`, BuildingComp.java:2114; `public float getLastScaledPowerIn(){`, PowerGraph.java:45-47): the `powerNetIn` leg reads it from the frame (`frame.has("last_scaled_power_in")`) only when present and `has_power` is true; absent key keeps the N2284 handled:false fallback.'),
        'last_scaled_power_out': a('float', 'case powerNetOut -> power == null ? 0 : power.graph.getLastScaledPowerOut() * 60;', 'The graph\'s last scaled power-out per tick (`case powerNetOut -> power == null ? 0 : power.graph.getLastScaledPowerOut() * 60;`, BuildingComp.java:2115; `public float getLastScaledPowerOut(){`, PowerGraph.java:49-51): the `powerNetOut` leg reads it from the frame only when present and `has_power` is true; absent key keeps the N2284 handled:false fallback.'),
        'last_power_stored': a('float', 'case powerNetStored -> power == null ? 0 : power.graph.getLastPowerStored();', 'The graph\'s last stored battery power (`case powerNetStored -> power == null ? 0 : power.graph.getLastPowerStored();`, BuildingComp.java:2116; `public float getLastPowerStored(){`, PowerGraph.java:73-75): the `powerNetStored` leg reads it from the frame only when present and `has_power` is true; absent key keeps the N2284 handled:false fallback.'),
        'last_capacity': a('float', 'case powerNetCapacity -> power == null ? 0 : power.graph.getLastCapacity();', 'The graph\'s last total battery capacity (`case powerNetCapacity -> power == null ? 0 : power.graph.getLastCapacity();`, BuildingComp.java:2117; `public float getLastCapacity(){`, PowerGraph.java:53-54): the `powerNetCapacity` leg reads it from the frame only when present and `has_power` is true; absent key keeps the N2284 handled:false fallback.'),
        'is_control_block': a('bool', 'case cameraX, cameraY, cameraWidth, cameraHeight -> this instanceof ControlBlock c ? c.unit().sense(sensor) : 0;', 'Whether `this instanceof ControlBlock` (`case cameraX, cameraY, cameraWidth, cameraHeight -> this instanceof ControlBlock c ? c.unit().sense(sensor) : 0;`, BuildingComp.java:2122, the gate of the ternary): the camera* legs read it from the frame only when present with `unit_sense_value`; absent key keeps the N2284 handled:false fallback.'),
        'unit_sense_value': a('float', 'case cameraX -> controller instanceof Player player ? World.conv(player.con == null ? Core.camera.position.x : player.con.viewX) : 0;', 'The proxy unit\'s sense result for this sensor (`c.unit().sense(sensor)`, BuildingComp.java:2122): the already-ported unit sense camera leg (`case cameraX -> controller instanceof Player player ? World.conv(player.con == null ? Core.camera.position.x : player.con.viewX) : 0;`, UnitComp.java:283-286, via `SourceUnitSensorState.laccess_state`) -- the camera* legs read it from the frame only when present with `is_control_block`; absent key keeps the N2284 handled:false fallback.', source=UNIT_COMP),
    }
    # The dispatch result symbols keep N2284's java_expr values
    # verbatim (so the N2284 registration + evidence tests stay
    # green untouched); only the rule / tests / proof move to
    # N2519. The result is the N2283/N2284 sense wire shape:
    # handled + sense_value + sense_value_is_nan.
    wiring_outputs = {
        'handled': a('bool', 'default -> Float.NaN; //gets converted to null in logic', 'Whether the wired dispatch resolved the sensor to a logic-variable write: true when the sensor is one of the 30 sense() cases and its live input is present (the 8 wired legs delegate to their leg function and return its result verbatim), false when a wired leg\'s frame key is absent or the sensor is unknown (`default -> Float.NaN; //gets converted to null in logic`, BuildingComp.java:2123).'),
        'sense_value': a('Variant', 'case x -> World.conv(x);', 'The numeric value written to the logic variable: the leg function\'s result verbatim for a wired leg (dead / health / totalItems / powerNet* / camera*), else the dispatch\'s own case value (`case x -> World.conv(x);`, BuildingComp.java:2094, first case of the switch); null when handled is false.'),
        'sense_value_is_nan': a('bool', 'default -> Float.NaN; //gets converted to null in logic', 'Whether Java returns Float.NaN for this sensor (`default -> Float.NaN; //gets converted to null in logic`, BuildingComp.java:2123); true exactly when handled is false (absent frame key for a wired leg, or unknown sensor), false otherwise.'),
    }
    return wiring_inputs, wiring_outputs


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
    wiring_inputs, wiring_outputs = definitions()

    # The dispatch result symbols are re-registered under
    # N2519's tests + proof (same java_source / java_expr /
    # godot_owner as N2284 -- the symbol count stays +0).
    # The 12 wiring frame keys are NOT upserted as a new
    # input schema: the dispatch input schema already exists
    # with its 24 params, and the contract params reference
    # `source_building_comp_sense_state_input.<param>` -- the
    # frame keys are documented on the existing `frame` input
    # below (the N2235 frame-key precedent), patched in
    # place instead of replaced.
    for field, meta in wiring_outputs.items():
        meta['used_by'] = [DISPATCH_OWNER]
        symbol = 'source_building_comp_sense_state_result.' + field
        symbols[symbol] = dict(status='source-backed', godot_owner=DISPATCH_OWNER, godot_symbol=symbol, java_source=meta['java_source'], java_method='BuildingComp.sense(LAccess)', java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)

    # Result schema: same 3 keys, re-pointed at N2519.
    source_symbols.upsert_source_state_schema(GODOT, 'source_building_comp_sense_state_result', dict(status='active', owner=DISPATCH_OWNER, source_slice='N2519', keys=wiring_outputs, runtime_proof=PROOF, rule='Source-backed BuildingComp super.sense() LAccess delegation from BuildingComp.java:2093-2126 + Turret.java + BaseTurret.java + ItemTurret.java + Blocks.java + Block.java + World.java + Vars.java + LAccess.java + Team.java + GlobalVars.java + Pal.java + arc Color.java. N2519 wires the eight already-ported legs (dead / health / totalItems / powerNetIn / powerNetOut / powerNetStored / powerNetCapacity / camera*) into the dispatch via 11 frame keys.'))

    # Input schema: patched in place -- same 24 keys; the
    # `frame` rule now documents the 12 wiring keys and the
    # `sensor` rule now says all 30 sensors resolve when
    # their live input is present.
    schema = source_symbols.load_source_state_schema(GODOT)
    input_entry = copy.deepcopy(schema['schemas']['source_building_comp_sense_state_input'])
    frame_rule = input_entry['keys']['frame']['rule']
    frame_rule += ' The N2519 wiring keys are read only when present (`frame.has(key)`): `tile_build_is_self` + `is_dead` (dead, `return tile.build == self() && !dead();`, BuildingComp.java:2031), `health` (health, `float health;`, HealthComp.java:11), `items_is_null` + `items_total` (totalItems, `items.total()`, ItemModule.java:174), `last_scaled_power_in` (powerNetIn, PowerGraph.java:45-47), `last_scaled_power_out` (powerNetOut, :49-51), `last_power_stored` (powerNetStored, :73-75), `last_capacity` (powerNetCapacity, :53-54), `is_control_block` + `unit_sense_value` (camera*, UnitComp.java:283-286); an absent key keeps the N2284 handled:false + NaN fallback.'
    input_entry['keys']['frame']['rule'] = frame_rule
    input_entry['keys']['sensor']['rule'] = input_entry['keys']['sensor']['rule'].replace('the 23 implemented sensors are handled here, the 7 deferred legs report handled=false.', 'all 30 sensors are handled here when their live input is present; the 8 wired legs (dead / health / totalItems / powerNetIn / powerNetOut / powerNetStored / powerNetCapacity / camera*, N2511-N2519) report handled=false only when their frame key is absent.')
    input_entry['source_slice'] = 'N2519'
    input_entry['runtime_proof'] = PROOF
    input_entry['rule'] = input_entry['rule'] + ' N2519 wires the eight already-ported legs (dead / health / totalItems / powerNetIn / powerNetOut / powerNetStored / powerNetCapacity / camera*) into the dispatch via 11 frame keys.'
    source_symbols.upsert_source_state_schema(GODOT, 'source_building_comp_sense_state_input', input_entry)

    # Contract: same owner key, same 24 params -- re-pointed
    # at N2519 (the catalog count stays +0; a second contract
    # for the same owner would be a duplicate).
    contracts = source_symbols.load_source_api_contracts(GODOT)
    contract = copy.deepcopy(contracts['contracts'][DISPATCH_OWNER])
    contract['source_slice'] = 'N2519'
    contract['tests'] = TESTS
    contract['runtime_proof'] = PROOF
    contract['rule'] = contract['rule'] + ' N2519 wires the eight already-ported legs (dead / health / totalItems / powerNetIn / powerNetOut / powerNetStored / powerNetCapacity / camera*) into the dispatch via 11 frame keys; the signature is unchanged (24 params).'
    source_symbols.upsert_source_api_contract(GODOT, DISPATCH_OWNER, contract)

    # The test pins this order: handled, sense_value, sense_value_is_nan.
    by_slice = {
        'N2519': [
            'source_building_comp_sense_state_result.handled',
            'source_building_comp_sense_state_result.sense_value',
            'source_building_comp_sense_state_result.sense_value_is_nan',
        ],
    }
    source_symbols.upsert_source_slice(GODOT, 'N2519', dict(status='done', java_source=BUILDING_COMP, java_class='mindustry.entities.comp.BuildingComp.BuildingComp', java_method='BuildingComp.sense(LAccess)', godot_owner=DISPATCH_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2519'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

    source_symbols.upsert_source_symbols(GODOT, symbols)
    source_symbols.write_source_symbol_audit_report(GODOT)

    manifest = json.loads((GODOT / 'src/generated/source_ssot_modules.json').read_text(encoding='utf-8'))
    modules = manifest['modules']
    new_owners = {DISPATCH_OWNER}
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
