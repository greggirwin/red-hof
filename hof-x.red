Red [
	Title:   "Red higher-order functions"
	Author:  "Gregg Irwin"
	File: 	 %hof.red
	Tabs:	 4
;	Rights:  "Copyright (C) 2013 All Mankind. All rights reserved."
;	License: {
;		Distributed under the Boost Software License, Version 1.0.
;		See https://github.com/dockimbel/Red/blob/master/BSL-License.txt
;	}
;   https://github.com/RenaudG/red-utilities/blob/master/funclib.red
;	https://docs.python.org/3/library/itertools.html
]

comment {
	apply (map)					[collect opt transform]
	accumulate (fold, reduce)	summarize
	filter (select)				remove-each/keep-each
	sort						sort
	group
}


#include %types.red
#include %math.red
#include %general.red
;-------------------------------------------------------------------------------

any-block?: func [value] [
	any [block? :value  paren? :value  any-path? :value]
]

any-string?: func [value] [
	any [
		string? :value  file? :value
		; email? :value  tag? :value  url? :value
	]
]

series?: func [value] [
	any [any-block? :value  any-string? :value]
]

;-------------------------------------------------------------------------------

use: func [
	"Defines words local to a block evaluation."
	vars [block!] "Words local to the block"
	body [block!] "Block to evaluate"
][
	; R3: apply make closure! reduce [to block! vars copy/deep body] []
	do has vars body
]
use: function [words [block!] body [block!]][
    forall words [words/1: to-set-word words/1]
    context head insert body append words none
]


; Should args come first? That's the normal series-first model, but 
; also backwards from normal func call order, which may be confusing.
apply: func [
	"Apply a function to a block of arguments."
	fn  [any-function!] "Function to apply"
	args [block!] "Arguments for function"
	/only "Use arg values as-is, do not reduce the block"
][
	; Renaud Gombert's simple approach. There is a reason Brian Hawley's
	; R2 version is so complex. The question is whether the complexity 
	; is justified. It may be, but this is very Rebolish.
	args: either only [copy args][reduce args]
	do head insert args :fn
]

;-------------------------------------------------------------------------------

