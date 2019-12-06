; 7 inplace maps
; 15 counters

                    foreach i next blk [
                        append face/colors load-image i
                    ]

                foreach x choices [append iter-face/flat-texts x]



    foreach name block [append list load-stock name] 


        foreach idx cor* [
            append dadis* index? find def idx
        ] 


        foreach idx sidx* [
            row: pick data* idx 
            insert/only tail face/output make block! length? dadis* 
            foreach col dadis* [
                set/any 'val either block? row [pick row col] [row] 
                insert/only tail last face/output 
                case [
                	...
                ]
            ]
        ]


        values: make block! length? words-of obj 
        foreach [word value] body-of obj [
            repend/only values [
                word 
                either all [series? :value greater? index? :value length? head :value] [
                    "Past End"
                ] [
                    form :value
                ]
            ]
        ] 

; in place
                    foreach file picked [insert file dir-path] 

; in place
    foreach rule rules [
        if word? :rule [rule: get rule] 
        switch type?/word :rule [
            integer! [
                pad: rule 
                ...
            ] 
            string! [out: change out rule] 
            char! [out: change out rule]
        ]
    ] 

; counter
            foreach [key value] input-value [
                i: i + 1 
                face/emit compose/deep [
                    selector-toggle (face/color) (as-pair face/widths/:i face/size/y) (value) of 'selection [
                        dirty-face face 
                        do-face face/parent-face none 
                        validate-face face/parent-face
                    ] with [
                        var: (to-lit-word key)
                    ]
                ]
            ]

; counter
            foreach [key value] input-value [
                i: i + 1 
                face/emit compose/deep [
                    multi-selector-toggle (widths/:i) (value) (clr) [
                        dirty-face face 
                        do-face face/parent-face none 
                        validate-face face/parent-face
                    ] with [var: (to-lit-word key)]
                ]
            ]


; counter
            foreach [key value] input-value [
                i: i + 1 
                face/emit compose/deep [
                    radio-line (value) of 'selection with [
                        var: (to-lit-word key)
                    ] [
                        dirty-face face 
                        do-face face/parent-face none 
                        validate-face face/parent-face
                    ]
                ]
            ]

; counter
            foreach [key value] input-value [
                i: i + 1 
                face/emit compose/deep [
                    check-line (value) with [
                        var: (to-lit-word key) 
                        ...
                    ] [
                        ...
                    ]
                ]
            ]

                        foreach [word string] get in get-opener-face 'setup [
                            insert/only tail data reduce [string word]
                        ]

; counter
            foreach [pane text] input-value [
                i: i + 1 
                face/emit compose/deep [
                    tab-button (text) of 'selection [
                        set-face/no-show face/parent-face (to-lit-word pane) 
                        do-face face/parent-face none
                    ] with [
                        var: (to-lit-word pane)
                    ]
                ]
            ]

                        foreach pos face/selected [
                            append/only vals pick head face/data pos
                        ] 

                        foreach val case [
                            object? :value [
                                reduce [:value]
                            ] 
                            block? :value [
                                :value
                            ] 
                            none? :value [
                                []
                            ]
                        ] 
                        [
                            append/only face/data make face/prototype val
                        ] 

                    foreach word face/column-order [
                        append face/names uppercase/part form word 1
                    ]

; counter
			foreach obj objs [
				i: i + 1
				if all [in obj 'menu block? obj/menu] [
					append menus compose/deep [at 0x0 menu-items with [source: [(obj/menu)]]]
				]
				emit compose/deep [
					...
				]
			]


; counter
				foreach item self/source [
					id: id + 1
					name-face/text: item/name
					x: max x 50 + name-face/para/origin/x + first size-text name-face
					append offsets
						either item/name [
							sub-face/size/y
						][
							separatorface/size/y
					]
					...
				]

