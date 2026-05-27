---
name: process-job-listings
description: Batch process all job postings in todo/ into inprogress/ with automated application materials, pre-ranking gates, AI writing detection, ranking, council review, and PDF generation.
disable-model-invocation: true
---

# Process Job Listings — Unified Batch Processor

## Source Templates

All generated materials start from these files:
- `full_cv.tex` — comprehensive resume with all experience (used for reference, not directly copied)
- `resume.tex` — canonical resume base
- `cover.tex` — canonical cover letter base
- `.secrets` — contact info (`[EMAIL]`, `[PHONE]`, `[LINKEDIN_URL]`, `[LINKEDIN_USERNAME]`, `[GITHUB_URL]`, `[GITHUB_USERNAME]`, `[WEBSITE_URL]`, `[WEBSITE_NAME]`)

Read full_cv.tex if you need to surface additional experience that closely matches the job posting.

## Hard Constraints

1. Never fabricate jobs, titles, projects, dates, tools, publications, outcomes, or scope. My title in the capsule statement should always be similar to"PhD Physicist" or "Researcher". I should at most have "7+" years of experience. You may need to break that down into 3 years of professional experience at L3 and 4+ years of research experience at SMU. Always preserve the truth of my experience and never add any claims that are not directly supported by the source templates.
2. Keep resume structure and meaning close to `resume.tex`. Add jobs and skills from `full_cv.tex` only if they clearly improve relevance without changing facts.
3. Do not dramatically rewrite section intent. Do NOT modify job, paper, or research titles. Only change the wording of the details points to better surface relevance, never to add new claims or change meaning.
4. Do not use em dashes (— or --).
5. Keep cover letter to one page.
6. Replace placeholders (`[PHONE]`, `[EMAIL]`, `[LINKEDIN_URL]`, `[LINKEDIN_USERNAME]`, `[GITHUB_URL]`, `[GITHUB_USERNAME]`, `[WEBSITE_URL]`, `[WEBSITE_NAME]`) with values from `.secrets`.
7. L3 Technologies employment dates are 1/2017 to 8/2019 (listed in source files as "2017 - 2019"). When referencing this tenure, use "nearly 3 years" of experience — never the full ~3.5 calendar months. In capsule statements and cover letters, frame as "nearly 3 years" or "3 years" of data engineering/production experience at L3.
8. In all generated headers (resume and cover letter), use FontAwesome icons for contact info instead of full URLs. Show only: icon + username/handle with a non-breaking space between them (~). No full links visible to the reader — just the icon and the handle. Examples: `\faLinkedinIn~jbrandons`, `\faGithub~jbrandons`, `\faGlobe~jbrandons.dev`. Use email text (not icon) for the email address.

## Guard Rules — Enforce These at Every Step

### Rule 0: General Rules and Non-Experience Topics
- Review the `NON_EXPERIENCE_TOPICS.md` file for a full list of Non-Experience Topics.
- The candidate does NOT have professional or hands-on experience in the listed areas in `NON_EXPERIENCE_TOPICS.md`. Never add these to resumes, cover letters, or any application materials.
- Read full_cv.tex if you need to surface additional experience that closely matches the job posting.

### Rule 1: Region Guard — Do Not Move Items Between Sections
- Research experience MUST stay under "Selected Research Experience" (SMU, Prof. Meyers, Prof. Olness)
- Professional experience MUST stay under "Professional Experience" (L3 Technologies)
- Never move research bullets into the professional section or vice versa
- Papers must stay under "Selected Papers"
- Awards must stay under "Selected Awards"
- Education must stay under "Education"

### Rule 2: Base Resume.tex Wording Preservation
After tailoring, compare each bullet against the original resume.tex:
- Only make small, truthful tweaks that PRESERVE the original factual claims and structure
- Never change job titles, project names, research paper titles, or company names
- The generated resume must remain structurally close to base resume.tex

## Directory Structure

