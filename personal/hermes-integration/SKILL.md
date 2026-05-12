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
hermes chat -q "Progress update: fetched first 50 repos from GitHub"
```

This sends a message through Hermes. By default it delivers via CLI. The response confirms the query was processed.

### Method 2: Full session (interactive)

```bash
hermes chat "Research GRPO papers and write summary to ~/research/grpo.md"
```

This runs the query through Hermes' full agent loop — the LLM processes it, uses tools if needed, and returns results via CLI.

### Method 3: Cron with Discord delivery (for scheduled/async)

For tasks that should deliver results back to Discord automatically, set up a cron job with Discord delivery in `~/.hermes/config.yaml`:

```yaml
cron_delivery: "discord"
```

Or create via command:
```bash
hermes cron create "backup ~/data to s3://bucket/" --deliver discord --schedule "0 6 * * *"
```

### Method 4: Via Discord itself (bidirectional)

The most natural Discord integration is bidirectional — you type in Discord and Hermes responds on Discord. When you send a message TO Hermes via Discord, the agent responds back on Discord automatically. This requires no special configuration from OpenCode.

## How Messages Flow

```
User types in Discord → Gateway routes to agent → Agent responds on Discord ✓
OpenCode → hermes chat -q → Agent processes → Delivers via CLI (by default)
Cron job → Agent processes → Delivers via cron_delivery target (CLI/Discord/etc)
External webhook → Agent triggers → Delivers via --deliver flag (discord, telegram, etc)
```

**Key insight**: There is no `--platform discord` flag on `hermes chat`. CLI commands deliver to CLI by default. Discord delivery happens when:
1. You message Hermes directly on Discord (natural bidirectional flow)
2. You configure `cron_delivery: "discord"` for scheduled tasks
3. You use webhook subscriptions with `--deliver discord`

## When to Use Hermes Discord Messaging

| Scenario | Approach |
|----------|----------|
| Simple status update from CLI | `hermes chat -q "update"` — delivers via CLI (confirmable) |
| Delegation of complex work | `hermes chat "full query"` — let Hermes handle it |
| Scheduled/cron tasks | Configure `cron_delivery: "discord"` in config.yaml |
| Quick question while away from terminal | Send message directly on Discord |
| Webhook-triggered notifications | Use `hermes webhook subscribe` with `--deliver discord` |

## Testing the Integration

To verify Hermes is working, run this test:

```bash
hermes chat -q "Test from OpenCode — Hermes integration pipeline verified"
```

Expected output shows:
- Query echo
- Agent initialization banner
- Response from the model
- Session ID for resume

**For Discord-specific testing**: Message the Hermes bot directly in your Discord DM or channel. It will respond on Discord, confirming the gateway is connected and operational.

## Gateway Status Verification

Check that Discord is properly connected:

```bash
# Gateway service status
hermes gateway status

# Check Discord connection in logs
grep -i "discord" ~/.hermes/logs/gateway.log | tail -5

# Verify gateway is running (systemd)
systemctl --user status hermes-gateway
```

Look for these log entries confirming successful Discord integration:
- `[Discord] Connected as Hermes#7400`
- `✓ discord connected`
- Inbound message logs showing `platform=discord`

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
cron_delivery: "origin"  # "origin" = back to source, "discord" = Discord DMs
```

## Troubleshooting

- **"hermes: command not found"** — Ensure Hermes Agent is installed. Check `which hermes` and verify it's on PATH.
- **"Failed to send to Discord"** — Check gateway status: `hermes gateway status`. Restart with `hermes gateway restart`.
- **"No Discord platform configured"** — Run `hermes gateway setup` and enable Discord during the wizard.
- **Message delivered but no content** — The LLM may have had trouble processing your query. Try rephrasing or use a simpler message for testing.
- **Gateway service not running** — `systemctl --user status hermes-gateway` then `systemctl --user start hermes-gateway`
- **Discord shows disconnected** — Check the bot token in config.yaml and ensure it's valid: `grep -A2 discord ~/.hermes/config.yaml | head -10`

## Best Practices

1. **Be concise in Discord messages** — Discord has character limits and mobile users prefer short updates
2. **Use status indicators** — prefix messages with `[PROGRESS]`, `[ERROR]`, `[COMPLETE]` for easy scanning
3. **Don't spam** — batch multiple small updates into periodic check-ins rather than per-step notifications
4. **Respect user choice** — if they say "no Discord," don't send unsolicited messages
5. **Test first** — before a major long-running job, send a quick test message to confirm the pipeline works
6. **Prefer bidirectional Discord** — for complex multi-turn tasks on Discord, just type naturally in Discord rather than trying to route CLI output there
7. **CLI-first for OpenCode** — since OpenCode runs in terminal context, use `hermes chat -q` for quick queries and expect results in the terminal
