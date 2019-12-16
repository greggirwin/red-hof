; 1 inplace map


	foreach flag [
		1 2 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768
		65536 131072 262144 524288 1048576 2097152 4194304 8388608
		16777216 33554432 67108864 134217728 268435456 536870912 1073741824
	][
		if flag = (port/state/flags and flag) [
			append out any [select flag-defs flag flag]
		]
	]

			foreach [header value] switch type?/word headers [
				block! [headers]
				object! [body-of headers]
			][
				if value [
					keep rejoin [" -H " enquote [form header ": " value]]
				]
			]

				foreach column columns [
					index: index? find columns column

					if case [
						...
					][
						append convert-body append/only compose action head insert at compose [
							change/only at row (index) :tmp
						] 5 handler
					]
				]


						foreach [name value] body-of data [
							unless any [
								unset? value
								none? value
							][
								keep to-attr/data name value
							]
						]

		foreach word words-of object [
			if get :word [
				insert tail header reduce [word ": " get :word newline]
			]
		]

					foreach w words-of system/words [
						if value? w [
							sys-word: mold w
							if find/match sys-word word [
								append result sys-word
							]
						]
					]

			foreach w words [
				sys-word: form w
				if any [empty? word find/match sys-word word] [
					append result sys-word
				]
			]



foreach [name codes width glyph] list [
	if codes/2 > 255 [break]
	if all [
		positive? codes/2
		find selected codes/2
	][
		repend sel [codes/2 glyph]
	]
]


	foreach file read db/base-dir [
		if %.log = suffix? file [
			insert tail log read/lines db/base-dir/:file
		]
	]
								foreach [(tables/:table/columns)] tables/:table/data [
									if (predicate) [insert tail buffer reduce [(columns)]]
									(either find columns 'rowid [copy [rowid: rowid + 1]][copy []])
								]

; map into 2 destinations
        foreach [key data] bot-expressions [
            if all [
                not find used data/2
                find data/1 findstring
            ] [
                link: ajoin ["[" data/1 "](" data/2 "); "]
                either chat-length-limit < add length? out length? link [
                    reply message-id out
                    wait 2
                    out: copy link
                ] [
                    append out link
                ]
                append used data/2
            ]
        ]

; map into 2 destinations
    foreach [key data] bot-expressions [
        if not find used data/2 [
            link: ajoin ["[" data/1 "](" data/2 "); "]
            either chat-length-limit < add length? out length? link [
                ; over chat-length-limit so send what we have
                reply message-id out
                wait 2
                out: copy link
            ] [append out link]
            append used data/2
        ]
    ]

; map into 2 destinations
    foreach [key data] bot-expressions [
        if not find used data/2 [
            if find/part data/2 links length? links [
                link: ajoin ["[" data/1 "](" data/2 "); "]
                ; if adding a new link exceeds allowed, then send current
                either chat-length-limit < tot: add length? out length? link [
                    reply message-id out
                    wait 2
                    ; and reset out to the new link
                    out: copy link
                ] [
                    append out link
                ]
                append used data/2
            ]
        ]
    ]

    foreach msg messages [
        if parse msg [some [thru <content> copy content string! | thru <user_name> copy user string! to end]] [
            if user/1 = username [
                ; found a message we want
                append wanted content
            ]
        ]
    ]


            foreach [header value] body-of oauth [
                if value [
                    repend out [", " form to string! to word! header {="} url-encode form value {"}]
                ]
            ]


				foreach s blk [
					if string? s [repend service/block-list [s 0]]
					if s = 'ip-host [service/block-ip-host?: yes]
				]


				foreach svc [task-master RConsole logger MTA][
					n: services/:svc/port-id
					if all [in-use find in-use n][
						n: n + offset
						until [not find in-use n: n + 1]
						services/:svc/port-id: n
						unless list [list: make block! 8]
						repend list [svc n]
					]
				]

; in place
			foreach line output [
				if longest > length? line [
					append/dup line none longest - length? line
				]
			]


	foreach [id commit] fixes [
		id: to integer! id
		if issue: get-issue-by-number issues id [
			author: issue/user/login
			either authors/:author [
				append authors/:author id ;TODO: or issue directly, let's see
			][
				authors/:author: reduce [id]
			]
		]
	]

	foreach commit commits [
		issue: none
		parse commit/commit/message [thru #"#" copy issue some numbers]
		if issue [repend fixes [issue commit]]
	]

	foreach-node data compose/deep [
		all [
			string? content
			append (ret) content
		]
	]

		foreach [key value] data [
			if any [not only all [only value]] [
				value: to-pct-encoded form value
				keep rejoin bind pattern 'key
			] 
		]

		foreach line deline/lines read-string file compose/deep [
			all [line/1 = #"^L" remove line]
			any [
				empty? trim copy line
				append/only blk reduce [(spec)]
			]
		]


    foreach word words-of node [
        unless find [name children] word [
            append result to set-word! word
            append-value result select node word
        ]
    ]


    foreach entry head doc [
        if find sects entry/1 [repend hdrs [entry/1 entry/2]]
    ]



		foreach [name doc types] spec [					;-- list operands:
			if none? types [break]							;-- stop right after the last operand
			repend r [" " decorate name types]				;-- append every operand as "<name>"
		]


					collect/into [attempt [ 		; handles data=none
						foreach s fa/data [
							unless string? :s [continue]			; don't display auxiliary data
							ysz: ysz + lh
							; xsz: max xsz first size-text (rt/text: s rt)
							if ysz <= fa/top [continue]			; line is over the viewport
							keep :s keep lf 							; add this line into the viewport
							if all [
								get 'keep
								ysz >= (fa/top + vp/y)				; further lines will be below the viewport
							] [set 'keep none]
						]
					]] t

					collect [
						foreach [id title _ misc] map-data [
							if test title [
								keep id
								keep/only reduce [
									snapshot attempt [first find misc block!]
									title
								]
							]
						]
					]

      foreach [word index] wb [
         if rse-ids/find-compact index doc-id [append word-list join current-word word]
      ]

   foreach doc-name document-name-list [
        if  _make-document-id/check doc-name [
          append doc-id-list _make-document-id doc-name
          ]
       ]


								foreach [class db] next next so-db [
									result: collect [...]

									if not empty? result [
										append outer class
										append/only outer result
									]
								]


        foreach header headers [
            if header/name <> "Content-Type" [
                keep reduce [
                    to set-word! header/name
                    make object! compose [
                        description: (header/value)
                        type: "string"
                    ]
                ]
            ]
        ]


        foreach ex examples [
            blk: ex/:type   ; requests or responses
            foreach item blk [
                hdr: find-header-by-key item/headers "Content-Type"
                if hdr [keep hdr/value]
            ]
        ]


        foreach y-pt y-data [
            ; don't plot any none values (after incrementing x)
            if y-pt [
                val-pair: to-pair reduce [(to-integer x-val) (scale-y y-pt)]
                
                insert tail result val-pair
            ]
            x-val: (x-increment: x-increment * parms/x-log-adj) + x-val 
        ]


        foreach val data [
            ; skip over the data if it is none (drop down to increment x-pos)
            if val [
                low-left: to-pair reduce [(to-integer x-pos) (min y-scale parms/y-min y-scale 0)]
                up-right: to-pair reduce [( to-integer (x-pos + bar-width)) (y-scale val)]
                
                insert insert insert tail result first [box] low-left up-right
            ]
            x-pos: x-pos + parms/bar-step
        ]


    foreach e res
    [
      if block? e
      [ replace/all e {_*http*_} target ]
      append/only fres e
    ]


	foreach [source-test source-result] source-log-contents [
		if find [crashed failed] source-result [
			; test failure
			write/append target-log rejoin [
				source-test " " mold source-result newline
			]
		]
	]

foreach [word style] vid-styles [
	if style/tags [
		append tag-list style/tags
	]
]


            foreach id fidx* [
                insert insert/only tail values obtain pick data* id id
            ] 


            foreach value vid-rules [if lit-word? :value [append vid-words to-word value]]

            foreach f face/pane [if f/data [insert tail values f/var]] 

        foreach type types [
            if all [obj1/:type in obj2 type] [append obj1/:type obj2/:type]
        ]

        foreach var [edge: font: para: doc:] [
            if here: find/tail specs :var [
                if here/1 <> 'none [
                    insert here reduce either get in face to-word :var [
                        ['make to-word :var]
                    ] [
                        ['make to-path reduce ['vid-face to-word :var]]
                    ]
                ]
            ]
        ] 

            foreach word [text effect colors texts font para edge] [
                if style/:word [
                    set in style word either series? style/:word [copy style/:word] [
                        make style/:word []
                    ]
                ]
            ]


