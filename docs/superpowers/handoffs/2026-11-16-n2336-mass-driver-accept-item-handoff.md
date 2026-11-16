# Handoff N2336 — MassDriver acceptItem gate

## What this slice did

Wired the MassDriver acceptItem gate: a new pure ports `total < capacity &&
linkValid()`, and the tick stamps the verdict into `frame["accepts_item"]`
every tick. 5 files, +939/−2, commit `53c313e0` on
`slice/N2336-mass-driver-accept-item`.

## Key facts for the next agent

- Pure `source_mass_driver_accept_item_state(frame, item_capacity, linked)`
  → `{accepts}` (capacity term + linkValid); private helper
  `_mass_driver_link_valid` mirrors the N2237 advance's has_link
  conjunction. `linkValid` (MassDriver.java:346-349): link == −1 → false;
  partner must be a MassDriverBuild, same block, same team, within range
  (STRICT dst2, Position.java:44-46).
- The tick stamps `frame["accepts_item"]` every tick after the dump
  write-back (N2295 Loader acceptPayload precedent); `_initial_frame` gains
  `"accepts_item": false`.
- The brief's "frame link_partner dict" is the `linked` dict the tick
  **already gathers** for the N2237 advance — the pure reuses it verbatim.
- No intake path calls acceptItem (only the N2294 dump's neighbour arrays)
  — the verdict stamp follows the established frame-verdict pattern
  (N2295/N2297/N2298), no invented call site.
- Single def, range 440f / itemCapacity 120 (Blocks.java:2170/2172); no
  large-mass-driver def. No scope corrections.
- N2237 advance call string and N2294 dump call string untouched (both
  pinned by their tests).
- SSOT +1/+1/+1/+2 (exactly the SCOPE estimate). DEFERRED net 0 (resolved
  #58 + 1 new frame items intake — distinct from #294/#295 dump-neighbour
  entries).

## Godot debt (this slice)

- NEW proof `C07MassDriverAcceptItemProof` (6 keys; live-tick checks fold
  into the first three keys) — never run.
