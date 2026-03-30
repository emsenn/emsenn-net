{-
  SubobjectLattice — Sub(Y) as a Heyting algebra

  Corresponds to §1.2 of semiotic-universe.md (Theorem 1.1).

  Given an elementary topos (R, Ω, true), for any object Y,
  the subobject poset Sub(Y) is a complete Heyting algebra.

  The operations are:
    ⊤ = id_Y                       (Y is a subobject of itself)
    ⊥ = 0 ↪ Y                     (empty subobject)
    a ∧ b = pullback of a and b    (intersection)
    a ∨ b = image of a + b → Y    (union)
    a ⇒ b = max { x | x ∧ a ≤ b } (Heyting implication)

  The Heyting implication exists because Ω has internal
  exponentials — the subobject classifier is a Heyting algebra
  object in the topos.

  This is THE key theorem: it is what converts the categorical
  structure of R (which lives in the Grothendieck universe) into
  the algebraic structure of H (which the rest of the spec uses).
-}

module SemioticUniverse.SubobjectLattice where

open import Level using (Level; _⊔_; suc)
open import Relation.Binary.PropositionalEquality
  using (_≡_; refl; sym; trans; cong)

open import SemioticUniverse.Category
open import SemioticUniverse.Topos

-- A subobject of Y in category C: a mono m : X ↪ Y, up to
-- the equivalence that identifies m₁ and m₂ when they factor
-- through each other.
--
-- For now we work with representatives (specific monos) rather
-- than equivalence classes. The ordering is: m₁ ≤ m₂ when
-- there exists a morphism i : X₁ → X₂ with m₁ = m₂ ∘ i.

