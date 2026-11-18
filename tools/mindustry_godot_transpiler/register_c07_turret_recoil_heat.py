"""Register the Turret recoil + heat decay (N2254).

TurretBuild.updateTile (Turret.java:490-532) decays the recoil
and the heat after the warmup advance and before it aims or
shoots: `curRecoil = Mathf.approachDelta(curRecoil, 0, 1 /
recoilTime);` (Turret.java:519) and `heat =
Mathf.approachDelta(heat, 0, 1 / cooldownTime);` (:526). The
driver never read frame["cur_recoil"] or frame["heat"] -- there
is no such key in SourceTurretBuildState.gd at all -- so recoil
and heat never decayed live. This slice adds the one pure
function on the shared TurretBuild driver file (it is
TurretBuild.updateTile, common to every turret, not
ItemTurret-only) plus one driver tick in the duo branch AFTER
the warmup stamp (N2253) and BEFORE the aim/shoot call (Java
order :519/:526 after :502-515 and before the shoot gate
:733).

GREEN decisions (pinned by this slice): (1) One pure function
on SourceTurretBuildState.gd,
source_turret_recoil_heat_state(cur_recoil, heat, recoil_time,
cooldown_time, delta), returning `{"cur_recoil": ...,
"heat": ...}`, plus one driver tick in the duo branch (after
the warmup stamp, before the aim/shoot call) that reads
frame["cur_recoil"] / frame["heat"] (default 0.0 -- neither
key existed before this slice), calls the pure function with
the per-def duo values (recoil_time 20.0 = reload,
cooldown_time 20.0 = class default) and delta = seconds, then
stamps cur_recoil + heat back on the frame. Two new result
symbols. (2) The step is approachDelta toward 0: each tick
moves the value by delta / recoilTime (resp. delta /
cooldownTime), never past 0 -- arc Mathf approach /
approachDelta (Mathf.java:415-422). With the duo values the
rate is 0.05 per tick, so a recoil of 1.0 reaches exactly 0.0
in 20 ticks. (3) The multi-recoil loop (:520-525) is NOT
this slice: duo recoils is -1, so the loop is skipped, and a
def with recoils > 0 waits for its own slice. (4) The shoot
stamp (`curRecoil = 1f;` / `heat = 1f;`, :807-810) and the
draw offset (`recoilOffset.trns(rotation,
-Mathf.pow(curRecoil, recoilPow) * recoil);`, :532) are NOT
this slice either: the shoot stamp waits with the
shoot-stamp slice (N2252 only stamped frame["bullet_spawn"])
and the offset is draw-side. (5) Delta is the live-loop
seconds value, the same convention as the N2253 warmup
(SourceFactoryRuntimeState.gd:214 passes delta into
source_turret_tick_buildings_state). SSOT expected after
GREEN: symbols +2, Done +1, contracts +1, schema +2,
11603/1703/1637/3065 -> 11605/1704/1638/3067; defense shard
slices 182 -> 183, contracts 181 -> 182.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_warmup import DEFERRED as N2253_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
MATHF = 'arc-core/src/arc/math/Mathf.java'
PROOF = '/root/C07TurretRecoilHeatProof'
RECOIL_HEAT_OWNER = 'SourceTurretBuildState.source_turret_recoil_heat_state'
TESTS = ['test_c07_turret_recoil_heat_registration', 'test_all_c07_turret_recoil_heat_input_evidence_is_exact', 'test_turret_recoil_heat_state', 'test_reference_graph_and_actual_c07_turret_recoil_heat']
# The 2 slice sources the N2254 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'arc-core/src/arc/math/Mathf.java',
]
EXACT_EXPRS = ['curRecoil = Mathf.approachDelta(curRecoil, 0, 1 / recoilTime);', 'heat = Mathf.approachDelta(heat, 0, 1 / cooldownTime);', 'if(recoils > 0){', 'curRecoils[i] = Mathf.approachDelta(curRecoils[i], 0, 1 / recoilTime);', 'public float recoil = 1f;', 'public int recoils = -1;', 'public float recoilTime = -1f;', 'public float recoilPow = 1.8f;', 'public float cooldownTime = 20f;', 'if(recoilTime < 0f) recoilTime = reload;', 'if(cooldownTime < 0f) cooldownTime = reload;', 'curRecoil = 1f;', 'heat = 1f;', 'recoilOffset.trns(rotation, -Mathf.pow(curRecoil, recoilPow) * recoil);', 'public float curRecoil, heat, logicControlTime = -1;', 'public static float approach(float from, float to, float speed){', 'return from + Mathf.clamp(to - from, -speed, speed);', 'public static float approachDelta(float from, float to, float speed){', 'return approach(from, to, Time.delta * speed);', 'float warmupTarget = (isShooting && canConsume()) || charging() ? 1f : 0f;', 'if(reloadCounter >= reload && !charging() && shootWarmup >= minWarmup){']

# DEFERRED is carried from the N2253 register script via import --
# never retyped. Recoil/heat decay is done by this slice, so the
# N2253 "Turret recoil/heat decay ... (N2254 candidate)" entry and
# the N2250 lumped "bullet() recoil/heat/totalShots" entry are
# superseded for the decay itself (the shoot stamp and the draw
# offset still wait, as separate entries below); the charge
# advance, multi-recoil, and findTarget / queuedBullets / the
# other ItemTurret defs still wait.
DEFERRED = list(N2253_DEFERRED) + [
    'Turret recoil/heat Windows Godot proof -- debt in GOAL.md section 5, same as N2240-N2253: the N2254 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Turret multi-recoil array (curRecoils approachDelta, Turret.java:520-525) -- duo recoils is -1, so the loop is skipped; a def with recoils > 0 waits for its own slice.',
    'Turret shoot stamp (curRecoil = 1f; / heat = 1f; / totalShots++;, Turret.java:807-810) -- the decay slice only decays the values; the stamp that sets them to 1 on a shot waits with the shoot-stamp slice.',
    'Turret recoilOffset draw (recoilOffset.trns(rotation, -Mathf.pow(curRecoil, recoilPow) * recoil);, Turret.java:532, recoilPow 1.8) -- draw-side; the decay slice only advances the values, the offset waits for its own slice.',
    'Turret charge advance (charge approachDelta, Turret.java:527) -- needs queuedBullets + firstShotDelay > 0; it goes with the queuedBullets slice, not the recoil/heat slice.',
    'Turret recoil/heat for defs with recoilTime / cooldownTime other than the duo defaults (per-def values other than recoilTime 20 / cooldownTime 20) -- the pure function takes them as params; only duo is wired in the driver.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    recoil_heat_inputs = {
        'cur_recoil': a('float', 'curRecoil = Mathf.approachDelta(curRecoil, 0, 1 / recoilTime);', 'The current recoil 0..1 (Turret.java:284, the curRecoil field the approachDelta step decays; the driver reads it from frame["cur_recoil"], default 0.0).'),
        'heat': a('float', 'heat = Mathf.approachDelta(heat, 0, 1 / cooldownTime);', 'The current heat 0..1 (Turret.java:284, the heat field the approachDelta step decays; the driver reads it from frame["heat"], default 0.0).'),
        'recoil_time': a('float', 'if(recoilTime < 0f) recoilTime = reload;', 'The recoil time in ticks (Turret.java:208, init -- recoilTime < 0 falls back to reload; duo reload is 20, N2250, so the driver passes 20.0).'),
        'cooldown_time': a('float', 'public float cooldownTime = 20f;', 'The cooldown time in ticks (Turret.java:148, class default 20f -- duo does not override it; the driver passes 20.0).'),
        'delta': a('float', 'return approach(from, to, Time.delta * speed);', 'The scaled tick delta in seconds (arc Mathf.java:422, approachDelta -- Time.delta; the driver passes seconds, the same convention as the N2253 warmup).', source=MATHF),
    }
    recoil_heat_outputs = {
        'cur_recoil': a('float', 'curRecoil = Mathf.approachDelta(curRecoil, 0, 1 / recoilTime);', 'The recoil after this tick (Turret.java:519 -- moved toward 0 by delta / recoilTime, never past 0; with the duo values the rate is 0.05 per tick, so 1.0 reaches 0.0 in 20 ticks).'),
        'heat': a('float', 'heat = Mathf.approachDelta(heat, 0, 1 / cooldownTime);', 'The heat after this tick (Turret.java:526 -- moved toward 0 by delta / cooldownTime, never past 0; with the duo values the rate is 0.05 per tick, so 1.0 reaches 0.0 in 20 ticks).'),
    }
    return recoil_heat_inputs, recoil_heat_outputs


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
    recoil_heat_inputs, recoil_heat_outputs = definitions()

    entries = [
        ('N2254', RECOIL_HEAT_OWNER, 'source_turret_recoil_heat_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.updateTile()', recoil_heat_inputs, recoil_heat_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret recoil + heat decay from Turret.java / Mathf.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret recoil + heat decay from Turret.java / Mathf.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: cur_recoil, heat.
    by_slice['N2254'] = [
        'source_turret_recoil_heat_state_result.cur_recoil',
        'source_turret_recoil_heat_state_result.heat',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2254', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.updateTile()', godot_owner=RECOIL_HEAT_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2254'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
