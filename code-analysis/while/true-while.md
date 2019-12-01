# True, justified, WHILE loops

This is the most diverse area...

---
- `unview`: each remove is reactively caught
- can be remove-each/reverse but then we will be unable to optimize this remove-each
```
    [while [not tail? pane][remove back tail pane]]
```
---
- fills buffer of size with random chars? rare stuff
```
    while [size > length? out][
        if find allowed char: 32 + random 223 [
            append out to-char char
        ]
    ]
```
---
- cmdline preprocessing
- can be `remove-each x args [ ... --catch = x ]`, but likely just as long
```
    while [
        all [
            not tail? args
            find/match args/1 "--"              ;-- skip options
            args/-1 <> "--"                     ;-- stop after "--"
        ]
    ][
        either --catch <> args/1 [
            args: next args
        ][
            remove args
            system/console/catch?: yes
        ]
    ]
```
---
- simplistic find value by segment bisection
- could be done more efficiently where linear approximation is applicable
- could be a mezz?
```
    while [hi >= lo][
        if key = copy/part at data to-index mid cols length [return mid]
        either key > copy/part at data to-index mid cols length [lo: mid + 1][hi: mid - 1]
        mid: to integer! hi + lo / 2
    ]
```
---
- looks table-oriented
```
    while [hi >= lo] [
        if condition = key: first data/:mid [
            lo: hi: mid
            while [all [lo > 1 condition = first data/(lo - 1)]] [lo: lo - 1]
            while [all [hi < rows condition = first data/(hi + 1)]] [hi: hi + 1]
            break
        ]
        either condition > key [lo: mid + 1] [hi: mid - 1]
        mid: to integer! hi + lo / 2
    ]
```
---
- count-while smth?
```
    i: 1
    while [
        all [
            block? face/pane
            (i <= length? face/pane)
            (none? lcl-face: top-face face/pane/:i point )
        ]
    ][
        i: i + 1
    ]
```
---
- count-while smth?
```
    while [textinfo face txti counter ] [
        counter: counter + 1
    ]
```
---
- count-while smth?
```
    while [textinfo face txti counter ] [
        insert tail blk copy/part txti/start txti/num-chars
        if offset [insert tail blk txti/offset]
        counter: counter + 1
    ]
```
---
- removes from random positions
- I think it has an extra `blk: head blk` though
```
    while [not tail? blk] [
        acc: 0
        forall blk [
            face: first blk
            ...
        ]
        blk: head blk
        ...
        remove find blk face
        blk: head blk
    ]
```
---
- base-58 machinations
```
    while [id > 0][
        insert out ch/(to-integer id // 58 + 1)
        id: to-integer id / 58
    ]
```
---
- ???
```
    while [tag <> position/1][
        if empty? branch [make error! "End tag error!"]
        take branch
    ]
```
---
- fill buffer from port
```
    while [expected > length? buffer][
        retrieve port buffer expected - length? buffer
    ]
```
---
- deep removal of an empty(?) path?
- should be a mezz?
```
    while [
	    ; better:
        ; also empty? folder: open path
        ;   close folder
        pare: empty? folder: open path
        close folder
        pare
    ][
        set [path target] split-path path
        folder: open path
        remove find folder target
        close folder
    ]
```
---
- from `make-dir`:
- a/b/c/d ->
-   a/b/c
-   a/b
-   a
```
    while [
        all [
            not empty? path
            not exists? path
            remove back tail path
        ]
    ][
        end: any [find/last/tail path slash path]
        insert dirs copy end
        clear end
    ]
```
---
- from `extract`
```
    while [not tail? series][
        append/only output series/1
        series: skip series width
    ]
```
---
- from `clean-path`: some trick:
- `>> clean-path %////`
- `== %/d/devel/red/`
```
    while [
        all [
            #"/" = first file
            do [f: find/tail out #"/"]
        ]
    ][
        file: next file
        out: f
    ]
```
---
- copy of data from a port; could be all handled by `read`
- append cgidata read port ?
```
    while [
        all [
           not error? trap [data: read system/ports/input]
           0 < probe length data
        ]
    ][
        append cgidata data
    ]
```
---
- same
```
    while [positive? read-io system/ports/input buffer 16380][
        append cgidata buffer
        clear buffer
    ]
```
---
- from `layout`: 125-line while, where `next` is hidden at the end
- uses spec/1 & spec/2, advances spec back and forth
```
    while [not tail? spec][                         ;-- process panel's content
        value: spec/1
        set [axis anti] pick [[x y][y x]] direction = 'across
        
        switch/default value [
            ...
            at      [at-offset: fetch-expr 'spec spec: back spec]
            ...
            react   [
                if later?: spec/2 = 'later [spec: next spec]
                repend reactors [none fetch-argument block! spec later?]
            ]
            style   [
                unless set-word? name: first spec: next spec [throw-error spec]
                styling?: yes
            ]
        ][
            unless styling? [
                name: none
                if set-word? value [
                    name: value
                    value: first spec: next spec
                ]
            ]
            ...
            spec: fetch-options face opts style spec local-styles to-logic styling?
            ... ~80 LOC ...
        ]
        spec: next spec
    ]
```
---
- ???
```
    while [
        all [
            not all [
                pos: find class/7 method
                entry: java-match-method pos spec method return-type
            ]
            class/5
        ]
    ][
        class: any [
            select/skip ~classes class/5 2
            java-fetch-class/with class/5 class/4
        ]
    ]
```
---
```
    while [mark <> tail stack][
        pop last stack
        either first? [first?: no][remove skip tail out -2]
    ]
```
---
- from RTD/`optimize`:
- rearranges some pairs
```
    pos: :cur mov: no
    while [pos: find/reverse pos pair!][
        case [
            any [
                pos/1/1 > cur/1/1
                all [pos/1/1 = cur/1/1 pos/1/2 < cur/1/2]
            ][
                ...
            ]
            mov [
                move/part cur pos1 offset? cur e
                break
            ]
            'else [break]
        ]
    ]
```
---
- can be `foreach/reverse [:lf] pos [...]` but unlikely will be better
```
    while [pos: find/reverse pos lf][if zero? n: n - 1 [break]]
    pos: any [pos buf]
    insert/part tail out pos length? pos
    any [zero? n head? p]
```
---
- append out read port ?
```
    while [data: pick port 1][append out data]
```
---
```
    while [positive? read-io system/ports/input buffer 16380] [ ...]
```
---
- ???
```
    while [all [s: find/last/tail line "  " i: index? s]] [
        insert widths i
        line: trim copy/part line i - 1
    ]
```
---
```
    while [time < run-time] [
        time: delta-time* cd count
        ...
    ]
```
---
- that's a nonstandard while-empty...
```
    while [empty? live-players][
        live-players: collect [
            foreach...
        ]
    ]
```
---
```
    while [open? server][
        ; used to test aspects of HTTPd
        wait [server 1000]
        print ["Is Open?" pick ['yes 'no] open? server/locals/subport]
    ]
```
---
- ??
```
    while [faces: face/pane face index faces] [
        index: index + 1
        if any [not item index = item] [
            facei: make_gobs_from_face faces
            faces/parent-face: face
            face-image: to-image facei/gob
            change/only at image facei/offset face-image
        ]
    ]
```
---
- from `do-events`:
```
    while [not tail? head system/view/screen-gob] [
        if ctx-do-event/pop-ups = 1 [ctx-do-event/pop-ups: 0 break] ; if pop-up closed exit this func returning to the caller
        insert system/ports/system make event! [type: 'time gob: gob]
        native-wait [system/view/event-port 0.02] ; FIXME: which is the right number to give here ? SEE: Note_on_timer
    ]
```
---
```
    while [
        remove-each face pane [
            ...
        ]
        face: all [native-pick pane 1 last pane] ; if there is one, get the last face
    ][
        ...
        either get in face 'pane [
            ...
        ][
            break
        ]
    ]
```
---
- foreach over 4 vectors at once; needs access to 2 adjacent items in each (mids are 1 item longer than `ps` and `cs`)
- foreach [pos: p pmid c cmid] zip [ps pmids cs cmids] [...]  -- still leaves pos/6 & pos/8; and slower!
- how to make this simple?
```
collect [
    while [not empty? ps] [
        keep compose [
            pen linear
                (cmids/1) (cs/1) (cmids/2)
                (pmids/1) (pmids/2) pad
            curve (pmids/1) (ps/1) (pmids/2)
        ]
        advance [ps pmids cs cmids]
    ]
]
```
---
- calculates path length; dxy is delta(X,Y) vector; last item is used later in another way
- can be just foreach/part or <take last item, do foreach, handle taken item>
```
    while [(e: e + 1) < length? xs] [   ; always exclude the trailing point from the 1st group
        if rea/opt-radius < grp-rad? 1 e [break]
        add2p dxy/:e
    ]
```
---
- groups small strokes into a single one, to be able to render it in real time
```
    while [(e: e + 1) < length? xs] [   ; always exclude the trailing point from the mid-groups
        cx0: cx  cy0: cy
        add2c xs/:e ys/:e
        if rea/opt-radius < grp-rad? s e [
            ; add the group without the last point (that's over the limit)
            add-grp cx0 cy0 s e - 1
            ; new center/path is the current point
            add2c xs/:e ys/:e
        ]
        add2p dxy/:e
    ]
```
---
```
    while [0 <> length? index-cache] [
        write-cache/flush index-cache/1
    ]
```
---
- can this not be `parse`?
```
unless tail? _str2 [
    while [_str2/1 = #";"][
        _str2: arg-scope _str2 none
        _str2: skip-some _str2 cls2
    ]
    _i1: index? _str1: _str2
    move-backdrop _str2
]
```
---
- prolog magick
```
    while [
        var-term? X
    ][
        X: get X
    ]
```
---
```
    while [call? curr-call base none] (compose/deep [
        set [(word)] reduce second curr-call/predicat
        (body)
    ])
```
---
- count-while [call? ...]
```
    while [call? curr-call base none] [i: i + 1]
```
---
- this at the very least can become `until [call? ...]`
```
    while [call? curr-call base none] []
```
---
```
    while [not empty? o/curr-goals][
    ...
    ]
```
---
```
    while [on] [ ... ]
```
---
```
    while [
        all [
            menu/actor <> menu/feel/first-of menu
            menu/feel/visible? menu extra
        ]
    ][
        menu/feel/visit  menu menu/feel/prev-of menu
    ]
```
---
```
    wr-res: write-msg message port
    while [not logic? wr-res][
        remove/part message wr-res
        wr-res: write-msg message port
    ]
```
---
- space `bin` into fixed columns + rows
- should `format` be able to handle this?
- `map-parse/self [copy xs [0 cols skip]] bin [rejoin [xs " "]]`  -- not better, need to also add LFs
- `parse bin [any [0 cols [0 chars skip insert (sp)] insert (lf)]]`
```
    while [(length? bin) > chars] [
        loop cols [
            bin: skip bin chars
            bin: insert bin " "
        ]
        bin: insert bin newline
    ]
```
---
- `parse vars-words [any [skip insert (tot) (tot: tot + 8)]]`
```
    while [not tail? vars-words] [
        vars-words: insert next vars-words tot
        tot: tot + 8
    ]
```
---
```
    while [this-line/mnem <> QUITK][ ; BEWARE of endianess
        p2: this-line/p2
        if p2 < 1E-100 [p2: from-int32 skip code 2 * 4]
        print [
            ..
            mnemsk/(this-line/mnem)
            this-line/p1
            ..
        ]
        code: skip code 4 + 4 + 8
        this-line: as lined code
        lin: lin + 16
    ]
```
---
- ??
```
    while [lex = 'op!][
        eval_infix infix-list
        eval_expr_first
        if not empty? infix-list [
            emit take infix-list
            -- dreg
        ]
    ]
```
---
```
    while [not tail? pos] [
        eval_expr_first
        eval_expr_next
    ]
```
---
```
    while [not tail? pos] [
        eval_stats
    ]
```
---
- forever [] or
- until [all ["quit" <> sentence: ask ... print ..]]
```
    while [true] [
        sentence: ask "chatbot> "
        if sentence = "quit" [break]
        print match sentence
    ]
```
---
- forever [] - unless there can be a cleaner logic
```
    while [true][
        if tmp1/idx = 1 [
            face/para/scroll/y: tmp1/offset/y
            if tmp1/offset/y > 0 [
                ...
                exit
            ]
            break
        ]
        if tmp1/offset/y <= 0 [break]
        ...
    ]
```
---
- min/max of a sorted block, skipping `none`
- first find temp-blk make typeset! [not none!]  -- this doesn't work - `find` only searches for a single type
- first filter temp-blk x [not none? x]  -- as a stream
- first map-each x temp-blk [either none? x [continue][x]]  -- not very efficient
- first remove-while x temp-blk [none? x]  -- neither, but a bit better
```
    while [none? y-min] [
        y-min: first temp-blk: next temp-blk
    ]
```
---

