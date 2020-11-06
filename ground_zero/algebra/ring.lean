import ground_zero.algebra.group
open ground_zero.types.equiv (transport)
open ground_zero.types.Id (map)
open ground_zero.structures
open ground_zero.types
open ground_zero

hott theory

namespace ground_zero.algebra

structure ring extends group :=
(ψ             : α.fst → α.fst → α.fst)
(add_comm      : Π a b, φ a b = φ b a)
(distrib_left  : Π a b c, ψ a (φ b c) = φ (ψ a b) (ψ a c))
(distrib_right : Π a b c, ψ (φ a b) c = φ (ψ a c) (ψ b c))

section
  variable (T : ring)
  def ring.carrier  := T.α.fst
  def ring.zero     := T.to_group.e

  def ring.subset := ens T.carrier

  def ring.neg := T.inv
  def ring.sub (x y : T.carrier) := T.φ x (T.neg y)

  def ring.isproper (x : T.carrier) := T.to_group.isproper x
  def ring.proper := T.to_group.proper

  def ring.proper_hset : hset T.proper :=
  begin
    apply hset_respects_sigma,
    intros a b, apply T.to_group.set,
    intro x, apply prop_is_set, apply not_is_prop
  end

  instance : has_add T.carrier := ⟨T.φ⟩
  instance : has_sub T.carrier := ⟨T.sub⟩
  instance : has_neg T.carrier := ⟨T.neg⟩

  instance : has_mul T.carrier := ⟨T.ψ⟩

  instance : has_zero T.carrier := ⟨T.zero⟩
end

@[hott] def ring.mul_zero {T : ring} (a : T.carrier) : a * 0 = 0 :=
begin
  apply group.unit_of_sqr, transitivity,
  { symmetry, apply T.distrib_left },
  apply map (T.ψ a), apply T.mul_one
end

@[hott] def ring.zero_mul {T : ring} (a : T.carrier) : 0 * a = 0 :=
begin
  apply group.unit_of_sqr, transitivity,
  { symmetry, apply T.distrib_right },
  apply map (* a), apply T.mul_one
end

@[hott] def ring.mul_neg {T : ring} (a b : T.carrier) : a * (-b) = -(a * b) :=
begin
  apply group.eq_inv_of_mul_eq_one, transitivity,
  { symmetry, apply T.distrib_left }, transitivity,
  { apply map (T.ψ a), apply group.mul_left_inv },
  apply ring.mul_zero
end

@[hott] def ring.neg_mul {T : ring} (a b : T.carrier) : (-a) * b = -(a * b) :=
begin
  apply group.eq_inv_of_mul_eq_one, transitivity,
  { symmetry, apply T.distrib_right }, transitivity,
  { apply map (* b), apply group.mul_left_inv },
  apply ring.zero_mul
end

@[hott] def ring.sub_distrib_left {T : ring} (a b c : T.carrier) := calc
  a * (b - c) = a * b + a * (-c) : T.distrib_left a b (T.neg c)
          ... = a * b - a * c    : (T.φ (T.ψ a b)) # (ring.mul_neg a c)

@[hott] def ring.sub_distrib_right {T : ring} (a b c : T.carrier) := calc
  (a - b) * c = a * c + (-b) * c : T.distrib_right a (T.neg b) c
          ... = a * c - b * c    : (T.φ (T.ψ a c)) # (ring.neg_mul b c)

class ring.assoc (T : ring) :=
(mul_assoc : Π a b c, T.ψ (T.ψ a b) c = T.ψ a (T.ψ b c))

class ring.comm (T : ring) :=
(mul_comm : Π a b, T.ψ a b = T.ψ b a)

class ring.monoid (T : ring) extends has_one T.carrier :=
(one_mul : Π a, T.ψ one a = a)
(mul_one : Π a, T.ψ a one = a)

class ring.divisible (T : ring) extends has_inv T.carrier, ring.monoid T :=
(zero         : inv 0 = 0)
(mul_left_inv : Π (x : T.carrier), T.isproper x → inv x * x = 1)

class field (T : ring) extends ring.assoc T, ring.divisible T, ring.comm T :=
(nontrivial : T.isproper 1)

@[hott] def field.proper_mul {T : ring} [field T] {a b : T.carrier} :
  T.isproper a → T.isproper b → T.isproper (a * b) :=
begin
  intros p q r, apply @field.nontrivial T _,
  transitivity, { symmetry, apply ring.divisible.mul_left_inv b q },
  transitivity, { apply map (* b), symmetry, apply ring.monoid.mul_one },
  transitivity, apply ring.assoc.mul_assoc,
  transitivity, apply map (λ y, b⁻¹ * (y * b)),
  { symmetry, apply ring.divisible.mul_left_inv a p },
  transitivity, apply map (T.ψ _), apply ring.assoc.mul_assoc,
  transitivity, { symmetry, apply ring.assoc.mul_assoc },
  transitivity, apply map, exact r, apply ring.mul_zero
end

@[hott] def field.prop_inv {T : ring} [field T] {a : T.carrier} :
  T.isproper a → T.isproper a⁻¹ :=
begin
  intros p q, apply @field.nontrivial T _,
  transitivity, { symmetry, apply ring.divisible.mul_left_inv a p },
  transitivity, apply map (* a), exact q, apply ring.zero_mul
end

@[hott] def field.mul (T : ring) [field T] :
  T.proper → T.proper → T.proper :=
