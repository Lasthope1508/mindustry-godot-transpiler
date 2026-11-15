# Report N2299 — UnitAssemblerModule acceptPayload + link Assembler gate

**Slice:** N2299 — UnitAssemblerModule acceptPayload + link Assembler gate (2 pures).
**Wave:** advances-9.
**Commit:** `48d2bd72` on `slice/N2299-unit-assembler-module-accept-payload` (base `9ca87a72`).
**Files:** 5, +1036/−1.

## Source

Module gate (UnitAssemblerModule.java:110-111 — **NOT :125-127 as DEFERRED entry 51
claimed**; :125-127 is inside `onRemoved`. The file is in `world/blocks/units/`, NOT
`payloads/`): `return link != null && this.payload == null && link.acceptPayload(this,
payload);`. Link gate (UnitAssembler.java:722-727): `(this.payload == null || (source
instanceof UnitAssemblerModuleBuild)) && plan.requirements.contains(b -> b.item ==
payload.content() && blocks.get(payload.content()) < Mathf.round(b.amount *
state.rules.unitCost(team)) - (source instanceof UnitAssemblerModuleBuild &&
(this.payload != null && this.payload.contentEquals(payload)) ? 1 : 0))`.

**Brief correction (grep-verified):** the quota does NOT go through
`java.lang.Math.round` — it goes through arc `Mathf.round` (Mathf.java:500-501,
BIG_ENOUGH trick `(int)(value + BIG_ENOUGH_ROUND) - BIG_ENOUGH_INT`, i.e.
floor(x+0.5)). The two agree on the non-negative domain, so the port's `roundi` is
correct; documented in driver comment + register docstring, test pins `roundi(2.5) == 3`.
`PayloadStack.amount` is int (PayloadStack.java:9); `PayloadSeq.get` returns 0 for
unknown keys (ObjectIntMap.java:285-286), as the brief assumed.

## Implementation

**Pure 1** `source_unit_assembler_module_accept_payload_state(has_link, has_payload,
link_accepts)` → {accepts, has_link, has_payload, link_accepts} (4 keys). **Pure 2**
`source_unit_assembler_accept_payload_state(payload, assembler, plan_requirements,
unit_cost, source_is_module)` → {accepts, requirement_found, quota, stored_count,
module_adjustment} (5 keys). Tick exposes `frame["accepts_payload"]` /
`frame["link_accepts_payload"]` AFTER the advance, and runs even when disabled
(acceptPayload does not check enabled in Java); `source_is_module` is always true
(the module calls `link.acceptPayload(this, payload)`). N2248 link/handoff wiring
untouched (the gate reads `frame["accept_payload"]`, a different key).

Design note: Java `plan.requirements.contains(...)` accepts when ANY matching
requirement passes the count check; the pure implements any-match for the verdict,
while the `quota` key reports the FIRST matching requirement's quota (every def has
1 stack/content, so the two agree in practice) — documented in driver/test/register.

Pre-existing drift (flagged, NOT fixed — out of scope): the driver header comment
cites `acceptsPayload = true;` at UnitAssemblerModule.java:27; the real line is :28.

## Commits

- Slice: `48d2bd72` (pushed, ls-remote verified).
- Integration cherry-pick: `ac19fe1c`.

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 27/27, row-state) +
proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings
(9 assembler + 18 payload-family modules): Ran 108 — 81 PASS + 27 proof fails, 0
other failures. Full gate (wave advances-9 integration, PID 13482, 03:38–03:59): Ran 6286 tests in 1229.839s, FAILED (failures=248, skipped=5), 0 errors — 248/248 Godot-absent `AssertionError: unexpectedly None` (242 inherited + 6 new proof tests N2295/N2296/N2297/N2298/N2299/N2301; N2300 adds no test).

## SSOT / DEFERRED

SSOT single-slice +9/+1/+2/+4 → 11897/1744/1679/3150; audit stays 1336 (2 pures → 2
contracts + 4 schemas). No shard changed. DEFERRED 322 (321 − 1 entry 51 resolved +
2 new: acceptPayload live fill, handoff-gate acceptPayload wiring; the
UnitAssemblerModule updateTile live fill entry reworded — acceptPayload evaluation
live from N2299, moduleFits/wasOccupied still wait).

## Godot debt

Proof `C07UnitAssemblerModuleAcceptPayloadProof` (6 keys:
`assembler_accepts_below_quota`, `assembler_rejects_at_quota`,
`live_tick_exposes_both_verdicts`, `module_accepts_when_linked_empty_link_accepts`,
`module_rejects_when_unlinked`, `module_source_minus_one_adjustment` + registry) —
written, NEVER run on this VM (no Godot binary, user order 2026-11-15). See GOAL.md §5.
