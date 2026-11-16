# Report N2429 — ItemBridge warmup / draw rows

**Slice:** N2429 — ItemBridge draw() + drawSelect + drawInput +
drawConfigure + the draw warmup: a new pure-only draw pure models
the warmup, the linked/unlinked draw, the arrows, the pulse, and
the select/input/configure calls. **Wave:** advances-26. **Commit:**
`78a72b08a` on `slice/N2429-item-bridge-draw-rows` (base
`cc1fe2ed0`). **Files:** 5, +1318/−1.

## Source

draw() (ItemBridge.java:345-420): the warmup approach (`float
warmup = hasPower ? ...` :345) is updateTile logic, live since
N2225 — NOT ported here. The draw itself: base rect + the dist
computation + the arrows loop (Lod.l1, :404-419) + the pulse color
branch (`pulse` field, :34). drawSelect (:223-250), drawInput
(:251-282), drawConfigure (:283-296 — the tap handler is live since
N2197; only the draw rows are new here). playerPlaced (:216-221)
live since N2199.

## Implementation

One pure-only draw pure `source_item_bridge_draw_state` (27 inputs
caller-supplied, pure-only, the tick does not call it) + 2 private
helpers (`_item_bridge_absolute_relative_to`,
`_item_bridge_draw_input_call`, no separate symbol) — 7 result
symbols: `warmup_value`, `draw_call`, `arrow_calls`, `pulse_call`,
`select_call`, `input_call`, `configure_call`.

**Overlap verdict (verify-first): #109 ⊆ #57 — CONFIRMED.** Both
entries cover the same draw family and differ only in cite range;
both resolve in this slice. The non-draw parts of #57 were already
live: the warmup approach :345 is updateTile (live N2225), the
playerPlaced tail :216-221 is live N2199, onConfigureBuildTapped
:283-296 is live N2197.

**Findings beyond the brief:**
1. **Both entries under-cite draw()**: only to :394, missing dist
   + the arrows Lod.l1 loop (:404-419). This slice ports the full
   draw() to :420.
2. **No icons() override** — the whole ItemBridge.java contains no
   line with "icon" — so there is no icons key (the brief had
   provisioned for this case).
3. **`moveArrows` is a dead field** — declared :34, nothing in
   draw() reads it. Not ported, not deferred (nothing to port).
4. **`pulse = true` at the phase-conveyor def** (Blocks.java:2124;
   class default false) — the pulse color branch is live, ported +
   proof-pinned (t = 0.035 at Time.time 0).
5. **Def-field cite line numbers in the old driver docstring are
   off by +1** (e.g. fadeIn is actually :33, the old docstring says
   :34). The new cites in this slice use the verified numbers; the
   old cites were not touched.
6. `warmup_value` is reported even when the draw is skipped (the
   gate lives in `draw_call` null) — intentional, recorded in the
   register rule.
7. The N2372 lesson (absin passed at double scale) applies at all
   3 absin sites; the epsilon `Mathf.zero` (1e-6) is pinned in the
   proof (0.0000005 → skip, 0.000002 → draw).
8. No `sqrtf` (uses `sqrt`); no duplicate `var` in the new
   functions; no other test pins the old docstring sentence.

## Commits

- Slice: `78a72b08a` (5 files, +1318/−1).
- Integration cherry-pick: `8f839bbea` (clean).

## Tests

Targeted (new module `tests.test_c07_item_bridge_draw_rows`): 3/4
PASS (registration, exact-evidence, row-state) + proof test FAIL
exactly AssertionError: unexpectedly None — NO Godot binary on this
VM (user order 2026-11-15). RED confirmed first (2 errors KeyError
`N2429` + row-state fail + proof Godot-absent).
Full gate (wave advances-26 integration, PID 16270, from 17:50): Ran 6710 tests in 1603.985s, FAILED (failures=352, skipped=5), 0 errors — 352/352 Godot-absent (345 inherited + 7 new proof tests N2425–N2431; N2432 adds no proof test; Ran 6710 = 6682 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+7/+1/+1/+2** → 12178/1845/1778/3348 (exactly
as estimated). Audit stays 1336. DEFERRED **#57 + #109 RESOLVED**
(280→278, by entry TEXT; no new entry).

## Godot debt

- NEW proof `C07ItemBridgeDrawRowsProof` (6 keys: `draw_warmup`,
  `draw_linked`, `draw_unlinked`, `draw_select`, `draw_configure`,
  `draw_input`) — written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring).
