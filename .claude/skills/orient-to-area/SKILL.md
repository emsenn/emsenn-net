---
description: Read and understand an area of the vault before working in it
id: orient-to-area
version: [0, 1]
kind: operational
runtime: inference
triggers:
  - "orient to"
  - "explore area"
  - "survey directory"
inputs:
  path: string
outputs:
  report: object
region:
  reads: ["content/"]
  writes: []
dependencies: []
scopes: []
---
Orient to: $ARGUMENTS

## Instructions

Before doing any work in a vault area, understand its structure.

1. List the directory tree (2 levels deep).
2. Read the area's `index.md` to understand its purpose.
3. Count files by type (terms, concepts, lessons, etc.).
4. Check for skills embedded in the area (`**/skills/*/SKILL.md`).
5. Check for formal artifacts (.ttl, .lean, .py, .json).
6. Read `memory/directives.md` for any constraints that apply.

Report:
- What the area is about
- What subdirectories and content exist
- What skills are available for this area
- What formal artifacts exist
- Any obvious gaps (missing index.md, empty directories, etc.)
