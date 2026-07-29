---
name: detecting-ai-writing
description: Use when reviewing prose that may have been written or heavily edited by an LLM, when text needs to be scanned for AI writing tells before publishing, or when a draft reads generically and the cause is unclear. Triggers on "check for AI writing", "detect AI prose", "is this AI written", "does this sound like ChatGPT", and on writing/editing review where authorship is in question.
---

# AI Writing Detector

Detect AI-written prose anti-patterns using lexical, structural, and stylistic signals, then rewrite or flag.

**Core principle:** No single tell is proof. AI prose is identified by *clusters* of tells in the same passage — one "delve" means nothing, three tells in one paragraph means a lot.

## Reference files

- [QUICK_REFERENCE.md](QUICK_REFERENCE.md) — scannable card: strongest tells first, scoring guide, known false positives. Start here for a fast judgment call.
- [REFERENCE.md](REFERENCE.md) — complete catalog of 24 tells with examples and explanations. Use when you need to justify a finding or handle an unusual case.
- [detection-patterns.md](detection-patterns.md) — ready-to-run `rg` commands for each tell category. Use when scanning files rather than reading passages.

## Review checklist

Work down this list. Note each hit and where it clusters.

1. **AI vocabulary** — "delve", "tapestry", "pivotal", "underscore", "fostering", "boasts"
2. **Promotional tone** — reads like a travel guide or press release when it shouldn't
3. **Superficial analysis** — trailing "-ing" clauses that restate a fact as if it were insight
4. **Rule of three** — clusters of exactly three items, formulaic rather than exhaustive
5. **Negative parallelism** — "not just X, but Y" / "it's not A, it's B"
6. **Elegant variation** — synonym cycling for every repeated proper noun
7. **Copulative avoidance** — "serves as", "stands as", "boasts" where "is"/"has" belongs
8. **Citation quality** — plausible-sounding references that may not exist
9. **Style shifts** — tone or formality changing abruptly mid-document
10. **Weasel attributions** — "experts argue", "industry reports show", no named source

For file-based scanning, run the commands in [detection-patterns.md](detection-patterns.md) instead of reading line by line.

## Scoring

| Signal | Weight | Severity |
|--------|--------|----------|
| High AI vocabulary density (3+ words) | 0.20 | Critical |
| Fake/hallucinated citations | 0.18 | Critical |
| Promotional tone where inappropriate | 0.14 | High |
| Superficial analysis (-ing phrases throughout) | 0.12 | Medium |
| Vague attributions | 0.10 | Medium |
| Copulative avoidance | 0.08 | Medium |
| Rule of three overuse | 0.06 | Low |
| Negative parallelism overuse | 0.05 | Low |
| Elegant variation abuse | 0.04 | Low |
| Pronounced style discontinuity | 0.03 | Low |

**> 0.3** — flag for human review. **> 0.5** — likely AI-generated; rewrite or verify with the author.

## Questions for the author

When a passage scores above threshold and the author is available:

- "Can you walk me through why you chose this phrasing?"
- "What specific details support that claim about significance?"
- "Where did this information come from — is the reference checkable?"
- "How does this fit the voice of the surrounding text?"

## Citation verification

For any cited claim: does the DOI resolve to the right paper, is the page number accurate, do links load, does the source actually say what the text claims, are ISBN checksums valid, and is there any placeholder text left (`INSERT_SOURCE_URL`, `2025-XX-XX`)?

## Prevention

Add to agent or system prompts that generate prose:

```
Write with a specific voice, not a generic one. Avoid promotional language unless the context demands it.
Use "is" and "has" naturally — don't substitute "serves as" or "boasts" for variety.
Be concrete. Replace "valuable insights" and "pivotal role" with actual specifics.
Do not use negative parallelism ("not just X, but Y") unless a real misconception needs correcting.
Avoid the rule of three when two items suffice — it is a common AI tell.
Verify every citation before including it. If you can't check the reference, don't include it.
Match the tone and register of surrounding text exactly.
```

## Model idiolects

Tells cluster differently by model, which helps attribute a draft:

- **ChatGPT (GPT-4 era)** — heavy boldface, promotional language, curly quotes, verbose
- **Claude** — more concise, less boldface, straight quotes
- **Gemini** — factual and concise, fewer superlatives
- **Grok** — broad context framing, verbosity similar to ChatGPT

## Common mistakes

- **Judging on a single tell.** Human writers use "crucial" and the rule of three. Require a cluster.
- **Scanning code or quoted material.** Detection applies to authored prose. Exclude code blocks, direct quotations, and cited passages before scoring.
- **Treating the score as a verdict.** It ranks passages for review; it does not establish authorship.
