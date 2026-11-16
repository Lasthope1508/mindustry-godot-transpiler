# Report N2443 — LightBlock config / color rows

**Slice:** N2443 — LightBlock config(Integer) + configured +
control(color) + sense(color) + buildConfiguration +
onConfigureBuildTapped + config() + minimapColor: two pure-only
pures model the color sensing (double-bits denormal) and the
config transitions. **Wave:** advances-28. **Commit:** `5dac58bf3`
on `slice/N2443-light-block-config-color-rows` (base `682c75eb9`).
**Files:** 5, +1045/−3.

## Source

config(Integer) (LightBlock.java:35): tile.color = value.
minimapColor (:66-70): build == null ? 0 : build.color | 0xff (A
= 255). configured (:72-76): super + if !headless:
renderer.minimap.update(tile). control (:78-88): if type ==
LAccess.color: color = Tmp.c1.fromDouble(p1).rgba8888(); if
!headless: minimap update. Then super.control(...). sense
(:90-94): if sensor == LAccess.color: return
Tmp.c1.set(color).toDoubleBits(); else super.sense.
buildConfiguration (:109-115): button pencil 40f → ui.picker.show
(Tmp.c1.set(color).a(0.5f), false, res ->
configure(res.rgba())); deselect(). onConfigureBuildTapped
(:117-127): if this == other: deselect(), return false; else
return true. config() (:132-133): return color. Arc Color
(Color.java:166-168, 174-176, 236, 756-757): toDoubleBits(r,g,b,a)
= Double.longBitsToDouble(rgba8888 & 0xffffffffL); fromDouble(v) =
rgba8888((int) doubleToRawLongBits(v)); rgba8888() = ((int)(r*255)
<<24) | ((int)(g*255)<<16) | ((int)(b*255)<<8) | (int)(a*255).

## Implementation

Two pures (the N2387/N2437 sense + action precedent, pure-only,
no tick wiring):
- `source_light_block_sense_color_state(sensor, color,
  super_value=null)` → `{value, delegated}` (mirrors the N2437
  sense pure shape; LAccess.color token — LAccess is
  mindustry.logic.LAccess, NOT arc, the N2437 lesson). value when
  sensor == color: float(rgba8888(color)) × 2^-1074 (the double
  denormal whose raw bits are the color int zero-extended —
  Java-exact per arc Color.java:166-168). Other sensors:
  delegated = true, value = super_value.
- `source_light_block_config_color_state(color, action,
  action_value, is_self_tap, headless)` → `{color,
  minimap_updated, tapped_result, picker_call, config_value}` —
  5 keys. action ∈ {"none", "configure", "control"}
  (discriminated input, documented in the register rule):
  "configure" → color = action_value (int); "control" → color =
  action_value (int — the caller-supplied raw low-32-bits of p1,
  because GDScript has no double bitcast; the logic executor owns
  the bitcast, the caller-supplied precedent N2435); "none" →
  color unchanged. `tapped_result` = {deselect: is_self_tap,
  return_value: !is_self_tap}. `picker_call` = {icon: "pencil",
  size: 40f, color_a: 0.5} (buildConfiguration UI — recorded as
  CALL, the UI is NOT ported). `config_value` = color (after
  action).

**Math verification (the hard part — no blocker):** the worker
re-verified the coordinator's pre-scope claims independently with
float32 emulation: (a) set(int)→rgba8888() round-trip EXACT for
every channel 0–255; (b) `float(B) × 2^-1074 ==
Double.longBitsToDouble(B)` for 200k random 32-bit values +
endpoints (0, 1, 0xff, 0x80000000, 0xffd37fff, 0xffffffff); (c)
the proof's division check `value / 5e-324 == float(B)` exact.
GDScript zero-extends the Java signed int via `color &
0xffffffff`. The proof deliberately avoids `is_equal_approx` for
the denormal (its epsilon would swallow any denormal difference).

**⚠️ DEVIATION vs the brief (Java-verified, implemented
Java-exact):** the brief specified `minimap_updated = (action !=
"none" && color changed && !headless)`, but Java has **no
color-changed condition**: `LightBuild.configured()` calls
`renderer.minimap.update(tile)` whenever `!headless`
(LightBlock.java:72-76), the super `configured()` runs the
handler unconditionally (`block.configurations.get(type).get(this,
value);`, BuildingComp.java:1429), and `InputHandler.tileConfig`
calls `configured` with no equality check anywhere in the chain
(InputHandler.java:706-728). Same for `control()`
(LightBlock.java:78-88). Implemented `minimap_updated = is_action
&& !headless`, and the proof pins it (same-color configure still
updates the minimap). Documented in the GDScript comment,
register rule, and test comments.

## Commits

- Slice: `5dac58bf3` (5 files, +1045/−3).
- Integration cherry-pick: `61becc6c7` (clean).

## Tests

Targeted (new module `tests.test_c07_light_block_config_color_rows`):
3/4 PASS (registration, exact-evidence 35/35 exprs verbatim
against upstream — LightBlock/LAccess/BuildingComp/Pal + arc
Color, row-state) + proof test FAIL exactly AssertionError:
unexpectedly None — NO Godot binary on this VM (user order
2026-11-15). RED confirmed first (2 failures + 2 errors, incl.
`KeyError: 'N2443'`).
Full gate (wave advances-28 integration, PID 12844, from 20:00): Ran 6762 tests in 1613.764s, FAILED (failures=365, skipped=5), 0 errors — 365/365 Godot-absent (359 inherited + 6 new proof tests N2440–N2445; Ran 6762 = 6738 + 24 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+7/+1/+2/+4** → 12266/1859/1795/3382 (exactly
as estimated; 7 symbols — sense value + delegated; config color,
minimap_updated, tapped_result, picker_call, config_value; 4
schemas — sense/config input+result; 2 contracts). Shards
touched: `power_api_contracts.json`, `power_slices.json` (+ 4
canonical files; audit report + manifest unchanged). DEFERRED
**#91 RESOLVED** (266→265, by entry TEXT; no new entry).

## Godot debt

- NEW proof `C07LightBlockConfigColorRowsProof` (6 keys:
  `sense_color_double_bits`, `sense_delegate`, `configure_set`,
  `control_bits`, `tapped_self_other`, `minimap_color_or_ff` —
  the last is a cross-pure check: configured color → N2439
  draw-place `minimap_color`) — written but NEVER run; debt in
  GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring).
