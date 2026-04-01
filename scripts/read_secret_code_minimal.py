#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import ast
import argparse
import os
import sys
from typing import Any, Dict, List, Optional

# ---------- Helpers ----------
def unparse(node: Optional[ast.AST]) -> Optional[str]:
    if node is None:
        return None
    try:
        return ast.unparse(node)  # py>=3.9
    except Exception:
        try:
            return ast.dump(node, annotate_fields=False)
        except Exception:
            return None

def is_public(name: str) -> bool:
    return not name.startswith('_')

def type_name_of_constant(val: Any) -> str:
    t = type(val).__name__
    # Normalisera builtins till kort form
    mapping = {
        'str': 'str', 'int': 'int', 'float': 'float', 'bool': 'bool',
        'list': 'list', 'dict': 'dict', 'tuple': 'tuple', 'NoneType': 'None',
        'bytes': 'bytes'
    }
    return mapping.get(t, t)

def preview_constant_value(node: ast.AST) -> str:
    """
    Gör en *kort* och säker förhandsvisning för konstanter.
    """
    if isinstance(node, ast.Constant):
        v = node.value
        if isinstance(v, str):
            # Strängar visas som "" (tom) eller "…" (om icke-tom)
            return '""' if v == "" else '"…"'
        if isinstance(v, bool):
            return 'True' if v else 'False'
        if v is None:
            return 'None'
        if isinstance(v, int):
            return '0'  # normalisera till 0
        if isinstance(v, float):
            return '0.0'  # normalisera till 0.0
        if isinstance(v, bytes):
            return 'b"…"' if len(v) > 0 else 'b""'
        # Fallback
        return repr(v)
    # För icke-Constant (list/tuple/dict litteraler etc.)
    if isinstance(node, (ast.List, ast.Tuple, ast.Set)):
        if isinstance(node, ast.List):
            return '[]' if len(node.elts) == 0 else '[…]'
        if isinstance(node, ast.Tuple):
            return '()' if len(node.elts) == 0 else '(…)'
        if isinstance(node, ast.Set):
            return '{…}' if len(node.elts) > 0 else 'set()'
    if isinstance(node, ast.Dict):
        return '{}' if len(node.keys) == 0 else '{…}'
    # Annat: visa kort AST-text
    txt = unparse(node) or type(node).__name__
    if txt and len(txt) > 40:
        txt = txt[:37] + '…'
    return txt

def typename_from_annotation(ann: Optional[ast.AST]) -> Optional[str]:
    if ann is None:
        return None
    return unparse(ann)

# ---------- Extraction ----------
def parse_function(fn: ast.FunctionDef) -> Dict[str, Any]:
    a = fn.args
    params: List[Dict[str, Any]] = []

    posonly = getattr(a, 'posonlyargs', [])
    pos_args = posonly + a.args
    defaults = list(a.defaults)
    first_def = len(pos_args) - len(defaults)

    for idx, arg in enumerate(pos_args):
        default = defaults[idx - first_def] if idx >= first_def else None
        params.append({
            'name': arg.arg,
            'ann': typename_from_annotation(arg.annotation),
            'default': unparse(default) if default is not None else None,
        })

    if a.vararg:
        params.append({'name': f"*{a.vararg.arg}", 'ann': typename_from_annotation(a.vararg.annotation), 'default': None})

    for ka, kd in zip(a.kwonlyargs, a.kw_defaults):
        params.append({'name': ka.arg, 'ann': typename_from_annotation(ka.annotation), 'default': unparse(kd) if kd is not None else None})

    if a.kwarg:
        params.append({'name': f"**{a.kwarg.arg}", 'ann': typename_from_annotation(a.kwarg.annotation), 'default': None})

    doc = ast.get_docstring(fn)
    if doc:
        # Endast första stycket, en rad
        doc = doc.strip().split("\n\n", 1)[0].strip().replace("\n", " ")

    return {
        'name': fn.name,
        'returns': typename_from_annotation(fn.returns),
        'params': params,
        'doc': doc
    }

def parse_class(klass: ast.ClassDef) -> Dict[str, Any]:
    methods: List[Dict[str, Any]] = []
    for n in klass.body:
        if isinstance(n, ast.FunctionDef) and (is_public(n.name) or n.name == '__init__'):
            methods.append(parse_function(n))
    doc = ast.get_docstring(klass)
    if doc:
        doc = doc.strip().split("\n\n", 1)[0].strip().replace("\n", " ")
    return {
        'name': klass.name,
        'bases': [unparse(b) for b in klass.bases] if klass.bases else [],
        'doc': doc,
        'methods': methods
    }

