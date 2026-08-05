# Checkout — Objectives

Why this exists: customers abandon carts because checkout is slow and because failed
payments silently lose the cart.

1. A signed-in customer can complete a purchase in under 60 seconds.
2. A failed payment must NEVER create an order, and must leave the cart intact so the
   customer can retry without re-adding items.
3. Gift cards may be combined with exactly one promo code.
4. The customer receives exactly one confirmation email per completed order.
5. Checkout works for customers in the EU, with prices shown inclusive of VAT.
