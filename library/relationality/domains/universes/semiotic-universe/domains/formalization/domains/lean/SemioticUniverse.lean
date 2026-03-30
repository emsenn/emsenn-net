/-
# Semiotic Universe — Lean Formalization

Formal verification of the semiotic universe specification
(semiotic-universe.md). Each file corresponds to a section of
the spec and proves that the claimed mathematical structures
are coherent.

Module hierarchy:
  HeytingDomain  — §1.1: meaning domain H (complete Heyting algebra)
  ModalClosure   — §1.2: modal closure j (habit-formation)
  TraceComonad   — §1.3: trace comonad G (semiotic provenance)
  Ambient        — §1.4: interaction axioms (j and G cohere)
  Syntax         — §2:   typed lambda calculus and definable operators
  Fragment       — §3:   finitely generated modal-temporal subalgebras
  Interpretation — §4:   interpretation mapping (semiosis formalized)
  Fusion         — §5–6: congruence, naming, and fusion reflection

See the spec: ../../semiotic-universe.md
See the roadmap: ../../curricula/formalizing-in-lean.md
-/

import SemioticUniverse.HeytingDomain
import SemioticUniverse.ModalClosure
import SemioticUniverse.TraceComonad
import SemioticUniverse.Ambient
import SemioticUniverse.Syntax
import SemioticUniverse.Fragment
import SemioticUniverse.Interpretation
import SemioticUniverse.Fusion
import SemioticUniverse.Test.Trivial
import SemioticUniverse.Test.ThreeElement
