# Test-Case Design for E2E Journeys

Techniques from Myers, *The Art of Software Testing*, 3rd ed., ch. 4, applied at the
end-to-end level. Apply them in the order below; each contributes cases the others miss, and
none alone yields a thorough set.

A good test case is one with a **high probability of detecting an undiscovered error**. Two
properties make a case good:

1. It reduces the number of *other* cases you must write, by more than one.
2. It tells you something about a whole class of inputs, not just the values it uses.

---

## 1. Cause-Effect: Combinations First

Use when the flow's behavior depends on combinations of conditions. Enumerating combinations
first prevents writing twelve near-identical tests that all exercise the same branch.

**Procedure**

1. List the *causes* — independent input conditions.
   Checkout: `logged in`, `cart non-empty`, `coupon valid`, `address on file`, `card valid`.
2. List the *effects* — distinct observable outcomes.
   `order created`, `payment charged`, `discount applied`, `error shown`, `redirect to login`.
3. Map which cause combinations produce which effects, including the constraints that make
   some combinations impossible (cannot have a valid coupon on an empty cart).
4. Each reachable combination-to-effect row is one test case.

The mapping is where the bugs surface: rows nobody thought about, and rows where the intended
effect is ambiguous, are defects found before any code runs.

Boundary cases from step 2 below can usually be folded into these combination tests rather than
written separately.

---

## 2. Boundary Value Analysis: Highest Payoff

Cases on the edges of a class find more defects than cases in the middle. This is the technique
to use if you only have time for one.

Boundary analysis differs from equivalence partitioning in two ways: you test *each edge*
rather than any representative, and you analyze **outputs as well as inputs**.

**Guidelines**

1. **Range of values** → test the two ends and just past each end.
   Valid range 1–999: test `1`, `999`, `0`, `1000`.
2. **Number of values** → test min, max, one below, one above.
   Upload accepts 1–10 files: test `0`, `1`, `10`, `11`.
3. **Apply guideline 1 to every output.** If a report shows a computed total with a documented
   floor and ceiling, construct inputs that produce exactly the floor and exactly the ceiling —
   then try to construct one that produces a value outside the range.
4. **Apply guideline 2 to every output.** If a search shows at most 20 results, construct cases
   producing `0`, `1`, and `20` results — and try to construct one producing `21`.
5. **Ordered sets** — lists, files, tables, paginated results — get attention on the **first and
   last elements** specifically.
6. Use ingenuity for boundaries the spec never named.

Output boundaries matter independently because the edges of the input domain and the edges of the
output range are frequently not the same circumstances.

**Why it beats partitioning alone:** with a valid triangle defined as any two sides summing to more
than the third, partitioning gives you `3,4,5` (valid) and `1,2,4` (invalid). Both pass against
code written as `a+b >= c` instead of `a+b > c`. Only the boundary case `1,2,3` exposes it.

**E2E boundary checklist:** empty and one-item collections; exactly one page and one over; the
first and last item on a page; string length limits; zero, negative, and maximum quantities;
timestamps at midnight, month end, DST transitions, and leap day; the free-tier limit and one
above it; session expiry at the exact boundary; upload at exactly the max size and one byte over.

---

## 3. Equivalence Partitioning: Cover the Classes

Partition each input condition into classes such that testing one member is assumed equivalent to
testing any other. Then cover every class with the fewest cases.

**Identify classes** — for each input condition, list valid and invalid classes:

| Condition form | Valid classes | Invalid classes |
|---|---|---|
| Range ("1 to 999") | one: within range | two: below, above |
| Count ("1 to 6 owners") | one: within count | two: none, too many |
| Set of values, each handled differently ("BUS, TRUCK, TAXI") | one per member | one: not a member |
| Must-be ("first character is a letter") | one: is a letter | one: is not |

Split a class further whenever you suspect the system does not treat its members identically.

**Turn classes into cases** — the two rules differ, and the asymmetry is the point:

1. **Valid classes: pack them.** Write cases covering as many uncovered valid classes at once as
   possible. This minimizes case count.
2. **Invalid classes: one per case, alone.** Never combine two invalid inputs in one test.

The reason for rule 2: one rejection masks another. Submit a form with both an unknown product
type and a quantity of zero, and the system rejects the product type and never reaches the
quantity check. The quantity validation is now untested while appearing covered.

---

## 4. Error Guessing: What Did They Forget?

No procedure exists — it is intuition and experience made explicit. Enumerate probable defects
and error-prone situations, then write a case for each.

The reliable seed: **`0`, empty, and one.** Wherever a count, list, or amount appears, the
values none/one/zero are error-prone, on input *and* on forced output.

Then ask what assumptions the implementer plausibly made — things the spec omitted because the
writer thought them obvious.

**Standing list for E2E:**

- Empty list; single-item list; all items identical; already in the target state
- Submit twice rapidly (double-click); two tabs submitting concurrently
- Browser back button mid-flow; refresh mid-flow; deep link into step 3 of a wizard
- Session expires between page load and submit
- Whitespace-only input; leading/trailing whitespace; a 4-byte emoji; RTL text
- Duplicate names or identifiers; two users with the same display name
- Odd vs even element counts (anything computing a median or splitting a list behaves differently)
- Negative numbers where only positives were imagined; a quantity of `0`
- Blank accepted as an answer where it should not be
- A record of the wrong type appearing in a set of another type
- Extra, partial, or malformed trailing input on a command or query
- Leading zeros; numbers passed as strings; very large integers
- The very first use, with no data yet, and no preferences saved
- Timezone difference between client and server
- The third-party dependency returning slowly, or 500, or malformed data

Anything found here that a unit test could have caught should also become a unit test.

---

## 5. Coverage Check

After the four techniques, examine which paths the journeys actually exercised. Where a decision
that matters to users has never been taken in either direction by any E2E case, add a case — unless
the combination is genuinely unreachable.

This step is a gap-filler, not a target. Chasing an E2E coverage percentage produces slow,
redundant journeys; coverage is for the unit suite (`improving-test-coverage`).

---

## Recording the Case

Every case records **input and expected output**, both written before execution. A case without a
predefined expected result is not a test case — it is an observation, and it will "pass" against
whatever the system happens to do.

Then: **inspect the whole result, not just the assertion.** Experiments repeatedly show testers
missing defects whose symptoms were plainly visible in output they had already produced. Defects
found in a later test round were usually visible in an earlier round's output and were not looked
at. In practice this means checking the console, the logs, the network tab, the adjacent
database rows, and the emails — every time, not only when the assertion fails.
