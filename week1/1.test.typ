#import "../templates/test.typ": *

#show: test-template.with(
  week: 1,
  title: "Specifications That Calculate",
)

// Total: 130 pts
// Part A: 20 | Part B: 20 | Part C: 15 | Part D: 35 | Part E: 25 | Part F: 15

== Part A: Multiple Choice [20 points]

#question(5)[
  What is the main purpose of writing a direct executable specification before
  optimizing?
  #enum(numbering: "a)", [It proves the final program is linear.], [It gives a precise meaning that later transformations must preserve.], [It avoids the need for tests.], [It guarantees the input has no duplicates.])
  Answer: #underscore(30pt)
  #solution[#mark([*b)*]) - The specification is the semantic contract for the calculation.]
]

#question(5)[
  Which statement about the checklist algorithm for `minfree` is correct?
  #enum(numbering: "a)", [It requires sorting the input first.], [It ignores every input value greater than `length xs`.], [It fails when the input contains duplicates.], [It uses constant space.])
  Answer: #underscore(30pt)
  #solution[#mark([*b)*]) - Values above `n` cannot affect the first absent value in `0..n`.]
]

#question(5)[
  In the divide-and-conquer `minfrom` method, why choose a split near the middle
  of the active interval?
  #enum(numbering: "a)", [To make recursive subproblems small enough for a linear recurrence.], [To make the list sorted.], [To avoid checking `length us`.], [To remove the distinctness assumption.])
  Answer: #underscore(30pt)
  #solution[#mark([*a)*]) - A balanced split gives `T(n) = T(n/2) + O(n)` behavior.]
]

#question(5)[
  What information is missing from `msc xs` when trying to join it with a right
  half `ys`?
  #enum(numbering: "a)", [The length of `ys` only.], [The actual left values that right-side elements may surpass.], [Whether `ys` is nonempty.], [The final maximum after sorting `ys`.])
  Answer: #underscore(30pt)
  #solution[#mark([*b)*]) - Cross-surpassers depend on values, not only on the old maximum count.]
]

== Part B: Formal Definitions [20 points]

#question(20)[
  Define a checklist for `minfree` and a sorted surpasser table for `msc`.
  Explain what invariant each representation maintains.

  #solution(height: 12em)[#mark([
    A checklist for input length `n` is a Boolean array indexed `0..n`; slot `i`
    is true exactly when value `i` occurs in the input. Its invariant is
    presence information over the bounded candidate range. A sorted surpasser
    table contains one pair `(x,c)` per occurrence, where `c` is the number of
    later values greater than that occurrence of `x`; the table is sorted by
    `x`. Its invariant is that counts are correct for the represented sublist
    and ordering by value is available for linear joins.
  ])]
]

== Part C: Basic Skills [15 points]

#question(7)[
  Compute `minfree [1, 4, 0, 2]`.

  #solution(height: 5em)[#mark([
    The length is `4`; candidates are `0..4`. Values `0`, `1`, `2`, and `4` are
    present, while `3` is absent. Therefore `minfree = 3`.
  ])]
]

#question(8)[
  For `[1, 3, 2, 5]`, compute the surpasser counts and `msc`.

  #solution(height: 7em)[#mark([
    `1` has later larger values `3,2,5`, count `3`. `3` has `5`, count `1`.
    `2` has `5`, count `1`. `5` has none, count `0`. Counts are `[3,1,1,0]`,
    so `msc = 3`.
  ])]
]

== Part D: Design [35 points]

#question(17)[
  Give pseudocode for a linear-time checklist implementation of `minfree`.
  State why the returned value is correct.

  #solution(height: 16em)[#mark([
    Pseudocode: let `n = length xs`; create `seen[0..n] = false`; for each `x`
    in `xs`, if `0 <= x <= n`, set `seen[x] = true`; return the least index
    `i` with `seen[i] = false`. The range theorem says at least one value in
    `0..n` is absent, so the scan finds an index. The invariant of the fill scan
    is that after processing some prefix, `seen[i]` records whether `i` appeared
    in that prefix. At the end, the first false slot is exactly the least
    natural number absent from `xs`.
  ])]
]

#question(18)[
  A divide-and-conquer algorithm for `msc` computes sorted tables for two halves.
  Describe the join operation and explain why the join is linear when both
  tables are sorted.

  #solution(height: 14em)[#mark([
    The join merges the two sorted tables by value. Right pairs are copied with
    unchanged counts. For a left pair `(x,c)`, the join adds the number of right
    values greater than `x`, because all right values occur later in the original
    concatenated list. Sorting makes this number trackable as a suffix length of
    the right table while merging, so each table element is advanced a constant
    number of times. Hence the join is linear in the combined table sizes.
  ])]
]

== Part E: Proofs [25 points]

#question(25)[
  Prove that if `xs` has length `n`, then `minfree xs <= n`.

  _Hint: Compare the number of list positions with the number of candidates in
  `0..n`._

  #solution(height: 12em)[*Proof:* #mark([
    The range `0..n` contains `n+1` natural numbers. The list has only `n`
    positions, so it cannot contain all `n+1` candidates, even in the best case
    where all present candidates are distinct. Therefore some candidate `k` with
    `0 <= k <= n` is absent from `xs`. Since `minfree xs` is the least absent
    natural number, it is at most `k`, and therefore at most `n`.
  ])]
]

== Part F: Additional Topics [15 points]

#question(15)[
  Explain the difference between the array-checklist solution and the
  divide-and-conquer solution for `minfree`. Include one advantage and one
  precondition or cost of each.

  #solution(height: 10em)[#mark([
    The checklist solution builds direct presence memory over `0..n`. It is
    simple, linear, and tolerates duplicates, but uses `O(n)` auxiliary array
    space. The divide-and-conquer solution partitions around a midpoint and uses
    counts to decide which half can contain the answer. It can avoid building a
    full mutable checklist and demonstrates calculational decomposition, but its
    efficient correctness argument relies on distinct input values for the
    fullness test.
  ])]
]

#test-footer()
