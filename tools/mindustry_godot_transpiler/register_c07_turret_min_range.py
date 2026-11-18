"""Register the Turret minRange() accessor (N2282).

TurretBuild.minRange() (Turret.java:334-339) is the artillery
minimum-range accessor:
`public float minRange(){`
`if(peekAmmo() != null){`
`return minRange + peekAmmo().minRangeChange;`
`}`
`return minRange;`
on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
(Turret.java:277). The def minimum is the Turret field
(`public float minRange = 0f;`, Turret.java:74, "Minimum
bullet range. Used for artillery only."); the ammo change is
the peeked bullet's minRangeChange (BulletType.java:163,
`public float minRangeChange = 0f;`, default 0f).

RED decisions (resolved at RED): (1) One pure function --
the def minimum arrives as the explicit float min_range,
peekAmmo() != null arrives as the explicit bool has_ammo,
and the peeked bullet's minRangeChange arrives as the
explicit float ammo_min_range_change. The gate is
peekAmmo() != null (Turret.java:693, `public @Nullable
BulletType peekAmmo(){`), NOT hasAmmo() (Turret.java:698,
which has the ammo-swap side effect and can be false while
peekAmmo() is non-null) -- so has_ammo carries the
peekAmmo() null check (the isActive :509 precedent, where
the param is_shooting carries wasShooting), never calls
hasAmmo(). peekAmmo() is likewise not ported here: the
caller passes the peeked bullet's minRangeChange explicitly
(0.0 when peekAmmo() is null, the Java fall-through leg).
(2) No ammo returns the bare def minimum (the Java
fall-through leg); with ammo the change is added even when
it is 0f (the BulletType default). (3) NO driver tick line:
minRange() is a read accessor its callers read, not a
per-tick write (the N2249 precedent) -- drawSelect() reads
it for the min-range dash circle (Turret.java:485,
`Drawf.dashCircle(x, y, minRange(), team.color);`) and the
shoot leg clamps the bullet life scale with it
(Turret.java:787, `Mathf.clamp(..., minRange() /
type.range, range() / type.range)`); both callers wait for
their own slices. (4) drawPlace() :253 reads the minRange
FIELD directly (`Drawf.dashCircle(..., minRange,
Pal.placing);`), already ported as N1162
turret_draw_place.min_range -- that is the field, not this
method. One new result symbol: min_range. Two slice
sources: Turret.java + BulletType.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_is_active import DEFERRED as N2279_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
BULLET_TYPE = 'core/src/mindustry/entities/bullet/BulletType.java'
PROOF = '/root/C07TurretMinRangeProof'
OWNER = 'SourceTurretBuildState.source_turret_min_range_state'
TESTS = ['test_c07_turret_min_range_registration', 'test_all_c07_turret_min_range_input_evidence_is_exact', 'test_turret_min_range_state', 'test_reference_graph_and_actual_c07_turret_min_range']
# The 2 slice sources the N2282 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/entities/bullet/BulletType.java',
]
EXACT_EXPRS = [
    'public class Turret extends ReloadTurret{',
    'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
    'public class BulletType extends Content implements Cloneable{',
    'public float minRange(){',
    'if(peekAmmo() != null){',
    'return minRange + peekAmmo().minRangeChange;',
    'return minRange;',
    'public float minRange = 0f;',
    'public float minRangeChange = 0f;',
    'public @Nullable BulletType peekAmmo(){',
    'return ammo.size == 0 ? null : ammo.peek().type();',
]

# DEFERRED is carried from the N2279 register script via import --
# never retyped. Nothing in it closes here: minRange() was never
# a deferred entry of the Turret chain. One entry is added: the
# N2282 Windows Godot proof debt (GOAL.md section 5).
DEFERRED = N2279_DEFERRED + [
    'Turret minRange() Windows Godot proof -- debt in GOAL.md section 5, same as N2148/N2227: the N2282 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    inputs = {
        'frame': a('Dictionary', 'public float minRange(){', 'The turret frame (TurretBuild.minRange, Turret.java:334): the family-convention first arg every Turret pure function takes; it carries no tracked key for this accessor -- the tick frame tracks no ammo state yet, so all live values arrive as explicit params (the N2188 precedent).'),
        'min_range': a('float', 'public float minRange = 0f;', 'The def minimum range (`minRange`, Turret.java:334-338): the Turret field (`public float minRange = 0f;`, Turret.java:74, "Minimum bullet range. Used for artillery only."); returned bare when there is no peeked ammo (the Java fall-through leg).'),
        'has_ammo': a('bool', 'public @Nullable BulletType peekAmmo(){', 'Whether a peeked ammo type exists (`peekAmmo() != null`, Turret.java:335): carries the peekAmmo() null check (`public @Nullable BulletType peekAmmo(){`, Turret.java:693, `return ammo.size == 0 ? null : ammo.peek().type();`), NOT hasAmmo() (Turret.java:698, which has the ammo-swap side effect and can be false while peekAmmo() is non-null) -- the isActive :509 precedent, where the param is_shooting carries wasShooting.'),
        'ammo_min_range_change': a('float', 'public float minRangeChange = 0f;', 'The peeked bullet\'s minimum-range change (`peekAmmo().minRangeChange`, Turret.java:336): the BulletType field (`public float minRangeChange = 0f;`, BulletType.java:163, default 0f); 0.0 when peekAmmo() is null (the Java fall-through leg), so the change is meaningful only when has_ammo.', source=BULLET_TYPE),
    }
    outputs = {
        'min_range': a('float', 'return minRange + peekAmmo().minRangeChange;', 'The effective minimum range (Turret.java:336-338, `return minRange + peekAmmo().minRangeChange;` / `return minRange;`): the def minimum plus the peeked bullet\'s minRangeChange when ammo is peeked, the bare def minimum otherwise.'),
    }
    return inputs, outputs


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
    inputs, outputs = definitions()

    entries = [
        ('N2282', OWNER, 'source_turret_min_range_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.minRange()', inputs, outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed TurretBuild.minRange() state from Turret.java + BulletType.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed TurretBuild.minRange() state from Turret.java + BulletType.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: min_range.
    by_slice['N2282'] = [
        'source_turret_min_range_state_result.min_range',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2282', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.minRange()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2282'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
