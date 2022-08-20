Red [
	title:   "MAP & ACCUMULATE routines"
	purpose: "Fast implementation of the most common higher order functions"
	author:  @hiiamboris
	license: 'BSD-3
]

; system/state/trace: 2

#system [
	count-refines: func [
		spec    [node!]
		return: [integer!]
		/local
			value [red-value!]
			s     [series!]
			n     [integer!]
	][
		assert spec <> null
		s: as series! spec/value
		value: s/offset
		n: 0
		while [value < s/tail] [
			if TYPE_OF(value) = TYPE_REFINEMENT [n: n + 1]
			value: value + 1
		]
		n
	]

	;-- recursive implementation of https://en.wikipedia.org/wiki/Pairwise_summation
	sum-pairwise*: func [
		data [byte-ptr!]								;-- ptr to vector values
		unit [integer!]
		int? [logic!]
		len  [integer!]
		return: [float!]
		/local r [float!] i half p
	][
		either all [len <= 16 len > 0] [				;-- 16 is found empirically (8 is ~20% slower, 32 is on par)
			r: 0.0
			p: data + (len * unit)
			either int? [
				while [p: p - unit  p >= data] [
					r: r + as-float vector/get-value-int as int-ptr! p unit
				]
			][
				while [p: p - unit  p >= data] [
					r: r + vector/get-value-float p unit
				]
			]
			if r <> r [throw 1]							;-- early exit for NaN case
		][
			half: len >>> 1
			r:     sum-pairwise* data                 unit int? half
			r: r + sum-pairwise* data + (half * unit) unit int? len - half	;-- watch out for bug #4937
		]
		r
	]

	sum-pairwise: func [
		vec [red-vector!]
		return: [float!]
		/local buf unit phead len r
	][
		assert any [vec/type = TYPE_FLOAT vec/type = TYPE_PERCENT vec/type = TYPE_INTEGER]
		buf: GET_BUFFER(vec)
		unit: GET_UNIT(buf)
		phead: (as byte-ptr! buf/offset) + (vec/head << (log-b unit))
		len: (as-integer buf/tail - phead) >>> (log-b unit)
		if len = 0 [return 0.0]
		catch 1 [										;-- catch for NaN case
			r: sum-pairwise* phead unit (vec/type = TYPE_INTEGER) len
			return r
		]
		system/thrown: 0
		0.0 / 0.0
	]
]

