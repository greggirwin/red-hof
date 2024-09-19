DESIGN: Iterator


# Sources and my thoughts on them

- REP 0101 "For Loop Function" https://github.com/red/REP/blob/master/REPs/rep-0101.adoc

  On-the-surface drawbacks of this REP:
  - it proposes a whole new dialect for one of the least used loops, and unlikely a lot of us will bother memorizing it
  - does not address how values and expressions get into the dialect block (supposedly, by `compose`?)
  - does not utilize ranges as datatype
  
- https://www.curecode.org/rebol3/ticket.rsp?id=1993

  Stated problem "choose a meaning for [start end bump] arguments" neglects deeper design questions:
  - we don't *usually* need `bump` (I've personally used `for` circa 10-20 times, but always with a bump of 1)
  - an attempt making `bump` optional is ruined by the fact that if it's a refinement, it will come *after* the code block in `for/step i i1 i2 [code] bump`, which will make it very ugly
  - to allow or disallow backwards traversal is not something we should enforce, as both approaches have their applications
  
  Design proposed below solves the `bump` issue and tries to accomodate for the varying traversal applications.
  
- `cfor` (I haven't found a live source, but basically `cfor [[init-expr] [condition] [incr-expr]] [code]`)

  A very general, but quite verbose and not Redbol-ish loop, that in my opinion has more historical than practical value.
  Though more readable than `while` when `init-expr` and `incr-expr` can be clearly extracted from the surrounding code.
  And it makes explicit whether and how backwards traversal may happen, unlike Rebol `for`.

- `*each` loops: https://codeberg.org/hiiamboris/red-common/src/commit/efd38a5f7354c57b2b4aa8d860e4ea1f093466e6/foreach-design.md

  Have proven to be the most useful and high-level loop constructs, but I can't shake off the feeling they're too monolithic, and I would love to deconstruct them into smaller orthogonal parts. Hence... 

- A teaser on loop unification https://github.com/greggirwin/red-hof/tree/master/code-analysis#one-each-to-rule-em-all

  But this lacks implementation-aware thoughts and some experience I've gathered over the years.



# Design proposal

**Goals:**
- make list operations in Red more readable and high level than ever before
- obsolete the zoo of highly specialized but all crippled loops inherited by Red from Rebol (crippled because they all shine at one and only one task: if I need two or more done at once, I have to reinvent the wheel once again)
- bridge iteration with series modification and generation
- split `*each` loops into self-sufficient parts, to expand the coverage of their design

This design aims to obsolete in particular:
- `for` loop proposed by REP 0101
- `loop` native loop
- `repeat` native loop
- `while` native loop
- `forall` native loop
- `foreach` native loop
- `remove-each` native loop
- [`for-each`](https://codeberg.org/hiiamboris/red-common/src/commit/efd38a5f7354c57b2b4aa8d860e4ea1f093466e6/foreach-design.md) extended loop
- [`remove-each`](https://codeberg.org/hiiamboris/red-common/src/commit/efd38a5f7354c57b2b4aa8d860e4ea1f093466e6/foreach-design.md) extended loop
- [`map-each`](https://codeberg.org/hiiamboris/red-common/src/commit/efd38a5f7354c57b2b4aa8d860e4ea1f093466e6/foreach-design.md) extended loop
- [`xyloop`](https://codeberg.org/hiiamboris/red-common/src/commit/efd38a5f7354c57b2b4aa8d860e4ea1f093466e6/xyloop.red) 2D loop

`until` loop is not questioned, as it is unary. 

Also, while technically this design may replace `while`, `loop`, `repeat`, I'm not saying it must, because:
- it still has a slight allocation cost on each iteration (not serious if allocator is optimized)
- we don't want to break legacy code or habits without a solid reason
- readability of more specialized names is sometimes a little higher, e.g.:
  - `while [condition] [code]` vs `for [condition] [code]` or `loop [condition] [code]`
  - `loop count [code]` vs `for count [code]`

Note that this design requires *ranges* and *slices* (a special case of ranges).

**Benefits** of this proposal include:
- **isolation of concerns**: iteration becomes decoupled from the action taken
- native **graph iteration** (tree, list, mesh...)
- **user-defined** iteration **order** support in all loops
- iteration **state** becomes a **first-class** value and can be passed around, continued at any time from where it left off
- iterators are **lazy**, do not need to preallocate the iteration sequence, so it can even be **cyclic/infinite** (e.g. tabbing)


## Syntax

**Briefly**:
```
	for    <series> <function>
	map    <series> <function>
	filter <series> <function>
	list   <iterator>
```
Where:
* `<series>` is any of: `series!`, `map!`, `iterator!`, `range!` or `integer!`
* `<function>` is either:
  - a block of code, or
  - a unary function that receives one of:
    - the series item (when series is given)
    - a map key (when map is given)
    - the iterator in its current state (when iterator is given)
    - an intermediate scalar value (when range is given)
    - an integer (when integer is given)

Such design makes these functions applicable both in FP and Redbol styles.

All the basic loops: `for`, `map`, `filter`, `list` should contain a control flow trap that catches `continue` and `break` signals. Thus control flow handling becomes centralized and uniform, as opposed to being scattered across a multitude of loop implementations (`map` and `filter` are special cases of `for` and will call it internally).

It should be valid for both `<function>` and the `<iterator>`'s internal matching code to throw `continue` and `break` signals to the loop. `continue` from both sources tells it to skip an iteration (esp. meaningful in `map`), while `break` tells it to skip all remaining iterations.
See more info in [iterators API](#iterators-api) description.

An **overview** of applications:
```
for each x [a b c d] [code]					;) iterator: target word and range - 2-3 cells; sets the word on every iteration
for each [/i k v] #[a b c d] [code]			;) extended syntax used by `for-each` is applicable to the `each` iterator
for each x s..e [code]						;) `each` only increases `x`, so if e<s it stops
for (each x s..e) [code]					;) same thing
for each x reverse s..e [code]				;) reverses the range itself, so if e<s this enables iteration again
for reverse each x s..e [code]				;) sets the 'reverse' flag in the iterator, reversing the order of values x receives (not s and e)
for each x limit [code]						;) no longer need `repeat`
for each xy WxH [code]						;) a 2D variant of `repeat` (like my `xyloop`)
for each xy AxB..CxD [code]					;) ditto, but the 2D area doesn't start at 1x1
for limit [code]							;) no iterator - no word - no longer need `loop`
for s..e [code]								;) almost useless, same as `for e - s + 1` (but can be fed an existing range)
for every xs [code]							;) `every` iterator mimicks `forall`, which will be no longer needed (unimportant if we have `map`)
for step x s..e bump [code]					;) `step` (`stride`?) iterator replaces the classic `for x: s e bump [code]`, unlike `each` may walk backwards
for each x above node [code]				;) `above` iterator on a tree reaches the root; note the human readability of it
for each x next above node [code]			;) same, but skipping the `node` itself
for each x after node [code]				;) `after` iterator traverses the tree to the right
for each x before node [code]				;) `before` iterator traverses the tree to the left
for iterate [init] [test] [incr] [code]		;) `cfor`-like iterator (or how to better name it?)

map each x [a b c d] [code]					;) binary `map`, compatible with the functional one `map series :func`

filter each x [a b c d] [code]				;) binary `filter`, compatible with the functional one `filter series :func`

list 2..5									;) expands range into a block => [2 3 4 5]
list reverse tail each x 2..5				;) lists values of a reversed iterator => [5 4 3 2]
list above node								;) lists node and all of its ancestors
```

---

Now in more detail...

### FOR

**Syntax:** `for <series> <function>` (see meanings [above](#syntax))

**Does:** evaluates `<function>` for every item in the series, key in the map, iterator state, value in range, or integer up to limit. When `<function>` is a unary function, it receives this value as argument.

**Returns:** last evaluation result or `none`.

**Refinements:** none.

**Examples:**
```
for 10        [try/catch [connect...] [print "Failed..."]]						;) same as `loop` - but the worst use case of it
for each i 10 [try/catch [connect...] [#print "Failed (i)..."]					;) same as `repeat` - even more readable

for row1..row2 func [row] [print ["row" row "is:" rows/:row]]					;) using ranges allows to provide starting value (FP-style)
for each row row1..row2   [print ["row" row "is:" rows/:row]]					;) same, more idiomatic 

for map: #[a 1 b 2] func [key] [print [key map/:key]]							;) map iteration, FP-style, without keys-of allocation
for each [key val] #[a 1 b 2]  [print [key val]]								;) replaces native `foreach` on maps

for image/size func [xy] [if image/:xy = black [print "found!"]]				;) 2D iteration, FP-style
for each xy image/size   [if image/:xy = black [print "found!"]]				;) 2D iteration, idiomatic, replaces `xyloop`

for xy1..xy2 render-cell: func [xy] [render cells/:xy]							;) 2D iteration over a range, FP-style
for each xy xy1..xy2                [render cells/:xy]							;) 2D iteration over a range, idiomatic

for next below this func [face] [if face/focusable? [set-focus face break]]		;) tree iteration - tabbing, FP-style
for each face next below this   [if face/focusable? [set-focus face break]]		;) tree iteration - tabbing, idiomatic

for above this func [node] [either face? node/value [break][invalidate node]]	;) tree iteration - upwards, FP-style
for each node above this   [either face? node/value [break][invalidate node]]	;) tree iteration - upwards, idiomatic
```
Alternatively, `loop` name can be used instead of `for`, but it seems that `for` is more fitting. `loop` reads better as a binary phrase "loop something", while `for` reads better as ternary "for subject do-action" which is the case here. Worse case of `for` is `for n [code]` which we're used to see as `loop n [code]` ("loop N times doing code"). But in other cases `for` seems to win in readability a bit, especially for tree iterators.


### MAP

**Syntax:** `map <series> <function>` (see meanings [above](#syntax))

**Does:** evaluates `<function>` for every item in the series, key in the map, iterator state, value in range, or integer up to limit. When `<function>` is a unary function, it receives this value as argument.

**Returns:** concatenated list of all evaluation results and skipped regions (a block usually).

**Refinements:**
- `/only` - treat lists returned by the `<function>` as single values (otherwise they are spliced)
- `/eval` - reduces lists returned by the `<function>` - an optimization to avoid the allocation stemming from a manual `reduce` call

  This becomes possible as long as returned words are not local to the `<series>` iterator or the `<function>`, but belong to an outer context, e.g. a function making the `map` call.
  
- `/self` - write the result back into original value (series or map only)

  This requires iterator to provide access to the source series/map, e.g. as `iterator/source`, which iterator combinators must also carry over.
  
- `/drop` - if iterator skips a region (due to filtering or a `continue` or `break` call), it is not concatenated as is to the result, but dropped

Because `map` itself doesn't have access to iterators arguments, for `/drop = off` mechanic to work iterators must provide access to the currently locked *range* of their source (may be read as `iterator/locked`), e.g.:
- `each [a b] 5` would lock during each iteration: `1..2`, `3..4`, `5..5` (as `range!`)
- `each [a b c] [1 2 3 4 5 6 7]` would lock: `1..3`, `4..6`, `7..7` (same for maps)

  Another option could be for series to lock a `slice!` of the series, but offsets are more general and reliable than series position, and can point before the head or after the tail of the series, which is necessary for proper handling of regions that do not align with iterator's step size.

When iterator itself throws `continue` (e.g. if it filters out a big range), it must set `/locked` to the whole skipped range. Range can be much bigger than the iteration step, which esp. makes sense on a `hash!` where O(1) far lookups are possible and iteration step by step would slow the process down a lot.

When `break` occurs inside `<function>`, `map` must know what all the remaining unprocessed source regions are, to be able to include them into the result. Since only the iterator knows that, it must expose a method (e.g. `iterator/break`) that:
- when possible, sets `/locked` to the remaining range and throws a `break`
- when impossible (e.g. remaining range is not contiguous), it sets `/locked` to the next part of the source and throws `/continue` (`map` then repeats calling `iterator/break` until it throws a `break` signalling the last region)

  This will very rarely be needed but should provide flexibility enough to support sparse or randomized iteration. Of course API may be more involved, I'm just drafting what seems a minimal solution.

**Examples:**
```
map      #[a 1 b 2] :to-string									;) convert all map keys and values into strings => #["a" "1" "b" "2"]
map      each [x [integer!]] [a 1 b c d 2] [x + 2]				;) offset integers => [a 3 b c d 4]
map/drop each [x [integer!]] [a 1 b c d 2] [x + 2]				;) offset and keep integers only => [3 4]
map      each x [2 7 11 23 41] [either x = 23 [break][x + 2]]	;) offset until 23 is found => [4 9 13 23 41]
map/self each x s: [2 7 11 23 41] .. skip s 3 [x + 2]			;) ditto, but in place, using a slice
map      each [x y] [1 2 3 4 5 6] [x by y]						;) fold pairs => [1x2 3x4 5x6]
map/eval each [x y] [1 2 3 4 5 6] [[y x]]						;) swap values => [2 1 4 3 6 5]
map      each x [[1 2] [3 4] [5]] [x]							;) flatten a list => [1 2 3 4 5]
map      each node above this [node/value]						;) get values of this and all ancestor nodes
```

### FILTER

Note: `remove` or `keep` names can't be used for this as e.g. `remove each` because they are unary. In my own experience and that of analyzing others' code, I find that cases where we need to remove an item happen as frequent as cases where we need to keep an item. So there's *no preference* on whether we filter *in or out* by default. `filter` name implies *yes = keep*, *no = discard*.

**Syntax:** `filter <series> <function>` (see meanings [above](#syntax))

**Does:** evaluates `<function>` for every item in the series, key in the map, iterator state, value in range, or integer up to limit. When `<function>` is a unary function, it receives this value as argument.

**Returns:** concatenation of ranges where evaluation resulted in a truthy value.

**Refinements:**
- `/drop` - if iterator skips a region (due to filtering or a `continue` or `break` call), it is not concatenated as is to the result, but dropped
- `/self` - write the result back into original value (series or map only)

  Though we could imply `/self` and just use `copy` when we want, the name `filter` is not usually associated with modification, so if we use it, I think we should make it copy by default and support `/self`. Unless there's a better (binary) name that implies modification?

**Examples:**
```
filter             [a 1 b c d 2] :integer?							;) copy out all integers, FP-style => [1 2]
filter      each x [a 1 b c d 2] [integer? x]						;) ditto, idiomatic
filter             spec-of :fn :all-word?							;) get all words in a function spec
filter      each w words [find/match form w prefix]					;) keep only words starting with a given prefix
filter/self each [canvas frame] frames [is-fresh? frame]			;) remove old entries from the cached frames map
filter      each [key val1] set1 [val1 <> select/skip set2 key 2]	;) exclude from a copy of set1 pairs found in set2
filter/self each [key [issue!] val] xml [no]						;) remove attributes from an XML block
filter      each node above this [face? node/value]					;) keeps all parent faces
```

**Another option** is for `filter` to accept an iterator and return a new iterator that only yields values that pass the filter condition. Then to receive a block result one would call `list filter ...`. Generally `filter` is used rarely compared to `for` and `map`, so it doesn't matter much which option we choose.

Other possible candidates for such filtering iterator combinator are:
- `if`, since `if` is already binary: `list if <iterator> <condition>`. However, this goes against the fact that iterator is truthy, and `if <iterator>` should normally just evaluate the following block
- `when` (which I'm using similarly to `if` but returning an empty block on failure): `list when <iterator> <condition>`. E.g. `list when each w words [find/match form w prefix]`. But it's kind of backwards.
- `list when <condition> <iterator>` is forwards, but `list when [find/match form w prefix] each w words` puts the code block before the iterator, and uses the word `w` set later by the iterator. And condition is a block, not a plain expression. But it aligns with the `while <condition> <iterator>` idea.
- `list select <iterator> <condition>` or `list pick <iterator> <condition>`? E.g. `list select each w words [find/match form w prefix]` but `select`'s refinements do not make sense for an iterator, and block for other series doesn't make sense either, so not a good fit.


### LIST

**Syntax:** `list <iterator>`

**Does:** lists all values returned by the iterator in a block.

**Returns:** resulting block.

**Refinements:** none.

**Examples:**
```
list 2..5												;) range expansion => [2 3 4 5]
list 5..2												;) step for numeric ranges is always 1, so => []
list reverse 5..2										;) reverse 5..2 = 2..5, so => [2 3 4 5]
reverse list 2..5										;) => [5 4 3 2]
list reverse tail each _ 2..5							;) reversing the iterator itself => [5 4 3 2]
list 3x3												;) 2D range expansion: [1x1 2x1 3x1 1x2 2x2 3x2 1x3 2x3 3x3]
list 1x1..3x3											;) ditto
list next above this									;) get all node ancestors
list while [x/value/type <> 'window] each x above this	;) list faces of node and its ancestors parents until window is reached
list each [_ [integer!]] [a 1 b c d 2]					;) extract integers => [1 2]
```

### EACH

**Syntax:**
- `each <spec> <series>` - acts similarly to the extended `*each` loops
- `each <word> <series>` - acts similarly to the extended `*each` loops
- `each <word> <iterator>` - acts as an iterator combinator

Where:
* `<spec>` is a word, set-word, or a [block spec in extended `*each` format](https://codeberg.org/hiiamboris/red-common/src/commit/efd38a5f7354c57b2b4aa8d860e4ea1f093466e6/foreach-design.md#spec)
* `<word>` is a word or set-word
* see the meaning of `<series>` [above](#syntax)

**Does:** creates an iterator that traverses `<series>` and sets values in the `<spec>` to the nearest values in the `<series>`.

When used as an iterator combinator, it sets given word to the value returned by the original iterator. While it technically can support multiple values in its `<spec>`, it doesn't look useful, as the source iterator doesn't have access to this `<spec>` and cannot know the length of it. Hence, I think only a `<word>` should be supported in this role.

**Returns:** an `iterator!` value.

**Refinements:**
* `/case` - when value filters are in the spec, they are matched strictly
* `/same` - when value filters are in the spec, they are matched for sameness

**Examples:**
```
each      [_ [integer!]] [a 1 b c d 2]					;) iterator over integers => [1] [2]
each/case [i w ('X)] [1 x 2 X 3 x 4 x 5 X]				;) iterator over big Xs => [2 X] [5 X]
each      x 3											;) iterator over a 1D range => [1] [2] [3]
each      xy 2x2										;) iterator over a 2D range => [1x1] [2x1] [1x2] [2x2]
each      x (s: "abcd")..(skip s 3)						;) iterator over a series slice => "a" "b" "c"
each      node after this								;) adds name 'node' to nodes returned by the 'after' iterator
```

### EVERY

A `forall`-like iterator. Nearly useless in presence of `map`, and is only good when parsing a series with varying step but `parse`/`forparse` is not a good option for some reason.

**Syntax:** `every <word> <series>`

Where:
* `<word>` is a word or set-word
* see the meaning of `<series>` [above](#syntax)

**Does:** creates an iterator that traverses `<series>` and sets `<word>` to every location in the series, until reaching its tail.

**Returns:** an `iterator!` value.

**Refinements:** none.

**Examples:**
```
every xs [1 2 3]									;) => [1 2 3] [2 3] [3] 
```

### STEP

An extension of the default iteration over ranges, with a user-specified step. Should be a rare need (never used it myself personally).

**Syntax:** `step <word> <range> <bump>`

Where:
* `<word>` is a word or set-word
* `<range>` is a range or slice (a special case of a range); could be 2D or 3D

**Does:** creates an iterator that traverses `<range>` and sets `<word>` to every location in it, until getting out of the range. Initial value is `range/1` (or *zero* when it's not a range), then it is increased by `<bump>` every time. End condition is:
- for 1D ranges: when point is strictly outside `<range>` bounds
- for 2D ranges: when point is strictly outside the box `<range>` describes
- for 3D ranges: when point is strictly outside the cube `<range>` describes
  
Unlike `each xy 2D-range`, `step` does not apply any carriage-return-like effect to the point (I don't know why anyone would want to iterate e.g. over each 7th pixel in an image), so `step` is good for traversing 2D/3D ranges in a straight line. E.g. `each 2x2 => [1x1 2x1 1x2 2x2]` but `step 1x1..2x2 1x0 => [1x1 2x1]` and `step 1x1..2x2 1x1 => [1x1 2x2]`.

`step word start..end bump` is equivalent to `iterate [set word start] [(get word) inside? start..end] [set word add get word bump]` (uugh that's ugly!).

**Returns:** an `iterator!` value.

**Refinements:** none.

**Examples:**
```
step xy 1x1..2x2 1x0							;) => 1x1 2x1
step xy 1x1..2x2 1x1							;) => 1x1 2x2 
step i 5 2										;) starts at zero! => 0 2 4 
step i -5 -2									;) starts at zero! => 0 -2 -4 
step xy 2x2 1x1									;) starts at zero! => 0x0 1x1 2x2 
step xy -2x-2 -1x-1								;) starts at zero! => 0x0 -1x-1 -2x-2 
step xyz (2,-2,-2)..(-2,2,2) (-1.5,1.5,1.5) 	;) a 3D line => (2,-2,-2) (0.5,-0.5,-0.5) (-1,1,1)
step pos (next s)..(back tail s) 1				;) stepping over a series slice
```

### ITERATE

A `cfor`-like general iterator. Usually a very ugly and very rare need. But may still be more readable than `while` loop when some kind of counter is used in it. 

**Syntax:** `iterate <init> <test> <bump>`

Where:
* `<init>` is a block to evaluate before the first iteration
* `<test>` is a block to evaluate before every iteration; if it fails the loop ends
* `<bump>` is a block to evaluate after every iteration

**Does:** creates a general low-level iterator similar to `for` in the C language.
  
**Returns:** an `iterator!` value.

**Refinements:** none.

**Examples:**
```
iterate [x: 2] [x <= 5] [x: x + 1]						;) x = 2 3 4 5
iterate [xy: 0x0] [xy inside? 5x5] [xy: xy + 1x1]		;) xy = 0x0 1x1 2x2 3x3 4x4 (strict comparison rules out 5x5)
```

### ABOVE

**Syntax:** `above <node>`

Where: `<node>` is a [node!](https://github.com/red/red/wiki/%5BPROP%5D-Node!-datatype#implementation-options) value

**Does:** creates an iterator that traverses the graph in the ['above' direction](https://github.com/red/red/wiki/%5BPROP%5D-Node!-datatype#iteration); first iteration starts with the provided node.

**Returns:** an `iterator!` value.

**Refinements:** none.

**Examples:**
```
list above node											;) list node and all of its ancestors
list next above this									;) list only ancestors
for each node above this [...]							;) work with this and all ancestor nodes 
filter each node above this [face? node/value]			;) keeps all parent faces
```

### BELOW

**Syntax:** `below <node>`

Where: `<node>` is a [node!](https://github.com/red/red/wiki/%5BPROP%5D-Node!-datatype#implementation-options) value

**Does:** creates an iterator that traverses the graph in the ['below' direction](https://github.com/red/red/wiki/%5BPROP%5D-Node!-datatype#iteration), also known as depth-first traversal; first iteration starts with the provided node.

**Returns:** an `iterator!` value.

**Refinements:** none.

**Examples:**
```
list below this										;) get all nodes in the subtree, in a depth-first order
for each node next below this [...]					;) forward tabbing iteration on a face tree
for each node next reverse below this [...]			;) backward tabbing iteration on a face tree
```


### AFTER

**Syntax:** `after <node>`

Where: `<node>` is a [node!](https://github.com/red/red/wiki/%5BPROP%5D-Node!-datatype#implementation-options) value

**Does:** creates an iterator that traverses the graph in the ['after' direction](https://github.com/red/red/wiki/%5BPROP%5D-Node!-datatype#iteration), also known as breadth-first traversal; first iteration starts with the provided node.

**Returns:** an `iterator!` value.

**Refinements:** none.

**Examples:**
```
list after this										;) get all nodes in the subtree, in a breadth-first order
for each node after this [...]						;) breadth-first iteration
```


### BEFORE

**Syntax:** `before <node>`

Where: `<node>` is a [node!](https://github.com/red/red/wiki/%5BPROP%5D-Node!-datatype#implementation-options) value

**Does:** creates an iterator that traverses the graph in the ['before' direction](https://github.com/red/red/wiki/%5BPROP%5D-Node!-datatype#iteration), also known as breadth-first traversal; first iteration starts with the provided node.

**Returns:** an `iterator!` value.

**Refinements:** none.

**Examples:**
```
list before this									;) get all nodes in the subtree, in a breadth-first order
for each node before this [...]						;) breadth-first iteration
```


### REVERSE

An iterator combinator that reverses the iteration direction.

**Syntax:** `reverse <iterator>`

**Does:** creates a copy of iterator with its `/step` negated.

**Returns:** a new iterator.

**Refinements:** none.

**Examples:**
```
reverse below this									;) turns forward tabbing into backward tabbing direction
reverse tail each x 2..5							;) a reversed range iterator => 5 4 3 2
```

For this to work, iterators must support an integer `/step` setting, which should usually be `1` by default, except for `each` iterator where it's equal to its spec length. An iterator may not support step reversal, in which case `reverse` call should result in an error.


### RANDOM

An iterator combinator that shuffles the iteration order.

**Syntax:** `random <iterator>`

**Does:** creates a copy of iterator with its return values shuffled.

**Returns:** a new iterator.

**Refinements:** none.

**Examples:**
```
random each x 2..5									;) => e.g. 3 4 2 5
```

I'm not sure if it is useful in practice, and it certainly isn't going to be easy to implement without first fetching and fixing all the nodes of its source iterator. But it is certainly useful as a thought experiment. E.g. it helped inform how `map` could work with iterators that are not contiguous.


### NEXT

Skips next returned value by the iterator.

**Syntax:** `next <iterator>`

**Does:** advances iterator's offset one step after the current value.

**Returns:** a new cell pointing to the same iterator.

**Refinements:** none.

**Examples:**
```
next above node									;) skips the 'node', lists only ancestors
next each x s..e								;) range iteration without the starting value
```

### BACK

Inserts previous iterator's value back into the queue.

**Syntax:** `back <iterator>`

**Does:** advances iterator's offset one step before the current value.

**Returns:** a new cell pointing to the same iterator.

**Refinements:** none.

**Examples:**
```
back next each x s..e							;) `back` undoes what `next` made
back each x s..e								;) `back` should do nothing, similar to how it works on series 
back above node									;) steps once in the 'reverse above' direction
```

Similarly to `reverse`, may not be supported by some iterators, in which case should result in an error. E.g. in a stream that discards processed values.


### HEAD

Inserts *all* previous iterator's values back into the queue.

**Syntax:** `head <iterator>`

**Does:** moves iterator's offset back to a point where no `back iterator` is possible anymore.

**Returns:** a new cell pointing to the same iterator.

**Refinements:** none.

**Examples:**
```
head next next each x s..e						;) `head` undoes what `next next` made
head each x s..e								;) `head` should do nothing, already at head
head below node									;) jumps to before the tree root
```

Similarly to `back`, may not be supported by some iterators, in which case should result in an error. E.g. in a stream that discards processed values.


### TAIL

Skips *all* iterator's values until there are no more.

**Syntax:** `tail <iterator>`

**Does:** moves iterator's offset forth to a point where no `next iterator` is possible anymore.

**Returns:** a new cell pointing to the same iterator.

**Refinements:** none.

**Examples:**
```
back tail each x s..e							;) => only the last value 'e'
tail above node									;) jumps to before the tree root
```

Similarly to `back`, may not be supported by some iterators, in which case should result in an error. E.g. in a stream that discards processed values.


### TAIL? (and EMPTY?)

**Syntax:** `tail? <iterator>`

**Does:** tests if iterator cannot yield a new value. 

**Returns:** a `logic!` value.

**Refinements:** none.

**Examples:**
```
tail? tail each x s..e							;) => true by definition
tail? each x 5..2								;) => true, because the range is empty
tail? above node								;) => always false 
tail? next above node							;) => true only if 'node' is last in the 'above' order 
```


### HEAD?

**Syntax:** `head? <iterator>`

**Does:** tests if iterator cannot go `back` anymore. 

**Returns:** a `logic!` value.

**Refinements:** none.

**Examples:**
```
head? head each x s..e							;) => true by definition
head? each x 2..5								;) => true, because at head
head? each x 5..2								;) => true, because the range is empty
head? below node								;) => true only if 'node' is tree root
```

For iterators that do not support `back`, it should probably always return `true`.


### REDUCE

**Syntax:** `reduce <iterator>`

**Does:** wraps original iterator's *values* into a `reduce` call. 

**Returns:** a new iterator.

**Refinements:** none.

**Examples:**
```
list reduce each [x y] [a 1 b 2 c 3] [[y x]]		;) => [[1 a] [2 b] [3 c]]
```
Just a wild idea. Probably not useful in practice, since unlike `map/eval` it implies allocation on every iteration.


### COPY

Just copies the `iterator!` value.

See also [node! proposal](https://github.com/red/red/wiki/%5BPROP%5D-Node!-datatype#copying) on thoughts how to copy a set of nodes.


### GET

Primary interface how to get a value from the iterator.

**Syntax:** `get <iterator>`

**Does:** returns the iterator's current *value*. 

**Examples:**
```
get each [x y] [a b c d]							;) => [a b] (as a slice!)
get next each [x y] [a b c d]						;) => [c d]
get each x 2..5										;) => 2
get next each x 2..5								;) => 3
get next next each x 2..5							;) => 4
get next next next each x 2..5						;) => 5
get next next next next each x 2..5					;) => none or unset (error without /any)
```
Another option could be an `iterator/value` accessor. But it seems that `get` fits the purpose well.


### Iterators API

- `get <iterator>` or `iterator/value` (read-only) - current value of the iterator, or none/unset if it's empty.
- `iterator/source` (read-only) - iterator's source (series, map, range, integer, pair, node). 
- `iterator/locked [range!]` (read-only) - currently locked source range, esp. useful for `map`. On trees the item counter may start at `0` and then increase with `next` and decrease (even into negative values) with `back`, and `/locked` return `counter x counter` (region of a single node). Or on trees it could simply return a `node..node` range, without any numeric meaning.
- `iterator/step [integer!]` (read/write, default: 1) - iteration step (how many source items to skip for series, map, range, etc.). Useful for direction reversal mainly.
- `iterator/break` (read-only) - function/native mainly useful for `map` (see description [there](#map))

**Examples:**
```
it: each [x y] [a b c d]
get it												;) => [a b] (a slice!)
it/source											;) => [a b c d] (the original series)
it/locked											;) => 1..2 (a range!)
it/step												;) => 2

it: reverse tail it
it/step												;) => -2
it/source											;) => [a b c d]
get it												;) => []
it/locked											;) => 5..4 (an empty range!)

it: next it
get it												;) => [c d]
it/locked											;) => 3..4
```  


## Implementation

I propose the following internal structure for the `iterator!` value (using current 32-bit model):
- `header` (32)
- iteration `offset` (32), changed with every iteration - meaning depends on the iteration source:
  - series or map offset (esp. useful for filtered iteration) when iterating over series
  - range offset when iterating over ranges
  - node reference when iterating over graphs
- `actions` context node (32) - static contexts for internal iterators, user defined objects for user-defined iterators
- `configuration` reference node (32) - created on iterator construction; contents is not copied around during iteration, and depends on iterator type, but as an example:
	- data source (series, map, range/slice, limit, parent iterator for iterator combinators) (cell, 128) - common for all iterators
	- step (integer, 32) - common for all iterators
	- spec (word or block) to set (cell, 128) - for `each`, `every`, `step`
	- other iterator-specific precomputed values...

In this model:
- iteration (`next`, `back`) does not require to copy the iterator
- offset is general enough to support all iteration sources (note that proposed [node implementations](https://github.com/red/red/wiki/%5BPROP%5D-Node!-datatype#implementation-options) all allow a 32-bit link to it)
- an integer offset can point before the series head, which is useful for reversed iteration


## User-defined iterators

The idea is that a user should be able to convert a `port!` into an `iterator!`, or maybe `make iterator!` filled with with custom functions. Point is that it should support actions (like get, next, back, reverse, etc).

This is especially valuable on graphs, where iteration order may be fully user-defined for their task.



 