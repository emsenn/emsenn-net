---
description: Apply the semiotic closure S = S_fus . S_syn . S_sem to a Thing in the emsemioverse until fixed point
id: stabilize
version: [0, 1]
kind: operational
runtime: inference
triggers:
  - "stabilize"
  - "close"
  - "apply closure"
inputs:
  path: string
outputs:
  stable: boolean
  changes: object[]
region:
  reads: ["content/"]
  writes: ["content/"]
dependencies:
  - check-note-style
  - fix-frontmatter
  - audit-vault-references
  - cross-link-document
  - manage-tags
scopes: []
---
Stabilize: $ARGUMENTS

## What this skill does

Applies the composite closure S = S_fus ∘ S_syn ∘ S_sem to a content
object (any path in the vault). A Thing is stable when S(X) = X — when
applying all three closures produces no change.

This is the ASR implementation of the semiotic universe's closure
operation (see `content/mathematics/objects/universes/semiotic-universe/semiotic-universe.md`,
Sections 5–7).

## Instructions

### 1. Locate the Thing

Resolve $ARGUMENTS to a file path. If it is a directory, operate on
its `index.md`. If the path does not exist, report and stop.

### 2. Apply S_sem (semantic closure)

The semantic content must be complete under its own operations.

Check:
- **Interpretation closure**: every concept referenced in the content
  exists as a resolvable link. Wikilinks (`[[x]]`) indicate missing
  pages — these are semantic gaps.
- **Relationship reciprocity**: if this page claims `derivesFrom: X`,
  does X's page list this as a product? Check all directional relations.
- **Self-standing definitions**: the page's definitions must not depend
  on external documents the reader cannot access. Draft citations are
  evidence, not definitions.
- **Fixed-point closure**: if the page defines something in terms of
  iteration or closure, the fixed-point content should be present (not
  just gestured at).

Use `/audit-vault-references` on the file to find broken links.
Use `/cross-link-document` to add missing references.

### 3. Apply S_syn (syntactic closure)

The syntactic form must be correct and complete.

Check:
- **Frontmatter**: all required fields present, correctly typed.
  Use `/fix-frontmatter`.
- **Style**: PTGAE compliance. Use `/check-note-style`.
- **Directory placement**: the file is in the correct subdirectory for
  its content type (term → terms/, concept → concepts/, etc.).
- **Link syntax**: all links use markdown format `[text](path.md)`,
  no agent-generated wikilinks.
- **Tags and type**: `type:` field matches content; tags follow
  conventions. Use `/manage-tags`.

### 4. Apply S_fus (fusion closure)

Syntax and semantics must cohere.

Check:
- **Type-content alignment**: does the `type:` field match what the
  content actually is? A page typed `term` should read like a term
  definition, not an essay.
- **Tag-content alignment**: do the tags reflect the actual conceptual
  communities this page participates in?
- **Directory-content alignment**: is the page in the directory that
  matches its semantic role?
- **Naming coherence**: does the filename, title, and content use
  consistent terminology?

### 5. Iterate

If any closure step made changes, the other closures may now be
unsatisfied (e.g., fixing a link in S_sem may introduce a new page
that needs S_syn). Re-check all three. Stop when no closure produces
changes — that is the fixed point.

### 6. Report

State:
- The Thing's path
- What each closure step found and fixed
- Whether fixed point was reached
- What remains unstable (if anything) and why
