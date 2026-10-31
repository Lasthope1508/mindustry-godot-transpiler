"""Record canonical delegate follow-ups without creating a second API/schema owner."""
from copy import deepcopy
from pathlib import Path

from mindustry_port import source_ssot, source_symbols


GODOT = Path(__file__).resolve().parents[2] / "godot-mindustry"


def main():
    ledger = source_symbols.load_source_slice_ledger(GODOT)["slices"]
    for original, followup, method, test in [
        ("N1449", "N1991", "update", "test_consume_liquid_update_has_one_canonical_formula_owner"),
        ("N1543", "N1992", "efficiency", "test_consume_liquid_efficiency_has_one_canonical_formula_owner"),
    ]:
        entry = deepcopy(ledger[original])
        entry["title"] = f"ConsumeLiquid.{method} generated canonical delegate"
        entry["rule"] = f"Generated ConsumeLiquid.{method} normalizes explicit inputs and delegates to the existing SourceConsumeLiquidState.{method}_state; formulas, source metadata and result schema remain owned by the original contract."
        entry["tests"] = [test, "test_consume_liquid_golden_runtime_and_building_composition"]
        entry["runtime_proof"] = "/root/Main.ConsumeLiquidCanonicalProof"
        # Keep the original deferred object/storage bindings visible. Delegation
        # proves a canonical state contract, not LiquidModule mutation or world wiring.
        source_symbols.upsert_source_slice(GODOT, followup, entry)
    source_ssot.write_registered_json(GODOT, "consumer_slices", source_ssot.build_extension_shard(GODOT, "consumer_slices"))


if __name__ == "__main__":
    main()
