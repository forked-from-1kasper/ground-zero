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

  def dom : 𝒞.carrier → 𝒞.carrier :=
  λ x, 𝒞.op arity.left (x, ★)

  def cod : 𝒞.carrier → 𝒞.carrier :=
  λ x, 𝒞.op arity.right (x, ★)

  def id (x : 𝒞.carrier) :=
  ∥(Σ φ, (𝒞.dom φ = x) + (𝒞.cod φ = x))∥

  def objs := Σ x, id 𝒞 x

  def Hom (a b : 𝒞.carrier) :=
  Σ φ, ∥(𝒞.dom φ = a) + (𝒞.cod φ = b)∥

  def defined (x : 𝒞.carrier) : Type u := x ≠ ∄

  def monic (a : 𝒞.carrier) :=
  Π b c, 𝒞.μ a b = 𝒞.μ a c → b = c

  def epic (a : 𝒞.carrier) :=
  Π b c, 𝒞.μ b a = 𝒞.μ c a → b = c

  def bimorphism (a : 𝒞.carrier) :=
  monic 𝒞 a × epic 𝒞 a

  def endo (a : 𝒞.carrier) :=
  𝒞.dom a = 𝒞.cod a
end precategory

class category (𝒞 : precategory) :=
(bottom_left  : Π a, 𝒞.μ ∄ a = ∄)
(bottom_right : Π a, 𝒞.μ a ∄ = ∄)
(bottom_dom   : 𝒞.dom ∄ = ∄)
(bottom_cod   : 𝒞.cod ∄ = ∄)
(dom_comp     : Π a, 𝒞.μ (𝒞.dom a) a = a)
(cod_comp     : Π a, 𝒞.μ a (𝒞.cod a) = a)
(dom_dom      : 𝒞.dom ∘ 𝒞.dom ~ 𝒞.dom)
(cod_cod      : 𝒞.cod ∘ 𝒞.cod ~ 𝒞.cod)
(dom_cod      : 𝒞.dom ∘ 𝒞.cod ~ 𝒞.cod)
(cod_dom      : 𝒞.cod ∘ 𝒞.dom ~ 𝒞.dom)
(mul_assoc    : Π a b c, 𝒞.μ (𝒞.μ a b) c = 𝒞.μ a (𝒞.μ b c))

namespace category
  variables (𝒞 : precategory) [category 𝒞]

  @[hott] def dom_endo : Π a, 𝒞.endo (𝒞.dom a) :=
  λ x, (category.dom_dom x) ⬝ (category.cod_dom x)⁻¹

  @[hott] def cod_endo : Π a, 𝒞.endo (𝒞.cod a) :=
  λ x, (category.dom_cod x) ⬝ (category.cod_cod x)⁻¹
end category

end ground_zero.algebra