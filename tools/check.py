#!/usr/bin/env python3
"""Consumer integrity; upstream owns desktop/engine regression suites."""

import ast
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from upstream import read_lock, checkout, general_profile


def main():
    for path in ROOT.rglob("*.py"):
        ast.parse(path.read_text(), filename=str(path))
    data = read_lock()
    profile = json.loads((ROOT / "profiles/siverteh.json").read_text())
    assert profile["id"] == "siverteh" and profile["version"] == 1
    assert profile["aiFullAccess"] is True
    assert profile["workspaceCount"] == len(profile["workspaceIcons"])
    assert set(profile["components"]) == {"configs", "shell", "ai", "brain"}
    source = checkout(data)
    general = general_profile(source)
    default = json.loads((source / "profiles/default.json").read_text())
    for key in set(default) - {"components", "aiFullAccess"}:
        assert general[key] == default[key]
    assert set(general["components"]) == {"configs", "shell", "ai", "brain"}
    assert general["aiFullAccess"] is True
    subprocess.run(
        [sys.executable, str(ROOT / "tools/upstream.py"), "status"],
        check=True,
        stdout=subprocess.DEVNULL,
    )
    print(
        "General/default inheritance, retained optional apps, legacy profile and source pin passed: "
        + data["nacre"]["revision"]
    )


if __name__ == "__main__":
    main()
