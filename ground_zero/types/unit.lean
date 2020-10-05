import ground_zero.types.equiv

namespace ground_zero.types

universe u
inductive unit : Type u
| star : unit

notation `𝟏` := unit
notation `★` := unit.star

namespace unit
  def elim {α : Type u} (a : α) : unit → α
  | star := a

  def ind {π : unit → Type u} (g : π star) : Π (x : unit), π x
  | star := g

  def uniq : Π (x : unit), x = star :> unit
  | star := idp star
end unit

end ground_zero.types