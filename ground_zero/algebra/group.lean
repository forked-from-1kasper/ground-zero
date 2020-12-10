import ground_zero.HITs.quotient ground_zero.types.integer
import ground_zero.theorems.functions ground_zero.algebra.basic
open ground_zero.types.equiv (biinv transport)
open ground_zero.types.Id (map)
open ground_zero.structures
open ground_zero.types
open ground_zero.proto
open ground_zero

/-
  Basic lemmas about groups and abelian groups.

  Homomorphism definition and properties
  + composition
  + extensionality
  + 0-Type

  Kernel and image of homomorphism.
  * https://groupoid.space/math/homology/

  Group isomorphism and its properties:
  + reflexivity
  + symmetry
  + transitivity

  Subgroup, normal subgroup. Factor/quotient group (as quotient type).
  * https://groupoid.space/math/homology/

  Trivial group, symmetric group, cyclic group Z₂,
  dihedral group D₃, alternating group A₃ as its subgroup.
  * https://en.wikipedia.org/wiki/Trivial_group
  * https://en.wikipedia.org/wiki/Symmetric_group
  * https://en.wikipedia.org/wiki/Cyclic_group
  * https://en.wikipedia.org/wiki/Dihedral_group_of_order_6
  * https://en.wikipedia.org/wiki/Alternating_group

  Z₂ ≅ D₃\A₃ proof.

  Group presentation, presentation of every group.
  * https://en.wikipedia.org/wiki/Presentation_of_a_group#Definition

  Abelianization (as factor group).
  * https://groupprops.subwiki.org/wiki/Abelianization
  * https://ncatlab.org/nlab/show/abelianization

  Opposite group.
  * https://en.wikipedia.org/wiki/Opposite_group

  Free group, free abelian group.
  * https://en.wikipedia.org/wiki/Free_group
  * https://en.wikipedia.org/wiki/Free_abelian_group

  First isomorphism theorem: Im φ ≅ G\ker φ.
  * https://en.wikipedia.org/wiki/Fundamental_theorem_on_homomorphisms
  * https://en.wikipedia.org/wiki/First_isomorphism_theorem#Theorem_A

  Cayley’s theorem.
  * https://en.wikipedia.org/wiki/Cayley's_theorem

  Differential group.
  * https://encyclopediaofmath.org/wiki/Differential_group
-/

set_option pp.generalized_field_notation false

namespace ground_zero.algebra
universes u v u' v' w

hott theory

@[hott] def mul_uniq {α : Type u} {a b c d : α}
  (h : a = b) (g : c = d) {φ : α → α → α} : φ a c = φ b d :=
begin induction h, induction g, reflexivity end

