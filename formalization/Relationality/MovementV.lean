/-
# Movement V — Emergent Containment

States, evolution, observation, and conservation as readings of the
structures from Movements I–IV. No new axioms are introduced. The
recognition field's elements are states. Flow is evolution. Monotone
endofunctions are observables. Conservation follows from commutation
with flow.

NOTE ON OBSERVABLES: The source (draft 12, Definition 15) defines
observables as morphisms ρ: a → Ω (to the subobject classifier),
measuring truth/presence. This formalization uses monotone
endofunctions α → α instead, which is a weaker notion. Formalizing
observables as morphisms to Ω requires the categorical machinery of
Movement I (subobject classifiers), which is not yet formalized.

NOTE ON MISSING CONTENT: Steps 2–3 (Transport/Continuity,
Relational Action/Symmetry) from the source are not formalized.
The stable envelope, transport equation, continuity equation,
Noether theorem, and variational principle are absent.

Source: draft 12, Movement V (Step 1 partial).
-/

import Relationality.Basic
import Relationality.MovementII
import Relationality.MovementIII

namespace Relationality.MovementV

noncomputable section

variable {Rel : Type*} [RecognitionField Rel]

/-!
## States

A state is an element of the recognition field. No new type.
-/

/-!
## Observables

A monotone endofunction on the recognition field. This is a weaker
notion than the source's morphisms to Ω. See header note.
-/

structure Observable (α : Type*) [Preorder α] where
  toFun : α → α
  monotone : ∀ a b, a ≤ b → toFun a ≤ toFun b

/-!
## Flow-Fixed States (The Stable Core)

A state is flow-fixed if flow does not change it: F(a) = a.
The image of flow consists entirely of flow-fixed states, which
follows from flow idempotence (Movement III).
-/

variable (flow : MovementIII.FlowOp Rel)

def IsFlowFixed (a : Rel) : Prop := flow.toFun a = a

-- The image of flow is flow-fixed. From flow idempotence.
theorem flow_image_fixed (a : Rel) :
    IsFlowFixed flow (flow.toFun a) :=
  MovementIII.flow_idempotent flow a

theorem top_fixed (h : flow.toFun (⊤ : Rel) = ⊤) : IsFlowFixed flow ⊤ := h
theorem bot_fixed (h : flow.toFun (⊥ : Rel) = ⊥) : IsFlowFixed flow ⊥ := h

/-!
## Conserved Observables

An observable is conserved under flow if it commutes with flow:
  obs(flow(a)) = flow(obs(a)).

A conserved observable preserves flow-fixed states: if a is stable,
then observing a yields a stable result.
-/

variable (obs : Observable Rel)

def IsConserved : Prop :=
  ∀ a : Rel, obs.toFun (flow.toFun a) = flow.toFun (obs.toFun a)

theorem conserved_preserves_fixed
    (hcons : IsConserved flow obs)
    (a : Rel) (hfix : IsFlowFixed flow a) :
    IsFlowFixed flow (obs.toFun a) := by
  show flow.toFun (obs.toFun a) = obs.toFun a
  rw [← hcons a, hfix]

/-!
## Closure of the Stable Core

When flow distributes over ⊓ (resp. ⊔), the stable core is closed
under togethering (resp. eithering).

FlowDistributesInf and FlowDistributesSup are stated as properties,
not derived from Flow's axioms.
-/

def FlowDistributesInf : Prop :=
  ∀ a b : Rel, flow.toFun (a ⊓ b) = flow.toFun a ⊓ flow.toFun b

theorem fixed_inf_closed
    (hdist : FlowDistributesInf flow)
    (a b : Rel) (ha : IsFlowFixed flow a) (hb : IsFlowFixed flow b) :
    IsFlowFixed flow (a ⊓ b) := by
  show flow.toFun (a ⊓ b) = a ⊓ b
  rw [hdist, ha, hb]

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

The identity and flow itself are observables. Both are conserved.
-/

def identityObs : Observable Rel where
  toFun := id
  monotone := fun _ _ h => h

theorem identity_conserved :
    IsConserved flow (identityObs (Rel := Rel)) := by
  intro a; rfl

def flowObs : Observable Rel where
  toFun := flow.toFun
  monotone := fun a b h => flow.monotone a b h

-- Flow commutes with itself (trivially).
theorem flow_self_conserved :
    IsConserved flow (flowObs flow) := by
  intro a
  show flow.toFun (flow.toFun a) = flow.toFun (flow.toFun a)
  rfl

/-!
## Self-Containment

Every operation in the formalization has type Rel → Rel or
Rel → Prop. Nothing escapes the recognition field. The sole
assumption throughout is [RecognitionField Rel], from which
all structure flows via Genesis.lean.

The type boundary of Rel expresses the meta-boundary: what
cannot be expressed as an element of Rel or a function on Rel
does not enter the formalization.
-/

end

end Relationality.MovementV
