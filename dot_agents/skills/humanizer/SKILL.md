---
name: humanizer
description: This skill should be used when the user wants to humanize text, remove AI writing patterns, or make writing sound more natural. It identifies and rewrites common AI-generated text patterns based on Wikipedia's "Signs of AI writing" guide. Invoke when text needs to sound less robotic, more authentic, or when explicitly asked to "humanize" content.
---

# Humanizer: Remove AI writing patterns

Identify and remove signs of AI-generated text to make writing sound natural and human. Based on Wikipedia's "Signs of AI writing" page, maintained by WikiProject AI Cleanup.

## Process

1. Read the input text
2. Identify all instances of the patterns below
3. Rewrite problematic sections
4. Ensure the revised text sounds natural when read aloud, varies sentence structure, uses specific details over vague claims, and uses simple constructions (is/are/has) where appropriate
5. Present the rewritten text, optionally with a brief summary of changes

## Personality and soul

Avoiding AI patterns is only half the job. Sterile, voiceless writing is just as obvious.

Signs of soulless writing: every sentence same length/structure, no opinions, no uncertainty, no first-person, no humor, reads like a press release.

To add voice:
- Have opinions. React to facts, don't just report them.
- Vary rhythm. Short sentences. Then longer ones. Mix it up.
- Acknowledge complexity. "This is impressive but also kind of unsettling" beats "This is impressive."
- Use "I" when it fits. First person is honest.
- Let some mess in. Perfect structure feels algorithmic.
- Be specific about feelings. Not "this is concerning" but "there's something unsettling about agents churning away at 3am while nobody's watching."

## Content patterns to fix

### 1. Undue emphasis on significance/legacy/broader trends
**Watch for:** stands/serves as, testament/reminder, vital/significant/crucial/pivotal/key, underscores/highlights importance, reflects broader, evolving landscape, indelible mark, deeply rooted

Replace inflated importance claims with concrete facts.

### 2. Undue emphasis on notability and media coverage
**Watch for:** independent coverage, national media outlets, active social media presence

Replace media name-dropping with specific claims from specific sources.

### 3. Superficial -ing analyses
**Watch for:** highlighting..., ensuring..., reflecting..., contributing to..., fostering..., showcasing...

Remove participle phrases tacked on for fake depth. Break into separate sentences with concrete claims.

### 4. Promotional language
**Watch for:** boasts a, vibrant, rich (figurative), profound, showcasing, nestled, in the heart of, groundbreaking, renowned, breathtaking, stunning

Replace with neutral, factual descriptions.

### 5. Vague attributions and weasel words
**Watch for:** Industry reports, Experts argue, Some critics argue, several sources

Replace with specific sources and citations.

### 6. Formulaic "Challenges and Future Prospects" sections
**Watch for:** Despite its... faces challenges..., Despite these challenges, Future Outlook

Replace with concrete facts about specific issues and responses.

## Language and grammar patterns to fix

### 7. Overused AI vocabulary
**Watch for:** Additionally, align with, crucial, delve, emphasizing, enduring, enhance, fostering, garner, highlight, interplay, intricate, key (adj), landscape (abstract), pivotal, showcase, tapestry (abstract), testament, underscore, valuable, vibrant

Replace with simpler, more natural word choices.

### 8. Copula avoidance
**Watch for:** serves as, stands as, marks, represents [a], boasts, features, offers

Replace with simple "is", "are", "has".

### 9. Negative parallelisms
**Watch for:** "Not only...but...", "It's not just about..., it's..."

Simplify to direct statements.

### 10. Rule of three overuse
Stop forcing ideas into groups of three. Use the natural number.

### 11. Synonym cycling
**Watch for:** protagonist → main character → central figure → hero

Stop substituting synonyms excessively. Repeat the same word when it's the right word.

### 12. False ranges
**Watch for:** "from X to Y" where X and Y aren't on a meaningful scale

Replace with simple lists or descriptions.

## Style patterns to fix

### 13. Em dash overuse
Replace excessive em dashes with commas or periods.

### 14. Boldface overuse
Remove mechanical boldface emphasis. Use it sparingly or not at all.

### 15. Inline-header vertical lists
Replace "**Header:** description" bullet lists with prose paragraphs.

### 16. Title case in headings
Use sentence case for headings.

### 17. Emojis
Remove decorative emojis from headings and bullet points.

### 18. Curly quotation marks
Replace curly quotes with straight quotes.

## Communication patterns to fix

### 19. Collaborative artifacts
**Remove:** "I hope this helps", "Of course!", "Certainly!", "You're absolutely right!", "Would you like...", "let me know", "here is a..."

### 20. Knowledge-cutoff disclaimers
**Remove:** "as of [date]", "While specific details are limited...", "based on available information..."

### 21. Sycophantic tone
**Remove:** "Great question!", "That's an excellent point!", excessive positivity.

## Filler and hedging to fix

### 22. Filler phrases
- "In order to" → "To"
- "Due to the fact that" → "Because"
- "At this point in time" → "Now"
- "has the ability to" → "can"
- "It is important to note that" → (delete)

### 23. Excessive hedging
"It could potentially possibly be argued that..." → make direct statements with appropriate qualifiers.

### 24. Generic positive conclusions
**Remove:** "The future looks bright", "Exciting times lie ahead", "journey toward excellence"

Replace with concrete next steps or facts.

## Reference

Based on [Wikipedia:Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing), maintained by WikiProject AI Cleanup.

Key insight: "LLMs use statistical algorithms to guess what should come next. The result tends toward the most statistically likely result that applies to the widest variety of cases."
