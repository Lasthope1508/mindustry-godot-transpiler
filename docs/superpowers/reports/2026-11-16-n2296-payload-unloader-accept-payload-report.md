# Report N2296 — PayloadUnloader acceptPayload + acceptItem/acceptLiquid false

**Slice:** N2296 — PayloadUnloader acceptPayload (Loader override inherited) +
acceptItem/acceptLiquid false. **Wave:** advances-9.
**Commit:** `14746b76` on `slice/N2296-payload-unloader-accept-payload` (base `9ca87a72`).
**Files:** 5, +1054/−2.

## Source

**The brief and SCOPE were WRONG about inheritance (grep-verified by the worker):**
`PayloadUnloaderBuild extends PayloadLoaderBuild` (PayloadUnloader.java:32) and
PayloadUnloader.java has NO acceptPayload override — so the Unloader inherits the
LOADER's override (PayloadLoader.java:90-101: base gate + fits + BuildPayload + 3
container branches), NOT the PayloadBlock base gate. DEFERRED entry 12's cite
("PayloadLoader.java:90-101, inherited") was CORRECT all along; the SCOPE calling it
"misleading" was the coordinator's error (the class declaration was never checked).
acceptItem / acceptLiquid are hard-coded false (PayloadUnloader.java:35-38 / :40-43 —
the brief's :40-44 was off by one, :44 is blank).

## Implementation

Pure `source_payload_unloader_accept_payload_state(has_payload, offered_payload)` →
{accept_payload, accept_item, accept_liquid} — the latter two ALWAYS false. The
offered-payload descriptor carries {is_build_payload, size (px), block:{has_items,
unloadable, item_capacity, size, has_liquids, liquid_capacity, cons_power_capacity,
cons_power_buffered}}; fits = `size()/tilesize <= 3` (Payload.java:50-52, tilesize 8,
BuildPayload.size = block.size*tilesize). Tick exposes `accepts_payload` /
`accepts_item` / `accepts_liquid` from frame input `offered_payload` (default null);
no offer → accepts FALSE (the brief's "accepts true" was a consequence of the wrong
design). N2279 live-fill, N2293 dump rows, N2209 static power untouched.

Note: pure N2296 and pure N2295 port the SAME Java method (the Loader override) for
two different drivers — duplicated logic is correct per Java, not overlap to dedup.

## Commits

- Slice: `14746b76` (pushed, ls-remote verified).
- Integration cherry-pick: `f90ebbfb`.

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 20/20, row-state) +
proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings
(payload family, 5 modules): Ran 20 — 15 PASS + 5 proof fails, 0 other failures. Full gate (wave advances-9 integration, PID 13482, 03:38–03:59): Ran 6286 tests in 1229.839s, FAILED (failures=248, skipped=5), 0 errors — 248/248 Godot-absent `AssertionError: unexpectedly None` (242 inherited + 6 new proof tests N2295/N2296/N2297/N2298/N2299/N2301; N2300 adds no test).

## SSOT / DEFERRED

SSOT single-slice +3/+1/+1/+2 → 11891/1744/1678/3148; audit stays 1336. Shards:
`payload_slices`, `payload_api_contracts`. DEFERRED 323 (321 − 1 entry 12 resolved +
3 new: intake-guard wiring, live offered source, descriptor unification).

## Godot debt

Proof `C07PayloadUnloaderAcceptPayloadProof` (6 keys:
`accept_item_always_false`, `accept_liquid_always_false`,
`accepts_container_when_empty`, `live_tick_exposes_all_three_verdicts`,
`rejects_non_container_payload`, `rejects_when_payload_present` + registry) —
written, NEVER run on this VM (no Godot binary, user order 2026-11-15). See GOAL.md §5.
