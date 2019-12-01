# Unclassified `while [find ...]`


- can foreach look for a substring of a string? probably not
- `forparse [string: text] string [repend res [..]]` ?
```
    while [string: find/tail string text] [
        insert insert/only tail res header copy/part skip string -50 120
    ]
```

---
- tables: some `for-each-row [do smth]`
- columns number is held separately: if we could have it as a property of the block ...
```
	while [pos: find/only/skip data key tables/:table/cols] compose [
		pos: index? pos
		(blk)
		data: at head data pos + (tables/:table/cols)
	]
```


---
- set new-line before each set-word
- `forparse [pos: set-word!] [...]`
- `foreach [pos: x [set-word!]] [...]`
```
	while [pos: find pos set-word!][
		new-line pos true
		pos: next pos
	]
```


---
- count term in content
- `rank: count/any content term`
```
	while [content: find/any/tail content term][rank: rank + 1]
```

---
- extraction of tags with contents
- could be: `parse para [collect any keep [<br> to <br />]]`
```
	while [cell: find para <br />][
		keep/only copy/part para cell
		para: next cell
	]
	keep/only copy para
```


---
- like `foreach [new old]`, but more careful - ensures a set word in a custom list format
```
    while [specs: find specs set-word!] [
        set [new old] specs 
        specs: skip specs 2 
        new: to-word :new 
        ....
        either old: find styles new [change next old new-face] [repend styles [new new-face]] 
    ] 
```

---
- same
```
	while [specs: find specs set-word!][
		set [new old] specs
		specs: skip specs 2
		new: to-word :new
		...
		args: copy/part specs tmp
		forall args [
			if any [
				find/only facet-words first args
				all [old-face/words find old-face/words first args]
			][
				change args to-lit-word first args
			]
		]
		...
		grow-facets new-face args
		either old: find styles new [change next old new-face][repend styles [new new-face]]
		if tmp: new-face/words [  ; convert word actions to functions
			while [tmp: find tmp block!] [
				change tmp func [new args] first tmp
			]
		]
	]
```


---
```
    while [find refs first dialect][
        refs?: true
        ref: take dialect
        either path? action [
            append action ref 
        ][
            action: make path! reduce [action ref]
        ] 
        unless zero? select arity ref [
            append ref-stack take dialect 
        ]
    ]
```

---
- no idea what's it doing :)
```
remove-transformations: does [
	while [
		find/match [transform translate scale skew] first next selection-start 			
	][
		change/part next selection-start first find selection-start block! find/tail selection-start block!
	]
]
```

---
- `any [find str negate chars  str]`
```
skip-some: func [str [string!] chars [bitset!]][
	while [find/match str chars][str: next str] 
	str
]
```

---
- `any [find s1 charset [not ws]  s1]`
```
	while [find ws s1/1][s1: next s1]
```
