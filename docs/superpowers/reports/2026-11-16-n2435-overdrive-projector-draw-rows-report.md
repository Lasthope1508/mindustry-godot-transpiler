# Report N2435 — OverdriveProjector draw / drawLight / drawSelect / drawPlace rows

**Slice:** N2435 — OverdriveProjector draw() + drawLight() +
drawSelect() + drawPlace(): a new pure-only draw pure models the
base/top/ring, the efficiency-scaled light, and the select/place
dash circles with their selected blocks. **Wave:** advances-27.
**Commit:** `15d176833` on
`slice/N2435-overdrive-projector-draw-rows` (base `91ee0f1dc`).
**Files:** 5, +1175/−1.

## Source

drawPlace (OverdriveProjector.java:54-61): super.drawPlace +
Drawf.dashCircle(x*tilesize + offset, y*tilesize + offset, range,
baseColor) + indexer.eachBlock (canOverdrive → Drawf.selected with
absin(4f, 1f) alpha). drawLight (:92-94): Drawf.light(x, y,
lightRadius * smoothEfficiency, baseColor, 0.7f * smoothEfficiency).
drawSelect (:128-133): realRange = range + phaseHeat *
phaseRangeBoost; eachBlock selected (absin 4f, 1f); dashCircle(x, y,
realRange, baseColor). draw() (:137-158): super.draw(); if !Lod.l2
return; f = 1 − (Time.time / 100f) % 1f; color(baseColor, phaseColor,
phaseHeat); alpha(heat * absin(Time.time, 50f / PI2, 1f) * 0.5f *
Lod.alpha2); rect(topRegion, x, y); alpha(Lod.alpha2); stroke((2f*f
+ 0.1f) * heat); the ring line loop (4 points, extra points when f <
0.5f).

## Implementation

One pure-only draw pure `source_overdrive_projector_draw_rows_state`
— 6 result symbols: `base_call`, `top_call`, `ring_call`,
`light_call`, `select_call`, `place_call`.

**Findings beyond the brief (all verify-first):**
1. **The pure is renamed vs the brief:** the brief/SCOPE name
   `source_overdrive_projector_draw_state` already belongs to the
   old display path N726 (`PortGame.source_overdrive_projector_draw_state`)
   and `upsert_source_state_schema` REPLACES the whole entry —
   using the brief name would break the N726 schemas + the pins in
   `test_source_symbols.py`. The worker named it
   `source_overdrive_projector_draw_rows_state`, exactly the N2372
   (MendProjector) precedent for the same reason, and verified the
   N726 schemas intact after the register run. **Systemic lesson
   for later briefs: check the pure name against the schema
   registry (old PortGame.* display path) for collisions before
   naming it.**
2. **SSOT +6, not +7 as estimated:** verify-first confirmed
   OverdriveProjector has NO `icons()` override (no line with
   "icon" in the Java file) → no `icon_regions` key (the N2429
   ItemBridge precedent). The brief's 7th key was that conditional
   one.
3. **f is computed AFTER the Lod guard** (:140 before :142 — the
   inverse of MendProjector): the pure reports `f = 0.0` when
   !lod_l2, top/ring calls empty, the draw scalars 0 (the display
   state N726 precedent); `base_call` is still recorded because
   `super.draw()` runs before the guard; light/select/place are
   not gated.
4. Ring points hand-verified: f=0.5 → 4 points r=7.3/w=0; f=0.25
   → 8 points r=7.55/w=4.0. Absin double-scale at both sites
   (100f/PI2 for draw, 8f for the 2-arg select/place). The
   drawPlace offset is computed from size per Block.java:761 (4
   for size 2, 0 for size 3/dome).

## Commits

- Slice: `15d176833` (5 files, +1175/−1).
- Integration cherry-pick: `19064f166` (clean).

## Tests

Targeted (new module
`tests.test_c07_overdrive_projector_draw_rows`): 3/4 PASS
(registration, exact-evidence 54/54 exprs verbatim, row-state) +
proof test FAIL exactly AssertionError: unexpectedly None — NO
Godot binary on this VM (user order 2026-11-15). RED confirmed
first (Ran 4: failures=2, errors=2).
Full gate (wave advances-27 integration, PID 4530, from 19:02): Ran 6738 tests in 1537.145s, FAILED (failures=359, skipped=5), 0 errors — 359/359 Godot-absent (352 inherited + 7 new proof tests N2433–N2439; Ran 6738 = 6710 + 28 new tests, exact arithmetic). Gate run 1 (PID 2236) invalid — VM restart #14 wiped javalang (Ran 6055, errors=15, all javalang-import).

## SSOT / DEFERRED

SSOT single-slice **+6/+1/+1/+2** → 12224/1852/1786/3364
(**variance vs the +7 estimate:** no icons() override → no
icon_regions key). Shards changed: `defense_api_contracts.json` +
`defense_slices.json`. No manifest drift. DEFERRED **#141
RESOLVED** (273→272, by entry TEXT; no new entry).

## Godot debt

- NEW proof `C07OverdriveProjectorDrawRowsProof` (6 keys:
  `draw_f_top`, `draw_ring_points`, `draw_lod_gate`, `draw_light`,
  `draw_select`, `draw_place` — no icons, so the draw splits into
  two keys) — written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring).
