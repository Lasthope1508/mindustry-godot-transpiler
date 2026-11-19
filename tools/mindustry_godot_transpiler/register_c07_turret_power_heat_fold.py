"""Register the Turret PowerTurret heat fold live wiring (N2270).

The deferred item named in the N2265 handoff and the N2269 report:
"efficiency fold for defs other than duo (afflict 20f / malign
144f are PowerTurrets, consumption branch riêng)". N2265 added
the pure fold function
(source_turret_efficiency_multiplier_state, Turret.java:674-679)
plus one driver tick in the duo branch with the class defaults
(-1.0 / 3.0, guard off) -- but the fold never ran for the two
defs that actually need it: afflict and malign are PowerTurrets
whose consumption branch is the generic power-consumer branch
of source_turret_tick_buildings_state, and the catalog never
captured their per-block heatRequirement / maxHeatEfficiency
overrides, so the driver had no values to fold with.

The fold itself (Turret.java:675-677):
`if(heatRequirement > 0){`
`efficiency *= Math.min(Math.max(heatReq / heatRequirement, cheating() ? 1f : 0f), maxHeatEfficiency);`
runs inside updateEfficiencyMultiplier(), which
updateConsumption() calls (BuildingComp.java:1949 cheating path
/ :1996 normal path) BEFORE updateTile() (:2274-2278), so it
reads the PREVIOUS tick's heatReq. Only afflict (PowerTurret,
`heatRequirement = 20f;`, Blocks.java:5122) and malign
(PowerTurret, `heatRequirement = 144f;`, Blocks.java:6240) set
a positive requirement among turrets -- and both override the
cap: `maxHeatEfficiency = 1f;` (Blocks.java:5123 / :6241), NOT
the class default 3f (Turret.java:55). A full-heat afflict
folds to 1.0x, never 3.0x -- the N2265 proof's cap-3.0 keys
used the class default, not the defs' own cap.

This slice is the N2143 catalog-capture pattern applied to the
turret fold: (1) the emitter captures heatRequirement /
maxHeatEfficiency for Turret-family blocks from the block
initializer's own assignment (the `range` / `reload` pattern --
only afflict and malign carry them); (2) one pure read on the
block, source_turret_heat_requirement_state(block), returns
{heat_requirement, max_heat_efficiency} -- the catalog values
when present, the class defaults -1.0 / 3.0 (Turret.java:53
`public float heatRequirement = -1f;`, :55 `public float
maxHeatEfficiency = 3f;`) otherwise, null-safe; (3) one driver
tick in the generic power-consumer consumption branch, right
after apply_update_consumption_state stamps the first-pass
efficiency, applies the existing fold with the read values and
stamps frame["efficiency"] -- Java order (updateConsumption
with the fold, then updateTile) and the previous-tick heatReq
read are preserved. The live calculateHeat proximity scan still
waits for its own slice (live entity scan, BLOCKED, N2263), so
frame["heat_req"] stays at its field default 0.0 and a
non-cheating afflict / malign with no heat folds to 0 -- the
faithful no-heater behavior. TurretBuild.canConsume()'s heat
gate (Turret.java:623-628, `if(heatRequirement > 0 && heatReq
<= 0f) return false;`) waits for its own slice: the driver
still has no shouldConsume gate (see the consumption-branch
comment in SourceTurretBuildState.gd). SSOT expected after
GREEN: symbols +2, Done +1, contracts +1, schema +2,
11638/1719/1653/3097 -> 11640/1720/1654/3099; defense shard
slices 196 -> 197, contracts 195 -> 196.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_queued_bullets import DEFERRED as N2269_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07TurretPowerHeatFoldProof'
HEAT_REQUIREMENT_OWNER = 'SourceTurretBuildState.source_turret_heat_requirement_state'
TESTS = ['test_c07_turret_power_heat_fold_registration', 'test_all_c07_turret_power_heat_fold_input_evidence_is_exact', 'test_turret_power_heat_fold_state', 'test_reference_graph_and_actual_c07_turret_power_heat_fold']
# The slice sources the N2270 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/content/Blocks.java',
]
EXACT_EXPRS = ['public float heatRequirement = -1f;', 'public float maxHeatEfficiency = 3f;', 'heatRequirement = 20f;', 'heatRequirement = 144f;', 'maxHeatEfficiency = 1f;', 'efficiency *= Math.min(Math.max(heatReq / heatRequirement, cheating() ? 1f : 0f), maxHeatEfficiency);', 'if(heatRequirement > 0){', 'public void updateEfficiencyMultiplier(){', 'updateEfficiencyMultiplier();', 'afflict = new PowerTurret("afflict"){{', 'malign = new PowerTurret("malign"){{', 'consumePower(5f);', 'consumePower(40f);']

# DEFERRED is carried from the N2269 register script via import --
# never retyped. The PowerTurret heat fold is done by this slice
# (it was the next item named in the N2269 handoff/report); the
# charge sound/effect, the canConsume() heat gate, calculateHeat
# live scan, findTarget, maxHealth/health re-sync, set(tile)
# world position and the other ItemTurret defs still wait.
DEFERRED = list(N2269_DEFERRED) + [
    'Turret PowerTurret heat fold Windows Godot proof -- debt in GOAL.md section 5, same as N2240-N2269: the N2270 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Turret efficiency fold for defs other than duo -- DONE by this slice (N2270); it was the next item named in the N2269 handoff/report. The catalog now captures heatRequirement / maxHeatEfficiency for Turret-family blocks (afflict 20f/1f, malign 144f/1f), the pure read exposes them with the class defaults (-1.0/3.0) otherwise, and the generic power-consumer consumption branch applies the N2265 fold with the read values.',
    'TurretBuild.canConsume() heat gate (Turret.java:623-628, `if(heatRequirement > 0 && heatReq <= 0f) return false;`) -- waits for its own slice; the driver still has no shouldConsume gate, so an unheated afflict/malign folds efficiency to 0 through the fold but is not yet gated out of consuming.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    heat_requirement_inputs = {
        'block': a('Object', 'afflict = new PowerTurret("afflict"){{', 'The block definition the read resolves (Blocks.java:5023): the catalog block whose properties carry the per-block heatRequirement / maxHeatEfficiency overrides, or the class defaults when it carries none. Malign is the same shape (Blocks.java:5925, `malign = new PowerTurret("malign"){{`).', source=BLOCKS),
    }
    heat_requirement_outputs = {
        'heat_requirement': a('float', 'public float heatRequirement = -1f;', 'The turret heat requirement in heat units (Turret.java:53, the class default; the read returns the catalog value when the block carries one -- 20.0 for afflict, Blocks.java:5122; 144.0 for malign, Blocks.java:6240).'),
        'max_heat_efficiency': a('float', 'public float maxHeatEfficiency = 3f;', 'The cap on the heat fold (Turret.java:55, the class default 3f; the read returns the catalog value when the block carries one -- 1.0 for afflict, Blocks.java:5123, and for malign, Blocks.java:6241).'),
    }
    return heat_requirement_inputs, heat_requirement_outputs


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
    heat_requirement_inputs, heat_requirement_outputs = definitions()

    entries = [
        ('N2270', HEAT_REQUIREMENT_OWNER, 'source_turret_heat_requirement_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.updateEfficiencyMultiplier()', heat_requirement_inputs, heat_requirement_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret heat requirement + cap read from Turret.java / Blocks.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret heat requirement + cap read from Turret.java / Blocks.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: heat_requirement, max_heat_efficiency.
    by_slice['N2270'] = [
        'source_turret_heat_requirement_state_result.heat_requirement',
        'source_turret_heat_requirement_state_result.max_heat_efficiency',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2270', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.updateEfficiencyMultiplier()', godot_owner=HEAT_REQUIREMENT_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2270'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
