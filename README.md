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


# Standard HOFs

- map              one result for each value
- filter/partition up to one result for each value, but may be less
- accumulate/fold  one aggregate result

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

## *-each

## *-while

## collect-*

## min/max


## aggregators

Stateful aggregators take a "stream" of inputs. Even if not a stream in
the sense of continuous inputs. It's the idea that the inputs are not
all known when the aggregator is created, may come at any time, and be
infinite in number. You should be able to read the state, based on 
inputs seen so far, and even reactively connect that to other aggregators
or functions/consumers (see functional reactive programming). 

