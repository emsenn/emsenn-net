/-
# Interpretation — From Syntax to Semantics

Corresponds to §4 of semiotic-universe.md.

The interpretation mapping is the formal counterpart of semiosis:
the process by which syntactic forms acquire determinate meanings.
It connects the syntactic operator algebra (§2) to the semantic
structure H = Sub(Y) (§1).

An interpretation assigns to each definable operator f of arity n
a semantic function ⟦f⟧ : Hⁿ → H, subject to seven conditions
that ensure syntax and semantics are structurally aligned:

  1. Monotone & join-continuous
  2. Heyting compatibility (∧, ∨, ⇨, ⊤, ⊥ map to themselves)
  3. Modal homomorphism: j(⟦f⟧(a⃗)) = ⟦f⟧(j(a⃗))
  4. Trace compatibility: G(⟦f⟧(a⃗)) = ⟦f⟧(G(a⃗))
  5. Definitional equality preservation
  6. Fragment preservation
  7. Hereditary extensionality

These seven conditions are not arbitrary — each one prevents a
specific way in which syntax and semantics could diverge.
-/

import SemioticUniverse.Ambient
import SemioticUniverse.Syntax
import SemioticUniverse.Fragment

namespace SemioticUniverse

variable {H : Type*} [SemioticAmbient H]

/-!
## §4.1 Interpretation of Unary Operators

We formalize the interpretation for unary operators (arity 1)
first. This is sufficient to state and prove the key structural
results (Proposition 4.1) without the complexity of n-ary
argument lists. The n-ary generalization follows the same pattern
but requires dependent vectors or careful list-length tracking.
-/

/-- An interpretation of unary definable operators into a semantic
domain H. (§4.1 of semiotic-universe.md, restricted to arity 1)

Each condition corresponds to a way syntax and semantics must
align. We state conditions 1, 3, 4, 6 for unary operators. -/
class Interpretation₁ (H : Type*) [SemioticAmbient H] where
  /-- The interpretation of a unary operator: a semantic
  endofunction on H. -/
  interp₁ : DefOp → (H → H)

  /-- Condition 1: Each interpreted operator is monotone. -/
  monotone₁ : ∀ (f : DefOp) (a b : H),
    a ≤ b → interp₁ f a ≤ interp₁ f b

  /-- Condition 3: Modal homomorphism.
  j(⟦f⟧(a)) = ⟦f⟧(j(a))

  Forming the habit of an interpreted meaning is the same as
  interpreting with habituated input. -/
  modal_hom₁ : ∀ (f : DefOp) (a : H),
    ModalClosure.j (interp₁ f a) = interp₁ f (ModalClosure.j a)

  /-- Condition 4: Trace compatibility.
  G(⟦f⟧(a)) = ⟦f⟧(G(a))

  The provenance of an interpreted meaning is the interpretation
  of the provenance. -/
  trace_compat₁ : ∀ (f : DefOp) (a : H),
    TraceComonad.G (interp₁ f a) = interp₁ f (TraceComonad.G a)

  /-- Condition 6: Fragment preservation.
  ⟦f⟧(F) ⊆ F for every fragment F. -/
  fragment_pres₁ : ∀ (f : DefOp) (F : Fragment (H := H)) (a : H),
    F.mem a → F.mem (interp₁ f a)

variable [Interpretation₁ H]

/-!
## Proposition 4.1: Modal fragment as type discipline

Interpreted operators preserve habituality. This is the formal
content of "the modal fragment is closed under the grammar of
the sign system."
-/

/-- If the input is habitual, the output is habitual.
(Proposition 4.1, unary case)

Proof: j(⟦f⟧(a)) = ⟦f⟧(j(a))  (modal homomorphism)
                   = ⟦f⟧(a)     (j(a) = a by habituality) -/
theorem interp_preserves_habitual₁ (f : DefOp) (a : H)
    (ha : IsHabitual a) :
    IsHabitual (Interpretation₁.interp₁ f a) := by
  unfold IsHabitual at *
  rw [Interpretation₁.modal_hom₁ f a, ha]

/-- Interpreted operators preserve the trace of habitual inputs.
If a is habitual, then G(⟦f⟧(a)) = ⟦f⟧(G(a)), and G(a) is
also habitual (by Axiom 1.5), so the output trace is habitual. -/
theorem interp_trace_habitual₁ (f : DefOp) (a : H)
    (ha : IsHabitual a) :
    IsHabitual (TraceComonad.G (Interpretation₁.interp₁ f a)) := by
  rw [Interpretation₁.trace_compat₁]
  exact interp_preserves_habitual₁ f (TraceComonad.G a)
    (isHabitual_G_of_isHabitual ha)

/-- Interpreted operators are fragment-preserving. -/
theorem interp_fragmentPreserving₁ (f : DefOp) :
    IsFragmentPreserving (Interpretation₁.interp₁ f : H → H) :=
  fun F a ha => Interpretation₁.fragment_pres₁ f F a ha

end SemioticUniverse
