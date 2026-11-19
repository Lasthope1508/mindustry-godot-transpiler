"""Register the TurretBuild.updateTile() warmup advance (N2308).

TurretBuild.updateTile() warmup advance (Turret.java:502-515,
`float warmupTarget = (isShooting && canConsume()) ||
charging() ? 1f : 0f;` / `if(warmupTarget > 0 &&
!controlled()){` / `warmupHold = 1f;` / `if(warmupHold >
0f){` / `warmupHold -= Time.delta / warmupMaintainTime;` /
`warmupTarget = 1f;` / `if(linearWarmup){` /
`shootWarmup = Mathf.approachDelta(shootWarmup,
warmupTarget, shootWarmupSpeed * (warmupTarget > 0 ?
efficiency : 1f));` / `}else{` / `shootWarmup =
Mathf.lerpDelta(shootWarmup, warmupTarget,
shootWarmupSpeed * (warmupTarget > 0 ? efficiency : 1f));`)
on `public class TurretBuild extends ReloadTurretBuild
implements ControlBlock{` (Turret.java:277), inside
updateTile() (Turret.java:490). canConsume() is the
TurretBuild override (Turret.java:624-629, `public
boolean canConsume(){` / `if(heatRequirement > 0 &&
heatReq <= 0f){` / `return false;` / `return
super.canConsume();`) over the BuildingComp gate
(BuildingComp.java:1917-1919, `public boolean
canConsume(){` / `return potentialEfficiency > 0;`);
heatRequirement is per-def (Turret.java:53, `public
float heatRequirement = -1f;`, 20f afflict / 144f
malign, Blocks.java:5122/6240) and heatReq is the live
field (Turret.java:295, `public float heatReq;`),
refreshed each tick (Turret.java:538-539,
`if(heatRequirement > 0){` / `heatReq =
calculateHeat(sideHeat);`); both arrive as explicit
params, so a cold heat turret (heatReq <= 0) cannot
consume even while shooting with power. charging() is
Turret.java:715-717 (`public boolean charging(){` /
`return queuedBullets > 0 && shoot.firstShotDelay >
0;`); controlled() is Turret.java:441-443 (`public
boolean controlled(){` / `return unit.isPlayer();`). The hold / warmup fields are
Turret.java:286 (`public float shootWarmup, charge,
warmupHold = 0f;`); the per-def knobs are
warmupMaintainTime (Turret.java:84, `public float
warmupMaintainTime = 0f;`, 120f on titan / smite /
malign, Blocks.java:4803/5909/6242), shootWarmupSpeed
(Turret.java:136, `public float shootWarmupSpeed =
0.1f;`, 0.04f on smite, Blocks.java:5904) and linearWarmup
(Turret.java:138, `public boolean linearWarmup =
false;`, no def sets it true). The approach / lerp legs
reuse the ported SourceMathState helpers (N489/N490,
source_approach_delta / source_lerp_delta), which already
encode arc Mathf.approachDelta / lerpDelta (arc
Mathf.java:420/430).

RED decisions (resolved at RED): (1) One pure function
on SourceTurretBuildState.gd next to the N2268 fogRadius
row, following the N2256 updateTile precedent: (frame,
is_shooting, potential_efficiency, charging, controlled,
warmup_hold, shoot_warmup, linear_warmup,
shoot_warmup_speed, efficiency, warmup_maintain_time,
delta) and three result keys `warmup_target`,
`warmup_hold`, `shoot_warmup`. (2) All live values
arrive as explicit params (the N2188 precedent) -- the
tick frame tracks only cheating / enabled / power_status /
efficiency today. (3) The set and the decay run in the
SAME tick: a hold set to 1f is decayed by Time.delta /
warmupMaintainTime before the warmupTarget = 1f force, so
a fresh hold reads 1 - delta/maintain, not 1 -- the proof
pins 7199/7200 for delta 1/60 and maintain 120. (4) With
the default warmupMaintainTime 0f the Java float division
yields Infinity and the hold goes to -Infinity in the
same tick -- no invented guard; the proof pins it. (5)
The lerp leg is the default (linearWarmup false on every
def); the approach leg is the linearWarmup branch. (6)
The rate folds efficiency only while the target is
positive (`warmupTarget > 0 ? efficiency : 1f`), so a
decaying warmup ignores efficiency -- the proof pins
both legs. (7) NO driver tick line: the tick frame
tracks no is_shooting / charging / controlled /
shoot_warmup / warmup_hold keys yet (the N2256 updateTile
precedent); the driver waits until those frame keys are
tracked. (8) The canConsume() call at :502 dispatches to
the TurretBuild override (Turret.java:624-629), not the
BuildingComp base: a heat turret (heatRequirement > 0 --
20f afflict, 144f malign, Blocks.java:5122/6240) with
heatReq <= 0 cannot consume even with power, so the heat
gate is computed in the pure function from two explicit
params (heat_requirement per-def, heat_req live) instead
of being deferred -- the -1f default means "no heat
gate" and the proof pins all three legs (blocked /
heated / no requirement). Three new result symbols:
warmup_target, warmup_hold, shoot_warmup. Slice
sources: Turret.java + BuildingComp.java + Blocks.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_estimate_dps import DEFERRED as N2301_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07TurretUpdateTileWarmupProof'
WARMUP_OWNER = 'SourceTurretBuildState.source_turret_update_tile_warmup_state'
TESTS = ['test_c07_turret_update_tile_warmup_registration', 'test_all_c07_turret_update_tile_warmup_input_evidence_is_exact', 'test_turret_update_tile_warmup_state', 'test_reference_graph_and_actual_c07_turret_update_tile_warmup']
# The 3 slice sources the N2308 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/content/Blocks.java',
]
EXACT_EXPRS = [
    'float warmupTarget = (isShooting && canConsume()) || charging() ? 1f : 0f;',
    'if(warmupTarget > 0 && !controlled()){',
    'warmupHold = 1f;',
    'if(warmupHold > 0f){',
    'warmupHold -= Time.delta / warmupMaintainTime;',
    'warmupTarget = 1f;',
    'if(linearWarmup){',
    'shootWarmup = Mathf.approachDelta(shootWarmup, warmupTarget, shootWarmupSpeed * (warmupTarget > 0 ? efficiency : 1f));',
    'shootWarmup = Mathf.lerpDelta(shootWarmup, warmupTarget, shootWarmupSpeed * (warmupTarget > 0 ? efficiency : 1f));',
    'public float warmupMaintainTime = 0f;',
    'public float shootWarmupSpeed = 0.1f;',
    'public boolean linearWarmup = false;',
    'public float shootWarmup, charge, warmupHold = 0f;',
    'public boolean canConsume(){',
    'if(heatRequirement > 0 && heatReq <= 0f){',
    'public float heatRequirement = -1f;',
    'public float heatReq;',
    'return potentialEfficiency > 0;',
    'public boolean charging(){',
    'return queuedBullets > 0 && shoot.firstShotDelay > 0;',
    'public boolean controlled(){',
    'return unit.isPlayer();',
    'transient float efficiency;',
    'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
    'warmupMaintainTime = 120f;',
    'shootWarmupSpeed = 0.04f;',
    'public void updateTile(){',
]

# DEFERRED is carried from the N2301 register script via import --
# never retyped. Nothing in it closes here: the warmup advance
# was never a deferred entry of the Turret chain. Four entries
# are added: the N2308 Windows Godot proof debt (GOAL.md
# section 5), the warmup driver tick line (waits for the frame
# keys), the isShooting computation (updateTile :492), and the
# rest of updateTile (:491-500 target/sound, :517-530
# recoil/heat/charge/unit).
DEFERRED = N2301_DEFERRED + [
    'Turret updateTile warmup Windows Godot proof -- debt in GOAL.md section 5, same as N2148/N2227: the N2308 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Wire the Turret warmup driver tick line (source_turret_tick_buildings_state) once the tick frame tracks is_shooting / charging / controlled / shoot_warmup / warmup_hold; N2308 is pure-function-only (the N2294 updateTile precedent).',
    'Port the TurretBuild.updateTile() isShooting computation (Turret.java:492, target / unit.controller() / logicControlled() / logicShooting) as its own slice; N2308 takes is_shooting as an explicit bool.',
    'Port the rest of TurretBuild.updateTile() (Turret.java:491-500 validateTarget / unit ammo / soundLoop, :517-530 curRecoil / heat / charge / unit.tile / unit.rotation) as their own slices; N2308 covers only the warmup advance :502-515.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    warmup_inputs = {
        'frame': a('Dictionary', 'public void updateTile(){', 'The turret frame (accepted for the family call shape; this leg reads no live frame key -- all live values arrive as explicit params, the N2188 per-def-param precedent, because the tick frame tracks only cheating/enabled/power_status/efficiency).'),
        'is_shooting': a('bool', 'public boolean wasShooting, isShooting;', 'Whether the turret is shooting: TurretBuild.isShooting (Turret.java:292, `public boolean wasShooting, isShooting;`), set in updateTile :492 from alwaysShooting / unit / logic / target; passed explicitly because the :492 computation is not ported yet and the tick frame tracks no is_shooting key.'),
        'potential_efficiency': a('float', 'transient float potentialEfficiency;', 'The building potential efficiency: BuildingComp.potentialEfficiency (BuildingComp.java:89), Java default 0.0f, machinery-set later; the canConsume() gate (BuildingComp.java:1917-1919, `public boolean canConsume(){` / `return potentialEfficiency > 0;`) reads it, so the pure function computes can_consume from it instead of taking a second bool; passed explicitly because the tick frame tracks no potential_efficiency key.', source=BUILDING_COMP),
        'charging': a('bool', 'public boolean charging(){', 'Whether the turret is charging a shot: TurretBuild.charging() (Turret.java:715-717, `public boolean charging(){` / `return queuedBullets > 0 && shoot.firstShotDelay > 0;`); passed explicitly because queuedBullets / firstShotDelay are not tracked in the tick frame yet. A charging turret targets warmup 1 even when not shooting.'),
        'controlled': a('bool', 'public boolean controlled(){', 'Whether a player controls the turret unit: TurretBuild.controlled() (Turret.java:441-443, `public boolean controlled(){` / `return unit.isPlayer();`); passed explicitly because the tick frame tracks no unit/player key. A controlled shooter never sets warmupHold.'),
        'warmup_hold': a('float', 'public float shootWarmup, charge, warmupHold = 0f;', 'The warmup hold timer: TurretBuild.warmupHold (Turret.java:286), Java default 0f; set to 1f when the target is positive and the turret is uncontrolled, then decayed by Time.delta / warmupMaintainTime in the same tick; passed explicitly because the tick frame tracks no warmup_hold key yet.'),
        'shoot_warmup': a('float', 'public float shootWarmup, charge, warmupHold = 0f;', 'The current warmup: TurretBuild.shootWarmup (Turret.java:286), Java default 0f, read by warmup() (Turret.java:354-355, `return shootWarmup;`); advanced toward warmupTarget by the approach (linearWarmup) or lerp leg; passed explicitly because the tick frame tracks no shoot_warmup key yet.'),
        'linear_warmup': a('bool', 'public boolean linearWarmup = false;', 'Whether warmup advances linearly: Turret.linearWarmup (Turret.java:138), default false; selects the approachDelta leg over the lerpDelta leg; passed explicitly because it is per-def static state, not a live frame key. No def sets it true.'),
        'shoot_warmup_speed': a('float', 'public float shootWarmupSpeed = 0.1f;', 'The warmup advance speed: Turret.shootWarmupSpeed (Turret.java:136), default 0.1f (0.04f on smite, Blocks.java:5904); the rate factor of both advance legs; passed explicitly because it is per-def static state, not a live frame key.'),
        'efficiency': a('float', 'transient float efficiency;', 'The folded live efficiency: BuildingComp.efficiency (BuildingComp.java:85); the advance rate folds it only while the target is positive (`warmupTarget > 0 ? efficiency : 1f`), so a decaying warmup ignores it; passed explicitly (the tick frame stamps frame["efficiency"] for power turrets, but this leg takes it as a param like the N2253/N2254 precedent).', source=BUILDING_COMP),
        'warmup_maintain_time': a('float', 'public float warmupMaintainTime = 0f;', 'How long warmup is maintained while not shooting: Turret.warmupMaintainTime (Turret.java:84, `public float warmupMaintainTime = 0f;`, 120f on titan / smite / malign, Blocks.java:4803/5909/6242); the hold decay divisor; passed explicitly because it is per-def static state, not a live frame key. The 0f default keeps the Java float-division behavior (Infinity, hold to -Infinity) -- no invented guard.'),
        'delta': a('float', 'return Time.delta * timeScale;', 'The tick delta: Time.delta through delta() (BuildingComp.java:1922-1923, `public float delta(){` / `return Time.delta * timeScale;`); passed explicitly as raw tick seconds (the N2248 convention).', source=BUILDING_COMP),
        'heat_requirement': a('float', 'public float heatRequirement = -1f;', 'The minimum input heat required to fire: Turret.heatRequirement (Turret.java:52-53, `Minimum input heat required to fire.` / `public float heatRequirement = -1f;`, default -1f meaning no heat gate; 20f on afflict, 144f on malign, Blocks.java:5122/6240); the canConsume() override (Turret.java:624-629) returns false when heatRequirement > 0 and heatReq <= 0; passed explicitly because it is per-def static state, not a live frame key.'),
        'heat_req': a('float', 'public float heatReq;', 'The live heat input: TurretBuild.heatReq (Turret.java:295, `public float heatReq;`, Java default 0f), refreshed each tick (Turret.java:538-539, `if(heatRequirement > 0){` / `heatReq = calculateHeat(sideHeat);`); the canConsume() override (Turret.java:624-629) reads it, so the pure function computes can_consume from it instead of taking a second bool; passed explicitly because the tick frame tracks no heat_req key.'),
    }
    warmup_outputs = {
        'warmup_target': a('float', 'float warmupTarget = (isShooting && canConsume()) || charging() ? 1f : 0f;', 'The warmup target: 1f when (isShooting and canConsume()) or charging(), else 0f (Turret.java:502), forced to 1f while warmupHold is positive (Turret.java:508).'),
        'warmup_hold': a('float', 'warmupHold -= Time.delta / warmupMaintainTime;', 'The warmup hold after the tick: 1f when the target is positive and the turret is uncontrolled (Turret.java:503-505), then decayed by Time.delta / warmupMaintainTime in the same tick (Turret.java:506-508); 1 - delta/maintain for a fresh hold, -Infinity when warmupMaintainTime is the 0f default.'),
        'shoot_warmup': a('float', 'shootWarmup = Mathf.lerpDelta(shootWarmup, warmupTarget, shootWarmupSpeed * (warmupTarget > 0 ? efficiency : 1f));', 'The warmup after the tick: advanced toward warmupTarget by approachDelta when linearWarmup (Turret.java:512) or lerpDelta otherwise (Turret.java:514), at rate shootWarmupSpeed * (efficiency while the target is positive, else 1f); read by warmup() (Turret.java:354-355) and the minWarmup fire gate (Turret.java:733).'),
    }
    return warmup_inputs, warmup_outputs


def verify():
    """Check every EXACT_EXPRS line and every input/output
    java_expr appears verbatim in its upstream source, without
    touching any SSOT JSON. Exit 0 when all are present."""
    upstream = {}
    for source in SLICE_SOURCES:
        upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
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
            text = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
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
    warmup_inputs, warmup_outputs = definitions()

    entries = [
        ('N2308', WARMUP_OWNER, 'source_turret_update_tile_warmup_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.updateTile()', warmup_inputs, warmup_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed TurretBuild.updateTile() warmup advance from Turret.java + BuildingComp.java + Blocks.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed TurretBuild.updateTile() warmup advance from Turret.java + BuildingComp.java + Blocks.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: warmup_target, warmup_hold, shoot_warmup.
    by_slice['N2308'] = [
        'source_turret_update_tile_warmup_state_result.warmup_target',
        'source_turret_update_tile_warmup_state_result.warmup_hold',
        'source_turret_update_tile_warmup_state_result.shoot_warmup',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2308', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.updateTile()', godot_owner=WARMUP_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2308'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
