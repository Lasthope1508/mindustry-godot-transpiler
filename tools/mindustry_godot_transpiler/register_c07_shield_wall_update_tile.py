"""Register the ShieldWall updateTile() advance (N2204).

The ShieldWall's updateTile() advance, following the N2202/N2203
pure-function pattern. N2203 closed the damage() half
(ShieldWall.java:100-117) with one pure function over the frame keys
plus the incoming damage, but left the tick advance unmodeled with a
documented limit: updateTile() (ShieldWall.java:74-89) decays
breakTimer by Time.delta while broken, regens the shield by regenSpeed
* edelta() while whole, decays hit by Time.delta / 10f, and lerps
shieldRadius toward broken() ? 0f : 1f -- yet the port stamped none of
those keys live, so a shield wall's shield never refilled, its break
timer never counted down, its hit flash never faded, and its shield
radius never moved after placement. N2204 closes the updateTile
advance with one pure function
(source_shield_wall_update_tile_state) over the frame keys (`shield`,
`break_timer`, `hit`, `shield_radius`, `efficiency`,
`potential_efficiency`) plus the tick delta, reusing the N2202 broken()
coupling instead of re-implementing it, and one driver line that calls
it for every ticked shield wall (updateConsumption runs BEFORE
updateTile in Java, so the advance reads this tick's freshly stamped
efficiency). RED decisions (pinned by this slice): breakTimer is NOT
clamped on decay -- Java (`breakTimer -= Time.delta;`,
ShieldWall.java:76) lets it go slightly negative, and broken() reads
`breakTimer > 0`, so a -0.5 timer is whole; the regen branch is decided
on the PRE-update timer (the if/else, ShieldWall.java:75-81), so a
timer that crosses zero this tick does NOT regen yet; broken() for the
radius lerp is read AFTER the decay, so the pure function evaluates it
on the updated timer (via a duplicated frame), never on the stale one;
the radius lerp runs through the port's canonical lerpDelta
(SourceMathState.source_lerp_delta). The driver also zeroes
potential_efficiency / efficiency for a disabled wall before the call
(BuildingComp.java:1954-1955, `if(!enabled){` with
`potentialEfficiency = efficiency = optionalEfficiency = 0f;`), so a
disabled wall is broken and never regens, and re-stamps broken outside
the consumption gate (the N2203 handoff note). Shard change expected:
the defense shard selects java_source paths under
/world/blocks/defense/ and ShieldWall.java lives there --
defense_slices 166 -> 167, defense_api_contracts 165 -> 166 (verify at
the GREEN register run).

Composition, not re-implementation: the N2202 broken() coupling
(SourceShieldWallBuildState.source_shield_wall_broken_state) already
models ShieldWallBuild.broken() over break_timer and
potential_efficiency, the N2203 damage() coupling already owns the
breakTimer = breakCooldown set on shield break (ShieldWall.java:110),
and SourceMathState.source_lerp_delta already models arc's
Mathf.lerpDelta for the port; N2204 does not touch any of them. N2204
supplies the missing pure updateTile() advance plus its driver line;
no new consumer rows. The shield wall's power draw stays static
(ConsumePower 3f / 60f = 0.05), so the folded efficiency is the min
over the *modeled* consumers (power only). Single def (shielded-wall,
size 2, health 260 * wallHealthMultiplier * 4, armor 15f, chanceDeflect
8f, Blocks.java:1903-1916).
"""
import ast
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
SHIELD_WALL = 'core/src/mindustry/world/blocks/defense/ShieldWall.java'
WALL = 'core/src/mindustry/world/blocks/defense/Wall.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
CONSUME_POWER = 'core/src/mindustry/world/consumers/ConsumePower.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07ShieldWallUpdateTileProof'
OWNER = 'SourceShieldWallBuildState.source_shield_wall_update_tile_state'
TESTS = ['test_c07_shield_wall_update_tile_registration', 'test_all_c07_shield_wall_update_tile_input_evidence_is_exact', 'test_shield_wall_update_tile_state', 'test_reference_graph_and_actual_c07_shield_wall_update_tile']
EXACT_EXPRS = ['public void updateTile(){', 'if(breakTimer > 0){', 'breakTimer -= Time.delta;', 'shield = Mathf.clamp(shield + regenSpeed * edelta(), 0f, shieldHealth);', 'if(hit > 0){', 'hit -= Time.delta / 10f;', 'hit = Math.max(hit, 0f);', 'shieldRadius = Mathf.lerpDelta(shieldRadius, broken() ? 0f : 1f, 0.12f);', 'public boolean broken(){', 'return breakTimer > 0 || !canConsume();', 'public float breakTimer;', 'public float shieldHealth = 900f;', 'public float breakCooldown = 60f * 10f;', 'public float regenSpeed = 2f;', 'public float shield = shieldHealth, shieldRadius = 0f;', 'public class ShieldWall extends Wall{', 'public class ShieldWallBuild extends WallBuild{', 'protected float hit;', 'public boolean canConsume(){', 'return potentialEfficiency > 0;', 'transient float potentialEfficiency;', 'transient float efficiency;', 'public float edelta(){', 'return efficiency * delta();', 'public float delta(){', 'return Time.delta * timeScale;', 'if(!enabled){', 'potentialEfficiency = efficiency = optionalEfficiency = 0f;', 'return build.power.status;', 'consumePower(3f / 60f);', 'update = true;']

