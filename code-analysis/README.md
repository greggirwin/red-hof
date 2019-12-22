This is an **analysis** of loop constructs written by various people for various real-world projects in R2, R3 and Red.
It's aim is to provide a solid ground for **decision making** about what kind of **HOFs design** should Red follow,
to find out where design's theoretical beauty becomes clumsiness in practice,
and where is the balance between HOFs internal complexity and that of users code.

**Navigate**:
- [Data sample](#data-sample)
- [Loop spread](#loop-spread)
- [Loop/Meaning matrix](#loopmeaning-matrix)
  * [Map: in-place vs another target](#map-in-place-vs-another-target)
  * [Index: numeric vs series](#index-numeric-vs-series)
  * [Other stats](#other-stats)
- [Proposed designs and their coverage](#proposed-designs-and-their-coverage)
  * [Idiomatic block HOFs vs FP-like function HOFs](#idiomatic-block-hofs-vs-fp-like-function-hofs)
  * [Providing an index](#providing-an-index)
  * [Graph (also tree, linked list) traversal](#graph-also-tree-linked-list-traversal)
  * [2D (pair) iteration](#2d-pair-iteration)
  * [On-demand advancement](#on-demand-advancement)
  * [Foreach](#foreach)
  * [Map-each](#map-each)
  * [Remove-each & Keep-each](#remove-each--keep-each)
  * [Filter](#filter)
  * [Inline filters](#inline-filters)
  * [Sift/Locate](#siftlocate)
    + [Syntax](#syntax)
  * [Forparse/Map-parse](#forparsemap-parse)
  * [Part/Limit](#partlimit)
  * [One EACH to rule 'em all](#one-each-to-rule-em-all)
  * [Bulk syntax](#bulk-syntax)
  * [\*-while](#-while)
  * [Count](#count)
  * [Indirect (non-literal) body blocks](#indirect-non-literal-body-blocks)


## Data sample

With properly chosen designs we can make iterators code both very readable and concise.
Another problem we may solve is that each wheel reinvention is time investments and extra risk of bugs.

To that end, a total of **1622 loop constructs** were extracted from the following projects (ordered by cumulative loops size):
- vid-extension-kit.r
- redlang.org (site engine)
- Red runtime files
- rebolforum.r
- rebolbot.r
- qml-base.r
- cheyenne.r
- red-tools.red
- munge3.r
- glayout.r
- lest.r
- topaz-parse.red
- last-man.r
- sql-protocol.r
- drawing.red
- r3-code-editor.r
- make-doc-pro.r
- vid1r3.r
- chessmoves.r
- mindmap.red
- cli.r
- q-plot.r
- skimp.r
- gritter.red
- syntax-highlighter.red
- prolog.r
- diagram-style.red
- rsochat.r
- menu-system.r
- redcodex.red
- liquid.r
- rugby.r
- mini-reb-vm.r
- diager.red
- explore.red
- blueprint-to-swagger.r
- pdf-maker.r
- nass-raw-view.r
- recombine.red
- MockupDesigner.red
- redis.r

The **choice of projects** were driven by these factors:
- variety of projects to cover more tasks 
- variety of authors to cover more approaches and designs
- bigger projects are chosen for they should be more refined, and it just save me time

## Loop spread

Loops were found to be **distributed** as follows:
- foreach: 59.9% (dumbest and most convenient)
- while: 13.4% (60% of whiles is reinventing features a language lacks)
- until: 6.9% (50% of untils is reinventing too)
- repeat: 6.4%
- forall: 5.4% (mostly used to cover for the limitations of foreach)
- loop: 4%
- remove-each: 2.7% (small number to it being often forgotten, or too limited)
- map-each: 0.8% (small number to it being rarely available)
- for: 0.6% (too old school, but makes perfect sense where the size is fixed, e.g. a chess board or matrices)

See the respective pages for each of the loop constructs analysis:<br>
[WHILE](while/README.md), [UNTIL](until/README.md), [FOREACH](foreach/README.md), [FORALL](forall.md), [REPEAT](repeat.md), [LOOP](loop.md), [REMOVE-EACH](remove-each.md), [MAP-EACH](map-each.md), [FOR](for.md). 

Read also on a [coordinate-related code repetition problem](gen-each.md).

An interesting observation I made during this analysis is that I also reinvented some constructs, while not realizing it.
It seems we are so getting caught in existing designs that we miss the opportunity to look at a different angle.
Partly, I expect, because we're usually thinking of the task rather than on choice of approach to it.

## Loop/Meaning matrix

The following table summarizes how each **loop** served to achieve one or other **aim**:

|   MEANING⇨<br> ⇩LOOP:spread⇩ | foreach<sup>1</sup>  | while/until | map<sup>2</sup>    | filter | fold<sup>3</sup> | lookup | loop repeat for | filtered<sup>4</sup> |
|     --:   | ---         | ---         | ---       |  ---   |  ---    | ---    | ---             | ---         |
|  foreach:60%  |  44% (6%)   |             | 39% (2%)  | 3%     |   6%    |  8%    |                 | 24%         |
|  while:13%    |  24% (29%)  | 37%         | 17% (56%) | 12%    |         |  4%    | 6%              | ?           |
|  until:7%     |  27% (48%)  | 48%         | 9% (12%)  | 1%     |         |  12%   | 3%              | ?           |
|  forall:5%    |  50%        |             | 42% (67%) | 1%     |         |  6%    | 1%              | 11%         |
|  repeat:6%    |  12%        |             | 27% (40%) |        |         |        | 60%             | 3%          |
|  loop:4%      |  10%        |             | 13% (83%) |        |         |        | 46% + 31% other | ?           |
| remove-each:3%|             |             |           | 100%   |         |        |                 | 100%        |
|  map-each:1%  |             |             | 100% (8%) |        |         |        |                 | ?           |
|  for:1%       |  14%        |             |           |        |         |        | 86%             | ?           |

**Same** table with numbers **premultiplied** by spread (1st column):

|   MEANING⇨<br> ⇩LOOP:spread⇩ | foreach<sup>1</sup>  | while/until | map<sup>2</sup>    | filter | fold<sup>3</sup> | lookup | loop repeat for | filtered<sup>4</sup> |
|     --:   | ---         | ---         | ---       |  ---   |  ---    | ---    | ---             | ---         |
|  foreach:60%  |  26.4% (6%) |             | 23.4% (2%)| 1.8%   | 3.6%    | 4.8%   |                 | 14.4%       |
|  while:13%    |  3.1% (29%) | 4.8%        | 2.2% (56%)| 1.6%   |         | 0.5%   | 0.8%            | ?           |
|  until:7%     |  1.9% (48%) | 3.4%        | 0.6% (12%)| 0%     |         | 0.8%   | 0.2%            | ?           |
|  forall:5%    |  2.5%       |             | 2.1% (67%)| 0%     |         | 0.3%   | 0%              | 0.6%        |
|  repeat:6%    |  0.7%       |             | 1.6% (40%)|        |         |        | 3.6%            | 0.2%        |
|  loop:4%      |  0.4%       |             | 0.5% (83%)|        |         |        |1.8% + 1.2% other| ?           |
| remove-each:3%|             |             |           | 3.0%   |         |        |                 | 3.0%        |
|  map-each:1%  |             |             | 1.0% (8%) |        |         |        |                 | ?           |
|  for:1%       |  0.1%       |             |           |        |         |        | 0.9%            | ?           |
|  Total        |  35.1%      | 8.2%        | 31.4%     | 6.4%   | 3.6%    | 6.4%   | 8.5%            | 18.2%       |

Footnotes:

<sup>1</sup>`total % (rel % on trees, rel % of lookups)`, e.g. `foreach/foreach 44% (6%)` means:
- 44% of all `foreachs` were indeed `foreach`s by meaning
- 6% of those 44% = 2.5% of all `foreach`s - were traversing trees (as `foreach-face` no doubt)

<sup>2</sup>`total % (rel % of in-place)`, e.g. `while/map 17% (56%)` means:
- 17% of all `while` loops were maps by meaning
- 56% of those 17% = 10% of all `while` loops - were in-place maps

<sup>3</sup> accumulators not including map (which is kind of fold too)

<sup>4</sup> spread of filtering of the incoming data, *across all meanings*. This column emphasizes the importance of having fast and concise filters.

### Map: in-place vs another target

Though `foreach` shows only 2% of in-place maps, this is because foreach does not provide the index right now.
Other loops were often used to implement an in-place map, reaching:
- 14% of all maps are in-place maps (not including `remove-each`)
- It doesn't mean that other 86% map into another series though. Some examples will work either way, as they map from temporary data.

### Index: numeric vs series

The following table shows the type of index best suited the needs of the developer, across all loops analyzed:

|           |while|until|loop|map-each|repeat|foreach|forall|total
| :--       | --- | --- | --- | ---   | ---  | ---   | ---  | :--
|as series  |  11 |   8 |  1 |        |      |       |  2   | 22 = 23%
|as integer |  4  |   12|    |    1   |    12|    23 |  13  | 65 = 66%
|both work  |  2  |   6 |    |        |      |    1  |  2   | 11 = 11%

It is clear that **integer** index is **preferred** (outnumbers series 3:1), although maybe we could support both?
These are convertible to one another of course, and are only a matter of convenience.

### Other stats

These are approximate numbers, likely more than less:
- 12 examples required `foreach`/`map-each` to advance on demand
- 12 examples required `zip` func as they iterate over 2 or more series in parallel
- 8 examples required `foreach`/`map-each` with step=1 and >1 arguments
- 9 examples required value filter embedded into `foreach`/`map-each`
- 5 examples required type filter embedded into `foreach`/`map-each`
- 2 examples decomposed `foreach`/`map-each` argument into more values with `set`
- 8 examples required `sum` aggreagate
- 10 examples required `max-of` or `min-of` aggregate


# Proposed designs and their coverage

One of the problems about loops is that they currently have to be implemented in compiler (as so-called 'intrinsics').
It's abilities there are so limited that even checking a counter is a big and tedious task.
Thankfully though, both `foreach` and `remove-each` are compiled as calls to their respective natives: `foreach-next`, `foreach-init`, etc.
So anything doable on R/S level should work.

## Idiomatic block HOFs vs FP-like function HOFs

**Compilability**

@dockimbel emphasizes:
> it seems that it would be good to **support both** block-oriented and function-oriented HOF, and use user-friendly naming (e.g. accumulate) for the former and more common names for the latter (e.g. fold).
> Note that HOF with **functions** (instead of blocks) can **be compiled** while block-oriented ones can't (unless we add annotations to let the compiler know that the body block contains code. In tight loops, it can make a significant speed difference.

See also [non-literal body blocks issue](#indirect-non-literal-body-blocks)

**Laziness**

Some HOFs may return a **stream** (as a port for example) with inputs and transformation defined.
This stream may fetch items upon request or even allow modification of the input (for maps), or go backwards when we ask (for reversibility).
- benefit: requires less RAM as no intermediate series have to be created (esp. when HOFs are stacked one upon another)
- benefit: lookups over streams will make streams process only the part of the data, up to the item looked for
- drawback: should be slower than series iteration

We could make block HOFs eager, and function HOFs lazy. FP addicts should like that ;)
See also [November 21, 2019 6:54 PM](https://gitter.im/red/HOF?at=5dd6b331986060548953f30a).

Think also filter streams capable of back-propagating the changes into the input.

`zip` (over 2+ series) is a particularily good candidate for a stream: not much use in holding the zipped series, usually we will just pass it to foreach.

This of course requires streams implementation (ports or whatever) to be lightweight.

**Features composition**

We can extend `*each` spec with index and filters (e.g. `foreach [pos: x (integer!)] ..`, but this won't be a good fit for traditional function-oriented HOFs,
where to add an index one would `zip` the series with a numeric sequence, to add a filter one would insert a `filter` HOF into a chain.

**Refinements**

Red uses refinements a lot. Function HOFs can't leverage that: `map srs :mold/all` is not allowed. That doesn't stop us from writing lambda-functions to wrap that: `map srs func [x] [mold/all x]`.

**Arity**

Typically, HOFs accept unary functions. This doesn't fit Red, as series are often used as tables. Thus, function-oriented HOFs, to be on par with block-oriented ones, should use function's spec to determine how many items it takes from the series at once.

## Providing an index

There is a **big demand** to have an index during iteration, in no less than 10% of all loops.
This makes people abandon the so-user-friendly `foreach` in favor of more low level loop constructs.
As this is a trivial feature, I don't see any reasons not to have it.

[As noted above](#index-numeric-vs-series), integer index is preferred, but even better would be to support both variants.
Obviously there's no point in having both integer and series index in a single loop, but being able to choose one that suits best the current need.

**Numeric** index considerations:
- used in the **majority** of cases
- it is better at accessing **another series**: `foreach [i: x y] ser1 [.. ser2/:i .. another-ser/(i / 2): ..]` (imagine `divide index? pos 2` in place of `i / 2`...)
- it is **harder to reason** about: in `foreach [i: x y] ser` - is `i` an iteration index? or index in the series? is it zero- or one-based? does it increase `i` by 2 or by 1? Will `i` start at 1 or at the `ser` current index? (I guess that it's better to have `i` an equivalent of `index? pos-before-x`, i.e. index in the series that increases by the number of words in foreach spec).

Then there are filtered loops, e.g. `foreach [i: x (string!)]` or `foreach [i: :value]`. Loop body does not know how many items have been skipped before an accepted value was found. It becomes even more valuable then to provide an absolute index, while the iteration number one can always deduce by inserting `n: n + 1` into the loop body.

**Series** index considerations:
- it is better at accessing **adjacent items**: `foreach [pos: x y] ser [.. pos/-1 .. pos/3 ..]`
- it is **easier to reason** about: `foreach [pos: x y] ser` naturally tells one that `pos:` is set to `ser` just before the `x` value
- it is familiar to us from **`parse`** syntax and **compatible** with `parse`-based designs: `foreach [pos: ..]` and `forparse [pos: ..]` share the same meaning for `pos:`

**Possible syntax:**
- `...each [pos: x y] ser` for `pos` to be set to series index
- `...each [/i x y] ser` for `i` to be set to numeric index
- index word, if given, should come **first**

Note that index in any form does not make sense for maps (`foreach [k v] map`).

## Graph (also tree, linked list) traversal

Of course it is not as widespread as series traversal, but it is much more complex to reimplement, so it's importance should not be judged by it's spread % only.

There are 4 traversal **directions** on graphs, and 5 on trees:
- from a node to it's subnodes, then to next adjacent node (this is how `foreach-face` visits)
- from a node to it's subnodes, then to previous adjacent node
- from a node to it's supernodes, then to previous adjacent node (reversing the parent-child relation)
- from a node to it's supernodes, then to next adjacent node
- from a node to it's single supernode only (towards the root (**TTR**), requires nodes to have at most one parent; this is often reinvented with `until`)

All of these directions can be cyclic (infinite), but only the first four are recursive.

You may notice `foreach/reverse` or `locate/back` in examples used as a mockup for TTR iteration.
Disregard this specific syntax, as it was just a wild idea. I think `/reverse` should follow the 3rd direction, being a true reverse of the 1st.
For TTR we can have a special iterator that, given a node, produces a list of it's supernodes, e.g. `foreach n ascend node [...]`.
One thing I don't like about `ascend` name though is that it talks about a tree having the root on top of it, which is acceptable but kind of... not right ;)

I also think that `foreach-face` should be implemented using a general graph-accepting `foreach`.

**Graph iterator** is a bit different from series iterators: it has to **hold** not only the current, but also the **starting node**.
Why so? Imagine we descended into a subnode then stopped. If we then pass this subnode to `foreach` we will never ascend back to the parent node and visit it's siblings.
By holding also the starting node, it is able to ascend until all nodes next to the starting one are visited. This also limits the applicability of `next` and `back`-like functions to graphs (but not to proper iterators on graphs).

Q: One of the key points, if we have a graph with arrows and nodes, expressed with the same `node!` datatype, **do we skip arrows** or process everything? [Inline filters](#inline-filters) can be the answer, but will require an extension. Custom iterators are another, probably better answer.

## 2D (pair) iteration

It makes sense to write `foreach [xy: color] image [..]`, traversing an image row-by-row then col-by-col inside rows.
This form supports both numeric (as pair) and series index.

There can however be a need for the same 2D iteration **over a range given by a pair**, so if we support this, we should also support 
`for xy 1x1 10x10` or `repeat xy 10x10` or both. `for` can even be a mezz over `repeat`, for it's use is very sparse and unlikely worth a native.

## On-demand advancement

Some examples benefit from this. To skip an item (using it or not), or to skip a whole bunch of items:
a positive number, where data record size depends on the data. Backward advancement can be considered but I haven't met any use cases.

An `advance` func can be exposed by `foreach`, in the same manner `keep` is exposed by `collect`.
But it will only be worth it if it doesn't slow down `foreach` startup. So, maybe not as a function, but as a native, like `break`/`continue`.
Those work by throwing exceptions though, while `advance` should continue the body evaluation.

If exposed, **it should** likely, when called:
- do a **skip** according to `foreach` spec, considering the number of items and whether they pass the filter expressions
- do **NOT set words** in `foreach` spec, as that will make it much harder to reason about `foreach`'s body behavior, even trivial examples like `map-each x s [advance x]` could deceive the user - it looks like 1-to-1 mapping of odd items, but it's not
- **return the new location** in the series, so that one may use `set` on it to manually set the words to the new data
- **return none** if there's nowhere to advance (met the tail)
- let `foreach`'s next iteration continue on from the location where `advance` left it (that's the main point)

## Foreach

`foreach`, when powered by index and filters, becomes an almost all-encompassing iteration tool.
However, a care should be taken, since the more we add to it, the more we lose when for some reason we have to fall back to plain `while`.
This, in turn, may incline us to embed more features, so that `foreach` will always be enough, leading it to overspecialization.
So, **when a feature can be easily separated, it should be.**

`foreach` is also a ground for other `..-each` implementations, and their descendants (e.g. `..-while`).

**End condition**. Foreach can end normally after:
- An expected number of iterations has passed (series length / args count). This is limited to read-only inputs.
- Input series' is too short to set all the words in the spec from it. This is limited to a single input buffer.
- Input series' tail (or head, if reversed) is met. If series is shorter than the number of spec words, remaining ones are set to `none`.
- Tail of the series returned by the given word is met. This allows to substitute the series during iteration, and is only working for `forall` in R2 & R3, and is forbidden in Red.

Third option is the one currently implemented and the one that makes most sense, and is consistent with `set [..]`. But we should be fully aware of it.

Q: Should foreach **wait for a stream** or not (think real-time processing and infinite streams)? Should a port flag control this behavior, or should there be functions that convert a waiting port into non-waiting one and back?

## Map-each

Examples show that `map-each` should **not** be limited to **one-to-one** mapping. A single item can be replaced by many, many - by one.

With `map-each` we want to be able to (considering inline filtering):
- pass filtered out items as they are (done by `map-each` internally)
- pass filtered in items as they are, e.g. `map-each [x y z] srs [reduce [x y z]]`
- pass filtered in items modified, e.g. `map-each [x y z] srs [reduce [z + y x]]`
- remove filtered in items, e.g. `map-each [x y z] srs [ [] ]`
- insert more items, e.g. `map-each [x y] srs [ reduce [x z y z] ]`
- map into the same series or a new block (see [Map: in-place vs another target](#map-in-place-vs-another-target))
- choose a delimiter item that is only inserted between other items, not at head, not at tail

**Refinements:**
- `/only` - just a sugar over `map-each [x] .. [reduce [:x]]`: `map-each/only [x] .. [:x]`
- `/self` - uses `change` on the source series (or rather mimicks it in a faster way), forming values if source is a string
- `/sep` - insert a separator between each group of items (e.g. `map-each/sep [x y] [1 2 3 4] [x] '|` = `[1 | 3]`). Should also separate filtered out item groups.
- `/eval` - reduce returned blocks automatically. For one, is simplifies many map expressions, as typing `reduce` is boring.
For two, it greatly reduces GC load and speeds things up, because it reduces right into the output buffer, without allocations. Should or not this be the default behavior? I think not, because it is dangerous, unable to tell a literal block from one resulting from an item: `map-each/eval [x] src [:x]` looks like an identity map, but it's not: if `src = [ [code] [code] [code] ]`, each `x = [code]` and it will evaluate `code`.

**Filtered out items**

With in-place maps we always want to pass them as they are. This way we can concentrate only on parts of the series that we care for.
Like modifying every `pair!` in draw block or you name it.

With normal maps, it is not that clear what is best. But if we go with `/self` refinement, we have to provide consistency.
Otherwise, there must be 2 map-eachs, one in-place, one normal, each with it's own treatment of filtered out items. E.g. `map-each` and `remap-each`.

But **most important** point here is to define **`continue` and `break`** behavior (also `break/return` and `advance`). And their **interplay** with each other and refinements (namely, `/sep`).

**Continue**

`/only` disables an option to remove items. Returning `[]` is no longer an option. We can use `continue` to do that:
- pros: mimicks `collect [foreach [..]]`, where `continue` does not involve `keep`
- pros: allows one to use it with `/only` to remove items
- cons: it doesn't feel a natural thing to do by `continue`
- cons: inconsistent with `remove-each`, which doesn't touch items on `continue`
- cons: inconsistent with items skipped by a filter (these items are handled without user code, which is similar to `continue`)

I think it's most reasonable to let `continue` pass items from source into target untouched. `map-each [anything..] src [continue]` then becomes an identity map.
We should also consider it's meaning for other functions, like `take-while`.

**Break**

Two options:
- pass all leftover items as is
- remove all leftover items (truncate the output)

On truncation:
- pros: mimicks `collect [foreach [..]]`, where `break` does not involve any more `keep`s
- cons: doesn't go very well with in-place maps, practically destroying the series, which is never the intent (and when it is, one can `clear` it). We usually want `break` to save time by not processing the rest, not to mimick `clear`.
- cons: inconsistent with `remove-each`, for the same reason

Again, I think the 1st option is the way to go.

`break/return`: discards the collected series obviously, unless `map-each/self` is used (then it commits the data first). Can be used for error propagation, fallbacks.

**Advance** within `map-each`

Perhaps, it should do what `continue` does with items (pass as is or remove, whatever decided).

Another option is to widen the area for a subsequent `change`:
```
map-each [x y] [1 2 3 4 5 6 7 8] [
    set [p q] advance
    reduce [x + y p + q]
]
``` 
would result in `[3 7 11 15]`.

**Unset & None treatment**

One possibility is to use `unset` or `none` values to remove items (along with the empty block). But this limits the applicability by a lot, so I'm against it.

Q: how should `map-each [x y z] srs [reduce [x y z]]` treat `srs: [1 2]`? Pass `z` as `none` and let the output be longer than input?

## Remove-each & Keep-each

These two can mirror each other (one removes on false, the other on true). Sometimes one looks cleaner, sometimes another. `keep-each` is not the best name though, maybe more ambiguous than `filter`. 

Another option is to have one copying, another working in place.

These filters, for consistency, should support `foreach` extensions. But what does it mean to filter the result of inline filter? This is where `keep-each` design becomes tricky:
- `remove-each [:value] srs [yes/no]` skips (leaves untouched) filtered out items
- `keep-each [:value] srs [yes/no]` ? should it also keep filtered out items (as a mirror of `remove-each`)? or remove them (by the word meaning, they are filtered OUT so should not be KEPT)?
- same question for `..each [x (datatype!)] ..` filters
- `keep-each [..] srs [continue]` - should this keep the item?
- `keep-each [..] srs [break]` - and this, should it keep the rest?

**Complexity**

[I criticize](https://gitter.im/red/HOF?at=5dd5aeb5e7cce550f591a869) the current design of `remove-each` for it's O(n^2) asymptotic complexity. R2 implementation is only O(n): it collects the items into a new buffer, then replaces the original series buffer with a new one. The subtle change is seen here:
```
;; R2
>> b: [1 2] remove-each x b [probe b yes] b
[1 2]
[1 2]
== []

;; Red
>> b: [1 2] remove-each x b [probe b yes] b
[1 2]
[2]
== []
```
This subtlety becomes bigger if we consider reactivity. The series in question can be a reactive source. It may be `face/text` or `face/data`.
It is arguable, what is more useful, to trigger reactions after every removal, or once after all of them. Former may catch data in inconsistent state (but so all of reactivity, when it goes unchecked). It is also WAY slower.

But if we go the R2 way, how do we explain to `on-deep-change*` (which accepts known action names only), that we have just performed a "buffer switch" trickery? I propose a `change` action on the whole buffer (more precisely, after it's original head).

This problem also concerns in-place maps.


## Filter

Whenever I try this in examples, it's always second-rate to `remove-each`/`keep-each`.
See [the laziness idea](#idiomatic-block-hofs-vs-fp-like-function-hofs) though. `filter` may return a stream.


## Inline filters

The point here is not to add whole `any`/`all` expression blocks into `foreach` spec and cover everything (as it adds nothing).
The point is to be able to write **clean one-liners** for the majority of the use cases.
Not to facilitate splitting `foreach` spec into separate lines, but to take a few lines (and a few levels of indentation) from the loop body and reduce it into a few words.

A separate benefit from `foreach [:value]` kind of filters is leverage of **fast lookups** on hash tables.
A drawback is that all `-each` funcs will have to support `/same` and `/case` refinements to control comparison strictness.

Another benefit is that we can add inline filters into `map-each/self` or `map-each` that uses items' indexes. Whereas if we pass the result of `filter` into `map`, we **can't affect the original and we lose the index info**.

**Value filters**

`foreach [x :value z]` only executes it's body where 2nd item equals `:value` (which can be of `datatype!` type)

Example:
```
while [not none? base: find/skip base name 2][
    insert tail result pick base 2
    base: skip base 2
]
```
Can be rewritten 
- as `foreach [:name y] base [append result :y]`
- or `append result extract keep-each [:name y] base [yes] 2` (note: `map-each` is not applicable if it keeps filtered out items)

**Type filters**

`foreach [x (typeset!) y z]` only executes it's body where 1st item is of typeset `typeset!`. I'm not sure about parens or block syntax (or path `x/typeset!`?). Blocks can be used for item decomposition: `foreach [ [x y z] ] [ [1 2 3] [4 5 6] ] [...]`. But it's a very rare case, and `set [x y z] value` works just fine. Parens look cleaner inside block spec. But not compose-deep-friendly. Blocks with types remind functions spec dialect.

Q: Should it support multiple typesets? Should it support an optional `not` keyword that negates the typeset? Examples do not seem to provide any use cases for this.

Example:
```
while [tmp: find tmp block!] [
    change tmp func [new args] first tmp
]
```
Can be rewritten as:
- `map-each/self [x [block!]] tmp [:x/1]`


## Sift/Locate

The **idea** behind these two is to **remove the syntactic noise** from trivial filter expressions.
To do the thing that is meaningful in 95% cases, without further ado.

The expression should be **more readable** than the code it replaces.
Keystones are: **table** support and **inner** item inspection.

Plain example:
```
until [
    any [
        rval: all [
            in face 'gl-class ; must at least be a glayout widget (not just a component face)
            face/gl-class = tp
            face
        ]
        ( face: face/parent-face
        none? face) ; exit when we have reached window
    ]
]
```
Can be rewritten as:
- `locate ascend face [/gl-class = (tp)]` (hint: `/gl-class` checks for this path existence automatically)

Table with inner inspection example (2 columns):
```
pane: tail pane
until [
    pane: back back pane
    any [
        pane/1/options/style <> 'connect
        pane/1/options/parent-style <> 'connect
    ]
]
```
Can be rewritten:
- as `locate/back pane [1 - .. /options [/style = 'connect or /parent-style = 'connect]]`
- or `locate pane [-2 - .. /options [/style = 'connect or /parent-style = 'connect]]`

There are plenty examples thoughout: see [remove-each](remove-each.md), [forall](forall.md), [until/foreach](until/foreach.md), [while/foreach](while/foreach.md)

* `sift` is a high-level filter. It produces a new series (or stream?). It thus loses the connection with the input data.
* `locate` is a high-level lookup. It returns the input at the expected location.

### Syntax

The syntax of `sift` and `locate` is mostly similar, but not complete. Nor there any model impelementations.

- `sift series filter-expression`
- `locate series filter-expression`

Filter expression consists of 2 parts: optional *selector* and optional *tests*

**Selector** can take one of these forms:

| Selector&nbsp;form_____ | Meaning |
| :-- | :-- |
| Omitted | Tests will be applied to every item, starting from the 1st |
| `[1 2 3 ..]` | Treat data as having 3 columns, their values will be referred to by their numbers |
| `[- 2 - ..]` | Hyphens omit columns (1 and 3) from the result, and from implicit testing (though still can be addressed explicitly as `1` or `3`). There must be at least one number and zero or more hyphens |
| `[1 5 ..]` | Defines a sequence (1st item, 5th, 9th ...). A shorthand for `[1 - - - ..]`. Cannot have hyphens in sequence form |
| `[-1 ..]` | Like `[1 ..]` or when omitted, but goes in reverse direction from the tail |
| `[-3 -2 -1 ..]` | Like `[1 2 3 ..]`, reversed |
| `[- -2 - ..]` | Like `[- 2 - ..]`, reversed |
| `[-1 -5 ..]` | Same as `[- - - -1 ..]`, more readable |
| `[-4 -8 ..]` | Same as `[-4 - - - ..]`, more readable |

`..` serves as both an end-of-selector marker and as a visual helper.

I also thought of `[start .. end]` form (e.g. `[3 .. -3]` would mean start with 3rd item, stop after (tail-3)rd) but it's ambiguous in current syntax, and is very rarely needed.

At this point, I'm undecided myself yet if it's worth using negative integers for direction control. Note that they are not necessarily the same as using `/back` refinement, because positive integers start from head, while negative ones start from tail:
```
srs: [1 2  3 4  5 6  7]
locate     srs [-2 - .. -2 <= (4)]     ;) = [4  5 6  7]    - counts pairs from tail
locate/back srs [1 - .. 1 <= (4)]      ;) = [3 4  5 6  7]  - counts pairs from head (last one maps `1` to `7` and `2` to `none`)
```

`locate/back` should forbid negative selectors.

Q: Should `sift`, `locate` and especially `locate/back` with negative selector jump to tail automatically? I think it's useful most of the time, but it does not allow one to start from the current position.

---

*Tests* are applied to *Subjects*.

**Subjects**

| Subject form | Example__________________________________ | Meaning |
| :--  | :--     | :--     |
| an integer | `3 has 'value` | Test `has 'value` is applied to the value in column #3 |
| a word | `x: 3 x pair! (print x)` | Type test `pair!` is applied to the value of word `x`, which must be set previously in the spec to a column number. It is useful when using a Red expression as a test. |
| nothing | `[1 - 3 .. integer!]` | Type test `integer!` is applied to all non-hyphenated columns values, which consitute *the default subject*. It is currently the only way to test multiple values at once. |
| brackets | `[1 2 .. /x [integer! >= (0) < (100)]]` | Locally replaces default subject: tests `integer!`, `>= 0` and `< 100` are applied to `/x` subpath of both 1st and 2nd column values. Immediately fails if any value has no such subpath. |

**Tests** are an ordered chain of conditional expressions on items (similar to `all`). If a test fails, ones to the right of it are not tried.

Tests are run against particular columns, but they decide if **whole row** passes or not:
- single failure = whole row is discarded
- all tests pass = whole row is passed

| Test&nbsp;form_____ | Example_______________________ | Meaning |
| :--  | :--     | :--     |
| `(expr)` | `[x: 1 y: 2 (myfunc x y)]` | Evaluates Red `expr` (every time!), passes if the result is not `none` or `false`. |
| `= (expr)` (any logical op) | `[1 2 .. 1 = (yes) 2 = (no)]` | Passes if `subject op (expr)` is not `none` or `false`. |
| `is (expr)` | `[is (now)]` | Equivalent of `= (expr)`, looks better without a subject, or when testing *every* item |
| `is same (expr)` | `[is same (my-blk)]` | Equivalent of `=? (expr)` |
| | | I haven't invented the form for strict (`==`) comparison alias (maybe `is strictly (expr)`, but it's somewhat long). |
| `has (expr)` | `[2 has (pair!)]` | Evaluates `find subject (expr)`, passes if `subject` is a series, and result is not `none`. |
| `in (expr)` | `[2 in ([any all])]` | Evaluates `find (expr) subject`, passes if `(expr)` is a series, and result is not `none`. |
| `type (expr)` | `[1 type (type? x)]` | Evaluates `(expr)`, passes if it returns a type or typeset and subject matches given type(s). |
| `type!` | `[1 integer!]` | A shortcut for the above, only allowed if the word (`integer!`) is bound to a `type!` or `typeset!` value. |
| `subject` | `[/subpath]` | Passes if subject exists, i.e. here every item must have a `/subpath` |
| `word: test` | `[x: /1 y: (print x)]` | Sets word to a value of the next test, always passes (if that test passes too), i.e. here `x` is set to first subitem of every item, and `y` to `unset` (result of `print`) |

Right now the only words allowed to appear in spec are:
- keywords: `is`, `in`, `has`, `same`, `type`, logical operators.
- those previously defined as set-words in it (`x: .. x = 1`)
- Red words that evaluate to types and typesets (`2 default!`).

`type` keyword can be renamed to `of`: `x of pair!`. But I like `type` better, more to the point.

Currently it's possible to allow right part of operator test to contain an integer: `1 > 0` may test if column #1 value is positive.
Another option would be to treat all integers as column numbers: `1 = 2` may test is values of columns #1 and #2 are equal.
I haven't decided what's better. First option makes parens around integers optional, but it does not remind the readed that `1` and `0` are values of different classes: column value and plain integer value. So I'm for the 2nd option.

I'm not sure if I should allow accessing columns that do not appear in selector, especially in it's table form: `[1 - 3 .. 4 = ('value) -1 in ([set])]` - is it an error or not? It's a potential place for refactoring bugs that can be reported, but also a potential feature.

Parens can be omitted in many cases. Perhaps everywhere where an expression is expected and it consists of a single item. E.g. `3 in [= =? ==]` it's obvious that we can accept a block without parens. I haven't made my mind yet. Currently in examples I allow plain lit-words and typesets: `1 = 'word` rather than `1 = ('word)`

**`locate` vs `sift` differences**:
- Hyphen `-` does not omit items in `locate`, obviously (as is no result to omit them from). It does affect *default subject* choice though.
- `locate` returns once match is found, it does not process the rest


## Forparse/Map-parse

`forparse pattern series body` can be considered a syntactic sugar for: `parse series [any [pattern (do body) | skip]]`. At least 8 examples of it.

`map-parse pattern series body` - for: `parse series [any [change pattern (do body) | skip]]`. At least 7 examples of it.

They are cleaner than plain parse and more general than `foreach`/`map-each`. And also more verbose, and do not inherit the benefits of `find` on hashes. And they inherit all `parse` bugs ;)

While `foreach` on string types examines separate characters, `forparse`/`map-parse` can work with whole substrings.

Also good point WRT vectors: https://github.com/red/red/issues/4194
Parse-based iterators won't work on vectors. Find-based will (to the extent of `find` vector support).

Refinements need to be thought about yet... Also proper `break`/`continue` support...

## Part/Limit

Also 2D limit, for loops over images.

I see sometimes `repeat` used in place of `foreach`, because to stop `foreach` before the tail we have to do a check in every iteration, which is both inefficient and clumsy.

The **idea** here is that `part series n` function can return a **stream over given series** that exhausts after `n` items and forbids any access beyond that and given series' head. Think `/part` refinement everywhere, even in user defined functions. I know this is an old idea. I've been thinking about it a lot myself. It can't be implemented as a datatype extension, because most series datatypes do not have a spare space in their cells. But as a stream it works gracefully.

Pretty silly to reimplement the same `/part` logic over and over in each function, no?

Should streams be read-only (not good but..), it will be **applicable to** `foreach`, `map-each` and other readonly HOFs, but also all aggregators, all vector arithmetic, set operations, reduce/compose/compress etc. With write (into the input series) capabilities, it extends to `map-each/self` (most notably), `forall`, `bind`, `trim`, `random`, `replace`, `complement`, `alter`.


## One EACH to rule 'em all

This model is a **unification** of block-oriented and func-oriented approaches.
Along the lines of [`headless.red`](../headless.red), but that's just a quick teaser. 
Constructing a function each time is too costly for general use.
OTOH, if `each` could return a lightweight iterator, then it might make sense to.

This **iterator would hold** (think of these as slots, holding routines or empty):
- the data source(s) if any
- words to be set on each iteration
- current location
- starting location (for graphs)

It is thus different from a stream that has only to hold the data source and location, so may require it's own datatype. Or not?

Primary **levers** it would expose are:
- move the data pointer forth (maybe using a filter)
- do so a number of times
- do so backwards
- set all the words at the current location (separately from the movement)

And **optionally**:
- replace the data at the current location (if data source is not read-only)
- reverse the default iteration direction (not sure about use cases ☻)

**Possible benefits** this iterator may provide:
- **Manual creation** of all sorts of highly specialized iterators and generators. Think iterators on tables that know their format, infinite sequences, time/date generators.
- Possibility to **pass iterators around** as first class values. Stop and resume in another place (forall-like, but general) at will. Disperse them among different functions that handle only specific value patterns. Thinks data providers, maybe DB modules, that would give out iterators for convenient use..
- **Separate complex filters** can be applied to the items (as a single word, not the whole `if ... ` construct requiring a new indentation level).
- A **common interface** will be shared by many loops. It should be extendable via user-provided functions or routines.
- `each` will **implement** `/reverse`, `/stride`, `/case` and `/same` **refinements once**, lifting the burden from all receivers,
while the receivers will only be responsible for their own specific refinements (e.g. `/self` for maps).
- But the *reddest* benefit lies in giving users more **expressive power**. In things that we can't foresee yet.

`all` (or rather `every` or `all-of`) can be a simpler iterator, with only one word to set and step = 1. `for all xs [...]`

`until` (or rather `till`) can be a wrapper around `each` that would accept a condition block and refine the iterator results.
`till [x < 0] x xs`, `for till [x < 0] x xs [..use x..]`, `map till [none? x] x xs [ [] ]` (removes none)

Consider `for` and `map` natives that accept such iterator and instead of `foreach-next` they call iterator's facilities, which may be predefined actions, or user provided `port!` actors.

On the outside, there still will be two-word shortcuts, like `keep-each`, `take-while` as `keep` and `take` are one-off funcs, and it's just shorter and cleaner this way.

...This is a deep topic and needs more thought and exploration, experiments...

## Bulk syntax

Somewhat cleaner syntax for trivial cases of `foreach`/`map-each`, `bulk` syntax allows to apply the same set of expressions to each item in a series. Not a huge win here. Sometimes no win at all ;)

`bulk [expressions..]` evaluates `expressions` for all items in a series, substituting an asterisk path `*` item with an index.
The result is ignored by default, and collected into a block with `/map` refinement (better names?).

| Bulk syntax | Original syntax |
| :-- | :-- |
| `bulk [set in get sides/* 'show? true]` | `foreach side sides [set in get side 'show? true]` |
| `bulk [gobbg/pane/*/data: gobs]` | `foreach subface gobbg/pane [subface/data: gobs]` |
| `bulk [messages/*/sent: load messages/*/sent]` | `foreach message messages [message/sent: load message/sent]` |
| `bulk/map [split query/* "="]` | `map-each/only v query [split v "="]` |
| `key: form bulk/map [rejoin [:key/* #":"]]` | `key: form map-each v key [rejoin [:v #":"]]` |
| `bulk [act-face system/view/screen-face/pane/* none 'on-deactivate]` | `foreach window system/view/screen-face/pane [act-face window none 'on-deactivate]` |

Also applicable to different series with same length.
Can be applicable to graphs using functions that convert graph iteration into series (or stream).
May be extended to scalars (tuples, pairs), where `foreach` can't work: `bulk/map [tuple/*]` would unpack all tuple items.


## \*-while

There are examples that would benefit from (there may be more, not counted):
- `remove-while` (4 examples)
- `count-while` (6 examples)

## Count

Used in only like 2 examples. But it's great :)
Just a mezz wrapper for `while [find..] [n: n + 1]` that delivers intent very clearly.
Basically: `count series term` to count how many times `term` appears in `series` (term can be a datatype).

E.g. `while [content: find/any/tail content term][rank: rank + 1]` becomes: `rank: count/any content term`

Should accept `find` refinements:
- `/part` (and maybe `/reverse`) to control the counting range
- `/same` and `/case` for equality control
- `/any` for pattern matching
- `/only` for block expansion control
- `/skip` for tabular data

## Indirect (non-literal) body blocks

Gregg asked:

Should the compiler support block refs for loop/repeat? e.g.:
```
code: []
loop 5 code
```
It doesn't today. 
```
*** Compilation Error: expected a block for LOOP-BODY instead of word! value 
*** in file: D:\Red\temp\bad-loop-compile.red
*** near: [code]
```

Nenad responded:

It could try to fallback on the interpreter for that, but I don't think it's possible to support all the possible expressions you could put after `loop 5....`



