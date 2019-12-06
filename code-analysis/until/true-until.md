# True, justified, UNTIL loops

- searches next or previous occurrence of a word from the current position
- selector is `next` or `back`
- foreach (at least foreach/reverse) won't work because of a custom starting position (unless we want to always add `tail` to foreach/reverse)
```
    until [
        ln: lines/1
        parse ln -line-
        if found? [
            ex/hilite: hilite-for-word face found? ex/subject
            ex/origin: pan-to-hilite ex/origin face/size face/text ex/hilite
            break
        ]
        lines: selector lines
        any [head? lines  tail? lines]
    ]
```

---
- prolog magick
```
    until [
        goal knowledge [
            deduction [X Y]
            call X
            (assert fact compose/deep Y)
       ]
       zero? goal knowledge [
           query [X Y Z]
            call X
            (inform layout compose [ (Y) across return btn-enter [
                assert fact compose/deep Z hide-popup
            ]])
        ]
    ]
```

---
```
    until
    [
      wait 0.003 ; bug fix for potential hang. see also wait-for-secure-result
      ; a wait on the client. Could we do some timeout stuff here?
      result-available? index
    ]
```

---
- I think it's bugged
```
    until [
        insert tail ud/request-data copy/part o/port 16
        ud/content-length: find/last/tail ud/request-data "Content-Length: "
    ]
```

---
```
    loop either upto [ n ][ 1 ]
    [
      until
      [
        size-read: read-io cleary msg 1
        ;1 = size-read ; HMK: Size-read is sometimes 0, which hangs this line
        1 >= size-read ; HMK
      ]
    ]
```

---
```
    until [result-available? index]
```

---
```
    until [secure-http-result-available? index ]
```

---
- I don't believe this is working: why it adds regardless of the find result?
```
    act-args: n
    stm-blok: copy statement
    until
    [
      stm-blok: find/tail stm-blok [make object!]
      act-args: act-args + 2
      not found? stm-blok
    ]
    stm: copy/part statement act-args
```

---
```
    until [
        unless d: request-dir/keep/dir/title what-dir msg [quit]
        change-dir d
        there?
    ]
```

---
```
    until [
        ...
        if compact [foreach message ret [strip-message message]]
        insert ret messages ; we may be inserting empty block, but who cares
        empty? messages
    ]
```

---
- `forever [... if empty? [break] ...]` can be shorter
```
    until [
        ...
        if compact [foreach message ret [strip-message message]]
        unless empty? ret [
            last-id: ret/1/id
            ...
        ]
        empty? ret
    ]
```

---
```
    until [ 
        y-val: y-val + y-inc
        y-pos: scale-y y-val
        insert insert tail result 'line (to-pair reduce [
                (x-offset) (to-integer y-pos)])
        insert tail result (to-pair reduce [(p-size/x + x-offset) (to-integer y-pos)])
        y-pos < 0.0
    ]
```


---
- draw block composition
```
    until [
        insert insert tail result first [line] (to-pair reduce [(to-integer x-val) 0])
        insert tail result (to-pair reduce [(to-integer x-val) (p-size/y)])
        x-val: (x-inc: parms/x-log-adj *  x-inc) + x-val
        x-val > (p-size/x + parms/x-offset + 1)
    ]
```

---
- justified or can be simpler?
```
    i: 0
    until [ 
        i: i + 1
        x-val: either x-data [
            pick x-data round-0 (i * x-inc)
        ][
            parms/x-min + to-integer (x-inc * i)
        ]
        x-pos: x-pos + x-step: (x-step * parms/x-log-adj)
        
        insert insert tail result first [text] (to-pair reduce [
                (to-integer x-pos) (y-height)])
        insert tail result to-string either date? x-val [x-val][round-2 x-val]
        
        x-pos > (full-size/x - (x-step))
    ]
```

---
- ??
```
    until [
        print to-string line/raw
        print ["new-line" line/id + 1]
        empty? bin: new-line bin
    ]
```

---
```
transform-node: function [node rules] [
    modified?: false
    until [
        done?: true
        ...
        if ... [...done?: false...]
        ...
        done?
    ]
    modified?
]
```

---
```
    until [
        none? line: print-page line
    ]
```

---
```
    until [
        data: github/get-commits/page repo probe page
        append commits data
        page: page + 1
        empty? data
    ]
```

---
- too complex to simplify?
```
    until [
        fin?: none
            ...
                if zero? mask: data/2 and 128 [     ;-- if mask bit is unset, close connection
                    ...
                ]
                fin?:   1 = shift to integer! data/1 7  ;-- test FIN flag
                opcode: data/1 and 15                   ;-- extract opcode
                len:    data/2 and 127                  ;-- mask the high bit
                pos:    0                               ;-- payload offset
                ...
                pos: pos + 3                        ;-- 3 is default offset to data (one-based index)
                mask: copy/part at data pos 4                   
                unmask data: at data pos + 4 mask len
                ...             
                ... insert ... data ...
                ...
                        data: head data             ;-- reuse the incoming ping unmasked frame
                        data/1: #"^(03)" xor data/1 ;-- convert ping opcode to pong
                        write-client data           ;-- echo back
                ...                     
                data: skip data len
                req/state: 'ws-header
            ...
        tail? data
    ]
```

---
- random filename generator
```
    until [
        clear out
        loop 8 [insert tail out #"`" + random 26]
        insert tail out ".tmp"
        not exists? incoming-dir/:out
    ]
```

---
```
    in-use: list-listen-ports
    ...
    until [not find in-use n: n + 1]
