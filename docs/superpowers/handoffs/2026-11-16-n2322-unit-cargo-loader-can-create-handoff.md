# Handoff N2322 — UnitCargoLoader live canCreate check

## What this slice did

Wired the UnitCargoLoader live canCreate check: a new pure evaluates
`Units.canCreate` over `getCap` from frame inputs and the tick passes the
live verdict as the 5th arg into the N2234 advance (replacing the default
`true`). 6 files, +986/−10, commit `ea28be9b` on
`slice/N2322-unit-cargo-loader-can-create`.

## Key facts for the next agent

- Pure `source_unit_cargo_loader_can_create_state(frame)` → `{can_create,
  cap}`, composing the existing N2140 helpers
  (`SourceUnitUpdateState.cap_state` +
  `SourceUnitRuntimeState.source_units_can_create_state`) instead of
  duplicating math.
- Frame input `can_create_inputs` dict (11 keys); absent/non-dict/empty →
  permissive `{true, 2147483647}` (driver const
  `SOURCE_UNIT_CARGO_LOADER_UNIT_CAP_MAX`).
- **The N2234 test pin was updated in this slice** (3-arg advance call
  INCLUDING the closing paren → 5-arg call + comment) — N2314/N2315
  precedent.
- Scope corrections: getCap is Units.java:119–126 (brief said :120–125 —
  signature :119, uncapped :122–124, clamped return :125); manifold has NO
  useUnitCap override (UnitTypes.java:4568–4593), keeps default `true`
  (UnitType.java:205); the only `useUnitCap = false` is assemblyDrone
  (:4612). canPlaceOn :65–68 (call at :66); :73 is the drawPlace call.
- **⚠️ FLAG for advances-13: the N2234 proof's live tick looks STALE at
  base** — it stamps no nitrogen but expects efficiency 0.5; since the N2249
  liquid row went live, an unstamped loader folds efficiency to 0 (same class
  as N2176/N2213/N2227/N2222). Verify by reading the proof first; fix = seed
  nitrogen on the sprite liquids meta (N2249 pattern).
- Proof has **8 keys** (brief suggested 6; permissive-default + live-tick
  added — both core to the contract).
- SSOT +2/+1/+1/+2 (exactly the SCOPE estimate). DEFERRED 323 (−1 canCreate
  entry + 1 new: live unit-count source).

## Godot debt (this slice)

- NEW proof `C07UnitCargoLoaderCanCreateProof` (8 keys) — never run.
