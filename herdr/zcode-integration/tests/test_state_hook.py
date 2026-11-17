import json
import os
from pathlib import Path
import pty
import select
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
HOOK = ROOT / "scripts" / "zcode-state-hook.sh"
DETACHED_HOOK = """
import subprocess, sys
result = subprocess.run(
    ["sh", sys.argv[1]],
    input=sys.stdin.buffer.read(),
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
    start_new_session=True,
    timeout=5,
)
sys.exit(result.returncode)
"""


class StateHookTest(unittest.TestCase):
    def environment(self):
        return {
            key: value
            for key, value in os.environ.items()
            if not key.startswith(("HC_", "HERDR_"))
        }

    def desktop_report(self, payload, enabled=True):
        master, slave = pty.openpty()
        env = self.environment()
        if enabled:
            env["HC_TERMINAL_ID"] = "test-terminal"
        try:
            result = subprocess.run(
                [sys.executable, "-c", DETACHED_HOOK, str(HOOK)],
                input=payload,
                stdout=slave,
                stderr=subprocess.PIPE,
                env=env,
                timeout=8,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            output = b""
            while select.select([master], [], [], 0)[0]:
                output += os.read(master, 4096)
            return output
        finally:
            os.close(master)
            os.close(slave)

    def test_detached_hook_reports_lifecycle_to_agent_terminal(self):
        cases = [
            ("SessionStart", b"\x1b]7501;state=idle:app=zcode\x1b\\"),
            ("UserPromptSubmit", b"\x1b]7501;state=working:app=zcode\x1b\\"),
            ("PreToolUse", b"\x1b]7501;state=working:app=zcode\x1b\\"),
            (
                "PermissionRequest",
                b"\x1b]7501;state=blocked:app=zcode:kind=permission\x1b\\",
            ),
            ("PostToolUse", b"\x1b]7501;state=working:app=zcode\x1b\\"),
            ("PostToolUseFailure", b"\x1b]7501;state=working:app=zcode\x1b\\"),
            ("Stop", b"\x1b]7501;state=done:app=zcode\x1b\\"),
        ]
        for field in ["hook_event_name", "hookEventName"]:
            for event, expected in cases:
                with self.subTest(field=field, event=event):
                    payload = json.dumps({field: event}).encode()
                    self.assertEqual(self.desktop_report(payload), expected)

    def test_unrecognized_or_malformed_input_does_not_report(self):
        for payload in [b"", b"not-json", b"[]", b'{"hook_event_name":"Unknown"}']:
            with self.subTest(payload=payload):
                self.assertEqual(self.desktop_report(payload), b"")

    def test_outside_herdr_does_not_write_to_terminal(self):
        self.assertEqual(
            self.desktop_report(b'{"hook_event_name":"UserPromptSubmit"}', enabled=False),
            b"",
        )

    def test_desktop_without_a_terminal_does_not_pollute_hook_output(self):
        env = self.environment()
        env["HC_TERMINAL_ID"] = "test-terminal"
        result = subprocess.run(
            ["sh", str(HOOK)],
            input=b'{"hook_event_name":"UserPromptSubmit"}',
            capture_output=True,
            start_new_session=True,
            env=env,
            timeout=5,
        )
        self.assertEqual((result.returncode, result.stdout, result.stderr), (0, b"", b""))

    def test_legacy_reports_keep_agent_identity_state_and_session(self):
        cases = [
            ({"hook_event_name": "UserPromptSubmit"}, "working", []),
            (
                {"hook_event_name": "PermissionRequest", "reason": "Needs approval"},
                "blocked",
                ["--message", "Needs approval"],
            ),
            (
                {"hook_event_name": "SessionStart", "session_id": "example-session"},
                "idle",
                ["--agent-session-id", "example-session"],
            ),
            ({"hook_event_name": "Stop"}, "idle", []),
        ]
        with tempfile.TemporaryDirectory() as directory:
            capture = Path(directory) / "report.json"
            reporter = Path(directory) / "herdr"
            reporter.write_text(
                f"#!{sys.executable}\n"
                "import json, os, sys\n"
                "from pathlib import Path\n"
                "Path(os.environ['TEST_REPORT']).write_text(json.dumps(sys.argv[1:]))\n"
            )
            reporter.chmod(0o700)
            env = self.environment()
            env.update(
                HERDR_ENV="1",
                HERDR_PANE_ID="test-pane",
                HERDR_BIN_PATH=str(reporter),
                TEST_REPORT=str(capture),
            )
            for payload, state, extra in cases:
                with self.subTest(payload=payload):
                    result = subprocess.run(
                        ["sh", str(HOOK)],
                        input=json.dumps(payload).encode(),
                        capture_output=True,
                        env=env,
                        timeout=5,
                    )
                    self.assertEqual(result.returncode, 0, result.stderr)
                    args = json.loads(capture.read_text())
                    self.assertEqual(
                        args[:8],
                        [
                            "pane", "report-agent", "test-pane", "--source",
                            "zcode-hooks", "--agent", "zcode", "--seq",
                        ],
                    )
                    self.assertGreater(int(args[8]), 0)
                    self.assertEqual(args[9:], ["--state", state, *extra])


if __name__ == "__main__":
    unittest.main()
