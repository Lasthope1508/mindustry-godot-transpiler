"""Register the Turret activationTimer decay (N2279).

The activation gate is `if(activationTimer > 0){
activationTimer -= Time.delta; return; }` (Turret.java:561-564)
on the field `public float activationTimer = 0;`
(BaseTurret.java:115, set to activationTime in placed()
:119-120), where `public float activationTime = 0f;`
(BaseTurret.java:27) is the class default. It gates the
aim/shoot half of TurretBuild.updateTile(): right after the
rotate sync (:542-545) and before the hasAmmo block (:566+),
a turret whose activation timer is still positive decays it
by Time.delta and returns before aiming or shooting. Duo
never overrides activationTime (Blocks.java:3257-3331), and
no turret def in Blocks.java sets it above 0, so the duo
timer is always 0.0 and the gate never fires -- the same
vacuous-guard precedent as the N2270 heat fold and the N2263
heatReq fold: the tick still stamps both keys so the frame
mirrors the TurretBuild fields. The timer decays by delta
while positive, with NO clamp (the N2261 precedent); the
elapsed verdict is the gate itself evaluated on the INPUT
timer -- Java returns before the rest of the tick when the
input is positive, even if this tick's decay would cross
zero. It is the same `activationTimer <= 0` clause
BaseTurret.status() uses (:144). The early-return skip of
the aim/shoot half is NOT wired in this slice: the gate
never fires for duo, so restructuring the aim block for a
never-firing guard is churn, and it waits for a def with
activationTime > 0.

GREEN decisions (pinned by this slice): (1) One pure function
on SourceTurretBuildState.gd,
source_turret_activation_timer_state(activation_timer, delta),
returning `{"activation_timer": .., "activation_timer_elapsed":
..}` -- the Java gate verbatim, no formula invented. It sits
immediately AFTER source_turret_rotate_sync_state (Java order
:542-545 rotate sync, then :561-564 activation gate). Plus one
driver tick in the duo branch (between the rotate sync tick
and the aim call) that decays the timer live from the frame
value and stamps both keys back on the frame. (2) isActive()
(`(target != null || wasShooting) && enabled &&
activationTimer <= 0`, Turret.java:448-450) is NOT this slice
-- it is the N2280 candidate now that activation_timer is
stamped; only LaserTurret consumes it in Java, and duo has no
consumer. (3) No legacy
`source_turret_activation_timer_result` schema exists, so the
contract validator falls through to the new
source_turret_activation_timer_state_result schema and no alias
is needed. SSOT expected after GREEN: symbols +2, Done +1,
contracts +1, schema +2, 11654/1728/1662/3115 ->
11656/1729/1663/3117; defense shard slices 205 -> 206,
contracts 204 -> 205.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_is_shooting import DEFERRED as N2277_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
BASE_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java'
PROOF = '/root/C07TurretActivationTimerProof'
ACTIVATION_TIMER_OWNER = 'SourceTurretBuildState.source_turret_activation_timer_state'
TESTS = ['test_c07_turret_activation_timer_registration', 'test_all_c07_turret_activation_timer_input_evidence_is_exact', 'test_turret_activation_timer_state', 'test_reference_graph_and_actual_c07_turret_activation_timer']
# The slice sources the N2279 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
]
EXACT_EXPRS = [
    'if(activationTimer > 0){',
    'activationTimer -= Time.delta;',
    'public float activationTimer = 0;',
    'activationTimer = activationTime;',
    'public float activationTime = 0f;',
]

# DEFERRED is carried from the N2277 register script via import --
# (merge 2026-11-23: N2278 logicControlled dropped, deduped into N2297 --
# the chain skips it; its Windows-proof debt is moot with the slice).
# never retyped. The activationTimer decay is done by this slice;
# the early-return skip, isActive(), shootp / calculateHeat /
# findTarget / the other ItemTurret defs / controlled() still wait.
DEFERRED = list(N2277_DEFERRED) + [
    'Turret activationTimer decay (`if(activationTimer > 0){ activationTimer -= Time.delta; return; }`, Turret.java:561-564) -- DONE by this slice (N2279); the pure function ports the Java gate verbatim and the duo driver stamps frame["activation_timer"] and frame["activation_timer_elapsed"] live between the rotate sync tick and the aim call (Java order :542-545, then :561-564, then :566+). The gate never fires for duo (activationTime 0 for every def), so the timer stays 0.0 and elapsed stays true.',
    'Turret activation early-return skip -- the aim/shoot half is NOT skipped when activation_timer > 0 in this slice: the gate never fires for duo (activationTime 0 for every def -- no Blocks.java def sets activationTime > 0), so restructuring the aim block for a never-firing guard is churn; it waits for a def with activationTime > 0.',
    'Turret isActive() (`(target != null || wasShooting) && enabled && activationTimer <= 0`, Turret.java:448-450) -- NOT this slice; candidate N2280 now that activation_timer is stamped. Only LaserTurret consumes it in Java, and duo has no consumer.',
    'Turret activationTimer decay for defs other than duo -- the pure function takes activation_timer / delta as params; only duo is wired in the driver.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    activation_timer_inputs = {
        'activation_timer': a('float', 'public float activationTimer = 0;', 'The activation timer (BaseTurret.java:115 `public float activationTimer = 0;`, set to activationTime in placed() :119-120; the class default activationTime is 0f, BaseTurret.java:27, and duo never overrides it, so the live duo value is 0.0).', source=BASE_TURRET),
        'delta': a('float', 'activationTimer -= Time.delta;', 'The per-tick delta subtracted from the timer (Turret.java:562; the driver passes the live-loop seconds).'),
    }
    activation_timer_outputs = {
        'activation_timer': a('float', 'activationTimer -= Time.delta;', 'The activation timer after the tick (Turret.java:561-562 -- decayed by delta while positive, untouched otherwise, with no clamp; the driver stamps it on frame["activation_timer"]).'),
        'activation_timer_elapsed': a('bool', 'activationTimer <= 0', 'Whether the activation period has elapsed, i.e. the :561-564 gate lets the tick proceed (evaluated on the INPUT timer -- Java returns before the rest of the tick when the input is positive, even if this tick\'s decay would cross zero; the same `activationTimer <= 0` clause BaseTurret.status() uses, BaseTurret.java:144).', source=BASE_TURRET),
    }
    return activation_timer_inputs, activation_timer_outputs


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
    activation_timer_inputs, activation_timer_outputs = definitions()

    entries = [
        ('N2279', ACTIVATION_TIMER_OWNER, 'source_turret_activation_timer_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.updateTile()', activation_timer_inputs, activation_timer_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret activationTimer decay from TurretBuild.updateTile() / Turret.java:561-564.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret activationTimer decay from TurretBuild.updateTile() / Turret.java:561-564.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: activation_timer, activation_timer_elapsed.
    by_slice['N2279'] = [
        'source_turret_activation_timer_state_result.activation_timer',
        'source_turret_activation_timer_state_result.activation_timer_elapsed',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2279', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.updateTile()', godot_owner=ACTIVATION_TIMER_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2279'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
