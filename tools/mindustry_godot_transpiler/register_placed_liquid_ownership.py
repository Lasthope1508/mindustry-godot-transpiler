"""Register typed liquid ordinals, source-explicit block flags and placed storage ownership."""
from pathlib import Path

from mindustry_port import source_ssot, source_symbols

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
LOADER = 'core/src/mindustry/core/ContentLoader.java'
CONTENT = 'core/src/mindustry/ctype/Content.java'
BLOCK = 'core/src/mindustry/world/Block.java'
DRILL = 'core/src/mindustry/world/blocks/production/Drill.java'
BUILDING = 'core/src/mindustry/entities/comp/BuildingComp.java'
PROOF = '/root/Main.PlacedLiquidOwnershipProof'
TESTS = ['test_explicit_liquid_flags_follow_constructor_inheritance_and_initializer', 'test_real_registry_drill_liquid_flag_and_registered_owner_contracts', 'test_liquid_owner_is_bound_on_real_placement_path', 'test_live_building_storage_and_typed_catalog_runtime']
CATALOG_OWNER = 'SourceContentRegistryRuntimeState.source_liquid_catalog_state'
FLAG_OWNER = 'SourcePlacedBlockState.source_block_has_liquids_state'
BUILDING_OWNER = 'SourcePlacedBlockState.source_initialize_building_liquids_state'


def key(typ, source, expr, rule, **extra):
    return dict(type=typ, status='source-backed', java_source=source, java_expr=expr, rule=rule, **extra)


def main():
    inputs = {
        'source_liquid_catalog_input': {'content_catalog': key('Object', LOADER, 'return getBy(ContentType.liquid);', 'Hydrated typed liquid sequence in upstream constructor registration order; UI string IDs remain unchanged.')},
        'source_block_has_liquids_input': {'block': key('Variant', BLOCK, 'public @NoPatch boolean hasLiquids;', 'Hydrated source-explicit constructor/initializer flag. Missing flags remain unresolved; this API has no false fallback.')},
        'source_initialize_building_liquids_input': {
            'sprite': key('Object', BUILDING, 'if(block.hasLiquids) liquids = new LiquidModule();', 'Existing placed sprite carries this Building instance field as registered metadata.'),
            'has_liquids': dict(type='bool', status='alias', alias_of='source_block_has_liquids_result.has_liquids'),
            'content_catalog': dict(type='Object', status='alias', alias_of='source_liquid_catalog_input.content_catalog'),
        },
    }
    results = {
        'source_liquid_catalog_result': {
            'content_liquid_ids': dict(type='Array', status='alias', alias_of='source_liquid_module_initial_input.content_liquid_ids', used_by=[CATALOG_OWNER]),
            'liquid_id_by_name': key('Dictionary', CONTENT, 'this.id = (short)Vars.content.getBy(getContentType()).size;', 'Typed liquid name-to-ordinal lookup derives from ordered registration, never the global mixed-type by_id map.', used_by=[CATALOG_OWNER]),
        },
        'source_block_has_liquids_result': {'has_liquids': key('bool', DRILL, 'hasLiquids = true;', 'Source-explicit flags follow constructor inheritance and initializer overrides. Consumer.apply-only flags and absent flags remain deferred.', used_by=[FLAG_OWNER])},
        'source_initialize_building_liquids_result': {'liquids': key('Variant', BUILDING, '@Nullable LiquidModule liquids;', 'Nullable canonical storage frame owned by this placed building. True guard replaces storage on create; false guard preserves the existing field.', schema='source_liquid_module_storage_state', used_by=[BUILDING_OWNER])},
    }
    entries = [
        ('N1999', CATALOG_OWNER, LOADER, 'mindustry.core.ContentLoader', 'liquids(); liquid(String name)', 'source_liquid_catalog', ['content_catalog'], ['public Seq<Liquid> liquids(){', 'return getBy(ContentType.liquid);', 'public Liquid liquid(String name){', 'return getByName(ContentType.liquid, name);']),
        ('N2000', FLAG_OWNER, DRILL, 'mindustry.world.blocks.production.Drill', 'Drill(String name)', 'source_block_has_liquids', ['block'], ['public Drill(String name){', 'hasLiquids = true;']),
        ('N2001', BUILDING_OWNER, BUILDING, 'mindustry.entities.comp.BuildingComp', 'create(Block block, Team team)', 'source_initialize_building_liquids', ['sprite', 'has_liquids', 'content_catalog'], ['public Building create(Block block, Team team){', 'if(block.hasLiquids) liquids = new LiquidModule();']),
    ]
    symbols = {}
    for slice_id, owner, source, java_class, method, prefix, params, exprs in entries:
        input_name, result_name = prefix + '_input', prefix + '_result'
        source_symbols.upsert_source_state_schema(GODOT, input_name, dict(status='active', owner=owner, runtime_proof=PROOF, keys=inputs[input_name]))
        source_symbols.upsert_source_state_schema(GODOT, result_name, dict(status='active', owner=owner, runtime_proof=PROOF, keys=results[result_name]))
        names = []
        for field, meta in {**inputs[input_name], **results[result_name]}.items():
            schema = input_name if field in inputs[input_name] else result_name
            name = prefix.removeprefix('source_') + '.' + field
            symbols[name] = dict(status='source-backed', godot_owner=owner, godot_symbol=f'{schema}.{field}', java_source=meta.get('java_source', source), java_method=method, java_expr=meta.get('java_expr', exprs[-1]), rule=meta.get('rule', 'Reuse the canonical registered input/result representation.'), tests=TESTS, runtime_proof=PROOF)
            names.append(name)
        source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=slice_id, java_source=source, source_method=method, params=[dict(name=p, type=inputs[input_name][p]['type'], schema=f'{input_name}.{p}') for p in params], return_keys=list(results[result_name]), tests=TESTS, runtime_proof=PROOF, rule='Typed source catalog and one persistent canonical frame per placed instance; no duplicated resource formulas or guessed liquid IDs.'))
        source_symbols.upsert_source_slice(GODOT, slice_id, dict(status='done', java_source=source, java_class=java_class, java_method=method, godot_owner=owner, exact_exprs=exprs, source_symbols=names, tests=TESTS, runtime_proof=PROOF, rule='Source-backed placed liquid storage ownership from hydrated explicit flags and typed content order.', deferred_exprs=['Consumers that enable hasLiquids only during apply/init are not inferred from missing metadata; their hydration remains deferred.', 'Production Drill consumer descriptors, booster predicates and automatic resource tick dispatch are not wired here; the proof drives a supplied consumer against the real world-owned frame.', 'Dynamic content/mod registration/reordering after placement, flow lifecycle and serialization remain separate checkpoints.']))
    symbols['placed_building_liquids.metadata_key'] = dict(status='source-backed', godot_owner=BUILDING_OWNER, godot_symbol='SourcePlacedBlockState.SOURCE_BUILDING_LIQUIDS_META_KEY', java_source=BUILDING, java_method='create(Block block, Team team)', java_expr='@Nullable LiquidModule liquids;', rule='Godot metadata key source_building_liquids represents the single BuildingComp.liquids field.', tests=TESTS, runtime_proof=PROOF)
    source_symbols.upsert_source_symbols(GODOT, symbols)
    for name in ['production_slices', 'production_api_contracts', 'production_state_schema', 'production_symbols', 'comp_slices', 'comp_api_contracts', 'content_registry_blocks']:
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))


if __name__ == '__main__':
    main()
