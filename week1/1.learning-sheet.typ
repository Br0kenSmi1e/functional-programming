#import "../templates/learning-sheet.typ": *

#show: learning-sheet-template.with(
  week: 1,
  title: "Specifications That Calculate",
)

#task-box[
  *Task:* A service stores millions of active integer IDs. New requests need the
  smallest unused ID, while a monitoring dashboard needs to know which log
  entry has the most later entries with larger priority. Both questions have
  direct list specifications, and both direct specifications are too slow. Design
  a principled route from the specification to an efficient algorithm without
  losing the meaning of the original problem.
]

#v(5pt)

You might try to solve both tasks by reaching for sorting immediately. Sorting
does help in many list problems, but here it can hide the important question:
what information does the final answer actually need? For the smallest unused
ID, a full order of all IDs is more information than necessary. For later larger
priorities, a single maximum count is too little information to combine two
halves of the input.

What if the specification were not just a slow program, but a contract we can
calculate from? This week studies two pearls from Bird: one where an array-like
checklist or a numeric partition gives a linear-time `minfree`, and one where a
scalar answer is deliberately generalized into a sorted table so a divide-and-
conquer algorithm has enough memory to join subproblems.

#setup-prompt()

#v(5pt)

*Learning objectives.* By the end of this guide, you will:
#set enum(numbering: "(1)")
1. Define executable specifications for `minfree` and maximum surpasser count.
2. Explain why the obvious specifications are quadratic.
3. Prove the key range and partition facts behind the linear `minfree` algorithm.
4. Convert a scalar specification into an auxiliary table that supports divide and conquer.
5. Analyze the time complexity of the calculated algorithms.

*Resources:*
- Bird, *Pearls of Functional Algorithm Design*, Pearls 1-2.
- Repository notes: `textbook/01.md` and `textbook/02.md`.

#pagebreak()

= Part 1: A Specification Is A Promise

Before improving an algorithm, we need a sentence precise enough to improve.
For the ID problem, the input is a finite list `xs` of natural numbers. The
answer is the first natural number that is not in that list. For the priority
problem, the input is a list ordered by time. A later element surpasses an
earlier one when it is larger; the count attached to a position is the number of
larger values to its right. The specification says what to compute before it says
how to compute it.

#definition(numbering: none, title: [Executable specifications])[
  For a finite list `xs` of natural numbers, `minfree xs` is the least natural
  number not occurring in `xs`.

  A value `y` is a *surpasser* of an earlier value `x` when `y` appears to the
  right of `x` and `x < y`. The *surpasser count* of `x` at that position is the
  number of its surpassers. The maximum surpasser count, written `msc xs`, is
  the largest such count over all positions of `xs`.
]

#v(5pt)

#example[Two direct traces][
  For IDs `xs = [2, 0, 3]`, the natural numbers are tested in order:

  #align(center, table(
    columns: 4,
    inset: 5pt,
    table.header([candidate], [0], [1], [2]),
    [in `xs`?], [yes], [no], [yes],
  ))

  So `minfree xs = 1`.

  For priorities `xs = [2, 5, 1, 4]`, the surpasser counts are:

  #align(center, table(
    columns: 5,
    inset: 5pt,
    table.header([value], [2], [5], [1], [4]),
    [larger later values], [`5, 4`], [`-`], [`4`], [`-`],
    [count], [2], [0], [1], [0],
  ))

  Hence `msc xs = 2`.
]

The direct Haskell-shaped specifications are clear:

#pythoncode([
```haskell
minfree xs = head [n | n <- [0..], n `notElem` xs]

scount x xs = length [y | y <- xs, x < y]
msc xs      = maximum [scount x rest | (x, rest) <- eachTail xs]
```
])

The clarity is the point. Both snippets are good specifications because a
reader can test them against small examples. They are poor final algorithms:
`minfree` may test many candidates against a long list, and `msc` compares many
pairs of positions.

#prompt[
  #badge-deeper *1.0 -- Specification audit*
  ```
  For xs = [3, 1, 0, 4], trace the direct minfree specification by hand. Which
  membership tests are performed, and where does repeated work appear?
  ```
]

#prompt[
  #badge-broader *1.1 -- Operational analogy*
  ```
  Give three real systems where "smallest unused natural number" appears. For
  each, explain why returning any unused number is weaker than returning the
  smallest unused number.
  ```
]

= Part 2: The Smallest Free Number

