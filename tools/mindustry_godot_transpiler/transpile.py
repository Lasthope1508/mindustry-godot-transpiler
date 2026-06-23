import argparse
from pathlib import Path

from mindustry_port.assets import copy_assets
from mindustry_port.content_registry import write_content_registry
from mindustry_port.emitter import emit_gdscript_classes
from mindustry_port.java_ast import parse_source_tree
from mindustry_port.playable import write_playable_manifest
from mindustry_port.reports import write_json, write_report
from mindustry_port.scanner import scan_source_tree


def generated_dir(godot_root: Path) -> Path:
    return godot_root / "src" / "generated"


def add_common_options(parser: argparse.ArgumentParser) -> None:
    parser.add_argument("--upstream", default="mindustry-upstream", help="Path to Mindustry upstream checkout")
    parser.add_argument("--godot", default="godot-mindustry", help="Path to Godot output project")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Mindustry to Godot GDScript transpiler pipeline")
    add_common_options(parser)
    subparsers = parser.add_subparsers(dest="command", required=True)
    commands = {
        "scan": "Scan Java source tree and write manifest",
        "assets": "Copy Mindustry assets into Godot project",
        "report": "Write pipeline status report",
        "parse": "Parse Java files into normalized AST manifest",
        "emit": "Emit parseable Java classes as GDScript skeletons",
        "playable": "Write playable slice manifest",
        "content": "Write source-derived content registry",
        "all": "Run scan, assets, and report",
    }
    for command, help_text in commands.items():
        subparser = subparsers.add_parser(command, help=help_text)
        add_common_options(subparser)
        if command == "parse":
            subparser.add_argument("--limit", type=int, default=None, help="Maximum Java files to parse")
        if command == "emit":
            subparser.add_argument("--limit", type=int, default=None, help="Maximum Java files to parse and emit")
    return parser


def run_scan(upstream: Path, godot: Path) -> dict:
    manifest = scan_source_tree(upstream / "core" / "src")
    write_json(generated_dir(godot) / "source_manifest.json", manifest)
    return manifest


def run_assets(upstream: Path, godot: Path) -> dict:
    manifest = copy_assets(upstream, godot / "assets")
    write_json(generated_dir(godot) / "asset_manifest.json", manifest)
    return manifest


def run_parse(upstream: Path, godot: Path, limit: int | None = None) -> dict:
    manifest = parse_source_tree(upstream / "core" / "src", limit)
    write_json(generated_dir(godot) / "ast_manifest.json", manifest)
    return manifest

def run_emit(upstream: Path, godot: Path, limit: int | None = None) -> dict:
    manifest = emit_gdscript_classes(upstream / "core" / "src", generated_dir(godot) / "classes", limit)
    write_json(generated_dir(godot) / "emitted_classes.json", manifest)
    return manifest


def run_report(upstream: Path, godot: Path, source_manifest: dict | None = None, asset_manifest: dict | None = None) -> dict:
    return write_report(generated_dir(godot), source_manifest, asset_manifest, upstream / "core" / "src")


def run_playable(godot: Path) -> dict:
    return write_playable_manifest(godot / "assets", generated_dir(godot) / "playable_content.json")


def run_content(upstream: Path, godot: Path) -> dict:
    return write_content_registry(upstream, godot)


def main(argv=None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    upstream = Path(args.upstream)
    godot = Path(args.godot)

    if args.command == "scan":
        manifest = run_scan(upstream, godot)
        print(f"scanned {manifest['java_file_count']} Java files")
    elif args.command == "assets":
        manifest = run_assets(upstream, godot)
        print(f"copied {manifest['asset_count']} assets")
    elif args.command == "parse":
        manifest = run_parse(upstream, godot, args.limit)
        print(f"parsed {manifest['parsed_file_count']} Java files failures={manifest['failed_file_count']}")
    elif args.command == "emit":
        manifest = run_emit(upstream, godot, args.limit)
        print(f"emitted classes={manifest['emitted_file_count']} failures={manifest['skipped_failure_count']}")
    elif args.command == "report":
        report = run_report(upstream, godot)
        print(f"report java={report['java_file_count']} assets={report['asset_count']}")
    elif args.command == "playable":
        manifest = run_playable(godot)
        print(f"playable blocks={len(manifest['blocks'])} item={manifest['item']['id']}")
    elif args.command == "content":
        registry = run_content(upstream, godot)
        counts = registry["counts"]
        print(f"content items={counts['items']} liquids={counts['liquids']} blocks={counts['blocks']} units={counts['units']}")
    elif args.command == "all":
        source_manifest = run_scan(upstream, godot)
        asset_manifest = run_assets(upstream, godot)
        report = run_report(upstream, godot, source_manifest, asset_manifest)
        print(f"all java={report['java_file_count']} assets={report['asset_count']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
