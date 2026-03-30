/-
# Test.ThreeElement — A sign system with one meaning still in play

Models a minimal nontrivial semiotic situation using the
3-element linear Heyting algebra {⊥, m, ⊤}.

## Semiotic interpretation

Consider a sign system with three semantic values:
  - ⊥ (absurdity): the empty meaning — no interpretation at all
  - m (provisional): a meaning still undergoing semiosis — an
    abductive hypothesis that further inquiry may confirm or discard
  - ⊤ (established): a meaning that is fully determined

The ordering ⊥ < m < ⊤ is containment of interpretive content:
absurdity contains nothing, the provisional meaning contains some
content, and the established meaning contains everything the
system can express.

## Habit-formation (j)

The modal closure j collapses the provisional to the established:
  j(⊥) = ⊥,  j(m) = ⊤,  j(⊤) = ⊤.

This models a sign system where habit-formation is total:
when you try to stabilize a provisional meaning, it becomes
fully established — there is no partial habituation. The gap
j(m) > m (i.e., ⊤ > m) represents the instability of m: it has
not yet settled into habit. The habitual fragment {⊥, ⊤} is
the domain of meanings that are either absent or fully stable.

This j is a Lawvere-Tierney topology: it preserves meets
(j(a ⊓ b) = j(a) ⊓ j(b) for all cases, verified by exhaustion).

## Trace (G = id)

We use the identity trace (G = id) for simplicity. This models
a sign system where provenance is trivial — meanings carry no
record of how they were produced. A richer test would use a
non-identity G, but that requires at least 4 elements to be
interesting (so that G can map some elements below themselves
while remaining a comonad with G(a) ≤ a).

## What this test verifies

The Prop instance (Test.Trivial) has j = id and G = id, so all
axioms are trivially satisfied. This instance has j ≠ id, which
means:
  - IsHabitual is a nontrivial predicate (m fails it)
  - The habitual fragment is a proper subalgebra of H
  - Proposition 4.1 (interpreted operators preserve habituality)
    has nontrivial content
  - The interaction axiom j(G(a)) ≤ G(j(a)) is genuinely checked
-/

import SemioticUniverse.Fusion

namespace SemioticUniverse.Test

/-!
## The 3-element type
-/

/-- Three elements: bot, mid, top. -/
inductive Three where
  | bot : Three
  | mid : Three
  | top : Three
  deriving DecidableEq, Repr

namespace Three

/-!
## Ordering: ⊥ < m < ⊤

We define ≤ by match and prove all required properties
by case exhaustion.
-/

/-- The ordering on Three. -/
def le : Three → Three → Prop
  | bot, _ => True
  | mid, bot => False
  | mid, _ => True   -- mid ≤ mid and mid ≤ top
  | top, top => True
  | top, _ => False

instance : LE Three := ⟨le⟩
instance : LT Three := ⟨fun a b => a ≤ b ∧ ¬(b ≤ a)⟩

instance : DecidableRel (α := Three) (· ≤ ·) :=
  fun a b => match a, b with
    | bot, _ => isTrue trivial
    | mid, bot => isFalse id
    | mid, mid => isTrue trivial
    | mid, top => isTrue trivial
    | top, bot => isFalse id
    | top, mid => isFalse id
    | top, top => isTrue trivial

/-!
## Lattice operations
-/

/-- Meet (infimum). -/
def inf3 : Three → Three → Three
  | bot, _ => bot | _, bot => bot
  | mid, mid => mid | mid, top => mid | top, mid => mid
  | top, top => top

/-- Join (supremum). -/
def sup3 : Three → Three → Three
  | top, _ => top | _, top => top
  | mid, _ => mid | _, mid => mid
  | bot, bot => bot

/-- Heyting implication. -/
def himp3 : Three → Three → Three
  | bot, _ => top
  | mid, bot => bot | mid, _ => top
  | top, b => b

instance : Top Three := ⟨top⟩
instance : Bot Three := ⟨bot⟩
instance : Min Three := ⟨inf3⟩
instance : Max Three := ⟨sup3⟩
instance : HImp Three := ⟨himp3⟩
instance : Compl Three := ⟨fun a => himp3 a bot⟩

/-!
## Heyting algebra instance (by exhaustion)

We verify all required properties by matching on all cases.
-/

