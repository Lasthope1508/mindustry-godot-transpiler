# Handoff N2337 — BaseShield sqrtf() → sqrt() (first real Godot error)

## What this slice did

Fixed the FIRST REAL Godot error: `sqrtf()` at
`SourceBaseShieldBuildState.gd:121` does not exist in GDScript and blocked
proof launch (found by the user running Godot 4.6.2 via MCP on wave-13).
One-line fix `sqrtf(` → `sqrt(` + a durable repo-wide `*f` sweep test. 2
files, +37/−2, commit `829f813f` on `slice/N2337-baseshield-sqrtf-fix`.

## Key facts for the next agent

- Origin: commit `ff8f6220`, slice N2236 (advances-4). `sqrtf` appeared
  exactly once in all `.gd`; not a transpiler bug.
- The old N2236 test PINNED THE BUG (`assertIn('sqrtf(...)')`) — fixed to
  `sqrt(...)`. A passing test does not prove the GDScript parses.
- Sweep test `test_no_c_style_float_math_functions_in_gdscript` pins 15
  nonexistent C-style `*f(` functions; `clampf/minf/maxf/absf/lerpf/floorf/ceilf`
  DO exist in Godot 4 — never "fix" them.
- SSOT +0, DEFERRED net 0, no ledger entry (fix slice).

## Godot debt (this slice)

- NO new proof. **RE-RUN N2236 + N2328** after this fix (both were blocked
  on the parse error).
