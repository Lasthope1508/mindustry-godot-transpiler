# Report N2417 — UnitCargoLoader bar rows

**Slice:** N2417 — UnitCargoLoader setBars "units" bar: a new pure-only
bar pure models the label, color, and fraction. **Wave:** advances-25.
**Commit:** `7b7ce3d69` on `slice/N2417-unit-cargo-loader-bar-rows`
(base `e4e57bca3`). **Files:** 5.

## Source

setBars (UnitCargoLoader.java:48-63): label `bar.unitcap` with
`Fonts.getUnicodeStr(unitType.name)`, `e.team.data().countType(unitType)`,
and `unitType.useUnitCap ? Units.getStringCap(e.team) : "∞"`; color
Pal.power; fraction `useUnitCap ? count / Units.getCap(e.team) : 1f`.

## Implementation

One pure-only pure
`source_unit_cargo_loader_bar_rows_state(unit_type_name, unit_icon,
count_type, use_unit_cap, cap)` — explicit inputs, no frame dict, no
tick wiring (bar is presentation). Returns bar name "units" + label
parts (icon/count/cap_text/text via `bar.unitcap = {0} {1}/{2}`) +
color "Pal.power" + fraction.

**Findings beyond the brief (all verify-first):**
1. **Fifth input `unit_icon`** (the brief listed 4): `Fonts.getUnicodeStr`
   looks up the runtime font-atlas `stringIcons` (Fonts.java:141/224) —
   not computable from the name; the pure takes the icon
   caller-supplied ("" when absent), parallel to the live count/cap.
2. **Cap string needs no separate input:** `getStringCap` is a pure
   function of cap (`cap >= MAX_VALUE - 1 ? "∞" : cap`).
3. **Cap = 0:** Java does NOT guard — `getCap` clamps `Math.max(0, …)`
   so cap 0 is reachable (unitCap 0); `(float)count/0` = NaN (count 0)
   / Infinity (count > 0). The pure does not guard either (GDScript
   float division by zero = inf/nan); proof key 6 verifies both.

## Commits

- Slice: `7b7ce3d69` (5 files).
- Integration cherry-pick: `bb6b0fa19` (clean).

## Tests

Targeted (new module `tests.test_c07_unit_cargo_loader_bar_rows`):
3/4 PASS (registration, exact-evidence, row-state) + proof test FAIL
exactly AssertionError: unexpectedly None — NO Godot binary on this
VM (user order 2026-11-15). All 21 EXACT_EXPRS verified verbatim
against upstream (UnitCargoLoader.java / Units.java / Fonts.java /
bundle.properties / Pal.java / Teams.java).
Full gate (wave advances-25 integration, PID 9433, from 17:08): Ran 6682 tests in 1574.715s, FAILED (failures=345, skipped=5), 0 errors — 345/345 Godot-absent (338 inherited + 7 new proof tests N2417-N2423; N2416/N2424 add no proof test).

## SSOT / DEFERRED

SSOT single-slice **+3/+1/+1/+2** → 12134/1838/1770/3332 (exactly as
estimated; 3 result symbols: bar_label, bar_color, bar_fraction).
Audit stays 1336. DEFERRED **#2 RESOLVED** (286→285, by entry TEXT;
no new entry).

## Godot debt

- NEW proof `C07UnitCargoLoaderBarRowsProof` (6 keys:
  `bar_label_parts`, `bar_cap_branch` (MAX_VALUE → "∞"),
  `bar_no_cap_branch` ("∞" + 1f), `bar_color`, `bar_fraction_math`,
  `bar_zero_cap_edge`) — written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring).
- Follow-through: no UI call site reads the bar yet (a UI slice's
  concern; no DEFERRED entry added).
