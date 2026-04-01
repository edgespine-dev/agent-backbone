#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
read_secret_code.py — Minimal, säkert API-utdrag för AI‑agenter

Mål: 1) Agentisk API‑beskrivning, 2) Exakta definitioner (signaturer) med typer
(om de finns) + små exempel. Ingen nätverksanvändning. Ingen exekvering av
modulen som standard (AST‑parsing). Alternativ flagga --import kan ge extra info
(typ- och runtimevärden) men KAN köra top‑level‑kod; använd endast om säkert.
"""

import ast
import argparse
import os
import sys
from typing import Any, Dict, List, Optional

# -----------------------------
# Små hjälpare
# -----------------------------
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

def const_preview(node: ast.AST) -> str:
    if isinstance(node, ast.Constant):
        v = node.value
        if isinstance(v, str):
            s = v.replace("\n", "\\n")
            if len(s) > 60:
                return f"str(len={len(v)}) '{s[:30]}…'"
            return repr(v)
        if isinstance(v, bytes):
            return f"bytes(len={len(v)})"
        return repr(v)
    text = unparse(node) or type(node).__name__
    if text and len(text) > 80:
        text = text[:77] + '…'
    return text

def is_public(name: str) -> bool:
    return not name.startswith('_')

# -----------------------------
# AST → API
# -----------------------------
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
            'ann': unparse(arg.annotation),
            'default': const_preview(default) if default is not None else None,
        })

    if a.vararg:
        params.append({'name': f"*{a.vararg.arg}", 'ann': unparse(a.vararg.annotation), 'default': None})

    for ka, kd in zip(a.kwonlyargs, a.kw_defaults):
        params.append({'name': ka.arg, 'ann': unparse(ka.annotation), 'default': const_preview(kd) if kd is not None else None})

    if a.kwarg:
        params.append({'name': f"**{a.kwarg.arg}", 'ann': unparse(a.kwarg.annotation), 'default': None})

    doc = ast.get_docstring(fn)
    if doc:
        doc = doc.strip().split('\n\n', 1)[0].strip()

    return {
        'kind': 'function',
        'name': fn.name,
        'lineno': fn.lineno,
        'returns': unparse(fn.returns),
        'params': params,
        'doc_first': doc,
        'decorators': [unparse(d) for d in fn.decorator_list] if fn.decorator_list else [],
    }

def parse_class(klass: ast.ClassDef) -> Dict[str, Any]:
    methods: List[Dict[str, Any]] = []
    for n in klass.body:
        if isinstance(n, ast.FunctionDef) and (is_public(n.name) or n.name == '__init__'):
            methods.append(parse_function(n))
    doc = ast.get_docstring(klass)
    if doc:
        doc = doc.strip().split('\n\n', 1)[0].strip()
    return {
        'kind': 'class',
        'name': klass.name,
        'lineno': klass.lineno,
        'bases': [unparse(b) for b in klass.bases] if klass.bases else [],
        'doc_first': doc,
        'methods': methods,
    }

def parse_constants(module: ast.Module) -> List[Dict[str, Any]]:
    out: List[Dict[str, Any]] = []
    for n in module.body:
        if isinstance(n, ast.Assign) and len(n.targets) == 1 and isinstance(n.targets[0], ast.Name):
            name = n.targets[0].id
            if name.isupper():
                out.append({'name': name, 'lineno': n.lineno, 'value': const_preview(n.value)})
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

# -----------------------------
# Exempelskapare (heuristisk, enkel)
# -----------------------------
def example_for_type(ann: Optional[str], name: str) -> str:
    a = (ann or '').replace(' ', '')
    lname = name.lower()
    if a in {'str', 'builtins.str'} or 'str' in a:
        if any(k in lname for k in ['path', 'file', 'dir']):
            return '"/path/to/file"'
        if 'query' in lname:
            return '"""SELECT …"""'
        return '"text"'
    if a in {'int', 'builtins.int'} or 'int' in a:
        return '0'
    if a in {'float', 'builtins.float'} or 'float' in a:
        return '0.0'
    if a in {'bool', 'builtins.bool'} or 'bool' in a:
        return 'False'
    if 'list[' in a or a.startswith('list') or a.startswith('typing.List'):
        return '[]'
    if 'dict[' in a or a.startswith('dict') or a.startswith('typing.Dict'):
        return '{}'
    if a.endswith('None') or a == 'None':
        return 'None'
    # fallback
    return '…'

def build_signature(fn: Dict[str, Any]) -> str:
    parts: List[str] = []
    for p in fn['params']:
        seg = p['name']
        if p.get('ann'):
            seg += f": {p['ann']}"
        if p.get('default') is not None:
            seg += f" = {p['default']}"
        parts.append(seg)
    sig = f"{fn['name']}({', '.join(parts)})"
    if fn.get('returns'):
        sig += f" -> {fn['returns']}"
    return sig

def render_markdown(module_path: str, api: Dict[str, Any]) -> str:
    title = os.path.basename(module_path)
    lines: List[str] = [f"# Agentisk API – {title}", "", "## 1) Agentisk sammanfattning", ""]

    if api['functions']:
        for fn in api['functions']:
            sig = build_signature(fn)
            lines.append(f"### `{sig}`  (rad {fn['lineno']})")
            if fn.get('doc_first'):
                lines.append(fn['doc_first'])
            else:
                lines.append("*(Ingen docstring)*")
            # Minimalt exempel (keyword‑anrop)
            args_ex = []
            for p in fn['params']:
                # hoppa över *args/**kwargs i exempelrad
                if p['name'].startswith('*'):
                    continue
                args_ex.append(f"{p['name']}={example_for_type(p.get('ann'), p['name'])}")
            lines.append("")
            lines.append("**Exempel**:")
            lines.append("```python")
            lines.append(f"from MODULE import {fn['name']}")
            lines.append(f"result = {fn['name']}({', '.join(args_ex)})")
            lines.append("print(result)")
            lines.append("```")
            lines.append("")

    if api['classes']:
        lines += ["## Klasser (översikt)", ""]
        for cl in api['classes']:
            bases = f"({', '.join([b for b in cl.get('bases', []) if b])})" if cl.get('bases') else ''
            lines.append(f"### `{cl['name']}{bases}`  (rad {cl['lineno']})")
            if cl.get('doc_first'):
                lines.append(cl['doc_first'])
            if cl.get('methods'):
                lines.append("")
                lines.append("Metoder:")
                for m in cl['methods']:
                    lines.append(f"- `{build_signature(m)}`")
                lines.append("")

    if api['constants']:
        lines += ["## Konstanter (översikt)", ""]
        for c in api['constants']:
            lines.append(f"- `{c['name']}` = {c['value']}  *(rad {c['lineno']})*")
        lines.append("")

    lines += ["## 2) API‑specifikationer (exakta signaturer)", ""]

    if api['functions']:
        lines.append("### Funktioner")
        lines.append("")
        for fn in api['functions']:
            lines.append(f"- `{build_signature(fn)}` *(rad {fn['lineno']})*")
        lines.append("")

    if api['classes']:
        lines.append("### Klasser och metoder")
        lines.append("")
        for cl in api['classes']:
            lines.append(f"- `{cl['name']}` *(rad {cl['lineno']})*")
            for m in cl['methods']:
                lines.append(f"  - `{build_signature(m)}` *(rad {m['lineno']})*")
        lines.append("")

    if api['constants']:
        lines.append("### Konstanter")
        lines.append("")
        for c in api['constants']:
            lines.append(f"- `{c['name']}` = {c['value']} *(rad {c['lineno']})*")
        lines.append("")

    return "\n".join(lines).rstrip() + "\n"

# -----------------------------
# CLI
# -----------------------------
def main(argv: Optional[List[str]] = None) -> int:
    p = argparse.ArgumentParser(
        description="Extrahera ett komprimerat, agentvänligt API i Markdown från en Python‑fil/katalog utan att exekvera koden.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    p.add_argument('path', help='Fil eller katalog att analysera')
    p.add_argument('--import', dest='do_import', action='store_true', help='(Avancerat) Försök importera för runtime‑typer (KAN köra top‑level‑kod)')
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
            md = render_markdown(f, api)
            # Om flera filer, separera
            if any_done:
                print('\n' + ('#' * 80) + '\n')
            print(md)
            any_done = True
        except SyntaxError as e:
            sys.stderr.write(f"[WARN] Syntaxfel i {f}: {e}\n")
        except Exception as e:
            sys.stderr.write(f"[ERROR] Misslyckades för {f}: {e}\n")

    return 0 if any_done else 2

if __name__ == '__main__':
    sys.exit(main())
