import Capless.Basic
import Capless.Context
import Capless.CaptureSet
import Capless.Type.Basic
import Capless.Typing
import Capless.Typing.Basic
import Capless.Renaming.Term.Subtyping
import Capless.Renaming.Type.Subtyping
import Capless.Renaming.Term.Typing
import Capless.Renaming.Type.Typing
import Capless.Renaming.Capture.Typing
import Capless.Inversion.Context
namespace Capless

structure VarSubst (Γ : Context n m k) (f : FinFun n n') (Δ : Context n' m k) where
  map : ∀ x E, Γ.Bound x E -> Typed Δ (Term.var (f x)) (EType.type (E.rename f))
  tmap : ∀ X b, Γ.TBound X b -> Δ.TBound X (b.rename f)
  cmap : ∀ c b, Γ.CBound c b -> Δ.CBound c (b.rename f)

structure TVarSubst (Γ : Context n m k) (f : FinFun m m') (Δ : Context n m' k) where
  map : ∀ x E, Γ.Bound x E -> Δ.Bound x (E.trename f)
  tmap : ∀ X S, Γ.TBound X (TBinding.bound S) ->
    SSubtyp Δ (SType.tvar (f X)) (S.trename f)
  tmap_inst : ∀ X S, Γ.TBound X (TBinding.inst S) ->
    SSubtyp Δ (SType.tvar (f X)) (S.trename f)
  cmap : ∀ c b, Γ.CBound c b -> Δ.CBound c b

structure CVarSubst (Γ : Context n m k) (f : FinFun k k') (Δ : Context n m k') where
  map : ∀ x E, Γ.Bound x E -> Δ.Bound x (E.crename f)
  tmap : ∀ X b, Γ.TBound X b -> Δ.TBound X (b.crename f)
  cmap_inst : ∀ c C, Γ.CBound c (CBinding.inst C) ->
    Subcapt Δ (CaptureSet.csingleton (f c)) (C.crename f)

def VarSubst.ext {Γ : Context n m k}
  (σ : VarSubst Γ f Δ)
  (T : CType n m k) :
  VarSubst (Γ.var T) f.ext (Δ.var (T.rename f)) := by
  constructor
  case map =>
    intros x E hb
    cases hb
    case here =>
      simp [FinFun.ext]
      apply Typed.var
      rw [<- CType.weaken_rename]
      constructor
    case there_var hb0 =>
      simp [FinFun.ext]
      rw [<- CType.weaken_rename]
      have h0 := σ.map _ _ hb0
      have h1 := Typed.weaken h0 (T := T.rename f)
      simp [Term.weaken, Term.rename, FinFun.weaken] at h1
      simp [EType.weaken, EType.rename, CType.weaken] at *
      exact h1
  case tmap =>
    intros X b hb
    cases hb
    case there_var hb0 =>
      have hb1 := σ.tmap _ _ hb0
      rw [<- TBinding.weaken_rename]
      constructor; trivial
  case cmap =>
    intros x b hb
    cases hb
    case there_var hb0 =>
      have hb1 := σ.cmap _ _ hb0
      rw [<- CBinding.weaken_rename]
      constructor; trivial

def VarSubst.text {Γ : Context n m k}
  (σ : VarSubst Γ f Δ) :
  VarSubst (Γ.tvar b) f (Δ.tvar (b.rename f)) := by
  constructor
  case map =>
    intros x T hb
    cases hb
    case there_tvar hb0 =>
      have h0 := σ.map _ _ hb0
      have h1 := h0.tweaken (b := (b.rename f))
      rw [CType.tweaken_rename]
      simp [EType.tweaken, EType.trename,
            CType.tweaken, Term.tweaken, Term.trename] at *
      exact h1
  case tmap =>
    intros X b hb
    cases hb
    case here =>
      rw [TBinding.tweaken_rename_comm]
      constructor
    case there_tvar hb0 =>
      have hb1 := σ.tmap _ _ hb0
      rw [TBinding.tweaken_rename_comm]
      constructor; trivial
  case cmap =>
    intros c b hb
    cases hb
    case there_tvar hb0 =>
      have hb1 := σ.cmap _ _ hb0
      constructor; trivial

