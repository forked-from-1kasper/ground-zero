import ground_zero.HITs.interval ground_zero.types.sigma
open ground_zero ground_zero.HITs ground_zero.HITs.interval

hott theory

namespace ground_zero.theorems.fibration
  universes u v

  inductive leg {α : Type u} : α → Type u
  | lam (f : I → α) : leg (f 0)

  inductive post {α : Type u} : α → Type u
  | lam (f : I → α) : post (f 1)

  def lifting_property {α : Type u} {β : Type v} (p : α → β) :=
  Π {x : α}, leg (p x) → leg x

  def fibration (α : Type u) (β : Type v) :=
  Σ (p : α → β), lifting_property p

  notation α ` ↠ ` β := fibration α β

  def lifting {α : Type u} {β : α → Type v} (f : I → α)
    (u : β (f 0)) : @leg (sigma β) ⟨f 0, u⟩ :=
  @leg.lam (sigma β) (λ i, ⟨f i,
    @interval.ind (β ∘ f) u (types.equiv.subst seg u)
      types.eq.rfl i⟩)

  def type_family {α : Type u} (β : α → Type v) :
    (Σ x, β x) ↠ α := begin
    existsi sigma.fst, intros x f,
    cases x with x u, cases f with f u, apply lifting
  end

  def forward {α : Type u} {β : α → Type v} (x : α) :
    types.fib (@sigma.fst α β) x → β x
  | ⟨⟨y, u⟩, h⟩ := types.equiv.subst h u

  def backward {α : Type u} {β : α → Type v} (x : α) (u : β x) :
    types.fib (@sigma.fst α β) x :=
  ⟨⟨x, u⟩, by trivial⟩

  theorem fiber_over {α : Type u} {β : α → Type v} (x : α) :
    types.fib (@sigma.fst α β) x ≃ β x := begin
    existsi (forward x), split; existsi (@backward α β x),
    { intro u, cases u with u h, cases u with y u,
      induction h, fapply types.sigma.prod; trivial },
    { intro u, trivial }
  end
end ground_zero.theorems.fibration