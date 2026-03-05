---
description: Generate RDF/Turtle from a page's frontmatter and content
id: generate-rdf
version: [0, 1]
kind: operational
runtime: inference
triggers:
  - "generate rdf"
  - "create turtle"
  - "convert to ttl"
inputs:
  path: string
outputs:
  ttl_path: string
region:
  reads: ["content/"]
  writes: ["content/"]
dependencies: []
scopes: []
---
Generate RDF for: $ARGUMENTS

## Instructions

Extract structured data from a markdown page and produce RDF/Turtle.

1. Read the page's frontmatter. Map fields to RDF:
   - `title` → `rdfs:label`
   - `type` → `rdf:type` (using the ASR type vocabulary)
   - `tags` → `dcterms:subject`
   - `date-created` → `dcterms:created`
   - `defines` → `rel:defines`
   - `cites` → `dcterms:references`
   - `requires` → `rel:requires`
   - `part-of` → `dcterms:isPartOf`
   - `extends` → `rel:extends`

2. Read the body for relationship claims (derivesFrom, produces,
   dualOf, etc.) and encode them as RDF triples.

3. Write the .ttl file alongside the source .md file (same directory,
   same filename stem).

4. Use the namespace `@prefix rel: <https://emsenn.net/relationality/ontology#>`.

The semantic frontmatter spec at
`content/technology/specifications/agential-semioverse-repository/semantic-frontmatter.md`
defines the full mapping. Read it if you haven't.
