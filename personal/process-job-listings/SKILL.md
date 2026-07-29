---
name: process-job-listings
description: Use when the user wants job postings turned into tailored application materials — processing a batch of listings, applying to a set of jobs, tailoring a resume and cover letter for specific postings, or working through their job search queue. Triggers on "process my job listings", "apply to these jobs", "tailor my resume for X company", and on being handed a list of job posting files or URLs.
disable-model-invocation: true
---

# Process Job Listings

When invoked, immediately execute **Initialization: Load References** (see below), use delegation to handle each job, one at a time per the workflow below. Collect all `needs_user_input` questions as they arise but don't interrupt the batch — present accumulated questions only after all jobs are processed.


## Skill Information

### Where to find things

- Job postings: `${CV_ROOT}/todo/[ID]`
- Output: `${CV_ROOT}/inprogress/<company>/<job>/`
- CV templates: `${CV_ROOT}/resume.tex`, `${CV_ROOT}/cover.tex`, `${CV_ROOT}/full_cv.tex`, `${CV_ROOT}/.secrets`
- Skill rules: `${SKILL_ROOT}/references/*.md` (pre-loaded once during initialization and passed to all subagents)

### Source Templates

All generated materials start from files in `${CV_ROOT}` — the `CV_ROOT` environment variable if set, otherwise `~/git/CV/`. `${SKILL_ROOT}` is this skill's own directory. Resolve both before use; do not assume a literal path.
- `${CV_ROOT}/full_cv.tex` — comprehensive resume with all experience (used for reference, not directly copied)
- `${CV_ROOT}/resume.tex` — canonical resume base, should be copied directly, using tools or `cp`, to the output directory before modifications are made.
- `${CV_ROOT}/cover.tex` — canonical cover letter base, should be copied directly, using tools or `cp`, to the output directory before modifcations are made.
- `${CV_ROOT}/.secrets` — contact info (`[EMAIL]`, `[PHONE]`, `[LINKEDIN_URL]`, `[LINKEDIN_USERNAME]`, `[GITHUB_URL]`, `[GITHUB_USERNAME]`, `[WEBSITE_URL]`, `[WEBSITE_NAME]`)

### Directory Structure

```
${CV_ROOT}/
  todo/              # Job postings (zero-padded by ID: 01, 02, ... N), these are files and not directories
  inprogress/        # In-progress runs <company_slug>/<job_slug>/*.tex, *.pdf, job_listing.md, match_report.md, meta.json
```

### Status States

- `complete` — Done with score ≥ 70
- `needs_user_input` — Missing or conflicting criteria (e.g., location, salary) or user confirmation required. Store the job and required question for later, process other jobs first.
- `failed` — Score below target after max retries, or max retries exhausted on any step
- `do_not_pursue` — Score < 40 or low relevance; no materials generated until user confirms

## Initialization: Load References

**Run this once at the start, before launching any subagents:**

1. Read all reference files from `${SKILL_ROOT}/references/`:
   - `acceptable_locations.md`
   - `additional_skills.md`
   - `non_experience_topics.md`
   - `rewrite_capsule.md`
   - `technical_hiring_manager.md`

## Hard Constraints

- Never fabricate jobs, titles, projects, dates, tools, publications, outcomes, or scope.
  **Why:** Employers verify claims — fabricated experience is grounds for immediate disqualification and reputational damage in a tight-knit field.
- My title in the capsule statement should always be similar to "PhD Physicist" or "Researcher". I should at most have "7+" years of experience. You may need to break that down into 3 years of professional experience at L3 and 4+ years of research experience at SMU.
- The capsule statement should be in natural language and flow well.
- Always preserve the truth of my experience and never add any claims not directly supported by the source templates.
- Keep resume structure and meaning close to `${CV_ROOT}/resume.tex`. Add jobs and skills from `${CV_ROOT}/full_cv.tex` only if they clearly improve relevance without changing facts.
- Ensure all sections and subsection remain with the same text, only sub content and locations may change. For example, "Selected Research Experience" must remain a section with the same name and only the bullets within it may be reordered or lightly reworded for emphasis.
- Do not dramatically rewrite section intent. Do NOT modify job, paper, or research titles. Only change the wording of the details points to better surface relevance, never to add new claims or change meaning.
- Keep cover letter to one page.
- Replace placeholders (`[PHONE]`, `[EMAIL]`, `[LINKEDIN_URL]`, `[LINKEDIN_USERNAME]`, `[GITHUB_URL]`, `[GITHUB_USERNAME]`, `[WEBSITE_URL]`, `[WEBSITE_NAME]`) with values from `${CV_ROOT}/.secrets`.

