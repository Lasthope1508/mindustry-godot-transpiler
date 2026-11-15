"""Register the RepairTurret shouldConsume gate (N2188).

The RepairTurret's shouldConsume gate, following the N2174 pure-row
pattern. N2174 folded power-only: a pure power row over the stamped
frame value, folded by the shared machinery into the min efficiency
(BuildingComp.java:1969-1976, ConsumePower.efficiency is
build.power.status) -- but RepairPointBuild DOES override
shouldConsume: `return target != null && enabled;`
(RepairTurret.java:222), and updateConsumption forces efficiency to
zero when the gate is false (BuildingComp.java:1960, `boolean update
= shouldConsume() && productionValid();` + 1992-1993, `if(!update){`
/ `efficiency = optionalEfficiency = 0f;`). N2174 deferred the gate
with a documented limit (the PointDefenseTurret N2151 precedent):
the port tracked no live target on any placed-building frame, so
with no target requestedPower is 0 so power.status reads 1.0 while
Java efficiency is 0. N2188 closes that gap with one pure function
(source_repair_turret_should_consume_state) over one new frame key
(`has_target`, bool): the gate is the same expression over the
observed target, `target != null && enabled`, and the power draw is
conditional on the same field -- `consumePowerCond(powerUse,
(RepairPointBuild entity) -> entity.target != null);`
(RepairTurret.java:89) draws 0 when there is no target
(ConsumePowerCondition.java:17, `return consume.get(entity) ?
usage : 0f;`). RED decision (pinned by this slice): when the frame
carries NO `has_target` key, preserve the N2174 behavior
(`should_consume = enabled`) -- null means "no observation yet",
not "no target", because no placed-building frame carries a live
target today and defaulting absent to false would zero efficiency
for every live repair turret, a live regression against N2174 GREEN.
The gate therefore activates when the future target-acquisition
slice stamps `has_target` from `Units.closest(team, x, y,
repairRadius, Unit::damaged)` (RepairTurret.java:216) plus the
null-out conditions (RepairTurret.java:193-195). The driver change
is one line in the existing
source_repair_turret_tick_buildings_state: the pure-function call
replaces `var should_consume: bool = bool(frame.get("enabled",
true))`; the setup / power row / `update_consumption_state` /
`apply_update_consumption_state` calls are unchanged. No new frame
meta key, no SOURCE_CONSUMER_FRAME_META_KEYS change, no
simulate_factory wiring change, no shard change (no shard selects
/world/blocks/units/).

Composition, not re-implementation: the shared efficiency machinery
(SourceBuildingEfficiencyState.update_consumption_state, via
update_consumption_non_optional_pass_state) already zeroes
efficiency when should_consume is false. N2188 does not touch it.
N2188 supplies the missing pure gate + the one-line driver change;
no new consumer rows. The repair turret's power draw stays
conditional (ConsumePowerCondition, target-gated), so the folded
efficiency is the min over the *modeled* consumers (power only);
the coolant optional consumer (repair-turret only: ConsumeCoolant,
acceptCoolant, coolantUse 0.16f, coolantMultiplier 1.6f,
Blocks.java:6404-6406) is the second pass and waits for its own
slice. No updateTile advance: the target re-acquire / heal /
rotation slerp / strength lerp (RepairTurret.java:187-218) waits
for its own slice; the proof carries no heal/strength/rotation/
target-acquisition keys. Two defs (repair-point, powerUse 1f;
repair-turret, powerUse 5f + coolant, Blocks.java:6386-6406);
repairSpeed 0.45f/3f, repairRadius 60f/145f, Blocks.java:6388-6401.
"""
import ast
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
REPAIR_TURRET = 'core/src/mindustry/world/blocks/units/RepairTurret.java'
CONSUME_POWER_CONDITION = 'core/src/mindustry/world/consumers/ConsumePowerCondition.java'
UNIT_ASSEMBLER = 'core/src/mindustry/world/blocks/units/UnitAssembler.java'
CONSUME_POWER = 'core/src/mindustry/world/consumers/ConsumePower.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BLOCK = 'core/src/mindustry/world/Block.java'
PROOF = '/root/C07RepairTurretShouldConsumeProof'
OWNER = 'SourceRepairTurretBuildState.source_repair_turret_should_consume_state'
TESTS = ['test_c07_repair_turret_should_consume_registration', 'test_all_c07_repair_turret_should_consume_input_evidence_is_exact', 'test_repair_turret_should_consume_state', 'test_reference_graph_and_actual_c07_repair_turret_should_consume']
EXACT_EXPRS = ['public boolean shouldConsume(){', 'return target != null && enabled;', 'public Unit target;', 'consumePowerCond(powerUse, (RepairPointBuild entity) -> entity.target != null);', 'return consume.get(entity) ? usage : 0f;', 'return build.power.status;', 'float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', 'hasConsumers = consumers.length > 0;', 'boolean update = shouldConsume() && productionValid();', 'if(!update){', 'efficiency = optionalEfficiency = 0f;', 'return efficiency * delta();']

