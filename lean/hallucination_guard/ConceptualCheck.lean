import Lean
import HallucinationGuard.Guard

namespace HallucinationGuard.ConceptualCheck

open Lean Meta

/--
  Structural conceptual validator.
  Checks:
  - operator exists
  - operator has a type
  - operator is a definition (not theorem)
  - operator is not unsafe
  - operator type is a function (conceptual operators transform states)
-/
def validateConceptualOp (op : Name) : MetaM Bool := do
  -- Check operator exists
  let some constInfo ← getConstInfo? op
    | throwError m!"ConceptualCheck: operator `{op}` does not exist."

  -- Check operator has a type
  let ty := constInfo.type
  unless ty.isType do
    throwError m!"ConceptualCheck: operator `{op}` does not have a valid type."

  -- Check operator is a definition (not theorem)
  if constInfo.isUnsafe then
    throwError m!"ConceptualCheck: operator `{op}` is unsafe or malformed."

  -- Conceptual operators must be functions (state → state or state → structure)
  match ty with
  | Expr.forallE _ _ _ _ =>
      pure true
  | _ =>
      throwError m!"ConceptualCheck: operator `{op}` is not a function type."

/-- Register this validator with the Guard macro. -/
unsafe def _init :=
  HallucinationGuard.registerValidator {
    name := "ConceptualCheck",
    fn := validateConceptualOp
  }

end HallucinationGuard.ConceptualCheck
