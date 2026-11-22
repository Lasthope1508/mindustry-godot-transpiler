"""Register the Turret drawrot() read (N2532).

TurretBuild.drawrot() (Turret.java:359-362):
`public float drawrot(){` /
`return rotation - 90;`
-- it uses the `rotation` AIM rotation field
(`public float rotation = 90;`, BaseTurret.java:114), NOT
the Building quadrant rotation (0-3). It overrides the
BuildingComp base (`public float drawrot(){` /
`return block.rotate && block.rotateDraw ? rotation * 90 : 0f;`,
BuildingComp.java:587-588), which uses quadrants * 90; the
Turret override ignores block.rotate / block.rotateDraw
and returns aim rotation - 90. NOT the PointDefense draw
state (SourcePointDefenseTurretBuildState.gd:678, key
`draw_rotation` inside source_point_defense_turret_draw_state
-- a different function for PointDefenseBuild.draw(), same
quantity, different key, no clash). Java has NO clamp/wrap
guard in drawrot() (Turret.java:584 only guards inside
updateTile, not in drawrot), so negative and >360 rotations
pass through unchanged. NO driver tick call site: drawrot()
is a read, not per-tick, and its only callers are draw code
(DrawTurret / DrawDefault), which is rendering outside the
game boundary.

GREEN decisions (pinned by this slice): (1) One pure
function on SourceTurretBuildState.gd,
source_turret_drawrot_state(rotation), placed immediately
AFTER source_turret_fog_radius_state (N2531) and BEFORE
source_turret_can_heal_state. It returns exactly one key,
`drawrot`. (2) NO tick call site -- the function is DORMANT
live today: the driver tick never calls it, so live behavior
does not change. (3) Every Java input stays an explicit
param -- the function never guesses the catalog in the
function body (the N2526/N2527/N2528 param-driven precedent).
SSOT expected after GREEN: symbols +1, Done +1, contracts
+1, schemas +2, 11725/1760/1693/3177 -> 11726/1761/1694/3179;
defense shard slices 218 -> 219, contracts 217 -> 218; comp
stays 572/475.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_fog_radius import DEFERRED as N2531_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
BASE_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
PROOF = '/root/C07TurretDrawrotProof'
DRAWROT_OWNER = 'SourceTurretBuildState.source_turret_drawrot_state'
TESTS = ['test_c07_turret_drawrot_registration', 'test_all_c07_turret_drawrot_input_evidence_is_exact', 'test_turret_drawrot_state', 'test_reference_graph_and_actual_c07_turret_drawrot']
# The slice sources the N2532 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
]
EXACT_EXPRS = [
    'public float drawrot(){',
    'return rotation - 90;',
    'public float rotation = 90;',
    'return block.rotate && block.rotateDraw ? rotation * 90 : 0f;',
]

# DEFERRED is carried from the N2531 register script via import --
# never retyped. No entry is dropped: the drawrot read the
# N2531 pool entry deferred is recorded DONE below. New entries
# below record the drawrot read as DONE by this slice and the
# Windows proof debt.
DEFERRED = N2531_DEFERRED + [
    'Turret drawrot() (`drawrot` frame key) -- DONE by this slice (N2532): `source_turret_drawrot_state` ports Turret.java:359-362 (`return rotation - 90;`, `rotation` = `public float rotation = 90;`, BaseTurret.java:114, the aim rotation in degrees) for the Turret family. NO driver tick call site: drawrot() is a read, not per-tick, and its only callers are draw code (DrawTurret / DrawDefault), which is rendering outside the game boundary. Dormant live today: the driver tick never calls the function, so live behavior does not change. NOT the BuildingComp base drawrot (BuildingComp.java:587-588, quadrants * 90) and NOT the PointDefense draw state (key `draw_rotation`, a different function).',
    'Turret drawrot() Windows Godot proof -- debt in GOAL.md section 5, same as N2283-N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515/N2516/N2517/N2518/N2519/N2520/N2521/N2522/N2523/N2524/N2525/N2526/N2527/N2528/N2529/N2530/N2531: the N2532 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    drawrot_inputs = {
        'rotation': a('float', 'public float rotation = 90;', 'The aim rotation in degrees (`public float rotation = 90;`, BaseTurret.java:114 -- the BaseTurretBuild field, default 90; it SHADOWS the Building quadrant rotation (0-3), Turret.java:543-544 comment `//sync underlying rotation; 0-3 rotation is a shadowed field`). An explicit float param, NOT read from the frame (the N2528/N2529/N2530/N2531 param-driven precedent).', source=BASE_TURRET),
    }
    drawrot_outputs = {
        'drawrot': a('float', 'public float drawrot(){', 'The Turret draw rotation (`public float drawrot(){` / `return rotation - 90;`, Turret.java:359-362 -- the TurretBuild override of the BuildingComp base drawrot (`return block.rotate && block.rotateDraw ? rotation * 90 : 0f;`, BuildingComp.java:587-588), which uses quadrants * 90).'),
    }
    return drawrot_inputs, drawrot_outputs


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
    drawrot_inputs, drawrot_outputs = definitions()

    entries = [
        ('N2532', DRAWROT_OWNER, 'source_turret_drawrot_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.drawrot()', drawrot_inputs, drawrot_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret drawrot() read from Turret.java:359-362 + BaseTurret.java:114 + BuildingComp.java:587-588.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret drawrot() read from Turret.java:359-362 + BaseTurret.java:114 + BuildingComp.java:587-588.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: drawrot.
    by_slice['N2532'] = [
        'source_turret_drawrot_state_result.drawrot',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2532', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.drawrot()', godot_owner=DRAWROT_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2532'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