# DEFERRED is carried from the N2175 register script via AST --
# never retyped. The N2175 script's DEFERRED is a plain list
# literal, so ast.literal_eval recovers it verbatim. The N2202 and
# N2203 scripts' DEFERRED are NOT plain literals (each is a
# comprehension over the N2175 list plus a literal tail), so they
# cannot be literal_eval'd whole -- instead the N2202 and N2203
# replacements are applied here in code and the N2202 / N2203 tails
# (their new entries) are recovered by literal_eval of the right
# side of each BinOp. The N2204 replacements below close the
# updateTile advance, the live break_timer stamping, the
# disabled/cheating broken re-stamp, and the live shield / hit
# stamping. The new N2204 entries below are the handoff's deferred
# items that are not already in that list.
_N2175_REGISTER = Path(__file__).resolve().parent / 'register_c07_shield_wall_power_status.py'
_N2175_DEFERRED = next(
    ast.literal_eval(node.value)
    for node in ast.walk(ast.parse(_N2175_REGISTER.read_text(encoding='utf-8')))
    if isinstance(node, ast.Assign)
    and any(isinstance(target, ast.Name) and target.id == 'DEFERRED' for target in node.targets)
)
_N2202_REGISTER = Path(__file__).resolve().parent / 'register_c07_shield_wall_broken.py'
_N2202_NEW = next(
    ast.literal_eval(node.value.right)
    for node in ast.walk(ast.parse(_N2202_REGISTER.read_text(encoding='utf-8')))
    if isinstance(node, ast.Assign)
    and any(isinstance(target, ast.Name) and target.id == 'DEFERRED' for target in node.targets)
)
_N2203_REGISTER = Path(__file__).resolve().parent / 'register_c07_shield_wall_damage.py'
_N2203_NEW = next(
    ast.literal_eval(node.value.right)
    for node in ast.walk(ast.parse(_N2203_REGISTER.read_text(encoding='utf-8')))
    if isinstance(node, ast.Assign)
    and any(isinstance(target, ast.Name) and target.id == 'DEFERRED' for target in node.targets)
)


def _n2202_deferred(entry):
    if entry.startswith('ShieldWall broken() / damage rows'):
        return 'ShieldWall broken() coupling -- DONE in N2202 (source_shield_wall_broken_state, ShieldWall.java:91-93, broken() returns breakTimer > 0 || !canConsume() with canConsume() from BuildingComp.java:1917-1919); damage() rows (damage absorbs min(shield, damage) and sets breakTimer = breakCooldown when the shield breaks, ShieldWall.java:101-117) still wait for their own slice.'
    return entry


def _n2203_deferred(entry):
    if entry.startswith('ShieldWall broken() coupling -- DONE in N2202'):
        return 'ShieldWall damage() coupling -- DONE in N2203 (source_shield_wall_damage_state, ShieldWall.java:100-117, damage() absorbs min(shield, damage) when whole, flashes hit, sets breakTimer = breakCooldown when the shield breaks, and returns the residual for super.damage); the residual super.damage wiring (applying residual_damage to building health via BuildingComp.damage(float), BuildingComp.java:2059-2080) still waits for a live damage call site -- no ShieldWall damage caller exists in the port yet.'
    return entry