def parse_constants(module: ast.Module) -> List[Dict[str, Any]]:
    out: List[Dict[str, Any]] = []
    for n in module.body:
        if isinstance(n, ast.Assign) and len(n.targets) == 1 and isinstance(n.targets[0], ast.Name):
            name = n.targets[0].id
            if name.isupper():
                # best-effort typnamn och normaliserad preview
                # typnamn primärt från Constant.value, annars strukturtyp
                if isinstance(n.value, ast.Constant):
                    tn = type_name_of_constant(n.value.value)
                elif isinstance(n.value, ast.List):
                    tn = 'list'
                elif isinstance(n.value, ast.Tuple):
                    tn = 'tuple'
                elif isinstance(n.value, ast.Dict):
                    tn = 'dict'
                elif isinstance(n.value, ast.Set):
                    tn = 'set'
                else:
                    tn = 'Any'
                out.append({
                    'name': name,
                    'type': tn,
                    'preview': preview_constant_value(n.value)
                })
    return out

def extract_api_from_source(source: str) -> Dict[str, Any]:
    tree = ast.parse(source)
    functions: List[Dict[str, Any]] = []
    classes: List[Dict[str, Any]] = []

    for n in tree.body:
        if isinstance(n, ast.FunctionDef) and is_public(n.name):
            functions.append(parse_function(n))
        elif isinstance(n, ast.ClassDef) and is_public(n.name):
            classes.append(parse_class(n))

    return {
        'functions': functions,
        'classes': classes,
        'constants': parse_constants(tree),
    }

# ---------- Rendering (plain text) ----------
def build_signature(fn: Dict[str, Any]) -> str:
    parts: List[str] = []
    for p in fn['params']:
        name = p['name']
        seg = name
        if p.get('ann'):
            seg += f": {p['ann']}"
        if p.get('default') is not None:
            seg += f" = {p['default']}"
        parts.append(seg)
    sig = f"{fn['name']}({', '.join(parts)})"
    if fn.get('returns'):
        sig += f" -> {fn['returns']}"
    return sig

def render_plain_api(api: Dict[str, Any], include_docstring: bool, include_constants: bool) -> str:
    lines: List[str] = []

    # Funktioner
    for fn in api['functions']:
        lines.append(build_signature(fn))
        if include_docstring and fn.get('doc'):
            lines.append(f'"""{fn["doc"]}"""')
        lines.append("")  # tom rad mellan poster

    # Klasser (om du vill ta med dem i samma format – valfritt)
    for cl in api['classes']:
        # Klassens docstring (om man vill ha)
        header = cl['name']
        if cl.get('bases'):
            header += f"({', '.join([b for b in cl['bases'] if b])})"
        lines.append(header)
        if include_docstring and cl.get('doc'):
            lines.append(f'"""{cl["doc"]}"""')
        # Metoder
        for m in cl['methods']:
            lines.append(build_signature(m))
            if include_docstring and m.get('doc'):
                lines.append(f'"""{m["doc"]}"""')
        lines.append("")

    # Konstanter
    if include_constants and api['constants']:
        for c in api['constants']:
            # Format: NAME: <typ> = <preview>
            lines.append(f'{c["name"]}: {c["type"]} = {c["preview"]}')
        lines.append("")

    return "\n".join(lines).rstrip() + "\n"

# ---------- CLI ----------
def main(argv: Optional[List[str]] = None) -> int:
    p = argparse.ArgumentParser(
        description="Minimal agentisk API‑utskrift: signaturer (+docstring valfritt) och konstanter. Ingen exekvering.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    p.add_argument('path', help='Fil eller katalog att analysera')
    p.add_argument('--include-docstring', action='store_true', help='Ta med docstrings (första stycket, en rad)')
    p.add_argument('--no-constants', action='store_true', help='Utelämna lista med konstanter')
    args = p.parse_args(argv)

    if not os.path.exists(args.path):
        sys.stderr.write(f"[ERROR] Sökvägen finns inte: {args.path}\n")
        return 1

    files: List[str] = []
    if os.path.isdir(args.path):
        for root, _, fnames in os.walk(args.path):
            for fn in fnames:
                if fn.endswith('.py'):
                    files.append(os.path.join(root, fn))
    else:
        files.append(args.path)

    any_done = False
    for f in sorted(files):
        try:
            with open(f, 'r', encoding='utf-8', errors='replace') as fh:
                src = fh.read()
            api = extract_api_from_source(src)
            text = render_plain_api(api, include_docstring=args.include_docstring, include_constants=not args.no_constants)
            if any_done:
                print("")  # tom rad mellan filer
            print(text, end="")
            any_done = True
        except SyntaxError as e:
            sys.stderr.write(f"[WARN] Syntaxfel i {f}: {e}\n")
        except Exception as e:
            sys.stderr.write(f"[ERROR] Misslyckades för {f}: {e}\n")

    return 0 if any_done else 2

if __name__ == '__main__':
    sys.exit(main())
