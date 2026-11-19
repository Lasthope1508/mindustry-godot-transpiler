"""Register the Turret multi-recoil decay (N2256).

TurretBuild.updateTile (Turret.java:490-532) decays the
per-barrel recoil counters right after the singular recoil
decay: `if(recoils > 0){` / `if(curRecoils == null) curRecoils
= new float[recoils];` / `for(int i = 0; i < recoils; i++){` /
`curRecoils[i] = Mathf.approachDelta(curRecoils[i], 0, 1 /
recoilTime);` / `}` (Turret.java:520-525). The driver never
stamped frame["cur_recoils"] -- N2254 only decayed the
singular curRecoil and N2255 only stamped the singular
curRecoil -- so a duo's barrel recoil never fell back toward
0 live. This slice adds the one pure function on the shared
TurretBuild driver file (updateTile is TurretBuild's method,
common to every turret, not ItemTurret-only) plus one driver
tick in the duo branch AFTER the N2254 singular recoil/heat
decay (Java order :519 then :520-525) and BEFORE the
aim/shoot call.

GREEN decisions (pinned by this slice): (1) One pure function
on SourceTurretBuildState.gd,
source_turret_multi_recoil_state(cur_recoils, recoils,
recoil_time, delta), returning `{"cur_recoils": decayed}` --
a NEW array of length recoils (missing entries read as 0.0,
so a null / absent frame key inits to zeros), each entry
moved toward 0 by delta / recoilTime, never past 0; the
input array is never mutated. Plus one driver tick in the
duo branch (after the N2254 decay tick, before aim/shoot)
that reads frame["cur_recoils"] (default [] -- no
cur_recoils key existed before this slice), calls the pure
function with the per-def duo values (recoils 2, recoil_time
20.0 = reload) and delta = seconds, then stamps cur_recoils
back on the frame. One new result symbol. (2) CORRECTION:
duo recoils is 2, NOT -1 -- N2254/N2255 deferred the
multi-recoil loop/stamp citing only the class default
(`public int recoils = -1;`, Turret.java:142) and missing
the duo override (`recoils = 2;`, Blocks.java:3301, inside
the duo block 3257-3330; the port catalog agrees,
content_registry_blocks.json duo entry has `"recoils": 2`).
The loop DOES apply to duo: its two drawer barrel parts
carry recoilIndex 0 / 1 (Blocks.java:3302-3311) and
DrawTurret reads `tb.curRecoils[part.recoilIndex]`
(DrawTurret.java:104/115). The N2254/N2255 comments in
SourceTurretBuildState.gd saying "duo recoils is -1" were
WRONG -- this slice fixes them, and the N2254/N2255
deferred entries citing -1 are superseded for the value
(the multi-recoil stamp itself still waits, N2257). (3)
`recoils = 2;` is NOT in exact_exprs (it lives in
Blocks.java, not Turret.java) -- the duo override is pinned
by a comment in the .gd plus an assert on the .gd text in
the test. (4) The multi-recoil stamp (`curRecoils[
barrelCounter % recoils] = 1f;`, :807-809) and the draw
offset (`recoilOffset.trns(rotation, -Mathf.pow(curRecoil,
recoilPow) * recoil);`, :532) are NOT this slice: the stamp
waits with the multi-recoil-stamp slice (N2257) and the
offset is draw-side. SSOT expected after GREEN: symbols +1,
Done +1, contracts +1, schema +2, 11608/1705/1639/3069 ->
11609/1706/1640/3071; defense shard slices 184 -> 185,
contracts 183 -> 184.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_shoot_stamp import DEFERRED as N2255_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
PROOF = '/root/C07TurretMultiRecoilProof'
MULTI_RECOIL_OWNER = 'SourceTurretBuildState.source_turret_multi_recoil_state'
TESTS = ['test_c07_turret_multi_recoil_registration', 'test_all_c07_turret_multi_recoil_input_evidence_is_exact', 'test_turret_multi_recoil_state', 'test_reference_graph_and_actual_c07_turret_multi_recoil']
# The slice source the N2256 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
]
EXACT_EXPRS = ['curRecoil = Mathf.approachDelta(curRecoil, 0, 1 / recoilTime);', 'if(recoils > 0){', 'if(curRecoils == null) curRecoils = new float[recoils];', 'curRecoils[i] = Mathf.approachDelta(curRecoils[i], 0, 1 / recoilTime);', 'public @Nullable float[] curRecoils;', 'public int recoils = -1;', 'public float recoilTime = -1f;', 'if(recoilTime < 0f) recoilTime = reload;']

# DEFERRED is carried from the N2255 register script via import --
# never retyped. The multi-recoil decay is done by this slice, so
# the N2254 "Turret multi-recoil array ... duo recoils is -1"
# entry and the N2255 "Turret multi-recoil stamp ... duo recoils
# is -1" entry are superseded for the recoils VALUE (duo recoils
# is 2, Blocks.java:3301, not the -1 class default); the
# multi-recoil stamp itself still waits (N2257), as a separate
# entry below. The recoilOffset draw, the charge advance,
# effects/sound, queuedBullets / findTarget / the other
# ItemTurret defs still wait.
DEFERRED = list(N2255_DEFERRED) + [
    'Turret multi-recoil Windows Godot proof -- debt in GOAL.md section 5, same as N2240-N2255: the N2256 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Turret multi-recoil stamp (curRecoils[barrelCounter % recoils] = 1f;, Turret.java:807-809) -- duo recoils is 2 (Blocks.java:3301), so the branch applies to duo; it waits for its own slice (N2257).',
    'Turret recoilOffset draw (recoilOffset.trns(rotation, -Mathf.pow(curRecoil, recoilPow) * recoil);, Turret.java:532, recoilPow 1.8) -- draw-side; the decay slice only advances the values, the offset waits for its own slice.',
    'Turret charge advance (charge approachDelta, Turret.java:527) -- needs queuedBullets + firstShotDelay > 0; it goes with the queuedBullets slice, not the multi-recoil slice.',
    'Turret multi-recoil decay for defs other than duo -- the pure function takes recoils / recoil_time as params; only duo is wired in the driver.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    multi_recoil_inputs = {
        'cur_recoils': a('Array', 'public @Nullable float[] curRecoils;', 'The per-barrel recoil counters 0..1 (Turret.java:285, the curRecoils field, null until the first updateTile tick allocates it; the driver reads it from frame["cur_recoils"], default [] -- no cur_recoils key existed before this slice -- and missing entries read as 0.0).'),
        'recoils': a('int', 'public int recoils = -1;', 'The number of per-barrel counters (Turret.java:142, the class default -1; duo overrides it with `recoils = 2;`, Blocks.java:3301, so the driver passes 2).'),
        'recoil_time': a('float', 'if(recoilTime < 0f) recoilTime = reload;', 'The recoil time in ticks (Turret.java:208, init -- recoilTime < 0 falls back to reload; duo reload is 20, N2250, so the driver passes 20.0).'),
        'delta': a('float', 'curRecoil = Mathf.approachDelta(curRecoil, 0, 1 / recoilTime);', 'The scaled tick delta in seconds (Turret.java:519, approachDelta -- Time.delta; the driver passes seconds, the same convention as the N2254 recoil/heat decay).'),
    }
    multi_recoil_outputs = {
        'cur_recoils': a('Array', 'curRecoils[i] = Mathf.approachDelta(curRecoils[i], 0, 1 / recoilTime);', 'The per-barrel counters after this tick (Turret.java:524 -- each entry moved toward 0 by delta / recoilTime, never past 0; a NEW array of length recoils, the input never mutated).'),
    }
    return multi_recoil_inputs, multi_recoil_outputs


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
    multi_recoil_inputs, multi_recoil_outputs = definitions()

    entries = [
        ('N2256', MULTI_RECOIL_OWNER, 'source_turret_multi_recoil_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.updateTile()', multi_recoil_inputs, multi_recoil_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret multi-recoil decay from Turret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret multi-recoil decay from Turret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: cur_recoils.
    by_slice['N2256'] = [
        'source_turret_multi_recoil_state_result.cur_recoils',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2256', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.updateTile()', godot_owner=MULTI_RECOIL_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2256'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
