# MAP-EACH

However few, still interesting ☺

## Examples

---
- map-each implementation that supports mapping a row of words at once, putting those words' new values into the series
- limited to 1-to-1 mapping (series length becomes unchanged)
```
	each: func [[catch throw] 'word [word! block!] series [any-block!] body [block!] /copy /local new][
		case/all [
			word? word [word: envelop word]
			not parse word [some word!][
				raise "WORDS argument should be a word or block of words"
			]
			copy [series: system/words/copy/deep series]
		]
		use word compose/deep [
			while [not tail? series][
				set [(word)] series (body)
				series: change/part series reduce [(word)] (length? word)
			]
		]
		head series
	]
```

---
```
	throw-on-error [
		each [name spec] specs [
			spec: bind load/header root/:spec qm/models
			type: get in spec/1 'type
			spec: compose [
				name: (to lit-word! name)
				header: (spec)
			]
			spec: switch type?/word type [
				word! [
					spec: compose/only [scheme: (to lit-word! type) locals: (spec)]
					if error? spec: try [open spec][
						raise ["Error opening Model: %models/" name ".r <" type "::" name ">"]
					]
					spec
				]
				none! [context bind spec qm/models]
			]
			set in qm/models name spec
		]
	]
```

---
- `trim-each` works on `values`
```
commas:     [line (values: parse/all text ",") trim-each]
pipes:      [line (values: parse/all text "|") trim-each]
```

---
- `rejoin map-each/sep word to block! value [form word] "."`
```
either parse value [some word!][
	remove press map-each word to block! value [join "." form word]
][form value]
```

---
- `map-each/only v query [split v "="]`
- `bulk [split query/* "="]` ??
```
	map/only query func [value][parse/all value "="]
```

---
- ??
- what's the point of `foreach selector reverse collect [..] [keep selector]` ? joining?
```
	selectors: map-each selector selectors [
		collect [
			foreach selector reverse collect [
				while [find selector 'in][
					keep/only copy/part selector selector: find selector 'in
					keep 'has
					selector: next selector
				] keep/only copy selector
			][keep selector]
		]
	]
```

---
- `key: form map-each v key [rejoin [:v #":"]]`
- `key: form bulk [rejoin [:key/* #":"]]`
```
	key: to string! map-each value key [
		ajoin reduce [:value #":"]
	]
```

---
- mapping channels to 0..1 floats
- some distinctive dialect of Rebol here..
- `c: color object [r: c/1 / 255.0 g: c/2 / 255.0 b: c/3 / 255.0]` - that's all
- `object map-each/eval [i: ch] [r: g: b:] [ [ch color/:i / 255.0] ]` - more general
- `set object [r: g: b: none] color/* / 255.0` ?
```
	; color [tuple!]
	color: reduce [color/1 color/2 color/3]
	bind/new [r g b] local: object []
	set words-of local map-each c color [c / 255]
```

---
- `vs: values-of color  color: to tuple!  to integer! round m + color/* * 255` - not better
```
	color: to tuple! map-each value values-of color [to integer! round m + value * 255]
```

---
```
	value: map-each val value [
		switch type [
			string 		[form val]
			date 		[attempt [to date! val]]
			integer 	[attempt [to integer! val]]
			file 		[to file! val]
			class 		[to word! join #"." form val]
		]
	]
```

---
- just `values-of players` ?
```
ranked-players: sort/compare 
	map-each player words-of players [players/:player]
	func [first second][
	    either first/points = second/points [
	        first/nick < second/nick
	    ][
	        first/points < second/points
	    ]
	]
```


