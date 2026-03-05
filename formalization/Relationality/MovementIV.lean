/-
# Movement IV — Geometric Cohesion

The architecture for translating between local and global
perspectives within the recognition field.

The Heyting residuation from Movement I (a ⊓ b ≤ c ↔ a ≤ b ⇨ c)
is itself a Galois connection. The cohesive chain extends this
pattern to four operators connected by three adjunctions.

The cohesive chain uses the vocabulary from draft 12:
  Shape ⊣ Flat ⊣ Sharp ⊣ Crisp

  - Shape: extracts global form, discarding local detail
  - Flat: embeds as if parts were isolated
  - Sharp: embeds as if parts were maximally connected
  - Crisp: extracts what holds everywhere

Additional properties from the source (Beck–Chevalley conditions,
Frobenius laws for the chain, idempotence of Shape/Crisp, full
faithfulness of Flat/Sharp, flow commutation) are not formalized.
Steps 2–4 (Stratification, Ambidexterity, Directed Cohesion) are
not formalized.

Source: draft 12, Movement IV (Step 1 only).
-/

import Relationality.Basic
import Relationality.MovementII
import Mathlib.Order.GaloisConnection.Defs

namespace Relationality.MovementIV

noncomputable section

variable {Rel : Type*} [RecognitionField Rel]

/-!
## The Heyting Residuation as a Galois Connection

The residuation a ⊓ b ≤ c ↔ a ≤ b ⇨ c, which follows from
the RecognitionField axioms (via HeytingAlgebra), is a Galois
connection between (· ⊓ b) and (b ⇨ ·).
-/

theorem heyting_galois (b : Rel) :
    GaloisConnection (· ⊓ b) (b ⇨ ·) := by
  intro a c
  exact le_himp_iff.symm

/-!
## Closure Operators and Adjoint Structure

Closure gives unit (a ≤ close(a)) and counit (close(close(a)) =
close(a)). These are the same facts as Movement II, restated to
show they have the same form as adjunction units/counits.
-/

variable (close : ClosureOperator Rel)

theorem closure_unit (a : Rel) : a ≤ close a :=
  close.le_closure a

theorem closure_counit (a : Rel) : close (close a) = close a :=
  close.idempotent a

/-!
## The Cohesive Chain

Four operators connected by three Galois connections:
  Shape ⊣ Flat ⊣ Sharp ⊣ Crisp

The three adjunctions are axiomatized. Units, counits, and
absorption follow as consequences.

The source (draft 12, Definition 11) additionally requires:
  - Shape and Crisp are idempotent (projection-like)
  - Flat and Sharp are fully faithful (inclusion-like)
  - Beck–Chevalley and Frobenius laws
  - Flow commutation
These are not included in this structure.
-/

structure CohesiveChain (α : Type*) [Preorder α] where
  shape : α → α
  flat : α → α
  sharp : α → α
  crisp : α → α
  gc_sf : GaloisConnection shape flat
  gc_fs : GaloisConnection flat sharp
  gc_sc : GaloisConnection sharp crisp

variable (coh : CohesiveChain Rel)

/-!
## Units and Counits

Each Galois connection l ⊣ u produces:
  - unit: a ≤ u(l(a))
  - counit: l(u(a)) ≤ a
These are consequences of the adjunction.
-/

-- Shape ⊣ Flat
theorem shape_counit (a : Rel) :
    coh.shape (coh.flat a) ≤ a :=
  coh.gc_sf.l_u_le a

theorem flat_unit (a : Rel) :
    a ≤ coh.flat (coh.shape a) :=
  coh.gc_sf.le_u_l a

-- Flat ⊣ Sharp
theorem flat_counit (a : Rel) :
    coh.flat (coh.sharp a) ≤ a :=
  coh.gc_fs.l_u_le a

theorem sharp_unit (a : Rel) :
    a ≤ coh.sharp (coh.flat a) :=
  coh.gc_fs.le_u_l a

-- Sharp ⊣ Crisp
theorem sharp_counit (a : Rel) :
    coh.sharp (coh.crisp a) ≤ a :=
  coh.gc_sc.l_u_le a

theorem crisp_unit (a : Rel) :
    a ≤ coh.crisp (coh.sharp a) :=
  coh.gc_sc.le_u_l a

/-!
## Absorption Properties

Each Galois connection l ⊣ u satisfies:
  l(u(l(a))) = l(a)  and  u(l(u(a))) = u(a).
These follow from the adjunction.
-/

theorem shape_absorbs (a : Rel) :
    coh.shape (coh.flat (coh.shape a)) = coh.shape a :=
  le_antisymm
    (coh.gc_sf.l_u_le (coh.shape a))
    (coh.gc_sf.monotone_l (coh.gc_sf.le_u_l a))

theorem flat_absorbs_shape (a : Rel) :
    coh.flat (coh.shape (coh.flat a)) = coh.flat a :=
  le_antisymm
    (coh.gc_sf.monotone_u (coh.gc_sf.l_u_le a))
    (coh.gc_sf.le_u_l (coh.flat a))

theorem sharp_absorbs (a : Rel) :
    coh.sharp (coh.flat (coh.sharp a)) = coh.sharp a :=
  le_antisymm
    (coh.gc_fs.monotone_u (coh.gc_fs.l_u_le a))
    (coh.gc_fs.le_u_l (coh.sharp a))

theorem crisp_absorbs (a : Rel) :
    coh.crisp (coh.sharp (coh.crisp a)) = coh.crisp a :=
  le_antisymm
    (coh.gc_sc.monotone_u (coh.gc_sc.l_u_le a))
    (coh.gc_sc.le_u_l (coh.crisp a))

/-!
## Discreteness and Codiscreteness

A recognition is flat-discrete if flat(shape(a)) = a.
A recognition is crisp-discrete if crisp(sharp(a)) = a.
-/

def IsFlatDiscrete (a : Rel) : Prop :=
  coh.flat (coh.shape a) = a

def IsCrispDiscrete (a : Rel) : Prop :=
  coh.crisp (coh.sharp a) = a

theorem flat_discrete_of_image (a : Rel) :
    IsFlatDiscrete coh (coh.flat (coh.shape a)) := by
  show coh.flat (coh.shape (coh.flat (coh.shape a))) =
       coh.flat (coh.shape a)
  congr 1
  exact shape_absorbs coh a

/-!
## Full Cohesion

The composition through the entire chain:
  FullCohesion(a) = Crisp(Sharp(Flat(Shape(a))))

This is inflationary: a ≤ FullCohesion(a), from chaining units.
-/

def FullCohesion (a : Rel) : Rel :=
  coh.crisp (coh.sharp (coh.flat (coh.shape a)))

theorem full_cohesion_inflationary (a : Rel) :
    a ≤ FullCohesion coh a := by
  show a ≤ coh.crisp (coh.sharp (coh.flat (coh.shape a)))
  calc a
      ≤ coh.flat (coh.shape a) := coh.gc_sf.le_u_l a
    _ ≤ coh.crisp (coh.sharp (coh.flat (coh.shape a))) :=
        coh.gc_sc.le_u_l _

end

end Relationality.MovementIV