## Guard Rules — Enforce These at Every Step

### Rule 0: General Rules and Non-Experience Topics
- Use the pre-loaded `non_experience_topics.md` reference for the full list of Non-Experience Topics when deciding what to include in application materials. **Do not re-read the file.**
- Read `${CV_ROOT}/full_cv.tex` if you need to surface additional experience that closely matches the job posting.

### Rule 1: Section Guard — Keep Experience Categories Separated
Research bullets belong under "Selected Research Experience" (SMU, Prof. Meyers, Prof. Olness).
Professional bullets belong under "Professional Experience" (L3 Technologies).
Papers → "Selected Papers", Awards → "Selected Awards", Education → "Education".
**Why:** Recruiters scan resumes top-to-bottom looking for specific experience types. Mixing research and professional sections confuses the hiring manager about which part of my background is most relevant to their role.

### Rule 2: Base Resume Wording Preservation
After tailoring, compare each bullet against the original `${CV_ROOT}/resume.tex`:
- Ensure the EXACT job title is used in the capsule statement headline and matches the job posting. Use `grep` or `sed` to ensure the job title is present in the capsule statement.
- Do not modify section or subsection titles, only the content within may be lightly reworded for emphasis.
- Make only truthful tweaks that PRESERVE the original factual claims and structure.
- Never change job titles, project names, research paper titles, or company names.
- The generated resume must remain structurally close to base `${CV_ROOT}/resume.tex`.
**Why:** The base resume is carefully structured over years. Radical rewrites risk introducing inconsistencies or omitting important context that recruiters look for.

## Company and Job Slug Generation

1. Read the job posting and extract the employer name and job title, location and pay range information.
2. If employer not in first line, look for "Company Description" or "About Us" section, if still not found attempt to infer.
3. Convert boundaries to safe lowercase slugs (`company_slug` and `job_slug`): lowercase, spaces → underscores, remove special characters.
4. Handle duplicates: Ask the user to confirm if the slugs are correct or provide a custom slug if multiple similar company names exist, or if one should be skipped.

## Batch Execution Model

**Batch rule:** Read and process **one job at a time**, and **using `process-listing` subagents for all reading and writing tasks**, not all of `todo/*` at once.
**Why:** Each job requires its own `process-listing` subagent with focused context. Loading all jobs into one prompt wastes tokens on irrelevant postings and risks confusing the model about which job's materials to generate.

**Reference Initialization:** Before batch processing starts, the orchestrator loads all references once and passes their content inline in each subagent's task prompt. This ensures:
- References are only read **once**, not per-job
- Subagents can reference shared context without redundant file I/O
- Consistency across all jobs (all subagents work from the same reference versions)

Execution sequence:
1. **Initialize:** Load all references and package into context
2. Process jobs in order from `todo/`
3. For each job: complete all steps (folder creation through PDF build or failure)
4. If a job is flagged as `needs_user_input`, defer it — store the question for later and move to the next job
5. Return to deferred jobs only after all other jobs are complete
6. Present all accumulated questions to the user once

This ensures all completable tasks finish and all questions are gathered before user interruption.

## Per-Job Workflow

**Subagent Context:** Each subagent receives the pre-loaded reference context in context. **Do not re-read reference files from disk.** Use the references provided in your initial context prompt, which include:
- `acceptable_locations.md` — valid job locations
- `additional_skills.md` — rules for adding skills truthfully
- `non_experience_topics.md` — topics to never claim
- `rewrite_capsule.md` — capsule statement rewriting guidance
- `technical_hiring_manager.md` — scoring rubric and ranking criteria
Each `process-listing` subagent executes this sequence for its assigned job. Subagents report results back in their final response; the orchestrator collects those and does not poll mid-run.
All steps for the current job must be completed before moving on to the next one in `todo/`.

