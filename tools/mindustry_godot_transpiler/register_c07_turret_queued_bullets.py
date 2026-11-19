"""Register the Turret queuedBullets counter + charging() gate (N2269).

TurretBuild keeps a cross-tick counter of bullets that have been
queued to fire but have not fired yet:
`public int queuedBullets = 0;` (Turret.java:293). shoot()
(Turret.java:741-777) increments it once per bullet the shoot
pattern queues:
`queuedBullets++;` (:754); when the pattern delay is positive the
bullet is deferred:
`if(delay > 0f){` `Time.run(delay, () -> {`
`bullet(type, xOffset, yOffset, angle, mover);` `});`
(:756-764), otherwise it fires at once (`bullet(type, xOffset,
yOffset, angle, mover);`, :765). bullet() (Turret.java:772-777)
decrements it first thing: `queuedBullets --;` (:773). While any
bullet is still queued and the def has a first-shot delay, the
turret is charging:
`public boolean charging(){`
`return queuedBullets > 0 && shoot.firstShotDelay > 0;`
`}` (:715-717) -- and updateShooting() (Turret.java:731-740)
refuses to shoot while charging:
`if(reloadCounter >= reload && !charging() && shootWarmup >= minWarmup){`
`shoot(type);`
`reloadCounter %= reload;`
`}` (:733-738). updateShooting() runs from updateTile()
(`updateShooting();`, :601/:609). The delay branch also plays the
charge sound when a shot begins: `if(shoot.firstShotDelay > 0){`
`chargeSound.at(bulletX, bulletY, Mathf.random(soundPitchMin, soundPitchMax));`
(:747-748) -- `/** Sound emitted when shoot.firstShotDelay is >0
and shooting begins. */` (:125). The field default is
`public float firstShotDelay = 0;` (ShootPattern.java:11), and the
only def that sets it is lancer:
`lancer = new PowerTurret("lancer"){{` `range = 165f;`
`shoot.firstShotDelay = 40f;` `reload = 80f;`
(Blocks.java:3560-3567). Duo never sets it (Blocks.java:3257-3331)
so its delay is 0, charging() is always false for duo, and its
delay-0 bullets fire at once, leaving the counter at 0.
`public float minWarmup = 0f;` (Turret.java:76) is the warmup floor
in the gate.

GREEN decisions (pinned by this slice): (1) One pure function
on SourceTurretBuildState.gd,
source_turret_queued_bullets_state(queued_bullets,
first_shot_delay, queued_now, fired_now, reload_counter, reload,
shoot_warmup, min_warmup), returning `{"queued_bullets": ..,
"charging": .., "can_shoot": .., "reload_counter_after": ..}` --
queued_bullets is the counter after this tick's queue/fire
transitions (queued_now added, fired_now subtracted); charging
is the :716 gate on the pre-update counter (the :733 ordering --
the gate reads the counter before shoot() queues); can_shoot is
the :733 gate (reload ready, not charging, warmup at/above the
floor); reload_counter_after is fmod(reload_counter, reload)
when the gate passes (:738), else the counter unchanged. (2) No
driver tick: the delayed bullets are Time.run callbacks with no
driver equivalent, and the gate is evaluated per shoot event,
not per tick -- the N2248/N2264/N2266/N2267/N2268 precedent --
so the proof calls the pure function directly, including a
two-call sequence that pins the cross-tick block (lancer queues
one bullet on tick 1, charging blocks tick 2 until it fires).
(3) The charge sound / charge effect are not modeled: effects
and sound wait for their own slice. SSOT expected after GREEN:
symbols +4, Done +1, contracts +1, schema +2, 11634/1718/1652/3095
-> 11638/1719/1653/3097; defense shard slices 195 -> 196,
contracts 194 -> 195.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_configured_dispatch import DEFERRED as N2268_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
SHOOT_PATTERN = 'core/src/mindustry/entities/pattern/ShootPattern.java'
PROOF = '/root/C07TurretQueuedBulletsProof'
QUEUED_BULLETS_OWNER = 'SourceTurretBuildState.source_turret_queued_bullets_state'
TESTS = ['test_c07_turret_queued_bullets_registration', 'test_all_c07_turret_queued_bullets_input_evidence_is_exact', 'test_turret_queued_bullets_state', 'test_reference_graph_and_actual_c07_turret_queued_bullets']
# The slice sources the N2269 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/entities/pattern/ShootPattern.java',
]
EXACT_EXPRS = ['public int queuedBullets = 0;', 'public boolean charging(){', 'return queuedBullets > 0 && shoot.firstShotDelay > 0;', 'protected void updateShooting(){', 'if(reloadCounter >= reload && !charging() && shootWarmup >= minWarmup){', 'shoot(type);', 'reloadCounter %= reload;', 'protected void shoot(BulletType type){', 'if(shoot.firstShotDelay > 0){', 'chargeSound.at(bulletX, bulletY, Mathf.random(soundPitchMin, soundPitchMax));', '/** Sound emitted when shoot.firstShotDelay is >0 and shooting begins. */', 'queuedBullets++;', 'if(delay > 0f){', 'Time.run(delay, () -> {', 'bullet(type, xOffset, yOffset, angle, mover);', 'protected void bullet(BulletType type, float xOffset, float yOffset, float angleOffset, Mover mover){', 'queuedBullets --;', 'public float minWarmup = 0f;', 'updateShooting();', 'public float firstShotDelay = 0;', 'lancer = new PowerTurret("lancer"){{', 'range = 165f;', 'shoot.firstShotDelay = 40f;', 'reload = 80f;']

# DEFERRED is carried from the N2268 register script via import --
# never retyped. The cross-tick queuedBullets counter is done by
# this slice (it was a deferred item in the N2268 handoff); the
# calculateHeat live proximity scan, the efficiency fold for defs
# other than duo, the maxHealth/health re-sync, the set(tile)
# world position, effects/sound, findTarget / the other ItemTurret
# defs still wait.
DEFERRED = list(N2268_DEFERRED) + [
    'Turret queuedBullets Windows Godot proof -- debt in GOAL.md section 5, same as N2240-N2268: the N2269 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Counter queuedBullets cross-tick + delayed bullets (Time.run) for turret firstShotDelay > 0 -- DONE by this slice (N2269); the pure function pins the counter transitions, the charging() gate and the updateShooting() gate, including the two-call cross-tick block for lancer.',
    'Turret charge sound / charge effect for firstShotDelay > 0 -- effects/sound wait for their own slice; N2269 only pins that the firstShotDelay > 0 branch exists (Turret.java:747-748).',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    queued_bullets_inputs = {
        'queued_bullets': a('int', 'public int queuedBullets = 0;', 'The current queuedBullets counter (Turret.java:293 -- incremented once per bullet the shoot pattern queues at :754, decremented in bullet() at :773).'),
        'first_shot_delay': a('float', 'if(shoot.firstShotDelay > 0){', 'The def shoot.firstShotDelay (Turret.java:747 -- the charging() gate at :716 needs it positive; the field default is 0, ShootPattern.java:11; lancer sets 40f, Blocks.java:3564).'),
        'queued_now': a('int', 'queuedBullets++;', 'Bullets queued by this shoot() call (Turret.java:754 -- one increment per bullet the pattern.shoot callback queues).'),
        'fired_now': a('int', 'queuedBullets --;', 'Bullets whose bullet() ran this tick (Turret.java:773 -- delay-0 bullets fire at once at :765, delayed bullets fire from the Time.run callback at :757-764).'),
        'reload_counter': a('float', 'if(reloadCounter >= reload && !charging() && shootWarmup >= minWarmup){', 'The current reloadCounter (Turret.java:733 -- the updateShooting() gate needs it at/above reload).'),
        'reload': a('float', 'reload = 80f;', 'The def reload (Blocks.java:3567, lancer -- the updateShooting() gate threshold and the modulo divisor at Turret.java:738).', source=BLOCKS),
        'shoot_warmup': a('float', 'if(reloadCounter >= reload && !charging() && shootWarmup >= minWarmup){', 'The current shootWarmup (Turret.java:733 -- the updateShooting() gate needs it at/above minWarmup).'),
        'min_warmup': a('float', 'public float minWarmup = 0f;', 'The def minWarmup floor (Turret.java:76 -- the updateShooting() gate threshold at :733; duo never sets it, so 0).'),
    }
    queued_bullets_outputs = {
        'queued_bullets': a('int', 'queuedBullets++;', 'The counter after this tick transitions (Turret.java:754/:773 -- queued_now added, fired_now subtracted; a lancer bullet queued on tick 1 stays queued until its Time.run callback fires).'),
        'charging': a('bool', 'return queuedBullets > 0 && shoot.firstShotDelay > 0;', 'Whether the turret is charging (Turret.java:716 -- queued bullets remain and firstShotDelay is positive; evaluated on the pre-update counter, the :733 ordering).'),
        'can_shoot': a('bool', 'if(reloadCounter >= reload && !charging() && shootWarmup >= minWarmup){', 'Whether updateShooting() fires (Turret.java:733 -- reload ready, not charging, warmup at/above the floor).'),
        'reload_counter_after': a('float', 'reloadCounter %= reload;', 'The reloadCounter after the gate (Turret.java:738 -- fmod(reload_counter, reload) when the gate passes, else unchanged).'),
    }
    return queued_bullets_inputs, queued_bullets_outputs


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
    queued_bullets_inputs, queued_bullets_outputs = definitions()

    entries = [
        ('N2269', QUEUED_BULLETS_OWNER, 'source_turret_queued_bullets_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret', 'TurretBuild.charging()/updateShooting()/shoot()/bullet()', queued_bullets_inputs, queued_bullets_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret queuedBullets counter + charging() gate from Turret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret queuedBullets counter + charging() gate from Turret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: queued_bullets, charging, can_shoot, reload_counter_after.
    by_slice['N2269'] = [
        'source_turret_queued_bullets_state_result.queued_bullets',
        'source_turret_queued_bullets_state_result.charging',
        'source_turret_queued_bullets_state_result.can_shoot',
        'source_turret_queued_bullets_state_result.reload_counter_after',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2269', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret', java_method='TurretBuild.charging()/updateShooting()/shoot()/bullet()', godot_owner=QUEUED_BULLETS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2269'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
