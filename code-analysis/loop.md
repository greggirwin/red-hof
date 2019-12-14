# LOOP

LOOPs were found to be distributed as follows:
- 46% were true, justified `loop`s
- 21% were imitating natives (mostly `append/dup` or `append/part`)
- 13% were imitating `map-each` (due to it being unavailable?)
- 10% were imitating `foreach` (usually to make it stop after a certain number of iterations)
- 10% were other, unclassified `loop`s

**Navigate:**
  * [Imitations of MAP-EACH](#imitations-of-map-each)
  * [Imitations of FOREACH](#imitations-of-foreach)
  * [Natives imitation](#natives-imitation)
  * [True LOOPs](#true-loops)
  * [Unclassified LOOPs](#unclassified-loops)


## Imitations of MAP-EACH

- in-place map
- `map-each/self [x y] pointer [... either .. [[]][reduce [x y]]]`
- `map-each/eval/self [x y] pointer [... either .. [[]][ [x y] ]]`
```
  loop (length? wb/:nn) / 2 [
     foreach doc-id doc-ids [_remove-packed pointer/2 doc-id]
     either all [block? pointer/2 0 = length? pointer/2] [
        remove pointer
        remove pointer
     ] [
        pointer: next next pointer
     ]
  ]
```

---
- table-oriented in-place map, changing column 2 of 3; + extraction of this column
- `map-each/self [x y z] image [... [y: load y] reduce [x y z]]`
- `map-each/eval/self [x y z] image [... [y: load y] [x y z]]`
```
    loop size [
        unless image? second image [change next image load second image] 
        append block second image 
        image: skip image 3
    ] 
```

---
- forall imitation, in-place map
- `map-each/self x on-columns [index? find columns :x]` -- that easy
```
	loop length? on-columns [
		change on-columns index? find columns first on-columns
		on-columns: next on-columns
	]
	on-columns: head on-columns
```
- and these re-do `union` in each iteration.. great
```
	loop length? grp-columns [
		change grp-columns index? find union columns query-columns first grp-columns
		grp-columns: next grp-columns
	]
```
```
	loop length? by-columns [
		change by-columns index? find union columns query-columns first by-columns
		by-columns: next by-columns
	]
```

---
- maximum on a map of a column
- `b: extract buffer cols  maximum-of (length? form b/*)` ??
- `maximum-of map-each x extract buffer cols [length? form x]`
- `accumulate 0 extract buffer cols func [acc x] [max acc length? form x]`
```
	loop rows [
		size: max size length? form first buffer
		buffer: skip buffer cols
	]
	buffer: head buffer
```


## Imitations of FOREACH

---
- limited foreach
- `prin rejoin map-each name limit list n [...reduce [tab pad name max-sz " "]]` - though maybe it's better to `prin` in real time
- `foreach name limit list n [...]` then
```
	loop n [
		if max-sz <= length? name: list/1 [
			name: append copy/part name max-sz - 4 "..."
		]
		prin tab
		prin pad form name max-sz
		prin " "
		if tail? list: next list [exit]
	]
```

---
- bulk assignment over `part` only
- `foreach face limit faces part [face/parent: owner]`
```
	loop part [
		faces/1/parent: owner
		faces: next faces
	]
```

---
- limited foreach with index
- `foreach [pos: face] limit target part [...pane: at target pos...]` - uses index as series
```
	loop part [
		face: target/1
		if face/type = 'window [
			stop-reactor/deep face
			modal?: find-flag? face/flags 'modal
			system/view/platform/destroy-view face face/state/4

			if all [modal? not empty? head target][
				pane: target
				until [
					pane: back pane
					pane/1/enabled?: yes
					unless system/view/auto-sync? [show pane/1]
					any [head? pane find-flag? pane/1/flags 'modal]
				]
			]
		]
		target: next target
	]
```

---
- `foreach face limit target part [...]`
```
	loop part [
		face: target/1
		face/parent: none
		stop-reactor/deep face
		system/view/platform/destroy-view face no
		target: next target
	]
```

---
- `foreach face limit faces part [...]`
```
	loop part [
		face: faces/1
		unless all [
			object? face
			in face 'type
			word? face/type
		][
			cause-error 'script 'face-type reduce [face]
		]
		if owner/type = 'tab-panel [
			face/visible?: no
			face/parent: owner
		]
		if all [owner/type = 'window face/type = 'window][
			cause-error 'script 'bad-window []
		]
		show/with face owner
		faces: next faces
	]
```



## Natives imitation


---
- `insert/dup`
```
unless tail? src [loop length? src [insert dst %../]]
```

---
- `append/dup`
```
values: remove rejoin collect [loop length? keys [keep ",?"]]
```

---
- `clear skip tail columns 0 - master-on-cols`
```
	loop master-on-cols [remove back tail columns]	; remove columns not in original selection
```
```
	loop min counter value/1 [remove back tail html] ; deletes counter times </UL>
```
```
	loop counter: value/1 [remove back tail html] ; delete value/1 times </UL> (the first remove might be </OL> tag)
```

---
- `threads: skip threads page - 1 * 50`
```
	loop (( page - 1)  * 10 * 5 ) [
		threads: next threads
	]	
```
```
	loop (( page - 1)  * 10 * 4 ) [
		titles: next titles
	]	
```

---
- `append/part threads2 threads 50`
```
	loop (10 * 5)  [
		append threads2 threads/1
		threads: next threads
	]
```
```
	loop (10 * 4 )  [
		append titles2 titles/1
		titles: next titles
	]
```

---
- `append/dup`
```
parse spec [
    integer! end (loop spec/1 [insert tail result copy/deep body]) 
]
```



## True LOOPs

---
```
	loop counter [emit [</ul></li>]]
```
```
	loop counter [emit </ul>]
```
```
	loop (number_of_table_cells - number_of_emitted_table_cells) [emit [</td><td> "&nbsp;"]]
```
```
	if old_level > level  [loop (old_level - level) [emit </div>]]
```
```
	[if old_level > 0 [loop old_level [emit </div>]]]
```

---
- true loop?
```
	loop value/1 - counter [
		if (back tail html) == [</li>] [remove back tail html]
		emit <ul>
	]
```

---
```
loop 25 [append/only list-data array/initial 4 does [random 100]]
```

---
```
loop 10 [
	insert
		tail
			list-data-1
		make default-object [
			name: random "abc"
			age: random 50
			height: random 100
			time: random now/precise
		]
]
```

---
```
loop 100 [append/only list-data array/initial 3 does [random "abcdef xyz nml"]]
```

---
```
loop 100 [
	append/only list-data make prototype [
		name: random "asd xyz"
		age: random 100
		height: random 50
	]
]
```

---
```
loop 25 [
	append/only
		list-data
		reduce [
			pick images random length? images
			pick images random length? images
			pick images random length? images
		]
]
```

---
```
	loop count [
		header: make header! []
		transcribe join "Get Column Header #" count read-packet port [...]
		append wire/columns :header
		net-log header
	]
```

---
- true loop, since `cols` is not fixed; though `repeat` can be cleaner
- populates 1st column from `data`
- `repeat i ..rows [j: i * cols  buffer/:j: data/:j]` ?
```
	loop (tables/:table/rows) [
		poke buffer pos: pos + (length? columns) first data
		data: skip data (tables/:table/cols)
	]
```

---
```
	loop (length? blk) / cols [
		if result <> copy/part blk (cols - 1) [
			;	tally grouped values
			(agg)
			clear tally
			result: copy/part blk (cols - 1)
		]
		insert tail tally pick blk (cols)
		blk: skip blk (cols)
	]
```

---
- true loop outside
- `for` imitation inside: `for offset offset offset + cols [..]` whew ugly so
```
	loop rows [
		insert tail page "<tr>"
		loop cols [
			insert tail page either any [none? buffer/:offset buffer/:offset = ""][
				copy "<td>&nbsp;</td>"
			][
				rejoin ["<td>" buffer/:offset "</td>"]
			]
			offset: offset + 1
		]
		insert tail page "</tr>"
	]
```

---
```
	loop length [
		char: random/secure/only chars
		append out char
		repeat i length? required [
			if find this required/:i char [
				used/:i: true
			]
		]
	]
```

---
```
    loop table/size/y - length? table/table [
        insert/only tail result content: copy [row] 
        if all [find [horiz both] header j = 1] [insert tail content 'header] 
        repeat i table/size/x [
            tmp: make-cell-style table none none pick table/columns i 
            insert/only tail content compose [
                cell (either tmp ['opts] [[]]) (either tmp [reduce [make-style/ignore tmp [position]]] [[]]) (either header? header i j ['header] [[]])
            ]
        ] 
        j: j + 1
    ] 
```

---
```
    loop table/size/x - length? row/contents [
        tmp: make-cell-style table none row pick table/columns i 
        insert/only tail content compose [
            cell (either tmp ['opts] [[]]) (either tmp [reduce [make-style/ignore tmp [position]]] [[]]) (either header? header i j ['header] [[]])
        ] 
        i: i + 1
    ]
```

---
- true loop?
```
	loop random samples [
		append/only blk reduce [random/only [item folder] copy/part random copy lbl random 10]
	]
```

---
```
    loop 8 [
    	; eat move events
        if all [event: take income event/type = 'move][
			while [all [move: first income move/type = 'move]][
				event: move remove income
			]
        ]
        unless event [break]
        port: event/port
        if wake-up port event [
            unless find waked port [append waked port]
        ]
    ]
```

---
- n-th find; true loop?
```
	found: next find canvas/draw figure
	loop n [found: next find found figure]
```


## Unclassified LOOPs

---
- `h: sum at heights top` ;)
```
	n: top
	h: 0
	len: length? skip lines top
	loop len [
		h: h + pick heights n
		n: n + 1
	]
```

---
- ??
```
	loop tmp: 2 + to-integer (length? gob) / 2 [
		tmp: has/hide [idx: 1 is caller/child-style] ; create a new child
		append face/pool tmp/gob
	]
```

---
- now WTH is this? some flavor of R3 uses `loop` as `forever`? dangerous feat
```
upward: new-upward [loop [do-action gob/data action]]
```
```
	loop [
		if trigger? gob [scroll-down scroll-up][
			do-event gob
				pick [scroll-up scroll-down] positive? global/offset/y
				offset
			break
		]
	]
```
```
	loop [
		either at: find/tail entered gob [
			if all [drag? not away][set 'away at/0]
			remove-each gob at [
				do-event gob 'leave offset
				on
			]
			break
		][
			if trigger? gob [enter over away leave key]
				[insert entering gob]
		]
	]
```