{
	Red-like argument order is: Accumulator Series Operator
	however when chained this becomes not so good:
	   accumulate (accumulate 0 series1 :fun1) series2 :fun2
	and when we produce the series in-line, it's also not very readable:
	   accumulate 0 produce the series :fun
	Haskell-like argument order is: Operator Accumulator Series
	which isn't very great when function is defined in-line:
	   accumulate func [a x] [a + x] 0 series
	func can be longer.. but that can be fixed by giving it a name (a good practice anyway)
	it also chains badly:
	   accumulate :fun2 (accumulate :fun1 0 series1) series2
	it though works for in-line series generation (common case):
	   accumulate :fun 0 produce the series
	so for now I don't see a clear winner, and am choosing the Red-like order
}
accumulate: routine [
	"Evaluate the operator over each item in the series"
	accumulator [any-type!] "Used as first argument to the operator, updated with it's result"
	series      [series!]   "Each item is used as second argument to the operator"	;-- requires #4927 fixed
	operator    [any-type!] "Operator or any binary function (or a word referring to it)"
	return:     [any-type!] "Last value of the accumulator (unchanged if series is empty)"
	/local check-arity [subroutine!] p [int-ptr!] ref-array [int-ptr!]
		fun [red-function!] empty-path [red-path!] arity [integer!] code [integer!] name [red-word!]
		oper srs type stype atype call rout nat act vec result i f item op? native? spec nrefs args
][
	stype: TYPE_OF(series)
	unless ANY_SERIES?(stype) [							;@@ typechecks are not working - #4928, have to do manually
		fire [TO_ERROR(script wrong-type) series]		;@@ not the best error message but there's no better one, with arg name
	]
	srs: as red-series! series
	atype: TYPE_OF(accumulator)

	type: TYPE_OF(operator)
	name: words/_anon
	if type = TYPE_WORD [
		name: as red-word! operator
		operator: word/get name
		type: TYPE_OF(operator)
	]

	fun: as red-function! operator
	check-arity: [
		empty-path: path/make-at as red-path! stack/push* 1
		arity: FFFFh and _function/calc-arity empty-path fun 0
		unless arity = 2 [
			fire [TO_ERROR(script invalid-arg) operator]	;@@ need a better error message, stating arity and arg name
		]
	]

	switch type [
		TYPE_ACTION TYPE_NATIVE TYPE_OP [
			op?:     type = TYPE_OP
			native?: type = TYPE_NATIVE
			unless op? [check-arity]					;@@ this relies on op having only 2 args (will change some day?)

			code: case [
				op? [
					oper: as red-op!     operator
					oper/code
				]
				native? [
					nat:  as red-native! operator
					nat/code
				]
				true [
					act:  as red-action! operator
					act/code
				]
			]

			;-- if action is a sum, attempt to perform fast pairwise summation on numeric vectors
			assert code <> 0
			i: ACT_ADD
			vec: as red-vector! srs
			if all [									;-- sum of vector: special case
				actions/table/i = code
				stype = TYPE_VECTOR
				any [atype    = TYPE_INTEGER atype    = TYPE_FLOAT atype = TYPE_PERCENT]
				any [vec/type = TYPE_INTEGER vec/type = TYPE_FLOAT atype = TYPE_PERCENT]	;-- delegate other vector types to 'add' action
			][
				switch atype [							;-- fetch initial accumulator value
					TYPE_INTEGER [f: as-float integer/get accumulator]
					TYPE_FLOAT   [f: float/get accumulator]
					TYPE_PERCENT [f: percent/get accumulator]
				]

				if f = f [								;-- don't sum if accumulator is NaN
					f: f + sum-pairwise as red-vector! srs	;-- perform summation
				]
				i: as-integer f
				either all [							;-- try to coerce to integer if sources are all integer
					atype    = TYPE_INTEGER
					vec/type = TYPE_INTEGER
				][
					unless f = as-float i [				;-- error, only for consistency with 'add' as an action!
						fire [TO_ERROR(math overflow)]
					]
					result: as red-value! integer/push i
				][
					either atype = TYPE_PERCENT [
						result: as red-value! percent/push f
					][	result: as red-value! float/push f
					]
				]
				return stack/set-last result
			]

			;-- natives/actions require an array of +1/-1 for each refinement, so we prepare it
			nrefs: 0
			unless op? [
				spec: either native? [nat/spec][act/spec]
				nrefs: count-refines spec
			]
			ref-array: null
			if nrefs <> 0 [
				ref-array: system/stack/allocate nrefs		
				p: ref-array  loop nrefs [p/1: -1 p: p + 1]	;-- -1 sets refinement to false
			]

			stack/mark-native name
			stack/push accumulator
			stack/push*

			call: as function! [] code
			args: stack/arguments
			i: 0
			catch RED_THROWN_ERROR [
				while [i < _series/length? srs] [		;-- length is not cached, in case it changes
					i: i + 1
					item: _series/pick srs i null
					copy-cell item stack/arguments + 1
					stack/top: args + 2					;-- clean up after _series/pick, or we get stack overflow
					if nrefs <> 0 [						;-- push prepared '-1's on the native stack
						p: system/stack/top - nrefs
						system/stack/top: p
						copy-memory
							as byte-ptr! p
							as byte-ptr! ref-array
							nrefs * size? integer!
					]
					if native? [push yes]				;-- yes to perform typecheck
					call
					; if nrefs <> 0 [system/stack/top: p + nrefs]
					; copy-cell stack/arguments accumulator
				]
			]
			if nrefs <> 0 [system/stack/free nrefs]
			if system/thrown <> 0 [re-throw]
		]

		TYPE_ROUTINE [
			rout: as red-routine! operator
			unless 2 = routine/get-arity rout [
				fire [TO_ERROR(script invalid-arg) operator]
			]

			stack/mark-native name
			stack/push accumulator
			stack/push*

			i: 0
			while [i < _series/length? srs] [			;-- length is not cached, in case it changes
				i: i + 1
				item: _series/pick srs i null
				stack/top: stack/arguments + 2			;-- clean up after _series/pick, or we get stack overflow
				copy-cell item stack/arguments + 1
				interpreter/exec-routine rout
			]
		]

		TYPE_FUNCTION [
			check-arity

			stack/mark-func name fun/ctx
			stack/push accumulator
			stack/push*

			i: 0
			while [i < _series/length? srs] [			;-- length is not cached, in case it changes
				i: i + 1
				item: _series/pick srs i null
				stack/top: stack/arguments + 2			;-- clean up after _series/pick, or we get stack overflow
				copy-cell item stack/arguments + 1
				interpreter/set-locals fun				;-- have to also set refinements and their arguments
				_function/call fun global-ctx			;@@ should it be called with global-ctx?
			]
		]

		;@@ again, not the best error (should tell the expected type as 'any-function' and arg name)
		default [fire [TO_ERROR(script invalid-op) oper]]
	]

	stack/unwind-last						;-- copies 'accumulator' (old stack/args+0) into new stack/args+0
]

