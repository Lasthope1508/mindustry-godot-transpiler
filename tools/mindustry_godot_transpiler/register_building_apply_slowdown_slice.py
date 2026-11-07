from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/entities/comp/BuildingComp.java"
OWNER = "PortGame.source_building_apply_slowdown_state"
PROOF = "/root/Main.BuildingTimeStateModuleProof"
TESTS = ["test_building_apply_slowdown_slice.py", "test_emitter.py", "test_source_symbols.py"]


def schema_key(type_name: str, status: str, method: str, expr: str, rule: str, *, alias_of: str | None = None) -> dict:
    entry = {
        "type": type_name,
        "status": status,
        "java_source": SOURCE,
        "java_method": method,
        "java_expr": expr,
        "rule": rule,
    }
    if alias_of:
        entry["alias_of"] = alias_of
    return entry


def symbol(name: str, godot_symbol: str, expr: str, rule: str, status: str = "source-backed") -> tuple[str, dict]:
    return name, {
        "status": status,
        "godot_owner": OWNER,
        "godot_symbol": godot_symbol,
        "rule": rule,
        "tests": TESTS,
        "runtime_proof": PROOF,
        "java_source": SOURCE,
        "java_method": "applySlowdown(float intensity, float duration)",
        "java_expr": expr,
    }


def main() -> None:
    method = "applySlowdown(float intensity, float duration)"
    input_name = "source_building_apply_slowdown_input"
    result_name = "source_building_apply_slowdown_result"
    symbols = dict([
        symbol("building_apply_slowdown.method", f"{result_name}.method", "public void applySlowdown(float intensity, float duration){", "Method boundary."),
        symbol("building_apply_slowdown.current_time_scale", f"{input_name}.currentTimeScale", "this.timeScale", "Current time-scale input.", "explicit-input"),
        symbol("building_apply_slowdown.current_duration", f"{input_name}.currentDuration", "timeScaleDuration", "Current duration input.", "explicit-input"),
        symbol("building_apply_slowdown.intensity", f"{input_name}.intensity", "intensity", "Slowdown intensity input.", "explicit-input"),
        symbol("building_apply_slowdown.duration", f"{input_name}.duration", "duration", "Slowdown duration input.", "explicit-input"),
        symbol("building_apply_slowdown.refresh_guard", f"{result_name}.refreshDurationGate", "if(intensity <= this.timeScale + 0.001f){", "Refresh duration only for a non-higher slowdown intensity."),
        symbol("building_apply_slowdown.duration_max", f"{result_name}.timeScaleDuration", "timeScaleDuration = Math.max(timeScaleDuration, duration);", "Source max assignment for slowdown duration."),
        symbol("building_apply_slowdown.time_scale_min", f"{result_name}.timeScale", "timeScale = Math.min(timeScale, intensity);", "Source min assignment for time scale."),
    ])
    source_symbols.upsert_source_slice(GODOT, "N1948", {
        "status": "done",
        "java_source": SOURCE,
        "java_class": "mindustry.entities.comp.BuildingComp",
        "java_method": method,
        "godot_owner": OWNER,
        "exact_exprs": [
            "public void applySlowdown(float intensity, float duration){",
            "if(intensity <= this.timeScale + 0.001f){",
            "timeScaleDuration = Math.max(timeScaleDuration, duration);",
            "timeScale = Math.min(timeScale, intensity);",
        ],
        "source_symbols": list(symbols),
        "tests": TESTS,
        "runtime_proof": PROOF,
        "rule": "Canonical BuildingComp slowdown owner shares the time-scale state module with applyBoost.",
    })
    source_symbols.upsert_source_api_contract(GODOT, OWNER, {
        "status": "active",
        "source_slice": "N1948",
        "java_source": SOURCE,
        "source_method": method,
        "params": [
            {"name": "current_time_scale", "type": "float", "schema": f"{input_name}.currentTimeScale"},
            {"name": "current_duration", "type": "float", "schema": f"{input_name}.currentDuration"},
            {"name": "intensity", "type": "float", "schema": f"{input_name}.intensity"},
            {"name": "duration", "type": "float", "schema": f"{input_name}.duration"},
        ],
        "return_keys": ["currentTimeScale", "currentDuration", "intensity", "duration", "refreshDurationGate", "timeScaleDuration", "timeScale"],
        "tests": TESTS,
        "runtime_proof": PROOF,
        "rule": "Public runtime contract for BuildingComp.applySlowdown with explicit time-scale inputs.",
    })
    source_symbols.upsert_source_state_schema(GODOT, input_name, {
        "status": "active", "owner": OWNER, "runtime_proof": PROOF,
        "keys": {
            "currentTimeScale": schema_key("float", "explicit-input", method, "this.timeScale", "Current time-scale field."),
            "currentDuration": schema_key("float", "explicit-input", method, "timeScaleDuration", "Current time-scale duration field."),
            "intensity": schema_key("float", "explicit-input", method, "intensity", "Source intensity parameter."),
            "duration": schema_key("float", "explicit-input", method, "duration", "Source duration parameter."),
        },
    })
    source_symbols.upsert_source_state_schema(GODOT, result_name, {
        "status": "active", "owner": OWNER, "runtime_proof": PROOF,
        "keys": {
            "currentTimeScale": schema_key("float", "generated", method, "this.timeScale", "Carries current time-scale input.", alias_of=f"{input_name}.currentTimeScale"),
            "currentDuration": schema_key("float", "generated", method, "timeScaleDuration", "Carries current duration input.", alias_of=f"{input_name}.currentDuration"),
            "intensity": schema_key("float", "generated", method, "intensity", "Carries intensity input.", alias_of=f"{input_name}.intensity"),
            "duration": schema_key("float", "generated", method, "duration", "Carries duration input.", alias_of=f"{input_name}.duration"),
            "refreshDurationGate": schema_key("bool", "source-backed", method, "if(intensity <= this.timeScale + 0.001f){", "Source duration refresh guard."),
            "timeScaleDuration": schema_key("float", "source-backed", method, "timeScaleDuration = Math.max(timeScaleDuration, duration);", "Source max duration assignment."),
            "timeScale": schema_key("float", "source-backed", method, "timeScale = Math.min(timeScale, intensity);", "Source min time-scale assignment."),
        },
    })
    source_symbols.upsert_source_symbols(GODOT, symbols)
    for name in ("comp_slices", "comp_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
