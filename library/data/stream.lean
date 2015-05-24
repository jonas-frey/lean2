/-
Copyright (c) 2015 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Author: Leonardo de Moura
-/
import data.nat data.list algebra.function
open nat function option

definition stream (A : Type) := nat → A

namespace stream
variables {A B C : Type}

definition cons (a : A) (s : stream A) : stream A :=
λ i,
  match i with
  | 0      := a
  | succ n := s n
  end

notation h :: t := cons h t

definition head (s : stream A) : A :=
s 0

definition tail (s : stream A) : stream A :=
λ i, s (i+1)

definition drop (n : nat) (s : stream A) : stream A :=
λ i, s (i+n)

definition nth (n : nat) (s : stream A) : A :=
s n

protected theorem eta (s : stream A) : head s :: tail s = s :=
funext (λ i, begin cases i, repeat reflexivity end)

theorem nth_zero_cons (a : A) (s : stream A) : nth 0 (a :: s) = a :=
rfl

theorem head_cons (a : A) (s : stream A) : head (a :: s) = a :=
rfl

theorem tail_cons (a : A) (s : stream A) : tail (a :: s) = s :=
rfl

theorem tail_drop (n : nat) (s : stream A) : tail (drop n s) = drop n (tail s) :=
funext (λ i, begin esimp [tail, drop], congruence, rewrite add.right_comm end)

theorem nth_drop (n m : nat) (s : stream A) : nth n (drop m s) = nth (n+m) s :=
rfl

theorem tail_eq_drop (s : stream A) : tail s = drop 1 s :=
rfl

theorem drop_drop (n m : nat) (s : stream A) : drop n (drop m s) = drop (n+m) s :=
funext (λ i, begin esimp [drop], rewrite add.assoc end)

theorem nth_succ (n : nat) (s : stream A) : nth (succ n) s = nth n (tail s) :=
rfl

theorem drop_succ (n : nat) (s : stream A) : drop (succ n) s = drop n (tail s) :=
rfl

protected theorem ext {s₁ s₂ : stream A} : (∀ n, nth n s₁ = nth n s₂) → s₁ = s₂ :=
assume h, funext h

protected definition all (p : A → Prop) (s : stream A) := ∀ n, p (nth n s)

protected definition any (p : A → Prop) (s : stream A) := ∃ n, p (nth n s)

theorem all_def (p : A → Prop) (s : stream A) : stream.all p s = ∀ n, p (nth n s) :=
rfl

theorem any_def (p : A → Prop) (s : stream A) : stream.any p s = ∃ n, p (nth n s) :=
rfl

section map
variable (f : A → B)

definition map (s : stream A) : stream B :=
λ n, f (nth n s)

theorem drop_map (n : nat) (s : stream A) : drop n (map f s) = map f (drop n s) :=
stream.ext (λ i, rfl)

theorem nth_map (n : nat) (s : stream A) : nth n (map f s) = f (nth n s) :=
rfl

theorem tail_map (s : stream A) : tail (map f s) = map f (tail s) :=
begin rewrite tail_eq_drop end

theorem head_map (s : stream A) : head (map f s) = f (head s) :=
rfl

theorem map_eq (s : stream A) : map f s = f (head s) :: map f (tail s) :=
by rewrite [-stream.eta, tail_map, head_map]

theorem map_cons (a : A) (s : stream A) : map f (a :: s) = f a :: map f s :=
by rewrite [-stream.eta, map_eq]

theorem map_id (s : stream A) : map id s = s :=
rfl
end map

section zip
variable (f : A → B → C)

definition zip (s₁ : stream A) (s₂ : stream B) : stream C :=
λ n, f (nth n s₁) (nth n s₂)

theorem drop_zip (n : nat) (s₁ : stream A) (s₂ : stream B) : drop n (zip f s₁ s₂) = zip f (drop n s₁) (drop n s₂) :=
stream.ext (λ i, rfl)

theorem nth_zip (n : nat) (s₁ : stream A) (s₂ : stream B) : nth n (zip f s₁ s₂) = f (nth n s₁) (nth n s₂) :=
rfl

