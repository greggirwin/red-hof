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

## More

See also the [Revault page](https://github.com/revault/rebol-wiki/wiki/Apply) by Chris Ross-Gill. It concentrates on goal (4) and approach 1. Nice argument there about possible error messages. I suggest we should support both passing function by name (word/path) and by value. Name will enhance error reports, while value will allow to call `apply` where only the value is available. Note that we can't use function literals to construct paths, so `apply` will be the only way to specify refinements to a function known by value.


# Gregg's Review Notes

`Apply` is an advanced function, but some of the interface choices may make
it tricky to use and reason about at call sites. Overall, it's a clean,
concise implementation.


- @hiiamboris thinks a mezz version won't work, but I think we just need to
note the limitations. As long as we don't break the interface, or even if
we learn we need to, it can be optimized later, and we can say that control
flow changes (break, return, exit) are not supported at this time. We want
`apply` soon, for other work in Q4 2021, which will also provide real world
use cases to evaluate its design.

- Boris' design uses a lit-arg for the first param for the use case of making
clean ops out of it. The chat shows we discussed the tradeoffs on this quite
a bit. No easy answer.

- `Apply` args are *not* treated literally by default, and `/verb` ("verbatim", to treat
them literally) has the opposite meaning in my mind. "Verb" means action, but here it
means "literal" or "don't evaluate". Since we *don't* know which will be the
more common case for args, and it may be split closely, how do we pick the
default behavior? There are pros and cons to both sides. Having users `reduce`
the args is more overhead, but block args are not normally evaluated elsewhere
in Red. But we can also argue that `apply` args are dialected in some sense
and therefore *are* evaluated in some special way. This is true to the extent
that the current implementation lets you chain set-words, making the args
*not* a pure key-value structure.

- For arg contexts, the word "local" has a very strong meaning which threw
me off in the example. My gut says to have the user use `context?` explicitly
in v1 and see what feedback we get.

- I wonder if there's a better word than `apply`. It has historical meaning
for functional folks, but "function application" isn't as human friendly
as thinking "call with args". PHP calls it `call_user_func_array`, and R 
calls it `do.call`. We already have `call` which is single arity, otherwise
it could work for this. But it also has a lot of refinements related to
shell commands, which don't apply in this context. Renaming `call` to
something like `syscall` is possible, but that specific name isn't great, as
it has a strong and clear meaning at lower levels. `call-OS` or `OS-call` is
in the right vein, but aren't great to me at a glance. We still have some
confusion at times, in the community, about `do` not evaluating functions,
but returning them. `Do-call` or `do-func`?


## Chat between Boris and Gregg

https://gitlab.com/hiiamboris/red-mezz-warehouse/-/blob/master/new-apply.red

What I (Boris) want from Nenad is ability to call functions efficiently
on R/S level using this design. Right now it's not possible

Gregg Irwin @greggirwin 12:37

The R/S aspect is separate, and likely not quick and easy. If the
interface doesn't change, that can be a later optimization, correct? We
should note that for him, if it isn't already. I will review and ping
him on it.

hiiamboris @hiiamboris 12:37

in short:

- apply I must be able to walk through function spec and set each argument
from the context given
- apply II must be able (to do the opposite) to walk through it's given
set-words, lookup each set-word into function argument offset (as O(1))
and set that argument before calling the func

But while working on #4854
we were talking about it and it was clear that one of the reasons apply
is still not there is because interpreter wasn't implemented to support
these ways of calling funcs and he seemingly agreed to consider it while
working on #4854 (because it needs partial rewrite of interpreter
anyway)

It can be later optimization, true

As much as I hate not having fast apply, I hate not having any apply even
more :D

Gregg Irwin @greggirwin 12:47

> apply name form is chosen over apply 'name because if we make operator
out of apply it will look better:

This is a tradeoff. Yes, if you make it an op! it's cleaner, but it also
complicates passing something other than a literal, and hides the detail
that the arg is treated literally; the latter being more important IMO.

You can always make a literal op version on top of the non-literal
foundation if so desired.

hiiamboris @hiiamboris 12:49

But it's so clean written in this way:
```
    my-func => [x: 1 y: 2 s: "abc"]
```
why it complicates passing something other than a literal?