The direct `minfree` program is slow because it asks too many membership
questions. The escape route is a range fact. If a list has length `n`, then among
the `n + 1` numbers `0, 1, ..., n`, at least one is absent. Therefore values
larger than `n` are irrelevant to finding the first absent value. This turns an
unbounded search into a bounded bookkeeping problem.

#definition(numbering: none, title: [Checklist representation])[
  Given a list `xs` of length `n`, a checklist is a Boolean array indexed by
  `0, 1, ..., n`. Entry `i` is true exactly when `i` occurs in `xs`. The smallest
  free number is the first index whose entry is false.
]

#theorem(numbering: none, title: [Range bound for `minfree`])[
  If `xs` has length `n`, then `minfree xs <= n`.
]

#proof[
  The goal is to show that the first absent natural number appears no later than
  `n`. The key insight is a pigeonhole count: there are `n + 1` candidate
  numbers in the range `0..n`, but the list has only `n` positions.

  Even if every element of `xs` in this range is distinct, at most `n` of the
  `n + 1` candidates can be present. Therefore at least one candidate in `0..n`
  is absent. Since `minfree xs` chooses the least absent natural number, it is no
  larger than that absent candidate, hence `minfree xs <= n`.
]

#v(5pt)

#example[Checklist trace][
  Let `xs = [2, 0, 3]`, so `n = 3`. The checklist has four slots:

  #align(center, table(
    columns: 5,
    inset: 5pt,
    table.header([index], [0], [1], [2], [3]),
    [seen?], [true], [false], [true], [true],
  ))

  The first false slot is index `1`. Notice that the trace does not sort `xs`;
  it only records presence in a bounded range.
]

The divide-and-conquer version uses a different memory. Suppose we are looking
for the least absent number at or above a lower bound `a`. Choose a midpoint
`b`, partition the list into values below `b` and values at least `b`, and count
how many values landed below `b`. If the lower interval is full, the answer must
be in the upper part. If it is not full, the answer stays below `b`.

#definition(numbering: none, title: [`minfrom` and interval fullness])[
  `minfrom a xs` is the least natural number at least `a` that is absent from
  `xs`, assuming every value in `xs` is at least `a`.

  For an interval `[a, b)`, say the interval is *full with respect to `xs`* when
  every number `a, a+1, ..., b-1` occurs in `xs`.
]

#theorem(numbering: none, title: [Partition decision])[
  Assume `xs` has distinct natural numbers, all at least `a`. Let
  `us` be the values of `xs` that are less than `b`, and `vs` the remaining
  values. If `length us = b - a`, then `minfrom a xs = minfrom b vs`;
  otherwise `minfrom a xs = minfrom a us`.
]

#proof[
  The key insight is that distinctness turns counting into a fullness test.
  Every value of `us` lies in `[a, b)`. There are exactly `b - a` possible
  numbers in that interval. If `length us = b - a`, distinctness forces `us` to
  contain them all, so no answer lies below `b`; the first absent number must be
  at least `b`, and values below `b` can be discarded.

  If `length us < b - a`, then some number in `[a, b)` is missing. The least
  absent number at or above `a` is below `b`, so values in `vs` cannot affect it.
  The search continues with `us`.
]

#prompt[
  #badge-deeper *2.0 -- Why distinctness matters*
  ```
  Find a list with duplicates where length us = b - a but the interval [a,b) is
  not full. Explain exactly which step of the partition proof fails.
  ```
]

#prompt[
  #badge-deeper *2.1 -- Cost recurrence*
  ```
  Suppose minfrom partitions a list of length n and recurses on at most half of
  it. Write the recurrence for the running time and solve it informally.
  ```
]

#prompt[
  #badge-broader *2.2 -- Sparse identifiers*
  ```
  In a production ID allocator, when would you prefer a checklist, and when
  would you prefer the divide-and-conquer partition method? Discuss memory,
  duplicates, and streaming updates.
  ```
]

= Part 3: Generalize The Answer To Make Joining Possible

For surpasser counts, the tempting question is: can we compute `msc (xs ++ ys)`
from `msc xs` and `msc ys`? No. The single number `msc xs` forgets which
elements in `xs` could be surpassed by elements of `ys`. The repair is a common
calculation move: generalize the result until it carries exactly the information
needed for the join.

#definition(numbering: none, title: [Surpasser table])[
  The *surpasser table* of a list `xs` is a list of pairs `(x, c)`, one for each
  position of `xs`, where `c` is the number of later elements greater than that
  occurrence of `x`. In the efficient divide-and-conquer algorithm, this table is
  kept sorted by the first component.
]

#v(5pt)

