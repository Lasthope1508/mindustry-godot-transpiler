# Report N2298 — PayloadMassDriver acceptPayload

**Slice:** N2298 — PayloadMassDriver acceptPayload (base gate + size fits).
**Wave:** advances-9.
**Commit:** `ea7c5609` on `slice/N2298-payload-mass-driver-accept-payload` (base `9ca87a72`).
**Files:** 5, +873/−1.

## Source

`PayloadMassDriverBuild.acceptPayload` (PayloadMassDriver.java:462-463):
`return super.acceptPayload(source, payload) && payload.size() <= maxPayloadSize *
tilesize;`. **DEFERRED entry 10's cite (:317-319) was WRONG** — that range is
shoot/reset code (`other.waitingShooters.removeFirst();` / `other.state = idle;`),
confirmed by the worker as the brief warned. `super.acceptPayload` =
`return this.payload == null;` (PayloadBlock.java:116-118). `maxPayloadSize = 3`
(PayloadMassDriver.java:30). tilesize = 8 (Vars.java:135) → threshold 24.
`BuildPayload.size()` = `build.block.size * tilesize` (:86-88).

## Implementation

Pure `source_payload_mass_driver_accept_payload_state(payload_size, has_payload)` →
{accepts, size_fits, threshold} (3 keys); threshold = 3 × 8 = 24
(`SourceWorldDefaults.TILESIZE`, Loader/Unloader/Deconstructor precedent). Const
`SOURCE_PAYLOAD_MASS_DRIVER_MAX_PAYLOAD_SIZE := 3.0`. Driver wiring in
`tick_buildings_state` AFTER the N2246 branches (the verdict reads post-tick payload —
a payload that just transferred out opens the gate in the same tick), from frame input
`offered_payload_size`; no offer → `accepts_payload = false`. N2245/N2246 wiring and
the N2294 dump gate untouched.

**New finding (not in the brief):** threshold 24 (class default) is NOT Java behavior
for either real def — both override `maxPayloadSize` (2.5f → threshold 20, 4f →
threshold 32, Blocks.java:6624/6636). The pure follows the brief (class default, proof
pins boundary 24); the deviation is a new DEFERRED entry — a per-def threshold slice
(or a `max_payload_size` param) is needed for Java-exactness on both defs.

## Commits

- Slice: `ea7c5609` (pushed, ls-remote verified).
- Integration cherry-pick: `81789d53`.

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 12/12, row-state) +
proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings
(payload family, 21 modules): Ran 84 — 63 PASS + 21 proof fails, 0 other failures. Full gate (wave advances-9 integration, PID 13482, 03:38–03:59): Ran 6286 tests in 1229.839s, FAILED (failures=248, skipped=5), 0 errors — 248/248 Godot-absent `AssertionError: unexpectedly None` (242 inherited + 6 new proof tests N2295/N2296/N2297/N2298/N2299/N2301; N2300 adds no test).

## SSOT / DEFERRED

SSOT single-slice +3/+1/+1/+2 → 11891/1744/1678/3148; audit stays 1336. Shards:
`payload_api_contracts.json`, `payload_slices.json`. DEFERRED 321 (321 − 1 entry 10
resolved + 1 new: per-def maxPayloadSize override).

## Godot debt

Proof `C07PayloadMassDriverAcceptPayloadProof` (6 keys:
`accepts_when_empty_and_size_fits`, `boundary_size_24_accepted`,
`live_tick_exposes_verdict`, `no_payload_offered_false`, `rejects_oversize`,
`rejects_when_payload_present` + registry) — written, NEVER run on this VM (no Godot
binary, user order 2026-11-15). See GOAL.md §5.
