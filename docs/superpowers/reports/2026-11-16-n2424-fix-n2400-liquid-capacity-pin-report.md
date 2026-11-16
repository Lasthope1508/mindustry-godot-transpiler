# Report N2424 — Fix N2400 liquid_capacity pin (serial, integration)

**Slice:** N2424 — coordinator-serial fix at advances-25 integration:
the N2400 verification pin `assertNotIn('liquid_capacity')` broke
because the N2420 draw pure takes `liquid_capacity` as an explicit
caller-supplied input. **Commit:** `7ec7a249d` (integration branch
only). **Files:** 1, +15/−8.

## Source

The N2400 test pinned the reported liquidCapacity discrepancy:
"the driver NEVER reads liquidCapacity (no catalog get, no frame
get)". N2420's draw pure models
`LiquidBlock.drawTiledFrames(..., liquids.get(drawLiquid) /
liquidCapacity)` (LaunchPad.java:104-136), so it takes
`liquid_capacity` as an explicit input param (line 342) and uses it
in the alpha ratio (line 391) — the driver now MENTIONS
liquid_capacity exactly twice, and the neighbours run caught it
(Ran 352, failures=88, 1 non-Godot: this pin).

## Implementation

The pin now asserts the NARROWED discrepancy precisely: the driver
mentions `liquid_capacity` exactly twice (the param + the alpha
ratio: `assertIn('liquid_capacity: float')` +
`assertEqual(count, 2)`), and still has NO supplier — no catalog get
(`assertNotIn('get("liquidCapacity"')`, kept), no frame read
(`assertNotIn('frame["liquid_capacity"]')`, new), no
`properties.get("size"` (kept). The comment explains the narrowing:
like the sense capacity pure, the draw pure takes the value
caller-supplied; nothing in the port still supplies the Java 40f
(no catalog key, no frame stamp, no tick wiring).

## Commits

- Serial: `7ec7a249d` (1 file, +15/−8).

## Tests

N2400 module: 2/3 PASS + proof test FAIL exactly AssertionError:
unexpectedly None (Godot-absent). Neighbours re-run (90 modules):
Ran 352, failures=87, 87/87 Godot-absent, 0 ERROR.
Full gate (wave advances-25 integration, PID 9433, from 17:08): Ran 6682 tests in 1574.715s, FAILED (failures=345, skipped=5), 0 errors — 345/345 Godot-absent (338 inherited + 7 new proof tests N2417-N2423; N2416/N2424 add no proof test).

## SSOT / DEFERRED

SSOT **+0/+0/+0/+0** (test-pin fix, the N2401 serial precedent — no
ledger entry). DEFERRED unchanged.

## Godot debt

- No new proof. No re-run (no proof file changed — the N2400 proof's
  expectations are unchanged; only a static pin in the row-state
  test moved).
