Red []


;-------------------------------------------------------------------------------
;-- This section was my first thought at how to approach things. The funcs
;   need to maintain state, but I wasn't sure I wanted to use objects.

; Aggregators are functions that allows you to compute certain results
; over unbounded series. They generally take one argument, and maintain
; state with each successive call. In the future we'll have real closures
; in REBOL.
; Added the /query refinement, but not sure I like using RETURN for it.
; Maybe an "if not query [change-state]" approach is better. Either way
; it's a bit ugly for funcs that take values because you still have to
; pass a none value even when using /query.

; An advantage to functions is that their inner state is protected, at
; the expense of having to use something like /query to get the result.

aggregation-ctx: context [

	set 'make-count-aggregator does [
		func [/query /local state] [
			state: [0]
			if query [return state/1]
			state/1: state/1 + 1
			state/1
		]
	]

	set 'make-sum-aggregator does [
		func [value /query /local state] [
			state: [0.0]
			if query [return state/1]
			state/1: state/1 + value
			state/1
		]
	]

	; Should this have an initial value override?
	set 'make-avg-aggregator does [
		func [value /query /local state] [
			state: [count 0 sum 0.0]
			if query [return divide state/sum state/count]
			state/count: state/count + 1
			state/sum: state/sum + value
			divide state/sum state/count
		]
	]

	;!! UNTESTED
	; Should this have an initial value override?
	set 'make-moving-avg-aggregator func [
		size [integer!]  "The subset/window size"
	][
		func [value /query /local state] [
			state: reduce [count size  sum 0.0  data array/initial size 0.0]
			if query [return divide state/sum state/count]
			state/sum: state/sum - state/data/1 + value
			state/data/1: value
			state/data: next state/data
			if tail? state/data [state/data: head state/data]
			divide state/sum state/count
		]
	]


	set 'make-min-aggregator func [
		/init init-val [number! time!] "Set the initial minimum value"
	][
		func [value /query /local state] compose/deep [
			state: [(any [init-val 0.0])] 
			if query [return state/1]
			;if init  [state/1: (init-val)]
			; Which is nicer here, path notation, or CHANGE? I like CHANGE.
			;   if value < state/1 [state/1: value]
			; Or always changing?
			;   change state min state/1 value
			if value < state/1 [change state value]
			state/1
		]
	]

	set 'make-max-aggregator func [
		/init init-val [number! time!]  "Set the initial maximum value"
	][
		func [value /query /local state] compose/deep [
			state: [(any [init-val 0.0])] 
			if query [return state/1]
			if value > state/1 [change state value]
			state/1
		]
	]

	; Need to think about how this could be generalized.
	; Power of 2 distribution quanitzer.
	set 'make-quantize-aggregator func [/local limits] [
		limits: []
		repeat i 48 [append limits 2 ** i]
		func [value /query /local state n] [
			state: [ ; 48 slots = a range up to 2 ** 48 - 1 (256 TB).
				0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
				0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
				0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
			]
			if query [return state]
			n: repeat i length? state [
				if value < pick limits i [break/return i]
			]
			state/:n: state/:n + 1
			state
		]
	]

	; scalar expression, lower bound, upper bound, step value
	;
	; A linear frequency distribution, sized by the specified range, of
	; the values of the specified expressions. Increments the value in
	; the highest bucket that is less than the specified expression.
	set 'make-linear-quantize-aggregator func [
		lbound ubound step /local limits
	][
		; Do we want to do this, or just use FOR or WHILE/UNTIL directly?
		; This allocates space, which would be bad for large ranges, but
		; linear quantize shouldn't be used that way anyway, right?
		limits: range/skip reduce [lbound ubound] step
		func [value /query /local state n lim] compose/deep [
			lim: [(copy limits)]
			state: [(head insert/dup copy [] 0 length? limits)]
			if query [return state]
			n: repeat i length? state [
				if value < pick lim i [break/return i]
			]
			state/:n: state/:n + 1
			state
		]
	]
	
	; normalize
	; denormalize
	
	; clear
	; trunc

] ; end aggregation-ctx


;-------------------------------------------------------------------------------
;-- What if we use objects instead of funcs?
;
;   Call UPDATE to feed new data into an aggregaor
;   Read RESULT to get the current aggregate value

aggregator-proto: context [
	tags:  'aggregator  ; Could call it 'type, but want to standardize on 'tags for general use
	state:  none        ; Replace this with your aggregator state data structure
	update: does [print "TBD: Replace this func with aggregator update logic"]
	result: does [state]
	; TBD: Look at protecting 'result
]