instance : Preorder Three where
  le_refl := fun a => match a with | bot => trivial | mid => trivial | top => trivial
  le_trans := fun a b c hab hbc => match a, b, c, hab, hbc with
    | bot, _, _, _, _ => trivial
    | mid, mid, _, _, h => h | mid, top, top, _, _ => trivial
    | top, top, _, _, h => h

instance : PartialOrder Three where
  le_antisymm := fun a b hab hba => match a, b, hab, hba with
    | bot, bot, _, _ => rfl | mid, mid, _, _ => rfl | top, top, _, _ => rfl

instance : SemilatticeInf Three where
  inf := inf3
  inf_le_left := fun a b => match a, b with
    | bot, _ => trivial | mid, bot => trivial | mid, mid => trivial
    | mid, top => trivial | top, bot => trivial | top, mid => trivial
    | top, top => trivial
  inf_le_right := fun a b => match a, b with
    | bot, _ => trivial | mid, bot => trivial | mid, mid => trivial
    | mid, top => trivial | top, bot => trivial | top, mid => trivial
    | top, top => trivial
  le_inf := fun a b c hab hac => match a, b, c, hab, hac with
    | bot, _, _, _, _ => trivial
    | mid, mid, mid, _, _ => trivial | mid, mid, top, _, _ => trivial
    | mid, top, mid, _, _ => trivial | mid, top, top, _, _ => trivial
    | top, top, top, _, _ => trivial

instance : SemilatticeSup Three where
  sup := sup3
  le_sup_left := fun a b => match a, b with
    | bot, _ => trivial | mid, bot => trivial | mid, mid => trivial
    | mid, top => trivial | top, bot => trivial | top, mid => trivial
    | top, top => trivial
  le_sup_right := fun a b => match a, b with
    | bot, bot => trivial | bot, mid => trivial | bot, top => trivial
    | mid, bot => trivial | mid, mid => trivial | mid, top => trivial
    | top, bot => trivial | top, mid => trivial | top, top => trivial
  sup_le := fun a b c hac hbc => match a, b, c, hac, hbc with
    | bot, bot, _, h, _ => h
    | bot, mid, mid, _, _ => trivial | bot, mid, top, _, _ => trivial
    | bot, top, top, _, _ => trivial
    | mid, bot, mid, _, _ => trivial | mid, bot, top, _, _ => trivial
    | mid, mid, mid, _, _ => trivial | mid, mid, top, _, _ => trivial
    | mid, top, top, _, _ => trivial
    | top, _, top, _, _ => trivial

instance : Lattice Three where
  inf := inf3
  sup := sup3
  inf_le_left := SemilatticeInf.inf_le_left
  inf_le_right := SemilatticeInf.inf_le_right
  le_inf := SemilatticeInf.le_inf
  le_sup_left := SemilatticeSup.le_sup_left
  le_sup_right := SemilatticeSup.le_sup_right
  sup_le := SemilatticeSup.sup_le

instance : OrderTop Three where
  le_top := fun a => match a with | bot => trivial | mid => trivial | top => trivial

instance : OrderBot Three where
  bot_le := fun _ => trivial

instance : BoundedOrder Three where

instance : GeneralizedHeytingAlgebra Three where
  himp := himp3
  le_himp_iff := fun a b c => match a, b, c with
    | bot, _, _ => ⟨fun _ => trivial, fun _ => trivial⟩
    | mid, bot, _ => ⟨fun _ => trivial, fun _ => trivial⟩
    | mid, mid, bot => ⟨fun h => h, fun h => h⟩
    | mid, mid, mid => ⟨fun _ => trivial, fun _ => trivial⟩
    | mid, mid, top => ⟨fun _ => trivial, fun _ => trivial⟩
    | mid, top, bot => ⟨fun h => h, fun h => h⟩
    | mid, top, mid => ⟨fun _ => trivial, fun _ => trivial⟩
    | mid, top, top => ⟨fun _ => trivial, fun _ => trivial⟩
    | top, bot, _ => ⟨fun _ => trivial, fun _ => trivial⟩
    | top, mid, bot => ⟨fun h => h, fun h => h⟩
    | top, mid, mid => ⟨fun _ => trivial, fun _ => trivial⟩
    | top, mid, top => ⟨fun _ => trivial, fun _ => trivial⟩
    | top, top, bot => ⟨fun h => h, fun h => h⟩
    | top, top, mid => ⟨fun h => h, fun h => h⟩
    | top, top, top => ⟨fun _ => trivial, fun _ => trivial⟩

