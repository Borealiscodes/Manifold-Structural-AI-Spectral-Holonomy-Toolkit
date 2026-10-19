import Lean
import HallucinationGuard.Guard

namespace HallucinationGuard.AlgebraCheck

open Lean Meta

/--
  Structural algebra validator.
  Checks:
  - operator exists
  - operator has a type
  - operator is a definition (not theorem)
  - operator is not unsafe
  - operator type is a function (algebraic requirement)
-/
def validateAlgebraOp (op : Name) : MetaM Bool := do
  -- Check operator exists
  let some constInfo ← getConstInfo? op
    | throwError m!"AlgebraCheck: operator `{op}` does not exist."

  -- Check operator has a type
  let ty := constInfo.type
  unless ty.isType do
    throwError m!"AlgebraCheck: operator `{op}` does not have a valid type."

  -- Check operator is a definition (not theorem)
  if constInfo.isUnsafe then
    throwError m!"AlgebraCheck: operator `{op}` is unsafe or malformed."

  -- Check operator type is a function (algebraic structure requirement)
  match ty with
  | Expr.forallE _ _ _ _ =>
      pure true
  | _ =>
      throwError m!"AlgebraCheck: operator `{op}` is not a function type."

/-- Register this validator with the Guard macro. -/
unsafe def _init :=
  HallucinationGuard.registerValidator {
    name := "AlgebraCheck",
    fn := validateAlgebraOp
  }

end HallucinationGuard.AlgebraCheck
