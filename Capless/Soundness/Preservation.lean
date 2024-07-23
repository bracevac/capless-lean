import Capless.Store
import Capless.Type
import Capless.Reduction
import Capless.Inversion.Typing
import Capless.Inversion.Lookup
import Capless.Renaming.Term.Subtyping
import Capless.Subst.Term.Typing
import Capless.Subst.Type.Typing
import Capless.Subst.Capture.Typing
namespace Capless

inductive Preserve : EType n m k -> State n' m' k' -> Prop where
| mk :
  TypedState state E ->
  Preserve E state
| mk_weaken :
  TypedState state E.weaken ->
  Preserve E state
| mk_tweaken :
  TypedState state E.tweaken ->
  Preserve E state
| mk_cweaken :
  TypedState state E.cweaken ->
  Preserve E state

theorem preservation
  (hr : Reduce state state')
  (ht : TypedState state E) :
  Preserve E state' := by
  cases hr
  case apply hl =>
    cases ht
    case mk hs ht hc =>
      have hg := TypedStore.is_tight hs
      have ⟨T0, Cf, F0, E0, hx, hy, he1, hs1⟩:= Typed.app_inv ht
      have hv := Store.lookup_inv_typing hl hs hx
      have ⟨hcfs, hcft⟩ := Typed.canonical_form_lam hg hv
      constructor
      constructor
      { trivial }
      { apply Typed.sub
        { apply Typed.open (h := hcft)
          exact hy }
        { subst he1
          trivial } }
      trivial
  case tapply hl =>
    cases ht
    case mk hs ht hc =>
      have hg := TypedStore.is_tight hs
      have ⟨Cf, F, E0, hx, he0, hs0⟩ := Typed.tapp_inv ht
      have hv := Store.lookup_inv_typing hl hs hx
      have ⟨hs1, hft⟩ := Typed.canonical_form_tlam hg hv
      constructor
      constructor
      { trivial }
      { apply Typed.sub
        { apply Typed.topen (h := hft) }
        { subst he0
          trivial } }
      trivial
  case capply hl =>
    cases ht
    case mk hs ht hc =>
      have hg := TypedStore.is_tight hs
      have ⟨Cf, F, E0, hx, he1, hs1⟩ := Typed.capp_inv ht
      have hv := Store.lookup_inv_typing hl hs hx
      have hct := Typed.canonical_form_clam hg hv
      constructor
      constructor
      { trivial }
      { apply Typed.sub
        { apply Typed.copen hct }
        { subst he1
          exact hs1 } }
      trivial
  case unbox hl =>
    cases ht
    case mk hs ht hc =>
      have hg := TypedStore.is_tight hs
      have ⟨S0, hx, he0⟩ := Typed.unbox_inv ht
      have hv := Store.lookup_inv_typing hl hs hx
      have hct := Typed.canonical_form_boxed hg hv
      constructor
      constructor
      { trivial }
      { exact hct }
      subst_vars; exact hc
  case push =>
    cases ht
    case mk hs ht hc =>
      have ⟨T, E0, htt, htu, hsub⟩ := Typed.letin_inv ht
      constructor
      constructor
      { trivial }
      { exact htt }
      { constructor
        apply? Typed.sub
        apply! ESubtyp.weaken
        trivial }
  case push_ex => sorry
  case rename => sorry
  case rename_ex => sorry
  case lift hv => sorry
  case tlift => sorry
  case clift => sorry

end Capless