aggregator?: func [object [object!]] [
	attempt [
		any [
			object/tags = 'aggregator
			all [series? object/tags  find object/tags 'aggregator]
			all [in object 'update  in object 'result]   ; object has required words
		]
	]
]

; Should we set result to: divide state/sum state/count ?
; And should we always set result on updates, for all aggregator types?
; Setting it on updates doesn't guarantee that somebody won't change it
; and produce bogus results. We need to protect it for that. And calc'ing
; the result on every update means more overhead if they only read it
; occasionally. But, what it also gives us is the result as a return
; value for updates.
set 'make-avg-aggregator does [
	make aggregator-proto [
		state: copy [count 0 sum 0.0]
		result: 0   ; result: does [divide state/sum state/count]
		update: func [value] [
			state/count: state/count + 1
			state/sum: state/sum + value
			result: divide state/sum state/count
		]
	]
]

set 'make-count-aggregator does [
	make aggregator-proto [
		state: 0
		update: does [state: state + 1]
	]
]

; scalar expression, lower bound, upper bound, step value
;
; A linear frequency distribution, sized by the specified range, of
; the values of the specified expressions. Increments the value in
; the highest bucket that is less than the specified expression.
set 'make-linear-quantize-aggregator func [
	lbound ubound step /local limits
][
	make aggregator-proto [
		; Do we want to do this, or just use FOR or WHILE/UNTIL directly?
		; This allocates space, which would be bad for large ranges, but
		; linear quantize shouldn't be used that way anyway, right?
		limits: range/skip reduce [lbound ubound] step
		state:  array/initial length? limits 0
		update: func [value /local n] [
			n: repeat i length? state [
				if value < pick limits i [break/return i]
			]
			state/:n: state/:n + 1
			state
		]
	]
]

set 'make-max-aggregator func [/initial start-val] [
	make aggregator-proto [
		state: any [start-val 0]
		update: func [value] [if value > state [state: value]]
	]
]

set 'make-min-aggregator func [/initial start-val] [
	make aggregator-proto [
		state: any [start-val 0]
		update: func [value] [if value < state [state: value]]
	]
]

set 'make-min-max-aggregator func [
	/initial start-val [block!] "Block containing starting min and max values"
] [
	make aggregator-proto [
		state: copy any [start-val [0 0]]
		update: func [value] [
			if value < state/1 [state/1: value]
			if value > state/2 [state/2: value]
			state
		]
	]
]

;!! UNTESTED
; Note that this does not account for reading results before UPDATE has
; been called SIZE times.
; Should this have an initial value override?
set 'make-moving-avg-aggregator func [
	size [integer!]  "The subset/window size"
][
	make aggregator-proto [
		state: reduce [count size  sum 0.0  data array/initial size 0.0]
		result: 0   ; result: does [divide state/sum state/count]
		update: func [value] [
			; Our count is always our subset size
			state/count: size
			; We could just keep a single last-val, rather than using
			; state/data/1 here. The reason I am keeping a block of
			; values for state/data is for debugging and analysis.
			state/sum: state/sum - state/data/1 + value
			; Replace the oldest value, which is at the current first series
			; position. Then step the series forward one. Reset to the head
			; when we reach the tail. It doesn't matter what order they come
			; in, because we can use HEAD during analysis to see where our
			; starting point is in the data block, knowing that we wrap.
			state/data/1: value
			state/data: next state/data
			if tail? state/data [state/data: head state/data]
			
			result: divide state/sum state/count
		]
	]
]

set 'make-product-aggregator does [
	make aggregator-proto [
		state: 1.0
		update: func [value] [state: state * value]
	]
]

; Power of 2 distribution quanitzer.
; Should, this be generalized beyond powers of 2?
set 'make-quantize-aggregator has [size] [
	make aggregator-proto [
		size:   48  ; 48 slots = a range up to 2 ** 48 - 1 (256 TB).
		limits: array size
		state:  array/initial size 0
		repeat i length? limits [limits/:i: 2 ** i]
		update: func [value /local n] [
			n: repeat i length? state [
				if value < pick limits i [break/return i]
			]
			state/:n: state/:n + 1
			state
		]
	]
]

set 'make-sum-aggregator does [
	make aggregator-proto [
		state: 0.0
		update: func [value] [state: state + value]
	]
]



;-------------------------------------------------------------------------------
;-- Aggregate funcs should be able to work on plain data blocks as well as
;   aggregator objects.


