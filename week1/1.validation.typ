#import "../templates/test.typ": *

#show: test-template.with(
  week: 1,
  title: "Specifications That Calculate",
  variant: "validation",
  references: "Pearls 1-2",
)

// Total: 130 pts
// Part A: 20 | Part B: 20 | Part C: 15 | Part D: 35 | Part E: 25 | Part F: 15

== Part A: Multiple Choice [20 points]

#question(5)[
  A list `xs` has length `n`. Which fact justifies looking only at candidates
  `0..n` when computing `minfree xs`?
  #enum(numbering: "a)", [Every element of `xs` is at most `n`.], [There are `n + 1` candidates and only `n` list positions.], [Sorting `xs` takes linear time.], [`xs` cannot contain duplicates.])
  Answer: #underscore(30pt)
  #solution[#mark([*b)*]) - The range bound is a pigeonhole argument over the `n + 1` candidates `0..n`; it does not require all input values to be at most `n`.]
]

#question(5)[
  Why is the direct specification `minfree xs = first n not in xs` quadratic in
  the worst case?
  #enum(numbering: "a)", [It uses recursion.], [Each membership test may scan the list, and many candidates may be tested.], [Natural numbers are infinite.], [The answer is always larger than every input value.])
  Answer: #underscore(30pt)
  #solution[#mark([*b)*]) - A candidate-by-candidate search repeats list membership work.]
]

#question(5)[
  In the divide-and-conquer `minfrom` algorithm, what does the test
  `length us = b - a` mean when inputs are distinct?
  #enum(numbering: "a)", [The lower interval `[a,b)` is full.], [The upper interval is empty.], [`b` is the answer.], [`us` is sorted.])
  Answer: #underscore(30pt)
  #solution[#mark([*a)*]) - With distinct values all lying in `[a,b)`, having exactly `b-a` values means every value in that interval is present.]
]

#question(5)[
  Why does the maximum surpasser count calculation generalize from a number to
  a sorted table?
  #enum(numbering: "a)", [Because sorting is always faster than counting.], [Because `msc xs` alone forgets values needed to account for cross-surpassers.], [Because tables avoid all comparisons.], [Because surpasser counts are undefined for unsorted lists.])
  Answer: #underscore(30pt)
  #solution[#mark([*b)*]) - The join must know which left values are beaten by right values.]
]

== Part B: Formal Definitions [20 points]

#question(20)[
  Define `minfree`, `minfrom`, surpasser, surpasser count, and sorted surpasser
  table. Use plain language, but be precise about list order.

  #solution(height: 12em)[#mark([
    `minfree xs` is the least natural number absent from `xs`. `minfrom a xs` is
    the least natural number at least `a` absent from `xs`, under the assumption
    that all relevant input values are at least `a`. A surpasser of a value `x`
    at a position is a later value `y` with `x < y`. The surpasser count is the
    number of such later larger values. A sorted surpasser table stores one pair
    `(x,c)` per occurrence, where `c` is that occurrence's surpasser count, and
    the table is sorted by the first component.
  ])]
]

== Part C: Basic Skills [15 points]

#question(7)[
  Compute `minfree [4, 0, 2, 1]` by drawing the checklist indexed by `0..4`.

  #solution(height: 6em)[#mark([
    Seen values in `0..4`: `0`, `1`, `2`, and `4`. The checklist is
    `[true, true, true, false, true]`. The first false index is `3`, so
    `minfree [4,0,2,1] = 3`.
  ])]
]

#question(8)[
  For the list `[3, 1, 4, 2]`, write the surpasser count attached to each
  position and give `msc`.

  #solution(height: 7em)[#mark([
    For `3`, the later larger values are `[4]`, count `1`. For `1`, they are
    `[4,2]`, count `2`. For `4`, none, count `0`. For `2`, none, count `0`.
    Counts are `[1,2,0,0]`, so `msc = 2`.
  ])]
]

== Part D: Design [35 points]

#question(17)[
  Design the array-checklist algorithm for `minfree`. State the input length,
  the checklist size, how the checklist is filled, and how the answer is read.
  Then give its asymptotic time and space cost.

  #solution(height: 16em)[#mark([
    Let `n = length xs`. Allocate `n+1` Boolean slots indexed `0..n`, initially
    false. Scan `xs`; for each value `x` with `0 <= x <= n`, set slot `x` to
    true. Finally scan the checklist from index `0` upward and return the first
    false index. The range bound guarantees such an index exists. The algorithm
    takes `O(n)` time to fill plus `O(n)` time to search, so `O(n)` total time,
    and uses `O(n)` space.
  ])]
]

#question(18)[
  Explain how to join two sorted surpasser tables for `xs` and `ys`. Your answer
  must say what is added to each left count and why right counts do not change.

  #solution(height: 14em)[#mark([
    For each left pair `(x,c)`, add the number of values in `ys` greater than
    `x`, because those values occur to the right of every element of `xs` and
    therefore are new surpassers. Pairs from the right table keep their counts:
    elements of `xs` are to their left, so they cannot be later surpassers of
    right-side elements. Keeping both tables sorted by value lets a merge track
    the suffix of right values greater than the current left value and produce a
    sorted combined table in linear time.
  ])]
]

== Part E: Theory [25 points]

#question(25)[
  Prove the partition decision for `minfrom`: assume all values are distinct and
  at least `a`. Let `us` be the values below `b` and `vs` the rest. If
  `length us = b - a`, the answer is in `vs`; otherwise the answer is in `us`.

  #solution(height: 13em)[#mark([
    All elements of `us` lie in `[a,b)`. This interval contains exactly `b-a`
    natural numbers. If `length us = b-a`, distinctness implies that `us`
    contains every number in `[a,b)`, so no missing value below `b` can be the
    answer; the least missing value at or above `a` must be at least `b`, so we
    continue with `vs`. If `length us < b-a`, at least one value in `[a,b)` is
    absent. Since this missing value is below every value in `vs`, the least
    missing value at or above `a` is determined entirely by `us`.
  ])]
]

== Part F: Additional Topics [15 points]

#question(15)[
  The sorted surpasser table for a list of distinct values contains enough
  information to recover a sorting order. Explain why this suggests an
  `Omega(n log n)` lower bound for computing the full table by comparisons.

  #solution(height: 10em)[#mark([
    If a comparison-based algorithm could compute the full sorted surpasser
    table faster than comparison sorting, then for distinct inputs we could use
    that table to recover ordering information and sort faster than the known
    comparison lower bound. Since comparison sorting needs `Omega(n log n)`
    comparisons in the worst case, computing a representation with enough
    information to determine sorted order also cannot beat that bound in the
    comparison model.
  ])]
]

#validation-footer()
