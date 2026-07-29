// Verbose null handling. Note: quantity and label legitimately accept 0 and "".
export function resolveSettings(user) {
  let retries = user.retries;
  if (retries === null || retries === undefined) {
    retries = 3;
  }

  let quantity = user.quantity;
  if (quantity === null || quantity === undefined) {
    quantity = 1;
  }

  let label = user.label;
  if (label === null || label === undefined) {
    label = 'untitled';
  }

  const results = [];
  for (const item of user.items) {
    if (item.active) {
      results.push(item.name);
    }
  }

  return { retries, quantity, label, results };
}
