{-
  Syntax — Typed Lambda Calculus and Definable Operators

  Corresponds to §2 of semiotic-universe.md.

  The syntactic side of the semiotic universe is a simply typed
  lambda calculus (STLC) with base type P, function types, and
  product types. We use intrinsically typed terms — the type
  system is baked into the term definition, so only well-typed
  terms exist.

  This module defines:
    - Ty:   the type language (§2.1)
    - Ctx:  typing contexts
    - Term: intrinsically typed terms (§2.1)
    - RawOp: operators as closed terms of type Pⁿ → P (§2.1)

  The universe level ℓ does not appear here — the syntax is
  pure structure, independent of the semantic domain. The
  connection between syntax and semantics happens in the
  interpretation module (§4).
-}

module SemioticUniverse.Syntax where

open import Data.Nat using (ℕ; zero; suc)
open import Data.List using (List; []; _∷_)
open import Relation.Binary.PropositionalEquality using (_≡_; refl)

-- §2.1: Types
--
-- Generated from:
--   P       base type (meanings / propositions)
--   A ⇒ B   function type
--   A ⊗ B   product type

data Ty : Set where
  P   : Ty
  _⇒_ : Ty → Ty → Ty
  _⊗_ : Ty → Ty → Ty

infixr 25 _⇒_
infixl 35 _⊗_

-- Contexts: lists of types.

Ctx : Set
Ctx = List Ty

-- De Bruijn indices: well-scoped variable references.

data _∈_ : Ty → Ctx → Set where
  here  : ∀ {A Γ} → A ∈ (A ∷ Γ)
  there : ∀ {A B Γ} → A ∈ Γ → A ∈ (B ∷ Γ)

-- §2.1: Intrinsically typed terms.
--
-- Each constructor corresponds to a typing rule. Only
-- well-typed terms are representable — ill-typed terms
-- cannot be constructed. This is the key advantage of
-- dependent types for syntax: type safety is definitional.

data Term : Ctx → Ty → Set where
  -- Variable reference
  var : ∀ {Γ A} → A ∈ Γ → Term Γ A

  -- Lambda abstraction: Γ, x:A ⊢ M : B  →  Γ ⊢ λx.M : A ⇒ B
  lam : ∀ {Γ A B} → Term (A ∷ Γ) B → Term Γ (A ⇒ B)

  -- Application: Γ ⊢ M : A ⇒ B  →  Γ ⊢ N : A  →  Γ ⊢ M N : B
  app : ∀ {Γ A B} → Term Γ (A ⇒ B) → Term Γ A → Term Γ B

  -- Pairing: Γ ⊢ M : A  →  Γ ⊢ N : B  →  Γ ⊢ (M,N) : A ⊗ B
  pair : ∀ {Γ A B} → Term Γ A → Term Γ B → Term Γ (A ⊗ B)

  -- First projection: Γ ⊢ P : A ⊗ B  →  Γ ⊢ π₁(P) : A
  fst : ∀ {Γ A B} → Term Γ (A ⊗ B) → Term Γ A

  -- Second projection: Γ ⊢ P : A ⊗ B  →  Γ ⊢ π₂(P) : B
  snd : ∀ {Γ A B} → Term Γ (A ⊗ B) → Term Γ B

-- §2.1: The n-fold product of the base type.
-- P⁰ = P, Pⁿ⁺¹ = P ⊗ Pⁿ

Pⁿ : ℕ → Ty
Pⁿ zero    = P
Pⁿ (suc n) = P ⊗ Pⁿ n

-- A raw operator of arity n: a closed term of type Pⁿ ⇒ P.
RawOp : ℕ → Set
RawOp n = Term [] (Pⁿ n ⇒ P)

-- A constant (nullary operator): a closed term of type P.
Const : Set
Const = Term [] P

-- §2.2: Definable Operators
--
-- The full definition requires βη-equivalence and the quotient
-- Op_n / ≡. In Agda, quotient types can be handled via setoids
-- or Cubical Agda's quotient types. For now we define the raw
-- operator types; the quotient construction is future work.
--
-- The key property is that Op^def is an algebra:
--   - contains all primitive operator constants
--   - closed under λ-definability (abstraction + application)
--   - closed under composition at type P
