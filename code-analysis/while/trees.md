# Tree traversal

These can become trivial with `node!` datatype support (https://github.com/red/REP/issues/57).

---
- tree: finding ascendant node with constraints
- `foreach/reverse f face [all [in f 'style  f/style = 'window  break]]`
- `locate/back face [/style = ('window)]`
```
    while [
        all [
            face 
            face/parent-face 
            in face 'style 
            face/style <> 'window
        ]
    ] [
        face: face/parent-face
    ] 
```

---
- `foreach/reverse f face [all [res: func-act f break]]`
```
    while [all [not res face/parent-face]] [
        res: func-act face/parent-face 
        face: face/parent-face
    ]
```

---
- `foreach/reverse f face [any [f/show? break]]`
- `locate/back face [not /show?]`
```
    while [all [face/show? face/parent-face]] [
        face: face/parent-face
    ] 
```

---
- coordinate system translation on a tree
- could be a sum of a parameter over a range of nodes
- code is pretty naive: it could just calculate offset and add it to every coordinate later once
- `offset: sum map-each/reverse f fp [if f/style = 'window [break] edge: .. edge + f/offset]` - then add offset to each t/l/r/b
- `offset: accumulate/reverse 0x0 fp func [acc f][[if f/style = 'window [break] edge: ... acc + f/offset]]` - same, may be faster
```
    while [all [fp fp/style <> 'window]] [
        edge: any [all [in fp 'edge fp/edge fp/edge/size] 0x0] 
        offset: edge + fp/offset 
        top/offset: top/offset + offset 
        left/offset: left/offset + offset 
        right/offset: right/offset + offset 
        bottom/offset: bottom/offset + offset 
        fp: fp/parent-face
    ] 
```

---
- same really
```
    while [face: face/parent-face][
        either face/parent-face [
            xy: xy + face/offset + either face/edge [face/edge/size][0]
        ][
            if window-edge [xy: xy + either face/edge [face/edge/size][0]]
        ]
    ]
```

---
- again
```
    while [face: face/parent-face][
        xy: xy + face/offset + either face/edge [face/edge/size][0]
    ]
```

---
- again, even simpler
- `ofs: sum map-each/reverse f fc [if f = parent [break] f/offset]`
- `ofs: accumulate/reverse 0x0 fc func [acc f] [if f = parent [break] acc + f/offset]`
```
    while [fc <> parent][
        ofs: ofs + fc/offset
        fc: fc/parent
    ]
```

---
- walks up the tree just to find window
- `p: locate/back face [/type = 'window]  p/selected: face`
```
set-focus: function [
    "Sets the focus on the argument face"
    face [object!]
][
    p: face/parent
    while [p/type <> 'window][p: p/parent]
    p/selected: face
]
```

---
- upwards tree lookup by class
- `locate/back face [/gl-class = ('frame)]`
```
    while [
        face
    ][
        if all [
            (in face 'gl-class)
            face/gl-class = 'frame
        ] [
            vout
            return face
        ]
        face: face/parent-face
    ]
```

---
- again
```
    while [
        if all [tface/feel get in tface/feel 'engage][
            tface/feel/engage tface 'time event ; call ENGAGE
            break
        ]
        tface/parent-face
    ][
        tface: tface/parent-face ; climb up
    ]
```

---
- climbs up, constructing the path
- could be `map-each/reverse x start-path [..]`
- `faces: sift (take-while x ascend start-path [x <> window/gob]) [is not (none)]  insert path bulk [faces/*/data/gob-face]` ?
```
    while [start-path <> window/gob] [
        if start-path/data/gob-face [insert path start-path/data/gob-face]
        start-path: start-path/parent ; FIXME: should I use faces instead of gobs? NO! because of over (see check-line)
    ]
```
