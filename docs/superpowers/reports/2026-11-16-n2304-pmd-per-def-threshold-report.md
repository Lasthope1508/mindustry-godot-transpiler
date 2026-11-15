# Report N2304 — PayloadMassDriver per-def maxPayloadSize threshold

**Slice:** N2304 — PMD acceptPayload per-def threshold (for_def pure + block-id helper). **Wave:** advances-10.
**Commit:** `a174435c` on `slice/N2304-pmd-per-def-threshold` (base `fa627ace`).
**Files:** 6, +940/−17.

## Source

`PayloadMassDriver.acceptPayload` (PayloadMassDriver.java:462-463) gates on
`maxPayloadSize`: the class default is 3 (`public float maxPayloadSize = 3;`,
PayloadMassDriver.java:30) → threshold 24 = 3 × tilesize. But BOTH real defs
override it: payload-mass-driver 2.5f → 20 (Blocks.java:6624),
large-payload-mass-driver 4f → 32 (Blocks.java:6636). N2298 ported the gate with
the class-default threshold only (and recorded the per-def follow-up as a new
DEFERRED entry). Threshold 24 is NOT Java behavior for either real def.

## Implementation

NEW pure `source_payload_mass_driver_accept_payload_state_for_def(payload_size,
has_payload, max_payload_size)` (3 outputs, mirroring N2298's 3) — NOT an
extension of the N2298 pure: the N2298 test pins the exact 2-arg tick call string
+ the class-default threshold line, so the N2298 pure stays untouched as the
class-default gate. Helper `_payload_mass_driver_max_payload_size_for_block(
block_id)` returns 2.5 / 4.0 / 3.0 (class default); the catalog was verified by
grep to have NO maxPayloadSize property, so the helper is required (N2273
precedent). The tick now passes the per-def value. **The N2298 test HAD to be
updated (6th file)** — it pins the tick-call string, and the tick rewire is the
point of this slice (N2290 precedent for updating another slice's test). Proof
discriminator: size 24 fits the class default but rejects at the small def.

## Commits

- Slice: `a174435c` (6 files, +940/−17).
- Integration cherry-pick: `1d4e810a` (clean).

## Tests

Targeted: 3/4 PASS for BOTH the new module
(`tests.test_c07_payload_mass_driver_per_def_threshold`) and the N2298 module
(Ran 8, failures=2, both proof tests failing exactly AssertionError: unexpectedly
None — NO Godot binary on this VM, user order 2026-11-15). Exact-evidence 12/12.
Siblings Ran 92 = 69 PASS + 23 proof, 0 other failures.
Full gate (wave advances-10 integration, PID 1755, 04:31–04:53, run 2 — run 1 PID 20261 killed by VM restart #8 ~04:30, no footer): Ran 6302 tests in 1216.770s, FAILED (failures=252, skipped=5), 0 errors — 252/252 Godot-absent `AssertionError: unexpectedly None` (248 inherited + 4 new proof tests N2304/N2305/N2306/N2308; N2302/N2303/N2307 add no test).

## SSOT / DEFERRED

SSOT single-slice **+3/+1/+1/+2** → 11925/1750/1686/3164 (brief estimated +5
symbols — the pure mirrors N2298's 3 outputs, nothing else source-backed); audit
stays 1336. DEFERRED 324 (325 − 1 per-def entry resolved + 0 new).

## Godot debt

- NEW proof `C07PayloadMassDriverPerDefThresholdProof` (6 keys:
  `small_def_boundary_20_accepted`, `small_def_size_24_rejected`,
  `large_def_boundary_32_accepted`, `large_def_size_33_rejected`,
  `class_default_boundary_24_accepted`, `live_tick_exposes_per_def_verdict`) —
  written but NEVER run; debt in GOAL.md §5.
- RE-RUN of proof N2298 RECOMMENDED (the tick path changed, though the live-tick
  values 16/32 still hold) — recorded as a re-run note on the N2298 §5 entry.
