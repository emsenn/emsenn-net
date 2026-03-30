{-
  Everything — Root module importing all components

  Type-check this file to verify the entire formalization:
    agda SemioticUniverse/Everything.agda
-}

module SemioticUniverse.Everything where

-- §1.0–1.1: U-small categories with finite limits
import SemioticUniverse.Category

-- §1.1–1.2: Subobject classifier, elementary topos
import SemioticUniverse.Topos

-- §1.2: Sub(Y) as a Heyting algebra (Theorem 1.1)
import SemioticUniverse.SubobjectLattice

-- §1.3: Lawvere-Tierney topology (habit-formation)
import SemioticUniverse.LawvereTierney

-- §2: Typed lambda calculus and definable operators
import SemioticUniverse.Syntax

-- §3: Fragments (finitely generated modal-temporal subalgebras)
import SemioticUniverse.Fragment

-- §4: Interpretation (semiosis formalized, Proposition 4.1)
import SemioticUniverse.Interpretation

-- §5–6: Fusion (congruence, naming, reflection)
import SemioticUniverse.Fusion
