---
title: "Relationality Formalization"
date-created: 2026-03-05T00:00:00
---

# Relationality — Lean 4 Formalization

Formal verification of the mathematical claims in emsenn's relational
framework, using Lean 4 and Mathlib.

## What this verifies

The relational derivation makes specific mathematical claims: that
coherent distinction earns a Heyting algebra, that self-application
earns closure operators, that Frobenius compatibility is required,
etc. This Lean project verifies those claims — if a theorem
typechecks, the claim follows from the axioms.

## Structure

- `Relationality/Basic.lean` — Foundational definitions, relational
  vocabulary mapped to Mathlib operations
- `Relationality/MovementI.lean` — Logical Origination: residuation,
  modus ponens, negation properties, the non-Boolean gap,
  distributive lattice
- `Relationality/MovementII.lean` — Structural Stabilization: closure
  operators, interior operators, Frobenius compatibility, modalities

## Setup

Requires [elan](https://github.com/leanprover/elan) (Lean version
manager).

```sh
cd formalization
lake update
lake build
```

First build will download Lean and Mathlib (~2 GB). Subsequent builds
are incremental.

## Relationship to the TTL ontology

The TTL ontology (`content/slop/.../ontology.ttl`) encodes WHAT
concepts are and how they connect. This Lean project verifies WHETHER
claimed properties actually hold. They are complementary:

- **TTL**: "Closing is idempotent" (stated as fact)
- **Lean**: `theorem closing_idempotent` (proved from axioms)

If a theorem doesn't typecheck, that surfaces a real question about
the drafts.
