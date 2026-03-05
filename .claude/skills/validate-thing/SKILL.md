---
description: Validate a Thing against its applicable SHACL shapes and report pass/fail
id: validate-thing
version: [0, 1]
kind: operational
runtime: inference
triggers:
  - "validate"
  - "check shapes"
  - "run shacl"
inputs:
  path: string
outputs:
  passed: boolean
  results: object[]
region:
  reads: ["content/"]
  writes: []
dependencies:
  - generate-rdf
scopes: []
---
Validate: $ARGUMENTS

## Instructions

Check whether a Thing satisfies formal constraints.

1. Locate the Thing (resolve path to a file or directory with index.md).
2. Check if the Thing has a colocated .ttl file. If not, run
   `/generate-rdf` first.
3. Look for applicable SHACL shapes:
   - Colocated shapes (same directory, `*.shapes.ttl`)
   - Type-based shapes (shapes that apply to all Things of this type)
   - Global shapes (shapes that apply to all Things)
4. If shapes exist, validate the .ttl against them. Report:
   - Which shapes passed
   - Which shapes failed and why
   - What needs to change to pass
5. If no shapes exist, check manually:
   - Does the frontmatter have all required fields?
   - Do all links resolve?
   - Is the type field consistent with the content?
   - Is the page in the right directory for its type?

Report pass/fail with specifics.
