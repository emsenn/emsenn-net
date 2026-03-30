/-
# HeytingDomain — The Meaning Domain H

Corresponds to §1.1 of semiotic-universe.md.

The meaning domain H is a complete Heyting algebra. Completeness
means arbitrary joins and meets exist; the Heyting structure means
implication is defined via the residuation adjunction:

  a ⊓ b ≤ c  ↔  a ≤ b ⇨ c

The domain is intuitionistic: double negation is inflationary
(a ≤ ¬¬a) but not necessarily involutive. This reflects that not
every question about a sign's meaning resolves to yes or no.

In the spec, H = Sub(Y) for a category of sign relations within
a Grothendieck universe U. Here we axiomatize only the algebraic
consequence: H is a complete Heyting algebra. The categorical
construction is future work.

Thinness: H is a thin category (poset). For any a, b ∈ H, there
is at most one morphism a → b, namely the proof of a ≤ b.
-/

import Mathlib.Order.Heyting.Basic

namespace SemioticUniverse

/-!
## The HeytingDomain typeclass

A HeytingDomain is a complete Heyting algebra carrying the
meaning domain of a semiotic universe. We use Mathlib's
existing `CompleteHeytingAlgebra` (which requires complete
lattice + Heyting structure + infinite distributivity of ⊓
over ⨆).

For now, we work with `HeytingAlgebra` and add completeness
when proofs require it. This lets us start proving things
without the full completeness machinery.
-/

/-- A `HeytingDomain` is the meaning domain of a semiotic universe:
a Heyting algebra that serves as the semantic space.

We make this a class rather than an alias so that the semiotic
universe can be built incrementally — `ModalClosure` and
`TraceComonad` extend this with additional operators. -/
class HeytingDomain (H : Type*) extends HeytingAlgebra H

/-- Every HeytingDomain is a BoundedOrder. -/
instance {H : Type*} [HeytingDomain H] : BoundedOrder H :=
  inferInstance

/-!
## Thinness

In a HeytingDomain (poset), any two proofs of a ≤ b are equal.
This is automatic in Lean since ≤ is Prop-valued.
-/

theorem le_unique {H : Type*} [HeytingDomain H] {a b : H}
    (h₁ h₂ : a ≤ b) : h₁ = h₂ :=
  rfl

end SemioticUniverse
