# Tree traversal

---
- general face tree traversal reinvention
```
    until [
        face: either reverse [
            back-face/deep face
        ] [
            next-face/deep face
        ] 
        ...
        any [
            face = f 
            either error? set/any 'result try [do bind criteria 'f] [
                throw make error! "FIND-RELATIVE-FACE error"
            ] [
                result
            ]
        ]
    ] 
```

---
- `ascend-face` here is: `{Ascends through parent faces and performs an action on each parent. Stops when action returns FALSE.}`
- so it goes thru all parents to see if at least one is of empty size
- but it cannot work properly (behold the evil of complex loops!) because unless the immediate parent is of empty size, `any` returns none and the ascension stops
- probably `hidden?: locate/back tab-face [/size [/x = 0 or /y = 0]]` line can be better than that ascend
```
    until [
        tab-face: any [
            either event/shift [
                find-flag/reverse tab-face tabbed
            ] [
                find-flag tab-face tabbed
            ] 
            tab-face
        ] 
        hidden?: false 
        ascend-face tab-face [hidden?: any [hidden? face/size/x = 0 face/size/y = 0]] 
        not hidden?
    ] 
```


---
- coordinate translation from face to screen
- could be `sum map-each/reverse fa [..]`
```
    until [
        xy: xy op fa/offset
        fa: fa/parent
        fa/type = 'screen
    ]
```

---
- yet another coordinate translation walking up the tree, but with a user-provided code
- `foreach/reverse x gob [...]`
```
    (body/start) until [
        (body/loop)
        not all [
            offset: offset + gob/offset
            gob: gob/parent
            not same? gob screen/gob
        ]
    ] (body/end)
```

---
- coordinate translation from screen into face
- `ev - sum map-each/reverse f back fc [if f/type = 'window [break] f/offset]` - wow it's longer :)
- `ev - sum map-each x locate/back fc [/type = ('window)] [x/offset]`
```
    until [fc: fc/parent ev: ev - fc/offset fc/type = 'window]
```

---
- path construction while walking up the faces tree
- `map-each/reverse/into x face [...] path`
```
    until [
        append path ajoin [
            face/type
            either 1 < idx: index? any [
                all [face/gob/parent find face/gob/parent face/gob]
                []
            ][join "-" idx][""]
            "/"
        ]
        not all [face/gob/parent face: face/gob/parent/data]
    ]
```

---
- find a gob upwards, by type
- `foreach/reverse x gob [if x/data/type = 'container [break]]` ?
- `locate/back gob [/data/type = ('container)]`
```
    until [
        not all [gob: gob/parent object? gob/data gob/data/type = 'container]
    ]
```

---
- here first `any` expr is a search condition, second goes up the tree
- `foreach/reverse f face [if all [.. those .. long .. conditions ..] [break]]`
- `locate/back face [/gl-class = tp]` - it should be this easy
```
    until [
        any [
            rval: all [
                in face 'gl-class ; must at least be a glayout widget (not just a component face)
                face/gl-class = tp
                face
            ]
            ( face: face/parent-face
            none? face) ; exit when we have reached window
        ]
    ]
```

---
- strange tree traversal - only visits last faces in the pane
```
    until [
        fpp: get in fp 'pane 
        case [
            object? :fpp [fp: :fpp] 
            all [block? :fpp not empty? :fpp] [fp: last :fpp] 
            true [tip-face: fp]
        ] 
        tip-face
    ]
```

---
- `next-face` here handles the traversal recursively
- Red has `foreach-face` variant of this
- but it can be just: `foreach f face [func-act f]`
```
    until [
        face: next-face/deep face 
        func-act face 
        same? last-face face
    ]
```

---
- `foreach/reverse f face [all [...lots of conditions ...  break]]`
- `locate/back face [/style <> ('highlight) /size <> (0x0) /show?  how to express "inside?" calls ?]`
```
    until [
        face: back-face/deep face 
        any [
            all [
                face/style <> 'highlight 
                face/size <> 0x0 
                face/show? 
                inside? offset face/win-offset 
                inside? face/win-offset + face/size offset
            ] 
            fc = face
        ]
    ] 
```

---
- this loop simply cannot work because it will stop right after the success of `pf: pf/parent-face`
```
    until [
        any [
            all [in pf :word get in pf :word] 
            none? pf/parent-face 
            pf: pf/parent-face
        ]
    ] 
```


---
- `foreach/reverse f cf [all [flag-face? f scrollable  break]]`
```
    until [
        any [
            flag-face? cf scrollable 
            none? cf: cf/parent-face
        ]
    ] 
```
