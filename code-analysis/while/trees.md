# Tree traversal

These can be solved by the `node!` datatype support.

---
- tree: finding ascendant node with constraints
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
- same
```
    while [all [not res face/parent-face]] [
        res: func-act face/parent-face 
        face: face/parent-face
    ]
```

---
- same
```
    while [all [face/show? face/parent-face]] [
        face: face/parent-face
    ] 
```

---
- coordinate system translation on a tree
- could be a sum of a parameter over a range of nodes
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
- same
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
- again
```
    while [fc <> parent][
        ofs: ofs + fc/offset
        fc: fc/parent
    ]
```

---
- walks up the tree just to find window
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
- could be keep-each/reverse x start-path [..]
```
    while [start-path <> window/gob] [
        if start-path/data/gob-face [insert path start-path/data/gob-face]
        start-path: start-path/parent ; FIXME: should I use faces instead of gobs? NO! because of over (see check-line)
    ]
```
