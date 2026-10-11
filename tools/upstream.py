#!/usr/bin/env python3
"""Pinned upstream consumer; private data and credentials never enter Git."""

import argparse
import json
import os
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LOCK = ROOT / "upstream.lock.json"


def read_lock():
    data = json.loads(LOCK.read_text())
    source = data["nacre"]
    if (
        data["version"] != 1
        or source["repository"] != "https://github.com/nacre-desktop/nacre.git"
        or not re.fullmatch(r"[0-9a-f]{40}", source["revision"])
    ):
        raise ValueError("Invalid pinned Nacre source")
    return data


def checkout(data):
    source = data["nacre"]
    cache = Path.home() / ".local/share/siverteh-os/upstream/nacre" / source["revision"]
    if not (cache / ".git").exists():
        cache.parent.mkdir(parents=True, exist_ok=True)
        subprocess.run(
            ["git", "clone", "--no-checkout", source["repository"], str(cache)],
            check=True,
        )
        subprocess.run(
            ["git", "-C", str(cache), "checkout", "--detach", source["revision"]],
            check=True,
        )
        subprocess.run(
            ["git", "-C", str(cache), "submodule", "update", "--init", "--recursive"],
            check=True,
        )
    revision = subprocess.check_output(
        ["git", "-C", str(cache), "rev-parse", "HEAD"], text=True
    ).strip()
    dirty = subprocess.check_output(
        ["git", "-C", str(cache), "status", "--porcelain"], text=True
    ).strip()
    if revision != source["revision"] or dirty:
        raise RuntimeError(
            "Cached upstream checkout is modified; preserve it and use a fresh cache"
        )
    return cache


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("status")
    update = sub.add_parser("pin")
    update.add_argument(
        "reference", help="Explicit tag/branch to resolve to an immutable commit"
    )
    install = sub.add_parser("install")
    install.add_argument("--apply", action="store_true")
    install.add_argument("--prepare", type=Path)
    install.add_argument(
        "--profile", default="siverteh", choices=("siverteh", "default")
    )
    install.add_argument(
        "--component",
        action="append",
        choices=("configs", "apps", "shell", "ai", "brain"),
    )
    install.add_argument("--migrate-owned", action="store_true")
    args = parser.parse_args()
    data = read_lock()
    if args.command == "status":
        print(json.dumps(data, indent=2))
        return
    if args.command == "pin":
        if not re.fullmatch(
            r"[A-Za-z0-9._/-]{1,100}", args.reference
        ) or args.reference.startswith("-"):
            raise ValueError("Invalid explicit reference")
        lines = subprocess.check_output(
            [
                "git",
                "ls-remote",
                data["nacre"]["repository"],
                args.reference,
                "refs/tags/" + args.reference + "^{}",
            ],
            text=True,
        ).splitlines()
        if not lines:
            raise ValueError("Reference not found")
        # Prefer the peeled commit for annotated tags.
        selected = next((line for line in lines if line.endswith("^{}")), lines[0])
        revision = selected.split()[0]
        if not re.fullmatch(r"[0-9a-f]{40}", revision):
            raise ValueError("Invalid resolved commit")
        data["nacre"].update(revision=revision, reference=args.reference)
        pending = LOCK.with_suffix(".next")
        pending.write_text(json.dumps(data, indent=2) + "\n")
        os.replace(pending, LOCK)
        print(
            "Pinned " + revision + ". Run checks/prepare and commit before deployment."
        )
        return
    source = checkout(data)
    profile = (
        ROOT / "profiles/siverteh.json"
        if args.profile == "siverteh"
        else source / "profiles/default.json"
    )
    command = [str(source / "install.sh"), "--profile", str(profile)]
    if args.apply:
        command.append("--apply")
    if args.prepare:
        command += ["--prepare", str(args.prepare)]
    if args.migrate_owned:
        command.append("--migrate-owned")
    for component in args.component or []:
        command += ["--component", component]
    subprocess.run(command, check=True)


if __name__ == "__main__":
    main()
