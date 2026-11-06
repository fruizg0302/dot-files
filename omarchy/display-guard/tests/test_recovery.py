import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
STOCK_BIN = Path("/usr/share/omarchy/bin")
USE_STOCK = os.environ.get("DISPLAY_GUARD_STOCK") == "1"

FAKE_COMMAND = """#!/usr/bin/python3
import json
import os
from pathlib import Path
import sys

state = json.loads(Path(os.environ["GUARD_TEST_STATE"]).read_text())
command = Path(sys.argv[0]).name
if command == "hyprctl":
    if sys.argv[1:] == ["monitors", "all", "-j"]:
        print(state.get("raw_monitors", json.dumps(state["monitors"])))
        sys.exit(state.get("query_exit", 0))
    if sys.argv[1:] == ["-j", "locked"]:
        print(state.get("raw_lock", json.dumps({"locked": state["locked"]})))
        sys.exit(state.get("lock_exit", 0))
    if sys.argv[1] not in ("eval", "dispatch"):
        raise SystemExit("Unexpected hyprctl call: " + repr(sys.argv[1:]))
elif command == "omarchy-hw-laptop-closed":
    sys.exit(0 if state["closed"] else 1)
elif command == "omarchy-hw-external-monitors":
    sys.exit(0 if state["connected"] else 1)
elif command == "omarchy-hyprland-monitor-laptop":
    print("eDP-1")
    sys.exit(0)
elif command in ("omarchy-hyprland-monitor-internal",
                 "omarchy-hyprland-monitor-internal-mirror"):
    sys.exit(0)
elif command != "omarchy-restart-hyprctl":
    raise SystemExit("Unexpected command: " + command)

with Path(os.environ["GUARD_TEST_EFFECTS"]).open("a") as log:
    log.write(command + " " + " ".join(sys.argv[1:]) + "\\n")
"""


def monitor(name, *, disabled=False, dpms=True, width=2560, height=1440):
    return {
        "id": 0 if name == "eDP-1" else 1,
        "name": name,
        "description": "Test display",
        "make": "Test",
        "model": "Test",
        "serial": "",
        "width": width,
        "height": height,
        "physicalWidth": 600,
        "physicalHeight": 330,
        "refreshRate": 60,
        "x": 0,
        "y": 0,
        "activeWorkspace": {"id": 1, "name": "1"},
        "specialWorkspace": {"id": 0, "name": ""},
        "reserved": [0, 0, 0, 0],
        "scale": 2,
        "transform": 0,
        "focused": name == "HDMI-A-1",
        "dpmsStatus": dpms,
        "vrr": False,
        "solitary": "0",
        "solitaryBlockedBy": [],
        "activelyTearing": False,
        "tearingBlockedBy": [],
        "directScanoutTo": "0",
        "directScanoutBlockedBy": [],
        "disabled": disabled,
        "currentFormat": "XRGB8888",
        "mirrorOf": "none",
        "availableModes": ["2560x1440@60.00Hz"] if width else [],
        "colorManagementPreset": "srgb",
        "sdrBrightness": 1,
        "sdrSaturation": 1,
        "sdrMinLuminance": 0.2,
        "sdrMaxLuminance": 80,
        "hardwareCursorsInUse": True,
    }


class RecoveryTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.home = Path(self.temporary.name)
        self.fake_bin = self.home / "bin"
        self.fake_bin.mkdir()
        for command in (
            "hyprctl",
            "omarchy-hw-laptop-closed",
            "omarchy-hw-external-monitors",
            "omarchy-hyprland-monitor-laptop",
            "omarchy-hyprland-monitor-internal",
            "omarchy-hyprland-monitor-internal-mirror",
            "omarchy-restart-hyprctl",
        ):
            path = self.fake_bin / command
            path.write_text(FAKE_COMMAND)
            path.chmod(0o755)

        self.flag = (
            self.home
            / ".local/state/omarchy/toggles/hypr/internal-monitor-clamshell.lua"
        )
        self.flag.parent.mkdir(parents=True)
        self.flag.write_text('hl.monitor({ output = "eDP-1", disabled = true })')
        config = self.home / ".config/hypr/monitors.lua"
        config.parent.mkdir(parents=True)
        config.write_text(
            'hl.monitor({ output = "eDP-1", mode = "preferred", '
            'position = "auto", scale = 2 })\n'
        )
        self.effects = self.home / "effects"
        self.state_path = self.home / "state.json"
        self.state = {
            "locked": True,
            "closed": True,
            "connected": True,
            "monitors": [monitor("eDP-1", disabled=True), monitor("HDMI-A-1")],
        }
        self.env = {
            **os.environ,
            "HOME": str(self.home),
            "OMARCHY_PATH": "/usr/share/omarchy",
            "PATH": f"{self.fake_bin}:{STOCK_BIN}:/usr/bin",
            "GUARD_TEST_STATE": str(self.state_path),
            "GUARD_TEST_EFFECTS": str(self.effects),
        }

    def run_recovery(self, name="clamshell"):
        self.state_path.write_text(json.dumps(self.state))
        directory = STOCK_BIN if USE_STOCK else ROOT / "bin"
        result = subprocess.run(
            ["/bin/bash", str(directory / f"omarchy-hyprland-monitor-{name}")],
            env=self.env,
            capture_output=True,
            text=True,
            timeout=10,
        )
        self.assertEqual(result.stderr, "")
        return result.returncode

    def assert_no_reconfiguration(self):
        self.assertTrue(self.flag.exists(), "Recovery removed the clamshell flag")
        self.assertFalse(self.effects.exists(), "Recovery reconfigured/woke displays")

    def test_locked_closed_lid_missing_external_does_not_wake_displays(self):
        self.state["monitors"] = [monitor("eDP-1", disabled=True)]
        self.assertEqual(self.run_recovery(), 0)
        self.assert_no_reconfiguration()

    def test_fallback_is_not_a_real_awake_output(self):
        self.state["monitors"] = [
            monitor("eDP-1", disabled=True),
            monitor("FALLBACK"),
        ]
        self.assertEqual(self.run_recovery(), 0)
        self.assert_no_reconfiguration()

    def test_blanked_modeless_monitor_does_not_trigger_reload(self):
        self.state["monitors"][1] = monitor("HDMI-A-1", dpms=False, width=0, height=0)
        self.assertEqual(self.run_recovery("modeless"), 1)
        self.assert_no_reconfiguration()

    def test_awake_modeless_monitor_can_still_recover(self):
        self.state["monitors"][1] = monitor("HDMI-A-1", width=0, height=0)
        self.assertEqual(self.run_recovery("modeless"), 0)

    def test_healthy_awake_monitor_needs_no_modeless_recovery(self):
        self.assertEqual(self.run_recovery("modeless"), 1)

    def test_lid_open_restores_internal_panel_while_locked(self):
        self.state.update(closed=False, connected=False)
        self.state["monitors"] = [monitor("eDP-1", disabled=True)]
        self.assertEqual(self.run_recovery(), 0)
        self.assertFalse(self.flag.exists())
        self.assertIn("omarchy-restart-hyprctl", self.effects.read_text())

    def test_unlocked_session_can_recover_missing_output(self):
        self.state.update(locked=False, connected=False)
        self.state["monitors"] = [monitor("eDP-1", disabled=True)]
        self.assertEqual(self.run_recovery(), 0)
        self.assertFalse(self.flag.exists())
        self.assertIn("omarchy-restart-hyprctl", self.effects.read_text())

    def test_dpms_off_remains_off_even_when_unlocked(self):
        self.state["locked"] = False
        self.state["monitors"][1] = monitor("HDMI-A-1", dpms=False, width=0, height=0)
        self.assertEqual(self.run_recovery("modeless"), 1)

    def test_malformed_monitor_reply_defers_recovery(self):
        self.state["raw_monitors"] = "not-json"
        self.assertEqual(self.run_recovery(), 0)
        self.assert_no_reconfiguration()
        self.assertEqual(self.run_recovery("modeless"), 2)

    def test_unavailable_compositor_defers_recovery(self):
        self.state["query_exit"] = 1
        self.assertEqual(self.run_recovery(), 0)
        self.assert_no_reconfiguration()
        self.assertEqual(self.run_recovery("modeless"), 2)

    def test_unknown_lock_state_without_outputs_defers_recovery(self):
        self.state["monitors"] = [monitor("eDP-1", disabled=True)]
        self.state["raw_lock"] = "not-json"
        self.assertEqual(self.run_recovery(), 0)
        self.assert_no_reconfiguration()
        self.assertEqual(self.run_recovery("modeless"), 2)

    def test_healthy_awake_clamshell_keeps_existing_layout(self):
        self.assertEqual(self.run_recovery(), 0)
        self.assert_no_reconfiguration()


if __name__ == "__main__":
    unittest.main()
