# REPEAT

REPEAT's **main place** is where a **counter** has to be used without **series**.
It can be good for data **sets generation**, iteration over non-series datatype (like **tuple**), or where **indexes are stored** in the program directly.
Besides, it's a very tight loop when compiled, involving no function calls, so it makes sense where one wants to push **performance** a bit.

Still, people often need **an integer index** to use in FOREACH, and REPEAT suits this task better than FORALL.
And another common use of it is to iterate **over 2 or more series** at once - where FOREACH over a zip-stream can help.

REPEATs were found to be **distributed** as follows:
- 49% were justified `repeat`s
- 27% were imitating `map-each` (40% in-place maps, 60% normal maps, almost all unfiltered)
- 12% were imitating `foreach` (with index or over 2+ series)
- 11% were other cases (mostly `append/dup` and `loop` imitations)

All in all, REPEAT examples only further confirm the list of features that WHILE has hinted at.

# Examples

**Navigate:**
  * [Imitations of MAP-EACH, in place](#imitations-of-map-each-in-place)
  * [Imitations of MAP-EACH, another target](#imitations-of-map-each-another-target)
  * [Imitations of FOREACH](#imitations-of-foreach)
  * [True REPEAT](#true-repeat)
  * [Unclassified REPEAT](#unclassified-repeat)


## Imitations of MAP-EACH, in place

- in-place map with index
- `map-each/self [i: x] data [to char x xor mask/(i + 3 // 4 + 1)]`
```
	repeat i len [
		data/(i): to char! data/:i xor mask/(i + 3 // 4 + 1)	;-- in-place decoding
	]
```

---
- in-place map, filtered by index
- `map-each/self [i: x] log [all [even? i continue] to-integer second parse x none]`
```
	repeat i length? log [
		if odd? i [
			poke log i to-integer second parse pick log i none
		]
	]
```

---
- `map-each/self x path-map [to either word? x [set-word!][set-path!] x]`
```
	repeat i length? path-map [
		path-map/:i: either word? path-map/:i [to set-word! path-map/:i] [to set-path! path-map/:i]
	]
```

---
- `map-each/self x data [...]`
```
replace-deep: function [
	"Replaces all occurences of search values with new values in a block or nested block"
	data [block!] "Block to replace within (modified)"
	map [map! block!] "Map of values to replace"
] compose/deep [
	repeat i length? data [
		either block? data/:i [replace-deep data/:i map] [
			all [
				not path? data/:i
				not set-path? data/:i
				val: (either settings/build = 'r2 [[select-map]] [[select]]) map data/:i
				any [
					equal? type? data/:i type? val
					all [word? data/:i path? val]
					all [set-word? data/:i set-path? val]
				]
				data/:i: val
			]
		]
	]
	data
]
```

---
- in-place map, strings to integers
- `map-each/self x date [to integer! x]`
```
	repeat i 3 [date/:i: to integer! date/:i]
```

---
- in-place map, wraps every row into a block
- does it work though? index `i` in data will become wrong after the 1st change
```
	repeat i rows [
		change/part/only at data i copy/part at data i cols cols
	]
```

---
- in-place map, computes difference between adjacent items
- can be `map-each/stride/self [x1 x2] widths [x2 - x1]` ?
- the trick of this snippet is that the last item becomes unchanged, and it probably doesn't matter then
```
	repeat i -1 + length? widths [
		poke widths i widths/(i + 1) - widths/:i
	]
```

---
- `map-each x fields: .. [to word! ..form x..]`
```
	repeat i length? fields: copy/deep first head data [
		poke fields i to word! join '& trim/with trim/all form fields/:i "@#$%^,"
	]
```

---
- `map-each/self c columns: ... [any [all ... [...]  c]]`
```
	repeat i length? columns: to block! columns [
		all [
			word? columns/:i
			any [
				columns/:i: select number-map columns/:i
				settings/error "invalid /part position"
			]
		]
	]
```


## Imitations of MAP-EACH, another target

- interestingly, R2 `repeat` accepts a series and works same as foreach, though it's a rare use case
- so this is a disguised foreach
- `vars-space` is a binary, so it's also a normal map from `params` to binary
- `change vars-space map-each/into param reduce params [to-float64 param] #{}` - may as well be faster despite the intermediate binary
```
	repeat param reduce params [
		change/part vars-space to-float64 param 8
		vars-space: skip vars-space 8
	]
```

---
- disguised foreach
- `stub: map-each entry expose-list [...]`
```
    repeat entry expose-list
    [  
      either secure-code
      [ append stub build-proxy/with/secure-code to-word entry num ]
      [ append stub build-proxy/with to-word entry num]
    ];repeat
```

---
- disguised foreach
- `spec: map-each/only word words [get word]`
- `spec: get words/*` ??
```
	repeat word words [insert/only tail spec get word ]
```

---
- what does it do with `line`?
```
	repeat index length? select data first keys [
		line: make string! 100
		append output to-csv-line collect [
			foreach key keys [keep data/:key/:index]
		] delimiter
	]
```

---
- normal map over 2 series; copy/deep is paranoid here
- `map-each [v s] zip [var src] [reduce ['set v s]]`
- `map-each/eval [v s] zip [var src] [ ['set v s] ]`
```
	repeat i length? var [
		append out compose/only copy/deep [set (var/:i) (src/:i)]
	]
```

---
- normal map with index
- `map-each [i: x] fields [reduce [x  append to path! 'row i]]`
- `map-each/eval [i: x] fields [ [x  append to path! 'row i] ]`
```
	repeat i length? fields [
		append path-map reduce [
			fields/:i
			append to path! 'row i
		]
	]
```

---
- normal map
- `map-each/into x :data/1 [to char! x] bin` - much better than pick-pick thingie
- `append bin map-each x :data/1 [to char! x]` - if we're against /into
```
	bin: make binary! size
	repeat i size [
		insert tail bin to char! pick pick data i 1
	]
```

---
- normal map with an integer index
- `blk: map-each [i: x] spec [rejoin [..]]` -- should use `composite` though
```
	repeat i width [
		append blk rejoin [{<col min="} i {" max="} i {" width="} spec/:i {"/>}]
	]
```

---
- normal map
- `map-each/sep/into x sects [x] "." ""`
- `delimit/into sects "." ""` ?
```
	repeat n num [append sn join sects/:n "."]
```

---
- normal map
- `map-each [os: x] record [reduce [db/locals/columns/:os/name x]]`
- `map-each/eval [os: x] record [ [db/locals/columns/:os/name x] ]`
```
	repeat os length? record [
		keep db/locals/columns/:os/name
		keep/only record/:os
	]
```

---
- normal map with index - enumeration of filtered items
- `map-each [nn: x] cif/document-list [if 0 = x [continue] nn]` if we use `continue` to remove, or
- `map-each [nn: x] cif/document-list [if 0 <> x [nn]]` if we use `unset` to remove
```
   repeat nn length? cif/document-list [
      if 0 <> cif/document-list/:nn [;; ignore deletion placeholders
         insert all-doc-ids nn
      ]
   ]
```

---
- filtered or not, normal map - enumeration
- `map-each [i: x] data* pick [ [either ffunc* x [i][[]]] [i] ] any-function? :ffunc*`
```
    repeat i length? data* 
    either any-function? :ffunc* [
        [if ffunc* data*/:i [insert tail fidx* i]]
    ] [
        [insert tail fidx* i]
    ] 
```

---
- `map-each/into [i: x] :fn [any [all [:x to-char i] continue]] copy ""` ?
- `rejoin map-each [i: x] :fn [any [all [:x to-char i] continue]]` ?
- `rejoin map-each [i: x] :fn [any [all [:x to-char i] ()]]` ?
```
	mold rejoin collect [repeat i length? :fn [if pick :fn i [keep to-char i]]]
```


## Imitations of FOREACH

---
- disguised foreach
```
    repeat item portz
    [
      current-port: item
      either (is-server? item)      
      [
      	..item is used..
      ]
    ]
```

---
- disguised foreach - even the closing bracket is followed by `foreach`
```
      repeat ref f-ref
      [
        ref-pos: find/tail f-sig to-refinement ref
        if not none? ref-pos
        [
          next-ref-pos: find ref-pos refinement!
          if not none? next-ref-pos
          [
            argc: argc + ((index? next-ref-pos) - (index? ref-pos))
          ];if not none next-ref-pos
        ];if not none? ref-pos
      ];foreach ref f-ref
```

---
- foreach over 2 series, but requires index of `buffer` - which is tricky
- `foreach [i: c b] zip [columns buffer] [...max size maximum map-each x extract at b 1 + i / 2 rows [form x]...]`
```
	repeat pos cols [
		;	calculate max column width
		size: length? form columns/:pos
		buffer: at buffer pos
		loop rows [
			size: max size length? form first buffer
			buffer: skip buffer cols
		]
		buffer: head buffer
		;	build format masks
		prin pad form columns/:pos size + 1
		insert/dup tail separator "-" size
		insert tail separator " "
		insert tail format reduce ['pad columns/:pos size]
	]
```

---
- foreach over 2 series (both are of 4 items)
- `foreach [st er] zip [state err] [unless st [cause-error 'access 'cannot-open [er]]` - even longer than repeat in this case
```
	repeat i 4 [unless state/:i [cause-error 'access 'cannot-open [err/:i]]]
```
```
	repeat i 4 [if handle? state/:i [cause-error 'access 'cannot-close [err/:i]]]
```

---
- foreach over 2 series
- `foreach [label value] zip [labels values] [...]`
```
	repeat i length? labels [
		label: labels/:i
		value: values/:i
		...
		set-user-word label value
	]
```

---
- foreach with index
- `foreach [i: result] results [...]`
```
    repeat i length? results [
        result: pick results i
        if result/status = 'Failure [
            print [i ")" mold-flat result/test 80]
        ]
    ]
```

---
- foreach with index (though it depends on where that index starts)
- `foreach [i: x] next statement [replace/all spec join ":" i x]`
```
	repeat i -1 + length? statement [
		replace/all spec join ":" i pick statement i + 1
	]
```

---
- populates map; can be indexed foreach
- `foreach [i: x] fields [put number-map x i]`
```
	repeat i length? fields [
		put number-map fields/:i i
	]
```

---
- foreach over 2 series
- `foreach [h l] zip [header line] [value/:h: l]`
```
	repeat index length [
		value/(header/:index): line/:index
	]
```



## True REPEAT

These examples are characterized by the usage of an index apart from any given series.

---
- char counting; great (fast) way of having foreach stop at a certain (non-tail) offset, without an extra check
- if we had a `limit` func that would stop after n items:
- `length? sift limit pos-start pos-end [is (tab)]`
```
    repeat i offset: offset? pos-start pos-end [
        if #"^-" = pick pos-start i [
            tabs: tabs + 1
        ]
    ] 
```

---
- could be map-each if `cols = length? buffer`, but unlikely it is
```
	repeat pos cols [
		insert tail page either find [integer! money! decimal!] type? buffer/:pos [
			{<col align="right">}
		][
			{<col align="left">}
		]
	]
```

---
```
	repeat cnt padding [
		insert lower current - cnt
		append upper current + cnt
	]
```

---
```
	repeat rowid (tables/:table/rows) [
		poke buffer pos: pos + (length? columns) rowid
	]
```

---
```
	repeat pos tables/:table/cols [
		if buffer/:pos = 'next [
			poke buffer pos either tables/:table/rows > 0 [
				1 + pick tail tables/:table/data pos - tables/:table/cols - 1
			][1]
		]
	]
```

---
- foreach over 2 series, but only over a part of them; will be ugly to use foreach here
```
	repeat pos (length? columns) [
		poke data offsets/:pos values/:pos
	]
```
```
	repeat pos (length? columns) [
		poke data offsets/:pos blk/:pos
	]
```

---
```
	repeat i tag/items [
		append carousel-menu reduce [
			'li 'with compose [
				data-target: ( to issue! tag/id )
				data-slide-to: ( i - 1 )
				( either i = tag/active [ [ class: active ] ] [] )
			]
			""
		]
	]
```

---
```
collect/into [
	repeat i 6 * 64 [
		keep reduce [
			'rotate i - 1 * 0.9375 150x150 
			compose [
				fill-pen (make-color i) 
				arc 150x150 128x128 0 1 closed
			]
		]
	]
] drw 
```

---
- could be map-each with 2 items known at once, step=1, and an integer index, but it's complicated: has to replace only the 2st item
```
	repeat i length? p: info-panel/pane [
		j: i - 1
		if i > 1 [p/:i/offset/x: p/(i - 1)/offset/x + p/(i - 1)/size/x + 5]
		if x: attempt [pick size-text p/:i 1][p/:i/size: as-pair x 35]
	]
```

---
```
	repeat i g-step/data/y - 1 [
		keep reduce ['line as-pair 0 i * g-size/data/y as-pair g-step/data/x * g-size/data/x i * g-size/data/y]
	]
```

---
- swaps rows in 2 tables
```
	repeat j MAP_PERIOD [swap at i1 j at i2 j]
```

---
```
  repeat node length? path [
      short-path: copy/part path node
      if node > 1 [emit " / "]
      emit [<span>]
      emit [
          build-tag compose [
              a href (rejoin [anchor-root next short-path either node > 1 ["/"][""]])
              title (either node = 1 ["home"][mold short-path/:node])
          ]
          short-path/:node
          </a> </span>
      ]
  ]
```

---
- true repeats, as map-each won't work on tuples (c0 and c1)
```
	c: copy [0.0 0.0 0.0]
	repeat i 3 [c/:i: (c1/:i * max 0.0 mix) + (c0/:i * max 0.0 1.0 - mix)]
```
```
	repeat i 3 [
		c/:i: c/:i - (hi - 255.0 * (c/:i - lo) / (hi - lo))
	]
```
```
	repeat i 3 [
		c/:i: c/:i - (lo * (hi - c/:i) / (hi - lo))
	]
```
```
	repeat i 3 [c/:i: max 0 min 255 to-integer c/:i]
```

- true repeat, as foreach won't work on tuples (a and b)
```
	d: 0  repeat i 3 [d: max d absolute a/:i - b/:i]
```

---
```
	repeat i height [
		keep reduce ['at pos + (i * 0x1) "│"]
	]
```

---
```
	repeat j lines-per-page [
		ansi/do print-line data line - 1 + j * 16
	]
```

---
```
	repeat page pages [
		print ["page" page]
		append issues github/get-issues/repo/page/with repo page + 1 [state: 'all]
	]
```

---
```
	repeat i min count 255 [
		c: 3 * (log-e i) / log-e (count - 1.0)
		c: case [
			c < 1 [(to integer! 255 * (c - 0)) * 1.0.0 +   0.0.0]
			c < 2 [(to integer! 255 * (c - 1)) * 0.1.0 + 255.0.0]
			true  [(to integer! 254 * (c - 2)) * 0.0.1 + 255.255.0]
		]
		append palette c
	]
```

---
```
d: collect [repeat i 100000 [keep append/dup copy "" form i 15]]
d2: collect [repeat i 100 [keep append/dup copy "" form i 15]]
```

---
```
	unless empty? cols [repeat i take cols [pop-color]]
```
```
	repeat col cols [append texts rejoin ["Column " col]]
```

---
- can be foreach with integer index, but unlikely, as it has to stop after a number of iterations
- `map-each [x: txt] texts [...]` - it depends on `texts`
```
	repeat x cols [
		append draw-block compose [line (as-pair x * step-x  2) (as-pair x * step-x  size/y - 2)]
		append draw-block compose [
			text (as-pair x - 1 * step-x + 2 4) (form any [texts/:x ""])
		]
	]
```

---
```
	repeat y rows - 1 [
		append draw-block compose [line (as-pair 2  y * step-y) (as-pair size/x - 2  y * step-y)]
	]
```

---
```
    repeat i table/size/x [
        tmp: make-cell-style table none none pick table/columns i 
        insert/only tail content compose [
            cell (either tmp ['opts] [[]]) (either tmp [reduce [make-style/ignore tmp [position]]] [[]]) (either header? header i j ['header] [[]])
        ]
    ]
```

---
- ??
```
	repeat ln 6 [
		if int <= en/:ln [
			char: reduce [os/:ln + to integer! (int / fc/:ln)]
			repeat ps ln - 1 [
				insert next char (to integer! int / fc/:ps) // 64 + 128
			]
			break
		]
	]
```

---
- scary map.. just setting `t: tables/:table` halves it
- can it be map-each? depends on `tables`
```
	repeat offset tables/:table/cols [
		insert tail tables/:table/offsets reduce [
			pick tables/:table/columns offset
			offset
		]
	]
```

---
- looks like an increment of a number in radix=26
- can be `map-each/reverse/self`?
```
	repeat index length [
		position: length - index + 1
		previous: position - 1
		either equal? #"Z" name/:position [
			name/:position: #"A"
			if position = 1 [
				insert name #"A"
			]
		][
			name/:position: name/:position + 1
			break
		]
	]
```

---
- range generation
```
	all [blk: make block! length? face/data repeat i length? face/data [append blk i] blk]
```

---
- gradient generation?
- could've been another loop inside: `repeat j 4 [...]`
```
	length: length - 1
	repeat i length - 1 [
		append blk to-tuple reduce [
			to-integer diff/1 / length * i + color1/1
			to-integer diff/2 / length * i + color1/2
			to-integer diff/3 / length * i + color1/3
			to-integer diff/4 / length * i + color1/4
		]
	]
```

---
- very strange map.. go figure
```
    repeat i length? pos [
        append/only face/data make face/prototype pick face/data pick pos i
    ] 
```

---
- it's like someone wanted this to be unreadable ;)
- I guess it extends objects in `face/data` in a specific order given by `pos`
```
    repeat i length? pos [
        change at face/data pick pos i make pick face/data pick pos i :value
    ] 
```

---
- replaces items with `unset` in a specific order
```
    repeat i length? pos [change at face/data pick pos i ()] 
```

---
- normal map; index is not used, although maybe in `data`? if so, `repeat` makes sense
```
	repeat index count [
		current: copy/deep element
		result: do bind bind data 'index user-words
		either 1 = length? values [
			replace-deep current values/1 result
		] [
			foreach value values [
				replace-deep current value (take result)
			]
		]
		append out current
	]
```

---
- same
```
	repeat index cols [
		current: copy/deep element
		replace-deep current value do bind data 'index
		if offset [
			insert skip find current 'col 2 reduce [ 'offset offset ]
			offset: none
		]
		append out current
	]
```

## Unclassified REPEAT

- there's `insert/dup` for this
```
  str: head repeat i 108000 [insert "" "a"]
```

---
- `append/dup`
```
    repeat i 7 [
        insert tail pane 'date-weekday-cell
    ] 
```
```
    repeat i 6 [
        insert insert/dup tail pane 'date-cell 7 'return
    ] 
```

---
- accumulation - max of a sum
```
    repeat i length? faces [
        pane/size/x: max pane/size/x faces/:i/offset/x + faces/:i/size/x
    ]
```

---
- index is never used, should be `loop`
```
    repeat i length? windows [repend tiles [as-pair width face/size/y offset: as-pair offset/x + width 0]] 
    repeat i length? windows [repend tiles [as-pair face/size/x height offset: as-pair 0 offset/y + height]] 
```

---
- can be loop, unless `blk` uses `rowid`?
```
	[repeat rowid (third predicate) - 1 blk]
```
```
	repeat rowid tables/:table/rows compose/deep [if (predicate) [(blk)]]
```

---
- should be `loop`
```
	repeat tries 10 [
		either handshake connect port [
			close port/sub-port
		][
			return port/locals/stream-end?: true	; force stream-end, so 'copy won't timeout !
		]
	]
```
