# Report N2422 — Accelerator powerBufferRequirement bar rows

**Slice:** N2422 — Accelerator setBars powerBufferRequirement bar: a
new pure-only bar pure models the gate, label amounts, color, and
raw fraction. **Wave:** advances-25. **Commit:** `7a40d42e1` on
`slice/N2422-accelerator-bar-rows` (base `e4e57bca3`). **Files:** 5.

## Source

setBars (Accelerator.java:105-109): `if(powerBufferRequirement >
0f){ addBar("powerBufferRequirement", b -> new Bar(() ->
Core.bundle.format("bar.powerbuffer",
UI.formatAmount((long)b.power.graph.getBatteryStored()),
UI.formatAmount((long)powerBufferRequirement)), () -> Pal.powerBar,
() -> b.power.graph.getBatteryStored() / powerBufferRequirement ...`.
Def: `powerBufferRequirement = 1_000_000f;` (Blocks.java:6826).
Label bundle: `bar.powerbuffer = Batteries: {0}/{1}`
(bundle.properties:1283). `Pal.powerBar = Color.valueOf("ec7b4c")`
(Pal.java:93).

## Implementation

One pure-only bar pure
`source_accelerator_power_buffer_bar_state(battery_stored,
power_buffer_requirement)` — explicit inputs, no tick wiring.
Returns `bar_present` (requirement > 0f), `label_key` bar.powerbuffer
+ raw long amounts (stored/requirement, int() = Java `(long)` cast),
`color` Pal.powerBar (symbolic token), `fraction` raw
stored/requirement, dict `bar` (empty when absent).
getBatteryStored is live battery state (N2359/N2342) — the pure takes
the value caller-supplied, never queries the power graph.

**Findings beyond the brief (all verify-first):**
1. **Bar DOES clamp** — the brief's verify-first question, answered:
   `Bar.java` clamps in both the constructor (`lastValue = value =
   Mathf.clamp(fraction.get());`) and draw (`float computed =
   Mathf.clamp(fraction.get());`); `Mathf.clamp(float)` → [0,1] (arc
   Mathf.java:402-404). The pure returns the RAW fraction + a note
   (stored 1.5M/1M → 1.5, Bar draws full).
2. **UI.formatAmount is complex** (mindustry/core/UI.java:781-800):
   magnitude suffixes + `[gray]` markup from bundle
   billions/millions/thousands + infinity guards (Long.MAX/MIN →
   ∞). The pure returns raw longs; the formatted string is a UI
   concern, not invented — and NO new DEFERRED entry was added for
   it (the bar entry resolves fully for the pure).
3. **Java spacing quirk line 107:**
   `format("bar.powerbuffer",UI.formatAmount(...),  UI.formatAmount(...))`
   — no space after the first comma, TWO spaces before the second UI;
   kept verbatim in EXACT_EXPRS + driver comment + proof.
4. **Absent-default (port choice, documented):** when requirement ≤
   0f, Java never evaluates the fraction lambda (the Bar is never
   created), so the pure returns fraction 0.0 — a documented default,
   not a Java value.

## Commits

- Slice: `7a40d42e1` (5 files).
- Integration cherry-pick: `1f85058b9` (clean).

## Tests

Targeted (new module
`tests.test_c07_accelerator_power_buffer_bar_rows`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL exactly
AssertionError: unexpectedly None — NO Godot binary on this VM (user
order 2026-11-15).
Full gate (wave advances-25 integration, PID 9433, from 17:08): Ran 6682 tests in 1574.715s, FAILED (failures=345, skipped=5), 0 errors — 345/345 Godot-absent (338 inherited + 7 new proof tests N2417-N2423; N2416/N2424 add no proof test).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+1/+2** → 12133/1838/1770/3332 (exactly as
estimated; 2 symbols: `bar_present` + `bar`). Audit stays 1336.
DEFERRED **#95 RESOLVED** (286→285, by entry TEXT; no new entry).

## Godot debt

- NEW proof `C07AcceleratorPowerBufferBarRowsProof` (6 keys:
  `bar_present_requirement_positive`,
  `bar_absent_requirement_zero`, `bar_label_amounts`,
  `bar_color_power_bar`, `bar_fraction_math` (incl. live-frame
  battery_stored 250000 → 0.25), `bar_fraction_overfull_raw`) —
  written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring).
