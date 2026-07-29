// Structurally identical, semantically different. Consolidating these is a TRAP:
// the two regimes are governed by separate regulations and will diverge.

// Consumer accounts: KYC rules, 18+ required by policy.
export function validateConsumerAge(age: number): boolean {
  return age >= 18 && age <= 120;
}

// Clinical trial enrollment: 18+ required by the study protocol, upper bound
// set by the protocol's exclusion criteria. Changes when the protocol changes.
export function validateTrialAge(age: number): boolean {
  return age >= 18 && age <= 120;
}
