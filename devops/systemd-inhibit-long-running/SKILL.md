---
name: systemd-inhibit-long-running
description: "Use systemd-inhibit to prevent system sleep during long-running or complex commands, with automatic cleanup when done."
version: 1.0.0
author: Hermes Agent + User
license: MIT
---

# systemd-inhibit for Long-Running Commands

Prevent the system from sleeping/idling while running complex or long-running tasks via `systemd-inhibit`.

## Why

Desktop environments (GNOME, KDE, etc.) will suspend or hibernate when idle. A long-running Hermes task, build, test suite, or data pipeline can get killed mid-flight. `systemd-inhibit` tells the session manager to hold off on sleep while a process is running.

## Prerequisites

- Linux with systemd (almost all modern distros)
- Normal user accounts can inhibit `sleep` and `idle` actions. Only root can inhibit `shutdown` or `reboot`.

## When to Use

Use this for any command expected to run **more than ~2 minutes** or that would be catastrophic to interrupt:

- `make`, `cargo build`, long compilations
- Test suites (`pytest`, `jest --ci`, etc.)
- Data pipelines, ETL jobs, large downloads
- Model training/fine-tuning runs
- Any Hermes task that delegates heavy work

Do NOT use for quick one-liners (under 2 minutes) — the overhead isn't worth it.

## How to Use

### Pattern: Background Inhibition Wrapper

Run a command inside an inhibition block. The inhibit is released when the command exits (success or failure):

```bash
systemd-inhibit --what=sleep --why="Running long task: <description>" bash -c '<command> && echo DONE || echo FAILED'
```

### Pattern: Foreground with Timeout

If you want to run it as a background process and monitor it:

```bash
# Start inhibition + command in background
systemd-inhibit --what=sleep --idle=block \
  --why="Long-running task" \
  bash -c '<command> 2>&1 | tee /tmp/hermes-task-<id>.log' &
TASK_PID=$!

# Wait for completion (non-blocking)
wait $TASK_PID
```

### Pattern: With Hermes Terminal Tool

When using the `terminal()` tool for long-running tasks, wrap the command:

```python
from hermes_tools import terminal

# For a build that takes > 2 minutes
result = terminal(
    command='systemd-inhibit --what=sleep --why="Building project" bash -c "cd /path/to/project && make -j$(nproc) 2>&1 | tee build.log"',
    background=True,
    timeout=600
)
```

### Pattern: Multiple Actions

Inhibit both sleep and idle (idle = prevents screensaver from triggering suspend):

```bash
systemd-inhibit \
  --what=sleep:idle \
  --mode=block \
  --why="Running data pipeline" \
  python3 pipeline.py
```

Available `--what` actions:
- `sleep` — prevent sleep/suspend (most useful)
- `idle` — prevent idle shutdown (screensaver-related)
- `shutdown` — prevent shutdown (requires root)
- `reboot` — prevent reboot (requires root)

### Pattern: Check What's Currently Inhibited

```bash
# See all current inhibitors
systemd-inhibit --list

# Output format: WHO UID PID WHAT MODE WHAT REASON
# Example: hermes 1000 4821 sleep block Building project
```

## Cleanup

The inhibit is **automatically released** when the inhibited process exits. No manual cleanup needed for normal usage.

If you need to force-release early:

```bash
# Find the inhibitor PID from `systemd-inhibit --list`
systemd-inhibit --list | grep "your-reason"

# Kill the process — inhibition is released on exit
kill <PID>
```

## Troubleshooting

- **"Not a login session"**: `systemd-inhibit` requires a systemd user session. If you SSH in without logging in, it may not work. Use `loginctl show-session $(loginctl | grep $(whoami) | awk '{print $1}')` to verify.
- **Inhibition not working**: Some desktop environments ignore systemd inhibitors. Check with `systemd-inhibit --list` before and after running.
- **No effect on laptop lid close**: Lid close is handled by a different mechanism (`HandleLidSwitch`). `systemd-inhibit` doesn't block that — you'd need `logind.conf` changes for that.

## Quick Reference

```bash
# One-shot: inhibit while command runs
systemd-inhibit --what=sleep --why="Task name" <command>

# See active inhibitors
systemd-inhibit --list

# Inhibit multiple actions
systemd-inhibit --what=sleep:idle --why="Reason" <command>

# Interactive mode (keeps inhibit alive until you Ctrl+C)
systemd-inhibit --what=sleep --interactive --why="My task"
```

## Creating systemd --user Services

For services that should start on login, use `systemd --user`:

1. Create the service file: `~/.config/systemd/user/<name>.service` (see `templates/user-service.service`)
2. Reload: `systemctl --user daemon-reload`
3. Enable: `systemctl --user enable <name>.service`
4. Start: `systemctl --user start <name>.service`
5. Check status: `systemctl --user status <name>.service`

**Pitfalls:**
- Always verify the binary path and flags with `which <binary>` and `<binary> --help` before creating the service — failures only surface at runtime (exit code 1).
- Use `ExecStart=/absolute/path/to/binary` — relative paths may not resolve correctly.
- `WantedBy=default.target` is the correct target for user services to start on login.

## References

- `templates/user-service.service` — Template for creating systemd --user service files
