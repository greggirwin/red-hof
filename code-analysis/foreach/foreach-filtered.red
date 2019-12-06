; 3 counters


    foreach-face/with root [
        pos-x: face/offset/x                            ;-- swap the "Cancel" button with last one
        face/offset/x: f/offset/x
        f/offset/x: pos-x
    ][
        either all [
            face/type = 'button
            face/parent
            find cancel-captions face/text
        ][
            last-but: none
            pos-x: face/offset/x
            pos-y: face/offset/y

            foreach f face/parent/pane [
                all [                                   ;-- search for last button on right
                    f <> face
                    f/type = 'button
                    5 > absolute f/offset/y - pos-y
                    pos-x < f/offset/x
                    pos-x: f/offset/x
                    last-but: f
                ]
            ]
            last-but
        ][no]
    ]


                            foreach-face/with face [
                                pane: find face/parent/pane face
                                move pane head pane
                            ][
                                any [
                                    face/options/style = 'connect 
                                    face/options/parent-style = 'connect
                                ]
                            ]


                                        foreach-face/with face/parent [
                                            face/offset: face/extra/pos1 + diff
                                            selection-start/(face/extra/ref): face/offset + 5x5
                                            face/extra/pos1: face/offset
                                        ][
                                            all [
                                                face <> me
                                                face/draw/4 = 80.150.255
                                            ]
                                        ]

--------------------------------------------

; bulk application ?
    foreach fc pane [
        if fc/style = 'scroller [
            fc/ratio: divide max 1 fps/(fc/axis) max 1 max fps/(fc/axis) fs/(fc/axis)
        ]
    ]


foreach [name data flags] system/view/vid/image-stock [
    unless all [word? name binary? data integer? flags] [
        print ["Invalid image-stock for " name] 
        wait 3 quit
    ]
] 

            foreach [word completion] :substitutions [
                if word = buffer [
                    lb: length? buffer 
                    lc: length? completion 
                    txt: remove/part at txt subtract index? system/view/caret lb lb 
                    insert txt copy completion 
                    clear buffer 
                    change head clear face/text head txt 
                    caret: add index? txt lc
                ]
            ]



; counter
            foreach item fs/pane [
                if object? item [
                    face/cell-func 
                    face 
                    item 
                    id 
                    count: count + 1 
                    fs/offset/y + fs/size/y <= sz
                ]
            ] 

                foreach actor first face/actors [
                    if find [
                        on-click on-key on-select on-unselect on-return on-escape on-double-click
                    ] actor [
                        pass-actor face face/list actor
                    ]
                ] 


                foreach f face/header-face/pane/pane [
                    if all [
                        f/style = 'sort-button 
                        f/feel
                    ] [
                        either f/column = face/list/sort-column [
                            set-face f face/list/sort-direction
                        ] [
                            clear-face f
                        ]
                    ]
                ] 

                foreach f face/parent-face/pane [
                    if f <> face [
                        either f/column = face/list/sort-column [
                            set-face f face/list/sort-direction
                        ] [
                            clear-face f
                        ]
                    ]
                ] 

        foreach word [text effect colors texts font para edge] [
            if style/:word [
                set in style word either series? style/:word [copy style/:word][
                    make style/:word []
                ]
            ]
        ]

foreach file read %../resources/skins/ [
    if #"/" = last file [
        store-skin
            to-word trim/with to-string file "/"
            parse-skin
                read-skin
                    join %../resources/skins/ file
                    none
    ]
]

; counter
        foreach pct pcts [
            count: count + 1
            if pct > 0 [
                fil-col: first fills
                ...
                labels-blk: next labels-blk
            ]
        ]

                    foreach widget win/pane [
                        if widget/widget-type [
                        ]
                    ]

            foreach subgob gobcp/pane [
                if overlap? subgob gobbg [
                    foreach subsubgob subgob/pane [
                        if subsubgob/draw [
                            subsubgob/draw: bind/only subsubgob/draw draw-mod
                        ]
                    ]
                ]
            ]

