# AI Prose Detection Patterns

Detection patterns for scanning text files for AI-generated writing tells. Organized by category with regex patterns and interpretation guidance.

## AI Vocabulary Scanner

Counts occurrences of high-frequency AI words in text blocks. Works across eras.

```bash
# Single-file scan (case-insensitive)
rg -ioP '(delve|tapestry|testament|meticulous|pivotal|crucial|intricate|boasts?|garner|bolster|underscores?|showcases?|fostering|enhances?|vibrant|valuable|enduring|align with|landscape)' FILE | wc -l

# Count per paragraph
rg -P '^\s*$' --multiline-dotall -N -A 0 FILE | grep -oiP '(delve|tapestry|testament|...' | wc -l
```

**Threshold:** 2+ words in a single paragraph = mild signal. 3+ words = strong signal. Co-occurring words from different eras (e.g., "delve" + "showcasing") is very strong signal — those word sets rarely appear together naturally.

## Copulative Avoidance Scanner

Detects deliberate substitution of "is"/"has" with more elaborate alternatives.

```bash
# Serves as / stands as patterns
rg -P '\bserves?\s+(as|to)\b' FILE

# Boasts pattern (meaning "has")
rg -P '\bboasts?\s+(a |an |the |of )' FILE

# Stands as / marks the / represents a patterns
rg -P '\bstands?\s+(as|for)\b|\bmarks?\s+(a |the |his |her |its )\b|\brepresents?\s+(a |an )' FILE

# Marketing verbs for "has"
rg -P '\boffers?\s+(a |an )|\bfeatures?\s+(a |an )' FILE
```

**Interpretation:** A single instance is fine. 3+ instances in a short text is a signal, especially when combined with other tells.

## Weasel Attribution Scanner

Detects vague authority attributions common in AI writing.

```bash
# Generic expert/researcher citations
rg -P '\b(?:experts?|researchers?|scholars?|observers?)\s+(argue|note|say|claim|suggest|observe)\b' FILE

# Industry/field reports
rg -P '\b(?:industry|academic|research)?\s*(reports?|studies|sources?)\s+(show|suggest|indicate|reveal|demonstrate)\b' FILE

# Widely-known / widely-cited claims
rg -P '\bit\s+(is|was)\s+widely?\s+(known|recognized|acknowledged|accepted|agreed)\b' FILE

# Some critics / some argue
rg -P '\bsome\s+(critics?|experts?|researchers?)\s+(argue|note|suggest)\b' FILE
```

**Interpretation:** Any instance warrants checking — can the claim be traced to a specific named source? Vague attribution is almost never useful in good writing.

## Superficial Analysis Scanner

Detects "-ing" phrases appended to factual sentences that add significance claims beyond what facts support.

```bash
# Ending -ing clauses (after periods)
rg -P '\.\s+\w+.*?(highlighting|underscoring|emphasizing|reflecting|symbolizing|contributing|fostering|enhancing|showcasing|ensuring).*?\.' FILE

# Present participle as significance claim
rg -P ',\s+(thereby|thus|creating|making|establishing|positioning|highlighting|underscoring)\b' FILE
```

**Interpretation:** If every paragraph has a sentence ending in one of these patterns, it's a strong signal. Humans use them selectively; AI uses them formulaically on nearly every fact statement.

## Negative Parallelism Scanner

Detects "not just X but also Y" and "not X, but Y" patterns.

```bash
# Not just/only X, but also Y
rg -P 'not\s+(just\s+)?(only\s+)?\w+,\s*(?:but\s+also|but)\s+' FILE

# It's not X, it's Y
rg -P '(?:is|was|are|were)\s+(?:not|no)\s+\w+(?:.*)?,?\s*it?s?\s+(just|a |an )' FILE

# Not X but Y (concise form)
rg -P '\bnot\s+\w+\s+but\s+\w+' FILE
```

**Interpretation:** Occasional use is fine (when correcting real misconceptions). 2+ instances in a short text without clear miscontext to correct = likely AI.

## Rule of Three Scanner

Detects clusters of exactly three parallel items.

```bash
# Three adjectives before a noun
rg -P '\b\w+,\s*\w+,\s*and\s+\w+\s+(noun|adjective)' FILE

# Three noun phrases in series with "and"
rg -P '\b[a-z]+,\s*[a-z]+,\s*and\s+[a-z]+\b' FILE
```

**Interpretation:** This is a soft signal — three-item lists are natural in human writing. Look for this combined with other tells. When *every* list has exactly three items, the signal strengthens.

## Promotional Tone Scanner

Detects travel-guide and press-release language common in AI writing.

```bash
# Travel guide vocabulary
rg -P '\b(?:nestled|breathtaking|vibrant|charming|stunning|picturesque)\b' FILE

# Press release vocabulary
rg -P '\b(?:boasts|showcasing|exemplifies|dedication\s+to|commitment\s+to|world-class|unparalleled|premier)\b' FILE

# Marketing buzzword combinations
rg -P 'rich\s+(heritage|tapestry|history|culture|tradition)' FILE
```

**Interpretation:** One instance in a marketing context is fine. Multiple instances in non-marketing text = signal. "Rich tapestry" + "vibrant" + "nestled" appearing together is almost certainly AI.

## Challenge/Future Template Scanner

Detects formulaic challenge acknowledgment sections.

```bash
# Opening template
rg -P 'Despite\s+(its|their)\s+\w+,\s+(?:it|the|this)\s+\w+\s+faces?\s+(?:several|numerous|multiple|various)?\s+challenges?\b' FILE

# Closing template
rg -P '\bDespite\s+(these\s+)?(?:fewer|similar)\s+challenges?,\s+(?:it|the|this)\s+\w+\s+(continues?\s+to|remains?|stands?)' FILE

# Section headers
rg -P '(Challenges|Future|Outlook|Prospects|Looking\s+ahead)' FILE
```

**Interpretation:** If a text has both an opening challenge template AND a closing optimism template, it's following the AI formula. Combined with other tells = strong signal.

## Elegant Variation Scanner

Detects unnecessary synonym cycling for repeated proper nouns (indirect detection — compare against author's style).

```bash
# Look for patterns where one entity is called by many different names
rg -P '\b(?:the?\s+(?:artist|musician|composer|conductor|pioneer|visionary|figure|individual|professional))\b' FILE | sort | uniq -c | sort -rn
```

**Interpretation:** If a specific person is referred to as "Yankilevsky," "the artist," "the visionary," "the Russian avant-garde figure," etc. — that's elegant variation abuse. Compare against surrounding text by the same author; if this pattern appears suddenly, it may be AI-injected.

## Markdown in Wrong Context Scanner

Detects Markdown formatting pasted into non-Markdown contexts.

```bash
# Markdown-style bold
rg -P '\*\*[^*]+\*\*' FILE

# Markdown-style headers
rg -P '^#{1,6}\s+\w' FILE

# Mixed markup (e.g., Markdown + HTML or Wikitext)
rg -P '(\*\*|`|##|---)\s+.*?\{\{' FILE
```

**Interpretation:** If the document format is NOT Markdown (e.g., plain text, Wikipedia wikitext, email), finding Markdown syntax = strong AI tell. Markdown-only in Markdown contexts is not a signal.
