"""Register the BuildTurret shouldConsume gate (N2201).

The BuildTurret's shouldConsume gate, following the N2184 pure-row
pattern. N2184 folded power-only: a pure power row over the stamped
frame value, folded by the shared machinery into the min efficiency
(BuildingComp.java:1969-1976, ConsumePower.efficiency is
build.power.status) -- but BuildTurretBuild DOES override
shouldConsume: `return unit.plans().size > 0 && !isHealSuppressed();`
(BuildTurret.java:230), and updateConsumption forces efficiency to
zero when the gate is false (BuildingComp.java:1960, `boolean update
= shouldConsume() && productionValid();` + 1992-1993, `if(!update){`
/ `efficiency = optionalEfficiency = 0f;`). N2184 deferred the gate
with a documented limit (the PointDefenseTurret N2151 precedent):
the port tracked no live build-plan state on any placed-building
frame, so with no plans requestedPower is 0 so power.status reads
1.0 while Java efficiency is 0. N2201 closes that gap with one pure
function (source_build_turret_should_consume_state) over two new
frame keys (`plans_count`, int, and `heal_suppressed`, bool): the
gate is the same expression over the observed plans,
`unit.plans().size > 0 && !isHealSuppressed()`. The tower's power
draw is STATIC (consumePower 3f, Blocks.java:2005), so unlike the
repair turret the power row reads 0.5 even with no plans -- the gate
is the only thing zeroing efficiency. RED decision (pinned by this
slice): when the frame carries NO `plans_count` key, preserve the
N2184 behavior (`should_consume = enabled`) -- null means "no
observation yet", not "no plans", because no placed-building frame
carries live build plans today and defaulting absent to false would
zero efficiency for every live build tower, a live regression
against N2184 GREEN. The gate therefore activates when the future
plan-acquisition slice stamps `plans_count` from
`unit.plans().size` (BuildTurret.java:230). The `heal_suppressed`
observation defaults to false when absent: suppression is a
transient timed state (`block.suppressable && Time.time <=
healSuppressionTime`, BuildingComp.java:487-489), and no slice
stamps it yet -- the future suppression slice owns live stamping
of it (the canonical is_heal_suppressed_state already exists in
SourceBuildingLifecycleState.gd). The driver change is one line in
the existing source_build_turret_tick_buildings_state: the
pure-function call replaces `var should_consume: bool =
bool(frame.get("enabled", true))`; the setup / power row /
`update_consumption_state` / `apply_update_consumption_state`
calls are unchanged. No new frame meta key, no
SOURCE_CONSUMER_FRAME_META_KEYS change, no simulate_factory wiring
change. Shard change expected: the defense shard selects
java_source paths under /world/blocks/defense/ and BuildTurret.java
lives there -- defense_slices 163 -> 164, defense_api_contracts
162 -> 163 (verify at the GREEN register run).

Composition, not re-implementation: the shared efficiency machinery
(SourceBuildingEfficiencyState.update_consumption_state, via
update_consumption_non_optional_pass_state) already zeroes
efficiency when should_consume is false. N2201 does not touch it.
N2201 supplies the missing pure gate + the one-line driver change;
no new consumer rows. The build tower's power draw stays static
(ConsumePower 3f), so the folded efficiency is the min over the
*modeled* consumers (power only); the nitrogen optional consumer
(consumeLiquid nitrogen 3f/60f, Blocks.java:2006) is the second pass
and waits for its own slice. No updateTile advance: the plan search
/ mimic / validate / updateBuildLogic (BuildTurret.java:156-225)
waits for its own slice; the proof carries no plan-acquisition keys.
Single def (build-tower, size 3, range 200f, buildSpeed 1.5f,
silicon 150 / oxide 40 / thorium 60, Blocks.java:1997-2006).
"""
import ast
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
BUILD_TURRET = 'core/src/mindustry/world/blocks/defense/BuildTurret.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
UNIT_ASSEMBLER = 'core/src/mindustry/world/blocks/units/UnitAssembler.java'
CONSUME_POWER = 'core/src/mindustry/world/consumers/ConsumePower.java'
BLOCK = 'core/src/mindustry/world/Block.java'
PROOF = '/root/C07BuildTurretShouldConsumeProof'
OWNER = 'SourceBuildTurretBuildState.source_build_turret_should_consume_state'
TESTS = ['test_c07_build_turret_should_consume_registration', 'test_all_c07_build_turret_should_consume_input_evidence_is_exact', 'test_build_turret_should_consume_state', 'test_reference_graph_and_actual_c07_build_turret_should_consume']
EXACT_EXPRS = ['public boolean shouldConsume(){', 'return unit.plans().size > 0 && !isHealSuppressed();', 'public BlockUnitc unit = (BlockUnitc)unitType.create(team);', 'public boolean isHealSuppressed(){', 'return block.suppressable && Time.time <= healSuppressionTime;', 'suppressable = true;', 'return build.power.status;', 'float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', 'hasConsumers = consumers.length > 0;', 'boolean update = shouldConsume() && productionValid();', 'if(!update){', 'efficiency = optionalEfficiency = 0f;', 'return efficiency * delta();', 'return enabled;', 'public class BuildTurretBuild extends BaseTurretBuild implements ControlBlock, RotBlock{']

