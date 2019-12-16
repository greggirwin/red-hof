; 11 counters
; 9 maps into 2 destinations
; 1 foreach over 2 series


        foreach-node ast [
            (loop n child)    -> [preserve-word n]
            (get type)        -> [preserve-word type]
            (match-type type) -> [preserve-word type]
            (into child)      -> [if type [preserve-word type]]
            (rule word)       -> [
                unless find result word [
                    compile-rules* result word get word
                ]
            ]
            (rule-function word ...) -> [
                unless find result word [
                    unless result/_functions [
                        result/_functions: make map! []
                    ]
                    value: get word
                    put result/_functions word value
                    set value/context value/parsed-spec
                    compile-rules* result word value/body
                ]
            ]
        ]



							foreach-face/with figs-panel [
								clear face/data 
								either face/extra = 'figs1 [
									face/size/y: face/parent/size/y
								][face/visible?: false]
							][2 < index? find face/parent/pane face]


foreach-face: function [
	"Evaluates body for each face in a face tree matching the condition"
	face [object!]	"Root face of the face tree"
	body [block! function!] "Body block (`face` object) or function `func [face [object!]]`"
	/with			"Filter faces according to a condition"
		spec [block! none!] "Condition applied to face object"
	/post 			"Evaluates body for current face after processing its children"
	/sub post?		"Do not rebind body and spec, internal use only"
][
	unless block? face/pane [exit]
	unless sub [
		all [spec bind spec 'face]
		if block? :body [bind body 'face]
	]
	if post [post?: yes]
	exec: [either block? :body [do body][body face]]
	
	foreach face face/pane [
		unless post? [either spec [all [do spec try exec]][try exec]]
		if block? face/pane [foreach-face/with/sub face :body spec post?]
		if post? [either spec [all [do spec try exec]][try exec]]
	]
]



---------------------------------------------

            foreach face pane [
                if flag-face? face drop [face/size: size] 
                face/pane-size: size
            ]

        foreach [fc act] any [get in src-face/actors actor []] [
            insert-actor-func/from target-face actor :act any [fc src-face]
        ]

        foreach [fc act] get in face/actors actor [
            act any [fc face] get-face any [fc face] event actor
        ]


            foreach f get-pane face [
                case [
                    find f/flags 'input [
                        unless empty? value [
                            unless flag-face? face transparent [
                                set-face f value/1
                            ] 
                            value: next value
                        ]
                    ] 
                    find f/flags 'panel [
                        value: set-panel f value
                    ]
                ]
            ] 


            foreach f get-pane face [
                case [
                    find f/flags 'input [
                        append/only blk 
                        either flag-face? face transparent [
                            unless flag-face? f disabled [get-face f]
                        ] [
                            get-face f
                        ]
                    ] 
                    find f/flags 'panel [
                        get-panel f
                    ]
                ]
            ]


            foreach f face/pane [
                set-face/no-show f found? find face/data f/var
            ]

foreach word [hilight-text hilight-all unlight-text] [
    set word get in ctx-text word
] 


        foreach facet [font para margin colors draw-image template draw] [
            if debug [print ["Facet:" facet "for:" describe-face face]] 
            value: get-surface-facet face facet state touch see init 
            if value [
                set in face/draw-body facet 
                either all [object? value object? get in face/draw-body facet] [
                    make get in face/draw-body facet value
                ] [
                    value
                ]
            ] 
            switch facet [
            	...
            ]
        ] 

            foreach type types [
                if exists? item: to-file rejoin [dirize form skin join type '.r] [
                    set in new-obj type load item
                ]
            ]


        foreach type types [
            switch type [
                surfaces [
                	...
                ]
            ]
        ] 


            foreach [w p] face/panes [
                either object? p [
                    set-parent-faces/parent p face
                ] [
                    foreach fc p [
                        set-parent-faces/parent fc face
                    ]
                ]
            ]


        foreach word changes [
            word: select [
                text on-text 
                minimize on-minimize 
                maximize on-maximize 
                activate on-activate 
                offset on-offset 
                restore on-restore
            ] word 
            if word [act-face face none word]
        ] 

            foreach act [on-key on-return on-escape on-tab on-unfocus] [
                insert-actor-func self act :set-scroller 
                pass-actor self area act
            ] 
            
