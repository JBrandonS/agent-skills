# Choosing the Next Test

The TDD cycle governs *how* to write a test. This governs *which* one. Techniques adapted from
Myers, *The Art of Software Testing*, to the unit level.

A good test case has a **high probability of detecting an undiscovered error**. Two properties
make a case good:

1. It reduces the number of other cases you need, by more than one.
2. It tells you something about a whole class of inputs, not just the values it uses.

Exhaustive input testing is impossible for anything non-trivial, so the entire game is picking
the right small subset. Apply these in order.

---

## 1. Boundary Values — Highest Payoff

Cases on the edges find far more defects than cases in the middle. If you only have time for one
technique, use this one.

**Guidelines**

1. **A range** → test both ends, and just past each end.
   Valid `1..999` → `1`, `999`, `0`, `1000`.
2. **A count of values** → test min, max, one below, one above.
   Accepts 1–10 items → `0`, `1`, `10`, `11`.
3. **Apply rule 1 to every output.** If a function's documented result floor is `0.00` and ceiling
   is `1165.25`, construct inputs producing exactly each — then try to construct one producing a
   negative result or one above the ceiling.
4. **Apply rule 2 to every output.** If it returns at most 4 results, force `0`, `1`, and `4` — and
   try to force `5`.
5. **Ordered sets** — lists, files, tables — get specific attention on the **first and last
   element**.
6. Use ingenuity for boundaries the spec never named.

**Why output boundaries need separate attention:** the edges of the input domain and the edges of
the output range are often entirely different circumstances. Consider a sine function — its input
extremes and its output extremes have nothing to do with each other.

**Why this beats partitioning alone.** Define a valid triangle as three integers where any two sum
to more than the third. Partitioning gives `3,4,5` (valid) and `1,2,4` (invalid). Both pass
against code written `a+b >= c` instead of `a+b > c`. Only the boundary case `1,2,3` exposes it.

**Standing boundary checklist:** empty and single-element collections; exactly at the limit and
one over; first and last element; string length limits; `0`, `-1`, and max int; timestamps at
midnight, month end, DST transition, leap day; the free-tier threshold and one above it;
exactly-full and one-past-full buffers.

---

## 2. Equivalence Classes — Cover, Don't Repeat

Partition each input condition into classes where testing one member is assumed equivalent to
testing any other. Then cover every class with the fewest cases.

**Identifying classes** — for each input condition:

| Condition form | Valid classes | Invalid classes |
|---|---|---|
| Range (`1 to 999`) | one: within | two: below, above |
| Count (`1 to 6 owners`) | one: within | two: none, too many |
| Set, members handled differently (`BUS, TRUCK, TAXI`) | one per member | one: not a member |
| Must-be (`first char is a letter`) | one: is | one: is not |

Suspect the code doesn't treat a class's members identically? Split the class.

**Turning classes into cases** — the asymmetry between the two rules is the whole point:

1. **Valid classes: pack them.** Each new test covers as many uncovered valid classes as possible.
   This is what keeps the case count down.
2. **Invalid classes: one per test, alone.** Never combine two invalid inputs in one case.

**Why rule 2:** one rejection masks another. Pass both an unknown book type and a quantity of `0`
to `order("XYZ", 0)` and the function rejects the type and returns before ever checking the
quantity. The quantity validation is now untested while looking covered. This is one of the most
common ways a suite lies about what it verifies.

---

## 3. Error Guessing — What Did They Forget?

No procedure exists; it is experience made explicit. Enumerate probable defects and error-prone
situations, then write a case for each.

The reliable seed: **`0`, empty, and one** — wherever a count, list, or amount appears, on input
*and* on forced output.

Then ask what the implementer plausibly assumed — things the spec omitted because the writer
thought them obvious.

**Worked example.** Testing a sort function, the situations to explore are:

- The input list is empty
- The input list has exactly one entry
- All entries have the same value
- The input list is already sorted
- The input list is sorted in reverse

**Worked example.** Testing a binary search, the situations are:

- Exactly one entry in the table
- Table size is a power of two (16)
- Table size is one less and one more than a power of two (15, 17)
- Target is the first element, the last element, and absent

**Standing list:**

- Empty / single / all-identical / already-in-target-state inputs
- Odd vs even element counts — anything computing a median or splitting a list behaves
  differently on each
- Whitespace-only strings; leading and trailing whitespace; 4-byte emoji; RTL text
- Duplicate keys, names, or IDs
- Negative numbers where only positives were imagined; `0` quantities; `-0`
- Leading zeros; numeric strings; integers past 2^53
- Null vs undefined vs absent vs empty-string — treated as four distinct cases
- Partial or malformed trailing input
- Called twice in a row; called concurrently; called with its own output
- The very first call, before any state exists
- Timezone difference between producer and consumer

Every situation you hit here that a unit test can cover *should* become a unit test — this is
also the list to re-read when a bug escapes to production, because it is usually on it.

---

## 4. Coverage as Gap-Filler, Not Target

After the three techniques, check which branches the tests actually took. Where a decision that
matters has never been taken in both directions, add a case — unless the combination is genuinely
unreachable.

This is a gap-check, not a goal. Chasing a coverage percentage produces tests written to touch
lines rather than to catch defects, which is exactly the failure mode TDD exists to prevent. See
the `improving-test-coverage` skill for measuring and targeting coverage deliberately.

---

## Recording the Case

Every case records **input and expected output, both written before execution**. A case whose
expected value was read off the first run is not a test case — it is a snapshot of current
behavior, and it will "pass" against whatever the code happens to do, including the bug.

Then **inspect the whole result, not just the assertion you wrote.** Defects are routinely missed
when their symptoms were plainly visible in output the tester had already produced. Bugs found in
a later round were usually visible in an earlier round's output and simply not looked at. In
practice: read the console output, the warnings, the adjacent state, and the log lines — every
run, not only when something goes red.
