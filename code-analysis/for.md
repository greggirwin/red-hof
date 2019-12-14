# FOR

A rare guest, but totally justified on a chess board.
Other games or applications dealing with a fixed field size will benefit from having FOR.

## Examples

```
    for n 2 58 8 [
        if  all [ pawn and game-board/(n) = pawn
                  black and game-board/(n) <> black] [
            game-board/(n): game-board/(n) or 2
            white-board/(n): game-board/(n)
        ]
    ]
```

---
```
    for n 7 63 8 [
        if  all [ pawn and game-board/(n) = pawn
                  black and game-board/(n) = black] [
            game-board/(n): game-board/(n) or 2
            black-board/(n): game-board/(n)
        ]
    ]
```

---
- should be foreach or repeat
```
    for i 1 64 1 [
        if  0 <> game-board/(i) [
        	...
        ]
    ]
```

---
- should be repeat
```
	for n 1 64 1 [
		thispiece: 0
		if  all [white-to-move 
				 0 < white-board/(n)] [
			thispiece: white-board/(n)
		]    
		if  all [black-to-move 
				 0 < black-board/(n)] [
			thispiece: black-board/(n)
		]    
		if thispiece > 0 [
			switch thispiece [
				  4   5   6   7 [add-pawn-moves thispiece n]   
				128 129 130 131 [add-king-moves thispiece n]
				 32  33  34  35 [add-rook-moves thispiece n]   
				 16  17  18  19 [add-bisshop-moves thispiece n]   
				  8   9  10  11 [add-knight-moves thispiece n]   
				 64  65  66  67 [add-rook-moves thispiece n
								 add-bisshop-moves thispiece n]
			]
		]
	]
```

---
```
    for n 4 60 8 [
        if  all [pawn and game-board/(n) = pawn
                 black and game-board/(n) <> black
                 inipos and game-board/(n) = inipos] [
            white-board/(n): game-board/(n): game-board/(n) and 253
        ]
    ]
```

---
```
    for n 5 61 8 [
        if  all [pawn and game-board/(n) = pawn
                 black and game-board/(n) = black
                 inipos and game-board/(n) = inipos] [
            black-board/(n): game-board/(n): game-board/(n) and 253
        ]
    ]
```

---
```
    for n 8 1 -1 [
        for m 1 8 1 [
            f: m - 1 * 8
            prin "^(tab)" prin game-board/(f + n)
        ]
        print ""
    ]
```


