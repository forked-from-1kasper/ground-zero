import ground_zero.algebra.basic
open ground_zero.types
open ground_zero

hott theory

namespace ground_zero.algebra

universe u

namespace precategory
  inductive arity : Type
  | left | right | mul | bottom
  open arity

  def signature : arity + ⊥ → ℕ
  | (sum.inl mul)    := 2
  | (sum.inl left)   := 1
  | (sum.inl right)  := 1
  | (sum.inl bottom) := 0
end precategory

def precategory : Type (u + 1) :=
Alg.{0 0 u 0} precategory.signature

namespace precategory
  variable (𝒞 : precategory.{u})

  def bottom : 𝒞.carrier :=
  𝒞.op arity.bottom ★
  notation `∄` := bottom _

  def μ : 𝒞.carrier → 𝒞.carrier → 𝒞.carrier :=
  λ x y, 𝒞.op arity.mul (x, y, ★)

  def lid : 𝒞.carrier → 𝒞.carrier :=
  λ x, 𝒞.op arity.left (x, ★)

  def rid : 𝒞.carrier → 𝒞.carrier :=
  λ x, 𝒞.op arity.right (x, ★)

  def id (x : 𝒞.carrier) :=
  ∥(Σ φ, (𝒞.lid φ = x) + (𝒞.rid φ = x))∥

  def objs := Σ x, id 𝒞 x

  def defined (x : 𝒞.carrier) : Type u := x ≠ ∄
end precategory

class category (𝒞 : precategory) :=
(bottom_left  : Π a, 𝒞.μ ∄ a = ∄)
(bottom_right : Π a, 𝒞.μ a ∄ = ∄)
(lid_comp     : Π a, 𝒞.μ (𝒞.lid a) a = a)
(rid_comp     : Π a, 𝒞.μ a (𝒞.rid a) = a)
(lid_lid      : 𝒞.lid ∘ 𝒞.lid ~ 𝒞.lid)
(rid_rid      : 𝒞.rid ∘ 𝒞.rid ~ 𝒞.rid)
(lid_rid      : 𝒞.lid ∘ 𝒞.rid ~ 𝒞.rid)
(rid_lid      : 𝒞.rid ∘ 𝒞.lid ~ 𝒞.lid)
(mul_assoc    : Π a b c, 𝒞.μ (𝒞.μ a b) c = 𝒞.μ a (𝒞.μ b c))

end ground_zero.algebra