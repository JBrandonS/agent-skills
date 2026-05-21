# AI Writing Tells Reference Catalog

Complete catalog of AI-generated prose signals organized by category. These are patterns to look for during review — no single signal is definitive; look for clusters of tells. Based on observed patterns from LLM outputs including ChatGPT, Claude, Gemini, and Grok.

## 1. AI Vocabulary Overuse

LLMs overuse specific words that started appearing far more frequently post-2022. They often co-occur: where there is one, there are likely others.

**Era 1 (GPT-4, 2023–mid 2024):** Additionally, boasts, bolstered, crucial, delve, emphasizing, enduring, garner, intricate/intricacies, interplay, key, landscape, meticulous/meticulously, pivotal, underscore, tapestry, testament, valuable, vibrant

**Era 2 (GPT-4o, mid 2024–mid 2025):** align with, bolstered, crucial, emphasizing, enhance, enduring, fostering, highlighting, pivotal, showcasing, underscore, vibrant

**Era 3 (GPT-5+, mid 2025+):** emphasizing, enhance, highlighting, showcasing (plus notability/attribution tells)

**Signal:** 3+ AI vocabulary words in a single paragraph. One or two may be coincidental; many co-occurring is one of the strongest tells.

## 2. Undue Emphasis on Significance

LLMs puff up importance by adding statements about how arbitrary aspects represent or contribute to a broader topic.

**Words to watch:** stands/serves as, is a testament/reminder, a vital/significant/crucial/pivotal/key role/moment, underscores/highlights its importance/significance, reflects broader, symbolizing its ongoing/enduring/lasting, contributing to the, setting the stage for, marking/shaping the, represents/marks a shift, key turning point, evolving landscape, focal point, indelible mark, deeply rooted

**Examples:**
- "This etymology highlights the enduring legacy of the community's resistance and the transformative power of unity in shaping its identity." (about a town name)
- "The founding represented a significant shift toward regional statistical independence... part of a broader movement across Spain to decentralize administrative functions."

**Signal:** Even mundane subjects (population data, etymology, small companies) get grandiose significance statements about broader societal impact.

## 3. Superficial Analysis ("-ing" phrases)

AI inserts superficial analysis attached as present participle phrases at the end of factual sentences, often with vague attributions.

**Words to watch:** highlighting/underscoring/emphasizing ..., ensuring ..., reflecting/symbolizing ..., contributing to ..., cultivating/fostering ..., encompassing ..., valuable insights, align/resonate with

**Examples:**
- "...creating a lively community within its borders." (after census data)
- "...contributing to the socio-economic development of the region." (after listing train services)
- "...reflecting its continued relevance in the regional and national transportation landscape." (about a railway station)

**Signal:** Every paragraph ends with an "-ing" phrase claiming significance or broader impact beyond what the facts support.

## 4. Promotional / Advertisement-like Language

LLMs struggle to maintain neutral tone, often drifting into travel-guide or press-release prose.

**Words to watch:** boasts a, vibrant, rich, profound, enhancing, showcasing, exemplifies, commitment to, natural beauty, nestled, in the heart of, groundbreaking, renowned, featuring, diverse array, seamlessly, captivating

**Subtypes:**
- **Cultural heritage padding:** "Nestled within the breathtaking region... stands as a vibrant town with a rich cultural heritage"
- **Press-release tone for companies/people:** "These projects align with KQ's goals of reducing its environmental footprint, improving operational efficiency, and fostering community development"
- **Car/product descriptions:** Reads like a luxury car brochure even for mundane subjects

**Signal:** Prose reads like marketing copy when the context calls for neutral writing. LLMs overuse the same set of promotional phrases regardless of topic.

## 5. Vague Attributions (Weasel Wording)

AI attributes opinions to vague authorities with no specific sourcing.

**Words to watch:** Industry reports, Observers have cited, Experts argue, Some critics argue, several sources/publications (when only few sources are cited), such as (before exhaustive word lists)

**Signal:** Claims attributed to "researchers and conservationists" or "industry reports" with no named source. Also: presenting one source's view as "widely held."

## 6. Negative Parallelism

LLMs describe subjects by retroactively challenging assumed misconceptions.