namespace group
  variables {G : group}
  local infix ` * ` := G.φ
  local notation `e` := G.e
  local postfix ⁻¹ := G.inv

  @[hott] def isproper (G : group) (x : G.carrier) := neq x G.e

  @[hott] def proper (G : group) := Σ x, G.isproper x

  @[hott] def proper.prop (G : group) {x : G.carrier} : prop (G.isproper x) :=
  structures.impl_prop structures.empty_is_prop

  @[hott] def left_unit_uniq (e' : G.carrier) (one_mul' : Π a, e' * a = a) : e' = e :=
  Id.inv (G.mul_one e') ⬝ one_mul' e

  @[hott] def right_unit_uniq (e' : G.carrier) (mul_one' : Π a, a * e' = a) : e' = e :=
  Id.inv (G.one_mul e') ⬝ mul_one' e

  @[hott] def unit_of_sqr {x : G.carrier} (h : x * x = x) := calc
      x = e * x         : by symmetry; apply monoid.one_mul
    ... = (x⁻¹ * x) * x : (* x) # (Id.inv $ G.mul_left_inv x)
    ... = x⁻¹ * (x * x) : by apply semigroup.mul_assoc
    ... = x⁻¹ * x       : G.φ x⁻¹ # h
    ... = e             : by apply group.mul_left_inv

  @[hott] def inv_eq_of_mul_eq_one {x y : G.carrier} (h : x * y = e) := calc
     x⁻¹ = x⁻¹ * e       : by symmetry; apply monoid.mul_one
     ... = x⁻¹ * (x * y) : G.φ x⁻¹ # (Id.inv h)
     ... = (x⁻¹ * x) * y : by symmetry; apply semigroup.mul_assoc
     ... = e * y         : (* y) # (G.mul_left_inv x)
     ... = y             : G.one_mul y

  @[hott] def inv_inv (x : G.carrier) : x⁻¹⁻¹ = x :=
  inv_eq_of_mul_eq_one (G.mul_left_inv x)

  @[hott] def eq_inv_of_mul_eq_one {x y : G.carrier} (h : x * y = e) : x = y⁻¹ :=
  Id.inv (inv_inv x) ⬝ G.inv # (inv_eq_of_mul_eq_one h)

  @[hott] def mul_right_inv (x : G.carrier) := calc
    x * x⁻¹ = x⁻¹⁻¹ * x⁻¹ : (* x⁻¹) # (Id.inv $ inv_inv x)
        ... = e           : G.mul_left_inv x⁻¹

  @[hott] def mul_eq_one_of_inv_eq {x y : G.carrier} (h : x⁻¹ = y) : x * y = e :=
  Id.inv (G.φ x # h) ⬝ (mul_right_inv x)

  @[hott] def inv_inj {x y : G.carrier} (h : x⁻¹ = y⁻¹) : x = y := calc
      x = x⁻¹⁻¹ : Id.inv (inv_inv x)
    ... = y⁻¹⁻¹ : G.inv # h
    ... = y     : inv_inv y

  @[hott] def mul_cancel_left {a b c : G.carrier} (h : c * a = c * b) := calc
      a = e * a         : Id.inv (G.one_mul a)
    ... = (c⁻¹ * c) * a : (* a) # (Id.inv $ G.mul_left_inv c)
    ... = c⁻¹ * (c * a) : G.mul_assoc _ _ _
    ... = c⁻¹ * (c * b) : G.φ c⁻¹ # h
    ... = (c⁻¹ * c) * b : Id.inv (G.mul_assoc _ _ _)
    ... = e * b         : (* b) # (G.mul_left_inv c)
    ... = b             : G.one_mul b

  @[hott] def mul_cancel_right {a b c : G.carrier} (h : a * c = b * c) := calc
      a = a * e         : Id.inv (G.mul_one a)
    ... = a * (c * c⁻¹) : (G.φ a) # (Id.inv $ mul_right_inv c)
    ... = (a * c) * c⁻¹ : Id.inv (G.mul_assoc _ _ _)
    ... = (b * c) * c⁻¹ : (* c⁻¹) # h
    ... = b * (c * c⁻¹) : G.mul_assoc _ _ _
    ... = b * e         : (G.φ b) # (mul_right_inv c)
    ... = b             : G.mul_one b

  @[hott] def unit_inv : e = e⁻¹ :=
  Id.inv (mul_right_inv e) ⬝ G.one_mul e⁻¹

  @[hott] def unit_sqr : e = e * e :=
  Id.inv (G.one_mul e)

  @[hott] def unit_commutes (x : G.carrier) : e * x = x * e :=
  (G.one_mul x) ⬝ Id.inv (G.mul_one x)

  @[hott] def unit_commutes_inv (x : G.carrier) : x * e = e * x :=
  Id.inv (unit_commutes x)

  @[hott] def inv_explode (x y : G.carrier) : (x * y)⁻¹ = y⁻¹ * x⁻¹ :=
  inv_eq_of_mul_eq_one
    (calc (x * y) * (y⁻¹ * x⁻¹)
        = ((x * y) * y⁻¹) * x⁻¹ :
          by symmetry; apply semigroup.mul_assoc
    ... = (x * e) * x⁻¹ :
          begin
            apply map (* x⁻¹), transitivity,
            { apply semigroup.mul_assoc },
            { apply map, apply mul_right_inv }
          end
    ... = x * x⁻¹ : (* x⁻¹) # (G.mul_one x)
    ... = e : by apply mul_right_inv)

  @[hott] def sqr_unit {x : G.carrier} (p : x * x = e) := calc
      x = x * e         : Id.inv (G.mul_one x)
    ... = x * (x * x⁻¹) : (G.φ x) # (Id.inv $ mul_right_inv x)
    ... = (x * x) * x⁻¹ : Id.inv (G.mul_assoc x x x⁻¹)
    ... = e * x⁻¹       : (* x⁻¹) # p
    ... = x⁻¹           : G.one_mul x⁻¹

  @[hott] instance sqr_unit_impls_abelian (H : Π x, x * x = e) : abelian G :=
  begin
    split, intros x y, have p := λ x, sqr_unit (H x), calc
      x * y = x⁻¹ * y⁻¹ : equiv.bimap G.φ (p x) (p y)
        ... = (y * x)⁻¹ : Id.inv (inv_explode y x)
        ... = y * x     : Id.inv (p _)
  end

  def conjugate (a x : G.carrier) := x⁻¹ * a * x

  local infix ^ := @conjugate G
  def conjugate_rev (a x : G.carrier) := x * a * x⁻¹

  def right_div (x y : G.carrier) := x * y⁻¹
  def left_div  (x y : G.carrier) := x⁻¹ * y

  local infix / := @right_div G

  @[hott] def eq_of_div_eq {x y : G.carrier} (h : @left_div G x y = e) : x = y :=
  Id.inv (inv_inv x) ⬝ (inv_eq_of_mul_eq_one h)

  section
    variables {μ : Type u} {η : Type v} (φ : μ → η)
    def im.aux := ground_zero.theorems.functions.fib_inh φ
    def im : ens η := ⟨im.aux φ, λ _, HITs.merely.uniq⟩
  end

  section
    variables {H : group}
    local infix × : 70 := H.φ

    def respects_mul (φ : G.carrier → H.carrier) :=
    Π a b, φ (a * b) = φ a × φ b

    @[hott] def homo (G H : group) :=
    Σ (φ : G.carrier → H.carrier), @respects_mul G H φ

    infix ` ⤳ `:20 := homo

    @[hott] def prop_respects_mul (φ : G.carrier → H.carrier) :
      prop (@respects_mul G H φ) :=
    begin intros f g, repeat { apply ground_zero.theorems.funext, intro }, apply H.set end

    section
      variables {F : group}
      local infix ` ∗ ` : 70 := F.φ

      @[hott] def homo.comp {G H : group} (f : H ⤳ F) (g : G ⤳ H) : G ⤳ F :=
      ⟨f.fst ∘ g.fst, λ a b, begin
        cases f with f f', cases g with g g', calc
          (f ∘ g) (a * b) = f (g a × g b)         : f # (g' a b)
                      ... = (f ∘ g) a ∗ (f ∘ g) b : by apply f'
      end⟩
    end

    infix ` ⋅ `:60 := homo.comp

    @[hott] def homo.zero {G H : group} : G ⤳ H :=
    ⟨λ _, H.e, λ _ _, Id.inv (H.one_mul H.e)⟩
    instance : has_zero (G ⤳ H) := ⟨homo.zero⟩

    @[hott] def homo.id : G ⤳ G :=
    ⟨id, λ x y, idp (x * y)⟩

    @[hott] def homo.funext {f g : G ⤳ H} : f.fst ~ g.fst → f = g :=
    begin
      intro p, induction f with f F, induction g with g G, fapply sigma.prod,
      { apply theorems.funext, assumption },
      { apply theorems.funext, intro x,
        apply theorems.funext, intro y,
        apply H.set }
    end

    @[hott] def idhomo (f g : G ⤳ H) : f = g → f.fst ~ g.fst :=
    begin intro p, induction p, reflexivity end

    variable (φ : G ⤳ H)
    def ker.aux := λ g, φ.fst g = H.e
    @[hott] def ker_is_prop (x : G.carrier) : prop (ker.aux φ x) :=
    begin intros f g, apply H.set end

    def ker : G.subset := ⟨ker.aux φ, ker_is_prop φ⟩

    def Ker := (ker φ).subtype
    def im.carrier := (im φ.fst).subtype
  end

  @[hott] def iso (G H : group) :=
  Σ (f : G.carrier → H.carrier), @respects_mul G H f × biinv f
  infix ` ≅ `:25 := iso

  @[hott, refl] def iso.refl (G : group) : G ≅ G :=
  begin
    existsi id, split,
    { intros a b, trivial },
    { split; existsi id; intro x; reflexivity }
  end

  section
    variables {H F : group}
    local infix × : 70 := H.φ
    local infix ` ∗ ` : 70 := F.φ

    @[hott, symm] def iso.symm : G ≅ H → H ≅ G
    | ⟨f, ⟨f', (⟨g, g'⟩, ⟨h, h'⟩)⟩⟩ := begin
      have g'' := qinv.rinv_inv f h g h' g',
      existsi g, split,
      { intros a b, symmetry, transitivity,
        { symmetry, apply g' }, transitivity,
        { apply map g, apply f' }, transitivity,
        { apply map g, apply map (× f (g b)), apply g'' },
        { apply map g, apply map (H.φ a), apply g'' } },
      { split; existsi f, apply g'', apply g' }
    end

    @[hott, trans] def iso.trans : G ≅ H → H ≅ F → G ≅ F
    | ⟨f, ⟨f', e₁⟩⟩ ⟨g, ⟨g', e₂⟩⟩ := begin
      existsi g ∘ f, split,
      { intros a b, transitivity, { apply map g, apply f' },
        transitivity, apply g', reflexivity },
      { apply equiv.biinv_trans e₁ e₂ }
    end

    @[hott] def iso.of_equiv : Π (eqv : G.carrier ≃ H.carrier),
      @respects_mul G H eqv.forward → G ≅ H :=
    λ ⟨f, eqv⟩ h, ⟨f, (h, eqv)⟩

    @[hott] def iso.to_equiv : G ≅ H → G.carrier ≃ H.carrier :=
    λ ⟨f, (p, q)⟩, ⟨f, q⟩

    @[hott] def iso.of_homo : Π (φ : G ⤳ H), biinv φ.fst → G ≅ H :=
    λ ⟨f, h⟩ eqv, ⟨f, (h, eqv)⟩

    @[hott] def iso.ext (φ ψ : G ≅ H) : φ.fst ~ ψ.fst → φ = ψ :=
    begin
      intro p, fapply sigma.prod, apply theorems.funext p,
      apply product_prop, apply prop_respects_mul, apply theorems.prop.biinv_prop
    end

    @[hott] def iso.homo (φ : G ≅ H) : G ⤳ H :=
    ⟨φ.fst, φ.snd.fst⟩

    @[hott] def iso.hset : hset (G ≅ H) :=
    begin
      apply hset_respects_sigma,
      { apply pi_hset, intros x a b, apply H.set },
      { intro x, apply prop_is_set,
        apply product_prop, apply prop_respects_mul,
        apply theorems.prop.biinv_prop }
    end
  end

  class is_subgroup (G : group) (φ : G.subset) :=
  (unit : G.e ∈ φ)
  (mul  : Π a b, a ∈ φ → b ∈ φ → G.φ a b ∈ φ)
  (inv  : Π a, a ∈ φ → G.inv a ∈ φ)
  notation φ ` ≤ ` G := is_subgroup G φ
  infix ≥ := is_subgroup

  class is_normal_subgroup (G : group) (φ : G.subset)
    extends is_subgroup G φ :=
  (cosets_eqv : Π g h, G.φ g h ∈ φ → G.φ h g ∈ φ)
  notation φ ` ⊴ `:50 G := is_normal_subgroup G φ
  infix ` ⊵ `:50 := is_normal_subgroup

  @[hott] def is_subgroup.prop (φ : G.subset) :
    structures.prop (G ≥ φ)
  | ⟨p₁, q₁, r₁⟩ ⟨p₂, q₂, r₂⟩ := begin
    have p := ens.prop G.e φ p₁ p₂, induction p,
    have q : q₁ = q₂ :=
    begin repeat { apply theorems.funext, intro }, apply ens.prop end,
    induction q,
    have r : r₁ = r₂ :=
    begin repeat { apply theorems.funext, intro }, apply ens.prop end,
    induction r, reflexivity
  end

  @[hott] def cancel_left (a b : G.carrier) := calc
      a = a * e         : Id.inv (G.mul_one a)
    ... = a * (b⁻¹ * b) : (G.φ a) # (Id.inv $ G.mul_left_inv b)
    ... = (a * b⁻¹) * b : Id.inv (G.mul_assoc a b⁻¹ b)

  @[hott] def cancel_right (a b : G.carrier) := calc
      a = a * e         : Id.inv (G.mul_one a)
    ... = a * (b * b⁻¹) : (G.φ a) # (Id.inv $ mul_right_inv b)
    ... = (a * b) * b⁻¹ : Id.inv (G.mul_assoc a b b⁻¹)

  @[hott] def comm_impl_conj {x y : G.carrier} (p : x * y = y * x) : x = x ^ y := calc
      x = e * x         : Id.inv (G.one_mul x)
    ... = (y⁻¹ * y) * x : (* x) # (Id.inv $ G.mul_left_inv y)
    ... = y⁻¹ * (y * x) : G.mul_assoc y⁻¹ y x
    ... = y⁻¹ * (x * y) : G.φ y⁻¹ # (Id.inv p)
    ... = (y⁻¹ * x) * y : Id.inv (G.mul_assoc y⁻¹ x y)
    ... = x ^ y         : by reflexivity

  @[hott] def is_normal_subgroup.conj (φ : G.subset)
    [G ⊵ φ] (n g : G.carrier) : n ∈ φ → n ^ g ∈ φ :=
  begin
    intro h, change g⁻¹ * n * g ∈ φ,
    apply ground_zero.types.equiv.transport (∈ φ),
    { symmetry, apply semigroup.mul_assoc },
    apply is_normal_subgroup.cosets_eqv,
    apply ground_zero.types.equiv.transport (∈ φ),
    apply cancel_right, assumption
  end

  @[hott] def conjugate_eqv (φ : G.subset) [G ⊵ φ] (n g : G.carrier) :
    @conjugate G n g ∈ φ → @conjugate_rev G n g ∈ φ :=
  begin
    intro h, apply is_normal_subgroup.cosets_eqv,
    apply transport (∈ φ),
    calc g * (g⁻¹ * n) = (g * g⁻¹) * n : Id.inv (G.mul_assoc g g⁻¹ n)
                   ... = e * n         : (* n) # (mul_right_inv g)
                   ... = (g⁻¹ * g) * n : (* n) # (Id.inv $ G.mul_left_inv g)
                   ... = g⁻¹ * (g * n) : G.mul_assoc g⁻¹ g n,
    apply is_normal_subgroup.cosets_eqv, assumption
  end

  def ldiv (φ : G.subset) [G ≥ φ] := λ x y, @left_div G x y ∈ φ
  def rdiv (φ : G.subset) [G ≥ φ] := λ x y, x / y ∈ φ

  @[hott] def inv_x_mul_y_inv (x y : G.carrier) := calc
    (x⁻¹ * y)⁻¹ = y⁻¹ * x⁻¹⁻¹ : by apply inv_explode
            ... = y⁻¹ * x     : (G.φ y⁻¹) # (inv_inv x)

  @[hott] def x_mul_inv_y_inv (x y : G.carrier) := calc
    (x * y⁻¹)⁻¹ = y⁻¹⁻¹ * x⁻¹ : by apply inv_explode
            ... = y * x⁻¹     : (* x⁻¹) # (inv_inv y)

  @[hott] def div_by_unit (x : G.carrier) : x / e = x :=
  begin
    change _ * _ = _,
    transitivity, { apply Id.map, symmetry, apply unit_inv },
    apply monoid.mul_one
  end

  @[hott] def ldiv_by_unit (x : G.carrier) : left_div x e = x⁻¹ :=
  by apply monoid.mul_one

  @[hott] def normal_subgroup_cosets (φ : G.subset) [G ⊵ φ] :
    Π {x y : G.carrier}, ldiv φ x y ↔ rdiv φ x y :=
  begin
    intros x y, split; intro h,
    { change x * y⁻¹ ∈ φ, apply transport (∈ φ),
      calc x * (y⁻¹ * x) * x⁻¹ = x * (y⁻¹ * x * x⁻¹) :
                                 G.mul_assoc x (left_div y x) x⁻¹
                           ... = x * y⁻¹ : (G.φ x) # (Id.inv $ cancel_right y⁻¹ x),
      apply conjugate_eqv,
      apply is_normal_subgroup.conj,
      apply transport (∈ φ), apply inv_x_mul_y_inv,
      apply is_subgroup.inv, assumption },
    { change x⁻¹ * y ∈ φ, apply transport (∈ φ),
      calc x⁻¹ * (y * x⁻¹) * x = x⁻¹ * (y * x⁻¹ * x) :
                                 G.mul_assoc x⁻¹ (y / x) x
                           ... = x⁻¹ * y : (G.φ x⁻¹) # (Id.inv $ cancel_left y x),
      apply is_normal_subgroup.conj, apply transport (∈ φ),
      apply x_mul_inv_y_inv,
      apply is_subgroup.inv, assumption }
  end

  @[hott] noncomputable def cosets_eq (φ : G.subset) [G ⊵ φ] : ldiv φ = rdiv φ :=
  begin
    repeat { apply ground_zero.theorems.funext, intro },
    apply ground_zero.ua.propext,
    repeat { apply ens.prop },
    apply normal_subgroup_cosets
  end

  @[hott] def chain_ldiv (x y z : G.carrier) := calc
          (left_div x y) * (left_div y z)
        = (x⁻¹ * y) * (y⁻¹ * z) : by reflexivity
    ... = x⁻¹ * (y * (y⁻¹ * z)) : (G.mul_assoc x⁻¹ y (y⁻¹ * z))
    ... = x⁻¹ * ((y * y⁻¹) * z) : (G.φ x⁻¹) # (Id.inv $ G.mul_assoc y y⁻¹ z)
    ... = x⁻¹ * (e * z)         :
          begin apply map, apply map (* z),
                apply group.mul_right_inv end
    ... = left_div x z : (λ y, x⁻¹ * y) # (G.one_mul z)

  @[hott] def chain_rdiv (x y z : G.carrier) := calc
    (x / y) * (y / z) = (x * y⁻¹) * (y * z⁻¹) : by reflexivity
                  ... = x * (y⁻¹ * (y * z⁻¹)) : (G.mul_assoc x y⁻¹ (y * z⁻¹))
                  ... = x * ((y⁻¹ * y) * z⁻¹) : (G.φ x) # (Id.inv $ G.mul_assoc y⁻¹ y z⁻¹)
                  ... = x * (e * z⁻¹)         :
                        begin apply map, apply map (* z⁻¹),
                              apply group.mul_left_inv end
                  ... = x / z : (λ y, x * y) # (G.one_mul z⁻¹)

  @[hott] def factor_left_rel (φ : G.subset) [G ≥ φ] :
    G.carrier → G.carrier → Ω :=
  λ x y, ⟨ldiv φ x y, by apply ens.prop⟩

  @[hott] def factor_right_rel (φ : G.subset) [G ≥ φ] :
    G.carrier → G.carrier → Ω :=
  λ x y, ⟨rdiv φ x y, by apply ens.prop⟩

  @[hott] def factor_eqrel_left (φ : G.subset) [G ≥ φ] : eqrel G.carrier :=
  ⟨factor_left_rel φ, begin
    split,
    { intro x, apply transport (∈ φ),
      symmetry, apply group.mul_left_inv,
      apply is_subgroup.unit },
    split,
    { intros x y h, apply transport (∈ φ), apply inv_x_mul_y_inv,
      apply is_subgroup.inv, assumption },
    { intros x y z h g, apply transport (∈ φ),
      apply chain_ldiv x y z, apply is_subgroup.mul;
      assumption }
  end⟩

  @[hott] def factor_eqrel_right (φ : G.subset) [G ≥ φ] : eqrel G.carrier :=
  ⟨factor_right_rel φ, begin
    split,
    { intro x, apply transport (∈ φ),
      symmetry, apply group.mul_right_inv,
      apply is_subgroup.unit },
    split,
    { intros x y h, apply transport (∈ φ), apply x_mul_inv_y_inv,
      apply is_subgroup.inv, assumption },
    { intros x y z h g, apply transport (∈ φ),
      apply chain_rdiv x y z, apply is_subgroup.mul;
      assumption }
  end⟩

  def factor_left (G : group) (φ : G.subset) [G ≥ φ] :=
  HITs.quotient (factor_eqrel_left φ)

  def factor_right (G : group) (φ : G.subset) [G ≥ φ] :=
  HITs.quotient (factor_eqrel_right φ)

  @[hott] noncomputable def factor_symm (φ : G.subset) [G ⊵ φ] :
    factor_left G φ = factor_right G φ :=
  begin
    apply map ground_zero.HITs.quotient, apply ground_zero.eqrel.eq,
    repeat { apply ground_zero.theorems.funext, intro },
    fapply ground_zero.types.sigma.prod,
    { change ldiv φ _ _ = rdiv φ _ _,
      apply HITs.interval.happly,
      apply HITs.interval.happly,
      apply cosets_eq },
    apply prop_is_prop
  end

  def factor.incl {φ : G.subset} [G ⊵ φ] : G.carrier → factor_left G φ :=
  ground_zero.HITs.quotient.elem

  section
    variables {φ : G.subset} [G ⊵ φ]

    @[hott] noncomputable def factor.mul :
      factor_left G φ → factor_left G φ → factor_left G φ :=
    begin
      fapply ground_zero.HITs.quotient.lift₂,
      { intros a b, exact factor.incl (a * b) },
      { apply ground_zero.HITs.quotient.set },
      { intros a b c d p q,
        apply ground_zero.HITs.quotient.sound,
        change _ ∈ φ, apply transport (∈ φ),
        calc b⁻¹ * (a⁻¹ * c * (d * b⁻¹)) * b
           = b⁻¹ * (a⁻¹ * c * d * b⁻¹) * b :
             (λ x, b⁻¹ * x * b) # (Id.inv $ G.mul_assoc (a⁻¹ * c) d b⁻¹)
       ... = b⁻¹ * (a⁻¹ * c * d * b⁻¹ * b) :
             G.mul_assoc b⁻¹ (a⁻¹ * c * d * b⁻¹) b
       ... = b⁻¹ * (a⁻¹ * c * d * (b⁻¹ * b)) :
             (λ x, b⁻¹ * x) # (G.mul_assoc (a⁻¹ * c * d) b⁻¹ b)
       ... = b⁻¹ * (a⁻¹ * c * d * e) :
             @map G.carrier G.carrier _ _ (λ x, b⁻¹ * (a⁻¹ * c * d * x))
               (G.mul_left_inv b)
       ... = b⁻¹ * (a⁻¹ * c * d) :
             (λ x, b⁻¹ * x) # (G.mul_one (a⁻¹ * c * d))
       ... = b⁻¹ * (a⁻¹ * (c * d)) :
             (λ x, b⁻¹ * x) # (G.mul_assoc a⁻¹ c d)
       ... = (b⁻¹ * a⁻¹) * (c * d) :
             (Id.inv $ G.mul_assoc b⁻¹ a⁻¹ (c * d))
       ... = left_div (a * b) (c * d) :
             (* (c * d)) # (Id.inv $ inv_explode a b),
        apply is_normal_subgroup.conj,
        apply is_subgroup.mul,
        { exact p },
        { apply transport (∈ φ), calc
            (b * d⁻¹)⁻¹ = d⁻¹⁻¹ * b⁻¹ : inv_explode b d⁻¹
                    ... = d * b⁻¹ : (* b⁻¹) # (inv_inv d),
          apply is_subgroup.inv,
          apply (normal_subgroup_cosets φ).left,
          exact q } }
    end

    noncomputable instance : has_mul (factor_left G φ) :=
    ⟨factor.mul⟩

    @[hott] def factor.one : factor_left G φ := factor.incl e
    instance : has_one (factor_left G φ) := ⟨factor.one⟩

    @[hott] noncomputable def factor.mul_one (x : factor_left G φ) :
      factor.mul x 1 = x :=
    begin
      fapply ground_zero.HITs.quotient.ind_prop _ _ x; clear x,
      { intro x, apply ground_zero.HITs.quotient.sound,
        apply transport (∈ φ), calc
            e = x⁻¹ * x       : Id.inv (G.mul_left_inv x)
          ... = e * x⁻¹ * x   : (* x) # (Id.inv $ G.one_mul x⁻¹)
          ... = e⁻¹ * x⁻¹ * x : (λ y, y * x⁻¹ * x) # unit_inv
          ... = (x * e)⁻¹ * x : (* x) # (Id.inv $ inv_explode x e),
        apply is_subgroup.unit },
      { intros, apply ground_zero.HITs.quotient.set }
    end

    @[hott] noncomputable def factor.one_mul (x : factor_left G φ) :
      factor.mul 1 x = x :=
    begin
      fapply ground_zero.HITs.quotient.ind_prop _ _ x; clear x,
      { intro x, change ground_zero.HITs.quotient.elem _ = _,
        apply map, apply monoid.one_mul },
      { intros, apply ground_zero.HITs.quotient.set }
    end

    @[hott] noncomputable def factor.assoc (x y z : factor_left G φ) :
      factor.mul (factor.mul x y) z = factor.mul x (factor.mul y z) :=
    begin
      fapply ground_zero.HITs.quotient.ind_prop _ _ x; clear x,
      { fapply ground_zero.HITs.quotient.ind_prop _ _ y; clear y,
        { fapply ground_zero.HITs.quotient.ind_prop _ _ z; clear z,
          { intros z y x, change ground_zero.HITs.quotient.elem _ = _,
            apply map, apply semigroup.mul_assoc },
          { repeat { intros, apply ground_zero.structures.pi_prop },
            intros, apply ground_zero.HITs.quotient.set } },
        { intros, apply ground_zero.structures.pi_prop,
          intros, apply ground_zero.HITs.quotient.set } },
      { intros, apply ground_zero.HITs.quotient.set }
    end

    @[hott] noncomputable def factor.inv (x : factor_left G φ) : factor_left G φ :=
    begin
      apply ground_zero.HITs.quotient.rec _ _ _ x; clear x,
      { intro x, exact factor.incl x⁻¹ },
      { intros u v H, apply ground_zero.HITs.quotient.sound,
        apply transport (∈ φ), { symmetry, apply map (* v⁻¹), apply inv_inv },
        apply (normal_subgroup_cosets φ).left, exact H },
      { apply ground_zero.HITs.quotient.set }
    end
    noncomputable instance : has_inv (factor_left G φ) := ⟨factor.inv⟩

    @[hott] noncomputable def factor.left_inv (x : factor_left G φ) :
      factor.mul (factor.inv x) x = 1 :=
    begin
      fapply ground_zero.HITs.quotient.ind_prop _ _ x; clear x,
      { intro x, change ground_zero.HITs.quotient.elem _ = _,
        apply map, apply mul_left_inv },
      { intros, apply ground_zero.HITs.quotient.set }
    end

    @[hott] noncomputable def factor (G : group) (φ : G.subset) [G ⊵ φ] : group :=
    ⟨⟨⟨⟨@zeroeqv (factor_left G φ) (λ _ _, HITs.quotient.set), factor.mul⟩, factor.assoc⟩,
      factor.one, @factor.one_mul G φ _, factor.mul_one⟩,
      factor.inv, factor.left_inv⟩
  end
  infix \ := factor

  @[hott] def factor.sound {φ : G.subset} [G ⊵ φ]
    {x : G.carrier} (H : x ∈ φ) : factor.incl x = 1 :> factor_left G φ :=
  begin
    apply HITs.quotient.sound, apply transport (∈ φ),
    { symmetry, apply ldiv_by_unit },
    apply is_subgroup.inv, assumption
  end

  section
    variables {H : group} (φ : G ⤳ H)
    local infix × : 70 := H.φ

    @[hott] def homo_saves_unit : φ.fst G.e = H.e :=
    begin
      cases φ with φ p, apply unit_of_sqr, calc
        φ G.e × φ G.e = φ (G.e * G.e) : Id.inv (p G.e G.e)
                  ... = φ G.e         : φ # (Id.inv unit_sqr)
    end

    @[hott] def homo_respects_inv (x : G.carrier) : φ.fst x⁻¹ = H.inv (φ.fst x) :=
    begin
      cases φ with φ p, calc
        φ x⁻¹ = φ x⁻¹ × H.e                 : Id.inv (H.mul_one (φ x⁻¹))
          ... = φ x⁻¹ × (φ x × H.inv (φ x)) : (λ y, φ x⁻¹ × y) # (Id.inv $ mul_right_inv (φ x))
          ... = φ x⁻¹ × φ x × H.inv (φ x)   : Id.inv (H.mul_assoc _ _ _)
          ... = φ (x⁻¹ * x) × H.inv (φ x)   : (× H.inv (φ x)) # (Id.inv $ p x⁻¹ x)
          ... = φ G.e × H.inv (φ x)         : (λ y, φ y × H.inv (φ x)) # (G.mul_left_inv x)
          ... = H.e × H.inv (φ x)           : (× H.inv (φ x)) # (homo_saves_unit ⟨φ, p⟩)
          ... = H.inv (φ x)                 : H.one_mul (H.inv $ φ x)
    end

    @[hott] def homo_respects_div (x y : G.carrier) :
      φ.fst (x / y) = right_div (φ.fst x) (φ.fst y) :=
    begin
      cases φ with φ p, calc
        φ (x / y) = φ x × φ y⁻¹       : p x y⁻¹
              ... = φ x × H.inv (φ y) : (λ y, φ x × y) # (homo_respects_inv ⟨φ, p⟩ y)
    end

    @[hott] instance ker_is_subgroup : G ≥ ker φ :=
    { unit := by apply homo_saves_unit,
      mul := begin
        intros a b h g, change _ = _,
        transitivity, { apply φ.snd }, symmetry,
        transitivity, { apply unit_sqr },
        apply mul_uniq, exact Id.inv h, exact Id.inv g
      end,
      inv := begin
        intros x h, change _ = _,
        cases φ with φ p, calc
          φ x⁻¹ = H.inv (φ x) : homo_respects_inv ⟨φ, p⟩ x
            ... = H.inv H.e   : H.inv # h
            ... = H.e         : Id.inv unit_inv
      end }

    @[hott] instance ker_is_normal_subgroup : G ⊵ ker φ :=
    begin
      apply is_normal_subgroup.mk, intros n g p, cases φ with φ q,
      change _ = _ at p, have r := Id.inv (q n g) ⬝ p, calc
        φ (g * n) = φ g × φ n         : q g n
              ... = φ g × H.inv (φ g) : (λ y, φ g × y) # (eq_inv_of_mul_eq_one r)
              ... = H.e               : by apply mul_right_inv
    end

    @[hott] instance im_is_subgroup : H ≥ im φ.fst :=
    { unit := HITs.merely.elem ⟨e, homo_saves_unit φ⟩,
      mul := begin
        intros a b p q, fapply HITs.merely.rec _ _ p,
        { apply HITs.merely.uniq },
        { intro r,
          { fapply HITs.merely.rec _ _ q,
            { apply HITs.merely.uniq },
            { intro s, induction r with x r,
              induction s with y s,
              apply HITs.merely.elem,
              existsi (x * y), transitivity, apply φ.snd,
              induction r, induction s, trivial } } }
      end,
      inv := begin
        intros x p, fapply HITs.merely.rec _ _ p,
        { apply HITs.merely.uniq },
        { intro q, apply HITs.merely.elem,
          induction q with y q, existsi y⁻¹,
          transitivity, apply homo_respects_inv,
          apply map, assumption }
      end }
  end

  -- Of course, this can be done by induction
  @[hott] def homo.of_path {G H : group} (φ : G.carrier = H.carrier)
    (p : G.φ =[λ G, G → G → G, φ] H.φ) : G ⤳ H :=
  begin
    fapply sigma.mk, exact @transport _ (λ G, G) G.carrier H.carrier φ,
    intros a b, transitivity, apply Id.map, apply equiv.bimap,
    iterate 2 { symmetry, apply @equiv.transport_forward_and_back _ (λ G, G) _ _ φ },
    transitivity, symmetry, apply equiv.transport_over_operation_pointwise G.φ,
    iterate 2 { apply HITs.interval.happly }, exact p
  end

  -- This statement in fact says that two groups are equal
  -- if their multiplication tables are equal
  @[hott] def table {G H : group} (φ : G.carrier = H.carrier)
    (p : G.φ =[λ G, G → G → G, φ] H.φ) : G = H :=
  begin
    fapply group.ext, exact φ, exact p,
    { apply homo_saves_unit (homo.of_path φ p) },
    { apply theorems.funext, intro x,
      transitivity, apply equiv.transport_over_morphism_pointwise,
      transitivity, apply homo_respects_inv (homo.of_path φ p),
      apply Id.map, apply @equiv.transport_back_and_forward _ (λ G, G) _ _ φ }
  end

  @[hott] noncomputable def iso.ua {G H : group} (φ : G ≅ H) : G = H :=
  begin
    induction φ with φ p, induction p with p q,
    fapply group.table, apply ground_zero.ua,
    apply iso.to_equiv, exact ⟨φ, (p, q)⟩,
    { apply Id.trans, apply equiv.transport_over_operation,
      apply theorems.funext, intro a,
      apply theorems.funext, intro b,
      transitivity, apply ua.transport_rule,
      transitivity, apply p, apply equiv.bimap;
      { transitivity, apply Id.map,
        transitivity, apply equiv.subst_over_inv_path,
        apply ua.transport_inv_rule,
        apply equiv.forward_left ⟨φ, q⟩ } }
  end

  @[hott] def factor.lift {H : group} (f : G ⤳ H) {φ : G.subset} [G ⊵ φ]
    (p : Π x, x ∈ φ → f.fst x = H.e) : factor_left G φ → H.carrier :=
  begin
    fapply HITs.quotient.rec,
    { exact f.fst },
    { intros x y q, apply eq_of_div_eq, transitivity,
      { change H.φ _ _ = _, apply Id.map (λ x, H.φ x (f.fst y)),
        symmetry, apply homo_respects_inv },
      transitivity, { symmetry, apply f.snd },
      apply p, apply q },
    { intros a b, apply H.set }
  end

  section
    variables {φ : G.subset} [G ≥ φ]
    include G

    @[hott] def subgroup.mul (x y : φ.subtype) : φ.subtype :=
    begin
      induction x with x p, induction y with y q,
      existsi (x * y), apply is_subgroup.mul; assumption
    end
    local infix ` ∗ `:70 := @subgroup.mul G φ _

    @[hott] def subgroup.inv (x : φ.subtype) : φ.subtype :=
    begin
      induction x with x H, existsi x⁻¹,
      apply is_subgroup.inv, assumption
    end

    @[hott] def subgroup.unit : φ.subtype := ⟨e, is_subgroup.unit⟩

    @[hott] def subgroup.ens : hset φ.subtype :=
    begin apply ens.hset, intros a b, apply G.set end

    @[hott] def subgroup.mul_assoc (x y z : φ.subtype) : x ∗ y ∗ z = x ∗ (y ∗ z) :=
    begin
      induction x with x A, induction y with y B, induction z with z C,
      fapply ground_zero.types.sigma.prod,
      apply semigroup.mul_assoc, apply φ.snd
    end

    @[hott] def subgroup.one_mul (x : φ.subtype) : subgroup.unit ∗ x = x :=
    begin
      induction x with x H,
      fapply ground_zero.types.sigma.prod,
      apply monoid.one_mul, apply φ.snd
    end

    @[hott] def subgroup.mul_one (x : φ.subtype) : x ∗ subgroup.unit = x :=
    begin
      induction x with x H,
      fapply ground_zero.types.sigma.prod,
      apply monoid.mul_one, apply φ.snd
    end

    @[hott] def subgroup.mul_left_inv (x : φ.subtype) :
      subgroup.inv x ∗ x = subgroup.unit :=
    begin
      induction x with x H,
      fapply ground_zero.types.sigma.prod,
      apply group.mul_left_inv, apply φ.snd
    end

    @[hott] def subgroup.group (G : group)
      (φ : G.subset) [G ≥ φ] : group :=
    ⟨⟨⟨⟨zeroeqv (λ _ _, subgroup.ens), subgroup.mul⟩, subgroup.mul_assoc⟩,
      subgroup.unit, subgroup.one_mul, subgroup.mul_one⟩,
      subgroup.inv, @subgroup.mul_left_inv G φ _⟩
  end

  @[hott] def subgroup.ext (φ ψ : G.subset) [G ≥ φ] [G ≥ ψ] :
    φ = ψ → subgroup.group G φ = subgroup.group G ψ :=
  begin
    intro p, tactic.unfreeze_local_instances, induction p,
    apply types.Id.map, apply is_subgroup.prop
  end

  @[hott] def subgroup.inter (φ ψ : G.subset)
    [G ≥ φ] [G ≥ ψ] : ens ψ.subtype :=
  ⟨λ x, x.fst ∈ φ, λ x, ens.prop x.fst φ⟩

  @[hott] instance subgroup_subgroup (φ ψ : G.subset)
    [G ≥ φ] [G ≥ ψ] : subgroup.group G ψ ≥ subgroup.inter φ ψ :=
  begin
    split, { change e ∈ φ, apply is_subgroup.unit },
    { intros a b G H, induction a with a g,
      induction b with b h, change _ ∈ φ,
      apply is_subgroup.mul; assumption },
    { intros a G, induction a with a g,
      change _ ∈ φ, apply is_subgroup.inv,
      assumption }
  end

  @[hott] def abelian_subgroup_is_normal (G : group) [abelian G]
    (φ : G.subset) [G ≥ φ] : G ⊵ φ :=
  begin split, intros g h p, apply transport (∈ φ), apply abelian.mul_comm, assumption end

  @[hott] instance abelian_subgroup_is_abelian (G : group) [abelian G]
    (φ : G.subset) [G ≥ φ] : abelian (subgroup.group G φ) :=
  begin
    split, intros a b, induction a with a p, induction b with b q,
    fapply sigma.prod, apply abelian.mul_comm, apply φ.snd
  end

  @[hott] def homo.surj (φ : G.subset) [G ≥ φ] : subgroup.group G φ ⤳ G :=
  ⟨sigma.fst, λ ⟨a, _⟩ ⟨b, _⟩, idp (a * b)⟩

  inductive D₃.carrier
  | R₀ | R₁ | R₂
  | S₀ | S₁ | S₂
  open D₃.carrier

  @[hott] def D₃.inv : D₃.carrier → D₃.carrier
  | R₀ := R₀ | R₁ := R₂ | R₂ := R₁
  | S₀ := S₀ | S₁ := S₁ | S₂ := S₂

  @[hott] def D₃.mul : D₃.carrier → D₃.carrier → D₃.carrier
  | R₀ R₀ := R₀ | R₀ R₁ := R₁ | R₀ R₂ := R₂
  | R₀ S₀ := S₀ | R₀ S₁ := S₁ | R₀ S₂ := S₂
  | R₁ R₀ := R₁ | R₁ R₁ := R₂ | R₁ R₂ := R₀
  | R₁ S₀ := S₁ | R₁ S₁ := S₂ | R₁ S₂ := S₀
  | R₂ R₀ := R₂ | R₂ R₁ := R₀ | R₂ R₂ := R₁
  | R₂ S₀ := S₂ | R₂ S₁ := S₀ | R₂ S₂ := S₁
  | S₀ R₀ := S₀ | S₀ R₁ := S₂ | S₀ R₂ := S₁
  | S₀ S₀ := R₀ | S₀ S₁ := R₂ | S₀ S₂ := R₁
  | S₁ R₀ := S₁ | S₁ R₁ := S₀ | S₁ R₂ := S₂
  | S₁ S₀ := R₁ | S₁ S₁ := R₀ | S₁ S₂ := R₂
  | S₂ R₀ := S₂ | S₂ R₁ := S₁ | S₂ R₂ := S₀
  | S₂ S₀ := R₂ | S₂ S₁ := R₁ | S₂ S₂ := R₀

  @[hott] instance D₃.has_one : has_one D₃.carrier := ⟨R₀⟩
  @[hott] instance D₃.has_inv : has_inv D₃.carrier := ⟨D₃.inv⟩
  @[hott] instance D₃.has_mul : has_mul D₃.carrier := ⟨D₃.mul⟩

  def D₃.elim {β : Type u} : β → β → β → β → β → β → D₃.carrier → β :=
  @D₃.carrier.rec (λ _, β)

  @[hott] def D₃.magma : magma :=
  begin
    fapply magma.mk, fapply zeroeqv, exact D₃.carrier,
    apply ground_zero.structures.Hedberg,
    intros x y, induction x; induction y;
    try { apply sum.inl, refl },
    repeat { apply sum.inr, intro p, apply ff_neq_tt, symmetry },
    repeat { apply (D₃.elim tt ff ff ff ff ff) # p },
    repeat { apply (D₃.elim ff tt ff ff ff ff) # p },
    repeat { apply (D₃.elim ff ff tt ff ff ff) # p },
    repeat { apply (D₃.elim ff ff ff tt ff ff) # p },
    repeat { apply (D₃.elim ff ff ff ff tt ff) # p },
    repeat { apply (D₃.elim ff ff ff ff ff tt) # p },
    exact D₃.mul
  end

  @[hott] def D₃.semigroup : semigroup :=
  ⟨D₃.magma, (begin intros a b c, induction a; induction b; induction c; trivial end)⟩

  @[hott] def D₃.monoid : monoid :=
  ⟨D₃.semigroup, R₀,
   begin intro a; induction a; trivial end,
   begin intro a; induction a; trivial end⟩

  @[hott] def D₃ : group :=
  ⟨D₃.monoid, D₃.inv, begin intro a, induction a; trivial end⟩

  @[hott] def A₃ : D₃.subset :=
  ⟨D₃.elim 𝟏 𝟏 𝟏 𝟎 𝟎 𝟎, begin
    intros x, induction x,
    repeat { apply ground_zero.structures.unit_is_prop },
    repeat { apply ground_zero.structures.empty_is_prop }
  end⟩

  @[hott] instance A₃.subgroup : D₃ ≥ A₃ :=
  begin
    split, { apply ★ },
    { intros a b p q, induction a; induction b;
      induction p; induction q; apply ★ },
    { intros a p, induction a; induction p; apply ★ }
  end

  @[hott] instance A₃.normal_subgroup : D₃ ⊵ A₃ :=
  begin
    split, intros g h p; induction g; induction h;
    induction p; apply ★
  end

  def Z₂.carrier := bool
  def Z₂.mul     := bxor
  def Z₂.inv     := @ground_zero.proto.idfun Z₂.carrier

  @[hott] instance Z₂.has_one : has_one Z₂.carrier := ⟨ff⟩
  @[hott] instance Z₂.has_inv : has_inv Z₂.carrier := ⟨Z₂.inv⟩
  @[hott] instance Z₂.has_mul : has_mul Z₂.carrier := ⟨Z₂.mul⟩

  @[hott] def Z₂.set : hset Z₂.carrier :=
  begin
    apply ground_zero.structures.Hedberg,
    intros x y, induction x; induction y; try { apply sum.inl, refl },
    repeat { apply sum.inr, intro p, apply ff_neq_tt },
    exact p, exact Id.inv p
  end

  @[hott] def Z₂.magma : magma :=
  begin fapply magma.mk, fapply @zeroeqv Z₂.carrier, intros p q, exact Z₂.set, exact Z₂.mul end

  @[hott] def Z₂.semigroup : semigroup :=
  ⟨Z₂.magma, begin intros a b c, induction a; induction b; induction c; trivial end⟩

  @[hott] def Z₂.monoid : monoid :=
  ⟨Z₂.semigroup, ff,
    begin intro a; induction a; trivial end,
    begin intro a; induction a; trivial end⟩

  @[hott] def Z₂ : group :=
  ⟨Z₂.monoid, Z₂.inv, begin intro a, induction a; trivial end⟩

  def D₃.inj : D₃.carrier → factor_left D₃ A₃ := @factor.incl D₃ A₃ _

  @[hott] def Z₂.encode : Z₂.carrier → factor_left D₃ A₃
  | ff := D₃.inj R₀
  | tt := D₃.inj S₀

  @[hott] def Z₂.decode : factor_left D₃ A₃ → Z₂.carrier :=
  begin
    fapply ground_zero.HITs.quotient.rec,
    { exact D₃.elim ff ff ff tt tt tt },
    { intros x y H; induction x; induction y; induction H; trivial },
    { intros a b, apply Z₂.set }
  end

  @[hott] noncomputable def Z₂.iso : Z₂ ≅ D₃\A₃ :=
  begin
    existsi Z₂.encode, split,
    { intros x y, induction x; induction y; trivial },
    split; existsi Z₂.decode,
    { intro x, induction x; trivial },
    { fapply HITs.quotient.ind,
      { intro x, induction x; apply HITs.quotient.sound; exact ★ },
      { intros x y H, apply HITs.quotient.set },
      { intro x, apply structures.prop_is_set,
        apply HITs.quotient.set } }
  end

  @[hott] def triv (G : group) : G.subset :=
  ⟨λ x, G.e = x, begin intro x, apply G.set end⟩

  @[hott] instance triv.subgroup : G ≥ triv G :=
  begin
    split, { change _ = _, reflexivity },
    { intros a b p q,
      change _ = _ at p, change _ = _ at q,
      induction p, induction q,
      change _ = _, symmetry,
      apply monoid.mul_one },
    { intros a p, change _ = _ at p,
      induction p, change _ = _,
      apply unit_inv }
  end

  @[hott] instance triv.normal_subgroup : G ⊵ triv G :=
  begin
    split, intros g h p, change _ = _ at p,
    change _ = _, apply @mul_cancel_left G _ _ g,
    transitivity, apply monoid.mul_one,
    transitivity, { symmetry, apply G.one_mul },
    symmetry, transitivity, { symmetry, apply semigroup.mul_assoc },
    symmetry, apply Id.map (* g),
    assumption
  end

  @[hott] def triv.encode : G.carrier → factor_left G (triv G) := factor.incl
  @[hott] def triv.decode : factor_left G (triv G) → G.carrier :=
  begin
    fapply HITs.quotient.rec,
    exact id,
    { intros x y p, change _ = _ * _ at p,
      apply inv_inj, apply eq_inv_of_mul_eq_one,
      exact Id.inv p },
    intros a b, apply G.set
  end

  @[hott] noncomputable def triv.factor : G ≅ G\triv G :=
  begin
    existsi triv.encode, split,
    { intros x y, reflexivity },
    split; existsi triv.decode,
    { intro x, reflexivity },
    { fapply HITs.quotient.ind_prop; intro x,
      { reflexivity }, { apply HITs.quotient.set } }
  end

  inductive exp (α : Type u)
  | unit {} : exp
  | elem {} : α → exp
  | mul  {} : exp → exp → exp
  | inv  {} : exp → exp

  namespace exp
    @[hott] def eval {α : Type u} (G : group)
      (f : α → G.carrier) : exp α → G.carrier
    | unit      := G.e
    | (elem x)  := f x
    | (mul x y) := G.φ (eval x) (eval y)
    | (inv x)   := G.inv (eval x)
  end exp

  private structure F.aux (α : Type u) :=
  (val : exp α)

  def F.carrier (α : Type u) := F.aux α

  namespace F
    variables {ε : Type u}
    attribute [nothott] F.aux.rec_on F.aux.rec aux.val

    @[hott] def unit : F.carrier ε := ⟨exp.unit⟩
    @[hott] def elem : ε → F.carrier ε := λ x, ⟨exp.elem x⟩

    @[safe] def mul (x y : F.carrier ε) : F.carrier ε := ⟨exp.mul x.val y.val⟩
    @[safe] def inv (x : F.carrier ε)   : F.carrier ε := ⟨exp.inv x.val⟩

    instance : has_one (F.carrier ε) := ⟨unit⟩
    instance : has_mul (F.carrier ε) := ⟨mul⟩
    instance : has_inv (F.carrier ε) := ⟨inv⟩

    local infix ` ∗ `:50 := has_mul.mul
    axiom mul_assoc (a b c : F.carrier ε) : mul (mul a b) c = mul a (mul b c)
    axiom one_mul       (a : F.carrier ε) : mul unit a = a
    axiom mul_one       (a : F.carrier ε) : mul a unit = a
    axiom mul_left_inv  (a : F.carrier ε) : mul (inv a) a = unit

    axiom ens : hset (F.carrier ε)

    @[safe] def rec (G : group) (f : ε → G.carrier) (x : F.carrier ε) :=
    exp.eval G f x.val

    @[safe] def ind {π : F.carrier ε → Type v}
      (setπ : Π x, hset (π x))
      (u : π unit) (η : Π {x}, π (elem x))
      (m : Π {x y}, π x → π y → π (mul x y))
      (i : Π {x}, π x → π (inv x))
      (mul_assoc : Π {x y z : F.carrier ε} (a : π x) (b : π y) (c : π z),
        m (m a b) c =[mul_assoc x y z] m a (m b c))
      (one_mul : Π {x : F.carrier ε} (a : π x), m u a =[one_mul x] a)
      (mul_one : Π {x : F.carrier ε} (a : π x), m a u =[mul_one x] a)
      (mul_left_inv : Π {x : F.carrier ε} (a : π x),
        m (i a) a =[mul_left_inv x] u) : Π x, π x :=
    begin
      intro x, cases x, induction x with x x y u v x u,
      { exact u }, { apply η }, { apply m u v }, { apply i u }
    end

    attribute [irreducible] F.carrier

    noncomputable def magma : magma :=
    ⟨zeroeqv (λ _ _, F.ens), @F.mul ε⟩

    noncomputable def semigroup : semigroup :=
    ⟨F.magma, @mul_assoc ε⟩

    noncomputable def monoid : monoid :=
    ⟨F.semigroup, unit, one_mul, @mul_one ε⟩
  end F

  noncomputable def F (ε : Type u) : group :=
  ⟨F.monoid, F.inv, @F.mul_left_inv ε⟩

  namespace F
    variables {ε : Type u}
    @[hott] def rec_mul (f : ε → G.carrier) (x y : F.carrier ε) :
      rec G f (mul x y) = rec G f x * rec G f y :=
    by reflexivity

    @[hott] def rec_inv (f : ε → G.carrier) (x : F.carrier ε) :
      rec G f (inv x) = (rec G f x)⁻¹ :=
    by reflexivity

    @[hott] def rec_one (f : ε → G.carrier) : rec G f unit = e :=
    by reflexivity

    @[hott] def homomorphism (f : ε → G.carrier) : F ε ⤳ G :=
    ⟨rec G f, rec_mul f⟩

    noncomputable def recβrule₁ {a b c : F.carrier ε} (f : ε → G.carrier) :
      rec G f # (mul_assoc a b c) =
        G.mul_assoc (rec G f a) (rec G f b) (rec G f c) :=
    by apply G.set
    noncomputable def recβrule₂ {a : F.carrier ε} (f : ε → G.carrier) :
      rec G f # (one_mul a) = G.one_mul (rec G f a) :=
    by apply G.set
    noncomputable def recβrule₃ {a : F.carrier ε} (f : ε → G.carrier) :
      rec G f # (mul_one a) = G.mul_one (rec G f a) :=
    by apply G.set
    noncomputable def recβrule₄ {a : F.carrier ε} (f : ε → G.carrier) :
      rec G f # (mul_left_inv a) = G.mul_left_inv (rec G f a) :=
    by apply G.set

    @[hott] noncomputable def ind_prop {π : F.carrier ε → Type v}
      (propπ : Π x, prop (π x))
      (u : π unit) (η : Π {x}, π (elem x))
      (m : Π {x y}, π x → π y → π (mul x y))
      (i : Π {x}, π x → π (inv x)) : Π x, π x :=
    begin
      fapply ind, { intro x, apply prop_is_set, apply propπ },
      { exact u },
      { intro x, apply η },
      { intros x y u v, apply m u v },
      { intros x u, apply i u },
      repeat { intros, apply propπ }
    end
  end F

  @[hott] def zentrum (G : group.{u}) : G.subset :=
  ⟨λ z, Π g, G.φ z g = G.φ g z, begin
    intros x p q, apply theorems.funext,
    intro y, apply G.set
  end⟩

  @[hott] instance zentrum_is_subgroup : G ≥ zentrum G :=
  begin
    split,
    { intro x, transitivity,
      { apply monoid.one_mul },
      { symmetry, apply monoid.mul_one } },
    { intros a b g h c, symmetry, calc
        c * (a * b) = (c * a) * b : Id.inv (G.mul_assoc _ _ _)
                ... = (a * c) * b : (* b) # (Id.inv $ g c)
                ... = a * (c * b) : G.mul_assoc _ _ _
                ... = a * (b * c) : (G.φ a) # (Id.inv $ h c)
                ... = a * b * c   : Id.inv (G.mul_assoc _ _ _) },
    { intros a g b, calc
      a⁻¹ * b = a⁻¹ * b⁻¹⁻¹ : (G.φ a⁻¹) # (Id.inv $ inv_inv b)
          ... = (b⁻¹ * a)⁻¹ : Id.inv (inv_explode _ _)
          ... = (a * b⁻¹)⁻¹ : G.inv # (Id.inv $ g b⁻¹)
          ... = b⁻¹⁻¹ * a⁻¹ : inv_explode _ _
          ... = b * a⁻¹     : (* a⁻¹) # (inv_inv b) }
  end

  @[hott] instance zentrum_is_normal : G ⊵ zentrum G :=
  begin
    split, intros g h r z,
    have p := Id.inv (G.mul_assoc g h g) ⬝ r g,
    have q := mul_cancel_left p,
    transitivity, { apply map (* z), apply q },
    symmetry, transitivity, { apply map (G.φ z), apply q },
    symmetry, apply r
  end

  @[hott] instance univ_is_subgroup : G ≥ G.univ :=
  begin split; intros; apply ★ end

  @[hott] instance univ_is_normal : G ⊵ G.univ :=
  begin split, intros, apply ★ end

  @[hott] def univ_iso (G : group) : G ≅ subgroup.group G G.univ :=
  begin
    fapply sigma.mk, { intro x, existsi x, exact ★ }, split,
    { intros x y, reflexivity }, apply types.qinv.to_biinv,
    fapply sigma.mk, { apply sigma.fst }, split; intro x,
    { induction x with x z, induction z, reflexivity }, { reflexivity }
  end

  @[hott] instance Z₁.has_mul : has_mul 𝟏 :=
  begin split, intros, apply ★ end

  @[hott] def Z₁.magma : magma :=
  ⟨zeroeqv (λ _ _, unit_is_set), @has_mul.mul 𝟏 _⟩

  @[hott] def Z₁.semigroup : semigroup :=
  ⟨Z₁.magma, begin intros, reflexivity end⟩

  @[hott] instance Z₁.has_one : has_one 𝟏 := ⟨★⟩

  @[hott] def Z₁.monoid : monoid :=
  ⟨Z₁.semigroup, ★,
    begin intro x, induction x, reflexivity end,
    begin intro x, induction x, reflexivity end⟩

  @[hott] instance Z₁.has_inv : has_inv 𝟏 := ⟨λ _, ★⟩

  @[hott] def Z₁ : group :=
  ⟨Z₁.monoid, λ _, ★, begin intros x, reflexivity end⟩

  @[hott] instance Z₁.abelian : abelian Z₁ :=
  ⟨begin intros x y, reflexivity end⟩

  def univ.decode : 𝟏 → factor_left G G.univ := λ _, 1

  @[hott] noncomputable def univ_contr :
    contr (factor_left G G.univ) :=
  begin
    existsi univ.decode ★,
    fapply HITs.quotient.ind_prop; intro x,
    { apply HITs.quotient.sound, apply ★ },
    { apply HITs.quotient.set }
  end

  @[hott] noncomputable def univ_prop :
    prop (factor_left G G.univ) :=
  contr_impl_prop univ_contr

  @[hott] noncomputable def univ_factor : Z₁ ≅ G\G.univ :=
  begin
    existsi univ.decode, split,
    { intros x y, apply univ_prop },
    split; existsi (λ _, ★); intro x,
    apply unit_is_prop, apply univ_prop
  end

  @[hott] def identity.ens {α : Type u} (H : hset α) : hset (identity α) :=
  begin apply hset_respects_equiv, apply equiv.identity_eqv, assumption end

  section
    variables {H : group}
    local infix ` × `:50 := H.φ

    @[hott] def ker.encode {φ : G ⤳ H} : factor_left G (ker φ) → im.carrier φ :=
    begin
      fapply HITs.quotient.rec,
      { intro x, existsi φ.fst x, apply HITs.merely.elem,
        existsi x, trivial },
      { intros x y p, fapply sigma.prod,
        change _ = _ at p, transitivity,
        { symmetry, apply inv_inv },
        apply inv_eq_of_mul_eq_one, transitivity,
        { apply map (× φ.fst y), symmetry, apply homo_respects_inv },
        transitivity, { symmetry, apply φ.snd }, apply p,
        apply HITs.merely.uniq },
      { apply ens.hset, intros a b, apply H.set }
    end
  
    @[hott] noncomputable def ker.encode_inj {φ : G ⤳ H} :
      Π (x y : factor_left G (ker φ)),
        ker.encode x = ker.encode y → x = y :=
    begin
      intros x y, fapply ground_zero.HITs.quotient.ind_prop _ _ x; clear x; intro x,
      { fapply ground_zero.HITs.quotient.ind_prop _ _ y; clear y; intro y,
        { intro p, apply ground_zero.HITs.quotient.sound,
          change _ = _, transitivity, apply φ.snd,
          transitivity, { apply Id.map (× φ.fst y), apply homo_respects_inv },
          apply mul_eq_one_of_inv_eq,
          transitivity, apply inv_inv,
          apply (sigma.sigma_eq_of_eq p).fst },
        { apply impl_prop, apply HITs.quotient.set } },
      { apply impl_prop, apply HITs.quotient.set }
    end
  
    @[hott] noncomputable def ker.decode_sigma {φ : G ⤳ H} :
      Π (x : im.carrier φ), (Σ (y : factor_left G (ker φ)), ker.encode y = x) :=
    begin
      intro x, induction x with x p,
      fapply ground_zero.HITs.merely.ind _ _ p; intro z,
      { induction z with z q, existsi factor.incl z,
        fapply ground_zero.types.sigma.prod, apply q,
        apply HITs.merely.uniq },
      { intros u v, induction u with u q, induction v with v G,
        fapply ground_zero.types.sigma.prod,
        { apply ker.encode_inj, transitivity, exact q,
          symmetry, exact G },
        { apply ens.hset, intros a b, apply H.set } }
    end
  
    @[hott] noncomputable def ker.decode {φ : G ⤳ H}
      (x : im.carrier φ) : factor_left G (ker φ) :=
    (ker.decode_sigma x).fst
  
    @[hott] def Im (φ : G ⤳ H) : group :=
    subgroup.group H (im φ.fst)

    -- First isomorphism theorem.
    @[hott] noncomputable def first_iso_theorem
      {φ : G ⤳ H} : Im φ ≅ G\ker φ :=
    begin
      existsi ker.decode, split,
      { intros a b, induction a with a A, induction b with b B,
        change ∥_∥ at A, change ∥_∥ at B,
        fapply ground_zero.HITs.merely.ind _ _ A; clear A; intro A,
        { fapply ground_zero.HITs.merely.ind _ _ B; clear B; intro B,
          { induction A, induction B, reflexivity },
          { apply HITs.quotient.set } },
        { apply HITs.quotient.set } },
      split; existsi ker.encode,
      { intro x, apply (ker.decode_sigma x).snd },
      { fapply ground_zero.HITs.quotient.ind_prop; intro x,
        { trivial }, { apply HITs.quotient.set } }
    end
  end

  @[hott] instance inter_subgroup (φ ψ : ens G.carrier)
    [G ≥ φ] [G ≥ ψ] : G ≥ φ ∩ ψ :=
  begin
    split, { split; apply is_subgroup.unit },
    { intros a b p q,
      induction p with p₁ p₂,
      induction q with q₁ q₂,
      split; apply is_subgroup.mul; assumption },
    { intros a h, induction h with u v,
      split; apply is_subgroup.inv; assumption }
  end

  @[hott] def mul (φ ψ : G.subset) : G.subset :=
  ⟨λ a, ∥(Σ x y, x ∈ φ × y ∈ ψ × x * y = a)∥, λ _, HITs.merely.uniq⟩

  -- Permutations
  @[hott] def S.carrier (α : 0-Type) := α.fst ≃ α.fst

  @[hott] def S.equiv (α β : 0-Type) : 0-Type :=
  @zeroeqv (α.fst ≃ β.fst) (begin
    apply theorems.prop.hset_equiv,
    apply zero_eqv_set.forward,
    exact β.snd
  end)
  infix ` ≃₀ `:25 := S.equiv

  section
    variables {ε : 0-Type}
    @[hott] def S.mul (p q : S.carrier ε) := equiv.trans q p
    @[hott] def S.one                     := equiv.id ε.fst
    @[hott] def S.inv (p : S.carrier ε)   := equiv.symm p

    @[hott] instance S.has_mul : has_mul (S.carrier ε) := ⟨S.mul⟩
    @[hott] instance S.has_one : has_one (S.carrier ε) := ⟨S.one⟩
    @[hott] instance S.has_inv : has_inv (S.carrier ε) := ⟨S.inv⟩

    section
      include ε
      @[hott] def S.magma : magma :=
      ⟨ε ≃₀ ε, S.mul⟩

      @[hott] def S.semigroup : semigroup :=
      ⟨@S.magma ε, begin
        intros, fapply theorems.prop.equiv_hmtpy_lem,
        intro x, induction a, induction b, induction c, reflexivity
      end⟩

      @[hott] def S.monoid : monoid :=
      begin
        fapply monoid.mk, exact @S.semigroup ε, exact S.one,
        repeat { intro x, fapply theorems.prop.equiv_hmtpy_lem,
                 intro y, induction x, reflexivity },
      end

      @[hott] def S (ε : structures.n_type.{u} 0) : group :=
      ⟨@S.monoid ε, S.inv, begin
        intro x, fapply theorems.prop.equiv_hmtpy_lem, intro y,
        induction x with f x, induction x with e₁ e₂,
        induction e₁ with g p, induction e₂ with h q,
        change h _ = y, apply qinv.linv_inv, exact q, exact p
      end⟩
    end

    @[hott] def left (G : group) (x : G.carrier) : G.carrier ≃ G.carrier :=
    begin
      existsi (λ y, x * y), split; existsi (λ y, x⁻¹ * y); intro y,
      { transitivity, { symmetry, apply semigroup.mul_assoc },
        transitivity, { apply Id.map (* y), apply group.mul_left_inv },
        apply monoid.one_mul },
      { transitivity, { symmetry, apply semigroup.mul_assoc },
        transitivity, { apply Id.map (* y), apply group.mul_right_inv },
        apply monoid.one_mul }
    end

    @[hott] def S.univ (G : group.{u}) : G ⤳ S G.zero :=
    ⟨left G, begin
      intros x y, fapply theorems.prop.equiv_hmtpy_lem,
      intro z, apply semigroup.mul_assoc
    end⟩

    @[hott] def S.univ.ker.encode : ker (S.univ G) ⊆ triv G :=
    λ x H, begin change _ = _, symmetry, apply unit_of_sqr, apply equiv.happly H end

    @[hott] def S.univ.ker.decode : triv G ⊆ ker (S.univ G) :=
    begin
      intros x H, apply theorems.prop.equiv_hmtpy_lem,
      intro y, induction H, apply monoid.one_mul
    end

    @[hott] noncomputable def S.univ.ker : ker (S.univ G) = triv G :=
    ens.ssubset.asymm S.univ.ker.encode S.univ.ker.decode
  end

  @[hott] def op.mul : G.carrier → G.carrier → G.carrier := λ x y, y * x
  @[hott] def op.inv : G.carrier → G.carrier             := G.inv
  @[hott] def op.one : G.carrier                         := e

  @[hott] def op.magma : magma := ⟨G.α, @op.mul G⟩

  @[hott] def op.semigroup : semigroup :=
  ⟨op.magma, λ a b c, Id.inv (G.mul_assoc c b a)⟩

  @[hott] def op.monoid : monoid :=
  ⟨op.semigroup, e, G.mul_one, G.one_mul⟩

  @[hott] def op (G : group) : group :=
  ⟨op.monoid, G.inv, mul_right_inv⟩
  postfix `ᵒᵖ`:2000 := op

  @[hott] def op.univ : G ⤳ Gᵒᵖ :=
  ⟨G.inv, begin intros a b, apply inv_explode end⟩

  @[hott] def op.iso : G ≅ Gᵒᵖ :=
  begin
    fapply iso.of_homo, exact op.univ,
    split; existsi G.inv; intro x; apply inv_inv
  end

  @[hott] def closure (G : group) (x : G.subset) : G.subset :=
  ens.smallest (λ φ, (G ⊵ φ) × x ⊆ φ)

  @[hott] def closure.sub (φ : G.subset) : φ ⊆ closure G φ :=
  begin intros x G y H, apply H.snd, assumption end

  @[hott] def closure.sub_trans {φ ψ : G.subset} [G ⊵ ψ] :
    φ ⊆ ψ → closure G φ ⊆ ψ :=
  begin intros H x G, apply G, split; assumption end

  @[hott] def closure.elim (φ : G.subset) [G ⊵ φ] : closure G φ ⊆ φ :=
  closure.sub_trans (ens.ssubset.refl φ)

  @[hott] instance closure.subgroup (x : G.subset) :
    G ≥ closure G x :=
  begin
    split,
    { intros y H, induction H with G H,
      apply G.to_is_subgroup.unit },
    { intros a b G H y F, apply F.fst.to_is_subgroup.mul,
      apply G y, assumption, apply H y, assumption },
    { intros a H y G, apply G.fst.to_is_subgroup.inv,
      apply H y, assumption }
  end

  @[hott] instance closure.normal_subgroup (x : G.subset) :
    G ⊵ closure G x :=
  begin
    split, intros g h G y H, apply H.fst.cosets_eqv,
    apply G y, assumption
  end

  section
    variables {ε : Type u} (R : ens (F.carrier ε))
    @[hott] noncomputable def presentation :=
    (F ε)\(closure (F ε) R)

    @[hott] def presentation.carrier :=
    factor_left (F ε) (closure (F ε) R)

    @[hott] noncomputable def presentation.one : presentation.carrier R :=
    (presentation R).e
  end

  @[hott] noncomputable def presentation.sound {α : Type u}
    {R : ens (F.carrier α)} {x : F.carrier α} (H : x ∈ R) :
      factor.incl x = presentation.one R :> (presentation R).carrier :=
  begin apply factor.sound, apply closure.sub, assumption end

  @[hott] def commutator (x y : G.carrier) := (x * y) * (x⁻¹ * y⁻¹)

  @[hott] def commutators (G : group) : G.subset :=
  im (function.uncurry (@commutator G))

  @[hott] noncomputable def abelianization (G : group) :=
  G\closure G (commutators G)
  postfix `ᵃᵇ`:2000 := abelianization

  @[hott] def abelianization.elem : G.carrier → (abelianization G).carrier :=
  factor.incl

  @[hott] def commutes {x y : G.carrier}
    (p : commutator x y = e) : x * y = y * x :=
  begin
    symmetry, transitivity, { symmetry, apply inv_inv },
    transitivity, apply Id.map, apply inv_explode,
    symmetry, apply eq_inv_of_mul_eq_one, exact p
  end

  @[hott] def commutator_over_inv (x y : G.carrier) :
    (commutator x y)⁻¹ = commutator y x :=
  begin
    transitivity, apply inv_explode,
    transitivity, apply Id.map, apply inv_explode,
    apply Id.map (* y⁻¹ * x⁻¹), transitivity, apply inv_explode,
    transitivity, apply Id.map, apply inv_inv,
    apply Id.map (* x), apply inv_inv
  end

  @[hott] noncomputable instance abelianization.abelian :
    abelian (abelianization G) := ⟨begin
    intros a b, apply @commutes (abelianization G),
    fapply HITs.quot.ind _ _ _ a; clear a; intro a,
    { fapply HITs.quot.ind _ _ _ b; clear b; intro b,
      { apply factor.sound, intros y H,
        apply H.snd, apply HITs.merely.elem,
        existsi (a, b), trivial },
      { intros, apply HITs.quot.set },
      { apply prop_is_set, apply HITs.quot.set } },
    { intros, apply HITs.quot.set },
    { apply prop_is_set, apply HITs.quot.set }
  end⟩

  section
    variables {H : group} [abelian H]
    local infix ×:70 := H.φ

    @[hott] def commutators.to_ker (f : G ⤳ H) : commutators G ⊆ ker f :=
    begin
      intros x, fapply HITs.merely.rec,
      { apply ens.prop },
      { intro H, induction H with p q, induction f with f F,
        induction p with a b, change _ = _, calc
          f x = f (a * b * (a⁻¹ * b⁻¹))     : f # (Id.inv q)
          ... = f (a * b) × f (a⁻¹ * b⁻¹)   : F (a * b) (a⁻¹ * b⁻¹)
          ... = f (a * b) × (f a⁻¹ × f b⁻¹) : by apply Id.map; apply F
          ... = f (a * b) × (f b⁻¹ × f a⁻¹) : by apply Id.map; apply abelian.mul_comm
          ... = f (a * b) × f (b⁻¹ * a⁻¹)   : by apply Id.map; symmetry; apply F
          ... = f (a * b * (b⁻¹ * a⁻¹))     : Id.inv (F _ _)
          ... = f (a * b * b⁻¹ * a⁻¹)       : f # (Id.inv $ G.mul_assoc _ _ _)
          ... = f (a * (b * b⁻¹) * a⁻¹)     : @Id.map G.carrier H.carrier _ _
                                                (λ x, f (x * a⁻¹))
                                                (G.mul_assoc a b b⁻¹)
          ... = f (a * e * a⁻¹)             : @Id.map G.carrier H.carrier _ _
                                                (λ x, f (a * x * a⁻¹))
                                                (mul_right_inv b)
          ... = f (a * a⁻¹)                 : @Id.map G.carrier H.carrier _ _
                                                (λ x, f (x * a⁻¹)) (G.mul_one a)
          ... = f e                         : f # (mul_right_inv a)
          ... = H.e                         : homo_saves_unit ⟨f, F⟩ }
    end
  end

  @[hott] def commutators.to_closure_ker {H : group} [abelian H] (f : G ⤳ H) :
    ens.ssubset (closure G (commutators G)) (ker f) :=
  closure.sub_trans (commutators.to_ker f)

  @[hott] def abelianization.rec {ε : group} {α : group} [abelian α] (f : ε ⤳ α) :
    εᵃᵇ.carrier → α.carrier :=
  begin
    fapply factor.lift, exact f,
    { intros x H, apply commutators.to_closure_ker,
      assumption }
  end

  @[hott] noncomputable def abelianization.homomorphism {ε : group} {α : group}
    [abelian α] (f : ε ⤳ α) : εᵃᵇ ⤳ α :=
  ⟨abelianization.rec f, begin
    intros a b, fapply HITs.quotient.ind_prop _ _ a; clear a; intro a,
    { fapply HITs.quotient.ind_prop _ _ b; clear b; intro b,
      { apply f.snd },
      { apply group.set } },
    { apply group.set }
  end⟩

  @[hott] noncomputable def FAb (α : Type u) := abelianization (F α)
  @[hott] noncomputable instance {α : Type u} : abelian (FAb α) :=
  by apply abelianization.abelian

  @[hott] noncomputable def FAb.elem {α : Type u} : α → (FAb α).carrier :=
  abelianization.elem ∘ F.elem

  @[hott] noncomputable def FAb.rec {α : group} [abelian α] {ε : Type v}
    (f : ε → α.carrier) : (FAb ε).carrier → α.carrier :=
  abelianization.rec (F.homomorphism f)

  @[hott] noncomputable def FAb.homomorphism {α : group} [abelian α] {ε : Type v}
    (f : ε → α.carrier) : FAb ε ⤳ α :=
  abelianization.homomorphism (F.homomorphism f)

  @[hott] def homo.id.encode :
    G.carrier → im.carrier homo.id :=
  λ x, ⟨x, HITs.merely.elem ⟨x, idp x⟩⟩

  @[hott] def homo.id.decode : im.carrier homo.id → G.carrier :=
  sigma.fst

  @[hott] def homo.id.iso : G ≅ Im homo.id :=
  begin
    existsi homo.id.encode, split,
    { intros a b, reflexivity },
    split; existsi homo.id.decode,
    { intro x, reflexivity },
    { intro x, induction x with x H,
      fapply sigma.prod, reflexivity,
      apply ens.prop }
  end

  section
    variables {φ : G.subset} {ψ : G.subset}
    variables [G ⊵ φ] [G ⊵ ψ]

    @[hott] noncomputable def factor.transfer (f : φ ⊆ ψ) :
      (G\φ).carrier → (G\ψ).carrier :=
    begin
      fapply HITs.quotient.rec,
      { exact factor.incl },
      { intros x y H, apply HITs.quotient.sound,
        apply f, exact H },
      { apply HITs.quotient.set }
    end

    @[hott] noncomputable def factor.iso
      (f : φ ⊆ ψ) (g : ψ ⊆ φ) : G\φ ≅ G\ψ :=
    begin
      existsi factor.transfer f, split,
      { intro x, fapply HITs.quotient.ind_prop _ _ x; clear x; intro x,
        { fapply HITs.quotient.ind_prop,
          { intro y, reflexivity },
          { intros, apply HITs.quotient.set } },
        { intros, apply pi_prop,
          intro z, apply HITs.quotient.set } },
      { split; existsi factor.transfer g;
        { fapply HITs.quotient.ind_prop,
          { intro x, reflexivity },
          { intros, apply HITs.quotient.set } } }
    end
  end

  @[hott] noncomputable def S.iso : Im (S.univ G) ≅ G :=
  begin
    fapply iso.trans first_iso_theorem,
    symmetry, fapply iso.trans triv.factor,
    apply factor.iso S.univ.ker.decode S.univ.ker.encode
  end

  @[hott] def subgroup (G : group) :=
  Σ (s : G.subset), G ≥ s
  @[hott] instance subgroup.really_subgroup (s : subgroup G) : G ≥ s.fst := s.snd

  @[hott] def subgroup.subtype (s : subgroup G) := s.fst.subtype
  @[hott] def subgroup.grp (s : subgroup G) : group :=
  subgroup.group G s.fst

  -- Cayley’s theorem
  @[hott] noncomputable def Cayley :
    Σ (s : subgroup (S G.zero)), s.grp ≅ G :=
  ⟨⟨im (S.univ G).fst, by apply_instance⟩, S.iso⟩

  @[hott] noncomputable def normal_factor (φ : G.subset) [G ⊵ φ] :
    G\φ ≅ G\closure G φ :=
  factor.iso (closure.sub φ) (closure.elim φ)

  @[hott] def F.homomorphism.encode : G.carrier → im.carrier (F.homomorphism id) :=
  λ x, ⟨x, HITs.merely.elem ⟨F.elem x, idp _⟩⟩

  @[hott] noncomputable def F.homomorphism.iso :
    G ≅ Im (F.homomorphism id) :=
  begin
    existsi F.homomorphism.encode, split,
    { intros x y, fapply sigma.prod,
      { reflexivity },
      { apply HITs.merely.uniq } },
    { split; existsi sigma.fst,
      { intro x, trivial },
      { intro x, induction x with x H,
        fapply sigma.prod,
        { reflexivity },
        { apply HITs.merely.uniq } } }
  end

  @[hott] noncomputable def presentation.univ :
    Σ (R : ens (F G.carrier).carrier), G ≅ presentation R :=
  ⟨ker (F.homomorphism id), begin
    apply iso.trans F.homomorphism.iso,
    apply iso.trans first_iso_theorem,
    apply normal_factor
  end⟩

  @[hott] def im_impl_ker {φ : G ⤳ G}
    (H : φ ⋅ φ = 0) : im φ.fst ⊆ ker φ :=
  begin
    intro x, fapply HITs.merely.rec,
    { apply G.set },
    { intro H, induction H with y p, change _ = _,
      transitivity, apply Id.map, exact Id.inv p,
      apply group.idhomo (φ ⋅ φ) 0, apply H }
  end

  @[hott] def boundary_of_boundary {φ : G ⤳ G}
    (G : im φ.fst ⊆ ker φ) : φ ⋅ φ = 0 :=
  begin
    induction φ with φ H, fapply group.homo.funext,
    intro x, apply G, apply HITs.merely.elem,
    existsi x, trivial
  end

  @[hott] def homo.set {G H : group} : hset (G ⤳ H) :=
  begin
    apply zero_eqv_set.forward, fapply ntype_respects_sigma 0,
    { apply pi_respects_ntype 0, intro x,
      apply zero_eqv_set.left, intros a b, apply H.set },
    { intro φ, apply zero_eqv_set.left, apply prop_is_set,
      apply pi_prop, intro x,
      apply pi_prop, intro y,
      apply H.set }
  end

  @[hott] def boundary_eqv (φ : G ⤳ G) :
    (φ ⋅ φ = 0) ≃ (im φ.fst ⊆ ker φ) :=
  begin
    apply structures.prop_equiv_lemma,
    apply homo.set, apply ens.ssubset.prop,
    exact im_impl_ker, exact boundary_of_boundary
  end

  def P.carrier (G : group) := ℕ → G.carrier

  def P.set (G : group) : is-0-type (P.carrier G) :=
  structures.pi_respects_ntype 0 (λ _, G.α.snd)

  def P.mul : P.carrier G → P.carrier G → P.carrier G :=
  λ f g n, f n * g n

  def P.one : P.carrier G := λ _, e
  def P.inv : P.carrier G → P.carrier G :=
  λ f n, (f n)⁻¹

  @[hott] def P.magma (G : group) : magma :=
  ⟨⟨P.carrier G, P.set G⟩, P.mul⟩

  @[hott] def P.semigroup (G : group) : semigroup :=
  ⟨P.magma G, λ f g h, begin fapply theorems.funext, intro n, apply G.mul_assoc end⟩

  @[hott] def P.monoid (G : group) : monoid :=
  begin
    fapply monoid.mk, exact P.semigroup G, exact P.one,
    repeat { intro f, fapply theorems.funext, intro n },
    apply G.one_mul, apply G.mul_one
  end

  @[hott] def P (G : group) : group :=
  ⟨P.monoid G, P.inv, begin intro f, fapply theorems.funext, intro n, apply G.mul_left_inv end⟩

  @[hott] instance P.abelian (G : group) [abelian G] : abelian (P G) :=
  ⟨begin intros f g, fapply theorems.funext, intro n, fapply abelian.mul_comm end⟩

  @[hott] def P.unit_sqr (H : Π x, x * x = e) (x : P.carrier G) :
    P.mul x x = P.one :=
  begin fapply theorems.funext, intro n, apply H end

  def P₂ := P Z₂
  @[hott] def P₂.periodic (x : P₂.carrier) : P.mul x x = P.one :=
  begin apply P.unit_sqr, intro b, induction b; trivial end

  @[hott] def prod_hset {α : Type u} {β : Type u}
    (p : hset α) (q : hset β) : hset (α × β) :=
  begin
    apply hset_respects_equiv,
    apply sigma.const,
    apply hset_respects_sigma,
    intros a b, apply p,
    intro x, intros a b, exact q
  end

  @[hott] def prod (G H : group) : group :=
  ⟨⟨⟨⟨zeroeqv (λ _ _, prod_hset (λ _ _, G.set) (λ _ _, H.set)),
    λ ⟨a₁, b₁⟩ ⟨a₂, b₂⟩, (G.φ a₁ a₂, H.φ b₁ b₂)⟩,
    begin
      intros a b c, cases a, cases b, cases c,
      apply product.prod,
      apply G.mul_assoc,
      apply H.mul_assoc
    end⟩,
    (G.e, H.e),
    begin
      intros a, cases a, apply product.prod,
      apply G.one_mul, apply H.one_mul
    end,
    begin
      intros a, cases a, apply product.prod,
      apply G.mul_one, apply H.mul_one
    end⟩,
    λ ⟨a, b⟩, (G.inv a, H.inv b),
    begin
      intros a, cases a, apply product.prod,
      apply G.mul_left_inv, apply H.mul_left_inv
    end⟩

  notation G × H := prod G H

  @[hott] instance prod.abelian (G H : group)
    [abelian G] [abelian H] : abelian (G × H) :=
  begin
    split, intros x y, cases x, cases y,
    apply product.prod; apply abelian.mul_comm
  end

  @[hott] def homo.prod {G H F : group} [abelian F]
    (φ : G ⤳ F) (ψ : H ⤳ F) : G × H ⤳ F :=
  ⟨λ ⟨g, h⟩, F.φ (φ.fst g) (ψ.fst h), begin
    intros x y, cases x with g₁ h₁, cases y with g₂ h₂,
    change F.φ (φ.fst _) (ψ.fst _) = F.φ (F.φ _ _) (F.φ _ _),
    transitivity, apply equiv.bimap F.φ,
    apply φ.snd, apply ψ.snd,
    transitivity, apply F.mul_assoc,
    transitivity, apply map (F.φ (φ.fst g₁)),
    transitivity, apply abelian.mul_comm, apply F.mul_assoc,
    transitivity, symmetry, apply F.mul_assoc,
    apply map, apply abelian.mul_comm
  end⟩

  def Aut.carrier (G : group) := G ≅ G

  @[hott] def Aut.magma (G : group) : magma :=
  ⟨@zeroeqv (G ≅ G) (λ _ _, iso.hset), λ φ ψ, iso.trans ψ φ⟩

  meta def iso.funext :=
  `[ apply iso.ext, intro x, reflexivity ]

  @[hott] def Aut.semigroup (G : group) : semigroup :=
  ⟨Aut.magma G, λ ⟨f, ⟨f', e₁⟩⟩ ⟨g, ⟨g', e₂⟩⟩ ⟨h, ⟨h', e₂⟩⟩, by iso.funext⟩

  @[hott] def Aut.monoid (G : group) : monoid :=
  ⟨Aut.semigroup G, iso.refl G,
   λ ⟨f, ⟨f', e₁⟩⟩, by iso.funext,
   λ ⟨f, ⟨f', e₁⟩⟩, by iso.funext⟩

  @[hott] def Aut (G : group) : group :=
  ⟨Aut.monoid G, iso.symm, λ ⟨f, ⟨f', ⟨⟨g, G⟩, ⟨h, H⟩⟩⟩⟩, begin
    apply iso.ext, apply G
  end⟩

  @[hott] def conjugate.idem {G : group} (x : G.carrier) := calc
    conjugate x x = G.φ G.e x : (λ y, G.φ y x) # (G.mul_left_inv x)
              ... = x         : G.one_mul x

  @[hott] def conjugate.eq {G : group} {x y : G.carrier}
    (p : conjugate x y = y) : x = y :=
  begin
    symmetry, apply eq_of_div_eq, fapply mul_cancel_right, exact y,
    transitivity, exact p, symmetry, apply G.one_mul
  end

  @[hott] def conjugate.comm {G : group} {x y : G.carrier}
    (p : conjugate x y = x) : G.φ x y = G.φ y x :=
  begin
    fapply mul_cancel_left, exact G.inv y,
    transitivity, { symmetry, apply G.mul_assoc },
    transitivity, exact p, transitivity,
    { transitivity, symmetry, apply G.one_mul,
      apply Id.map (λ y, G.φ y x),
      symmetry, apply G.mul_left_inv y },
    apply G.mul_assoc
  end

  @[hott] def semidirect.magma {N H : group} (φ : H ⤳ Aut N) : magma :=
  ⟨zeroeqv (λ _ _, prod_hset (λ _ _, N.set) (λ _ _, H.set)),
  λ ⟨n₁, h₁⟩ ⟨n₂, h₂⟩, (N.φ n₁ ((φ.fst h₁).fst n₂), H.φ h₁ h₂)⟩

  @[hott] def semidirect.semigroup {N H : group} (φ : H ⤳ Aut N) : semigroup :=
  ⟨semidirect.magma φ,
  λ ⟨n₁, h₁⟩ ⟨n₂, h₂⟩ ⟨n₃, h₃⟩, begin
    apply product.prod,
    { repeat { clear _fun_match },
      induction φ with φ H,
      transitivity, apply N.mul_assoc,
      apply Id.map (N.φ n₁), symmetry,
      transitivity, apply (φ h₁).snd.fst,
      apply Id.map, symmetry,
      transitivity, apply HITs.interval.happly,
      apply Id.map, apply H,
      change _ = (φ h₁).fst ((φ h₂).fst n₃),
      cases φ h₁ with f F,cases φ h₂ with g G,
      cases F with F₁ F₂, cases G with G₁ G₂,
      reflexivity },
    { apply H.mul_assoc }
  end⟩

  @[hott] def semidirect.monoid {N H : group} (φ : H ⤳ Aut N) : monoid :=
  ⟨semidirect.semigroup φ, (N.e, H.e), λ ⟨n, h⟩, begin
    apply product.prod,
    { transitivity, apply monoid.one_mul,
      transitivity, apply HITs.interval.happly,
      apply Id.map, apply homo_saves_unit,
      reflexivity },
    { apply monoid.one_mul }
  end, λ ⟨n, h⟩, begin
    apply product.prod,
    { transitivity, apply Id.map (N.φ n),
      apply homo_saves_unit (φ.fst h).homo,
      apply monoid.mul_one },
    { apply monoid.mul_one }
  end⟩

  -- Outer semidirect product
  @[hott] def semidirect {N H : group} (φ : H ⤳ Aut N) : group :=
  ⟨semidirect.monoid φ, λ ⟨n, h⟩, ⟨(φ.fst (H.inv h)).fst (N.inv n), H.inv h⟩,
  λ ⟨n, h⟩, begin
    apply product.prod,
    { transitivity, symmetry, apply (φ.fst (H.inv h)).snd.fst,
      transitivity, apply Id.map, apply N.mul_left_inv,
      apply homo_saves_unit (φ.fst (H.inv h)).homo },
    { apply H.mul_left_inv }
  end⟩

  notation N ` ⋊` `[` φ `] ` H := @semidirect N H φ
  notation H ` ⋉` `[` φ `] ` N := @semidirect N H φ

  @[hott] def left_action (G : group) (α : Type u) :=
  Σ (φ : G.carrier → α → α), (Π x, φ G.e x = x) × (Π g h x, φ g (φ h x) = φ (G.φ g h) x)
  infix ` ⮎ `:20 := left_action

  @[hott] def left_action.id {G : group} {α : Type u} (H : hset α)
    (φ ψ : G ⮎ α) : φ.fst ~ ψ.fst → φ = ψ :=
  begin
    intro p, induction φ with φ p₁, induction ψ with ψ p₂,
    fapply sigma.prod, apply theorems.funext, exact p, apply product_prop;
    { repeat { apply pi_prop, intro }, apply H }
  end

  @[hott] def right_action (G : group) (α : Type u) :=
  Σ (φ : α → G.carrier → α), (Π x, φ x G.e = x) × (Π g h x, φ (φ x g) h = φ x (G.φ g h))
  infix ` ⮌ `:20 := right_action

  section
    variable {α : Type u}

    @[hott] def right_action.associated : (G ⮎ α) → (G ⮌ α) :=
    λ ⟨φ, (p, q)⟩, ⟨λ x g, φ (G.inv g) x, (begin
      intro x, transitivity, apply Id.map (λ g, φ g x),
      symmetry, apply unit_inv, apply p
    end, begin
      intros g h x, transitivity,
      apply q, apply Id.map (λ g, φ g x),
      symmetry, apply inv_explode
    end)⟩

    def orbit (φ : G ⮎ α) (x : α) :=
    im (λ g, φ.fst g x)

    def Orb (φ : G ⮎ α) (x : α) :=
    (orbit φ x).subtype

    def orbitᵣ (φ : G ⮌ α) (x : α) :=
    im (φ.fst x)

    def Orbᵣ (φ : G ⮌ α) (x : α) :=
    (orbitᵣ φ x).subtype
  end

  @[hott] def S.ap {α : 0-Type} : S α ⮎ α.fst :=
  ⟨λ f x, f.fst x, (idp, λ ⟨g, G⟩ ⟨h, G⟩ x, idp (g (h x)))⟩

  @[hott] def left_action.cut {α : Type u} (φ : G.subset)
    [G ≥ φ] : (G ⮎ α) → (subgroup.group G φ ⮎ α) :=
  λ ⟨φ, (p, q)⟩, ⟨λ ⟨g, G⟩ x, φ g x, (p, λ ⟨g, G⟩ ⟨h, G⟩, q g h)⟩

  @[hott] def left_action.eqv {α : Type u} (φ : G ⮎ α) (n m : α) :=
  ∥(Σ g, φ.fst g n = m)∥

  @[hott] def left_action.refl {α : Type u} (φ : G ⮎ α) {a : α} : φ.eqv a a :=
  begin apply HITs.merely.elem, existsi G.e, apply φ.snd.fst end

  @[hott] def left_action.symm {α : Type u} (φ : G ⮎ α)
    {a b : α} : φ.eqv a b → φ.eqv b a :=
  begin
    apply HITs.merely.lift,
    intro p, induction p with g p, existsi G.inv g,
    transitivity, apply Id.map, exact Id.inv p,
    transitivity, apply φ.snd.snd,
    transitivity, apply Id.map (λ g, φ.fst g a),
    apply mul_left_inv, apply φ.snd.fst
  end

  @[hott] def left_action.trans {α : Type u} (φ : G ⮎ α)
    {a b c : α} : φ.eqv a b → φ.eqv b c → φ.eqv a c :=
  begin
    apply HITs.merely.lift₂, intros p q,
    induction p with g p, induction q with h q,
    existsi G.φ h g, transitivity, symmetry, apply φ.snd.snd,
    transitivity, apply Id.map, exact p, exact q
  end

  @[hott] def left_action.rel {α : Type u} (φ : G ⮎ α) : hrel α :=
  λ n m, ⟨φ.eqv n m, HITs.merely.uniq⟩

  @[hott] def left_action.eqrel {α : Type u} (φ : G ⮎ α) : eqrel α :=
  ⟨left_action.rel φ, (λ _, φ.refl, λ _ _, φ.symm, λ _ _ _, φ.trans)⟩

  @[hott] def orbit.subset {α : Type u} (φ : G ⮎ α) {a b : α}
    (p : φ.eqv a b) : orbit φ a ⊆ orbit φ b :=
  begin
    intro c, change φ.eqv a c → φ.eqv b c,
    intro q, apply φ.trans, apply φ.symm p, exact q
  end

  @[hott] def Orbits {α : Type u} (φ : G ⮎ α) :=
  HITs.quotient φ.eqrel

  @[hott] def transitive {α : Type u} (φ : G ⮎ α) :=
  Π a b, ∥(Σ g, φ.fst g a = b)∥

  @[hott] def free {α : Type u} (φ : G ⮎ α) :=
  Π x g h, φ.fst g x = φ.fst h x → g = h

  @[hott] def regular {α : Type u} (φ : G ⮎ α) :=
  Π a b, contr (Σ g, φ.fst g a = b)

  @[hott] def regular.mk {α : Type u} (H : hset α)
    (φ : G ⮎ α) : transitive φ → free φ → regular φ :=
  begin
    intros f g a b, fapply HITs.merely.rec _ _ (f a b),
    { apply contr_is_prop },
    { intro p, existsi p,
      intro q, fapply sigma.prod,
      { apply g a, transitivity, exact p.snd,
        symmetry, exact q.snd },
      { apply H } }
  end

  @[hott] def regular.elim {α : Type u}
    (φ : G ⮎ α) : regular φ → transitive φ × free φ :=
  begin
    intro H, split,
    { intros a b, apply HITs.merely.elem,
      exact (H a b).point },
    { intros x g h p,
      apply @Id.map (Σ g, φ.fst g x = φ.fst h x) G.carrier
                    ⟨g, p⟩ ⟨h, Id.refl⟩ sigma.fst,
      apply contr_impl_prop, apply H }
  end

  @[hott] def regular.eqv {α : Type u} (H : hset α)
    (φ : G ⮎ α) : regular φ ≃ transitive φ × free φ :=
  begin
    apply prop_equiv_lemma,
    { repeat { apply pi_prop, intro },
      apply contr_is_prop },
    { apply product_prop;
      repeat { apply pi_prop, intro },
      { apply HITs.merely.uniq },
      { apply G.set } },
    { apply regular.elim },
    { intro x, induction x,
      apply regular.mk; assumption }
  end

  open ground_zero.theorems
  @[hott] def union (φ : ℕ → G.subset) (p : Π i, φ i ⊆ φ (i + 1))
    (H : Π i, G ≥ φ i) : G ≥ ⋃φ :=
  begin
    split, { apply HITs.merely.elem, existsi 0, apply (H 0).unit },
    { intros a b, apply HITs.merely.lift₂,
      intros r s, induction r with n r, induction s with m s,
      let ε := @nat.le.elim (λ n m, φ n ⊆ φ m)
        (λ n m k, ens.ssubset.trans) (λ n, ens.ssubset.refl (φ n)) p,
      existsi nat.max n m, apply (H (nat.max n m)).mul,
      apply ε, apply nat.le.max, assumption,
      apply ε, apply nat.le.max_rev, assumption },
    { intro a, apply HITs.merely.lift, intro r,
      induction r with n r, existsi n, apply (H n).inv,
      assumption }
  end

  @[hott] def distinct_normal_subgroups {φ ψ : G.subset}
    (H : Π x, x ∈ φ → x ∈ ψ → x = e) [G ⊵ φ] [G ⊵ ψ] :
    Π g h, g ∈ φ → h ∈ ψ → g * h = h * g :=
  begin
    intros g h p q, apply commutes, apply H,
    { apply transport (∈ φ), symmetry, apply G.mul_assoc,
      apply is_subgroup.mul, exact p,
      apply transport (∈ φ), apply G.mul_assoc,
      apply conjugate_eqv, apply is_normal_subgroup.conj,
      apply is_subgroup.inv, exact p },
    { apply transport (∈ ψ), apply G.mul_assoc,
      apply is_subgroup.mul, apply conjugate_eqv,
      apply is_normal_subgroup.conj, exact q,
      apply is_subgroup.inv, exact q }
  end
end group

def diff := Σ (G : group) [abelian G] (δ : G ⤳ G), δ ⋅ δ = 0

-- Accessors
def diff.grp (G : diff)                 := G.fst
def diff.δ   (G : diff) : G.grp ⤳ G.grp := G.snd.snd.fst
def diff.sqr (G : diff) : G.δ ⋅ G.δ = 0  := G.snd.snd.snd

instance diff.abelian (G : diff) : abelian G.grp := G.snd.fst

namespace diff
  open ground_zero.algebra.group (im ker)
  variables (G : diff)

  @[hott] def univ : im G.δ.fst ⊆ ker G.δ :=
  group.im_impl_ker G.sqr
end diff

end ground_zero.algebra