# DEFERRED is carried from the N2174 register script via AST --
# never retyped. The N2174 script's DEFERRED is a plain list
# literal, so ast.literal_eval recovers it verbatim; the new
# N2188 entries below are the handoff's deferred items that are
# not already in that list (the RepairTurret updateTile advance,
# coolant, per-def stats, RepairTower, and MassDriver/LaunchPad
# rows are already carried).
_N2174_REGISTER = Path(__file__).resolve().parent / 'register_c07_repair_turret_power_status.py'
_N2174_DEFERRED = next(
    ast.literal_eval(node.value)
    for node in ast.walk(ast.parse(_N2174_REGISTER.read_text(encoding='utf-8')))
    if isinstance(node, ast.Assign)
    and any(isinstance(target, ast.Name) and target.id == 'DEFERRED' for target in node.targets)
)
DEFERRED = list(_N2174_DEFERRED) + [
    'ShockwaveTower shouldConsume gate (ShockwaveTowerBuild.shouldConsume() returns reloadCounter < reload, ShockwaveTower.java:121-122; the charge advance reloadCounter += edelta(), ShockwaveTower.java:73) -- needs a live counter that only the updateTile charge slice can advance plus the per-def reload (field 90f, ShockwaveTower.java:26; def 80f, Blocks.java:2044); the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent).',
    'BuildTurret shouldConsume gate (BuildTurretBuild.shouldConsume() returns unit.plans().size > 0 && !isHealSuppressed(), BuildTurret.java:229-230) -- needs a plans count plus suppression state, and the port tracks no live build-plan state; the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent).',
    'ShieldWall broken() / damage coupling (broken() returns breakTimer > 0 || !canConsume(), ShieldWall.java:91-93; damage absorbs min(shield, damage) and sets breakTimer = breakCooldown when the shield breaks, ShieldWall.java:101-117) -- ShieldWallBuild has no shouldConsume override (default `return enabled;` applies), so there is no gate to wire; the broken()/damage coupling waits for its own slice.',
    'RepairTurret shouldConsume Windows Godot proof -- debt in GOAL.md section 5, same as N2182-N2187: the N2188 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def main():
    symbols = {}

    def f(typ, expr, rule, source=REPAIR_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2188_inputs = {
        'frame': f('Dictionary', 'return target != null && enabled;', 'The building frame carrying the has_target observation (RepairTurret.java:154, `public Unit target;`) and enabled; a missing has_target key means no observation yet (N2174 behavior preserved), not no target.'),
    }
    n2188_outputs = {
        'should_consume': f('bool', 'return target != null && enabled;', 'The shouldConsume gate (RepairTurret.java:221-222): has_target && enabled when a target observation is present, enabled when the frame carries no has_target key (the N2174 behavior); false gates efficiency to 0 via updateConsumption (BuildingComp.java:1960 + 1992-1993).'),
    }

    entries = [
        ('N2188', OWNER, 'source_repair_turret_should_consume_state', REPAIR_TURRET, 'mindustry.world.blocks.units.RepairTurret.RepairPointBuild', 'RepairPointBuild.shouldConsume()', n2188_inputs, n2188_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed RepairTurret shouldConsume gate from RepairTurret.java / BuildingComp.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed RepairTurret shouldConsume gate from RepairTurret.java / BuildingComp.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the gate, its only result key.
    by_slice['N2188'] = [
        'source_repair_turret_should_consume_state_result.should_consume',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2188', dict(status='done', java_source=REPAIR_TURRET, java_class='mindustry.world.blocks.units.RepairTurret.RepairPointBuild', java_method='RepairPointBuild.shouldConsume()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2188'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
    main()
