/-
# Movement III — Directed Dynamics

Flow arises when the boundary between closed and open is itself
related. It is a monotone, inflationary, self-limiting operator
on the recognition field.

Draft 12 defines Flow with three properties:
  1. Monotone: a ≤ b → F(a) ≤ F(b)
  2. Inflationary: a ≤ F(a)
  3. Self-limiting: F(F(a)) ≤ F(a)

From (2) and (1), comultiplication F(a) ≤ F(F(a)) follows.
From (3) and comultiplication, idempotence F(F(a)) = F(a) follows.

Draft 12 identifies this as a lax-idempotent monad internal to
the recognition field's partial order. (Earlier drafts use
comonadic language; the formal content is the same.)

NOTE ON DYNAMIC RESIDUATION: Draft 12 defines a custom operator
Induce_F(a,b) = max{x | F(a ∧ x) ≤ F(b)} and proves the Galois
connection F(a ∧ b) ≤ F(c) ↔ b ≤ Induce_F(a,c). Draft 10 gives
a simpler formulation: F(a ∧ b) ≤ c ↔ a ≤ F(b ⇨ c). These are
different statements. The formalization below uses draft 10's
version; the relationship between the two is an open question
in the derivation.
-/

import Relationality.Basic
import Relationality.MovementII
import Mathlib.Order.Closure

namespace Relationality.MovementIII

noncomputable section

variable {Rel : Type*} [RecognitionField Rel]

/-!
## Flow Operator

Flow is a monotone, inflationary, self-limiting operator on the
recognition field.

- Monotone: preserves the ordering.
- Inflationary: a ≤ F(a). Flow expands — every recognition is
  contained in its flow.
- Self-limiting: F(F(a)) ≤ F(a). Repeated flow contracts.
  Motion settles.

Comultiplication F(a) ≤ F(F(a)) is derived from inflation and
monotonicity: a ≤ F(a) implies F(a) ≤ F(F(a)). Idempotence
F(F(a)) = F(a) then follows from self-limiting + comultiplication.
-/

structure FlowOp (α : Type*) [Preorder α] where
  toFun : α → α
  monotone : ∀ a b, a ≤ b → toFun a ≤ toFun b
  inflationary : ∀ a, a ≤ toFun a
  selfLimiting : ∀ a, toFun (toFun a) ≤ toFun a

variable (flow : FlowOp Rel)

-- Comultiplication: derived from inflation + monotonicity.
-- a ≤ F(a) implies F(a) ≤ F(F(a)) by monotonicity.
theorem flow_comult (a : Rel) :
    flow.toFun a ≤ flow.toFun (flow.toFun a) :=
  flow.monotone _ _ (flow.inflationary a)

-- Idempotence: F(F(a)) = F(a). From self-limiting + comultiplication.
theorem flow_idempotent (a : Rel) :
    flow.toFun (flow.toFun a) = flow.toFun a :=
  le_antisymm (flow.selfLimiting a) (flow_comult flow a)

-- Kock-Zoberlein condition: F(a) ≤ F(b) ↔ a ≤ F(b).
-- The forward direction uses inflation; the reverse uses monotonicity.
-- This characterizes F as a KZ-lax idempotent monad.
theorem kock_zoberlein (a b : Rel) :
    flow.toFun a ≤ flow.toFun b ↔ a ≤ flow.toFun b := by
  constructor
  · intro h
    exact le_trans (flow.inflationary a) h
  · intro h
    calc flow.toFun a
        ≤ flow.toFun (flow.toFun b) := flow.monotone _ _ h
      _ = flow.toFun b := flow_idempotent flow b

/-!
## Core Preservation

Flow preserves the modal core: closing after flowing does not
exceed flowing after closing.

  close(flow(a)) ≤ flow(close(a))

When this holds, flowing a closed element produces a result
whose closure is bounded by the flow of that element.
-/

variable (close : ClosureOperator Rel)

def PreservesCore
    (close : ClosureOperator Rel)
    (flow : FlowOp Rel) : Prop :=
  ∀ a : Rel, close (flow.toFun a) ≤ flow.toFun (close a)

theorem flow_closed_is_bounded
    (pres : PreservesCore close flow)
    (a : Rel)
    (ha : close a = a) :
    close (flow.toFun a) ≤ flow.toFun a := by
  calc close (flow.toFun a)
      ≤ flow.toFun (close a) := pres a
    _ = flow.toFun a := by rw [ha]

/-!
## Dynamic Residuation

The extension of the static residuation to directed dynamics.

Static (Movement I):   a ⊓ b ≤ c  ↔  a ≤ b ⇨ c
Dynamic (Movement III): F(a ⊓ b) ≤ c  ↔  a ≤ F(b ⇨ c)

This is draft 10's formulation. Draft 12 uses a different
version with a custom Induce_F operator and F wrapping c on
the left side: F(a ∧ b) ≤ F(c) ↔ b ≤ Induce_F(a,c). The
relationship between these formulations is not yet resolved
in the derivation.

Stated as a property that a given Flow may or may not satisfy.
-/

def DynamicResiduation (flow : FlowOp Rel) : Prop :=
  ∀ a b c : Rel, flow.toFun (a ⊓ b) ≤ c ↔ a ≤ flow.toFun (b ⇨ c)

/-!
## Flow Arithmetic

Adding and Multiplying describe how processes combine under flow.

- Adding(a,b) = F(a ⊓ b): combining within a single flow.
- Multiplying(a,b) = F(a) ⊓ F(b): flowing independently, then combining.

Adding ≤ Multiplying: simultaneous combination never exceeds
independent combination. This follows from monotonicity alone.
-/

def Add (a b : Rel) : Rel := flow.toFun (a ⊓ b)

def Multiply (a b : Rel) : Rel := flow.toFun a ⊓ flow.toFun b

theorem add_le_multiply (a b : Rel) :
    Add flow a b ≤ Multiply flow a b := by
  show flow.toFun (a ⊓ b) ≤ flow.toFun a ⊓ flow.toFun b
  exact le_inf (flow.monotone _ _ inf_le_left) (flow.monotone _ _ inf_le_right)

theorem dynamic_residuation_adjoint
    (dyn : DynamicResiduation flow)
    (a b c : Rel) :
    Add flow a b ≤ c ↔ a ≤ flow.toFun (b ⇨ c) :=
  dyn a b c

/-!
## Stable Envelope

The meet of the necessary and possible aspects of a flowed
recognition:

  Envelope(a) = close(flow(a)) ⊓ open(flow(a))

This is the range within which a recognition can vary under
flow while remaining stable under both closing and opening.
-/

variable (open_ : MovementII.InteriorOp Rel)

def StableEnvelope (a : Rel) : Rel :=
  close (flow.toFun a) ⊓ open_.toFun (flow.toFun a)

theorem envelope_le_necessary (a : Rel) :
    StableEnvelope flow close open_ a ≤ close (flow.toFun a) := by
  exact inf_le_left

theorem envelope_ge_possible (a : Rel)
    (h : open_.toFun (flow.toFun a) ≤ close (flow.toFun a)) :
    open_.toFun (flow.toFun a) ≤ StableEnvelope flow close open_ a := by
  exact le_inf h (le_refl _)

end

end Relationality.MovementIII
