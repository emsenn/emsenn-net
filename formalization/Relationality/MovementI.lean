/-
# Movement I — Logical Origination

Properties of the recognition field that follow from the axioms
established in Genesis.lean. These theorems verify that the
RecognitionField axioms produce the expected logical structure:
residuation, modus ponens, negation, double negation inflation,
and distributivity.

Every theorem here is a consequence of the HeytingAlgebra instance
derived from RecognitionField. The proofs apply Mathlib's
HeytingAlgebra lemmas, which are available through Genesis's
instance resolution.

Source: draft 12, Movement I (Steps 1–4).
-/

import Relationality.Basic

namespace Relationality.MovementI

variable {Rel : Type*} [RecognitionField Rel]

/-!
## The Residuation (Galois connection)

together(a, b) ≤ c ↔ a ≤ induces(b, c).

This is the defining property of the Heyting implication, stated
as RecognitionField.le_induces_iff in Genesis. Here we restate it
using the relational vocabulary.
-/

theorem residuation (a b c : Rel) :
    Together a b ≤ c ↔ a ≤ Induces b c := by
  exact le_himp_iff.symm

/-!
## Modus Ponens

together(a, induces(a, b)) ≤ b.
Combining a recognition with its sufficiency for b yields at least b.
-/

theorem modus_ponens (a b : Rel) :
    Together a (Induces a b) ≤ b := by
  show a ⊓ (a ⇨ b) ≤ b
  rw [inf_comm]
  exact himp_inf_le

/-!
## Self-sufficiency

a ≤ induces(a, a). Every recognition is sufficient for itself.
-/

theorem self_sufficiency (a : Rel) :
    a ≤ Induces a a := by
  exact le_himp_iff.mpr inf_le_left

/-!
## Negation Properties

negate(a) = induces(a, ⊥). Negation is implication to bottom.
-/

theorem negate_is_induces_bot (a : Rel) :
    Negate a = Induces a Relationlessness := by
  show aᶜ = a ⇨ ⊥
  exact (himp_bot a).symm

/-- together(a, negate(a)) = ⊥. -/
theorem together_negate (a : Rel) :
    Together a (Negate a) = Relationlessness := by
  exact inf_compl_eq_bot

/-!
## The Non-Boolean Gap

Double negation is inflationary (a ≤ ¬¬a) but not necessarily
involutive. The gap between a and ¬¬a represents genuine
indeterminacy: matters not yet determined by relational activity.
In a Boolean algebra ¬¬a = a always; in a Heyting algebra the
inequality can be strict. This non-Boolean character is intrinsic
to the relational framework.
-/

theorem double_negation_inflationary (a : Rel) :
    a ≤ Negate (Negate a) := by
  exact le_compl_compl

theorem negate_antitone (a b : Rel) (h : a ≤ b) :
    Negate b ≤ Negate a := by
  exact compl_anti h

theorem triple_negation (a : Rel) :
    Negate (Negate (Negate a)) = Negate a := by
  show aᶜᶜᶜ = aᶜ
  exact compl_compl_compl a

/-!
## Inducing Properties

Antitone in first argument, monotone in second.
-/

theorem induces_antitone_left (a b c : Rel) (h : a ≤ b) :
    Induces b c ≤ Induces a c := by
  show b ⇨ c ≤ a ⇨ c
  exact himp_le_himp_right h

theorem induces_monotone_right (a b c : Rel) (h : b ≤ c) :
    Induces a b ≤ Induces a c := by
  show a ⇨ b ≤ a ⇨ c
  exact himp_le_himp_left h

/-!
## The Bounded Distributive Lattice

Together and Either form a bounded distributive lattice.
-/

theorem together_distributes_either (a b c : Rel) :
    Together a (Either b c) = Either (Together a b) (Together a c) := by
  show a ⊓ (b ⊔ c) = a ⊓ b ⊔ a ⊓ c
  exact inf_sup_left a b c

theorem either_distributes_together (a b c : Rel) :
    Either a (Together b c) = Together (Either a b) (Either a c) := by
  show a ⊔ b ⊓ c = (a ⊔ b) ⊓ (a ⊔ c)
  exact sup_inf_left a b c

end Relationality.MovementI
