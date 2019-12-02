# MAP-EACH imitations

Interesting observation is that so far in-place maps are about as numerous as maps into another target (or copy).

## Mixed, in-place

- `do compose [(either only ['map-each/only/self]['map-each/self]) x series [action x]]`
```
    while [not tail? series][
        series: either only [
            change/part/only series action series/1 1
        ][
            change/part series action series/1 1
        ]
    ]
    head series
```

---
- from `replace` func:
- why does it use remove/insert rather than change? wicked...
- side note: replace doesn't have /same - should it?
- `map-parse/self [copy x pattern] pos [value]`
- too high level for this though :)
```
	len: either many? [length? pattern] [1]
	do-find: pick [find/case find] case
	...
	while [pos: do compose [(do-find) pos pattern]] [
		remove/part pos len
		pos: insert pos value
	]
	...
	while [pos: do compose [(do-find) pos :pattern]] [
		pos: insert remove pos value
	]
```




## Single item, in place


- filtered - only affects blocks
- `map-each/self [x /where block? x] spot [...]` ?
- `map-each/self x spot [either block? x [x][func [new args] x]]`
```
    while [spot: find spot block!] [change spot func [new args] first spot] 
```

---
- same
```
    while [tmp: find tmp block!] [
        change tmp func [new args] first tmp
    ]
```

---
- `map-each tk tokens [ any [do select... [] tk] ]`
```
    while [not tail? tokens] [
        subst-word: do select substitutions first tokens
        if any [subst-word] [
            change tokens subst-word
        ]
        tokens: next tokens
    ]
```




## Multiple items, in place

- from `each` - attempt to define a generalized iterator
```
	while [not tail? series][
		set [(word)] series (body)
		series: change/part series reduce [(word)] (length? word)
	]
```


---
- filtered: skips a row if 1st item is none
- `map-parse/self [copy xs cols skip] buffer [... result or xs]`
```
	while [not tail? buffer] [
		if first buffer [	; skip none!
			if result: binary-search tables/:lookup-table/data first buffer tables/:lookup-table/cols tables/:lookup-table/rows [
				result: first skip tables/:lookup-table/data to-index result tables/:lookup-table/cols
			]
			change buffer result
		]
		buffer: skip buffer cols
	]
	buffer: head buffer
```

---
- skips by `cols`, excludes `result`
- `map-parse/self [copy xs cols skip] buffer [if result = xs [continue] xs]`
```
	while [not tail? buffer][
		if result <> copy/part buffer cols [
			insert tail blk result: copy/part buffer cols
		]
		buffer: skip buffer cols
	]
	buffer: head buffer
```

---
- `replace/all mark #{C2A0} #{20}`
- `map-parse/self [#{C2A0}] mark [#{20}]`
```
	while [mark: find mark #{C2A0}] [
		change/part mark #{20} 2
	]
```
---
- `map-each/self [p: x] mark [...]`
```
	while [mark: invalid-utf? mark] [
		change/part mark to char! mark/1 1
	]
```

---
- `map-each/self x rule [...x or new block of 2 items]`
```
	while [not tail? rule] [
	    either all [rule/1 <> '| not block? get/any word: rule/1] [
	        rule: insert/only change rule 
	        form word to paren! compose [value: (to lit-word! word)]
	    ] [rule: next rule]
	]
```

---
- `map-each/self [x _] [reduce [to word! x _]]`
```
	while [not tail? list][
		poke list 1 to word! first list 
		list: skip list 2
	]
```


## Single item, another target

- `map-each x values [form-value x]`
- or maybe it needs `values` as a block?
```
	rejoin collect [
		while [not tail? values][keep form-value values]
	]
```

