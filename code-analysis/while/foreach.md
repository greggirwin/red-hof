# FOREACH imitations

- this should be one-liner:
- `not none? find/same/skip queue reduce [reactor :reaction] 4`
- but if we imagine q/3 rather than q/2:
- `foreach [:reactor _ :reaction _] [return yes] no`
- `forparse [reactor skip reaction skip] [return yes] no`
- `foreach [x _ y _ /where all [x = reactor y = :reaction]] [return yes] no`
- `not empty? filter queue [x _ y _] [all [x = reactor y = :reaction]]`
- `not empty? sift queue [1 - - - .. 1 = (reactor) and 3 = (reaction)]`
- `locate queue [[is (reactor)] - [is (reaction)] -]`
```
    pending?: function [reactor [object!] reaction [block! function!]][
        q: queue
        while [q: find/same/skip q reactor 4][
            if same? :q/2 :reaction [return yes]
            q: skip q 4
        ]
        no
    ]
```

---
- searches rows by reactor
- filtered foreach:
- `foreach/same [:reactor word reaction targets] relations [...]`
- `foreach [r word reaction targets /where r =? reactor] relations [...]`
- `foreach [_ word reaction targets] filter relations [r _ _ _] [r =? reactor] [...]`
- `foreach [word reaction targets] sift relations [- 2 3 4 .. 1 =? reactor] [...]`
```
    pos: relations
    while [pos: find/same/skip pos reactor 4][
        reaction: :pos/3
        ... also uses pos/2 and pos/4 ...
        pos: skip pos 4
    ]
```

---
- this should be a `find/same` one-liner, but it's bugged (#4165)
- there's a bug in `reactor = context?` (#4166)
- workarounds:
- `foreach [pos: _ _ reaction :field] [if reactor =? context? :pos/4 [return reaction]]`
- `field: in reactor field  foreach/same [_ _ reaction :field] [return reaction]`
- `field: in reactor field  foreach [_ _ reaction f /where f =? field] [return reaction]`
- `first sift relations [- - 3 - .. 4 =? (in reactor field)]`
- `third locate relations [- - - [same (in reactor field)]]`
```
    pos: skip relations 3
    while [pos: find/skip pos field 4][
        if reactor = context? pos/1 [return pos/-1]
        pos: skip pos 4
    ]
```

---
- same; workarounds:
- `foreach/same [:reactor :field reaction _] [return :reaction]`
- ...
- `first sift relations [- - 3 - .. 1 =? (reactor) and 2 = (field)]`
- `third locate [[is (reactor)] [is (field)] - -]`
```
    pos: relations
    while [pos: find/same/skip pos reactor 4][
        if pos/2 = field [return pos/3]
        pos: skip pos 4
    ]
```

---
- from `check-cfg` of GUI console:
- iter is a block `[set-word: value ...]`
- joins options from config and default config
- it's interesting because it replaces invalid lines, and adds those not found
- a single remove-each won't handle it
- `foreach [word val] [...]` - the best way?
```
    while [not tail? iter][
        either f: find cfg iter/1 [
            if (type? f/2) <> type? iter/2 [
                f/2: iter/2
            ]
        ][
            repend cfg [iter/1 iter/2]
        ]
        iter: skip iter 2
    ]
```

---
- from GUI console `red-complete-path` (internal)
- `foreach [ptr: #"/"] str [...]`
- `foreach word split str "/" [...]`
- `str: ""` can be just `break`
```
    while [ptr: find str #"/"][
        word: attempt [to word! copy/part str ptr]
        if none? word [return result]
        either first? [
            set/any 'w1 get/any word
            first?: no
        ][
            if w1: in :w1 word [set/any 'w1 get/any w1]
        ]
        str: either object? :w1 [next ptr][""]
    ]
```

---
- `foreach/reverse [cmd _] [either find .. [..][break]]`
```
    while [find ["left" "right" "center" "justify"] cmd: pick block-stack -2] [
        stage3 join cmd "." none 
        block-stack: skip block-stack -2
    ] 
```