;@@ TODO: /into /part support
;-- another name option: `apply-to-each` (quite verbose, nonstandard)
map*: routine [
	"Evaluate the function over each item in the series"
	;-- Haskell-like argument order
	mapfunc [any-type!] "Any unary function (or a word referring to one)"
	series  [series!] "Each item is used a an argument to the function"		;-- requires #4927 fixed
	return: [block!]
	/local check-arity [subroutine!] empty-path [red-path!] arity [integer!] p [int-ptr!]
		fun [red-function!] name [red-word!] code [integer!]
		nat act rout spec call srs type result i item len native? nrefs ref-array
][
	type: TYPE_OF(series)
	unless ANY_SERIES?(type) [							;@@ typechecks are not working - #4928, have to do manually
		fire [TO_ERROR(script wrong-type) series]		;@@ not the best error message but there's no better one, with arg name
	]

	type: TYPE_OF(mapfunc)
	name: words/_anon
	if type = TYPE_WORD [
		name: as red-word! mapfunc
		mapfunc: word/get name
		type: TYPE_OF(mapfunc)
	]

	fun:  as red-function! mapfunc
	rout: as red-routine!  mapfunc
	check-arity: [
		empty-path: path/make-at as red-path! stack/push* 1
		arity: FFFFh and _function/calc-arity empty-path fun 0
		unless arity = 1 [
			fire [TO_ERROR(script invalid-arg) mapfunc]	;@@ need a better error message, stating arity and arg name
		]
	]

	srs: as red-series! series
	len: _series/length? srs
	result: block/push-only* len

	switch type [
		TYPE_ACTION TYPE_NATIVE [
			check-arity

			native?: type = TYPE_NATIVE
			either native? [
				nat: as red-native! mapfunc
				spec: nat/spec
				code: nat/code
			][
				act: as red-action! mapfunc
				spec: act/spec
				code: act/code
			]
			nrefs: count-refines spec
			ref-array: system/stack/allocate nrefs		;-- natives/actions require an array of +1/-1 for each refinement
			p: ref-array  loop nrefs [p/1: -1 p: p + 1]	;-- -1 sets refinement to false

			stack/mark-native name
			stack/push*

			assert code <> 0
			call: as function! [] code
			i: 0
			catch RED_THROWN_ERROR [
				while [i < _series/length? srs] [		;-- length is not cached, in case it changes
					i: i + 1
					item: _series/pick srs i null
					stack/reset							;-- clean up after _series/pick, or we get stack overflow
					stack/push item

					if nrefs <> 0 [						;-- push prepared '-1's on the native stack
						p: system/stack/top - nrefs
						copy-memory
							as byte-ptr! p
							as byte-ptr! ref-array
							nrefs * size? integer!
						system/stack/top: p				;-- stack offset is fragile and should be set right before the call
					]
					if native? [push yes]				;-- yes to perform typecheck
					call

					block/rs-append result stack/arguments
				]
			]
			system/stack/free nrefs
			if system/thrown <> 0 [re-throw]
		]

		TYPE_ROUTINE [
			unless 1 = routine/get-arity rout [
				fire [TO_ERROR(script invalid-arg) mapfunc]
			]

			stack/mark-native name
			stack/push*

			i: 0
			while [i < _series/length? srs] [			;-- length is not cached, in case it changes
				i: i + 1
				item: _series/pick srs i null
				stack/reset								;-- clean up after _series/pick, or we get stack overflow
				stack/push item
				interpreter/exec-routine rout
				block/rs-append result stack/arguments
			]
		]

		TYPE_FUNCTION [
			check-arity

			stack/mark-func name fun/ctx
			stack/push*

			i: 0
			while [i < _series/length? srs] [			;-- length is not cached, in case it changes
				i: i + 1
				item: _series/pick srs i null
				stack/reset								;-- clean up after _series/pick, or we get stack overflow
				stack/push item
				interpreter/set-locals fun				;-- have to also set refinements and their arguments
				_function/call fun global-ctx			;@@ should it be called with global-ctx?
				block/rs-append result stack/arguments
			]
		]

		;@@ again, not the best error (should tell the expected type as 'any-function except op' and arg name)
		default [fire [TO_ERROR(script invalid-arg) mapfunc]]
	]
	
	stack/unwind
	as red-block! stack/set-last as cell! result
]

