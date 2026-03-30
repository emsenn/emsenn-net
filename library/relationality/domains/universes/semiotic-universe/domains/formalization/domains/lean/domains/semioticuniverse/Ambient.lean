/-
# Ambient — The Semiotic Ambient Structure

Corresponds to §1.4 of semiotic-universe.md.

The semiotic ambient structure combines:
  - a HeytingDomain H (§1.1)
  - a ModalClosure j on H (§1.2)
  - a TraceComonad G on H (§1.3)

with two interaction axioms ensuring that habit-formation (j)
and semiotic provenance (G) cohere:

  Axiom 1.3:  j(G(a)) ≤ G(j(a))
    Forming a habit from the provenance of a meaning does not
    exceed tracing the habit.

  Axiom 1.4:  j(G(a)) = G(a)  ↔  j(a) = a
    A meaning is habitual if and only if its provenance is
    habitual. (Equivalently: G restricts to the habitual
    fragment.)
-/

import SemioticUniverse.ModalClosure
import SemioticUniverse.TraceComonad

namespace SemioticUniverse

/-- The full ambient structure of a semiotic universe.
Combines the HeytingDomain, ModalClosure, and TraceComonad
with interaction axioms (§1.4). -/
class SemioticAmbient (H : Type*) extends
    HeytingDomain H, ModalClosure H, TraceComonad H where
  /-- Axiom 1.3: j(G(a)) ≤ G(j(a)). -/
  j_G_le_G_j : ∀ (a : H), ModalClosure.j (TraceComonad.G a) ≤
    TraceComonad.G (ModalClosure.j a)
  /-- Axiom 1.4: habituality equivalence. -/
  habitual_iff_trace_habitual : ∀ (a : H),
    ModalClosure.j (TraceComonad.G a) = TraceComonad.G a ↔
    ModalClosure.j a = a

variable {H : Type*} [SemioticAmbient H]

/-!
## Lemma 1.5: G restricts to the habitual fragment

If a is habitual, then G(a) is habitual. This means G
is well-defined on the habitual fragment H_hab.
-/

/-- If a is habitual, then G(a) is habitual. -/
theorem isHabitual_G_of_isHabitual {a : H} (ha : IsHabitual a) :
    IsHabitual (TraceComonad.G a) :=
  (SemioticAmbient.habitual_iff_trace_habitual a).mpr ha

/-- G restricted to habitual elements is still a comonad:
counit holds (G(a) ≤ a when a is habitual). -/
theorem TraceComonad.counit_habitual {a : H} (_ha : IsHabitual a) :
    TraceComonad.G a ≤ a :=
  TraceComonad.counit a

/-- G restricted to habitual elements: comultiplication. -/
theorem TraceComonad.comult_habitual {a : H} (_ha : IsHabitual a) :
    TraceComonad.G a ≤ TraceComonad.G (TraceComonad.G a) :=
  TraceComonad.comult a

/-- G restricted to habitual elements preserves meets. -/
theorem TraceComonad.pres_inf_habitual {a b : H}
    (_ha : IsHabitual a) (_hb : IsHabitual b) :
    TraceComonad.G (a ⊓ b) = TraceComonad.G a ⊓ TraceComonad.G b :=
  TraceComonad.pres_inf a b

-- Note: The reverse direction G(j(a)) ≤ j(G(a)) is NOT an axiom —
-- it would make j and G commute. The asymmetry is intentional:
-- habit-forming a provenance may lose information that
-- tracing a habit preserves.

/-!
## Working inside the habitual fragment

After establishing these lemmas, we can safely work inside
the habitual fragment H_hab without losing trace structure.
This is the content of the paragraph after Lemma 1.5 in the
spec.
-/

end SemioticUniverse
