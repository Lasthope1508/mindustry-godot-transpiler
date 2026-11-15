# Report N2314 — UnitAssemblerModule handoff-gate wiring

**Slice:** N2314 — UAM handoff-gate wiring (link verdict feeds the N2248 gate). **Wave:** advances-11.
**Commit:** `cbdce965` on `slice/N2314-uam-handoff-gate` (base `18dcabf2`).
**Files:** 6, +905/−45.

## Source

The handoff gate is `link.acceptPayload(this, payload)`
(UnitAssemblerModule.java:137–139 — the full if spans :137–139; the condition
is :138), i.e. the ASSEMBLER's gate (UnitAssembler.java:722-727), NOT the
module's own gate (:110-111). The N2299 tick stamps verdicts AFTER the advance
(:449–452 vs :416), while the N2248 handoff gate reads `frame["accept_payload"]`
as an explicit predicate input. The worker confirmed the LINK verdict from Java
independently (the brief said :138; the if spans :137–139).

## Implementation

The link verdict evaluates BEFORE the advance and stamps
`frame["accept_payload"]` from it (frame-stamp, N2235 precedent); the module
verdict still runs AFTER the advance (from post-advance link/payload). The test
pins ordering by string index (link call < advance call < module call). N2299
pins its tick-call string verbatim (preserved), N2248 pins its advance call
string (unchanged) — no N2299/N2248 test file needed changes.

**The N2248 fixture DID need the seed** — the worker removed the seeded
`accept_payload=true` (the tick overwrites it with the verdict — false without
an offer — so the key would fail) and added `offered_payload {router}` +
assembler (empty, 0 stored) + `plan_requirements [{router, 5}]` + `unit_cost
1.0` → TRUE verdict; key assertion unchanged. → N2248 proof becomes a RE-RUN.
N2299 proof untouched (live tick holds no payload, nothing hands off either
way); one comment line in the N2299 proof was wording-stale but behaviour-true
— the coordinator fixed it at integration (commit `b9ca6d7e`, c36b0563
precedent).

## Commits

- Slice: `cbdce965` (6 files, +905/−45).
- Integration cherry-pick: `06f48adf` (clean).

## Tests

Targeted (new module `tests.test_c07_unit_assembler_module_handoff_gate`): 3/4 PASS
+ proof test FAIL exactly AssertionError: unexpectedly None — NO Godot binary on
this VM (user order 2026-11-15). RED before GREEN, N2308 pattern.
Exact-evidence 15/15. Siblings Ran 36 = 27 PASS + 9 proof, 0 other failures.
Full gate (wave advances-11 integration, PID 7620, 05:08–05:30): Ran 6314 tests in 1275.835s, FAILED (failures=255, skipped=5), 0 errors — 255/255 Godot-absent `AssertionError: unexpectedly None` (252 inherited + 3 new proof tests N2313/N2314/N2315; N2309/N2310/N2311/N2312 add no test).

## SSOT / DEFERRED

SSOT single-slice **+0/+1/+0/+0** → 11933/1754/1688/3168: ledger entry with
`godot_owner` = the N2299 link pure, `source_symbols` = its 5 result symbols
(accepts / requirement_found / quota / stored_count / module_adjustment —
shared ownership; the validator only requires a non-empty list). No new pure,
no new symbol/schema/contract. DEFERRED 324 (325 − 1 handoff-gate entry #318
resolved + 0 new).

## Godot debt

- NEW proof `C07UnitAssemblerModuleHandoffGateProof` (6 keys:
  `handoff_fires_when_link_accepts`, `handoff_blocked_when_link_rejects`,
  `handoff_blocked_without_link`, `live_tick_wires_the_gate`,
  `module_verdict_does_not_drive_gate`, `handoff_blocked_when_efficiency_zero`)
  — written but NEVER run; debt in GOAL.md §5.
- RE-RUN of proof N2248 (`C07UnitAssemblerModuleUpdateTileProof`) — the
  fixture changed (seed replaced by a live offer); recorded as a re-run note
  on the N2248 §5 entry.
