---
name: fabric-patterns
description: Access curated Fabric AI prompts for content processing, research, and writing.
---

# fabric-patterns

Access curated Fabric AI prompts for content processing, research, and writing.

## Pattern Discovery

**Primary Source:** `~/.config/fabric/patterns/pattern_explanations.md`

When users ask for patterns or need help finding the right pattern:
1. Search the pattern explanations file for keywords matching user intent
2. Suggest 2-3 relevant patterns with their one-line descriptions
3. Recommend using `suggest_pattern` for complex queries

**Key Pattern:** `suggest_pattern` - Meta-pattern that suggests appropriate fabric patterns based on user input

## Curated Patterns (11)

### Content Processing
1. **extract_wisdom** - Deep extraction: IDEAS, INSIGHTS, QUOTES, HABITS, FACTS, REFERENCES, RECOMMENDATIONS
2. **extract_ideas** - Extract key ideas (simpler than extract_wisdom)
3. **summarize** - Quick structured: ONE SENTENCE + 10 MAIN POINTS + 5 TAKEAWAYS
4. **summarize_micro** - Ultra-brief: 3 MAIN POINTS + 3 TAKEAWAYS (12 words each max)
5. **summarize_meeting** - Meeting notes → TASKS, DECISIONS, NEXT STEPS, TIMELINE

### Analysis & Quality
6. **analyze_paper** - Academic paper analysis with scientific rigor scoring (Novelty/Rigor/Empiricism ratings, A-F grade)
7. **analyze_claims** - Fact-check claims with evidence, rating, and reasoning

### Writing & Communication
8. **improve_writing** - Polish text for clarity, grammar, and style
9. **create_formal_email** - Draft professional business emails
10. **create_mermaid_visualization** - Generate Mermaid diagrams from content

### Meta
11. **suggest_pattern** - Suggests appropriate fabric patterns or commands based on user input

## Basic Usage

```bash
# Process content and save output
cat article.txt | fabric -p summarize | tee summary.md

# Extract wisdom from YouTube video
fabric -y "https://youtube.com/watch?v=..." -p extract_wisdom | tee notes.md

# Quick summary to decide if content is worth reading
curl -s "https://example.com/article" | fabric -p summarize_micro

# Meeting notes → action items
cat transcript.txt | fabric -p summarize_meeting | tee meeting-notes.md

# View raw system prompt for any pattern
echo "" | fabric --dry-run -p <pattern_name>
```

## Advanced Options

```bash
# Scrape website URL to markdown (using Jina Reader)
fabric -u "https://example.com/article" -p summarize

# Scrape Twitter/X posts
fabric -u "https://x.com/user/status/123456" -p summarize_micro

# Web search using Jina AI (search engine, not URL scraping)
fabric -q "your search query" -p summarize

# Use specific AI model
cat file.txt | fabric -p summarize -m claude-sonnet-4 | tee output.md

# Chain with other commands
curl -s https://example.com | fabric -p extract_ideas | tee ideas.md

# List all 230+ available patterns
fabric --listpatterns
```

## URL & Search Options

**`-u, --scrape_url=`** - Scrapes any URL and converts to markdown using Jina Reader
- Works with blogs, articles, Twitter/X posts, news sites
- Handles JavaScript rendering
- More reliable than direct curl for complex pages

**`-q, --scrape_question=`** - Web search using Jina AI search engine
- Searches the web and summarizes results
- Requires valid Jina API authentication
- Different from `-u` (which scrapes specific URLs)

## Reasoning Strategies

For advanced reasoning wrappers (CoT, ToT, AoT, Reflexion, etc.), see:
- **[references/reasoning-strategies.md](references/reasoning-strategies.md)** - Deep dive into reasoning wrappers and when to use them
