# REMOVE-EACH imitations

- needs the index for `change`:
- `remove-each [pos: path] picked [...]`
- or can be a filter+map:
- `map-each path picked [returns unset for removal...]`
```
    while [not tail? picked] [
        set [name file] split-path first picked 
        either name <> where [
            remove picked
        ] [
            change picked file 
            picked: next picked
        ]
    ] 
```

---
- from `stop-reactor`:
- `remove-each [rr _ _ tgts] [any [...condition block...]]`
- `map-each/self/same [:face _ _ tgts /where all [block? tgts pos: find.. remove pos..]] []`  -- this is real bad practice
- `map-each/self/same [:face _ _ tgts] [unless all [...] [continue]]`
- `remap-each/same [:face _ _ tgts] [unless all [...] [continue]]`
```
	list: relations
	while [not tail? list][
		either any [
			same? list/1 face
			all [
				block? list/4
				pos: find/same list/4 face
				empty? head remove pos
			]
		][
			remove/part list 4
		][
			list: skip list 4
		]
	]
```

---
- from `react/unlink` (bugged, see #4166-4):
- `remove-each/same [obj _ :reaction _] [...]`
```
	pos: relations
	found?: no
	while [pos: find/same/only pos :reaction][
		obj: pos/-2
		either any [src = 'all src = obj all [block? src find/same src obj]][
			pos: remove/part skip pos -2 4
			found?: yes
		][
			break
		]
	]
```


---
- from RTD/`close-colors`:
- color-stk consists of triples [s-idx '_ c] - I don't get it why it needs an `'_` ??
- `append map-each [pos: idx '_ color] [...remove/part pos 3...]`  ?
- `remove-each [pos: idx '_ color] [... insert out ...]` ?
```
	pos: tail color-stk
	while [pos: find/reverse pos '_][
		pos/1: tail-idx?
		insert out as-pair pos/-1 tail-idx? - pos/-1
		insert next out pos/2
		new-line out on
		pos: remove/part skip pos -1 3
	]
```

---
- `remove-each/reverse [x _] block-stack [..  yes]`
- `foreach/reverse [x _] block-stack [ ... ]  clear block-stack` ?
```
    while [not empty? block-stack] [
        stage3 join block-stack/1 "." none 
        block-stack: skip clear block-stack -2
    ]
```

---
- path cleanup
- `remove-each/reverse x list [count ".."s to remove them on next iterations]`
```
	while [not tail? list][
		any [
			all [
				any [
					empty? list/1
					list/1 = "."
				]
				remove list
			]
			all [
				list/1 = ".."
				remove list
				any [
					head? list
					remove list: back list
				]
			]
			list: next list			
		]				
	]
```

---
- can be `remove-each x q [.. break if not /code]`
```
	while [
		all [
			not empty? q
			q/1/out/code
		]
	][		
		if send-response first q [remove q]
	]
```

---
- `remove-each job jobs [...return if not pending]`
```
	while [not empty? jobs][			
		either jobs/1/4 = 'pending [
			either closed-port? jobs/1/3 [					
				remove jobs
			][
				if not sel [sel: jobs/1]
				jobs: next jobs
			]
		][
			return none
		]
	]
```

---
- `trim/head/with string #"0"`
- or `remove-each x string [x = #"0"]`
```
	while [string/1 = #"0"] [remove string]
```

---
- interesting case - decomposition of each item
- `remove-each/self [[spec]] [...]` ?
```
    while [not tail? data][
        row: first data
        set [(spec)] row
        either (where) [
            data: remove data
        ][
            data: next data
        ]
    ]
```

---
- `remove-each x gob [... yes]`
```
	while [not empty? gob][
		append face/pool gob/1
		remove gob
	]
```

---
- `remove-each [lf] code [yes]`
- `trim/lines/head code`
```
	while [(first code) == newline] [remove code]
```

---
- `foreach/reverse [p: x] list [either 0 = x [remove p][break]]`
- `remove-each/reverse x list [unless 0 = x [break] yes]`
- `remove-while/reverse x list [0 = x]`
```
   while [
      all [0 <> length? cif/document-list
         0 = last cif/document-list
      ]
   ] [
      remove back tail cif/document-list
   ]
```

---
- `remove-each/reverse _ path [attempt [to get a function and break]]`
- `remove-while/reverse _ path [attempt [to get a function]]`
```
	while [
		not any [
			tail? path 
			any-function? attempt [get/any either 1 = length? path [path/1][path]]
		]
	][
		clear back tail path
	] 
```

---
- `remove-each [x y] base [..]`
```
    while [not empty? base] [
        either remove-clause second base predicat all [
            if empty? second base [
                remove/part base 2
            ]
            if not all [
                break
            ]
        ][
            base: skip base 2
        ]
    ]
```

---
- `remove-each [:name y] base [..]`
```
    while [not none? base: find/skip base name 2][
        either remove-clause second base predicat all [
            if empty? second base [
                remove/part base 2
            ]
            if not all [
                break
            ]
        ][
            base: skip base 2
        ]
    ]
```

---
- `remove-each x base [..]`
```
    while [not empty? base] [
        set local save
        object: make clause first base
        either unify predicat object/predicat [
            base: remove base
            result: true
            if not flag [
                break
            ]
        ][
            base: skip base 1
        ]
    ]
```

---
- `remove-each t position [any [tag <> t break]]`
- `remove-while t position [tag <> t]`
```
	while [tag <> position/1][
		probe reform ["No End Tag:" position/1]
		if empty? branch [make error! "End tag error!"]
		take branch
	]
```

---
- removes outdated timestamps from a queue's head - for that finds first timestamp that's still actual
- `remove-each [_ t] ps [...]`
```
	while [all [
		not empty? ps
		limit < to time! t - ps/2 // 24:0:0
	]] [ps: ps ++ 2]
	ps: remove/part head ps ps
```
