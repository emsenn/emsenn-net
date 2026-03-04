---
id: commit-repository
description: Stage all changes and commit them with an appropriate message
region:
  reads: ["content/", ".claude/"]
  writes: []
dependencies: []
---

Run `git status` now to see what has changed, then:

1. Stage everything except `content/private/`.
2. Write a commit message:
   - Imperative mood, under 72 characters
   - Conceptual, not mechanical
   - Trailer: `Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>`
3. Commit.

$ARGUMENTS
