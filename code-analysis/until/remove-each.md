# REMOVE-EACH imitations


---
- `remove-each/reverse [x y] stack [... yes]`
```
	until [
		stack: skip stack -2
		append retact stack/2
		if same? up-to stack/1 [
			state: up-to
			do retact
			state-stack: skip clear stack -2
			return true
		]
		head? stack
	]
```
