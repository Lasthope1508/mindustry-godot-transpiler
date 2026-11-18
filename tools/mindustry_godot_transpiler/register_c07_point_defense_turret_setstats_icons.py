"""Register the PointDefenseTurret setStats() rows + icons() return array (N2246).

N2240-N2245 made the point-defense turret live (aim + shoot,
shouldConsume, live bullets, team stamp, draw, write/read) --
but the class-level display rows had no slice: PointDefenseTurret
overrides setStats() (PointDefenseTurret.java:51-57, `public void
setStats(){`) adding two unconditional stat rows
(`stats.add(Stat.reload, 60f / reload, StatUnit.perSecond);` --
PointDefenseTurret.java:55 -- and `stats.add(Stat.damage,
bulletDamage, StatUnit.none);` -- PointDefenseTurret.java:56),
and overrides icons() (PointDefenseTurret.java:46-49,
`@Override public TextureRegion[] icons(){`) returning the two
loaded regions in order (`return new TextureRegion[]{baseRegion,
region};` -- PointDefenseTurret.java:48). baseRegion is the
block's own base field (`public @Load(value = "@-base",
fallback = "block-@size") TextureRegion baseRegion;` --
PointDefenseTurret.java:24) and region is the inherited block
region (`public TextureRegion region;` -- Block.java:427).

RED decisions (resolved at RED): (1) Two pure functions on the
same family file N2240-N2245 built:
source_point_defense_turret_set_stats_state(reload,
bullet_damage) returning reload_per_second (60f / reload) and
damage (bulletDamage); source_point_defense_turret_icons_state(
base_region, region) returning icons ([base_region, region]).
Both setStats params are explicit floats (the N2224 RepairTurret
setStats per-def-param precedent -- reload and bulletDamage are
per-def static state, not live frame keys: class defaults reload
30f / bulletDamage 10f, PointDefenseTurret.java:40, :33; the one
def, segment, reload 8f / bulletDamage 30f, Blocks.java:3845,
:3844); both icons params are explicit Variants (the N2227
RepairTurret icons precedent: TextureRegion values ride as
Variants; the proof passes string region ids, as the N2227 proof
did with ["repair-point-base", "repair-point"]). (2) There is NO
driver tick line: setStats/icons are load-time/display reads, not
per-tick writes (the N2224 setStats + N2227 icons lifecycle
precedent); the proof calls the pure functions directly with
per-def params. (3) The `super.setStats();` leg
(PointDefenseTurret.java:53) is NOT this slice: the base stats
come from the ReloadTurret.setStats() booster replace
(ReloadTurret.java:17-23, `if(coolant != null){` /
`stats.replace(Stat.booster, StatValues.boosters(reload,
coolant.amount, coolantMultiplier, true, coolant::consumes));`)
-- a no-op for segment, which defines NO coolant consumer
(Blocks.java:3835-3845, the N2241 precedent) -- plus the
BaseTurret shootRange row (`stats.add(Stat.shootRange, range /
tilesize, StatUnit.blocks);`, BaseTurret.java:96) and the Block
base rows (N1696); only the two PointDefenseTurret-own rows are
pinned here. (4) The Block.icons() base (`protected
TextureRegion[] icons(){`, Block.java:976-980, the
variants/teamRegion fold) is NOT this slice: PointDefenseTurret
overrides it, so only the override's return array is pinned; the
getGeneratedIcons cache (`public TextureRegion[]
getGeneratedIcons(){`, Block.java:986, `return generatedIcons ==
null ? (generatedIcons = icons()) : generatedIcons;`,
Block.java:987) is likewise deferred -- only the override's
two-element array, base first (the N1232 TractorBeamTurret.icons()
precedent). (5) The one def, segment, is the only
PointDefenseTurret def (Blocks.java:3835-3845), so one set of
functions covers it. Three new result symbols:
reload_per_second, damage, icons. SSOT expected after GREEN:
symbols +3, Done +1, contracts +2, schema +4, 11563/1695/1627/3045
-> 11566/1696/1629/3049; defense shard slices 174 -> 175.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_point_defense_turret_write_read import DEFERRED as N2245_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
POINT_DEFENSE = 'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
BLOCK = 'core/src/mindustry/world/Block.java'
RELOAD_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java'
BASE_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java'
PROOF = '/root/C07PointDefenseTurretSetStatsIconsProof'
SET_STATS_OWNER = 'SourcePointDefenseTurretBuildState.source_point_defense_turret_set_stats_state'
ICONS_OWNER = 'SourcePointDefenseTurretBuildState.source_point_defense_turret_icons_state'
TESTS = ['test_c07_point_defense_turret_setstats_icons_registration', 'test_all_c07_point_defense_turret_setstats_icons_input_evidence_is_exact', 'test_point_defense_turret_setstats_icons_state', 'test_reference_graph_and_actual_c07_point_defense_turret_setstats_icons']
# The 5 slice sources the N2246 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/world/Block.java',
    'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
    'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
]
EXACT_EXPRS = ['public TextureRegion[] icons(){', 'return new TextureRegion[]{baseRegion, region};', 'public void setStats(){', 'super.setStats();', 'stats.add(Stat.reload, 60f / reload, StatUnit.perSecond);', 'stats.add(Stat.damage, bulletDamage, StatUnit.none);', 'public float bulletDamage = 10f;', 'reload = 30f;', 'public @Load(value = "@-base", fallback = "block-@size") TextureRegion baseRegion;', 'public TextureRegion region;', 'protected TextureRegion[] icons(){', 'public TextureRegion[] getGeneratedIcons(){', 'return generatedIcons == null ? (generatedIcons = icons()) : generatedIcons;', 'public class PointDefenseTurret extends ReloadTurret{', 'segment = new PointDefenseTurret("segment"){{', 'bulletDamage = 30f;', 'reload = 8f;', 'if(coolant != null){', 'stats.replace(Stat.booster, StatValues.boosters(reload, coolant.amount, coolantMultiplier, true, coolant::consumes));', 'stats.add(Stat.shootRange, range / tilesize, StatUnit.blocks);']

# DEFERRED is carried from the N2245 register script via import --
# never retyped. Nothing is dropped here: the lumped
# PointDefenseTurret updateTile advance entry still waits for
# the live coolant wiring + the real effect/sound spawn (its
# "setStats / icons" words are stale now that N2246 lands them
# -- the N2245 precedent carries the entry verbatim), and the
# TractorBeam half is untouched. Only the N2246 Windows-proof
# debt entry is appended.
DEFERRED = list(N2245_DEFERRED) + [
    'PointDefenseTurret setStats/icons Windows Godot proof -- debt in GOAL.md section 5, same as N2240-N2245: the N2246 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=POINT_DEFENSE, **extra):
        return backed(typ, source, expr, rule, **extra)

    set_stats_inputs = {
        'reload': a('float', 'reload = 30f;', 'The per-def reload in ticks between shots (PointDefenseTurret.java:40, `reload = 30f;`, the constructor default; segment 8f, Blocks.java:3845); passed explicitly because it is per-def static state, not a live frame key (the N2224 RepairTurret setStats per-def-param precedent).'),
        'bullet_damage': a('float', 'public float bulletDamage = 10f;', 'The per-def bullet damage (PointDefenseTurret.java:33, `public float bulletDamage = 10f;`, the class default; segment 30f, Blocks.java:3844); passed explicitly because it is per-def static state, not a live frame key.'),
    }
    set_stats_outputs = {
        'reload_per_second': a('float', 'stats.add(Stat.reload, 60f / reload, StatUnit.perSecond);', 'The Stat.reload row value in shots per second: 60f / reload (PointDefenseTurret.java:55, `stats.add(Stat.reload, 60f / reload, StatUnit.perSecond);`): class default 2.0 (60/30), segment 7.5 (60/8).'),
        'damage': a('float', 'stats.add(Stat.damage, bulletDamage, StatUnit.none);', 'The Stat.damage row value: bulletDamage, unit none (PointDefenseTurret.java:56, `stats.add(Stat.damage, bulletDamage, StatUnit.none);`): class default 10.0, segment 30.0.'),
    }
    icons_inputs = {
        'base_region': a('Variant', 'public @Load(value = "@-base", fallback = "block-@size") TextureRegion baseRegion;', 'The block base region (PointDefenseTurret.java:24, `public @Load(value = "@-base", fallback = "block-@size") TextureRegion baseRegion;`, loaded as name + "-base" with the "block-@size" fallback); passed explicitly because it is per-def static state, not a live frame key (the N2227 RepairTurret icons per-def-param precedent).'),
        'region': a('Variant', 'public TextureRegion region;', 'The inherited block region (Block.java:427, `public TextureRegion region;`); passed explicitly because it is per-def static state, not a live frame key.', source=BLOCK),
    }
    icons_outputs = {
        'icons': a('Array', 'return new TextureRegion[]{baseRegion, region};', 'The icons() return array: [baseRegion, region], base first, exactly 2 elements (PointDefenseTurret.java:48, `return new TextureRegion[]{baseRegion, region};`); segment ["segment-base", "segment"] (Blocks.java:3835). The Block.icons() base (Block.java:976-980, variants/teamRegion fold) and the getGeneratedIcons cache (Block.java:986-987) are deferred (the N1232 precedent) -- only the override return array is pinned.'),
    }
    return set_stats_inputs, set_stats_outputs, icons_inputs, icons_outputs


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
    set_stats_inputs, set_stats_outputs, icons_inputs, icons_outputs = definitions()

    entries = [
        ('N2246', SET_STATS_OWNER, 'source_point_defense_turret_set_stats_state', POINT_DEFENSE, 'mindustry.world.blocks.defense.turrets.PointDefenseTurret', 'PointDefenseTurret.setStats()', set_stats_inputs, set_stats_outputs, True, 'Dictionary'),
        ('N2246', ICONS_OWNER, 'source_point_defense_turret_icons_state', POINT_DEFENSE, 'mindustry.world.blocks.defense.turrets.PointDefenseTurret', 'PointDefenseTurret.icons()', icons_inputs, icons_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed PointDefenseTurret setStats()/icons() state from PointDefenseTurret.java + Blocks.java + Block.java + ReloadTurret.java + BaseTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed PointDefenseTurret setStats()/icons() state from PointDefenseTurret.java + Blocks.java + Block.java + ReloadTurret.java + BaseTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: reload_per_second, damage, icons.
    by_slice['N2246'] = [
        'source_point_defense_turret_set_stats_state_result.reload_per_second',
        'source_point_defense_turret_set_stats_state_result.damage',
        'source_point_defense_turret_icons_state_result.icons',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2246', dict(status='done', java_source=POINT_DEFENSE, java_class='mindustry.world.blocks.defense.turrets.PointDefenseTurret', java_method='PointDefenseTurret.setStats()/icons()', godot_owner=SET_STATS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2246'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