theorem head_zip (s₁ : stream A) (s₂ : stream B) : head (zip f s₁ s₂) = f (head s₁) (head s₂) :=
rfl

theorem tail_zip (s₁ : stream A) (s₂ : stream B) : tail (zip f s₁ s₂) = zip f (tail s₁) (tail s₂) :=
rfl

theorem zip_eq (s₁ : stream A) (s₂ : stream B) : zip f s₁ s₂ = f (head s₁) (head s₂) :: zip f (tail s₁) (tail s₂) :=
by rewrite [-stream.eta]
end zip

definition const (a : A) : stream A :=
λ n, a

theorem const_eq (a : A) : const a = a :: const a :=
begin
  apply stream.ext, intro n,
  cases n, repeat reflexivity
end

theorem tail_const (a : A) : tail (const a) = const a :=
by rewrite [const_eq at {1}]

theorem map_const (f : A → B) (a : A) : map f (const a) = const (f a) :=
rfl

theorem nth_const (n : nat) (a : A) : nth n (const a) = a :=
rfl

theorem drop_const (n : nat) (a : A) : drop n (const a) = const a :=
stream.ext (λ i, rfl)

definition iterate (f : A → A) (a : A) : stream A :=
λ n, nat.rec_on n a (λ n r, f r)

theorem head_iterate (f : A → A) (a : A) : head (iterate f a) = a :=
rfl

theorem tail_iterate (f : A → A) (a : A) : tail (iterate f a) = iterate f (f a) :=
begin
  apply funext, intro n,
  induction n with n' IH,
    {reflexivity},
    {esimp [tail, iterate] at *,
     rewrite add_one at *,
     esimp at *, rewrite IH}
end

theorem iterate_eq (f : A → A) (a : A) : iterate f a = a :: iterate f (f a) :=
begin
  rewrite [-stream.eta], congruence, exact !tail_iterate
end

theorem nth_zero_iterate (f : A → A) (a : A) : nth 0 (iterate f a) = a :=
rfl

theorem nth_succ_iterate (n : nat) (f : A → A) (a : A) : nth (succ n) (iterate f a) = nth n (iterate f (f a)) :=
by rewrite [nth_succ, tail_iterate]

section bisim
  variable (R : stream A → stream A → Prop)
  local infix ~ := R

  definition is_bisimulation := ∀ ⦃s₁ s₂⦄, s₁ ~ s₂ → head s₁ = head s₂ ∧ tail s₁ ~ tail s₂

  lemma nth_of_bisim (bisim : is_bisimulation R) : ∀ {s₁ s₂} n, s₁ ~ s₂ → nth n s₁ = nth n s₂ ∧ drop (n+1) s₁ ~ drop (n+1) s₂
  | s₁ s₂ 0     h := bisim h
  | s₁ s₂ (n+1) h :=
    obtain h₁ (trel : tail s₁ ~ tail s₂), from bisim h,
    nth_of_bisim n trel

  -- If two streams are bisimilar, then they are equal
  theorem eq_of_bisim (bisim : is_bisimulation R) : ∀ {s₁ s₂}, s₁ ~ s₂ → s₁ = s₂ :=
  λ s₁ s₂ r, stream.ext (λ n, and.elim_left (nth_of_bisim R bisim n r))
end bisim

theorem bisim_simple (s₁ s₂ : stream A) : head s₁ = head s₂ → s₁ = tail s₁ → s₂ = tail s₂ → s₁ = s₂ :=
assume hh ht₁ ht₂, eq_of_bisim
  (λ s₁ s₂, head s₁ = head s₂ ∧ s₁ = tail s₁ ∧ s₂ = tail s₂)
  (λ s₁ s₂ h,
    obtain h₁ h₂ h₃, from h,
    begin
      constructor, exact h₁, rewrite [-h₂, -h₃], exact h
    end)
  (and.intro hh (and.intro ht₁ ht₂))

