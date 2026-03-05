/-
# Movement I — Logical Origination

The recognition field, as a Heyting algebra, satisfies the properties
claimed in Movement I of the relational derivation. This module
verifies those claims.

Key properties to verify:
1. Inducing is the residual of Togethering (Galois connection)
2. Negating is defined as Inducing(a, ⊥)
3. Double negation is inflationary but not necessarily involutive
4. The non-Boolean gap: genuine indeterminacy
5. Modus ponens: Together(a, Induces(a,b)) ≤ b
-/

import Relationality.Basic
import Mathlib.Order.Heyting.Basic

namespace Relationality.MovementI

variable {Rel : Type*} [HeytingAlgebra Rel]

/-!
## The Residuation (Galois connection)

PRE Axiom 2: `Includes(Together(a,b), c) ↔ Includes(a, Induces(b,c))`.
This is THE central algebraic fact of Movement I. Togethering and
Inducing are adjoint: Together(b, −) ⊣ Induces(b, −).
-/

/-- The residuation law: the defining property of Heyting implication.
    `a ⊓ b ≤ c ↔ a ≤ b ⇨ c`. This is what EARNS Inducing from Togethering. -/
theorem residuation (a b c : Rel) :
    Together a b ≤ c ↔ a ≤ Induces b c :=
  le_himp_iff.symm

/-!
## Modus Ponens

PRE: `Includes(Together(a, Induces(a,b)), b)`.
If you combine `a` with what must be added to `a` to get `b`,
you get (at least) `b`.
-/

/-- Modus ponens: combining a recognition with its sufficiency for b
    yields (at least) b. -/
theorem modus_ponens (a b : Rel) :
    Together a (Induces a b) ≤ b :=
  himp_inf_le

/-!
## Self-sufficiency

PRE: `Includes(a, Induces(a,a))`.
Every recognition is sufficient for itself.
-/

/-- Every recognition induces itself. -/
theorem self_sufficiency (a : Rel) :
    a ≤ Induces a a :=
  le_himp_iff.mpr inf_le_left

/-!
## Negation Properties

Negating(a) = Induces(a, ⊥): the most you can combine with a and
get nothing.
-/

/-- Negation is defined as implication to bottom. -/
theorem negate_def (a : Rel) :
    Negate a = Induces a Relationlessness :=
  rfl

/-- Together(a, Negate(a)) = ⊥. A recognition combined with its
    negation yields nothing. -/
theorem together_negate (a : Rel) :
    Together a (Negate a) = Relationlessness :=
  inf_compl_eq_bot

/-!
## The Non-Boolean Gap — Genuine Indeterminacy

CRUCIALLY: `Negate(Negate(a)) ≥ a` but not necessarily `= a`.
Double negation is inflationary. The gap between `a` and `¬¬a`
is the formal expression of genuine indeterminacy — the space
where the relational field has not yet determined an outcome.

In a Boolean algebra, `¬¬a = a` always. In a Heyting algebra,
`¬¬a ≥ a` but the inequality can be strict. This non-Boolean
character is not a deficiency — it IS the tension between
including and excluding.
-/

/-- Double negation is inflationary: `a ≤ ¬¬a`. -/
theorem double_negation_inflationary (a : Rel) :
    a ≤ Negate (Negate a) :=
  le_compl_compl

/-- Negation is antitone: if `a ≤ b` then `¬b ≤ ¬a`. -/
theorem negate_antitone (a b : Rel) (h : a ≤ b) :
    Negate b ≤ Negate a :=
  compl_anti h

/-- Triple negation equals single negation: `¬¬¬a = ¬a`. -/
theorem triple_negation (a : Rel) :
    Negate (Negate (Negate a)) = Negate a :=
  compl_compl_compl_eq

/-!
## Inducing Properties

Antitone in first argument, monotone in second.
-/

/-- Inducing is antitone in its first argument:
    if `a ≤ b` then `Induces(b,c) ≤ Induces(a,c)`. -/
theorem induces_antitone_left (a b c : Rel) (h : a ≤ b) :
    Induces b c ≤ Induces a c :=
  himp_anti_left h

/-- Inducing is monotone in its second argument:
    if `b ≤ c` then `Induces(a,b) ≤ Induces(a,c)`. -/
theorem induces_monotone_right (a b c : Rel) (h : b ≤ c) :
    Induces a b ≤ Induces a c :=
  himp_le_himp_left h

/-!
## The Bounded Distributive Lattice

Together and Either form a bounded distributive lattice.
-/

/-- Togethering distributes over Eithering. -/
theorem together_distributes_either (a b c : Rel) :
    Together a (Either b c) = Either (Together a b) (Together a c) :=
  inf_sup_left

/-- Eithering distributes over Togethering. -/
theorem either_distributes_together (a b c : Rel) :
    Either a (Together b c) = Together (Either a b) (Either a c) :=
  sup_inf_left

end Relationality.MovementI
