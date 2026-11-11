# Report — N2127: Source-exhaustion / output-full acts in the live-loop power stamp

Date: 2026-11-11. Batch: N2127 (single slice). Status: built, registered, proof 27/27 verified, test module 4/4 standalone. **Targeted gate 5605 tests OK (log targeted-n2127.log); full Python suite 5605 tests OK (log full-suite-n2127.log).**

## What changed

N2125's stamp read only the placed building's live frame `enabled` flag. That left two Java acts unwired for the factory families, and N2127 wires both into `SourcePlacedPowerGraphState.source_consumer_should_consume_for_cell_state(game, cell)` (extended in place, still N2125):

- **Output-full:** a GenericCrafter's shouldConsume() is the output-full gate (GenericCrafter.java:203-231) and the adjacent family's is its own body (Separator.java:99-108, WallCrafter.java:246-248, BlockProducer.java:108-110) — the stamp now calls the family's per-class shouldConsume for `should_consume`, which is the `entity.shouldConsume()` factor `ConsumePower.requestedPower` reads (ConsumePower.java:60-63: an unbuffered consumer pays `usage * (entity.shouldConsume() ? 1f : 0f)`), so an output-full factory requests no power.
- **Source-exhaustion:** `shouldConsumePower` is now the frame's live `should_consume_power` key — the updateConsumption first-pass flag (BuildingComp.java:1971-1974: a non-power, non-optional consumer with efficiency at most 0.0000001f clears it), stamped every tick by `apply_update_consumption_state` from the factory and adjacent tick drivers — falling back to `enabled` before the first tick. `PowerGraph.getPowerNeeded` (PowerGraph.java:105-115) sums only consumers whose `shouldConsumePower` is set, so a starved factory stops drawing power even while its outputs have room.

Unit-factory frames stay on the N2125 enabled-only stamp (their per-class shouldConsume bodies are not wired to the stamp yet — deferred).

## Verified numbers

- Godot proof `C06SourceExhaustionProof`: **27/27 true** (`matches: true`, 0 false). A starved smelter reads shouldConsumePower false while should_consume stays true and the graph needs only the lancer's 6.0/60; feeding coal 5 + sand 5 flips the flag true and needed reads 6.5/60; filling silicon to 10 flips should_consume false while the flag stays true and needed drops back to 6.0/60; a cliff-crusher filled to sand 10 stops the same way.
- Test module `test_c06_source_exhaustion_output_full.py`: **4/4 OK standalone in 13.919s**.
- SSOT +0/+1/+0/+0 → **11232 / 1578 / 1500 / 2791**; audit stays 1335. All 77 shards equal a fresh `build_extension_shard`.
- Suite size: 5601 + 4 new tests = **5605** expected.

## Deferred

Unit-factory frames' per-class shouldConsume wiring to the power stamp; the battery's live `enabled` stamp; `ConsumeItemDynamic.trigger` at unit completion; UnitAssembler plan dynamics. C06–C12 remain open.

See `handoffs/2026-11-11-c06-source-exhaustion-output-full-handoff.md` for the full detail.

## Gate / suite

- Targeted gate: **5605 tests OK in 1938.767s** (log `targeted-n2127.log`).
- Full Python suite: **5605 tests OK in 1934.236s** (log `full-suite-n2127.log`).
