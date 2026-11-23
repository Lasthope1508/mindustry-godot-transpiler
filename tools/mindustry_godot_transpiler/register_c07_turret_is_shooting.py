"""Register the Turret isShooting state (N2277).

TurretBuild.updateTile (Turret.java:490-615) sets the shooting
flag at the head of the tick, first line after the validateTarget
verdict: `isShooting = alwaysShooting || (unit.controller()
instanceof Player ? unit.isShooting() : logicControlled() ?
logicShooting : target != null);` (Turret.java:492). The flag
feeds the warmup target (:502) and shouldConsume (:364-366),
but the driver had no frame["is_shooting"] stamp and no
standalone pure function: N2253 folded the formula inline as
the warmup call's is_shooting arg. This slice adds the one pure
function on the shared TurretBuild driver file plus one driver
tick in the duo branch AFTER the validateTarget block and
BEFORE the N2265 efficiency fold (Java order :491 validate,
:492 isShooting, then the updateConsumption fold :674-679 and
the :502 warmup), and rewires the warmup call to read the
stamped key instead of recomputing the formula inline.

GREEN decisions (pinned by this slice): (1) One pure function
on SourceTurretBuildState.gd,
source_turret_is_shooting_state(always_shooting, is_player,
player_is_shooting, logic_controlled, logic_shooting,
has_target), returning `{"is_shooting": ..}` -- the Java
ternary verbatim, no formula invented. It sits immediately
BEFORE source_turret_warmup_state (Java order :492 isShooting
before :502 warmupTarget). Plus one driver tick in the duo
branch (immediately after the validateTarget block, before the
N2265 efficiency fold) that derives logicControlled LIVE from
the PREVIOUS tick's logic_control_time (the N2261 decay tick
runs later in the driver; Java order :492 is before :534-536),
the same precedent as N2265 reading the previous tick's
heat_req, and stamps the key back on the frame. (2) Duo
alwaysShooting is false (Turret.java:103, never overridden in
Blocks.java:3257-3331); no player unit exists in the port, so
the driver passes false for always_shooting and
player_is_shooting and reads controlled from the frame
(default false). (3) `frame["logic_controlled"]` is never
stamped anywhere (only read with default false at the N2251
validate call) -- this slice does NOT rewire that call; the
live derivation lives in the new tick only. (4) The warmup
call rewire is value-identical for every existing duo frame
(logic_control_time defaults -1.0 -> not logic-controlled ->
has_target && valid); for logic-controlled frames the new value
is the CORRECT Java value (logicShooting, not target != null).
If wiring/neighbours regress on the rewire, revert only the
rewire line and keep the stamp. (5) No legacy
`source_turret_is_shooting_result` schema exists, so the
contract validator falls through to the new
source_turret_is_shooting_state_result schema and no alias is
needed. SSOT expected after GREEN: symbols +1, Done +1,
contracts +1, schema +2, 11652/1726/1660/3111 ->
11653/1727/1661/3113; defense shard slices 203 -> 204,
contracts 202 -> 203.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_unit_health import DEFERRED as N2276_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
PROOF = '/root/C07TurretIsShootingProof'
IS_SHOOTING_OWNER = 'SourceTurretBuildState.source_turret_is_shooting_state'
TESTS = ['test_c07_turret_is_shooting_registration', 'test_all_c07_turret_is_shooting_input_evidence_is_exact', 'test_turret_is_shooting_state', 'test_reference_graph_and_actual_c07_turret_is_shooting']
# The slice sources the N2277 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
]
EXACT_EXPRS = [
    'if(!validateTarget()) target = null;',
    'isShooting = alwaysShooting || (unit.controller() instanceof Player ? unit.isShooting() : logicControlled() ? logicShooting : target != null);',
    'return isShooting;',
    'public boolean alwaysShooting = false;',
    'public boolean logicShooting = false;',
    'return unit.isPlayer();',
    'return logicControlTime > 0;',
]

# DEFERRED is carried from the N2276 register script via import --
# never retyped. The isShooting flag is done by this slice, so the
# warmup rewire is done too (not deferred); calculateHeat /
# findTarget / shootp / the other ItemTurret defs still wait.
DEFERRED = list(N2276_DEFERRED) + [
    'Turret isShooting flag from updateTile() (`isShooting = alwaysShooting || (unit.controller() instanceof Player ? unit.isShooting() : logicControlled() ? logicShooting : target != null);`, Turret.java:492) -- DONE by this slice (N2277); the duo driver derives logicControlled LIVE from the previous tick\'s logic_control_time (the N2261 decay tick runs later in the driver; Java order :492 before :534-536) and stamps is_shooting on the frame right after the validateTarget block, before the N2265 efficiency fold. The :502 warmup call now reads the stamped key instead of recomputing `has_target and validate.valid` inline.',
    'Turret isShooting for defs other than duo -- the pure function takes all six branches as params; only duo is wired in the driver (alwaysShooting false, no player).',
    'Turret calculateHeat live proximity scan (BuildingComp.java:410-461) -- BLOCKED, live entity scan.',
    'Turret control() shootp live wiring -- logic executor not in the driver yet.',
    'Turret findTarget -- BLOCKED, live entity scan.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    is_shooting_inputs = {
        'always_shooting': a('bool', 'alwaysShooting', 'Whether the turret always shoots when it has ammo (Turret.java:103 `public boolean alwaysShooting = false;`; duo never overrides it, Blocks.java:3257-3331; driver passes false).'),
        'is_player': a('bool', 'unit.isPlayer()', 'Whether a player controls the block unit (Turret.java:441-443 `controlled()` returns `unit.isPlayer();`; driver reads frame["controlled"], default false -- no player unit in the port).'),
        'player_is_shooting': a('bool', 'unit.isShooting()', 'The player-controlled unit\'s own isShooting (Turret.java:492 player branch; no player input exists in the port; driver passes false -- the branch is unreachable while is_player is false).'),
        'logic_controlled': a('bool', 'logicControlTime > 0', 'Whether logic controls the turret (Turret.java:445-447 `logicControlled()` returns `logicControlTime > 0;`; the driver derives it LIVE from the PREVIOUS tick\'s logic_control_time, since the N2261 decay tick runs later in the driver -- Java order :492 before :534-536).'),
        'logic_shooting': a('bool', 'logicShooting', 'The logic shooting flag (Turret.java:288 `public boolean logicShooting = false;`, set by the control() setters :384/:394, N2264; driver reads frame["logic_shooting"], default false).'),
        'has_target': a('bool', 'target != null', 'Whether a target survives the :491 validateTarget verdict (Turret.java:491-492; driver passes `bool(frame.get("has_target", false)) and bool(validate.get("valid", false))` -- the same proxy the warmup call used before this slice).'),
    }
    is_shooting_outputs = {
        'is_shooting': a('bool', 'isShooting = alwaysShooting || (unit.controller() instanceof Player ? unit.isShooting() : logicControlled() ? logicShooting : target != null);', 'The shooting flag after the tick (Turret.java:492 -- feeds the warmup target :502 and shouldConsume :364-366; true for a duo with a target, false without one; a logic-controlled duo follows logicShooting, not the target).'),
    }
    return is_shooting_inputs, is_shooting_outputs


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
    is_shooting_inputs, is_shooting_outputs = definitions()

    entries = [
        ('N2277', IS_SHOOTING_OWNER, 'source_turret_is_shooting_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.updateTile()', is_shooting_inputs, is_shooting_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret isShooting flag from TurretBuild.updateTile() / Turret.java:492.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret isShooting flag from TurretBuild.updateTile() / Turret.java:492.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: is_shooting.
    by_slice['N2277'] = [
        'source_turret_is_shooting_state_result.is_shooting',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2277', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.updateTile()', godot_owner=IS_SHOOTING_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2277'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
