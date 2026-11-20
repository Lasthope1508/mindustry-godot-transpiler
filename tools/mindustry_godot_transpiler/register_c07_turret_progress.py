"""Register the Turret progress() derivation (N2282).

progress() is `public float progress(){ return
Mathf.clamp(reloadCounter / reload); }`
(Turret.java:425-427) on the fields `public float
reloadCounter;` (ReloadTurret.java:26, inherited by
TurretBuild via ReloadTurretBuild -- the driver already
stamps it live as frame["reload_counter"] from the aim
tick, capped at reload by updateReload :720-723) and
`public float reload = 10f;` (ReloadTurret.java:10, the
class default; duo overrides `reload = 20f;`,
Blocks.java:3317 -- the driver aim call already passes
20.0). Mathf.clamp(float) is `return Math.max(Math.min(
value, 1f), 0f);` (arc Mathf.java:402-404) -- GDScript
clampf(value, 0.0, 1.0) is the same min-then-max. The
only Java consumer is sense() LAccess.progress (`case
progress -> progress();`, Turret.java:414); the sense
dispatch is its own later slice, so no consumer is
rewired: this slice is stamp-only like N2280/N2281, one
pure function plus one driver tick. The driver tick runs
right after the reload_counter stamp, once the counter is
final for this tick, so the frame carries the verdict as
a live key for the future sense() slice to feed.

GREEN decisions (pinned by this slice): (1) One pure function
on SourceTurretBuildState.gd,
source_turret_progress_state(reload_counter, reload),
returning `{"progress": ..}` -- the Java return verbatim.
It sits immediately BEFORE source_turret_is_shooting_state
(Java order: progress :425-427 before isShooting
:440-442). Plus one driver tick in the duo branch (right
after the reload_counter stamp) that derives the verdict
live from the frame counter and the duo reload and stamps
it on frame["progress"]. (2) No consumer is rewired: the
sense() LAccess.progress dispatch (Turret.java:414) waits
for its own slice; both the dispatch and the other sense
cases need the logic-executor / sensor plumbing the port
does not have yet. (3) No legacy
`source_turret_progress_result` schema exists, so the
contract validator falls through to the new
source_turret_progress_state_result schema and no alias
is needed. SSOT expected after GREEN: symbols +1, Done +1,
contracts +1, schema +2, 11658/1731/1665/3121 ->
11659/1732/1666/3123; defense shard slices 208 -> 209,
contracts 207 -> 208.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_can_heal import DEFERRED as N2281_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
RELOAD_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java'
MATHF = 'arc-core/src/arc/math/Mathf.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07TurretProgressProof'
PROGRESS_OWNER = 'SourceTurretBuildState.source_turret_progress_state'
TESTS = ['test_c07_turret_progress_registration', 'test_all_c07_turret_progress_input_evidence_is_exact', 'test_turret_progress_state', 'test_reference_graph_and_actual_c07_turret_progress']
# The slice sources the N2282 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'arc-core/src/arc/math/Mathf.java',
    'core/src/mindustry/content/Blocks.java',
]
EXACT_EXPRS = [
    'public float progress(){',
    'return Mathf.clamp(reloadCounter / reload);',
    'case progress -> progress();',
    'return Math.max(Math.min(value, 1f), 0f);',
    'reload = 20f;',
]

# DEFERRED is carried from the N2281 register script via import --
# never retyped. progress() is done by this slice; the
# sense() dispatch, validateTarget effective-team wiring,
# findTarget, shootp / calculateHeat / the other ItemTurret
# defs / controlled() still wait.
DEFERRED = list(N2281_DEFERRED) + [
    'Turret progress() (`return Mathf.clamp(reloadCounter / reload);`, Turret.java:425-427) -- DONE by this slice (N2282); the pure function ports the Java return verbatim and the duo driver stamps frame["progress"] live right after the reload_counter stamp. Duo has no consumer yet; the stamp is for the future sense() slice.',
    'Turret sense() LAccess.progress dispatch (`case progress -> progress();`, Turret.java:414) -- NOT this slice; the sense dispatch is its own later slice (it needs the logic-executor / sensor plumbing the port does not have yet); progress live will feed it when that slice lands.',
    'Turret progress() for defs other than duo -- the pure function takes reload_counter / reload as params; only duo is wired in the driver.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    progress_inputs = {
        'reload_counter': a('float', 'public float reloadCounter;', 'The live reload counter (ReloadTurret.java:26, inherited by TurretBuild via ReloadTurretBuild; the driver stamps it live as frame["reload_counter"] from the aim tick, capped at reload by updateReload :720-723).', source=RELOAD_TURRET),
        'reload': a('float', 'public float reload = 10f;', 'The reload interval in ticks (ReloadTurret.java:10, the class default; duo overrides `reload = 20f;`, Blocks.java:3317, the same 20.0 the driver aim call already passes).', source=RELOAD_TURRET),
    }
    progress_outputs = {
        'progress': a('float', 'return Mathf.clamp(reloadCounter / reload);', 'The reload progress as a 0..1 fraction (Turret.java:425-427, the progress() return verbatim; Mathf.clamp(float) is `return Math.max(Math.min(value, 1f), 0f);`, arc Mathf.java:402-404, so GDScript clampf(value, 0.0, 1.0) is the same min-then-max; the driver stamps it on frame["progress"] right after the reload_counter stamp).'),
    }
    return progress_inputs, progress_outputs


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
    progress_inputs, progress_outputs = definitions()

    entries = [
        ('N2282', PROGRESS_OWNER, 'source_turret_progress_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.progress()', progress_inputs, progress_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret progress() derivation from TurretBuild.progress() / Turret.java:425-427.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret progress() derivation from TurretBuild.progress() / Turret.java:425-427.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: progress.
    by_slice['N2282'] = [
        'source_turret_progress_state_result.progress',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2282', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.progress()', godot_owner=PROGRESS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2282'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
