---
name: job-application-adaptation
description: Create truthful, job-specific resumes and cover letters from base CV templates. Use when adapting Brandon Stevenson's resume for a specific job posting — reframing real experience to match the role without fabricating anything.
---

# Job Application Adaptation

Create tailored resume and cover letter PDFs from base CV templates for a given job posting. The goal is reframe real experience for the role, not invent new experience.

## Prerequisites

Before you begin read in the following files. This MUST be done prior to do anything else.

- Base CV templates at `~/git/CV/`:
  - `resume_25.tex` — canonical source of factual content
  - `resume_25_engineering.tex` — starting template with allowed light reframing
  - `engineering_cover.tex` — cover letter template
  - `.secrets` — contact info (PHONE, EMAIL)
- LaTeX build toolchain: `latexmk`, `pdflatex`

## Source of Truth

Always read both templates before editing:

1. `resume_25.tex` is the canonical factual source — all job titles, dates, project names, and core facts must remain accurate.
2. `resume_25_engineering.tex` shows the maximum allowed level of reframing.

**Rule:** If a change would make the resume look meaningfully different from `resume_25.tex`, it is probably too far. Keep adaptations tight, honest, and role-aware.

## What to Preserve

- Actual job titles and dates
- Real project names and publications
- True tools, methods, and outcomes
- Overall structure of source templates

## What You May Adjust

- Summary wording to match the role
- Section order to highlight most relevant experience first
- Skills ordering to mirror the job posting
- Bullet emphasis (facts must not change)
- Section labels only with minor reframing

## What Not to Do

- Fabricate jobs, projects, or titles
- Rewrite experience to imply work that did not happen
- Exaggerate scale, impact, or timeline
- Dramatically change section names or bullet meaning
- Use em dashes

## Pre-Adaptation Fit Check

Before adapting anything, evaluate whether the ground-truth resume (`resume_25.tex`) is a reasonable match for the job posting.

1. Read the job posting and extract key requirements (skills, experience level, domain knowledge, must-haves).
2. Cross-reference against `resume_25.tex` — check for:
   - **Required skills overlap:** Are most must-have skills present in the resume?
   - **Experience level match:** Does the seniority align (e.g., entry-level vs 7+ years)?
   - **Domain relevance:** Is the field/domain reasonable (e.g., ML, data engineering, systems)?
   - **Red flags:** Any glaring gaps that would make the application look desperate or mismatched (e.g., job requires 10 years Java and the resume has zero Java).

**Decision rule:**
- If there is strong overlap in skills, experience level, and domain → proceed with adaptation.
- If there are major gaps (e.g., core required skill entirely absent, seniority mismatch, or domain is completely unrelated) → **stop and ask the user** whether to proceed anyway. Present a brief summary of what matches and what is missing.

Example prompt to user if bad match:

> The job requires [X] and [Y], but your resume shows no experience in those areas. Your strongest matches are [A] and [B]. Do you still want me to proceed with the application?

## Workflow

1. **Read the job posting** — extract main requirements, keywords, and desired skills.
2. **Create application folder** — `~/git/CV/applications/[NAME]/` where `[NAME]` is a lowercase slug (e.g., `capital_one`).
3. **Save the posting** — write the full job description to `applications/[NAME]/job_listing.md`.
4. **Copy templates** — copy `resume_25_engineering.tex` and `engineering_cover.tex` into the application folder, renaming them to `[NAME]_resume.tex` and `[NAME]_cover.tex`.
5. **Adapt the resume:**
   - Reframe the summary to match the role's focus
   - Reorder skills to mirror the job posting's priority list
   - Adjust bullet emphasis toward the most relevant truths (no fabrication)
   - Replace placeholder contact info using `~/git/CV/.secrets`
6. **Adapt the cover letter:**
   - Replace `[Company Name]`, `[Position Title]`, and location placeholders
   - Tailor the opening to reference the specific role
   - Adjust body bullets to highlight relevant experience for this position
   - Keep to one page, 2 short body paragraphs focused on relevant experience
7. **Build PDFs** — compile inside the application folder.

## PDF Build Commands

```bash
cd ~/git/CV/applications/[NAME]
latexmk -pdf [NAME]_resume.tex
latexmk -pdf [NAME]_cover.tex
```

Verify both `.pdf` files are generated and non-empty.

## Quality Check

Before building, verify:

- Resume still matches source templates closely in structure and facts
- Skills order reflects the job posting's priorities
- Cover letter is specific to the company and role
- All facts are unchanged and accurate
- LaTeX compiles cleanly (no errors)
- No em dashes used anywhere

## Practical Rule

When in doubt, err on the side of conservatism. The resume should look like Brandon Stevenson's actual resume, just with emphasis shifted toward the target role.

## Job Posting Extraction

LinkedIn job postings require special handling due to sign-in walls. See `references/linkedin-extraction.md` for the extraction technique.

## Resume Length

Keep resumes to 2 pages maximum. If compilation produces 3+ pages:
- Shorten bullet points (remove redundant words, merge related items)
- Tighten skills descriptions (use abbreviations like "C/C++" instead of "C, C++")
- Reduce section spacing (adjust `\titlespacing` values if needed)
- Minor overfull hbox warnings are acceptable; major ones (>20pt) should be fixed by breaking long lines.
