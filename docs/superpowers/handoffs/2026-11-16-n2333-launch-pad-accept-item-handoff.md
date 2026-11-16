# Handoff N2333 — LaunchPad acceptItem gate

## What this slice did

Wired the LaunchPad acceptItem gate: a new pure ports `total < capacity AND
(accept_multiple OR total == 0 OR first == item)`, with first() scanned in
content-id order. 5 files, +458/−1, commit `24ff62bf` on
`slice/N2333-launch-pad-accept-item`.

## Key facts for the next agent

- Pure `source_launch_pad_accept_item_state(frame, item, item_capacity,
  accept_multiple_items, item_order)` → `{accepts}`; private helper
  `_launch_pad_first_item` mirrors StackRouter (content-id-order scan over
  catalog `item_names_by_id`, item compared by name string per N2225).
- **No driver call site:** driver grep acceptItem was 0 hits before this
  slice — pure + test + proof only, no invented wiring (test pins with
  `assertNotIn`).
- Scope corrections: `acceptMultipleItems` is on LaunchPad.java:40 (NOT
  StorageBlock); launch-pad true (:6796), advanced-launch-pad false default;
  itemCapacity 100 for both defs (:6793/6803); the catalog does NOT carry
  `acceptMultipleItems` → the pure takes it as an explicit parameter (the
  driver would stamp it from the block id at wiring time, launchTime
  precedent).
- Key-name deviation (brief-permitted): the 6th key is
  `first_item_uses_content_order` (the brief suggested two overlapping
  keys).
- SSOT +1/+1/+1/+2 (exactly the SCOPE estimate). DEFERRED net 0 (resolved
  #62 + 1 new driver wiring — waits for the frame-items-intake design).

## Godot debt (this slice)

- NEW proof `C07LaunchPadAcceptItemProof` (6 keys) — never run.
