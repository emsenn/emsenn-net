{-
  Interpretation — From Syntax to Semantics

  Corresponds to §4 of semiotic-universe.md.

  The interpretation mapping is semiosis formalized: syntactic
  operators acquire semantic content. For each definable operator
  f of arity n, we assign a semantic function ⟦f⟧ : Hⁿ → H
  satisfying seven coherence conditions.

  The key conditions for the semiotic universe:
    3. Modal homomorphism:  j(⟦f⟧(a⃗)) = ⟦f⟧(j(a⃗))
    4. Trace compatibility: G(⟦f⟧(a⃗)) = ⟦f⟧(G(a⃗))
    6. Fragment preservation: ⟦f⟧(Fⁿ) ⊆ F

  These ensure that the grammar (syntax) respects habit-formation
  (j), semiotic provenance (G), and local interpretive context
  (fragments).
-}

module SemioticUniverse.Interpretation where

open import Level using (Level; _⊔_) renaming (suc to lsuc)
open import Data.Nat using (ℕ; zero; suc)
open import Data.List using (List; []; _∷_; map)
open import Relation.Binary.PropositionalEquality
  using (_≡_; refl; cong; trans)

-- The interpretation is parameterized over the semantic domain
-- and its operators. This keeps it independent of whether H
-- was constructed synthetically or axiomatized.

module Interp
  {ℓ : Level}
  (H : Set ℓ)
  -- Heyting operations
  (_⊓_ _⊔_ _⇨_ : H → H → H)
  (⊤H ⊥H : H)
  -- Modal closure and trace
  (j G : H → H)
  -- Ordering
  (_≤_ : H → H → Set ℓ)
  where

  -- A semantic operator of arity n: a function from n-tuples
  -- of meanings to a meaning.
  SemanticOp : ℕ → Set ℓ
  SemanticOp zero    = H
  SemanticOp (suc n) = H → SemanticOp n

  -- For uniformity, we also define the list-based version.
  SemanticOpL : Set ℓ
  SemanticOpL = List H → H

  -- The interpretation structure.
  --
  -- We state the three most important conditions as fields.
  -- The full development would include all seven conditions
  -- from §4.1.

  record Interpretation : Set (lsuc ℓ) where
    field
      -- The interpretation function: definable operator →
      -- semantic function (represented as list-based for
      -- generality).
      ⟦_⟧ : ℕ → SemanticOpL
        -- In the full version, this would be indexed by DefOp
        -- rather than ℕ. We use ℕ as a placeholder for the
        -- operator identifier.

      -- Condition 3: Modal homomorphism.
      -- j(⟦f⟧(a⃗)) = ⟦f⟧(j(a⃗))
      --
      -- Habit-formation commutes with grammatical combination.
      modal-hom : ∀ (n : ℕ) (args : List H)
                → j (⟦ n ⟧ args) ≡ ⟦ n ⟧ (map j args)

      -- Condition 4: Trace compatibility.
      -- G(⟦f⟧(a⃗)) = ⟦f⟧(G(a⃗))
      --
      -- Semiotic provenance commutes with grammatical combination.
      trace-compat : ∀ (n : ℕ) (args : List H)
                   → G (⟦ n ⟧ args) ≡ ⟦ n ⟧ (map G args)

  -- Habituality: j(a) = a means a has settled into habit.
  IsHabitual : H → Set ℓ
  IsHabitual a = j a ≡ a

  -- All elements of a list are habitual.
  data AllHabitual : List H → Set ℓ where
    all-[]  : AllHabitual []
    all-∷   : ∀ {a as} → IsHabitual a → AllHabitual as → AllHabitual (a ∷ as)

  -- If each element is j-fixed, mapping j is identity.
  map-j-id : ∀ (args : List H) → AllHabitual args → map j args ≡ args
  map-j-id []       all-[]          = refl
  map-j-id (a ∷ as) (all-∷ ha has) =
    trans (cong (λ x → x ∷ map j as) ha)
          (cong (a ∷_) (map-j-id as has))

  -- Proposition 4.1: Interpreted operators preserve habituality.
  -- If all inputs are habitual, the output is habitual.
  module _ (I : Interpretation) where
    open Interpretation I

    prop-4-1 : ∀ (n : ℕ) (args : List H) → AllHabitual args
             → IsHabitual (⟦ n ⟧ args)
    prop-4-1 n args hall =
      trans (modal-hom n args)
            (cong ⟦ n ⟧ (map-j-id args hall))
