# FOR/LOOP/REPEAT imitations


- `for i to step`
```
	looping?: pick [[i <= _to][_to <= i]] positive? step: sign? delta
	while looping? [
		insert p [set-pwm pin i]
		wait delay
		i: i + step
	]
```

---
- I always thought we need a special 2D loop for pairs, but maybe `for` will do
- `for pos args/start args/end [...]`
```
    while [pos/y <= args/end/y] [
        while [pos/x <= args/end/x] [
            make-reference table-state pos cell 
            pos: pos + 1x0
        ] 
        pos/x: args/start/x 
        pos: pos + 0x1
    ] 
```

---
- mandelbrot
- `repeat iy height [repeat ix width [..]]`
- but should be a 2D loop over image
```
	while [iy <= height] [
		ix: 0
		while [ix <= width] [
			x: xmin + ((xmax - xmin) * ix / width)
			y: ymin + ((ymax - ymin) * iy / height)

			i: switch engine [
				rebol [mandelbrot-iter x y iterations]
				vm [mandelbrot-vm x y iterations]
				exe [mandelbrot-exe x y iterations]
			]
			
			if i > 255 [i: to integer! 255 * i / iterations]

			poke imgpix as-pair ix iy palette/(i)

			ix: ix + 1
		]
		if even? iy [wait 0.01]		;-- allow GUI msgs to be processed
		if stopped [exit] ; avoid "recursion"
		if empty? system/view/screen-face/pane [exit] ; stop calcs when window is closed
		iy: iy + 1
	]
```

---
- `for i 0 40000h [...]`
```
    while [i < length] [
        ...
        i: i + 262144
    ]
```

---
- `for start start finish [..]`
```
	while [start <= finish] [
		remove-key start so-db
		++ start
	]
```

---
- same
```
	while [start <= finish] [
		if not find db start [
			append db start
		]
		++ start
	]
```

---
- `loop max-iter - i [...]`
```
	while [i < max-iter] [
		zr2: zr * zr
		zi2: zi * zi
		zrzi: zr * zi
		zr: zr2 - zi2 + cr
		zi: zrzi + zrzi + ci
		if zr2 + zi2 > 4.0 [break]

		i: i + 1
	]
```