```
CV/
  todo/              # Job postings (zero-padded by ID: 01, 02, ... N), these are files and not directories
  inprogress/        # In-progress runs COMPANY_NAME/*.tex, *.pdf, job_listing.md, match_report.md
  todo/done_status.json   # Tracking: scores, status per job
```

### Company Name Slug Generation

1. Read the job posting and extract employer name if present.
2. If employer not in first line, look for "Company Description" or "About Us" section.
3. Convert to safe lowercase slug: lowercase, spaces → underscores, remove special characters.
4. Handle duplicates: Ask the user to confirm if the slug is correct or provide a custom slug if multiple similar company names exist, or if one should be skipped.

### Status States

- `pending` — Not yet processed
- `processing` — Currently being worked on
- `complete` — Done with score ≥ 70
- `needs_retry` — Score below target, needs re-processing
- `needs_user_input` — Missing or conflicting criteria (e.g., location, salary) or user confirmation required. Store the job and required question for later, process other jobs first.
- `failed` — Max retries exhausted
- `skip` — Valid materials generated but job marked for skip (low relevance)
- `do_not_pursue` — Score < 40; no materials generated until user confirms

## Batch Execution Model

**CRITICAL RULE:** Do NOT read in all jobs in `todo/*` at once. 
You must read and process **one job at a time, individually** using a dedicated subagent. Do not move on to the next job in `todo/` until the current job's subagent has fully completed its lifecycle and returned its report. 

Each subagent handles its full lifecycle for one single job: pre-rank, generate, rank, loop, build PDFs, update status. The orchestrator collects results sequentially and runs the council review at the end. Context should be limited to the current job's content and generated materials to avoid context window issues, compact or trim as needed and after each lifecycle.
If a job is flagged as `needs_user_input`, put it on hold. Store the question for later, and continue the process with the next job. This ensures all completable tasks are finished and all questions are gathered before asking the user.

## Pre-Ranking Gate

Before scoring, check for these **Hard Criteria**:
1. **Location:** The role must explicitly state it is "Remote" or located in one of the acceptable cities within a 50-mile radius of Dallas, TX, as listed in the `acceptable_locations.md` file.
2. **Salary:** If a salary is provided in the description, it must be above $100k/year.
If these criteria are not met or are unclear, **do not reject**. Flag the job as `needs_user_input`, record the specific question for the user, and move on to the next job.

After passing the hard criteria check, score the base `resume.tex` against the job requirements using the 100-point rubric below.

**Thresholds:**
- **Score ≥ 70** → Proceed directly to application generation.
- **Score 40–69** → Look at modifying verbiage and emphasis in the base resume to improve fit.
- **Score < 40** → Flag as `do_not_pursue`. Still create a folder with job listing and match report (no application materials). Do NOT proceed until user explicitly confirms override.

## Per-Job Workflow
Do not worry about the time or steps this process takes. It is known to be a long running job.
Each subagent executes this sequence for its assigned job. you must complete all steps for the current job before moving on to the next one in `todo/`:

### Step 0 — Always Create Folder (All Jobs)
**Regardless of match score, every job MUST get a folder in `inprogress/COMPANY_NAME/`.** This ensures the batch output is complete and auditable.

1. Create `inprogress/COMPANY_NAME/` directory (if not already created by company slug generation).
2. Save full posting text to `inprogress/COMPANY_NAME/job_listing.md`.
3. Write a `match_report.md` scoring report (see Minimum Output for All Jobs below).
4. Compact the context by removing any existing references to previous job postings or companies to avoid confusion in later steps. If using subagents all sub agents must only have access to the current job's context and files in `inprogress/COMPANY_NAME/` to ensure focus and avoid context limits.

This step runs for every job, including those flagged as `do_not_pursue` or skipped after pre-ranking.

### Step 1 — Extract Requirements
Parse the todo/N content to extract:
- Company name and slug
- Role title
- Must-have requirements
- Nice-to-have requirements
- Top keywords

