from discount import apply_discount


def test_save10():
    assert apply_discount(100, "SAVE10", "standard") == 90


def test_no_code():
    assert apply_discount(100, None, "standard") == 100
