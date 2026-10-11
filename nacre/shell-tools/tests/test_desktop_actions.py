import importlib.util
import json
import tempfile
from pathlib import Path
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location(
    "desktop_commands", Path(__file__).parents[1] / "desktop-actions.py"
)
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)


class DesktopActionTests(unittest.TestCase):
    def test_bounded_size_toggle_restores_geometry_and_ordinary_apps_still_maximize(
        self,
    ):
        client = {
            "address": "0x123",
            "stableId": "unique",
            "pid": 42,
            "title": "Nacre Welcome",
            "class": "org.quickshell",
            "monitor": 0,
            "floating": True,
            "fullscreen": 0,
            "size": [920, 680],
            "at": [500, 280],
        }
        monitor = {
            "id": 0,
            "width": 2880,
            "height": 1800,
            "scale": 1.5,
            "reserved": [10, 50, 10, 10],
            "x": 0,
            "y": 0,
        }
        calls = []

        def run(args, *a):
            if args[1] == "activewindow":
                return json.dumps(client)
            if args[1] == "monitors":
                return json.dumps([monitor])
            calls.append(args[-1])
            return ""

        with (
            tempfile.TemporaryDirectory() as folder,
            patch.object(m, "HOME", Path(folder)),
            patch.object(m, "run", side_effect=run),
        ):
            m.maximize()
            self.assertIn("x=1020,y=740", calls[-1])
            self.assertNotIn('action="toggle"', calls[-1])
            m.maximize()
            self.assertIn("x=920,y=680", calls[-1])
            self.assertIn("x=500,y=280", calls[-1])
            self.assertEqual(
                json.loads(
                    (
                        Path(folder) / ".local/state/nacre/window-sizes/windows.json"
                    ).read_text()
                ),
                {},
            )
            client["title"] = "Browser"
            m.maximize()
            self.assertIn('mode="maximized"', calls[-1])
            self.assertNotIn("resize", calls[-1])

    def test_bounded_geometry_handles_small_rotated_and_offset_monitors(self):
        client = {"title": "Nacre Colors"}
        for monitor in [
            {
                "width": 1280,
                "height": 800,
                "scale": 1.5,
                "reserved": [0, 40, 0, 0],
                "x": 1920,
                "y": 0,
            },
            {
                "width": 1920,
                "height": 1080,
                "scale": 1,
                "transform": 1,
                "reserved": [0, 0, 0, 0],
                "x": -1080,
                "y": 0,
            },
        ]:
            x, y, w, h = m.bounded_geometry(client, monitor)
            a = m.workarea(monitor)
            self.assertGreaterEqual(x, a[0])
            self.assertGreaterEqual(y, a[1])
            self.assertLessEqual(x + w, a[0] + a[2])
            self.assertLessEqual(y + h, a[1] + a[3])

    def test_update_and_lock_routes_do_not_import_or_launch_brain(self):
        with patch.object(m, "launch_app") as launch:
            m.action("updates")
            self.assertEqual(
                launch.call_args.args[0][-1],
                str(m.HOME / ".local/share/nacre/shell/tools/updates.sh"),
            )
            m.action("lock")
            self.assertEqual(launch.call_args.args[0], ["loginctl", "lock-session"])

    def test_window_and_volume_commands_remain_bounded(self):
        with patch.object(m, "run") as run:
            with self.assertRaises(ValueError):
                m.action("focus", '"; injected')
            with self.assertRaises(ValueError):
                m.action("workspace", "99")
            run.assert_not_called()
            m.action("volume", "500")
            self.assertIn("100%", run.call_args.args[0])

    def test_unknown_command_cannot_become_a_shell_command(self):
        with self.assertRaises(ValueError):
            m.action("shell", "anything")
