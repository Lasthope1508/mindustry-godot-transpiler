# Handoff N2466 — LaunchPad config/display rows

## What this slice did

Two pure-only pures (no tick wiring):
`source_launch_pad_display_state` (destination_label Dict {key
"launch.destination", value token-or-"[accent]"+name}, null unless
the campaign/client/team gate passes) + `source_launch_pad_config_state`
(show_configure + button CALL record + deselect + destination_after
+ refresh flag). 5 files, commit `d64eefbb9` on
`slice/N2466-launch-pad-config-display-rows`.

## Key facts for the next agent

- **refresh = (prev != null && callback applied)** — NOT
  value-inequality. Re-selecting the same sector STILL refreshes
  in Java (:196 checks only prev != null). Pinned in the proof.
- **One is_campaign input** serves both the build gate and the
  callback re-check (one evaluation moment). The client gate is
  button-only (:186 vs :193).
- **Line cites:** display :164-177, shouldShowConfigure :180-182,
  buildConfiguration :185-203 (the brief counted trailing blanks).
- **LaunchPad.java is in blocks/campaign/**, not distribution/.
- SSOT +6/+1/+2/+4 (exact est). DEFERRED #34 resolved (246→245).

## Godot debt (this slice)

- NEW proof `C07LaunchPadConfigDisplayRowsProof` (6 keys) — never
  run.
