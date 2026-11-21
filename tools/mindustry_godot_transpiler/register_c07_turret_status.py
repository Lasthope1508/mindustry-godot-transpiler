"""Register the Turret status() read (N2527).

TurretBuild.status() (Turret.java:369-372):
`public BlockStatus status(){` /
`if(enabled && !hasAmmo()) return BlockStatus.noInput;` /
`return super.status();`,
with super.status() the BuildingComp chain
(BuildingComp.java:632-646):
`if(!enabled){` / `return BlockStatus.logicDisable;` /
`if(!shouldConsume()){` / `return BlockStatus.noOutput;` /
`if(efficiency <= 0 || !productionValid()){` /
`return BlockStatus.noInput;` /
`return ((state.tick / 30f) % 1f) < efficiency ?
BlockStatus.active : BlockStatus.noInput;`.
The Turret leg runs BEFORE super -- order matters: a
turret with ammo falls through to super, a turret
without ammo reports noInput even when enabled. The
shouldConsume leg reuses
`source_turret_should_consume_state(frame, reload)`
(N2524, Turret.java:364-366, `return isShooting ||
reloadCounter < reload;` -- `reload` is the per-def
reload time, `public float reload = 10f;`,
ReloadTurret.java:10, read from the catalog
`block.properties` with the 10.0 default, the tick
:2665 precedent -- NOT hardcoded to duo).
`has_ammo` is a bool param, NOT computed in the
function: hasAmmo() MUTATES the ammo stack
(`ammo.swap(ammo.size - 1, i);`, Turret.java:703), so
it cannot be a pure read; the boolean equivalent (no
swap) is `canConsume() && size > 0 && (any entry
amount >= ammoPerShot || cheating())` -- the swap only
moves a sufficient entry to peek, it never changes the
boolean. canConsume() live is `potentialEfficiency > 0`
(BuildingComp.java:1917-1919) through the heat gate
(Turret.java:624-629, ported as
source_turret_can_consume_heat_gate_state; the
heatRequirement default is -1f, Turret.java:53, only
afflict 20f / malign 144f are positive,
Blocks.java:5122/:6240). ammoPerShot is 1 by default
(Turret.java:49) with per-def overrides (ripple 2,
foreshadow 5, spectre 2, diffuse 3, titan 4, smite 15,
malign 2, Blocks.java). The live hasAmmo computation
(stacks + canConsume + ammoPerShot) is a follow-up --
this slice ports super.status() + the Turret leg with
the param. productionValid() is the canonical true
default (BuildingComp.java:759-761, `return true;` --
no override in world/blocks/defense/turrets/ or
world/blocks/defense/). The tick arrives as an
explicit float param, not from the frame (the
RepairTurret precedent). NO driver tick call site:
status() is a read function, not per-tick, and no
caller reads it today (UI/status display is C11).

GREEN decisions (pinned by this slice): (1) One pure
function on SourceTurretBuildState.gd,
source_turret_status_state(frame, tick, has_ammo,
reload), placed immediately AFTER
source_turret_range_state (N2526) and BEFORE
source_turret_can_heal_state. It returns exactly one
key, `status`, one of the SourceBuildingAccessState
constants ("logicDisable" / "noOutput" / "noInput" /
"active"). (2) NO tick call site -- the function is
DORMANT live today: the driver tick never calls it, so
live behavior does not change. (3) `has_ammo` stays a
bool param -- the function never computes hasAmmo()
itself, because hasAmmo() mutates the ammo stack.
SSOT expected after GREEN: symbols +1, Done +1,
contracts +1, schema +1, 11718/1755/1688/3167 ->
11719/1756/1689/3168; defense shard slices 214 -> 215,
contracts 213 -> 214; comp stays 572/475.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_range import DEFERRED as N2526_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
RELOAD_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07TurretStatusProof'
STATUS_OWNER = 'SourceTurretBuildState.source_turret_status_state'
TESTS = ['test_c07_turret_status_registration', 'test_all_c07_turret_status_input_evidence_is_exact', 'test_turret_status_state', 'test_reference_graph_and_actual_c07_turret_status']
# The slice sources the N2527 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
    'core/src/mindustry/content/Blocks.java',
]
EXACT_EXPRS = [
    'if(enabled && !hasAmmo()) return BlockStatus.noInput;',
    'return super.status();',
    'if(!enabled){',
    'return BlockStatus.logicDisable;',
    'if(!shouldConsume()){',
    'return BlockStatus.noOutput;',
    'if(efficiency <= 0 || !productionValid()){',
    'return BlockStatus.noInput;',
    'return ((state.tick / 30f) % 1f) < efficiency ? BlockStatus.active : BlockStatus.noInput;',
    'return isShooting || reloadCounter < reload;',
    'public float reload = 10f;',
]

# DEFERRED is carried from the N2526 register script via import --
# never retyped. No entry is dropped: the status read the
# N2526 pool entry deferred is recorded DONE below. New entries
# below record the status read as DONE by this slice, the
# Windows proof debt, and the live hasAmmo computation + the
# C11 status consumers that still need wiring.
DEFERRED = N2526_DEFERRED + [
    'Turret status() (`status` frame key) -- DONE by this slice (N2527): `source_turret_status_state` ports Turret.java:369-372 + BuildingComp.java:632-646 for the Turret family (Turret leg `enabled && !hasAmmo()` -> noInput BEFORE super; super legs logicDisable / noOutput via `source_turret_should_consume_state(frame, reload)` (N2524) / noInput on `efficiency <= 0 || !productionValid()` / active on `fmod(tick / 30.0, 1.0) < efficiency`), mirroring `source_repair_turret_status_state` (N2221). NO driver tick call site: status() is a read function, not per-tick, and no caller reads it today (UI/status display is C11). Dormant live today: the driver tick never calls the function, so live behavior does not change.',
    'Turret status() Windows Godot proof -- debt in GOAL.md section 5, same as N2283-N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515/N2516/N2517/N2518/N2519/N2520/N2521/N2522/N2523/N2524/N2525/N2526: the N2527 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Turret live hasAmmo() computation still DEFERRED (after N2527): `source_turret_status_state` takes `has_ammo` as a bool param because hasAmmo() MUTATES the ammo stack (`ammo.swap(ammo.size - 1, i);`, Turret.java:703) and cannot be a pure read; the live computation (boolean equivalent without the swap: `canConsume() && size > 0 && (any entry amount >= ammoPerShot || cheating())`, with canConsume() live = `potentialEfficiency > 0` through the heat gate, Turret.java:624-629, and ammoPerShot per-def: default 1, Turret.java:49; ripple 2, foreshadow 5, spectre 2, diffuse 3, titan 4, smite 15, malign 2, Blocks.java) waits for a caller slice that reads the tick ammo stacks (`source_turret_use_ammo_state` takes `stacks: Array`) and stamps the result. The C11 status display that reads `status` is also a later slice.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    status_inputs = {
        'frame': a('Dictionary', 'public void updateTile(){', 'The turret frame (the port Building state) the tick stamps every tick (`public void updateTile(){`, Turret.java:490 -- the driver tick for every Turret-family build); it carries `enabled` (stamped by the tick, `frame["enabled"] = bool(frame.get("enabled", true))`), `is_shooting` / `reload_counter` (the N2524 shouldConsume leg) and the folded `efficiency` (stamped every tick by the driver via apply_update_consumption_state; absent folds to 1.0, the N2174 missing-stamp precedent).', source=TURRET),
        'tick': a('float', 'return ((state.tick / 30f) % 1f) < efficiency ? BlockStatus.active : BlockStatus.noInput;', 'The global tick (`state.tick`, BuildingComp.java:645 -- `((state.tick / 30f) % 1f) < efficiency`); it arrives as an explicit float param, not from the frame (the RepairTurret precedent -- the driver stamps no tick key).', source=BUILDING_COMP),
        'has_ammo': a('bool', 'if(enabled && !hasAmmo()) return BlockStatus.noInput;', 'Whether the turret has ammo (`if(enabled && !hasAmmo()) return BlockStatus.noInput;`, Turret.java:370 -- the Turret leg, BEFORE super); a bool param, NOT computed in the function, because hasAmmo() MUTATES the ammo stack (`ammo.swap(ammo.size - 1, i);`, Turret.java:703) and cannot be a pure read. The boolean equivalent (no swap) is `canConsume() && size > 0 && (any entry amount >= ammoPerShot || cheating())` -- the swap only moves a sufficient entry to peek, it never changes the boolean; the live computation is a follow-up.'),
        'reload': a('float', 'public float reload = 10f;', 'The per-def reload time in ticks (`public float reload = 10f;`, ReloadTurret.java:10 -- the class default; duo 20f, scatter 18f, salvo 29f, foreshadow 200f, Blocks.java): the shouldConsume leg half (`return isShooting || reloadCounter < reload;`, Turret.java:365), read from the catalog `block.properties` with the 10.0 default (the tick :2665 precedent).', source=RELOAD_TURRET),
    }
    status_outputs = {
        'status': a('String', 'public BlockStatus status(){', 'The block status (`public BlockStatus status(){`, Turret.java:369 -- the Turret leg `enabled && !hasAmmo()` -> noInput, else super.status(), BuildingComp.java:632-646): one of "logicDisable" / "noOutput" / "noInput" / "active" (the SourceBuildingAccessState constants).'),
    }
    return status_inputs, status_outputs


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
    status_inputs, status_outputs = definitions()

    entries = [
        ('N2527', STATUS_OWNER, 'source_turret_status_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.status()', status_inputs, status_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret status() read from Turret.java:369-372 + BuildingComp.java:632-646 + Turret.java:364-366 + ReloadTurret.java:10 + Blocks.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret status() read from Turret.java:369-372 + BuildingComp.java:632-646 + Turret.java:364-366 + ReloadTurret.java:10 + Blocks.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: status.
    by_slice['N2527'] = [
        'source_turret_status_state_result.status',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2527', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.status()', godot_owner=STATUS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2527'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
