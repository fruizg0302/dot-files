# herdr-zcode

Makes [Herdr](https://herdr.dev) recognize [ZCode](https://github.com/zai-org/ZCode)
as a first-class agent: the pane shows up in `herdr agent list` and the sidebar
with live `working` / `blocked` / `idle` state, notifications, and `herdr agent wait`
support — instead of being treated as a plain terminal.

## Herdr Desktop (Linux)

The same registered hooks also support Herdr Desktop and `herdr-core`.
Inside an `HC_TERMINAL_ID` terminal, they emit Program Status Protocol
(OSC 7501) reports through `scripts/desktop-state-hook.py`:

| ZCode hook | Desktop state |
| --- | --- |
| `SessionStart` | `idle` |
| `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `PostToolUseFailure` | `working` |
| `PermissionRequest` | `blocked` (`kind=permission`) |
| `Stop` | `done` (shown as `idle` after viewing) |

ZCode captures hook output and detaches hook subprocesses. The desktop
reporter follows the Linux ancestor process chain to write to the agent's
pseudo-terminal, rather than the hook's captured stdout or missing `/dev/tty`.
Outside Herdr it does nothing. Legacy panes continue to use the socket API.

Add ZCode to the desktop launcher in `~/.config/herdr-app/programs.json`
(merge with any existing `programs` entries):

```json
{
  "programs": {
    "zcode": {
      "name": "ZCode",
      "tile": "#2563eb",
      "color": "#ffffff",
      "match": ["zcode-cli", "zcode.cjs"],
      "run": ["zcode"]
    }
  }
}
```

The launcher configuration hot-reloads. Start `zcode` inside a Herdr Desktop
terminal, or choose ZCode from its new-terminal menu. Check its state with
`hc ls`. Already-registered hooks use the updated reporter on their next event;
new hook registrations require restarting ZCode.

Run the integration tests with `python3 -m unittest discover -s tests -v`.

## How it works

Two pieces, both installed by `setup.sh`:

1. **Agent detection override** (`config/agent-detection/zcode.toml`) — teaches
   Herdr's process detector to match the `zcode-cli` process, so the pane is
   labeled as a `zcode` agent.
2. **ZCode hooks** (`scripts/zcode-state-hook.sh`) — registered in
   `~/.zcode/cli/config.json` for every lifecycle event ZCode fires, reporting
   state to Herdr via the documented `herdr pane report-agent` API:

   | ZCode hook | Herdr state |
   | --- | --- |
   | `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `PostToolUseFailure` | `working` |
   | `PermissionRequest` | `blocked` (message = permission reason) |
   | `Stop`, `SessionStart` | `idle` |

   Reported state is a "lifecycle authority", so Herdr uses it instead of
   screen-reading the pane.

Setup also removes the `claude` integration hook that Herdr auto-installs into
ZCode configs (`~/.claude/hooks/herdr-agent-state.sh`); inside a ZCode pane it
mislabels the agent as `claude` because ZCode never matches Herdr's claude
process detection. A timestamped backup of the config is kept alongside.

## Install

```sh
herdr plugin link /path/to/herdr-zcode
herdr plugin action invoke zcode.integration.setup
```

or run `sh scripts/setup.sh` directly. Then restart any running ZCode session
(hooks are loaded at startup).

Verify:

```sh
herdr agent list
herdr agent explain <pane>   # shows matched rule / manifest source
```

## Uninstall

```sh
herdr plugin action invoke zcode.integration.uninstall
herdr plugin unlink zcode.integration
```

The agent-detection override is left in place (delete
`~/.config/herdr/agent-detection/zcode.toml` to drop it too).

## Caveats

- ZCode has no `SessionEnd` hook, so the pane is not explicitly released on
  exit. Herdr clears the agent itself once the pane is back at a shell prompt.
- Resume-after-restart (`resume_argv`) needs Herdr 0.10+; on older Herdr the
  session id is still reported and shown, but the pane is not auto-resumed.
- Hook config changes only apply to ZCode sessions started afterwards.
