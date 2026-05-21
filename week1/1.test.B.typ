#import "../templates/test.typ": *

#show: test-template.with(
  week: 1,
  title: "Specifications That Calculate",
  variant: "B",
)

// Total: 130 pts
// Part A: 20 | Part B: 20 | Part C: 15 | Part D: 35 | Part E: 25 | Part F: 15

== Part A: Multiple Choice [20 points]

#question(5)[
  In `minfrom a xs`, what does the parameter `a` represent?
  #enum(numbering: "a)", [The current lower bound for possible answers.], [The largest value in `xs`.], [The length of the original list.], [The midpoint of every recursive call.])
  Answer: #underscore(30pt)
  #solution[#mark([*a)*]) - `minfrom` searches for the first absent value at or above `a`.]
]

#question(5)[
  Which input property is needed for the efficient partition fullness test in
  the divide-and-conquer `minfree` algorithm?
  #enum(numbering: "a)", [The list is sorted.], [The list has distinct natural numbers.], [Every value is below the midpoint.], [The list length is even.])
  Answer: #underscore(30pt)
  #solution[#mark([*b)*]) - Counting values in an interval proves fullness only when duplicates cannot inflate the count.]
]

#question(5)[
  For a value `x` in the left half of a concatenation `xs ++ ys`, which values
  from `ys` become new surpassers?
  #enum(numbering: "a)", [All values in `ys`.], [Values in `ys` less than `x`.], [Values in `ys` greater than `x`.], [Only the maximum value of `ys`.])
  Answer: #underscore(30pt)
  #solution[#mark([*c)*]) - A surpasser must be later and larger.]
]

#question(5)[
  Why is a sorted surpasser table useful during join?
  #enum(numbering: "a)", [It makes right-side counts irrelevant.], [It lets the number of right values greater than a left value be tracked during a merge.], [It removes the need to compare values.], [It stores only the maximum count.])
  Answer: #underscore(30pt)
  #solution[#mark([*b)*]) - Sorted order turns repeated counting into a linear merge calculation.]
]

== Part B: Formal Definitions [20 points]

#question(20)[
  Define surpasser, surpasser count, maximum surpasser count, and the join
  contribution from a right half.

  #solution(height: 12em)[#mark([
    In a list, a later value `y` is a surpasser of an earlier occurrence `x` if
    `x < y`. The surpasser count of that occurrence is the number of later values
    satisfying this inequality. The maximum surpasser count is the largest of
    these occurrence counts. When joining a left half with a right half, the
    contribution added to a left occurrence `x` is the number of values in the
    right half greater than `x`.
  ])]
]

== Part C: Basic Skills [15 points]

#question(7)[
  Compute `minfree [0, 2, 5, 1]`.

  #solution(height: 5em)[#mark([
    The length is `4`; candidates are `0..4`. Values `0`, `1`, and `2` are
    present. Value `3` is absent, so `minfree = 3`.
  ])]
]

#question(8)[
  For `[4, 1, 3, 2, 5]`, compute the surpasser counts and `msc`.

  #solution(height: 7em)[#mark([
    `4` has later larger value `5`, count `1`. `1` has `3,2,5`, count `3`.
    `3` has `5`, count `1`. `2` has `5`, count `1`. `5` has `0`. Counts are
    `[1,3,1,1,0]`, so `msc = 3`.
  ])]
]

== Part D: Design [35 points]

#question(17)[
  Design a recursive `minfrom` step. Given lower bound `a`, list `xs`, midpoint
  `b`, and partition `(us, vs)` where `us` contains values below `b`, state the
  recursive choice and justify it.

  #solution(height: 16em)[#mark([
    Compute `m = length us`. If `m = b-a`, then the interval `[a,b)` is full
    because the input values are distinct and all `us` values lie in that
    interval; recurse with `minfrom b vs`. If `m < b-a`, some value in `[a,b)`
    is absent, so the least absent value is below `b`; recurse with
    `minfrom a us`. Choosing `b` near the middle keeps the surviving subproblem
    at most about half the size after the partition work.
  ])]
]

#question(18)[
  The direct `msc` specification uses all nonempty tails of the list. Explain why
  this is clear but slow, then describe the representation change that makes
  divide and conquer possible.

  #solution(height: 14em)[#mark([
    The tail specification is clear because it directly counts, for each
    position, later values larger than the current value. It is slow because the
    counts repeatedly scan suffixes, giving many pairwise comparisons. The
    representation change is to compute the full surpasser table rather than
    only the final maximum, and to maintain that table sorted by value. The table
    keeps enough information to add cross-surpassers during a linear join.
  ])]
]

== Part E: Proofs [25 points]

#question(25)[
  Prove the join invariant for surpasser tables: when joining tables for `xs`
  and `ys`, each left count must be increased by the number of right values
  greater than the left value, while right counts are unchanged.

  _Hint: Use the order of `xs ++ ys`._

  #solution(height: 12em)[*Proof:* #mark([
    In the concatenated list `xs ++ ys`, every element of `ys` occurs to the
    right of every element of `xs`. Therefore a left occurrence `x` keeps all
    surpassers already counted inside `xs`, and gains exactly those elements
    `y` in `ys` with `x < y`. No other right values qualify. A right occurrence
    has no new later elements from `xs`, because all of `xs` lies to its left.
    Thus right counts are unchanged, and left counts receive exactly the stated
    cross contribution.
  ])]
]

== Part F: Additional Topics [15 points]

#question(15)[
  Give a short comparison of the two Week 1 design moves: bounding the search
  space for `minfree` and generalizing the output for `msc`.

  #solution(height: 10em)[#mark([
    Bounding the search space removes irrelevant information: for `minfree`, no
    value above `length xs` is needed to identify the first missing candidate.
    Generalizing the output adds necessary information: for `msc`, the scalar
    maximum forgets too much, so the table keeps values and counts for joining.
    Both moves preserve the original specification, but one compresses the
    input problem while the other enriches the intermediate result.
  ])]
]

#test-footer()
