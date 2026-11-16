# Handoff N2417 — UnitCargoLoader bar rows

## What this slice did

One pure-only bar pure
`source_unit_cargo_loader_bar_rows_state(unit_type_name, unit_icon,
count_type, use_unit_cap, cap)` (no tick wiring): bar name "units" +
`bar.unitcap` label parts + Pal.power + count/cap fraction. 5 files,
commit `7b7ce3d69` on `slice/N2417-unit-cargo-loader-bar-rows`.

## Key facts for the next agent

- **Fifth input `unit_icon`** — the font-atlas lookup is runtime
  data, not computable from the name.
- **Cap string is derived** from cap (MAX_VALUE−1 → "∞").
- **Cap 0 unguarded, like Java** (NaN/Infinity) — intentional.
- SSOT +3/+1/+1/+2. DEFERRED #2 resolved (286→285).

## Godot debt (this slice)

- NEW proof `C07UnitCargoLoaderBarRowsProof` (6 keys) — never run.
