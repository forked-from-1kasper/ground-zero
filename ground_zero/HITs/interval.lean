import ground_zero.structures ground_zero.types.heq
open ground_zero.structures ground_zero.types

hott theory

/-
  The unit interval I as Higher Inductive Type.
  Proof of functional extensionality from it.
  * HoTT 6.3

  It is primitive HIT.
  * HoTT, chapter 6, exercise 6.13
-/

namespace ground_zero
namespace HITs

inductive I.rel : bool → bool → Prop
| mk (a b : bool) : I.rel a b

def I : Type := quot I.rel
abbreviation interval := I

namespace interval
  universes u v w

  def discrete : bool → I := quot.mk rel
  def i₀ : I := discrete ff
  def i₁ : I := discrete tt

  def seg : i₀ = i₁ := support.inclusion $ quot.sound (rel.mk ff tt)
  def seg_inv : i₁ = i₀ := support.inclusion $ quot.sound (rel.mk tt ff)

  instance : has_zero I := ⟨i₀⟩
  instance : has_one I := ⟨i₁⟩

  abbreviation left := i₀
  abbreviation right := i₁

  abbreviation zero := i₀
  abbreviation one := i₁

  /- β i₀ and β i₁ are Prop’s,
     so s : b₀ = b₁ is trivial -/
  def prop_rec {β : I → Prop} (b₀ : β i₀) (b₁ : β i₁) :
    Π (x : I), β x := begin
    intros, refine quot.ind _ x, intro b,
    cases b, exact b₀, exact b₁
  end

  def hrec (β : I → Type u)
    (b₀ : β 0) (b₁ : β 1) (s : b₀ == b₁)
    (x : I) : β x := begin
    fapply quot.hrec_on x,
    { intro b, cases b, exact b₀, exact b₁ },
    { intros a b R, cases a; cases b,
      { trivial },
      { exact s },
      { symmetry, exact s },
      { trivial } }
  end

  def ind {π : I → Type u} (b₀ : π i₀) (b₁ : π i₁)
    (s : b₀ =[seg] b₁) (x : I) : π x := begin
    fapply quot.hrec_on x,
    { intro b, cases b, exact b₀, exact b₁ },
    { intros,
      cases a; cases b,
      { reflexivity },
      { simp, apply types.heq.from_pathover, exact s },
      { simp, symmetry,
        apply types.heq.from_pathover, exact s },
      { reflexivity } }
  end

  @[inline]
  def rec {β : Type u} (b₀ : β) (b₁ : β)
    (s : b₀ = b₁ :> β) : I → β :=
  ind b₀ b₁ (types.equiv.pathover_of_eq seg s)

  def lift {β : Type u} (f : bool → β) (H : prop β) : I → β :=
  begin fapply rec, exact f ff, exact f tt, apply H end

  def contr_left : Π i, i₀ = i :=
  interval.ind types.eq.rfl seg (begin
    apply types.equiv.pathover_from_trans,
    apply types.eq.refl_left
  end)

  def contr_right : Π i, i₁ = i :=
  interval.ind seg⁻¹ types.eq.rfl (begin
    apply types.equiv.pathover_from_trans,
    apply types.eq.inv_comp
  end)

  def interval_contr : contr I := ⟨i₁, contr_right⟩

  def interval_prop : prop I :=
  contr_impl_prop interval_contr

  def seg_inv_comp : seg ⬝ seg⁻¹ = types.eq.rfl :=
  by apply prop_is_set interval_prop

  def homotopy {α : Type u} {β : Type v} {f g : α → β}
    (p : f ~ g) (x : α) : I → β :=
  rec (f x) (g x) (p x)

  def funext {α : Type u} {β : Type v} {f g : α → β}
    (p : f ~ g) : f = g :> α → β :=
  @eq.map I (α → β) 0 1 (function.swap (homotopy p)) seg

  def dhomotopy {α : Type u} {β : α → Type v} {f g : Π x, β x}
    (p : f ~ g) (x : α) : I → β x :=
  rec (f x) (g x) (p x)

  def dfunext {α : Type u} {β : α → Type v}
    {f g : Π x, β x} (p : f ~ g) : f = g :=
  @eq.map I (Π x, β x) 0 1 (function.swap (dhomotopy p)) seg

  def happly {α : Type u} {β : α → Type v}
    {f g : Π x, β x} (p : f = g) : f ~ g :=
  equiv.transport (λ g, f ~ g) p (types.equiv.homotopy.id f)

  def transport_over_hmtpy {α : Type u} {β : Type v} {γ : Type w}
    (f : α → β) (g₁ g₂ : β → γ) (h : α → γ)
    (p : g₁ = g₂) (H : g₁ ∘ f ~ h) (x : α) :
    equiv.transport (λ (g : β → γ), g ∘ f ~ h) p H x =
    @equiv.transport (β → γ) (λ (g : β → γ), g (f x) = h x) g₁ g₂ p (H x) :=
  begin apply HITs.interval.happly, apply equiv.transport_over_pi end

  def bool_to_interval (f : bool → bool → bool) (a b : I) : I :=
  lift (λ a, lift (discrete ∘ f a) interval_prop b) interval_prop a

  axiom indβrule {π : I → Type u} (b₀ : π i₀) (b₁ : π i₁)
    (s : b₀ =[seg] b₁) : types.equiv.apd (ind b₀ b₁ s) seg = s

  noncomputable def recβrule {π : Type u} (b₀ b₁ : π)
    (s : b₀ = b₁) : rec b₀ b₁ s # seg = s := begin
    apply equiv.pathover_of_eq_inj seg, transitivity,
    symmetry, apply equiv.apd_over_constant_family,
    transitivity, apply indβrule, reflexivity
  end

  def neg : I → I := interval.rec i₁ i₀ seg⁻¹
  instance : has_neg I := ⟨neg⟩

  def min (a b : I) : I :=
  lift (begin intro x, cases x, exact i₀, exact a end)
        interval_prop b

  def max (a b : I) : I :=
  lift (begin intro x, cases x, exact a, exact i₁ end)
        interval_prop b

  notation r `∧`:70 s := min r s
  notation r `∨`:70 s := max r s

  def elim {α : Type u} {a b : α} (p : a = b) : I → α := rec a b p
  def lam  {α : Type u} (f : I → α) : f 0 = f 1 := eq.map f seg

  def conn_and {α : Type u} {a b : α} (p : a = b) : Π i, a = elim p i :=
  λ i, lam (λ j, elim p (i ∧ j))

  def cong {α : Type u} {β : Type v} {a b : α}
    (f : α → β) (p : a = b) : f a = f b :=
  lam (λ i, f (elim p i))

  noncomputable def cong_refl {α : Type u} {β : Type v} {a : α}
    (f : α → β) : cong f (idp a) = idp (f a) := begin
    transitivity, apply types.equiv.map_over_comp,
    transitivity, apply eq.map, apply recβrule, trivial
  end

  noncomputable def map_eq_cong {α : Type u} {β : Type v} {a b : α}
    (f : α → β) (p : a = b) : f # p = cong f p :=
  begin induction p, symmetry, apply cong_refl end

  noncomputable def neg_neg : Π x, neg (neg x) = x :=
  interval.ind eq.rfl eq.rfl (calc
    equiv.transport (λ x, neg (neg x) = x) seg (idp i₀) =
    (@eq.map I I i₁ i₀ (neg ∘ neg) seg⁻¹) ⬝ idp i₀ ⬝ seg :
      by apply equiv.transport_over_involution
    ... = neg # (neg # seg⁻¹) ⬝ idp i₀ ⬝ seg :
      begin apply eq.map (λ p, p ⬝ idp i₀ ⬝ seg),
            apply equiv.map_over_comp end
    ... = neg # (neg # seg)⁻¹ ⬝ idp i₀ ⬝ seg :
      begin apply eq.map (λ p, p ⬝ idp i₀ ⬝ seg),
            apply eq.map, apply eq.map_inv end
    ... = neg # seg⁻¹⁻¹ ⬝ idp i₀ ⬝ seg :
      begin apply eq.map (λ p, p ⬝ idp i₀ ⬝ seg),
            apply eq.map, apply eq.map ground_zero.types.eq.symm,
            apply interval.recβrule end
    ... = neg # seg ⬝ idp i₀ ⬝ seg :
      begin apply eq.map (λ (p : i₀ = i₁), neg # p ⬝ idp i₀ ⬝ seg),
            apply eq.inv_inv end
    ... = seg⁻¹ ⬝ idp i₀ ⬝ seg :
      begin apply eq.map (λ p, p ⬝ idp i₀ ⬝ seg),
            apply interval.recβrule end
    ... = seg⁻¹ ⬝ seg :
      begin apply eq.map (λ p, p ⬝ seg),
            apply eq.refl_right end
    ... = idp i₁ : by apply eq.inv_comp)

  def neg_neg' (x : I) : neg (neg x) = x :=
  (conn_and seg⁻¹ (neg x))⁻¹ ⬝ contr_right x

  noncomputable def twist : I ≃ I :=
  ⟨neg, ⟨⟨neg, neg_neg⟩, ⟨neg, neg_neg⟩⟩⟩
end interval

end HITs
end ground_zero