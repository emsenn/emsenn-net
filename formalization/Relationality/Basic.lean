/-
# Relationality — Basic Definitions

Relational vocabulary as aliases for the operations provided by
RecognitionField (via its HeytingAlgebra instance).

The sole assumption throughout is [RecognitionField Rel]. The
HeytingAlgebra structure is derived from Genesis.lean's instance
construction. No independent Mathlib imports introduce new axioms.

## Naming conventions

  Including    ↔  ≤  (partial order)
  Togethering  ↔  ⊓  (inf/meet)
  Eithering    ↔  ⊔  (sup/join)
  Inducing     ↔  ⇨  (Heyting implication)
  Negating     ↔  ᶜ  (pseudocomplement)
  Bottom       ↔  ⊥  (Relationlessness)
  Top          ↔  ⊤  (FullRecognition)
-/

import Relationality.Genesis

namespace Relationality

noncomputable section

variable {Rel : Type*} [RecognitionField Rel]

-- Relational vocabulary as aliases.
-- These use the HeytingAlgebra notation (⊓, ⊔, ⇨, etc.) which is
-- available through the RecognitionField.toHeytingAlgebra instance.

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

/-- FullRecognition: the maximal recognition. -/
abbrev FullRecognition : Rel := ⊤

end

end Relationality