I agree it's a tradeoff, but what do I sacrifice?

- functions that return function values: `apply (get-func 'abc) [x: 1 y: 2]`
- functions defined in line: `apply (func [x][x + 1]) [x: 100]`

both scenarios are rare and advanced

Another consideration for this, I didn't found proper words previously...
remember how Gab calls functions in Topaz?
```
if 3+ args, the call becomes:
my-func [
  arg1: value
  arg2: value
  arg3: value
  ...
]
```
something Galen ran into recently

I kinda like that with literal syntax we get this form out of the box:
```
apply my-func [
  arg1: value
  arg2: value
  arg3: value
  ...
]
```
which is tiny thing when we have a few apply calls scattered around, but
if we consider the possibility of writing our code in the following
manner where it's appropriate, `apply fn` becomes preferable to `apply 'fn`
(too many lit-words = visual clutter)

so, yeah, I understand the risk, but I also value code aesthetic enough to prefer this ;)

Gregg Irwin @greggirwin 13:02
```
    >> fn: 'append
    == append
    >> help fn
    FN is a word! value: append
```
Words are normally evaluated. Literal args are the very rare exception,
and mainly only for console use. So you then have to know to use another
construct, e.g. get-word or paren, when making the call.

In this case, it's interesting, because the args are not treated
literally by default, but you can force that. On that subject /verb has
an opposite meaning in my mind. "Verb" means action, but here it means
"literal".

I'll have to look at Topaz again for his func call syntax.

All apply use cases are advanced. :^)

I'm not convinced that, universally, ops are clearer. They are not words
and, while shorter, they are noisier in that sense. Here the meaning of
"send the function these args" is a good match for the arrow pattern,
but I'm also wondering if there's a better word than apply. It has
historical meaning for functional folks, but "function application"
isn't as human friendly as thinking "call with args".

hiiamboris @hiiamboris 13:02

help (fn) ;)

Gregg Irwin @greggirwin 13:04

That's what I said:

So you then have to know to use another construct, e.g. get-word or
paren, when making the call.

hiiamboris @hiiamboris 13:04

right ;)
sure, I considered all this

Gregg Irwin @greggirwin 13:10

The great thing about aesthetic judgements is how personal and
subjective they are. Hence, the need for Ye Evidence Oriented Language
Design Environment (Ye Olde ...).

hiiamboris @hiiamboris 13:11
:D
we can attach a poll to the PR ;)

Gregg Irwin @greggirwin 13:14

I'll add my review comments to %apply.md.

hiiamboris @hiiamboris 13:28

sure, PR it

Gregg Irwin @greggirwin 13:48

Do you have examples where you use apply ... <word!> in your other code?
The word "local" has a very strong meaning which threw me off in the
example. My gut says to have the user use context? explicitly in v1 and
see what feedback we get.

hiiamboris @hiiamboris 14:03

why complicate things? we're supposed to simplify them ;)

word 'local is the most readable and intent-clarifying IMO

when there are no locals, it's worse: `f: func [x][apply g 'x]` is fine,
but `f: func [x y z][apply g 'x]` is less clear than if we wrote `apply g
'local`.

Gregg Irwin @greggirwin 14:07

I don't see it as a complication, or I wouldn't suggest it. It makes
something explicit, which is otherwise implicit. Remember that you wrote
it, so it's always going to be clear to you. :^)

hiiamboris @hiiamboris 14:10

`bind 'x 'local` is also clear to me ;) and `to value other-value` ;)

I expect ~80% such cases to use 'local, other 10% to use another word as
local may be absent of not known if it's present or not (case when you
copy the spec from another func), and another 10% use a word from some
context(object) or from outer function less clutter = cleaner code

besides, apply allows words, not requires them, so you can always write
context? 'local if it makes sense

Gregg Irwin @greggirwin 14:13

Do you have examples where you use apply ... <word!> in your other code?

hiiamboris @hiiamboris 14:13

I do know of a case yes

I have lots of 'local examples, but one different:
```
; my-find: function spec-of :find [
;     case: yes
;     only: no
;     apply find 'only
; ]
```
as a native it doesn't have /local refinement

