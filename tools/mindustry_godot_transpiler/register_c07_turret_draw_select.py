"""Register the Turret drawSelect() row (N2334).

TurretBuild.drawSelect() (Turret.java:481-488) calls
`super.drawSelect();` (:482) then, when the def field
drawMinRange is true, draws one dash circle around the
building (`Drawf.dashCircle(x, y, minRange(), team.color);`,
:485): the center is the building world position, the
radius is the LIVE minRange() value (N2340), the color is
the building team's color. One pure function on the family
file (the N2220 RepairPointBuild.drawSelect() / N2283
DrillBuild.drawSelect() / N2333 Radar drawSelect
precedent): the caller passes the live minRange() result
(the N2340 source_turret_min_range_state output) and the
team color as explicit params, and the pure function
returns the draw-command state (whether the circle is
drawn, center, radius, color). No driver tick line lands
here: drawSelect is selection UI, not per-tick state (the
accessor precedent N2311/N2340). This is a different
method from N2329 peekAmmo() (which minRange() reads) and
from drawPlace() (:252-253, which reads the minRange FIELD
directly -- already ported as N1162
turret_draw_place.min_range) -- no overlap.

RED decisions (resolved at RED): (1) One pure function,
source_turret_draw_select_state(x, y, draw_min_range,
min_range, team_color), returning draw_min_range_circle /
center / radius / color -- the N2220/N2333 drawSelect
shape (no frame: drawSelect reads no frame key -- x/y are
the building world position, draw_min_range is the def
field, min_range is the live N2340 value, team_color is
the team color string), not the frame-first accessor shape
of the other Turret functions. (2) super.drawSelect() is
EVIDENCE, not a param: the base BuildingComp.drawSelect()
is ALREADY LIVE as N573
(PortGame.source_building_draw_select_state) and runs
first at the call site; its output does not feed the
Turret leg, so no param carries it -- the exact_exprs
carry `super.drawSelect();` verbatim and the deferred
entry records the N573 call-site order. (3) minRange() is
NOT re-ported: the caller passes the N2340 live value as
the explicit min_range param (the N2311/N2261 precedent);
the field `minRange` (Turret.java:74, `public float
minRange = 0f;`) is evidence only. (4) team.color arrives
as an explicit String param (the SourceBuildingDrawState
draw_team precedent -- `team_color: String`); no Color
object is constructed, no playback happens. (5) When
drawMinRange is false the function still returns all four
keys (schema-stable): draw_min_range_circle false and
radius 0.0 (no circle drawn). Four new result symbols:
draw_min_range_circle, center, radius, color. Slice
source: Turret.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_peek_ammo import DEFERRED as N2329_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
PROOF = '/root/C07TurretDrawSelectProof'
DRAW_SELECT_OWNER = 'SourceTurretBuildState.source_turret_draw_select_state'
TESTS = ['test_c07_turret_draw_select_registration', 'test_all_c07_turret_draw_select_input_evidence_is_exact', 'test_turret_draw_select_state', 'test_reference_graph_and_actual_c07_turret_draw_select']
# The 1 slice source the N2334 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
]
EXACT_EXPRS = ['public void drawSelect(){', 'super.drawSelect();', 'if(drawMinRange){', 'Drawf.dashCircle(x, y, minRange(), team.color);', 'public boolean drawMinRange;', 'public float minRange = 0f;', 'public float minRange(){', 'return minRange + peekAmmo().minRangeChange;', 'return minRange;', 'public class Turret extends ReloadTurret{', 'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{']

# DEFERRED is carried from the N2329 register script via import --
# never retyped. Two entries are added: the N2334 Windows Godot
# proof debt (GOAL.md section 5) and the note that the base
# BuildingComp.drawSelect() leg (live N573) runs first at the
# call site and is NOT re-ported here.
DEFERRED = N2329_DEFERRED + [
    'Turret drawSelect() Windows Godot proof -- debt in GOAL.md section 5, same as N2148/N2227: the N2334 proof runs headless on Linux here and waits for a Windows Godot run.',
    'TurretBuild.drawSelect() (Turret.java:481-488, `super.drawSelect();` then `if(drawMinRange){ Drawf.dashCircle(x, y, minRange(), team.color); }`) -- the base BuildingComp.drawSelect() leg is ALREADY LIVE as N573 (PortGame.source_building_draw_select_state) and runs first at the call site; only the Turret min-range dash-circle leg is this slice (N2334).',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    select_inputs = {
        'x': a('float', 'Drawf.dashCircle(x, y, minRange(), team.color);', 'The building world x (Turret.java:485, `Drawf.dashCircle(x, y, minRange(), team.color);`): the dash circle is centered on the building position.'),
        'y': a('float', 'Drawf.dashCircle(x, y, minRange(), team.color);', 'The building world y (Turret.java:485, `Drawf.dashCircle(x, y, minRange(), team.color);`): the dash circle is centered on the building position.'),
        'draw_min_range': a('bool', 'if(drawMinRange){', 'The def field drawMinRange (Turret.java:70, `public boolean drawMinRange;`, "If true, a range ring is also drawn for minRange."): when true the min-range dash circle is drawn, when false no circle is drawn (after the super leg). A def field, not build state, so it arrives as an explicit param (the N2311/N2261 precedent).'),
        'min_range': a('float', 'Drawf.dashCircle(x, y, minRange(), team.color);', 'The live minRange() value (Turret.java:485, `Drawf.dashCircle(x, y, minRange(), team.color);`): minRange() (Turret.java:334, `public float minRange(){` with `return minRange + peekAmmo().minRangeChange;`, Turret.java:335) -- computed by the caller through N2340 source_turret_min_range_state and passed in as an explicit param, NOT re-ported here (the N2311/N2261 precedent). The field `minRange` (Turret.java:74, `public float minRange = 0f;`, "Minimum bullet range. Used for artillery only.") is evidence only.'),
        'team_color': a('String', 'Drawf.dashCircle(x, y, minRange(), team.color);', 'The building team color (Turret.java:485, `Drawf.dashCircle(x, y, minRange(), team.color);`): `team.color` -- the Team color of the building, passed as an explicit String param (the SourceBuildingDrawState draw_team precedent, `team_color: String`); no Color object is constructed and no playback happens.'),
    }
    select_outputs = {
        'draw_min_range_circle': a('bool', 'if(drawMinRange){', 'Whether the min-range dash circle is drawn (Turret.java:484, `if(drawMinRange){`): true when the def field drawMinRange is true, false otherwise (no circle is drawn after the super leg).'),
        'center': a('Vector2', 'Drawf.dashCircle(x, y, minRange(), team.color);', 'The dash-circle center (Turret.java:485, `Drawf.dashCircle(x, y, minRange(), team.color);`): the building position itself.'),
        'radius': a('float', 'Drawf.dashCircle(x, y, minRange(), team.color);', 'The dash-circle radius (Turret.java:485, `Drawf.dashCircle(x, y, minRange(), team.color);`): the live minRange() value when drawMinRange is true, 0.0 when false (no circle drawn).'),
        'color': a('String', 'Drawf.dashCircle(x, y, minRange(), team.color);', 'The dash-circle color (Turret.java:485, `Drawf.dashCircle(x, y, minRange(), team.color);`): the building team color, carried as the team_color String.'),
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
        ('N2334', DRAW_SELECT_OWNER, 'source_turret_draw_select_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.drawSelect()', select_inputs, select_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret drawSelect() row from Turret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret drawSelect() row from Turret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: draw_min_range_circle, center, radius, color.
    by_slice['N2334'] = [
        'source_turret_draw_select_state_result.draw_min_range_circle',
        'source_turret_draw_select_state_result.center',
        'source_turret_draw_select_state_result.radius',
        'source_turret_draw_select_state_result.color',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2334', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.drawSelect()', godot_owner=DRAW_SELECT_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2334'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