-- AKA coinduction freeze
theorem coinduction.{l} {A : Type.{l}} {s₁ s₂ : stream A} :
        head s₁ = head s₂ → (∀ (B : Type.{l}) (fr : stream A → B), fr s₁ = fr s₂ → fr (tail s₁) = fr (tail s₂)) → s₁ = s₂ :=
assume hh ht,
  eq_of_bisim
    (λ s₁ s₂, head s₁ = head s₂ ∧ ∀ (B : Type) (fr : stream A → B), fr s₁ = fr s₂ → fr (tail s₁) = fr (tail s₂))
    (λ s₁ s₂ h,
      have h₁ : head s₁ = head s₂,               from and.elim_left h,
      have h₂ : head (tail s₁) = head (tail s₂), from and.elim_right h A (@head A) h₁,
      have h₃ : ∀ (B : Type) (fr : stream A → B), fr (tail s₁) = fr (tail s₂) → fr (tail (tail s₁)) = fr (tail (tail s₂)), from
        λ B fr, and.elim_right h B (λ s, fr (tail s)),
      and.intro h₁ (and.intro h₂ h₃))
    (and.intro hh ht)

theorem iterate_id (a : A) : iterate id a = const a :=
coinduction
  rfl
  (λ B fr ch, by rewrite [tail_iterate, tail_const]; exact ch)

theorem map_iterate (f : A → A) (a : A) : iterate f (f a) = map f (iterate f a) :=
begin
  apply funext, intro n,
  induction n with n' IH,
    {reflexivity},
    {esimp [map, iterate, nth] at *,
     rewrite IH}
end

section corec
  definition corec (f : A → B) (g : A → A) : A → stream B :=
  λ a, map f (iterate g a)

  theorem corec_def (f : A → B) (g : A → A) (a : A) : corec f g a = map f (iterate g a) :=
  rfl

  theorem corec_eq (f : A → B) (g : A → A) (a : A) : corec f g a = f a :: corec f g (g a) :=
  by rewrite [corec_def, map_eq, head_iterate, tail_iterate]

  theorem corec_id_id_eq_const (a : A) : corec id id a = const a :=
  by rewrite [corec_def, map_id, iterate_id]

  theorem corec_id_f_eq_iterate (f : A → A) (a : A) : corec id f a = iterate f a :=
  rfl
end corec

definition interleave (s₁ s₂ : stream A) : stream A :=
corec
  (λ p, obtain s₁ s₂, from p, head s₁)
  (λ p, obtain s₁ s₂, from p, (s₂, tail s₁))
  (s₁, s₂)

infix `⋈`:65 := interleave

theorem interleave_eq (s₁ s₂ : stream A) : s₁ ⋈ s₂ = head s₁ :: head s₂ :: (tail s₁ ⋈ tail s₂) :=
begin
  esimp [interleave], rewrite corec_eq, esimp, congruence, rewrite corec_eq
end

theorem tail_interleave (s₁ s₂ : stream A) : tail (s₁ ⋈ s₂) = s₂ ⋈ (tail s₁) :=
by esimp [interleave]; rewrite corec_eq

theorem interleave_tail_tail (s₁ s₂ : stream A) : tail s₁ ⋈ tail s₂ = tail (tail (s₁ ⋈ s₂)) :=
by rewrite [interleave_eq s₁ s₂]

definition even (s : stream A) : stream A :=
corec
  (λ s, head s)
  (λ s, tail (tail s))
  s

definition odd (s : stream A) : stream A :=
even (tail s)

theorem odd_eq (s : stream A) : odd s = even (tail s) :=
rfl

theorem head_even (s : stream A) : head (even s) = head s :=
rfl

theorem tail_even (s : stream A) : tail (even s) = even (tail (tail s)) :=
by esimp [even]; rewrite corec_eq

theorem even_cons_cons (a₁ a₂ : A) (s : stream A) : even (a₁ :: a₂ :: s) = a₁ :: even s :=
by esimp [even]; rewrite corec_eq

theorem even_tail (s : stream A) : even (tail s) = odd s :=
rfl

