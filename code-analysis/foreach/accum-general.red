
                foreach fc focus-ring-faces [
                    fc/offset: fc/offset + diff
                ] 

                    foreach size sizes [
                        panel-size/x: max size/x panel-size/x 
                        panel-size/y: max size/y panel-size/y
                    ] 

    foreach item rules [
        if word? :item [item: get item] 
        val: val + switch/default type?/word :item [
            integer! [abs item] 
            string! [length? item] 
            char! [1]
        ] [0]
    ] 

            foreach f faces [
                f/offset/y: f/offset/y + diff/y 
                f/win-offset/y: f/win-offset/y + diff/y
            ]


            foreach f faces [
                f/offset/:axis: f/offset/:axis + diff/:axis 
                f/win-offset/:axis: f/win-offset/:axis + diff/:axis
            ]

				foreach fc focus-ring-faces [
					fc/offset: fc/offset + diff
				]

; 2D min+max - why not use min/max on pairs?
					foreach size sizes [
						panel-size/x: max size/x panel-size/x
						panel-size/y: max size/y panel-size/y
					]

			foreach f face/pane [if f/data [insert tail values f/var]]

        foreach val data [
            sum: sum + val
            ]

            foreach val ratios [
                total-ratio: total-ratio + val
            ]

                    item-offset: 0x0
                    foreach item pane [
                        item/size: add text-size? item edge-size? item
                        if all [item/para item/para/origin] [
                            item/size: item/size + (2 * item/para/origin)
                        ]
                        item-offset: item/size + item/offset: 1x0 * item-offset
                    ]



			foreach l lines [
				either width >= length? l [fit: fit + 1][dont: dont + 1]
				if all [fit > 20  1.0 * dont / fit > 5%] [width: width + 5  dont: 0]
			]

			foreach l lines [width: max width length? l]

			foreach face list-chat/pane [pane-height: pane-height + face/size/y]


	foreach pixel image [
		color/r: color/r + pixel/1
		color/g: color/g + pixel/2
		color/b: color/b + pixel/3
	]

; tricky accumulation
                    foreach jump knightsjump/:i [
                        either odd? thispiece [
                            infl-black/(jump): infl-black/(jump) + 1
                        ][
                            infl-white/(jump): infl-white/(jump) + 1                           
                        ]
                    ]


		counts: copy [0 0 0 0 0]
		foreach char data [
			switch char [
				#","	[counts/1: counts/1 + 1]
				#"^-"	[counts/2: counts/2 + 1]
				#"|"	[counts/3: counts/3 + 1]
				#"~"	[counts/4: counts/4 + 1]
				#";"	[counts/5: counts/5 + 1]
			]
		]
		pick [#"," #"^-" #"|" #"~" #";"] index? find counts max-of counts

		foreach v series [val: min val v]


		foreach byte data [result: result + to integer! byte]


		foreach digit reverse copy data [
			result: result + (mult * to integer! form digit)
			try [mult: mult * 8]
		]

	foreach file files [
		all [
			id: third split file dot
			id: try [to integer! id]
			if id > maximum [maximum: id]
		]
	]

; map buildup
	foreach issue issues [
		author: issue/user/login
		either authors/:author [authors/:author: authors/:author + 1][authors/:author: 1]
	]

foreach blk at depth 2 [arg/3: make arg/3 blk] ; triggers sub 'do



		foreach val block [total: total + val]


		foreach val vals [
			total: total + (((val - mbar) ** 2) / div)
		]


sum: func [
	"Returns the sum of all values in a block"
	values [block! vector! paren! hash!]
	/local result value
][
	result: make any [values/1 0] 0
	foreach value values [result: result + value]
	result
]

										foreach p extract next value 2 [
											layout/parent/styles reduce ['panel copy p] face divides css
											p: last face/pane
											max-sz: max max-sz p/offset + p/size
										]


			foreach [field value] default-font [
				if none? face-font/:field [face-font/:field: get value]
			]



				foreach name block [
					either value: select codes :name [
						total: total + value
					][
						raise ["Unknown argument: " :name]
					]
				]

		foreach term query [
			if find/any title term [rank: rank + 4]
			content: text
			while [content: find/any/tail content term][rank: rank + 1]
		]


        foreach item items [
            value: test item
            unless target: select out value [
                repend out [value target: copy []]
            ]
            append target item
        ]

