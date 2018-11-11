namespace ground_zero

universes u v

theorem K {α : Sort u} {a b : α} (p q : a = b) : p = q :=
by trivial

inductive eq {α : Sort u} (a : α) : α → Sort u
| refl : eq a
attribute [refl] eq.refl

local infix ` = ` := eq
notation a ` = ` b ` :> ` α := @eq α a b

/- fails!
theorem K₁ {α : Sort u} {a b : α} (p q : a = b :> α) :
  p = q :> (a = b :> α) :=
by trivial
-/

namespace eq
  @[inline] def rfl {α : Sort u} {a : α} : a = a :> α :=
  eq.refl a

  @[trans] def trans {α : Sort u} {a b c : α}
    (p : a = b :> α) (q : b = c :> α) : a = c :> α :=
  begin induction p, assumption end

  @[symm] def symm {α : Sort u} {a b : α} (p : a = b :> α) :
    b = a :> α :=
  begin induction p, reflexivity end

  infix ` ⬝ ` := trans
  postfix ⁻¹ := symm

  def comp_inv {α : Sort u} {a b : α} (p : a = b :> α) :
    p ⬝ p⁻¹ = eq.refl a :> a = a :> α :=
  begin induction p, trivial end

  def refl_left {α : Sort u} {a b : α} (p : a = b :> α) :
    eq.refl a ⬝ p = p :> a = b :> α :=
  begin induction p, trivial end

  def refl_right {α : Sort u} {a b : α} (p : a = b :> α) :
    p ⬝ eq.refl b = p :> a = b :> α :=
  begin induction p, trivial end

  def assoc {α : Sort u} {a b c d : α}
    (p : a = b :> α) (q : b = c :> α) (r : c = d :> α) :
    p ⬝ (q ⬝ r) = (p ⬝ q) ⬝ r := begin
    induction p, induction q, induction r,
    trivial
  end

  def map {α : Sort u} {β : Sort v} {a b : α}
    (f : α → β) (p : a = b :> α) : f a = f b :> β :=
  begin induction p, reflexivity end
  infix ` # ` := map

  class dotted (space : Sort u) :=
  (point : space)

  structure pointed :=
  (space : Sort u) (point : space)

  def loop_space (X : pointed) : pointed :=
  ⟨X.point = X.point :> X.space, eq.refl X.point⟩

  def iterated_loop_space : pointed → ℕ → pointed
  | X 0 := X
  | X (n+1) := iterated_loop_space (loop_space X) n

  def loop_pointed_space (α : Sort u) [h : dotted α] :=
  iterated_loop_space ⟨α, dotted.point α⟩

  notation `Ω` `[` n `]` `, ` X := (iterated_loop_space X n).space
  notation `Ω¹` X := (loop_pointed_space X 1).space
end eq

namespace not
  notation `¬` a := a → empty
  notation a ` ≠ ` b := ¬(a = b :> _)
end not

end ground_zero