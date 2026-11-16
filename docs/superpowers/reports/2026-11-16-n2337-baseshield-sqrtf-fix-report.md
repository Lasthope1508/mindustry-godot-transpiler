# Report N2337 — BaseShield sqrtf() → sqrt() (first real Godot error)

**Slice:** N2337 — BaseShield `sqrtf()` → `sqrt()` fix (first REAL Godot error,
found by the user running real Godot 4.6.2 via MCP — NOT Godot-absent).
**Wave:** advances-15. **Commit:** `829f813f` on
`slice/N2337-baseshield-sqrtf-fix` (base `f3f7af8e`, the docs tip the user's
Godot side is on). **Files:** 2, +37/−2.

## Source

Java: `dst` = `Mathf.sqrt(dx*dx + dy*dy)` (BaseShield.java:40,
Position.java:28-32, Mathf.java:180-182). GDScript has NO `sqrtf()` — the
global is `sqrt()`. The bug was at `SourceBaseShieldBuildState.gd:121`
(`var unit_dst: float = sqrtf(unit_dx * unit_dx + unit_dy * unit_dy)`), in
the enemy-unit scan loop (repel/instakill), from commit `ff8f6220`, slice
N2236 (wave advances-4). `sqrtf` appeared exactly ONCE in all `.gd`; the
transpiler tools contain no `sqrtf` — not a transpiler-system bug, a
one-point bug.

## Implementation

One-line fix: `sqrtf(` → `sqrt(` at :121; the dst formula is unchanged
(Java-exact). The old N2236 test PINNED THE BUG
(`assertIn('sqrtf(...)')`) — fixed to `sqrt(...)`; a passing test does not
prove the GDScript parses. Durable sweep test
`test_no_c_style_float_math_functions_in_gdscript` added (regex over 15
nonexistent C-style `*f(` functions across all `.gd`, excluding legit
`clampf/minf/maxf/absf/lerpf/floorf/ceilf`). Sweep re-run: ONLY sqrtf at
:121 (now fixed); sinf/cosf/tanf/powf/expf/logf/... = 0 hits.

## Commits

- Slice: `829f813f` (2 files, +37/−2).
- Integration cherry-pick: `1fb94f4b` (clean).

## Tests

Targeted (BaseShield family): Ran 13 = 10 PASS + 3 proof Godot-absent, 0
other errors; `test_c07_base_shield_update_tile` 4/5 (the added sweep pin
is the 5th test). RED confirmed (2 pins failed before the fix).
Full gate (wave advances-15 integration, PID 1755, 08:31–08:52): Ran 6415 tests in 1285.515s, FAILED (failures=280, skipped=5), 0 errors — 280/280 Godot-absent `AssertionError: unexpectedly None` (275 inherited + 5 new proof tests N2338/N2339/N2340/N2342/N2343).

## SSOT / DEFERRED

SSOT **+0** (fix slice, no register, no ledger entry). DEFERRED net 0 (no
register). Audit stays 1336.

## Godot debt

- NO new proof. **RE-RUN required:** proofs N2236 (BaseShield updateTile)
  and N2328 (BaseShield scans) were BLOCKED on the parse error — re-run
  both on Godot 4.6.2 after this fix (the user can pull
  `slice/N2337-baseshield-sqrtf-fix` and re-run immediately; no need to
  wait for advances-15 integration). Recorded as re-run notes on the
  existing GOAL.md §5 entries.