---
- `foreach with step=1, and 2 items + index known at once, advancing by 1 or 2`
- `foreach/skip [p: x y] spec [... advance ...] 1` -- bad to have skip after code
- `foreach/stride [p: x y] spec [... advance ...]`
- `crawl [p: x y] spec [... advance ...]`
- why `global?` and not `break`?
```
    while [all [global? not tail? spec]][           ;-- process wrapping panel options
        switch/default spec/1 [
            ...
        ][
            either all [word? spec/1 find/skip next system/view/evt-names spec/1 2][
                make-actor panel spec/1 spec/2 spec spec: next spec
            ][
                global?: no
            ]
        ]
        
        if global? [spec: next spec]
    ]
```

---
- foreach with step=1 and 2 items at once
- `foreach/stride [a b] points [...]`
- `crawl [a b] points [...]`
```
    while [1 < length? points][
        either at-distance-from-line? event/offset points/1 points/2 3 [is-within?: true break][points: next points]
    ]
```


---
- foreach with index
- 2 rules are generated in parallel
- `[xxxxx xxxxx ..] -> [xxxxx (m: index?) | ..] and [xxx (m: index?) | ..]`
- `map-each m list [p: ... compose [xxxxx (p) | ]]`
- `map-each m list [p: ... compose [xxx (p) | ]]`
- can we make it simple in one go? should we?
- using morph DSL: `morph [:list m (i: index? list) month: m i pipe (m': copy/part m 3) mon: m' i pipe]` - roughly the whole loop
```
    list: system/locale/months
    while [not tail? list][
        append month-rule list/1
        append/only month-rule p: copy quote (m: ?)
        unless tail? next list [append month-rule '|]
        p/2: index? list
        append mon-rule copy/part list/1 3
        append/only mon-rule p
        unless tail? next list [append mon-rule '|]
        list: next list
    ]
```

---
- `foreach item args [...]`
- `foreach item sift args [any-word! and not set-word! or refinement!] [..]` -- prefiltered
```
    while [not tail? args] [
        item: first args 

        if :item = /local [break] 
        if any [all [any-word? :item not set-word? :item] refinement? :item] [
            prin append mold :item " " 
            if op? :value [prin append uppercase mold word " " value: none]
        ] 

        args: next args
    ] 
```

---
- foreach with known index, very inefficient
- `foreach [values: value] values [...]`
```
    while [value: take lengths][
        value: compose [(value)]
        case [
            not find values 'width [set 'width value]
            not find values 'height [set 'height value]
        ]
    ]
    while [value: take colors][
        value: compose [(value)]
        case [
            not find values 'color [set 'color value]
            not find values 'background-color [set 'background-color value]
        ]
    ]
```


---
- `foreach item specs`
- should stop on 1st set-word:
- `foreach item parse specs [collect any [not set-word! | keep skip]] [...]`
- `foreach item keep-while x specs [not set-word? :x] [...]`
- `foreach/while item specs [...] [not set-word? :item]`
- `foreach item some specs [not set-word! skip] [...]`
```
    while [not tail? specs] [
        item: first specs 
        if set-word? :item [break] 

        either word? :item [
            if any [find vid-words item find styles item] [break] 
            facets: insert facets either any [
                all [words find words item] 
                all [find facet-words item]
            ] [to-lit-word item] [item]
        ] [
            facets: insert/only facets :item
        ] 

        specs: next specs
    ] 
```


---
- `foreach event port`
```
    while [event: pick port 1] [
        either all [
            in compressed-events event/type 
            last-type = event/type
        ] [
            change back tail events event
        ] [
            last-type: event/type 
            insert tail events event
        ]
    ] 
```
---
- reads from open/lines port
- foreach should take care of this
```
    while [not tail? sub-port][
        data: insert*/only data load first sub-port
        sub-port: next sub-port
    ]
```

---
- `foreach x file [..]`
```
    file: split-full-path file
    while [all [
        not tail? file
        heap: select* heap first file
    ]][
        file: next file
    ]
```

---
- foreach constructor ;)
```
    while [not tail? (item)][
        set (to-word rejoin ['£ item1]) first (item)
        (make-do-loop cols skip from 2 where port index + 1)
        (to-set-word item) next (item) 
    ]
```

---
- `forparse [set x block!] [x/2/4: ...]`
```
    while [found: find next found block!][
        found/1/2/4: to integer! alpha/data * 255
    ]
```

