/-
# Genesis — The Axioms of the Recognition Field

This file contains the SOLE axioms of the formalization. Every
subsequent file (Basic, Movements I–V) derives its structure from
what is established here. No file imports HeytingAlgebra independently.

The axioms are organized in three groups corresponding to the three
steps of the philosophical derivation (draft 12, Movement I):

  Step 1 — Partial order: distinctions compose. The collection of
    distinctions on an object, ordered by inclusion, forms a
    partially ordered set.

  Step 2 — Bounded lattice: coherent combining requires a greatest
    lower bound (together, ⊓). Coherent choosing requires a least
    upper bound (either, ⊔). The empty distinction gives bottom (⊥).
    The total distinction gives top (⊤).

  Step 3 — Heyting implication: coherent conditioning requires an
    operation answering "given a, what must be added to get b?" This
    is induces(a,b) = max{x | together(x,a) ≤ b}, with the defining
    property together(a,b) ≤ c ↔ a ≤ induces(b,c).

These axioms encode the conclusion of the philosophical derivation.
They are equivalent to the axioms of a Heyting algebra — the
toHeytingAlgebra construction below proves this by building a
HeytingAlgebra instance from the RecognitionField fields. All
Mathlib lemmas about Heyting algebras then become available
throughout the formalization via instance resolution.

The philosophical derivation argues that these axioms MUST hold for
any coherent system of distinctions. A formal derivation from
categorical foundations (showing that subobject lattices of a
suitable category satisfy these axioms) is future work. For now,
the axioms are postulated and their sufficiency is verified.

The algebra is Heyting, not Boolean. Double negation is inflationary
(a ≤ ¬¬a) but not necessarily involutive (¬¬a may strictly exceed a).
The gap is genuine indeterminacy: matters not yet determined by
relational activity so far.
-/

import Mathlib.Order.Heyting.Basic

namespace Relationality

/-!
## The Recognition Field

RecognitionField is a typeclass carrying the operations and axioms
of the recognition field. It is the sole axiom source for the
entire formalization. Subsequent files assume [RecognitionField R]
and receive HeytingAlgebra R through instance resolution.
-/

class RecognitionField (R : Type*) where
  -- Step 1: Partial order from coherent distinguishing.
  le : R → R → Prop
  le_refl : ∀ (a : R), le a a
  le_trans : ∀ (a b c : R), le a b → le b c → le a c
  le_antisymm : ∀ (a b : R), le a b → le b a → a = b

  -- Step 2: Bounded lattice from coherent combining and choosing.
  -- Togethering: greatest lower bound.
  together : R → R → R
  together_le_left : ∀ (a b : R), le (together a b) a
  together_le_right : ∀ (a b : R), le (together a b) b
  le_together : ∀ (a b c : R), le a b → le a c → le a (together b c)
  -- Eithering: least upper bound.
  either : R → R → R
  le_either_left : ∀ (a b : R), le a (either a b)
  le_either_right : ∀ (a b : R), le b (either a b)
  either_le : ∀ (a b c : R), le a c → le b c → le (either a b) c
  -- Bounds.
  bottom : R
  bottom_le : ∀ (a : R), le bottom a
  top : R
  le_top : ∀ (a : R), le a top

  -- Step 3: Heyting implication from coherent conditioning.
  -- induces(b,c): the greatest x such that together(x,b) ≤ c.
  induces : R → R → R
  le_induces_iff : ∀ (a b c : R), le a (induces b c) ↔ le (together a b) c

/-!
## HeytingAlgebra Instance

The axioms of RecognitionField are sufficient to constitute a
Heyting algebra. This instance construction proves that claim and
makes all Mathlib HeytingAlgebra lemmas available to any type
carrying a RecognitionField instance.

This is the SOLE point where HeytingAlgebra enters the formalization.
No subsequent file assumes HeytingAlgebra independently.
-/

noncomputable instance RecognitionField.toHeytingAlgebra {R : Type*}
    [rf : RecognitionField R] : HeytingAlgebra R where
  le := rf.le
  le_refl := rf.le_refl
  le_trans := rf.le_trans
  le_antisymm := rf.le_antisymm
  inf := rf.together
  inf_le_left := rf.together_le_left
  inf_le_right := rf.together_le_right
  le_inf := rf.le_together
  sup := rf.either
  le_sup_left := rf.le_either_left
  le_sup_right := rf.le_either_right
  sup_le := rf.either_le
  bot := rf.bottom
  bot_le := rf.bottom_le
  top := rf.top
  le_top := rf.le_top
  himp := rf.induces
  le_himp_iff := rf.le_induces_iff
  compl := fun a => rf.induces a rf.bottom
  himp_bot := fun _ => rfl

/-!
## Reverse Direction: HeytingAlgebra → RecognitionField

Every Heyting algebra satisfies the axioms of a RecognitionField.
This shows the axiom sets are equivalent: RecognitionField and
HeytingAlgebra are the same mathematical structure under different
vocabulary.

This construction is NOT used in the formalization's dependency
chain. It exists to document the equivalence.
-/

def RecognitionField.ofHeytingAlgebra {R : Type*}
    [ha : HeytingAlgebra R] : RecognitionField R where
  le := (· ≤ ·)
  le_refl := fun a => _root_.le_refl a
  le_trans := fun _ _ _ hab hbc => _root_.le_trans hab hbc
  le_antisymm := fun _ _ hab hba => _root_.le_antisymm hab hba
  together := (· ⊓ ·)
  together_le_left := fun _ _ => _root_.inf_le_left
  together_le_right := fun _ _ => _root_.inf_le_right
  le_together := fun _ _ _ hab hac => _root_.le_inf hab hac
  either := (· ⊔ ·)
  le_either_left := fun _ _ => _root_.le_sup_left
  le_either_right := fun _ _ => _root_.le_sup_right
  either_le := fun _ _ _ hac hbc => _root_.sup_le hac hbc
  bottom := ⊥
  bottom_le := fun _ => _root_.bot_le
  top := ⊤
  le_top := fun _ => _root_.le_top
  induces := (· ⇨ ·)
  le_induces_iff := fun _ _ _ => _root_.le_himp_iff

end Relationality