aggr-avg: func [
	input [any-block! object!] "Block of values to sum or aggregator object"
][
	either object? input [
		if aggregator? object [object/result]
	] [
		if empty? input [return none]
		divide  aggr-sum input  length? input
	]
]

aggr-product: func [
	input [any-block! object!] "Block of values to sum or aggregator object"
	/local result
][
	either object? input [
		if aggregator? object [object/result]
	][
		result: any [
			attempt [make pick block 1 1]
			attempt [add (0 * pick block 1) 1]
			1
		]
		foreach value block [result: result * value]
		result
	]
]

aggr-sum: func [
	input [any-block! object!] "Block of values to sum or aggregator object"
	/local result
][
	either object? input [
		if aggregator? object [object/result]
	] [
		result: any [
			attempt [make pick block 1 0]
			attempt [0 * pick block 1]
			0
		]
		foreach value reduce block [result: result + value]
		result
	]
]

;-------------------------------------------------------------------------------

; Reactive Aggregators

; Use deep reactors, because `state` will often be a block.
; Using `is` for the result MUST be done in new objects, not inherited from
; the aggregator-proto.

aggregator-proto: make deep-reactor! [
	tags:  'aggregator  ; Could call it 'type, but want to standardize on 'tags for general use
	state:  none        ; Replace this with your aggregator state data structure
	update: does [print "TBD: Replace this func with aggregator update logic"]
	result: does [print "TBD: Replace this func with `is` reactor body"]
]

aggregator?: func [object [object!]] [
	attempt [
		any [
			object/tags = 'aggregator
			all [series? object/tags  find object/tags 'aggregator]
			all [in object 'update  in object 'result]   ; object has required words
		]
	]
]

; Calc'ing the result on every update means more overhead if they only read it
; occasionally.
set 'make-avg-aggregator does [
	make aggregator-proto [
		state: copy [count 0 sum 0.0]
		result: is [divide state/sum state/count]
		update: func [value] [
			state/count: state/count + 1
			state/sum: state/sum + value
		]
	]
]
aa: make-avg-aggregator []
aa/update 1
aa/update 100
aa/update 1000
aa/result

set 'make-count-aggregator does [
	make aggregator-proto [
		state: 0
		result: is [state]
		update: does [state: state + 1]
	]
]
ca: make-count-aggregator
ca/update
ca/update
ca/update
ca/result

set 'make-sum-aggregator does [
	make aggregator-proto [
		state: 0.0
		result: is [state]
		update: func [value] [state: state + value]
	]
]
sa: make-sum-aggregator []
sa/update 1
sa/update 100
sa/update 1000
sa/result

;-------------------------------------------------------------------------------

; What if we make a multi-aggregator. That is, one that stores multiple
; aggregate values that can later be queried. The inner funcs could 
; even be user defined. It just means storing more fields, avoiding name
; collisions, and defining an spec for user funcs.
; This is, of course, very wasteful for count aggregates. And the more
; aggregates you and, and the more complex they are, the more you waste
; in the simple cases. So you could make the constructor smart, using
; tags as keys for what to include.

make-multi-aggregator: func [tags] [
	make aggregator-proto compose/deep [
		tags:  ['aggregator (tags)]  ; Could call it 'type, but want to standardize on 'tags for general use
		state: [
			count:	0
			min:	0
			max:	0
			sum:	0
			avg:	0
		]
		update: func [value [number!]][
			state/count: state/count + 1
			state/min: min state/min value 
			state/max: max state/max value
			state/sum: state/sum + value
			state/avg: state/sum / state/count
			
		]
		result: does [copy state]
	]
]

; https://github.com/graphite-project/carbon/blob/master/lib/carbon/aggregator/rules.py
;def percentile(factor):
;  def func(values):
;    if values:
;      values = sorted(values)
;      rank = factor * (len(values) - 1)
;      rank_left = int(floor(rank))			round/floor
;      rank_right = int(ceil(rank))			round/ceiling
;
;      if rank_left == rank_right:
;        return values[rank_left]
;      else:
;        return values[rank_left] * (rank_right - rank) + values[rank_right] * (rank - rank_left)
;
;  return func
;
;
;AGGREGATION_METHODS = {
;  'sum': sum,
;  'avg': avg,
;  'min': min,
;  'max': max,
;  'p50': percentile(0.50),
;  'p75': percentile(0.75),
;  'p80': percentile(0.80),
;  'p90': percentile(0.90),
;  'p95': percentile(0.95),
;  'p99': percentile(0.99),
;  'p999': percentile(0.999),
;  'count': count,
;}

