"""Register the Turret canControl() read (N2530).

TurretBuild.canControl() (Turret.java:376-379):
`public boolean canControl(){` /
`return playerControllable;`,
narrowing the ControlBlock default
(ControlBlock.java:15-17):
`/** @return whether this block can be controlled at all. */` /
`default boolean canControl(){` /
`return true;`.
`playerControllable` is the block field
(`/** If true, this turret can be controlled by players. */` /
`public boolean playerControllable = true;`,
Turret.java:96-97). No per-def override exists in Blocks.java
(grep `playerControllable` = 0 results), so the catalog is
uniformly true today -- but the function still takes the field
as an explicit bool param (the N2526/N2527 param-driven
precedent), it never hardcodes the catalog. NOT
canControlSelect (`public boolean canControlSelect(Unit
player){`, BuildingComp.java:677 -- a different method with a
Unit player param, already stubbed as
source_building_can_control_select_state) and NOT
SourceUnitLifecycleState.player_controllable_state (the
Unit-type level, a different function). NO driver tick call
site: canControl() is a read predicate, not per-tick, and no
caller reads it today (player control / UI is C11).

GREEN decisions (pinned by this slice): (1) One pure
function on SourceTurretBuildState.gd,
source_turret_can_control_state(player_controllable), placed
immediately AFTER source_turret_estimate_dps_state (N2528)
and BEFORE source_turret_can_heal_state. It returns exactly
one key, `can_control`, the bool param passed through. (2) NO
tick call site -- the function is DORMANT live today: the
driver tick never calls it, so live behavior does not change.
(3) `player_controllable` stays an explicit bool param -- the
function never guesses the catalog in the function body.
SSOT expected after GREEN: symbols +1, Done +1, contracts
+1, schemas +2, 11723/1758/1691/3173 -> 11724/1759/1692/3175;
defense shard slices 216 -> 217, contracts 215 -> 216; comp
stays 572/475.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_bullet_type_estimate_dps import DEFERRED as N2529_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
CONTROL_BLOCK = 'core/src/mindustry/world/blocks/ControlBlock.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07TurretCanControlProof'
CAN_CONTROL_OWNER = 'SourceTurretBuildState.source_turret_can_control_state'
TESTS = ['test_c07_turret_can_control_registration', 'test_all_c07_turret_can_control_input_evidence_is_exact', 'test_turret_can_control_state', 'test_reference_graph_and_actual_c07_turret_can_control']
# The slice sources the N2530 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/world/blocks/ControlBlock.java',
    'core/src/mindustry/content/Blocks.java',
]
EXACT_EXPRS = [
    'public boolean canControl(){',
    'return playerControllable;',
    'public boolean playerControllable = true;',
    '/** If true, this turret can be controlled by players. */',
    'default boolean canControl(){',
    '/** @return whether this block can be controlled at all. */',
]

# DEFERRED is carried from the N2529 register script via import --
# never retyped. No entry is dropped: the canControl read the
# N2529 pool entry deferred is recorded DONE below. New entries
# below record the canControl read as DONE by this slice and the
# Windows proof debt.
DEFERRED = N2529_DEFERRED + [
    'Turret canControl() (`can_control` frame key) -- DONE by this slice (N2530): `source_turret_can_control_state` ports Turret.java:376-379 (`return playerControllable;`, field `public boolean playerControllable = true;`, Turret.java:97) narrowing the ControlBlock default (ControlBlock.java:15-17) for the Turret family. NO driver tick call site: canControl() is a read predicate, not per-tick, and no caller reads it today (player control / UI is C11). Dormant live today: the driver tick never calls the function, so live behavior does not change. NOT canControlSelect (BuildingComp.java:677) and NOT the Unit-type player_controllable_state.',
    'Turret canControl() Windows Godot proof -- debt in GOAL.md section 5, same as N2283-N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515/N2516/N2517/N2518/N2519/N2520/N2521/N2522/N2523/N2524/N2525/N2526/N2527/N2528/N2529: the N2530 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    can_control_inputs = {
        'player_controllable': a('bool', 'public boolean playerControllable = true;', 'Whether this turret can be controlled by players (`/** If true, this turret can be controlled by players. */` / `public boolean playerControllable = true;`, Turret.java:96-97 -- the class default; no per-def override in Blocks.java, grep `playerControllable` = 0 results, so the catalog is uniformly true today -- but the function still takes the field as an explicit bool param, never hardcoded, the N2526/N2527 param-driven precedent).'),
    }
    can_control_outputs = {
        'can_control': a('bool', 'public boolean canControl(){', 'Whether this turret can be controlled at all (`public boolean canControl(){` / `return playerControllable;`, Turret.java:376-379 -- the Turret override narrowing the ControlBlock default, `default boolean canControl(){` / `return true;`, ControlBlock.java:15-17).'),
    }
    return can_control_inputs, can_control_outputs


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
    can_control_inputs, can_control_outputs = definitions()

    entries = [
        ('N2530', CAN_CONTROL_OWNER, 'source_turret_can_control_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.canControl()', can_control_inputs, can_control_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret canControl() read from Turret.java:376-379 + Turret.java:96-97 + ControlBlock.java:15-17 + Blocks.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret canControl() read from Turret.java:376-379 + Turret.java:96-97 + ControlBlock.java:15-17 + Blocks.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: can_control.
    by_slice['N2530'] = [
        'source_turret_can_control_state_result.can_control',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2530', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.canControl()', godot_owner=CAN_CONTROL_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2530'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