instance : HeytingAlgebra Three where
  compl := fun a => himp3 a bot
  himp_bot := fun _ => rfl

instance : HeytingDomain Three where

/-!
## Modal closure: j collapses m to ⊤

This is a non-identity Lawvere-Tierney topology.
The habitual fragment H_hab = {⊥, ⊤}.
-/

/-- The modal closure on Three: j(⊥) = ⊥, j(m) = ⊤, j(⊤) = ⊤. -/
private def j3 : Three → Three
  | bot => bot
  | mid => top
  | top => top

instance : ModalClosure Three where
  j := j3
  extensive := fun a => match a with
    | bot => trivial | mid => trivial | top => trivial
  monotone := fun a b hab => match a, b, hab with
    | bot, _, _ => trivial
    | mid, mid, _ => trivial | mid, top, _ => trivial
    | top, top, _ => trivial
  idempotent := fun a => match a with
    | bot => rfl | mid => rfl | top => rfl
  join_preserving := fun a b => match a, b with
    | bot, bot => rfl | bot, mid => rfl | bot, top => rfl
    | mid, bot => rfl | mid, mid => rfl | mid, top => rfl
    | top, bot => rfl | top, mid => rfl | top, top => rfl
  j_bot := rfl
  meet_preserving := fun a b => match a, b with
    | bot, bot => rfl | bot, mid => rfl | bot, top => rfl
    | mid, bot => rfl | mid, mid => rfl | mid, top => rfl
    | top, bot => rfl | top, mid => rfl | top, top => rfl

/-!
## Trace comonad: G = id (trivial)
-/

instance : TraceComonad Three where
  G := id
  counit := fun a => le_refl a
  comult := fun a => le_refl a
  pres_inf := fun _ _ => rfl
  pres_sup := fun _ _ => rfl
  pres_himp := fun _ _ => rfl
  pres_top := rfl
  pres_bot := rfl

/-!
## Ambient structure
-/

instance : SemioticAmbient Three where
  j_G_le_G_j := fun a => match a with
    | bot => trivial | mid => trivial | top => trivial
  habitual_iff_trace_habitual := fun a => match a with
    | bot => ⟨fun h => h, fun h => h⟩
    | mid => ⟨fun h => h, fun h => h⟩
    | top => ⟨fun h => h, fun h => h⟩

/-!
## Tests: The habitual fragment is a proper subalgebra

In this sign system, only ⊥ and ⊤ are habitual. The provisional
meaning m has not settled: j(m) = ⊤ ≠ m. This is the semiotic
content — there exist meanings still undergoing interpretation.
-/

-- The provisional meaning has NOT become habitual.
-- Trying to stabilize it (applying j) overshoots to ⊤.
example : ¬ IsHabitual Three.mid := by
  intro h
  show False
  have : Three.top = Three.mid := h
  exact absurd this (by intro h'; cases h')

-- Absurdity and full establishment are habitual (fixed under j).
example : IsHabitual (⊥ : Three) := by show j3 bot = bot; rfl
example : IsHabitual (⊤ : Three) := by show j3 top = top; rfl

-- j is not the identity — this is a nontrivial sign system.
example : ModalClosure.j Three.mid ≠ Three.mid := by
  show j3 mid ≠ mid; intro h; cases h

-- Habit-formation sends the provisional to the established.
example : ModalClosure.j Three.mid = (⊤ : Three) := by
  show j3 mid = top; rfl

-- Lawvere-Tierney: j preserves meets (conjunction of meanings).
example : ModalClosure.j (Three.mid ⊓ Three.mid) =
    ModalClosure.j Three.mid ⊓ ModalClosure.j Three.mid := by
  show j3 (inf3 mid mid) = inf3 (j3 mid) (j3 mid); rfl

-- The habitual fragment is closed under Heyting operations:
-- meets and implications of habitual elements remain habitual.
example : IsHabitual ((⊤ : Three) ⊓ ⊥) :=
  IsHabitual.inf (by show j3 top = top; rfl) (by show j3 bot = bot; rfl)

-- "If established then absurd" is habitual (⊤ ⇨ ⊥ = ⊥ in Three).
example : IsHabitual ((⊤ : Three) ⇨ ⊥) :=
  IsHabitual.himp (by show j3 top = top; rfl) (by show j3 bot = bot; rfl)

end Three

end SemioticUniverse.Test
