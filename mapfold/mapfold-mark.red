Red [title: "ACCUMULATE simple benchmark"]

#include %mapfold.red

rou-add: routine [a [float!] b [float!] return: [float!]] [a + b]
do [
	fun-add: func [a [float!] b [float!]] [a + b]		;-- make it fully interpreted

	any [
		attempt [do %/d/devel/red/common/clock.red]
		do https://gitlab.com/hiiamboris/red-mezz-warehouse/-/raw/master/clock.red
	]

	b: append/dup [] 1e-16 n: 1'000'000
	v: make vector! b

	print ["^/Summing" n "floats using internal addition"]
	rv: clock/times [accumulate 0.0 v :add] 1000
	print ["result is" rv "(pairwise/vector)"]

	print ["^/Summing" n "floats using native 'add'"]
	rb: clock/times [accumulate 0.0 b :add] 100
	print ["result is" rb "(block)"]

	print ["^/Summing" n "floats using routine 'add'"]
	rb: clock/times [accumulate 0.0 b :rou-add] 100
	print ["result is" rb "(block)"]

	print ["^/Summing" n "floats using function 'add'"]
	rb: clock/times [accumulate 0.0 b :fun-add] 10
	print ["result is" rb "(block)"]

	; print ["Subtracting" n "floats (no special case)"]
	; rv: clock/times [accumulate 0.0 v :subtract] 100
	; print ["result is" rv "(normal/vector)"]

	clear b clear v
	append/dup b 12345 n			;-- big enough to overflow integer range
	v: make vector! b

	print ["^/Summing" n "integers using native add"]
	rb: clock/times [accumulate 0.0 b :add] 100
	rv: clock/times [accumulate 0.0 v :add] 100
	print ["result is" rb "(block) =" rv "(pairwise/vector)"]
	print ["^/Subtracting" n "ints (no special case)"]
	rv: clock/times [accumulate 0.0 v :subtract] 100
	print ["result is" rv "(normal/vector)"]
]

