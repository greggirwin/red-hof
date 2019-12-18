This is a WIP **analysis** of loop constructs written by various people for various real-world projects in R2, R3 and Red.
It's aim is to provide a solid ground for **decision making** about what kind of **HOFs design** should Red follow,
to find out where design's theoretical beauty becomes clumsiness in practice,
and where is the balance between HOFs internal complexity and that of users code.

**Navigate**:
- [Data sample](#data-sample)
- [Loop spread](#loop-spread)
- [Loop/Meaning matrix](#loopmeaning-matrix)
  * [Map: in-place vs another target](#map-in-place-vs-another-target)
  * [Index: numeric vs series](#index-numeric-vs-series)
- [Proposed designs and their coverage](#proposed-designs-and-their-coverage)


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

Footnotes:

<sup>1</sup>`total % (rel % on trees, rel % of lookups)`, e.g. `foreach/foreach 44% (6%)` means:
- 44% of all `foreachs` were indeed `foreach`s by meaning
- 6% of those 44% = 2.5% of all `foreach`s - were traversing trees (as `foreach-face` no doubt)

<sup>2</sup>`total % (rel % of in-place)`, e.g. `while/map 17% (56%)` means:
- 17% of all `while` loops were maps by meaning
- 56% of those 17% = 10% of all `while` loops - were in-place maps

<sup>3</sup> accumulators not including map (which is kind of fold too)

<sup>4</sup> spread of filtering of the incoming data, *across all meanings*

### Map: in-place vs another target

Though `foreach` shows only 2% of in-place maps, this is because foreach does not provide the index right now.
Other loops were often used to implement an in-place map, reaching:
- 14% of all maps are in-place maps

### Index: numeric vs series

The following table shows the type of index best suited the needs of the developer, across all loops analyzed:

|           |while|until|loop|map-each|repeat|foreach|forall|total
| :--       | --- | --- | --- | ---   | ---  | ---   | ---  | :--
|as series  |  11 |   8 |  1 |        |      |       |  2   | 22 = 23%
|as integer |  4  |   12|    |    1   |    12|    23 |  13  | 65 = 66%
|both work  |  2  |   6 |    |        |      |    1  |  2   | 11 = 11%

It is clear that **integer** index is **preferred** (outnumbers series 3:1), although maybe we could support both?
- integer index is better at accessing another series: `foreach [i: x y] ser1 [.. ser2/:i ..]`
- series index is better at accessing adjacent items: `foreach [pos: x y] ser [.. pos/-1 .. pos/3 ..]`

These are convertible to one another of course, and are only a matter of convenience.

### Other stats

- 12 examples required `foreach` to advance on demand
- 12 examples required `zip` func as they iterate over 2 or more series in parallel
- 8 examples required `foreach` with step=1 and >1 arguments
- 9 examples required value filter embedded into `foreach`
- 5 examples required type filter embedded into `foreach`
- 2 examples decomposed `foreach` argument into more values with `set`

(`foreach` here also includes `map-each`)

## Proposed designs and their coverage

One of the problems about loops is that they currently have to be implemented in compiler (as so-called 'intrinsics').
It's abilities there are so limited that even checking a counter is a big and tedious task.
Thankfully though, both `foreach` and `remove-each` are compiled as calls to their respective natives: `foreach-next`, `foreach-init`, etc.
So anything doable on R/S level should work.

### Idiomatic block HOFs vs FP-like function HOFs

@dockimbel emphasizes:
> it seems that it would be good to support both block-oriented and function-oriented HOF, and use user-friendly naming (e.g. accumulate) for the former and more common names for the latter (e.g. fold).
> Note that HOF with functions (instead of blocks) can be compiled while block-oriented ones can't (unless we add annotations to let the compiler know that the body block contains code. In tight loops, it can make a significant speed difference.

Another point to consider is laziness: some HOFs may return a stream (as a port for example) with inputs and transformation defined.
This stream may fetch items upon request or even allow modification of the input.
- benefit: requires less RAM as no intermediate series have to be created (esp. when HOFs are stacked one upon another)
- benefit: lookups over streams will make streams process only the part of the data, up to the item looked for
- drawback: should be slower than series iteration

We could make block HOFs eager, and function HOFs lazy. FP addicts should like that ;)

`zip` (over 2+ series) is a particularily good candidate for a stream: not much use in holding the zipped series, usually we will just pass it to foreach.

### Providing an index



### Foreach



### Map-each

### Filter

### Sift

### Part/limit

*TO BE CONTINUED... ;)*


