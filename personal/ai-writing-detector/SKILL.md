---
name: ai-writing-detector
description: Detects AI-generated prose/writing anti-patterns and prevents AI slop from entering written content. Use during writing review, editing, copywriting, or when reviewing text that may contain AI-written prose tells. Triggers on phrases like "check for AI writing", "detect AI prose", "review this text", "is this AI written", or when the user asks to scan for AI-generated writing tells in natural language.
---

# AI Writing Detector

Detect and prevent AI-written prose anti-patterns using lexical, structural, and stylistic checks. See [REFERENCE.md](REFERENCE.md) for the complete catalog of AI tells.

## Quick Review Checklist (Writing Review)

When reviewing suspected AI-generated prose:

1. **AI vocabulary** — Overuse of words like "delve", "tapestry", "pivotal", "underscore", "fostering"?
2. **Promotional tone** — Reads like a travel guide or press release when it shouldn't?
3. **Superficial analysis** — "-ing" phrases tacked on to state facts without real insight?
4. **Rule of three** — Clusters of exactly three items that feel formulaic?
5. **Negative parallelism** — "Not just X, but also Y" or "It's not ..., it's ..."?
6. **Elegant variation** — Unnecessary synonym cycling for every repeated proper noun?
7. **Copulative avoidance** — "serves as", "stands as", "boasts" instead of "is", "has"?
8. **Citation quality** — References that sound plausible but may not exist or verify?
9. **Style shifts** — Sudden tone/formality changes compared to surrounding text?
10. **Weasel attributions** — "Experts argue", "Industry reports show" with no specific source?

### Review Prompts for Suspected AI Writing

Ask the author:
- "Can you walk me through why you chose this phrasing?"
- "What specific details support that claim about significance?"
- "Where did this information come from — is the reference checkable?"
- "How does this fit the voice of the surrounding text?"

## Text-Grep Detection Patterns

Run these against text files to find suspicious patterns:

### AI Vocabulary Overuse
```bash
# Common AI words (case-insensitive)
rg -i -P '(delve|tapestry|testament|meticulous|pivotal|crucial|intricate|boasts|garner|bolster|underscores|showcases|fostering|enhances)' FILE

# Co-occurrence check (2+ AI words in same paragraph = strong signal)
```

### Structural Tells
```bash
# "Not just X, but also Y" / negative parallelism
rg -P 'not\s+(just\s+)?(only\s+)?\w+,?\s*(but|also)\s*' FILE

# Rule of three (three adjectives or nouns in series)
rg -P '\b\w+\s+\w+,?\s+\w+\s+(and|&)\s+\w+' FILE

# Vague attributions
rg -i -P '(experts?\s+(argue|note|say)|industry\s+reports?\s*(show|suggest|indicate)|it\s+is?\swidely?\s+(known|recognized|acknowledged)))' FILE

# Copulative avoidance (euphemistic "is")
rg -P '(serves?\s+(as|to)|stands?\s+(as|for)|marks?\s+(a|the)|represents?\s+(a|an)|boasts?)\s+' FILE
```

## Pre-Commit Prevention (Agent Instructions)

Add to agent/system prompts:
```
Write with a specific voice, not a generic one. Avoid promotional language unless the context demands it.
Use "is" and "has" naturally — don't substitute "serves as" or "boasts" for variety.
Be concrete. Replace "valuable insights" and "pivotal role" with actual specifics.
Do not use negative parallelism ("not just X, but Y") unless a real misconception needs correcting.
Avoid the rule of three when two items suffice — it is a common AI tell.
Verify every citation before including it. If you can't check the reference, don't include it.
Match the tone and register of surrounding text exactly.
```

## Citation Verification Checklist

For any cited claim, verify:
1. Does the DOI resolve to the correct paper?
2. Is the book page number accurate (for print-only sources)?
3. Are external links accessible (not 404s)?
4. Does the source actually say what the text claims?
5. Are ISBN checksums valid?
6. No placeholder text like "INSERT_SOURCE_URL" or "2025-XX-XX"?

## Scoring Model

| Signal | Weight | Severity |
|--------|--------|----------|
| High AI vocabulary density (3+ words) | 0.20 | Critical |
| Fake/hallucinated citations | 0.18 | Critical |
| Promotional/travel-guide tone inappropriately | 0.14 | High |
| Superficial analysis (-ing phrases on every paragraph) | 0.12 | Medium |
| Vague attributions (weasel wording) | 0.10 | Medium |
| Copulative avoidance pattern | 0.08 | Medium |
| Rule of three overuse | 0.06 | Low |
| Negative parallelism overuse | 0.05 | Low |
| Elegant variation abuse | 0.04 | Low |
| Pronounced style discontinuity | 0.03 | Low |

**Score > 0.3**: Flag for human review
**Score > 0.5**: Likely AI-generated prose, needs rewrite or author verification

## Distinguishing Between AI Models

Different LLMs have different idiolects:

- **ChatGPT (GPT-4 era)**: Higher boldface usage, more promotional language, curly quotation marks ("..."), more verbose
- **Claude**: More concise, fewer boldface elements, straight quotes
- **Gemini**: Tends to be more factual/concise, less superlative language
- **Grok**: Broader context focus, similar to ChatGPT in verbosity

When evaluating, consider which tells cluster and match the model's known patterns.
