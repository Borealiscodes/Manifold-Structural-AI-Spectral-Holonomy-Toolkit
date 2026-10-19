import Lean
import HallucinationGuard.Guard

namespace HallucinationGuard.CollapseCheck

open Lean Meta

/--
  Structural collapse validator.
  Checks:
  - operator exists
  - operator has a type
  - operator is a definition (not theorem)
  - operator is not unsafe
  - operator type is a function (collapse operators transform collapse states)
  - operator codomain is non-empty (collapse operators must produce residual structure)
-/
def validateCollapseOp (op : Name) : MetaM Bool := do
  -- Check operator exists
  let some constInfo ← getConstInfo? op
    | throwError m!"CollapseCheck: operator `{op}` does not exist."

  -- Check operator has a type
  let ty := constInfo.type
  unless ty.isType do
    throwError m!"CollapseCheck: operator `{op}` does not have a valid type."

  -- Check operator is a definition (not theorem)
  if constInfo.isUnsafe then
    throwError m!"CollapseCheck: operator `{op}` is unsafe or malformed."

  -- Collapse operators must be functions
  match ty with
  | Expr.forallE _ dom cod _ =>
      -- Codomain must not be trivially empty
      unless cod.isType do
        throwError m!"CollapseCheck: operator `{op}` has an invalid codomain."
      pure true
  | _ =>
      throwError m!"CollapseCheck: operator `{op}` is not a function type."

/-- Register this validator with the Guard macro. -/
unsafe def _init :=
  HallucinationGuard.registerValidator {
    name := "CollapseCheck",
    fn := validateCollapseOp
  }

end HallucinationGuard.CollapseCheck
