/-
# Syntax — Typed Lambda Calculus and Definable Operators

Corresponds to §2 of semiotic-universe.md.

The syntactic side of the semiotic universe is a simply typed
lambda calculus with:
  - a base type P (the type of meanings / propositions)
  - function types A → B
  - product types A × B

From this calculus, we extract the "definable operators":
closed terms of type P^n → P, quotiented by definitional
equality (βη). These are the grammar of the sign system —
the syntactic procedures by which meanings combine.

§2.1 defines the raw type/term language.
§2.2 defines the definable operator algebra.
-/

import SemioticUniverse.HeytingDomain

namespace SemioticUniverse

/-!
## §2.1 Types

The type language is generated from a base type P, closed under
function types and product types. This is the simply typed
lambda calculus (STLC) — see the typed-lambda-calculus curriculum.
-/

/-- Types of the semiotic calculus. -/
inductive Ty : Type where
  /-- The base type: meanings / propositions. -/
  | P : Ty
  /-- Function type. -/
  | arr : Ty → Ty → Ty
  /-- Product type. -/
  | prod : Ty → Ty → Ty
  deriving DecidableEq, Repr

infixr:25 " ⇒ " => Ty.arr
infixl:35 " ⊗ " => Ty.prod

/-!
## Contexts

A typing context is a list of types, representing the
variable-type assignments Γ = x₁ : A₁, x₂ : A₂, ...
-/

/-- A typing context: a list of type assignments. -/
abbrev Ctx := List Ty

/-!
## §2.1 Terms

Terms are indexed by their typing context and their type,
so that only well-typed terms are representable. This is the
"intrinsically typed" approach: ill-typed terms cannot be
constructed.

This encoding bakes the typing rules directly into the
inductive definition, so there is no separate typing judgment
to prove correct — type safety is by construction.
-/

set_option autoImplicit true in
/-- De Bruijn index: a variable reference within a context. -/
inductive Var : Ctx → Ty → Type where
  | zero : Var (A :: Γ) A
  | succ : Var Γ A → Var (B :: Γ) A

set_option autoImplicit true in
/-- Intrinsically typed terms of the semiotic calculus. -/
inductive Term : Ctx → Ty → Type where
  /-- Variable reference. -/
  | var : Var Γ A → Term Γ A
  /-- Lambda abstraction: λx.M -/
  | lam : Term (A :: Γ) B → Term Γ (A ⇒ B)
  /-- Application: M N -/
  | app : Term Γ (A ⇒ B) → Term Γ A → Term Γ B
  /-- Pairing: (M, N) -/
  | pair : Term Γ A → Term Γ B → Term Γ (A ⊗ B)
  /-- First projection: π₁(P) -/
  | fst : Term Γ (A ⊗ B) → Term Γ A
  /-- Second projection: π₂(P) -/
  | snd : Term Γ (A ⊗ B) → Term Γ B

/-!
## §2.1 Raw Operators

An n-ary operator is a closed term of type P^n → P.
We represent P^n as the n-fold product P ⊗ P ⊗ ... ⊗ P,
and "closed" as having the empty context [].

For n = 0, Op₀ is the set of closed terms of type P
(constants / nullary operators).
-/

/-- The n-fold product of the base type P. -/
def Ty.Pn : Nat → Ty
  | 0     => Ty.P
  | n + 1 => Ty.P ⊗ Ty.Pn n

/-- A raw operator of arity n: a closed term of type Pⁿ → P.
For n = 0, this is a closed term of type P (a constant). -/
def RawOp (n : Nat) : Type :=
  Term [] (Ty.Pn n ⇒ Ty.P)

/-- A nullary operator: a closed term of type P. -/
def Const : Type := Term [] Ty.P

/-!
## §2.2 Definable Operators

The definable operators Op^def are the smallest set containing:
  1. all primitive operator constants
  2. closed under λ-abstraction and application yielding P^n → P
  3. closed under composition at type P

For now, we represent the definable operator algebra abstractly
as a quotient by definitional equality. The quotient itself
requires βη-equivalence, which we define next.

Full βη-equivalence and the quotient construction are future
work — they require substitution calculus, which is substantial.
For now, we define the types and operators needed to state the
interpretation axioms of §4.
-/

/-- The set of definable operators (abstract for now).
This will be refined to a quotient of RawOp by βη-equivalence. -/
structure DefOp where
  /-- The arity of this operator. -/
  arity : Nat
  -- In the full development, this would carry the equivalence
  -- class of closed terms of type Pⁿ → P under βη.

/-!
## Worked examples

Concrete terms in the semiotic calculus, verifying that the
intrinsically typed encoding works as expected.
-/

/-- The identity function on P: λx. x -/
def idP : Term [] (Ty.P ⇒ Ty.P) :=
  Term.lam (Term.var Var.zero)

/-- The constant function: λx. λy. x -/
def constP : Term [] (Ty.P ⇒ Ty.P ⇒ Ty.P) :=
  Term.lam (Term.lam (Term.var (Var.succ Var.zero)))

/-- Pairing: λx. λy. (x, y) -/
def pairP : Term [] (Ty.P ⇒ Ty.P ⇒ Ty.P ⊗ Ty.P) :=
  Term.lam (Term.lam
    (Term.pair (Term.var (Var.succ Var.zero))
               (Term.var Var.zero)))

/-- First projection as a closed term: λp. π₁(p) -/
def fstP : Term [] (Ty.P ⊗ Ty.P ⇒ Ty.P) :=
  Term.lam (Term.fst (Term.var Var.zero))

/-- Second projection as a closed term: λp. π₂(p) -/
def sndP : Term [] (Ty.P ⊗ Ty.P ⇒ Ty.P) :=
  Term.lam (Term.snd (Term.var Var.zero))

/-- Composition: given f : P → P and g : P → P, build
λx. g (f x). This takes f and g as free variables. -/
def composeP : Term [Ty.P ⇒ Ty.P, Ty.P ⇒ Ty.P] (Ty.P ⇒ Ty.P) :=
  -- Context: g : P → P, f : P → P
  Term.lam  -- λx : P
    (Term.app
      (Term.var (Var.succ (Var.succ Var.zero)))  -- g
      (Term.app
        (Term.var (Var.succ Var.zero))            -- f
        (Term.var Var.zero)))                     -- x

/-- A nullary operator (constant): a closed term of type P.
This is the simplest possible "meaning" — a raw semantic value
with no dependencies. -/
example : Const = Term [] Ty.P := rfl

/-- A unary operator: a closed term of type P ⊗ P⁰ → P,
i.e., P ⊗ P → P. fstP is an example. -/
example : RawOp 1 = Term [] (Ty.P ⊗ Ty.P ⇒ Ty.P) := rfl

/-!
## Structural properties

The spec requires subject reduction, weakening, exchange, and
substitution. With intrinsically typed terms, these are
properties of the *substitution calculus*, not of a separate
type system. They will be proved when substitution is defined.

Strong normalization (every reduction sequence terminates)
follows from the STLC being strongly normalizing — this is
a standard result (Tait 1967, proved in e.g.
Pierce, Types and Programming Languages, Ch. 12).
-/

end SemioticUniverse
