/-
# Relationality — Basic Definitions

This module establishes the foundational setting for formalizing
emsenn's relational framework. The recognition field is modeled
as a complete Heyting algebra, which Mathlib provides.

The key insight: we do not ASSUME a Heyting algebra. The relational
derivation EARNS it from the requirements of coherent distinction.
But for formal verification, we work within the structure and verify
that claimed properties hold.

## Naming conventions

We use the relational vocabulary as primary names, with the standard
mathematical names available via Mathlib:

  Including    ↔  ≤  (partial order)
  Togethering  ↔  ⊓  (inf/meet)
  Eithering    ↔  ⊔  (sup/join)
  Inducing     ↔  ⇨  (Heyting implication)
  Negating     ↔  ᶜ  (complement/pseudocomplement)
  Bottom       ↔  ⊥  (Relationlessness)
  Top          ↔  ⊤  (maximal recognition)
-/

import Mathlib.Order.Heyting.Basic
import Mathlib.Order.CompleteLattice.Basic

namespace Relationality

/-!
## The Recognition Field

We work over an arbitrary complete Heyting algebra `Rel`.
This is the recognition field — the ordered collection of all
recognitions, equipped with the operations that coherent
distinction earns.
-/

variable {Rel : Type*} [HeytingAlgebra Rel]

-- Relational vocabulary as aliases for Mathlib operations

/-- Including: `a` is included in `b` iff `a ≤ b`. -/
abbrev Includes (a b : Rel) : Prop := a ≤ b

/-- Togethering: joint recognition of both operands. -/
abbrev Together (a b : Rel) : Rel := a ⊓ b

/-- Eithering: recognition of at least one operand. -/
abbrev Either (a b : Rel) : Rel := a ⊔ b

/-- Inducing: what must be added to `a` for `b` to be recognized.
    The greatest `c` such that `Together(a, c) ≤ b`. -/
abbrev Induces (a b : Rel) : Rel := a ⇨ b

/-- Negating: total exclusion. `Negate(a) = Induces(a, ⊥)`. -/
abbrev Negate (a : Rel) : Rel := aᶜ

/-- Relationlessness: the absence of all recognition. -/
abbrev Relationlessness : Rel := ⊥

/-- Top: the maximal recognition. -/
abbrev FullRecognition : Rel := ⊤

end Relationality
