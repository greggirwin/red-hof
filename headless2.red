Red [
	title:  "simplistic iterators experiment"
	author:  @hiiamboris
	license: BSD-3
]

iterator!: object [
	pattern:  []				;-- words, set-words, get-words, blocks, refinements (see for-each)
	series:   []
	inum:     0					;-- current iteration number
	bgn:      []				;-- series at positions past which it shouldn't advance (required for /stride & /reverse)
	end:      []				;-- ditto
	step:     1					;-- skip size
	width:    []				;-- pattern size
	comparator: 'equal?			;-- equal?, same?, strict-equal? - TBD
	code:     [do pattern]		;-- to evaluate

	next: func ["Advance to next location"] [
		if series =? end [return none]	;-- further iteration is forbidden
		series: skip series step
		inum: inum + 1
		self
	]

	back: func ["Advance to previous location"] [
		if series =? bgn [return none]	;-- further iteration is forbidden
		series: skip series 0 - step
		inum: inum + 1
		self
	]

	reset: func ["Start over"] [
		series: begin
		inum: 1
	]

	fill: func ["Set words within the pattern"] [
		if empty? series [return none]
		foreach (pattern) series [break]
		true		;@@ TBD - return none if pattern does not match data
	]
]

each: function [
	'pattern [word! block!]		;-- this implementation supports only words
	series [series! map!]
	/case "TBD"
	/same "TBD"
	/reverse "reverse iteration order"
	/stride  "lock step at 1, exclude partial pattern fills"
][
	if map? series [series: to [] series]
	len:   length? series
	width: length? pattern: compose [(pattern)]
	step: either stride [1][width]
	stop: len - either stride [width][len - 1 % width + 1]
	end: skip series stop
	if reverse [
		series: also end end: series
		step: 0 - step
	]
	make iterator! compose/only [
		pattern:  (pattern)
		series:   (series)
		inum:     1
		bgn:      (series)
		end:      (end)
		step:     (step)
		width:    (width)
		comparator: 'equal?		;@@ TBD, not a priority
	]
]

next': func [iter] [iter/next]		;-- iterator is like a series
back': func [iter] [iter/back]


;----------------------------------------
;-- now we can create loops with this    
;--                                      


for': function [
	"Supplies code to the iterator"
	it [object!] code [block!]
][
	it/code: code
	it
]

do': function [		;-- suppose we extend `do` native with iterators support
	"Evaluate iterators code for each matched pattern"
	it [object!] "iterator!"
][
	r: none
	until [
		if it/fill [set/any 'r do it/code]
		none? it/next
	]
	:r
]

change': function [
	"Map iterator code over series, changing it in place"
	it [object!] "iterator!"
	/only
	/eval
][
	path: as path! [map']
	if only [append path 'only]
	if eval [append path 'eval]
	out: do compose [(path) it]
	bgn: at it/series min index? it/bgn index? it/end
	end: at it/series max index? it/bgn index? it/end
	change/part bgn out skip end it/width
	it/series
]

map': function [
	"Map iterator code over series & collect results; parts not matched by the pattern are kept as is"
	it [object!] "iterator!"
	/only
	/eval
][
	out:     clear copy it/series
	eval?:   either eval ['reduce][[]]
	append?: either only ['append/only]['append]
	until compose/deep [
		either it/fill [
			(append?) out (eval?) do it/code
		][
			append/part out it/series it/width
		]
		none? it/next
	]
	out
]

keep': function [
	"Map iterator code over series & collect results; parts not matched by the pattern are discarded"
	it [object!] "iterator!"
	/only
	/eval
][
	out:     clear copy it/series
	eval?:   either eval ['reduce][[]]
	append?: either only ['append/only]['append]
	until compose/deep [
		if it/fill [(append?) out (eval?) do it/code]
		none? it/next
	]
	out
]

remove': function [
	"Remove series parts for which iterator code is truthy"
	it [object!] "iterator!"
][
	out:     clear copy it/series
	until compose/deep [
		unless all [it/fill do it/code] [
			append/part out it/series it/width
		]
		none? it/next
	]
	out
]

apply': function [
	"Add a function to the iterator"
	'fun [word!]
	it [object!]
][
	insert it/code fun
	it
]

for-each:    func ['pattern series code] [do'     for' each (pattern) series code]	;@@ refinements should be added
change-each: func ['pattern series code] [change'/eval for' each (pattern) series code]	;@@ refinements should be added
map-each:    func ['pattern series code] [map'    for' each (pattern) series code]	;@@ refinements should be added
keep-each:   func ['pattern series code] [keep'   for' each (pattern) series code]	;@@ refinements should be added
remove-each: func ['pattern series code] [remove' for' each (pattern) series code]

print': function [it [object!]] [
	do' for' it compose/only [print (it/code)]
	()
]

print "------------------"
test: func [code] [print [">>" mold/only code] print ["==" mold do code]]



; test [each x [1 2 3]]
test [for-each x [1 2 3] [print x]]
test [map-each x [1 2 3] [x * 2]]
test [keep-each x [1 2 3] [x * 2]]
test [remove-each x [1 2 3] [odd? x]]
test [print' each x [1 2 3]]
double: func [x][x * 2]
test [print' apply' double each x [1 2 3]]
test [change-each [x y] [1 2 3 4] [[y x]]]
test [change-each [x y] [1 2 3 4] [[y + x]]]

output: {
>> for-each x [1 2 3] [print x]
1
2
3
== unset
>> map-each x [1 2 3] [x * 2]
== [2 4 6]
>> keep-each x [1 2 3] [x * 2]
== [2 4 6]
>> remove-each x [1 2 3] [odd? x]
== [2]
>> print' each x [1 2 3]
1
2
3
== unset
>> print' apply' double each x [1 2 3]
2
4
6
== unset
>> change-each [x y] [1 2 3 4] [[y x]]
== [2 1 4 3]	
>> change-each [x y] [1 2 3 4] [[y + x]]
== [3 7]
}
