"""Register the Turret logicControlTime decay (N2261).

TurretBuild.updateTile (Turret.java:490-615) decays the
logic-control timer every tick, after the recoilOffset draw
and before the heat-requirement fold:
`if(logicControlTime > 0){`
`logicControlTime -= Time.delta;`
(Turret.java:534-536). The field is
`public float curRecoil, heat, logicControlTime = -1;`
(:284), so the timer starts at -1 (never logic-controlled)
and only a logic shoot control arms it
(`logicControlTime = logicControlCooldown;`, :384/:394, with
`public final static float logicControlCooldown = 60 * 2;`,
:38 -- 120 ticks of logic control). The reader is
`logicControlled()` (`return logicControlTime > 0;`,
:445-447), so the decay is observable through the
isShooting gate (:492) on the very next tick. The new C07
duo driver (N2250-N2260) never decayed the timer -- the
logicControlled() read had no live timer frame key. This
slice adds the one pure function on the shared TurretBuild
driver file (updateTile() is TurretBuild's method, common
to every turret, not ItemTurret-only) plus one driver tick
in the duo branch AFTER the N2258 recoilOffset tick and
BEFORE the aim call (Java order :532 offset, :534-536
decay, :595-596 turnToTarget, :601/:609 updateShooting).

GREEN decisions (pinned by this slice): (1) One pure function
on SourceTurretBuildState.gd,
source_turret_logic_control_time_state(logic_control_time,
delta), returning `{"logic_control_time": ..}` -- the
guard is `logic_control_time > 0.0`, then subtract delta,
with NO clamp: a timer of 0.001 with delta 1/60 lands
negative (0.001 - 0.0166... = -0.0156...), exactly what
Java does, and the next tick's guard then leaves it alone.
Plus one driver tick in the duo branch (right after the
N2258 recoilOffset tick, before the aim call) that reads
the frame timer (default -1.0, the field default) and the
live-loop `seconds`, calls the pure function, then stamps
the key back on the frame -- the tick runs BEFORE the aim
call, so the isShooting gate (:492, reading
logicControlled()) sees a fresh timer. (2) The control()
setters that arm the timer to logicControlCooldown (120)
wait for their own slices -- the decay only reads the
frame value, it never arms it -- and the rotate sync
(:542-545) is N2262. (3) No legacy
`source_turret_logic_control_time_result` schema exists
(unlike N2258's recoilOffset), so the contract validator
falls through to the new
source_turret_logic_control_time_state_result schema and
no alias is needed. SSOT expected after GREEN:
symbols +1, Done +1, contracts +1, schema +2,
11618/1710/1644/3079 -> 11619/1711/1645/3081; defense
shard slices 189 -> 190, contracts 188 -> 189.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_unit_sync import DEFERRED as N2260_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
PROOF = '/root/C07TurretLogicControlTimeProof'
LOGIC_CONTROL_TIME_OWNER = 'SourceTurretBuildState.source_turret_logic_control_time_state'
TESTS = ['test_c07_turret_logic_control_time_registration', 'test_all_c07_turret_logic_control_time_input_evidence_is_exact', 'test_turret_logic_control_time_state', 'test_reference_graph_and_actual_c07_turret_logic_control_time']
# The slice source the N2261 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
]
EXACT_EXPRS = ['if(logicControlTime > 0){', 'logicControlTime -= Time.delta;', 'public float curRecoil, heat, logicControlTime = -1;', 'return logicControlTime > 0;', 'logicControlTime = logicControlCooldown;', 'public final static float logicControlCooldown = 60 * 2;']

# DEFERRED is carried from the N2260 register script via import --
# never retyped. The logicControlTime decay is done by this
# slice (it was the next item named in the N2260 handoff);
# the control() setters, the rotate sync, the heatReq fold,
# the maxHealth/health re-sync, the set(tile) world position,
# the cross-tick queuedBullets counter, effects/sound,
# findTarget / the other ItemTurret defs still wait.
DEFERRED = list(N2260_DEFERRED) + [
    'Turret logicControlTime decay Windows Godot proof -- debt in GOAL.md section 5, same as N2240-N2260: the N2261 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Turret logicControlTime decay (Turret.java:534-536) -- DONE by this slice (N2261); it was the next item named in the N2260 handoff.',
    'Turret logicControlTime decay for defs other than duo -- the pure function takes logic_control_time / delta as params; only duo is wired in the driver.',
    'Turret control() setters arming logicControlTime = logicControlCooldown (Turret.java:384/:394, LAccess shoot/shootp + targetPos/targetPosition) -- waits for its own slice: the decay only reads the frame value, it never arms the timer.',
    'Turret rotate sync (Turret.java:542-545) -- N2262: `if(rotate){ ((Building)this).rotation = Mathf.mod(Mathf.round(rotation / 90f), 4); }`, needs the rotate default of Turret + whether duo overrides it, and a building_rotation frame key.',
    'Turret heatReq fold (Turret.java:538-540) -- waits for its own slice: needs sideHeat + calculateHeat.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    logic_control_time_inputs = {
        'logic_control_time': a('float', 'public float curRecoil, heat, logicControlTime = -1;', 'The logic-control timer before this tick (Turret.java:284, the field default is -1 -- never logic-controlled; the driver reads frame["logic_control_time"], default -1.0).'),
        'delta': a('float', 'logicControlTime -= Time.delta;', 'The per-tick delta subtracted from the timer (Turret.java:535; the driver passes the live-loop seconds).'),
    }
    logic_control_time_outputs = {
        'logic_control_time': a('float', 'logicControlTime -= Time.delta;', 'The logic-control timer after the tick (Turret.java:535 -- decayed by delta while positive, untouched otherwise, with no clamp; the driver stamps it on frame["logic_control_time"]).'),
    }
    return logic_control_time_inputs, logic_control_time_outputs


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
    logic_control_time_inputs, logic_control_time_outputs = definitions()

    entries = [
        ('N2261', LOGIC_CONTROL_TIME_OWNER, 'source_turret_logic_control_time_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.updateTile()', logic_control_time_inputs, logic_control_time_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret logicControlTime decay from Turret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret logicControlTime decay from Turret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: logic_control_time.
    by_slice['N2261'] = [
        'source_turret_logic_control_time_state_result.logic_control_time',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2261', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.updateTile()', godot_owner=LOGIC_CONTROL_TIME_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2261'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
