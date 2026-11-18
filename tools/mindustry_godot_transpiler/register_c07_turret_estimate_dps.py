"""Register the TurretBuild.estimateDps() accessor (N2261).

TurretBuild overrides estimateDps (Turret.java:329-332, `public
float estimateDps(){` / `if(!hasAmmo()) return 0f;` /
`return shoot.shots / reload * 60f * (peekAmmo() == null ? 0f
: peekAmmo().estimateDPS()) * potentialEfficiency *
timeScale;`). The shots are the ShootPattern def shots
(ShootPattern.java:9, `public int shots = 1;`, default 1; def
salvo has shots > 1) and the reload is the ReloadTurret def
reload (ReloadTurret.java:10, `public float reload = 10f;`).
The potential efficiency is the BuildingComp field
(BuildingComp.java:89, `transient float
potentialEfficiency;`, Java default 0.0f, machinery-set
later) and the time scale is Time.timeScale through delta()
(BuildingComp.java:1922-1923, `public float delta(){` /
`return Time.delta * timeScale;`). The peeked bullet's DPS is
BulletType.estimateDPS() (BulletType.java:414-431, `public
float estimateDPS(){`, recursive over spawnUnit /
despawnUnit / fragBullet / spawnBullets with the cachedDps
cache). hasAmmo() (Turret.java:698-712, `public boolean
hasAmmo(){` / `return ammo.size > 0 && (ammo.peek().amount
>= ammoPerShot || cheating());` after the ammo-swap and
canConsume gates) has a side effect -- it swaps the ammo
queue when the first entry is short -- so the pure function
takes has_ammo as an explicit bool, never calls hasAmmo().
peekAmmo() (Turret.java:693, `public @Nullable BulletType
peekAmmo(){`) is likewise not ported here: the caller passes
the peeked bullet's DPS explicitly (0.0 when peekAmmo() is
null, the Java ternary leg). The accessor is what the RTS AI
reads (RtsAI.java:336, `dps[0] += t.estimateDps();`); the AI
itself waits for its own slice.

RED decisions (resolved at RED): (1) One pure function
on SourceTurretBuildState.gd next to the N2268 fogRadius
row, following the N2268 accessor precedent exactly:
(frame, has_ammo, shots, reload, peek_ammo_estimate_dps,
potential_efficiency, time_scale) and one result key
`estimate_dps`. (2) All live values arrive as explicit
params (the N2188 precedent) -- the tick frame
tracks only cheating / enabled / power_status /
efficiency today. (3) No ammo returns 0.0 (the Java early
return); a null peek also yields 0.0 through the explicit
0.0 param. (4) reload = 0 keeps the Java float-division
behavior (Infinity for a nonzero numerator) -- no invented
guard; the proof pins it. (5) NO driver line:
estimateDps() is a read accessor the RTS AI calls, not a
per-tick write (the N2268/N2249 precedent); the AI caller
waits for its own slice. One new result symbol:
estimate_dps. Slice sources: Turret.java +
ReloadTurret.java + ShootPattern.java + BulletType.java +
BuildingComp.java + RtsAI.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_fog_radius import DEFERRED as N2268_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
RELOAD_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java'
SHOOT_PATTERN = 'core/src/mindustry/entities/pattern/ShootPattern.java'
BULLET_TYPE = 'core/src/mindustry/entities/bullet/BulletType.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
RTS_AI = 'core/src/mindustry/ai/RtsAI.java'
PROOF = '/root/C07TurretEstimateDpsProof'
ESTIMATE_DPS_OWNER = 'SourceTurretBuildState.source_turret_estimate_dps_state'
TESTS = ['test_c07_turret_estimate_dps_registration', 'test_all_c07_turret_estimate_dps_input_evidence_is_exact', 'test_turret_estimate_dps_state', 'test_reference_graph_and_actual_c07_turret_estimate_dps']
# The 6 slice sources the N2261 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
    'core/src/mindustry/entities/pattern/ShootPattern.java',
    'core/src/mindustry/entities/bullet/BulletType.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/ai/RtsAI.java',
]
EXACT_EXPRS = [
    'public float estimateDps(){',
    'if(!hasAmmo()) return 0f;',
    'return shoot.shots / reload * 60f * (peekAmmo() == null ? 0f : peekAmmo().estimateDPS()) * potentialEfficiency * timeScale;',
    'public boolean hasAmmo(){',
    'public @Nullable BulletType peekAmmo(){',
    'public int shots = 1;',
    'public float reload = 10f;',
    'transient float potentialEfficiency;',
    'return Time.delta * timeScale;',
    'public float estimateDPS(){',
    'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
    'dps[0] += t.estimateDps();',
]

# DEFERRED is carried from the N2268 register script via import --
# never retyped. Nothing in it closes here: estimateDps() was never
# a deferred entry of the Turret chain. Three entries are added:
# the N2261 Windows Godot proof debt (GOAL.md section 5) and the
# three pure ports this slice defers (hasAmmo, peekAmmo,
# BulletType.estimateDPS).
DEFERRED = N2268_DEFERRED + [
    'Turret estimateDps() Windows Godot proof -- debt in GOAL.md section 5, same as N2148/N2227: the N2261 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Port pure TurretBuild.hasAmmo() (Turret.java:698-712, ammo-swap side effect) as its own slice; N2261 takes has_ammo as an explicit bool.',
    'Port pure TurretBuild.peekAmmo() (Turret.java:693-695) as its own slice; N2261 takes peek_ammo_estimate_dps as an explicit float.',
    'Port pure BulletType.estimateDPS() (BulletType.java:414-431, recursive + cachedDps cache) as its own slice; N2261 takes peek_ammo_estimate_dps as an explicit float.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    estimate_dps_inputs = {
        'frame': a('Dictionary', 'public float estimateDps(){', 'The turret frame (accepted for the family call shape; this leg reads no live frame key -- all live values arrive as explicit params, the N2188 per-def-param precedent, because the tick frame tracks only cheating/enabled/power_status/efficiency).'),
        'has_ammo': a('bool', 'public boolean hasAmmo(){', 'Whether the turret has usable ammo: the TurretBuild.hasAmmo() gate (Turret.java:698-712, `return ammo.size > 0 && (ammo.peek().amount >= ammoPerShot || cheating());` after the ammo-swap and canConsume gates); passed explicitly because the tick frame tracks no ammo state yet -- and because hasAmmo() swaps the ammo queue, the pure function must never call it. False returns 0.0 (the Java early return).'),
        'shots': a('int', 'public int shots = 1;', 'The shoot-pattern shot count: ShootPattern.shots (ShootPattern.java:9), default 1 (def salvo has shots > 1); the first factor of the estimateDps() formula (Turret.java:331, `return shoot.shots / reload * 60f * (peekAmmo() == null ? 0f : peekAmmo().estimateDPS()) * potentialEfficiency * timeScale;`); passed explicitly because it is per-def static state, not a live frame key.', source=SHOOT_PATTERN),
        'reload': a('float', 'public float reload = 10f;', 'The reload time in ticks: ReloadTurret.reload (ReloadTurret.java:10), default 10f; the divisor of the estimateDps() formula (Turret.java:331); passed explicitly because it is per-def static state, not a live frame key. reload = 0 keeps the Java float-division behavior (Infinity for a nonzero numerator) -- no invented guard.', source=RELOAD_TURRET),
        'peek_ammo_estimate_dps': a('float', 'public float estimateDPS(){', 'The peeked ammo bullet DPS: BulletType.estimateDPS() (BulletType.java:414-431, recursive over spawnUnit / despawnUnit / fragBullet / spawnBullets with the cachedDps cache); read by the estimateDps() formula through peekAmmo() (Turret.java:693, `public @Nullable BulletType peekAmmo(){`) and 0.0 when peekAmmo() is null (the Java ternary leg); passed explicitly because BulletType.estimateDPS() is not ported yet.', source=BULLET_TYPE),
        'potential_efficiency': a('float', 'transient float potentialEfficiency;', 'The building potential efficiency: BuildingComp.potentialEfficiency (BuildingComp.java:89), Java default 0.0f, machinery-set later; a factor of the estimateDps() formula (Turret.java:331); passed explicitly because the tick frame tracks no efficiency state yet -- no invented default.', source=BUILDING_COMP),
        'time_scale': a('float', 'return Time.delta * timeScale;', 'The time scale: Time.timeScale through delta() (BuildingComp.java:1922-1923, `public float delta(){` / `return Time.delta * timeScale;`); the last factor of the estimateDps() formula (Turret.java:331); passed explicitly (raw tick seconds, timeScale default 1, as N2248).', source=BUILDING_COMP),
    }
    estimate_dps_outputs = {
        'estimate_dps': a('float', 'return shoot.shots / reload * 60f * (peekAmmo() == null ? 0f : peekAmmo().estimateDPS()) * potentialEfficiency * timeScale;', 'The estimated DPS: shots / reload * 60 * peeked bullet DPS * potentialEfficiency * timeScale (Turret.java:329-331), 0.0 when the turret has no ammo; read by the RTS AI (RtsAI.java:336, `dps[0] += t.estimateDps();`).'),
    }
    return estimate_dps_inputs, estimate_dps_outputs


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
    estimate_dps_inputs, estimate_dps_outputs = definitions()

    entries = [
        ('N2261', ESTIMATE_DPS_OWNER, 'source_turret_estimate_dps_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.estimateDps()', estimate_dps_inputs, estimate_dps_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed TurretBuild.estimateDps() state from Turret.java + ReloadTurret.java + ShootPattern.java + BulletType.java + BuildingComp.java + RtsAI.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed TurretBuild.estimateDps() state from Turret.java + ReloadTurret.java + ShootPattern.java + BulletType.java + BuildingComp.java + RtsAI.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: estimate_dps.
    by_slice['N2261'] = [
        'source_turret_estimate_dps_state_result.estimate_dps',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2261', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.estimateDps()', godot_owner=ESTIMATE_DPS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2261'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
