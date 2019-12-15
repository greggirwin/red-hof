# FORALL

FORALL is a somewhat low-level construct. It's main use is to **provide for the deficiencies of FOREACH**:
- 42% were imitating MAP-EACH, latter being unavailable or limited (67% in-place maps, 33% mapped into another target)
- 31% were meant to be FOREACHs, but didn't become so for whatever reason
- 20% were adding an index to FOREACH, noble cause if REPEAT wouldn't have been better at that
- 1 case was a REPEAT in disguise
- 1 case was imitating a REMOVE-EACH
- 4% (only) were really meant to be FORALLs

Among FOREACH imitations, **18%** were **lookups** (break or return after a value is found).
About **11%** of all FORALLs were **filtering** the inputs before processing.

**Features** of FORALL:
- It **provides an index** in the form of series position, although in the vast majority of cases that index is **used numerically** as `index? series`. This is easy to add into FOREACH.
- With that index one can **modify the series** in place. Something a MAP-EACH must be able to do more gracefully.
- Easy access to **adjacent items** - `series/2`, `series/3`... Can be done with a refinement for FOREACH (e.g. `/stride`) that will fix it's step at 1 and also prevent iterations where one of the need items is over the tail (FORALL requires an additional check for that).
- It's **possible to advance** the series when needed, when the loop algorithm requires. This can be solved by adding an `advance` function to FOREACH, same as we have `keep` in COLLECT.
- It's **possible to replace** the series: `forall s [.. s: something-else..]`, and FORALL continues on the new series. Well, it's possible in R2 & R3, but not in Red ☻ Red complains about that, by design.

I believe we can almost totally replace FORALL (along with half of WHILEs and UNTILs) with **more declarative `-each`** loops if we provide the facilities mentioned above.

One other feature is that FORALL **leaves the index** of the series as is **after a BREAK**.
Sometimes this was used in lookups: index after BREAK tells *where* the found item is.
In one identified case this feature was used to update the series index to later be able to enter another FORALL, from that index.
**Most of the time** though, it was either **assumed** that the loop finishes without BREAK, so the index will be set to head, or this feature was **fought against** by placing an explicit `series: head series` after. And it makes sense - very **rarely** we want the series be **left not at it's head**.


# Examples

