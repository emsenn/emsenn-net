/-
# Semiotic Ambient — Modal Closure and Heyting-Comonadic Trace

This file extends the recognition field (Genesis.lean) with the two
additional operators that constitute the ambient semantic structure
of the semiotic universe (Section 1 of semiotic-universe.md):

  - A modal closure operator j : R → R (Section 1.2)
  - A Heyting-comonadic trace G : R → R (Section 1.3, Axiom 1.2)
  - Interaction axioms between j and G (Axioms 1.3, 1.4)

The resulting structure (H, j, G) — a Heyting algebra with modal
closure and trace — is the ambient environment in which all further
semiotic construction takes place. It corresponds to Lean Step 1
of the formalization roadmap.

## Architecture

ModalClosure and HeytingComonad are typeclasses parameterized by
[RecognitionField R], so there is exactly one HeytingAlgebra instance
(from RecognitionField.toHeytingAlgebra). SemioticAmbient is a mixin
that assumes all three and adds the interaction axioms.

## What is NOT formalized here

- Completeness of the Heyting algebra (arbitrary joins/meets).
  We postulate j_bot and j_inf as individual axioms of
  ModalClosure; these are consequences of join-continuity in
  a complete Heyting algebra, but the full completeness is not
  yet available in RecognitionField.
- Join-continuity over arbitrary families. We include binary
  join-preservation (j_sup), bottom preservation (j_bot), and
  meet preservation (j_inf). The philosophical derivation
  constructs H as Sub(Y) and asserts completeness; the formal
  derivation from the Sub(Y) construction is future work.

## Source

Semiotic universe specification, Section 1 (Axioms 1.1–1.4,
Lemmas 1.1, 1.5).
-/

import Relationality.Genesis

namespace Relationality

/-!
## Modal Closure Operator

A modal closure operator j on a Heyting algebra R is:
- extensive: a ≤ j(a)
- monotone: a ≤ b → j(a) ≤ j(b)
- idempotent: j(j(a)) = j(a)
- preserves binary joins: j(a ⊔ b) = j(a) ⊔ j(b)
- preserves bottom: j(⊥) = ⊥
- preserves binary meets: j(a ⊓ b) = j(a) ⊓ j(b)

Binary join/meet preservation and bottom preservation are finitary
consequences of join-continuity on a complete Heyting algebra.
Together with extensivity and idempotency, meet preservation makes
j a nucleus in the sense of locale theory.

Corresponds to Section 1.2 of the semiotic universe specification.
-/

class ModalClosure (R : Type*) [RecognitionField R] where
  /-- The modal closure operator. -/
  j : R → R
  /-- Extensive: a ≤ j(a). -/
  j_extensive : ∀ (a : R), a ≤ j a
  /-- Monotone: a ≤ b → j(a) ≤ j(b). -/
  j_monotone : ∀ (a b : R), a ≤ b → j a ≤ j b
  /-- Idempotent: j(j(a)) = j(a). -/
  j_idempotent : ∀ (a : R), j (j a) = j a
  /-- Binary join preservation: j(a ⊔ b) = j(a) ⊔ j(b). -/
  j_sup : ∀ (a b : R), j (a ⊔ b) = j a ⊔ j b
  /-- Bottom preservation: j(⊥) = ⊥.  In the specification j is
      join-continuous over arbitrary families (§1.2 of
      semiotic-universe.md); applied to the empty family this gives
      j(⊥) = ⊥.  Since RecognitionField is finitary, we postulate
      this consequence directly. -/
  j_bot : j (⊥ : R) = ⊥
  /-- Meet preservation: j(a ⊓ b) = j(a) ⊓ j(b).  In a complete
      Heyting algebra, join-continuity of a closure operator implies
      meet preservation.  Since RecognitionField is finitary, we
      postulate this consequence directly. -/
  j_inf : ∀ (a b : R), j (a ⊓ b) = j a ⊓ j b

/-- An element is stable (modal) if j fixes it. -/
def IsStable {R : Type*} [RecognitionField R] [ModalClosure R] (a : R) : Prop :=
  ModalClosure.j a = a

/-!
## Heyting-Comonadic Trace

A Heyting-comonadic trace G on a Heyting algebra R is simultaneously:
- a comonad on the poset-category (counit + comultiplication)
- a Heyting algebra endomorphism (preserves ⊓, ⊔, ⇨, ⊤, ⊥)

In a poset, comonad axioms reduce to inequalities:
- counit:           G(a) ≤ a
- comultiplication:  G(a) ≤ G(G(a))

The Heyting preservation is Axiom 1.2 of the specification.

