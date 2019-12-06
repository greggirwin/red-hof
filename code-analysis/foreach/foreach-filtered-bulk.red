---------------------------------------------------------------------------------------------
------- bulk assignment -------

; 7 assignments


    foreach-face/with root [face/color: face/parent/color][
        all [
            none? face/color
            face/parent
            find [window panel group-box tab-panel] face/parent/type
            find [text slider radio check group-box tab-panel panel] face/type
        ]
    ]

    foreach-face/with root [
        face/color: any [
            gp/color
            system/view/metrics/colors/tab-panel
        ]
    ][
        all [
            none? face/color
            face/parent
            face/parent/type = 'panel
            gp: face/parent/parent
            gp/type = 'tab-panel
            find [text slider radio check group-box tab-panel] face/type
        ]
    ]

                    foreach-face/with f [
                        face/offset/x: f/size/x - face/size/x - 10
                    ][face/type = 'button]


                    foreach-face/with f [
                        face/offset/x: f/size/x - face/size/x - 10
                    ][face/type = 'button]

                                    foreach-face/with face/parent [
                                        face/extra/pos1: face/offset
                                    ][face/draw/4 = 80.150.255]

                                        foreach-face/with face [ 
                                            face/draw/4: 80.150.255 
                                        ][
                                            within? face/offset + 5x5 min face/parent/extra/pos1 face/parent/extra/pos2 face/parent/extra/size
                                        ]

                                            foreach-face/with face [ 
                                                face/draw/4: 'transparent
                                            ][
                                                not within? face/offset + 5x5 min face/parent/extra/pos1 face/parent/extra/pos2 face/parent/extra/size
                                            ]

--------------------------------------------

            foreach face pane [if flag-face? face drop [face/size: 0x0]] 

                            foreach elem face/pane [
                                if any [
                                    elem/options/style = 'connect
                                    elem/options/parent-style = 'connect
                                ][
                                    elem/size: mx + 20
                                ]
                            ]


            foreach child gob/pane [
                unless child/data [child/size: gob/size]
            ]






---------------------------------------------------------------------------------------------
------- bulk application -------






                foreach f get-pane face [
                    if any [find f/flags 'input find f/flags 'panel] [
                        clear-face/no-show f
                    ]
                ]


                foreach f get-pane face [
                    if any [find f/flags 'input find f/flags 'panel] [
                        reset-face/no-show f
                    ]
                ]

            foreach item face/parent-face/pane [
                if all [
                    item <> face 
                    item/related 
                    item/related = face/related 
                    item/data
                ] [
                    clear-face item
                ]
            ]

            foreach item face/parent-face/pane [
                if all [
                    item <> face
                    item/related
                    item/related = face/related
                    item/data
                ][
                    clear-face item
                ]
            ]


            foreach fc panel-face/pane/pane [
                if fc/style = 'fold-button [
                    insert-actor-func fc 'on-click :fold-func
                ]
            ]

    foreach image read %../resources/images/ [
        unless #"." = first image [
            add-binary join %../resources/images/ image
        ]
    ]

    foreach file [
        vid                 ; base VID context
        ctx/ctx-vid-debug   ; debugging
        feel                ; feel and access contexts for various styles
        ...
    ] [
        unless tag? file [
            add-file to-file join %../source/ join to-file file '.r
        ]
    ]

   foreach [word document-list] inverted-list [
      if 0 <> length? word [;; can't index the null word
         _add-a-word word document-list
      ]
   ]

            foreach child gob/pane [
                if object? child/data [with child/data refresh-child]
            ]


    foreach w words-of* self [if any-function? get w [protect w]]


                foreach word words-of ctx [
                    unless find parsed-rules word [
                        put parsed-rules keep word false
                    ]
                ]


            foreach item next second port/locals/data [
                if port? item [
                    update* item
                ]
            ]


        foreach table either table = '* [extract tables 2][to-block table][
            if all [find tables table not tables/:table/dirty?][
                close-table table
            ]
        ]

        foreach file files [
            if equal? last folder/:file #"/" [
                get-subfolders/deep folder/:file
            ]
        ]


        foreach spec words-of qm/models [
            if port? spec: get :spec [close spec]
        ]


