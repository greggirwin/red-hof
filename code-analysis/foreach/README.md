# FOREACH

This one is really **numerous**, and for a reason.
Compared to WHILE and UNTIL loops, whose logic is often very tricky, FOREACH is absolutely **transparent**.
I usually takes me only a momentary glance to see the meaning of the whole FOREACH construct.
This is an outstanding quality.

Foreach loops were found to be **distributed** as follows:
- 44% were true `foreach`s
- 48% were accumulators (89% of those were `map-each`s, the rest were usually a summation or min/max)
- 8% were lookups (filters that return the first match, or a position of it, or raise an error)

I categorized FOREACH as:
- **Filtered** if before doing something with the data it applied a `if` block on it.
- **A true filter** if after filtering it did no modification to the original data.
These are the cases that we should try to approach with our `filter`/`remove-each`/`sift` designs.
A playground that can answer what's best *in practice*.

Note that *true filters* are also a part of *filtered* loops. Any filtered loop can expressed as an action on the result of a true filter.

---
I have also put some loops into 2 **"bulk"** subcategories:
- **bulk application** (e.g. `foreach message ret [strip-message message]`)
- **bulk assignment** (e.g. `foreach shape shapes/pane [shape/draw/line-width: lw]`)

These are not in any way different from other foreachs, but they are one-liners that can probably be expressed more clearly:
as `strip-message ret/*` or `shapes/pane/*/draw/line-width: lw`.
I haven't invented a syntax for that, or even convinced myself there's a win in that. It's just an idea, whatever it's worth.


## More detailed overview of `foreach`s:

Flavor/Loop | General foreach | Bulk foreach | Bulk + General | Map-each | Other accumulators | All accumulators | Lookups
---         | ---             | ---          | ---            | ---      | ---                | ---              | ---
Normal      | 25%             | 10%          | 36%            | 34%      | 4%                 | 38%              |
Filtered    | 6%              | 3%           | 9%             | 5%       | 2%                 | 7%               | 8%
True filters|                 |              |                | 3%       |                    | 3%               |
Total       | 31%             | 13%          | 44%            | 42%      | 6%                 | 48%              | 8%

## Other **notable facts**:

- 16% of bulk `foreach`s were *bulk assignments*, the other 84% were a *bulk application*.
- Only 3% of `foreach`s were used with a counter (evenly dispersed between other categories). `forall` seems a preferred construct to add a counter so far.
- Only 2% of `map-each`s (imitated by `foreach`) were in-place maps (contrary to `while`/`until` statistic where the number was around 50%). It seems people prefer other loops to fight against the language than `foreach`. So in conclusion, in-place maps are a minority. This includes `remove-each`s, which were almost never being imitated by `foreach`.

## Examples 

I did not beautify the examples, just tossed them into respective files:
- [foreach-filtered-bulk.red](foreach-filtered-bulk.red) - filtered bulk true foreachs
- [foreach-filtered.red](foreach-filtered.red) - other filtered true foreachs
- [foreach-bulk.red](foreach-bulk.red) - not filtered bulk foreachs
- [foreach.red](foreach.red) - other not filtered foreachs
- [accum-mapeach-filtered-asis.red](accum-mapeach-filtered-asis.red) - true filters
- [accum-mapeach-filtered.red](accum-mapeach-filtered.red) - other filtered maps
- [accum-mapeach.red](accum-mapeach.red) - other maps, not filtered
- [accum-general-filtered.red](accum-general-filtered.red) - other accumulators than map, filtered
- [accum-general.red](accum-general.red) - other accumulators than map, not filtered
- [lookups.red](lookups.red)

It's a bit of a mess there, but it's understandable enough. Feel free to take some examples out if you think there's something to showcase.
Also I'm sure there are still miscategorized examples present. If you happen to encounter one, please move it into the proper category ☻

Some more work can be done here. Like, how many examples will benefit from having `foreach [:value]` or `foreach [datatype!]` enhancements.

---
P.S. And here's the most epic foreach loop I've encountered (enjoy ☺):
```
	foreach manage face/manage [
		do
			get in
				face/parent-face/parent-face/parent-face
				manage
			face/parent-face/parent-face/parent-face
			face/parent-face
	]
```
