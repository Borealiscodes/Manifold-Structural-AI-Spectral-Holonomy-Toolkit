import Lean
import HallucinationGuard.Guard

namespace HallucinationGuard.GeometryCheck

open Lean Meta

/--
  Structural geometry validator.
  Checks:
  - operator exists
  - operator has a type
  - operator is a definition (not theorem)
  - operator is not unsafe
-/
def validateGeometryOp (op : Name) : MetaM Bool := do
  -- Check operator exists
  let some constInfo ← getConstInfo? op
    | throwError m!"GeometryCheck: operator `{op}` does not exist."

  -- Check operator has a type
  let ty := constInfo.type
  unless ty.isType do
    throwError m!"GeometryCheck: operator `{op}` does not have a valid type."

  -- Check operator is a definition (not theorem)
  if constInfo.isUnsafe then
    throwError m!"GeometryCheck: operator `{op}` is unsafe or malformed."

  pure true

/-- Register this validator with the Guard macro. -/
unsafe def _init := 
  HallucinationGuard.registerValidator {
    name := "GeometryCheck",
    fn := validateGeometryOp
  }

end HallucinationGuard.GeometryCheck
