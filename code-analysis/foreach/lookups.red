; lookups are filters that return first match, or a position of it


				foreach-face w [
					if all [
						none? child
						face/type = 'base
						true = try [face/extra/class = 'text-column]
					][
						if within? face-to-face abs-ofs w face 0x0 face/size [child: face]
					]
				]

					foreach-face w [
						; if f- [continue] 	; crashes
						if any [
							face/type = 'area
							all [
								face/type = 'base
								true = try [face/extra/class = 'text-column]
							]
						][
							case [
								same? face f [
									if all [e/shift? f-] [set-focus f-]
								]
								same? f- f [
									unless e/shift? [set-focus face]
								]
							]
							f-: face
						]
					]


----------------------------------


            foreach f w [if all [object? f f: find-key-face f keycode] [result: f break]] 

            foreach t tabs [
                if integer? t [t: t * 1x1] 
                if all [pair? t (way * t) = (way * max t where)] [
                    return way * t + (where * reverse way)
                ]
            ]


            foreach f pane [
                if all [
                    find f/flags 'input 
                    f/var = var 
                    set-face f value
                ] [return true]
            ] 


            foreach f face/pane [if f/data [break/return f/var]]

        foreach fc any [get in face 'pane []] [
            if fc/style = 'tool-tip [return fc]
        ]


        foreach evt-func event-funcs [
            unless event? evt-func: evt-func face event [
                return either evt-func [event] [none]
            ]
        ] 

    foreach event events [
        if system/view/wake-event event [return true]
    ] 

            no-btn: foreach item face/pane [if get in item 'action [break/return false] true]

            foreach window system/view/screen-face/pane [
                all [lo: find-style window type break]
            ]


			foreach f pane [
				if all [
					find f/flags 'input
					f/var = var
					set-face f value
				][return true]
			]

			foreach f face/pane [if f/data [break/return f/var]]

			foreach f w [if all [object? f f: find-key-face f keycode][result: f break]]

	foreach cell data [if find cell value [return true]]


                foreach item bypass [
                    if any [
                        all [x: find/match/any host item tail? x]
                    ] [return true]
                ]

	; find item with a specific attribute - common pattern
    foreach obj metadata [
        if obj/name = key [return obj]
    ]


    foreach obj content [
        if obj/attributes/role = role [return obj]
    ]

    foreach expr-name get-expressions-from-uri-template uri-template [
    	...
        if expr-name = param-name [
            return either q? ["query"] ["path"]
        ]
    ]

					foreach evt-func event-funcs [
						if not event? evt-func: evt-func face event [
							return either evt-func [event][none]
						]
					]

					no-btn: foreach item face/pane [if get in item 'action [break/return false] true]

                foreach face path [
                    ;debug ["path" face/text index]
                    event/7: event/face: face
                    if attempt [:face/feel/detect] [if none? face/feel/detect face event [exit]]
                ]

        first-of: func ["Returns first item." menu [object!]] [
            foreach item menu/list/pane [
                if instance-of item 'menu-item [break/return item]
            ]
        ]

; complex lookup
            foreach item next find reverse copy menu/list/pane extra [          ;-- This results in other being the last visble item or
                if instance-of item 'menu-item [                                     ;   none, if extra itself is the last visible one.
                    if     menu/feel/visible? menu item [other: item]
                    if not menu/feel/visible? menu item [break/return other]
                ]
            ]

                    foreach item next find reverse copy menu/list/pane menu/actor [
                        if instance-of item 'menu-item [break/return item]
                    ]

                    foreach item next find menu/list/pane menu/actor [
                        if instance-of item 'menu-item [break/return item]
                    ]

            foreach item items [
                if all [
                    instance-of item 'menu-item
                    item/body/text
                    equal? uppercase char uppercase item/body/text/1
                ][ 
                    break/return item
                ]
            ]

        last-of: func ["Returns menu's last item." menu [object!]] [
            foreach item reverse copy menu/list/pane [
                if instance-of item 'menu-item [break/return item]
            ]
        ]

							foreach init plug/observers [
								if init/valve/stream/depth init msg dpt [
									end?: true
									exit ; stop looking for the end, we got it.
								]
							]



			foreach tag result [
				if tag? tag [
					if parse tag [thru "fkey" thru "hidden" thru "value" thru {"} copy fkey to {"} to end][
						fkey: to string! fkey
						break
					]
				]
			]

										foreach [key type][
											fkey string!
											room-id integer!
											room-descriptor string!
											bot-cookie string!
										][
											if not-equal? type to word! t: type? tobj/(key) [
												alert ajoin ["Wrong value for " form key " expected " type " and got " t]
												exit
											]
										]


	foreach item series [
		if equal? item/:word value [return item]
	]

	foreach room rooms [if equal? name room/:field [return room]]

	foreach message messages [
		if equal? id message/id [return message]
	]


        foreach area areas [
            if all [
                equal? 'link area/type
                inside-face? area event-offset
            ] [
                ...
                break
            ]
        ]


		foreach entry mdp-stack [
			if entry/1 == 'meta [
				file: to-file entry/2
					...
				break
			]
		]

                            for-each player words-of week/player-picks [
                                unless find week/starters player [
                                    return make error! spaced [
                                        "Player" mold form player "was eliminated before" week/name
                                    ]
                                ]
                            ]

					no-btn: foreach item face/pane [if get in item 'action [break/return false] true]


    foreach word words-of pattern [
        unless find [name children] word [
            unless equal? select node word select pattern word [
                return none
            ]
        ]
    ]

        foreach rule node-rules [
            if mapped: map-node node rule/pattern [
                mapped/.stack: stack
                mapped/.indent: indent
                mapped/.parent: last stack
                mapped: map-to-object mapped
                ; apparently there's a bug with BIND/COPY
                production: bind copy/deep rule/production mapped
                emit-production output rules mapped production
                break
            ]
        ]

		foreach line data [
			any [empty? line return line]
		]

	foreach issue issues [
		if equal? issue/number number [return issue]
	]

	foreach obj tree/tree [
		all [
			equal? "blob" obj/type
			equal? form file obj/path
			return obj
		]
	]

			foreach zone self/zone-cache [
				if equal? name zone/name [return zone/id]
			]

		foreach zone self/zone-cache [
			if equal? zone-id zone/id [return zone/name]
		]

		foreach record records [
			if equal? name record/name [return record/id]
		]


; counter - and not a place for `zip`
		foreach [s n] block-list [
			if find/case line s [			
				poke block-list c block-list/:c + 1
				if banning? [ban-ip copy/part line 120]
				return true
			]
			c: c + 2
		]

			foreach [pattern action] list [		
				if find/any/match url pattern [			
					req/out/code: second action
					if slash = last url: first action [
						insert tail url: copy url join req/in/target any [req/in/arg ""]
					]				
					h-store req/out/headers 'Location url
					return true
				]
			]

			foreach [pattern action] list [
				if find/any/match req/in/url pattern [
					req/in/file: rejoin [req/cfg/root-dir slash action]  ;-- make a smart rejoin!!!
					req/in/script-name: copy pattern
					if ext: find/last action #"." [
						req/in/ext: to word! as-string ext
						req/handler: select service/handlers req/in/ext
					]
					;req/handler: select service/handlers to word! as-string suffix? action
					return false			;-- let mod-static finish the work
				]
			]


		foreach name list [
			if all [
				extapp: select actives name
				not empty? extapp/jobs
			][
				jobs: extapp/jobs
				sel: none			
				while [not empty? jobs][			
					...
				]
				if sel [return sel]
			]
		]

			foreach [path cfg] apps [
				res: join req/in/path req/in/target
				if any [empty? path pos: find/match res path][
					if any [
						req/in/target = "app-init.r"
						all [pos find pos "ws-apps"]
						all [pos find pos "private"]	; forbid /app/private, but allow /private/app
						all [not pos find res "private"]
					][
						req/out/code: 404
						return false
					]
					...
					break
				]
			]


		until [
			id: random 9999
			either empty? apps [true][
				foreach [name app] apps [if app/__id = id [break/return false] true]
			]
		]


		foreach mime list [
			if all [
				any [mime/1 = '* mime/1 = type/1]
				any [mime/2 = '* mime/2 = type/2]
			][
				return true
			]
		]

				foreach file to block! any [select cfg 'default []][
					req/in/file: rejoin [cfg/root-dir req/in/path file]				
					if req/file-info: info? req/in/file [
						req/in/target: form file
						if ext: find/last req/in/target dot [
							req/in/ext: to word! ext
							req/handler: select service/handlers req/in/ext
						]
						if req/file-info/type = 'file [return false]
					]
				]


				foreach id list [
					if set-lang to word! id [exit]
				]



            foreach word select* tmap type?/word :value [
                if paren? :word [
                    do bind to block! word in obj 'self 
                    break
                ] 
                if all [word <> 'none none? get word: in obj word] [
                    set word value 
                    break
                ]
            ]

        for-each element exes [
            if find e element [
                return false
            ]
        ]


    foreach [key data] lib/bot-expressions [
        if find/part probe key probe search-key length? search-key [
            understood: true
            lib/reply lib/message-id ["[" data/1 "](" data/2 ") " either found? person [person] [""]]
            break
        ]
    ]

    match: func [sentence /local reply token] [
        foreach [p-symbol phrases r-symbol replies] rules [
            foreach phrase phrases [
                if parse sentence make-parse-rule phrase [
                    reply: pick replies random (length? replies)
                    foreach token reply [
                        if word? token [
                            set :token substitute get token
                        ]
                    ]
                    return rejoin head reply
                ]
            ]
        ]
    ]


        for-each element exes [
            if find e element [
                return false
            ]
        ]

	foreach [a b c d] list [
		if b/2 = id [return d]
	]


			foreach handler handlers [
				set/any 'result do-safe [handler face event]
				either event? :result [event: result][if :result [return :result]]
			]



			foreach [name codec] system/codecs [
				if find codec/suffixes suffix [
					return do [codec/decode source]
				]
			]


				foreach [name codec] system/codecs [
					foreach mime codec/mime-type [
						if find source/2/Content-Type mold mime [
							return do [codec/decode source/3]
						]
					]
				]


		foreach f face/pane [
			if all [
				object? f
				f/visible?
				within? pos - extra f/offset f/size
			][
				face: offset-to-face f pos - extra
				break
			]
		]


		foreach [old new permission action] :conditions [
			if all [
				old = current
				new = target
				all to block! :permission
			][
				break/return do action
			]
		]


			get: func [key [word!]][foreach [k v] data [if k = key [break/return v]]]



		route: foreach [path action] controller/routes [
			args: request/path-info
			path: to block! path

			case/all [
				string? path/1 [
					args: either path/1 = args/1 [next args][none]
					path: next path
				]
				args: validate/block args to block! path [
					break/return action
				]
			]
		]

            foreach lookup-table lookup-tables [
                unless db-table? :lookup-table [to-error "Invalid lookup table"]
            ]

