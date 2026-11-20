"""Register the Turret logicControlled() live derivation (N2278).

logicControlled() is `public boolean logicControlled(){
return logicControlTime > 0; }` (Turret.java:445-447) on the
field `public float curRecoil, heat, logicControlTime = -1;`
(:284, set to logicControlCooldown by the control() setters
:384/:394, N2264; decayed :534-536 by the N2261 tick). It
rescues validateTarget (`return !Units.invalidateTarget(target,
canHeal() ? Team.derelict : team, x, y) || controlled() ||
logicControlled();`, :631-633, N2251) and picks the logic branch
of isShooting (:492, N2277) -- but the driver validate call
passed `bool(frame.get("logic_controlled", false))` while
frame["logic_controlled"] was NEVER stamped anywhere, so a
logic-controlled duo with an otherwise-invalid target wrongly
failed validation. This slice ports the one-line Java method as
a pure function on the shared TurretBuild driver file plus one
driver tick in the duo branch immediately BEFORE the validate
call (Java order :491 validate before :534-536 decay, so the
stamp reads the PREVIOUS tick's logic_control_time -- the N2261
decay tick runs later in the driver, the same precedent as
N2277 / N2265); the validate call itself is unchanged and now
reads a live value. The N2251 proof's frame 5 fixture is
repaired in the same slice: it stamped
frame["logic_controlled"] directly, which the new tick would
overwrite with the live derivation, so it now sets
logic_control_time = 120.0 instead.

GREEN decisions (pinned by this slice): (1) One pure function
on SourceTurretBuildState.gd,
source_turret_logic_controlled_state(logic_control_time),
returning `{"logic_controlled": ..}` -- the Java method
verbatim, no formula invented. It sits immediately BEFORE
source_turret_is_shooting_state (the :492 isShooting formula
consumes logicControlled()). Plus one driver tick in the duo
branch (immediately before the validateTarget call) that
derives logic_controlled LIVE from the PREVIOUS tick's
logic_control_time and stamps the key back on the frame. (2)
controlled() (`return unit.isPlayer();`, :441-443) is NOT this
slice -- no player unit exists in the port, so it still
defaults false at the validate call. (3) The N2277 isShooting
tick is NOT rewired to read the stamped key: its test pins the
inline derivation, and the value is identical (same expression,
same previous-tick logic_control_time, the decay tick runs
later). (4) No legacy `source_turret_logic_controlled_result`
schema exists, so the contract validator falls through to the
new source_turret_logic_controlled_state_result schema and no
alias is needed. SSOT expected after GREEN: symbols +1, Done
+1, contracts +1, schema +2, 11653/1727/1661/3113 ->
11654/1728/1662/3115; defense shard slices 204 -> 205,
contracts 203 -> 204.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_is_shooting import DEFERRED as N2277_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
PROOF = '/root/C07TurretLogicControlledProof'
LOGIC_CONTROLLED_OWNER = 'SourceTurretBuildState.source_turret_logic_controlled_state'
TESTS = ['test_c07_turret_logic_controlled_registration', 'test_all_c07_turret_logic_controlled_input_evidence_is_exact', 'test_turret_logic_controlled_state', 'test_reference_graph_and_actual_c07_turret_logic_controlled']
# The slice sources the N2278 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
]
EXACT_EXPRS = [
    'public boolean logicControlled(){',
    'return logicControlTime > 0;',
    'public float curRecoil, heat, logicControlTime = -1;',
    'if(!validateTarget()) target = null;',
    'return !Units.invalidateTarget(target, canHeal() ? Team.derelict : team, x, y) || controlled() || logicControlled();',
]

# DEFERRED is carried from the N2277 register script via import --
# never retyped. logicControlled() is done by this slice, so the
# stale validate-call read is done too (not deferred); the
# N2277 isShooting inline derivation stays as-is (identical
# value); calculateHeat / findTarget / shootp / the other
# ItemTurret defs still wait.
DEFERRED = list(N2277_DEFERRED) + [
    'Turret logicControlled() live derivation (`public boolean logicControlled(){ return logicControlTime > 0; }`, Turret.java:445-447) -- DONE by this slice (N2278); the pure function ports the one-line Java method verbatim and the duo driver stamps frame["logic_controlled"] live from the previous tick\'s logic_control_time right before the validateTarget call (Java order :491 validate before :534-536 decay). The validate call itself is unchanged and now reads a live value; the N2251 proof frame 5 fixture now sets logic_control_time = 120.0 instead of stamping the flag directly.',
    'Turret logicControlled() for defs other than duo -- the pure function takes logic_control_time as a param; only duo is wired in the driver.',
    'Turret controlled() live wiring (`return unit.isPlayer();`, Turret.java:441-443) -- no player unit exists in the port, so the validate call still defaults it false.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    logic_controlled_inputs = {
        'logic_control_time': a('float', 'logicControlTime > 0', 'The logic control timer (Turret.java:284 `public float curRecoil, heat, logicControlTime = -1;`, set to logicControlCooldown by the control() setters :384/:394, N2264; decayed :534-536 by the N2261 tick; the driver passes the PREVIOUS tick\'s frame value, since the decay tick runs later in the driver -- Java order :491 validate before :534-536 decay).'),
    }
    logic_controlled_outputs = {
        'logic_controlled': a('bool', 'return logicControlTime > 0;', 'Whether logic controls the turret (Turret.java:445-447 -- rescues validateTarget :631-633 and picks the logic branch of isShooting :492; true while the timer is positive, false at zero and at the -1 default).'),
    }
    return logic_controlled_inputs, logic_controlled_outputs


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
    logic_controlled_inputs, logic_controlled_outputs = definitions()

    entries = [
        ('N2278', LOGIC_CONTROLLED_OWNER, 'source_turret_logic_controlled_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.updateTile()', logic_controlled_inputs, logic_controlled_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret logicControlled() predicate from TurretBuild.updateTile() / Turret.java:445-447.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret logicControlled() predicate from TurretBuild.updateTile() / Turret.java:445-447.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: logic_controlled.
    by_slice['N2278'] = [
        'source_turret_logic_controlled_state_result.logic_controlled',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2278', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.updateTile()', godot_owner=LOGIC_CONTROLLED_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2278'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
