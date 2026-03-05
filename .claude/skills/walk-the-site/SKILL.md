---
description: Walk the published site as a first-time visitor, finding and fixing friction points
id: walk-the-site
version: [0, 1]
kind: operational
runtime: inference
triggers:
  - "walk the site"
  - "browse as visitor"
  - "check the site"
inputs:
  entry_point: string?
outputs:
  pages_visited: string[]
  issues: object[]
region:
  reads: ["content/"]
  writes: ["content/"]
dependencies:
  - check-note-style
scopes: []
---
Walk the site starting from: $ARGUMENTS

("index.md" for homepage, "random" for a random published page, or a specific path)

1. Determine the entry point:
   - If `$ARGUMENTS` is "index.md" or empty, start from `content/index.md`
   - If `$ARGUMENTS` is "random", pick a random published page by running:
     ```bash
     find content -name "*.md" -not -path "*/private/*" -not -path "*/meta/*" -not -path "*/slop/*" -not -path "*/triage/*" -not -path "*/.obsidian/*" | shuf -n 1
     ```
   - Otherwise, start from the specified path

2. Read the entry page. Adopt the perspective of someone encountering this site for the first time with no prior context. You are NOT emsenn, NOT a collaborator — you are a stranger who found this page.

3. For each page you visit, evaluate these friction points:
   - **Broken links**: wikilinks or markdown links that point to nonexistent pages
   - **Assumed knowledge**: terms, acronyms, or concepts used without explanation or link, that a newcomer would not know
   - **Missing context**: references to "this project," "the derivation," "the vault," etc. without explaining what those are
   - **Dead ends**: pages with no outgoing links, no "what comes next," no way to continue exploring
   - **Stale content**: references to things that no longer exist, outdated descriptions, wrong paths
   - **Frontmatter issues**: missing required fields, wrong field names, deprecated fields
   - **Style violations**: check against the style guide at `content/writing/text/style-guide.md`
   - **Unclear purpose**: pages where a newcomer cannot tell what the page is about or why it exists within the first two sentences
   - **Missing index.md**: directories that should have an index but don't

4. Fix issues directly as you find them:
   - Add wikilinks to terms that should be linked
   - Add brief contextualizing phrases where knowledge is assumed
   - Fix broken links
   - Fix frontmatter
   - Add forward links to pages that are dead ends
   - Fix style violations
   - Do NOT restructure or move files — only edit content in place

5. Follow links from each page you visit. Visit at least 8-12 pages per walk, following the path a curious newcomer would take. Prioritize:
   - Links that look like they lead to core concepts
   - Links in introductory or overview pages
   - Links that a newcomer would click first

6. After visiting all pages, report:
   - Pages visited (in order)
   - Issues found and fixed (with brief description)
   - Issues found but NOT fixed (because they need emsenn's decision)
   - Patterns observed (recurring problems across multiple pages)
   - Suggestions for structural improvements (new pages needed, reorganization ideas)

Rules:
- Only visit published content (not private/, meta/, slop/, triage/)
- Fix issues directly — do not just report them
- Do not create new files unless a missing index.md is needed
- Do not move or rename files
- Read the style guide before starting if you haven't recently
