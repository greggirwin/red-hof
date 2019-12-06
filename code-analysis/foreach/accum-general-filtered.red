                    foreach-face/with legend [face/offset/y: face/offset/y - szy][face/offset/y > ofy]

            foreach-face/with legend [
                face/offset/y: face/offset/y + idx/1/size/y
            ][
                face/offset/y > idx/1/offset/y
            ]

		foreach-face/with refine [face/offset/y: face/offset/y + diff] [face/offset/y > r-expr/offset/y]

						foreach-face/with refine [face/offset/y: face/offset/y + diff] [face/offset/y > r-def/offset/y]



-------------
                foreach f faces [
                    if f/style <> 'highlight [
                        f/offset/:axis: f/offset/:axis + diff 
                        f/win-offset/:axis: f/win-offset/:axis + diff
                    ]
                ]

                            foreach elem face/pane [
                                either any [
                                    elem/options/style = 'connect
                                    elem/options/parent-style = 'connect
                                ][
                                    ...
                                ][
                                    mx: max mx elem/offset + elem/size
                                ]
                            ]

										foreach elem next shape [
											either pair? elem [total: total + elem][cnt: cnt + 1]
										]

		4 <= sum collect [
			foreach f [%red.r %environment/ %modules/ %runtime/ %system/ %libRed/] [
				if exists? f [keep 1]
			]
		]


		foreach item gob/text [
			if string? item [len: len + length? item]
		]

							foreach-face/with figs-panel [tot: tot + face/size/y][face/visible? = yes];prev/size/y + face/size/y + nex/size/y

	foreach file read %tests/ [
	    if test-file? file [
	        summary: run-test-file file
	        total-passed: total-passed + summary/passed
	        total-failed: total-failed + summary/failed
	        total-unknown: total-unknown + summary/unknown
	        total-perf-regressions: total-perf-regressions + summary/perf-regressions
	    ]
	]

				foreach txt data [
					if any-string? txt [min-sz: max min-sz size-text/with face as string! txt]
				]


                foreach cell row/contents [
                    if cell [
                        cell/style: make-cell-style table-state cell/style row none
                    ]
                ]


                foreach row table-state/table [
                    if row [
                        if cell: pick row/contents table-state/curpos/x [
                            cell/style: make-cell-style table-state cell/style none col
                        ]
                    ]
                ]

; uses accumulated value
			foreach byte data [
				if all [byte <> #" " byte <> #"^-"][
					byte: to-pair to integer! byte
					nr: xor-pair nr (((and-pair 63x1 nr) + nr2) * byte) + (nr * 256x1)
					nr2: nr2 + byte
				]
			]


; uses accumulated value
			foreach byte data [
				if all [byte <> #" " byte <> #"^-"][
					byte: to-pair to integer! byte
					nr: xor-pair nr (((and-pair 63x1 nr) + adding) * byte) + (nr * 256x1)
					nr2: nr2 + xor-pair nr (nr2 * 256x1)
					adding: adding + byte
				]
			]
