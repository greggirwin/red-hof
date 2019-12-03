# WHILE

I started with WHILE loop as it is the most interesting, because WHILE is used to reinvent something that the language does not easily provide.
Contrary to pretty dumb FOREACH that iterates element-wise, WHILE by itself does not convey any meaning. It is the condition and the code that adds meaning to it. So it is the most diverse of all loops.

## Distribution by condition.

Of around ~200 WHILE loops I analyzed:
- 40% were `while [not empty? series]` (in some cases `series` gets substituted within the loop)
- 20% were `while [find ...]` (mostly `find series item`, rarely `find set series/1` and others)
- 40% everything else

These numbers may be off by 5% or so.. I'm bad at counting things ;)

These numbers may say that we want special constructs for *while-not-empty* and *while-find*, but only at the first sight.
It turns out that *while-not-empty* kind of loop is almost always used to imitate one of `-each` HOFs, and *while-find* usually does the same but also filters incoming data. If we consider any filtering capabilities for our `-each` HOFs, these HOFs should cover the vast majority of applications.

## Distribution by meaning.

- 37% were justified *while* loops (mostly correlates with the "everything else" group above)
- 21% were imitating `foreach` due to it being limited or unavailable
- 17% were imitating `map-each` due to it being unavailable mostly
- 12% were imitating `remove-each` due to it being limited or unavailable
- 7% were crawling up the tree (usually a tree of faces)
- 6% were imitating `for`, `repeat` or `loop`

So, I should say that extending `-each` HOFs functionality should stop people from using WHILE to fight against the language.

## Extensions

This functionality supposedly may include, in the order of importance:
- making index available to `-each` funcs
- preliminary filtering of input data (simple - by value; or advanced - by parse pattern)
- allowing /reverse refinement for `-each` funcs
- introducing `-while` HOFs
- support graphs as input
- support ports as input
- forcing step size to 1, regardless of the spec length

## Examples

Before each snippet of code there are general thoughts and ideas how can it be rewritten.
You are welcome to add your versions, as I am most certainly biased by my own thought patterns ;)

- [FOREACH imitations](while/foreach.md)
- [MAP-EACH imitations](while/map-each.md)
- [REMOVE-EACH imitations](while/remove-each.md)
- [FOR/LOOP/REPEAT imitations](while/for.md)
- [Tree navigation](while/trees.md)
- [True, justified, WHILE loops](while/true-while.md)
- [Unclassified while-find](while/while-find.md)
- [Unclassified while-not-empty](while/while-not-empty.md)