def _n2204_deferred(entry):
    if entry.startswith('ShieldWall updateTile advance'):
        return 'ShieldWall updateTile advance -- DONE in N2204 (source_shield_wall_update_tile_state, ShieldWall.java:74-89, breakTimer decay by Time.delta, shield regen by regenSpeed * edelta() clamped to shieldHealth, hit decay by Time.delta / 10f floored at 0, shieldRadius lerpDelta toward broken() ? 0f : 1f at 0.12, with one driver line stamping shield / break_timer / hit / shield_radius / broken live every tick); the read/write rows (shield, ShieldWall.java:119-130) and the draw / setStats / pickedUp rows still wait for their own slices.'
    if entry.startswith('ShieldWall broken() live break_timer stamping'):
        return 'ShieldWall broken() live break_timer stamping -- DONE in N2204 (the updateTile advance stamps break_timer live every tick: breakTimer decay, ShieldWall.java:75-76; breakTimer = breakCooldown on shield break stays in the N2203 damage function, ShieldWall.java:110).'
    if entry.startswith('ShieldWall broken() on disabled/cheating frames'):
        return 'ShieldWall broken() on disabled/cheating frames -- DONE in N2204 for the disabled half (the driver zeroes potential_efficiency / efficiency when disabled, BuildingComp.java:1954-1955, and re-stamps broken outside the consumption gate from the updateTile advance); the cheating half keeps the last stamped efficiency (a cheating frame never runs the machinery, so the regen follows the last stamped efficiency -- see the cheating-frame entry below).'
    if entry.startswith('ShieldWall damage() live shield / hit stamping'):
        return 'ShieldWall damage() live shield / hit stamping -- DONE in N2204 (the updateTile advance stamps shield live via regen, ShieldWall.java:80, hit live via decay, ShieldWall.java:83-86, plus break_timer and shield_radius; the read/write slice still stamps shield on load, ShieldWall.java:119-130).'
    return entry


