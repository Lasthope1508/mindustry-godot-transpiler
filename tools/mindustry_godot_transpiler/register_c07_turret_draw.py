"""Register the Turret draw() row (N2377).

TurretBuild.draw() (Turret.java:476-478) is the whole method in
one line: `drawer.draw(this);` (Turret.java:477). The drawer is
the block-level DrawBlock field (`public DrawBlock drawer = new
DrawTurret();`, Turret.java:155) -- the delegate that draws the
whole turret. One pure function on the family file (the N2334
drawSelect precedent): the caller passes the drawer as an
explicit Callable param and the build as an explicit
Dictionary, and the pure function calls the drawer with the
build and returns the delegation state (draw_delegated /
drawer_called). DrawTurret itself is NOT ported here. No driver
tick line lands here: draw() is a render delegate, not
per-tick state (the accessor precedent N2311/N2340). This is a
different method from N2334 drawSelect() (selection UI,
Turret.java:481-488) and from drawPlace() (:252-253, already
ported as N1162 turret_draw_place.min_range) -- no overlap.

RED decisions (resolved at RED): (1) One pure function,
source_turret_draw_state(drawer, build), returning
draw_delegated / drawer_called -- the N2334 drawSelect shape
(no frame: draw() reads no frame key -- the drawer is the def
field, the build is the `this` of `drawer.draw(this);`), not
the frame-first accessor shape of the other Turret functions.
(2) The drawer arrives as an explicit Callable param (the
SourceBlockGeometry world_tile_lookup precedent: guarded with
is_valid(), invoked with .call()); an invalid drawer is
reported via drawer_called false, the delegation flag still
reads true. (3) DrawTurret is NOT ported: no draw method of
the drawer is registered (`drawer.load`,
`drawer.finalIcons`, `drawer.drawPlan`,
`drawer.getRegionsToOutline` are already owned at
N1157-N1160/N1925-N1927). (4) N2297 (drawrot) + N2334
(drawSelect) are substring false positives -- their records
were read directly and none of their exprs is re-registered.
Two new result symbols: draw_delegated, drawer_called. Slice
source: Turret.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_handle_liquid import DEFERRED as N2356_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
PROOF = '/root/C07TurretDrawProof'
DRAW_OWNER = 'SourceTurretBuildState.source_turret_draw_state'
TESTS = ['test_c07_turret_draw_registration', 'test_all_c07_turret_draw_input_evidence_is_exact', 'test_turret_draw_state', 'test_reference_graph_and_actual_c07_turret_draw']
# The 1 slice source the N2377 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
]
EXACT_EXPRS = ['public void draw(){', 'drawer.draw(this);', 'public DrawBlock drawer = new DrawTurret();', 'public class Turret extends ReloadTurret{', 'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{']

# DEFERRED is carried from the N2356 register script via import --
# never retyped. One entry is added: the N2377 Windows Godot
# proof debt (GOAL.md section 5).
DEFERRED = list(N2356_DEFERRED) + [
    'Turret draw() Windows Godot proof -- debt in GOAL.md section 5, same as N2356: the N2377 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    draw_inputs = {
        'drawer': a('Callable', 'drawer.draw(this);', 'The block-level drawer (Turret.java:477, `drawer.draw(this);`): the DrawBlock field (`public DrawBlock drawer = new DrawTurret();`, Turret.java:155, "Defines drawing behavior for this turret.") arrives as an explicit Callable param (the SourceBlockGeometry world_tile_lookup precedent: guarded with is_valid(), invoked with .call()); DrawTurret itself is NOT ported here.'),
        'build': a('Dictionary', 'drawer.draw(this);', 'The turret build itself (Turret.java:477, `drawer.draw(this);`): the `this` the drawer draws -- the build state passed to the drawer, carried as an explicit Dictionary param (the N2334 drawSelect precedent: no frame, explicit params only).'),
    }
    draw_outputs = {
        'draw_delegated': a('bool', 'drawer.draw(this);', 'Whether draw() delegated to the drawer (Turret.java:477, `drawer.draw(this);`): always true -- the whole method is the delegation; the flag reads true even when the drawer callable is invalid (the call is skipped, the delegation is still the method behavior).'),
        'drawer_called': a('bool', 'drawer.draw(this);', 'Whether the drawer callable was actually invoked (Turret.java:477, `drawer.draw(this);`): true when the drawer Callable is valid and was called with the build, false when the drawer is invalid (the SourceBlockGeometry is_valid() guard precedent).'),
    }
    return draw_inputs, draw_outputs


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
    draw_inputs, draw_outputs = definitions()

    entries = [
        ('N2377', DRAW_OWNER, 'source_turret_draw_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.draw()', draw_inputs, draw_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret draw() row from Turret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret draw() row from Turret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: draw_delegated, drawer_called.
    by_slice['N2377'] = [
        'source_turret_draw_state_result.draw_delegated',
        'source_turret_draw_state_result.drawer_called',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2377', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.draw()', godot_owner=DRAW_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2377'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