Save full posting text to `inprogress/COMPANY_NAME/job_listing.md` (overwrite from Step 0 if needed).

### Step 2 — Generate Application Materials (Score ≥ 70 Only)
1. Copy `resume.tex` → `inprogress/COMPANY_NAME/COMPANY_NAME_resume.tex`.
2. Copy `cover.tex` → `inprogress/COMPANY_NAME/COMPANY_NAME_cover.tex`.
3. Rewrite the capsule statement (the professional summary at the beginning of the resume) for the role using only true claims.
4. Reorder skills to mirror posting priorities.
5. Lightly adjust bullet emphasis without changing factual meaning.
6. Replace contact info placeholders ([PHONE], [EMAIL], [LINKEDIN_URL], etc) with values from `.secrets`.

### Step 3 — AI Writing Detection (Inline)

After drafting the resume and cover letter, run the ai-writing-detector skill and then scan both files for these 6 tell categories:

1. **AI vocabulary density** — words like "delve", "tapestry", "pivotal", "underscore", "fostering"
2. **Copulative avoidance** — "serves as" / "boasts" instead of natural "is" / "has"
3. **Promotional tone** — travel-guide or press-release language inappropriately applied
4. **Superficial analysis** — "-ing" significance claims after every fact statement
5. **Negative parallelism** — "Not just X, but also Y" without real misconceptions to correct
6. **Check dangling placeholders** - Ensure placeholders like `[COMPANY_NAME]`, `[Position Title]`, `[location]`. are fully replaced and not left dangling in the text. If the information is missing, remove the placeholder and rephrase the sentence to avoid leaving it incomplete.

**Rule:** If 2+ tells are flagged, rewrite the flagged sections using plain language before proceeding to PDF build. Do not add content that would require em dashes.

### Step 4 — Ranking (Rubric)

Launch an independent subagent to act as a Technical Hiring Manager to review and score the drafted resume and cover letter against the provided job description. Explicitly tell the subagent to use the `technical-hiring-manager-review` skill. This skill contains the persona, methodology, evaluation rubric (100 points), ranking bands, and required output format.

#### Ranking Workflow
1. Score base `resume.tex` → PRE_REVISION only (this occurs before starting generation).
2. If < 70, apply pre-ranking gate rules (revise, pause or skip).
3. If ≥ 70, generate tailored materials (Steps 1–3 above).
4. Score drafted materials → POST_REVISION using the `technical-hiring-manager-review` skill.
5. Apply truth-preserving reflection improvements if not yet done during generation.
6. Re-score once and report delta.

### Step 5 — Loop and Retry

If the final score is below 70, enter a loop of reflection and revision:
1. Analyze the gaps and identify which are fixable through tailoring.
2. Make specific, actionable revisions to the resume and cover letter based on the identified gaps.
3. Re-run the ranking rubric after each revision.
4. If after 2 rounds of revision the score is still below 70, mark as `needs_retry` for later review.

### Step 6 — Validate Placeholders (Before PDF Build)

After all revisions are complete and before running LaTeX builds, scan every `.tex` file for leftover placeholders that indicate incomplete filling. Reject any build where these remain:

**Must be replaced (from `.secrets`):**
- `[EMAIL]`, `[PHONE]`, `[LINKEDIN_URL]`, `[LINKEDIN_USERNAME]`
- `[GITHUB_URL]`, `[GITHUB_USERNAME]`, `[WEBSITE_URL]`, `[WEBSITE_NAME]`

**Must be replaced (job-specific, filled during generation):**
- `[COMPANY_NAME]`, `[LOCATION]`, `[Position Title]`

**Rule:** If any of these placeholders remain in the final `.tex` files, do NOT proceed to PDF build. Replace them with the correct values from `.secrets` and job context before continuing.

### Step 7 — PDF Build

Execute inside `inprogress/COMPANY_NAME/`:

```bash
latexmk -pdf COMPANY_NAME_resume.tex
latexmk -pdf COMPANY_NAME_cover.tex
```