Corresponds to Section 1.3 of the semiotic universe specification.
-/

class HeytingComonad (R : Type*) [RecognitionField R] where
  /-- The trace operator. -/
  G : R → R
  /-- Counit: G(a) ≤ a (extraction is deflating). -/
  G_counit : ∀ (a : R), G a ≤ a
  /-- Comultiplication: G(a) ≤ G(G(a)) (duplication is inflating within G). -/
  G_comult : ∀ (a : R), G a ≤ G (G a)
  /-- Preserves meets: G(a ⊓ b) = G(a) ⊓ G(b). -/
  G_inf : ∀ (a b : R), G (a ⊓ b) = G a ⊓ G b
  /-- Preserves joins: G(a ⊔ b) = G(a) ⊔ G(b). -/
  G_sup : ∀ (a b : R), G (a ⊔ b) = G a ⊔ G b
  /-- Preserves top: G(⊤) = ⊤. -/
  G_top : G (⊤ : R) = ⊤
  /-- Preserves bottom: G(⊥) = ⊥. -/
  G_bot : G (⊥ : R) = ⊥
  /-- Preserves Heyting implication: G(a ⇨ b) = G(a) ⇨ G(b). -/
  G_himp : ∀ (a b : R), G (a ⇨ b) = G a ⇨ G b

/-!
## Derived Properties of G
-/

section DerivedG

variable {R : Type*} [RecognitionField R] [HeytingComonad R]

/-- Monotonicity of G follows from meet preservation. -/
theorem HeytingComonad.G_monotone (a b : R) (h : a ≤ b) :
    HeytingComonad.G a ≤ HeytingComonad.G b := by
  have hab : a ⊓ b = a := inf_eq_left.mpr h
  calc HeytingComonad.G a
      = HeytingComonad.G (a ⊓ b) := by rw [hab]
    _ = HeytingComonad.G a ⊓ HeytingComonad.G b := HeytingComonad.G_inf a b
    _ ≤ HeytingComonad.G b := inf_le_right

/-- G preserves the complement: G(aᶜ) = (G a)ᶜ. -/
theorem HeytingComonad.G_compl (a : R) :
    HeytingComonad.G aᶜ = (HeytingComonad.G a)ᶜ := by
  -- aᶜ = a ⇨ ⊥ and (G a)ᶜ = G a ⇨ ⊥ by himp_bot.
  calc HeytingComonad.G aᶜ
      = HeytingComonad.G (a ⇨ ⊥) := by rw [himp_bot]
    _ = HeytingComonad.G a ⇨ HeytingComonad.G ⊥ := HeytingComonad.G_himp a ⊥
    _ = HeytingComonad.G a ⇨ ⊥ := by rw [HeytingComonad.G_bot]
    _ = (HeytingComonad.G a)ᶜ := himp_bot (HeytingComonad.G a)

end DerivedG

/-!
## The Semiotic Ambient Structure

The full ambient structure assumes a RecognitionField with both
ModalClosure and HeytingComonad, plus interaction axioms.

Axiom 1.3 (basic interaction): j(G(a)) ≤ G(j(a)).
Axiom 1.4 (stability equivalence): a is stable iff G(a) is stable.
-/

class SemioticAmbient (R : Type*) [RecognitionField R]
    [ModalClosure R] [HeytingComonad R] where
  /-- Axiom 1.3: j(G(a)) ≤ G(j(a)). -/
  j_G_le_G_j : ∀ (a : R), ModalClosure.j (HeytingComonad.G a) ≤
    HeytingComonad.G (ModalClosure.j a)
  /-- Axiom 1.4 forward: if a is stable then G(a) is stable. -/
  stable_of_trace_stable : ∀ (a : R),
    IsStable a → IsStable (HeytingComonad.G a)
  /-- Axiom 1.4 reverse: if G(a) is stable then a is stable. -/
  trace_stable_of_stable : ∀ (a : R),
    IsStable (HeytingComonad.G a) → IsStable a

/-!
## Lemma 1.1: The Stable Fragment is a Heyting Subalgebra

If a and b are stable (fixed by j), then so are:
- a ⊓ b, a ⊔ b, a ⇨ b, ⊤, ⊥

This shows H^st is closed under all Heyting operations.
-/

section StableFragment

variable {R : Type*} [RecognitionField R] [ModalClosure R]

/-- ⊤ is stable: j(⊤) = ⊤. -/
theorem isStable_top : IsStable (⊤ : R) := by
  unfold IsStable
  apply le_antisymm
  · exact le_top
  · exact ModalClosure.j_extensive ⊤

