---
title: "Survey: Lean 4 vs Agda for Relationality Formalization"
date-created: 2026-03-07T00:00:00
authors:
  - claude
tags:
  - Formalization
  - ProofAssistants
---

# Survey: Lean 4 vs Agda for Relationality Formalization

Survey of the two proof assistants available in this environment for formalizing
the mathematical structures underlying relationality and the semioverse hierarchy.

## Environment

| Tool | Version | Library | Status |
|------|---------|---------|--------|
| Lean 4 | 4.17.0 (via elan) | Mathlib4 (latest) | Working, builds with cache |
| Agda | 2.6.3 | agda-stdlib | Working, pre-installed |

Both tools are functional. Lean requires `~/.elan/bin` on PATH and downloads
~2 GB of Mathlib cache on first use. Agda works out of the box.

## Heyting Algebras (the base structure)

### Lean 4 + Mathlib

- `HeytingAlgebra` is a typeclass at `Mathlib.Order.Heyting.Basic`,
  extending `BoundedOrder` and `DistribLattice`
- Also provides `GeneralizedHeytingAlgebra`, `CoheytingAlgebra`, `BiheytingAlgebra`
- Convenience constructors: `HeytingAlgebra.ofHImp` and `HeytingAlgebra.ofCompl`
- Rich library of lemmas: `le_himp_iff`, `inf_le_left`, `sup_le`, etc.
- Category of Heyting algebras: `HeytAlg` with `HeytingHom` morphisms and
  forgetful functors (`Mathlib.Order.Category.HeytAlg`)
- Typeclass inference provides instances automatically
- The deleted formalization used this: `RecognitionField` fields → `HeytingAlgebra`
  instance → all Mathlib lemmas available

### Agda + stdlib

- `IsHeytingAlgebra` is a record at `Relation.Binary.Lattice.Structures`
- `HeytingAlgebra` bundle at `Relation.Binary.Lattice.Bundles`
- Pre-proved properties at `Relation.Binary.Lattice.Properties.HeytingAlgebra`:
  `transpose-⇨`, `transpose-∧` (residuation), `⇨-eval` (modus ponens),
  `y≤x⇨y` (weakening), distributivity, etc.
- Record-based: explicitly opened, no implicit inference chains

### Verdict

Both have solid Heyting algebra support. Agda's is more explicit (you open
modules and name what you use). Lean's is more automatic (typeclass inference).

## Closure Operators and Modal Structure

### Lean 4 + Mathlib

- `ClosureOperator` at `Mathlib.Order.Closure`
- Provides inflationary, idempotent, monotone maps on partial orders
- No built-in `InteriorOperator` (the deleted formalization defined one)
- No built-in nucleus / Frobenius compatibility
- An independent Lean 4 formalization by Hotz et al. (2024) covers frames,
  nuclei, and fixed-point Heyting algebra construction (240+ theorems,
  compiles clean) — not in Mathlib but demonstrates the path

### Agda + stdlib

- No built-in `ClosureOperator`
- Easy to define as a record (tested: typechecks cleanly)
- Custom records for `InteriorOp`, `FrobeniusCompatible`, `ModalClosure`,
  `HeytingComonad`, `SemioticAmbientStr` all typecheck

### Verdict

Lean has a head start with `ClosureOperator` but both require custom definitions
for the full semiotic ambient structure. Agda's record system makes custom
algebraic structures natural to define and compose.

## Completeness, Frames, Locales

### Lean 4 + Mathlib

- `CompleteLattice` is well-supported
- `Order.Frame` provides frames (complete Heyting algebras where meets
  distribute over arbitrary joins)
- Locale theory via `Topology.Order` module
- This is a significant advantage for the semiotic universe spec, which
  requires completeness

### Agda + stdlib

- No built-in complete lattice, frame, or locale
- Would need to be defined from scratch or imported from agda-categories
- agda-categories has some categorical lattice theory but nothing as
  developed as Mathlib's

### Verdict

Lean + Mathlib is substantially ahead for frames/locales/completeness.

## Categorical Structures (monads, comonads, sheaves)

### Lean 4 + Mathlib

- `CategoryTheory.Monad` and `CategoryTheory.Comonad` with full axiomatics
- Eilenberg-Moore coalgebras, adjunction-induced comonads, Beck's
  comonadicity theorem
- Sheaf theory: `CategoryTheory.Sites.Sheaf` for Grothendieck topologies,
  canonical/subcanonical topologies, sheaf cohomology in progress (Riou 2025)
- `Locale` defined as opposite category of `Frame`
- GaloisConnection is in `Order.GaloisConnection`

### Agda + agda-categories

- Full categorical formalization: categories, functors, natural
  transformations, adjunctions, monads, comonads
