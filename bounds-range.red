Red []

; limits
bounds: func [
	"Returns upper and lower bounds as a block of two values"
	[catch throw]
	input [block! number! char! money! time! tuple!]  ; a.k.a. spec
		"A single value is the upper bound; a tuple defines both bounds; a block is a dialected value."
	/local a b val val= a-val= b-val= ab-val= keywords
] [
	keywords: [now time today date tomorrow yesterday from up back to .. ... - --]
	val=:    [
		set val [number! | char! | money! | time! | date!]
		| 'now (val: now)
		| 'time (val: now/time)
		| ['today | 'date] (val: now/date)
		| 'tomorrow  (val: now/date + 1)
		| 'yesterday (val: now/date - 1)
		;| set word word! (val: get word) ; watch out, we're looking up words now
	]
	a-val=:  ['from val= (a: val)]
	; Will allowing a dash/minus lead to confusion?
	b-val=:  [
		[opt ['up | 'back] 'to | '.. | '... | '- | '--]
		[val= (b: val) | end (throw make error! "An ending boundary value must be set")]
	]
	ab-val=: [val= (either a [b: val] [a: val])]
	switch/default type?/word input [
		block! [
			input: reduce/only input keywords
			if not parse input [some [a-val= | b-val= | ab-val=]] [
				throw make error! "Boundary values must be one of: number! char! money! time! date!"
			]
			a: any [a  make b either date? b [now] [1]]
			;b: to a b
		]
		tuple! [
			if not all [3 = length? input  0 = input/2] [
				throw make error! "tuple! range values must be of the form m..n"
			]
			a: input/1  b: input/3
		]
	] [a: make input 1   b: input]
	reduce [a b]
]

range: func [
	"Returns a block containing a range of values"
	[catch]
	bound [block! number! char! money! time! tuple!]
		"A single value is the upper bound; a tuple defines both bounds; a block is a dialected value."
	   ;{IMPORTANT: Don't use an upper char! bound of #"ÿ" (255)--for now
	   ; FOR can't handle it and it causes an endless loop.}
	/skip step
	/local start end val
	  ; start/end instead of low/high because they may range high to low.
] [
	if bound = #"ÿ" [throw make error! join [script invalid-arg] :bound]
	set [start end] bounds bound
	; If from > b, and they specify a negative step, we don't catch that
	; and do anything smart, they just get an empty block back.
	step: any [step 1] ;make a either date? a [now] [1]
	if end < start [step: negate abs step]
	collect [for v start end step [keep :v]]
]

; comment {
;     range 1..255
;     range 255..1
;     range 10
;     range [3 10]
;     range [4 to 11]
;     range [6 .. 12]
;     range [8 - 14]
;     range [to 28 from 14]
;     range compose [.. (now + 4)]
;     range compose [(now/time) - (now/time + 1:0:0)]
;     range/skip compose [(now/time) - (now/time + 1:0:0)] 0:1
;     range compose [(now) - (now + 10)]
;     range/skip compose [(now) - (now + 10)] 3
; }


range: function [
	"Returns a block containing a range of values"
	spec [block! number! char! money! time! tuple!]
		"A single value is the upper bound; a tuple defines both bounds; a block is a dialected value."
	/skip step
][
	default 'step 1
	set [start end] bounds spec
	if end < start [step: negate abs step]
	collect [for v start end step [keep :v]]
]

;-------------------------------------------------------------------------------


thru': func [start end body][
	for v start end [do body]]
]
thru: make op! :thru'