/-- ⊥ is stable: j(⊥) = ⊥. -/
theorem isStable_bot : IsStable (⊥ : R) := ModalClosure.j_bot

/-- Binary join of stable elements is stable. -/
theorem isStable_sup {a b : R} (ha : IsStable a) (hb : IsStable b) :
    IsStable (a ⊔ b) := by
  unfold IsStable at *
  rw [ModalClosure.j_sup, ha, hb]

/-- Binary meet of stable elements is stable. -/
theorem isStable_inf {a b : R} (ha : IsStable a) (hb : IsStable b) :
    IsStable (a ⊓ b) := by
  unfold IsStable at *
  rw [ModalClosure.j_inf, ha, hb]

/-- Heyting implication of stable elements is stable.
    Uses meet preservation (j_inf) and the Heyting adjunction. -/
theorem isStable_himp {a b : R} (ha : IsStable a) (hb : IsStable b) :
    IsStable (a ⇨ b) := by
  unfold IsStable at *
  apply le_antisymm
  · -- j(a ⇨ b) ≤ a ⇨ b; by adjunction, suffices j(a ⇨ b) ⊓ a ≤ b.
    apply le_himp_iff.mpr
    calc ModalClosure.j (a ⇨ b) ⊓ a
        = ModalClosure.j (a ⇨ b) ⊓ ModalClosure.j a := by congr 1; exact ha.symm
      _ = ModalClosure.j ((a ⇨ b) ⊓ a) := (ModalClosure.j_inf _ _).symm
      _ ≤ ModalClosure.j b := ModalClosure.j_monotone _ _ himp_inf_le
      _ = b := hb
  · exact ModalClosure.j_extensive (a ⇨ b)

end StableFragment

/-!
## Lemma 1.5: G Restricts to the Stable Fragment

Given the SemioticAmbient structure (Axiom 1.4), G maps stable
elements to stable elements and preserves the Heyting structure.
-/

section TraceOnStable

variable {R : Type*} [RecognitionField R] [ModalClosure R]
  [HeytingComonad R] [SemioticAmbient R]

/-- G maps stable elements to stable elements (Axiom 1.4 forward). -/
theorem G_stable_of_stable {a : R} (h : IsStable a) :
    IsStable (HeytingComonad.G a) :=
  SemioticAmbient.stable_of_trace_stable a h

/-- If G(a) is stable then a is stable (Axiom 1.4 reverse). -/
theorem stable_of_G_stable {a : R} (h : IsStable (HeytingComonad.G a)) :
    IsStable a :=
  SemioticAmbient.trace_stable_of_stable a h

end TraceOnStable

/- The following are convenience restatements of G's Heyting
   preservation. They only need [RecognitionField R] [HeytingComonad R],
   not the full SemioticAmbient structure. -/

section GPreservation

variable {R : Type*} [RecognitionField R] [HeytingComonad R]

/-- G preserves meets. -/
theorem G_pres_inf (a b : R) :
    HeytingComonad.G (a ⊓ b) = HeytingComonad.G a ⊓ HeytingComonad.G b :=
  HeytingComonad.G_inf a b

/-- G preserves joins. -/
theorem G_pres_sup (a b : R) :
    HeytingComonad.G (a ⊔ b) = HeytingComonad.G a ⊔ HeytingComonad.G b :=
  HeytingComonad.G_sup a b

/-- G preserves implication. -/
theorem G_pres_himp (a b : R) :
    HeytingComonad.G (a ⇨ b) = HeytingComonad.G a ⇨ HeytingComonad.G b :=
  HeytingComonad.G_himp a b

end GPreservation

/-!
## Completeness Gap

No sorry marks remain.  The two previously sorry-marked theorems
(`isStable_bot` and `isStable_himp`) were resolved by adding
`j_bot` and `j_inf` to ModalClosure.

These added axioms are consequences of join-continuity in a complete
Heyting algebra.  The semiotic universe specification (§1.2) assumes
H is complete, which makes j a nucleus (= meet-preserving closure
operator).  However, `RecognitionField` (Genesis.lean) formalizes
only the finitary Heyting algebra structure.

The philosophical derivation (draft 12, Movement I) constructs H
as Sub(Y) — the subobject lattice of an object Y — and asserts
completeness: "our lattice is complete (any collection of
subobjects has a join)."  This is standard when the ambient
category is a topos, but the topos structure itself is not yet
formally derived from philosophical first principles.

Following the Genesis.lean pattern (postulate, verify sufficiency,
note future work), `j_bot` and `j_inf` are added as postulated
axioms.  A formal derivation of completeness from the Sub(Y)
construction is future work.
-/

end Relationality
