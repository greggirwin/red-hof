# REMOVE-EACH

No doubt, every usage of REMOVE-EACH follows it's meaning, and the only way we can help is to provide better filters.
Some cases use an explicit COPY to counter the in-place behavior of it. Some don't care as they work on temporary data.

This is a great playground for `sift` experimental DSL or any other filters you have in mind.
I provided the examples and their `sift` variants.
The goal of `sift` is to make clean and short one-liners for most use cases, not to replace `remove-each`.


## Examples 

- `sift kids [/name <> (selector/1)]`
```
	remove-each kid kids [not selector/1 = kid/name]
```

---
- checks sub-items of each item
- `sift src-data [/1 <> ("Commodity") /2 <> ("Practice")]`
```
    remove-each item src-data [
        any [
            item/1 = "Commodity"
            item/2 = "Practice"
        ]
    ]
```

---
- too big to be an one-liner filter?
- `sift src-data [x: 1 (not last? x) /1 <> ("Commodity") /2 <> ("Practice")]` ?
```
    remove-each item _DATA_ [
        any [
            1 = length? item
            item/1 = "Crop"
            item/2 = "Practice"
        ]
    ]
```

---
- `sift list [1 2 .. sess: 2 (sess/expires >= (now)]`
- `sift list [1 2 [/expires >= (now)] ..]` ?
```
	remove-each [id sess] list [sess/expires < now]
```

---
- `sift uploads [1 2 3 .. ts: 3 (ts + 0:1 >= n)]`
- `sift uploads [1 2 ts .. (ts + 0:1 >= n)]` ?? - such naming hurts skip and direction inference
```
	remove-each [id req ts] uploads [ts + 00:01 < n] ;-- Remove tokens older than 1 minute
```

---
- an explicit copy
- `f: find sift face/setup [word!] value`
```
    words: copy face/setup 
    remove-each w words [not word? w] 
    f: find words value 
```

---
- `sift face/data [default!]` ;)
```
	remove-each row face/data [not value? 'row] 
```

---
- `.. sift files [f: 1 (dir? f)]`
- `.. sift files [ends-with (#"/")]` ?
```
set-face/no-show face/file-list remove-each file files [#"/" <> last file] 
```

---
- `sift face/column-order [is ('|) or is ('||)]`
- `sift face/column-order [1 in [| ||]]`
```
	remove-each val face/column-order [find [| ||] val]
```

---
- explicit copy (returns it)
- `sift words [w: 1 w: (:codes/:w) is (w and port/state/flags)]` - not better
```
	remove-each word copy words [
		word: select codes word
		word <> (port/state/flags and word)
	]
```

---
- explicit copy
- `result: context append sift spec [set-word!] none`
```
(result: context append remove-each item copy spec [not set-word? item] none)
```

---
- `sift query: ... [not empty]` ?
- `sift query: ... [has any-type!]` ?
```
	remove-each value query: parse/all query "&" [empty? value]
```

---
- sift provides extraction already
- `sift any [roles []] [- 2 .. 2 is ("yes")]` - row syntax
- `sift any [roles []] [2 4 .. is ("yes")]` - skip syntax
```
	extract remove-each [role value] any [roles []][value <> "yes"] 2
```

---
- `sift values [default!  is not (none)]`
- `sift values [x: 1 (value? :x) (not none? :x)]`
- `cs: exclude default! unset!  sift values [type (cs)]` - fastest
```
	remove-each value values [any [unset? get/any 'value none? value]]
```

---
- `sift lower [1 > (1)]`
- `sift upper [1 < (last)]`
```
	remove-each val lower [val <= 1]
	remove-each val upper [val >= last]
```

---
- `sift user-data [f: 1 (parse f state/custom)]`
```
	remove-each file user-data [not parse file state/custom]
```

---
- should `sift` accept maps as a special case? only when there are 2 positions?
- `sift data [1 2 .. 1 is not (key)]`
- `sift data [1 [is not (key)] 2 ..]`
- `sift data [1 <> (key) 2 ..]` ?
```
unset: func [key [word!]][remove-each [k v] data [k = key]]
unset: func [key [word!]][remove-each [k value] values [k = key]]
```

---
- `sift pending [1 2 .. k: 1 (find keys k)]`
- `sift pending [1 2 .. 1 in (keys)]`
- `sift pending [1 [in (keys)] 2 ..]`
- `sift pending [1 2 .. 1 not in (exceptions)]`
```
if only [remove-each [key value] pending [not find keys key]]
if except [remove-each [key value] pending [find exceptions key]]
```

---
- explicit copy
- `sift doc [in ([sect1 sect2 sect3 sect4])]`
```
	remove-each style copy doc [
		not find [sect1 sect2 sect3 sect4] style
	]
```

---
- explicit copy
- `sift document [1 2 .. 1 in (level)]`
```
	remove-each [style para] copy document [
		not find level style
	]
```

---
- `sift reduce ... [is not (none)]`
```
	remove-each val reduce [
		to-key column/1
		...composes big block using ifs, switches, parse...
		if column/5 [reduce ['init column/5]]
	][none? val]
```

---
- `sift list [f: 1 (%.caf <> suffix? f)]`
- `sift list [ends-with (%.caf)]` ?
```
	remove-each file list [%.caf <> suffix? file]
```

---
- explicit copy
- `blk: sift spec-of :fn [v: 1 (ext-word? v)]`
```
	remove-each val blk: copy spec-of :fn [not ext-word? val]	; Remove doc strings and type specs
```

---
- not very fit for an one-liner
- `sift sort data [row: 1 /1 not in (["" #[none]]) or not (single? unique row)]  is not (old-row)  (old-row: row)`
- `sift sort data [row: 1 not (empty? row) or not (single? unique row)  is not (old-row)  (old-row: row)]`
```
	remove-each row sort data [
		any [
			all [
				find ["" #[none]] row/1
				1 = length? unique row
			]
			either row = old-row [true] [old-row: row false]
		]
	]
```

---
- this is `remove-each` by design ;)
```
	remove-each row data bind compose/only [all (condition)] 'row
```

---
- ??
```
	remove-each gob at [
		do-event gob 'leave offset
		on
	]
```

---
- filter is too complicated for `sift` to matter
- `sift  map-each [face (function!)] pane [all [...]]  [f: 1 (f) (ignore) or in (ignore-faces) /show? (within? ...)]`
```
	remove-each face pane [
		if function? :face [ ; iterated pane function ? 
			face: all [
				; first call the pane with a pair to figure out the iteration index
				index: face parent-face (offset - sum) ; pane function should return iteration index or NONE
				face parent-face index ; call the pane again with the index to get the iterated face
			]
		]
		any [
			none? face ; NONE might be returned by the pane function
				all [ignore find ignore-faces face] ; <---
			;transparent-face? face (offset - sum) ; <--- if implemented would make /ignore redundant
			not face/show?
			not within? (offset - sum) face/offset face/size
		]
	]
```

---
- `sift menu [1 2 .. 1 is ('url)]`
- `sift menu [1 2 .. 1 in ([url split])]`
```
	remove-each [style content] menu [style <> 'url]
	remove-each [style content] menu [all [style <> 'split style <> 'url]]
```

---
- `sift nonce [not in ("+/=")]`
```
	remove-each char nonce [find "+/=" char]
```

---
- `sift files [has (%access) is not (%other_vhosts_access.log)]`
```
	remove-each file files [
		any [
			not find file %access
			equal? file %other_vhosts_access.log
		]
	]
```

---
- `sift win/pane [is (grabber)]`
```
	remove-each face win/pane [
		not grabber = face
	]
```

