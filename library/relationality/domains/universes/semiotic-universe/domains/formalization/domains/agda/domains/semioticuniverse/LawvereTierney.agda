{-
  LawvereTierney — Modal closure as Lawvere-Tierney topology

  Corresponds to §1.3 of semiotic-universe.md.

  A Lawvere-Tierney topology on a topos is an endomorphism
  j : Ω → Ω satisfying:

    1. j(true) = true
    2. j ∘ j = j                    (idempotent)
    3. j(p ∧ q) = j(p) ∧ j(q)      (preserves meets)

  These three axioms are the DEFINITION. Meet-preservation is
  not an extra property we need to prove — it is what makes j
  a Lawvere-Tierney topology rather than just a closure operator.

  From these three axioms, the induced operator on Sub(Y) — which
  sends a subobject m to the subobject classified by j ∘ χ_m —
  inherits all the properties that the Lean formalization
  axiomatizes:
    - extensive (a ≤ j(a))
    - monotone
    - idempotent
    - join-preserving (in a complete topos)
    - meet-preserving (by definition!)

  This is the payoff of the constructive approach: meet-
  preservation is definitional, not postulated.
-}

module SemioticUniverse.LawvereTierney where

open import Level using (Level; _⊔_; suc)
open import Relation.Binary.PropositionalEquality
  using (_≡_; refl; sym; trans; cong)

open import SemioticUniverse.Category
open import SemioticUniverse.Topos

-- A Lawvere-Tierney topology on an elementary topos.
--
-- j is an endomorphism of Ω (the subobject classifier) satisfying
-- three axioms. Everything else follows.

record LawvereTierney {ℓ ℓ′} (T : ElementaryTopos ℓ ℓ′)
    : Set (ℓ ⊔ ℓ′) where
  open ElementaryTopos T

  field
    j : Hom Ω Ω

    -- Axiom 1: j preserves truth.
    -- j(true) = true, i.e., j ∘ true = true.
    j-true : j ∘ true ≡ true

    -- Axiom 2: j is idempotent.
    -- j ∘ j = j.
    j-idem : j ∘ j ≡ j

    -- Axiom 3: j preserves meets.
    -- j(p ∧ q) = j(p) ∧ j(q).
    -- This requires the internal meet ∧_Ω on Ω, which exists
    -- because Ω is an internal Heyting algebra in any topos.
    --
    -- For now we state this using a postulated internal meet
    -- on Ω. The full construction would build ∧_Ω from the
    -- universal property of Ω.

  -- The internal meet on Ω.
  -- In a topos, Ω has a canonical meet operation ∧_Ω : Ω × Ω → Ω
  -- classifying the intersection of two subobjects. We postulate
  -- it here; the full construction derives it from the diagonal
  -- Δ : Ω → Ω × Ω and the product structure.

  field
    ∧Ω    : Hom Ω Ω → Hom Ω Ω → Hom Ω Ω
    -- This is a simplification — properly, ∧_Ω is a single
    -- morphism Ω × Ω → Ω and we'd need products. The above
    -- captures the induced operation on global sections / endo-
    -- morphisms, which suffices for stating the axiom.

    j-meet : ∀ (p q : Hom Ω Ω) → j ∘ ∧Ω p q ≡ ∧Ω (j ∘ p) (j ∘ q)

  -- From j on Ω, we get j on Sub(Y) by post-composition with
  -- the classifying map:
  --
  --   j_Sub(m) = the subobject classified by j ∘ χ_m
  --
  -- The three axioms on Ω transfer to Sub(Y):
  --
  -- 1. j(true) = true  →  j_Sub(⊤) = ⊤  →  extensive
  --    (More precisely: for any a, a ≤ j(a) because
  --    χ_a ≤ j ∘ χ_a follows from j(true) = true applied
  --    to the truth values classified by a.)
  --
  -- 2. j ∘ j = j  →  j_Sub(j_Sub(a)) = j_Sub(a)  →  idempotent
  --
  -- 3. j(p ∧ q) = j(p) ∧ j(q)  →  j_Sub(a ∧ b) = j_Sub(a) ∧ j_Sub(b)
  --    This IS meet-preservation. It's not derived — it's the
  --    direct image of Axiom 3 under the classify/pullback
  --    correspondence.