DEFERRED = [_n2204_deferred(_n2203_deferred(_n2202_deferred(entry))) for entry in _N2175_DEFERRED] + [_n2204_deferred(entry) for entry in _N2202_NEW] + [_n2204_deferred(entry) for entry in _N2203_NEW] + [
    'ShieldWall updateTile cheating-frame efficiency -- the N2204 driver zeroes potential_efficiency / efficiency only when the wall is disabled (BuildingComp.java:1954-1955); a cheating shield wall never runs the machinery (the driver skips the consumption block for cheating teams, the N2175 precedent), so its frame keeps the last stamped efficiency and the regen follows that stale value -- Java sets potentialEfficiency = enabled && productionValid() ? 1f : 0f and efficiency = shouldConsume() ? potentialEfficiency : 0f when cheating (BuildingComp.java:1945-1947); stamping the cheating efficiency waits for its own slice.',
    'ShieldWall updateTile timeScale -- edelta() is efficiency * delta() and delta() is Time.delta * timeScale (BuildingComp.java:1922-1923, 1927-1928); the port passes the raw tick seconds as delta (timeScale 1 by default, the N2190 driver convention) and no frame key carries a live timeScale; a timeScale-affected advance waits for its own slice.',
    'ShieldWall updateTile Windows Godot proof -- debt in GOAL.md section 5, same as N2175-N2203: the N2204 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def main():
    symbols = {}

    def f(typ, expr, rule, source=SHIELD_WALL, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2204_inputs = {
        'frame': f('Dictionary', 'public float shield = shieldHealth, shieldRadius = 0f;', 'The building frame carrying the shield observation (ShieldWall.java:44, `public float shield = shieldHealth, shieldRadius = 0f;`, shieldHealth 900f, ShieldWall.java:15), the break_timer observation (ShieldWall.java:45, `public float breakTimer;`), the hit flash (Wall.java:89, `protected float hit;`), the shield_radius observation, the folded efficiency (BuildingComp.java:85, `transient float efficiency;`) and the potential_efficiency observation stamped by the N2175 machinery (BuildingComp.java:1989, `potentialEfficiency = efficiency;`); a missing shield key means the shield was never damaged yet (900.0), a missing break_timer key means no break in progress (0.0), a missing hit key means no flash (0.0), a missing shield_radius key means never drawn (0.0), a missing efficiency key means no machinery run yet (0.0, the transient field default), a missing potential_efficiency key means no machinery run yet (1.0, not "no power").'),
        'delta': f('float', 'breakTimer -= Time.delta;', 'The tick delta in Time.delta units (ShieldWall.java:76, `breakTimer -= Time.delta;`); the driver passes its tick seconds (the N2190 driver convention), and edelta() is efficiency * delta() (BuildingComp.java:1927-1928, `return efficiency * delta();`, delta() is Time.delta * timeScale, BuildingComp.java:1922-1923, timeScale 1 by default).'),
    }
    n2204_outputs = {
        'shield': f('float', 'shield = Mathf.clamp(shield + regenSpeed * edelta(), 0f, shieldHealth);', 'The shield after the tick (ShieldWall.java:80): unchanged while broken (breakTimer > 0), otherwise clamp(shield + regenSpeed * edelta(), 0, shieldHealth) with regenSpeed 2f (ShieldWall.java:17) and edelta() = efficiency * delta (BuildingComp.java:1927-1928); the regen branch is decided on the pre-update break_timer.'),
        'break_timer': f('float', 'breakTimer -= Time.delta;', 'The break timer after the tick (ShieldWall.java:75-76, `if(breakTimer > 0){` / `breakTimer -= Time.delta;`): decayed by the raw delta while broken, never clamped (Java lets it go slightly negative; broken() reads `breakTimer > 0`), otherwise the incoming break_timer unchanged.'),
        'hit': f('float', 'hit = Math.max(hit, 0f);', 'The hit flash after the tick (ShieldWall.java:83-86, `if(hit > 0){` / `hit -= Time.delta / 10f;` / `hit = Math.max(hit, 0f);`, hit declared in WallBuild, Wall.java:89, `protected float hit;`): decayed by delta / 10f while above zero, floored at 0.0.'),
        'shield_radius': f('float', 'shieldRadius = Mathf.lerpDelta(shieldRadius, broken() ? 0f : 1f, 0.12f);', 'The shield radius after the tick (ShieldWall.java:88): lerped toward broken() ? 0f : 1f at 0.12 through the port canonical lerpDelta (SourceMathState.source_lerp_delta); broken() is the N2202 coupling read AFTER the breakTimer decay, on the updated timer.'),
        'broken': f('bool', 'return breakTimer > 0 || !canConsume();', 'Whether the wall is broken after the tick (ShieldWall.java:91-92, `public boolean broken(){` with `return breakTimer > 0 || !canConsume();`, canConsume() is BuildingComp.java:1917-1918, `return potentialEfficiency > 0;`): true while the updated break_timer is above zero or the wall has no power; the driver re-stamps this outside the consumption gate.'),
    }

    entries = [
        ('N2204', OWNER, 'source_shield_wall_update_tile_state', SHIELD_WALL, 'mindustry.world.blocks.defense.ShieldWall.ShieldWallBuild', 'ShieldWallBuild.updateTile()', n2204_inputs, n2204_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed ShieldWall updateTile() advance from ShieldWall.java / Wall.java / BuildingComp.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed ShieldWall updateTile() advance from ShieldWall.java / Wall.java / BuildingComp.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the shield, the break timer,
    # the hit flash, the shield radius, and the broken flag.
    by_slice['N2204'] = [
        'source_shield_wall_update_tile_state_result.shield',
        'source_shield_wall_update_tile_state_result.break_timer',
        'source_shield_wall_update_tile_state_result.hit',
        'source_shield_wall_update_tile_state_result.shield_radius',
        'source_shield_wall_update_tile_state_result.broken',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2204', dict(status='done', java_source=SHIELD_WALL, java_class='mindustry.world.blocks.defense.ShieldWall.ShieldWallBuild', java_method='ShieldWallBuild.updateTile()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2204'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
