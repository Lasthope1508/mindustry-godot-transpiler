# Handoff N2313 — Unloader intake full-gate wiring

## What this slice did

Wired the Unloader intake through the N2296 acceptPayload verdict: the tick
builds a descriptor from the incoming dict and evaluates the pure; the push
applies only when it accepts. Occupied → KEEP for retry; rejected → DROP, still
consumed. 7 files, +951/−34, commit `c4f76868` on
`slice/N2313-unloader-intake-gate`.

## Key facts for the next agent

- **Occupancy vs rejection:** the verdict is only evaluated when the frame is
  empty. A push arriving while a payload is held is KEPT (N2279 keep-for-retry
  preserved exactly); a rejected push is DROPPED (it would retry forever).
  This is the N2313 difference from N2308.
- Missing descriptor keys default to rejecting inside the pure (no `size` = no
  fits, `is_build_payload` false) — the intake does NOT inject a default (unlike
  N2315, whose pure defaults missing block_size to 0 = fits).
- The Unloader inherits the Loader's acceptPayload override
  (PayloadUnloader.java:32) — NOT the bare PayloadBlock base gate.
- The offer verdict still governs `frame["accepts_payload"]` — the intake never
  overwrites it. The handle pure is untouched (one call site).
- **The N2279 live push lives in the PROOF file**, not the test module — the
  worker updated the N2279 proof fixture (+`is_build_payload` + `size: 24.0`),
  load-bearing. → N2279 proof is a RE-RUN.
- The N2296 test pinned the pure's call-site count (2) — the wiring adds the
  second call site, so the pin is now 3 (stale-pin fix, N2300 class).
- SSOT +0/+1/+0/+0 (shared ownership of the N2296 pure's 3 symbols). DEFERRED
  324 (−1 #313 +0).

## Godot debt (this slice)

- NEW proof `C07PayloadUnloaderIntakeGateProof` (6 keys) — never run.
- RE-RUN of proof N2279 (`C07PayloadUnloaderLiveFillProof`).
