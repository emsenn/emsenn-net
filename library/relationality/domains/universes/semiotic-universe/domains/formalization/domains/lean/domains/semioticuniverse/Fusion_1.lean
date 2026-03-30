/-
# Fusion — Congruence, Naming, and Reflection

Corresponds to §5–6 of semiotic-universe.md.

Fusion enforces coherence between syntax and semantics by:
  - quotienting syntactic operators by fragmentwise semantic equality,
  - adding new operators that name already-available semantic behaviors.

A sign system in which every available semantic behavior has a
syntactic name, and every syntactically identical pair agrees
semantically everywhere, is one in which what can be said and
what can be meant are in complete correspondence.

§5.1 defines partial semiotic structures (pairs (H_X, Op_X)).
§5.2 defines fragmentwise congruence (~_X).
§5.3 defines naming of existing behaviors (fusion-generated operators).
§6.1 defines the fusion closure operator S_fus.
§6.2 proves fusion is a reflector (left adjoint to inclusion).
-/

import SemioticUniverse.Interpretation

namespace SemioticUniverse

variable {H : Type*} [SemioticAmbient H]

/-!
## §5.1 Partial Semiotic Structures

A partial semiotic structure is a pair (H_X, Op_X) of a subset of
semantic objects and a set of syntactic operators. These form a
complete lattice U = P(H) × P(Op^def), ordered by inclusion.
-/

/-- A partial semiotic structure: a subset of H and a set of operators.
(Definition 5.1) -/
structure PartialStructure where
  /-- The semantic component: which elements of H are in scope. -/
  sem : H → Prop
  /-- The syntactic component: which operators are in scope. -/
  syn : DefOp → Prop

/-- Ordering on partial structures: inclusion in both components. -/
instance : LE (PartialStructure (H := H)) where
  le X Y := (∀ a, X.sem a → Y.sem a) ∧ (∀ f, X.syn f → Y.syn f)

omit [SemioticAmbient H] in
/-- Reflexivity of ≤ on partial structures. -/
theorem PartialStructure.le_refl (X : PartialStructure (H := H)) :
    X ≤ X :=
  ⟨fun _ h => h, fun _ h => h⟩

omit [SemioticAmbient H] in
/-- Transitivity of ≤ on partial structures. -/
theorem PartialStructure.le_trans {X Y Z : PartialStructure (H := H)}
    (hXY : X ≤ Y) (hYZ : Y ≤ Z) : X ≤ Z :=
  ⟨fun a ha => hYZ.1 a (hXY.1 a ha), fun f hf => hYZ.2 f (hXY.2 f hf)⟩

/-!
## §5.2 Fragmentwise Congruence

Two operators f, g in Op_X are congruent (~_X) if they agree on
every fragment F contained in H_X. This uses the fragmentwise
equality from §3.3.
-/

/-- A fragment is contained in a partial structure if all its
members are in the semantic component. -/
def Fragment.containedIn (F : Fragment (H := H))
    (X : PartialStructure (H := H)) : Prop :=
  ∀ a, F.mem a → X.sem a

/-- Fragmentwise congruence for unary operators: f ~_X g iff
for every fragment F ⊆ H_X, ⟦f⟧ ≡_F ⟦g⟧.
(Definition 5.1, restricted to unary case) -/
def Congruent [Interpretation₁ H] (X : PartialStructure (H := H))
    (f g : DefOp) : Prop :=
  X.syn f ∧ X.syn g ∧
  ∀ (F : Fragment (H := H)), F.containedIn X →
    FragmentwiseEq (Interpretation₁.interp₁ f) (Interpretation₁.interp₁ g) F

/-- Congruence is reflexive. -/
theorem Congruent.refl [Interpretation₁ H] {X : PartialStructure (H := H)}
    {f : DefOp} (hf : X.syn f) : Congruent X f f :=
  ⟨hf, hf, fun _ _ _ _ => rfl⟩

/-- Congruence is symmetric. -/
theorem Congruent.symm [Interpretation₁ H] {X : PartialStructure (H := H)}
    {f g : DefOp} (h : Congruent X f g) : Congruent X g f :=
  ⟨h.2.1, h.1, fun F hF a ha => (h.2.2 F hF a ha).symm⟩

/-- Congruence is transitive. -/
theorem Congruent.trans [Interpretation₁ H] {X : PartialStructure (H := H)}
    {f g k : DefOp} (hfg : Congruent X f g) (hgk : Congruent X g k) :
    Congruent X f k :=
  ⟨hfg.1, hgk.2.1, fun F hF a ha =>
    (hfg.2.2 F hF a ha).trans (hgk.2.2 F hF a ha)⟩

/-!
## §5.3 Admissible Behaviors and Naming

An admissible behavior is a semantic function h : H → H that is
monotone, fragment-preserving, modal-compatible, and
trace-compatible. These are the behaviors that "deserve a name"
in the syntactic algebra.
-/

/-- An admissible behavior: a semantic endofunction satisfying
all the interpretation coherence conditions. (§5.3)

These are the functions that could be the interpretation of some
operator — they respect all the structure that interpretations
must respect. -/
structure AdmissibleBehavior where
  /-- The semantic function. -/
  fn : H → H
  /-- Monotone. -/
  monotone : ∀ (a b : H), a ≤ b → fn a ≤ fn b
  /-- Modal compatible: j(h(a)) = h(j(a)). -/
  modal_compat : ∀ (a : H),
    ModalClosure.j (fn a) = fn (ModalClosure.j a)
  /-- Trace compatible: G(h(a)) = h(G(a)). -/
  trace_compat : ∀ (a : H),
    TraceComonad.G (fn a) = fn (TraceComonad.G a)
  /-- Fragment-preserving. -/
  fragment_pres : ∀ (F : Fragment (H := H)) (a : H),
    F.mem a → F.mem (fn a)

