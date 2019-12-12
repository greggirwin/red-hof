# MAP-EACH imitations

**Navigate:**
  * [Mixed, in-place](#mixed-in-place)
  * [Single item, another target](#single-item-another-target)
  * [Multiple items, another target](#multiple-items-another-target)
  * [Unclassified map-each](#unclassified-map-each)


## Mixed, in-place

---
- `foreach [pos: x [string!]] glyph [...]` - it grows the glyph though, so `foreach` can't rely on a fixed length
- `map-each/self [pos: x [string!]] glyph [...]` - this'll work
- this example shows that in-place map-each cannot be properly implemented using foreach, unless foreach checks the length every time
```
	pos: find glyph string!
	until [
		parse/all pos/1 [copy ref [to "N" | to "S"] skip copy trans to end]
		ref: first to block! ref
		remove pos			
		insert pos reduce ['push blk: copy/deep dive get-glyph ref]
		if [1 0 0 1 0 0] <> trans: to block! trans [
			trans/6: negate trans/6
			insert blk reduce ['matrix trans]
		]		
		not pos: find pos string!
	]
```

## Single item, another target

---
- reinvention, limited to 1 item at once
```
map-each: func ['word series code][
    collect [
        until [
            set :word first series
            keep do code
            series: next series
            tail? series
        ]
    ]
]
```

---
- another one, same limit, calls functions it encounters
- strange to see `bind` here
```
map-each: function [
	'word ; NOTE: leaks word
	series
	body
] [
	forall series [
		set word series/1
		series/1: do bind body word
	]
	series
]
```

---
- from `to-red-file`:
- `parse path [any [[set c #":" (..) opt [[#"\" | #"/"] (i: i + 1)] (c: #"/") | [#"\" | #"/"] (c: #"/" ..) | skip (...)] (append dst c)]] path` - messy
- `map-parse [set c skip set c2 opt [if (c = #":") skip]] path [... c]` - better
- `map-each c path [if c = #":" [c2: advance] ... c]` - even more
```
	until [
		c: pick path i
		i: i + 1
		case [
			c = #":" [
				if any [colon? slash?] [return dst]
				colon?: yes
				if i <= len [
					c: pick path i
					if any [c = #"\" c = #"/"][i: i + 1]	;-- skip / in foo:/file
				]
				c: #"/"
			]
			any [c = #"\" c = #"/"][
				if slash? [continue]
				c: #"/"
				slash?: yes
			]
			true [slash?: no]
		]
		append dst c
		i > len
	]
```

---
- that's something... even if data and out are of different series type:
- `map-each/into x data [x] out` is cleaner
```
envelop: func [data][either block? data [data][compose [(data)]]]
emit: func [data][
	data: reduce envelop data
	until [append out take data empty? data]
]
```


## Multiple items, another target

---
- parallel iteration over 4 blocks
- a zip stream may help:
- `map-each [o h l c] zip [opens highs lows closes] [...]`
```
    until [
        ...lots of `insert tail result`...
        ; step to the next element in each vector of prices
        opens: next opens
        highs: next highs
        lows: next lows
        closes: next closes
        x-pos: x-pos + x-inc: (parms/x-log-adj * x-inc) 
        tail? opens
    ]
```

---
- over 2 blocks
- `map-each [x y] zip [x-data y-data] [...]`
```
    until [
        y-pt: first y-data
        x-pt: first x-data
        y-data: next y-data
        x-data: next x-data
        ... append result ...
        tail? y-data
    ]
```

---
- `remove-each data/2 [pos: _ _ _] [repend ... take ... yes]`
- `map-each/into [pos: _ _ _] data/2 [copy/part pos 3] output`
```
	until [
		repend output process-tag take/part data/2 3
		empty? data/2
	]
```



## Unclassified map-each


---
- `forskip data size [...]` - size is unknown and can be big
- any alternatives? make stream that reads by size and then map to-csv-line over that stream?
```
collect/into [
    until [
        keep to-csv-line copy/part data size delimiter
        tail? data: skip data size
    ]
] make string! 1000
```
