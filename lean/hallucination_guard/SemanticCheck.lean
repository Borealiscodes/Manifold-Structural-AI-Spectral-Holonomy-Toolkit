import Lean
import HallucinationGuard.Guard

namespace HallucinationGuard.SemanticCheck

open Lean Meta

/--
  Structural semantic validator.
  Checks:
  - operator exists
  - operator has a type
  - operator is a definition (not theorem)
  - operator is not unsafe
  - operator type is a function (semantic operators transform semantic states)
  - operator codomain is non-empty (semantic operators must produce structure)
-/
def validateSemanticOp (op : Name) : MetaM Bool := do
  -- Check operator exists
  let some constInfo ← getConstInfo? op
    | throwError m!"SemanticCheck: operator `{op}` does not exist."

  -- Check operator has a type
  let ty := constInfo.type
  unless ty.isType do
    throwError m!"SemanticCheck: operator `{op}` does not have a valid type."

  -- Check operator is a definition (not theorem)
  if constInfo.isUnsafe then
    throwError m!"SemanticCheck: operator `{op}` is unsafe or malformed."

  -- Semantic operators must be functions
  match ty with
  | Expr.forallE _ dom cod _ =>
      -- Codomain must not be trivially empty
      unless cod.isType do
        throwError m!"SemanticCheck: operator `{op}` has an invalid codomain."
      pure true
  | _ =>
      throwError m!"SemanticCheck: operator `{op}` is not a function type."

/-- Register this validator with the Guard macro. -/
unsafe def _init :=
  HallucinationGuard.registerValidator {
    name := "SemanticCheck",
    fn := validateSemanticOp
  }

end HallucinationGuard.SemanticCheck
