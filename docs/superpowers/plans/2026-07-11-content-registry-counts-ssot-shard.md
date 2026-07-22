# Content Registry Counts SSOT Shard

## Totals

| Metric | Count |
| --- | ---: |
| Total tasks | 10 |
| Done | 8 |
| Not done | 2 |

## Done

- [x] Read SSOT rules, module manifest, existing content registry shard tests, and `content_registry.json` canonical counts.
- [x] Add RED tests for `content_registry_counts` manifest registration, canonical mirror fields, shard file, and `PortGame` lookup accessor.
- [x] Add `content_registry_counts` to `source_ssot_modules.json` with one root key, canonical module, canonical collection, reference key, and mirror fields.
- [x] Add `source_modules/content_registry_counts.json` mirroring canonical `content_registry.counts`.
- [x] Add `content_registry_count_state(count_name)` through `SourceSsotCatalog.lookup_state`.
- [x] Fix label collision from `count` to `countName` after MCP runtime proved `lookup_state.count` was overwritten.
- [x] Run focused tests, SSOT validator, Godot MCP runtime proof, and full Python suite.
- [x] Module shard for remaining `content_registry.waves.version` metadata.

## Not Done

- [ ] Module shards for root policy dictionaries where useful.
- [ ] Java behavior slice N1151 and later gameplay migration remain separate.

## Evidence

- RED 1: `content_registry_counts` tests failed because manifest key and shard file were missing.
- RED 2: label collision test failed because manifest label was `count`, expected `countName`.
- Focused tests: `8 passed, 638 subtests passed`.
- SSOT: `module_count=112`, `errors=[]`.
- Godot MCP runtime: `/root/Main.content_registry_count_state("blocks")` returned `loaded=true`, `count=4`, `countName=blocks`, `entry.canonical_count=content_registry.counts.blocks`, `entry.count=417`.
- Godot debug: `errors=[]`, final `finalErrors=[]`.
- Full suite: `4017 passed, 39290 subtests passed`.
- Wave metadata follow-up: focused tests `2 passed, 2666 deselected`; SSOT gate `json_modules 93 []`; full suites `1687 passed` and `1067 passed, 15990 subtests`; Godot MCP runtime `/root/Main.content_registry_wave_metadata_state("version")` returned `loaded=true`, `metadataKey="version"`, `entry.canonical_metadata=content_registry.waves.version`, `entry.value=7`, and `version=1`; debug `errors=[]`, final `finalErrors=[]`.
- Ledger unchanged: `1073 total`, `847 done`, `226 not done`, `78.94%`; next unfinished Java slice remains `N1151`.