# DEFERRED is carried from the N2184 register script via AST --
# never retyped. The N2184 script's DEFERRED is a plain list
# literal, so ast.literal_eval recovers it verbatim; the new
# N2201 entries below are the handoff's deferred items that are
# not already in that list (the BuildTurret plan search / mimic /
# validate, liquid, suppression, draw / read / write / sense and
# per-def stat rows are already carried).
_N2184_REGISTER = Path(__file__).resolve().parent / 'register_c07_build_turret_power_status.py'
_N2184_DEFERRED = next(
    ast.literal_eval(node.value)
    for node in ast.walk(ast.parse(_N2184_REGISTER.read_text(encoding='utf-8')))
    if isinstance(node, ast.Assign)
    and any(isinstance(target, ast.Name) and target.id == 'DEFERRED' for target in node.targets)
)
DEFERRED = list(_N2184_DEFERRED) + [
    'BuildTurret shouldConsume live plans_count stamping -- the N2201 gate activates when the future plan-acquisition slice stamps plans_count from unit.plans().size (BuildTurret.java:230); until then the gate preserves the N2184 behavior when the frame carries no plans_count key.',
    'BuildTurret shouldConsume Windows Godot proof -- debt in GOAL.md section 5, same as N2184-N2200: the N2201 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def main():
    symbols = {}

    def f(typ, expr, rule, source=BUILD_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2201_inputs = {
        'frame': f('Dictionary', 'return unit.plans().size > 0 && !isHealSuppressed();', 'The building frame carrying the plans_count observation (BuildTurret.java:93, `public BlockUnitc unit = (BlockUnitc)unitType.create(team);`, plans are unit.plans()) and the heal_suppressed observation (BuildingComp.java:487-489, isHealSuppressed) and enabled; a missing plans_count key means no observation yet (N2184 behavior preserved), not no plans.'),
    }
    n2201_outputs = {
        'should_consume': f('bool', 'return unit.plans().size > 0 && !isHealSuppressed();', 'The shouldConsume gate (BuildTurret.java:229-230): plans_count > 0 && !heal_suppressed && enabled when a plans observation is present, enabled when the frame carries no plans_count key (the N2184 behavior); false gates efficiency to 0 via updateConsumption (BuildingComp.java:1960 + 1992-1993).'),
    }

    entries = [
        ('N2201', OWNER, 'source_build_turret_should_consume_state', BUILD_TURRET, 'mindustry.world.blocks.defense.BuildTurret.BuildTurretBuild', 'BuildTurretBuild.shouldConsume()', n2201_inputs, n2201_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BuildTurret shouldConsume gate from BuildTurret.java / BuildingComp.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BuildTurret shouldConsume gate from BuildTurret.java / BuildingComp.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the gate, its only result key.
    by_slice['N2201'] = [
        'source_build_turret_should_consume_state_result.should_consume',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2201', dict(status='done', java_source=BUILD_TURRET, java_class='mindustry.world.blocks.defense.BuildTurret.BuildTurretBuild', java_method='BuildTurretBuild.shouldConsume()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2201'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
