"""Register BuildTurretBuild.warmup() (N2482).

BuildTurretBuild.warmup() (BuildTurret.java:254-255) is one
slice (batch 53 slot 1):
    @Override
    public float warmup(){
        return warmup;
    }
on `public class BuildTurretBuild extends BaseTurretBuild
implements ControlBlock, RotBlock{` (BuildTurret.java:92).
The field `public float warmup;` (BuildTurret.java:96)
is lerped by updateTile every tick (`warmup =
Mathf.lerpDelta(warmup, unit.activelyBuilding() ?
efficiency : 0f, 0.1f);`, BuildTurret.java:136-137)
and read by draw() for the glow (`Drawf.additive(
glowRegion, heatColor, warmup, x, y, rotation - 90f,
Layer.turretHeat);`, BuildTurret.java:247) -- but this
slice is ONLY the accessor: return the field whole, no
clamp, no floor. The trap is that warmup follows
efficiency, and efficiency > 1 passes through whole (a
port clamping to [0, 1] is wrong -- the proof pins
warmup = 1.5 -> 1.5), and a negative warmup passes
through (Java has no Math.min/max here; the lerp target
is 0f or efficiency, and the field itself is never
clamped). Do NOT confuse with TurretBuild.warmup()
(N2297, Turret.java:354-356, `return shootWarmup;` --
the parent-class method reading a different field,
`public float shootWarmup, charge, warmupHold = 0f;`,
Turret.java:1592). One GD function on the existing file
SourceBuildTurretBuildState.gd, placed after
source_build_turret_should_consume_state (Java
shouldConsume :229-230) and before
source_build_turret_read_plans_state (Java read
:266-278), because warmup() (:254-255) stands after
draw() (:234-251) and before write() (:259-265) in Java
order. One input (the precomputed warmup field) + one
output. One slice source: BuildTurret.java.

TWIN-REGISTER -- approved explicitly by the main thread
for N2482 (2026-11-27). The body literals are ALREADY
exact_exprs of N2184 (BuildTurretBuild.updateTile, owner
GD SourceBuildTurretBuildState.
source_build_turret_power_status_row_state): the decl
`public float warmup(){` hits N1625/N910/N2182/N2184/
N2186/N2232/N2297 and the body `return warmup;` hits
N2182/N2184/N2186/N2232, but N2184 cites the
BuildTurret.java:254-255 rows only as dependency
evidence for its power-status/updateTile rows -- N2184
ports NO warmup function (its godot_owner is the
power-status row state), and its own deferred_exprs say
"BuildTurret warmup / setStats rows (warmup() returns
warmup, BuildTurret.java:254-255; ...) -- accessor/stats,
not tick state; waits for its own slice", i.e. N2184
itself declares warmup waits for its own slice. The
other literal hits are other methods: N1625/N910 (bare
warmup()), N2182/N2186 (ImpactReactor updateTile),
N2232 (RepairTower, Windows line), N2297
(TurretBuild.warmup, `return shootWarmup;` -- a
different field in the parent class). java_method
`BuildTurretBuild.warmup()` is 0-hit, registry
`build_turret_warmup` is 0-hit, and no GD function
computes it yet, so this slice adds a real new GD
function -- NOT a duplicate like TeamData.active(),
which was permanently excluded because its behaviour
was already ported by N2074/N2075. Precedent for twin
registration with explicit main-thread approval: N2474
(isCampaign, literal owned by N2124), N2477/N2480
(buildRotation/canControl, literals owned by N2184 --
the same owner and the same BuildTurret.java cluster),
N2421 (`return isShooting;`), N2389, N2418. One slice
source: BuildTurret.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BUILD_TURRET = 'core/src/mindustry/world/blocks/defense/BuildTurret.java'
PROOF = '/root/C07BuildTurretWarmupProof'
WARMUP_OWNER = 'SourceBuildTurretBuildState.source_build_turret_warmup_state'
TESTS = ['test_c07_build_turret_warmup_registration', 'test_all_c07_build_turret_warmup_input_evidence_is_exact', 'test_build_turret_warmup_state', 'test_reference_graph_and_actual_c07_build_turret_warmup']
# The 1 slice source the N2482 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/BuildTurret.java',
]
FORMULA = '            return warmup;'
EXACT_EXPRS = [
    '        public float warmup(){',
    FORMULA,
    '        public float warmup;',
    '    public class BuildTurretBuild extends BaseTurretBuild implements ControlBlock, RotBlock{',
]
JAVA_METHOD = 'BuildTurretBuild.warmup()'

DEFERRED = [
    'BuildTurretBuild.warmup() Windows Godot proof -- debt in GOAL.md section 5: the N2482 proof runs headless on Linux here and waits for a Windows Godot run.',
    'BuildTurretBuild.warmup() is a TWIN-REGISTER with explicit main-thread approval (2026-11-27): the literals `public float warmup(){` and `return warmup;` are also exact_exprs of N2184 (BuildTurretBuild.updateTile), which cites the BuildTurret.java:254-255 rows only as dependency evidence and ports no warmup function; N2184 is the original owner of the literals, and its own deferred_exprs say "BuildTurret warmup / setStats rows (warmup() returns warmup, BuildTurret.java:254-255; ...) -- accessor/stats, not tick state; waits for its own slice". The other literal hits are other methods: N1625/N910 (bare warmup()), N2182/N2186 (ImpactReactor updateTile), N2232 (RepairTower, Windows line), N2297 (TurretBuild.warmup, `return shootWarmup;` -- a different field in the parent class). Precedent: N2474, N2477, N2480, N2421, N2389, N2418.',
    'TurretBuild.warmup() (Turret.java:354-356, N2297, `return shootWarmup;`) is NOT in this slice: it is the parent-class method reading the `shootWarmup` field (Turret.java:1592) -- a tower with warmup = 1.5 and shootWarmup = 0.25 returns different values in the two methods; the proof pins the cross-trap.',
    'BuildTurretBuild.updateTile() warmup lerp (BuildTurret.java:136-137, `warmup = Mathf.lerpDelta(warmup, unit.activelyBuilding() ? efficiency : 0f, 0.1f);`) is NOT in this slice: this slice only reads the warmup field whole; the per-tick advance of the field stays with N2184.',
    'BuildTurretBuild.draw() glow use of warmup (BuildTurret.java:247, `Drawf.additive(glowRegion, heatColor, warmup, x, y, rotation - 90f, Layer.turretHeat);`) is NOT in this slice: presentation, not state; the draw rows wait for their own slice.',
]


def definitions():
    def a(typ, expr, rule, source=BUILD_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    warmup_inputs = {
        'warmup': a('float', FORMULA, 'The build-tower warmup field (BuildTurret.java:254-255): the BuildTurretBuild field `public float warmup;` (BuildTurret.java:96), lerped by updateTile every tick (`warmup = Mathf.lerpDelta(warmup, unit.activelyBuilding() ? efficiency : 0f, 0.1f);`, BuildTurret.java:136-137), returned whole -- no clamp, no floor.'),
    }
    warmup_outputs = {
        'warmup': a('float', FORMULA, 'The warmup value (BuildTurret.java:254-255): `warmup` returned whole -- 0 stays 0.0, 1.5 passes through (efficiency > 1 is not clamped), a negative value passes through (no Math.min/max here).'),
    }
    return warmup_inputs, warmup_outputs


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
    warmup_inputs, warmup_outputs = definitions()

    entries = [
        ('N2482', WARMUP_OWNER, 'source_build_turret_warmup_state', BUILD_TURRET, 'mindustry.world.blocks.defense.BuildTurret.BuildTurretBuild', JAVA_METHOD, warmup_inputs, warmup_outputs, True, 'Dictionary'),
    ]
    all_names = []
    for sid, owner, prefix, source, cls, method, inputs, outputs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                # N2096 symbol naming: schema name + '.' + field.
                symbol = name + '.' + field
                names.append(symbol)
                symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BuildTurretBuild.warmup() state from BuildTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BuildTurretBuild.warmup() state from BuildTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2482'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2482', dict(status='done', java_source=BUILD_TURRET, java_class='mindustry.world.blocks.defense.BuildTurret.BuildTurretBuild', java_method=JAVA_METHOD, godot_owner=WARMUP_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2482'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