def VarSubst.cext {Γ : Context n m k}
  (σ : VarSubst Γ f Δ) :
  VarSubst (Γ.cvar b) f (Δ.cvar (b.rename f)) := by
  constructor
  case map =>
    intros x T hb
    cases hb
    case there_cvar hb0 =>
      have h0 := σ.map _ _ hb0
      have h1 := h0.cweaken (b := (b.rename f))
      rw [CType.cweaken_rename_comm]
      simp [EType.cweaken, EType.crename,
            CType.cweaken, Term.cweaken, Term.crename] at *
      exact h1
  case tmap =>
    intros X b hb
    cases hb
    case there_cvar hb0 =>
      have hb1 := σ.tmap _ _ hb0
      rw [TBinding.cweaken_rename_comm]
      constructor; trivial
  case cmap =>
    intros c b hb
    cases hb
    case here =>
      rw [CBinding.cweaken_rename_comm]
      constructor
    case there_cvar hb0 =>
      have hb1 := σ.cmap _ _ hb0
      rw [CBinding.cweaken_rename_comm]
      constructor; trivial

def VarSubst.open
  (hx : Typed Γ (Term.var x) (EType.type T)) :
  VarSubst (Γ.var T) (FinFun.open x) Γ := by
  constructor
  case map =>
    intro x P hb
    cases hb
    case here =>
      simp [FinFun.open]
      simp [CType.weaken, CType.rename_rename, FinFun.open_comp_weaken]
      simp [CType.rename_id]
      trivial
    case there_var hb0 =>
      simp [FinFun.open]
      simp [CType.weaken, CType.rename_rename, FinFun.open_comp_weaken]
      simp [CType.rename_id]
      apply Typed.bound_typing
      trivial
  case tmap =>
    intro X b hb
    cases hb
    case there_var hb0 =>
      simp [TBinding.weaken, TBinding.rename_rename, FinFun.open_comp_weaken]
      simp [TBinding.rename_id]
      trivial
  case cmap =>
    intro c b hb
    cases hb
    case there_var hb0 =>
      simp [CBinding.weaken, CBinding.rename_rename, FinFun.open_comp_weaken]
      simp [CBinding.rename_id]
      trivial

def VarSubst.narrow
  (hs : CSubtyp Γ T' T) :
  VarSubst (Γ.var T) FinFun.id (Γ.var T') := by
  constructor
  case map =>
    intro x Q hb
    cases hb
    case here =>
      simp [FinFun.id]
      simp [CType.rename_id]
      apply Typed.sub
      apply Typed.var; constructor
      apply ESubtyp.type
      apply hs.weaken
    case there_var hb0 =>
      simp [FinFun.id]
      simp [CType.rename_id]
      apply Typed.var
      constructor
      trivial
  case tmap =>
    intro X b hb
    cases hb
    case there_var hb0 =>
      simp [TBinding.rename_id]
      constructor; trivial
  case cmap =>
    intro c b hb
    cases hb
    case there_var hb0 =>
      simp [CBinding.rename_id]
      constructor; trivial

def TVarSubst.narrow
  (hs : SSubtyp Γ S' S) :
  TVarSubst
    (Γ.tvar (TBinding.bound S))
    FinFun.id
    (Γ.tvar (TBinding.bound S')) := by
  constructor
  case map =>
    intro x T hb
    simp [CType.trename_id]
    cases hb
    constructor
    trivial
  case tmap =>
    intro X S hb
    cases X using Fin.cases
    case zero =>
      cases hb
      simp [SType.trename_id, FinFun.id]
      apply SSubtyp.trans
      { apply SSubtyp.tvar
        { constructor } }
      { apply! SSubtyp.tweaken }
    case succ X0 =>
      simp [FinFun.id, SType.trename_id]
      have ⟨b0, hb0, he0⟩ := Context.tvar_tbound_succ_inv hb
      cases b0
      case bound =>
        simp [TBinding.tweaken, TBinding.trename] at he0
        subst_vars
        rw [<- SType.tvar_tweaken_succ]
        apply SSubtyp.tweaken
        apply! SSubtyp.tvar
      case inst => simp [TBinding.tweaken, TBinding.trename] at he0
  case tmap_inst =>
    intro X S hb
    simp [FinFun.id, SType.trename_id]
    have ⟨X0, S0, hb0, he1, he2⟩ := Context.tbound_tbound_inst_inv hb
    subst_vars
    apply SSubtyp.tinstr
    have h : (TBinding.inst S0).tweaken = TBinding.inst (S0.tweaken) := by
      simp [TBinding.tweaken, TBinding.trename, SType.tweaken]
    rw [<- h]
    constructor
    trivial
  case cmap =>
    intro c b hb
    cases hb
    constructor
    trivial

end Capless
