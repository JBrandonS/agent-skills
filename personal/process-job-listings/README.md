# process-job-listings

Batch-process job postings into tailored application materials with automated ranking, AI writing detection, and PDF generation.

## Structure

```
process-job-listings/
├── SKILL.md                  # Orchestrates the full batch workflow
├── README.md                 # This file
├── evals/                    # Test cases for evaluation (not loaded at runtime)
│   └── evals.json            # Prompt set for testing skill performance
├── references/               # Domain knowledge loaded on demand
│   ├── non_experience_topics.md    # What NOT to claim on resumes
│   ├── acceptable_locations.md     # Valid job locations (DFW metro)
│   ├── additional_skills.md        # Flexibility rules for skills/clearances
│   └── technical_hiring_manager.md # 100-point scoring rubric for ranking
├── scripts/                  # Reusable helper scripts
│   └── validate_placeholders.sh  # Scan .tex files for unfilled placeholders
└── .serena/                  # Serena project config (code navigation)
```

## How It Works

1. **Input:** Job postings in `${CV_ROOT}/todo/[ID]` (zero-padded)
2. **Output:** Tailored materials in `${CV_ROOT}/inprogress/<company>/<job>/`
3. **Flow per job:** Setup → Gate check → Tailor → AI writing check → Rank → Retry if needed → PDF build → Status update
4. **Final council review** consolidates results into a ranked apply-first list

## CV Source Files (at `${CV_ROOT}/`)

- `resume.tex` — Canonical resume base
- `full_cv.tex` — Comprehensive resume (reference only)
- `cover.tex` — Cover letter base
- `.secrets` — Contact placeholders

## Customization

- Update `references/non_experience_topics.md` if the candidate's actual skills change
- Update `references/acceptable_locations.md` for new geographic constraints
