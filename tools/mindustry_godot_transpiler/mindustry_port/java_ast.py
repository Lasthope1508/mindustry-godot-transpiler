from pathlib import Path
from typing import Any

import javalang
from javalang.tree import ClassDeclaration, ConstructorDeclaration, EnumDeclaration, FieldDeclaration, MethodDeclaration


def _type_name(type_node: Any) -> str:
    if type_node is None:
        return ""
    name = getattr(type_node, "name", None)
    if name:
        return str(name)
    return str(type_node)


def _parameters(parameters: list[Any]) -> list[dict]:
    result = []
    for parameter in parameters or []:
        result.append({
            "name": parameter.name,
            "type": _type_name(parameter.type),
            "varargs": bool(getattr(parameter, "varargs", False)),
        })
    return result


def _modifiers(node: Any) -> list[str]:
    return sorted(list(getattr(node, "modifiers", []) or []))


def _field_entries(field: FieldDeclaration) -> list[dict]:
    entries = []
    for declarator in field.declarators:
        entries.append({
            "name": declarator.name,
            "type": _type_name(field.type),
            "modifiers": _modifiers(field),
        })
    return entries


def _method_entry(method: MethodDeclaration) -> dict:
    return {
        "name": method.name,
        "return_type": _type_name(method.return_type),
        "parameters": _parameters(method.parameters),
        "modifiers": _modifiers(method),
    }


def _constructor_entry(constructor: ConstructorDeclaration) -> dict:
    return {
        "name": constructor.name,
        "parameters": _parameters(constructor.parameters),
        "modifiers": _modifiers(constructor),
    }


def _class_entry(node: ClassDeclaration) -> dict:
    fields = []
    methods = []
    constructors = []
    for member in node.body:
        if isinstance(member, FieldDeclaration):
            fields.extend(_field_entries(member))
        elif isinstance(member, MethodDeclaration):
            methods.append(_method_entry(member))
        elif isinstance(member, ConstructorDeclaration):
            constructors.append(_constructor_entry(member))

    return {
        "kind": "class",
        "name": node.name,
        "extends": _type_name(node.extends),
        "implements": [_type_name(item) for item in (node.implements or [])],
        "modifiers": _modifiers(node),
        "fields": fields,
        "constructors": constructors,
        "methods": methods,
        "enum_constants": [],
    }


def _enum_entry(node: EnumDeclaration) -> dict:
    fields = []
    methods = []
    constructors = []
    body = node.body
    for member in body.declarations or []:
        if isinstance(member, FieldDeclaration):
            fields.extend(_field_entries(member))
        elif isinstance(member, MethodDeclaration):
            methods.append(_method_entry(member))
        elif isinstance(member, ConstructorDeclaration):
            constructors.append(_constructor_entry(member))

    return {
        "kind": "enum",
        "name": node.name,
        "extends": "",
        "implements": [_type_name(item) for item in (node.implements or [])],
        "modifiers": _modifiers(node),
        "fields": fields,
        "constructors": constructors,
        "methods": methods,
        "enum_constants": [constant.name for constant in body.constants],
    }


def parse_java_file(java_file: Path, source_root: Path) -> dict:
    java_file = Path(java_file)
    source_root = Path(source_root)
    source = java_file.read_text(encoding="utf-8", errors="replace")
    tree = javalang.parse.parse(source)
    types = []
    for type_node in tree.types:
        if isinstance(type_node, ClassDeclaration):
            types.append(_class_entry(type_node))
        elif isinstance(type_node, EnumDeclaration):
            types.append(_enum_entry(type_node))
        else:
            types.append({
                "kind": type_node.__class__.__name__,
                "name": getattr(type_node, "name", ""),
                "extends": "",
                "implements": [],
                "modifiers": _modifiers(type_node),
                "fields": [],
                "constructors": [],
                "methods": [],
                "enum_constants": [],
            })

    return {
        "path": java_file.relative_to(source_root).as_posix(),
        "package": tree.package.name if tree.package else "",
        "imports": [item.path for item in tree.imports],
        "types": types,
    }


def parse_source_tree(source_root: Path, limit: int | None = None) -> dict:
    files = []
    failures = []
    java_files = sorted(Path(source_root).rglob("*.java"))
    if limit is not None:
        java_files = java_files[:limit]
    for java_file in java_files:
        try:
            files.append(parse_java_file(java_file, source_root))
        except Exception as exc:
            failures.append({
                "path": java_file.relative_to(source_root).as_posix(),
                "error": str(exc),
                "error_type": exc.__class__.__name__,
            })
    return {
        "source_root": Path(source_root).as_posix(),
        "parsed_file_count": len(files),
        "failed_file_count": len(failures),
        "files": files,
        "failures": failures,
    }