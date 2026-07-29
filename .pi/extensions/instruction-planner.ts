/**
 * Instruction Planner Extension
 *
 * Detects important user instructions and delegates them to a planning subagent.
 * The resulting structured plan is injected into LLM context so the main agent
 * has organized, actionable guidance — not just raw user text.
 *
 * Detection heuristics (any match triggers planning):
 *   - Explicit planning markers: "Plan:", numbered steps, phases/milestones
 *   - Architectural language: "architect", "design system", "build from scratch"
 *   - Scope-changing verbs: "refactor", "migrate", "rewrite", "redesign"
 *   - Feature/impl requests with structural detail
 *   - Multi-step complexity indicators (step1, phase2, then/before/after chains)
 *   - Explicit keywords: "important", "critical", "priority", "must-have"
 *
 * Flow:
 *   1. input event → detect importance → queue planning subagent (async, non-blocking)
 *   2. Turn 1 processes normally with original user text
 *   3. Before turn 2+, before_agent_start injects structured plan if available
 *
 * Usage: works silently — no toggle or flag needed.
 */

import { spawn } from "node:child_process";
import * as fs from "node:fs/promises";
import * as os from "node:os";
import * as path from "node:path";
import type { ExtensionAPI, ExtensionContext, BeforeAgentStartEvent, InputEvent } from "@earendil-works/pi-coding-agent";

// ── State ──────────────────────────────────────────────────────────────────────

interface PendingPlan {
	/** The raw user prompt that triggered this */
	prompt: string;
	/** Structured plan text (null while running) */
	planText: string | null;
	/** Planner state */
	status: "idle" | "pending" | "running" | "done" | "error";
}

let pendingPlan: PendingPlan = { prompt: "", planText: null, status: "idle" };

// ── Detection heuristics ───────────────────────────────────────────────────────

