"""Register the Turret controlled() frame stamp (N2523).

controlled() is `public boolean controlled(){
return unit.isPlayer(); }` (Turret.java:441-443) on the unit
`public BlockUnitc unit = (BlockUnitc)UnitTypes.block.create(team);`
(:291). It rescues validateTarget (`return
!Units.invalidateTarget(target, canHeal() ? Team.derelict : team,
x, y) || controlled() || logicControlled();`, :631-633, N2251),
picks the player branch of isShooting (`isShooting =
alwaysShooting || (unit.controller() instanceof Player ?
unit.isShooting() : logicControlled() ? logicShooting : target !=
null);`, :492, N2277) and gates the warmup hold
(`if(warmupTarget > 0 && !controlled()){` / `warmupHold = 1f;`,
:503, N2253) -- but the driver validate / isShooting / warmup
calls passed `bool(frame.get("controlled", false))` while
frame["controlled"] was NEVER stamped anywhere, so the three
readers always saw the absent default. This slice ports the
one-line Java method as a pure stamp function on the shared
TurretBuild driver file plus one driver tick in the duo branch
immediately AFTER the N2278 logic_controlled stamp and right
BEFORE the validate call (Java order :491 validate reads it --
the same position rule as N2278); the validate / isShooting /
warmup calls themselves are UNCHANGED and now read a live
value. The tick passes `false` today: the port has NO player
unit -- every turret unit is the BlockUnitc from
UnitTypes.block.create(team) (:291), PortGame.gd carries no
player, and the proxy unit has no player controller attached --
so unit.isPlayer() is false for every live turret (the N2520
unit_sense_value = 0.0 precedent). When player control lands,
the tick passes the live value and this stamp needs no change.
The stamp does NOT invent a player, does NOT touch
source_turret_unit_sync_state (N2260), and does NOT change the
validate / isShooting / warmup call arguments -- their values
are identical on all current frames (absent default false ==
stamped false), so N2251/N2277/N2253 tests need no changes.

GREEN decisions (pinned by this slice): (1) One pure function
on SourceTurretBuildState.gd,
source_turret_controlled_stamp_state(frame, unit_is_player),
placed immediately AFTER source_turret_logic_controlled_state
(mirroring Java order :441-443 controlled before :445-447
logicControlled). It writes exactly ONE key,
`frame["controlled"] = unit_is_player`, and returns the frame
(the N2108 tick-frame precedent: one result symbol,
`result.controlled`). The parameter name is `unit_is_player`
(the existing SSOT/port name -- source_turret_control_state
:1852 and source_turret_is_shooting_state :1321), NOT a new
synonym. (2) ONE tick call site in
source_turret_tick_buildings_state, immediately AFTER the N2278
logic_controlled stamp: `var controlled_state: Dictionary =
source_turret_controlled_stamp_state(frame, false)` then
`frame["controlled"] = controlled_state.get("controlled",
false)`. (3) The `controlled` sense leg is already ported in
the dispatch (`case controlled -> ... ? GlobalVars.ctrlPlayer :
0;`, BuildingComp.java:77, ported at
SourceTurretBuildState.gd:740-742 reading the `is_player`
param) -- this slice does NOT touch the dispatch or any leg
function. (4) No legacy
`source_turret_controlled_stamp_state_result` schema exists, so
the contract validator falls through to the new schema and no
alias is needed. SSOT expected after GREEN: symbols +1, Done
+1, contracts +1, schema +2, 11710/1751/1684/3159 ->
11711/1752/1685/3161; defense shard slices 210 -> 211,
contracts 209 -> 210; comp stays 572/475. (The scope's comp
573/476 expectation is NOT followed: the manifest routes
shards by java_source -- comp selects `/entities/comp/`,
defense selects `/world/blocks/defense/` -- and the ported
method is TurretBuild.controlled() in Turret.java, so the
N2278 precedent (Turret.java -> defense) applies, not the
N2522 one (BuildingComp.java -> comp).)
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_power_graph_last_values_stamp import DEFERRED as N2522_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
PROOF = '/root/C07TurretControlledStampProof'
CONTROLLED_STAMP_OWNER = 'SourceTurretBuildState.source_turret_controlled_stamp_state'
TESTS = ['test_c07_turret_controlled_stamp_registration', 'test_all_c07_turret_controlled_stamp_input_evidence_is_exact', 'test_turret_controlled_stamp_state', 'test_reference_graph_and_actual_c07_turret_controlled_stamp']
# The slice sources the N2523 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
]
EXACT_EXPRS = [
    'public boolean controlled(){',
    'return unit.isPlayer();',
    'public BlockUnitc unit = (BlockUnitc)UnitTypes.block.create(team);',
    'if(!validateTarget()) target = null;',
    'return !Units.invalidateTarget(target, canHeal() ? Team.derelict : team, x, y) || controlled() || logicControlled();',
    'isShooting = alwaysShooting || (unit.controller() instanceof Player ? unit.isShooting() : logicControlled() ? logicShooting : target != null);',
    'if(warmupTarget > 0 && !controlled()){',
]

# DEFERRED is carried from the N2522 register script via import --
# never retyped. No entry is dropped: the stamp completes no
# deferred entry except the `controlled` frame key (recorded
# STAMPED below). New entries below record the key as DONE by
# this slice and the still-open work with its reasons (the
# scope's verbatim reasons).
DEFERRED = N2522_DEFERRED + [
    'Turret controlled() frame stamp (`controlled` frame key) -- STAMPED by this slice (N2523): `source_turret_controlled_stamp_state` writes `frame["controlled"] = unit_is_player` and the tick calls it right after `source_turret_logic_controlled_state` and right before the validateTarget call (Java order :491 validate reads it), so the validate / isShooting / warmup readers stop reading the never-stamped absent default. The tick passes `false` today -- the port has NO player unit (every turret unit is the BlockUnitc from `UnitTypes.block.create(team)`, Turret.java:291; PortGame.gd carries no player; the proxy unit has no player controller attached), so `unit.isPlayer()` is false for every live turret; when player control lands, the tick passes the live value and this stamp needs no change.',
    'Live player-unit source for `unit_is_player` (and for `unit_sense_value`, N2520) -- DEFERRED (still, after N2523): when player control lands, the tick passes the live value instead of `false` / `0.0`.',
    'Turret controlled() stamp Windows Godot proof -- debt in GOAL.md section 5, same as N2283-N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515/N2516/N2517/N2518/N2519/N2520/N2521/N2522: the N2523 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    controlled_stamp_inputs = {
        'frame': a('Dictionary', 'public void updateTile(){', 'The turret frame (the port Building state) the tick stamps every tick (`public void updateTile(){`, Turret.java:490 -- the driver tick for every Turret-family build); the stamp writes the `controlled` key in place and returns the frame (the N2108 tick-frame precedent).'),
        'unit_is_player': a('bool', 'return unit.isPlayer();', 'Whether the turret\'s own unit is player-controlled (`return unit.isPlayer();`, Turret.java:441-443, on `public BlockUnitc unit = (BlockUnitc)UnitTypes.block.create(team);`, :291); the tick passes `false` today -- the port has NO player unit, so every live turret reads false (the N2520 `unit_sense_value = 0.0` precedent) -- and passes the live value when player control lands.'),
    }
    controlled_stamp_outputs = {
        'controlled': a('bool', 'return unit.isPlayer();', 'Whether the turret is player-controlled (`public boolean controlled(){` / `return unit.isPlayer();`, Turret.java:441-443 -- rescues validateTarget :631-633, picks the player branch of isShooting :492, and gates the warmup hold :503; the three driver readers now read this stamped key instead of the never-stamped absent default).'),
    }
    return controlled_stamp_inputs, controlled_stamp_outputs


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
    controlled_stamp_inputs, controlled_stamp_outputs = definitions()

    entries = [
        ('N2523', CONTROLLED_STAMP_OWNER, 'source_turret_controlled_stamp_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.controlled()', controlled_stamp_inputs, controlled_stamp_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret controlled() frame stamp from Turret.java:441-443 + :490-503 + :631-633.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret controlled() frame stamp from Turret.java:441-443 + :490-503 + :631-633.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: controlled.
    by_slice['N2523'] = [
        'source_turret_controlled_stamp_state_result.controlled',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2523', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.controlled()', godot_owner=CONTROLLED_STAMP_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2523'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
