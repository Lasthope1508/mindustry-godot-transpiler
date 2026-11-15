"""Register the ShieldWall broken() coupling (N2202).

The ShieldWall's broken() coupling, following the N2201 pure-function
pattern. N2175 folded the shield wall's live power.status into the min
efficiency (BuildingComp.java:1969-1976, ConsumePower.efficiency is
build.power.status) in its own driver, and its updateTile regen advance
(ShieldWall.java:80, `shield = Mathf.clamp(shield + regenSpeed *
edelta(), 0f, shieldHealth);`) regens by edelta()
(BuildingComp.java:1927-1929, `return efficiency * delta();`) -- but
N2175 left the broken() coupling unmodeled with a documented limit:
broken() (ShieldWall.java:92, `return breakTimer > 0 ||
!canConsume();`) with canConsume() (BuildingComp.java:1917-1919,
`return potentialEfficiency > 0;`) means a powerless shield wall is
broken and absorbs nothing, yet the port stamped no broken flag at
all -- the shield radius lerp (ShieldWall.java:88, `shieldRadius =
Mathf.lerpDelta(shieldRadius, broken() ? 0f : 1f, 0.12f);`) and the
damage path (ShieldWall.java:102, `float shieldTaken = broken() ? 0f
: Math.min(shield, damage);`) had no broken value to read. N2202
closes the broken() half with one pure function
(source_shield_wall_broken_state) over two frame keys (`break_timer`,
float, and `potential_efficiency`, float, stamped by the N2175
machinery via apply_update_consumption_state): the coupling is the
same expression over the observed break timer and the live potential
efficiency, reusing the canonical can_consume_state
(SourceBuildingEfficiencyState.gd:84-85, `potential_efficiency >
0.0`) instead of re-implementing canConsume(). RED decisions (pinned
by this slice): when the frame carries NO `break_timer` key, default
to 0.0 (no break in progress) -- the future updateTile-advance slice
owns live stamping of break_timer (breakTimer decay,
ShieldWall.java:75-76, and `breakTimer = breakCooldown;`,
ShieldWall.java:110, on shield break); when the frame carries NO
`potential_efficiency` key, default to 1.0 (not broken by power) --
the N2175 null-folds-to-1.0 precedent and the N2201
absent-preserves-behavior precedent: Java's field default is 0.0
(BuildingComp.java:89, `transient float potentialEfficiency;`), but
updateConsumption runs before updateTile every tick in live play, so
broken() is only ever evaluated with a fresh potentialEfficiency,
and absent means "no machinery run yet", not "no power" --
defaulting absent to 0 would mark every shield wall broken before
its first tick, a live regression against N2175 GREEN. The driver
change is one line in the existing
source_shield_wall_tick_buildings_state, after
apply_update_consumption_state: the pure-function call stamps
frame["broken"], so the flag reads the fresh potential_efficiency
the machinery just stamped. No new frame meta key, no
SOURCE_CONSUMER_FRAME_META_KEYS change, no simulate_factory wiring
change. Shard change expected: the defense shard selects java_source
paths under /world/blocks/defense/ and ShieldWall.java lives there --
defense_slices 164 -> 165, defense_api_contracts 163 -> 164 (verify
at the GREEN register run).

Composition, not re-implementation: the shared efficiency machinery
(SourceBuildingEfficiencyState.update_consumption_state, via
update_consumption_non_optional_pass_state) already folds the power
row into the min efficiency and stamps potential_efficiency onto the
frame via apply_update_consumption_state, and can_consume_state
already models BuildingComp.canConsume(). N2202 does not touch any
of it. N2202 supplies the missing pure broken() coupling + the
one-line driver stamp; no new consumer rows. The shield wall's power
draw stays static (ConsumePower 3f / 60f = 0.05), so the folded
efficiency is the min over the *modeled* consumers (power only).
No updateTile advance: the breakTimer decay / shield regen / hit
decay / shieldRadius lerp (ShieldWall.java:74-89) waits for its own
slice; the proof carries no shield/shieldRadius/regen keys. The
damage path (ShieldWall.java:101-117) waits for its own slice.
Single def (shielded-wall, size 2, health 260 * wallHealthMultiplier
* 4, armor 15f, chanceDeflect 8f, Blocks.java:1903-1916).
"""
import ast
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
SHIELD_WALL = 'core/src/mindustry/world/blocks/defense/ShieldWall.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
UNIT_ASSEMBLER = 'core/src/mindustry/world/blocks/units/UnitAssembler.java'
CONSUME_POWER = 'core/src/mindustry/world/consumers/ConsumePower.java'
BLOCK = 'core/src/mindustry/world/Block.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07ShieldWallBrokenProof'
OWNER = 'SourceShieldWallBuildState.source_shield_wall_broken_state'
TESTS = ['test_c07_shield_wall_broken_registration', 'test_all_c07_shield_wall_broken_input_evidence_is_exact', 'test_shield_wall_broken_state', 'test_reference_graph_and_actual_c07_shield_wall_broken']
EXACT_EXPRS = ['public boolean broken(){', 'return breakTimer > 0 || !canConsume();', 'public float breakTimer;', 'if(breakTimer > 0){', 'breakTimer -= Time.delta;', 'breakTimer = breakCooldown;', 'public boolean canConsume(){', 'return potentialEfficiency > 0;', 'transient float potentialEfficiency;', 'potentialEfficiency = enabled && productionValid() ? 1f : 0f;', 'potentialEfficiency = efficiency = optionalEfficiency = 0f;', 'potentialEfficiency = efficiency;', 'shield = Mathf.clamp(shield + regenSpeed * edelta(), 0f, shieldHealth);', 'shieldRadius = Mathf.lerpDelta(shieldRadius, broken() ? 0f : 1f, 0.12f);', 'float shieldTaken = broken() ? 0f : Math.min(shield, damage);', 'public float shieldHealth = 900f;', 'public float breakCooldown = 60f * 10f;', 'public float regenSpeed = 2f;', 'public float shield = shieldHealth, shieldRadius = 0f;', 'public class ShieldWall extends Wall{', 'public class ShieldWallBuild extends WallBuild{', 'return build.power.status;', 'float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', 'hasConsumers = consumers.length > 0;', 'return enabled;', 'boolean update = shouldConsume() && productionValid();', 'if(!update){', 'return efficiency * delta();', 'consumePower(3f / 60f);', 'update = true;']

