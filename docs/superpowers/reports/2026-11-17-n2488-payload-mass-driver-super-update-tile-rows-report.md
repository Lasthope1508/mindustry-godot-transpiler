# Report N2488 — PayloadMassDriver super.updateTile rows

**Slice:** N2488 — PayloadMassDriver super.updateTile payload
update rows (DEFERRED #131). **Wave:** advances-34. **Commit:**
`baf1eb7df` on `slice/N2488-payload-mass-driver-super-update-tile-rows`
(base `ad308cf7e`). **Files:** 5, +816/−2.

## Source

PayloadBlock.java (core/src/mindustry/world/blocks/payloads/):
the call site :158-162 (`public void updateTile(){` with
`if(payload != null){` then `payload.update(null, this);` —
the null check is the ONLY gate on the call itself). Payload is
an INTERFACE (`public interface Payload extends Position{`,
Payload.java:15); update is a DEFAULT no-op (`default void
update(@Nullable Unit unitHolder, @Nullable Building
buildingHolder){}`, Payload.java:42). The only two
implementations in the whole upstream are BuildPayload
(`public class BuildPayload implements Payload{`,
BuildPayload.java:16) and UnitPayload (`public class
UnitPayload implements Payload{`, UnitPayload.java:22).
BuildPayload.update (:52-57) gates on `if(unitHolder != null &&
(!build.block.updateInUnits || (!state.rules.unitPayloadUpdate
&& !build.block.alwaysUpdateInUnits))) return;` — with
unitHolder == null (the PMD ALWAYS passes null) the gate
short-circuits, so the call ALWAYS runs for a non-null payload.
UnitPayload.update (:51-53) delegates: `unit.type.
updatePayload(unit, unitHolder, buildingHolder);`.

## Implementation

One pure-only CALL record (the N2471 Loader precedent, the
N2396 record-the-call precedent): `source_payload_mass_driver_payload_update_state(payload)`
→ {payload_update_call} — null when the payload is null, else
{method: "payload.update", unit_holder: null, building_holder:
"self", payload_kind}. NO tick wiring: the N2245 advance still
skips the call. The N2471 Loader pure and its proof are NOT
amended; each driver owns its pures. The pure takes no gate
inputs at all: the call is unconditional on payload non-null.

**Verify-first findings:**
- **The PMD generic is NOT BuildPayload** — `public class
  PayloadDriverBuild extends PayloadBlockBuild<Payload>
  implements RotBlock{` (PayloadMassDriver.java:132), so T is
  the Payload interface itself and BOTH kinds are genuinely
  possible in Java (acceptPayload, PayloadMassDriver.java:
  462-463, has no instanceof check, only the size gate). The
  "BuildPayload" default for a kind-less dict is therefore
  the N2471 PORT convention, not a Java-exact generic
  default — recorded in the pure comment, register, test,
  and proof.
- Payload.update is a DEFAULT no-op and the two overrides are
  ENTITY behaviour (a live inner building / unit) the port
  cannot model — there is no live payload entity — so the
  N2245 advance notes the call and advances only the driver
  frame.
- The PMD contract carries no kind key, only "size" in world
  units (N2245).

## Commits

- Slice: `baf1eb7df` (5 files, +816/−2).
- Integration cherry-pick: `6352c89bb` (clean).

## Tests

Targeted (new module
`tests.test_c07_payload_mass_driver_super_update_tile_rows`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL exactly
AssertionError: unexpectedly None — NO Godot binary on this VM (user
order 2026-11-15). Neighbours (8 PMD modules + the N2471 Loader
module) Ran 37 (28 PASS + 9 proof Godot-absent), 0 errors.
Full gate (wave advances-34 integration): run 1 (PID 16663, from 02:12) KILLED by VM restart #18 ~02:32 (no footer); run 2 (PID 1769, 02:33–03:08): Ran 6930 tests in 1643.573s, FAILED (failures=407, skipped=5), 0 errors — 407/407 Godot-absent (400 inherited + 7 new proof tests N2484–N2490; Ran 6930 = 6902 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+1/+1/+1/+2 → 12402/1899/1853/3498** (exactly as
estimated). DEFERRED **#131 RESOLVED** (231→230, by entry TEXT —
this is the generic entry N2471 deliberately left alone;
neighbours #130/#132 stay).

## Godot debt

- NEW proof `C07PayloadMassDriverSuperUpdateTileRowsProof` (6
  keys: `update_call_build`, `update_call_unit`,
  `update_null`, `update_kind`, `update_holders`,
  `update_live_input`) — written but NEVER run; debt in
  GOAL.md §5.
- No old proof needs a re-run.
