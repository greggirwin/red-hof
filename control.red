Red [
	Title:   "Red control functions"
	Author:  "Gregg Irwin"
	File: 	 %control.red
	Tabs:	 4
;	Rights:  "Copyright (C) 2013 All Mankind. All rights reserved."
;	License: {
;		Distributed under the Boost Software License, Version 1.0.
;		See https://github.com/dockimbel/Red/blob/master/BSL-License.txt
;	}
]

; Evidence Oriented Programming
; `If and 'when are good words. 'case is not
; 'repeat and 'loop are good. 'for, 'foreach, and 'while are not.
; Specific word choices and ordering matter. Natural language isn't better.
; 'text vs 'string is just shorter and easier to type.

; repeat 'word value body	; current syntax
; repeat <n> times ... end
; repeat while <test> ... end
; repeat until <test> ... end
; repeat [n times]
; repeat [while test]
; repeat [until test]
; repeat-while test
; repeat/while body test 

; Trying to fit into existing call syntax is ugly, because 'word is
; redundant for while/until, though it does give you auto-incrementing.
; The trick is to make it both clear and concise, because looping is
; used so often. We want it to be quick to read and understand, and
; easy to write correctly, without having to increment counters manually.
; A macro could easy transitioning.
repeat+: function [
	"Evaluates body a number of times, tracking iteration count."
    'word [word!] "Iteration counter; not local to loop."
    cond  [integer! block!] "Iteration count or test condition."
    body  [block!]
    /while "Evaluates body while condition block holds true."
    /until "Evaluates body while condition block holds false."
][
	; Using standard funcs while experimenting means hacking args.
	if any [while until][
		incr-word: reduce [to set-word! word  word '+ 1]	; add counter for while/until
		set word 0											; initialize it
		body: head insert copy body incr-word				; increment it in the body
		if until [append body cond]							; UNTIL tests at the end of the body
	]
    case [
    	while [system/words/while cond body]
    	until [system/words/until body]
    	'else [system/words/repeat :word cond body]
    ]
]
repeat+ i 3 [print ['n i]]
repeat+/while i [i < 3] [print ['w i]]
repeat+/until i [i >= 3] [print ['u i]]

; Ladislav's CFOR func
cfor: func [  ; Not this name
	"General loop based on an initial state, test, and per-loop change."
	init [block!] "Words and initial values as spec block (local)"
	test [block!] "Continue if condition is true"
	bump [block!] "Move to the next step in the loop"
	body [block!] "Block to evaluate each time"
	/local ret
] [
	do function [] join init [

		; It should actually make a selfless object from a block spec, but
		; that's awkward to specify in mezzanine code, so just make sure
		; that the native code makes a selfless context. It is likely a bad
		; idea to catch any break or continue in the init evaluation code
		; since the loop hasn't started yet, so we might want to just send
		; them upwards. Or should we process break and ignore continue?
	
		test: bind/copy test init
		body: bind/copy body init
		bump: bind/copy bump init
	
		; We don't need a direct reference to init anymore here, but we will
		; need to make sure our new values are referenced on the stack for
		; safety in the native so they don't get collected. Those assignments
		; are metaphors for replacing the references to the blocks in the stack
		; frame slots with references to their copies.
	
		while test [set/any 'ret do body do bump get/any 'ret]
	
		; The body and bump should be evaluated separately to make sure their
		; code doesn't mix, or otherwise you'll get weird errors. And don't
		; forget to return the value from the evaluation of the body by default
		; but also process break and continue from body, test and bump, according
		; to the behavior of the while loop here.
	]
		
]

; match - pattern matching SWITCH
; could also support various dispatch checkers to work like
; any of SWITCH, CASE, LIKE?, or SELECT-CASE.
; Pattern matching would be like tuplespace matching templates

res: match value [
	_like? [...]	[]
	_is? ! | []  	[]
	:func           []
	?    ! | []		[]
]

binding-parse: function [input rules words [block!]][
	?: [set v any-type! (set words/1 v  words: next words)]
	parse input bind/copy rules '?
	head words
]
x: y: none
print binding-parse [1 2 a b] [integer! ? ? word!] [x y]
o: object [xx: yy: none]
print binding-parse [1 2 a b] [integer! ? ? word!] words-of o

; We want to parse 'input with 'rules, but we want to mod 'rules
; with the values that match '?
;unifying-parse: function [input rules "(modified)" words [block!]][
;	?: [set v any-type! (set words/1 v  words: next words)]
;	parse input bind/copy rules '?
;	rules
;]
;x: y: none
;print binding-parse [1 2 a b] [integer! ? ? word!] [x y]


forskip: function [
	"Evaluates a block at intervals in a series"
	;[throw catch]
	'word [word!]    "Word set to each position in series (must refer to a series)"
	size  [integer!] "Number of values to skip each time"
	body  [block!]   "Block to evaluate each time"
][
	if not positive? size [cause-error 'script 'invalid-arg [size]]
	if not [series? get word] [
		cause-error 'script 'invalid-arg ["forskip expected word argument to refer to a series"]
	]
	orig: get word
	; This test is a little tricky at a glance. ANY will be satisified until
	; we hit the tail of the series. On each pass we move towards the tail.
	; Once we hit the tail, ANY will evaluate the paren in the test, which
	; resets the word to the original position in the series and returns
	; false, which causes WHILE to break.
	while [any [not tail? get word (set word orig  false)]][
		set/any 'result do body
		set word skip get word size
		get/any 'result
	]
]
;b: [1 2 3 4 5 6]
;forskip b 0 [print [b/1 b/2]]
;forskip b 1 [print [b/1 b/2]]
;forskip b 2 [print [b/1 b/2]]
;forskip b 3 [print [b/1 b/2 b/3]]
;forskip b 4 [print [b/1 b/2 b/3 b/4]]
;forskip b 4 [print [b/1 b/2 break b/3 b/4]]

;-------------------------------------------------------------------------------

divisible?: func [a b] [0 = remainder a b]

; This doesn't work like R3 in how negative widths work.
forskip: func [
	"Evaluates a block at regular intervals in a series."
	'word [word!] "Word referring to the series to traverse (modified)"
	width [integer!] "Interval size (width of each skip)"
	body  [block!] "Body to evaluate at each position"
	/local orig result op
][
	either zero? width [none] [
		; Assert that word ref's series
		if not [series? get word] [
			cause-error 'script 'invalid-arg ["forskip expected word argument to refer to a series"]
		]
		; Store original position in series, so we can restore it.
		orig: get word
		; What is our "reached the end" test?
		op: either positive? width [:tail?][:head?]
		if all [negative? width  tail? get word][
			; We got a negative width, so we're going backwards,
			; and we're at the tail. That means we want to step
			; back one interval to find the start of the first
			; "record".
			set word skip get word width
		]
		; When we hit the end, restore the word to the original position.
		while [any [not op get word (set word orig  false)]][
			set/any 'result do body
			set word skip get word width
			get/any 'result
		]
		if all [
			negative? width
			divisible? subtract index? orig 1 width
			;?? check orig = get word for BREAK support?
		][
			; We got a negative width, so we're going backwards,
			; and the above WHILE loop ended before processing
			; the element at the head of the series. Plus we reset
			; the word to its original position, *and* we would
			; have landed right on the head. Because of all that,
			; we want to process the head element.
			set word head get word
			set/any 'result do body
			set word orig
		]
		get/any 'result
	]
]

;tbb: back tb: tail blk: [1 2 3 4 5 6]
;forskip blk 2 [print mold blk]
;forskip tb -2 [print mold tb]
;forskip tbb -2 [print mold tbb]

;-------------------------------------------------------------------------------

opt: func [
	"If condition is TRUE, return value, otherwise return empty value of the same type"
	condition
	value "Some types, e.g., word types, return none if condition is false."
][
	either condition [:value][attempt [make :value 0]]
]
;opt true 'a
;opt true "A"
;opt false 'a
;opt false "test"
;opt false 100
;opt false http://www.red-lang.org
;opt false 10x10
;opt false 1:2:3
;

; select-case

;-------------------------------------------------------------------------------

; List Comprehension (Steeve, inspired by MaxV's Rebol version)
make-list-comprehension: function [rule][
	parse rule [
		some [
			s: word! 'in skip 
				(in: last reduce/into ['foreach s/1 s/3 make block! 4] in)
			| 'if skip 
				(in: last reduce/into ['if to-paren s/2 make block! 4] in)
			| skip '| 
				(res: s/1 fun: in: make block! 4)
			| (reduce/into ['reduce/into res 'tail 'out] in) break
		]
	]
	has [out] compose [out: make block! 10 (fun) out] 
]

;x-set: [1 2 3]
;r: make-list-comprehension [[x + y ] | x in x-set y in [10 100 1000] if [ x <> 2]]
;r
;== func [/local out][out: make block! 10 foreach x x-set [foreach y [10 100 1000] [if (x <> 2) [reduce/into [x + y] tail out]]] out]

;-------------------------------------------------------------------------------

match: func [
	value
	cases [block!]
	;/only
][
	
]

; Is there a single, base func that can iterate, optionally with a skip
; value > 1, APPLY a function to values in the current "processing window"
; (MAP has a window size of 1), give that function all the info it needs
; to make detailed decisions (e.g. skip size). Maybe even throw in some
; pattern matching to make it interesting. You can build MAP from FOLD/
; ACCUMULATE, and a map func that returns NONE for some args can lead to
; an easy FILTER. So it's really a smart FOLD/ACCUMULATE (maybe with 
; /reverse, like SORT, to become FOLDR), with an optional skip value. But
; the skip value may be mutiple words, like you would use with FOREACH,
; except that we really want this to be PARSE-based for maximum power.
mapskiply: func [
	result "Where to collect output"
	input [series!] "Series to iterate over"
	rules [block!]
	fn    [any-function!]
	/skip
		size [integer!]	; could we also skip by typeset or rule?
][
]

blk: [a b c 1 2 3]
; MAP
res: mapskiply copy [] blk :append

;-------------------------------------------------------------------------------

do-in-parallel: func [progs [block!] "key-val pairs"][
	while [not empty? progs][
		foreach [key prog] progs [
		    do/next prog 'prog
		    progs/:key: prog
		    if empty? prog [remove/part find progs key 2]
		]
	]
]

do-in-parallel [
	a [print 1 print 2 print 3]
	b [ print "^-v" print "^-w" print "^-x" print "^-y" print "^-z"]
	c [print [tab tab mold #qrs]  print [tab tab now/time]]
]

;-------------------------------------------------------------------------------

do-tasks-in-parallel: function [tasks [block!] "Task objects"][
	orig-list: tasks
	tasks: copy tasks
	while [not empty? tasks][
		forall tasks [
			task: tasks/1
		    task/_state: do/next task/_prog 'prog
		    task/_prog: prog
		    if task/_state = 'done [remove tasks]
		]
		head tasks
	]
	orig-list
]

task-proto: context [_prog: none _state: none]
make-task: func [spec body][
	task: make task-proto spec
	task/_prog: bind body task
	task
]
t-a: make-task [a: 1 b: 2][
	a: a + 1  print a * b
	a: a + 1  print a * b
	a: a + 1  print a * b
	'done
]
t-b: make-task [s: copy "" c: 'x][
	append s c print mold s
	append s c print mold s
	append s c print mold s
	append s c print mold s
	append s c print mold s
	'done
]
print mold do-tasks-in-parallel reduce [t-a t-b]

;-------------------------------------------------------------------------------

; match-case is a function that takes a set of conditions and dispatches,
; like CASE, by matching the result of all those conditions. The goal 
; being to make what might take nested any/all constructs easier to read
; and branch on.

a: -1
b: 20
c: ""

match-case [
	positive? a
	b > 10
	empty? c
][
	[false false false] [none]
	[false false true]  [neg small empty]
	[false true true]   [neg big empty]
	[true true true]    [pos big empty]
	[true true false]   [pos big not-empty]
]

;-------------------------------------------------------------------------------

every: func [size value body /local interval] [
    if zero? value // size [
        interval: value / size
        do bind/copy body 'interval
    ]
]
comment {
    repeat i 50 [every 5 i [print [i interval]]]
}

; Another approach to `every` would be like Icon does, making it more like a
; HOF iterator

;-------------------------------------------------------------------------------

for-map: function [
	"Iterate over a map, making each `key` and `value` available to the body."
	data [map! series!]
	body [block!]
][
	either series? data [
		foreach [key value] data [do body]
	][
		foreach key keys-of data [
			value: data/:key
			do bind body 'key
		]
	]
]
blk: [a: 1 b: 2 c: 3]
for-map m [print [key value]]
m: #(a: 11 b: 22 c: 33)
for-map m [print [key value]]
for-map m [
	print [key value]
	if value > 2 [break]
]

;-------------------------------------------------------------------------------

>> either': func [cond tv fv] [either cond [tv] [fv]]
== func [cond tv fv][either cond [tv] [fv]]
>> either' true 1 2
== 1
>> either' false 1 2
== 2
>> either' false [1] [2]
== [2]

; @toomasv
either': func [cond tv fv][
	any [
		block? tv: get pick [tv fv] cond return :tv
	]
	do tv
]
if': func [cond tv][
	either tv: if cond [:tv][
		either block? :tv [do tv][:tv]
	][]
]
rejoin ['This if' false " omits" " something"]
;== "This something"
rejoin ['This if' true " omits" " something"]
;== "This omits something"

;-------------------------------------------------------------------------------

; Generator replacement

; take a series and return each element

;-------------------------------------------------------------------------------

; Boris' idea
foreach [pos: x y] srs [..]