"""Register the TurretBuild.BulletEntry ctor (N2410).

TurretBuild.BulletEntry(Bullet, float, float, float, float)
(Turret.java:867-873, `public BulletEntry(Bullet bullet, float x,
float y, float rotation, float life){`) assigns 5 fields on the
inner record (Turret.java:864-866, `public static class
BulletEntry{` / `public Bullet bullet;` / `public float x, y,
rotation, life;`). Only 2 of the 5 assignments are unowned:
`this.bullet = bullet;` (:868) and `this.life = life;` (:872).
The other 3 are already exact_exprs elsewhere and are never
re-registered: `this.x = x;` and `this.y = y;` are N1115's
(`void set(float x, float y){` slice), `this.rotation =
rotation;` is N1770's (`public Building init(...)` slice).
One GD function on SourceTurretBuildState.gd (the TurretBuild
file) -- BulletEntry is an inner data class, not a Build, so
the port is a pure function returning the record Dictionary
(main-thread decision 2026-11-22, recorded in allocations.json
N2410): the 5 ctor params arrive as explicit params (the N2188
precedent) and the function returns all 5 record fields. The
inline `bullet_entry` dicts in the ContinuousTurret/LaserTurret
bridges are call-site literals, not this ctor -- no dedup. The
record's callers store entries in a seq
(ContinuousTurret.java:39 / LaserTurret.java:45, `public
Seq<BulletEntry> bullets = new Seq<>();`) and construct them at
ContinuousTurret.java:156 / LaserTurret.java:142 -- those call
sites are not ported here. Five new result symbols, one per
record field, in ctor order. One slice source: Turret.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_continuous_turret_default_constructor import DEFERRED as N2407_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
PROOF = '/root/C07TurretBulletEntryProof'
BULLET_ENTRY_OWNER = 'SourceTurretBuildState.source_turret_bullet_entry_state'
TESTS = ['test_c07_turret_bullet_entry_registration', 'test_all_c07_turret_bullet_entry_input_evidence_is_exact', 'test_turret_bullet_entry_state', 'test_reference_graph_and_actual_c07_turret_bullet_entry']
# The 1 slice source the N2410 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
]
EXACT_EXPRS = [
    'this.bullet = bullet;',
    'this.life = life;',
]

# DEFERRED is carried from the N2407 register script via import --
# never retyped. Nothing in it closes here: N2410 ports the
# BulletEntry ctor, which no N2407 entry lists. One entry is added:
# the N2410 Windows Godot proof debt (GOAL.md section 5).
DEFERRED = list(N2407_DEFERRED) + [
    'TurretBuild.BulletEntry ctor N2410 Windows Godot proof -- debt in GOAL.md section 5, same as N2407: the N2410 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    ctor_sig = 'public BulletEntry(Bullet bullet, float x, float y, float rotation, float life){'
    ctor_inputs = {
        'bullet': a('Variant', ctor_sig, 'The bullet the entry wraps (Turret.java:867, `public BulletEntry(Bullet bullet, float x, float y, float rotation, float life){`): the ctor\'s first param; a Bullet object is an opaque ref in GDScript, so it arrives as Variant and passes through unchanged.'),
        'x': a('float', ctor_sig, 'The x position of the bullet entry (Turret.java:867, ctor signature): the ctor\'s second param; the assignment `this.x = x;` is already the exact_expr of N1115 -- cited as evidence only, never re-registered here.'),
        'y': a('float', ctor_sig, 'The y position of the bullet entry (Turret.java:867, ctor signature): the ctor\'s third param; the assignment `this.y = y;` is already the exact_expr of N1115 -- cited as evidence only, never re-registered here.'),
        'rotation': a('float', ctor_sig, 'The rotation of the bullet entry (Turret.java:867, ctor signature): the ctor\'s fourth param; the assignment `this.rotation = rotation;` is already the exact_expr of N1770 -- cited as evidence only, never re-registered here.'),
        'life': a('float', ctor_sig, 'The life of the bullet entry (Turret.java:867, ctor signature): the ctor\'s fifth param; the ctor assigns it with `this.life = life;` (Turret.java:872), owned by this slice.'),
    }
    ctor_outputs = {
        'bullet': a('Variant', 'this.bullet = bullet;', 'The wrapped bullet (Turret.java:868, `this.bullet = bullet;`): BulletEntry.bullet; the ctor stores the Bullet ref unchanged -- the record keeps the same object the caller passed in.'),
        'x': a('float', ctor_sig, 'The x position of the record (Turret.java:867, ctor signature): BulletEntry.x; the ctor assigns it with `this.x = x;` (Turret.java:869), already the exact_expr of N1115 -- cited as evidence only, never re-registered here.'),
        'y': a('float', ctor_sig, 'The y position of the record (Turret.java:867, ctor signature): BulletEntry.y; the ctor assigns it with `this.y = y;` (Turret.java:870), already the exact_expr of N1115 -- cited as evidence only, never re-registered here.'),
        'rotation': a('float', ctor_sig, 'The rotation of the record (Turret.java:867, ctor signature): BulletEntry.rotation; the ctor assigns it with `this.rotation = rotation;` (Turret.java:871), already the exact_expr of N1770 -- cited as evidence only, never re-registered here.'),
        'life': a('float', 'this.life = life;', 'The life of the record (Turret.java:872, `this.life = life;`): BulletEntry.life; the ctor stores the life value unchanged -- continuous drivers pass 0f, laser drivers pass shootDuration.'),
    }
    return ctor_inputs, ctor_outputs


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
    ctor_inputs, ctor_outputs = definitions()

    entries = [
        ('N2410', BULLET_ENTRY_OWNER, 'source_turret_bullet_entry_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild.BulletEntry', 'BulletEntry(Bullet, float, float, float, float)', ctor_inputs, ctor_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed TurretBuild.BulletEntry() ctor record state from Turret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed TurretBuild.BulletEntry() ctor record state from Turret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the 5 record fields in ctor order.
    by_slice['N2410'] = [
        'source_turret_bullet_entry_state_result.bullet',
        'source_turret_bullet_entry_state_result.x',
        'source_turret_bullet_entry_state_result.y',
        'source_turret_bullet_entry_state_result.rotation',
        'source_turret_bullet_entry_state_result.life',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2410', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild.BulletEntry', java_method='BulletEntry(Bullet, float, float, float, float)', godot_owner=BULLET_ENTRY_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2410'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
