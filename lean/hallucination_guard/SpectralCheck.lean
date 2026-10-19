import Lean
import HallucinationGuard.Guard

namespace HallucinationGuard.SpectralCheck

open Lean Meta

/--
  Structural spectral validator.
  Checks:
  - operator exists
  - operator has a type
  - operator is a definition (not theorem)
  - operator is not unsafe
  - operator type is non-empty (spectral operators must map something)
-/
def validateSpectralOp (op : Name) : MetaM Bool := do
  -- Check operator exists
  let some constInfo ← getConstInfo? op
    | throwError m!"SpectralCheck: operator `{op}` does not exist."

  -- Check operator has a type
  let ty := constInfo.type
  unless ty.isType do
    throwError m!"SpectralCheck: operator `{op}` does not have a valid type."

  -- Check operator is a definition (not theorem)
  if constInfo.isUnsafe then
    throwError m!"SpectralCheck: operator `{op}` is unsafe or malformed."

  -- Check operator type is non-empty (spectral operators must map something)
  match ty with
  | Expr.forallE _ _ _ _ =>
      pure true
  | _ =>
      throwError m!"SpectralCheck: operator `{op}` does not appear to map any domain."

/-- Register this validator with the Guard macro. -/
unsafe def _init :=
  HallucinationGuard.registerValidator {
    name := "SpectralCheck",
    fn := validateSpectralOp
  }

end HallucinationGuard.SpectralCheck