/-- An admissible behavior preserves habituality.
This follows from modal compatibility, just as for
interpreted operators (Proposition 4.1). -/
theorem AdmissibleBehavior.preserves_habitual
    (h : AdmissibleBehavior (H := H)) {a : H}
    (ha : IsHabitual a) : IsHabitual (h.fn a) := by
  unfold IsHabitual at *
  rw [h.modal_compat, ha]

/-!
## §6.1 Fusion Closure Operator

S_fus(X) = (H_X, Op_X^fus), leaving the semantic component
unchanged and saturating the operator set under:
  1. inclusion of existing operators
  2. identification of congruent operators
  3. naming of admissible behaviors

Since we work with DefOp abstractly (not yet a quotient), we
model the fusion closure as extending the syntactic component
to include any DefOp whose interpretation is an admissible
behavior reachable from the existing operators.
-/

/-- The fusion closure of a partial structure.
Leaves the semantic part unchanged and extends the syntactic
part to include all operators whose interpretations are
admissible behaviors. (Definition 5.2, §6.1)

In the full development, this would also quotient by ~_X.
For now, we extend the operator set to include any operator
whose interpretation is globally fragment-preserving (an
admissible behavior). -/
def fusionClosure [Interpretation₁ H]
    (X : PartialStructure (H := H)) : PartialStructure (H := H) where
  sem := X.sem
  syn := fun f =>
    X.syn f ∨
    -- f is admissible: its interpretation is globally fragment-preserving
    IsFragmentPreserving (Interpretation₁.interp₁ f : H → H)

/-!
### Lemma 6.1: Inflationary and monotone
-/

/-- Fusion is inflationary: X ≤ S_fus(X). -/
theorem fusionClosure_inflationary [Interpretation₁ H]
    (X : PartialStructure (H := H)) :
    X ≤ fusionClosure X :=
  ⟨fun _ h => h, fun _ h => Or.inl h⟩

/-- Fusion is monotone: X ≤ Y → S_fus(X) ≤ S_fus(Y). -/
theorem fusionClosure_monotone [Interpretation₁ H]
    {X Y : PartialStructure (H := H)} (hXY : X ≤ Y) :
    fusionClosure X ≤ fusionClosure Y :=
  ⟨hXY.1,
   fun f hf => hf.elim
    (fun h => Or.inl (hXY.2 f h))
    (fun h => Or.inr h)⟩

/-!
### Lemma 6.2: Idempotence of fusion
-/

/-- Fusion is idempotent: S_fus(S_fus(X)) = S_fus(X).
Since the semantic component is unchanged and the syntactic
component is already saturated after one application, a second
application adds nothing new. -/
theorem fusionClosure_idempotent [Interpretation₁ H]
    (X : PartialStructure (H := H)) :
    fusionClosure (fusionClosure X) ≤ fusionClosure X := by
  constructor
  · -- Semantic component: identical
    intro a h; exact h
  · -- Syntactic component: already saturated
    intro f hf
    cases hf with
    | inl h => exact h
    | inr h =>
      -- f's interpretation preserves fragments contained in S_fus(X).
      -- Since sem(S_fus(X)) = sem(X), fragments contained in S_fus(X)
      -- are exactly fragments contained in X.
      exact Or.inr h

/-!
## §6.2 Fusion-Saturated Structures

A structure is fusion-saturated if it is a fixed point of S_fus.
The fusion-saturated structures form a reflective subcategory.
-/

/-- A partial structure is fusion-saturated if applying fusion
does not change it. (§6.2) -/
def IsFusionSaturated [Interpretation₁ H]
    (X : PartialStructure (H := H)) : Prop :=
  fusionClosure X ≤ X ∧ X ≤ fusionClosure X

/-- Fusion-saturated structures are exactly the fixed points of
fusion closure. -/
theorem isFusionSaturated_iff [Interpretation₁ H]
    (X : PartialStructure (H := H)) :
    IsFusionSaturated X ↔
    (fusionClosure X ≤ X ∧ X ≤ fusionClosure X) :=
  Iff.rfl

/-- The fusion closure of any structure is fusion-saturated.
(Consequence of idempotence) -/
theorem fusionClosure_saturated [Interpretation₁ H]
    (X : PartialStructure (H := H)) :
    IsFusionSaturated (fusionClosure X) :=
  ⟨fusionClosure_idempotent X, fusionClosure_inflationary (fusionClosure X)⟩

/-!
### Lemma 6.3: Fusion is a reflector

For X ∈ U and Y fusion-saturated: S_fus(X) ≤ Y iff X ≤ Y.
This is the standard fact for closure operators on posets.
-/

/-- Fusion reflection: S_fus(X) ≤ Y ↔ X ≤ Y, when Y is
fusion-saturated. (Lemma 6.3) -/
theorem fusion_reflection [Interpretation₁ H]
    {X Y : PartialStructure (H := H)}
    (hY : IsFusionSaturated Y) :
    fusionClosure X ≤ Y ↔ X ≤ Y := by
  constructor
  · -- If S_fus(X) ≤ Y then X ≤ S_fus(X) ≤ Y
    intro h
    exact PartialStructure.le_trans (fusionClosure_inflationary X) h
  · -- If X ≤ Y and Y is saturated, then S_fus(X) ≤ S_fus(Y) ≤ Y
    intro hXY
    exact PartialStructure.le_trans (fusionClosure_monotone hXY) hY.1

end SemioticUniverse