; counter - both integer and as item from another series
                foreach day face/pane [
                    either i < 7 [
                        day/text: copy/part pick system/locale/days i + 1 2
                    ] [
                        set-face/no-show day current-date: start-date + i - 7 
                        set-face/no-show day reduce [
                            if current-date/month <> face/data/month ['out-of-month] 
                            if find [6 7] current-date/weekday ['weekend] 
                            if current-date = face/data ['day]
                        ]
                    ] 
                    i: i + 1
                ]



                foreach word [input output widths adjust modes types names resize-column header-face sub-face render] 
                  [set in face word none] 

                
                foreach      [word value]       any [values []] 
                [
                    value: 
                    case [
                        lit-word? :value [:value] 
                        word? :value [get :value] 
                        path? :value [either value? :value [do :value] [:value]] 
                        object? :value [words-of :value] 
                        true [:value]
                    ] 
                    set in face word value
                ] 

                foreach [idx chn] [2 1 5 2 8 3 11 4] [
                    set-slider face/sliders/:idx face/data/:chn
                ]

; counter - `zip` is not fit for 2+1 merging
            foreach [size offset] arrangement [
                i: i + 1 
                face/restore/no-show face windows/:i 
                resize/no-springs/no-show windows/:i size offset
            ] 


foreach [style flags] face-flags: [
    WINDOW [panel action] 
    RESIZABLE-WINDOW [panel action] 
    FACE [] 
    ...
] [
    if error? try [
        set in get-style style 'flags flags
    ] [
        make error! rejoin ["Error when setting flags for style " style]
    ]
] 

foreach [style tags] [
    FACE [internal] 
    BLANK-FACE [] 
    IMAGE [] 
    IMAGES [] 
    ...
] [
    if error? try [
        set in get-style style 'tags tags
    ] [
        make error! rejoin ["Error when setting tags for style " style]
    ]
]


		foreach [fc act] any [get in src-face/actors actor []] [
			insert-actor-func/from target-face actor :act any [fc src-face]
		]

		foreach [fc act] get in face/actors actor [
			act any [fc face] get-face any [fc face] event actor ; face, value, event and actor
		]



		foreach face pane [
			if flag-face? face drop [face/size: size]
			face/pane-size: size
		]


	foreach type types [
		switch type [
			surfaces [
				; [!] - this executes code in the skin, which is not secure
				; so the dialect should be extended with specific image loading
				paren-rule: [
					any [
						p: paren! (change p do p/1)
						| ['template | 'draw] opt 'state skip
						| into paren-rule
						| skip
					]
				]
				parse obj/surfaces paren-rule
			]
			; other types come later
		]
	]

                    foreach p o/vars [
                        if not none? q: get-term/deep p [
                            set p q
                        ]
                    ]



          foreach [ p item] hipe-serv/object-q
          [
            if now > (item/lastaccess + hipe-serv/conn-timeout)
            [
              hipe-serv/stop item/port
            ]
          ]


    foreach act resource/actions [
        dbg*: act
        op: make ... []
        op/..: act/...
    ]




				foreach-face self [face/offset/x: 120 - face/extra/size/x / 2]


	foreach word [
		all show size-text offset-to-caret caret-to-offset to-integer second request-file draw
		to-word shift wait to-string pick event? third poke
	][
		set load join 'native- word get word
	]

        foreach item items [
            set [mark icon body key arrow] reduce bind [mark icon body key arrow] in item 'self  
            item-size/y: 0
            ...
		]		                

	foreach f fs pick [
		[index-file f]
		[unless find f "tests/" [index-file f]]
	] config/include-tests?

		foreach subordinate blk [
			either word? subordinate [
				lbl: subordinate
				v?? lbl
			][
				...
			]
		]


				foreach subordinate subordinates [
					either object? subordinate [
						vprint ["plug " subordinate/sid " disregarding " observer/sid ]
						either (found? blk: find subordinate/observers observer) [
							remove blk
						][
							to-error rejoin ["liquid/"  type  "[" plug/sid "]/disregard: not observing specified subordinate ( " subordinate/sid ")" ]
						]
					][
						to-error rejoin ["liquid/"  type  "[" plug/sid "]/disregard: supplied subordinates must be or contain objects." ]
					]
				]

					foreach tmpplug plug/observers [
						either object? tmpplug/pipe?  [
							either (same? tmpplug/pipe? plug) [
								tmpplug/valve/dirty tmpplug
							][
							]
						][
							tmpplug/valve/dirty tmpplug
						]
					]


	foreach msg messages [
		content: user-name: none message-no: 0
		either attempt [parse msg [some message-rule]] [
			...
		] [print "failed"]
	]

										foreach key words-of tobj [
											u/(key): tobj/(key)
										]

remove-key: funct [key so-db][
	foreach [class db] next next so-db [
		if at: find db key [remove at]
	]
]

	foreach message messages [
		code/(message/id): get-code message
	]


	foreach room rooms [
		print rejoin [room/name ": #" room/id]
	]

	foreach message messages/mention [
		print ["--- Processing" message]
		; we care only about messages for our bot (may change later)
		parse-message gitter/get-message room message
	]

	foreach message messages/chat [
		print ["--- Processing" message]
		; we care only about messages for our bot (may change later)
		parse-command gitter/get-message room message
	]	

; map into 2 destinations
        foreach jump knightsjump/:i [
            either odd? thispiece [
                if 0 = black-board/(jump) [these-moves: append these-moves jump]
            ][
                if 0 = white-board/(jump) [these-moves: append these-moves jump]
            ]
        ]

    foreach [a b] from-to-fields [
        prin a prin "^(tab)" print b
    ]

   foreach [index-name index-file] index-cache [
      write-cache index-name
   ]

   foreach item next first con-set [
      error? try
      [set in cif/config to-word item get in con-set to-word item]
   ]


   foreach target targets [
      seq: seq + 1
      hits: _and-results hits
      find-word index-name target
      seq
   ]

   foreach letter unique join starting-word-index cif/word-index-block/1 [
      letter: to-string letter
      if not find cif/admin/dirty-tags letter [alter cif/admin/dirty-tags letter]
   ]

   foreach entry next first cif [
      if entry <> 'word-index-block [
         temp-cif: make temp-cif reduce [to-set-word entry none]
         set in temp-cif entry get in cif entry
      ]
      temp-cif: make temp-cif [word-index-block: none]
   ]

   foreach tag cif/admin/dirty-tags [
      file-name: to-file rejoin [index-name-prefix index-name "-" to-integer tag/1 index-name-suffix]
      either nn: find cif/word-index-block/1 tag [
         nn: 1 + index? nn
         write/binary file-name compress mold cif/word-index-block/:nn
      ] [
         error? try [delete file-name]
      ]
   ]


   foreach e either block? doc-id [doc-id] [reduce [doc-id]] [_insert-packed word-entry/2 e]


		foreach child next gob/pane [
			child/data/offset/y: child/offset/y: tmp + correct
			tmp: child/size/y + tmp + correct
		]


		foreach child gob/pane [
			child/data/offset/y: child/offset/y:  tmp
			tmp: child/size/y + tmp + correct
			case [
				tmp < 0 [
					dprint ["hide above" child/data/idx]
					append tmp2 child
					remove find gob child
				]
				child/offset/y > face/size/y [
					dprint ["hide below" child/data/idx]
					append tmp1 child
					remove find gob child
				]
				; childs which are already inside the window are only scrolled
			]
		]


			foreach gob show-queue [
				'print ["*SHOW*" gob/parent/size ":" gob/offset gob/size "-"
					min max parent/size (gob/offset + gob/size) gob/offset
				]
				unless find show-queue gob/parent [*show gob]
			]


			append face body-of foreach :words words compose [
				set words: copy bind? (to-lit-word words/1) none words
			]


	foreach gob reverse copy entered [
		do-event gob 'up offset
		if find clicked gob [
			do-event gob 'click offset
		]
	]


				foreach match [blank not-blank][
					until [
						tmp: any [face/back? tmp]
						any [
							head? tmp
							not if find get match tmp/0 [tmp: back tmp]
						]
					]
				]


					foreach child face/pane [
						with child [offset face/origin + parent/para/scroll show]
					]

advance: func [ws] [foreach w ws [set w next get w]]

							foreach [id' _] ch/assocs [
								a: rea/map/lookup! [id: id' assocs]
								remove/part find/skip a ch/id 2 2
							]

		foreach [alias target] deferred-aliases [
			(all [
				target: attempt [load target]
				find [word! refinement!] type?/word target
				pos: find-refinement spec to refinement! target
			]) else form rejoin ["Target "target" of alias "alias" is not defined"]
			append pos/1 alias
		]

		foreach [opt val] options [
			if all [
				set [opt arg types] find-option? :caller opt	;-- option is supported by the caller
				not get opt [continue]							;-- it wasn't explicitly provided
			][
				if arg [
					...
					set arg :val
				]
				set opt to logic! :val
			]
		]

		foreach arg call/2 [
			either word? spec/1 [							;-- pass single argument normally
				if find spec/3 block! [arg: reduce [arg]]
				append/only r arg
				spec: skip spec 3
			][												;-- collect all other arguments into the last block
				unless block? last r [complain [ER_MUCH "Extra operands given"]]
				append last r arg
			]
		]


			foreach x call/3 [							;-- call/3 is refinements block
				either refinement? x [					;-- /ref
					append r/1 to word! x					;-- add ref to path
					types: pick find-refinement spec x 6	;-- 3rd is none, 6th is argument's typeset (or none if no argument)
				][										;-- [values...]
					if typeset? types [						;-- none if refinement is nullary
						either find types block! [
							append/only r x					;-- add as block of collected values
						][
							#assert [not empty? x]
							append r last x					;-- last value replaces prior ones
						]
						types: none
					]
				]
			]

		foreach [names doc types] spec [
			#assert [string? doc]
			either none? types [						;-- options
				#assert [not empty? names]
				unless committed? [commit]

				short: copy ""  long: copy ""
				foreach name names [					;-- form short & long options strings
					either single? form to word! name 
						[ repend short ["-" name ", "] ]
						[ repend long ["--" name ", "] ]
				]
				...
			][											;-- operands or option arguments
				...
				commit
			]
		]

			foreach [name value] arg-blk [					;-- do processing
				either name										;-- none if operand
					[ add-refinements/options call get program name value opts ]
					[ add-operand/options     call get program value opts ]
			]

      foreach [style content] menu [
          href: content/1
          marked: either content/2 [content/2][href]
          tag: reduce ['a 'href join anchor-root href]
          if content/2 [repend tag ['title marked]]
          emit [nsp " " <li> build-tag tag marked </a></li>]
      ]


		foreach tmp mdp-stack [
			name: tmp/1
			value: tmp/2
			switch/default name [
				align							[align]
				bar								[bar]
				...
			][print ["Unknown TAG found:" name]]
		]

		foreach tmp value [
			name: tmp/1
			pvalue: escape-html tmp/2

			switch/default name [
				...
			][print ["1: Unknown INLINE-TAG found:" name]]
		]

      foreach [style content] menu [
      	switch style [
      		url [
	          href: content/1
	          marked: either content/2 [content/2][href]
	          tag: reduce ['a 'href join anchor-root href]
	          if content/2 [repend tag ['title marked]]
	          emit [nsp " " <li> build-tag tag marked </a></li>]
	        ]
	        split [
				if content/1 > 0 [emit [nsp <li> content/2 </li>]]
	        ]
        ]
      ]

		foreach entry mdp-stack [
			; check to see if there is an other file name used?
			if entry/1 == 'file [
				filename: either (pick parse entry/2 "." 2) == "html" [entry/2][to-file join entry/2 ".html"]
				emit [<br /><em> "references into file: " filename </em><br />]
			]
			; check each word to find a section
			if level: find [sect1 sect2 sect3 sect4] entry/1 [
				...
			]
		]


	foreach file compose [(files)] [
		; do we have source-text or files?
		either (type? file) == file!
			[
		    either exists? file
		    ...
		  ]
			[parse/all detab file mdp-parser/mdp]
			...
		]

		...
		mdp-parser/init
 	] ; foreach

							foreach key keys-of figures* [figures*/:key: none]

do [foreach tab tab-pan/pane [tab/parent/offset tab/offset: tab/parent/offset + 10x30]];2x24]];[drawing-panel-tab: pane/1/pane/1 animations-panel-tab: pane/1/pane/2]


        foreach team words-of teams [
            poke teams team make object! [
                target: teams/:team
                image: switch probe type of teams/:team [
                	...
                ]
                ...
            ]
        ]


                for-each week words-of weeks [
                    week: weeks/:week
                    week/number: week-no: me + 1
                    week/name: spaced ["Week" pick cardinals week/number]
                    ...
                ]


                            for-each match week/matches [
                                either pair? match/score [
                                    week/points/(match/home): case [
                                    ...
                                    ]
                                ][
                                	...
                                ]
                            ]


                                    remove-each player missing-picks [
                                        for-each team sort words-of week/match-by-team [
                                            unless find players/:player/picks team [
                                                append any [
                                                    select week/picks team
                                                    week/picks/(team): make block! 0
                                                ] players/:player/nick
                                                week/player-picks/(player): team
                                                break
                                            ]
                                        ]
                                        block? find words-of week/player-picks player
                                    ]


                            for-each player words-of players [
                                case [
                                    find week/starters player [
                                        player: players/:player
                                        ...
                                    ]
                                    ...
                                ]
                            ]


        for-each week collect [
            if this-week [keep this-week]
            if this-week <> last weeks-played [
                keep last weeks-played
            ]
        ][....]


            for-each match week/matches [
            ...
            ]

                for-each value compose [(style)][
                    switch type-of style [
                        :file! :url! [
                            unspaced [| build-tag compose [link href (style) rel "stylesheet" type "text/css"]]
                        ]
                        :string! [
                            unspaced [
                                | <style type="text/css">
                                | sanitize trim/auto style
                                | </style>
                            ]
                        ]
                        (no-content)
                    ]
                ]


				foreach item choices [
					switch type?/word item [
						...
					]
				]

						foreach face head selection [
							face/de-select
							show face
						]

				foreach item pane [
					either in item 'def-size [
						item/parent-face: self
						item/calc-sizes

						item/def-size: max item/def-size item/min-size
						...
					][
						vprint/error "no def-size! gadgets HAVE to be built using glayout..."
					]
				]

; map into 2 destinations
					foreach sub-face pane [
						append either (coord/s sub-face/elasticity dir) = 0 [nel-pane][el-pane] sub-face
					]

					foreach face pane [
						either (coord/f face/stretch dir) [
							amount: (coord/fpair size dir)
						][
							; restrict size to something between min and default size.
							amount:  min ((max (coord/fpair face/min-size dir) (coord/fpair size dir)) (coord/fpair face/def-size dir))
						]

						face/offset: current-offset
						face/layout oriented-add amount face/size dir

						current-offset: oriented-add current-offset face/size dir
					]

			foreach item frame-face/items frame-face [
				either item/1 = 'folder [
					frame-face/add-folder item/2 (get in frame-face 'frame-action) (random copy item/2)
				][
					frame-face/add-item item/2 (get in frame-face 'frame-action) (random copy item/2)
				]
			]

					foreach item spec [
						switch type?/word item [
							block! [
								...
								 append face/panes item
							]
							
							string! [
								;print ["next block's label: " item]
								label: item
								
							]
						]
					]

; counter - for head and tail checks only
			foreach choice choices [
				any[
					all [ (i = 1) clip:  ['right]  corner: tab/corner ]
					all [ ( i = (length? choices)) clip: ['left]  corner: tab/corner ]
					all [ clip: ['both] corner: 6 ]
				]
				
				...				
				i: i + 1
			]

			foreach pane panes [
				pane/offset: as-pair margin margin + container/offset/y
				pane/layout pane-size 
			]

; map into 2 destinations
							foreach item dirlist [
								append  either dir? item [dlist][flist] item
							]

							foreach item dlist [
								either absolute? item [
									dirpath: item
								][
									dirpath: to-file append copy dir item
								]
								...
							]



        foreach source-file files-to-test [
            if error? set/any 'error try [do source-file] [
                print [tab "UNABLE TO DO" source-file]
                print form error
                summary/failed: 1
                return summary
            ]
        ]


            foreach word pattern/children [
                if word = '... [
                    ...?: true
                    break
                ]
                unless word? word [
                    cause-error 'script 'invalid-arg [word]
                ]
                put node word first node/children
                node/children: next node/children
            ]

            foreach rule node-rules [
                if mapped: map-node old-node rule/pattern [
                	...
                    ] [
                    	...
                        if block? prod/children [
                            node/children: make block! 0

                            foreach child prod/children [
                                either word? :child [
                                	...
                                ]
                            ]
                        ]
                        foreach word words-of prod [
                            unless find [name children] word [
                                value: select prod word
                                ...
                            ]
                        ]
                    ]
                    break
                ]
            ]


foreach-node*: function [node rules] [
    node-rules: select rules node/name
    if node-rules [
        foreach rule node-rules [
            if mapped: map-node node rule/pattern [
                mapped: map-to-object mapped
                do bind/copy rule/production mapped
            ]
        ]
    ]
    if block? node/children [
        foreach child node/children [
            if node? :child [foreach-node* child rules]
        ]
    ]
    foreach word words-of node [
        unless find [name children] word [
            if node? child: select node word [foreach-node* child rules]
        ]
    ]
]


			foreach value locals/datalist [
				emit build-tag 'option compose [value: (value)]
			]


		foreach word [compress decimal! deline invalid-utf? join reform to-rebol-file] [
			all [value? word print [word "already defined!"]]
		]

; counter
			i: 1
			foreach row data [
				...
					cause-error 'user 'message reduce [reform ["Row" i message]]
				...
				i: i + 1
			]

		foreach word words [
			do compose [(to-set-word word) (to-get-word in self word)]
		]
		words

		foreach row data [all [block? row new-line/all row false]]

			(either settings/as-is [] [[foreach val row [trim/lines val]]])

; counter
		foreach row inner [
			put map row/:key2 i: i + 1
		]

		foreach char [#"'" #" " #"-" #"." #","] [
			all [find string char string: next find string char mixedcase string]
		]

					foreach row data compose/deep [
						either group = copy/part row (len) [append val last row] [
							append group (operation) val
							append/only blk group
							group: copy/part row (len)
							append val: copy [] last row
						]
					]

					foreach row stdout [
						foreach val row [
							all ["NULL" == val clear val]
						]
					]


		foreach [sheet-name block spec] data [
			unless empty? block [
				...
			]
		]

	foreach [cgi-key red-key] [
		"HTTP_HOST" remote-host
		...
		"CONTENT_TYPE" Content-Type
	] [
		headers/:red-key: raw/:cgi-key
		raw/:cgi-key: none
	]

		foreach manage face/manage [
			do
				get in
					face/parent-face/parent-face/parent-face
					manage
				face/parent-face/parent-face/parent-face
				face/parent-face
		]


    foreach [cmd args] dialect [
        data: apply get cmd head insert/only args data
    ]



foreach-node: func [
	data
	code
] [
	; FN takes three parameters: [tag content attribute] (or just two? without content)
	foreach [tag content attributes] data [
		do bind code 'tag
		if block? content [
			foreach-node content code
		]
	]
]


	foreach word words [
		result/:word: get word
	]

	foreach [file data] gist [
		write to file! data/filename data/content
	]

	foreach file files [
		tree-file: find-file tree file
	; -- 3. retrieve the content of the blob object that tree has for that particular file path
	;	NOTE: why do I retrieve the blob? I am not reusing it, AFAIK
		blob: get-blob repo tree-file/sha
	; -- 4. change the content somehow and post a new blob object with that new content, getting a blob SHA back
		content: read file
		new-blob: make-blob repo content ; TODO: expects textfiles, does not handle binary files yet
		blob/sha: new-blob/sha
	]

; tricky map 
			foreach [phase blk] phases [
				np: reduce [mod/name get in mod :phase]
				switch select mod/order phase [
					first	[insert blk np]
					normal	[insert back back tail blk np]
					last	[insert tail blk np]
				]
			]
		]


		foreach [name mod] mod-list [
			if fun: in mod event [
				do :fun self
				if verbose > 1 [
					log/info reform ["event" event "done (" name ")"]
				]
			]
		]

		foreach [mod do-handler] phases/:name [
			if verbose > 1 [
				log/info reform ["trying phase" name "(" mod ")"]
			]
			state: do-handler req
			if all [verbose > 1 logic? state][
				log/info "=> request processed"
			]
			if state [return state]
		]	


; map into 2 destinations
				foreach ext to-block args/2 [
					data: reduce [ext args/1]
					append service/mod-list/mod-action/dyn-types data
					append service/handlers data
				]



		foreach spec templates [
			parse spec [
				some [
					'environment into [
						any [set n skip set v skip (set-env form n form v)]
					]
					| 'command set cmd string!
					| 'channels set chan integer!
					| skip
				]
			]
			...
		]


			foreach file to-block any [select cfg 'default []][
				new: rejoin [cfg/root-dir req/in/path file]
				if req/file-info: info? new [
					req/in/target: form file
					if ext: find/last req/in/target dot [
						req/in/ext: to word! ext
						req/handler: select service/handlers req/in/ext
					]
					if not req/in/file [req/in/file: new]					
					if d?: declined? req [return false]
				]
			]

		foreach [vhost cache] second second :logging [			;-- flush logs
			unless empty? cache/2 [
				if error? set/any 'err try [
					write/append join log-dir [form-host vhost #"-" log-file] cache/2
				][
					log/error mold disarm :err
				]
			]
		]

		foreach rule extract/index sym-proto 2 2 [
			if all [
				not empty? rule: get rule
				'| = last rule
			][
				remove back tail rule
			]
		]

		foreach [word rules] symbols [
			if all [not empty? rules '| = last rules][
				remove back tail rules
			]
		] 


		foreach file list [
			if file? file [
				either exists? file [
					safe-exec/with file does [do file] "##User Library error"
				][
					log/error ["access error: cannot open " mold file]
				]
			]
		]

; counter - unused
			foreach [a b c d] list [
				log/info reform [a b]
				log/info ["code:" mold c]
				cnt: cnt + 1
			]


				foreach w class [
					if pos: find cache w [
						poke list (index? next pos) / 2 now
					]
				]


			foreach :value spec [
				either pos: find vars name [
				....
			]



				foreach fun next first events [
					if fun: get in events :fun [bind second :fun ctx]
				]


		foreach [app-dir events ctx] apps [
			safe-exec %on-application-end events/on-application-end
		]



                        foreach var vars [
                            either in set-actions var [
                                do bind get in set-actions var in obj 'self
                            ] [
                                set in obj var value
                            ]
                        ]


            foreach [cmd opts] defaults [
                if w: select [
                	...
                ] cmd [
                    set w parse-command-options cmd opts
                ]
            ]



                foreach row data/contents [
                    open-block 'row none 
                    foreach column row [
                        emit [reduce ['cell reduce ['para column]]]
                    ] 
                    close-block
                ] 


; counter i
; counter j
; map into 2 destinations
            foreach row table/table [
                either object? row [
                    i: 1 
                    insert/only tail result content: copy [row] 
                    if row/style [insert/only insert tail content 'opts make-style row/style] 
                    if all [find [horiz both] header j = 1] [insert tail content 'header] 
                    foreach cell row/contents [
                        either object? cell [
                            if cell/type = 'cell [
                                insert/only tail content compose [
                                    cell (either cell/style ['opts] [[]]) (either cell/style [reduce [make-style/ignore cell/style [position]]] [[]]) (either cell/spansize ['span] [[]]) (any [cell/spansize []]) (either header? header i j ['header] [[]]) (cell/out)
                                ]
                            ]
                        ] [
                            tmp: make-cell-style table none row pick table/columns i 
                            insert/only tail content compose [
                                cell (either tmp ['opts] [[]]) (either tmp [reduce [make-style/ignore tmp [position]]] [[]]) (either header? header i j ['header] [[]])
                            ]
                        ] 
                        i: i + 1
                    ] 
                    loop table/size/x - length? row/contents [
                        tmp: make-cell-style table none row pick table/columns i 
                        insert/only tail content compose [
                            cell (either tmp ['opts] [[]]) (either tmp [reduce [make-style/ignore tmp [position]]] [[]]) (either header? header i j ['header] [[]])
                        ] 
                        i: i + 1
                    ]
                ] [
                    insert/only tail result content: copy [row] 
                    if all [find [horiz both] header j = 1] [insert tail content 'header] 
                    if not any [table/style] 
                    repeat i table/size/x [
                        tmp: make-cell-style table none none pick table/columns i 
                        insert/only tail content compose [
                            cell (either tmp ['opts] [[]]) (either tmp [reduce [make-style/ignore tmp [position]]] [[]]) (either header? header i j ['header] [[]])
                        ]
                    ]
                ] 
                j: j + 1
            ] 


            foreach word words [
                if none? get in dest word [
                    set in dest word get in source word
                ]
            ] 


    for-each command read command-dir [
        if error? err: trap [
            ...
        ][
            probe err
        ]
    ]

    foreach c " ." [
        replace/all username c "-"
    ]


    for-each command lib/commands [
        if all [
            callback: find words-of command 'pulse-callback
            function? :callback
        ] [command/pulse-callback]
    ]


        for-each msg messages [
            content: lib/user-name: _ lib/message-id: 0
            ...
        ] ; end of for-each loop


                foreach file sort/reverse read storage [
                    if cnt > 50 [
                        break
                    ]
                    if not dir? file [
                        json: load-json to string! read join-of storage file

                        if all [
                            in json 'content
                            find json/content form target
                        ] [
                            ++ cnt
                            repend/only out [json/time_stamp json/user_name json/message_id json/user_id json/content]
                        ]
                    ]
                ]

                foreach person newbies [
                    ;;append addressees ajoin [ "@" person " " ]
                    full-greet-message: copy greet-message
                    if error? set/any 'err try [
                        either 20 > person/4 [
                            append full-greet-message low-rep-message
                        ] [
                            speak ajoin [profile-url person/3 "/" url-encode to-dash person/2]
                            ; Modified following SO discussion about bots not speaking unless spoken to
                            speak full-greet-message
                        ]
                    ] [
                        log mold err
                    ]
                    ;speak ajoin ["@" person/2 " " full-greet-message]
                    wait 1
                ]

for-each w paranoid: [
    old-write
    old-read
    old-open
    call
    cd change-dir
    ls list-dir 
    rm
    make-routine ; FFI
][unset w]



    foreach content result [
        ; grab all links from the message
        parse decode 'markup to binary! decode-xml content [
            some [
                opt string!
                set link tag!
                set text string!
                </a> (
                    if parse form link [thru {a href="} copy ilink to {"} to end] [
                        repend links [text ilink]
                    ]
                )
                opt string!
            ]
        ]
    ]

        foreach [text link] links [
            link: rejoin ["[" text "](" link "); "]
            either chat-length-limit < add length? payload length? link [
                reply message-id payload
                wait 2
                payload: copy link
            ] [
                append payload link
            ]
        ]

            foreach item head reverse copy order-by [
                set [index way] either block? item [
                    item
                ][
                    reduce [item 'asc]
                ]
                if not integer? index [
                    index: index? find cols reduce [index]
                ]
                either way = 'desc [ 
                    sort/compare/reverse result index
                ][  
                    sort/compare result index
                ]
            ]

        foreach [item1 item2] from [
            append spec reduce [item1 £item1: to-word rejoin ['£ item1]]
            words: copy* []
            set-words: copy* []
            foreach item get-cols item2 port [
                item: first to-block item
                append words item
                append set-words to-set-word item
            ]
            ...
        ]

		foreach char next string [
			parse form char [
				[
					  [["B" | "F" | "P" | "V"]							(val: "1")]
					| [["C" | "G" | "J" | "K" | "Q" | "S" | "X" | "Z"]	(val: "2")]
					| [["D" | "T"]										(val: "3")]
					| [["L"]											(val: "4")]
					| [["M" | "N"]										(val: "5")]
					| [["R"]											(val: "6")]
				]
				(insert tail code val)
			]
			if 3 = length? code [break]	; stop after reaching 3rd char
		]

; counter
		foreach column columns compose/deep [
			seq: seq + 1
			pos: seq - (length? columns)
			either column = 'rowid [
				repeat rowid (tables/:table/rows) [
					poke buffer pos: pos + (length? columns) rowid
				]
			][
				data: at tables/:table/data tables/:table/offsets/:column
				loop (tables/:table/rows) [
					poke buffer pos: pos + (length? columns) first data
					data: skip data (tables/:table/cols)
				]
			]
			explain-plan "Fetch" column
		]

					foreach [(columns)] copy buffer [
						query-table: copy query-block
						foreach offset on-columns [
							replace/all query-table join ":" pick [(columns)] offset pick reduce [(columns)] offset
						]
						do query-table
						unless empty? buffer [
							;	insert master details
							while [not tail? buffer] [
								insert tail blk copy/part reduce [(columns)] (cols - master-on-cols)
								insert tail blk copy/part buffer (length? query-columns)
								buffer: skip buffer (length? query-columns)
								insert tail query-plan plan
							]
							buffer: head buffer
						]
					]



				foreach lookup-table lookup-tables [
					open-table/no-clear :lookup-table
					buffer: at buffer index? find columns first lookup-columns
					remove lookup-columns
					while [not tail? buffer] [
						if first buffer [	; skip none!
							if result: binary-search tables/:lookup-table/data first buffer tables/:lookup-table/cols tables/:lookup-table/rows [
								result: first skip tables/:lookup-table/data to-index result tables/:lookup-table/cols
							]
							change buffer result
						]
						buffer: skip buffer cols
					]
					buffer: head buffer
				]

			foreach rowid head reverse buffer compose [
				;	remove row from data file
				remove/part at data to-index rowid (tables/:table/cols) (tables/:table/cols)
			]


			foreach rowid buffer compose [
				data: at head data to-index rowid (tables/:table/cols)
				repeat pos (length? columns) [
					poke data offsets/:pos values/:pos
				]
			]

					foreach rowid buffer [
						data: at head data to-index rowid (tables/:table/cols)
						;	evaluate expression(s)
						set [(exp-columns)] reduce [(blk)]
						blk: reduce [(values)]
						;	update value(s)
						repeat pos (length? columns) [
							poke data offsets/:pos blk/:pos
						]
					]

; map into 2 destinations
		spec: join "db-" first statement
		foreach word next statement [
			;	ignore 'rowid
			either find next reserved-words word [
				;	ignore "fill" words
				unless find [by from into on set table to values with] word [
					insert tail spec join "/" word
				]
			][
				insert/only tail args word
			]		
		]

			foreach [(columns)] buffer [
				print trim/tail reform [(format)]
			]

			foreach line read/lines script [execute/script line]

    foreach  [ID title date ]  titles [
    	print [<item> <title> title </title> <link>]
    	print rejoin [http://rebolforum/index.rsp?type=thread&ID=  ID]
    	print [</link> <description> title </description><pubDate>date</pubDate></item>]
	]

foreach [name codes width glyph] list [
	if zero? remainder cnt: cnt + 1 100 [prin [cnt #"."]]
	dive glyph
]

		foreach char text [
			glyph: get-glyph char
			...glyph is used, not char...
		]


					foreach f head old [
						f/parent: none
						stop-reactor/deep f
						if all [block? f/state handle? f/state/1][
							system/view/platform/destroy-view f no
						]
					]


			foreach f parent [
				system/reactivity/check/only f 'para
				system/view/platform/update-para f (index? in self word) - 1 ;-- sets f/state flag too
				if all [f/state f/state/1][show f]
			]


		foreach f face [
			if word? f [f: get f]
			if object? f [show f]
		]

			foreach field [para font][
				if all [field: face/:field p: in field 'parent][
					either block? p: get p [
						unless find p face [append p face]
					][
						field/parent: reduce [face]
					]
				]
			]


						foreach f head pane [
							f/enabled?: no
							unless system/view/auto-sync? [show f]
						]


; counter n
; counter y
		foreach str at lines top [
			txt: either zero? cnt: pick flags n [str][
				txt: copy/part str cnt
				append/dup txt "*" length? skip str cnt
			]
			box/text: txt
			if color? [highlight/add-styles txt clear styles theme]
			mark-selects styles n
			cmds/4/y: y
			system/view/platform/draw-face console cmds

			cnt: rich-text/line-count? box
			h: cnt * line-h
			poke heights n h
			line-cnt: line-cnt + cnt - pick nlines n
			poke nlines n cnt
			clear styles

			n: n + 1
			y: y + h
			if y > end [break]
		]


			foreach list reduce [general select OS system/platform user][
				foreach name list [
					if debug? [print ["Applying rule:" name]]
					name: get in processors name
					do [name root]
				]
			]

			foreach [f blk later?] reactors [
				either f [
					bind blk ctx: context [face: f]
					either later? [react/later/with blk ctx][react/with blk ctx]
				][
					either later? [react/later blk][react blk]
				]
			]

		foreach face pane [
			unless face/options/at-offset [				;-- exclude absolute-positioned faces
				offset: either top-left? [0][max-sz - face/size/:axis]
				mar: select system/view/metrics/margins face/type
				if type: face/options/class [mar: select mar type]
				if mar [
					...
				]
				if offset <> 0 [
					if find [center middle] align [offset: to integer! round/floor offset / 2.0]
					face/offset/:axis: face/offset/:axis + offset
				]
			]
		]

		foreach word words-of system/words [
			col-1: rejoin [DENT_1 as-col-1 word]
			set/any 'val get/any word
			if all [not unset? :val  type = type? :val  (found-at-least-one?: yes)] [
				_print/fit case [
					datatype? :val [
						either system/catalog/accessors/:word [
							[col-1 DOC_SEP mold system/catalog/accessors/:word]
						][
							[col-1]
						]
					]
					any-function? :val [[col-1 DOC_SEP any [doc-string :val ""]]]
					'else [[col-1 DEF_SEP form-value :val]]
				]
			]
		]



			foreach param fn-as-obj/params [_print [DENT_1 form-param param]]


			foreach rec fn-as-obj/refinements [
				_print [DENT_1 as-arg-col mold/only rec/name DOC_SEP either rec/desc [dot-str rec/desc][NO_DOC]]
				foreach param rec/params [_prin DENT_2 print-param param]
			]


		foreach map-word words-of map [
			set/any 'value map/:map-word
			_print/fit [
				DENT_1 pad form map-word word-col-wd DEF_SEP as-type-col :value DEF_SEP
				either same? :value output-buffer [""][form-value :value]
			]
		]


		foreach obj-word words-of obj [
			set/any 'value get/any obj-word
			_print/fit [
				DENT_1 pad form obj-word word-col-wd DEF_SEP as-type-col :value DEF_SEP
				either same? :value output-buffer [""][form-value :value]
			]
		]

		foreach word sort get-sys-words either with [:set?][:any-function?] [
			val: get word
			if any [
				not with
				find form word text
				all [spec  any-function? :val  find mold spec-of :val text]
			][
				found-at-least-one?: yes
				_print/fit [DENT_1 as-col-1 word  as-type-col :val  DEF_SEP  form-value :val]
			]
		]



; iteration index <> index pos here - how to make a simple index? just div by 4?
		foreach [obj field reaction target] relations [
			prin count: count + 1
			prin ":---^/"
			prin "  Source: object "
			list: words-of obj
			...
		]

		foreach d delimiters [
			word: find/last/tail/part str d len
			if all [word (index? ptr) < (index? word)] [ptr: word]
		]

each: func [code [block!]][
	foreach photo photos :code
]

				foreach [test onfail][
					[sw*/insert sub-port data]
					["Could not write <" url ">"]
					[set-rights sub-port 'file]
					["Could not set permissions <" url ">"]
				][
					if error? try :test [raise :onfail]
				]


						foreach row rows :convert-body


				foreach [key spec] body-of packet [
					key: to word! key
					value: record/get key

					verify [
						any [
							...
						][
							report :key 'required [uppercase form key " is Required"]
						]
						...
					]

					packet/(key): either none? value [spec/default][value]
				]


	foreach cell collect [
		while [cell: find para <br />][
			keep/only copy/part para cell
			para: next cell
		]
		keep/only copy para
	][
		emit either header [<th>][<td>]
		emit-inline cell
		emit either header [</th>][</td>]
	]


		add: func [fragment][
			foreach part fragment [
				switch/default type?/word part [
					string! [emit part]
					get-word! [emit form-value get :part]
				][
					switch/default part [
					...
					][make error! join "Don't Know What This Is: " mold part]
				]
			] 
		]


		foreach [name database] schema [
			...

			foreach [name table] database/tables [
				...
				foreach [name field] table/fields [
					result/add-field field
				]
				...
			]

			foreach [name view] database/views [
				...
				result/add-tables view/tables
				result/add-expression view/expressions
				result/add [next feed]
			]
		]

		return: has [rel][
			foreach [name database] out [
				foreach [name table] database/tables [
					foreach [name field] table/fields [
						if rel: field/rel [
							unless rel: all [
								find out/(database/name)/tables rel/1
								find out/(database/name)/tables/(rel/1)/fields rel/2
								out/(database/name)/tables/(rel/1)/fields/(rel/2)
							][throw make error! join "Could Not Find Relation: " [field/rel/1 "/" field/rel/2]]
							field/type: rel/type
							field/width: rel/width
						]
					]
				]
			]

			out
		]



; over 2 series
	foreach word next words [
		type: type?/word pick vals 1 
		str: form word 
		if any [
			...
		] [
			str: form-pad word 15 
			...
		] 
		vals: next vals
	] 


	foreach [name values] out [
		new-line/all/skip values true 2
		foreach [name values] values [
			either tail? skip values 6 [
				new-line/all values false
			][
				new-line/all/skip values true 4
			]
		]
	]

; bulk application ?
; map into 2 destinations
        foreach pt data-blk [
            insert tail x-data pt/1
            insert tail y-data pt/2
        ]

; map into 2 destinations
        foreach room user-rooms [
            put rooms room/name room/id
            append either room/oneToOne [names/users][names/rooms] room/name
        ]

; tricky map
    foreach message messages [
        user: message/fromUser/username
        ...
        append users/:user/messages message
    ]



; map into 2 destinations
    foreach [word value] body [
        append words word
        append/only values :value
    ]