#example[Why `msc` alone cannot join][
  Compare these two left halves:

  #align(center, table(
    columns: 4,
    inset: 5pt,
    table.header([left half], [`msc`], [right half], [new cross-surpassers]),
    [`[9, 8]`], [`0`], [`[10]`], [two],
    [`[2, 1]`], [`0`], [`[10]`], [two],
  ))

  These happen to behave the same against `[10]`, but against `[5]` they behave
  differently: `[9, 8]` gets no cross-surpassers, while `[2, 1]` gets two. The
  number `msc left = 0` has forgotten the values that the right half must
  compare with.
]

The sorted table fixes this. When joining a left table with a right table, each
left pair `(x, c)` needs to add the number of right-side values greater than
`x`. If the right table is sorted by value, that number is a suffix length. A
linear merge can emit the combined sorted table while adding those suffix
lengths to the left counts.

#theorem(numbering: none, title: [Join invariant for surpasser tables])[
  Let `txs` and `tys` be sorted surpasser tables for `xs` and `ys`. A correct
  join for `xs ++ ys` must keep all pairs from `tys`, and must replace each
  left pair `(x, c)` by `(x, c + r)`, where `r` is the number of values in `ys`
  greater than `x`.
]

#proof[
  A surpasser of an element in `xs ++ ys` is either already to its right inside
  the same half, or appears in the right half `ys`. The old count `c` records the
  first kind for an occurrence in `xs`. The missing contribution is exactly the
  number of elements of `ys` greater than `x`. Elements in `ys` receive no new
  right-hand elements from `xs`, because `xs` is to their left. Keeping the
  tables sorted lets this accounting be performed during one merge.
]

#prompt[
  #badge-deeper *3.0 -- Table by hand*
  ```
  Compute the sorted surpasser table for [2, 5, 1, 4]. Then split the list into
  [2,5] and [1,4] and show how the two tables join.
  ```
]

#prompt[
  #badge-deeper *3.1 -- Minimal information*
  ```
  Explain why msc xs is too little information for divide and conquer, but the
  full sorted table is enough. Could there be an intermediate representation?
  ```
]

#prompt[
  #badge-broader *3.2 -- Inversions and ranking*
  ```
  Surpasser counts are closely related to inversion counts. Explain the
  relationship, then name one place where inversion-like statistics appear in
  ranking, recommendation, or bioinformatics.
  ```
]

= Summary

#v(5pt)
#align(center, diagram(
  node-stroke: 0.8pt, edge-stroke: 0.6pt, spacing: 3em, label-sep: 0em,
  node((0, 0), [*Spec*], shape: rect, width: 4em, height: 2em, name: <spec>, fill: box-fill),
  node((2, 0), [*Bottleneck*], shape: rect, width: 5em, height: 2em, name: <slow>, fill: box-fill),
  node((4, 1), [*Bounded memory*], shape: rect, width: 7em, height: 2em, name: <bound>, fill: box-fill),
  node((4, -1), [*Auxiliary table*], shape: rect, width: 7em, height: 2em, name: <table>, fill: box-fill),
  node((6, 0), [*Fast algorithm*], shape: rect, width: 7em, height: 2em, name: <fast>, fill: box-fill),
  edge(<spec>, <slow>, "->", [analyze]),
  edge(<slow>, <bound>, "->", [`minfree`]),
  edge(<slow>, <table>, "->", [`msc`]),
  edge(<bound>, <fast>, "->", [calculate]),
  edge(<table>, <fast>, "->", [join]),
))

#v(8pt)

*The big picture:* A good functional specification is not thrown away when it is
too slow. It becomes the object of calculation. For `minfree`, the decisive move
is bounding or partitioning the search space. For `msc`, the decisive move is
remembering a sorted table instead of only the final maximum.

#if not hide-section [
*Back to the problem.* The ID service should use the range bound to avoid
unbounded search: either build a bounded checklist for batch data, or use the
`minfrom` partition rule when distinctness and recursive splitting are natural.
The monitoring dashboard should first compute a sorted surpasser table and then
take the maximum count from it.

#pythoncode([
```python
def minfree(xs):
    n = len(xs)
    seen = [False] * (n + 1)
    for x in xs:
        if 0 <= x <= n:
            seen[x] = True
    return seen.index(False)
```
])
]

*What's next?* Week 1 shows two clean calculations over lists. The next pair of
pearls pushes the same habit into search and selection, where the challenge is
not only what to remember, but which parts of a large implicit search space can
be ignored.

#closing-prompts()
