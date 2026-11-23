"""Register the BaseTurret drawSelect() row (N2393).

BaseTurretBuild.drawSelect() (BaseTurret.java:133-135) is the
whole method in one line: `Drawf.dashCircle(x, y, range(),
team.color);` (BaseTurret.java:134). The center is the
building world position, the radius is the LIVE range()
value (BaseTurret.java:124, `public float range(){` with
`return range;`, BaseTurret.java:125), the color is the
building team's color. One pure function on the family
file (the N2334 TurretBuild.drawSelect() / N2377
TurretBuild.draw() precedent): the caller passes the live
range() result and the team color as explicit params, and
Drawf.dashCircle arrives as an explicit Callable param (the
N2377 drawer precedent: guarded with is_valid(), invoked
with .call()) -- Drawf itself is NOT ported here. No driver
tick line lands here: drawSelect is selection UI, not
per-tick state (the accessor precedent N2311/N2340). This
is a different method from N2334 TurretBuild.drawSelect()
(selection UI, Turret.java:481-488, the min-range circle,
which calls super.drawSelect() first) and from drawPlace()
(BaseTurret.java:84-92, which draws the range circle at
place time) -- no overlap.

RED decisions (resolved at RED): (1) One pure function,
source_base_turret_build_draw_select_state(x, y,
range_value, team_color, dash_circle), returning
dash_circle_called / center / radius / color -- the
N2334/N2377 draw shape (no frame: drawSelect reads no
frame key -- x/y are the building world position,
range_value is the live range() value, team_color is the
team color string, dash_circle is the Drawf delegate), not
the frame-first accessor shape of the other Turret
functions. (2) range() is NOT re-ported: the caller
passes the live value as the explicit range_value param
(the N2311/N2261 precedent); the field `range`
(BaseTurret.java:22, `public float range = 80f;`) is
evidence only. (3) team.color arrives as an explicit
String param (the SourceBuildingDrawState draw_team
precedent -- `team_color: String`); no Color object is
constructed, no playback happens. (4) Drawf.dashCircle is
NOT re-ported: it arrives as the explicit dash_circle
Callable param (the N2377 drawer precedent); an invalid
callable is reported via dash_circle_called false, the
center/radius/color keys still read their values. (5) The
function is named
source_base_turret_build_draw_select_state -- NOT
source_turret_draw_select_state, which is already taken by
N2334 (TurretBuild.drawSelect). Four new result symbols:
dash_circle_called, center, radius, color. Slice source:
BaseTurret.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_draw import DEFERRED as N2377_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BASE_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java'
PROOF = '/root/C07BaseTurretBuildDrawSelectProof'
DRAW_SELECT_OWNER = 'SourceTurretBuildState.source_base_turret_build_draw_select_state'
TESTS = ['test_c07_base_turret_build_draw_select_registration', 'test_all_c07_base_turret_build_draw_select_input_evidence_is_exact', 'test_base_turret_build_draw_select_state', 'test_reference_graph_and_actual_c07_base_turret_build_draw_select']
# The 1 slice source the N2393 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
]
EXACT_EXPRS = ['public void drawSelect(){', 'Drawf.dashCircle(x, y, range(), team.color);', 'public float range(){', 'return range;', 'public float range = 80f;', 'public class BaseTurret extends Block{', 'public class BaseTurretBuild extends Building implements Ranged, RotBlock{']

# DEFERRED is carried from the N2377 register script via import --
# never retyped. One entry is added: the N2393 Windows Godot
# proof debt.
DEFERRED = list(N2377_DEFERRED) + [
    'BaseTurret drawSelect() Windows Godot proof -- debt in GOAL.md section 5, same as N2377: the N2393 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=BASE_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    select_inputs = {
        'x': a('float', 'Drawf.dashCircle(x, y, range(), team.color);', 'The building world x (BaseTurret.java:134, `Drawf.dashCircle(x, y, range(), team.color);`): the dash circle is centered on the building position.'),
        'y': a('float', 'Drawf.dashCircle(x, y, range(), team.color);', 'The building world y (BaseTurret.java:134, `Drawf.dashCircle(x, y, range(), team.color);`): the dash circle is centered on the building position.'),
        'range_value': a('float', 'Drawf.dashCircle(x, y, range(), team.color);', 'The live range() value (BaseTurret.java:134, `Drawf.dashCircle(x, y, range(), team.color);`): range() (BaseTurret.java:124, `public float range(){` with `return range;`, BaseTurret.java:125) -- computed by the caller and passed in as an explicit param, NOT re-ported here (the N2311/N2261 precedent). The field `range` (BaseTurret.java:22, `public float range = 80f;`) is evidence only.'),
        'team_color': a('String', 'Drawf.dashCircle(x, y, range(), team.color);', 'The building team color (BaseTurret.java:134, `Drawf.dashCircle(x, y, range(), team.color);`): `team.color` -- the Team color of the building, passed as an explicit String param (the SourceBuildingDrawState draw_team precedent, `team_color: String`); no Color object is constructed and no playback happens.'),
        'dash_circle': a('Callable', 'Drawf.dashCircle(x, y, range(), team.color);', 'The Drawf.dashCircle delegate (BaseTurret.java:134, `Drawf.dashCircle(x, y, range(), team.color);`): Drawf is NOT ported, so the dash-circle draw arrives as an explicit Callable param (the N2377 drawer precedent: guarded with is_valid(), invoked with .call(x, y, range_value, team_color)); an invalid callable is reported via dash_circle_called false.'),
    }
    select_outputs = {
        'dash_circle_called': a('bool', 'Drawf.dashCircle(x, y, range(), team.color);', 'Whether the dash-circle delegate was invoked (BaseTurret.java:134, `Drawf.dashCircle(x, y, range(), team.color);`): true when the dash_circle Callable is valid, false otherwise (the N2377 drawer_called precedent).'),
        'center': a('Vector2', 'Drawf.dashCircle(x, y, range(), team.color);', 'The dash-circle center (BaseTurret.java:134, `Drawf.dashCircle(x, y, range(), team.color);`): the building position itself.'),
        'radius': a('float', 'Drawf.dashCircle(x, y, range(), team.color);', 'The dash-circle radius (BaseTurret.java:134, `Drawf.dashCircle(x, y, range(), team.color);`): the live range() value, read through even when the delegate is invalid.'),
        'color': a('String', 'Drawf.dashCircle(x, y, range(), team.color);', 'The dash-circle color (BaseTurret.java:134, `Drawf.dashCircle(x, y, range(), team.color);`): the building team color, carried as the team_color String.'),
    }
    return select_inputs, select_outputs


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
    select_inputs, select_outputs = definitions()

    entries = [
        ('N2393', DRAW_SELECT_OWNER, 'source_base_turret_build_draw_select_state', BASE_TURRET, 'mindustry.world.blocks.defense.turrets.BaseTurret.BaseTurretBuild', 'BaseTurretBuild.drawSelect()', select_inputs, select_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BaseTurret drawSelect() row from BaseTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BaseTurret drawSelect() row from BaseTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: dash_circle_called, center, radius, color.
    by_slice['N2393'] = [
        'source_base_turret_build_draw_select_state_result.dash_circle_called',
        'source_base_turret_build_draw_select_state_result.center',
        'source_base_turret_build_draw_select_state_result.radius',
        'source_base_turret_build_draw_select_state_result.color',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2393', dict(status='done', java_source=BASE_TURRET, java_class='mindustry.world.blocks.defense.turrets.BaseTurret.BaseTurretBuild', java_method='BaseTurretBuild.drawSelect()', godot_owner=DRAW_SELECT_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2393'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
