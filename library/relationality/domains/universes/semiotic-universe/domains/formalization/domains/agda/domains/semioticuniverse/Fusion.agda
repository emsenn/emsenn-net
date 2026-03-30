{-
  Fusion — Congruence, Naming, and Reflection

  Corresponds to §5–6 of semiotic-universe.md.

  Fusion enforces coherence between syntax and semantics:
    - quotienting syntactic operators by fragmentwise equality,
    - adding new operators that name already-available behaviors.

  A sign system in which every available semantic behavior has a
  syntactic name, and every syntactically identical pair agrees
  semantically everywhere, is one in which what can be said and
  what can be meant are in complete correspondence.

  §5.1: Partial semiotic structures (pairs (H_X, Op_X))
  §5.2: Fragmentwise congruence (~_X)
  §5.3: Naming of admissible behaviors
  §6.1: Fusion closure operator S_fus
  §6.2: Fusion as a reflector (left adjoint to inclusion)
-}

module SemioticUniverse.Fusion where

open import Level using (Level; _⊔_) renaming (suc to lsuc)
open import Data.Nat using (ℕ)
open import Data.List using (List)
open import Data.Product using (_×_; _,_; proj₁; proj₂)
open import Data.Sum using (_⊎_; inj₁; inj₂)
open import Relation.Binary.PropositionalEquality
  using (_≡_; refl; sym; trans; cong)

-- Parameterized over the same abstract Heyting domain as
-- Fragment and Interpretation.

