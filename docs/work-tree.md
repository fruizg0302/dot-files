# Work directory layout

First-level directories under `~/Work`, recorded on September 22, 2026:

```text
~/Work/
├── Archive/
├── Configs/
├── Diagnostics/
├── Notes/
├── Omarchy/
├── Scripts/
├── Tlalpan/
└── tries/
```

| Directory | Purpose |
| --- | --- |
| `Archive/` | Historical backups and cleanup records |
| `Configs/` | Reusable configuration copies and installation references |
| `Diagnostics/` | Hardware investigations, tests, benchmarks, and logs |
| `Notes/` | Reports, setup notes, and decisions |
| `Omarchy/` | Desktop incidents, plugin audits, and repair patches |
| `Scripts/` | Standalone utilities grouped by purpose |
| `Tlalpan/` | Tlalpan project work |
| `tries/` | Scratch workspace |

The local `~/Work/README.md` is the detailed index. This document records only
the first-level folder structure; files and subdirectories are not uploaded.
Live settings remain under `~/.config/` and `~/.local/`, while `~/dot-files`
stays at its existing path because active configuration links into it.

The desktop snapshot repository lives at `~/Work/Configs/omarchy-personalization`
and is published at
[fruizg0302/omarchy-personalization](https://github.com/fruizg0302/omarchy-personalization).

To create the same top-level layout on another machine:

```bash
mkdir -p "$HOME/Work"/{Archive,Configs,Diagnostics,Notes,Omarchy,Scripts,Tlalpan,tries}
```
