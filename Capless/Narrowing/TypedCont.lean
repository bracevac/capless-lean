import Capless.Tactics
import Capless.Store
import Capless.Subtyping.Basic
import Capless.Narrowing.Typing
namespace Capless

theorem TypedCont.narrow
  (h : TypedCont Γ E1 cont E)
  (hsub : ESubtyp Γ E2 E1) :
  TypedCont Γ E2 cont E := by
  cases h
  case none =>
    apply TypedCont.none
    apply? ESubtyp.trans
  case cons =>
    cases hsub
    rename_i hsub
    apply TypedCont.cons
    { apply! Typed.narrow }
    { trivial }
  case conse =>
    cases hsub
    rename_i hsub
    apply TypedCont.conse
    { apply! Typed.narrow }
    { trivial }

end Capless