λ ⟨a, p⟩ ⟨b, q⟩, ⟨T.ψ a b, field.proper_mul p q⟩

@[hott] def field.inv (T : ring) [field T] : T.proper → T.proper :=
λ ⟨a, p⟩, ⟨@has_inv.inv T.carrier _ a, field.prop_inv p⟩

@[hott] def ring.proper_eq {T : ring} {x y : T.proper} (p : x.fst = y.fst) : x = y :=
begin fapply sigma.prod, exact p, apply not_is_prop end

abbreviation additive : ring → group := ring.to_group
postfix `⁺`:1034 := additive

@[hott] instance additive.abelian (T : ring) : abelian T⁺ :=
⟨T.add_comm⟩

def multiplicative (T : ring) [field T] : group :=
⟨⟨⟨⟨zeroeqv (λ _ _, T.proper_hset), field.mul T⟩,
  λ ⟨a, p⟩ ⟨b, q⟩ ⟨c, r⟩, ring.proper_eq (ring.assoc.mul_assoc a b c)⟩,
  ⟨1, field.nontrivial⟩,
  λ ⟨a, p⟩, ring.proper_eq (ring.monoid.one_mul a),
  λ ⟨a, p⟩, ring.proper_eq (ring.monoid.mul_one a)⟩,
  field.inv T, λ ⟨a, p⟩, ring.proper_eq (ring.divisible.mul_left_inv a p)⟩
postfix `ˣ`:1034 := multiplicative

-- voilà, no need to repeat a bunch of lemmas
@[hott] def field.mul_right_inv (T : ring) [field T] {x : T.carrier}
  (p : T.isproper x) : x * x⁻¹ = 1 :=
sigma.fst # (@group.mul_right_inv Tˣ ⟨x, p⟩)

class lid (T : ring) (φ : T.subset) :=
(subgroup : T⁺ ≥ φ)
(ideal    : Π r i, i ∈ φ → r * i ∈ φ)

class rid (T : ring) (φ : T.subset) :=
(subgroup : T⁺ ≥ φ)
(ideal    : Π i r, i ∈ φ → i * r ∈ φ)

class ideal (T : ring) (φ : T.subset) :=
(subgroup : T⁺ ≥ φ)
(left     : Π r i, i ∈ φ → r * i ∈ φ)
(right    : Π i r, i ∈ φ → i * r ∈ φ)

instance ideal.auto (T : ring) (φ : T.subset) [lid T φ] [rid T φ] : ideal T φ :=
⟨lid.subgroup, lid.ideal, rid.ideal⟩

namespace ring
  variables (T : ring) (φ : T.subset) [ideal T φ]

  @[hott] instance subgroup : T⁺ ≥ φ :=
  ideal.subgroup

  @[hott] instance normal : T⁺ ⊵ φ :=
  group.abelian_subgroup_is_normal T⁺ φ

  noncomputable def factor.mul :
    group.factor_left T⁺ φ → group.factor_left T⁺ φ → group.factor_left T⁺ φ :=
  begin
    fapply HITs.quotient.lift₂,
    { intros a b, apply HITs.quotient.elem, exact T.ψ a b },
    { apply HITs.quotient.set },
    { intros a₁ a₂ b₁ b₂ p q,
      apply HITs.quotient.sound,
      apply transport (∈ φ),
      { let φ' := @group.left_div T⁺,
        change T.φ (φ' (T.ψ a₁ a₂) (T.ψ a₁ b₂)) (φ' (T.ψ a₁ b₂) (T.ψ b₁ b₂)) = _,
        transitivity, apply T⁺.mul_assoc,
        transitivity, apply Id.map (T.φ _),
        transitivity, symmetry, apply T⁺.mul_assoc,
        apply Id.map (λ z, T.φ z (T.ψ b₁ b₂)),
        apply group.mul_right_inv,
        apply Id.map, apply T⁺.one_mul },
      apply group.is_subgroup.mul,
      { apply transport (∈ φ),
        transitivity, apply ring.distrib_left T a₁ (T.inv a₂) b₂,
        apply Id.map (λ z, T.φ z (T.ψ a₁ b₂)),
        apply ring.mul_neg, apply ideal.left, exact q },
      { apply transport (∈ φ),
        transitivity, apply ring.distrib_right T (T.inv a₁) b₁ b₂,
        apply Id.map (λ z, T.φ z (T.ψ b₁ b₂)),
        apply ring.neg_mul, apply ideal.right, exact p } }
  end

  meta def πprop :=
  `[ repeat { intros, apply structures.pi_prop <|> apply HITs.quotient.set } ]

  meta def quotΩind :=
  `[ intro x, fapply HITs.quotient.ind_prop _ _ x; clear x ]

  @[hott] noncomputable def factor : ring :=
  ⟨T⁺\φ, factor.mul T φ, begin
    iterate 2 { quotΩind, intros },
    apply Id.map HITs.quotient.elem,
    apply ring.add_comm,
    repeat { πprop }
  end, begin
    iterate 3 { quotΩind, intros },
    apply Id.map HITs.quotient.elem,
    apply ring.distrib_left,
    repeat { πprop }
  end, begin
    iterate 3 { quotΩind, intros },
    apply Id.map HITs.quotient.elem,
    apply ring.distrib_right,
    repeat { πprop }
  end⟩

  infix \ := factor
end ring

end ground_zero.algebra