Red [Title: "headless DSL experiment" Author: @hiiamboris]

;) the purpose is to detach heads of `-each` funcs from `each` itself
;) as you can see this is fun, but creates a namespace clash with actions & natives
;) so I'm keeping it in a context for damage control :D

headless: function [code] [
	~: :system/words
	do bind code context [
		each: function ['spec [block! word!] data [series!]] [
			if word? spec [spec: reduce [spec]]
			ctx: context collect [
				foreach w spec [keep to set-word! w] keep none
			]
			func [/context /step] compose/deep/only bind [
				if context [return (ctx)]
				if step [return (length? spec)]
				unless empty? d [
					set (ctx) d
					also d d: skip d (length? spec)
				]
			] context [d: data]
		]

		handler: func [body [block!]] [
			function [source code [block!]] compose [
				bind code source/context
				(body)
			]
		]

		for: handler [while [source] code]

		;) funcs that affect next result of the iterator are the worst
		take: handler [
			; while [pos: source] [if do code [~/remove pos]]
			collect [while [p: source] [if do code [keep ~/take/part p source/step]]]
		]

		map: handler [
			collect [while [source] [keep do code]]
		]

		partition: handler [
			also r: copy/deep [[][]]
			while [p: source] [
				append/part pick r make logic! do code p source/step
			]
		]

		keep: handler [first partition :source code]
	]
]

{ * Examples *
>> headless [for each x [1 2 3] [probe x]]
1
2
3
>> headless [map each x [1 2 3] [form x]]
== ["1" "2" "3"]
>> headless [partition each x [1 2 3] [odd? x]]
== [[1 3] [2]]
>> headless [keep each x [1 2 3] [odd? x]]
== [1 3]
>> headless [probe take each x s: [1 2 3] [odd? x]  s]
[1 3]
== [2]

>> more: headless [each x s: [1 2 3]]
>> more
== [1 2 3]
>> more
== [2 3]
>> more
== [3]
>> more
== none
}
