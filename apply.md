# Apply

## The problem of `apply`

`apply` cannot be a mezz for it must satisfy the following requirements:
- Speed. If it slows down some action twice, it's not gonna be used. Not to mention path construction will slow native calls down 100x-1000x times.
- Double evaluation involved in a `do` call: to avoid it, when constructing a path one has to prefix all arguments with `quote`.

This is also complicated by refinement arguments being `none` when not supplied - while the spec of the function may not accept `none!` at all.
And by spec inconsistencies (e.g. `return:` problem or `/local`s handling).

REBOL provides `/only` refinement to avoid extra evaluation: `/only -- Use arg values as-is, do not reduce the block`
<br>But as always, "only what?". It sounds like a buzzword here, as most widely used `/only` meaning is "treat blocks as single values".
And if the word "only" does not carry any meaning, why not just call it `/x`? At least shorter this way ;)

I propose either:
- `apply/eval` or `apply/reduce` for evaluating version, no refinement otherwise; or
- `apply/as-is` or `apply/quote` for non-evaluating version, no refinement otherwise.

What's the most common use of `apply`? Evaluating or not?


## Use cases

Is there more use cases?

### 1. Function extension

E.g. make one's own action (supporting a new datatype no less!) that - for this particular datatype does it's thing - and for every other just passes the call thru to the native implementation. 1 or 2 refinements can be handled with `either`, anything more - requires path construction.
<br>Here, refinements & argument names are inherited as is.

### 2. Tracing calls

E.g. to know every occasion of `find` call and dump it's arguments before calling it.
<br>Refinements & argument names are inherited again.

### 3. Passing around a set of refinements+arguments

To an extent, similar to (1) in function, if not in meaning.
My CLI is an example: higher-level functions pass their refinement+argument info to lower-level ones to affect their behavior.
<br>Set of supported refinements may vary a lot but share some common parts. In particular, set can hold refinements not known to some of callees.

Problem here to ensure that same refinement has the same arity and meaning in all functions, including same argument names.
Good `apply` implementation could provide some level of defense against such errors.

### 4. Programmatic call construction

E.g. call a func with arguments/refinements known from some data.
One example in CLI: data is command line arguments, a call to Red function should be constructed based on that data.
<br>Refinement and arguments are not (usually) shared between the callee and the caller.
<br>Usually requires spec parsing to ensure that the constructed call is well formed.

Problem here is that Red decomposes that path again into a linear call, mapping every refinement to an index.
An efficient `apply` implementation could leverage type checking but bypass path construction+deconstruction phases.

### Goals

Goal with (1) & (2) is speed and simplicity. A one-liner that pays virtually no performance cost (a chain of such extensions possible).

(3) tries to balance between sharing some state internally and exposing it to the user.
For (4) ideally we'd like to avoid the burdens of spec parsing & path construction.
Key point for these is clean code.


## Approaches


### 1. Positional approach (R2 & R3)

`apply :fun [block]` - where block mirrors spec, for each refinement/argument supplying a value

Flaws:
1. `find` has 16 refinements/arguments. One can win an obfuscation award with a call to it:
<br>`apply :find [series value none none none none none none none none none none none none none yes]` - this *obviously* sets `/match` to true.
2. One has to look up callee's spec every time to find a correspondence between it's arguments and stuff in the block.
3. Refinements are orderless by nature. `[/a x /b]` is the same as `[/b /a x]`. By designing `apply` in a positional way, we will make spec refactoring (or adding new refinements not to the tail) - a dangerous activity that will break someone's code.

Benefits:
1. Performance as it avoids path construction & deconstruction (though on R/S level it matters little)
2. Shorter than other forms when all arguments are specified
3. Required block can be obtained from the function's spec - by removing blocks, changing refinements to words, and then reducing it (still, pretty dumb procedure)


### 2. Bolek's approach

`apply :fun [.. /ref1 arg1 /ref2 arg2]`, e.g. `find/match/part a b c` can be written as `apply :find [a b /part c /match]` or `apply :find [a b /match /part c]`.

Flaws:
- Doesn't fit use cases (1), (2), (3) - one will have to check every refinement's value before deciding to add it or not.

Benefits:
- Most beautiful and concise when used with a literal block - that is manually written

### 3. Variant 1 of Bolek's approach

Using same syntax, treat every `/ref` not as 'true', but get the corresponding word's value:
`apply :find [a b /part c]` would become `find/part a b c` if `part` is true, and `find a b` if it's false.

Flaws:
- Requires one to define words used in the call (e.g. `part: yes`). Not required for use cases (1), (2), (3) - as it's already so - but complicates (4).

Benefits:
- Still beautiful and concise


### 4. Variant 2 of Bolek's approach

After every refinement - add word that holds it's value (true/false):
`apply :find [a b /part part c]` would become `find/part a b c` if `part` is true, and `find a b` if it's false.

Flaws:
- Requires doubling of refinement names in cases (1) & (2). For full `find` spec it will be 11 more words, to a total of 27. At least they are readable ☻


### 5. Key-value approach

Any form of 2-column table (block, object, map): e.g. `apply :find [series: a  value: b  part: yes  length: c  match: yes]`. Block is the fastest and can be obtained from both map and object (when that is required).

Flaws:
- Overly verbose for (1) & (2) cases

Benefits:
- Simple to construct: just throw in a bunch of words and their values
- Table may contain refinements & arguments not used by specific function - `apply` will decide what words to use - ideal for (3)
- Very self-documenting, does not force reader to look the spec up
- Secure against adding new arguments to existing refinements. Renaming of refinement's arguments will cause runtime error - not a bad thing, as that may imply a change in argument's type/meaning.



