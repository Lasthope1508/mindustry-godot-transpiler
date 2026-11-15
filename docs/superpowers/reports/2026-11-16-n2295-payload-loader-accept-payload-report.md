# Report N2295 — PayloadLoader acceptPayload

**Slice:** N2295 — PayloadLoader acceptPayload consult gate. **Wave:** advances-9.
**Commit:** `762ff9a1` on `slice/N2295-payload-loader-accept-payload` (base `9ca87a72`).
**Files:** 5, +906/−2.

## Source

`PayloadLoaderBuild.acceptPayload` (PayloadLoader.java:90-101): base gate
(`super.acceptPayload` = `this.payload == null`, PayloadBlock.java:116-118) AND
`payload.fits(maxBlockSize)` AND `instanceof BuildPayload` AND one of three container
branches — item container (hasItems && unloadable && itemCapacity >= 10 && size <=
maxBlockSize), liquid container (hasLiquids && liquidCapacity >= 10f), battery
(consPower != null && buffered). `maxBlockSize = 3` (PayloadLoader.java:25).
`Payload.fits` is `size() / tilesize <= s` (Payload.java:50-52) and `BuildPayload.size()`
is `build.block.size * tilesize` (BuildPayload.java:86-88) — so fits = size <=
maxBlockSize is Java-exact for BuildPayload.

## Implementation

Pure `source_payload_loader_accept_payload_state(payload, has_payload)` →
{accepts, fits, is_item_container, is_liquid_container, is_battery} (5 keys).
The payload descriptor carries 9 keys (is_build_payload, block_size, has_items,
unloadable, item_capacity, has_liquids, liquid_capacity, has_cons_power,
cons_power_buffered); missing keys default to the rejecting value, so a partial
fixture never accepts. Tick stamps `frame["accepts_payload"]` from
`frame["offered_payload"]` BEFORE the N2278 intake (acceptPayload is consulted before
handlePayload). N2278 intake and N2270 power rows untouched.

Nuance (documented in the driver docstring, not a deviation): for a non-build payload
Java's fits uses `UnitPayload.size()` = `unit.hitSize`, which the descriptor doesn't
carry — the pure reads descriptor `block_size` for fits, but the verdict rejects
regardless via the instanceof gate, so the fits value is inert there.

## Commits

- Slice: `762ff9a1` (pushed, ls-remote verified).
- Integration cherry-pick: `462e1110`.

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 22/22, row-state) +
proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings
(payload family: Loader ×5, Unloader ×5, Deconstructor ×5, PMD ×3): Ran 72 — 54 PASS +
18 proof fails, 0 other failures. Full gate (wave advances-9 integration, PID 13482, 03:38–03:59): Ran 6286 tests in 1229.839s, FAILED (failures=248, skipped=5), 0 errors — 248/248 Godot-absent `AssertionError: unexpectedly None` (242 inherited + 6 new proof tests N2295/N2296/N2297/N2298/N2299/N2301; N2300 adds no test).

## SSOT / DEFERRED

SSOT single-slice +5/+1/+1/+2 → 11893/1744/1678/3148; audit stays 1336. Shards:
`payload_api_contracts.json`, `payload_slices.json`. DEFERRED 322 (321 − 1 entry 161
resolved + 2 new: offered_payload live sources, payload-descriptor contract).

## Godot debt

Proof `C07PayloadLoaderAcceptPayloadProof` (6 keys:
`base_gate_rejects_when_payload_present`, `battery_accepted`,
`item_container_accepted`, `liquid_container_accepted`,
`non_build_payload_rejected`, `oversize_or_under_capacity_rejected` + registry) —
written, NEVER run on this VM (no Godot binary, user order 2026-11-15). See GOAL.md §5.
