#!/usr/bin/env python3
"""One-off generator for charts/freeradius/values.schema.json.

Walks values.yaml and emits a JSON Schema draft-07 document matching
the convention used by charts/adminer/values.schema.json: type-only,
no descriptions, no constraints, no `required`. Empty objects use
`properties: {}`; arrays use `items` only when entries share a single
scalar type.

This is a build-time helper, not shipped with the chart. Re-run after
material values.yaml changes:

    python3 charts/freeradius/.gen-values-schema.py
"""
from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import Any

import yaml


def scalar_type(value: Any) -> str | None:
    if isinstance(value, bool):
        return "boolean"
    if isinstance(value, int):
        return "integer"
    if isinstance(value, float):
        return "number"
    if isinstance(value, str):
        return "string"
    return None


def is_port_context(key: str | None, parent_key: str | None) -> bool:
    """True for keys that idiomatically hold a TCP/UDP port number.

    Catches direct port fields (`port`, `nodePort`, `targetPort`,
    `containerPort`) and children of *Ports / nodePorts containers
    (`service.nodePorts.auth`, `containerPorts.acct`). When the chart
    default is `""` (sentinel for "not set"), users naturally override
    with an integer — schema must accept both shapes.
    """
    if key:
        lowered = key.lower()
        if lowered == "port" or lowered.endswith("port"):
            return True
    if parent_key:
        plowered = parent_key.lower()
        if plowered == "ports" or plowered == "nodeports" or plowered.endswith("ports"):
            return True
    return False


def schema_for(
    value: Any,
    key: str | None = None,
    parent_key: str | None = None,
) -> dict[str, Any]:
    if isinstance(value, dict):
        node: dict[str, Any] = {"type": "object"}
        node["properties"] = {
            k: schema_for(v, key=k, parent_key=key) for k, v in value.items()
        }
        return node
    if isinstance(value, list):
        node = {"type": "array"}
        if value:
            scalar_kinds = {scalar_type(item) for item in value if not isinstance(item, (dict, list))}
            if scalar_kinds and len(scalar_kinds) == 1 and not any(
                isinstance(item, (dict, list)) for item in value
            ):
                node["items"] = {"type": scalar_kinds.pop()}
        return node
    if value is None:
        # Nullable placeholder (typically `~` in values.yaml for things
        # like `existingGateway`, `existingVirtualService`). Allow both
        # null (the default) AND string (any override the user supplies)
        # so `helm lint` accepts both the shipped defaults and overrides.
        return {"type": ["string", "null"]}
    if value == "" and is_port_context(key, parent_key):
        return {"type": ["string", "integer"]}
    return {"type": scalar_type(value) or "string"}


def main() -> int:
    repo_root = Path(__file__).resolve().parent
    values_path = repo_root / "values.yaml"
    schema_path = repo_root / "values.schema.json"

    with values_path.open("r", encoding="utf-8") as fh:
        values = yaml.safe_load(fh) or {}

    schema = {
        "$schema": "http://json-schema.org/draft-07/schema#",
        "type": "object",
        "properties": {k: schema_for(v) for k, v in values.items()},
    }

    with schema_path.open("w", encoding="utf-8", newline="\n") as fh:
        json.dump(schema, fh, indent=2)
        fh.write("\n")

    print(f"wrote {schema_path} ({schema_path.stat().st_size} bytes)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