---
- `foreach/reverse [:figure] found [n: n + 1]`
- actually, foreach/reverse shouldn't work like that, otherwise it will mostly be accompanied by `tail`, so:
- `count/reverse found figure`
- `count/part head found figure found`
```
    while [found: find/reverse found form figure][n: n + 1]
```
---
- `foreach [x y] hdrs [...]`
```
    while [not tail? hdrs][
        ts: index? find sects hdrs/1
        sn: sect-num? ts
        emit [
            nsp <li> {<a href="#sect} sn {">} hdrs/2 </a> </li>
        ]
        hdrs: skip hdrs 2
    ]
```

---
- `foreach face faces [..]`
- `foreach face sift faces [object! /type = ('face)] [..]` -- could've worked if there was no error code
```
    while [not tail? faces][
        either all[
            object? face: pick faces 1
            in face 'type
            face/type = 'face
            ][
            if not face/show? [face/show?: true]
            case [
                find system/view/screen-face/pane face [ ; a window?
                ....
            ]
        ][
            do make error! "Invalid graphics face object"
        ]
        faces: next faces
    ]
```
---
- `foreach [val line _] white-pieces [...]` - this however makes chars not strings
```
    while [all [not tail? white-pieces
                not error-in-position ]] [
        pieceval: piece-value copy/part white-pieces 1
        pieceline: copy/part next white-pieces 1
        ...
        white-pieces: skip white-pieces 3
    ]
```
---
- `foreach loc steps [...]`
```
    while [all [not tail? steps
                step-on        ]] [
        loc: first steps
        temp: game-board/(loc)
        ...
        steps: next steps
    ]
```

---
- `foreach/reverse p out [if pair? p [...count blocks...]]`
- `foreach/reverse [p [pair!]] out [...count blocks...]`
- `forparse [set p pair!] reverse copy out [...] ??`
- `foreach p sift out [-1 .. pair!] [..]`
```
    while [not zero? blocks] [
        if pair? out/1 [
            out/1/y: y-pos + line-height - out/1/y ;+ font-offset
            blocks: blocks - 1
        ]
        out: back out
    ]
```

---
- `foreach [p: :elem] str1 [..]`
- `foreach [p: x /where x = elem] str1 [..]`
- `foreach [p: x] sift str1 [is (elem)] [..]`
```
    while [
        str1: find/tail str1 elem
    ][
        if all [
            any [attempt [find skp4 first skip str1 -1 - len] head? skip str1 0 - len]
            any [attempt [find skp3 first str1] tail? str1]
        ][
            i1: index? str1
            repend rt/data [as-pair i: i1 - len len 'backdrop either i = i0 [0.200.0][100.255.100]]
        ]
    ]
```

---
- map-each is not directly applicable, as using it we would expect it to keep filtered out items as is
- `map-each/into [p: _] sift found [is (lf)] [rejoin [lf index? p] lns/text`
- `foreach [:lf] found [append lns/text ...]`
- `keep-each/into [:lf] found [...] lns/text`
```
    while [found: find/tail found lf] [append lns/text rejoin [lf n: n + 1]]
```

---
- `foreach cl o/curr-clauses [..]`
```
    while [not empty? o/curr-clauses][
        o/curr-call: make clause bind/copy first o/curr-clauses in o 'self
        o/curr-clauses: next o/curr-clauses
        if unify curr-goal o/curr-call/predicat [
            o/save-vars: copy/deep reduce o/vars
            break
        ]
        o/curr-call: none
        curr-goal: copy/deep o/curr-goal
        set o/vars copy/deep o/curr-vars
    ]
```
---
- `foreach [:name y] base [append result y]`
- `append result extract keep-each [:name y] base [yes] 2` (map-each might not work here)
- `rejoin sift result [- 2 .. 1 = (name)]`
```
    while [not none? base: find/skip base name 2][
        insert tail result pick base 2
        base: skip base 2
    ]
```
---
- `foreach line port/sub-port [..]`
```
    while [(line: pick port/sub-port 1) <> ""] [net-log line]
```

---
- `foreach x series [... break instead of tail...]`
```
    while* [ 
        (not tail? series)
    ][
        ...
        if all [while counter > 0] [
            if not find item wend [
                series: tail series
            ]
        ]
        if all [until counter > 0] [
            if find item uend [
                series: tail series
            ]
        ]
        if all [... ][
            series: tail series
        ]
        series: next series
    ]
```