theorem even_interleave (s₁ s₂ : stream A) : even (s₁ ⋈ s₂) = s₁ :=
eq_of_bisim
  (λ s₁' s₁, ∃ s₂, s₁' = even (s₁ ⋈ s₂))
  (λ s₁' s₁ h,
    obtain s₂ (h₁ : s₁' = even (s₁ ⋈ s₂)), from h,
    begin
      rewrite h₁,
      constructor,
       {reflexivity},
       {existsi (tail s₂),
        rewrite [interleave_eq, even_cons_cons, tail_cons],
        apply rfl}
    end)
  (exists.intro s₂ rfl)

theorem interleave_even_odd (s₁ : stream A) : even s₁ ⋈ odd s₁ = s₁ :=
eq_of_bisim
  (λ s' s, s' = even s ⋈ odd s)
  (λ s' s (h : s' = even s ⋈ odd s),
    begin
      rewrite h, constructor,
       {reflexivity},
       {esimp, rewrite [*odd_eq, tail_interleave, tail_even]}
    end)
  rfl

open list
definition append : list A → stream A → stream A
| []     s := s
| (a::l) s := a :: append l s

theorem nil_append (s : stream A) : append [] s = s :=
rfl

theorem cons_append (a : A) (l : list A) (s : stream A) : append (a::l) s = a :: append l s :=
rfl

infix ++ := append
-- the following local notation is used just to make the following theorem clear
local infix `++ₛ`:65 := append

theorem append_append : ∀ (l₁ l₂ : list A) (s : stream A), (l₁ ++ l₂) ++ₛ s = l₁ ++ (l₂ ++ₛ s)
| []      l₂ s := rfl
| (a::l₁) l₂ s := by rewrite [list.append_cons, *cons_append, append_append]

theorem map_append (f : A → B) : ∀ (l : list A) (s : stream A), map f (l ++ s) = list.map f l ++ map f s
| []     s := rfl
| (a::l) s := by rewrite [cons_append, list.map_cons, map_cons, cons_append, map_append]

theorem drop_append : ∀ (l : list A) (s : stream A), drop (length l) (l ++ s) = s
| []     s := by esimp
| (a::l) s := by rewrite [length_cons, add_one, drop_succ, cons_append, tail_cons, drop_append]

theorem append_head_tail (s : stream A) : [head s] ++ tail s = s :=
by rewrite [cons_append, nil_append, stream.eta]

definition approx : nat → stream A → list A
| 0     s := []
| (n+1) s := head s :: approx n (tail s)

theorem approx_zero (s : stream A) : approx 0 s = [] :=
rfl

theorem approx_succ (n : nat) (s : stream A) : approx (succ n) s = head s :: approx n (tail s) :=
rfl

theorem nth_approx : ∀ (n : nat) (s : stream A), list.nth (approx (succ n) s) n = some (nth n s)
| 0     s := rfl
| (n+1) s := begin rewrite [approx_succ, add_one, list.nth_succ, nth_approx] end

theorem append_approx_drop : ∀ (n : nat) (s : stream A), append (approx n s) (drop n s) = s :=
begin
  intro n,
  induction n with n' ih,
   {intro s, reflexivity},
   {intro s, rewrite [approx_succ, drop_succ, cons_append, ih (tail s), stream.eta]}
end

-- Take lemma reduces a proof of equality of infinite streams to an
-- induction over all their finite approximations.
theorem take_lemma (s₁ s₂ : stream A) : (∀ (n : nat), approx n s₁ = approx n s₂) → s₁ = s₂ :=
begin
  intro h, apply stream.ext, intro n,
    induction n with n ih,
     {injection (h 1), assumption},
     {have h₁ : some (nth (succ n) s₁) = some (nth (succ n) s₂), by rewrite [-*nth_approx, h (succ (succ n))],
      injection h₁, assumption}
end

-- auxiliary definition for cycle corecursive definition
private definition cycle_f : A × list A × A × list A → A
| (v, _, _, _) := v

-- auxiliary definition for cycle corecursive definition
private definition cycle_g : A × list A × A × list A → A × list A × A × list A
| (v₁, [],     v₀, l₀) := (v₀, l₀, v₀, l₀)
| (v₁, v₂::l₂, v₀, l₀) := (v₂, l₂, v₀, l₀)