; counter
            foreach item subface/pane [
                if object? item [           
                    subfunc item id count: count + 1
                ]
            ]


                        foreach sibling items [
                            if all [
                                instance-of sibling 'menu-item
                                sibling <> item
                                item/mark/group = get in sibling/mark 'group
                            ][
                                sibling/mark/state: false
                                show sibling/mark
                        ]   ]


            foreach d c [
                unless d/options/shape/1 = 'blank [
                    l: find/tail d/draw 'line 
                    l/1: node/offset + (node/size / 2)
                ]
            ]

            foreach d c [
                unless d/options/shape/1 = 'blank [
                    l: find/tail d/draw 'line 
                    l/2: node/offset + (node/size / 2)
                ]
            ]

        foreach node nodes/pane [
            if all [
                node/options
                none? node/options/at-offset
            ][
                node/offset: as-pair first j: random nodes/size second j
                reconnect node
            ]
        ]


        foreach r face/pane [
            if all [
                r/options
                none? r/options/at-offset
            ][
                f: 0x0
                foreach e face/pane [
                    if all [
                        e/options
                        none? e/options/at-offset
                        not same? e r
                    ][
                        ...
                    ]
                ]
                ...
            ]
        ]


    foreach [module test][
        %prot-http.r3 idate-to-idate
        %r3-gui.r3 to-text
        %altjson.r3 load-json
        %altxml.r3 load-xml
        %altwebform.r load-webform
    ][
        unless value? :test [
            unless exists? module [
            ...
            ]

            do rsolog module
        ]
    ]

                            foreach msg read storage-dir [
                                ...
                                if not dir? msg [
                                    if error? try [
                                        msg: load join storage-dir msg
                                    ][
                                        msg: to string! read join storage-dir msg
                                        either parse msg [thru <content> insert {"} to " <" insert {"} thru <user_name> insert {"} to " <" insert {"} to end][
                                            attempt [msg: load msg]
                                        ][
                                            msg: copy []
                                        ]
                                    ]
                                    ...
                                ]
                            ]


    foreach area face/extra/areas [
        all [
            equal? 'link area/type
            inside-face? area event-offset
            browse area/link
            break
        ]
    ]

                        foreach [id draw] d: into-list dat [
                            if where: find/skip index/data id 2 [       ; not filtered out?
                                change/only next where draw
                            ]
                        ]

        for-each match this-week/matches [
            if any [
                find words-of this-week/picks match/home
                find words-of this-week/picks match/away
            ][
            ...
            ]
        ]


    foreach file read %tests/ [
        if results-file? file [
            print ["^/^/*** File:" file]
            review-test-results rejoin [%tests/ file]
            print "***^/"
        ]
    ]


    foreach result results [
        if find to-review result/status [
        ...
        ]
    ]

                            foreach fc face/pane [
                                if find fc/options 'connect [put fc/options 'bound true]
                            ]


            foreach word words-of old-node [
                unless find [name children] word [
                    if node? select old-node word [
                        if transform-node select old-node word rules [
                            done?: false
                            modified?: true
                        ]
                    ]
                    put node word select old-node word
                ]
            ]

        foreach [name extapp] actives [
            foreach app extapp/instances [
                if app/pid [
                    kill-app app/pid
                    if verbose > 0 [log/info reform [name "killed"]]
                ]
            ]
        ]


                foreach word next first new [
                    if val: get in new word [
                        set in old word val
                    ]
                ]


        foreach [ article article-link comments ] blog-comment-data [
            foreach [ name datetime comment-content ] comments  [
                if positive? (difference (datetime + diff-to-localtime) last-updated) [
                    ;print [ article name datetime last-updated]
                    remove-each tag comment-content: decode 'markup to binary! comment-content [tag? tag]
                    comment-content: head clear skip reform comment-content comment-length
                    comment-content: copy/part comment-content any [ find/last comment-content " " length? comment-content ]
                    speak reform [ name "-" article comment-content "..." join-of base-article-link (to string! article-link) ]
                ]
            ]
        ]

        foreach table either table = '* [extract tables 2][to-block table][
            if all [find tables table tables/:table/dirty?][
                sort-table table
                either lines? [
                    new-line/skip tables/:table/data on tables/:table/cols  ; add new-lines
                    new-line tables/:table/data off                         ; remove first new-line
                    write tables/:table/dat-file mold/only/all tables/:table/data
                    new-line/all tables/:table/data off                     ; remove all new-lines
                ][
                    write tables/:table/dat-file mold/only/all tables/:table/data
                ]
                recycle
                tables/:table/dirty?: false
                delete tables/:table/log-file
            ]
        ]


        foreach table either table = '* [extract tables 2][to-block table][
            if all [find tables table tables/:table/dirty?][
                delete tables/:table/log-file
                close-table table
            ]
        ]


        foreach [seq statement] sort/skip log 2 [
            unless value? 'alert [print statement]
            sql to-block statement
        ]

    foreach  [IDt title date Author] titles2 [
        if IDt [ print [ <tr> 
            <td>  (rejoin ["<a href=./index.rsp?type=thread&ID=" IDt ])  ">"  title </a> </td>          
             <td> db-select/count/where [ ID ] archive [ ID = to-integer IDt ]</td>         
             <td>date</td>
            <td>Author</td></tr>
            ]]
        ]
        ...
    ]


    foreach  [ID2 title date Author post] threads2 [
        if ID2 [ 
            print [ <tr> <td align=center width=30% > Author <br>  ]            
            avatar:  db-select/where  [avatar] users  [name = to-string Author]
            print rejoin ["<img src=" avatar " width=40px height=40px ><br>" ]
            print [<i><small>date</small></i></td>]
            print [<td> (to-br post)  </td></tr>]       
            ]
        ]
        ...
    ]


        foreach f parent [
            if f/state [
                system/reactivity/check/only f 'font
                f/state/2: f/state/2 or 00080000h       ;-- (1 << ((index? in f 'font) - 1))
                if block? f/draw [                      ;-- force a redraw in case the font in draw block
                    f/state/2: f/state/2 or 00400000h   ;-- (1 << ((index? in f 'draw) - 1))
                ]
                show f
            ]
        ]


; bulk application ?
        foreach f event/face/parent/pane [
            if all [f/type = 'radio f/data][f/data: off show f]
        ]


            foreach [name codec] system/codecs [
                if (find codec/suffixes suffix) [       ;@@ temporary required until dyn-stack implemented
                    data: do [codec/encode value dst]
                    if same? data dst [exit]
                    find-encoder?: yes
                ]
            ]



    foreach [name entry] list [
        if name <> fun [return none]
        proto: entry/3
        if (length? proto) = length? spec [
            args: spec
            match?: yes
            foreach required proto [
                match?: either block? args/1 [          ;-- is object or class?
                    none? to-Red-type required
                ][
                    type: type?/word args/1
                    expected: to-Red-type required
                    all [match? type = expected]        ;-- cumulative matching
                ]
                args: next args
            ]
            if return-type [
                match?: all [match? entry/2 = return-type]
            ]
            if match? [return entry]
        ]
    ]


; bulk application ?
        foreach word words [if word? word [set/any in dest word get/any word]]


            foreach photo photos/photos/photo [
                if photo/ispublic = 1 [
                    keep/only new-line/all reduce [
                        ...
                        photo/owner
                        ...
                        to pair! reduce [
                            as integer! any [get in photo 'width_c get in photo 'width_z get in photo 'height_m]
                            as integer! any [get in photo 'height_c get in photo 'height_z get in photo 'height_m]
                        ]
                    ] false
                ]
            ]
