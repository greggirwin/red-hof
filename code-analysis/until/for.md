# FOR/LOOP/REPEAT imitations

---
- `for maximum maximum 1 -1 [...]`
- `repeat i maximum [... using maximum - i + 1 ...]`
```
	until [
		data: to string! decompress read/binary rejoin [dir %access.log. maximum %.gz]
		append result parse-log data
		maximum: maximum - 1
		1 = maximum
	]
```


---
- `repeat index len [...]`
```
	index: 1
	until [
		... cycle?: ...
		index: index + 1
		any [
			cycle?
			index > len
		]
	]
```

