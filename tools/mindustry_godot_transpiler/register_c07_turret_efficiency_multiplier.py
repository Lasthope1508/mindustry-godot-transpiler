"""Register the Turret efficiency fold (N2265).

TurretBuild.updateEfficiencyMultiplier() (Turret.java:674-679)
overrides BuildingComp's (BuildingComp.java:1932-1935,
`float scale = efficiencyScale();` /
`efficiency *= scale;` / `optionalEfficiency *= scale;`)
with the heat fold:
`if(heatRequirement > 0){`
`efficiency *= Math.min(Math.max(heatReq / heatRequirement, cheating() ? 1f : 0f), maxHeatEfficiency);`
(Turret.java:675-677). The override replaces the base --
it does not call super and never touches
optionalEfficiency -- and it runs inside
updateConsumption() (BuildingComp.java:1949 cheating path /
:1996 normal path), which BuildingComp.update() calls
BEFORE updateTile() (:2274-2278), so the fold reads the
PREVIOUS tick's heatReq: heatReq is only recomputed later
in updateTile() (:538-540, N2263). `heatRequirement`
defaults to -1 (Turret.java:53, `public float
heatRequirement = -1f;`) and duo never sets it
(Blocks.java:3257-3331), so the guard is false for duo and
efficiency stays at the first-pass value
(BuildingComp.java:1946, 1.0 when enabled and
production-valid). Only afflict (PowerTurret,
`heatRequirement = 20f;`, Blocks.java:5122) and malign
(PowerTurret, `heatRequirement = 144f;`,
Blocks.java:6240) set a positive requirement among turrets,
with `public float maxHeatEfficiency = 3f;`
(Turret.java:55) capping the fold at 3x. `cheating()` is
`public boolean cheating(){` / `return
team.rules().cheat;` (TeamComp.java:17-19, N2099 stamps it
live on frame["cheating"] every tick), so a cheating team
floors the ratio at 1.0 and never loses efficiency to
missing heat, while a non-cheating team with no heat folds
to 0. The new C07 duo driver (N2250-N2264) never folded
efficiency -- the frame's efficiency key only carried the
first-pass value. This slice adds the one pure function on
the shared TurretBuild driver file plus one driver tick in
the duo branch BEFORE the N2253 warmup tick (Java order:
updateConsumption with the fold, then updateTile's warmup
:512-514 -- the warmup lerp reads efficiency as its rate,
so the fold must land first).

GREEN decisions (pinned by this slice): (1) One pure function
on SourceTurretBuildState.gd,
source_turret_efficiency_multiplier_state(efficiency,
heat_requirement, heat_req, cheating, max_heat_efficiency),
returning `{"efficiency": ..}` -- when the requirement is
not positive efficiency is returned unchanged, exactly what
Java does by skipping the fold; when it is positive
efficiency is multiplied by min(max(heatReq /
heatRequirement, cheating ? 1.0 : 0.0), maxHeatEfficiency).
(2) One driver tick in the duo branch (right before the
N2253 warmup tick) that passes the frame efficiency
(default 1.0, the enabled + production-valid first pass),
the duo catalog requirement -1.0 (never overridden), the
previous tick's frame heat_req (default 0.0, the field
default), the frame cheating flag (live, N2099) and the
class max 3.0, calls the pure function, then stamps
efficiency back on the frame. (3) The live calculateHeat
proximity scan waits for its own slice -- live entity scan,
BLOCKED (N2263). (4) No legacy
`source_turret_efficiency_multiplier_state_result` schema
exists (unlike N2258's recoilOffset), so the contract
validator falls through to the new
`source_turret_efficiency_multiplier_state_result` schema
and no alias is needed. SSOT expected after GREEN:
symbols +1, Done +1, contracts +1, schema +2,
11626/1714/1648/3087 -> 11627/1715/1649/3089; defense
shard slices 193 -> 194, contracts 192 -> 193.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_control import DEFERRED as N2264_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
TEAM_COMP = 'core/src/mindustry/entities/comp/TeamComp.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07TurretEfficiencyMultiplierProof'
EFFICIENCY_OWNER = 'SourceTurretBuildState.source_turret_efficiency_multiplier_state'
TESTS = ['test_c07_turret_efficiency_multiplier_registration', 'test_all_c07_turret_efficiency_multiplier_input_evidence_is_exact', 'test_turret_efficiency_multiplier_state', 'test_reference_graph_and_actual_c07_turret_efficiency_multiplier']
# The slice sources the N2265 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/entities/comp/TeamComp.java',
    'core/src/mindustry/content/Blocks.java',
]
EXACT_EXPRS = ['efficiency *= Math.min(Math.max(heatReq / heatRequirement, cheating() ? 1f : 0f), maxHeatEfficiency);', 'if(heatRequirement > 0){', 'public float heatRequirement = -1f;', 'public float maxHeatEfficiency = 3f;', 'public float heatReq;', 'public boolean cheating(){', 'return team.rules().cheat;', 'public void updateEfficiencyMultiplier(){', 'float scale = efficiencyScale();', 'efficiency *= scale;', 'updateEfficiencyMultiplier();', 'heatRequirement = 20f;', 'heatRequirement = 144f;']

# DEFERRED is carried from the N2264 register script via import --
# never retyped. The efficiency fold is done by this slice (it was
# the next item named in the N2264 handoff); the targetPosition(pos)
# call, the calculateHeat live proximity scan, the maxHealth/health
# re-sync, the set(tile) world position, the cross-tick
# queuedBullets counter, effects/sound, findTarget / the other
# ItemTurret defs still wait.
DEFERRED = list(N2264_DEFERRED) + [
    'Turret efficiency fold Windows Godot proof -- debt in GOAL.md section 5, same as N2240-N2264: the N2265 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Turret efficiency fold (Turret.java:676) -- DONE by this slice (N2265); it was the next item named in the N2264 handoff.',
    'Turret efficiency fold for defs other than duo -- the pure function takes heat_requirement / heat_req / cheating / max_heat_efficiency as params; only duo is wired in the driver (afflict 20f and malign 144f are the only turrets with a positive requirement, and both are PowerTurrets whose consumption branch is a separate slice).',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    efficiency_inputs = {
        'efficiency': a('float', 'transient float efficiency;', 'The first-pass efficiency before the fold (BuildingComp.java:85, the field; the driver reads frame["efficiency"], default 1.0 -- the enabled + production-valid first pass, BuildingComp.java:1946).', source=BUILDING_COMP),
        'heat_requirement': a('float', 'public float heatRequirement = -1f;', 'The turret heat requirement in heat units (Turret.java:53, the class default; duo never overrides it, Blocks.java:3257-3331; the driver passes -1.0 for duo).'),
        'heat_req': a('float', 'public float heatReq;', 'The folded heat requirement value from the PREVIOUS tick (Turret.java:295, the field default is 0; updateConsumption runs before updateTile, so the fold reads the previous tick\'s value -- the driver reads frame["heat_req"], the N2263 stamp, default 0.0).'),
        'cheating': a('bool', 'return team.rules().cheat;', 'Whether the turret team is cheating (TeamComp.java:18; N2099 stamps it live on frame["cheating"] every tick -- a cheating team floors the ratio at 1.0).', source=TEAM_COMP),
        'max_heat_efficiency': a('float', 'public float maxHeatEfficiency = 3f;', 'The cap on the heat fold (Turret.java:55, the class default 3f; the driver passes 3.0 for duo).'),
    }
    efficiency_outputs = {
        'efficiency': a('float', 'efficiency *= Math.min(Math.max(heatReq / heatRequirement, cheating() ? 1f : 0f), maxHeatEfficiency);', 'The efficiency after the fold (Turret.java:676 -- the first-pass value times min(max(heatReq / heatRequirement, cheating ? 1.0 : 0.0), maxHeatEfficiency) when heatRequirement > 0, unchanged otherwise; the driver stamps it on frame["efficiency"]).'),
    }
    return efficiency_inputs, efficiency_outputs


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
    efficiency_inputs, efficiency_outputs = definitions()

    entries = [
        ('N2265', EFFICIENCY_OWNER, 'source_turret_efficiency_multiplier_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.updateEfficiencyMultiplier()', efficiency_inputs, efficiency_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret efficiency fold from Turret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret efficiency fold from Turret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: efficiency.
    by_slice['N2265'] = [
        'source_turret_efficiency_multiplier_state_result.efficiency',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2265', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.updateEfficiencyMultiplier()', godot_owner=EFFICIENCY_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2265'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