#### Sub-step 1a — Create Folder
**Every job gets a folder** in `inprogress/<company_slug>/<job_slug>/` regardless of match score. This ensures the batch output is complete and auditable.

1. Create `inprogress/<company_slug>/<job_slug>/` directory.
2. Copy the exact full posting text from `todo/[ID]` directly to `inprogress/<company_slug>/<job_slug>/job_listing.md`.
3. Initialize a `meta.json` file inside the new directory to store metadata (company name, role, initial scores, status).
4. Write a `match_report.md` scoring report (see Minimum Output for All Jobs below).

This step runs for every job, including those flagged as `do_not_pursue` after pre-ranking.

#### Sub-step 1b — Extract Requirements and Check Pre-Ranking Gate
Parse the `job_listing.md` content to extract:
- Company name and slug
- Location and remote status
- Salary range (if provided)
- Role title and slug
- Must-have requirements
- Nice-to-have requirements
- Top keywords

Update the specific metadata to `meta.json`.

**Hard Criteria Check (use pre-loaded references from initialization):**
- **Location:** The role must explicitly state it is "Remote" or located in one of the acceptable cities listed in the pre-loaded `acceptable_locations.md` reference, within a 50-mile radius of Dallas, TX. If location is not specified or is outside the acceptable list, flag as `needs_user_input` and record the question for the user. Do not reject outright — some postings are vague on location but may be open to remote candidates.
- **Salary:** If a salary is provided in the description, it must contain $100k/year in its range. It is okay if the salary range starts below this threshold as long as the upper bound is above it. If no salary is listed, this is not a stopper so keep going with the evaluation.
- **Additional Skills & Requirements:** Use the pre-loaded `additional_skills.md` reference for eligibility conditions. For example, jobs requiring an *active* security clearance are blockers (while clearance *eligibility* is acceptable), and ensure any physical requirements listed in the job description align with the capabilities detailed there.
- If these criteria are not met or are unclear, **do not reject**. Flag the job as `needs_user_input`, record the specific question for the user, and move on to the next job.

After passing hard criteria, score the base `${CV_ROOT}/resume.tex` against the job requirements using a new `process-listing` subagent based on the pre-loaded `technical_hiring_manager.md` reference. This will provide an initial match score and band. If the score is below 40, flag as `do_not_pursue` and skip to Step 2.

### Step 2 — Generate Application Materials
1. Copy `${CV_ROOT}/resume.tex` to `inprogress/<company_slug>/<job_slug>/resume.tex` using `cp ${CV_ROOT}/resume.tex inprogress/<company_slug>/<job_slug>/resume.tex`.
2. Copy `${CV_ROOT}/cover.tex` to `inprogress/<company_slug>/<job_slug>/cover.tex` using `cp ${CV_ROOT}/cover.tex inprogress/<company_slug>/<job_slug>/cover.tex`.
3. Rewrite the capsule statement (the professional summary at the beginning of the resume) for the role using only true claims. Follow the guidance in the pre-loaded `rewrite_capsule.md` reference to ensure the headline matches the job title exactly and includes 3-4 key skills drawn from the posting.
4. Reorder, and fill in, skills to mirror posting priorities. Use the pre-loaded `additional_skills.md` reference for rules on adding or emphasizing skills truthfully. Ensure that the pre-loaded `non_experience_topics.md` reference is consulted to avoid adding non-experience-based claims.
5. Lightly adjust bullet emphasis without changing factual meaning.
6. Replace contact info placeholders ([PHONE], [EMAIL], [LINKEDIN_URL], etc) in the `inprogress/<company_slug>/<job_slug>/resume.tex`, and `inprogress/<company_slug>/<job_slug>/cover.tex` files with values from `${CV_ROOT}/.secrets`.

### Step 3 — AI Writing Detection

After drafting the resume and cover letter, run the detecting-ai-writing skill on the new files.

**Rule:** If ANY tells are flagged, rewrite the flagged sections in plain, direct language before proceeding to PDF build.

Why this matters: AI writing detectors flag em-dash-heavy prose as a tell of LLM-generated text. Keep sentences straightforward — one idea per sentence, active verbs, no ornamental punctuation.

