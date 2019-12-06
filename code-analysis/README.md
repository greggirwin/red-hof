This is a WIP **analysis** of loop constructs written by various people for various real-world projects in R2, R3 and Red.
It's aim is to provide a solid ground for **decision making** about what kind of **HOFs design** should Red follow,
to find out where design's theoretical beauty becomes clumsiness in practice,
and where is the balance between HOFs internal complexity and that of users code.

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

**So far**, I've analyzed the WHILE, UNTIL and FOREACH loops. I tried not to include any duplicates or very similar constructs, but some may have slipped through.

See the respective pages: [WHILE](while/README.md), [UNTIL](until/README.md), [FOREACH](foreach/README.md). 

FOREACH is the basis of all `-each` funcs. As I expected, slightly over 50% of FOREACHs are imitating MAP-EACH. 
Partly because virtually every COLLECT is `collect [foreach [keep...]]` and that is MAP-EACH by very definition.
Note also that REMOVE-EACH is only a special case of MAP-EACH, and it's quite unfair to have the former but not the latter.

I expect FORALL to be 95% obsoleted by adding index support to FOREACH.

An interesting observation I made during this analysis is that I also reinvented some constructs, while not realizing it.
It seems we are so getting caught in existing designs that we miss the opportunity to look at a different angle.
Partly, I expect, because we're usually thinking of the task rather than on choice of approach to it.

**Proposed designs** and their coverage:

*TO BE FILLED...*
