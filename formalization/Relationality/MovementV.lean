/-
# Movement V — Emergent Containment

The relational field contains its own physics. States, evolution,
observation, and conservation are not imposed from outside — they
are READ from the structures already earned in Movements I–IV.

Key insight: we define nothing new here except READINGS. The
recognition field's elements are states. Flow is evolution.
Monotone functions are observables. Conservation follows from
algebraic properties already proved.

We do NOT import physics. "Spectral theory" and "operator algebras"
are the mathematical CORRESPONDENCES. Here we show that the
relational structures already contain what these formalisms describe.

Key claims to verify:
1. Flow-fixed states form a stable core (from Movement III idempotence)
2. Conserved observables preserve the stable core
3. The stable core is closed under lattice operations
4. The system is self-contained: verified by the type checker
-/

import Relationality.Basic
import Relationality.MovementII
import Relationality.MovementIII
import Mathlib.Order.Heyting.Basic

namespace Relationality.MovementV

variable {Rel : Type*} [HeytingAlgebra Rel]

/-!
## States

A state is an element of the recognition field. This is not a new
definition — it is the recognition that what Movement I called
"recognitions" CAN BE READ as states of a system. The element `a : Rel`
is simultaneously a recognition (Movement I), a stable form
(Movement II), a configuration under flow (Movement III), and a state
(Movement V).
-/

-- No new type needed. A state is a recognition is an element of Rel.

/-!
## Observables

An observable is a monotone function on the recognition field.
It extracts measurable content from a state. Observables are the
"instruments" of the relational field — they determine what can
be distinguished about a state.
-/

structure Observable (α : Type*) [Preorder α] where
  toFun : α → α
  monotone : ∀ a b, a ≤ b → toFun a ≤ toFun b

/-!
## Flow-Fixed States (The Stable Core)

A state is flow-fixed if flow does not change it. The image of
flow consists entirely of flow-fixed states — this follows from
flow idempotence (Movement III, Theorem `flow_idempotent`).

The stable core is the set of all flow-fixed states. It is where
the system has settled: further evolution produces no change.
-/

variable (flow : MovementIII.FlowOp Rel)

-- A state is flow-fixed if flow leaves it unchanged.
def IsFlowFixed (a : Rel) : Prop := flow.toFun a = a

-- The image of flow is flow-fixed: flow(a) is always a fixed point.
-- EARNED from flow idempotence (Movement III).
theorem flow_image_fixed (a : Rel) :
    IsFlowFixed flow (flow.toFun a) :=
  MovementIII.flow_idempotent flow a

-- Top (full recognition) and bottom (relationlessness) are flow-fixed
-- when flow preserves them. These are structural fixed points.
theorem top_fixed (h : flow.toFun (⊤ : Rel) = ⊤) : IsFlowFixed flow ⊤ := h
theorem bot_fixed (h : flow.toFun (⊥ : Rel) = ⊥) : IsFlowFixed flow ⊥ := h

/-!
## Conserved Observables

An observable is conserved under flow if measuring after flowing
gives the same result as flowing after measuring. This is the
commutation condition:

  `obs(flow(a)) = flow(obs(a))`

Conservation means there is no gap between observing-then-evolving
and evolving-then-observing. The measurement is transparent to dynamics.
-/

variable (obs : Observable Rel)

-- An observable is conserved if it commutes with flow.
def IsConserved : Prop :=
  ∀ a : Rel, obs.toFun (flow.toFun a) = flow.toFun (obs.toFun a)

-- A conserved observable preserves flow-fixed states:
-- if `a` is stable, then observing `a` yields a stable result.
-- This IS the conservation law in algebraic form.
theorem conserved_preserves_fixed
    (hcons : IsConserved flow obs)
    (a : Rel) (hfix : IsFlowFixed flow a) :
    IsFlowFixed flow (obs.toFun a) := by
  show flow.toFun (obs.toFun a) = obs.toFun a
  rw [← hcons a, hfix]

/-!
## Closure of the Stable Core

When flow distributes over ⊓, the stable core is closed under
Togethering: if two states are stable, their conjunction is stable.
This means the stable core inherits lattice structure from the
recognition field.
-/

-- Flow distributes over ⊓: combining then flowing = flowing then combining.
def FlowDistributesInf : Prop :=
  ∀ a b : Rel, flow.toFun (a ⊓ b) = flow.toFun a ⊓ flow.toFun b

-- The stable core is closed under ⊓.
theorem fixed_inf_closed
    (hdist : FlowDistributesInf flow)
    (a b : Rel) (ha : IsFlowFixed flow a) (hb : IsFlowFixed flow b) :
    IsFlowFixed flow (a ⊓ b) := by
  show flow.toFun (a ⊓ b) = a ⊓ b
  rw [hdist, ha, hb]

-- The stable core is closed under ⊔ when flow distributes over ⊔.
def FlowDistributesSup : Prop :=
  ∀ a b : Rel, flow.toFun (a ⊔ b) = flow.toFun a ⊔ flow.toFun b

theorem fixed_sup_closed
    (hdist : FlowDistributesSup flow)
    (a b : Rel) (ha : IsFlowFixed flow a) (hb : IsFlowFixed flow b) :
    IsFlowFixed flow (a ⊔ b) := by
  show flow.toFun (a ⊔ b) = a ⊔ b
  rw [hdist, ha, hb]

/-!
## Structural Observables

The identity and flow itself are observables. Both are trivially
conserved. These are the observables that "come for free" from
the relational structure.
-/

-- The identity observable: measures everything as-is.
def identityObs : Observable Rel where
  toFun := id
  monotone := fun _ _ h => h

-- The identity is always conserved under any flow.
theorem identity_conserved :
    IsConserved flow (identityObs (Rel := Rel)) := by
  intro a; rfl

-- Flow itself is an observable.
def flowObs : Observable Rel where
  toFun := flow.toFun
  monotone := fun a b h => flow.monotone a b h

-- Flow-as-observable is conserved: flow commutes with itself.
-- This follows from flow idempotence.
theorem flow_self_conserved :
    IsConserved flow (flowObs flow) := by
  intro a
  show flow.toFun (flow.toFun a) = flow.toFun (flow.toFun a)
  rfl

/-!
## Self-Containment

The relational field is self-contained. Every operation in the
formalization has type `Rel → Rel` or `Rel → Prop`:

- Togethering, Eithering, Inducing, Negating: `Rel → Rel → Rel`
- Closing, Opening: `Rel → Rel`
- Flow: `Rel → Rel`
- Observables: `Rel → Rel`
- Shape, Discrete, Codiscrete, Global: `Rel → Rel`

Nothing escapes the recognition field. The physics is not applied
to the algebra from outside — it is read from within.

This is verified by the type system: every theorem in Movements I–V
operates over a single `{Rel : Type*} [HeytingAlgebra Rel]`.
No external types, no imported physical constants, no coordinate
systems. The containment is structural and machine-checked.

The meta-boundary — the distinction between the relational field
and what lies beyond — is expressed by the type boundary itself.
`Rel` is all there is. What cannot be expressed as an element of
`Rel` or a function on `Rel` does not enter the formalization.
-/

end Relationality.MovementV
