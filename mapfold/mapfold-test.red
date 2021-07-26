Red [title: "MAP/ACCUMULATE manual tests"]

#include %mapfold.red

{
==== BINARY builtin functions that's possible to use with ACCUMULATE: ====

to while insert if set AT FIND PICK SKIP SELECT change append MOVE SWAP
checksum ADD SUBTRACT divide MULTIPLY rename write MAKE reflect POWER
REMAINDER AND~ OR~ XOR~ as unless loop forall func function has
switch equal? not-equal? strict-equal? lesser? greater?
lesser-or-equal? greater-or-equal? same? BIND in parse union
INTERSECT DIFFERENCE exclude MAX MIN shift arctangent2 as-pair as-money
extend new-line set-env + < <> % << or = also ** * / // - > MOD <= save
set-quiet set-slot-quiet =? >> offset? >= repend routine find-flag? draw
foreach-face pad alter extract ellipsize-at get-scroller caret-to-offset
offset-to-caret shift-right shift-left shift-logical count-chars
parse-trace MODULO split atan2 == >>> AND XOR is react? overlap? distance?
offset-to-char metrics? red-complete-input

==== those also defined in mezz-warehouse: ====

count with default once maybe anonymize trace pcatch fcatch apply keep-type
composite bind-only upscale by parent-of? face-to-window window-to-face
face-to-screen screen-to-face trace-deep

==== UNARY builtin functions, that can be used with MAP: ====

not remove collect ANY copy quote case back head head? index? LENGTH? next
tail tail? clear random reverse sort TAKE trim uppercase lowercase try catch
browse open create close delete query read update scan load comment throw math
return form mold ALL absolute negate round even? odd? complement last open?
source until forever does DO expand reduce compose GET print prin type? show
context object unique complement? dehex enhex negative? positive? to-hex SINE
COSINE TANGENT ARCSINE ARCCOSINE ARCTANGENT NaN? zero? LOG-2 LOG-10 LOG-e EXP
SQUARE-ROOT construct value? debase enbase to-local-file wait unset new-line?
context? get-env sign? CALL size? compress decompress transcode dir
set-current-dir make-dir view error? quit-return series? map? none? any-block?
any-list? binary? any-string? block? bitset? tag? trap word? url? string?
suffix? SECOND file? object? body-of FIRST third clean-path dir? exists?
normalize-dir empty? dirize CREATE-DIR attempt charset expand-directives
split-path change-dir path-thru load-thru SUM any-word? words-of TO-JSON
LOAD-JSON to-csv load-csv keys-of rejoin ASSERT reactor set-word?
STOP-REACTOR REACT function? spec-of unset? get-word? paren? integer?
any-function? path? op? to-paren TO-RED-FILE class-of SIZE-TEXT hex-to-rgb
tuple? make-face debug-info? handle? link-tabs-to-parent update-font-faces
do-safe event? pair? issue? typeset? datatype? layout image? rtd-layout
TO-LOGIC TO-SET-WORD TO-BLOCK center-face dump-face char? any-object? a-an
help-string routine? to-UTC-date write-clipboard TO-WORD float? ask list-dir
TO-INTEGER probe action? native? refinement? logic? TO-STRING write-stdout
alert ?? fourth fifth values-of email? get-path? hash? lit-path? lit-word?
percent? set-path? time? date? money? ref? vector? any-path? number? immediate?
scalar? all-word? to-bitset to-binary to-char to-email to-file TO-FLOAT
to-get-path to-get-word to-hash to-issue to-lit-path to-lit-word to-map to-none
TO-PAIR to-path to-percent to-refinement to-set-path to-tag to-time to-typeset
to-tuple to-unset to-url TO-IMAGE to-date to-money to-ref eval-set-path
flip-exe-flag do-file exists-thru? read-thru do-thru COS SIN TAN ACOS ASIN ATAN
SQRT to-local-date transcode-trace AVERAGE last? DT single? deep-reactor
register-scheme decode-url encode-url face? insert-event-func remove-event-func
set-focus help ? fetch-help ls ll cd

==== also those defined in mezz-warehouse: ====

import export minmax-of minimum-of maximum-of prettify reshape
collect-set-words catch-a-break catch-continue catch-return pixels-to-units
contrast-with explore units-to-pixels window-of CLOCK clock-each
format-readable exponent-of show-trace stepwise EXPECT show-deep-trace DETAB
ENTAB do-atomic is-face?
}


last-result: none
test: func [expr] [
	prin pad mold/only expr 70
	set/any 'last-result do expr
	print [" =>" mold/part :last-result 100]
	:last-result
]
===: func [expected] [
	unless :last-result == :expected [
		print ["TEST FAILED! Expected:" :expected]
	]
]


;--            
;-- ACCUMULATE 
;--            