map: :map*												;@@ workaround for #4930


;-- this is how FP junkies expect the interface to be (uses Haskell-like name & argument order)
;-- but do we want it beside `accumulate`? I think it only brings confusion
fold: func [
	"Evaluate the operator over each item in the series"
	operator    [word! any-function!] "Operator or any binary function (or a word referring to one)"
	accumulator [any-type!] "Used as first argument to the operator, updated with it's result"
	series      [series!]   "Each item is used as second argument to the operator"
	return:     [any-type!] "Last value of the accumulator (unchanged if series is empty)"
][
	accumulate :accumulator series :operator
]

;-- http://www.multiwingspan.co.uk/haskell.php?page=scanning
;-- this a is very important function in pure functional langs, but..
;--  * do WE need it?
;--  * how do we name it?
;--  * in any case, it does not deserve to be a native IMO
;@@ it's name conflicts with lexer's `scan` func, so we need another name candidate
scan: func [
	"Evaluate the operator over each item in the series"
	;-- Haskell-like argument order
	operator    [any-function!] "Operator or any binary function"
	accumulator [any-type!]     "Used as first argument to the operator, updated with it's result"
	series      [series!]       "Each item is used as second argument to the operator"
	return:     [any-type!]     "All values accumulator has had"
][
	collect [
		keep/only :accumulator
		fun: func [a [any-type!] b [any-type!]]
			either op? :operator [
				[keep/only :a operator :b]
			][	[keep/only operator :a :b]
			]
		accumulate :accumulator :series :fun
	]
]

;-- by far the most common use case of fold/accumulate
;-- see https://github.com/red/red/issues/4372 for some SUM design notes
;-- this version returns none on empty series
;@@ TODO: for vectors, sum could return zero of their element type if we had a reflector for it
sum: func [
	"Returns the sum of all values in the list"
	list [any-list! vector!]
	return: [any-type!] "none if list is empty"
][
	accumulate :list/1 next list :+
]


average: function [
	"Returns the average of all values in the list"
	list [any-list! vector!]
	return: [any-type!] "none if list is empty"
][
	if total: sum list [total / length? list]
]
mean: :average

