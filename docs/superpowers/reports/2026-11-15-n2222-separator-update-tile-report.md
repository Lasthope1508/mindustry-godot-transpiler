# N2222 Separator updateTile Advance — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 4 — wave advances-1, integration branch `integration/wave-advances-1-n2219-n2223`, base `2b6e6a33`).

## Source

- SeparatorBuild.updateTile (Separator.java:**130–167** — worker corrected the scope cite 128–166 by grep): totalProgress += warmup * delta(); if efficiency > 0: progress += getProgressIncrease(craftTime); warmup lerpDelta → 1f 0.02f; else warmup → 0; if progress >= 1f: progress %= 1f; weighted random pick via Mathf.randomSeed(seed++, 0, sum-1) over results; consume(); if item != null && items.get(item) < itemCapacity: offload(item); timerDump dump deferred (no timer helper).
- getProgressIncrease is the BASE at **BuildingComp.java:1203-1205** — Separator extends Block, NOT GenericCrafter, so there is no override (scope said to trace it; worker traced it).
- created() seed init (Separator.java:**82–84** — scope said :78-80): `seed = Mathf.randomSeed(tile.pos(), 0, Integer.MAX_VALUE - 1)`.
- craftTime defs (Blocks.java:**1240/:1258** — scope said :1259 for disassembler): separator 35f, disassembler 15f. Results ItemStacks: separator copper 5/lead 3/graphite 2/titanium 2; disassembler sand 2/graphite 1/titanium 1/thorium 1.
- Arc Mathf.randomSeed (Mathf.java:297-302): seeds a 2-state xorshift128+ Rand with the raw seed and discards 1 `nextInt()` when max is a power of two.
- BuildingComp.java:2274/2276-2277 — updateConsumption runs BEFORE updateTile.

## Implementation

- `SourceSeparatorBuildState.gd`:
  - Frame keys: progress, warmup, total_progress, seed (+ `cdump` from offload).
  - Pure `source_separator_update_tile_state(frame, ...)`; advance runs after the consumption fold, only when enabled.
  - **Random pick PORTED faithfully (not deferred).** Worker verified `SourceMathState.random_seed_int` is NOT faithful to Arc: it seeds a single-state murmur chain with `seed * 99999` (the float-overload seeding) and masks in the power-of-two branch, while Arc seeds a 2-state xorshift128+ Rand with the raw seed and discards 1 `nextInt()` when max is a power of two. This slice ports Rand.java faithfully as a private helper in the Separator file (murmurHash3, setSeed, xorshift128+ nextLong, rejection-sampled nextLong(n), `>>>` simulated with `>>` + mask; murmur constants reused from `SourceMathDefaults`). Verified with a Python reference written 2 independent ways (direct unsigned transliteration + GDScript mirror): **1030/1030 seed/bound cases match, distribution matches weights** (copper 4185/10000 vs expected 4167). Proof pins exact values from the reference: seed 1 → titanium (separator), seed 3 → thorium (disassembler, power-of-two discard branch), seed from `Point2.pack(28,21)` = **1943898491**.
  - **consume() DONE (not deferred).** `consume()` only subtracts items via `ConsumeItems.trigger` (default multiplier 1f, clamped by `ItemModule.remove`), ported via existing `inventory.remove_item_state`. Separator def has no consumeItem → no-op; disassembler subtracts 1 scrap. Java order preserved: pick → consume → conditional offload.
  - **Bonus beyond scope: `created()` seed init is LIVE** — `tile.pos()` is `Point2.pack(x, y)`, computable from the origin cell, so the driver seeds a new frame as `created()` does instead of default 0 (pure calls still default 0).
  - craftTime/results are per-def constants (catalog only parses craftTime for the GenericCrafter family).
  - **Finding for a later slice:** `SourceMathState.random_seed_int` is unfaithful to Arc — needs an audit/fix slice if that helper is used elsewhere.

## Commits

- Slice `34861097` (worker-N2222, branch `slice/N2222-separator-update-tile`, 5 files +965/−3; đã push 16:22, remote tip 34861097).
- Integration cherry-pick `f26f7498`; SSOT gộp `bde67d63` (wave advances-1): 11470/1664/1587/2965 (slice riêng +8/+1/+1/+2 → 11443/1660/1583/2957).

## Tests

- Post-register: 3/4 PASS + proof FAIL đúng `AssertionError: unexpectedly None` (Godot-absent; `which godot` rc=1, không chạy Godot).
- SSOT: register exit 0, **+8/+1/+1/+2 → 11443/1660/1583/2957; audit totalSourceFunctions 1336, legacy 0**.
- **Exact exprs: 66**, tất cả verify verbatim (0 missing) qua mindustry + arc sources.
- **DEFERRED: 259 (258 − 2 + 3)** — REMOVE entry "Separator updateTile advance (…)" AND the bundled "created / shouldAmbientSound rows" entry (created() is now live); ADD 3 entries: timerDump dump (Separator.java:165-167 — no timer helper); offload neighbor routing (offload via `offload_item_state` with an empty routing context — no proximity acceptItem query yet — so the result always falls back into the separator's own items, which matches the Java outcome when no neighbor accepts); shouldAmbientSound row (replacing the old bundled entry).
- **Shard đổi: 4 production shards** (+297 dòng, toàn thêm mới, đúng 8 symbol N2222) + 4 file SSOT chính.
- Same-file sanity: N2169 + N2200 6/6 non-proof tests PASS (other 2 fails are their Godot-absent proofs as expected) — no regression.

## Godot proof (debt — chưa chạy, chờ agent Godot test)

- `C07SeparatorUpdateTileProof` — 6 keys: progress_advances_when_efficient, warmup_approaches_one_when_efficient, total_progress_advances_with_warmup, craft_completes_at_progress_one, offload_picks_weighted_result, live_tick_advances_progress_and_warmup (live tick also verifies the seed created from tile position). Ghi nợ trong GOAL.md §5 + handoff + STATUS.md.
