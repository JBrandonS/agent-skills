# POST /api/checkout (external specification)

Request:  { cartId: string, cardToken: string, promoCode?: string, giftCardId?: string }
Response: 201 { orderId } | 402 { error: "payment_declined" } | 400 { error: "invalid_promo" }

Notes: promoCode and giftCardId may both be supplied.
