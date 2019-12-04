# FOREACH imitations


---
- same as `while [find/reverse..]`
- `foreach/reverse compose [found: (select ...)] [unless all [..] [break]]` not a huge win here
- `foreach found sift br [-1 .. is (select opp stack/1)] [..]`
```
    found: br
    until [any [
        all [
            found: find/reverse found select opp stack/1
            not find/part find/reverse/tail found lf #";" found
            load/next found 's
            s = next br
        ]
        not found
    ]]
```


---
- `find/reverse negate ws` (ws is a charset)
- or via -each: `foreach/reverse [p: x /where not find ws x] str [break]`
```
    until [str: back str not find/match str ws]
```


---
- `foreach/reverse target-engage path [...]`
```
    path: back tail path
    until [
        target-engage: first path
        if any [target-down-engage all [
            ...
        ]][
            ...
            break
        ]

        path: back path
        head? path
    ]
```

---
- `foreach/reverse targ path [..]`
- `foreach targ sift path [-1 .. /feel [/over] not window] [...]`
```
    path: back tail path
    until [
        targ: first path
        if all [
            attempt [get in targ/feel 'over]
            targ <> window
            any [changed previndex <> index find window/face-flags 'all-over]
        ][
            currindex: index ; currindex is used by show
            targ/feel/over targ true event/offset
            break
        ]
        
        path: back path
        head? path
    ]
```

---
- adding index does the trick:
- `foreach/reverse [pane: x _] pane [unless any .. [break]]`
- `last sift pane [-2 - .. /options [/style = 'connect or /parent-style = 'connect]]`
- `locate/back pane [/options [/style = 'connect or /parent-style = 'connect]]`
```
    until [
        pane: back back pane
        any [
            pane/1/options/style <> 'connect
            pane/1/options/parent-style <> 'connect
        ]
    ]
```

---
- same: `foreach [pane: x] pane [..]`
- `first sift pane [/options [/style = 'connect or /parent-style = 'connect]]` - this returns an item from pane
- `locate pane [/options [/style = 'connect or /parent-style = 'connect]]` - this returns pane at found position
- `locate pane [/options [/style [is ('connect)] or /parent-style [is ('connect)]]` same, less sugary
- `locate pane [[/options/style = ('connect) or /options/parent-style = ('connect)]]` same
```
    until [
        pane: next pane
        any [
            pane/1/options/style <> 'connect
            pane/1/options/parent-style <> 'connect
        ]
    ]
```

---
- foreach without the last item
- `foreach/stride [x _] pane [...]` ?
- `foreach x sift pane [1 .. -2] [...]` ?
```
    until [
        ob: pane/1
        insert found layout/only dia [
            connect forward with [data: data* options: opts*]
        ]
        pane: next pane 
        tail? pane
    ]
```

---
- `foreach [spec: names _ _] spec [if all [block? names find names ref] [return spec]]`
- `foreach [spec: names [block!] _ _] spec [if find names ref [return spec]]`
- `foreach [spec: names _ _ /where block? names] spec [if find names ref [return spec]]`
- `sift` requires `find/same` to find the block in the original spec:
- `find/same first sift spec [1 - - .. block! has ref] spec`
- `locate spec [[block! has ref] - -]` ?
```
    until [
        names: first spec
        if all [block? names  find names ref][return spec]
        empty? spec: skip spec 3
    ]
```

---
- inverse find
- `foreach/reverse [html: x] html [if x <> </ul> [break]]`
- `locate html [is not (</ul>)]`
```
    counter: 0
    until [
        counter: counter - 1
        (pick tail html counter) <> </ul>
    ]
```


---
- only `file` is iterated unconditionally here, and only `file/1` is used
- `foreach f file [...]`
```
    until [
        file: next file
        ...
        if expected-result: results/1 [...]
        ...
        unless perf-data: perf/1 [
            perf-data: make map! []
            perf-data/test: file/1
            perf-data/samples: copy []
            append perf perf-data
        ]
        ...
                results/1: current-result
        ...
                append results current-result
        ...
        results: next results
        perf: next perf
        tail? next file
    ]
    clear results ; remove extra results
    results: head results
    clear perf ; remove extra samples
    perf: head perf
```

---
- takes 1 or more items in one iteration (pretty ineffecient to use `take`)
- could be `foreach action dialect [... advance when needed... do code]`
```
ufcs: function ["Apply functions to given series" series dialect] [
    result: none
    until [
        action: take dialect
        ...
        unless zero? args [append ref-stack take dialect]
        while [find refs first dialect][
            refs?: true
            ref: take dialect
            ...
            unless zero? select arity ref [
                append ref-stack take dialect 
            ]
        ]
        ...
        series: do code
        empty? dialect
    ]
    series
]
```

---
- random map generator ;)
- foreach val maps [...]
```
    until [
        key: to word! random-string 8
        map/:key: take maps
        map: map/:key
        empty? maps
    ]
```

---
- `foreach/reverse [x _] inline-stack [stage3... if x = cmd [break]]`
```
    until [
        inline-stack: skip inline-stack -2 
        stage3 join inline-stack/1 "." none 
        inline-stack/1 = cmd
    ] 
```

---
- `foreach/reverse face pane [...]`
```
    until [
        pane: back pane
        pane/1/enabled?: yes
        unless system/view/auto-sync? [show pane/1]
        any [head? pane find-flag? pane/1/flags 'modal]
    ]
```

---
- from GUI console's `vprint`:
- `foreach [s: :lf] str [... str: next s]`
- `map-each [s: :lf] str [... also copy/part str s str: next s]` - though it probably wants on-the-fly redraws...
```
    until [
        add-line copy/part str s
        str: skip s 1
        cnt: cnt + 1
        if cnt = 100 [
            refresh
            cnt: 0
        ]
        not s: find str lf
    ]
```

---
- from VID `fetch-options` (108 LOC!):
- foreach that can go back and forth - pretty tricky case!
- `foreach [spec: value] spec [...back spec ... advance..]` may do, since we're skipping `draw`
```
    until [
        unless no-skip [spec: next spec]
        if no-skip [no-skip: false]                 ;-- disable the flag after 1st use
        value: first spec
        match?: parse spec [[
              ['left | 'center | 'right]     (opt?: add-flag opts 'para 'align value)
                ...
            | 'draw       (opts/draw: process-draw fetch-expr 'spec spec: back spec)
                ...
               opt [rate! 'now (opts/now?: yes spec: next spec)]
                ...
            ] to end
        ]
        ...
        any [not opt? tail? spec]
    ]
    unless opt? [spec: back spec]
```

---
- that's quite implicit and non-obvious end condition... ;)
- `foreach k key [..]` could be cleaner
```
    until [
        ser: any [
            find/tail ser key/1
            insert tail ser key/1
        ]
        key: next key
        switch type?/word ser/1 [
            none! [unless tail? key [insert/only ser ser: copy []]]
            string! [change/only ser ser: envelop ser/1]
            block! [ser: ser/1]
        ]
        if tail? key [append ser val]
    ]
```


---
- `first find tmp function!`
```
    until [function? first tmp: next tmp]   ; function follows words, guaranteed
```


---
- `foreach [pos: o] face/offsets [all [id/y < o  face/selection: -1 + index? pos  break]]`
- `face/selection: -1 + index? locate face/offsets [1 > (id/y)]`
```
    until [
        all [
            not tail? face/offsets
            id/y < first face/offsets
            face/selection: (index? face/offsets) - 1
        ]
        face/offsets: next face/offsets
        any [
            face/selection
            tail? face/offsets
        ]
    ]
```
