"""Register the Turret warmup lerp advance (N2253).

TurretBuild.updateTile (Turret.java:490-515) advances the warmup
before it aims or shoots: `float warmupTarget = (isShooting &&
canConsume()) || charging() ? 1f : 0f;` (Turret.java:502), the
hold (`if(warmupTarget > 0 && !controlled()){ warmupHold = 1f;
}` / `if(warmupHold > 0f){ warmupHold -= Time.delta /
warmupMaintainTime; warmupTarget = 1f; }`, :503-509), then the
lerp (`if(linearWarmup){` / `shootWarmup =
Mathf.approachDelta(shootWarmup, warmupTarget,
shootWarmupSpeed * (warmupTarget > 0 ? efficiency : 1f));` /
`}else{` / `shootWarmup = Mathf.lerpDelta(shootWarmup,
warmupTarget, shootWarmupSpeed * (warmupTarget > 0 ?
efficiency : 1f));`, :511-515). The driver read
frame["shoot_warmup"] (SourceTurretBuildState.gd:317, default
0.0) as the aim/shoot gate input but NEVER stamped it back --
warmup never advanced live. This slice adds the one pure
function on the shared TurretBuild driver file (it is
TurretBuild.updateTile, common to every turret, not
ItemTurret-only) plus one driver tick in the duo branch BEFORE
the aim/shoot call (Java order :502-514 before the shoot gate
:733, and aim/shoot read shoot_warmup as a gate input).

GREEN decisions (pinned by this slice): (1) One pure function
on SourceTurretBuildState.gd,
source_turret_warmup_state(shoot_warmup, warmup_hold,
is_shooting, can_consume, charging, controlled, efficiency,
delta, shoot_warmup_speed, linear_warmup,
warmup_maintain_time), returning `{"shoot_warmup": ...,
"warmup_hold": ..., "warmup_target": ...}`, plus one driver
tick in the duo branch (before the aim/shoot call) that reads
the peek amount from the last duo stack entry, computes
can_consume as stacks non-empty AND (peek amount >=
ammoPerShot 1 OR cheating), calls the pure function with
is_shooting = has_target AND the N2251 validate verdict, and
stamps shoot_warmup + warmup_hold back on the frame. Three
new result symbols. (2) can_consume reads the peek amount
as-is: ItemTurret canConsume is `return ammo.size > 0 &&
(ammo.peek().amount >= ammoPerShot || cheating());`
(Turret.java:711 -- ammo.peek() is the last stack; the
driver's stacks are the {"item", "amount"} dicts, peeked
from the last stack, SourceItemTurretBuildState.gd:420 and
the useAmmo inline at :541-543). The hasAmmo() swap
(Turret.java:700-706) is hasAmmo() detail and waits with
the hasAmmo() wrapper slice. (3) With the duo default
warmupMaintainTime 0f the hold division is +inf, so the
hold ends on the very tick it is set -- the test pins
warmup_hold <= 0.0 after that tick, never exactly -inf.
(4) The rate is shootWarmupSpeed * (efficiency when the
target is 1, else 1.0); the linear branch is approach with
step rate * delta, the curve branch is lerp with progress
clamp(rate * delta, 0, 1) -- arc Mathf approach /
approachDelta / lerp / lerpDelta (Mathf.java:402-432).
(5) The duo def overrides NONE of minWarmup 0f /
warmupMaintainTime 0f / shootWarmupSpeed 0.1f / linearWarmup
false, so the driver passes 0.1 / false / 0.0. SSOT
expected after GREEN: symbols +3, Done +1, contracts +1,
schema +2, 11600/1702/1636/3063 -> 11603/1703/1637/3065;
defense shard slices 181 -> 182, contracts 180 -> 181.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_item_turret_bullet_spawn import DEFERRED as N2252_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
MATHF = 'arc-core/src/arc/math/Mathf.java'
PROOF = '/root/C07TurretWarmupProof'
WARMUP_OWNER = 'SourceTurretBuildState.source_turret_warmup_state'
TESTS = ['test_c07_turret_warmup_registration', 'test_all_c07_turret_warmup_input_evidence_is_exact', 'test_turret_warmup_state', 'test_reference_graph_and_actual_c07_turret_warmup']
# The 2 slice sources the N2253 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'arc-core/src/arc/math/Mathf.java',
]
EXACT_EXPRS = ['if(!validateTarget()) target = null;', 'isShooting = alwaysShooting || (unit.controller() instanceof Player ? unit.isShooting() : logicControlled() ? logicShooting : target != null);', 'float warmupTarget = (isShooting && canConsume()) || charging() ? 1f : 0f;', 'if(warmupTarget > 0 && !controlled()){', 'warmupHold = 1f;', 'if(warmupHold > 0f){', 'warmupHold -= Time.delta / warmupMaintainTime;', 'warmupTarget = 1f;', 'if(linearWarmup){', 'shootWarmup = Mathf.approachDelta(shootWarmup, warmupTarget, shootWarmupSpeed * (warmupTarget > 0 ? efficiency : 1f));', 'shootWarmup = Mathf.lerpDelta(shootWarmup, warmupTarget, shootWarmupSpeed * (warmupTarget > 0 ? efficiency : 1f));', 'public boolean controlled(){', 'return unit.isPlayer();', 'return ammo.size > 0 && (ammo.peek().amount >= ammoPerShot || cheating());', 'return queuedBullets > 0 && shoot.firstShotDelay > 0;', 'if(reloadCounter >= reload && !charging() && shootWarmup >= minWarmup){', 'public float minWarmup = 0f;', 'public float warmupMaintainTime = 0f;', 'public float shootWarmupSpeed = 0.1f;', 'public boolean linearWarmup = false;', 'return shootWarmup;', 'public static float clamp(float value){', 'return Math.max(Math.min(value, 1f), 0f);', 'public static float approach(float from, float to, float speed){', 'return from + Mathf.clamp(to - from, -speed, speed);', 'public static float approachDelta(float from, float to, float speed){', 'return approach(from, to, Time.delta * speed);', 'public static float lerp(float fromValue, float toValue, float progress){', 'return fromValue + (toValue - fromValue) * progress;', 'public static float lerpDelta(float fromValue, float toValue, float progress){', 'return lerp(fromValue, toValue, clamp(progress * Time.delta));', 'curRecoil = Mathf.approachDelta(curRecoil, 0, 1 / recoilTime);', 'heat = Mathf.approachDelta(heat, 0, 1 / cooldownTime);', 'charge = charging() ? Mathf.approachDelta(charge, 1, 1 / shoot.firstShotDelay) : 0;']

# DEFERRED is carried from the N2252 register script via import --
# never retyped. Warmup is done by this slice, so the N2250
# lumped "warmup lerp advance" entry is superseded: the lerp /
# approach advance, the hold, and the duo driver tick are all
# here. The recoil/heat decay, the charge advance, and the
# hasAmmo() swap still wait, as separate entries below, and
# findTarget / queuedBullets / the other ItemTurret defs still
# wait.
DEFERRED = list(N2252_DEFERRED) + [
    'Turret warmup Windows Godot proof -- debt in GOAL.md section 5, same as N2240-N2252: the N2253 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Turret recoil/heat decay (curRecoil/heat approachDelta, Turret.java:519/526) -- the warmup slice advances shootWarmup only; recoil and heat still wait for their own slice (N2254 candidate).',
    'Turret charge advance (charge approachDelta, Turret.java:527) -- needs queuedBullets + firstShotDelay > 0; it goes with the queuedBullets slice, not the warmup slice.',
    'ItemTurret hasAmmo() swap (ammo.swap to bring a sufficient stack to the top, Turret.java:700-706) -- can_consume here reads the peek amount as-is; the swap waits with the hasAmmo() wrapper slice.',
    'Turret warmup for defs with warmupMaintainTime > 0 / linearWarmup true (per-def values other than the duo defaults) -- the pure function takes them as params; only duo (shootWarmupSpeed 0.1 / linearWarmup false / warmupMaintainTime 0.0) is wired in the driver.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    warmup_inputs = {
        'shoot_warmup': a('float', 'return shootWarmup;', 'The current warmup 0..1 (Turret.java:355, warmup() -- the field the lerp/approach step advances; the driver reads it from frame["shoot_warmup"], default 0.0).'),
        'warmup_hold': a('float', 'warmupHold = 1f;', 'The current warmup hold (Turret.java:504 -- set to 1f when the target is 1 and the build is not controlled, then decayed by delta / warmupMaintainTime; the driver reads it from frame["warmup_hold"], default 0.0).'),
        'is_shooting': a('bool', 'isShooting = alwaysShooting || (unit.controller() instanceof Player ? unit.isShooting() : logicControlled() ? logicShooting : target != null);', 'Whether the build is shooting this tick (Turret.java:492 -- duo has no player and no logic, so this is target != null after the validateTarget verdict at :491; the driver passes has_target AND the N2251 verdict).'),
        'can_consume': a('bool', 'return ammo.size > 0 && (ammo.peek().amount >= ammoPerShot || cheating());', 'Whether the build can consume ammo (Turret.java:711, ItemTurret canConsume -- stacks non-empty and the peek (last) stack amount >= ammoPerShot 1, or cheating; the driver reads the last duo stack entry amount).'),
        'charging': a('bool', 'return queuedBullets > 0 && shoot.firstShotDelay > 0;', 'Whether the build is charging a delayed shot (Turret.java:715-717 -- duo firstShotDelay is 0, so false live; the driver passes frame["charging"]).'),
        'controlled': a('bool', 'return unit.isPlayer();', 'Whether the build is player-controlled (Turret.java:441-443, controlled() -- the hold is only set when not controlled; the driver passes frame["controlled"] with a false default, the live player stamp waits for its own slice).'),
        'efficiency': a('float', 'shootWarmup = Mathf.lerpDelta(shootWarmup, warmupTarget, shootWarmupSpeed * (warmupTarget > 0 ? efficiency : 1f));', 'The build efficiency (Turret.java:514 -- scales the warmup rate when the target is 1, else the rate is unscaled; the driver passes frame["efficiency"], 1.0 for duo).'),
        'delta': a('float', 'warmupHold -= Time.delta / warmupMaintainTime;', 'The scaled tick delta in seconds (Turret.java:507 -- Time.delta; the driver passes seconds).'),
        'shoot_warmup_speed': a('float', 'public float shootWarmupSpeed = 0.1f;', 'The warmup lerp speed (Turret.java:136, class default 0.1f -- duo does not override it; the driver passes 0.1).'),
        'linear_warmup': a('bool', 'public boolean linearWarmup = false;', 'Whether the warmup advances linearly instead of as a curve (Turret.java:138, class default false -- duo does not override it; the driver passes false).'),
        'warmup_maintain_time': a('float', 'public float warmupMaintainTime = 0f;', 'How long the warmup is maintained after shooting stops (Turret.java:84, class default 0f -- duo does not override it; the driver passes 0.0, so the hold ends on the tick it is set).'),
    }
    warmup_outputs = {
        'shoot_warmup': a('float', 'shootWarmup = Mathf.lerpDelta(shootWarmup, warmupTarget, shootWarmupSpeed * (warmupTarget > 0 ? efficiency : 1f));', 'The warmup after this tick (Turret.java:514 -- the lerp branch for duo; the linear branch is approachDelta at :512).'),
        'warmup_hold': a('float', 'warmupHold -= Time.delta / warmupMaintainTime;', 'The hold after this tick (Turret.java:507 -- decayed by delta / warmupMaintainTime; with the duo default 0.0 the division is +inf, so the hold is <= 0.0 after the tick it was set).'),
        'warmup_target': a('float', 'float warmupTarget = (isShooting && canConsume()) || charging() ? 1f : 0f;', 'The warmup target 0.0/1.0 after the hold fold (Turret.java:502, forced to 1.0 while the hold is positive, :509).'),
    }
    return warmup_inputs, warmup_outputs


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
    warmup_inputs, warmup_outputs = definitions()

    entries = [
        ('N2253', WARMUP_OWNER, 'source_turret_warmup_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.updateTile()', warmup_inputs, warmup_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret warmup lerp advance from Turret.java / Mathf.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret warmup lerp advance from Turret.java / Mathf.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: shoot_warmup, warmup_hold,
    # warmup_target.
    by_slice['N2253'] = [
        'source_turret_warmup_state_result.shoot_warmup',
        'source_turret_warmup_state_result.warmup_hold',
        'source_turret_warmup_state_result.warmup_target',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2253', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.updateTile()', godot_owner=WARMUP_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2253'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
