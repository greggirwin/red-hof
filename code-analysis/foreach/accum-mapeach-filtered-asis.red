
		collect [
			foreach [style content] get 'document [
				if style = 'tags [keep content]
			]
		]

		foreach [name value] codes [
			if equal? value flags and value [append list name]
		]

				foreach w spec-of w1 [
					if refinement? w [append words w]
				]

		foreach f files [
			if any [empty? word find/match f word] [
				append result f
			]
		]

			foreach [name f s b] face/actors [
				unless find actors name [repend actors [name f s b]]
			]

					foreach w opt-words [if get in opts w [append styled w]]


		collect [
			foreach word words-of system/words [
				if test get/any word [keep word]
			]
		]

    result: collect [
        for-each [key value] cookie-jar [
            if find key domain [
                keep value
            ]
        ]
    ]

    for-each cookie cookie-string [
        for-each element split cookie ";" [
            trim/head/tail element
            if all [
                find element "="
                exclusions? element
            ][
                append cookies element
            ]
        ]
    ]


            foreach [word val] obj [
                if all [:val not find block to word! word] [insert/only insert tail local word :val]
            ] 

            foreach word words-of system/words [
                if action? get/any word [keep word]
            ]

				foreach word words-of system/words [
					if datatype? get/any word [keep word]
				]

          foreach [menu-path menu-content] menus [
              if all [node <> 1 short-path = menu-path][append menu menu-content]
          ]

      foreach [menu-path menu-content] menus [
          if short-path = menu-path [append menu menu-content]
      ]

   foreach [file block] data-block [
      if 0 <> length? block [
         append db file
         append/only db block
      ]
   ]

                    foreach jump fromknight [
                        if  knight and white-board/(jump) = knight [
                            chess-resolvers: append chess-resolvers jump
                        ]
                    ]

	foreach message messages [
		if find message/text string [append result message]
	]

									result: collect [
										foreach id db [
											if all [
												id >= start
												id <= finish
											][
												keep id
											]
										]
									]

							foreach [image name block] u/tool-bar-data [
								if string? name [
									append people name
								]
							]

						foreach item plug/subordinates [
							if word! = (type? item) [
								lbls: any [lbls copy []]
								append lbls item
							]
						]

	collect/into [
		foreach word words-of system/words [
			if not unset? get/any word [keep word]
		]
	] sys-words

	datatypes: sort collect [
		foreach word load help-string datatype! [
			if datatype? attempt [get word] [keep word]
		]
	]

                        foreach id face/data-sorted [
                            if values pick face/data id [insert tail face/selected id]
                        ] 

