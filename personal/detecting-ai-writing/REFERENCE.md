# AI Writing Tells Reference Catalog

Complete catalog of AI prose signals. **No single tell is definitive — look for clusters.** Observed across ChatGPT, Claude, Gemini, and Grok.

## Contents

- **Lexical** — 1. Vocabulary overuse · 2. Undue significance · 3. Superficial "-ing" analysis · 4. Promotional language · 5. Vague attributions
- **Rhetorical** — 6. Negative parallelism · 7. Rule of three · 8. Elegant variation · 9. Copulative avoidance · 10. Challenge/future sections · 11. Leading-list definitions
- **Formatting** — 12. Em dashes · 13. Inline-header lists · 14. Boldface · 15. Title case · 16. Curly quotes · 17. Markdown in non-Markdown contexts · 18. Emoji as structure
- **Leaked chatbot artifacts** — 19. Canned correspondence · 20. Knowledge-cutoff disclaimers · 21. Placeholder text · 22. Canned offers to receive criticism · 23. Subject lines · 24. Excessive edit summaries · 25. Submission statements
- **Discussion-context tells** — 26. Hallucinated policies · 27. Wikilawyering
- **Authorship** — 28. Style discontinuity
- [Ineffective indicators](#ineffective-indicators) — what does *not* work
- [Model-specific tells](#model-specific-tells) · [Research sources](#research-sources)

---

## Lexical

### 1. Vocabulary overuse

Words that spiked post-2022 and co-occur: where there's one, expect others.

- **Era 1 (GPT-4, 2023–mid 2024):** additionally, boasts, bolstered, crucial, delve, emphasizing, enduring, garner, intricate/intricacies, interplay, key, landscape, meticulous, pivotal, underscore, tapestry, testament, valuable, vibrant
- **Era 2 (GPT-4o, mid 2024–mid 2025):** align with, bolstered, crucial, emphasizing, enhance, enduring, fostering, highlighting, pivotal, showcasing, underscore, vibrant
- **Era 3 (GPT-5+, mid 2025+):** emphasizing, enhance, highlighting, showcasing

**Signal:** 3+ in one paragraph. Co-occurrence *across eras* ("delve" + "showcasing") is very strong — those sets rarely appear together naturally.

### 2. Undue emphasis on significance

Arbitrary details get inflated into broader importance.

**Watch:** stands/serves as, is a testament/reminder, a vital/significant/crucial/pivotal role, underscores its importance, reflects broader, symbolizing its enduring, contributing to the, setting the stage for, marks a shift, key turning point, evolving landscape, focal point, indelible mark, deeply rooted

> "This etymology highlights the enduring legacy of the community's resistance and the transformative power of unity in shaping its identity." (about a town name)

**Signal:** Mundane subjects — population data, etymology, small companies — receive grandiose societal-impact claims.

### 3. Superficial "-ing" analysis

Present-participle phrases tacked onto factual sentences.

**Watch:** highlighting/underscoring/emphasizing, ensuring, reflecting/symbolizing, contributing to, cultivating/fostering, encompassing, valuable insights, align/resonate with

> "...creating a lively community within its borders." (after census data)
> "...reflecting its continued relevance in the regional transportation landscape." (about a railway station)

**Signal:** Every paragraph ends with an "-ing" clause claiming impact the facts don't support.

### 4. Promotional language

Drift into travel-guide or press-release tone where neutrality is expected.

**Watch:** boasts a, vibrant, rich, profound, enhancing, showcasing, exemplifies, commitment to, natural beauty, nestled, in the heart of, groundbreaking, renowned, featuring, diverse array, seamlessly, captivating

Subtypes: heritage padding ("Nestled within the breathtaking region... stands as a vibrant town with a rich cultural heritage"); corporate press-release tone; product-brochure prose for mundane subjects.

### 5. Vague attributions

**Watch:** industry reports, observers have cited, experts argue, some critics argue, several sources (when few are cited), "such as" before exhaustive lists

**Signal:** Claims attributed to "researchers and conservationists" with no named source; one source's view presented as widely held.

---

## Rhetorical

### 6. Negative parallelism

Retroactively correcting a misconception nobody held.

- "Not just X, but also Y" — "It is not just a meme, it's a celebration"
- "It's not ..., it's ..."
- "No ..., no ..., just ..." — "Not a career, not a body of work — just an algorithmic moment"

**Signal:** Common when the model is reaching for "nuance."

### 7. Rule of three

Three adjectives ("bold, elegant, and timeless"), three noun phrases, three clauses. **Signal:** *Every* list has exactly three items. Humans often use two or four.

### 8. Elegant variation

Repetition penalty causes synonym cycling: "Vierny" → "the artist" → "her" → "Dina Vierny" → back around; or "protagonist," "key player," "eponymous figure" instead of the name. More frequent in longer texts.

### 9. Copulative avoidance

Elaborate verbs replacing "is"/"has".

**Watch:** serves as / stands as / marks / represents [a], boasts / features / maintains / offers [a], "refers to" when the subject isn't the word itself

> "Gallery 825 serves as LAAA's exhibition space" → "is LAAA's exhibition arm"

One study found a >10% drop in "is"/"are" usage in academic writing after ChatGPT's launch.

### 10. Challenge/future sections

Rigid template at article endings: "Despite its [positives], [subject] faces challenges typical of [category]" → vague optimism ("continues to thrive"). **Signal:** the formulaic structure, not the mention of difficulties.

### 11. Leading-list definitions

A list or category title defined as though it were a real entity: "The 'List of songs about Mexico' is a curated compilation of musical works that reference Mexico..."

---

## Formatting

### 12. Em dashes
Used where humans would pick commas, parentheses, or colons; formulaic clause-emphasis mimicking sales copy. More common in discussion text. GPT-5.1+ suppresses them, so absence proves nothing.

### 13. Inline-header vertical lists
Every bullet as `**Bold Header**: description`, regardless of whether prose would serve better.

### 14. Boldface overuse
Every instance of key terms bolded; "Key Takeaways" density; bold used structurally instead of for first-use definitions or genuine emphasis.

### 15. Title case headings
"Impact of Technology and Digitalization" where sentence case is the norm — especially in Markdown and informal text.

### 16. Curly quotes
ChatGPT and DeepSeek emit curly quotes and apostrophes; Claude and Gemini typically don't. **Weak alone** — Word, macOS, and typesetting also produce them. Only counts alongside other tells.

### 17. Markdown in non-Markdown contexts
`**bold**`, `# Heading`, `*italic*` in wikitext, HTML, or plain text; mixed syntax in one document.

### 18. Emoji as structure
Emoji decorating every heading or bullet ("🧠 Cognitive Dissonance Pattern:") rather than emphasizing content. More common in older models.

---

## Leaked chatbot artifacts

Text meant for the user, pasted into the finished product.

### 19. Canned correspondence
"I hope this helps", "Of course!", "Certainly!", "You're absolutely right!", "Would you like...", "let me know", "here is a ..."

### 20. Knowledge-cutoff disclaimers
"as of [date]", "up to my last training update", "while specific details are limited", "not widely available/documented", "in the provided sources", "based on available information"

### 21. Placeholder text
"[Describe the specific section]", "[link to source list]", "Best regards, [Your Name]", dates like "2025-XX-XX", URLs like "INSERT_SOURCE_URL_30"

### 22. Canned offers to receive criticism
"If you have any concerns/suggestions", "I am willing/happy to address", "I welcome any further input/guidance/feedback" — where a human would be specific ("I'll move the economic section").

### 23. Subject lines in discussion text
"Subject: Request for Permission to Edit Wikipedia Article - 'Dog'" — email structure in an informal context.

### 24. Excessive edit summaries
Formal paragraphs echoing policy language, or itemized compliance lists, where a one-line description belongs.

### 25. Submission statements in drafts
Reviewer-facing blocks inside the draft: "Reviewer note (for AfC): This draft is a neutral and well-sourced biography..."

---

## Discussion-context tells

### 26. Hallucinated policies
Fake shortcuts ("WP:NOTENGLISH clearly states..."), misattributed policies with invented quotes, citations that resolve nowhere.

### 27. Wikilawyering
Selective, authoritative-sounding policy citation that's misapplied — invoking WP:PRESERVE regardless of the deletion rationale, or citing AI-detection guidelines to dismiss AI-content concerns. Reads like a legal brief.

---

## Authorship

### 28. Style discontinuity
Sudden change in tone, formality, grammar quality, or English variety versus the same author's other work: flawless grammar from an error-prone editor, American English from a non-US writer, formal register where casual is the norm. Especially suspicious if their pre-Nov-2022 writing differs.

---

## Ineffective indicators

Commonly mistaken for AI tells; **not** reliable:

- **Perfect grammar** — skilled writers and good editing exist
- **"Bland" or "robotic" prose** — subjective; reads as clear to others
- **"Fancy" or academic prose** — LLMs favor specific words, not formality generally
- **Letter-like writing** — formal salutations predate LLMs
- **Transition words alone** — only a few are AI-skewed (additionally, consequently, notably)
- **Unsourced content** — most predates LLMs; AI text often *has* citations (possibly fake)
- **A single AI vocabulary word** — 1–2 occurrences are coincidental or borrowed from a source

## Model-specific tells

| Tell | ChatGPT | Claude | Gemini | Grok |
|------|---------|--------|--------|------|
| Verbosity | High | Lower | Moderate | High |
| Boldface | Frequent | Less | Rare | Moderate |
| Curly quotes | Yes | No | No | Yes |
| Context focus | Broad | Focused | Factual | Broad |
| Promotional tone | Blatant | Subtle | Minimal | Moderate |
| Em dashes | Frequent | Less | Less | Frequent |

Vocabulary shifts by generation — GPT-5+ replaced "delve" and "tapestry" with "emphasizing, enhance, highlighting, showcasing." Detection must account for model version.

## Research sources

- Russell et al. (2025), *People who frequently use ChatGPT for writing tasks are accurate and robust detectors* — ACL
- Reinhart et al. (2025), *Do LLMs write like humans? Variation in grammatical and rhetorical styles* — PNAS
- Kriss (2025), *Why Does A.I. Write Like … That?* — NYT
- Merrill et al. (2025), *What are the clues that ChatGPT wrote something?* — Washington Post
- Kobak et al. (2025), *Delving into LLM-assisted writing in biomedical publications through excess vocabulary* — Science Advances
- Geng & Trotta (2025), *Human-LLM Coevolution: Evidence from Academic Writing*
