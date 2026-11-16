# Report N2325 — RegenProjector mendMap flush

**Slice:** N2325 — RegenProjector mendMap flush (the advance reports
heal_applications + clears the map + stamps last_update_frame on a new
update id; the live heal application to target buildings still defers).
**Wave:** advances-13.
**Commit:** `7cd2d224` on `slice/N2325-regen-projector-update-tile` (base
`4349a660`).
**Files:** 6, +1032/−45.

## Source

⚠️ **SCOPE PREMISE WAS WRONG** — the RegenProjector updateTile advance
already existed from N2228 (741652ea) and the consume rows were live from
N2260 (hydrogen required + phaseFabric booster); the scope asked for a
"full advance" that was already there. N2325 is only the **mendMap flush**:
`if(lastUpdateFrame != state.updateId){ lastUpdateFrame = state.updateId;
for(var entry : mendMap.entries()){ ... build.heal(entry.value); ...
mendMap.clear(); } }` (RegenProjector.java:166–177). `mendMap` is a
static-shared map (RegenProjector.java:23) and `lastUpdateFrame` a static
long defaulting to −1 (:24); `updateId` is `public long updateId;`
(GameState.java:23), incremented once per logic update (`state.updateId
++;`, Logic.java:512). The flush sits OUTSIDE the efficiency gate
(`if(efficiency > 0){`, RegenProjector.java:142) — it fires even at
efficiency 0 — and a suppressed tick does not flush. Lesson recorded in
STATUS.md: **scope must verify the real driver, not trust DEFERRED
blindly** (same class as the stale PMD charge/reload entry).

## Implementation

The advance reports the whole mend_map as `heal_applications` + clears it
+ stamps `last_update_frame` when the frame `last_update_frame` (default
−1) differs from the frame `update_id` (default 0); the tick write-backs
the flushed amounts on the frame and applies nothing to the target
buildings yet (live heal application defers). Schema/contract N2228
extended in place 9→11 keys (the flush keys ride the existing advance
contract — no new contract).

**Follow-through (N2228 proof, 6th file):** the 7 accumulation calls seed
`last_update_frame` 0 / `update_id` 0; the live-tick key was REWRITTEN
with a damaged copper-wall neighbour + hydrogen 1.0 + 1 phaseFabric — that
key was ALREADY stale before N2325 (same nitrogen/liquid-seed class as
N2323). The N2228 proof header was still wrong ("consume() defers" —
wrong since N2260); the coordinator fixed it at integration (ded46b85,
comment-only, no new re-run).

## Commits

- Slice: `7cd2d224` (6 files, +1032/−45).
- Integration cherry-pick: `9a87653a` (clean).

## Tests

Targeted (new module `tests.test_c07_regen_projector_mend_map_flush`): 3/4
PASS + proof test FAIL exactly AssertionError: unexpectedly None — NO
Godot binary on this VM (user order 2026-11-15). Exact-evidence 19/19.
Siblings Ran 24 = 18 PASS + 6 proof, 0 other failures.
Full gate (wave advances-13 integration, PID 4634, 06:38–07:02): Ran 6366 tests in 1287.324s, FAILED (failures=268, skipped=5), 0 errors — 268/268 Godot-absent `AssertionError: unexpectedly None` (262 inherited + 6 new proof tests N2324–N2329; N2323 adds no test).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+0/+0** → 11951/1764/1695/3182 (NOT the +8 SCOPE
estimate — the advance already existed from N2228; schema/contract N2228
extended in place 9→11 keys); audit stays 1336. DEFERRED 325→327 (+2: #163
rewritten in place + 2 new entries).

## Godot debt

- NEW proof `C07RegenProjectorMendMapFlushProof` (**5 keys**:
  `mend_map_flushes_on_new_frame`, `no_flush_when_frame_unchanged`,
  `flush_fires_without_efficiency`, `suppression_blocks_flush`,
  `live_tick_flushes_mend_map`) — written but NEVER run; debt in GOAL.md
  §5.
- RE-RUN of N2228 proof `C07RegenProjectorUpdateTileProof` (live-tick key
  rewritten + accumulation seeds changed) — never run; debt in GOAL.md §5.
