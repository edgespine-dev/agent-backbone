#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import ast
import argparse
import json
import os
import re
import sys
from typing import Any, Dict, List, Optional, Tuple, Union

# -----------------------------
# Redaction heuristics
# -----------------------------

REDACTION_PATTERNS = [
    # AWS Access Key
    re.compile(r'AKIA[0-9A-Z]{16}'),
    # Google API Key
    re.compile(r'AIza[0-9A-Za-z\-_]{35}'),
    # GitHub PAT
    re.compile(r'ghp_[A-Za-z0-9]{36,}'),
    # Slack tokens
    re.compile(r'xox[abprs]-[A-Za-z0-9\-]+'),
    # OpenAI-like
    re.compile(r'sk-[A-Za-z0-9]{32,}'),
    # JWT (grov)
    re.compile(r'eyJ[a-zA-Z0-9_\-]{10,}\.[a-zA-Z0-9_\-]{10,}\.[a-zA-Z0-9_\-]{10,}'),
    # Generic "api_key|token|secret|password = '...'" (case-insensitive)
    re.compile(r'(?i)(api[_-]?key|token|secret|password)\s*[:=]\s*["\']([^"\'
    # Långa hexsträngar
    re.compile(r'\b[0-9a-fA-F]{32,}\b'),
]

def redact(text: Optional[str]) -> Optional[str]:
    if not text:
        return text
    red = text
    for pat in REDACTION_PATTERNS:
        if pat.flags & re.IGNORECASE and pat.pattern.find('=') != -1:
            # preserve the key name, redact only the value (group 2)
            red = pat.sub(lambda m: f'{m.group(1)}="***REDACTED***"', red)
        else:
            red = pat.sub('***REDACTED***', red)
    return red

# -----------------------------
# AST helpers
# -----------------------------

def safe_unparse(node: Optional[ast.AST]) -> Optional[str]:
    if node is None:
        return None
    try:
        # Python 3.9+
        src = ast.unparse(node)  # type: ignore[attr-defined]
        return src
    except Exception:
        try:
            return ast.dump(node, annotate_fields=False)
        except Exception:
            return None

def constant_preview(node: ast.AST) -> str:
    """
    Returnera en säker, kort representation av en default/literal utan att exekvera någonting.
    """
    if isinstance(node, ast.Constant):
        val = node.value
        if isinstance(val, str):
            s = redact(val) or ''
            if len(s) > 64:
                return f"str(len={len(s)}) {s[:32]!r}…"
            return f"str {s!r}"
        if isinstance(val, bytes):
            return f"bytes(len={len(val)})"
        if isinstance(val, (int, float, complex, bool)) or val is None:
            return repr(val)
        return f"const:{type(val).__name__}"
    # försök unparse men korta
    txt = safe_unparse(node) or type(node).__name__
    if len(txt) > 80:
        txt = txt[:77] + "…"
    return txt

def arg_to_dict(arg: ast.arg, default: Optional[ast.AST], ann: Optional[ast.AST]) -> Dict[str, Any]:
    item: Dict[str, Any] = {"name": arg.arg}
    if ann is not None:
        item["annotation"] = safe_unparse(ann)
    if default is not None:
        item["default"] = constant_preview(default)
        if isinstance(default, ast.Constant) and isinstance(default.value, str):
            item["default"] = redact(item["default"])
    return item

def get_docstring_summary(node: ast.AST, full: bool, max_lines: int) -> Optional[str]:
    ds = ast.get_docstring(node)
    if not ds:
        return None
    ds = ds.replace('\r\n', '\n')
    # Ta första stycket om summary-läge
    if not full:
        parts = ds.strip().split("\n\n", 1)
        ds = parts[0]
    # Begränsa antal rader
    lines = ds.splitlines()
    ds = "\n".join(lines[:max_lines]).strip()
    # Ta bort typiska kodstaket
    ds = re.sub(r"```.*?```", "", ds, flags=re.DOTALL)
    ds = re.sub(r"`([^`]+)`", r"\1", ds)
    # Redactera
    return redact(ds)

def is_public(name: str) -> bool:
    # publik = inte börjar med _  (men __init__ metoder räknas när klassen är publik)
    return not name.startswith("_")

def extract___all__(module: ast.Module) -> Optional[set]:
    names = set()
    for node in module.body:
        if isinstance(node, ast.Assign):
            for t in node.targets:
                if isinstance(t, ast.Name) and t.id == "__all__":
                    if isinstance(node.value, (ast.List, ast.Tuple, ast.Set)):
                        for elt in node.value.elts:
                            if isinstance(elt, ast.Constant) and isinstance(elt.value, str):
                                names.add(elt.value)
                        return names
    return None

# -----------------------------
# Extractors
# -----------------------------

def parse_function(node: ast.FunctionDef, doc_mode: str, max_doc_lines: int) -> Dict[str, Any]:
    args = node.args
    params: List[Dict[str, Any]] = []

    # Positional-only (Py3.8+)
    posonly = getattr(args, "posonlyargs", [])
    defaults = list(args.defaults)
    # match defaults to args (only for positional-or-keyword)
    pos_args = posonly + args.args
    num_defaults = len(defaults)
    first_default_idx = len(pos_args) - num_defaults

    for idx, a in enumerate(pos_args):
        default = defaults[idx - first_default_idx] if idx >= first_default_idx else None
        params.append(arg_to_dict(a, default, a.annotation))

    # varargs *args
    if args.vararg:
        params.append({"name": f"*{args.vararg.arg}", "annotation": safe_unparse(args.vararg.annotation)})

    # kwonly
    for a, d in zip(args.kwonlyargs, args.kw_defaults):
        params.append(arg_to_dict(a, d, a.annotation))

    # kwargs **kw
    if args.kwarg:
        params.append({"name": f"**{args.kwarg.arg}", "annotation": safe_unparse(args.kwarg.annotation)})

    out: Dict[str, Any] = {
        "name": node.name,
        "lineno": node.lineno,
        "parameters": params,
    }
    if node.returns is not None:
        out["returns"] = safe_unparse(node.returns)

    if doc_mode != "none":
        out["doc"] = get_docstring_summary(node, full=(doc_mode == "full"), max_lines=max_doc_lines)

    decos = [safe_unparse(d) for d in node.decorator_list] if node.decorator_list else []
    if decos:
        out["decorators"] = decos

    return out

def parse_class(node: ast.ClassDef, doc_mode: str, max_doc_lines: int, include_private: bool) -> Dict[str, Any]:
    bases = [safe_unparse(b) for b in node.bases] if node.bases else []
    methods: List[Dict[str, Any]] = []
    for b in node.body:
        if isinstance(b, ast.FunctionDef):
            if include_private or is_public(b.name) or b.name == "__init__":
                methods.append(parse_function(b, doc_mode, max_doc_lines))
    klass: Dict[str, Any] = {
        "name": node.name,
        "lineno": node.lineno,
        "bases": bases,
        "methods": methods,
    }
    if doc_mode != "none":
        klass["doc"] = get_docstring_summary(node, full=(doc_mode == "full"), max_lines=max_doc_lines)
    return klass

def parse_constants(module: ast.Module) -> List[Dict[str, Any]]:
    consts: List[Dict[str, Any]] = []
    for node in module.body:
        if isinstance(node, ast.Assign):
            if len(node.targets) != 1:
                continue
            t = node.targets[0]
            if isinstance(t, ast.Name) and t.id.isupper() and isinstance(node.value, ast.AST):
                preview = constant_preview(node.value)
                if isinstance(node.value, ast.Constant) and isinstance(node.value.value, str):
                    preview = redact(preview)
                consts.append({
                    "name": t.id,
                    "lineno": node.lineno,
                    "value": preview
                })
    return consts

def extract_api_from_source(source: str, doc_mode: str, include_private: bool, max_doc_lines: int) -> Dict[str, Any]:
    tree = ast.parse(source)
    exports = extract___all__(tree)
    functions: List[Dict[str, Any]] = []
    classes: List[Dict[str, Any]] = []

    def visible(name: str) -> bool:
        if include_private:
            return True
        if exports is not None:
            return name in exports
        return is_public(name)

    for node in tree.body:
        if isinstance(node, ast.FunctionDef) and visible(node.name):
            functions.append(parse_function(node, doc_mode, max_doc_lines))
        elif isinstance(node, ast.ClassDef) and visible(node.name):
            classes.append(parse_class(node, doc_mode, max_doc_lines, include_private=include_private))

    constants = parse_constants(tree)

    out = {
        "functions": functions,
        "classes": classes,
        "constants": constants,
    }
    if exports is not None:
        out["__all__"] = sorted(list(exports))
    return out

# -----------------------------
# Markdown rendering
# -----------------------------

def render_md(module_path: str, api: Dict[str, Any]) -> str:
    rel = os.path.basename(module_path)
    lines: List[str] = [f"# API – {rel}", ""]
    if "__all__" in api:
        lines += ["**Exporterade symboler**: " + ", ".join(api["__all__"]), ""]

    if api.get("constants"):
        lines += ["## Konstanter", ""]
        for c in api["constants"]:
            lines.append(f"- `{c['name']}` (rad {c['lineno']}): {c['value']}")
        lines.append("")

    if api.get("functions"):
        lines += ["## Funktioner", ""]
        for f in api["functions"]:
            sig_parts = []
            for p in f.get("parameters", []):
                name = p["name"]
                ann = p.get("annotation")
                default = p.get("default")
                part = name
                if ann:
                    part += f": {ann}"
                if default is not None:
                    part += f" = {default}"
                sig_parts.append(part)
            ret = f.get("returns")
            sig = f"{f['name']}({', '.join(sig_parts)})"
            if ret:
                sig += f" -> {ret}"
            lines.append(f"### `{sig}`  *(rad {f['lineno']})*")
            if f.get("decorators"):
                lines.append(f"- Dekoratorer: {', '.join(f['decorators'])}")
            if f.get("doc"):
                lines.append("")
                lines.append(f"{f['doc']}")
            lines.append("")
    if api.get("classes"):
        lines += ["## Klasser", ""]
        for c in api["classes"]:
            bases = f"({', '.join([b for b in c.get('bases', []) if b])})" if c.get("bases") else ""
            lines.append(f"### `{c['name']}{bases}`  *(rad {c['lineno']})*")
            if c.get("doc"):
                lines.append("")
                lines.append(c["doc"])
                lines.append("")
            if c.get("methods"):
                lines.append("#### Metoder")
                lines.append("")
                for m in c["methods"]:
                    sig_parts = []
                    for p in m.get("parameters", []):
                        name = p["name"]
                        ann = p.get("annotation")
                        default = p.get("default")
                        part = name
                        if ann:
                            part += f": {ann}"
                        if default is not None:
                            part += f" = {default}"
                        sig_parts.append(part)
                    ret = m.get("returns")
                    sig = f"{m['name']}({', '.join(sig_parts)})"
                    if ret:
                        sig += f" -> {ret}"
                    lines.append(f"- `{sig}` *(rad {m['lineno']})*")
                    if m.get("decorators"):
                        lines.append(f"  - Dekoratorer: {', '.join(m['decorators'])}")
                    if m.get("doc"):
                        lines.append(f"  - {m['doc']}")
                lines.append("")
    return "\n".join(lines).rstrip() + "\n"

# -----------------------------
# CLI
# -----------------------------

def process_path(path: str, doc_mode: str, include_private: bool, max_doc_lines: int, out_format: str) -> List[Tuple[str, Dict[str, Any], str]]:
    results: List[Tuple[str, Dict[str, Any], str]] = []
    files: List[str] = []
    if os.path.isdir(path):
        for root, _, fnames in os.walk(path):
            for fn in fnames:
                if fn.endswith(".py"):
                    files.append(os.path.join(root, fn))
    else:
        files.append(path)

    for fpath in sorted(files):
        try:
            with open(fpath, "r", encoding="utf-8", errors="replace") as fh:
                source = fh.read()
            api = extract_api_from_source(source, doc_mode=doc_mode, include_private=include_private, max_doc_lines=max_doc_lines)
            md = render_md(fpath, api) if out_format in ("md", "both") else ""
            results.append((fpath, api, md))
        except SyntaxError as e:
            sys.stderr.write(f"[WARN] SyntaxError i {fpath}: {e}\n")
        except Exception as e:
            sys.stderr.write(f"[WARN] Fel i {fpath}: {e}\n")
    return results

def main():
    p = argparse.ArgumentParser(
        description="Extrahera API (signaturer, typer, docstrings) ur Python-kod utan att exekvera den."
    )
    p.add_argument("path", help="Fil eller katalog att analysera")
    p.add_argument("-f", "--format", choices=["json", "md", "both"], default="both", help="Utdataformat")
    p.add_argument("--docstrings", choices=["none", "summary", "full"], default="summary", help="Docstring-nivå")
    p.add_argument("--include-private", action="store_true", help="Inkludera privata namn (som börjar med _)")
    p.add_argument("--max-doc-lines", type=int, default=12, help="Max antal rader docstring att ta med")
    args = p.parse_args()

    results = process_path(
        path=args.path,
        doc_mode=args.docstrings,
        include_private=args.include_private,
        max_doc_lines=args.max_doc_lines,
        out_format=args.format,
    )

    if args.format in ("json", "both"):
        payload = {
            "results": [
                {
                    "file": fpath,
                    "api": api
                } for (fpath, api, _) in results
            ]
        }
        print(json.dumps(payload, ensure_ascii=False, indent=2))

    if args.format in ("md", "both"):
        for (fpath, _, md) in results:
            if md:
                # Avgränsa flera filer
                if args.format == "both":
                    print("\n" + "#" * 80 + "\n")
                print(md)

if __name__ == "__main__":
    main()
