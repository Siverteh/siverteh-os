#!/usr/bin/env python3
"""Desktop and AI launch commands, independent of the private knowledge browser."""

import argparse
import fcntl
import tempfile
import json
import os
from pathlib import Path
import re
import subprocess
import sys

HOME = Path.home()


def run(command, default=None, timeout=10):
    result = subprocess.run(command, capture_output=True, text=True, timeout=timeout)
    if result.returncode:
        if default is not None:
            return default
        raise RuntimeError(result.stderr.strip() or "Desktop command failed")
    return result.stdout.strip()


def launch(command):
    subprocess.Popen(
        ["uwsm", "app", "--", *command],
        start_new_session=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


launch_app = launch


APP_LIMITS = {
    "Nacre Welcome": (1020, 740),
    "Nacre Settings": (1160, 820),
    "Nacre Colors": (1200, 850),
    "Nacre Brain": (1160, 820),
    "Nacre AI": (1100, 800),
}


def workarea(monitor):
    scale = monitor.get("scale", 1) or 1
    width, height = monitor["width"] / scale, monitor["height"] / scale
    if monitor.get("transform", 0) % 2:
        width, height = height, width
    left, top, right, bottom = monitor.get("reserved", [0, 0, 0, 0])
    return (
        monitor.get("x", 0) + left + 16,
        monitor.get("y", 0) + top + 16,
        max(1, width - left - right - 32),
        max(1, height - top - bottom - 32),
    )


def bounded_geometry(client, monitor, size=None):
    x, y, available_w, available_h = workarea(monitor)
    limits = size or APP_LIMITS[client["title"]]
    width, height = (
        int(min(limits[0], available_w * 0.84)),
        int(min(limits[1], available_h * 0.85)),
    )
    return [
        int(x + (available_w - width) / 2),
        int(y + (available_h - height) / 2),
        width,
        height,
    ]


def maximize():
    """Use a reversible reading size for Nacre apps, normal maximize elsewhere."""
    client = json.loads(run(["hyprctl", "activewindow", "-j"], "{}"))
    address = client.get("address", "")
    if not re.fullmatch(r"0x[0-9a-fA-F]+", address):
        return
    window = json.dumps("address:" + address)
    title = client.get("title", "")
    is_app = title in APP_LIMITS and (
        client.get("class") == "org.quickshell" or title in ("Nacre Brain", "Nacre AI")
    )
    if not is_app:
        run(
            [
                "hyprctl",
                "eval",
                f'hl.dispatch(hl.dsp.window.fullscreen({{mode="maximized",window={window}}}))',
            ]
        )
        return
    monitors = json.loads(run(["hyprctl", "monitors", "-j"]))
    monitor = next(item for item in monitors if item["id"] == client["monitor"])
    folder = HOME / ".local/state/nacre/window-sizes"
    folder.mkdir(parents=True, exist_ok=True)
    with (folder / "owner.lock").open("a") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        path = folder / "windows.json"
        data = json.loads(path.read_text()) if path.exists() else {}
        key = (
            str(client.get("stableId", address))
            + ":"
            + str(client.get("pid", 0))
            + ":"
            + title
        )
        previous = data.pop(key, None)
        if previous:
            area = workarea(monitor)
            geometry = [
                previous["at"][0],
                previous["at"][1],
                int(min(previous["size"][0], area[2])),
                int(min(previous["size"][1], area[3])),
            ]
            geometry[0], geometry[1] = previous["at"]
            area = workarea(monitor)
            geometry[0] = int(
                max(area[0], min(area[0] + area[2] - geometry[2], geometry[0]))
            )
            geometry[1] = int(
                max(area[1], min(area[1] + area[3] - geometry[3], geometry[1]))
            )
        else:
            previous = {
                "size": [min(client["size"][i], APP_LIMITS[title][i]) for i in range(2)]
                if client.get("fullscreen")
                else client["size"],
                "at": client["at"],
                "floating": client["floating"],
            }
            data[key] = previous
            geometry = bounded_geometry(client, monitor)
        x, y, width, height = geometry
        commands = [
            f'hl.dispatch(hl.dsp.window.fullscreen({{mode="maximized",action="unset",window={window}}}))',
            f'hl.dispatch(hl.dsp.window.fullscreen({{mode="fullscreen",action="unset",window={window}}}))',
        ]
        # This host's float dispatcher defaults to toggling, even with "set".
        # Toggle only from a known state, never an already-floating window.
        if not client["floating"]:
            commands.append(
                f'hl.dispatch(hl.dsp.window.float({{action="toggle",window={window}}}))'
            )
        commands += [
            f"hl.dispatch(hl.dsp.window.resize({{x={width},y={height},relative=false,window={window}}}))",
            f"hl.dispatch(hl.dsp.window.move({{x={x},y={y},relative=false,window={window}}}))",
        ]
        if key not in data and not previous["floating"]:
            commands.append(
                f'hl.dispatch(hl.dsp.window.float({{action="toggle",window={window}}}))'
            )
        lua = ";".join(commands)
        run(["hyprctl", "eval", lua])
        data = dict(list(data.items())[-24:])
        fd, temporary = tempfile.mkstemp(dir=folder)
        try:
            with os.fdopen(fd, "w") as stream:
                json.dump(data, stream)
            os.replace(temporary, path)
        finally:
            Path(temporary).unlink(missing_ok=True)


def action(name, value=""):
    if name == "maximize":
        return maximize()
    actions = {
        "network": ["nm-connection-editor"],
        "bluetooth": ["blueman-manager"],
        "updates": [
            "kitty",
            "--class",
            "nacre-control",
            "--title",
            "System updates",
            "--",
            "bash",
            str(HOME / ".local/share/nacre/shell/tools/updates.sh"),
        ],
        "audio": ["pavucontrol"],
        "notifications": [str(HOME / ".local/bin/nacre-settings"), "notifications"],
        "play": ["playerctl", "play-pause"],
        "next": ["playerctl", "next"],
        "previous": ["playerctl", "previous"],
        "mute": ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"],
        "lock": ["loginctl", "lock-session"],
        "power": [str(HOME / ".local/bin/nacre-shell"), "session"],
        "files": [str(HOME / ".local/bin/nacre-app"), "files"],
        "terminal": ["kitty"],
        "tasks": [
            "kitty",
            "--class",
            "siverteh-ai-dashboard",
            "--title",
            "Nacre AI",
            "--",
            "nacre-ai",
            "dashboard",
        ],
        "new": [
            "kitty",
            "--class",
            "siverteh-ai-task",
            "--title",
            "New chat",
            "--",
            "nacre-ai",
            "window",
            "--worker-command",
            "new",
        ],
        "resume": [
            "kitty",
            "--class",
            "siverteh-ai-task",
            "--title",
            "Resume task",
            "--",
            "nacre-ai",
            "window",
            "--worker-command",
            "latest",
        ],
    }
    if name in actions:
        if name == "tasks":
            clients = json.loads(run(["hyprctl", "clients", "-j"], "[]"))
            old = next(
                (c for c in clients if c["class"] == "siverteh-ai-dashboard"), None
            )
            if old:
                return action("focus", old["address"])
        launch_app(actions[name])
        if name in ("new", "resume", "tasks"):
            action("workspace", "2")
        return
    if name == "volume":
        run(
            [
                "wpctl",
                "set-volume",
                "@DEFAULT_AUDIO_SINK@",
                str(max(0, min(100, int(value)))) + "%",
            ]
        )
        return
    if name == "brightness":
        run(
            [
                str(HOME / ".local/share/nacre/shell/bin/qs"),
                "-c",
                "nacre",
                "ipc",
                "call",
                "brightness",
                "set",
                str(max(0.01, min(1, int(value) / 100))),
            ]
        )
        return
    if name == "workspace":
        num = int(value)
        if num not in range(1, 8):
            raise ValueError("Invalid workspace")
        run(
            [
                "hyprctl",
                "eval",
                f"hl.dispatch(hl.dsp.focus({{workspace={num},on_current_monitor=true}}))",
            ]
        )
        return
    if name == "focus":
        if not re.fullmatch(r"0x[0-9a-fA-F]+", value):
            raise ValueError("Invalid window")
        run(
            [
                "hyprctl",
                "eval",
                'hl.dispatch(hl.dsp.focus({window="address:' + value + '"}))',
            ]
        )
        return
    if name == "app-windows":
        ids = json.loads(value)
        if not isinstance(ids, list) or not all(
            isinstance(i, str) and re.fullmatch(r"0x[0-9a-fA-F]+", i) for i in ids
        ):
            raise ValueError("Invalid window group")
        clients = json.loads(run(["hyprctl", "clients", "-j"], "[]"))
        windows = sorted(
            (c for c in clients if c["address"] in ids),
            key=lambda c: (c["workspace"]["id"], c["title"]),
        )
        if len(windows) == 1:
            return action("focus", windows[0]["address"])
        if not windows:
            return
        labels = [
            str(c["workspace"]["id"]) + "  " + c["title"].replace("\n", " ")[:120]
            for c in windows
        ]
        try:
            choice = subprocess.check_output(
                ["rofi", "-dmenu", "-i", "-p", "Choose window", "-format", "i"],
                input="\n".join(labels),
                text=True,
                timeout=300,
            ).strip()
        except subprocess.SubprocessError:
            return
        if choice.isdigit() and int(choice) < len(windows):
            return action("focus", windows[int(choice)]["address"])
        return
    if name == "wifi":
        rows = []
        seen = set()
        for line in run(
            [
                "nmcli",
                "-t",
                "-f",
                "IN-USE,SSID,SIGNAL,SECURITY",
                "device",
                "wifi",
                "list",
                "--rescan",
                "no",
            ]
        ).splitlines():
            parts = re.split(r"(?<!\\):", line)
            if len(parts) < 4:
                continue
            active, ssid, signal, security = parts[:4]
            ssid = ssid.replace("\\:", ":").replace("\\\\", "\\")
            if not ssid or ssid in seen:
                continue
            seen.add(ssid)
            rows.append(
                (
                    ssid,
                    ("● " if active == "*" else "  ")
                    + ssid
                    + "   "
                    + signal
                    + "%"
                    + ("  " if security and security != "--" else ""),
                )
            )
        if not rows:
            launch(
                [
                    "kitty",
                    "--class",
                    "nacre-control",
                    "--title",
                    "Wi-Fi connections",
                    "--",
                    "nmtui-connect",
                ]
            )
            return
        try:
            choice = subprocess.check_output(
                ["rofi", "-dmenu", "-i", "-p", "Wi-Fi", "-format", "i"],
                input="\n".join(label for _, label in rows),
                text=True,
                timeout=300,
            ).strip()
        except subprocess.SubprocessError:
            return
        if choice.isdigit() and int(choice) < len(rows):
            # Native NetworkManager prompt owns credentials; never capture passwords.
            launch(
                [
                    "kitty",
                    "--class",
                    "nacre-control",
                    "--title",
                    "Connect Wi-Fi",
                    "--",
                    "nmcli",
                    "--ask",
                    "device",
                    "wifi",
                    "connect",
                    rows[int(choice)][0],
                ]
            )
        return
    raise ValueError("Unknown desktop action")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("action")
    parser.add_argument("value", nargs="?", default="")
    args = parser.parse_args()
    action(args.action, args.value)