**Patterns:**
- **"Not just X, but also Y"** — "It is not just a meme, it's a celebration"
- **"It's not ..., it's ..."** — "This isn't WP:NBIO — it's WP:1EVENT in disguise"
- **"No ..., no ..., just ..."** — "Not a career, not a body of work, not sustained relevance — just an algorithmic moment"

**Signal:** The text seems to be clearing up a misconception that nobody actually held. Common when the LLM is trying to add "nuance."

## 7. Rule of Three Overuse

LLMs structure lists in clusters of exactly three items that feel formulaic.

**Forms:**
- Three adjectives: "bold, elegant, and timeless"
- Three noun phrases: "keynote sessions, panel discussions, and networking opportunities"
- Three clauses in a row

**Signal:** Every list has exactly three items. Human writers often use two or four; the rule of three is an AI structural tell.

## 8. Elegant Variation Abuse

AI has a repetition-penalty code that makes it avoid reusing words, leading to unnecessary synonym cycling.

**Examples:**
- "Vierny" → "Yankilevsky" → "the artist" → "her" → "Vierny's commitment" → "Dina Vierny" → circular back to start
- Repeated use of synonyms like "protagonist," "key player," "eponymous figure" instead of just repeating the name

**Signal:** Every mention of a proper noun uses a different synonym or related term. More common in longer texts where the LLM's repetition penalty fires repeatedly.

## 9. Copulative Avoidance

LLMs substitute simpler constructions using "is"/"are" for more elaborate alternatives.

**Words to watch:** serves as/stands as/marks/represents [a], boasts/features/maintains/offers [a], refers to (when the article is about the subject, not the word)

**Examples:**
- "Gallery 825... serves as LAAA's exhibition space" instead of "is LAAA's exhibition arm"
- "Harian Metro holds the distinction of being the first" instead of "is the first and oldest"
- A study found over 10% decrease in "is"/"are" usage in academic writing after ChatGPT's launch

**Signal:** Simple sentences that could use "is" or "has" are deliberately rewritten with more elaborate verbs.

## 10. Outline-like Challenge/Future Sections

LLMs insert rigid formulaic sections about challenges and future prospects, often at article endings.

**Words to watch:** Despite its... faces several challenges..., Despite these challenges, Challenges and Legacy, Future Outlook

**Typical structure:**
- Begins: "Despite its [positive words], [subject] faces challenges typical of [category]"
- Ends: "With its strategic location/initiatives, [subject] continues to thrive" or speculates about future benefits

**Signal:** The paragraph has a rigid template — acknowledgment of challenges followed by vague optimism. Not just mentioning difficulties, but the formulaic structure.

## 11. Overuse of Em Dashes

LLMs use em dashes more frequently and in places where humans would use commas, parentheses, or colons.

**Signal:** Em dashes appear in a formulaic way, often mimicking "punched up" sales-like writing by over-emphasizing clauses. More common on discussion/comment text than article prose. Newer models (GPT-5.1+) have been instructed to suppress them.

## 12. Inline-header Vertical Lists

AI outputs include lists where each item has a bold header separated by colon from descriptive text.

**Format:**
```
• Bold Header: Description of point
• Second Header: Another description
• Third Header: Final description
```

**Signal:** Every list uses this pattern regardless of context. Human writers mix prose paragraphs with occasional lists; AI generates inline-header lists even when prose would be more natural.

## 13. Boldface Overuse

LLMs display phrases in boldface for emphasis in an excessive, mechanical manner — like a slide deck or sales pitch.

**Patterns:**
- Every instance of key terms is bolded
- Section summaries have every concept bolded ("Key Takeaways" style)
- Bold used for structural purposes (like headings within body text)

**Signal:** Boldface appears scattered throughout paragraphs, not just for first-use definitions or genuine emphasis.

## 14. Title Case Headings

In section headings and subheadings, AI chatbots strongly tend to capitalize all main words rather than sentence case.

**Examples:**
- "Impact of Technology and Digitalization" instead of "Impact of technology and digitalization"
- "Sustainable Development and Environmental Law" instead of "Sustainable development and environmental law"

