import ground_zero.HITs.colimit ground_zero.HITs.generalized
import ground_zero.structures
open ground_zero.types.equiv (subst apd pathover_from_trans)
open ground_zero.types.eq (cong inv)
open ground_zero.structures (prop contr lem_contr)

namespace ground_zero.HITs
hott theory

universes u v

/-
  Propositional truncation is colimit of a following sequence:
    α → {α} → {{α}} → ...

  * https://github.com/fpvandoorn/leansnippets/blob/master/truncation.hlean
  * https://github.com/fpvandoorn/leansnippets/blob/master/cpp.hlean
    (we use this proof here)
  * https://homotopytypetheory.org/2015/07/28/constructing-the-propositional-truncation-using-nonrecursive-hits/
  * https://homotopytypetheory.org/2016/01/08/colimits-in-hott/
  * https://arxiv.org/pdf/1512.02274
-/
def truncation (α : Type u) :=
colimit (generalized.repeat α) (generalized.dep α)

notation `∥` α `∥` := truncation α

namespace truncation
  def elem {α : Type u} (x : α) : ∥α∥ :=
  colimit.inclusion 0 x

  notation `|` a `|` := elem a

  def ind {α : Type u} {π : ∥α∥ → Type v}
    (elemπ : Π x, π (elem x))
    (uniqπ : Π x, prop (π x)) : Π x, π x := begin
    fapply colimit.ind,
    { intros, induction n with n ih,
      { apply elemπ },
      { refine generalized.ind _ _ x,
        { clear x, intro x, apply subst,
          symmetry, apply colimit.glue, apply ih },
        { intros, apply uniqπ } } },
    { intros, apply uniqπ }
  end

  def rec {α : Type u} {β : Type v} (h : prop β)
    (f : α → β) : ∥α∥ → β :=
  ind f (λ _, h)

  def weak_uniq {α : Type u} (x y : α) : elem x = elem y :> ∥α∥ := begin
    transitivity, { symmetry, apply colimit.glue }, symmetry,
    transitivity, { symmetry, apply colimit.glue },
    apply ground_zero.types.eq.map, apply generalized.glue
  end

  abbreviation incl {α : Type u} {n : ℕ} :=
  @colimit.incl (generalized.repeat α) (generalized.dep α) n

  abbreviation glue {α : Type u} {n : ℕ} {x : generalized.repeat α n} :
    incl (generalized.dep α n x) = incl x :=
  colimit.glue x

  def exact_nth {α : Type u} (a : α) : Π n, generalized.repeat α n
  | 0 := a
  | (n + 1) := generalized.dep α n (exact_nth n)

  def nth_glue {α : Type u} (a : α) : Π n,
    incl (exact_nth a n) = @incl α 0 a
  | 0 := by reflexivity
  | (n + 1) := colimit.glue (exact_nth a n) ⬝ nth_glue n

  def incl_uniq {α : Type u} {n : ℕ} (a b : generalized.repeat α n) :
    incl a = incl b :=
  calc incl a = incl (generalized.dep α n a) : glue⁻¹
          ... = incl (generalized.dep α n b) : incl # (generalized.glue a b)
          ... = incl b : glue

  def incl_zero_eq_incl {α : Type u} {n : ℕ} (x : α)
    (y : generalized.repeat α n) : @incl α 0 x = incl y :=
  calc @incl α 0 x = incl (exact_nth x n) : (nth_glue x n)⁻¹
               ... = incl y : incl_uniq (exact_nth x n) y

  def weakly_constant_ap {α : Type u} {β : Type v} (f : α → β)
    {a b : α} (p q : a = b) (H : Π (a b : α), f a = f b) : f # p = f # q :=
  let L : Π {u v : α} {r : u = v}, (H a u)⁻¹ ⬝ H a v = f # r :=
  begin intros, induction r, apply ground_zero.types.eq.inv_comp end in
  L⁻¹ ⬝ L

  def cong_close {α : Type u} {n : ℕ} {a b : generalized.repeat α n} (p : a = b) :
    inv glue ⬝ incl # (generalized.dep α n # p) ⬝ glue = incl # p := begin
    induction p, transitivity,
    { symmetry, apply ground_zero.types.eq.assoc },
    apply ground_zero.types.equiv.rewrite_comp, symmetry,
    apply ground_zero.types.eq.refl_right
  end

  def cong_over_path {α : Type u} {n : ℕ} {a b : generalized.repeat α n}
    (p q : a = b) : incl # p = incl # q :=
  weakly_constant_ap incl p q incl_uniq

  def glue_close {α : Type u} {n : ℕ} {a b : generalized.repeat α n} :
    inv glue ⬝ incl # (generalized.glue (generalized.dep α n a)
                                        (generalized.dep α n b)) ⬝ glue =
    incl # (generalized.glue a b) := begin
    symmetry, transitivity,
    { symmetry, exact cong_close (generalized.glue a b) },
    apply cong (λ p, p ⬝ glue), apply cong,
    apply cong_over_path
  end

  def incl_uniq_close {α : Type u} {n : ℕ} (a b : generalized.repeat α n) :
    inv glue ⬝ incl_uniq (generalized.dep α n a) (generalized.dep α n b) ⬝ glue =
    incl_uniq a b := begin
    unfold incl_uniq, apply cong (λ p, p ⬝ glue), apply cong,
    apply glue_close
  end

  def uniq {α : Type u} : prop ∥α∥ := begin
    apply lem_contr, fapply ind,
    { intro x, existsi elem x, fapply colimit.ind; intros n y,
      { apply incl_zero_eq_incl },
      { simp, unfold incl_zero_eq_incl, unfold nth_glue,
        apply pathover_from_trans,
        symmetry, transitivity,
        { symmetry, apply cong, apply incl_uniq_close },
        symmetry, transitivity, apply cong
          (λ p, p ⬝ incl_uniq (exact_nth x (n + 1)) (generalized.dep α n y) ⬝
                    colimit.glue y),
        apply ground_zero.types.eq.explode_inv,
        repeat { transitivity, symmetry, apply ground_zero.types.eq.assoc },
        apply cong (λ p, (nth_glue x n)⁻¹ ⬝ p),
        unfold incl_uniq, apply ground_zero.types.eq.assoc } },
    { intro x, apply ground_zero.structures.contr_is_prop }
  end

  def lift {α β : Type u} (f : α → β) : ∥α∥ → ∥β∥ :=
  rec uniq (elem ∘ f)

  theorem equiv_iff_trunc {α β : Type u}
    (f : α → β) (g : β → α) : ∥α∥ ≃ ∥β∥ := begin
    existsi lift f, split; existsi lift g;
    { intro x, apply uniq }
  end

  def double {α : Type u} (a : α) : α × α := ⟨a, a⟩
  theorem product_identity {α : Type u} :
    ∥α∥ ≃ ∥α × α∥ := begin
    apply equiv_iff_trunc, exact double,
    intro x, cases x with u v, exact u
  end

  def uninhabited_implies_trunc_uninhabited {α : Type u} : ¬α → ¬∥α∥ :=
  rec ground_zero.structures.empty_is_prop
end truncation

def surj {α : Type u} {β : Type v} (f : α → β) :=
Π (b : β), ∥ground_zero.types.fib f b∥

def embedding {α : Type u} {β : Type v} (f : α → β) :=
Π (x y : α), ground_zero.types.equiv.biinv (λ (p : x = y), f # p)

def is_connected (α : Type u) :=
Σ (x : α), Π y, ∥x = y∥

end ground_zero.HITs