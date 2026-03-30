{-
  Fragment — Finitely Generated Modal-Temporal Subalgebras

  Corresponds to §3 of semiotic-universe.md.

  Interpretation is always local. A fragment is a finitely
  generated modal-temporal subalgebra of H — a bounded
  interpretive context closed under all the sign system's
  operations.

  §3.1: Modal-temporal subalgebras and fragments
  §3.2: Restriction of operators to fragments
  §3.3: Fragmentwise equality and hereditary extensionality
-}

module SemioticUniverse.Fragment where

open import Level using (Level; _⊔_) renaming (suc to lsuc)
open import Data.Nat using (ℕ; zero; suc)
open import Data.List using (List; []; _∷_; length)
open import Data.Product using (_×_; _,_)
open import Relation.Binary.PropositionalEquality
  using (_≡_; refl)

-- We parameterize over an abstract Heyting domain with
-- modal closure and trace, since the Fragment concept is
-- independent of whether H was constructed synthetically
-- (from a topos) or axiomatized.

module Fragments
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

  -- List membership
  data _∈L_ {A : Set ℓ} : A → List A → Set ℓ where
    here  : ∀ {x xs} → x ∈L (x ∷ xs)
    there : ∀ {x y xs} → x ∈L xs → x ∈L (y ∷ xs)

  -- §3.1: A modal-temporal subalgebra is a predicate on H
  -- closed under all operations.

  record IsSubalgebra (F : H → Set ℓ) : Set (lsuc ℓ) where
    field
      ⊓-closed   : ∀ {a b} → F a → F b → F (a ⊓ b)
      ⊔-closed   : ∀ {a b} → F a → F b → F (a ⊔ b)
      ⇨-closed   : ∀ {a b} → F a → F b → F (a ⇨ b)
      ⊤-member   : F ⊤H
      ⊥-member   : F ⊥H
      j-closed   : ∀ {a} → F a → F (j a)
      G-closed   : ∀ {a} → F a → F (G a)

  -- §3.1: A fragment is a finitely generated subalgebra.
  -- We represent the generating set as a list.

  record Fragment : Set (lsuc ℓ) where
    field
      mem          : H → Set ℓ
      isSubalgebra : IsSubalgebra mem
      generators   : List H
      gen-mem      : ∀ {a} → a ∈L generators → mem a
      minimal      : ∀ (F' : H → Set ℓ) → IsSubalgebra F'
                   → (∀ {a} → a ∈L generators → F' a)
                   → ∀ {a} → mem a → F' a
  -- §3.2: Fragment preservation

  -- An operator preserves a specific fragment.
  PreservesFragment : (H → H) → (H → Set ℓ) → Set ℓ
  PreservesFragment f F = ∀ {a} → F a → F (f a)

  -- An operator is fragment-preserving (globally).
  IsFragmentPreserving : (H → H) → Set (lsuc ℓ)
  IsFragmentPreserving f = ∀ (frag : Fragment) →
    PreservesFragment f (Fragment.mem frag)

  -- §3.3: Fragmentwise equality

  -- Two operators agree on a fragment.
  FragmentwiseEq : (H → H) → (H → H) → (H → Set ℓ) → Set ℓ
  FragmentwiseEq f g F = ∀ {a} → F a → f a ≡ g a

  -- §3.3: Hereditary extensionality
  --
  -- If two operators agree on a fragment F, they agree on
  -- every fragment reachable from F by the sign system's
  -- operations. This captures that local agreement propagates
  -- through semiosis.

  IsHereditarilyExtensional : List (H → H) → Set (lsuc ℓ)
  IsHereditarilyExtensional ops =
    ∀ {f g} → f ∈L ops → g ∈L ops →
    ∀ (frag : Fragment) → FragmentwiseEq f g (Fragment.mem frag) →
    ∀ (frag' : Fragment) →
      -- F ⊆ F' (simplified reachability condition)
      (∀ {a} → Fragment.mem frag a → Fragment.mem frag' a) →
      FragmentwiseEq f g (Fragment.mem frag')