### Step 4 — Final Ranking

Use an independent subagent with the pre-loaded `technical_hiring_manager.md` reference to score the **drafted** materials (`inprogress/<company_slug>/<job_slug>/resume.tex` and `inprogress/<company_slug>/<job_slug>/cover.tex`). Explicitly instruct the subagent to use the reference provided. The output must follow the ranking format in the pre-loaded reference.

The rubric will produce both a **PRE_REVISION** score (for the base resume) and a **POST_REVISION** score (for the drafted materials). Compare the delta — a positive delta confirms tailoring added value. If delta is negative, explain why in your report.

### Step 5 — Retry Loop

If the POST_REVISION score is still below 70 after initial tailoring:
1. Analyze gaps from the match report and identify fixable items (keyword gaps, emphasis issues, ordering).
2. Make specific, actionable revisions to the resume and cover letter.
3. Restart at Step 3 (AI Writing Detection) to ensure the new revisions are not flagged, and then re-run Step 4 (Final Ranking) to check if the score has improved.
4. If after 2 full rounds of revision + re-scoring the score is still below 70, mark as `failed` for later human review.

### Step 6 — Validate Placeholders

After all revisions are complete and before running LaTeX builds, run the validation script:

```bash
${SKILL_ROOT}/scripts/validate_placeholders.sh inprogress/<company_slug>/<job_slug>/
```

It scans every `.tex` file in the directory for unfilled placeholders and exits non-zero, listing each one, if any remain.

**Rule:** A non-zero exit blocks the PDF build. Fill the reported placeholders — contact fields (`[EMAIL]`, `[PHONE]`, `[LINKEDIN_URL]`, `[LINKEDIN_USERNAME]`, `[GITHUB_URL]`, `[GITHUB_USERNAME]`, `[WEBSITE_URL]`, `[WEBSITE_NAME]`) from `${CV_ROOT}/.secrets`, job-specific fields (`[COMPANY_NAME]`, `[LOCATION]`, `[Position Title]`) from the posting — then re-run the script until it exits 0.

### Step 7 — PDF Build

Execute inside `inprogress/<company_slug>/<job_slug>/`:

```bash
latexmk -pdf resume.tex
latexmk -pdf cover.tex
```

Cleanup LaTeX build artifacts: remove all `.aux`, `.log`, `.fls`, `.fdb_latexmk`, `.out`, and `.toc` files. Only keep `.tex`, `.pdf`, `.md`, and `.json` files.

### Step 8 — Update Status

Write or update `inprogress/<company_slug>/<job_slug>/meta.json` with this schema:

```json
{
  "last_updated": "YYYY-MM-DD",
  "role": "Role Title",
  "company": "Company Name",
  "company_slug": "company_slug",
  "job_slug": "job_slug",
  "initial_score": "XX",
  "final_score": "XX",
  "ranking_band": "Band name",
  "status": "complete|do_not_pursue|failed|needs_user_input",
  "files": ["job_listing.md", "resume.tex", "cover.tex", "resume.pdf", "cover.pdf", "match_report.md", "meta.json"]
}
```

### Minimum Output for All Jobs

Every job produces at minimum the following output — even if scored as a weak match or flagged `do_not_pursue`:

```
inprogress/<company_slug>/<job_slug>/
  ├── job_listing.md           # Full raw job posting text copied from todo/
  ├── meta.json                # Job-specific metadata and tracking
  └── match_report.md          # Scoring report with pre-ranking scores and gap analysis
```

The `match_report.md` for low-scoring jobs (`do_not_pursue`) should contain:
- Pre-rank score and band (from the 100-point rubric)
- Top gaps blocking a higher score
- Summary of why the role is a poor fit
- Timestamp and job reference info

**No application materials** (resume, cover letter, PDFs) are generated for `do_not_pursue` jobs unless the user explicitly overrides.

## Output Contract

After all jobs complete and council review finishes:
1. Total processed, succeeded, failed, deferred for user input.
2. Apply-first list (sorted by final score, top-down).
3. Jobs marked `do_not_pursue` with reasons.
4. Borderline jobs (score 60–70) needing caution.
5. All accumulated questions for jobs marked `needs_user_input` gathered into one prompt for the user.