private lemma cycle_g_cons (a : A) (a₁ : A) (l₁ : list A) (a₀ : A) (l₀ : list A) :
              cycle_g (a, a₁::l₁, a₀, l₀) = (a₁, l₁, a₀, l₀) :=
rfl

definition cycle : Π (l : list A), l ≠ nil → stream A
| []     h := absurd rfl h
| (a::l) h := corec cycle_f cycle_g (a, l, a, l)

theorem cycle_eq : ∀ (l : list A) (h : l ≠ nil), cycle l h = l ++ cycle l h
| []     h := absurd rfl h
| (a::l) h :=
  have gen : ∀ l' a', corec cycle_f cycle_g (a', l', a, l) = (a' :: l') ++ₛ corec cycle_f cycle_g (a, l, a, l),
    begin
      intro l',
      induction l' with a₁ l₁ ih,
        {intro a', rewrite [corec_eq]},
        {intro a', rewrite [corec_eq, cycle_g_cons, ih a₁]}
    end,
  gen l a

theorem cycle_singleton (a : A) (h : [a] ≠ nil) : cycle [a] h = const a :=
coinduction
  rfl
  (λ B fr ch, by rewrite [cycle_eq, const_eq]; exact ch)

definition tails (s : stream A) : stream (stream A) :=
corec id tail (tail s)

theorem tails_eq (s : stream A) : tails s = tail s :: tails (tail s) :=
by esimp [tails]; rewrite [corec_eq]

theorem nth_tails : ∀ (n : nat) (s : stream A), nth n (tails s) = drop n (tail s) :=
begin
  intro n, induction n with n' ih,
    {intros, reflexivity},
    {intro s, rewrite [nth_succ, drop_succ, tails_eq, tail_cons, ih]}
end

definition inits_core (l : list A) (s : stream A) : stream (list A) :=
corec
  prod.pr1
  (λ p, match p with (l', s') := (l' ++ [head s'], tail s') end)
  (l, s)

definition inits (s : stream A) : stream (list A) :=
inits_core [head s] (tail s)

theorem inits_core_eq (l : list A) (s : stream A) : inits_core l s = l :: inits_core (l ++ [head s]) (tail s) :=
by esimp [inits_core]; rewrite [corec_eq]

theorem tail_inits (s : stream A) : tail (inits s) = inits_core [head s, head (tail s)] (tail (tail s)) :=
by esimp [inits]; rewrite inits_core_eq

theorem inits_tail (s : stream A) : inits (tail s) = inits_core [head (tail s)] (tail (tail s)) :=
rfl

theorem cons_nth_inits_core : ∀ (a : A) (n : nat) (l : list A) (s : stream A),
                                 a :: nth n (inits_core l s) = nth n (inits_core (a::l) s) :=
begin
  intro a n,
  induction n with n' ih,
   {intros, reflexivity},
   {intro l s, rewrite [*nth_succ, inits_core_eq, +tail_cons, ih, inits_core_eq (a::l) s] }
end

theorem nth_inits : ∀ (n : nat) (s : stream A), nth n (inits s) = approx (succ n) s  :=
begin
  intro n, induction n with n' ih,
    {intros, reflexivity},
    {intros, rewrite [nth_succ, approx_succ, -ih, tail_inits, inits_tail, cons_nth_inits_core]}
end

theorem inits_eq (s : stream A) : inits s = [head s] :: map (list.cons (head s)) (inits (tail s)) :=
begin
  apply stream.ext, intro n,
  cases n,
    {reflexivity},
    {rewrite [nth_inits, nth_succ, tail_cons, nth_map, nth_inits]}
end

theorem zip_inits_tails (s : stream A) : zip append (inits s) (tails s) = const s :=
begin
  apply stream.ext, intro n,
  rewrite [nth_zip, nth_inits, nth_tails, nth_const, approx_succ,
           cons_append, append_approx_drop, stream.eta]
end
end stream