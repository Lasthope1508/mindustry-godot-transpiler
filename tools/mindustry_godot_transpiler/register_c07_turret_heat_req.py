"""Register the Turret heatReq fold (N2263).

TurretBuild.updateTile (Turret.java:490-615) folds the heat
requirement every tick, after the logic-control timer decay
and before the rotate sync:
`if(heatRequirement > 0){`
`heatReq = calculateHeat(sideHeat);`
(Turret.java:538-540). `heatRequirement` defaults to -1
(Turret.java:53, `public float heatRequirement = -1f;`) and
duo never sets it (Blocks.java:3257-3331), so the guard is
false for duo and heatReq stays at its field default 0
(`public float heatReq;`, Turret.java:295). Only afflict
(PowerTurret, `heatRequirement = 20f;`, Blocks.java:5122)
and malign (PowerTurret, `heatRequirement = 144f;`,
Blocks.java:6240) set a positive requirement among turrets.
`calculateHeat(sideHeat)` is
`public float calculateHeat(float[] sideHeat){`
(BuildingComp.java:406) returning
`return calculateHeat(sideHeat, null);` (:407), which fills
the per-side array (`Arrays.fill(sideHeat, 0f);`, :411) from
the live proximity scan of same-team HeatBlock heaters
(`sideHeat[Mathf.mod(relativeTo(build), 4)] += add;`) and
returns the total heat (`return heat;`, :460). That scan is
a live entity scan -- BLOCKED, same class as findTarget --
so the scan itself is deferred and this slice captures only
the fold: guard + assign of the scan result, which arrives
as the pure function's heat_total / side_heat inputs. The
new C07 duo driver (N2250-N2262) never folded heatReq --
the frame had no heat_req or side_heat key at all. This
slice adds the one pure function on the shared TurretBuild
driver file (updateTile() is TurretBuild's method, common to
every turret, not ItemTurret-only) plus one driver tick in
the duo branch AFTER the N2261 logicControlTime tick and
BEFORE the N2262 rotate sync tick (Java order :534-536
decay, :538-540 heatReq, :542-545 rotate sync, :595-596
turnToTarget, :601/:609 updateShooting).

GREEN decisions (pinned by this slice): (1) One pure function
on SourceTurretBuildState.gd,
source_turret_heat_req_state(heat_requirement, heat_total,
side_heat, heat_req), returning `{"heat_req": ..,
"side_heat": ..}` -- when the requirement is not positive
both are returned unchanged, exactly what Java does by
skipping the assignment; when it is positive heat_req takes
the scan total and side_heat takes the scan's per-side
array. (2) One driver tick in the duo branch (right after
the N2261 logicControlTime tick, before the N2262 rotate
sync tick) that passes the duo catalog requirement -1.0
(never overridden), the deferred scan total 0.0 (never
assigned while the guard is off), the frame side_heat
(default four zeros, the field default) and the frame
heat_req (default 0.0, the field default), calls the pure
function, then stamps both keys back on the frame. (3) The
live calculateHeat proximity scan waits for its own slice
-- live entity scan, BLOCKED. (4) No legacy
`source_turret_heat_req_state_result` schema exists (unlike
N2258's recoilOffset), so the contract validator falls
through to the new `source_turret_heat_req_state_result`
schema and no alias is needed. SSOT expected after GREEN:
symbols +2, Done +1, contracts +1, schema +2,
11620/1712/1646/3083 -> 11622/1713/1647/3085; defense
shard slices 191 -> 192, contracts 190 -> 191.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_rotate_sync import DEFERRED as N2262_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07TurretHeatReqProof'
HEAT_REQ_OWNER = 'SourceTurretBuildState.source_turret_heat_req_state'
TESTS = ['test_c07_turret_heat_req_registration', 'test_all_c07_turret_heat_req_input_evidence_is_exact', 'test_turret_heat_req_state', 'test_reference_graph_and_actual_c07_turret_heat_req']
# The slice sources the N2263 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/content/Blocks.java',
]
EXACT_EXPRS = ['if(heatRequirement > 0){', 'heatReq = calculateHeat(sideHeat);', 'public float heatRequirement = -1f;', 'public float heatReq;', 'public float[] sideHeat = new float[4];', 'public float calculateHeat(float[] sideHeat){', 'return calculateHeat(sideHeat, null);', 'Arrays.fill(sideHeat, 0f);', 'heatRequirement = 20f;', 'heatRequirement = 144f;']

# DEFERRED is carried from the N2262 register script via import --
# never retyped. The heatReq fold is done by this slice (it was
# the next item named in the N2262 handoff); the calculateHeat
# live proximity scan, the control() setters, the maxHealth/health
# re-sync, the set(tile) world position, the cross-tick
# queuedBullets counter, effects/sound, findTarget / the other
# ItemTurret defs still wait.
DEFERRED = list(N2262_DEFERRED) + [
    'Turret heatReq fold Windows Godot proof -- debt in GOAL.md section 5, same as N2240-N2262: the N2263 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Turret heatReq fold (Turret.java:538-540) -- DONE by this slice (N2263); it was the next item named in the N2262 handoff.',
    'calculateHeat live proximity scan (BuildingComp.java:410-461) -- BLOCKED, live entity scan: the proximity walk over same-team HeatBlock heaters, the facing/rotation checks, the contact-point math and the split-heat division need live neighbor entities; the fold only takes the scan result as input.',
    'Turret heatReq fold for defs other than duo -- the pure function takes heat_requirement / heat_total / side_heat / heat_req as params; only duo is wired in the driver (afflict 20f and malign 144f are the only turrets with a positive requirement).',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    heat_req_inputs = {
        'heat_requirement': a('float', 'public float heatRequirement = -1f;', 'The turret heat requirement in heat units before this tick (Turret.java:53, the class default; duo never overrides it, Blocks.java:3257-3331; the driver passes -1.0 for duo).'),
        'heat_total': a('float', 'return heat;', 'The calculateHeat scan total before this tick (BuildingComp.java:460, the return of calculateHeat(sideHeat, cameFrom); the live scan is deferred, so the driver passes 0.0 for duo -- never assigned while the guard is off).', source=BUILDING_COMP),
        'side_heat': a('Array', 'public float[] sideHeat = new float[4];', 'The per-side heat array before this tick (Turret.java:296, the field default is four zeros; the driver reads frame["side_heat"], default four zeros).'),
        'heat_req': a('float', 'public float heatReq;', 'The folded heat requirement value before this tick (Turret.java:295, the field default is 0; the driver reads frame["heat_req"], default 0.0).'),
    }
    heat_req_outputs = {
        'heat_req': a('float', 'heatReq = calculateHeat(sideHeat);', 'The folded heat requirement value after the tick (Turret.java:539 -- the calculateHeat total when heatRequirement > 0, unchanged otherwise; the driver stamps it on frame["heat_req"]).'),
        'side_heat': a('Array', 'sideHeat[Mathf.mod(relativeTo(build), 4)] += add;', 'The per-side heat array after the tick (BuildingComp.java:436 -- the scan fills one side per heater; the driver stamps it on frame["side_heat"]).', source=BUILDING_COMP),
    }
    return heat_req_inputs, heat_req_outputs


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
    heat_req_inputs, heat_req_outputs = definitions()

    entries = [
        ('N2263', HEAT_REQ_OWNER, 'source_turret_heat_req_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.updateTile()', heat_req_inputs, heat_req_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret heatReq fold from Turret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret heatReq fold from Turret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: heat_req, side_heat.
    by_slice['N2263'] = [
        'source_turret_heat_req_state_result.heat_req',
        'source_turret_heat_req_state_result.side_heat',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2263', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.updateTile()', godot_owner=HEAT_REQ_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2263'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
