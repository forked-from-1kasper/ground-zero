import ground_zero.structures ground_zero.HITs.colimit
open ground_zero.types ground_zero.structures (hset)
open ground_zero (pt)

namespace ground_zero.types.nat

hott theory

universes u v w

def glue : ℕ → ℕ + 𝟏
|    0    := coproduct.inr ★
| (n + 1) := coproduct.inl n

def peel_off : ℕ + 𝟏 → ℕ
| (coproduct.inr _) := nat.zero
| (coproduct.inl n) := nat.succ n

@[hott] def closed_nat : ℕ ≃ ℕ + 𝟏 := begin
  existsi glue, split; existsi peel_off,
  { intro n, induction n with n ih; trivial },
  { intro n, induction n,
    { trivial },
    { induction n, trivial } }
end

@[hott] def equiv_addition {α : Type u} {β : Type v} (γ : Type w)
  (e : α ≃ β) : α + γ ≃ β + γ := begin
  induction e with f H,
  have q := qinv.of_biinv f H,
  cases q with g inv, induction inv with α' β',

  let f : α + γ → β + γ := λ x, match x with
  | coproduct.inl a := coproduct.inl (f a)
  | coproduct.inr c := coproduct.inr c
  end,
  let g : β + γ → α + γ := λ x, match x with
  | coproduct.inl b := coproduct.inl (g b)
  | coproduct.inr c := coproduct.inr c
  end,

  existsi f, split; existsi g,
  { intro x, induction x,
    { apply eq.map sum.inl, apply β' },
    { trivial } },
  { intro x, induction x,
    { apply eq.map sum.inl, apply α' },
    { trivial } }
end

@[hott] example : ℕ ≃ ℕ + 𝟏 + 𝟏 := begin
  transitivity, exact closed_nat,
  apply equiv_addition, exact closed_nat
end

@[hott] def nat_plus_unit (n : ℕ) : ℕ ≃ pt ℕ n := begin
  induction n with n ih,
  { reflexivity },
  { transitivity,
    exact closed_nat, change _ ≃ _ + _,
    apply equiv_addition 𝟏 ih }
end

abbreviation lift_unit (n : ℕ) : pt 𝟏 n → pt 𝟏 (n + 1) :=
coproduct.inl

def lift_to_top (x : 𝟏) : Π (n : ℕ), pt 𝟏 n
|   0     := x
| (n + 1) := coproduct.inl (lift_to_top n)

def iterated := ground_zero.HITs.colimit (pt 𝟏) lift_unit

def iterated.encode : ℕ → iterated
|    0    := ground_zero.HITs.colimit.inclusion 0 ★
| (n + 1) := ground_zero.HITs.colimit.inclusion (n + 1) (coproduct.inr ★)

def code : ℕ → ℕ → Type
|    0       0    := 𝟏
| (m + 1)    0    := 𝟎
|    0    (n + 1) := 𝟎
| (m + 1) (n + 1) := code m n

def r : Π n, code n n
|    0    := ★
| (n + 1) := r n

def encode {m n : ℕ} (p : m = n) : code m n :=
equiv.subst p (r m)

@[hott] def decode : Π {m n : ℕ}, code m n → m = n
|    0       0    p := by reflexivity
| (m + 1)    0    p := by cases p
|    0    (n + 1) p := by cases p
| (m + 1) (n + 1) p := begin
  apply eq.map nat.succ, apply decode, exact p
end

@[hott] def decode_encode {m n : ℕ} (p : m = n) : decode (encode p) = p :=
begin
  induction p, induction m with m ih,
  { reflexivity },
  { transitivity, apply eq.map (eq.map nat.succ),
    apply ih, reflexivity }
end

@[hott] def encode_decode : Π {m n : ℕ} (p : code m n), encode (decode p) = p
|    0       0    p := begin cases p, reflexivity end
| (m + 1)    0    p := by cases p
|    0    (n + 1) p := by cases p
| (m + 1) (n + 1) p := begin
  transitivity, symmetry,
  apply @equiv.transport_comp ℕ ℕ (code (m + 1)) m n
        nat.succ (decode p) (r (m + 1)),
  apply encode_decode
end

@[hott] def recognize (m n : ℕ) : m = n ≃ code m n := begin
  existsi encode, split; existsi decode,
  apply decode_encode, apply encode_decode
end

end ground_zero.types.nat