# DEFERRED is carried from the N2175 register script via AST --
# never retyped. The N2175 script's DEFERRED is a plain list
# literal, so ast.literal_eval recovers it verbatim. The N2175
# entry for the ShieldWall broken/damage rows is REPLACED (not
# carried): N2202 closes the broken() half, so the entry now
# records broken() as done and damage() as still deferred. The new
# N2202 entries below are the handoff's deferred items that are not
# already in that list.
_N2175_REGISTER = Path(__file__).resolve().parent / 'register_c07_shield_wall_power_status.py'
_N2175_DEFERRED = next(
    ast.literal_eval(node.value)
    for node in ast.walk(ast.parse(_N2175_REGISTER.read_text(encoding='utf-8')))
    if isinstance(node, ast.Assign)
    and any(isinstance(target, ast.Name) and target.id == 'DEFERRED' for target in node.targets)
)


def _n2202_deferred(entry):
    if entry.startswith('ShieldWall broken() / damage rows'):
        return 'ShieldWall broken() coupling -- DONE in N2202 (source_shield_wall_broken_state, ShieldWall.java:91-93, broken() returns breakTimer > 0 || !canConsume() with canConsume() from BuildingComp.java:1917-1919); damage() rows (damage absorbs min(shield, damage) and sets breakTimer = breakCooldown when the shield breaks, ShieldWall.java:101-117) still wait for their own slice.'
    return entry


DEFERRED = [_n2202_deferred(entry) for entry in _N2175_DEFERRED] + [
    'ShieldWall broken() live break_timer stamping -- the N2202 pure function reads frame break_timer (absent defaults to 0.0, "no break in progress"); the future updateTile-advance slice stamps break_timer live (breakTimer decay, ShieldWall.java:75-76, and breakTimer = breakCooldown on shield break, ShieldWall.java:110).',
    'ShieldWall broken() on disabled/cheating frames -- the N2202 driver line sits inside the consumption block (the N2188/N2201 precedent), so a disabled or cheating shield wall keeps its last stamped broken value; Java sets potentialEfficiency = 0 when disabled (BuildingComp.java:1955) so broken() is true; the updateTile-advance slice owns re-stamping broken outside the consumption gate.',
    'ShieldWall broken() Windows Godot proof -- debt in GOAL.md section 5, same as N2175-N2201: the N2202 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def main():
    symbols = {}

    def f(typ, expr, rule, source=SHIELD_WALL, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2202_inputs = {
        'frame': f('Dictionary', 'return breakTimer > 0 || !canConsume();', 'The building frame carrying the break_timer observation (ShieldWall.java:45, `public float breakTimer;`, decayed ShieldWall.java:75-76 and set ShieldWall.java:110) and the potential_efficiency observation stamped by the N2175 machinery via apply_update_consumption_state (BuildingComp.java:1989, `potentialEfficiency = efficiency;`); a missing break_timer key means no break in progress (0.0), a missing potential_efficiency key means no machinery run yet (1.0, not "no power").'),
    }
    n2202_outputs = {
        'broken': f('bool', 'return breakTimer > 0 || !canConsume();', 'The broken() coupling (ShieldWall.java:91-93): break_timer > 0 || !canConsume(), where canConsume() is potentialEfficiency > 0 (BuildingComp.java:1917-1919); true means the shield absorbs nothing (ShieldWall.java:102) and the shield radius lerps to 0 (ShieldWall.java:88).'),
    }

    entries = [
        ('N2202', OWNER, 'source_shield_wall_broken_state', SHIELD_WALL, 'mindustry.world.blocks.defense.ShieldWall.ShieldWallBuild', 'ShieldWallBuild.broken()', n2202_inputs, n2202_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed ShieldWall broken() coupling from ShieldWall.java / BuildingComp.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed ShieldWall broken() coupling from ShieldWall.java / BuildingComp.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the broken flag, its only result key.
    by_slice['N2202'] = [
        'source_shield_wall_broken_state_result.broken',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2202', dict(status='done', java_source=SHIELD_WALL, java_class='mindustry.world.blocks.defense.ShieldWall.ShieldWallBuild', java_method='ShieldWallBuild.broken()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2202'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
