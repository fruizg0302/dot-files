import json
import os
from pathlib import Path
import re
import sys


STATES = {
    "SessionStart": "idle",
    "UserPromptSubmit": "working",
    "PreToolUse": "working",
    "PermissionRequest": "blocked",
    "PostToolUse": "working",
    "PostToolUseFailure": "working",
    "Stop": "done",
}


def main():
    if not os.environ.get("HC_TERMINAL_ID"):
        return
    try:
        data = json.load(sys.stdin)
    except (ValueError, OSError):
        return
    if not isinstance(data, dict):
        return
    event = data.get("hook_event_name") or data.get("hookEventName")
    if not isinstance(event, str) or event not in STATES:
        return
    payload = f"\x1b]7501;state={STATES[event]}:app=zcode"
    if event == "PermissionRequest":
        payload += ":kind=permission"
    payload = (payload + "\x1b\\").encode()

    # ZCode detaches hook processes and captures their output, so /dev/tty
    # cannot reach the agent. Find its terminal through the ancestor chain.
    pid = os.getppid()
    visited = set()
    while pid > 1 and pid not in visited:
        visited.add(pid)
        try:
            for number in (1, 2):
                target = Path(f"/proc/{pid}/fd/{number}")
                if not re.fullmatch(r"/dev/pts/[0-9]+", os.readlink(target)):
                    continue
                fd = os.open(target, os.O_WRONLY | os.O_NOCTTY | os.O_NONBLOCK)
                try:
                    if os.isatty(fd):
                        os.write(fd, payload)
                        return
                finally:
                    os.close(fd)
            stat = Path(f"/proc/{pid}/stat").read_text()
            pid = int(stat.rsplit(") ", 1)[1].split()[1])
        except (OSError, ValueError, IndexError):
            return


if __name__ == "__main__":
    main()
