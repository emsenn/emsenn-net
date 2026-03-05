/-
# Movement II — Structural Stabilization

Movement II earns persistence through closure and interior operators.

Key structures to formalize:
1. Closing: inflationary, idempotent, monotone (closure operator)
2. Opening: deflationary, idempotent, monotone (interior operator)
3. Balancing: Frobenius compatibility between closure and interior
4. Necessitating: what survives all closure (□)
5. Possibilizing: what is reachable by opening (◇)
6. Fixed points of Closing form a sub-Heyting algebra

The Frobenius law is the key claim of Movement II:
  Opening(a ∧ Closing(b)) = Opening(a) ∧ Closing(b)
This is NOT automatic — it is an additional condition that
closing and opening must satisfy for coherence.
-/

import Relationality.Basic
import Mathlib.Order.Heyting.Basic
import Mathlib.Order.Closure

namespace Relationality.MovementII

variable {Rel : Type*} [HeytingAlgebra Rel]

/-!
## Closure Operator (Closing)

A closure operator on the recognition field. In Mathlib,
`ClosureOperator` on a partial order gives us inflationary,
idempotent, monotone maps.

PRE: `Close(a) ≥ a`, `Close(Close(a)) = Close(a)`, monotone.
-/

variable (close : ClosureOperator Rel)

-- Closing is inflationary: `a ≤ close(a)`.
theorem closing_inflationary (a : Rel) :
    a ≤ close a :=
  close.le_closure a

-- Closing is idempotent: `close(close(a)) = close(a)`.
theorem closing_idempotent (a : Rel) :
    close (close a) = close a :=
  close.idempotent a

-- Closing is monotone: `a ≤ b → close(a) ≤ close(b)`.
theorem closing_monotone (a b : Rel) (h : a ≤ b) :
    close a ≤ close b :=
  close.monotone h

/-!
## Fixed Points (Closed Recognitions)

The fixed points of Closing — recognitions `a` where `close(a) = a` —
are the "closed recognitions." These are what PERSIST: further
application of closing does not change them.

In PRE: `Fix(Close)` = the reflexive locus.
In draft 12: `L_C` = the closed recognitions.
-/

-- A recognition is closed iff closing does not change it.
def IsClosed (a : Rel) : Prop := close a = a

-- Closing always produces a closed recognition.
theorem close_is_closed (a : Rel) : IsClosed close (close a) :=
  close.idempotent a

/-!
## Interior Operator (Opening)

Opening is the dual of Closing. Where Closing pushes outward to
stability, Opening looks inward. It is deflationary, idempotent,
monotone.

We define it as a structure with the dual properties.
-/

-- An interior operator: deflationary, idempotent, monotone.
structure InteriorOp (α : Type*) [PartialOrder α] where
  toFun : α → α
  deflationary : ∀ a, toFun a ≤ a
  idempotent : ∀ a, toFun (toFun a) = toFun a
  monotone : ∀ a b, a ≤ b → toFun a ≤ toFun b

variable (open_ : InteriorOp Rel)

-- Opening is deflationary: `open(a) ≤ a`.
theorem opening_deflationary (a : Rel) :
    open_.toFun a ≤ a :=
  open_.deflationary a

-- Opening is idempotent: `open(open(a)) = open(a)`.
theorem opening_idempotent (a : Rel) :
    open_.toFun (open_.toFun a) = open_.toFun a :=
  open_.idempotent a

/-!
## The Frobenius Law (Balancing)

PRE: `Opening(a ∧ Closing(b)) = Opening(a) ∧ Closing(b)`.

This is the KEY claim of Movement II. It says that inward
consolidation (closing) and outward release (opening) do not
conflict. What is closed inward coheres with what is opened outward.

This is NOT automatic in an arbitrary Heyting algebra with a
closure and interior. It is an additional condition — a REQUIREMENT
that the relational field must satisfy for coherence.
-/

-- The Frobenius compatibility condition between closure and interior.
-- This is the formal content of "Balancing" in the relational framework.
def FrobeniusCompatible
    (close : ClosureOperator Rel)
    (open_ : InteriorOp Rel) : Prop :=
  ∀ a b : Rel, open_.toFun (a ⊓ close b) = open_.toFun a ⊓ close b

/-!
## Modalities

Necessitating (□) = Closing applied objectwise.
Possibilizing (◇) = Opening applied objectwise.

NOTE: In the relational framework, Necessitating IS Closing (not its
dual). This means □a ≥ a (what must be includes what is). The standard
S4 axiom □a ≤ a corresponds to Opening (what is open is contained
in what is).
-/

-- Necessitating: what must be. `□a = close(a)`.
abbrev Necessary (a : Rel) : Rel := close a

-- Possibilizing: what may be. `◇a = open(a)`.
abbrev Possible (a : Rel) : Rel := open_.toFun a

-- What is necessary includes what is: `a ≤ □a`.
theorem necessary_inflationary (a : Rel) :
    a ≤ Necessary close a :=
  close.le_closure a

-- Necessity is idempotent: `□□a = □a`.
theorem necessary_idempotent (a : Rel) :
    Necessary close (Necessary close a) = Necessary close a :=
  close.idempotent a

-- What is possible is contained in what is: `◇a ≤ a`.
theorem possible_deflationary (a : Rel) :
    Possible open_ a ≤ a :=
  open_.deflationary a

-- Possibility is idempotent: `◇◇a = ◇a`.
theorem possible_idempotent (a : Rel) :
    Possible open_ (Possible open_ a) = Possible open_ a :=
  open_.idempotent a

end Relationality.MovementII
