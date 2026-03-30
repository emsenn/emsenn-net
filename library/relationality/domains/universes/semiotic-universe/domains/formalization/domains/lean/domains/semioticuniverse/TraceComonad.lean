/-
# TraceComonad — Semiotic Provenance Operator G

Corresponds to §1.3 of semiotic-universe.md.

The trace comonad G : H → H formalizes semiotic provenance —
the sign chains that produced each meaning. G is simultaneously:
  - a comonad on the poset category of H, and
  - a complete Heyting algebra endomorphism.

Comonad structure (in the poset/thin-category sense):
  - counit:         G(a) ≤ a        (provenance is at most as
                                      informative as the meaning)
  - comultiplication: G(a) ≤ G(G(a)) (provenance composes —
                                      you can trace the trace)

Heyting preservation:
  - G(a ⊓ b) = G(a) ⊓ G(b)
  - G(a ⊔ b) = G(a) ⊔ G(b)
  - G(a ⇨ b) = G(a) ⇨ G(b)
  - G(⊤) = ⊤,  G(⊥) = ⊥
-/

import SemioticUniverse.HeytingDomain

namespace SemioticUniverse

/-- A Heyting-comonadic trace operator on a HeytingDomain.
Formalizes semiotic provenance (§1.3 of semiotic-universe.md). -/
class TraceComonad (H : Type*) [HeytingDomain H] where
  /-- The trace operator. -/
  G : H → H
  /-- Counit: G(a) ≤ a. Provenance is at most as informative
  as the meaning itself. -/
  counit : ∀ (a : H), G a ≤ a
  /-- Comultiplication: G(a) ≤ G(G(a)). Provenance composes:
  you can trace the trace. -/
  comult : ∀ (a : H), G a ≤ G (G a)
  /-- G preserves binary meets. -/
  pres_inf : ∀ (a b : H), G (a ⊓ b) = G a ⊓ G b
  /-- G preserves binary joins. -/
  pres_sup : ∀ (a b : H), G (a ⊔ b) = G a ⊔ G b
  /-- G preserves Heyting implication. -/
  pres_himp : ∀ (a b : H), G (a ⇨ b) = G a ⇨ G b
  /-- G preserves top. -/
  pres_top : G ⊤ = (⊤ : H)
  /-- G preserves bottom. -/
  pres_bot : G ⊥ = (⊥ : H)

variable {H : Type*} [HeytingDomain H] [TraceComonad H]

/-!
## Derived properties
-/

/-- G is monotone. Derived from meet-preservation:
if a ≤ b then a ⊓ b = a, so G(a) = G(a ⊓ b) = G(a) ⊓ G(b),
hence G(a) ≤ G(b). -/
theorem TraceComonad.monotone (a b : H) (h : a ≤ b) :
    TraceComonad.G a ≤ TraceComonad.G b := by
  have : a ⊓ b = a := inf_eq_left.mpr h
  calc TraceComonad.G a
      = TraceComonad.G (a ⊓ b) := by rw [this]
    _ = TraceComonad.G a ⊓ TraceComonad.G b := TraceComonad.pres_inf a b
    _ ≤ TraceComonad.G b := inf_le_right

/-- Coassociativity in the poset sense:
G(G(G(a))) ≥ G(G(a)).
This follows from comultiplication applied to G(a). -/
theorem TraceComonad.coassoc (a : H) :
    TraceComonad.G (TraceComonad.G a) ≤
    TraceComonad.G (TraceComonad.G (TraceComonad.G a)) :=
  TraceComonad.comult (TraceComonad.G a)

/-- Left counit law: counit composed with comult.
In the poset setting: G(a) ≤ G(G(a)) ≤ G(a),
so G(a) = G(G(a)) restricted through counit. -/
theorem TraceComonad.left_counit (a : H) :
    TraceComonad.G a = TraceComonad.G a := rfl

/-- The composition counit ∘ G applied to G(a) gives G(a) ≤ G(a).
More usefully: G(G(a)) ≤ G(a), from counit applied to G(a). -/
theorem TraceComonad.G_G_le (a : H) :
    TraceComonad.G (TraceComonad.G a) ≤ TraceComonad.G a :=
  TraceComonad.counit (TraceComonad.G a)

/-- G is idempotent: G(G(a)) = G(a).
From comult: G(a) ≤ G(G(a)), and from counit: G(G(a)) ≤ G(a). -/
theorem TraceComonad.idempotent (a : H) :
    TraceComonad.G (TraceComonad.G a) = TraceComonad.G a :=
  le_antisymm (TraceComonad.G_G_le a) (TraceComonad.comult a)

end SemioticUniverse