**Navigate**:
  * [Imitations of MAP-EACH, in-place, unfiltered](#imitations-of-map-each-in-place-unfiltered)
  * [Imitations of MAP-EACH, in-place, filtered](#imitations-of-map-each-in-place-filtered)
  * [Imitations of MAP-EACH, another target](#imitations-of-map-each-another-target)
  * [Imitations of FOREACH with index](#imitations-of-foreach-with-index)
    + [Lookups](#lookups)
  * [Imitations of FOREACH without index](#imitations-of-foreach-without-index)
    + [Lookups](#lookups-1)
  * [Other cases](#other-cases)


## Imitations of MAP-EACH, in-place, unfiltered

Most of these can be considered "bulk application" (see [FOREACH](foreach/README.md))

---
- in-place map + accumulator
- `map-each p shape [pos: pos + p]`
```
	forall shape [shape/1: pos: pos + shape/1]
```

---
- `map-each xy dxy [sqrt xy]`, but better to support `sqrt` on vectors
```
	forall dxy [dxy/1: sqrt dxy/1]
```

---
- in-place map with skip=2; `val` and `char` are strings; should deadlock if `1 < length? char` ?
- `map-each x val [rejoin [char x]]` - way cleaner
- `map-each/sep x val [x] char`
- `delimit val char`
```
	forall val [
		insert val char
		val: next val
	]
```

---
- in-place map with skip=2
- `parse body [any [skip change set x skip (form x)]]`
- `map-each [x y] body [reduce [x form y]]`
- `map-each/eval [x y] body [ [x form y] ]`
- `map-each x body [advance form x]`
```
	forall body [body: next body body/1: form body/1]
```

---
- `map-each x list [to-set-word x]`
- `to-set-word list/*` ?
```
	forall list [change list to-set-word list/1]
```

---
- some magic here
```
    forall word [
        X: to-string to-word first word
        change X to-char uppercase to-string first X 
        change word to-word X 
    ]
```

---
- `map-each x block [dirize to-file x]`
```
	forall block [
	    change* block to-file rejoin [first block "/"]
	]
```

---
- `p/*: to-word p/*` ?
```
	forall p [change p to-word first p]
```

---
```
	forall res [change/part res/1 object res/1 1]
```

---
```
	forall words [words/1: form words/1]
```

---
```
	forall str [str/1: str/1 - pick "70" str/1 >= #"A"]
```

---
```
	forall frames [change frames load-image first frames] 
```

---
```
	forall new [new/1: new/1 xor b]
```

---
```
	named [forall result [change/only result name-fields db result/1]]
```

---
```
	forall data [
		data/1: apply :f compose [(first data) (code)]
	]
```

---
```
	forall subordinate [
		..
		val: pick subordinate 1
		either any [
			..
		][
			..
			change subordinate to-word val
		][
			..
			change subordinate do val
		]
	]
	blk: subordinate: head subordinate
```

---
```
    forall t [
        if head? t [uppercase/part t 1] 
        if find [#" " #"-"] first t [uppercase/part t 2]
    ]
```


## Imitations of MAP-EACH, in-place, filtered

---
- `map-each [x (block!)] args [any [x/1 x/2]]` ?
```
	forall args [
		if block? args/1 [
			args/1: any [args/1/1 args/1/2]				;-- replace block with id
		]
	]
```

---
```
	forall args [
		if any [
			find/only facet-words first args
			all [old-face/words find old-face/words first args]
		][
			change args to-lit-word first args
		]
	]
```

---
```
move-connected: func [p3d][
	forall connected [
		either all [
			any [
				find [line spline] connected/1/-1
				parse skip connected/1 -2 [some [l: ['line | 'spline] to end | pair! (l: back l) :l | reject]]
			]
			any [
				; start- arrow
				block? connected/1/-2
				'transform = connected/1/3
				; end-arrow
				'transform = connected/1/2
				block? connected/1/-3
			]
		][
			; transform's offset is changed already (catched automatically)
			; but we have to change line's point manually because we have intercepted this
			change connected/1 connected/1/1 + p3d
				...
			]
		][
			change connected/1 connected/1/1 + p3d
		]
	]
]
```

---
- `map-each [x (number!)] block [to-char x // 256]`
```
	forall block [
		if number? block/1 [change block to-char either block/1 >= 0 [block/1][256 + block/1]]
	]
```

---
- foreach or in-place map
- `map-each [p (pair!)] pos3 [...]`
```
	forall pos3 [
		if pair? pos3/1 [
			case [
				all [negative? len curpos < pos3/1/1] [pos3/1/1: pos3/1/1 + len]
				all [negative? len curpos > pos3/1/1 curpos < (pos3/1/1 + pos3/1/2 + len)][pos3/1/2: pos3/1/2 + len]
				all [positive? len curpos <= pos3/1/1] [pos3/1/1: pos3/1/1 + len]
				all [positive? len curpos > pos3/1/1 curpos <= (pos3/1/1 + pos3/1/2 + len)][pos3/1/2: pos3/1/2 + len]
			]
		]
	]
```


## Imitations of MAP-EACH, another target

---
- `map-each/into x src [reduce [either ..]] out`
- `append out map-each/eval x src [ [either ..] ]`
```
    forall src [ repend out [ either as-is [mold src/1] [src/1] delimiter ] ]
```

---
- map with index and able to skip an arbitrary number of items
- `map-each [pos: x] src [... advance/by -1 + length? var ...]`
```
	forall src [
		append out compose [set index (index? src)]
		either block? var [
			repeat i length? var [
				append out compose/only copy/deep [set (var/:i) (src/:i)]
			]
			src: skip src -1 + length? var
			append/only out copy/deep content
		] [
			append out compose/only copy/deep [set (var) (src/1) (copy/deep content)]
		]
	]
```

---
- map - grouping with delimiter: tail check
- `map-each/sep x values [switch ...] delimiter`
```
	forall values [
		append result switch/default type?/word values/1 [
			word! 		[get-user-word :values/1]
			lit-word! 	[form to word! values/1]
			issue!		[form to word! values/1]
		] [form values/1]
		all [
			delimiter 
			not tail? next values
			append result delimiter
		]
	]
```

---
- map with index
- `map-each [int: x] int [romans/(length? int)/(x - #"/")]`
```
    forall int [
        insert tail res pick pick romans length? int int/1 - #"/"
    ] 
```

---
```
	found: selection-start
	forall move-points [
		found: find next found move-points/1
		append edit-layer/pane layout/only head insert at copy/deep [
			at base 10x10 loose glass draw [line-width 2 fill-pen transparent pen 80.150.255 circle 5x5 4]
			with [
				extra: make map! reduce ['ref 1 + offset? selection-start found]
				actors: object [
					...
				]
			]
		] 2 move-points/1 - 5x5
	]
```

---
- normal map over 2 vectors
- `map-each [x y] zip [v1 v2] [f x y]` - just as slow :)
```
vjoin: func [v1 v2 f] [
	collect [
		forall v1 [
			keep f v1/1 v2/1
			v2: next v2
		]
	]
]
```

---
```
	forall points [append df-points pos3 - points/1]
```

---
- this stops working properly after first use :)
```
copy collect/into [forall data [keep to char! data/1]] {}
```

---
```
collect [if data [
	either type = 'text [
		lines: data
		forall lines [
			keep form reduce [pad/left index? lines 4  lines/1]
		]
	][
		prev: none
		foreach [file line] data [
			keep line: rejoin [form to-local-file file "/" line]
			; unless line = prev [keep line]   can't skip yet or will be unable to find index in data
			prev: line
		]
	]
]]
```

---
- map-each or foreach, with index
```
	forall words [
		either block? :path [
			type: type? words/1
		][
			type: type? case [
				any-list? get path [
					pick get path index? words
				]
				any-function? get path [get words/1]
				any [map? get path any-object? get path][select get path words/1]
				true [
					attempt/safer [words/1]
				]
			]
		]
		if type2: in-types? type [
			repend/only selected [words/1 type type2]
		]
	]
```

---
```
	forall data [
		blk-ctr: blk-ctr + 1
		gt: either odd? blk-ctr [bg-clr] [bg-clr + 20.20.20]
		item-data: first data
		append rblk compose/deep [
			wtext 100  static-size -1x20 (copy/part mold :item-data 100) with [color: (gt)]
		]
	]
```


## Imitations of FOREACH with index

Curiously, almost all these examples use `forall series [..index? series..]` to achieve their goal.
Where REPEAT seems more suitable for that: `repeat i length? series [..i..]`.

---
- maximum with an index of it; though `find` may be faster if we make an R/S maximum func
```
	forall next series [
		if series/1 > max [
			max: series/1
			pos: index? series
		]
	]
```

---
```
	forall para [
		position: :para
		set 'value para/1
		inline/event value
	]
```

---
```
	forall faces [
		#if config/OS = 'Windows [				;@@ remove this system specific code
			faces/1/visible?: make logic! all [visible? face/selected = index? faces]
		]
		faces/1/parent: face
		if init [show/with faces/1 face]
	]
```

---
```
	forall move-points [
		x: divide -1 + index? move-points 4
		poke figure-proper x + 1 + index? move-points move-points/1 + diff
	]
```

---
```
	forall move-points [poke figure-proper 1 + index? move-points move-points/1 + diff]
```

---
```
	forall move-points [poke figure-proper -1 move-points/1 + diff poke figure-proper pick moveable index? move-points move-points/1 + diff]
```

---
```
	forall move-points [poke figure-proper pick moveable index? move-points move-points/1 + diff]
```

---
```
	forall strokes [
		if same? strokes limit [break]
		stroke: either 1 = offset? strokes limit [optimize strokes/1][strokes/1]
		if 6 > length? stroke [continue]
		keep to-spline size * scale stroke
	]
```

---
```
	forall data [
		item-data: first data
		item: to-string index? data
		blk-ctr: blk-ctr + 1
		gt: either odd? blk-ctr ['toggletext]['toggletext-odd]
		switch/default type?/word :item-data [
			...
		][
			append vblk compose/deep [(gt) 50 (rejoin [to-string item " (" type?/word :item-data ")"]) static-size -1x20 with [idata: (:item-data)] [inspect get in face 'idata (to-string item) (depth + 1)]]
		]
	]
```

---
```
	forall data [
		blk-ctr: blk-ctr + 1
		gt: either odd? blk-ctr [bg-clr] [bg-clr + 20.20.20]
		item-data: first data
		append rblk compose/deep [
			wtext 100  static-size -1x20 (copy/part mold :item-data 100) with [color: (gt)]
		]
	]
```

---
- filtered
```
	forall points [
		if 5 >= sqrt add power first ds: pos1 - points/1 2 power second ds 2 [
			i: index? points 
			; register offsets of the point for s, edit1 and edit2
			face/extra: reduce [1 + i    7 + i    7 + (i - 1 * 3 + 1)]
		]
	]
```


---
- unboxing foreach with index
- `foreach [pos: [word type type2]] selected [...]` ?
```
	forall selected [
		set [word type type2] selected/1
		color: get-color type type2
		make-box/with word index? selected reduce [type type2]
	]
```

---
```
	forall words [
		make-box words/1 index? words
	]
```

---
- foreach with tail check
```
    forall plots [
        subplot: first plots
		...            
        if ((type? first subplot) = pair!) [remove subplot]
        this-img: to-image quick-plot (head insert subplot subplot-size)
        ...
        if (not tail? next plots) [
            append panes-blk compose [origin (this-origin - 2) box (box-size) coal] 
        ]
    ]
```


### Lookups

---
- `lookup months [m: (month = copy/part m 3)]` ?
```
	forall months [
		if equal? month copy/part first months 3 [
			return index? months
		]
	]
```

---
- gets match and position
- `if match: lookup list [x: (find/match form x get-face face)] [complete face]`
```
    forall list [
        if find/match form first list get-face face [match: list complete face break]
    ] 
```


## Imitations of FOREACH without index

Why not use foreach? Could be mistakes? Refactoring leftovers?

---
- in-place map? can be foreach
```
	forall x [detab x/1]
```

---
- in-place map? can be foreach
```
	forall filt [append first filt ";"]
```

---
- `file` is a port, probably was not supported by foreach
```
    forall file [
        parse/all first file [
        	...
        ]
    ]
```

---
- `foreach x value [replace/all ...]`
```
	forall value [
		replace/all value/1/text #"{" "^^{"
		replace/all value/1/text #"}" "^^}"

		replace/all value/1/html #"{" "^^{"
		replace/all value/1/html #"}" "^^}"
	]
```

---
- filtered
```
	forall blk [
		face: first blk
		if (val: coord/s face/min-size dir) >= acc [
			acc: val
			largest: face
		]
	]
```

---
```
	forall pane [
		face: first pane
		... pane is not used... :(

		face/offset: current-offset
		face/layout amount
		current-offset: oriented-add current-offset amount dir
		faces-left: faces-left - 1
	]
```

---
```
	forall entering [do-event entering/1 'enter offset]
```

---
- filtered
```
	forall entered [
		unless away = entered/1 [
			do-event entered/1 'over offset
		]
	]
```

---
```
	forall lines [
		resolve/all line lines/1
		print [
			id ",lv:" bra/level
			"[" select bra/opener 'id
			"-" select bra/closer 'id "]:"
			mold/only new-line head tokens off
		]
	]
```

---
- filtered
```
	forall pane [
		subface: first pane
		;print [">>" subface/text]
		if object? subface [
			subface: make_gobs_from_face subface
			subface/parent-face: face
			append gobcp subface/gob
		]
	]
	pane: head pane
```

---
```
	forall pane [
		update_gobs_from_face/no-refresh first pane
	]
	pane: head pane
```

---
```
	forall path [
		targ: first path
		try [targ/feel/detect targ event]
	]
```

---
- `-line-` contains code to evaluate
```
	forall ls [parse ls/1 -line-]
```

---
```
	forall breaks [
		pos: breaks/1
		change/part at head out pos + 4 + 4 + 1 to-int32 (length? out) 4
	]
```

---
```
	forall breaks [
		pos: breaks/1 ; take position of jump
		change/part at head out pos + 2 to-int32 ((length? out) - pos - 5) 4
	]
```

---
- foreach with step=1 and 2 items known; skips the last item
- `foreach/stride [pos face] opts [...]` ?
```
	forall opts [
		if 1 < length? opts [
			max-x: max max-x lim x opts/1
			max-y: max max-y lim y opts/1
			opts/2/offset: either options/size/x - opts/2/size/x - 20 < lim x opts/1 [
				max-x: 0
				as-pair 10 cur-y: max-y + 10
			][
				as-pair max-x + 10 cur-y 
			]
		]
	] 
```

---
- foreach with step=1 and 2 items known
- `foreach/stride [l1 l2] lines [...]  keep ...` ?
```
	forall lines [
		either 1 < length? lines [
			...uses lines/1 lines/2 and index? lines...
		][
			keep line2 keep l2*						; last line
		]
	]
```

---
- foreach with step=1 and 3 items known; skips the last 2 items
- `foreach/stride [a b c] pane [...]` ?
```
	forall pane [
		if all [2 < length? pane not find pane/1/options 'connect][
			max-y: max max-y lim y pane/1
			max-x: max max-x lim x pane/1
			either face/options/direction = 'vertical [
				pane/3/offset: either face/size/y - pane/3/size/y - spacing*/y < lim y pane/1 [
					...
				]
			][
				pane/3/offset: either face/size/x - pane/3/size/x - spacing*/x < lim x pane/1 [
					...
				]
			]
		]
	]
```

---
- foreach with an ability to advance upon request
```
	forall args [
		arg: first args
		unless string? :arg [arg: form :arg]		;-- should never happen?

		either not all [allow-options?  option?/options arg opts] [
			either all [arg == "--" allow-options?]
				[ allow-options?: no ]
				[ repend r [none arg] ]
		][
			parse arg [
				...
							args: next args
							if empty? args [complain [ER_EMPTY arg "needs a value"]]
							arg: :args/1
							unless string? :arg [arg: form :arg]		;-- should never happen?
				...
			];; parse arg
		];; else: either not all [allow-options?  option?/options arg opts]
	];; forall args
```

### Lookups


---
- `not none? lookup ports [in (waked)]`
```
    forall ports [
        if find waked first ports [return true]
    ]
```

---
- lookup - should be foreach
- `found-text: copy first lookup texts [string! x: (find/match x start-text)]` ?
```
    forall texts [
        if string? texts/1 [
            if find/match texts/1 start-text [found-text: copy texts/1 break]
        ]
    ] 
```

---
- lookup; foreach with 2 points known at once and skip=1
- `foreach/stride [p1 p2] points [...]`
- `index? lookup points [p1: 1 p2: 2 (at-distance-from-line? event/offset p1 p2 7)]` ?? this complicates `lookup` to much
```
	forall points [
		if all [
			1 < length? points 
			at-distance-from-line? event/offset points/1 points/2 7
		][
			point-idx: index? points
			;face/extra/1: min points/1 points/2 
			;face/extra/2: max points/1 points/2
			break
		]
	]
	points: head points
```

---
- lookup - foreach
- `foreach t with-types [t: get t  if any [t = type  all [typeset? t find t type]] [return t]]`
- `lookup with-types [x: (type = get x) or (all [...])]` boring...
```
	with-types: head with-types
	forall with-types [
		if any [
			type = get with-types/1 
			all [
				typeset? get with-types/1 
				find get with-types/1 type
			]
		] [return with-types/1]
	]
```

---
- complex lookup - foreach?
```
	forall typesets [
		if either typeset? get type2 [
			find intersect get typesets/1 get type2 type
		][
			find get typesets/1 get type2
		][
			color: select options typesets/1
			if color [break]
		]
	]
```


## Other cases


---
- `remove-each x clauses [:goal/1 = :x/2/1]`
```
    forall clauses [
        if equal? first goal first second first clauses [
            remove clauses
        ]
    ]
```

---
- tricky; replaces `args` with new series
```
    forall args [
        val: first args 
        switch/default type?/word val [
        	...
            word! [
                any [
                    if all [new/words tmp: find new/words :val] [
                        until [function? first tmp: next tmp] 
                        args: do first tmp new args
                    ] 
                    if tmp: find facet-words :val [
                        either 0 >= offset? tmp fw-with [
                            until [function? first tmp: next tmp] 
                            args: do first tmp new args
                        ] [
                            either tail? args: next args [error "Missing argument for" :val] [
                                set in new val either positive? offset? fw-feel tmp [
                                    first args
                                ] [
                                    if first args [make any [get in new val vid-face/:val] bind/copy first args new]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ] [
            error "Unrecognized parameter:" val
        ]
    ] 
```

---
- true forall - saves index of `lines'`; can be indexed foreach but that probably won't win a thing
```
	forall lines' [
		pos: (cells-to-size cells) - ori
		if sz/y <= pos/y [break]
		ln: lines'/1
		if all [text?  subs: leave-only ln sub][
			keep compose [pen (cbox) text (pos + hlofs) (make-boxes subs) pen (ctxt)]
		]
		keep compose [text (pos) (ln)]
		if all [text?  subs][
			keep compose [pen (chlt) text (pos) (subs) pen (ctxt)]
		]
		if com: find ln #";" [
			exc: make-excerpt ln com length? ln
			keep compose [pen (ccom) text (pos) (exc) pen (ctxt)]
		]
		cells/y: cells/y + 1
	]
```

---
- true forall ? can be in-place map
```
	forall s-doc [
		trim/tail s-doc/1
		while [cols/5 < length? s-doc/1] [		;-- split by column width parts
			s-doc: insert  s-doc  take/part s-doc/1 any [
				find/part/last/tail s-doc/1 #" " cols/5
				cols/5
			]
		]
	]
```

---
- this should be `repeat n length? block [repend ...]`
```
	forall block [
		append spec compose/deep/only [(to-word join '_ n) [decimal!]]
		n: n + 1
	]
```

