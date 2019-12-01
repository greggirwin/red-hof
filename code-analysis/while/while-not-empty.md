# Unclassified `while [not empty? ...]`


- from `common-substr` (internal) - for auto completion
- IMO we should have an R/S level func to do this
- workarounds:
- `foreach [x y] zip [a b] [... incr counter...]`
- `count-while [x y] zip [a b] [...]`
```
    sort blk
    a: first blk
    b: last blk
    while [
        all [
            not tail? a
            not tail? b
            find/match a first b
        ]
    ][
        a: next a
        b: next b
    ]
```

---
- foreach with variable skip size
- should there be a special `advance` func inside foreach (like keep in collect)?
- like, `advance: does [set x xs: skip xs length? compose [(x)]]`
- `foreach x args [... if block? x [types: x advance] ...]`
```
    while [not tail? args] [
        item: first args 
        args: next args 
        ...
        either refinement? :item [
            prin [tab mold item] 
            if string? pick args 1 [prin [" --" first args] args: next args] 
            print ""
        ] [
            if all [any-word? :item not set-word? :item] [
                if refmode = 'refs [prin tab] 
                prin [tab :item "-- "] 
                types: if block? pick args 1 [args: next args first back args] 
                if string? pick args 1 [prin [first args ""] args: next args] 
                if not types [types: 'any] 
                prin rejoin ["(Type: " types ")"] 
                print ""
            ]
        ]
    ] 
```

---
- skips 1-2 items
- `forparse [set value skip  set attrs opt string!] [...]`
```
    while [not tail? attrs] [
        value: first attrs 
        attrs: next attrs 
        if any-word? value [
            prin [tab value] 
            if string? pick attrs 1 [
                prin [" -- " first attrs] 
                attrs: next attrs
            ] 
            print ""
        ]
    ]
```


---
- could it be map-each?
```
    close: does [while [not empty? stack][unmark] copy out]
```

---
- like variable-step foreach? seems to stop on a row only
```
    while [not tail? rows][
        row: rows
        do convert-body
        rows: skip rows length? columns
    ]
```

---
- steps by 1-2 items
- `parse spec [ any [ set attr opt set-word!  set value skip (...code...) ] ]`
- `forparse [ set attr opt set-word!  set value skip ] [...]`
- `forparse [ attr [set-word!] value | value ] [...]`
- `forparse [ attr/set-word! value | value ] [...]`
```
    while [not empty? spec][
        switch/default value: take spec [
            x: y: z: scale: rotate: rotate-x: rotate-y: rotate-z: [
                form-attr to word! value take spec
            ]
        ][
            case [
                issue? value [attrs/id: rejoin [{ id="} sanitize to string! value {"}]]
                get-word? value [append attrs/class form to word! value]
                all [word? value #"." = take value: form value][
                    append attrs/class value
                ]
            ]
        ]
    ]
```

---
- `"...=[stuff]" -> "...[(callback stuff)]"`
- body is replaced by the inner expression
```
compose-tags: func [body [string!] callback [any-function!] /local out tag block][
    out: make string! length? body
    while [tag: find body "=["][
        insert/part tail out body offset? body tag
        body: either error? err: try [
            block: load/next tag: next tag
        ][
            append out "**Tag Loading Error: #"
            tag
        ][
            append out any [callback first block ""]
            second block
        ]
    ]
    append out body
]
```

---
- deep select by path?
```
get-from: func [series 'key][
    key: copy envelop key
    while [all [not tail? key any-block? series]][
        series: select series take key
    ]
    all [tail? key series]
]
```

---
- what a weird and complex construct...
- almost `foreach` but may advance by 2 items or jump into another `specs`
- should while-not-tail consider the replacement of the given word? 'blk vs blk syntax...
```
    while [not tail? specs] [
        forever [
            value: first specs specs: next specs 
            if set-word? :value [var: :value break] 
            unless word? :value [error "Misplaced item:" :value break] 
            if find vid-words value [
                either value = 'style [
                    facets: reduce [first specs] 
                    specs: next specs
                ] [
                    set [specs facets] do-facets start: specs [] styles
                ] 
                if :var [set :var where var: none] 
                insert facets :value 
                unless parse facets vid-rules [error "Invalid args:" start] 
                break
            ] 
            new: select styles value 
            ...
            break
        ]
    ] 
```
