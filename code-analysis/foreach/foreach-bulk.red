---------------------------------------------------------------------------------------------
------- bulk assignment -------

; 17 assignments


									foreach-face face [face/draw/4: 'transparent]

				foreach-face drawing-panel [face/size: drawing-panel/size]

            foreach [word pane] face/panes [pane/size: panel-size]

            foreach side sides [set in get side 'show? true] 

			foreach [word pane] face/panes [pane/size: panel-size]

					fill-pen [color: select-color foreach shape shapes/pane [shape/draw/fill-pen: color]]

					pen [color: select-color foreach shape shapes/pane [shape/draw/pen: color]]

						foreach shape shapes/pane [shape/draw/line-width: lw]

		foreach subface gobbg/pane [subface/data: gobs]

							foreach msg data [
								msg/5: from-now utc-to-local unix-to-utc msg/5
							]

	foreach message messages [
		message/sent: load message/sent
	]

; bulk assignment ?
					foreach w [color image flags options edge para] [rt/:w: :fa/:w]

												foreach fig next find figs-panel/pane figs [
													fig/visible?: no
												]

				foreach tab tab-pan/pane [
					tab/size: tab/parent/size - 4x25;!
				]

				foreach tab tab-pan/pane [
					tab/offset: tab/parent/offset + 2x24
					tab/size: tab/parent/size - 5x27
				]

	foreach [id job] port/job-queue [job/4: 'pending]

			foreach pane tab/pane [pane/size: tp-size]






---------------------------------------------------------------------------------------------
------- bulk application -------



		trim-each: [(foreach val values [trim/head/tail val])]


							foreach-face info-panel [clear face/text] 

        block? :pane [foreach f :pane [dump-face/parent f face]] 

            foreach f face/pane [
                set-face/no-show f false
            ] 

            foreach fc face/pane [
                set-parent-faces/parent fc face
            ]

        foreach fc get in f 'focus-ring-faces [hide fc]

            block? :panes [foreach [w p] head panes [either object? p [do-align p face] [foreach fc p [do-align fc face]]]] 

            block? :pane [foreach fc pane [do-align fc face]]


            block? :panes [foreach [w p] head panes [either object? p [do-resize p diff] [foreach fc p [do-resize fc diff]]]] 

            block? :pane [foreach fc pane [do-resize fc diff]]

                        if block? face/pane [foreach fc face/pane [do-resize fc size]] 

    foreach window system/view/screen-face/pane [
        act-face window none 'on-deactivate
    ]

    foreach file picked [insert file dir-path]

				foreach observer copy plug/observers [
					observer/valve/unlink/only observer plug
				]

	foreach room rooms [
		print room/name
	]

			if compact [foreach message ret [strip-message message]]

	foreach room rooms [
		save rejoin [%rooms/ room/id %.red] room
	]

      foreach doc-name doc-id-list [
         _remove-document-id doc-name
         ]

   foreach w add-list [
      _add-a-word w doc-id
   ]

         foreach doc-id doc-ids [_remove-packed pointer/2 doc-id]

		foreach gob gob/pane [do-action gob/data 'resize]

		foreach entry stack [probe entry]

						foreach face el [
							face/size: coord/spair face/def-size dir
						]

			foreach face head pane [
				face/parent-face: self
			]

			foreach pane panes [
				pane/calc-sizes
			]

            foreach word with [
                put result word select ctx word
            ]

; bulk application ?
						foreach value values [
							replace-deep current value (take result)
						]

	foreach [t c a] headings [print c/a/2]

			foreach p any [port-id [80]][control/start/only 'HTTPd p]

		foreach file req/tmp/files [attempt [delete file]]

			foreach [name list] phases [clear list]


	foreach [name value] request/headers [
		emit [<LI><B> name ":"</B> html-encode mold value </LI>]
	]

	foreach [name value] request/content [
		emit [<LI><B> name ":"</B> html-encode mold value </LI>]
	]

		foreach [name value] session/content [
			emit [<LI><B> name ":"</B> html-encode mold value </LI>]
		]

					foreach h list [
						h-store ro 'Access-Control-Expose-Headers form h
					]

; bulk application ?
			foreach [id sess] list [
				sess/busy?: no
				clear sess/queue
			]

		foreach [name value] vars/sys [
			set-env name value
		]

	foreach var vars/cgi 	[set-env var empty]

		foreach var vars/apache [set-env var empty]

		foreach [name value] system/options/cgi/other-headers [
			set-env name empty
    	]

		foreach [name value] soc/other-headers [
			set-env name value
		]


            foreach [cmd opts] inline-stack [
                stage3 cmd opts
            ]


    foreach script system/script/header/Scripts [do script]


			foreach [owner word target action new index part state] pending [
				on-face-deep-change* owner word target action new index part state yes
			]


					foreach f face/pane [show/force f]


		foreach f face/pane [show/with f face]


	if block? face/pane [foreach f face/pane [dump-face f]]


			foreach [field value] spec [put opts/options field value]



		if all [deep block? face/pane][foreach f face/pane [stop-reactor/deep f]]


	if face/pane [foreach f face/pane [show/with f face]]


	foreach c text [do-event/with 'key c]

		foreach [value items] out [new-line/all items true]

			foreach path dirs [make-dir/deep path]

				foreach path folder [close clear open path]


				foreach [key val] pending [set key val]


				foreach [key reasons] errs [
					foreach reason reasons [
						emit ["[" sanitize reason "]"]
					]
				]

			foreach line parse/all data "^/" [
				feed emit <h3> emit sanitize line emit </h3>
			] feed emit </div>

		foreach [retact state] head reverse head state-stack [do retact]


	foreach entry entries: select news [latest] [entry/load-doc]

		foreach flag get-all-flags port [print ["    FLAG:" form flag]]


		emit foreach [from to][
			"\\" "\"
			"\`" "`"
		][
			replace/all code from to
		]

		foreach [from to] reduce [ ; (join avoids the pattern)
			"&" "&amp;" "<" "&lt;" ">" "&gt;"
			join "-[" "-" "<" join "-" "]-" ">"
		][
			replace/all out from to
		]

			foreach value query [change/only value parse/all value/1 "."]

                    foreach word scope [
                        repend select symbols word [out '|]
                    ]