test [type? try [accumulate "abc" [#[none] #[none]] 'to]]
=== error!

test [accumulate 1    make vector! [2% 3% 4%] :add]
=== 1.09

test [accumulate 100% make vector! [2% 3% 4% 5%] :add]
=== 114%

test [accumulate 100% make vector! [2% 3% 4%] :add]
=== 109%

test [accumulate 100% make vector! [2% 3%] :add]
=== 105%

test [accumulate 100% make vector! [2%] :add]
=== 102%


;-- suppose we have an array of word lengths; we can skip some of them without summing
test [accumulate "one two three four" [4 4 6] :skip]
=== "four"
;-- or we can do similar thing using find/tail
test [accumulate "one two three four" "   " func [s x] [find/tail s :x]]
=== "four"

;-- we can deep-pick/deep-select fast
test [accumulate [one [two [three [four] x] y] z] [2 2 2] :pick]
=== [four]
test [accumulate [one [two [three [four] x] y] z] [one two three] :select]
=== [four]

;-- we could swap multiple items at once ("xyz" will contain "abc").. if only swap advanced it's input :)
; probe accumulate "abcdef" ["x" "y" "z"] :swap
test [head accumulate "abcdef" ["x" "y" "z"] func [s1 s2] [swap s1 s2 next s1]]
=== "xyzdef"

;-- we can deeply translate coordinates in a face tree, like what face-to-screen and screen-to-face do
;-- problem is getting those coordinates from faces ;)
test [accumulate 101x201 [20x20 0x150 80x30] :subtract]
=== 1x1

;-- factorial can be accumulate over a range (when we'll have ranges)
test [accumulate 1 [1 2 3 4 5] :multiply]
=== 120

;-- extend object with multiple extensions; though more GC load
test [accumulate object! [[a: 1] [b: 1] [b: 2 c: 3]] :make]
=== object [a: 1 b: 2 c: 3]

;-- incremental xoring, or incremental hash computation
test [accumulate 0 [1 10h 100h 1000h] :xor]
=== 1111h

;-- 'with' can be rewritten faster:
; accumulate 'target [ctx-word1 ctx-word2 ...] :bind




;--            
;--  MAP & co  
;--            


test [map :length? ["abc" "de" "f"]]
=== [3 2 1]

fsine: func [x /radians] [either radians [sine/radians x][sine x]]
test [map :sine    [90 180 -90]]
=== [1.0 0.0 -1.0]

test [map :fsine   [90 180 -90]]
=== [1.0 0.0 -1.0]

test [map :cosine  [90 180 -90]]
=== [0.0 -1.0 0.0]


;-- any [all [expr..] all [expr..] ...] pattern can be simplified:
;--                  failed all   failed all  succeeded all
test [any map :all [ [yes yes no] [no yes]    [yes] ]]
=== true

;-- check if all list items are any-words:
test [all map :any-word? [x 'y :z w:]]
=== true
;-- but then it's faster to fold the results without 'all':
test [accumulate true (map :any-word? [x 'y :z w:]) :and]
=== true
;-- `accumulate` then can be used as non-evaluating `all` or `any`...
test [accumulate true  [#[true] #[true] #[true]] :and]
=== true
test [accumulate false [#[false] #[true] #[false]] :or]
=== true


;-- and we can also make a non-evaluating `reduce`:
test [x: 1 y: 2 z: 3  map :get [x y z]]
=== [1 2 3]

;-- we can take first data column:
test [rejoin map :take ["123" "456" "789"]]
=== "147"
;-- or any other:
test [rejoin map :take map :next ["123" "456" "789"]]
=== "258"

;-- having a set of lines of text, we can calc the whole text size (including newlines), fast:
test [lines: ["line1" "line2" "line3"]  (length? lines) + sum map :length? lines]
=== 3 + 15



;-- map can be used as faster `foreach x xs [f x]`, where it matters
test [map :dt [[1 + 2] [2 + 3 * 4]]]

;-- multi-line unit tests done with just assert+map:
; test [all map :assert [
; 	[1 = 1]
; 	[2 + 3 = 5]
; ]]
; === yes




;--            
;--    SUM     
;--            


test [sum reduce [make vector! [1 1 1] make vector! [2 2 2] make vector! [3 3 3] make vector! [4 4 4]]]
=== make vector! [10 10 10]

test [sum reduce [make vector! [1 1 1] 2 3 4]]
=== make vector! [10 10 10]

test [sum [1x1 2x2 3 4.0]]
=== 10x10

test [sum [1/1/1970 1:0 2:0 3:0]]
=== 1-Jan-1970/6:00:00

test [sum [1.2.3 4.5.6]]
=== 5.7.9




;--            
;--    SCAN    
;--            


test [scan :add 0      [1 2 3 4 5 6]]
=== [0 1 3 6 10 15 21]

test [scan :+   0      [1 2 3 4 5 6]]
=== [0 1 3 6 10 15 21]

test [scan :add 1 next [1 2 3 4 5 6]]
=== [  1 3 6 10 15 21]

; test [scan :+ now/time next [0 1:0]]

; test [accumulate "abc" [#[none] #[none]] :pick]

; probe fold ["abc"] :+ #"b"


; probe accumulate 1 make vector! [2] :add
; probe accumulate 1 make vector! [2 3] :add
; probe accumulate 1 make vector! [2 3 4] :add
; probe accumulate 1 make vector! [2 3 4 5] :add
; probe accumulate 1 make vector! [2 3 4 5 6] :add
; probe accumulate 1 make vector! [2 3 4 5 6 7] :add
; probe accumulate 1 make vector! [2 3 4 5 6 7 8] :add
; probe fold :+ 1 make vector! [2 3 4]
; probe fold :r 1 make vector! [2 3 4]
; probe fold func [a b] [probe reduce [a b]] 1 make vector! [2 3 4]

; probe fold "^A^B^C" :+ #"^@"
; probe r "abc" #"b"
; probe r "abc" #"b"
; probe r "abc" #"b"
