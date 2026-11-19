"""Register the Turret recoilOffset draw (N2258).

TurretBuild.updateTile (Turret.java:490-615) recomputes the
draw offset every tick, after the recoil/heat decay and
before turnToTarget: `recoilOffset.trns(rotation,
-Mathf.pow(curRecoil, recoilPow) * recoil);`
(Turret.java:532). The new C07 duo driver (N2250-N2257)
never stamped frame["recoil_offset"] -- the formula was
already proven once on the legacy PortGame path (N742,
`PortGame.source_turret_recoil_offset`, MCP: recoil 0.5 /
rotation 0 / curRecoil 1 -> Vector2(-0.5, 0.0)), but the
duo sprite never kicked back live on the new frame driver.
This slice adds the one pure function on the shared
TurretBuild driver file (updateTile() is TurretBuild's
method, common to every turret, not ItemTurret-only) plus
one driver tick in the duo branch AFTER the N2256
multi-recoil decay tick and BEFORE the aim/shoot call
(Java order :519/:520-525 decay, :532 offset, :595-596
turnToTarget, :601/:609 updateShooting).

GREEN decisions (pinned by this slice): (1) One pure function
on SourceTurretBuildState.gd,
source_turret_recoil_offset_state(rotation, cur_recoil,
recoil_pow, recoil), returning `{"recoil_offset": {"x": ..,
"y": ..}}` -- the frame's JSON-friendly dict convention,
same as frame["target_pos"] from the N2250 aim state.
trns: x = cos(rotation) * mag, y = sin(rotation) * mag,
mag = -pow(cur_recoil, recoil_pow) * recoil. Plus one
driver tick in the duo branch (right after the N2256
multi-recoil decay tick, before the aim call) that reads
frame["rotation"] (default 90.0, the aim stamp default --
the PREVIOUS tick's rotation, since Java :532 runs before
turnToTarget :595-596) and frame["cur_recoil"] (already
decayed this tick by the N2254 tick), calls the pure
function with duo recoilPow 1.8 / recoil 0.5, then stamps
recoil_offset back on the frame. One new result symbol.
(2) Duo recoilPow is 1.8 (`public float recoilPow = 1.8f;`,
Turret.java:146) and duo recoil is 0.5 (`recoil = 0.5f;`,
Blocks.java:3315, inside the duo block 3257-3330), NOT the
1.0 class default (`public float recoil = 1f;`,
Turret.java:140). (3) `recoil = 0.5f;` is NOT in
exact_exprs (it lives in Blocks.java, not Turret.java) --
the duo override is pinned by a comment in the .gd plus an
assert on the .gd text in the test, same rule as N2257's
`recoils = 2;`. (4) The offset lags a shot by one tick:
Java :532 runs before the shoot gate :733, so the tick
that shoots still offsets from the pre-shot recoil and
only the next tick kicks. (5) The charge advance (:527),
effects/sound, queuedBullets, findTarget and the other
ItemTurret defs still wait. (6) Gate N2258 found the contract
validator resolves the result schema by trying
source_turret_recoil_offset_result (legacy N742) before
source_turret_recoil_offset_state_result, so this register
script also aliases the recoil_offset return key into the
legacy result schema -- no new schema, no new symbol.
SSOT expected after GREEN:
symbols +1, Done +1, contracts +1, schema +2,
11610/1707/1641/3073 -> 11611/1708/1642/3075; defense
shard slices 186 -> 187, contracts 185 -> 186.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_multi_recoil_stamp import DEFERRED as N2257_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
PROOF = '/root/C07TurretRecoilOffsetProof'
RECOIL_OFFSET_OWNER = 'SourceTurretBuildState.source_turret_recoil_offset_state'
TESTS = ['test_c07_turret_recoil_offset_registration', 'test_all_c07_turret_recoil_offset_input_evidence_is_exact', 'test_turret_recoil_offset_state', 'test_reference_graph_and_actual_c07_turret_recoil_offset']
# The slice source the N2258 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
]
EXACT_EXPRS = ['recoilOffset.trns(rotation, -Mathf.pow(curRecoil, recoilPow) * recoil);', 'public Vec2 recoilOffset = new Vec2();', 'public float recoilPow = 1.8f;', 'public float recoil = 1f;', 'public float curRecoil, heat, logicControlTime = -1;']

# DEFERRED is carried from the N2257 register script via import --
# never retyped. The recoilOffset draw is done by this slice, so
# the N2257 "Turret recoilOffset draw ... waits for its own
# slice" entry is superseded (the draw tick is N2258 itself);
# the charge advance, effects/sound, queuedBullets /
# findTarget / the other ItemTurret defs still wait.
DEFERRED = list(N2257_DEFERRED) + [
    'Turret recoilOffset draw Windows Godot proof -- debt in GOAL.md section 5, same as N2240-N2257: the N2258 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Turret recoilOffset draw (recoilOffset.trns(rotation, -Mathf.pow(curRecoil, recoilPow) * recoil);, Turret.java:532, recoilPow 1.8, duo recoil 0.5) -- DONE by this slice (N2258); the N2257 deferred entry above saying it waits for its own slice is superseded.',
    'Turret charge advance (charge approachDelta, Turret.java:527) -- needs queuedBullets + firstShotDelay > 0; it goes with the queuedBullets slice, not the recoilOffset slice.',
    'Turret recoilOffset draw for defs other than duo -- the pure function takes rotation / cur_recoil / recoil_pow / recoil as params; only duo is wired in the driver.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    recoil_offset_inputs = {
        'rotation': a('float', 'rotation = Angles.moveToward(rotation, targetRot, rotateSpeed * delta() * potentialEfficiency);', 'The turret rotation the offset is drawn along (Turret.java:666, the turnToTarget update; the driver reads the PREVIOUS tick rotation from frame["rotation"], default 90.0, because Java :532 runs before turnToTarget :595-596).'),
        'cur_recoil': a('float', 'public float curRecoil, heat, logicControlTime = -1;', 'The decayed recoil 0..1 (Turret.java:284, the curRecoil field; the driver reads frame["cur_recoil"], already decayed this tick by the N2254 tick, so a shot stamped last tick kicks this tick).'),
        'recoil_pow': a('float', 'public float recoilPow = 1.8f;', 'The power curve applied to the visual recoil (Turret.java:146; duo uses the class value 1.8, so the driver passes 1.8).'),
        'recoil': a('float', 'public float recoil = 1f;', 'The visual recoil amount per shot (Turret.java:140, the class default 1.0; duo overrides it with `recoil = 0.5f;`, Blocks.java:3315, so the driver passes 0.5).'),
    }
    recoil_offset_outputs = {
        'recoil_offset': a('Dictionary', 'recoilOffset.trns(rotation, -Mathf.pow(curRecoil, recoilPow) * recoil);', 'The sprite offset after the tick (Turret.java:532 -- trns from the rotation and -pow(cur_recoil, recoil_pow) * recoil, returned as a {"x": .., "y": ..} dict, the frame JSON-friendly convention; zero with no recoil, -recoil along the rotation at a fresh shot).'),
    }
    return recoil_offset_inputs, recoil_offset_outputs


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
    recoil_offset_inputs, recoil_offset_outputs = definitions()

    entries = [
        ('N2258', RECOIL_OFFSET_OWNER, 'source_turret_recoil_offset_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.updateTile()', recoil_offset_inputs, recoil_offset_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret recoilOffset draw from Turret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret recoilOffset draw from Turret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: recoil_offset.
    by_slice['N2258'] = [
        'source_turret_recoil_offset_state_result.recoil_offset',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2258', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.updateTile()', godot_owner=RECOIL_OFFSET_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2258'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

    source_symbols.upsert_source_symbols(GODOT, symbols)
    source_symbols.write_source_symbol_audit_report(GODOT)

    # N2258 linkage fix (gate N2258 found it): the contract validator
    # (_contract_result_schema_name) resolves the result schema for
    # source_turret_recoil_offset_state by trying
    # source_turret_recoil_offset_result FIRST -- the legacy N742
    # schema for PortGame.source_turret_recoil_offset -- and only
    # then source_turret_recoil_offset_state_result, so the return
    # key recoil_offset must also exist in the legacy schema. Alias
    # it to the canonical N2258 result key, following the alias
    # pattern the legacy schema already uses (curRecoil, formula,
    # recoil, rotation, turret). No new schema, no new symbol, no
    # change to the N742 entries.
    legacy = source_symbols.load_source_state_schema(GODOT)['schemas']['source_turret_recoil_offset_result']
    legacy_keys = dict(legacy.get('keys', {}))
    legacy_keys['recoil_offset'] = {
        'alias_of': 'source_turret_recoil_offset_state_result.recoil_offset',
        'rule': 'The sprite offset after the tick, returned as a {"x": .., "y": ..} dict by SourceTurretBuildState.source_turret_recoil_offset_state (Turret.java:532); aliases the canonical N2258 result key because the contract validator resolves this legacy result schema before the _state_result schema.',
        'status': 'generated',
        'type': 'Dictionary',
    }
    source_symbols.upsert_source_state_schema(GODOT, 'source_turret_recoil_offset_result', {**legacy, 'keys': legacy_keys})

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
