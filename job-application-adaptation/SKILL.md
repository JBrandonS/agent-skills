---
name: job-application-adaptation
description: Create truthful, job-specific resumes and cover letters from base CV templates. Use when adapting Brandon Stevenson's resume for a specific job posting — reframing real experience to match the role without fabricating anything.
---

# Job Application Adaptation

Create tailored resume and cover letter PDFs from base CV templates for a given job posting. The goal is reframe real experience for the role, not invent new experience.

## Prerequisites

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
