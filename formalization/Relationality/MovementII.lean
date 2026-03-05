/-
# Movement II — Structural Stabilization

Closure and interior operators on the recognition field, and the
Frobenius compatibility condition between them.

Closure (inflationary, idempotent, monotone) secures form.
Interior (deflationary, idempotent, monotone) preserves openness.
The Frobenius law requires their compatibility:
  interior(a ⊓ closure(b)) = interior(a) ⊓ closure(b).

Mathlib provides ClosureOperator. InteriorOp is defined here as
the dual structure. FrobeniusCompatible is stated as a property
that a closure-interior pair may satisfy. The source material
(draft 12, Movement II, Lemma 9) derives the Frobenius law from
the adjoint triple O ⊣ I ⊣ C. That derivation is not formalized
here; FrobeniusCompatible is an axiom on the pair, not a theorem.

Source: draft 12, Movement II (Steps 1–4).

NOTE: Steps 3–4 (Higher Stabilization, transfinite iteration)
are not formalized.
-/

import Relationality.Basic
import Mathlib.Order.Closure

namespace Relationality.MovementII

noncomputable section

variable {Rel : Type*} [RecognitionField Rel]

/-!
## Closure Operator (Closing)

Mathlib's ClosureOperator provides inflationary, idempotent,
monotone maps on a partial order.
-/

variable (close : ClosureOperator Rel)

theorem closing_inflationary (a : Rel) :
    a ≤ close a :=
  close.le_closure a

theorem closing_idempotent (a : Rel) :
    close (close a) = close a :=
  close.idempotent a

theorem closing_monotone (a b : Rel) (h : a ≤ b) :
    close a ≤ close b :=
  close.monotone h

/-!
## Fixed Points (Closed Recognitions)

A recognition is closed if closure does not change it.
The fixed points of closure form the set of stable recognitions.
-/

def IsClosed (a : Rel) : Prop := close a = a

theorem close_is_closed (a : Rel) : IsClosed close (close a) :=
  close.idempotent a

/-!
## Interior Operator (Opening)

The dual of closure. Deflationary, idempotent, monotone.
Mathlib does not provide a dedicated interior operator type,
so it is defined here.
-/

structure InteriorOp (α : Type*) [PartialOrder α] where
  toFun : α → α
  deflationary : ∀ a, toFun a ≤ a
  idempotent : ∀ a, toFun (toFun a) = toFun a
  monotone : ∀ a b, a ≤ b → toFun a ≤ toFun b

variable (open_ : InteriorOp Rel)

theorem opening_deflationary (a : Rel) :
    open_.toFun a ≤ a :=
  open_.deflationary a

theorem opening_idempotent (a : Rel) :
    open_.toFun (open_.toFun a) = open_.toFun a :=
  open_.idempotent a

/-!
## The Frobenius Law (Balancing)

interior(a ⊓ closure(b)) = interior(a) ⊓ closure(b).

This is the compatibility condition between closure and interior.
The source material (draft 12, Lemma 9) derives it from the
adjoint triple O ⊣ I ⊣ C. Here it is stated as a property that
a closure-interior pair may or may not satisfy. Formalizing the
derivation from the adjoint triple is future work.
-/

def FrobeniusCompatible
    (close : ClosureOperator Rel)
    (open_ : InteriorOp Rel) : Prop :=
  ∀ a b : Rel, open_.toFun (a ⊓ close b) = open_.toFun a ⊓ close b

/-!
## Modalities

Necessitating (□) = closure. What must be.
Possibilizing (◇) = interior. What may be.

In this framework, □a ≥ a (what must be includes what is) because
closure is inflationary. ◇a ≤ a (what may be is contained in what
is) because interior is deflationary.
-/

abbrev Necessary (a : Rel) : Rel := close a

abbrev Possible (a : Rel) : Rel := open_.toFun a

theorem necessary_inflationary (a : Rel) :
    a ≤ Necessary close a :=
  close.le_closure a

theorem necessary_idempotent (a : Rel) :
    Necessary close (Necessary close a) = Necessary close a :=
  close.idempotent a

theorem possible_deflationary (a : Rel) :
    Possible open_ a ≤ a :=
  open_.deflationary a

theorem possible_idempotent (a : Rel) :
    Possible open_ (Possible open_ a) = Possible open_ a :=
  open_.idempotent a

end

end Relationality.MovementII