;@@ TODO: how to define average on tuples so it'll work for all the edge cases?
;@@ e.g. average [1.2.3 100 1000 1.#nan] ? average [1.2.3 100.200.300.400 99.99.99.99.99] ?

minimum-of: func [
	"Returns smallest value in the list"
	list [any-list! vector!]
	return: [any-type!] "none if list is empty"
][
	accumulate :list/1 next list :min
]

maximum-of: func [
	"Returns biggest value in the list"
	list [any-list! vector!]
	return: [any-type!] "none if list is empty"
][
	accumulate :list/1 next list :max
]


{
	Alternate implementations - no `none`, enforces integer type for empty list
	although I think it makes no sense for minimum-of/maximum-of

	sum: func [
		"Returns the sum of all values in the list"
		list [any-list! vector!]
		return: [any-type!] "integer 0 if list is empty"
	][
		if tail? list [return 0]
		accumulate :list/1 next list :+
	]

	average: func [
		"Returns the average of all values in the list"
		list [any-list! vector!]
		return: [any-type!] "integer 0 if list is empty"
	][
		(sum list) / max 1 length? list
	]

	;-- this is more correct: 0/0 = NaN
	average: func [
		"Returns the average of all values in the list"
		list [any-list! vector!]
		return: [any-type!] "NaN if list is empty"
	][
		(sum list) * 1.0 / length? list
	]
}


partition: function [
	"Split given series into two: with items passing the test, and those not"
	series [series!]
	test [function! native! action! routine! word!] "Unary function (or a word referring to one)"
	return: [block!] "[[passing...] [failing...]]"
][
	r: copy/deep [[] []]
	logic: map :test series
	repeat i length? logic [
		; append/only pick r to logic! logic/:i :series/:i
		append/only either logic/:i [r/1][r/2] :series/:i
	]
	r
]

; if true [
comment [
	;-- Alternate implementations:
	;-- 50-70% slower (compiled), because of `do` most likely
	;-- require no temporary buffer
	;-- do not support word argument (worse at error reporting)

	partition2: function [
		"Split given series into two: with items passing the test, and those not"
		series [series!]
		test [function! native! action! routine!] "Unary function"
		return: [block!] "[[passing...] [failing...]]"
	][
		accumulate
			copy/deep [[] []]
			series
			func [acc x [any-type!]] [
				append/only either do [test :x] [acc/1][acc/2] :x		;@@ `do` is required as compiler won't call the function
				acc
			]
	]

	partition3: function [
		"Split given series into two: with items passing the test, and those not"
		series [series!]
		test [function! native! action! routine!] "Unary function"
		return: [block!] "[[passing...] [failing...]]"
	][
		r: copy/deep [[] []]
		repeat i length? series [
			append/only either do [test :series/:i] [r/1][r/2] :series/:i	;@@ `do` is required as compiler won't call the function
		]
		r
	]

	do %/d/devel/red/common/clock.red
	recycle/off
	do [
		list: [] repeat i 100000 [append list i]
		clock/times [partition  list 'odd?] 100
		clock/times [partition2 list :odd?] 100
		clock/times [partition3 list :odd?] 100
	]

	probe partition  [1 2 3 4 5 6 7] :odd?
	probe partition2 [1 2 3 4 5 6 7] :odd?
	probe partition3 [1 2 3 4 5 6 7] 'odd?
]

context [
	square: func [x] [:x * :x]
	
	set 'sum-squares function [ 
		"Returns the sum of squares of all values in the list"
		list [any-list! vector!]
		return: [any-type!] "none if list is empty"
	][
		sum either vector? list [list * list][map :square list]
	]
]

;; stddev of 1 measurement is actually a NaN (undefined), because there isn't enough info to draw conclusions
;; but it's probably simpler to deal with `none`
standard-deviation: function [
	"Returns the statistical corrected standard deviation of a sample"
	list [any-list! vector!]
	return: [any-type!] "none if list length is less than two"
][
	all [
		2 <= n: length? list
		avg: mean list
		sum2: sum-squares either vector? list [
			list - avg
		][
			map func [x][x - avg] list
		]
		sqrt divide sum2 n - 1
	]
]
std-dev: :standard-deviation

probe sum-squares [1 3 10 5 4]
probe std-dev [1 3 10 5 4]
