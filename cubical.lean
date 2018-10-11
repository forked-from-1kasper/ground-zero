import ground_zero.interval ground_zero.heq

namespace ground_zero

inductive {u} PathP (σ : 𝕀 → Type u) : σ 𝕀.i₀ → σ 𝕀.i₁ → Type u
| lam (f : Π (i : 𝕀), σ i) : PathP (f 𝕀.i₀) (f 𝕀.i₁)
notation `<` binder `>` r:(scoped P, PathP.lam P) := r

def {u} Path {α : Type u} (a b : α) := PathP (λ _, α) a b
infix ` ⇝ `:30 := Path

namespace PathP
  universe u

  def to_heq {σ : 𝕀 → Type u} {a : σ 𝕀.i₀} {b : σ 𝕀.i₁}
    (p : PathP σ a b) : a == b :=
  PathP.rec (λ f, heq.map f 𝕀.seg) p

  def from_heq {σ : 𝕀 → Type u} {a : σ 𝕀.i₀} {b : σ 𝕀.i₁}
    (p : a == b) : PathP σ a b :=
  PathP.lam (𝕀.hrec a b p)

  def compute {σ : 𝕀 → Type u} {a : σ 𝕀.i₀} {b : σ 𝕀.i₁} (p : PathP σ a b) : Π (i : 𝕀), σ i :=
  𝕀.hrec a b (to_heq p)

  -- ??? it works wrong!
  --infix ` # ` := compute

  --def conn_and {α : Type u} {a b : α} (p : a ⇝ b) :
  --  PathP (λ i, a ⇝ (compute p i)) (<i> a) p :=
  --PathP.lam (λ i, <j> compute p (i ∧ j))

  def square {α : Type u} {a₀ a₁ b₀ b₁ : α}
    (u : Path a₀ a₁) (v : Path b₀ b₁)
    (r₀ : Path a₀ b₀) (r₁ : Path a₁ b₁) :=
  PathP (λ i, (compute u i) ⇝ (compute v i)) r₀ r₁
end PathP

namespace Path
  universes u v

  def to_eq {α : Type u} {a b : α} (p : a ⇝ b) : a = b :=
  PathP.rec (λ f, eq.map f 𝕀.seg) p

  def from_eq {α : Type u} {a b : α} (p : a = b) : a ⇝ b :=
  PathP.lam (𝕀.rec a b p)

  def compute {α : Type u} {a b : α} (p : a ⇝ b) : 𝕀 → α :=
  PathP.compute p
  infix ` # ` := compute

  def only_refl {α : Type u} {a b : α}
    (p : a ⇝ b) : PathP (λ i, a ⇝ (p # i)) (<i> a) p := begin
    admit
  end

  @[refl] def refl {α : Type u} (a : α) : a ⇝ a := <i> a
  @[refl] def rfl {α : Type u} {a : α} : a ⇝ a := <i> a

  @[symm] def symm {α : Type u} {a b : α} (p : a ⇝ b) : b ⇝ a :=
  <i> p # −i
  postfix `⁻¹` := symm

  def funext {α : Type u} {β : Type v} {f g : α → β}
    (p : Π (x : α), f x ⇝ g x) : f ⇝ g :=
  <i> λ x, (p x) # i

  def cong {α : Type u} {β : Type v} {a b : α} (f : α → β) (p : a ⇝ b) :
    f a ⇝ f b :=
  <i> f (p # i)

  def subst {α : Type u} {π : α → Type v} {a b : α}
    (p : a ⇝ b) : π a → π b :=
  equiv.subst (to_eq p)

  def transport {α β : Type u} : (α ⇝ β) → (α → β) :=
  sigma.fst ∘ equiv.idtoeqv ∘ to_eq

  def idtoeqv (α β : Type u) (p : α ⇝ β) : α ≃ β :=
  transport (<i> α ≃ p # i) (equiv.id α)

  def test_eta {α : Type u} {a b : α} (p : Path a b) : Path p p := rfl
  def face₀ {α : Type u} {a b : α} (p : a ⇝ b) : α := p # 𝕀.i₀
  def face₁ {α : Type u} {a b : α} (p : a ⇝ b) : α := p # 𝕀.i₁

  def comp_test₀ {α : Type u} {a b : α} (p : a ⇝ b) : (p # 𝕀.i₀) ⇝ a := rfl
  def comp_test₁ {α : Type u} {a b : α} (p : a ⇝ b) : (p # 𝕀.i₁) ⇝ b := rfl

  -- fail
  --def symm_test {α : Type u} {a b : α} (p : a ⇝ b) : (p⁻¹)⁻¹ ⇝ p := rfl

  def trans {α : Type u} {a b c : α} (p : a ⇝ b) (q : b ⇝ c) : a ⇝ c :=
  from_eq (eq.trans (to_eq p) (to_eq q))
  infix ⬝ := trans

  def comp {α : Type u} {a b c d : α}
    (bottom : b ⇝ c) (left : b ⇝ a) (right : c ⇝ d) : a ⇝ d :=
  left⁻¹ ⬝ bottom ⬝ right

  --transport (<i> C (comp (<_> A) a [(i=0) -> <_> a,(i=1) -> p])
  --                 (fill (<_> A) a [(i=0) -> <_> a,(i=1) -> p])) d

  def J {α : Type u} {a : α} {π : Π (b : α), a ⇝ b → Type u}
    (h : π a (refl a)) (b : α) (p : a ⇝ b) : π b p :=
  transport (<i> π (comp (<j> a) (<j> a) p # i)
                   (PathP.compute (only_refl p) i)) h
end Path

namespace cubicaltt
  def add (m : ℕ) : ℕ → ℕ
  | 0 := m
  | (n+1) := nat.succ (add n)

  def add_zero : Π (a : ℕ), add nat.zero a ⇝ a
  | 0 := <i> nat.zero
  | (a+1) := <i> nat.succ (add_zero a # i)

  def add_succ (a : ℕ) : Π (b : ℕ), add (nat.succ a) b ⇝ nat.succ (add a b)
  | 0 := <i> nat.succ a
  | (b+1) := <i> nat.succ (add_succ b # i)

  def add_zero_inv : Π (a : ℕ), a ⇝ add a nat.zero :=
  Path.refl

  def add_comm (a : ℕ) : Π (b : ℕ), (add a b) ⇝ (add b a)
  | 0 := <i> (add_zero a) # −i
  | (b+1) := Path.comp (<i> nat.succ (add_comm b # i))
                       (<j> nat.succ (add a b))
                       (<j> add_succ b a # −j)

  def add_assoc (a b : ℕ) : Π (c : ℕ), add a (add b c) ⇝ add (add a b) c
  | 0 := <i> add a b
  | (c+1) := <i> nat.succ (add_assoc c # i)

  def add_comm₃ {a b c : ℕ} : add a (add b c) ⇝ add c (add b a) :=
  let r : add a (add b c) ⇝ add a (add c b) := <i> add a (add_comm b c # i) in
  Path.comp (add_comm a (add c b)) (<j> r # −j) (<j> add_assoc c b a # −j)
end cubicaltt

end ground_zero