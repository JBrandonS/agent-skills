---
name: hermes-integration
description: "Teaches OpenCode how to use Hermes Agent for Discord messaging and progress updates. Use when starting large/complex tasks that may benefit from asynchronous progress reporting via Discord."
version: 2.0.0
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

Hermes Agent is an autonomous AI agent framework that runs on the same machine as OpenCode. It connects to messaging platforms (Discord, Telegram, Slack, etc.) via a **gateway** service. When OpenCode needs to send a message to you asynchronously, it uses Discord API or `hermes chat` to route through this gateway.

## Core Principle: Ask Before Sending Long Jobs to Discord

**When starting any large, complex, or potentially long-running task (estimated >5 minutes of work), you MUST ask the user first:**

> "This looks like it'll take a while — would you like progress updates via my Discord bot, or should I just report back here in OpenCode?"

This respects user preferences. Some users prefer:
- **Discord updates** — get notified on their phone/desktop without switching terminals
- **OpenCode-only** — stay in the terminal and see everything in real-time
- **No updates at all** — just run it quietly

## Sending Messages to Discord (Primary Method)

The most reliable way for OpenCode to send messages to your Discord is via the Discord API using the `DISCORD_BOT_TOKEN` environment variable. This method bypasses Hermes CLI and delivers directly to Discord.

### Method 1: Direct Discord API (Recommended)

```bash
# Send a message to your Discord DM/channel
curl -s \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  https://discord.com/api/v10/channels/1500253700265087076/messages \
  -H "Content-Type: application/json" \
  -d '{"content": "Your message here"}'
```

**Parameters:**
- `$DISCORD_BOT_TOKEN` — Environment variable containing the bot token (already set on this machine)
- `1500253700265087076` — Your Discord DM channel ID with the Hermes bot

**Example progress updates:**
```bash
# Status update during a long task
curl -s \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  https://discord.com/api/v10/channels/1500253700265087076/messages \
  -H "Content-Type: application/json" \
  -d '{"content": "[PROGRESS] Building project... 50% complete"}'

# Error notification
curl -s \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  https://discord.com/api/v10/channels/1500253700265087076/messages \
  -H "Content-Type: application/json" \
  -d '{"content": "[ERROR] Build failed at step 3. Check ~/logs/build.log"}'

# Completion notification
curl -s \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  https://discord.com/api/v10/channels/1500253700265087076/messages \
  -H "Content-Type: application/json" \
  -d '{"content": "[COMPLETE] All done! Results are in ~/results/"}'
```

### Method 2: Via Hermes CLI (Terminal delivery)

For quick queries that don't need Discord delivery:

```bash
hermes chat -q "Research GRPO papers and write summary to ~/research/grpo.md"
```

This runs through Hermes' full agent loop and delivers results via CLI.

### Method 3: Cron with Discord delivery (scheduled)

For tasks that should deliver results back to Discord automatically, set up a cron job:

```yaml
# In ~/.hermes/config.yaml
cron_delivery: "discord"
```

Or create via command:
```bash
hermes cron create "backup ~/data to s3://bucket/" --deliver discord --schedule "0 6 * * *"
```

## How Messages Flow

```
OpenCode → curl Discord API (DISCORD_BOT_TOKEN) → Direct message in your DM ✓
OpenCode → hermes chat -q → Agent processes → Delivers via CLI
Cron job → Agent processes → Delivers via cron_delivery target
Discord user types → Gateway routes to agent → Responds on Discord ✓
```

**Key insight**: The Discord API method (`curl` with `$DISCORD_BOT_TOKEN`) is the most reliable for OpenCode to send messages. It bypasses Hermes CLI and delivers directly to your DM.

## When to Use Each Method

| Scenario | Approach |
|----------|----------|
| Progress updates during long tasks | `curl` Discord API with `[PROGRESS]` prefix |
| Error notifications | `curl` Discord API with `[ERROR]` prefix |
| Completion notifications | `curl` Discord API with `[COMPLETE]` prefix |
| Delegation of complex work | `hermes chat "full query"` — let Hermes handle it |
| Scheduled/cron tasks | Configure `cron_delivery: "discord"` in config.yaml |
| Quick questions on the go | Message Hermes directly on Discord (bidirectional) |

## Testing the Integration

To verify Discord messaging works, run this test from OpenCode:

```bash
curl -s \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  https://discord.com/api/v10/channels/1500253700265087076/messages \
  -H "Content-Type: application/json" \
  -d '{"content": "Test from OpenCode — Hermes integration working"}'
```

You should receive a message in your Discord DM shortly after. Check the response for HTTP 200 to confirm success.

## Configuration Reference

### Environment Variables (already set)
- `DISCORD_BOT_TOKEN` — Bot authentication token for Discord API access

### Discord Channel ID
- Your DM with Hermes bot: `1500253700265087076`

### Hermes Configuration

Hermes configuration lives at `~/.hermes/config.yaml`. Key sections:

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

## Troubleshooting

- **"`DISCORD_BOT_TOKEN` not set"** — This should be pre-configured. Check with `echo $DISCORD_BOT_TOKEN`.
- **"401 Unauthorized"** — Token may be invalid or expired. Regenerate from Discord Developer Portal.
- **"404 Not Found"** — Channel ID may be wrong. Verify with Discord dev tools or gateway logs.
- **"`hermes: command not found`"** — Ensure Hermes Agent is installed. Check `which hermes` and verify it's on PATH.
- **Gateway service not running** — `systemctl --user status hermes-gateway` then `systemctl --user start hermes-gateway`

## Best Practices

1. **Be concise in Discord messages** — Discord has character limits and mobile users prefer short updates
2. **Use status indicators** — prefix messages with `[PROGRESS]`, `[ERROR]`, `[COMPLETE]` for easy scanning
3. **Don't spam** — batch multiple small updates into periodic check-ins rather than per-step notifications
4. **Respect user choice** — if they say "no Discord," don't send unsolicited messages
5. **Test first** — before a major long-running job, send a quick test message to confirm the pipeline works
6. **Prefer direct Discord API for OpenCode** — it's more reliable than routing through Hermes CLI
7. **CLI-first for OpenCode terminal context** — use `hermes chat -q` for quick queries and expect results in the terminal
