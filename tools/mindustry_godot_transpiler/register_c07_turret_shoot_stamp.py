"""Register the Turret shoot stamp (N2255).

TurretBuild.bullet (Turret.java:779-812) stamps the recoil and
the heat and counts the shot after the bullet is created and
handled: `curRecoil = 1f;` (Turret.java:806), `heat = 1f;`
(:810) and `totalShots++;` (:811). The driver never stamped
any of the three -- N2252 only stamped frame["bullet_spawn"]
and N2254 only decayed the values toward 0 -- so a duo that
shoots keeps cur_recoil 0 / heat 0 / total_shots 0 live. This
slice adds the one pure function on the shared TurretBuild
driver file (bullet() is TurretBuild's method, common to every
turret, not ItemTurret-only) plus one driver tick in the duo
shot branch AFTER the spawn_turret_bullet call (Java order
:806-811 after the bullet is created at :797).

GREEN decisions (pinned by this slice): (1) One pure function
on SourceTurretBuildState.gd,
source_turret_shoot_stamp_state(cur_recoil, heat, total_shots),
returning `{"cur_recoil": 1.0, "heat": 1.0, "total_shots":
total_shots + 1}`, plus one driver tick in the duo shot branch
(after the spawn_turret_bullet call) that reads
frame["cur_recoil"] / frame["heat"] / frame["total_shots"]
(defaults 0.0 / 0.0 / 0 -- no total_shots key existed before
this slice), calls the pure function, then stamps cur_recoil +
heat + total_shots back on the frame, so the next tick decays
from 1.0 (N2254) and counts from the stamped total. Three new
result symbols. (2) The inputs are the pre-shot frame values,
so the pure function maps any decayed recoil / heat to 1.0 and
any count to count + 1. (3) The multi-recoil stamp
(`if(recoils > 0){` / `curRecoils[barrelCounter % recoils] =
1f;` / `}`, :807-809) is NOT this slice: duo recoils is -1,
so the branch is skipped, and a def with recoils > 0 waits
for its own slice. (4) The effects / sound / shake lines
(:799-805) are NOT this slice either. SSOT expected after
GREEN: symbols +3, Done +1, contracts +1, schema +2,
11605/1704/1638/3067 -> 11608/1705/1639/3069; defense shard
slices 183 -> 184, contracts 182 -> 183.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_recoil_heat import DEFERRED as N2254_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
PROOF = '/root/C07TurretShootStampProof'
SHOOT_STAMP_OWNER = 'SourceTurretBuildState.source_turret_shoot_stamp_state'
TESTS = ['test_c07_turret_shoot_stamp_registration', 'test_all_c07_turret_shoot_stamp_input_evidence_is_exact', 'test_turret_shoot_stamp_state', 'test_reference_graph_and_actual_c07_turret_shoot_stamp']
# The slice source the N2255 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
]
EXACT_EXPRS = ['curRecoil = 1f;', 'if(recoils > 0){', 'curRecoils[barrelCounter % recoils] = 1f;', 'heat = 1f;', 'totalShots++;', 'public float curRecoil, heat, logicControlTime = -1;', 'public int totalShots, barrelCounter;', 'public int recoils = -1;', 'public float recoil = 1f;', 'public float recoilTime = -1f;', 'public float cooldownTime = 20f;', 'if(recoilTime < 0f) recoilTime = reload;', 'if(cooldownTime < 0f) cooldownTime = reload;', 'if(reloadCounter >= reload && !charging() && shootWarmup >= minWarmup){']

# DEFERRED is carried from the N2254 register script via import --
# never retyped. The shoot stamp is done by this slice, so the
# N2254 "Turret shoot stamp ... waits with the shoot-stamp
# slice" entry is superseded for the stamp itself (the
# multi-recoil stamp and the draw offset still wait, as separate
# entries below); the charge advance, effects/sound/shake,
# queuedBullets / findTarget / the other ItemTurret defs still
# wait.
DEFERRED = list(N2254_DEFERRED) + [
    'Turret shoot stamp Windows Godot proof -- debt in GOAL.md section 5, same as N2240-N2254: the N2255 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Turret multi-recoil stamp (curRecoils[barrelCounter % recoils] = 1f;, Turret.java:807-809) -- duo recoils is -1, so the branch is skipped; a def with recoils > 0 waits for its own slice.',
    'Turret recoilOffset draw (recoilOffset.trns(rotation, -Mathf.pow(curRecoil, recoilPow) * recoil);, Turret.java:532, recoilPow 1.8) -- draw-side; the shoot stamp only sets the values, the offset waits for its own slice.',
    'Turret charge advance (charge approachDelta, Turret.java:527) -- needs queuedBullets + firstShotDelay > 0; it goes with the queuedBullets slice, not the shoot-stamp slice.',
    'Turret shoot stamp for defs other than duo -- the pure function takes the pre-shot frame values as params; only duo is wired in the driver.',
    'Turret shoot effects / sound / shake (Turret.java:799-805) -- presentation / audio, not tick state; waits for its own slice.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    shoot_stamp_inputs = {
        'cur_recoil': a('float', 'curRecoil = 1f;', 'The pre-shot recoil 0..1 (Turret.java:284, the curRecoil field; the driver reads it from frame["cur_recoil"], default 0.0, and the stamp maps any decayed value to 1.0).'),
        'heat': a('float', 'heat = 1f;', 'The pre-shot heat 0..1 (Turret.java:284, the heat field; the driver reads it from frame["heat"], default 0.0, and the stamp maps any decayed value to 1.0).'),
        'total_shots': a('int', 'public int totalShots, barrelCounter;', 'The pre-shot shot count (Turret.java:287, the totalShots field, default 0; the driver reads it from frame["total_shots"], default 0 -- no total_shots key existed before this slice).'),
    }
    shoot_stamp_outputs = {
        'cur_recoil': a('float', 'curRecoil = 1f;', 'The recoil after the shot (Turret.java:806 -- stamped to 1.0; the next tick decays from 1.0, N2254).'),
        'heat': a('float', 'heat = 1f;', 'The heat after the shot (Turret.java:810 -- stamped to 1.0; the next tick decays from 1.0, N2254).'),
        'total_shots': a('int', 'totalShots++;', 'The shot count after the shot (Turret.java:811 -- the pre-shot count + 1).'),
    }
    return shoot_stamp_inputs, shoot_stamp_outputs


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
    shoot_stamp_inputs, shoot_stamp_outputs = definitions()

    entries = [
        ('N2255', SHOOT_STAMP_OWNER, 'source_turret_shoot_stamp_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.bullet()', shoot_stamp_inputs, shoot_stamp_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret shoot stamp from Turret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret shoot stamp from Turret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: cur_recoil, heat, total_shots.
    by_slice['N2255'] = [
        'source_turret_shoot_stamp_state_result.cur_recoil',
        'source_turret_shoot_stamp_state_result.heat',
        'source_turret_shoot_stamp_state_result.total_shots',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2255', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.bullet()', godot_owner=SHOOT_STAMP_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2255'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
