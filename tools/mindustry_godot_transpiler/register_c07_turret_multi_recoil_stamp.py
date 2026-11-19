"""Register the Turret multi-recoil stamp (N2257).

TurretBuild.bullet (Turret.java:779-812) stamps the
per-barrel recoil counter of the barrel that just fired,
after the bullet is created and handled: `curRecoil = 1f;` /
`if(recoils > 0){` / `curRecoils[barrelCounter % recoils] =
1f;` / `}` / `heat = 1f;` / `totalShots++;`
(Turret.java:806-811). The driver never stamped
frame["cur_recoils"] after a shot -- N2255 only stamped the
singular curRecoil / heat / totalShots and N2256 only
decayed the cur_recoils array -- so a duo's fired barrel
never kicked back to 1.0 live. This slice adds the one pure
function on the shared TurretBuild driver file (bullet() is
TurretBuild's method, common to every turret, not
ItemTurret-only) plus one driver tick in the duo branch
AFTER the N2255 singular shoot stamp (Java order :806 then
:807-809, both inside bullet(), after the bullet spawn
:797).

GREEN decisions (pinned by this slice): (1) One pure function
on SourceTurretBuildState.gd,
source_turret_multi_recoil_stamp_state(cur_recoils, barrel,
recoils), returning `{"cur_recoils": stamped}` -- a NEW array
of length recoils (missing entries read as 0.0, so a null /
absent frame key inits to zeros), entry barrel % recoils
stamped to 1.0, every other entry untouched, the input array
never mutated; when recoils <= 0 the Java guard does
nothing, so the function returns the input unchanged. Plus
one driver tick in the duo branch (right after the N2255
shoot-stamp tick) that reads frame["cur_recoils"] (default
[]), calls the pure function with the shoot_event barrel
(the PRE-increment barrelCounter -- the aim tick already
stamped frame["barrel_counter"] with barrel_counter_after =
barrelCounter + 1, so the frame key is the WRONG barrel
here) and duo recoils 2, then stamps cur_recoils back on
the frame. One new result symbol. (2) Duo recoils is 2
(`recoils = 2;`, Blocks.java:3301, inside the duo block
3257-3330; the port catalog agrees,
content_registry_blocks.json duo entry has `"recoils": 2`),
NOT the -1 class default (`public int recoils = -1;`,
Turret.java:142) -- the branch DOES apply to duo: its two
drawer barrel parts carry recoilIndex 0 / 1
(Blocks.java:3302-3311) and DrawTurret reads
`tb.curRecoils[part.recoilIndex]`
(DrawTurret.java:104/115). (3) `recoils = 2;` is NOT in
exact_exprs (it lives in Blocks.java, not Turret.java) --
the duo override is pinned by a comment in the .gd plus an
assert on the .gd text in the test. (4) The recoilOffset
draw (`recoilOffset.trns(rotation, -Mathf.pow(curRecoil,
recoilPow) * recoil);`, :532) is NOT this slice: it is
draw-side. The charge advance (:527), effects/sound,
queuedBullets, findTarget and the other ItemTurret defs
still wait. SSOT expected after GREEN: symbols +1,
Done +1, contracts +1, schema +2, 11609/1706/1640/3071 ->
11610/1707/1641/3073; defense shard slices 185 -> 186,
contracts 184 -> 185.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_multi_recoil import DEFERRED as N2256_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
PROOF = '/root/C07TurretMultiRecoilStampProof'
MULTI_RECOIL_STAMP_OWNER = 'SourceTurretBuildState.source_turret_multi_recoil_stamp_state'
TESTS = ['test_c07_turret_multi_recoil_stamp_registration', 'test_all_c07_turret_multi_recoil_stamp_input_evidence_is_exact', 'test_turret_multi_recoil_stamp_state', 'test_reference_graph_and_actual_c07_turret_multi_recoil_stamp']
# The slice source the N2257 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
]
EXACT_EXPRS = ['curRecoil = 1f;', 'if(recoils > 0){', 'curRecoils[barrelCounter % recoils] = 1f;', 'heat = 1f;', 'totalShots++;', 'public @Nullable float[] curRecoils;', 'public int recoils = -1;', 'public int totalShots, barrelCounter;']

# DEFERRED is carried from the N2256 register script via import --
# never retyped. The multi-recoil stamp is done by this slice, so
# the N2256 "Turret multi-recoil stamp ... waits for its own
# slice (N2257)" entry is superseded (the stamp is N2257
# itself); the recoilOffset draw, the charge advance,
# effects/sound, queuedBullets / findTarget / the other
# ItemTurret defs still wait.
DEFERRED = list(N2256_DEFERRED) + [
    'Turret multi-recoil stamp Windows Godot proof -- debt in GOAL.md section 5, same as N2240-N2256: the N2257 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Turret multi-recoil stamp (curRecoils[barrelCounter % recoils] = 1f;, Turret.java:807-809) -- DONE by this slice (N2257); the N2256 deferred entry above saying it waits for N2257 is superseded.',
    'Turret recoilOffset draw (recoilOffset.trns(rotation, -Mathf.pow(curRecoil, recoilPow) * recoil);, Turret.java:532, recoilPow 1.8) -- draw-side; the stamp slice only sets the values, the offset waits for its own slice.',
    'Turret charge advance (charge approachDelta, Turret.java:527) -- needs queuedBullets + firstShotDelay > 0; it goes with the queuedBullets slice, not the multi-recoil-stamp slice.',
    'Turret multi-recoil stamp for defs other than duo -- the pure function takes barrel / recoils as params; only duo is wired in the driver.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    multi_recoil_stamp_inputs = {
        'cur_recoils': a('Array', 'public @Nullable float[] curRecoils;', 'The per-barrel recoil counters 0..1 (Turret.java:285, the curRecoils field, null until the first updateTile tick allocates it; the driver reads it from frame["cur_recoils"], default [] -- no cur_recoils key existed before N2256 -- and missing entries read as 0.0).'),
        'barrel': a('int', 'public int totalShots, barrelCounter;', 'The barrel that just fired, pre-increment (Turret.java:287, the barrelCounter field; pattern.shoot runs before the `}, () -> barrelCounter++);` incrementer at :770, so the driver passes the shoot_event barrel, not frame["barrel_counter"] which the aim tick already stamped with barrel_counter_after).'),
        'recoils': a('int', 'public int recoils = -1;', 'The number of per-barrel counters (Turret.java:142, the class default -1; duo overrides it with `recoils = 2;`, Blocks.java:3301, so the driver passes 2).'),
    }
    multi_recoil_stamp_outputs = {
        'cur_recoils': a('Array', 'curRecoils[barrelCounter % recoils] = 1f;', 'The per-barrel counters after the shot (Turret.java:808 -- entry barrelCounter % recoils stamped to 1.0, every other entry untouched; a NEW array of length recoils, the input never mutated; when recoils <= 0 the guard does nothing and the input is returned unchanged).'),
    }
    return multi_recoil_stamp_inputs, multi_recoil_stamp_outputs


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
    multi_recoil_stamp_inputs, multi_recoil_stamp_outputs = definitions()

    entries = [
        ('N2257', MULTI_RECOIL_STAMP_OWNER, 'source_turret_multi_recoil_stamp_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.bullet()', multi_recoil_stamp_inputs, multi_recoil_stamp_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret multi-recoil stamp from Turret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret multi-recoil stamp from Turret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: cur_recoils.
    by_slice['N2257'] = [
        'source_turret_multi_recoil_stamp_state_result.cur_recoils',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2257', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.bullet()', godot_owner=MULTI_RECOIL_STAMP_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2257'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