---
- from `list-dir`/`ls`
- side note: should `ellipsize` be a common mezz?
- can be foreach with index:
- `foreach [p: name] list [prin rejoin ["^-" ..name..] if 0 = mod index? p n [prin lf]]`
- `print map-each [p: name] list [rejoin ["^-" ..name.. either 0 = mod index? p n [lf][""]]]]`
- can `format` do all this?
```
	while [not tail? list][
		loop n [
			if max-sz <= length? name: list/1 [
				name: append copy/part name max-sz - 4 "..."
			]
			prin tab
			prin pad form name max-sz
			prin " "
			if tail? list: next list [exit]
		]
		prin lf
	]
```
---
- `foreach x c [append pinstring get-pin-var ...]`
- `append rejoin map-each x c [get-pin-var ...]`
- `map-each/into x c [get-pin-var ...] pinstring`
```
    while [not tail? c] [ 
        pinstring: append pinstring get-pin-var game-board/(first c) kingpiece
        c: next c
    ]
```
---
- `foreach f fields [...]`
- `map-each/into f fields [... f] result`
```
    while [all [not tail? fields
               step-on]] [
        result: append result first fields
        if  0 <> game-board/(first fields) [
            step-on: false
            thispiece: game-board/(first fields)
            ...
        ] 
        fields: next fields  
    ]
```



## Multiple items, another target


- a definite forskip (length? query-columns)
- mb `map-each columns buffer [reduce [...]]` ??
```
	while [not tail? buffer] [
		insert tail blk copy/part reduce [(columns)] (cols - master-on-cols)
		insert tail blk copy/part buffer (length? query-columns)
		buffer: skip buffer (length? query-columns)
		insert tail query-plan plan
	]
	buffer: head buffer
```


---
- why not: `append blk map-each x split path "/" [reduce [form x x]]`
```
    while [not root] [
        repend blk [form path path] 
        root: path = %/ 
        path: first split-path path
    ] 
```

---
- `map-each [pos: tk] tokens [.. produces variable width output ..]`
```
    while [not tail? match-rule] [
        token: first match-rule
        parse-rule: join-of parse-rule either word? token [[
                'copy token 
                'to either tail? next match-rule ['end][
                    second match-rule
                ]
            ]
        ][token]
        match-rule: next match-rule
    ]
```

---
- fill a block of caller's refinements/arguments
- `forparse [set ref refinement!] [repend r ...]`
- `map-parse [set ref refinement!] [reduce [...]]`
```
	pos: spec-of :caller
	while [pos: find/tail pos refinement!] [
		set [opt arg types] find-option? :caller to word! pos/-1
		#assert [opt]
		repend r [
			to set-word! opt
			get any [arg opt]
		]
	]
```

---
- `map-each/into line port/sub-port [..] page`
```
	while [(str: pick port/sub-port 1) <> ""] [append page reduce [str newline]] 
```

---
- detab
- `map-each/self [:tab] x [...]`
```
	while [x: find x tab] [
		change/part x (skip ws (index? x) - 1 % 4) 1
	]
```



## Unclassified map-each

- interesting!
- tricky map-each - groups items between separators
- `[ ... in ... in ... ] -> [ [...] has [...] has [...] ]`
- `[term ['in repeat]] -> [[term] 'has ???]` any way to visually specify the transform?
```
	collect [
		while [find selector 'in][
			keep/only copy/part selector selector: find selector 'in
			keep 'has
			selector: next selector
		] keep/only copy selector
	]
```
---
- `[ ... and ... and ... ] -> [ [...] [...] [...] ]`
- using morph DSL: `morph [ (xs: copy []) :xs [x (x <> 'and) grp: x] -> grp :xs ? x ]`
```
selectors: collect [
	while [find selectors 'and][
		keep/only copy/part selectors selectors: find selectors 'and
		selectors: next selectors
	] keep/only copy selectors
]
```

---
- interesting case
- foreach that decomposes each item(row)
- `foreach row data [set spec row [...]]`
- how to do this without `set`?
- `foreach [[spec]] [...]`  -- possible?
- `map-each/self [[spec]] [...]`  -- should return `[[result]]` wrapped
```
    while [not tail? data][
        row: first data
        set [(spec)] row
        if (where) [
            reduce [(values)]
            change/only data reduce [(spec)]
        ]
        data: next data
    ]
```
