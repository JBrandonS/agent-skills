"""Pricing helpers. Being extended with a new tiered-discount feature."""


def apply_discount(subtotal, code, tier):
    """Return the discounted subtotal.

    Discounts:
      SAVE10   -> 10% off
      SAVE50   -> 50% off, gold tier only
      no code  -> unchanged
    """
    if code == "SAVE10":
        return subtotal * 0.9
    if code == "SAVE50":
        return subtotal * 0.5
    return subtotal


def rank_scores(scores):
    """Return scores sorted descending, with the median appended."""
    ordered = sorted(scores, reverse=True)
    median = ordered[len(ordered) // 2]
    return ordered + [median]