**Signal:** Nearly every heading uses title case, especially in Markdown or informal text where sentence case is more common.

## 15. Curly Quotation Marks and Apostrophes

ChatGPT and DeepSeek use curly quotation marks ("..." or '...') instead of straight ones ("..." or '...'). They also use curly apostrophes (') in contractions and possessives.

**Note:** Not definitive — Microsoft Word, macOS, and professional typesetting also use curly quotes. Gemini and Claude typically do not use curly quotes.

**Signal:** Curly quotes + other AI tells = strong signal. Curly quotes alone are inconclusive.

## 16. Canned Collaborative Communication

Text includes phrases meant for user correspondence pasted into article content.

**Words to watch:** I hope this helps, Of course!, Certainly!, You're absolutely right!, Would you like..., is there anything else, let me know, more detailed breakdown, here is a ...

**Signal:** Conversational AI-to-user language in formal/informational text. Common when someone pastes chatbot output without cleaning it up.

## 17. Knowledge-Cutoff Disclaimers and Speculation About Gaps

AI inserts statements about information limitations that have no place in finished writing.

**Words to watch:** as of [date], Up to my last training update, as of my last knowledge update, While specific details are limited/scarce..., not widely available/documented/disclosed, ...in the provided/available sources/search results..., based on available information ...

**Signal:** Statements like "While specific details about X's history are not extensively documented in readily available sources" — speculative claims about what is or isn't known.

## 18. Phrasal Templates and Placeholder Text

LLMs generate fill-in-the-blank text that users forget to complete.

**Patterns:**
- "[Describe the specific section or content that needs editing]"
- "[link to source list]"
- "Best regards, [Your Name] and Chloe"
- Placeholder dates: "2025-XX-XX", "2026-02-09"

**Signal:** Obvious Mad Libs-style blanks in finished text. Also: placeholder URLs like "INSERT_SOURCE_URL_30" or "PASTE_SPOTIFY_TRACK_URL_HERE".

## 19. Markdown in Non-Markdown Contexts

AI chatbots trained on web content often output Markdown formatting when they should be using the target format's native markup.

**Patterns:**
- `**bold**` instead of native bold
- `# Heading` instead of proper heading markup
- `*italic*` instead of proper italic markup
- Mixed Markdown and native markup syntax in same document

**Signal:** Document has Markdown syntax when it should use a different format (wikitext, HTML, plain text, etc.). Often combined with broken formatting.

## 20. Canned Offers to Receive Criticism

Common in comments by users whose work was declined.

**Words to watch:** If you have any concerns/suggestions, If there are specific sections/areas that ..., I am willing/happy to address ..., I am open to/would appreciate/welcome any additional/further input/guidance/feedback

**Signal:** Formulaic expressions of willingness to take feedback. Human writers typically be more specific: "I'll move the economic section" vs "I'm open to any suggestions."

## 21. Subject Lines in Discussion Text

Comments begin with text that appears intended for an email subject field.

**Examples:**
- "Subject: Request for Permission to Edit Wikipedia Article - 'Dog'"
- "Subject: Concerns about Inaccurate Information"

**Signal:** Formal letter/email structure pasted into informal discussion/comment context.

## 22. Hallucinated Policies or Guidelines (in comments)

AI chatbots cite non-existent policies, guidelines, or shortcuts when arguing in discussion contexts.

**Patterns:**
- Fake policy shortcuts: "WP:NOTENGLISH clearly states..."
- Misattributed existing policies with fake quotes
- Hallucinated WP:XYZ shortcuts that redirect nowhere

**Signal:** Policy citations that don't resolve to real pages, or quotes from policies that say something entirely different.

## 23. Wikilawyering in Discussion

AI-generated defense text selectively cites policies in ways that sound authoritative but are misapplied.

**Patterns:**
- Invoking preservation (WP:PRESERVE) regardless of deletion rationale
- Citing AI-detection guidelines to dismiss concerns about AI content itself
- Reassuring reviewers that content is "neutral" and "verified" without demonstrating either

**Signal:** Text reads like a legal brief citing rules out of context. Common when defending suspected AI content against detection flags.

## 24. Pronounced Shift in Writing Style

A sudden change in tone, formality, grammar quality, or English variety compared to surrounding text by the same author.

**Patterns:**
- Suddenly flawless grammar from an editor who usually makes errors
- American English from a non-US writer without prompt instruction
- Formal/academic register where casual is the norm
- Consistent voice across previously unrelated topics written by different authors

**Signal:** The writing has a completely different feel from the author's other work or surrounding text. Especially suspicious if it predates LLM availability for that author (pre-Nov 2022).

## 25. Excessive Edit Summaries

AI-generated edit summaries are formal, verbose paragraphs echoing policy language.

**Patterns:**
- "I revised the content to provide a neutral and informative description... The tone was adjusted to be more encyclopedic"
- "**Concise edit summary:** Improved clarity, flow, and readability of the plot section; reduced redundancy and refined tone for better encyclopedic style."
- Itemized policy compliance lists in what should be one-line summaries

**Signal:** Edit summaries that read like formal letters or essays instead of brief descriptions of changes made.

## 25a. Submission Statements in Drafts

LLMs insert faux-reviewer-facing statements into drafts explaining why the subject is notable and how it meets guidelines.

**Signal:** Text blocks reading "Reviewer note (for AfC): This draft is a neutral and well-sourced biography..." — meant to be read by reviewers, not appearing in the article itself.

## 26. Emoji as Formatting

AI chatbots have decorated section headings or bullet points with emoji.

**Patterns:**
- 🧠 Cognitive Dissonance Pattern:
- 🔭 Sine of the Bow: Sanskrit Terminology
- Emojis used before every list item or heading

**Signal:** Emoji used structurally rather than for content emphasis. More common in older models; still occasionally seen.

## 27. Leading Lists/Broad Titles as Proper Nouns

When writing about lists or broad categories, the first sentence defines the title as if it were a real-world entity.

**Examples:**
- "Catchment area (health) refers to the geographic area from which a health facility draws its patients." (about a list)
- "The 'List of songs about Mexico' is a curated compilation of musical works that reference Mexico..."

**Signal:** The title itself is defined as though it were an entity rather than an article/section name.

## Ineffective Indicators

These are commonly mistaken AI tells but are NOT reliable indicators:

- **Perfect grammar:** Many skilled writers exist; good editing produces clean prose
- **"Bland" or "robotic" prose:** What reads as robotic to one person may read as clear to another
- **"Fancy" or "academic" prose:** LLMs favor specific words, not all formal language is AI
- **Letter-like writing:** Formal salutations have existed long before LLMs
- **Transition words alone:** Only a few are specifically overused by AI (Additionally, Consequently, Notably)
- **Unsourced content:** Most unsourced content predates LLMs; AI text often has citations (that may be fake)
- **Single instance of one AI vocabulary word:** 1–2 occurrences can be coincidental or borrowed from source material

## Model-Specific Tells

Each model has a distinctive idiolect:

| Tell | ChatGPT | Claude | Gemini | Grok |
|------|---------|--------|--------|------|
| Verbosity | High | Lower | Moderate | High |
| Boldface | Frequent | Less | Rare | Moderate |
| Curly quotes | Yes | No | No | Yes |
| Context focus | Broad | Focused | Factual | Broad |
| Promotional tone | Blatant | Subtle | Minimal | Moderate |
| Em dashes | Frequent | Less frequent | Less | Frequent |

Newer models (GPT-5+) show shifted vocabulary: "emphasizing, enhance, highlighting, showcasing" replaced older words like "delve" and "tapestry." Detection must account for model version.

## Research Sources

- Russell et al. (2025), *People who frequently use ChatGPT for writing tasks are accurate and robust detectors* — ACL
- Reinhart et al. (2025), *Do LLMs write like humans? Variation in grammatical and rhetorical styles* — PNAS
- Kriss (2025), *Why Does A.I. Write Like … That?* — NYT
- Merrill et al. (2025), *What are the clues that ChatGPT wrote something?* — Washington Post
- Kobak et al. (2025), *Delving into LLM-assisted writing in biomedical publications through excess vocabulary* — Science Advances
- Geng & Trotta (2025), *Human-LLM Coevolution: Evidence from Academic Writing*
