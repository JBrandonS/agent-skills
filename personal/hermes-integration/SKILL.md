---
name: hermes-integration
description: "Teaches OpenCode how to use Hermes Agent for Discord messaging and progress updates. Use when starting large/complex tasks that may benefit from asynchronous progress reporting via Discord."
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [OpenCode, Herms-Agent, Discord, Progress-Updates, Messaging]
    related_skills: [hermes-agent, webhook-subscriptions, oh-my-opencode-slim]
---

# OpenCode → Hermes Agent Integration

This skill teaches OpenCode (Claude Code) how to use **Hermes Agent** — a multi-platform AI agent that can send messages back to you via Discord when running long-running or complex tasks.

## What is Hermes?

Hermes Agent is an autonomous AI agent framework that runs on the same machine as OpenCode. It connects to messaging platforms (Discord, Telegram, Slack, etc.) via a **gateway** service. When OpenCode needs to send a message to you asynchronously, it uses `hermes chat` to route through this gateway.

## Core Principle: Ask Before Sending Long Jobs to Discord

**When starting any large, complex, or potentially long-running task (estimated >5 minutes of work), you MUST ask the user first:**

> "This looks like it'll take a while — would you like progress updates via my Discord bot, or should I just report back here in OpenCode?"

This respects user preferences. Some users prefer:
- **Discord updates** — get notified on their phone/desktop without switching terminals
- **OpenCode-only** — stay in the terminal and see everything in real-time
- **No updates at all** — just run it quietly

## Sending Messages to Discord via Hermes

### Method 1: Fire-and-forget (simple)

```bash
hermes chat -q "Progress update: fetched first 50 repos from GitHub" --platform discord
```

This sends a message directly to your configured Discord channel. The `--platform discord` flag specifies the target.

### Method 2: Full session (interactive)

```bash
hermes chat "Research GRPO papers and write summary to ~/research/grpo.md"
```

This runs the query through Hermes' full agent loop — the LLM processes it, uses tools if needed, and delivers results back via Discord.

### Method 3: Background task with result delivery

```bash
hermes chat -q "Set up CI/CD for ~/myapp" --platform discord --background
```

Starts a background task and delivers results to Discord when complete.

## When to Use Hermes Discord Messaging

| Scenario | Approach |
|----------|----------|
| Simple status update during long task | `hermes chat -q "update"` with `--platform discord` |
| Delegation of complex work | `hermes chat "full query"` — let Hermes handle it |
| Scheduled/cron tasks | Already configured in your `~/.hermes/config.yaml` |
| Quick question while away from terminal | `hermes chat -q "question"` — gets answer via Discord |

## How It Works Under the Hood

```
OpenCode  →  hermes chat command  →  Hermes Gateway  →  Discord Platform  →  Your Phone/PC
   │              (terminal tool)        (localhost:port)     (Discord API)       (you)
```

The Hermes gateway runs as a systemd user service (`hermes-gateway`). It listens on localhost and routes messages to all configured platforms. Discord is one of many possible targets.

## Testing the Integration

To verify Discord messaging works, run this from OpenCode:

```bash
hermes chat -q "Test message from OpenCode — Hermes integration working" --platform discord
```

You should receive a message in your Hermes Discord DM shortly after.

## Configuration Reference

Hermes configuration lives at `~/.hermes/config.yaml`. Key sections relevant to this skill:

```yaml
# Model provider (what LLM powers the agent)
model:
  default: llama
  provider: custom:llama
  base_url: http://127.0.0.1:8080/v1

# Gateway — handles platform routing
gateway:
  timeout: 1800          # per-message timeout (seconds)
  # ... more settings in full config

# Cron delivery — where scheduled results go
cron_delivery: "origin"  # or "discord" for Discord DMs
```

## Troubleshooting

- **"hermes: command not found"** — Ensure Hermes Agent is installed. Check `which hermes` and verify it's on PATH.
- **"Failed to send to Discord"** — Check gateway status: `hermes gateway status`. Restart with `hermes gateway restart`.
- **"No Discord platform configured"** — Run `hermes gateway setup` and enable Discord during the wizard.
- **Message delivered but no content** — The LLM may have had trouble processing your query. Try rephrasing or use a simpler message for testing.
- **Gateway service not running** — `systemctl --user status hermes-gateway` then `systemctl --user start hermes-gateway`

## Best Practices

1. **Be concise in Discord messages** — Discord has character limits and mobile users prefer short updates
2. **Use status indicators** — prefix messages with `[PROGRESS]`, `[ERROR]`, `[COMPLETE]` for easy scanning
3. **Don't spam** — batch multiple small updates into periodic check-ins rather than per-step notifications
4. **Respect user choice** — if they say "no Discord," don't send unsolicited messages
5. **Test first** — before a major long-running job, send a quick test message to confirm the pipeline works
