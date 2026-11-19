"""Register the Turret rotate sync (N2262).

TurretBuild.updateTile (Turret.java:490-615) syncs the
underlying building rotation every tick, after the
logic-control timer decay and before the heat-requirement
fold:
`if(rotate){`
`((Building)this).rotation = Mathf.mod(Mathf.round(rotation / 90f), 4);`
(Turret.java:542-545). `rotate` is true for every turret
(Turret constructor, `rotate = true;`, :163) and duo never
overrides it (Blocks.java:3257-3331 sets only
`rotateSpeed = 10f;`). `rotation` is the turret's own float
aim rotation in degrees (frame["rotation"], default 90.0);
the synced field is the shadowed int 0-3 Building rotation
(`transient int rotation;`, BuildingComp.java:69, default 0).
arc `Mathf.round(float)` is
`return (int)(value + BIG_ENOUGH_ROUND) - BIG_ENOUGH_INT;`
(Mathf.java:500-502) -- round half UP toward +inf, like Java
Math.round, NOT half away from zero: -0.5 rounds to 0, -1.5
rounds to -1. arc `Mathf.mod(float, float)` is
`return ((f % n) + n) % n;` (Mathf.java:574-576) -- a proper
mod for negatives, so -1 maps to 3. The new C07 duo driver
(N2250-N2261) never synced the building rotation -- the
frame had no building_rotation key at all. This slice adds
the one pure function on the shared TurretBuild driver file
(updateTile() is TurretBuild's method, common to every
turret, not ItemTurret-only) plus one driver tick in the duo
branch AFTER the N2261 logicControlTime tick and BEFORE the
aim call (Java order :534-536 decay, :538-540 heatReq,
:542-545 rotate sync, :595-596 turnToTarget, :601/:609
updateShooting).

GREEN decisions (pinned by this slice): (1) One pure function
on SourceTurretBuildState.gd,
source_turret_rotate_sync_state(rotation, rotate,
building_rotation), returning `{"building_rotation": ..}` --
when rotate is false the building rotation is returned
unchanged, exactly what Java does by skipping the
assignment; when rotate is true the sync is
`mod(round(rotation / 90), 4)` with the round done as
`floor(rotation / 90.0 + 0.5)` (the
SourceBlockRequirementsState precedent -- arc round is half
UP, so Godot's `round()` would be wrong for negative
halves) and the mod done as `((rounded % 4) + 4) % 4` (the
arc mod formula). Plus one driver tick in the duo branch
(right after the N2261 logicControlTime tick, before the aim
call) that reads the frame rotation (default 90.0, the aim
stamp default), passes rotate=true for duo and the frame
building rotation (default 0, the Building field default),
calls the pure function, then stamps the key back on the
frame -- the tick runs BEFORE the aim call, so the aim reads
a synced rotation. (2) The heatReq fold (:538-540) waits for
its own slice -- the sync only reads the frame rotation, it
never touches heat. (3) No legacy
`source_turret_rotate_sync_result` schema exists (unlike
N2258's recoilOffset), so the contract validator falls
through to the new `source_turret_rotate_sync_state_result`
schema and no alias is needed. SSOT expected after GREEN:
symbols +1, Done +1, contracts +1, schema +2,
11619/1711/1645/3081 -> 11620/1712/1646/3083; defense
shard slices 190 -> 191, contracts 189 -> 190.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_logic_control_time import DEFERRED as N2261_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
ARC_MATHF = 'arc-core/src/arc/math/Mathf.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
PROOF = '/root/C07TurretRotateSyncProof'
ROTATE_SYNC_OWNER = 'SourceTurretBuildState.source_turret_rotate_sync_state'
TESTS = ['test_c07_turret_rotate_sync_registration', 'test_all_c07_turret_rotate_sync_input_evidence_is_exact', 'test_turret_rotate_sync_state', 'test_reference_graph_and_actual_c07_turret_rotate_sync']
# The slice sources the N2262 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'arc-core/src/arc/math/Mathf.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
]
EXACT_EXPRS = ['if(rotate){', '((Building)this).rotation = Mathf.mod(Mathf.round(rotation / 90f), 4);', 'rotate = true;', 'return ((f % n) + n) % n;', 'return (int)(value + BIG_ENOUGH_ROUND) - BIG_ENOUGH_INT;', 'transient int rotation;']

# DEFERRED is carried from the N2261 register script via import --
# never retyped. The rotate sync is done by this slice (it was the
# next item named in the N2261 handoff); the heatReq fold, the
# control() setters, the maxHealth/health re-sync, the set(tile)
# world position, the cross-tick queuedBullets counter,
# effects/sound, findTarget / the other ItemTurret defs still wait.
DEFERRED = list(N2261_DEFERRED) + [
    'Turret rotate sync Windows Godot proof -- debt in GOAL.md section 5, same as N2240-N2261: the N2262 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Turret rotate sync (Turret.java:542-545) -- DONE by this slice (N2262); it was the next item named in the N2261 handoff.',
    'Turret rotate sync for defs other than duo -- the pure function takes rotation / rotate / building_rotation as params; only duo is wired in the driver.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    rotate_sync_inputs = {
        'rotation': a('float', 'Mathf.round(rotation / 90f)', 'The turret float aim rotation in degrees before this tick (Turret.java:544; the driver reads frame["rotation"], default 90.0, the aim stamp default).'),
        'rotate': a('bool', 'rotate = true;', 'Whether this turret rotates its building (Turret.java:163, the Turret constructor default; duo never overrides it, Blocks.java:3257-3331; the driver passes true for duo).'),
        'building_rotation': a('int', 'transient int rotation;', 'The shadowed int 0-3 Building rotation before this tick (BuildingComp.java:69, the field default is 0; the driver reads frame["building_rotation"], default 0).', source=BUILDING_COMP),
    }
    rotate_sync_outputs = {
        'building_rotation': a('int', '((Building)this).rotation = Mathf.mod(Mathf.round(rotation / 90f), 4);', 'The shadowed int 0-3 Building rotation after the tick (Turret.java:544 -- mod(round(rotation / 90), 4) when rotate is true, unchanged otherwise; the driver stamps it on frame["building_rotation"]).'),
    }
    return rotate_sync_inputs, rotate_sync_outputs


def verify():
    """Check every EXACT_EXPRS line and every input/output
    java_expr appears verbatim in its upstream source, without
    touching any SSOT JSON. Exit 0 when all are present."""
    upstream = {}
    for source in SLICE_SOURCES:
        upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
        upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
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
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            text = (upstream_root / source).read_text(encoding='utf-8')
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
    rotate_sync_inputs, rotate_sync_outputs = definitions()

    entries = [
        ('N2262', ROTATE_SYNC_OWNER, 'source_turret_rotate_sync_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.updateTile()', rotate_sync_inputs, rotate_sync_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret rotate sync from Turret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret rotate sync from Turret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: building_rotation.
    by_slice['N2262'] = [
        'source_turret_rotate_sync_state_result.building_rotation',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2262', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.updateTile()', godot_owner=ROTATE_SYNC_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2262'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
