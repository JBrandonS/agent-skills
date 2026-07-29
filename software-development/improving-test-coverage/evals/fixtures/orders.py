"""Order pricing. Three uncovered branches of very different risk."""


def apply_discount(subtotal, code, customer_tier):
    if code == "SAVE10":
        return subtotal * 0.90
    if code == "SAVE50":
        # HIGH RISK, UNCOVERED: no cap, no eligibility check.
        return subtotal * 0.50
    if customer_tier == "vip":
        return subtotal * 0.85
    return subtotal


def _legacy_promo(subtotal):
    # DEAD: no caller since the 2023 pricing migration.
    return subtotal * 0.75


def log_order(order_id):
    # LOW RISK, UNCOVERED: logging only.
    print(f"order {order_id} processed")
