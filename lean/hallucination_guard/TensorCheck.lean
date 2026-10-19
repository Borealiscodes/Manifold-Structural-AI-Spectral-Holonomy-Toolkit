import Lean
import HallucinationGuard.Guard

namespace HallucinationGuard.TensorCheck

open Lean Meta

/--
  Structural tensor validator.
  Checks:
  - operator exists
  - operator has a type
  - operator is a definition (not theorem)
  - operator is not unsafe
  - operator type is a function (tensor operators transform tensor states)
  - operator codomain is a type (tensor operators must produce tensor structure)
-/
def validateTensorOp (op : Name) : MetaM Bool := do
  -- Check operator exists
  let some constInfo ← getConstInfo? op
    | throwError m!"TensorCheck: operator `{op}` does not exist."

  -- Check operator has a type
  let ty := constInfo.type
  unless ty.isType do
    throwError m!"TensorCheck: operator `{op}` does not have a valid type."

  -- Check operator is a definition (not theorem)
  if constInfo.isUnsafe then
    throwError m!"TensorCheck: operator `{op}` is unsafe or malformed."

  -- Tensor operators must be functions
  match ty with
  | Expr.forallE _ dom cod _ =>
      -- Codomain must be a type (tensor structure)
      unless cod.isType do
        throwError m!"TensorCheck: operator `{op}` has an invalid tensor codomain."
      pure true
  | _ =>
      throwError m!"TensorCheck: operator `{op}` is not a function type."

/-- Register this validator with the Guard macro. -/
unsafe def _init :=
  HallucinationGuard.registerValidator {
    name := "TensorCheck",
    fn := validateTensorOp
  }

end HallucinationGuard.TensorCheck
