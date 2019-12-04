# UNTIL

In total 83 UNTIL loops were analyzed, not including duplicates or very similar ones.

## Distribution by meaning

- 48% were justified UNTIL loops
- 23% were imitating FOREACH usually due to it being limited, but sometimes by an oversight
- 16% were implementing TREE traversal (often a faces tree, towards the root)
- 9% were imitating MAP-EACH due to it being unavailable or limited
- 3% were imitating REPEAT or FOR loops, likely by an oversight
- 1% was imitating REMOVE-EACH due to it being limited

UNTIL is not the best fit to imitate `-each` because it evaluates the body at least once, and that usually complicates the loop logic.
It however was used for that, just as WHILE. In some cases traversal is so complex that `-each` can't handle it.
But some examples were found to be bugged - a testimony for the danger of using UNTIL carelessly.
UNTIL's logic is usually hard to read, so bugs are no surprise.

Another downside of UNTIL (and WHILE) here is that it does not add meaning to the operands used: what is `series/1` or `series/3`?
A name is rarely given to these, so one has to look up how the series were constructed to get that info.
Contraty to `-each` funcs that give clear names to the operands, e.g. `foreach [key value]`.

UNTIL fits well into ascending (towards the root) tree traversal, and in absence of dedicated tree iterators is totally justified for that.

But the main place of UNTIL seems to be in event loops, where a flag is waited for.
Cheyenne stands out for it's pragmatic and clean UNTIL loops, none of which can be rewritten better by any other loop construct.

In general, [thoughts on WHILE](../while/README.md) are also applicable to UNTIL.

## Examples

Most interesting examples are in MAP-EACH category I think ;)

- [FOREACH imitations](foreach.md)
- [MAP-EACH imitations](map-each.md)
- [REMOVE-EACH imitations](remove-each.md)
- [FOR/REPEAT imitations](for.md)
- [Tree navigation](trees.md)
- [True, justified, UNTIL loops](true-until.md)
