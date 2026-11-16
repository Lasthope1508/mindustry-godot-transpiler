# Handoff N2464 — PayloadDeconstructor setBars row

## What this slice did

One pure-only pure (no tick wiring):
`source_payload_deconstructor_bar_state(progress)` → {label, color,
fraction} — label "bar.progress" (bundle key, NOT a Dict), color
"Pal.ammo", fraction = progress RAW (no clamp). 5 files, +746/−1,
commit `f3e39b2de` on `slice/N2464-deconstructor-set-bars-row`.

## Key facts for the next agent

- **Label is a plain key, NOT a Dict** — this bar calls no
  Core.bundle.format. The N2450 Dict form applies only to
  format-with-args bars.
- **Clamp cite correction:** Bar.java:33 is the Prov-form ctor
  clamp; this bar uses the String ctor (:23-29) which stores RAW
  (:27) — clamp is draw-only (:80). The pure does NOT clamp.
- **Frame key:** progress is frame["progress"] (N2276 advance).
- SSOT +3/+1/+1/+2 (exact est). DEFERRED #3 resolved (246→245).

## Godot debt (this slice)

- NEW proof `C07PayloadDeconstructorBarRowsProof` (6 keys) — never
  run.
