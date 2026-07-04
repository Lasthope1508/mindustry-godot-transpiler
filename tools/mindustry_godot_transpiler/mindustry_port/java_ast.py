from pathlib import Path
from typing import Any
import re

import javalang
from javalang.tree import ClassDeclaration, ConstructorDeclaration, EnumDeclaration, FieldDeclaration, MethodDeclaration

def _replace_text_blocks(source: str) -> str:
    result: list[str] = []
    index = 0
    while index < len(source):
        start = source.find('"""', index)
        if start == -1:
            result.append(source[index:])
            break
        end = source.find('"""', start + 3)
        if end == -1:
            result.append(source[index:])
            break
        result.append(source[index:start])
        result.append('"__text_block__"')
        index = end + 3
    return "".join(result)

def _previous_non_space(source: str, index: int) -> int:
    index -= 1
    while index >= 0 and source[index].isspace():
        index -= 1
    return index

def _matching_open_paren(source: str, close_index: int) -> int:
    depth = 0
    index = close_index
    while index >= 0:
        char = source[index]
        if char == ")":
            depth += 1
        elif char == "(":
            depth -= 1
            if depth == 0:
                return index
        index -= 1
    return -1

def _token_before(source: str, index: int) -> str:
    index = _previous_non_space(source, index)
    end = index + 1
    while index >= 0 and (source[index].isalnum() or source[index] in "_$"):
        index -= 1
    return source[index + 1:end]

def _find_matching_brace(source: str, open_index: int) -> int:
    depth = 1
    index = open_index + 1
    state = "code"
    while index < len(source):
        char = source[index]
        next_char = source[index + 1] if index + 1 < len(source) else ""
        if state == "line_comment":
            if char == "\n":
                state = "code"
        elif state == "block_comment":
            if char == "*" and next_char == "/":
                state = "code"
                index += 1
        elif state == "string":
            if char == "\\":
                index += 1
            elif char == '"':
                state = "code"
        elif state == "char":
            if char == "\\":
                index += 1
            elif char == "'":
                state = "code"
        else:
            if char == "/" and next_char == "/":
                state = "line_comment"
                index += 1
            elif char == "/" and next_char == "*":
                state = "block_comment"
                index += 1
            elif char == '"':
                state = "string"
            elif char == "'":
                state = "char"
            elif char == "{":
                depth += 1
            elif char == "}":
                depth -= 1
                if depth == 0:
                    return index
        index += 1
    return -1

def _is_callable_body(source: str, brace_index: int) -> bool:
    previous = _previous_non_space(source, brace_index)
    if previous < 0 or source[previous] != ")":
        return False
    open_paren = _matching_open_paren(source, previous)
    if open_paren == -1:
        return False
    return _token_before(source, open_paren) not in {"if", "for", "while", "switch", "catch", "synchronized"}

def _strip_callable_bodies(source: str) -> str:
    result: list[str] = []
    index = 0
    last = 0
    state = "code"
    while index < len(source):
        char = source[index]
        next_char = source[index + 1] if index + 1 < len(source) else ""
        if state == "line_comment":
            if char == "\n":
                state = "code"
        elif state == "block_comment":
            if char == "*" and next_char == "/":
                state = "code"
                index += 1
        elif state == "string":
            if char == "\\":
                index += 1
            elif char == '"':
                state = "code"
        elif state == "char":
            if char == "\\":
                index += 1
            elif char == "'":
                state = "code"
        else:
            if char == "/" and next_char == "/":
                state = "line_comment"
                index += 1
            elif char == "/" and next_char == "*":
                state = "block_comment"
                index += 1
            elif char == '"':
                state = "string"
            elif char == "'":
                state = "char"
            elif char == "{" and _is_callable_body(source, index):
                end = _find_matching_brace(source, index)
                if end != -1:
                    result.append(source[last:index])
                    result.append("{}")
                    index = end
                    last = end + 1
        index += 1
    result.append(source[last:])
    return "".join(result)

def _preprocess_modern_java(source: str) -> str:
    source = _replace_text_blocks(source)
    source = _strip_callable_bodies(source)
    return re.sub(r"\binstanceof\s+([A-Za-z_$][\w$]*(?:\s*\.\s*[A-Za-z_$][\w$]*)*(?:\s*<[^;\n(){}]+>)?(?:\s*\[\s*\])*)\s+[A-Za-z_$][\w$]*", r"instanceof \1", source)


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
    inner_classes = []
    for member in node.body:
        if isinstance(member, FieldDeclaration):
            fields.extend(_field_entries(member))
        elif isinstance(member, MethodDeclaration):
            methods.append(_method_entry(member))
        elif isinstance(member, ConstructorDeclaration):
            constructors.append(_constructor_entry(member))
        elif isinstance(member, ClassDeclaration):
            inner_classes.append(_class_entry(member))

    return {
        "kind": "class",
        "name": node.name,
        "extends": _type_name(node.extends),
        "implements": [_type_name(item) for item in (node.implements or [])],
        "modifiers": _modifiers(node),
        "fields": fields,
        "constructors": constructors,
        "methods": methods,
        "inner_classes": inner_classes,
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
    source = _preprocess_modern_java(source)
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