```

---
```
    until [not find uploads id: random 999999999]
```

---
```
    until [
        set/any 'evt do-events                  ;-- main event loop
        either all [value? 'evt none? evt][
            scheduler/on-timer                  ;-- scheduler job event
        ][
            unless uniserve/flag-stop [log/warn "premature exit from event loop"]
        ]
        uniserve/flag-stop
    ]
```

---
- inner `while` can become:
- `foreach/reverse buf [pos: :lf] [if zero? n: n - 1 [break]] unless zero? n [pos: buf]`
- `repeat i n [unless pos: find/reverse pos lf [pos: buf n: n - i break]]`
- can outer `until` be simpler?
```
    until [
        pos: tail buf: copy/part p: skip p negate sz sz
        while [pos: find/reverse pos lf][if zero? n: n - 1 [break]]
        pos: any [pos buf]  
        insert/part tail out pos length? pos
        any [zero? n head? p]
    ]
```

---
```
    until [
        if trace [probe data ask "? "] 
        not match data [mk1: rules* mk2: (change/part mk1 prod mk2) :mk1]
    ] 
```

---
- why not use `forever` with a few `break`s instead of lots of `true`?
```
    until [
        either parse/all data [
            copy chunk-size some hex-digits thru crlfbin mk1: to end
        ] [
            chunk-size: to integer! to issue! chunk-size
            either chunk-size = 0 [
                ...
                true
            ] [
                either parse/all mk1 [
                    chunk-size skip mk2: crlfbin to end
                ] [
                    ...
                    empty? data
                ] [
                    true
                ]
            ]
        ] [
            true
        ]
    ]
```

---
- from GUI console's `offset-to-line`:
- `sum-while h heights [... n: n + 1  all [n <= max-n y >= ???]]` ???
- `count-while lh heights [h: h + lh ...  all [y >= h ??? <= max-n]]` ???
```
    until [
        h: h + pick heights n
        if y < h [break]
        n: n + 1
        any [n > max-n h > end]
    ]
```

---
- from GUI console's `scroll-lines`:
- any better way?
```
    until [
        cnt: pick nlines n
        delta: delta - cnt
        n: n - 1
        any [delta < 1 n < 1]
    ]
    ...
    until [
        cnt: pick nlines n
        delta: delta + cnt
        n: n + 1
        any [delta >= 0 n > len]
    ]
```

---
- from GUI console's `copy-selection`:
- I'm sure this can do away with only 2 appends
```
    until [
        str: head pick lines n
        case [
            n = start-n [
                append clip-buf at str start-idx
                append clip-buf #"^/"
            ]
            n = end-n   [append/part clip-buf str end-idx - 1]
            true        [
                append clip-buf str
                append clip-buf #"^/"
            ]
        ]
        n: n + 1
        n > end-n
    ]
```

---
- from reactivity `check` - deadlock prevention by building up a queue:
- no way foreach can handle this...
```
    q: tail queue
    until [
        q: skip q': q -4
        either q/4 [                ;-- was already executed?
            clear q                 ;-- allow requeueing of it
        ][
            eval-reaction q/1 :q/2 q/3
            either tail? q' [       ;-- queue wasn't extended
                clear q             ;-- allow requeueing
            ][
                q/4: yes            ;-- mark as executed
                q: tail queue       ;-- jump to recently queued reactions
            ]
        ]
        head? q
    ]
```

---
- from `react` - looks for a known object in the path:
```
    until [                 ;-- search for an object (deep first)
        part: part - 1
        path: copy/part item part
        any [
            tail? path
            object? obj: attempt [get path]
            part = 1
        ]
    ]
```

---
- similar to `all cases` but always evaluates everything, even after a failure
```
verify: assert-all: func [cases][
    until [
        set [value cases] do/next cases
        unless value cases/1
        cases: next cases
        any [not value tail? cases]
    ]
    any [value]
]
```

---
```
    until [
        clear wire/buffer
        chunk-size: retrieve port wire/buffer wire/buffer-size
        all [wire/buffer-size > chunk-size last-packet? last wire/buffer]
    ]
```

---
```
    until [
        row-data: read-packet-via port
        if empty? row-data [return rows]        ; empty set
        ...
        any [
            wire/stream-end?
            limit = count: count + 1
        ]   ; end of stream or rows # reached
    ]
```

---
```
    until [
        done?: yes
        local: any [
            find state evt
            find state to-get-word type?/word evt
            find state [default:]
        ]
        if local [
            parse local [
                ...sets done? to yes/no...
            ]
        ]
        done?
    ]
```

---
```
    until [not find owner set 'id make-hash random 99999999]
```

---
```
    until [
        s: find surfaces to-set-word parent 
        any [s make error! rejoin ["Unknown surface '" parent "'"]] 
        parse s [
            set-word! 
            set parent opt word! 
            set block block! (insert surface-block block)
        ] 
        none? parent
    ] 
```

---
- `until`s can become very twisted...
- the inner loop can be `locate/back fp [/parent-face [block! or none!]]`
- but I think it should just `return root-face` once found
```
    return until [
        until [
            fp: fp/parent-face 
            any [
                all [none? fp/parent-face root-face: fp] 
                block? get in fp/parent-face 'pane
            ]
        ] 
        any [
            root-face 
            either panes [next-face/deep/panes fp idx + 2] [next-face fp]
        ]
    ]
```

---
- totally opaque
```
    until [
        eval_stats
        tail? pos
    ]
```
