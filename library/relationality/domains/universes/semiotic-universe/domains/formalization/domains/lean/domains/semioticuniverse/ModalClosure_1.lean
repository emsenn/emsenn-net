/-
# ModalClosure — Habit-Formation Operator j

Corresponds to §1.2 of semiotic-universe.md.

The modal closure operator j : H → H formalizes habit-formation:
the process by which meanings stabilize through repeated semiosis
into habitual interpretations. A meaning a where j(a) = a has
become habitual; a meaning where j(a) > a is still undergoing
semiosis.

j is:
  - extensive:       a ≤ j(a)       (habit includes raw meaning)
  - monotone:        a ≤ b → j(a) ≤ j(b)
  - idempotent:      j(j(a)) = j(a) (forming a habit of a habit is the same habit)
  - join-preserving: j(a ⊔ b) = j(a) ⊔ j(b)
  - meet-preserving: j(a ⊓ b) = j(a) ⊓ j(b) (nucleus / Lawvere-Tierney)

The habitual fragment H_hab = { a | j(a) = a } is the domain of
meanings that have become habits. Lemma 1.1 of the spec proves
this is a complete Heyting subalgebra.
-/

import SemioticUniverse.HeytingDomain

namespace SemioticUniverse

/-- A modal closure operator on a HeytingDomain.
Formalizes habit-formation (§1.2 of semiotic-universe.md). -/
class ModalClosure (H : Type*) [HeytingDomain H] where
  /-- The closure operator. -/
  j : H → H
  /-- Extensive: a ≤ j(a). -/
  extensive : ∀ (a : H), a ≤ j a
  /-- Monotone: a ≤ b → j(a) ≤ j(b). -/
  monotone : ∀ (a b : H), a ≤ b → j a ≤ j b
  /-- Idempotent: j(j(a)) = j(a). -/
  idempotent : ∀ (a : H), j (j a) = j a
  /-- Join-preserving (binary): j(a ⊔ b) = j(a) ⊔ j(b). -/
  join_preserving : ∀ (a b : H), j (a ⊔ b) = j a ⊔ j b
  /-- j(⊥) = ⊥. The empty meaning forms no habit. -/
  j_bot : j ⊥ = (⊥ : H)
  /-- Meet-preserving (nucleus): j(a ⊓ b) = j(a) ⊓ j(b).
  This is the defining property of a Lawvere-Tierney topology
  (see lawvere-tierney-topology.md): closure of a conjunction
  is the conjunction of closures. It is inherent in the
  construction of j as an endomorphism of the subobject
  classifier Ω in the topos of sign relations. -/
  meet_preserving : ∀ (a b : H), j (a ⊓ b) = j a ⊓ j b

variable {H : Type*} [HeytingDomain H] [ModalClosure H]

/-- A meaning is habitual if it is a fixed point of j. -/
def IsHabitual (a : H) : Prop := ModalClosure.j a = a

/-!
## Lemma 1.1: The habitual fragment is a Heyting subalgebra

We prove closure under each Heyting operation.
-/

/-- ⊤ is habitual. -/
theorem isHabitual_top : IsHabitual (⊤ : H) := by
  unfold IsHabitual
  apply le_antisymm
  · exact le_top
  · exact ModalClosure.extensive ⊤

/-- ⊥ is habitual. -/
theorem isHabitual_bot : IsHabitual (⊥ : H) :=
  ModalClosure.j_bot

/-- j(a) is always habitual (idempotence). -/
theorem isHabitual_j (a : H) : IsHabitual (ModalClosure.j a) :=
  ModalClosure.idempotent a

/-- The join of two habitual elements is habitual. -/
theorem IsHabitual.sup {a b : H} (ha : IsHabitual a)
    (hb : IsHabitual b) : IsHabitual (a ⊔ b) := by
  unfold IsHabitual at *
  rw [ModalClosure.join_preserving, ha, hb]

/-- The meet of two habitual elements is habitual.
With meet_preserving, this is immediate: j(a ⊓ b) = j(a) ⊓ j(b) = a ⊓ b. -/
theorem IsHabitual.inf {a b : H} (ha : IsHabitual a)
    (hb : IsHabitual b) : IsHabitual (a ⊓ b) := by
  unfold IsHabitual at *
  rw [ModalClosure.meet_preserving, ha, hb]

/-- The Heyting implication of two habitual elements is habitual.

This is the deepest part of Lemma 1.1. It requires:
  j(a ⇨ b) = a ⇨ b  when j(a) = a and j(b) = b.

Proof sketch: For any c, c ≤ j(a ⇨ b) implies
  c ⊓ a ≤ j(a ⇨ b) ⊓ j(a) = j(a ⇨ b) ⊓ a
  ≤ j((a ⇨ b) ⊓ a) ≤ j(b) = b.
So j(a ⇨ b) ≤ a ⇨ b by the residuation adjunction.
Combined with extensiveness. -/
theorem IsHabitual.himp {a b : H} (ha : IsHabitual a)
    (hb : IsHabitual b) : IsHabitual (a ⇨ b) := by
  unfold IsHabitual at *
  apply le_antisymm
  · -- Show j(a ⇨ b) ≤ a ⇨ b, i.e. j(a ⇨ b) ⊓ a ≤ b
    rw [le_himp_iff]
    -- j(a ⇨ b) ⊓ a ≤ j(a ⇨ b) ⊓ j(a)
    calc ModalClosure.j (a ⇨ b) ⊓ a
        = ModalClosure.j (a ⇨ b) ⊓ ModalClosure.j a := by rw [ha]
      _ ≤ ModalClosure.j ((a ⇨ b) ⊓ a) := by
          -- j(x) ⊓ j(y) ≤ j(x ⊓ y) follows directly from
          -- meet_preserving: j(x ⊓ y) = j(x) ⊓ j(y).
          rw [ModalClosure.meet_preserving]
      _ ≤ ModalClosure.j b := by
          apply ModalClosure.monotone
          exact himp_inf_le
      _ = b := hb
  · exact ModalClosure.extensive _

end SemioticUniverse
