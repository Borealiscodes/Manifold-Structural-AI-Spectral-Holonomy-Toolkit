-- lean/hallucination_guard/Guard.lean

import Lean

namespace HallucinationGuard

open Lean Elab Command Meta

/--
  Core registry for validation functions.
  Each domain-specific Guard module will register its validator here.
-/
structure Validator where
  name : String
  fn   : Name → MetaM Bool

def validatorRegistry : IO.Ref (List Validator) := unsafeIO (IO.mkRef [])

/-- Register a validator from any Guard module. -/
def registerValidator (v : Validator) : IO Unit := do
  validatorRegistry.modify fun vs => v :: vs

/-- Run all registered validators on an operator name. -/
def runValidators (op : Name) : MetaM Unit := do
  let validators ← validatorRegistry.get
  for v in validators do
    let ok ← v.fn op
    if !ok then
      throwError m!"HallucinationGuard: validation failed in `{v.name}` for operator `{op}`."

/-- Syntax: #guard operatorName -/
syntax "#guard" ident : command

@[command_elab «guard»] def guardImpl : CommandElab := fun stx => do
  let opName := stx[1].getId
  logInfo m!"HallucinationGuard: validating `{opName}`..."
  runValidators opName
  logInfo m!"HallucinationGuard: `{opName}` passed all validation checks."

end HallucinationGuard
