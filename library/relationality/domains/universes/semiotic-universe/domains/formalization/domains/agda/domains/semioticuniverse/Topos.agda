{-
  Topos — Subobject classifier and elementary topos structure

  Corresponds to §1.1–1.2 of semiotic-universe.md.

  The spec requires R to have a subobject classifier: an object Ω
  and a distinguished arrow true : 1 → Ω such that every mono
  m : X ↪ Y has a unique characteristic morphism χ_m : Y → Ω
  making the appropriate square a pullback.

  The existence of Ω, together with finite limits, makes R an
  elementary topos. This is where the Heyting algebra structure
  on Sub(Y) comes from — it is a theorem of topos theory, not
  an axiom we impose.
-}

module SemioticUniverse.Topos where

open import Level using (Level; _⊔_; suc)
open import Relation.Binary.PropositionalEquality
  using (_≡_; refl; sym; trans; cong)

open import SemioticUniverse.Category

-- A subobject classifier in a category with a terminal object.
--
-- Ω is the "object of truth values." The arrow true : 1 → Ω
-- classifies monomorphisms: for every mono m : X ↪ Y, there
-- is a unique χ : Y → Ω such that m is the pullback of true
-- along χ.

record SubobjectClassifier {ℓ ℓ′} (C : Category ℓ ℓ′)
    (term : HasTerminal C) : Set (ℓ ⊔ ℓ′) where
  open Category C
  open HasTerminal term
  field
    Ω     : Obj
    true  : Hom 𝟙 Ω

    -- For every mono m : X ↪ Y, a characteristic morphism χ
    classify : ∀ {X Y} (m : Hom X Y) → IsMono C m → Hom Y Ω

    -- The classifying square is a pullback
    classifying-pullback : ∀ {X Y} (m : Hom X Y) (mono : IsMono C m)
      → Pullback C (classify m mono) true

    -- χ is unique: any other morphism making the square a
    -- pullback equals χ
    classify-unique : ∀ {X Y} (m : Hom X Y) (mono : IsMono C m)
      → (χ′ : Hom Y Ω) → Pullback C χ′ true → classify m mono ≡ χ′

-- An elementary topos: a category with finite limits and a
-- subobject classifier.
--
-- This is the minimal structure from which Sub(Y) as a Heyting
-- algebra is derivable. We do not require cartesian closure
-- separately — in the presence of a subobject classifier and
-- finite limits, it follows (Johnstone, Sketches of an Elephant,
-- A2.1).

record ElementaryTopos (ℓ ℓ′ : Level) : Set (suc (ℓ ⊔ ℓ′)) where
  field
    cat          : Category ℓ ℓ′
    hasTerminal  : HasTerminal cat
    hasPullbacks : HasPullbacks cat
    subobj       : SubobjectClassifier cat hasTerminal

  open Category cat public
  open HasTerminal hasTerminal public
  open SubobjectClassifier subobj public