Cleanup LaTeX build artifacts: remove all `.aux`, `.log`, `.fls`, `.fdb_latexmk`, `.out`, and `.toc` files. Only keep `.tex`, `.pdf`, and `.md` files.

### Step 8 — Update Status

Write or update `todo/done_status.json` with this schema:

```json
{
  "last_updated": "YYYY-MM-DD",
  "total_jobs_processed": N,
  "jobs": [
    {
      "directory": "company_slug_role",
      "role": "Role Title",
      "company": "Company Name",
      "initial_score": "XX",
      "final_score": "XX",
      "ranking_band": "Band name",
      "status": "complete|skip|do_not_pursue|needs_retry|failed",
      "files": ["job_listing.md", "_resume.tex", "_cover.tex", "_resume.pdf", "_cover.pdf", "match_report.md"]
    }
  ]
}
```

### Minimum Output for All Jobs

Every job processed through this skill MUST produce the following minimum output, even if scored as a weak match or flagged `do_not_pursue`:

```
inprogress/COMPANY_NAME/
  ├── job_listing.md           # Full raw job posting text
  └── match_report.md          # Scoring report with pre-ranking scores and gap analysis
```

The `match_report.md` for low-scoring jobs (`do_not_pursue` or `skip`) should contain:
- Pre-rank score and band (from the 100-point rubric)
- Top gaps blocking a higher score
- Summary of why the role is a poor fit
- Timestamp and job reference info

**No application materials** (resume, cover letter, PDFs) are generated for `do_not_pursue` jobs unless the user explicitly overrides.

## Retry Strategy

| Failure Type | Action | Max Retries |
|---|---|---|
| Tool call error / timeout | Restart step, preserve state | 3 |
| LaTeX compilation failure | Read `.log`, fix syntax, rebuild | 3 |
| Match score < 70 (Borderline) | Second reflection pass with deeper truthful reframing | 2 |
| PDF generation missing | Re-run latexmk after tex fix | 3 |

On retry, overwrite the previous attempt's output in `inprogress/COMPANY_NAME/`. Save intermediate state to `todo/done_status.json` after each step so progress is not lost on interruption.

## Council Agent Final Ranking

After all subagents complete their jobs:

1. Launch a `councillor` subagent (the built-in read-only council advisor).
2. Provide the councillor with:
   - Full `done_status.json`
   - All `match_report.md` files from `inprogress/*/`
   - Any `do_not_pursue` or `skip` entries with reasons
3. Ask the councillor to independently review:
   - Accuracy of match scores and bands
   - Validity of skip/apply decisions
   - Consistency of scoring across jobs
   - Whether any Borderline jobs should be upgraded/downgraded
4. Incorporate councillor findings into a final authoritative summary.

## Output Contract

### Per-Job Report

After each job completes, report:
1. Files created or updated.
2. Key tailoring decisions made.
3. Confirmation that facts were preserved.
4. Initial and final match score plus ranking band.
5. Build status for both PDFs.

### Batch Summary (Final)

After all jobs complete and council review finishes:
1. Total processed, succeeded, failed, skipped.
2. Apply-first list (sorted by final score, top-down).
3. Jobs to skip (`do_not_pursue` / `skip`) with reasons.
4. Borderline jobs needing caution.
5. All accumulated questions for jobs marked `needs_user_input` gathered into one prompt for the user.

## Execution Notes

- **CRITICAL:** Do NOT attempt to read all files in `todo/` upfront. 
- Process exactly one job at a time per subagent to avoid context limits.
- After each job, save progress and intermediate state to `done_status.json` to ensure no loss on interruption, then compact / trim context.
- This is a long-running batch process (~N jobs × ~2–3 minutes each).
- Expect tool call errors; be resilient and retry per the retry table.
- Use `auto_continue` to keep working through incomplete batches sequentially.
- Save intermediate state after each job so progress is not lost on interruption.
