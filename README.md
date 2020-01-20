# red-hof

Red Higher Order Function Design Experiments

# Introduction

Higher-order functions do at least one of the following:

- Take one or more functions as arguments
- Return a function as a result

In Red, we have the `*-each` model, which lets you use a body block
without having to define a function. This is more idiomatic, but 
can't be compiled, where functions can. Hence, there will be a
performance hit.

# Overview

(Note: Gregg's code is really old in many cases. Some is *really*
experimental and thinking out loud.)



# Use Cases

- Spreadsheets/Dataflow
- Data Science
- FP
- FRP

For Red programmers we may think of the basic functions, and 
next the FP use cases. FRP moves up the abstraction ladder a
bit, in how it's been marketed, but the real value comes at
the highest levels: spreadsheets and data science. This applies
to aspects of time series and column store data models as well.


## Basic versus advanced

I like simple solutions for simple needs. e.g. the current `sum`
and `average` funcs in Red (mezzanines) are just fine for most
things. But a more extensible model may prove useful, given the
right interface. The target audience is key to driving the design.

## Flat lists

## Tree/graph processing

## Aggregators

There is an older use case that drove aggregators for me, as an
experiment: DTrace. The ability to collect a lot of information
efficiently, which can then be queried, in the context of long-
running data acquisition, rather than an on-demand calc. That is,
if you have millions of data points, func calls, profiling info,
etc. but only care about the final result, you don't need to 
store every data point and calc when queried.


# Standard HOFs

- map/transform      one result for each value
- filter/partition   up to one result for each value, but may be less
- accumulate/fold    one aggregate result

`Map` is a tricky name, since we have a `map!` type.

I like `partition` as a name, but it may mean a performance hit if
the implementation is kept simple.


# Goals and Design Decisions

Two important elements that affect the design, and may be leveraged or 
impose constraints are free ranging evaluation and the ability to use
body blocks as other langs use anonymous functions. An example of the
latter is `remove-each`. This can simplify both writing and reading
(understanding) code, and is more idiomatic in Red. But we're aware
that many people may want a more traditional functional approach as
well.

Common functions built on HOFs may also be included, and may use direct
implementations if they are simple enough. For example, `count` is a
very simple aggregator.

Red does not have tail call optimization, so recursion probably won't
be used in implementations. 

## General dialect thoughts

I (Gregg) haven't gone down a particular path yet, but want to. That
path being the same that led to `round`, Rebol's `split`, and the new
`loop` proposal. What you have in those ideas is a single entry point
to a domain. It works well in my mind, but is quite different from
having many single-purpose functions. 

There are two ways to address that: split functionality internally,
exposing targeted funcs; or wrap the dialected func. e.g. `ceil`
wraps `round/ceiling`. With `round`, the original mezz implementation
was tiny, and handled all types, so splitting didn't make sense. With
`split` I can see delegating based on the input spec as a possibility.

How that applies to HOFs I don't know yet. I don't think there's a
`HOF` generic entry point, but maybe there is.



# Contexts and Functions

## map

## accumulate/fold/reduce

## filter

The name `filter` is ambiguous, like `pad`. Does it filter *in* or 
filter *out* items that pass the test? An option is to have it return
2 blocks, which is also called `partition`, and may be generalized to
more than a single predicate test. If you only want matching items, it
wastes performance collecting things that don't match, and just throwing
them away.

## *-each / *-all

e.g. `change-each`

## *-while

e.g. `take-while`

## collect-*

## count


## min/max (find/pick/take + /part)

`/part` needs to have standard meaning, but then what do you call the
refinement that lets you "take the 3 highest values"? Or is the 
multi/count part another HOF? You could do the same thing with `collect`
which maps to the concept of `parse` min/max counts (different from
min/max value in a series).


## aggregators

Stateful aggregators take a "stream" of inputs. Even if not a stream in
the sense of continuous inputs. It's the idea that the inputs are not
all known when the aggregator is created, may come at any time, and be
infinite in number. You should be able to read the state, based on 
inputs seen so far, and even reactively connect that to other aggregators
or functions/consumers (see functional reactive programming). 

Aggregated partitioning is something to consider.

## apply 

See [`apply.md`](apply.md)