module Fusions
  {ℓ : Level}
  (H : Set ℓ)
  -- Heyting operations
  (_⊓_ _⊔H_ _⇨_ : H → H → H)
  (⊤H ⊥H : H)
  -- Modal closure and trace
  (j G : H → H)
  -- Ordering
  (_≤_ : H → H → Set ℓ)
  where

  open import SemioticUniverse.Fragment
  open Fragments H _⊓_ _⊔H_ _⇨_ ⊤H ⊥H j G _≤_

  -- We work with unary interpretations for Fusion (matching the Lean
  -- formalization). The n-ary generalization requires dependent vectors.
  -- A unary interpretation maps operator identifiers to semantic
  -- endofunctions on H.

  record Interpretation₁ : Set (lsuc ℓ) where
    field
      interp : ℕ → (H → H)
      modal-hom    : ∀ (f : ℕ) (a : H) → j (interp f a) ≡ interp f (j a)
      trace-compat : ∀ (f : ℕ) (a : H) → G (interp f a) ≡ interp f (G a)
      frag-pres    : ∀ (f : ℕ) (F : Fragment) (a : H)
                   → Fragment.mem F a → Fragment.mem F (interp f a)

  -- §5.1: Partial semiotic structures.
  -- A pair (H_X, Op_X) of a set of meanings and a set of operators.
  -- Together these form the complete lattice U = P(H) × P(Op^def),
  -- ordered componentwise by inclusion.

  record PartialStructure : Set (lsuc (lsuc ℓ)) where
    field
      sem : H → Set ℓ           -- which meanings are in scope
      syn : ℕ → Set (lsuc ℓ)   -- which operators are in scope (ℕ as placeholder)

  -- Ordering: componentwise inclusion.
  record _≤PS_ (X Y : PartialStructure) : Set (lsuc ℓ) where
    open PartialStructure
    field
      sem-sub : ∀ a → sem X a → sem Y a
      syn-sub : ∀ f → syn X f → syn Y f

  -- Reflexivity
  ≤PS-refl : ∀ (X : PartialStructure) → X ≤PS X
  ≤PS-refl X = record { sem-sub = λ _ h → h ; syn-sub = λ _ h → h }

  -- Transitivity
  ≤PS-trans : ∀ {X Y Z : PartialStructure} → X ≤PS Y → Y ≤PS Z → X ≤PS Z
  ≤PS-trans xy yz = record
    { sem-sub = λ a h → _≤PS_.sem-sub yz a (_≤PS_.sem-sub xy a h)
    ; syn-sub = λ f h → _≤PS_.syn-sub yz f (_≤PS_.syn-sub xy f h)
    }

  -- §5.2: A fragment is contained in a partial structure.
  ContainedIn : Fragment → PartialStructure → Set ℓ
  ContainedIn F X = ∀ a → Fragment.mem F a → PartialStructure.sem X a

  -- Fragmentwise congruence: f ~_X g iff they agree on every
  -- fragment contained in X.
  Congruent : Interpretation₁ → PartialStructure → ℕ → ℕ → Set (lsuc ℓ)
  Congruent I X f g =
    PartialStructure.syn X f × PartialStructure.syn X g ×
    (∀ (F : Fragment) → ContainedIn F X →
      FragmentwiseEq (Interpretation₁.interp I f) (Interpretation₁.interp I g)
        (Fragment.mem F))

  -- Congruence is reflexive.
  cong-refl : ∀ (I : Interpretation₁) (X : PartialStructure) (f : ℕ)
            → PartialStructure.syn X f → Congruent I X f f
  cong-refl I X f hf = hf , hf , (λ _ _ _ → refl)

  -- Congruence is symmetric.
  cong-sym : ∀ (I : Interpretation₁) (X : PartialStructure) (f g : ℕ)
           → Congruent I X f g → Congruent I X g f
  cong-sym I X f g (hf , hg , eq) =
    hg , hf , (λ F hF ha → sym (eq F hF ha))

  -- Congruence is transitive.
  cong-trans : ∀ (I : Interpretation₁) (X : PartialStructure)
               (f g k : ℕ)
             → Congruent I X f g → Congruent I X g k
             → Congruent I X f k
  cong-trans I X f g k (hf , _ , efg) (_ , hk , egk) =
    hf , hk , (λ F hF ha → trans (efg F hF ha) (egk F hF ha))

  -- Habituality: j(a) = a.
  IsHabitual : H → Set ℓ
  IsHabitual a = j a ≡ a

  -- §5.3: Admissible behaviors.
  -- A semantic endofunction that respects all the structure
  -- that interpreted operators must respect.

  record AdmissibleBehavior : Set (lsuc ℓ) where
    field
      fn : H → H
      monotone      : ∀ a b → a ≤ b → fn a ≤ fn b
      modal-compat  : ∀ a → j (fn a) ≡ fn (j a)
      trace-compat  : ∀ a → G (fn a) ≡ fn (G a)
      frag-pres     : ∀ (F : Fragment) (a : H)
                     → Fragment.mem F a → Fragment.mem F (fn a)

  -- Admissible behaviors preserve habituality.
  admissible-preserves-habitual : ∀ (h : AdmissibleBehavior)
    (a : H) → IsHabitual a → IsHabitual (AdmissibleBehavior.fn h a)
  admissible-preserves-habitual h a ha =
    trans (AdmissibleBehavior.modal-compat h a)
          (cong (AdmissibleBehavior.fn h) ha)

  -- §6.1: Fusion closure operator.
  -- S_fus(X) = (H_X, Op_X^fus), leaving semantics unchanged
  -- and extending the operator set to include any operator
  -- whose interpretation is globally fragment-preserving.

  fusionClosure : Interpretation₁ → PartialStructure → PartialStructure
  fusionClosure I X = record
    { sem = PartialStructure.sem X
    ; syn = λ f → PartialStructure.syn X f ⊎
                   IsFragmentPreserving (Interpretation₁.interp I f)
    }

  -- Fusion is inflationary: X ≤ S_fus(X).
  fusion-inflationary : ∀ I (X : PartialStructure) → X ≤PS fusionClosure I X
  fusion-inflationary I X = record
    { sem-sub = λ _ h → h
    ; syn-sub = λ _ h → inj₁ h
    }

  -- Fusion is monotone: X ≤ Y → S_fus(X) ≤ S_fus(Y).
  fusion-monotone : ∀ I {X Y : PartialStructure} → X ≤PS Y
                  → fusionClosure I X ≤PS fusionClosure I Y
  fusion-monotone I {X} {Y} xy = record
    { sem-sub = _≤PS_.sem-sub xy
    ; syn-sub = helper
    }
    where
      helper : ∀ f → PartialStructure.syn X f ⊎
                      IsFragmentPreserving (Interpretation₁.interp I f)
             → PartialStructure.syn Y f ⊎
               IsFragmentPreserving (Interpretation₁.interp I f)
      helper f (inj₁ hf) = inj₁ (_≤PS_.syn-sub xy f hf)
      helper f (inj₂ hf) = inj₂ hf

  -- Fusion is idempotent: S_fus(S_fus(X)) ≤ S_fus(X).
  fusion-idempotent : ∀ I (X : PartialStructure)
                    → fusionClosure I (fusionClosure I X) ≤PS fusionClosure I X
  fusion-idempotent I X = record
    { sem-sub = λ _ h → h
    ; syn-sub = λ f h → helper f h
    }
    where
      helper : ∀ f → (PartialStructure.syn X f ⊎
                       IsFragmentPreserving (Interpretation₁.interp I f)) ⊎
                      IsFragmentPreserving (Interpretation₁.interp I f)
             → PartialStructure.syn X f ⊎
               IsFragmentPreserving (Interpretation₁.interp I f)
      helper f (inj₁ inner) = inner
      helper f (inj₂ fp)    = inj₂ fp

  -- §6.2: Fusion-saturated structures.
  -- A structure is fusion-saturated if it is a fixed point of S_fus.

  IsFusionSaturated : Interpretation₁ → PartialStructure → Set (lsuc ℓ)
  IsFusionSaturated I X = fusionClosure I X ≤PS X × X ≤PS fusionClosure I X

  -- The fusion closure of any structure is fusion-saturated.
  fusion-closure-saturated : ∀ I (X : PartialStructure)
    → IsFusionSaturated I (fusionClosure I X)
  fusion-closure-saturated I X =
    fusion-idempotent I X , fusion-inflationary I (fusionClosure I X)

  -- Lemma 6.3: Fusion reflection.
  -- S_fus(X) ≤ Y ↔ X ≤ Y, for Y fusion-saturated.
  -- (→) direction
  fusion-reflection-→ : ∀ I {X Y : PartialStructure}
    → fusionClosure I X ≤PS Y → X ≤PS Y
  fusion-reflection-→ I h = ≤PS-trans (fusion-inflationary I _) h

  -- (←) direction
  fusion-reflection-← : ∀ I {X Y : PartialStructure}
    → IsFusionSaturated I Y → X ≤PS Y → fusionClosure I X ≤PS Y
  fusion-reflection-← I satY xy = ≤PS-trans (fusion-monotone I xy) (proj₁ satY)
