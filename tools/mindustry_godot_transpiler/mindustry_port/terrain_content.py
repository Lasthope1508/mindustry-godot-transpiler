"""Bounded source constructor evaluation for Block terrain definitions.

Only name, itemDrop and cacheLayer are projected. Unknown definitions are
omitted, never replaced with Java defaults from a different constructor path.
"""
from pathlib import Path

import javalang
from javalang import tree as jt

from .java_ast import _find_matching_brace, _preprocess_modern_java

UNKNOWN = object()
FIELDS = ('itemDrop', 'cacheLayer')


def _tokens(source):
    # javalang's Java-8 lexer miscounts positions inside Java text blocks.
    # Mask only their contents, keeping every source offset/newline intact.
    # Terrain expressions themselves do not accept text-block values.
    masked = list(source)
    start = source.find('"""')
    while start != -1:
        end = source.find('"""', start + 3)
        if end == -1: break
        for i in range(start, end + 3):
            if source[i] not in '\r\n': masked[i] = ' '
        masked[start:start + 3] = '"_"'
        start = source.find('"""', end + 3)
    return list(javalang.tokenizer.tokenize(''.join(masked)))


def anonymous_body(source, assignment_end):
    start = assignment_end
    while start < len(source) and source[start].isspace(): start += 1
    if start == len(source) or source[start] != '{': return ''
    end = _find_matching_brace(source, start)
    return source[start:end + 1] if end != -1 else ''


def block_creators(source):
    tokens = _tokens(source)
    offsets = [0]
    for line in source.splitlines(keepends=True): offsets.append(offsets[-1] + len(line))
    for i in range(len(tokens) - 5):
        if tokens[i + 1].value != '=' or tokens[i + 2].value != 'new' or tokens[i + 4].value != '(': continue
        depth = 1
        end = i + 5
        while end < len(tokens):
            if tokens[end].value == '(': depth += 1
            elif tokens[end].value == ')':
                depth -= 1
                if depth == 0: break
            end += 1
        if end == len(tokens): continue
        line, column = tokens[end].position
        yield tokens[i].value, tokens[i + 3].value, ' '.join(t.value for t in tokens[i + 5:end]), offsets[line - 1] + column


def _member(node):
    if isinstance(node, jt.MemberReference) and node.qualifier in ('', None):
        return node.member
    if isinstance(node, jt.This) and len(node.selectors or []) == 1:
        return _member(node.selectors[0])
    return ''


def _writes(node):
    return {_member(value.expressionl) for _, value in node.filter(jt.Assignment)} & set(FIELDS)


def _constructor_ranges(tokens, name):
    depth = 0
    for i, token in enumerate(tokens):
        if token.value == '{': depth += 1
        elif token.value == '}': depth -= 1
        if depth != 1 or token.value != name or i + 1 == len(tokens) or tokens[i + 1].value != '(':
            continue
        p = i + 1
        balance = 0
        while p < len(tokens):
            if tokens[p].value == '(': balance += 1
            elif tokens[p].value == ')':
                balance -= 1
                if balance == 0: break
            p += 1
        if p + 1 == len(tokens) or tokens[p + 1].value != '{': continue
        end = p + 1
        balance = 0
        while end < len(tokens):
            if tokens[end].value == '{': balance += 1
            elif tokens[end].value == '}':
                balance -= 1
                if balance == 0: break
            end += 1
        yield i, end


def _constructors(source, name):
    """Lexically delimit class-level constructors, then parse their real ASTs."""
    tokens = _tokens(source)
    result = []
    for start, end in _constructor_ranges(tokens, name):
        text = ' '.join(t.value for t in tokens[start:end + 1])
        try:
            result.append(javalang.parse.parse('class ' + name + ' { ' + text + ' }').types[0].constructors[0])
        except (javalang.parser.JavaSyntaxError, TypeError):
            return None
    return result