const IMPORTANT_PATTERNS = [
	// Explicit planning structure
	/plan[\s]*[:(\n]/i,
	/\b(?:phase|step|milestone)\s*\d+/i,
	/^(?:1\.|2\.|3\.|first|second|third|next|then)/im,

	// Architectural / design language
	/\b(?:architect|design\s+(?:the\s+)?(?:system|architecture|structure|framework))\b/i,
	/\bbuild\s+(?:from\s+(?:scratch|ground)|create)\s+(?:a\s+)?(?:new|complete)?/i,

	// Scope-changing verbs with detail
	/\b(?:refactor|migrate|restructure|redesign|rewrite)\s+(?:the\s+)?(?:system|app|codebase|architecture|service|module)\b/i,

	// Implementation requests with scope markers
	/\bimplement[\s]+(?:a|an|the)[\s]+(?:complete|full|end-to-end|comprehensive)/i,

	// Multi-step complexity chains
	/\b(?:first\s+(?:need|should|must|have)|then\s+(?:we|you|should)|after\s+that|before\s+this)\b/i,

	// Priority / importance markers with scope
	/\b(?:important|critical|priority|must[ -](?:have|do)|key\s+(?:requirement|goal|objective))\b.*\b(?:implement|build|create|design|add|support)\b/i,

	// Multi-part feature requests
	/\b(?:also|and also|in addition|plus|furthermore|another)\s+(?:require|need|want|support|include)\b/i,

	// Explicit delegation patterns
	/\b(set\s+up|create|build)\s+(?:a\s+)?(?:.*\s+\n){2,}/i,
] as const;

function isImportantInstruction(text: string): boolean {
	if (!text || text.length < 15) return false;

	for (const pattern of IMPORTANT_PATTERNS) {
		if (pattern.test(text)) return true;
	}

	return false;
}

// ── Planner subprocess ────────────────────────────────────────────────────────

async function runPlanner(task: string, cwd: string): Promise<string> {
	const tmpDir = await fs.mkdtemp(path.join(os.tmpdir(), "pi-planner-"));
	const systemPromptPath = path.join(tmpDir, "system-prompt.md");

	const systemPrompt = `You are a planning assistant. Break down the user's instructions into a clear, actionable plan.

Output format:
1. Summarize the intent in one sentence.
2. List numbered steps (atomic actions), each with:
   - Brief description
   - Files/components to modify (if known)
3. Note any risks or dependencies.
4. Suggest a good order of execution.

Be concise and actionable. No preamble.`;

	await fs.writeFile(systemPromptPath, systemPrompt);

	return new Promise<string>((resolve, reject) => {
		const piBin = process.argv[0];
		const scriptPath = process.argv[1];
		const isBunVirtual = scriptPath?.startsWith("/$bunfs/root/");

		let cmd: string;
		let args: string[];

		if (isBunVirtual) {
			cmd = "pi";
			args = ["--mode", "json", "-p"];
		} else {
			cmd = process.execPath;
			args = [scriptPath, "--mode", "json", "-p"];
		}

		args.push("--append-system-prompt", systemPromptPath);
		args.push(task);

		const proc = spawn(cmd, args, {
			cwd,
			stdio: ["ignore", "pipe", "pipe"],
			timeout: 30_000, // 30s safety net
		});

		let buffer = "";
		let finalOutput = "";

		const onData = (data: Buffer) => {
			buffer += data.toString();
			const lines = buffer.split("\n");
			buffer = lines.pop() || "";
			for (const line of lines) {
				if (!line.trim()) continue;
				try {
					const event = JSON.parse(line);
					if (event.type === "message_end" && event.message?.role === "assistant") {
						for (const part of event.message.content) {
							if (part.type === "text") {
								finalOutput += part.text;
							}
						}
					}
				} catch {
					// ignore parse errors on partial lines
				}
			}
		};

		proc.stdout.on("data", onData);
		proc.stderr.on("data", () => { /* suppress noise */ });

		proc.on("close", (code) => {
			if (buffer.trim()) onData(Buffer.from(buffer));
			if (code !== 0 && !finalOutput) {
				reject(new Error(`Planner exited ${code}`));
			} else {
				resolve(finalOutput || "(planning failed — see stderr for details)");
			}
		});

		proc.on("error", () => reject(new Error("Failed to spawn planner")));

		setTimeout(() => {
			if (!proc.killed) proc.kill("SIGTERM");
		}, 30_000);
	});
}

// ── Injection helper ──────────────────────────────────────────────────────────

function injectPlanPrompt(messages: import("@earendil-works/pi-agent-core").AgentMessage[], planText: string): import("@earendil-works/pi-agent-core").AgentMessage[] {
	const planBlock: import("@earendil-works/pi-agent-core").AgentMessage = {
		role: "user" as const,
		content: [
			{
				type: "text",
				text: `[PLANNED INSTRUCTIONS — structured from your original request]

${planText}

Use this plan as your guide. Execute each step in order and report progress.`,
			},
		],
		customType: "planned-instructions",
	};
	return [planBlock, ...messages];
}

// ── Extension entry ───────────────────────────────────────────────────────────

export default function instructionPlanner(pi: ExtensionAPI): void {
	let isPlanning = false;

	// ── 1. Detect important instructions on user input ────────────────────────
	pi.on("input", async (event: InputEvent, ctx: ExtensionContext) => {
		if (isPlanning || pendingPlan.status !== "idle") return { action: "continue" };

		const text = event.text?.trim();
		if (!text || !isImportantInstruction(text)) return { action: "continue" };

		// Detect important → queue planning
		isPlanning = true;
		pendingPlan = { prompt: text, planText: null, status: "running" };

		// Notify user via status bar
		ctx.ui.setStatus("planner", ctx.ui.theme.fg("warning", "🧠 planning..."));

		// Run planner asynchronously (non-blocking)
		runPlanner(text, ctx.cwd)
			.then((planText) => {
				pendingPlan.planText = planText;
				pendingPlan.status = "done";
				ctx.ui.setStatus("planner", ctx.ui.theme.fg("success", "✓ planned"));
				setTimeout(() => {
					if (pendingPlan.status === "done") {
						ctx.ui.setStatus("planner", undefined);
					}
				}, 5000); // auto-clear after 5s if still idle
			})
			.catch((err) => {
				pendingPlan.planText = null;
				pendingPlan.status = "error";
				ctx.ui.setStatus("planner", ctx.ui.theme.fg("error", `plan err`));
				setTimeout(() => {
					if (pendingPlan.status === "error") {
						ctx.ui.setStatus("planner", undefined);
						pendingPlan.status = "idle";
					}
				}, 10000);
			})
			.finally(() => {
				isPlanning = false;
			});

		return { action: "continue" }; // let turn run normally
	});

	// ── 2. Inject structured plan before agent starts (after first turn) ─────
	pi.on("before_agent_start", async (event, ctx) => {
		if (pendingPlan.status === "idle") return;
		if (pendingPlan.status === "running") {
			// Plan still running — inject a placeholder so agent knows to proceed now
			return {
				message: {
					customType: "planning-pending",
					content: `[⏳ Planning in progress — proceeding with your original request]`,
					display: false,
				},
			};
		}

		if (pendingPlan.status === "done" && pendingPlan.planText) {
			return {
				message: {
					customType: "planned-instructions",
					content: `[PLANNED INSTRUCTIONS — structured from your original request]

${pendingPlan.planText}

Use this plan as your guide. Execute each step in order and report progress.`,
					display: false,
				},
			};
		}

		if (pendingPlan.status === "error") {
			// Reset state — user can try again
			pendingPlan = { prompt: "", planText: null, status: "idle" };
		}
	});
}