module _ {ℓ ℓ′} (T : ElementaryTopos ℓ ℓ′) where

  open ElementaryTopos T

  -- A subobject of Y: a mono into Y.
  record Sub (Y : Obj) : Set (ℓ ⊔ ℓ′) where
    field
      domain : Obj
      arrow  : Hom domain Y
      isMono : IsMono cat arrow

  -- Ordering on subobjects: m₁ ≤ m₂ when m₁ factors through m₂.
  record _≤Sub_ {Y : Obj} (m₁ m₂ : Sub Y) : Set ℓ′ where
    open Sub
    field
      factor   : Hom (domain m₁) (domain m₂)
      commutes : _∘_ (arrow m₂) factor ≡ arrow m₁

  -- The top subobject: Y itself.
  ⊤Sub : ∀ {Y} → Sub Y
  ⊤Sub {Y} = record
    { domain = Y
    ; arrow  = id
    ; isMono = λ f g eq →
        trans (sym (id-left f)) (trans eq (id-left g))
    }

  -- Meet of two subobjects: their pullback.
  -- This is where HasPullbacks does the work.
  _∧Sub_ : ∀ {Y} → Sub Y → Sub Y → Sub Y
  _∧Sub_ {Y} m₁ m₂ = record
    { domain = Pullback.P pb
    ; arrow  = _∘_ (Sub.arrow m₁) (Pullback.p₁ pb)
    ; isMono = λ f g eq →
        -- The pullback of two monos is mono.
        -- Given: (m₁ ∘ p₁) ∘ f = (m₁ ∘ p₁) ∘ g
        -- Step 1: by assoc, m₁ ∘ (p₁ ∘ f) = m₁ ∘ (p₁ ∘ g)
        -- Step 2: m₁ mono ⟹ p₁ ∘ f = p₁ ∘ g
        -- Step 3: from commutes, m₂ ∘ (p₂ ∘ f) = m₂ ∘ (p₂ ∘ g)
        -- Step 4: m₂ mono ⟹ p₂ ∘ f = p₂ ∘ g
        -- Step 5: uniqueness of pullback mediator ⟹ f = g
        let open Pullback pb
            m₁-arr = Sub.arrow m₁
            m₂-arr = Sub.arrow m₂
            m₁-mono = Sub.isMono m₁
            m₂-mono = Sub.isMono m₂
            -- Step 1-2: p₁ ∘ f = p₁ ∘ g
            p₁f≡p₁g = m₁-mono (p₁ ∘ f) (p₁ ∘ g)
              (trans (sym (assoc f p₁ m₁-arr))
                (trans eq (assoc g p₁ m₁-arr)))
            -- Step 3-4: p₂ ∘ f = p₂ ∘ g
            -- From commutes: m₁-arr ∘ p₁ = m₂-arr ∘ p₂
            -- So m₂-arr ∘ (p₂ ∘ f) = (m₂-arr ∘ p₂) ∘ f
            --    = (m₁-arr ∘ p₁) ∘ f = m₁-arr ∘ (p₁ ∘ f)
            --    = m₁-arr ∘ (p₁ ∘ g) = (m₁-arr ∘ p₁) ∘ g
            --    = (m₂-arr ∘ p₂) ∘ g = m₂-arr ∘ (p₂ ∘ g)
            p₂f≡p₂g = m₂-mono (p₂ ∘ f) (p₂ ∘ g)
              (trans (sym (assoc f p₂ m₂-arr))
                (trans (cong (_∘ f) (sym commutes))
                  (trans (assoc f p₁ m₁-arr)
                    (trans (cong (m₁-arr ∘_) p₁f≡p₁g)
                      (trans (sym (assoc g p₁ m₁-arr))
                        (trans (cong (_∘ g) commutes)
                          (assoc g p₂ m₂-arr)))))))
            -- Step 5: both f and g mediate the same cone
            -- f = universal ... and g = universal ... so f = g
            comm-f = trans (sym (assoc f p₁ m₁-arr))
                       (trans (cong (_∘ f) commutes)
                         (assoc f p₂ m₂-arr))
            comm-g = trans (sym (assoc g p₁ m₁-arr))
                       (trans (cong (_∘ g) commutes)
                         (assoc g p₂ m₂-arr))
        in trans (mediator-unique (p₁ ∘ f) (p₂ ∘ f) comm-f f refl refl)
             (sym (mediator-unique (p₁ ∘ f) (p₂ ∘ f) comm-f g
               (sym p₁f≡p₁g) (sym p₂f≡p₂g)))
    }
    where
      pb = HasPullbacks.pullback hasPullbacks
             (Sub.arrow m₁) (Sub.arrow m₂)

  -- The Heyting implication a ⇒ b.
  --
  -- In a topos, this exists because Ω is an internal Heyting
  -- algebra. The implication a ⇒ b is classified by the
  -- composite χ_a ⇒_Ω χ_b, where ⇒_Ω is the internal
  -- implication on Ω.
  --
  -- This is the deepest construction — it requires the internal
  -- logic of the topos. For now, we postulate it and record what
  -- it must satisfy.

  postulate
    _⇒Sub_ : ∀ {Y} → Sub Y → Sub Y → Sub Y

    -- Residuation: the defining property of Heyting implication.
    -- c ∧ a ≤ b  ↔  c ≤ a ⇒ b
    ⇒Sub-residuation-→ : ∀ {Y} (a b c : Sub Y)
      → _≤Sub_ (_∧Sub_ c a) b → _≤Sub_ c (_⇒Sub_ a b)
    ⇒Sub-residuation-← : ∀ {Y} (a b c : Sub Y)
      → _≤Sub_ c (_⇒Sub_ a b) → _≤Sub_ (_∧Sub_ c a) b

  -- The above postulates are justified by:
  --   1. Ω has an internal Heyting algebra structure in any topos
  --      (Johnstone, Sketches of an Elephant, A1.6)
  --   2. The classifying map χ : Y → Ω preserves this structure
  --   3. Residuation on Sub(Y) is inherited from Ω
  --
  -- A full proof would construct ⇒_Ω using the exponential
  -- Ω^Ω in the topos, then define a ⇒ b via its classifying
  -- map. This is the main piece of future work in this
  -- formalization.