- Comonads include: cofree comonads, distributive laws, morphisms,
  relative comonads
- Monads: strong, relative, graded, idempotent, Kleisli/Eilenberg-Moore
- Proof-relevant: coherence isomorphisms made explicit
- Sheaf theory: `Categories.Category.Site` and `.Topos` exist as stubs;
  Jon Sterling's independent constructive-sheaf-semantics project is
  more developed but standalone

### Verdict

Both have categorical machinery. Lean's sheaf theory is more developed.
Agda-categories is clean but would require more custom work.

## Constructive vs Classical

### Lean 4

- Classical by default (`Classical.propDecidable`, `Decidable` instances)
- `Prop` is proof-irrelevant
- Can work constructively but swimming upstream
- Proofs of Heyting (non-Boolean) properties work fine — the algebra
  is constructive even if the metalogic isn't

### Agda

- Natively constructive
- `--cubical-compatible --safe` flags enforce constructive reasoning
- Heyting algebras are the natural "home" logic
- The distinction between Heyting and Boolean is philosophically
  salient in Agda: you SEE the non-Boolean gap because you can't
  prove double negation elimination without postulating it

### Verdict

For a project that takes the Heyting/non-Boolean distinction seriously
as a philosophical point (the "genuine indeterminacy" of the recognition
field), Agda's constructive foundation is a better philosophical fit.
But Lean works fine for proving the same theorems.

## Practical Comparison

| Factor | Lean 4 + Mathlib | Agda + stdlib |
|--------|-----------------|---------------|
| Build time | Slow (Mathlib is huge) | Fast (stdlib is small) |
| Library depth | Deep (frames, locales, sheaves) | Shallow (Heyting, lattice basics) |
| Custom structures | Typeclasses (implicit) | Records (explicit) |
| Error messages | Improving but opaque | Clear, precise |
| Readability | Tactic proofs can be cryptic | Term proofs are readable |
| Constructive | No (classical default) | Yes (native) |
| Colocation | `.lean` files alongside `.md` | `.agda` files alongside `.md` |
| IDE support | VS Code + lean4 extension | VS Code + agda-mode |

## What Was in the Deleted Formalization

The `formalization/` directory contained Lean 4 code that:

1. **Genesis.lean** — Defined `RecognitionField` typeclass with partial order,
   lattice, and Heyting implication axioms. Built a `HeytingAlgebra` instance.
   Also proved the reverse: every `HeytingAlgebra` is a `RecognitionField`.
2. **Basic.lean** — Relational vocabulary aliases (Includes, Together, Either,
   Induces, Negate, etc.)
3. **SemioticAmbient.lean** — `ModalClosure` and `HeytingComonad` typeclasses
   with interaction axioms
4. **MovementI.lean** — Residuation, modus ponens, negation properties
5. **MovementII.lean** — Closure/interior operators, Frobenius compatibility
6. **MovementIII.lean** — Flow operator (monotone, inflationary, self-limiting)
7. **MovementIV.lean** — Cohesive chain (Shape ⊣ Flat ⊣ Sharp ⊣ Crisp)
8. **MovementV.lean** — States, observables, conservation

Much of this was thin wrappers around Mathlib lemmas. The Movement I proofs,
for instance, were one-liners applying existing Mathlib facts.

## Recommendation

**Use both, for different purposes.**

- **Agda** for the core relational formalization (RecognitionField, semiotic
  ambient, the "philosophical" mathematics). Its constructive foundation
  respects the Heyting/non-Boolean distinction. Its readable term proofs
  can serve as documentation. Custom record types compose naturally.

- **Lean 4 + Mathlib** for advanced structural properties that depend on
  Mathlib's library depth: complete Heyting algebras, frames/locales,
  sheaf conditions, categorical constructions. When you need to prove
  something about arbitrary joins or Grothendieck topologies, Mathlib
  has the infrastructure.

Both produce `.lean` / `.agda` files that colocate naturally with `.md`
content per the ASR specification.

## Tested Artifacts

The following files were tested and typecheck:

- `/tmp/RecognitionField.agda` — RecognitionField record wrapping IsHeytingAlgebra,
  with relational vocabulary aliases and conversion to HeytingAlgebra bundle
- `/tmp/MovementI.agda` — Residuation, modus ponens, weakening proved from
  stdlib's HeytingAlgebra properties
- `/tmp/ClosureTest.agda` — Custom ClosureOp, InteriorOp, FrobeniusCompatible records
- `/tmp/SemioticAmbient.agda` — ModalClosure, HeytingComonad, SemioticAmbientStr
  records with interaction axioms
- `/tmp/lean-test/Test.lean` — Lean 4 + Mathlib builds, HeytingAlgebra accessible
