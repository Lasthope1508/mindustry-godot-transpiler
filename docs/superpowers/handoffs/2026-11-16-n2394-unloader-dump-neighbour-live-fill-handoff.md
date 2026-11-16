# Handoff N2394 — PayloadUnloader dump neighbour live fill

## What this slice did

New pure `source_payload_unloader_dump_neighbour_live_fill_state`
— scans the proximity ring live before the dump pure and fills
all 6 neighbour arrays in ring order (index i = ring cell i).
Accepts/canDump use ONLY the default BuildingComp gates. Tick
wires the fill before the dump reads; supplied arrays win +
`dump_neighbour_live` flag. 5 files, +1306/−4, commit `2ab1b8a54`
on `slice/N2394-unloader-dump-neighbour-live-fill`.

## Key facts for the next agent

- **Default gates only:** acceptItem :864-866 REQUIRES
  consumesItem; acceptLiquid :868-870; canDumpLiquid :910-912;
  canDump :1124-1126. Per-block overrides are OUT of scope — the
  unloader CANNOT dump into vault/container/core yet (follow-up
  slice).
- **Judgment calls:** accepts-item = FIRST held item by content
  order; no-frame = 0.0/0.0/false×4 (conduit counts as no-frame);
  ring NOT deduped, NO team filter (proof pins the multi-press at
  both ring 5 and 6).
- **Catalog gap (NOT fixed):** 30 defs have consumeLiquid rows
  but lack the `hasLiquids` key (e.g. electrolyzer) — the fill
  uses the Java field default false.
- SSOT +6/+1/+1/+2. DEFERRED #248 resolved (301→300).

## Godot debt (this slice)

- NEW proof `C07PayloadUnloaderDumpNeighbourLiveFillProof` (6
  keys) — never run.
