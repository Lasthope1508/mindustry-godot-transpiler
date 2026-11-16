# Report N2336 — MassDriver acceptItem gate

**Slice:** N2336 — MassDriver acceptItem gate (`items.total() < itemCapacity
&& linkValid()`; frame `accepts_item` verdict). **Wave:** advances-14.
**Commit:** `53c313e0` on `slice/N2336-mass-driver-accept-item` (base `f3f7af8e`).
**Files:** 5, +939/−2.

## Source

Java: `acceptItem` (MassDriver.java:285-288, comment :286 + return :287):
`items.total() < itemCapacity && linkValid()`; `linkValid` (:346-349, guard
:347 + return :348): `link == -1` → false; `world.build(link)` must be a
MassDriverBuild with the same block, same team, and `within(other, range)`.
`within` is STRICT dst2 < dst² (Position.java:44-46). Single def, range 440f
/ itemCapacity 120 (Blocks.java:2170/2172); no large-mass-driver def. All
brief cites checked out — no scope corrections.

## Implementation

New pure `source_mass_driver_accept_item_state(frame, item_capacity, linked)`
→ `{accepts}` (capacity term + linkValid), private helper
`_mass_driver_link_valid` mirroring the N2237 advance's has_link conjunction.
The tick stamps `frame["accepts_item"]` every tick after the dump write-back
(N2295 Loader acceptPayload precedent); `_initial_frame` gains
`"accepts_item": false`; Documented limits (6) records acceptItem live.

**Refinements:** (1) the brief's "frame link_partner dict" is the `linked`
dict the tick **already gathers** for the N2237 advance — the pure reuses it
verbatim, no new partner dict or frame key beyond the stamped verdict;
(2) the driver has no intake path calling acceptItem (only the N2294 dump's
neighbour arrays), so per the N2295/N2297/N2298 precedent the verdict stamp
is wired into the tick rather than leaving the pure unwired — no invented
call site, just the established frame-verdict pattern. The N2237 advance
call string and N2294 dump call string are untouched (both pinned by their
tests).

## Commits

- Slice: `53c313e0` (5 files, +939/−2).
- Integration cherry-pick: `0d03ab0b` (clean).

## Tests

Targeted (new module `tests.test_c07_mass_driver_accept_item`): 3/4
PASS + proof test FAIL exactly AssertionError: unexpectedly None — NO
Godot binary on this VM (user order 2026-11-15). Exact-evidence 12/12.
Siblings (MassDriver power_status + update_tile + dump): 9/12 PASS, only the
3 proof tests failing, all exactly `AssertionError: unexpectedly None`.
Full gate (wave advances-14 integration, PID 11801, 07:14–07:36): Ran 6394 tests in 1305.500s, FAILED (failures=275, skipped=5), 0 errors — 275/275 Godot-absent `AssertionError: unexpectedly None` (268 inherited + 7 new proof tests N2330–N2336).

## SSOT / DEFERRED

SSOT single-slice **+1/+1/+1/+2** → 11961/1770/1702/3196 (exactly the SCOPE
estimate): symbol `source_mass_driver_accept_item_state_result.accepts`;
2 new schemas (input + result); 4 generated files touched by the register
(registry/ledger/contracts/schema), no shard changes; audit stays 1336.
DEFERRED 329→329 net 0 (resolved #58 `MassDriver acceptItem rows`, added 1
new: `MassDriver frame items intake` — no live intake fills `frame["items"]`
yet and no live neighbour reads the stamped verdict; distinct from existing
#294/#295 dump-neighbour entries).

## Godot debt

- NEW proof `C07MassDriverAcceptItemProof` (6 keys:
  `accepts_when_linked_and_room`, `rejects_when_full`,
  `rejects_when_unlinked`, `rejects_when_partner_wrong_block`,
  `rejects_when_partner_wrong_team`, `rejects_when_partner_out_of_range`)
  — written but NEVER run; debt in GOAL.md §5. Live-tick checks fold into
  the first three keys (linked pair stamps true, full store stamps false,
  unlinked stamps false).
