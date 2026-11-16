# Report N2466 — LaunchPad config / display / shouldShowConfigure rows

**Slice:** N2466 — LaunchPad display + buildConfiguration +
shouldShowConfigure: two pure-only pures model the destination
label and the config button/select callback. **Wave:** advances-31.
**Commit:** `d64eefbb9` on
`slice/N2466-launch-pad-config-display-rows` (base `43a5c79ad`).
**Files:** 5.

## Source

LaunchPad.java (core/src/mindustry/world/blocks/campaign/):
- display :164-177: `super.display(table); if(!state.isCampaign()
  || net.client() || team != player.team()) return; table.row();
  table.label(() -> { Sector dest = state.rules.sector == null ?
  null : state.rules.sector.info.destination; return
  Core.bundle.format("launch.destination", dest == null ||
  !dest.hasBase() ? Core.bundle.get("sectors.nonelaunch") :
  "[accent]" + dest.name()); }).pad(4).wrap().width(200f).left();`
- shouldShowConfigure :180-182: `return state.isCampaign();`
- buildConfiguration :185-203: `if(!state.isCampaign() ||
  net.client()){ deselect(); return; } table.button(Icon.upOpen,
  Styles.cleari, () -> { ui.planet.showSelect(state.rules.sector,
  other -> { if(state.isCampaign() && other.planet ==
  state.rules.sector.planet){ var prev = state.rules.sector.info.
  destination; state.rules.sector.info.destination = other;
  if(prev != null){ prev.info.refreshImportRates(state.getPlanet());
  } } }); deselect(); }).size(40f);`

## Implementation

Two pure-only pures (no tick wiring):
1. `source_launch_pad_display_state(is_campaign, is_client,
   is_player_team, destination)` → `{destination_label}`.
   destination is null-or-Dict {name, has_base} (caller-supplied —
   the sector state is not in the driver, the N2435 precedent).
   destination_label = null unless the gate passes (campaign &&
   !client && player team). Else {key: "launch.destination",
   value: "sectors.nonelaunch" | "[accent]" + name} — a Dict,
   because Java calls Core.bundle.format with an argument (the
   N2450 precedent; the "sectors.nonelaunch" value is the BUNDLE
   TOKEN, not the localized text). Bundle keys verified in
   bundle.properties:875/921. The super.display call is recorded,
   not a symbol; pad(4)/wrap/width(200f)/left() is UI chrome — not
   modeled.
2. `source_launch_pad_config_state(is_campaign, is_client,
   selected_sector, current_sector, prev_destination)` →
   `{show_configure, button_call, deselect_called,
   destination_after, refresh_import_rates_called}`.
   show_configure = is_campaign (shouldShowConfigure, folded into
   this pure as a result key). button_call = null unless campaign
   && !client, else {icon: "Icon.upOpen", style: "Styles.cleari",
   size: 40.0} (a CALL record — the UI is NOT ported, the N2443
   picker precedent; Icon.upOpen verified at LaunchPad.java:191,
   Styles.cleari at Styles.java:89/337). deselect_called = true
   when the gate FAILS (the early-return deselect, :187); the
   click-time deselect (:203) is part of the button_call record.
   destination_after = selected_sector iff campaign &&
   selected.planet == current.planet, else prev_destination.

**Verify-first findings (Java wins):**
1. **Line numbers:** display is **:164-177** (brief :164-178),
   shouldShowConfigure **:180-182** (brief :180-183),
   buildConfiguration **:185-203** (brief :185-208). The brief
   counted trailing blank lines / the next method's @Override.
2. **refresh_import_rates_called = (prev != null && callback
   applied)** — NOT value-inequality as the brief wrote. Java only
   checks `if(prev != null){` (:196) inside the callback, so
   re-selecting the SAME sector still refreshes (the assignment
   still runs). "Destination changed" = callback applied, not
   value-inequality. Pinned in the proof (`config_select`, reselect
   case).
3. **Callback re-check isCampaign:** one `is_campaign` input is
   reused for both the build gate and the callback re-check (the
   brief left the choice to the worker) — one evaluation moment; a
   campaign change at click time is UI-timing, not a pure. The
   client gate is only on the button, not the callback — exactly
   Java (:186 vs :193).
4. **No deferral docstring line existed** for config/display as the
   brief assumed — the worker added **item (11)** to the Documented
   limits list ("Config/display rows live (N2466)").

## Commits

- Slice: `d64eefbb9` (5 files).
- Integration cherry-pick: `a11856632` (clean).

## Tests

Targeted (new module
`tests.test_c07_launch_pad_config_display_rows`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL exactly
AssertionError: unexpectedly None — NO Godot binary on this VM (user
order 2026-11-15). RED before GREEN confirmed (KeyError 'N2466' ×2
+ missing driver func). Neighbours (N2444 FX + N2420 draw): Ran 8
(6 PASS + 2 proof Godot-absent), 0 errors.
Full gate (wave advances-31 integration, PID 8788, from 23:14): Ran 6846 tests in 1750.614s, FAILED (failures=386, skipped=5), 0 errors — 386/386 Godot-absent (379 inherited + 7 new proof tests N2462–N2468; Ran 6846 = 6818 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+6/+1/+2/+4** → 12347/1879/1828/3448 (exactly
as estimated). Display 1 + config 5 symbols. DEFERRED **#34
RESOLVED** (246→245, by entry TEXT — verified
`deferred.count(TARGET) == 1` at index 33; no new entry).

## Godot debt

- NEW proof `C07LaunchPadConfigDisplayRowsProof` (6 keys:
  `display_label_dest`, `display_label_none`, `display_gate`,
  `config_button`, `config_select`, `config_deselect`) — written
  but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring).