foreach [word style] vid-styles [
	repend style-previews ['no-display [test-frame [box "?"]]] ; for styles that have no init block
	all [
;		style/size
		style/init ; only styles that have an init block are allowed in
		repend style-previews [word reduce ['test-frame reduce [word]]]
	]
]

		foreach arg args [keep make-bulk arg]

		foreach checksum reduce [code-checksum test-checksum] [
			append log-file "_"
			append log-file copy/part skip mold checksum 2 6
		]


    s: head clear skip foreach v b [insert tail s rejoin [form v c]] negate length? c

	foreach text selected-face/texts [
		append txt rejoin [text newline]
	]

			foreach val first blocks [
				either only [
					keep recombine/into/only  next blocks  append/only copy start val
				][
					keep recombine/into  next blocks  append copy start val
				]
			]

			foreach val compose [(pick spec 2)] [	; pick instead of path syntax prevents func evals
				either object? :val [
					keep recombine-object-words/into  construct copy skip spec 2  append/only copy base :val
				][
					;if function? :val [print ['FUNC! mold :val]]
					keep recombine-kv/into  skip spec 2  append/only copy base :val
				]
			]


		foreach spec recombine-kv/into body-of obj any [start copy []] [
			if block? spec [spec: construct copy/deep spec]
			keep spec
		]

        foreach rec src-data [
            dbg*: :rec
            repend/only _DATA_ [
                rec/:DL_COL_State
                rec/:DL_COL_County
                to integer! rec/:DL_COL_Year
                rec/:DL_COL_Commodity
                to integer! rec/:DL_COL_Harvested
                rec/:DL_COL_Harvested_unit
                any [attempt [to decimal! rec/:DL_COL_Yield] 0]  ; to integer! returns 0 for "", but to decimal! errors out on it.
                rec/:DL_COL_Yield_unit
                to integer! rec/:DL_COL_Production
                rec/:DL_COL_Production_unit
            ]
        ]

            foreach item X [
                append result get-clause-vars item
            ]

        foreach item vars [
            append result compose [(to-set-word item)]
        ]

        foreach item local [
            append save either value? item [
                get item
            ][
                none
            ]
        ]

            foreach [item1 item2] base [
                insert tail result item2
            ]

  foreach entry cookies
  [
    cookie: copy []
    parse entry [ name-val [some optionals]]
    append/only cookie-list cookie
  ]

foreach file files
[
  append distrib remove read/lines join to-file file ".r"
]

            foreach element value [
                insert insert tail result pdf-form/only element #" "
            ]


        foreach item xref' [
            insert tail pos reduce [
                zero-padded item/1 10 " 00000 " item/2 " ^/"
            ]
        ]

            foreach object contents [
                insert tail result object/to-pdf
            ]


                foreach text next val1 [
                    emit-line
                    typeset-text text
                ]

; counter
        foreach font used-fonts [
            insert tail font-resources reduce [to-refinement font i 0 'R]
            insert tail pdf-spec compose/deep [
                obj (i) [
                    #<< /Type /Font
                        /Subtype /Type1
                        /BaseFont (to-refinement font)
                        /Encoding /WinAnsiEncoding
                    #>>
                ]
            ]
            i: i + 1
        ]

; counter
        foreach [name image] used-images [
            insert tail image-resources reduce [to-refinement name i 0 'R]
            insert tail pdf-spec compose/deep [
                image (i) (i + 1) (image)
            ]
            i: i + 2
        ]

; counter
        foreach page pages [
            insert tail kids reduce [i 0 'R]
            mediabox: reduce [0 0 mm2pt page/size/1 mm2pt page/size/2]
            stream: clear []
            insert tail stream compose [(mm2pt 1) 0 0 (mm2pt 1) (mm2pt page/offset/1) (mm2pt page/offset/2) cm]
            foreach object page/contents [
                insert tail stream object/to-pdf
            ]
            insert tail pdf-spec compose/deep [
                obj (i) [
                	...
                ]

                stream (i + 1) [
                    (stream)
                ]
            ]
            i: i + 2
        ]


            
        foreach val data [
            append pcts (to-decimal val / sum)
        ]


        foreach group groups [
            obj: make swagger-path-item-proto []
            foreach res group/resources [
                keep apib-resource-to-swagger-path group res
            ]
        ]


        foreach param parameters [
            obj: make swagger-parameter-proto [
                ...: param/...
            ]
            keep obj
        ]


        foreach obj objects [keep get in obj 'value]


        foreach ex examples [
            foreach req ex/requests [
                keep apib-request-to-swagger-param req uri-template
            ]
        ]


        foreach ex examples [
            foreach resp ex/responses [
                keep apib-response-to-swagger-response resp
            ]
        ]


		foreach [opt clr] options [
			box1: copy/deep box
			box1/text: to-string opt
			box1/color: get clr
			box1/offset/y: ofy 
			ofy: ofy + box/size/y
			append legend/pane  box1
		]

		foreach [where what] [datatypes which typesets which colors opt/2][
			append opt-lay compose/only/deep [
				drop-list data (split form get where space) 
				with [
					flags: 'scrollable 
					selected: either found: find (where) (what) [index? found][none]
				] on-change [
					...
				]
			]
		]

		foreach [type color] options [
			repend legend-VID/3 ['bx to-string type color]
		]

				foreach arg inf/arg-names [
					i2: index? s2: arg-scope s1 inf/args/:arg
					while [find ws s1/1][s1: next s1]
					i1: index? s1
					repend rt/data [as-pair i1 i2 - i1 'backdrop clr: clr - 30]
					s1: :s2
				]

				foreach ref either word? fnc [next fn][skip fn length? fnc] [
					if 0 < length? refs: inf/refinements/:ref [
						foreach type values-of refs [
							i2: index? s2: arg-scope s1 type
							while [find ws s1/1][s1: next s1]
							i1: index? s1
							repend rt/data [as-pair i1 i2 - i1 'backdrop clr: clr - 30]
							s1: :s2
						]
					]
				]


						data: collect [foreach fnt exclude words-of fonts: system/view/fonts [size] [keep fonts/:fnt]]

										foreach point points [append ctrl-points compose [circle (point) 5]] 

; counter
		foreach j colors [
			append pallette compose/deep [
				clr (j) extra (to-lit-word j)
			]
			if (x: x + 1) % 9 = 0 [append pallette 'return]
		]


		foreach name block [append list load-stock name]

	collect [
		if m: index/:w [
			foreach f keys-of m [
				foreach l m/:f [
					keep reduce [f l]
	]	]	]	]

				foreach [file line] data [
					keep line: rejoin [form to-local-file file "/" line]
					; unless line = prev [keep line]   can't skip yet or will be unable to find index in data
					prev: line
				]

					foreach item lbls [
						append labels item
						append labels rejoin ["("  plug/valve/links/labeled plug item ")"]
					]


				foreach subordinate compose [(subordinate)] [
					if object? subordinate [
						vprint ["linking to : " subordinate/valve/type]
					]
					....
				]

						foreach subordinate plug/subordinates [
							if object? subordinate [
								if (found? blk: find subordinate/observers plug) [
									remove blk
								]
								vprint ["Unlinked from plug (" subordinate/sid ")"]
							]
							append rval subordinate
						]

						kids: collect [
							foreach kid compose [(any [:result []])][
								keep kid
							]
						]

						result: collect [
							foreach kid kids [
								keep kid/get-by-tag selector/2
							]
						]

						kids: collect [
							foreach kid compose [(any [:result []])] [
								keep kid/attributes
								keep kid/children
							]
						]

								result: collect [foreach kid kids [keep/only kid/value]]

									foreach [class db] next next so-db [
										keep class
									]

						data: to-json collect [
							foreach [class db] next next so-db [
								keep class
							]
						]

			foreach message unread/chat [
				found?: false
				foreach face pane/1/pane [
					found?: found? or equal? message face/extra
				]
				unless found? [keep message]
			]


	foreach message messages [
		body: rich-text/info emit-rich marky-mark message/text 530
		append out compose/deep [
			...
		]
	]

	foreach commit commits [
		append output rejoin [
			asterisk space open-block strip-newline commit/commit/message close-block
			open-paren commit/commit/url close-paren
			newline newline
		]
	]

	foreach issue issues [
		append output rejoin [
			asterisk space open-block issue/number close-block
			open-paren issue/html_url close-paren
			colon space issue/title
			newline newline
		]
	]


		foreach char text [
			char-size: size-text/with face form char
			if char-size/y > line-height [line-height: char-size/y]
			x-pos: x-pos + char-size/x
			case [
				whitespace? char (
					append word char
					...
				)
			]
		]


    foreach move these-moves [
        legal-moves: append/only legal-moves compose[(piece-to-letter thispiece) " " 
                    (field-to-a1h8 i) " " (field-to-a1h8 move)]  
    ]

      foreach char cif/word-index-block/1 [
         append index-info/top-index to-string char
      ]

   foreach tag cif/word-index-block/1 [
     append cif/admin/dirty-tags to-string tag
     ]

   foreach [document-name words] db [
      append doc-ids _make-document-id document-name
   ]

   foreach w all-words [
      temp: copy []
      append inverted-list form w
      for nn 2 length? db 2 [
         if w = db/:nn/1 [
            insert temp pick doc-ids (nn / 2) ;; document id
            poke db nn next db/:nn
         ]
      ]
      append/only inverted-list temp
   ]


   foreach e doc-ids [
      insert ent-block pick cif/document-list e
   ]

      foreach [word index] wb [
         append word-list join current-word word
         if document-list [append/only word-list sort _map-to-doc-names _unpack-numset index]
      ]


			foreach [action code] body [
				all [
					remove pos: find/reverse tail when action	; remove the action word!
					block? pick pos 1		; followed by an action block! ?
					not word? pick pos -1	; and not shared by another action word! ?
					remove pos				; safe! one can remove the action block!
				]
				repend when [action code]
			]

	collect [
		foreach :ws alts [
			parse expr': copy/deep expr rule: [any [
				p: any-word! (
					foreach w ws [
						if w = p/1 [
							change p do pick
								[ [to type? p/1 get w] [get w] ]
								any-word? get w
						]
					]
				)
			|	ahead [block! | paren! | any-path!] into rule
			|	skip
			]]
			keep new-line expr' yes
		]
	]

					foreach [aid dist] ass [lookup! [id: aid  keep dist keep title]]

			foreach w words-of face/internal-actors [
				keep compose/deep [
					(to set-word! w) func [fa ev /local f] [
						f: select fa/internal-actors quote (w)  f fa ev
						if f: select fa/user-actors quote (w)  [f fa ev]
					]
				]
			]

				foreach w system/catalog/accessors/event! [
					keep compose [(to set-word! w) (to path! reduce ['ev w])]
				]


			foreach ln s-doc [								;-- output all lines
				repend r [cols1-4 ln #"^/"]
				replace/all cols1-4 [skip] #" "
			]


; deep map
	flatten: function [block [any-block!] /with out /local b][
		out: any [out clear []] 
		foreach b block [either any-block? b [flatten/with b out][append out b]] 
		out
	] 

	foreach join [miter bevel round] [
		append line-joins compose/deep [
			box 22x22 with [extra: (to-lit-word join)] draw [
				pen gray box 0x0 21x21 pen black line-join (join) anti-alias off line-width 5 line 4x4 15x15 4x15
			][
				...
			]
		]
	]

	foreach cap [flat square round] [
		append line-caps compose/deep [
			box 22x22 with [extra: (to-lit-word cap)] draw [
				pen gray box 0x0 21x21 pen black line-cap (cap) anti-alias off line-width 5 line 5x10 16x10
			][
				...
			]
		]
	]

        empty? remove -team-: collect [
            foreach team words-of teams: make map! lock teams [
                keep '| keep team
            ]
        ][
            make error! "No Teams"
        ]


        empty? remove -player-: collect [
            foreach [nick name email paid] players [
                keep '| keep to lit-word! nick
            ]
        ][
            make error! "No Players"
        ]


        players: make map! collect [
            foreach [nick name email paid] players [
                keep nick
                keep make player! compose/only [
                    nick: (to lit-word! nick)
                    name: (name)
                    email: (email)
                    paid: (paid)
                    picks: (make block! 10)
                    points: 0
                ]
            ]
        ]


                            collect [
                                    for-each player week/starters [
                                        players/:player/points: players/:player/points - 1
                                        if players/:player/points < 2 [
                                            players/:player/fell: _
                                            remove find week/eliminated player
                                            keep player
                                        ]
                                    ]
                            ]


        unspaced remove collect [
            foreach player words-of players [
                keep ",^^/" keep players/:player/name keep " <" keep players/:player/email keep ">"
            ]
        ]

        unspaced remove collect [
            for-each player this-week/undecided [
                keep ", " keep nickname-of player
            ]
        ]

				foreach [word effect] blk [
					; redefine the args so we have two local words to use.
					args: [new args /local tmp val]
					if block? words: pick effect 1 [
						vprint ["will add words : [" words "] to local vars of facet func"]
						args: append copy args words
					]
					insert insert self/words word f: func args effect
				]

							foreach item flist [
								dirpath: to-file append copy dir item
								append blk reduce compose/deep copy [
									'file to-string item [
										face/parent-face/parent-face/browse-path face/dirpath
									]
									'with [dirpath: (dirpath)]
								]
							]

		foreach button button-text [
			append buttons compose [ button (button) (either def-button = button [gold][])[ctx/answer: face/text hide-popup]]
		]

				foreach line (parse/all data "^/") [
					append blk compose [lvtext as-is (line)]
				]


						foreach item sort next first data [
							; special case for unset values
							either error? item-data: try [item-data: get in data item][
								...
							][
								switch/default type?/word :item-data [
									...
								][
									append vblk compose/deep [toggletext 50 (rejoin [to-string item " (" type?/word :item-data ")"]) with [idata: (:item-data)] [inspect get in face 'idata (to-string item) (depth + 1)]]
								]
							]
						]


							foreach item extract data 2 [
								; special case for unset values
								either error? item-data: try [item-data: select data item][
									item-data: disarm item-data
									either item-data/id = 'no-value [
										...
									][
										to-error item-data
									]
	
								][
									switch/default type?/word :item-data [
										...
									][
										append vblk compose/deep [toggletext 50 (rejoin [to-string item " (" type?/word :item-data ")"]) with [idata: (:item-data)] [inspect get in face 'idata (to-string item) (depth + 1)]]
									]
								]
							]						

						foreach subordinate plug/subordinates [
							switch/default type?/word subordinate [
								object! [
									append/only blk  subordinate/valve/cleanup subordinate
								]
								word! [
									append/only blk to-word rejoin [subordinate '=]
								]
								none! [
									append blk none
								]
							][
								to-error rejoin ["liquid sid: [" plug/sid "] subordinates block cannot contain data of type: " type? subordinate]
							]
						]

	emit:  func [data /local tmp] [
		foreach [dialectword item] reduce data [
			pif [
				dialectword == 'textbox	[
					if (type? item) = string! [item: reduce [item]]
					tmp: precalc-textbox 200 item
					append pdf reduce [dialectword 10 y-textpos 200 10 item] y-textpos: y-textpos - tmp
				]
				true [print ["Unknown tag found:" dialectword item]]
			]
		]
	]

		foreach tmp value [
			name: tmp/1
			pvalue: tmp/2

			switch/default name [
				parapart 	[append last toemit pvalue]
				bold		[append last toemit compose [font Helvetica-Bold 4.23 (pvalue) font Helvetica 4.23]]
			][print ["2: Unknown INLINE-TAG found:" name]]
		]

            foreach arg result/parsed-spec [
                keep to set-word! arg/word
            ]



        foreach child node/children [
            append-value result :child
        ]


                    foreach value node/children [
                        unless any [none? :separator first-value?] [
                            either block? :separator [
                                emit-production output rules node separator
                            ] [
                                append/only output :separator
                            ]
                        ]
                        first-value?: no
                        either node? :value [
                            i: either no-indent [node/.indent] [next-indent]
                            tree-to-block* output next-stack i value rules
                        ] [
                            append output :value
                        ]
                    ]




                foreach child old-node/children [
                    if node? :child [
                        if transform-node child rules [
                            done?: false
                            modified?: true
                        ]
                    ]
                    append/only node/children :child
                ]


	foreach [ key value ] data [
		if issue? value [ value: next value ]
		repend out [
			to word! key
			#"="
			value
			#"&"
		]
	]

	foreach [ name value ] values [
		skip?: false
		value: switch/default type?/word value [
			block!	[
				if empty? value [ skip?: true ]
				catenate value #" "
			]
			string!	[ if empty? value [ skip?: true ] value ]
			none!	[ skip?: true ]
		][
			form value
		]
		unless skip? [
			repend tag [ to word! name {="} value {" } ]
		]
	]


				foreach item data [
					current: copy/deep element
					foreach value values [
						replace-deep current value item
						; FIXME: won't work for multiple values
					]
					if offset [
						insert skip find current 'col 2 reduce [ 'offset offset ]
						offset: none
					]
					append out current
				]



		foreach value data [
			append out append copy content value
		]


				foreach prefix [-webkit- -moz- -ms- -o-][
					keep form-property to word! join prefix form property values
				]

			foreach [property values] values [
				case [
					find [opacity] property [
						if tail? next values [insert values '*]
					]
					all [
						property = 'background-image
						find [radial linear] values/1
					][
						foreach prefix [-webkit- -moz- -ms- -o-][
							keep form-property/inline property copy values prefix
						]
					]
					
				]
				switch/default property [][
					keep form-property property values
				]
			]

			foreach transform transformations [
				transform: form-transform transform
				keep form-property/vendors 'transform transform
			]


					foreach transition transitions [
						keep ","
						keep form-values transition
					]

; in place
		foreach [from to][
			[no repeat] 'no-repeat
			[no bold] 'normal
			[no italic] 'normal
			[no underline] 'none
			[inline block] 'inline-block
			[line height] 'line-height
		][
			replace value from to
		]

				foreach selector selectors [
					parse selector [
						set selector block! (selector: map-each element selector [form-element element])
						any [
							'with mark block! capture (
								selector: collect [
									foreach selector selector [
										foreach element captured/1 [
											keep join selector form-element element
										]
									]
								]
							) |
							'has mark block! capture (
								selector: collect [
									foreach selector selector [
										foreach element captured/1 [
											keep rejoin [selector " " form-element element]
										]
									]
								]
							)
						]
					]
					keep/only selector
				]


				foreach selector selectors [
					foreach rule selector [
						keep "," keep "^/"
						keep rule
					]
				]

			foreach [selector rule] rules [
				keep selector
				keep " "
				keep rule/render
				keep "^/"
			]



foreach [id code][
	unknown-user 	["Unknown user:" :arg1]
	wrong-password 	["Wrong password"]
	user-exists 	["User" :arg1 "already exists"]
][
	append system/catalog/errors/access reduce [id code]
]

	foreach set required [
		append chars this set
	]



		foreach value block [repend with [value delimiter]]


			foreach word words-of user-ctx [
				repend user-words [to lit-word! word '|]
			]


		foreach file needs [
			file: to file! join file %.reb
			print [header/name " == needs == " file]	
			module-file: load/header/type file 'unbound
			mod-header: take module-file
			append module-cache compose/deep [
				comment (rejoin ["Import file " file " for " script-name ":" checksum/method to binary! mold module-file 'SHA1]) 
				import module [(body-of mod-header)] [(preprocess-script file module-file)]
			]
		]

foreach plugin plugins [
	repend plugin-cache [
		to word! first parse plugin #"."
		load join %plugins/ plugin
	]
]


			foreach item data [
				current: copy/deep element
				replace-deep current value item
				if offset [
					insert skip find current 'col 2 reduce [ 'offset offset ]
					offset: none
				]
				append out current
			]

; is this flattening a block of blocks?
			result: copy []
			foreach row data [
				append result row
			]


					foreach col columns: to block! columns [
						append part/2 either integer? col [
							all [not ignore any [col < 1 col > cols] settings/error reform ["invalid /part position:" col]]
							compose [(append to path! 'row col)]
						] [col]
					]

		either part [
			part: copy []
			foreach width widths [
				append/only part reduce [pos width]
				pos: pos + width
			]
			foreach col to block! columns [
				append spec compose [trim/lines copy/part at line (part/:col/1) (part/:col/2)]
			]
		] [
			foreach width widths [
				append spec compose [trim/lines copy/part at line (pos) (width)]
				pos: pos + width
			]
		]

; in place
							foreach [code char] [
								{&amp;}		{&}
								{&lt;}		{<}
								{&gt;}		{>}
								{&quot;}	{"}
								{&apos;}	{'}
							] [replace/all s code char]

		foreach col columns [
			append code compose [(append to path! 'row col)]
		]

			either default [
				foreach row outer [
					all [
						i: (either settings/build = 'r2 [[select-map]] [[select]]) map row/:key1
						append row inner/:i
					]
					append/only blk reduce [(code)]
				]
			] [
				foreach row outer [
					all [
						i: (either settings/build = 'r2 [[select-map]] [[select]]) map row/:key1
						append row inner/:i
						append/only blk reduce [(code)]
					]
				]
			]

				foreach row data compose [
					(
						either where [
							either settings/build <> 'red [
								compose/deep [all [(condition) append/only blk (columns)]]
							] [
								bind compose/deep [all [(condition) append/only blk (columns)]] 'row
							]
						] [
							compose [append/only blk (columns)]
						]
					)
				]


					foreach row data [
						either group = row [i: i + 1] [
							append group i
							append/only blk group
							group: copy row
							i: 1
						]
					]

; in place
						foreach row either headings [next stdout] [stdout] [
							foreach i to block! columns [
								row/:i: to integer! row/:i
							]
						]


		foreach row data compose/deep [
			s: copy ""
			foreach value row [
				append s (
					either %.csv = suffix? file [
						[rejoin [either any [find val: trim/with form value {"} "," find val lf] [rejoin [{"} val {"}]] [val] ","]]
					] [
						[rejoin [value "^-"]]
					]
				)
			]
			take/last s
			any [empty? s append b s]
		]


				foreach row block [
					append blk "<row>"
					foreach value row [
						append blk case [
							...
							true [
								foreach [char code] [
									"&"		"&amp;"
									"<"		"&lt;"
									">"		"&gt;"
									{"}		"&quot;"
									{'}		"&apos;"
									"^/"	"&#10;"
								] [replace/all value char code]
								...
							]
						]
					]
					append blk "</row>"
				]


				foreach part split-multipart string boundary [
					keep parse-part part
				]


		foreach value block [
			append list rejoin [mold value #","]
		] 

		foreach [key value] body-of data [
			repend obj [mold key space mold value #"," space]
		] 


        foreach word words-of locals [
            insert body reduce [to set-word! word locals/:word]
        ]


	block: collect [
		foreach value block [keep reduce [to lit-word! value '|]]
	]
	also block take/last block


		foreach [type species pre-act act] values [
			length: 8
			do pre-act
			value: select type-templates type
			value: any [pick value species first value]
			value: func [length] value
			value: value length
			if action [value: do action]
			append/only results value
		]

	foreach line data [
		loop absolute value [
			case [
				; indent
				indent? [insert line tab]
				; unindent
				all [not indent? equal? first line #"^-"] [remove line]
				all [not indent? equal? copy/part line sz tab] [remove/part line sz]
			]
		]
		; process output
		append out line
		append out newline
	]


	collect [foreach [tag content attributes] data [keep tag]]

	result: collect [
		foreach [t c a] results [keep reduce [get-text c/a rejoin [http://www.google.com select c/3 "href"]]]
	]

			foreach [t col a] headers [
				col: get-text col
				if trim [col: system/words/trim/lines form col]
				keep col
			]

		foreach [t row a] table [ ; row
			keep/only collect [
				foreach [t cell a] row [
					if cell: get-text cell [
						if trim [cell: system/words/trim/lines form cell]
						keep cell
					]
				]
			]
		]

	foreach line log [
		append result parse-line line
	]

	foreach line data [
		value: pick line column
		unless find result value [append result value]
	]

; deep map
		foreach file dir [
			either dir? file [
				append dirs file
				scan-dir to file! dirs
				take/last dirs
			] [
				scan-file filepath: append to file! dirs file
			]
		]


	foreach value data [
		files/(form value): make map! reduce [quote content: read value]
	]

		collect/into [
			foreach value data [
				keep rejoin [escape-value/with value delimiter delimiter]
			]
		] output: make string! 1000

		foreach value data [
			append columns difference columns words-of value 
		]

			append output to-csv-line collect [
				foreach key keys [keep data/:key/:index]
			] delimiter

; map buildup
			foreach key header [
				key-index: key-index + 1
				out-map/:key: make block! length? output
				foreach line output [append out-map/:key line/:key-index]
			]

		types: unique collect [foreach value data [keep type? value]]

			append output collect/into [
				foreach value data [
					; construct block
					line: collect [
						foreach column columns [
							keep value/:column ; FIXME: this can be problematic when key isn't in object
						]
					]
					keep to-csv-line line delimiter
				]		
			] make string! 1000

			collect/into [
				foreach line data [
					keep to-csv-line line delimiter
				]
			] make string! 1000

		data: collect/into [
			foreach key keys-of data [
				keep rejoin [key #"=" enquote data/:key space]
			]
		] clear ""



					foreach word words-of data [
						encode-into word buffer
						append buffer #":"
						encode-into data/:word buffer
						append buffer #","
					]

					foreach v data [
						encode-into v buffer
						append buffer #","
					]

; counter
	foreach [test result] tests [
		repend output either equal? xml-lite/decode test result [
			["Test #" index " passed." newline]
		] [
			["Test #" index " failed." newline]
		]
		index: index + 1
	]

; in place
	foreach [code msg] http-responses [
		insert msg rejoin ["HTTP/1.1 " code #" "]
		append msg crlf
	]


			foreach [name phase] phases [
				append out reform ["phase:" name #"^/"]
				cnt: 0
				foreach [mod fun] phase [append out rejoin [tab cnt: cnt + 1 #"." mod newline]]
			]		


					foreach method list [
						insert tail buf form method
						insert tail buf ", "
					]


		foreach [name extapp] actives [	
			if all [
				url: select extapp/specs 'url
				scheme = get in parse-url url 'scheme
			][
				foreach app extapp/instances [
					ctx: service/client				
					defs: repend any [defs make block! 2][
						...
					]
					loop any [select extapp/specs 'channels 1][
						...
					]
				]
				append out name
			]
		]


			foreach item pick pos 4 [			
				either block? item [					
					...
				][
					insert tail out item
				]
			]

			foreach item head list [
				insert tail out item
				insert tail out slash
			]

			foreach ext to block! args/2 [			
					ext: mold ext
					if dot = first ext [remove ext]
					append sm to word! ext
			]			

			foreach ext to-block args/2 [
				repend service/handlers [ext args/1]
			]

		foreach name conf/2 [
			name: to-word join "mod-" name
			append svc/mod-list name
			file: join svc/mod-dir [name ".r"]	
			if svc/verbose > 0 [log/info ["Loading extension: " mold :name]]		
			append svc/mod-list do-cache file
		]


			foreach-nv-pair content [
				insert tail out name
				insert tail out #"="
				insert tail out url-encode any [
					all [any-string? value value]
					form value
				]
				insert tail out #"&"
			]


foreach [name url] value [repend databases/global [name url make block! 1]]


		foreach [name value] data/in/headers [
			insert tail soc/other-headers http-encode name
			insert tail soc/other-headers value
		] 


    foreach [pattern production] rules [
        insert insert/only insert/only tail rules* pattern make paren! compose/only [
            prod: compose/deep (production)
        ] '|
    ] 


; in place
                    foreach [from to] [
                        color! [issue! refinement! tuple!] 
                        percent! money! 
                        comma-pair! block!
                    ] [
                        replace rule from to
                    ]

            foreach col table/columns [
                insert/only tail content either col [reduce ['column 'opts make-style col]] [[column]]
            ] 

                        foreach cell next val/content [
                            insert insert tail index " " cell
                        ] 


                    foreach row val/contents [
                        clear locals 
                        bind-var locals var row 
                        insert tail result rewrite copy/deep body rewrite-rules
                    ]


; over 2 series
                        foreach var vars [
                            insert insert tail local form var row/1 
                            row: next row
                        ]


                    foreach row rows [
                        clear locals 
                        bind-var locals var row 
                        insert tail result rewrite copy/deep body rewrite-rules
                    ]

; counter
                        foreach var vars [
                            cell: pick row/contents i 
                            if cell/type = 'span [cell: cell/reference] 
                            insert insert tail locals form var cell 
                            i: i + 1
                        ]



        foreach [header string] skip doc 2 [
            while [string: find/tail string text] [
                insert insert/only tail res header copy/part skip string -50 120
            ]
        ] 


    dialect-rule: collect [
        for-each command lib/commands [
            keep/only command/dialect-rule keep '|
        ]
    ]

    foreach [word string] headers [
        repend result [mold word #" " string CRLF]
    ]

            params: sort/skip unique/skip collect [
                for-each [key value] body-of make oauth any [:params []][
                    keep to word! key
                    keep switch/default type-of value [
                        issue! [to string! to word! value]
                    ][
                        value
                    ]
                ]
            ] 2 2


    foreach [key data] bot-expressions [
        repend tmp [key data/1]
    ]

    foreach [key description] tmp [
        repend out ajoin [key { "} description {"^/}]
    ]

                    foreach result out [
                        append html reword message-template reduce [
                            'time_stamp from-now unix-to-date result/1
                            'user_name result/2
                            'message_id result/3
                            'user_id result/4
                            'content result/5
                        ]
                    ]

    foreach [user data] about-users [
        append visitors form user
    ]


env: collect [
    for-each w words-of cgi [
        keep get-env w 
    ]
]

            foreach [user url] tmp [
                append about-users user
                tz: either rec: select was-about-users user [
                    rec/2
                ] [_]
                repend/only about-users [url tz]
            ]


        sort/skip collect [foreach command commands [keep command/help-string keep newline]] 2


    foreach [user address] about-users [
        append tmp user
    ]

        foreach item port/state/inBuffer [
            buffer: insert* buffer port/handler/to-sub-record port item
        ]

                foreach item first result [
                    repend port/locals/cols [to-word item copy* []]
                ]


            foreach item port/locals/cols [
                if block? item [
                    item: first item
                ]
                item: to-string item
                append line sep
                append line item
                sep: port/locals/delimiter
            ]

        foreach item head port/state/inBuffer [
            line: clear []
            sep: ""
            foreach jtem item [
                if none? find [integer! decimal! date! time!] type? jtem [
                    jtem: to-string jtem
                    jtem: replace/all to-string jtem {"} {""}
                    ...
                ]
                append line sep
                append line jtem
                sep: port/locals/delimiter
            ]
            append port/sub-port line
            append port/sub-port newline
        ]


        foreach item cols [
            set [item1 item2] to-block item
            either item1 = '* [
                foreach [item1 item2] from [
                    foreach item get-cols item2 port [
                        item: first to-block item
                        insert*/only tail result to-path reduce [item1 item]
                    ]
                ]
            ][
                either item2 = '* [
                    item2: first select/skip from item1 2
                    foreach item get-cols item2 port [
                        item: first to-block item
                        insert*/only tail result to-path reduce [item1 item]
                    ]
                ][
                    insert*/only tail result item
                ]
            ]
        ]


                foreach item to-record values false [
                    set [(cols)] item
                    insert*/only tail rows reduce [(spec)]
                ]

; is this a block flattening?
        foreach item get-cols table port [
            append spec item
        ]

        foreach item get-cols table port [
            append result either block? item [ first item ][ item ]
        ]

                foreach [table spec] third port/locals/table [
                    append file rejoin ["[" to-word table "]"]
                    schema: third make sql-text select spec to-set-word 'schema
                    foreach [name value] schema [
        		        name: lowercase to-string name
		                switch/default name [
		                	...
                        ][
                            append file rejoin ["" name "=" value]
                        ]
                    ]
                ]

; map into 2 destinations
				foreach column columns [
					insert tail blk either column = 'rowid [
						copy [insert tail buffer rowid]
					][
						compose [
							insert/only tail buffer pick skip data rowid - 1 * (tables/:table/cols) (tables/:table/offsets/:column)
						]
					]
				]


; map into 2 destinations
			foreach column columns [
				insert tail blk either column = 'rowid [
					compose [insert tail buffer to-rowid pos - (offset) + 1 (tables/:table/cols)]
				][
					compose [insert/only tail buffer pick file pos - (offset) + (tables/:table/offsets/:column)]
				]
			]


		foreach column tables/:table/columns [
			insert tail buffer reduce [
				column
				type? pick tables/:table/data tables/:table/offsets/:column
			]
		]

		foreach [table blk] tables [
			insert tail buffer reduce [
				table
				tables/:table/cols
				tables/:table/rows
				tables/:table/sorted?
				to-date first parse form tables/:table/loaded "+"
				to-date first parse form tables/:table/accessed "+"
				tables/:table/accesses
				tables/:table/dirty?
			]
		]


		foreach column columns [
			insert tail offsets tables/:table/offsets/:column
		]


			foreach column exp-columns [
				insert tail blk compose [pick data (tables/:table/offsets/:column)]
			]

		foreach column columns [
			insert tail page rejoin ["<th>" column "</th>"]
		]


    foreach topic database [
        append topics first topic
    ]

        foreach [message name time] (at pick database t1/cnt 2) [
            append messages rejoin [
                message newline newline name "  " time newline newline
                "---------------------------------------"  newline newline
            ]
        ]

; counter i
; counter j
i: 0
j: 0
foreach item temp [
	j: 0
	++ i	
	title: first item
	temp2: copy item 
	temp2: next temp2
	foreach [post aut date ] temp2 [   
		++ j
		append post reform ["<br> <i>" aut  "</i>"]		
		db-insert archive reduce [i j title  post author date]
	]
]


	foreach [name desc][
		spec   "Returns the spec of a value that supports reflection"
		body   "Returns the body of a value that supports reflection"
		words  "Returns the list of words of a value that supports reflection"
		class  "Returns the class ID of an object"
		values "Returns the list of values of a value that supports reflection"
	][
		repend list [
			load join form name "-of:" 'func reduce [desc 'value] new-line/all compose [
				reflect :value (to lit-word! name)
			] off
		]
	]


	foreach name test-list [
		repend list [
			load head change back tail form name "?:" 'func
			["Returns true if the value is this type" value [any-type!]]
			compose [(name) = type? :value]
		]
	]


	foreach name [
		any-list! any-block! any-function! any-object! any-path! any-string! any-word!
		series! number! immediate! scalar! all-word!
	][
		repend list [
			load head change back tail form name "?:" 'func
			compose [(join docstring head clear back tail form name) value [any-type!]]
			compose [find (name) type? :value]
		]
	]


	foreach name to-list [
		repend list [
			to set-word! join "to-" head remove back tail form name 'func
			reduce [reform ["Convert to" name "value"] 'value]
			compose [to (name) :value]
		]
	]


					foreach [k v] header-data [
						append header-str reduce [#"^-" mold k #" " mold v newline]
					]

	foreach dir dirs [
		path: either empty? path [dir] [path/:dir]
		append path slash
		if error? try [make-dir path] [
			foreach dir created [attempt [delete dir]]
			cause-error 'access 'cannot-open path
		]
		insert created path
	]

                        foreach v next value [
                            append output ",^/"
                            append/dup output indent indent-level
                            red-to-json-value output :v
                        ]


                        foreach v next value [
                            append output #","
                            red-to-json-value output :v
                        ]

                        foreach k next keys [
                            append output ",^/"
                            append/dup output indent indent-level
                            emit-key-value output ": " value :k
                        ]

                        foreach k next keys [
                            append output #","
                            emit-key-value output #":" value :k
                        ]



		foreach val path [
			case [
				issue? val [append out mold val]
				get-word? val [repend out ["/" get/any :val]]
				parse/all form val [["." | ","] to end][append out form val]
				parse/all form val [["`" | "!"] to end][append out back change form val ","]
				refinement? val [append out replace mold val "/" OOGIEBOOGIE]
				val [repend out ["/" form val]]
			]
		]


			remove head foreach key path [insert "" reduce ["." key]]

		day: remove collect [
			foreach day system/locale/days [
				keep '|
				keep copy/part day 3
			]
		]

		month: remove collect [
			foreach month system/locale/months [
				keep '|
				keep copy/part month 3
			]
		]


		locals: collect [
			foreach word locals [
				keep reduce [to set-word! word get/any word]
			]
		]

			foreach i seed [
				seed1: clip-max ((seed1 * 3x1) + seed2)
				seed2: clip-max (seed1 + seed2 + 33x1)
				d: seed1/x / to decimal! max-value/x
				append new to char! floor (d * 31) + 64
			]

		keys: remove rejoin collect [foreach key keys [keep "," keep form-key key]]

		keys: next press collect [
			foreach key words-of packet [keep reduce [", " form-key key "=?"]]
		]


						collect [foreach record result [keep load-record table record]]


				foreach record query-db/named [
					"SELECT * FROM ? LIMIT ?,?"
					to word! table/locals/name
					table/state/index
					table/state/num
				][
					keep load-record table record
				]



			foreach [word value] args [keep to set-word! word keep value]
			foreach [word] any [get in controller/header 'locals []][
				keep to set-word! word
			]

				foreach prefix [-webkit- -moz- -ms- -o-][
					keep form-property to word! join prefix form property values
				]

			foreach [property values] values [
				case [
					find [opacity] property [
						if tail? next values [insert values '*]
					]
					all [...][
						foreach prefix [-webkit- -moz- -ms- -o-][
							keep form-property/inline property copy values prefix
						]
					]
					
				]
				switch/default property [][
					keep form-property property values
				]
			]

			foreach transform transformations [
				transform: form-transform transform
				keep form-property/vendors 'transform transform
			]

			unless empty? transitions [
				keep form-property/vendors 'transition rejoin next collect [
					foreach transition transitions [
						keep ","
						keep form-values transition
					]
				]
			]

			selectors: collect [
				foreach selector selectors [
					parse selector [
						set selector block! (selector: map-each element selector [form-element element])
						any [
							'with mark block! capture (
								selector: collect [
									foreach selector selector [
										foreach element captured/1 [
											keep join selector form-element element
										]
									]
								]
							) |
							'has mark block! capture (
								selector: collect [
									foreach selector selector [
										foreach element captured/1 [
											keep rejoin [selector " " form-element element]
										]
									]
								]
							)
						]
					]
					keep/only selector
				]
			]


			rejoin remove collect [
				foreach selector selectors [
					foreach rule selector [
						keep "," keep "^/"
						keep rule
					]
				]
			]

			foreach [selector rule] rules [
				keep selector
				keep " "
				keep rule/render
				keep "^/"
			]


		press remove collect [
			foreach value list [
				keep comma
				keep form-value value
			]
		]


						foreach field envelop fieldset [
							append/only fields to-path new-line/all reduce [term: to-word term field] false
						]

			foreach tag tags [
				append query slot
				slot: ",(?,?)"
				keep wordify tag
				keep item
			]


		remove head foreach key path [insert "" reduce ["." key]]

		collect [
			if parse document [opt ['options skip] 'para skip 'code set boiler string! to end][
				foreach para parse/all boiler "^/" [
					keep form-para para
				]
			]
		]

; keep-each could get this rid of `keep`
		foreach part para [
			case [
				string? part [keep part]
				integer? part [keep encode-utf8 part]
				switch part [
					<quot> [keep to string! #{E2809C}]
					</quot> [keep to string! #{E2809D}]
					<apos> [keep to string! #{E28098}]
					</apos> [keep to string! #{E28099}]
				][]
				char? part [keep part]
			]
		]

		collect [
			foreach doc read/custom path ["draft!" thru "!" thru "!.rmd" end][
				keep doc
				doc: parse dehex doc "!"
				keep to-date doc/2
				keep doc/3
			]
		]

pivot: func [values [block!] data [block!] /local out reducees][
	out: collect [
		foreach name next values [
			keep name
			keep/only copy []
		]
	]

	reducees: collect [
		foreach name next values [
			keep to lit-word! name
			keep name
		]
	]

	foreach :values data compose/deep [
		foreach [name* values*] reduce [(reducees)][
			foreach value* values* [
				append first any [
					find/tail select out name* value*
					back insert tail select out name* reduce [value* copy []]
				] (values/1)
			]
		]
	]
	...
	new-line/all/skip out true 2
]


	render-each: func [
		'items [word! block!]
		source [series!]
		body [file! string!]
		/whole /with locals /local out
	][
		out: copy ""
		locals: append any [locals copy []] items: envelop items
		foreach :items source compose/only [
			append out do either whole ['render/with]['render/partial/with] body (locals)
		]
		out
	]

			selectors: map-each selector selectors [
				collect [
					foreach selector reverse collect [
						while [find selector 'in][
							keep/only copy/part selector selector: find selector 'in
							keep 'has
							selector: next selector
						] keep/only copy selector
					][keep selector]
				]
			]
