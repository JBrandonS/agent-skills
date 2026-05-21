# AI Writing Detection — Quick-Reference Card

A condensed checklist for rapid text review. Look for **clusters** of tells, not single instances.

---

## TOP 5 STRONGEST TILLS (check these first)

1. **AI vocabulary density** — 3+ words from the banned list in one paragraph
   - "delve", "tapestry", "testament", "pivotal", "meticulous", "underscore", "fostering"
   - "vibrant", "intricate", "bolster", "garner", "boasts", "showcase"

2. **Fake or unverifiable citations** — References that sound plausible but you can't find

3. **Promotional tone in non-promotional context** — Reads like travel guide / press release

4. **Superficial analysis pattern** — Every paragraph ends with "-ing" significance claims

5. **Style discontinuity** — Writing voice suddenly changes vs surrounding text

---

## MEDIUM STRENGTH TILLS (look for combinations)

6. **Weasel attributions** — "experts argue", "industry reports show" without names

7. **Copulative avoidance** — "serves as" / "boasts" instead of natural "is" / "has"

8. **Negative parallelism** — "Not just X, but also Y" repeated without real misconceptions to correct

9. **Rule of three overuse** — Every list has exactly three items; every adjective cluster has three words

10. **Boldface overuse** — Key terms bolded throughout paragraphs like a slide deck

11. **Em dash overuse** — More frequent and formulaic than the author's usual style

12. **Title case headings** — Nearly all headings use Title Case rather than sentence case

---

## SOFT TILLS (only meaningful in clusters)

13. **Elegant variation abuse** — Synonym cycling for every repeated proper noun

14. **Curly quotation marks** — In a context where straight quotes are standard (inconclusive alone)

15. **Markdown in wrong format** — Markdown syntax pasted into non-Markdown document

16. **Canned collaborative language** — "I hope this helps" in formal writing

17. **Knowledge cutoff disclaimers** — "As of my last update..." in finished text

18. **Placeholder text** — "[Your Name]", "2025-XX-XX", "INSERT_SOURCE_URL_HERE"

19. **Emoji as formatting** — Emojis decorating headings or list items structurally

20. **Subject lines in discussion** — "Subject: ..." pasted into chat/comment context

---

## SCORING GUIDE

| Score | Interpretation | Action |
|-------|---------------|--------|
| 0–1 tell | Normal text | No action needed |
| 2 tells, different categories | Mild concern | Review more carefully |
| 3+ tells OR 2 from strongest group | Moderate concern | Verify citations, check style consistency |
| 5+ tells | Strong concern | Likely AI-generated; rewrite or verify authorship |
| 7+ tells | Very strong concern | Almost certainly AI; flag for review |

---

## MODEL DIFFERENTIATION

| Tell | ChatGPT | Claude | Gemini | Grok |
|------|---------|--------|--------|------|
| Boldface frequency | High | Low | Minimal | Moderate |
| Curly quotes | Yes | No | No | Yes |
| Verbosity | Very high | Concise | Moderate | High |
| Promotional tone | Strong | Mild | Weak | Moderate |
| Context scope | Broad | Focused | Factual | Broad |

---

## WHAT TO IGNORE (false positives)

- Perfect grammar alone
- "Bland" or formal prose alone
- Single instance of one AI vocabulary word
- Transition words like "Additionally" (only when frequent + combined with other tells)
- Unsourced content alone (most predates LLMs)
- Any single tell in isolation — clusters are what matter

---

*Based on analysis of Wikipedia:Signs_of_AI_writing, academic research, and observed LLM outputs.*
