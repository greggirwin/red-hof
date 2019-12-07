# GEN-EACH

Here's one more, maybe small, HOF-related problem I'd like to outline.

While I was working with vectors once, I grew bored of repetition these incur.
The task was as simple as to smoothly render mouse strokes, using pointer velocity as a measure of line thickness.
But that meant every millisecond of delay in mouse event processing affected the timestamp and so - the result.

There were code patterns like this (about 10 of them):
```
    extract/into stroke period xs: make vector! [float! 64 0] 
    take/last insert xs-: copy xs xs/1 
    append xs+: copy next xs last xs 

    extract/into next stroke period ys: make vector! [float! 64 0] 
    take/last insert ys-: copy ys ys/1 
    append ys+: copy next ys last ys 

    extract/into at stroke 3 period ts: make vector! [float! 64 0] 
    take/last insert ts-: copy ts ts/1 
    append ts+: copy next ts last ts 
```
Naturally it pains the eye, so I wrote a macro that would save me.
I started writing generator patterns:
```
	#gen-each [s s- s+ i] [xs xs- xs+ 1  ys ys- ys+ 2  ts ts- ts+ 3] [
		extract/into  at stroke i  period  s: make vector! [float! 64 0]
		take/last insert s-: copy s s/1
		append s+: copy next s last s
	]
```
This macro would expand the contents into the original pattern. Much cleaner!
In the above example, `s` would become `xs`, `ys`, `ts`.

Where I didn't have numbers, only words to substitute, I shortened it even further:
`#gen-each [xs xs- xs+] [ys ys- ys+  ts ts- ts+] [..]` did the job.

And it worked for bigger patterns. It still made sense to write:
```
	add2c: func [x y] [
		#gen-each [x cx][y cy] [cx: cx * cn + x / (1 + cn)]
		0 < cn: cn + 1
	]
```
or even
```
	#gen-each [i1][i2] [i1: skip data' i1 - 1 * p]
```

But with shorter patterns the macro became longer and more messy than the original:
```
	#gen-each [dx1 dx2 xs xs- xs+][dy1 dy2 ys ys- ys+] [
		dx1: xs - xs-  dx2: xs+ - xs
	]
```
is certainly worse than:
```
		dx1: xs - xs-  dx2: xs+ - xs
		dy1: ys - ys-  dy2: ys+ - ys
```

And I'm not exactly happy with it or the trick I had to resort to, to shorten it in the absence of numbers.

But what choice is there?
- I can't use `foreach s [xs ys ts]` because it will turn into a get/set hell. Totally unreadable. I tried.
- I can't go higher level because even in this implementation, leveraging R/S as much as possible, it was still not performing in real-time.

I'm still looking for a better solution. I didn't meet any other examples like that in the code sample I collected.
Maybe because vectors were only available in R3 and at some later stage. Maybe because Rebol wasn't suited for even simplest number crunching.
But Red aims to be. I think it can become good at this. So, this problem will reappear over and over.

Isometric space leads to X, Y (and maybe Z) coordinates being processed using the same algorithms. That leads to doubling or tripling the code.
Time coordinate can have it's own pipeline, at times similar, at times not.

