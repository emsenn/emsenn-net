/-
# Movement III — Directed Dynamics

Flow is earned when the boundary between closed and open is itself
related. It is an operator on the SAME Heyting algebra, with properties
stated entirely in terms of ≤, ⊓, ⇨, and the closure/interior
operators from Movement II.

We do NOT import comonad theory. "KZ-lax idempotent comonad" is the
mathematical CORRESPONDENCE — what mathematicians would recognize
the structure as. Here we define Flow by its properties on the
recognition field and prove consequences.

Key claims to verify:
1. Flow is self-limiting: Flow(Flow(a)) ≤ Flow(a)
2. Flow preserves the modal core
3. Dynamic Residuation: Flow(a ∧ b) ≤ c ↔ a ≤ Flow(b ⇒ c)
4. Flow arithmetic: Add and Multiply with their interaction
-/

import Relationality.Basic
import Relationality.MovementII
import Mathlib.Order.Heyting.Basic
import Mathlib.Order.Closure

namespace Relationality.MovementIII

variable {Rel : Type*} [HeytingAlgebra Rel]

/-!
## Flow Operator

Flow is an operator on the recognition field earned from the
interplay of closing and opening. Its properties:

- **Monotone**: Flow preserves the ordering
- **Self-limiting**: Flow(Flow(a)) ≤ Flow(a) — motion contracts
  under repetition. This is the "KZ-lax" property.
- **Comultiplication**: Flow(a) ≤ Flow(Flow(a)) — flow decomposes
  into iterated flow.
- Together these give **idempotence**: Flow(Flow(a)) = Flow(a).
-/

structure FlowOp (α : Type*) [Preorder α] where
  toFun : α → α
  monotone : ∀ a b, a ≤ b → toFun a ≤ toFun b
  selfLimiting : ∀ a, toFun (toFun a) ≤ toFun a
  comult : ∀ a, toFun a ≤ toFun (toFun a)

variable (flow : FlowOp Rel)

-- Flow is idempotent: earned from self-limiting + comultiplication.
-- This is a CONSEQUENCE, not an axiom.
theorem flow_idempotent (a : Rel) :
    flow.toFun (flow.toFun a) = flow.toFun a :=
  le_antisymm (flow.selfLimiting a) (flow.comult a)

/-!
## Core Preservation

Flow preserves the modal core: what must be (what survives
closing) stays stable under motion.

`close(flow(a)) ≤ flow(close(a))`

Closing after flowing does not exceed flowing after closing.
If you flow first and then close, the result is no bigger than
if you close first and then flow. The modal core is stable
under dynamics.
-/

variable (close : ClosureOperator Rel)

-- PreservesCore: the key interaction between Flow and Close.
def PreservesCore
    (close : ClosureOperator Rel)
    (flow : FlowOp Rel) : Prop :=
  ∀ a : Rel, close (flow.toFun a) ≤ flow.toFun (close a)

-- When the core is preserved, flowing a closed element stays closed.
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

The extension of the residuation law to directed dynamics.

Static:  `a ⊓ b ≤ c ↔ a ≤ b ⇨ c`  (Movement I)
Dynamic: `flow(a ⊓ b) ≤ c ↔ a ≤ flow(b ⇨ c)`  (Movement III)

This says: acting-then-reasoning is equivalent to
reasoning-about-acting. There is no gap between theory and practice
when both are carried by Flow.

We state this as a property that Flow may or may not satisfy,
then derive consequences.
-/

def DynamicResiduation (flow : FlowOp Rel) : Prop :=
  ∀ a b c : Rel, flow.toFun (a ⊓ b) ≤ c ↔ a ≤ flow.toFun (b ⇨ c)

/-!
## Flow Arithmetic

When Dynamic Residuation holds, Flow interacts with ⊓ and ⇨
in structured ways. These operations describe how processes combine.

- `Add(a,b) = Flow(a ⊓ b)` — combining within a single flow
- `Multiply(a,b) = Flow(a) ⊓ Flow(b)` — flowing independently, then combining
-/

-- Adding: combination within directed motion.
def Add (a b : Rel) : Rel := flow.toFun (a ⊓ b)

-- Multiplying: independent motion, then combination.
def Multiply (a b : Rel) : Rel := flow.toFun a ⊓ flow.toFun b

-- Add(a,b) ≤ Multiply(a,b): simultaneous combination ≤ independent combination.
-- This follows from Flow being monotone and self-limiting.
theorem add_le_multiply (a b : Rel) :
    Add flow a b ≤ Multiply flow a b := by
  show flow.toFun (a ⊓ b) ≤ flow.toFun a ⊓ flow.toFun b
  exact le_inf (flow.monotone _ _ inf_le_left) (flow.monotone _ _ inf_le_right)

-- When Dynamic Residuation holds, the left adjoint of Add is the
-- flow-indexed implication: Flow(b ⇨ c).
theorem dynamic_residuation_adjoint
    (dyn : DynamicResiduation flow)
    (a b c : Rel) :
    Add flow a b ≤ c ↔ a ≤ flow.toFun (b ⇨ c) :=
  dyn a b c

/-!
## Stable Envelope

The bandwidth of stable variation: what persists under both
opening and closing when carried by flow.

`Envelope(a) = Necessary(Flow(a)) ⊓ Possible(Flow(a))`
           `= close(flow(a)) ⊓ open(flow(a))`

This is the range within which a state can vary under flow
while remaining measurably the same.
-/

variable (open_ : MovementII.InteriorOp Rel)

-- Stable Envelope: the range of stable variation under flow.
def StableEnvelope (a : Rel) : Rel :=
  close (flow.toFun a) ⊓ open_.toFun (flow.toFun a)

-- The envelope is contained in the closure of flow.
theorem envelope_le_necessary (a : Rel) :
    StableEnvelope flow close open_ a ≤ close (flow.toFun a) := by
  exact inf_le_left

-- The envelope contains the interior of flow.
-- (only when close(flow(a)) ≥ open(flow(a)), which is typical)
theorem envelope_ge_possible (a : Rel)
    (h : open_.toFun (flow.toFun a) ≤ close (flow.toFun a)) :
    open_.toFun (flow.toFun a) ≤ StableEnvelope flow close open_ a := by
  exact le_inf h (le_refl _)

end Relationality.MovementIII
