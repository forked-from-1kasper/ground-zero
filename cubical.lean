import ground_zero.interval ground_zero.heq
import ground_zero.support ground_zero.product
open ground_zero.interval

namespace ground_zero

namespace path

universes u v

inductive binary (α : Sort u) : ℕ → Type u
| leaf {} : α → α → binary 0
| node {n : ℕ} : binary n → binary n → binary (n + 1)

def interval_cube : ℕ → Type
| 0 := 𝕀
| (n + 1) := interval_cube n × 𝕀

def construct_cube {α : Sort u} :
  Π {n : ℕ}, (interval_cube n → α) → binary α n
| 0 f := binary.leaf (f i₀) (f i₁)
| (n + 1) f := binary.node
  (construct_cube (λ n, f ⟨n, i₀⟩))
  (construct_cube (λ n, f ⟨n, i₁⟩))

inductive cube {α : Sort u} (n : ℕ) : binary α n → Type u
| lam (f : interval_cube n → α) : cube (construct_cube f)

def path {α : Sort u} (a b : α) := cube 0 (binary.leaf a b)
def path.lam {α : Sort u} (f : 𝕀 → α) :
  path (f i₀) (f i₁) :=
cube.lam f

def square {α : Sort u} (a b c d : α) :=
cube 1 (binary.node (binary.leaf a b) (binary.leaf c d))
def square.lam {α : Sort u} (f : 𝕀 → 𝕀 → α) :
  square (f i₀ i₀) (f i₁ i₀) (f i₀ i₁) (f i₁ i₁) :=
cube.lam (λ (x : interval_cube 1), product.elim f x)

def line {α : Sort u} {a b : α} (p : a = b :> α) : path a b :=
path.lam (interval.rec a b p)

def equality {α : Sort u} {a b : α} (p : path a b) : a = b :> α :=
@cube.rec α 0 (begin intros B p, cases B with a b, exact a = b :> α end)
  (λ f, f # seg) (binary.leaf a b) p

def compute {α : Sort u} {a b : α} (p : path a b) : 𝕀 → α :=
interval.rec a b (equality p)
infix ` # ` := compute
notation `<` binder `>` r:(scoped P, path.lam P) := r

/-
                     p
          a -----------------> b
          ^                    ^
          |                    |
          |                    |
    <j> a |     conn_and p     | p
          |                    |
          |                    |
          |                    |
          a -----------------> a
                   <i> a
  vertices are written from left to right, from bottom to top:
    square a a a b
-/
def conn_and {α : Sort u} {a b : α}
  (p : a = b :> α) : square a a a b :=
square.lam (λ i j, interval.rec a b p (i ∧ j))

infix ` ⇝ `:30 := path

--def only_refl {α : Type u} {a b : α}
--  (p : a ⇝ b) : PathP (λ i, a ⇝ (p # i)) (<i> a) p := begin
--  admit
--end

@[refl] def refl {α : Type u} (a : α) : a ⇝ a := <i> a
@[refl] def rfl {α : Type u} {a : α} : a ⇝ a := <i> a

@[symm] def symm {α : Type u} {a b : α} (p : a ⇝ b) : b ⇝ a :=
<i> p # −i
postfix `⁻¹` := symm

def funext {α : Type u} {β : Type v} {f g : α → β}
  (p : Π (x : α), f x ⇝ g x) : f ⇝ g :=
<i> λ x, (p x) # i

def cong {α : Type u} {β : Type v} {a b : α}
  (f : α → β) (p : a ⇝ b) : f a ⇝ f b :=
<i> f (p # i)

def subst {α : Type u} {π : α → Type v} {a b : α}
  (p : a ⇝ b) : π a → π b :=
equiv.subst (equality p)

def transport {α β : Type u} : (α ⇝ β) → (α → β) :=
psigma.fst ∘ equiv.idtoeqv ∘ equality

def idtoeqv {α β : Type u} (p : α ⇝ β) : α ≃ β :=
transport (<i> α ≃ p # i) (equiv.id α)

def test_eta {α : Type u} {a b : α} (p : a ⇝ b) : p ⇝ p := rfl
def face₀ {α : Type u} {a b : α} (p : a ⇝ b) : α := p # i₀
def face₁ {α : Type u} {a b : α} (p : a ⇝ b) : α := p # i₁

def comp_test₀ {α : Type u} {a b : α} (p : a ⇝ b) : (p # i₀) ⇝ a := rfl
def comp_test₁ {α : Type u} {a b : α} (p : a ⇝ b) : (p # i₁) ⇝ b := rfl

-- fail
--def symm_test {α : Type u} {a b : α} (p : a ⇝ b) : (p⁻¹)⁻¹ ⇝ p := rfl

def trans {α : Type u} {a b c : α} (p : a ⇝ b) (q : b ⇝ c) : a ⇝ c :=
line (equality p ⬝ equality q)
infix ⬝ := trans

-- this will be replaced by a more general version in future
def comp {α : Type u} {a b c d : α}
  (bottom : b ⇝ c) (left : b ⇝ a) (right : c ⇝ d) : a ⇝ d :=
left⁻¹ ⬝ bottom ⬝ right

--def J {α : Type u} {a : α} {π : Π (b : α), a ⇝ b → Type u}
--  (h : π a (refl a)) (b : α) (p : a ⇝ b) : π b p :=
--transport (<i> π (comp (<j> a) (<j> a) p # i)
--                 (PathP.compute (only_refl p) i)) h

--theorem general_equality_condition {α : Type u} {a b : α} :
--  (a ⇝ b) ≃ (a = b :> α) := begin
--  existsi to_eq, split; existsi from_eq,
--  { intro p, simp, induction p, simp [from_eq],
--    admit },
--  { intro x, admit }
--end

end path

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
path.refl

def add_comm (a : ℕ) : Π (b : ℕ), add a b ⇝ add b a
| 0 := <i> (add_zero a) # −i
| (b+1) := path.comp (<i> nat.succ (add_comm b # i))
                     (<j> nat.succ (add a b))
                     (<j> add_succ b a # −j)

def add_assoc (a b : ℕ) : Π (c : ℕ), add a (add b c) ⇝ add (add a b) c
| 0 := <i> add a b
| (c+1) := <i> nat.succ (add_assoc c # i)

def add_comm₃ {a b c : ℕ} : add a (add b c) ⇝ add c (add b a) :=
let r : add a (add b c) ⇝ add a (add c b) := <i> add a (add_comm b c # i) in
path.comp (add_comm a (add c b)) (<j> r # −j) (<j> add_assoc c b a # −j)

example (n m : ℕ) (h : n ⇝ m) : nat.succ n ⇝ nat.succ m :=
<i> nat.succ (h # i)

end cubicaltt

end ground_zero