class TerrainContentResolver:
    def __init__(self, upstream_root: Path, items):
        self.items = {item['field']: ('item', item['field'], item['id']) for item in items}
        self.classes = {}
        world = Path(upstream_root) / 'core/src/mindustry/world'
        for path in [world / 'Block.java', *sorted((world / 'blocks').rglob('*.java'))]:
            if not path.exists(): continue
            source = path.read_text(encoding='utf-8', errors='replace')
            try:
                cls = javalang.parse.parse(_preprocess_modern_java(source)).types[0]
                constructors = _constructors(source, cls.name)
                # Scan method writes independently of modern method-body syntax.
                late = set()
                tokens = _tokens(source)
                ranges = list(_constructor_ranges(tokens, cls.name))
                depth = 0
                for i, token in enumerate(tokens[:-1]):
                    if token.value == '{': depth += 1
                    elif token.value == '}': depth -= 1
                    if depth > 1 and not any(start <= i <= end for start, end in ranges) and token.value in FIELDS and tokens[i + 1].value in ('=', '+=', '-=', '++', '--'):
                        late.add(token.value)
                # The actual OreBlock setup assignment is identity-preserving:
                # init calls setup(itemDrop), and setup assigns its Item argument.
                # Validate these ASTs rather than trusting an implementation name.
                try:
                    full = javalang.parse.parse(source).types[0]
                    late = set().union(*(_writes(method) for method in full.methods)) if full.methods else set()
                    for init in [m for m in full.methods if m.name == 'init']:
                        for _, call in init.filter(jt.MethodInvocation):
                            if len(call.arguments) != 1 or _member(call.arguments[0]) not in FIELDS: continue
                            key = _member(call.arguments[0])
                            targets = [m for m in full.methods if m.name == call.member and len(m.parameters) == 1]
                            if len(targets) != 1: continue
                            method = targets[0]
                            assignments = [a for _, a in method.filter(jt.Assignment) if _member(a.expressionl) == key]
                            param = method.parameters[0].name
                            mutated_param = any(_member(a.expressionl) == param for _, a in method.filter(jt.Assignment))
                            if len(assignments) == 1 and assignments[0].type == '=' and not mutated_param and _member(assignments[0].value) == param:
                                # Must be an unconditional statement, and the sole
                                # post-construction writer of this field.
                                direct = [s.expression for s in method.body if isinstance(s, jt.StatementExpression)]
                                writers = [m for m in full.methods if key in _writes(m)]
                                if assignments[0] in direct and writers == [method]: late.discard(key)
                except (javalang.parser.JavaSyntaxError, TypeError):
                    # Modern methods can be unsupported by javalang; the
                    # lexical write scan remains conservative in that case.
                    pass
                self.classes[cls.name] = (cls, constructors, late)
            except (javalang.parser.JavaSyntaxError, javalang.tokenizer.LexerError, AttributeError, IndexError):
                continue

    def _value(self, node, params):
        if node is None: return None
        if getattr(node, 'prefix_operators', None) or getattr(node, 'postfix_operators', None) or getattr(node, 'selectors', None): return UNKNOWN
        if isinstance(node, jt.Literal):
            if node.value == 'null': return None
            if node.value.startswith('"'): return node.value[1:-1]
            try: return int(node.value)
            except ValueError: return UNKNOWN
        if isinstance(node, jt.MemberReference):
            if node.qualifier == 'Items': return self.items.get(node.member, UNKNOWN)
            if node.qualifier == 'CacheLayer': return ('layer', node.member)
            if not node.qualifier: return params.get(node.member, UNKNOWN)
            if node.member == 'name':
                item = params.get(node.qualifier, UNKNOWN)
                if isinstance(item, tuple) and item[0] == 'item': return item[2]
        if isinstance(node, jt.BinaryOperation) and node.operator == '+':
            left, right = self._value(node.operandl, params), self._value(node.operandr, params)
            if isinstance(left, str) and isinstance(right, str): return left + right
        return UNKNOWN

    @staticmethod
    def _compatible(param, value):
        typ = param.type.name
        return (typ == 'String' and isinstance(value, str)) or (typ == 'Item' and (value is None or isinstance(value, tuple) and value[0] == 'item')) or (typ == 'int' and type(value) is int)

    def _resolve(self, name, args, stack):
        if name not in self.classes or name in stack: return {}
        cls, constructors, late = self.classes[name]
        if constructors is None: return {}
        candidates = [c for c in constructors if len(c.parameters) == len(args) and all(self._compatible(p, a) for p, a in zip(c.parameters, args))]
        if not constructors and len(args) == 0:
            values = self._resolve(cls.extends.name, [], stack | {name}) if cls.extends else {}
            return {k: v for k, v in values.items() if k not in late}
        if len(candidates) != 1: return {}
        constructor = candidates[0]
        params = {p.name: arg for p, arg in zip(constructor.parameters, args)}
        first = constructor.body[0] if constructor.body else None
        invocation = first.expression if isinstance(first, jt.StatementExpression) else None
        if isinstance(invocation, jt.ExplicitConstructorInvocation):
            delegated = [self._value(a, params) for a in invocation.arguments]
            # Allow another overload in this same class; cycle guard includes
            # signature so this(...) does not block valid constructor chaining.
            signature = (name, tuple(p.type.name for p in constructor.parameters))
            if signature in stack: return {}
            values = self._resolve(name, delegated, stack | {signature})
        elif name == 'Block':
            values = {}
            if isinstance(invocation, jt.SuperConstructorInvocation) and len(invocation.arguments) == 1:
                values['name'] = self._value(invocation.arguments[0], params)
        elif cls.extends:
            delegated = [self._value(a, params) for a in invocation.arguments] if isinstance(invocation, jt.SuperConstructorInvocation) else []
            values = self._resolve(cls.extends.name, delegated, stack | {name})
        else:
            return {}
        if not isinstance(invocation, jt.ExplicitConstructorInvocation):
            for field in cls.fields:
                for declaration in field.declarators:
                    if declaration.name in FIELDS: values[declaration.name] = self._value(declaration.initializer, params)
            for member in cls.body:
                if isinstance(member, list):
                    for statement in member: self._statement(statement, params, values)
        for statement in constructor.body or []: self._statement(statement, params, values)
        for field in late: values.pop(field, None)
        return values

    def _statement(self, statement, params, values):
        if isinstance(statement, jt.StatementExpression) and isinstance(statement.expression, jt.Assignment):
            expression = statement.expression
            # A nested write in another assignment's RHS is unsupported too;
            # it must invalidate inherited metadata rather than disappear.
            for nested_key in _writes(expression): values[nested_key] = UNKNOWN
            key = _member(expression.expressionl)
            if key in FIELDS:
                values[key] = self._value(expression.value, params) if expression.type == '=' else UNKNOWN
        elif isinstance(statement, jt.Node):
            for key in _writes(statement): values[key] = UNKNOWN

    def resolve(self, implementation, arguments):
        try:
            invocation = javalang.parse.parse_expression('new ' + implementation + '(' + arguments + ')')
            args = [self._value(a, {}) for a in invocation.arguments]
            if any(a is UNKNOWN for a in args): return {}
            values = self._resolve(implementation, args, set())
            return {key: (value[1] if isinstance(value, tuple) else value) for key, value in values.items() if value is not UNKNOWN}
        except (javalang.parser.JavaSyntaxError, TypeError, IndexError):
            return {}

    def overrides(self, initializer):
        """Parse real anonymous initializer AST; unrecognized writes stay unknown."""
        if not initializer: return {}
        try:
            cls = javalang.parse.parse('class Initializer ' + initializer).types[0]
            values = {}
            for member in cls.body:
                if isinstance(member, list):
                    for statement in member: self._statement(statement, {}, values)
            for method in cls.methods:
                for key in _writes(method): values[key] = UNKNOWN
            return values
        except (javalang.parser.JavaSyntaxError, TypeError):
            return {field: UNKNOWN for field in FIELDS}
