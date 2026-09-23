# Codex and Claude Code status lines

Status line settings captured from the active configuration on September 22,
2026. These are small configuration fragments for merging into each app's
existing settings. Back up a settings file as `<file>.bak-YYYY-MM-DD` before
editing it.

## Codex

Merge [codex/statusline.toml](../codex/statusline.toml) into
`~/.codex/config.toml`. If `[tui]` already exists, update its matching keys;
do not add a second `[tui]` table or replace the whole configuration file.

The footer shows, in order:

1. Model and reasoning effort.
2. Context used.
3. Used tokens.
4. Git branch.
5. Current directory.

The fragment also preserves the current `catppuccin-mocha` theme and
`status_line_use_colors = true` setting. It was captured with Codex CLI 0.155.1.
The color flag is present in the local configuration but is not listed in the
current public configuration reference, so support may vary by Codex version.

Restart Codex after merging the settings. See the official
[configuration reference](https://learn.chatgpt.com/docs/config-file/config-reference)
for `tui.status_line` and `tui.theme`.

## Claude Code

Install Oh My Posh and use a Nerd Font in the terminal. Ensure
`~/.config/oh-my-posh/claude-statusline.omp.json` resolves to the tracked
[theme](../oh-my-posh/claude-statusline.omp.json). The repository's installation
instructions link `~/.config/oh-my-posh` to its `oh-my-posh/` directory.

Merge the `statusLine` object from
[claude/statusline.settings.json](../claude/statusline.settings.json) into
`~/.claude/settings.json`, keeping the other settings. Restart Claude Code
afterwards.

The theme displays the model name, a five-cell context gauge, context percentage,
formatted token count, Git branch and changes, and the current directory.
It uses an orange and stone palette, with warning colors above 60% and 80%
context usage. The saved command uses Oh My Posh's dedicated `claude` renderer
and one character of padding. The installed Oh My Posh version at capture was
31.3.0.

See [Claude Code's status line documentation](https://code.claude.com/docs/en/statusline)
and [Oh My Posh's Claude integration](https://ohmyposh.dev/docs/installation/prompt).

## What is tracked

Only the status line fragments and the shared theme are stored here. The full
Codex and Claude settings, authentication, conversations, project trust entries,
and machine-specific permissions remain local. The two settings fragments are
snapshots; they are not automatically synchronized with the live settings.