;collect: func [
;	"Returns a block of values collected when KEEP is called."
;	body [block!]
;	/into "Put results in out block, instead of creating a new block"
;		; TBD: make out type series!
;		output [any-block!] "Target for results, when /into is used" 
;	/local keep
;][
;	keep: func [value /only] [
;		either only [append/only output :value] [append output :value]
;		:value
;	]
;	output: any [output copy []]
;	do bind/copy body 'keep
;	output
;]
collect: function [
	"Collect in a new block all the values passed to KEEP function from the body block"
	body [block!]		 "Block to evaluate"
	/into 		  		 "Insert into a buffer instead (returns position after insert)"
		collected [series!] "The buffer series (modified)"
][
	keep: func [v /only][either only [append/only collected v][append collected v]]
	
	unless collected [collected: make block! 16]
	parse body rule: [									;-- selective binding (needs BIND/ONLY support)
		any [pos: ['keep | 'collected] (pos/1: bind pos/1 'keep) | any-string! | into rule | skip]
	]
	do body
	either into [collected][head collected]
]

default: func [
	"Set a value for the word if the word is not set or is none."
	'word
	value
][
	if not all [value? :word  not none? get word] [
		set word :value
	]
	;TBD: get-word args support not in place yet.
	;if not set? :word [set word :value]
	get word
]

;forskip: func [
;	"Evaluates a block at regular intervals in a series."
;	'word [word!] "Word referring to the series to traverse (modified)"
;	width [integer!] "Interval size (width of each skip)"
;	body  [block!] "Body to evaluate at each position"
;	/local orig result op
;][
;	either zero? width [none] [
;		; TBD: assert word refs series
;		; Store original position in series, so we can restore it.
;		orig: get word
;		; What is our "reached the end" test?
;		op: either positive? width [:tail?] [:head?]
;		if all [negative? width  tail? get word] [
;			; We got a negative width, so we're going backwards,
;			; and we're at the tail. That means we want to step
;			; back one interval to find the start of the first
;			; "record".
;			set word skip get word width
;		]
;		; When we hit the end, restore the word to the original position.
;		while [any [not op get word (set word orig  false)]] [
;			set/any 'result do body
;			set word skip get word width
;			get/any 'result
;		]
;		if all [
;			negative? width
;			divisible? subtract index? orig 1 width
;			;?? check orig = get word for BREAK support?
;		] [
;			; We got a negative width, so we're going backwards,
;			; and the above WHILE loop ended before processing
;			; the element at the head of the series. Plus we reset
;			; the word to its original position, *and* we would
;			; have landed right on the head. Because of all that,
;			; we want to process the head element.
;			set word head get word
;			set/any 'result do body
;			set word orig
;		]
;		get/any 'result
;	]
;]

;gather: function [
;	"Gather the specified values from each item in the block"
;	block [block!] "Block of items to gather data from"
;	keys [word! integer! block!] "Indexes or keys to gather"
;	/only "Insert results as sub-blocks"
;][
;	keys: compose [(keys)]						; blockify keys for consistent iteration
;	res: make block! multiply length? block either only [1] [length? keys]
;	collect/into [
;		foreach item block [
;			vals: collect [
;				foreach key keys [keep/only item/:key]
;			]
;			either only [keep/only vals] [keep vals]
;		]
;	] res
;]

incr: func [
	"Increments a value or series index."
	'word [word!] "Must refer to a number or series value"
	/by "Change by this amount"
		value
][
	;_incr-by word value
	either series? get word [
		set word skip get word any [value 1]
	][
		set word add get word any [value 1]
	]
]

value?: func [
	"Returns true if the word has a value."
	value [any-type!]
][
	not unset? get/any value
]

;-------------------------------------------------------------------------------

; Clojure: If coll contains no items, f must accept no arguments as well,
; and reduce returns the result of calling f with no arguments.  If coll
; has only 1 item, it is returned and f is not called. (reduce func)

; The 1 = length? check isn't good. We should always apply 'fn. Nim does
; not apply the func when only one item exists. Need to check other langs.
; That means we should always pass a starting value.
fold: accumulate: function [
	"Combines the results of a function applied to each value in a series."
	series [series! map!]
	fn     [any-function!] "Must take RESULT and INPUT args, and return RESULT"
	/with "Use a different starting value than the first in the series" ;/into
		value "Starting value; used as accumulator"
][
	if 1 = length? series [return series/1]
	default value first series
	if not with [incr 'series]
	;assert 2 = length? words-of :fn
	foreach item series [value: fn :value :item]
]
; Red should have TCO before we try to do this recursively.
;fold: function [	; fold/right
;	"Combines the results of a function applied to each value in a series."
;	result
;	series [series! map!]
;	fn     [any-function!] "Must take RESULT and INPUT args, and return RESULT"
;][
;	either empty? series [result][
;		result: fn result series/1
;		fold result next series :fn
;	]
;]
;map: func [series fn][
;	fold copy [] series func [res val][append res fn val  res]
;]
;map [1 2 3] :form
;map [1 2 3] func [v][add v 2]

; @9214
order: func [block item /skip size /head /tail][
    also block (
        while [not tail? next block][
            block: insert system/words/skip block any [size 1] item 
        ]

        case/all [
            head [insert system/words/head block item]
            tail [append block item]
        ]
    )
]
;probe do order [3 4 5 6 7] '+
;probe do append order/head [4 2 3 8 1] 'max 1

; @hiiamboris - lispy mod of @9214's macro:
#do [
    fold: func [op a b /local x][unless op? :op [op: make op! :op] foreach x b [a: a op x] a]
        rule: [['+ | '- | '* | '/ | '// | '% | '** | 'max | 'min] some scalar! end]
]
#macro [ahead paren! set b into rule] func [s e][ fold get first b second b skip b 2 ]
;
;probe (+ 1 2 3 4 5)
;probe (* 1 2 3 4 5)
;probe (** 2 2 2 2)
;probe (/ 100 2 5)
;probe (min 4 7 3 4 1)
;probe (max 4 7 3 4 1x1)



; Has a code-injection vulnerability with get-word! parameters (R3 uses APPLY).
; R3 version based on a discussion about FOLD in AltME.
blk: [1 2 3 4 5 6 7 8 9 10]
mean-red: func [res val][
	res/sum: res/sum + val
	res/count: res/count + 1
	res
]
accumulate/with blk :mean-red [sum 0 count 0]

;collect-accumulate
accumulate/with [a b c] :append copy []
accumulate/with b1: [a b c] func [res val][append res form val] b2: copy []
accumulate b1: ["a" b c] func [res val][append res form val]

incr-transducer: func [fn [any-function!]][
	func [res val] compose [
		(:fn) res val + 1
	]
]
accumulate/with blk incr-transducer :mean-red [sum 0 count 0]

reducing-func-spec: [result input]
reducing-func: func [
	"Make a reducing function that takes RESULT and INPUT params"
	body [block!]
][
	; Reducing funcs MUST return the result
	if not 'result = last body [body: append copy body 'result]
	func [result input] body
]
;red>> fn: reducing-func [print [result input]]
;== func [result input][print [result input] result]
;red>> fn 1 2
;1 2
;== 1
;red>> fn: reducing-func [result: result + input]
;== func [result input][result: result + input result]
;red>> fn 1 2
;== 3
;red>> fn fn 1 2 3
;== 6

;-------------------------------------------------------------------------------


;all?: func [    ; every?
;	"Returns true if all items in the series match a test."
;	series  [series!]
;	test [datatype! any-function!] "Datatype to match, or func that returns false if test fails."
;][
;	either datatype? test [
;		parse series compose [some (test)]
;	][
;		foreach value series [
;			if not test :value [return false]
;		]
;	]
;]
; This name is too close to ALL
; all??  double ?? to denote that it takes a predicate func and is a predicate itself?
all?: func [    ; every? each? is-each? are-all? all-are? all-of?
	"Returns true if all items in the series match a test."
	series	[series!]
	test	[any-function!] "Test (predicate) to perform on each value; must take one arg"
][
	foreach value series [
		if not test :value [return false]
	]
]

; ALL? is too close to ALL
all-are?: func [    ; every? all-are? ;; each? is-each? each-is? are-all? all-of?
	"Returns true if all items in the series match a test"
	series	[series!]
	test	"Test to perform against each value; must take one arg if a function"
][
	either any-function? :test [
		foreach value series [if not test :value [return false]]
		true
	][
		if word? test [test: to lit-word! form test]
		either integer? test [
			parse series compose [some quote (test)]
		][
			parse series [some test]
		]
	]
]
e.g. [
	all-are? [1 2 3] integer!
	all-are? [1 2 3] :integer?
	all-are? [x x x] word!
	all-are? [x x x] 'x
	all-are? [x x y] 'x

	a1: 1 a2: 2 a3: 3
	blk: reduce [a1 a2 a3]
	all-are? next blk blk/1
	a1: 1 a2: 1 a3: 1
	blk: reduce [a1 a2 a3]
	all-are? next blk blk/1

	a1: 1 a2: 2 a3: 3
	blk: reduce [a1 a2 a3]
	all-are? next blk func [v][equal? blk/1 v]
	a1: 1 a2: 1 a3: 1
	blk: reduce [a1 a2 a3]
	all-are? next blk func [v][equal? blk/1 v]
]

;any?: func [    ; some?
;	"Returns true if any items in the series match a test."
;	series [series!]
;	test [datatype! any-function!] "Datatype to match, or func that returns true if test passes"
;][
;	either datatype? test [
;		found? find series test
;	][
;		foreach value series [
;			if test :value [return true]
;		]
;	]
;]
; ANY? is too close to ANY
;any?: func [    ; some? is-any? are-any? any-are? any-of?
;	"Returns true if any items in the series match a test"
;	series	[series!]
;	test	[any-function!] "Test (predicate) to perform on each value; must take one arg"
;][
;	foreach value series [
;		if test :value [return true]
;	]
;]
; This really only needs to support functions. FIND works for simple values.
; Then we have to ask if it should match ALL-ARE? in what args it supports.
any-are?: function [    ; some? is-any? are-any? any-are? any-of?
	"Returns true if any items in the series match a test"
	series	[series!]
	test	"Test to perform against each value; must take one arg if a function"
][
	either any-function? :test [
		foreach value series [if test :value [return true]]
		false
	][
		if word? test [test: to lit-word! form test]
		either integer? test [
			parse series compose [some quote (test)]
		][
			parse series [some test]
		]
		;find/only series test
	]
]
e.g. [
	any-are? [1 2.3] integer!
	any-are? [1.2 3] :integer?
	any-are? [x #y ] word!
	any-are? [x y z] 'x
	any-are? [w y z] 'x
]

count: function [
	"Returns a count of values in a series that match a test."
	series [series!]
	test [any-function!] "Test (predicate) to perform on each value; must take one arg"
][
	n: 0
	;foreach value series [if test :value [incr n]]
	foreach value series [if test :value [n: n + 1]]
	n
]
;b: [1 2 3 4 5 6 a b c d #e #f #g]

;collect-each: func [
;	"Removes values from a series where body returns TRUE."
;	;"Returns the series after removing all values that match a test."
;	'word [get-word! word! block!] "Word or block of words to set each time (will be local)"
;	series [series!]
;	body [block!] "Block to evaluate; return TRUE to reomve"
;	/into "Put results in out block, instead of creating a new block"
;		; TBD: make out type series!
;		out [any-block!] "Target for results, when /into is used" 
;	/local tmp
;][
;	collect/into [
;		foreach	:word series [
;			if not unset? set/any 'tmp do body [keep/only :tmp]
;		]
;	] any [out copy []]
;]
;collect-each: func [
;	"Removes values from a series where body returns TRUE."
;	;"Returns the series after removing all values that match a test."
;	'word [get-word! word! block!] "Word or block of words to set each time (will be local)"
;	series [series!]
;	body [block!] "Block to evaluate; return TRUE to reomve"
;	/into "Put results in out block, instead of creating a new block"
;		; TBD: make out type series!
;		out [any-block!] "Target for results, when /into is used" 
;	/local tmp res
;][
;	res: any [out copy []]
;	foreach	:word series [
;		if not unset? set/any 'tmp do body [append/only res :tmp]
;	]
;	res
;]
;?? I still like my original COLLECT syntax, which I have now aliased
;   to COLLECT-EACH, but for the greater good...
;collect-each: :map-each

collect-each: func [
	"Evaluates body for all values in a series, collecting results with `keep`"
	'word [word! block!] "Word, or words, to set on each iteration" 
	series [series!] 
	body [block!]
][
	; This can't keep unset values.
	collect compose/only [
		foreach (word) series (body)
	]
]
;collect-each v [1 2 3] [keep v * 2]


count-each: function [
	"Evaluates body for each value(s) in a series, returning a count of true results."
	'word [word!] "Word, or words, to set on each iteration"
	data  [block!] 
	body  [block!]
][
	n: 0
	foreach :word data [if do body [n: n + 1]]
	n
]
;count-each a [1 2 3] [odd? a]

;filter: func [
;	"Returns all values in a series that match a test."
;	series [series!]
;	test [function!] "Test (predicate) to perform on each value; must take one arg" ; TBD: any-function!
;	/skip "Treat the series as fixed size records"
;		size [integer! none!]
;][
;	either empty? series [none] [
;		default size 1
;		;TBD: assert positive? size
;		collect [
;			forskip series size [
;				; Should we copy the value?
;				; Should we copy n (skip size) values?
;				; Should we have an option to return the series positions?
;				if test first series [keep first series]
;			]
;		]
;	]
;]

;filter: function [
;	"Returns all values in a series that match a test."
;	series [series!]
;	test [function!] "Test (predicate) to perform on each value; must take one arg" ; TBD: any-function!
;	/out "Reverse the test, filtering out matching results"
;][
;	collect [
;		foreach value series [
;			either out [
;				if not test :value [keep/only :value]
;			][
;				if test :value [keep/only :value]
;			]
;		]
;	]
;]
;
;; This doesn't use COLLECT, so there is no conflict with /OUT in Red right now.
;filter: function [
;	"Returns all values in a series that match a test."
;	series [series!]
;	test [function!] "Test (predicate) to perform on each value; must take one arg" ; TBD: any-function!
;	/out "Reverse the test, filtering out matching results"
;][
;    result: copy []
;	foreach value series [
;		either out [
;			if not test :value [append/only result :value]
;		][
;			if test :value [append/only result :value]
;		]
;	]
;	result
;]
;
;filter: function [
;	"Returns all values in a series that match a test."
;	series [series!]
;	test [function!] "Test (predicate) to perform on each value; must take one arg" ; TBD: any-function!
;	/out "Reverse the test, filtering out matching results"
;][
;    result: copy []
;    ; The lambda here is like QUOTE, but it evaluates.
;    ; This gets the EITHER out, at the cost of always calling OP.
;    ; Red crashes when I try to build a func to do the NOT in it right now.
;    op: either out [:not] [func [val] [:val]]
;	foreach value series [
;		if op test :value [append/only result :value]
;	]
;	result
;]
; b: append/dup copy [] [1 b #c "d"] 15000


filter: function [
	"Returns two blocks: items that pass the test, and those that don't"
	series [series!]
	test [any-function!] "Test (predicate) to perform on each value; must take one arg"
	/only "Return a single block of values that pass the test"
][
	either only [
		collect [foreach value series [if test :value [keep/only :value]]]
	][
		; First block is values that pass the test, second for those that fail.
		result: copy/deep [[][]]
		foreach value series [
			; Coercing the result of the test to logic! lets us safely
			; use it with PICK, where true picks the first item, and
			; false the second.
			append/only pick result make logic! test :value :value
		]
		result
	]
]
;filter: function [
;	"Returns two blocks: items that pass the test, and those that don't."
;	series [series!]
;	test [any-function!] "Test (predicate) to perform on each value; must take one arg"
;	/only "Return a single block of values that pass the test"
;	/local result
;][
;    result: reduce [copy [] copy []]
;	foreach value series [
;		append/only pick result make logic! test :value :value
;	]
;	result
;]
; Clojure: When coll is a map, pred is called with key/value pairs.
; Some langs call this 'partition
filter: function [
	"Returns two blocks: items that pass the test, and those that don't"
	series [series!]
	test [any-function!] "Test (predicate) to perform on each value; must take one arg"
	/only "Return a single block of values that pass the test"
	; Getting only the things that don't pass a test means applying NOT
	; to the test and using /ONLY. Applying NOT means making a lambda.
	; Not hard, for people who understand anonymous funcs.
	;/pass "Return a single block of values that pass the test"
	;/fail "Return a single block of values that fail the test"
][
	;TBD: Is it worth optimizing to avoid collecting values we won't need to return?
	result: copy/deep [[][]]
	foreach value series [
		; `make logic!` is used, so zero test results become false.
		append/only pick result make logic! test :value :value
	]
	either only [result/1][result]
]
;red>> filter [1 2 3 4 5 6 7] :even?
;== [[2 4 6] [1 3 5 7]]
;red>> filter [1 2 3 4 5 6 7] :odd?
;== [[1 3 5 7] [2 4 6]
;red>> filter/only [1 2 3 4 5 6 7] :odd?
;== [1 3 5 7]
;red>> filter [/only /dup 3] :refinement?
;== [[/only /dup] [3]

; Is . better than _ as a placeholder for the current value? It maps
; to the concept of %. as a current directory, but _ looks like an
; empty space where something goes.
filter: partition: function [
	"Returns two blocks: items that pass the test, and those that don't"
	series [series!]
	test [any-function! block!] "Test (predicate) to perform on each value; must take one arg if a function; block implied arg is named ."
	/only "Return a single block of values that pass the test"
	; Getting only the things that don't pass a test means applying NOT
	; to the test and using /ONLY. Applying NOT means making a lambda.
	; Not hard, for people who understand anonymous funcs.
	;/pass "Return a single block of values that pass the test"
	;/fail "Return a single block of values that fail the test"
	
	; This gets more involved for blocks of words. > single arity.
	; It also puts the words at the end, which is completely backwards from -each std.
	;/each arg [word! block!] "Override . name for blocks."
][
	;TBD: Is it worth optimizing to avoid collecting values we won't need to return?
	result: copy/deep [[][]]
	; Convert block test to anonymous func
	if block? :test [
		;probe test: func either arg [compose [(arg)]][[.]] test
		test: func [.] test
	]
	foreach value series [
		; `make logic!` is used, so zero test results become false.
		append/only pick result make logic! test :value :value
	]
	either only [result/1][result]
]
;red>> filter [1 2 3 4 5 6 7] :even?
;== [[2 4 6] [1 3 5 7]]
;red>> filter [1 2 3 4 5 6 7] :odd?
;== [[1 3 5 7] [2 4 6]
;red>> filter/only [1 2 3 4 5 6 7] :odd?
;== [1 3 5 7]
;red>> filter [/only /dup 3] :refinement?
;== [[/only /dup] [3]
;>> filter [1 2 3 4 5 6 7] [odd? _]
;== [[1 3 5 7] [2 4 6]]
;>> filter [[1 2] [3 4] [6 6]] [odd? ./1]
;== [[[1 2] [3 4]] [[6 6]]]

;filter/each [1 2 3 4 5 6 7 8 9 10] [all [a > 3  b < 10  reduce [a b]]] [a b]


;find-all: function [
;	"Returns all positions in a series that match a test."
;	series [series!]
;	test [function!] "Test (predicate) to perform on each value; must take one arg" ; TBD: any-function!
;][
;	result: copy []
;	forall series [
;		if test series/1 [append/only result series]
;	]
;	result
;]

find-all: function [
	"Returns all positions in a series that match a test."
	series [series!]
	test   [any-function!] "Test (predicate) to perform on each value; must take one arg"
][
	collect [
		forall series [if test series/1 [keep/only series]]
	]
]
find-all [1 2 3 4 5 6] :odd?
find-all [1 2 3 4 5 6] :even?
find-all [1 2 q 3 #x 4 /c 5 6] :any-word?

;find-each

; This should return the first value that matches, but we don't have BREAK yet.
;find-if: func [
;	;"Finds the value in a series that matches a predicate."
;	"Returns a series at the last value that matches a test."
;	series [series!]
;	test [function!] "Test (predicate) to perform on each value; must take two args" ; TBD: any-function!
;	/skip "Treat the series as fixed size records"
;		size [integer! none!]
;	/local pos
;][
;	; FIND returns NONE if not found, but FIRST fails on NONE, so
;	; we can't blindly do FIRST FIND.
;	either empty? series [none] [
;		default size 1
;		;TBD: assert positive? size
;		;TBD: Handle case if none match
;		pos: series
;		forskip series size [
;			if test first pos [pos: series]
;		]
;		pos
;	]
;]
;find-if: func [
;	"Returns a series at the first value that matches a test."
;	series [series!]
;	test [function!] "Test (predicate) to perform on each value"
;	/skip "Treat the series as fixed size records"
;		size [integer! none!]
;][
;	either empty? series [none][
;		size: any [size 1]
;		forskip series size [
;			if test first series [return series]
;		]
;	]
;]

find-if: func [
	"Returns a series at the first value that matches a test."
	series [series!]
	test [any-function!] "Test (predicate) to perform on each value"
	/skip "Treat the series as fixed size records"
		size [integer! none!]
][
	either empty? series [none][
		forall series [
			if test first series [return series]
		]
	]
]
find-if [2 4 6 7] :odd?


;fold: :accumulate
;sum: func [block [any-block!]] [fold block :add]
;product: func [block [any-block!]] [fold/with block :multiply 1]
;sum-of-squares: func [block [any-block!]] [
;    fold block func [x y] [x * x + y] 0
;]

keep-each: func [
	"Keeps only values from a series where body block returns TRUE."
	'word [get-word! word! block!] "Word or block of words to set each time (will be local)"
	data  [series!]
	body  [block!] "Block to evaluate; return TRUE to collect"
][
	remove-each :word data compose [not do (body)]
	data
]
e.g. [
	filter: :keep-each
	filter x [1 2 3] [x = 2]
	filter x [1 2 3] [odd? x]
	filter res [1 2 3] [odd? res]
	filter [x y] [a 1 b 2 c 3] [all [odd? y  'c = x]]
	filter x [(1 2) (2 3) (3 4)] [x = first [(2 3)]]
]


map: func [
	"Evaluates a function for each value(s) in a series and returns the results."
	series [series!]
	fn [any-function!] "Function to perform on each value; must take one arg"
][
	collect [
		foreach value series [
			keep/only fn value
		]
	]
]
map: func [
	"Evaluates a function for each value(s) in a series and returns the results."
	series [series!]
	fn [function!] "Function to perform on each value; must take one arg" ; TBD: any-function!
	;/only "Insert block types as single values"
	;/skip "Treat the series as fixed size records"
	;	size [integer!]
][
	collect [
		foreach value series [
			keep/only fn value
		]
	]
]

; JS-like MAP. The order of args to the function is a bit odd, but is set
; up that way because we always want at least the value (if your func takes
; only one arg), the next most useful arg is the index, as you may display
; progress, and the series is there to give you complete control and match
; how JS does it. Now, should the series value be passed as the head of the
; series, or the current index, using AT?
; This is *sort of* like map-indexed in Clojure.
map-js: func [
	"Evaluates a function for all values in a series and returns the results."
	series [series!]
	fn [any-function!] "Function to perform on each value; called with value, index, series, [? and size ?] args"
	;/only "Collect block types as single values"
	;/skip "Treat the series as fixed size records"
	;	size [integer!]
][
	collect [
		repeat i length? series [   ; use FORSKIP if we want to support /SKIP.
			keep/only fn series/:i :i :series ;:size
		]
	]
]
res: map-js [1 2 3 a b c #d #e #f] :form
res: map-js [1 2 3 a b c #d #e #f] func [v i] [reduce [i v]]
res: map-js [1 2 3 a b c #d #e #f] func [v i s] [reduce [i v s]]
res: map-js "Hello World!" func [v i s] [pick s i]
res: map-js "Hello World!" func [v] [either v = #"o" [1][0]]	; sum result = count
res: map-js "Hello World!" func [v i] [if v = #"o" [i]]			; remove none! values to keep only index values
res: map-js "Hello World!" func [v i s] [if v = #"o" [at s i]]	; remove none! values to keep only series offsets

map-ex: func [
	"Evaluates a function for all values in a series and returns the results."
	series [series!]
	fn [any-function!] "Function to perform on each value; called with value, index, series, [? and size ?] args"
	;/only "Collect block types as single values"
	;/skip "Treat the series as fixed size records"
	;	size [integer!]
][
	collect [
		repeat i length? series [   ; use FORSKIP if we want to support /SKIP.
			keep/only fn series/:i :i :series ;:size
		]
	]
]
res: map-ex [1 2 3 a b c #d #e #f] :form
res: map-ex [1 2 3 a b c #d #e #f] func [v i] [reduce [i v]]
res: map-ex [1 2 3 a b c #d #e #f] func [v i s] [reduce [i v s]]
res: map-ex "Hello World!" func [v i s] [pick s i]
res: map-ex "Hello World!" func [v] [either v = #"o" [1][0]]	; sum result = count
res: map-ex "Hello World!" func [v i] [if v = #"o" [i]]			; remove none! values to keep only index values
res: map-ex "Hello World!" func [v i s] [if v = #"o" [at s i]]	; remove none! values to keep only series offsets

; Minimal map-ex: no /skip, always /only
map-ex: func [
	"Evaluates a function for all values in a series and returns the results."
	series [series!]
	fn [any-function!] "Function to perform on each value; called with value, index, series args"
][
	collect [
		repeat i length? series [
			keep/only fn series/:i :i :series
		]
	]
]
res: map-ex [1 2 3 a b c #d #e #f] :form
res: map-ex [1 2 3 a b c #d #e #f] func [v i] [reduce [i v]]
res: map-ex [1 2 3 a b c #d #e #f] func [v i s] [reduce [i v s]]

;-------------------------------------------------------------------------------

default: func [
	"Set a value for the word if the word is not set or is none."
	'word
	value
][
	if not all [value? :word  not none? get word] [
		set word :value
	]
	;TBD: get-word args support not in place yet.
	;if not set? :word [set word :value]
	get word
]

find-min: func [
	"Finds the smallest value in a series"
	series [series!]
	/skip "Treat the series as fixed size records"
		size [integer! none!]
	/local pos
][
	either empty? series [none] [
		default size 1
		;TBD: assert positive? size
		pos: series
		forskip series size [
			if lesser? first series first pos [pos: series]
		]
		pos
	]
]

pick-min: func [
	"Pick the smallest value in a series"
	series [series!]
	/skip "Treat the series as fixed size records"
		size [integer! none!]
][
	either empty? series [none] [
		either skip [
			copy/part find-min/skip series size size
		][
			pick find-min/skip series size 1
		]
	]
]

map: function [
	"Evaluates a function for all values in a series and returns the results."
	series [series!]
	fn [any-function!] "Function to perform on each value; called with value, index, and series args"
	/only "Series is a block of blocks to process items from in parallel"
][
	collect [
		either only [
			; Use shortest series to control iterations
			repeat i pick-min map series :length? [
				fn-call: clear []
				insert fn-call :fn
				repeat j length? series [append/only fn-call series/:j/:i]
				keep/only do fn-call
			]
		][
			repeat i length? series [
				keep/only fn series/:i :i :series ; :size ?
			]
		]
	]
]
res: map [1 2 3 a b c #d #e #f] :form
res: map/only [[1 2 3] [4 5 6]] :add
;res: map [1 2 3 a b c #d #e #f] func [v i s] [reduce [i v s]]
;res: map "Hello World!" func [v i s] [pick s i]

;-------------------------------------------------------------------------------


; Lisp-like MAP
;map: func [
;	{Maps a function to all elements of a block}
;	[throw]
;	fn   [any-function! word! path!] "Function to map over args"
;	block [block!] "Block of values to use as first function arg"
;	/with other-args [block!] "Block of sub-blocks; remaining args to function"
;	/local result blk
;] [
;	if word? :fn [fn: get fn]
;	result: make block! length? block
;	either none? other-args [
;		foreach elem block [append/only :result fn get/any 'elem]
;	][
;		fn: reduce [:fn]
;		other-args: copy/deep other-args
;		blk: make block! length? other-args
;		foreach elem block [
;			clear blk
;			foreach arg-blk other-args [
;				append/only blk pick arg-blk 1
;				remove arg-blk
;			]
;			append/only :result do compose [(fn) get/any 'elem (blk)]
;		]
;	]
;	result
;]


; From R2-forward
; MAP-EACH, minimal fast version
;map-each: function [
;	"Evaluates a block for each value(s) in a series and returns them as a block."
;	[throw]
;	'word [word! block!] "Word or block of words to set each time (local)"
;	data [block!] "The series to traverse"
;	body [block!] "Block to evaluate each time"
;] compose/deep [ ; To reduce function creation overhead to just once
;	foreach :word data reduce [
;		first [(func [output val [any-type!]] [
;			if value? 'val [insert/only tail output :val]
;			output
;		])]
;		make block! either word? word [length? data] [divide length? data length? word]
;		:do body
;	]
;]
; R3-compatible interface
; What happens if the result of the DO is unset!? For now, we'll
; ignore unset values. The example case being SPLIT, which uses
; MAP-EACH with an unset value for negative numeric vals used to
; skip in the series.
;map-each: func [
;	"Evaluates body for each value(s) in a series, returning all results."
;	'word [word!] "Word, or words, to set on each iteration"
;	data [block!] 
;	body [block!]
;	/local tmp
;] [
;	collect compose/deep [
;		foreach (:word) data [
;			;set/any 'tmp do bind/copy body (:word)
;			set/any 'tmp do body
;			if value? 'tmp [keep/only :tmp]
;		]
;	]
;]

; COLLECT doesn't work here yet.
;map-each: func [
;	"Evaluates body for each value(s) in a series, returning all results."
;	'word [word!] "Word, or words, to set on each iteration"
;	data [block!] 
;	body [block!]
;	/local tmp
;] [
;	;body: bind/copy body :word
;	collect compose [
;		foreach (:word) data [
;			;set/any 'tmp do bind/copy body (:word)
;			set/any 'tmp do body
;			if value? 'tmp [keep/only :tmp]
;		]
;	]
;]
;map-each a [1 2 3] [print mold a a]
; This returns:
;red>> map-each a [1 2 3] [print mold a a]
;1
;2
;3
;1
;2
;3
;1
;2
;3
; == [1 2 3 [1 2 3 [1 2 3 [1 2 3 [1 2 3 [1 2 3 [1 2 3 [1 2 3 [1 2 3 [1 ...
; Something about COLLECT isn't happy
; But this version works
map-each: func [
	"Evaluates body for each value(s) in a series, returning all results."
	'word [word!] "Word, or words, to set on each iteration"
	data [block!] 
	body [block!]
	/local tmp
] [
	res: copy []
	foreach :word data [
		if value? set/any 'tmp do body [append/only res :tmp]
	]
	res
]
;map-each v [1 2 3] [2 * v]
;map-each x [1 2 3 4 5] [either even? x [continue] [x]]
;map-each x [1 2 3 4 5] [either even? x [break] [x]]


;map-each: func [
;	"Evaluates body for each value(s) in a series, returning all results."
;	'word [word!] "Word, or words, to set on each iteration"
;	data [block!] 
;	body* [block!]
;	/local tmp
;] [
;	collect [
;	    print mold data 
;    	foreach :word data [
;    	    ;print mold word
;    	    ;print mold body*
;    		if not unset? set/any 'tmp do bind body* get word [keep :tmp]
;    	]
;	]
;]
;map-each v [1 2 3] [2 * v]


; MAP isn't a great name to us in Red. For one thing, we have a `map!` type
; that has nothing to do with MAP HOF use. There is also the concept of
; map-reduce, which is a well-known term but we also have `reduce`, which
; is *not* related to the concept of FOLD in HOF terms. It means "evaluate
; in place" basically.

; apply-each apply-to-each
map-each: function [
	"Evaluates body for each value in a series, returning all results."
	'word [word! block!] "Word, or words, to set on each iteration"
	data [series!] ; map!
	body [block!]
][
	collect [
		foreach :word data [
			; @dockimbel said it should return a block of the same size
			; as the input, but there is no hard decision on whether 
			; unset results should be returned as NONE. They are different,
			; as unset! is treated as a truthy value.
			; ES5 has the concept of `holes` in arrays.
			;  http://speakingjs.com/es5/ch18.html#array_holes
			; Supporting unset! results means COLLECT's KEEP func has to
			; be modded to allow any-type! in its spec.
			;if not unset? set/any 'tmp do body [keep/only :tmp]
			;keep/only either unset? set/any 'tmp do body [none][:tmp]
			keep/only do body
		]
	]
]
map-each v [1 2 3] [2 * v]
map-each v "IBM" [v - 1]
;map-each [k v] #(a 1 b 2 c 3) [append form v k]
map-each x [1 2 3 4 5] [either even? x [continue] [x]]
map-each x [1 2 3 4 5] [either even? x [break] [x]]

; As it is in Red right now.
apply: func [
    "Apply a function to a block of arguments." 
    fn [any-function!] "Function to apply" 
    args [block!] "Arguments for function" 
    /only "Use arg values as-is, do not reduce the block"
][
    args: either only [copy args] [reduce args] 
    do head insert args :fn
]

apply: function [
    "Apply a function to a block of arguments." 
    fn [any-function!] "Function to apply" 
    args [block!] "Arguments for function" 
    /only "Use arg values as-is, do not reduce the block"
    /all  "Apply (map) the function to each value in args"
][
    args: either only [copy args] [reduce args]
    either all [
		collect [
			foreach value args [
				;keep/only apply :fn reduce [value]
				attempt [keep/only fn value]	; attempt for unset values that keep doesn't like.
			]
		]
    ][
    	do head insert args :fn
    ]
]
apply :print [1 2]
apply/all :print [1 2]

    
;ref-name: func [
;	refs [word! refinement! block!]
;][
;	if block? refs [
;		refs: remove-each val copy refs [not any-word? val]
;	]
;	collect [
;		; If we use TO REFINEMENT! here, then TO PATH! used on the result
;		; block gives us double slashes in the path.
;		foreach val compose [(refs)] [
;		    if get/any val [keep to word! val]
;		]
;	]
;]
;;>> fn: func [/ref /r2] [print mold ref-name [ref r2]]
;;>> fn/ref/r2
;;[/ref /r2]
;;>> fn/ref
;;[/ref]
;;>> fn/r2
;;[/r2]
;;>> fn
;;[]
;
;refine: function [
;	"Returns a path, by adding refinement(s) to a word or path."
;	path [word! path!]
;	refs [word! block!] "Refinements to add"
;][
;	refs: remove-each val copy refs [not any-word? val]
;	join to path! :path refs
;	;to path! append copy [find] ref-name [last tail] s v
;]

;remove-each: func [
;	"Removes values from a series where body block returns TRUE."
;	"Returns the series after removing all values that match a test."
;	'word [get-word! word! block!] "Word or block of words to set each time (will be local)"
;	series [series!]
;	body [block!] "Block to evaluate; return TRUE to reomve"
;][
;	
;]

; This is just conceptual. Basic tests work, but do not consider it robust.
remove-each: function [
	"Removes values from a series where body returns TRUE."
	;"Returns the series after removing all values that match a test."
	'word  [get-word! word! block!] "Word or block of words to set each time (will be local)"
	series [series!]
	body   [block!] "Block to evaluate; return TRUE to remove"
][
	; How many words are we setting on each iteration?
	count: length? compose [(word)]
	; This is a two pass approach, pass 1 marks removal locations,
	; pass 2 removes the values from tail to head.
	marks: copy []
	i: 1
	; Pass 1: Mark locations, using INSERT so higher values are at the head.
	foreach :word series [
		if do body [insert marks i]
		i: i + count
	]
	; Pass 2: Remove values
	foreach mark marks [
		remove/part at series mark count
	]
	series
]
;b: [1 2 3 4 5 6 7 8]
;print remove-each v b [v > 4]
;b: [1 -2 3 4 5 -6 7 8]
;print remove-each v b [v < 0]
;b: [1 -2 3 4 5 -6 7 8]
;print remove-each [x y] b [y < 0]
;b: [1 -2 3 4 5 -6 7 8 9 -10 11 12 13 -14 15 16 17  -18]
;print remove-each [x y z] copy b [y < 0]


;-------------------------------------------------------------------------------

; TRANSform and reDUCE/fold (reduce in Python/Clojure/Haskell terms, not rebol}
; A fold func takes a seed and a new input and returns the next result.
; a transducer is a function that takes one reducing function and returns another:
; WORK IN PROGRESS
transduce: function [fn [any-function!] seed data [block! none!]] [
	either none? data [
		either none? seed [
		    func [seed data] compose/deep [
				either tail? data [seed][
			    	(fn) data/1 foldr (:fn) seed next data
			    ]
		   	]
		][
		    func [data] compose/deep [
				either tail? data [(seed)][
			    	(fn) data/1 foldr (:fn) (seed) next data
			    ]
		   	]
		]
	][
		either tail? data [seed][
	    	fn data/1 foldr :fn seed next data
	    ]
	]
]
transduce :add none none

; This works
foldr: func [fn [any-function!] seed data [block!]][
	;print ['foldr seed mold data]
	either tail? data [seed][
		fn data/1 foldr :fn seed next data
	]
]
foldr :add 0 [1 2 3]
foldr :multiply 1 [2 3 4]


; Seeded left reduce is the generalization

;for-map: func ['words [block!] map [map!] body [block!]][
;	foreach words/1 keys-of map [do body]
;]
;select-each

; list comprehensions
;list-of list
;set-of set

into: function [output body][
]

;-------------------------------------------------------------------------------

;!! UNTESTED
; Just an idea. 
; for-which such-that
build-set: function [spec [block!] "[word | test]"][
	parse spec [set word [word! series!] '| set test [block! | word! | any-function!]]
	series: get word
	if word? test [test: get test]
	either block? [keep-each word series test][filter/only series :test]
]

;-------------------------------------------------------------------------------

; Should this return the position, like FIND, rather than an integer?
; No match would then mean a NONE result. REMOVE/TAKE/COPY with /PART
; then means using INDEX?.
find-while: function [
	"Find leading items that match test; return last found index; zero if no matches."
	series	[series!] "(modified)"
	test	[any-function!] "Test (predicate) to perform on each value; must take one arg"
][
	n: 0
	repeat i length? series [
		either test pick series i [n: n + 1][break]
	]
	n
]


keep-while: function [
	"Keeps items from series head that match test, until one fails; returns series"
	series	[series!] "(modified)"
	test	[any-function!] "Test (predicate) to perform on each value; must take one arg"
][
	head clear at series 1 + find-while series :test
]
e.g. [
	b: [1 2 3 4 5 6]
	keep-while b func [v][v <= 3]
	?? b
	b: [1 2 3 4 5 6]
	keep-while b func [v][v <= 1]
	?? b
	b: [1 2 3 4 5 6]
	keep-while b func [v][v <= 0]
	?? b
	b: []
	keep-while b func [v][v <= 3]
	?? b
	b: [1 2 3 4 5 6]
	keep-while b func [v][v <= 5]
	?? b
	b: [1 2 3 4 5 6]
	keep-while b func [v][v <= 9]
	?? b
]


;take-while: function [
;	"Takes and returns items from series head that match test, until one fails"
;	series	[series!] "(modified)"
;	test	[any-function!] "Test (predicate) to perform on each value; must take one arg"
;][
;	collect [
;		n: 0
;		repeat i length? series [
;			either test val: pick series i [keep :val  n: n + 1][break]
;		]
;		remove/part series n
;	]
;]

;remove-while: function [
;	"Removes items from series head that match test, until one fails; returns series"
;	series	[series!] "(modified)"
;	test	[any-function!] "Test (predicate) to perform on each value; must take one arg"
;][
;	n: 0
;	repeat i length? series [
;		either test pick series i [n: n + 1][break]
;	]
;	remove/part series n
;]

;remove-while: function [
;	"Removes items from series head that match test, until one fails; returns series"
;	series	[series!] "(modified)"
;	test	[any-function!] "Test (predicate) to perform on each value; must take one arg"
;][
;	while [all [not empty? series  test pick series 1]][remove series]
;	series	; return the series, in case the `while` body never executes
;]

remove-while: function [
	"Removes items from series head that match test, until one fails; returns series"
	series	[series!] "(modified)"
	test	[any-function!] "Test (predicate) to perform on each value; must take one arg"
][
	remove/part series find-while series :test
]

e.g. [
	b: [1 2 3 4 5 6]
	remove-while b func [v][v <= 3]
	?? b
	b: [1 2 3 4 5 6]
	remove-while b func [v][v <= 1]
	?? b
	b: [1 2 3 4 5 6]
	remove-while b func [v][v <= 0]
	?? b
	b: []
	remove-while b func [v][v <= 3]
	?? b
	b: [1 2 3 4 5 6]
	remove-while b func [v][v <= 5]
	?? b
	b: [1 2 3 4 5 6]
	remove-while b func [v][v <= 9]
	?? b
]

;take-while: function [
;	"Takes and returns items from series head that match test, until one fails"
;	series	[series!] "(modified)"
;	test	[any-function!] "Test (predicate) to perform on each value; must take one arg"
;][
;	n: 0
;	repeat i length? series [
;		either test pick series i [n: n + 1][break]
;	]
;	take/part series n
;]

;take-while: function [
;	"Takes and returns items from series head that match test, until one fails"
;	series	[series!] "(modified)"
;	test	[any-function!] "Test (predicate) to perform on each value; must take one arg"
;][
;	collect [
;		while [all [not empty? series  test pick series 1]][keep take series]
;	]
;]

take-while: function [
	"Takes and returns items from series head that match test, until one fails"
	series	[series!] "(modified)"
	test	[any-function!] "Test (predicate) to perform on each value; must take one arg"
][
	take/part series find-while series :test
]
e.g. [
	b: [1 2 3 4 5 6]
	take-while b func [v][v <= 3]
	?? b
	b: [1 2 3 4 5 6]
	take-while b func [v][v <= 1]
	?? b
	b: [1 2 3 4 5 6]
	take-while b func [v][v <= 0]
	?? b
	b: []
	take-while b func [v][v <= 3]
	?? b
	b: [1 2 3 4 5 6]
	take-while b func [v][v <= 5]
	?? b
	b: [1 2 3 4 5 6]
	take-while b func [v][v <= 9]
	?? b
]

copy-while: function [
	"Copies and returns items from series head that match test, until one fails"
	series	[series!]
	test	[any-function!] "Test (predicate) to perform on each value; must take one arg"
][
	copy/part series find-while series :test
]
e.g. [
	b: [1 2 3 4 5 6]
	b: copy-while b func [v][v <= 3]
	?? b
]


skip-while: function [
	"Skips items from series head that match test, until one fails; returns series"
	series	[series!]
	test	[any-function!] "Test (predicate) to perform on each value; must take one arg"
][
	at series 1 + find-while series :test
]
e.g. [
	b: [1 2 3 4 5 6]
	b: skip-while b func [v][v <= 3]
	?? b
	b: [1 2 3 4 5 6]
	b: skip-while b func [v][v <= 1]
	?? b
	b: [1 2 3 4 5 6]
	b: skip-while b func [v][v <= 0]
	?? b
	b: []
	b: skip-while b func [v][v <= 3]
	?? b
	b: [1 2 3 4 5 6]
	b: skip-while b func [v][v <= 5]
	?? b
	b: [1 2 3 4 5 6]
	b: skip-while b func [v][v <= 9]
	?? b
]


do-while: function [
	"Evaluate a function for each matching value, until the first non-match"
	series	[series!]
	test	[any-function!] "Test (predicate) to perform on each value; must take one arg"
	body    [any-function!] "Must take one arg"
][
	print mold :test
	repeat i find-while series :test [
		body pick series i
	]
]
e.g. [
	b: [1 2 3 4 5 6 7 8 9 10]
	do-while b func [v][v <= 3] :print
	; Have to be careful using ALL with *-while. 
	;do-while b func [v][probe v all [v <= 7  odd? v]] :print
]


;-------------------------------------------------------------------------------
; Idea noted, but discarded for the moment.

; This is bad because we can't walk a series and modify it at the same time.
; Not easily and safely at the mezz level anyway.
do-while: function [
	"Test for each value in a series, until one fails, evaluating body for those that pass."
	test	[any-function!] "Test (predicate) to perform on each value; must take one arg"
	series	[series!] "(may be modified)"
	body    [block!] "Block to evaluate for matching items"
][
	;bind body 'series
	repeat i length? series [
		probe pick series i
		if test pick series i [do body]
	]
	series
]
e.g. [
	blk: [1 2 3 4 5 6 7 8 9 10]
	; terrible to have an anonymous func first for readability
	do-while func [v][v <= 5]  blk  [take blk]

]

while-each: function [
	"Test for each value in a series, until one fails, evaluating body for those that pass."
	'word
	test	[any-function!] "Test (predicate) to perform on each value; must take one arg"
	series	[series!] "(may be modified)"
	body    [block!] "Block to evaluate for matching items"
][
	repeat i length? series [
		if test pick series i [do body]
	]
	series
]

;-------------------------------------------------------------------------------

; Macros
; Shen (defmacro hi [X + Y] -> [+ X Y] where (and (number? X) (number? Y)))
; https://gist.github.com/anonymous/36dc0c2e4975800c1688adaf9ff1113c

upper-ch: charset [#"A" - #"Z"]
lower-ch: charset [#"a" - #"z"]

var: [copy =var [some upper-ch any lower-ch]]
	
parse/case "abc" var
parse/case "Abc" var

;---

; Anonymous vars experiment
transform: function [input [block!] output [block!][
	vals: copy []
	vals: parse input [
	]
]

probe transform [1 + 2]

;-------------------------------------------------------------------------------



; Monad 
; Monadic value - wraps a value with a context that talks to composer
; Pure function - returns a monadic value
; Composer - function that composes a monadic value with a monadic function

;-------------------------------------------------------------------------------

loop-thru: function [cond body] [
    return: does [throw/name () 'return]
    while cond bind body 'body
]

func2: func [spec [block!] body [block!]][
    func spec compose/only [catch/name (body) 'return]
]

f: func2 [x] [
    loop-thru [x < 10] [x: x + 1 if x = 5 [return]]
    print "you see where return takes me?"
]

f 2

;-------------------------------------------------------------------------------

memoize: func [
    fn [function!] 
][
    
]

;-------------------------------------------------------------------------------

remove-each-and-count: function [
	"Like remove-each, but returns both modified series and count of removed items." 
    'word [word! block!] "Word or block of words to set each time" 
    data [series!] "The series to traverse (modified)" 
    body [block!] "Block to evaluate (return TRUE to remove)"
][
	orig-ct: length? data
	remove-each :word data body
	reduce [data  orig-ct - length? data]
]
remove-each-and-count v [1 2 3 4 5] [odd? v]
remove-each-and-count v [1 2 3 4 5 6 7 8 9 10] [odd? v]

;-------------------------------------------------------------------------------

; wikipedia HOF example

twice: func [fn [any-function!] x][fn fn x]
add-3: func [n][n + 3]
twice :add-3 7

;-------------------------------------------------------------------------------

; https://www.wolfram.com/language/elementary-introduction/2nd-ed/26-pure-anonymous-functions.html

; Wolfram pure func syntax lets you put a # placeholder for an arg
; in a func call, which is then replaced by each value in the series
; being mapped over.

