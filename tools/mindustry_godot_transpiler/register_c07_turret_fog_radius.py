"""Register the Turret fogRadius() read (N2531).

TurretBuild.fogRadius() (Turret.java:420-422):
`public float fogRadius(){` /
`return (range + (hasAmmo() ? peekAmmo().rangeChange : 0f)) / tilesize * fogRadiusMultiplier;`
-- it uses the `range` FIELD plus the peeked ammo rangeChange
when hasAmmo() is true; it does NOT call range()
(Turret.java:343-347), though the value equals range() when
hasAmmo is true and peekAmmo is non-null. `tilesize` is
`public static final int tilesize = 8;` (Vars.java:135) and
`fogRadiusMultiplier` is the block field
`public float fogRadiusMultiplier = 1f;` (BaseTurret.java:24),
with the one per-def override `fogRadiusMultiplier = 0.4f;`
(Blocks.java:5627, scathe). `rangeChange` is the BulletType
field `public float rangeChange = 0f;` (BulletType.java:157)
and `range` is the block field `public float range = 80f;`
(BaseTurret.java:21). NOT the block-init fogRadius
(BaseTurret.java:59, `fogRadius = Math.max(Mathf.round(range /
tilesize * fogRadiusMultiplier), fogRadius);`) -- that is a
field init at block level, not the TurretBuild.fogRadius()
override. `hasAmmo()` MUTATES the ammo stack
(`ammo.swap(ammo.size - 1, i);`, Turret.java:703), so it is a
bool param, not computed in the function (the N2527/N2528
precedent). NO driver tick call site: fogRadius() is a read,
not per-tick, and no caller reads it today (fog-of-war / draw
logic is a later slice).

GREEN decisions (pinned by this slice): (1) One pure
function on SourceTurretBuildState.gd,
source_turret_fog_radius_state(range_value, has_ammo,
peek_ammo_range_change, tilesize, fog_radius_multiplier),
placed immediately AFTER source_turret_can_control_state
(N2530) and BEFORE source_turret_can_heal_state. It returns
exactly one key, `fog_radius`. (2) NO tick call site -- the
function is DORMANT live today: the driver tick never calls
it, so live behavior does not change. (3) Every Java input
stays an explicit param -- the function never guesses the
catalog in the function body (the N2526/N2527/N2528
param-driven precedent).
SSOT expected after GREEN: symbols +1, Done +1, contracts
+1, schemas +2, 11724/1759/1692/3175 -> 11725/1760/1693/3177;
defense shard slices 217 -> 218, contracts 216 -> 217; comp
stays 572/475.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_can_control import DEFERRED as N2530_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
BASE_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java'
VARS = 'core/src/mindustry/Vars.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
BULLET_TYPE = 'core/src/mindustry/entities/bullet/BulletType.java'
PROOF = '/root/C07TurretFogRadiusProof'
FOG_RADIUS_OWNER = 'SourceTurretBuildState.source_turret_fog_radius_state'
TESTS = ['test_c07_turret_fog_radius_registration', 'test_all_c07_turret_fog_radius_input_evidence_is_exact', 'test_turret_fog_radius_state', 'test_reference_graph_and_actual_c07_turret_fog_radius']
# The slice sources the N2531 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
    'core/src/mindustry/Vars.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/entities/bullet/BulletType.java',
]
EXACT_EXPRS = [
    'public float fogRadius(){',
    'return (range + (hasAmmo() ? peekAmmo().rangeChange : 0f)) / tilesize * fogRadiusMultiplier;',
    'public static final int tilesize = 8;',
    'public float fogRadiusMultiplier = 1f;',
    'fogRadiusMultiplier = 0.4f;',
    'public float rangeChange = 0f;',
    'public float range = 80f;',
]

# DEFERRED is carried from the N2530 register script via import --
# never retyped. No entry is dropped: the fogRadius read the
# N2530 pool entry deferred is recorded DONE below. New entries
# below record the fogRadius read as DONE by this slice and the
# Windows proof debt.
DEFERRED = N2530_DEFERRED + [
    'Turret fogRadius() (`fog_radius` frame key) -- DONE by this slice (N2531): `source_turret_fog_radius_state` ports Turret.java:420-422 (`return (range + (hasAmmo() ? peekAmmo().rangeChange : 0f)) / tilesize * fogRadiusMultiplier;`, `tilesize` = `public static final int tilesize = 8;`, Vars.java:135, `fogRadiusMultiplier` = `public float fogRadiusMultiplier = 1f;`, BaseTurret.java:24, scathe override `fogRadiusMultiplier = 0.4f;`, Blocks.java:5627) for the Turret family. NO driver tick call site: fogRadius() is a read, not per-tick, and no caller reads it today (fog-of-war / draw logic is a later slice). Dormant live today: the driver tick never calls the function, so live behavior does not change. NOT the block-init fogRadius (BaseTurret.java:59) and NOT range() (Turret.java:343-347).',
    'Turret fogRadius() Windows Godot proof -- debt in GOAL.md section 5, same as N2283-N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515/N2516/N2517/N2518/N2519/N2520/N2521/N2522/N2523/N2524/N2525/N2526/N2527/N2528/N2529/N2530: the N2531 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    fog_radius_inputs = {
        'range_value': a('float', 'public float range = 80f;', 'The block `range` FIELD (`public float range = 80f;`, BaseTurret.java:21 -- the class default; fogRadius() uses the field plus the conditional rangeChange, it does NOT call range(), Turret.java:343-347).', source=BASE_TURRET),
        'has_ammo': a('bool', 'public boolean hasAmmo(){', 'Whether the turret has ammo (`public boolean hasAmmo(){`, Turret.java:698 -- hasAmmo() MUTATES the ammo stack (`ammo.swap(ammo.size - 1, i);`, Turret.java:703), so it cannot be a pure read; it is an explicit bool param, the N2527/N2528 precedent).'),
        'peek_ammo_range_change': a('float', 'public float rangeChange = 0f;', 'The peeked ammo rangeChange (`public float rangeChange = 0f;`, BulletType.java:157 -- the BulletType field; added to range only when has_ammo is true, the N2526 range() param precedent).', source=BULLET_TYPE),
        'tilesize': a('int', 'public static final int tilesize = 8;', 'The tile size in units (`public static final int tilesize = 8;`, Vars.java:135 -- `/** size of tiles in units */`), an explicit int param, never hardcoded.', source=VARS),
        'fog_radius_multiplier': a('float', 'public float fogRadiusMultiplier = 1f;', 'The block fogRadiusMultiplier field (`public float fogRadiusMultiplier = 1f;`, BaseTurret.java:24 -- the class default; the one per-def override is `fogRadiusMultiplier = 0.4f;`, Blocks.java:5627, scathe -- but the function takes the field as an explicit float param, never hardcoded, the N2526/N2527 param-driven precedent).', source=BASE_TURRET),
    }
    fog_radius_outputs = {
        'fog_radius': a('float', 'public float fogRadius(){', 'The Turret fog radius (`public float fogRadius(){` / `return (range + (hasAmmo() ? peekAmmo().rangeChange : 0f)) / tilesize * fogRadiusMultiplier;`, Turret.java:420-422 -- the TurretBuild override of the Building fogRadius read).'),
    }
    return fog_radius_inputs, fog_radius_outputs


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
    fog_radius_inputs, fog_radius_outputs = definitions()

    entries = [
        ('N2531', FOG_RADIUS_OWNER, 'source_turret_fog_radius_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.fogRadius()', fog_radius_inputs, fog_radius_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret fogRadius() read from Turret.java:420-422 + BaseTurret.java:21/24 + Vars.java:135 + Blocks.java:5627 + BulletType.java:157.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret fogRadius() read from Turret.java:420-422 + BaseTurret.java:21/24 + Vars.java:135 + Blocks.java:5627 + BulletType.java:157.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: fog_radius.
    by_slice['N2531'] = [
        'source_turret_fog_radius_state_result.fog_radius',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2531', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.fogRadius()', godot_owner=FOG_RADIUS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2531'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
