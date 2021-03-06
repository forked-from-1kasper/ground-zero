import ground_zero.HITs.circle

/-
  The Möbius band as quotient of square I × I.
  * https://en.wikipedia.org/wiki/M%C3%B6bius_strip#Topology

  -------->
  |   A   |
  |       |
  |   A   |
  <--------
  Edges labelled A are joined that
  so the directions of arrows match.
-/

namespace ground_zero.HITs
open ground_zero.types ground_zero.HITs.interval

hott theory
universes u v

inductive moebius.rel : I × I → I × I → Type
| glue (x : I) : moebius.rel (x, 0) (neg x, 1)
def moebius := graph moebius.rel

namespace moebius
  def elem (x y : I) : moebius := graph.elem (x, y)

  def a := elem 0 0
  def b := elem 1 0
  def c := elem 0 1
  def d := elem 1 1

  def up   : a = b := interval.lam (λ i, elem i 0)
  def down : d = c := interval.lam (λ i, elem (neg i) 1)

  @[hott] def glue (x : I) : elem x 0 = elem (neg x) 1 :> moebius :=
  graph.line (rel.glue x)
end moebius

def M : S¹ → Type := circle.rec I (ground_zero.ua interval.twist)
def moebius' := Σ b, M b

def cylinder := S¹ × I

def C : S¹ → Type := circle.rec I Id.refl
def cylinder' := Σ b, C b

@[hott] noncomputable def C.const : Π x, C x = I :=
begin
  intro x, fapply circle.ind _ _ x,
  refl, apply Id.trans,
  apply equiv.transport_over_contr_map,
  transitivity, apply Id.map (⬝ idp I),
  transitivity, apply Id.map_inv, apply Id.map,
  apply circle.recβrule₂, trivial
end

@[hott] noncomputable def cyl_eqv : cylinder' ≃ cylinder :=
begin
  transitivity,
  { apply equiv.idtoeqv, apply Id.map,
    apply ground_zero.theorems.funext, exact C.const },
  { apply sigma.const }
end

end ground_zero.HITs