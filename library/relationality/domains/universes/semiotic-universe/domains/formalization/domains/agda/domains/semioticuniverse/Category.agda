{-
  Category — U-small categories with finite limits

  Corresponds to §1.0–1.1 of semiotic-universe.md.

  The spec says: "We work inside a fixed Grothendieck universe U."
  In Agda's type theory, the universe hierarchy Set ℓ already has
  the closure properties that ZFC needs a Grothendieck universe
  axiom to provide: closure under dependent products, dependent
  sums, and identity types. So "U-small" translates to "lives at
  a fixed universe level ℓ."

  We define a minimal notion of category — just enough to state
  what it means for R to have finite limits and be well-powered.
  We do not import agda-categories wholesale; we build what we
  need from the universe structure.
-}

module SemioticUniverse.Category where

open import Level using (Level; _⊔_; suc)
open import Relation.Binary.PropositionalEquality
  using (_≡_; refl; sym; trans; cong; subst)

-- A category at universe level ℓ for objects, ℓ′ for morphisms.
-- This is the standard definition: objects, hom-sets, identity,
-- composition, with associativity and unit laws.

record Category (ℓ ℓ′ : Level) : Set (suc (ℓ ⊔ ℓ′)) where
  field
    Obj : Set ℓ
    Hom : Obj → Obj → Set ℓ′
    id  : ∀ {A} → Hom A A
    _∘_ : ∀ {A B C} → Hom B C → Hom A B → Hom A C

    -- Laws
    assoc     : ∀ {A B C D} (f : Hom A B) (g : Hom B C) (h : Hom C D)
              → (h ∘ g) ∘ f ≡ h ∘ (g ∘ f)
    id-left   : ∀ {A B} (f : Hom A B) → id ∘ f ≡ f
    id-right  : ∀ {A B} (f : Hom A B) → f ∘ id ≡ f

  infixr 9 _∘_

-- A morphism is monic if it is left-cancellable.

IsMono : ∀ {ℓ ℓ′} (C : Category ℓ ℓ′) {A B : Category.Obj C}
       → Category.Hom C A B → Set (ℓ ⊔ ℓ′)
IsMono C {A} {B} m =
  ∀ {X} (f g : Category.Hom C X A) → Category._∘_ C m f ≡ Category._∘_ C m g → f ≡ g

-- A terminal object: an object 1 such that for every A there is
-- exactly one morphism A → 1.

record HasTerminal {ℓ ℓ′} (C : Category ℓ ℓ′) : Set (ℓ ⊔ ℓ′) where
  open Category C
  field
    𝟙       : Obj
    terminal : ∀ (A : Obj) → Hom A 𝟙
    unique   : ∀ {A} (f g : Hom A 𝟙) → f ≡ g

-- A pullback of f and g over B.

record Pullback {ℓ ℓ′} (C : Category ℓ ℓ′)
    {A B D : Category.Obj C}
    (f : Category.Hom C A B) (g : Category.Hom C D B)
    : Set (ℓ ⊔ ℓ′) where
  open Category C
  field
    P   : Obj
    p₁  : Hom P A
    p₂  : Hom P D
    commutes : f ∘ p₁ ≡ g ∘ p₂
    -- Universal property: for any cone, there's a unique mediator
    universal : ∀ {Q} (q₁ : Hom Q A) (q₂ : Hom Q D)
              → f ∘ q₁ ≡ g ∘ q₂
              → Hom Q P
    factor₁   : ∀ {Q} (q₁ : Hom Q A) (q₂ : Hom Q D)
              → (eq : f ∘ q₁ ≡ g ∘ q₂)
              → p₁ ∘ universal q₁ q₂ eq ≡ q₁
    factor₂   : ∀ {Q} (q₁ : Hom Q A) (q₂ : Hom Q D)
              → (eq : f ∘ q₁ ≡ g ∘ q₂)
              → p₂ ∘ universal q₁ q₂ eq ≡ q₂
    mediator-unique : ∀ {Q} (q₁ : Hom Q A) (q₂ : Hom Q D)
              → (eq : f ∘ q₁ ≡ g ∘ q₂)
              → (u : Hom Q P) → p₁ ∘ u ≡ q₁ → p₂ ∘ u ≡ q₂
              → u ≡ universal q₁ q₂ eq

record HasPullbacks {ℓ ℓ′} (C : Category ℓ ℓ′) : Set (ℓ ⊔ ℓ′) where
  open Category C
  field
    pullback : ∀ {A B D} (f : Hom A B) (g : Hom D B) → Pullback C f g
