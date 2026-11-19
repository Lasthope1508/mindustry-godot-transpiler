"""Register the Turret charge advance (N2259).

TurretBuild.updateTile (Turret.java:490-615) advances the
charge every tick, after the recoil/heat decay and before
the recoilOffset draw: `charge = charging() ?
Mathf.approachDelta(charge, 1, 1 / shoot.firstShotDelay) : 0;`
(Turret.java:527), where charging is
`return queuedBullets > 0 && shoot.firstShotDelay > 0;`
(:715-717). The new C07 duo driver (N2250-N2258) never
stamped frame["charge"] / frame["charging"] -- the warmup
tick (N2253) already read frame["charging"] and the aim
call already passed it, but the value was always the false
default because no tick stamped it, and the shoot gate
(:733) also reads !charging(). This slice adds the one
pure function on the shared TurretBuild driver file
(updateTile() is TurretBuild's method, common to every
turret, not ItemTurret-only) plus one driver tick in the
duo branch AFTER the N2256 multi-recoil decay tick and
BEFORE the N2258 recoilOffset tick (Java order :519/:520-525
decay, :526 heat, :527 charge, :532 offset).

GREEN decisions (pinned by this slice): (1) One pure function
on SourceTurretBuildState.gd,
source_turret_charge_state(charge, queued_bullets,
first_shot_delay, delta), returning `{"charge": ..,
"charging": ..}` -- charging is derived INSIDE the
function (queuedBullets > 0 and firstShotDelay > 0, so
firstShotDelay <= 0 never divides by zero); when charging
the charge moves toward 1 by delta / firstShotDelay
(approachDelta: approach(from, to, Time.delta * speed),
arc Mathf.java:420-422, with approach :415-417 clamping
the step, so it never passes 1), and when not charging
the charge resets to 0 outright (not a decay). Plus one
driver tick in the duo branch (right after the N2256
multi-recoil decay tick, before the N2258 recoilOffset
tick) that reads frame["charge"] (default 0.0) and
frame["queued_bullets"] (default 0) and calls the pure
function with duo firstShotDelay 0.0, then stamps charge
+ charging back on the frame -- the tick runs BEFORE the
aim call, so aim reads a fresh charging flag (Java :527
runs before :601/:609). (2) With duo, queuedBullets is 0
at every tick boundary -- ShootAlternate.shoot passes
delay = firstShotDelay + shotDelay * i (ShootAlternate.java:32);
duo firstShotDelay is 0 (ShootPattern.java:11, never
overridden -- `shoot = new ShootAlternate(3.5f);`,
Blocks.java:3299) and shotDelay is 0 (:13, never
overridden), so every delay is 0; shoot() only defers
bullet() through Time.run(delay, ...) when delay > 0
(Turret.java:770-777), so delay 0 runs bullet()
synchronously and queuedBullets++ then -- nets to 0
before the tick ends; and charge :527 runs BEFORE the
shoot gate :733, so it always reads 0 for duo. The
frame["queued_bullets"] read is therefore live-correct
for duo and needs no counter tick of its own in this
slice. (3) `firstShotDelay = 0;` is NOT in exact_exprs
(it lives in ShootPattern.java, not Turret.java) -- the
duo override is pinned by a comment in the .gd plus an
assert on the .gd text in the test, same rule as N2257's
`recoils = 2;` and N2258's `recoil = 0.5f;`. (4) The
cross-tick queuedBullets counter for turrets with
firstShotDelay > 0 (bullets deferred through Time.run,
queue alive across ticks) still waits for its own slice
-- it needs a delayed-bullet model no driver tick has
yet. (5) No legacy `source_turret_charge_result` schema
exists (unlike N2258's recoilOffset), so the contract
validator falls through to the new
source_turret_charge_state_result schema and no alias
is needed. SSOT expected after GREEN:
symbols +2, Done +1, contracts +1, schema +2,
11611/1708/1642/3075 -> 11613/1709/1643/3077; defense
shard slices 187 -> 188, contracts 186 -> 187.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_recoil_offset import DEFERRED as N2258_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
SHOOT_PATTERN = 'core/src/mindustry/entities/pattern/ShootPattern.java'
MATHF = 'arc-core/src/arc/math/Mathf.java'
PROOF = '/root/C07TurretChargeProof'
CHARGE_OWNER = 'SourceTurretBuildState.source_turret_charge_state'
TESTS = ['test_c07_turret_charge_registration', 'test_all_c07_turret_charge_input_evidence_is_exact', 'test_turret_charge_state', 'test_reference_graph_and_actual_c07_turret_charge']
# The slice source the N2259 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
]
EXACT_EXPRS = ['charge = charging() ? Mathf.approachDelta(charge, 1, 1 / shoot.firstShotDelay) : 0;', 'return queuedBullets > 0 && shoot.firstShotDelay > 0;', 'public float shootWarmup, charge, warmupHold = 0f;', 'public int queuedBullets = 0;']

# DEFERRED is carried from the N2258 register script via import --
# never retyped. The charge advance is done by this slice, so
# the N2258 "Turret charge advance ... goes with the
# queuedBullets slice" entry is superseded (the charge tick
# is N2259 itself); the cross-tick queuedBullets counter,
# effects/sound, findTarget / the other ItemTurret defs
# still wait.
DEFERRED = list(N2258_DEFERRED) + [
    'Turret charge advance Windows Godot proof -- debt in GOAL.md section 5, same as N2240-N2258: the N2259 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Turret charge advance (charge approachDelta, Turret.java:527) -- DONE by this slice (N2259); the N2258 deferred entry above saying it goes with the queuedBullets slice is superseded.',
    'Turret charge advance for defs other than duo -- the pure function takes charge / queued_bullets / first_shot_delay / delta as params; only duo is wired in the driver (firstShotDelay 0.0).',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    charge_inputs = {
        'charge': a('float', 'public float shootWarmup, charge, warmupHold = 0f;', 'The charge before this tick (Turret.java:286, the charge field; the driver reads it from frame["charge"], default 0.0).'),
        'queued_bullets': a('int', 'public int queuedBullets = 0;', 'The live queued-bullet count (Turret.java:293; the driver reads it from frame["queued_bullets"], default 0 -- live-correct for duo, whose every bullet delay is firstShotDelay + shotDelay * i = 0 + 0 = 0, so the queue is empty at every tick boundary).'),
        'first_shot_delay': a('float', 'public float firstShotDelay = 0;', 'The delay in ticks before the first shot (ShootPattern.java:11, `/** delay in ticks before first shot */`; duo never overrides it -- `shoot = new ShootAlternate(3.5f);`, Blocks.java:3299 -- so the driver passes 0.0).', source=SHOOT_PATTERN),
        'delta': a('float', 'return approach(from, to, Time.delta * speed);', 'The scaled tick delta in seconds (arc Mathf.java:422, approachDelta -- Time.delta; the driver passes seconds, the same convention as the N2253 warmup and the N2254 recoil/heat decay).', source=MATHF),
    }
    charge_outputs = {
        'charge': a('float', 'charge = charging() ? Mathf.approachDelta(charge, 1, 1 / shoot.firstShotDelay) : 0;', 'The charge after this tick (Turret.java:527 -- moved toward 1 by delta / firstShotDelay when charging, never past 1; reset to 0 outright when not charging).'),
        'charging': a('bool', 'return queuedBullets > 0 && shoot.firstShotDelay > 0;', 'Whether the turret is charging this tick (Turret.java:715-717 -- queuedBullets > 0 and firstShotDelay > 0; false for duo live, but the warmup tick N2253 and the shoot gate :733 still read it).'),
    }
    return charge_inputs, charge_outputs


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
    charge_inputs, charge_outputs = definitions()

    entries = [
        ('N2259', CHARGE_OWNER, 'source_turret_charge_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.updateTile()', charge_inputs, charge_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret charge advance from Turret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret charge advance from Turret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: charge, charging.
    by_slice['N2259'] = [
        'source_turret_charge_state_result.charge',
        'source_turret_charge_state_result.charging',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2259', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.updateTile()', godot_owner=CHARGE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2259'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
