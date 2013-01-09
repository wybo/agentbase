globals [ best-tour-nodes best-tour-length best-tour-tick ]
breed [ nodes node ]
breed [ travelers traveler ]
travelers-own [ tour-nodes tour-length ]

to setup
  clear-all
  set-default-shape nodes "circle"
  ask patches [ set pcolor yellow + 4.5 ]
  ; random-seed 1234 ;; make the layout and optimization repeatable.
  reset-ticks
  
  create-nodes node-count [ setup-node ]
  create-tour-links [self] of nodes ;; note: "of" returns randomized list.
  set best-tour-length sum [link-length] of links
  create-travelers traveler-count [ setup-traveler ]
  install-best-tour
  set-plot-y-range 0 ceiling best-tour-length
end
to go
  tick  
  if mouse-down? [
    let t min-one-of nodes [distancexy mouse-xcor mouse-ycor]
    while [mouse-down?] [ ask t [setxy mouse-xcor mouse-ycor] display ]
    set best-tour-length sum [link-length] of links
    ask travelers [ set tour-length length-from-nodes tour-nodes ]
  ]
  ask travelers [ make-tour ]
  install-best-tour
  plot precision best-tour-length 1
end

to setup-node  ;; node procedure
  set color red
  setxy random-xcor random-ycor
  while [ count nodes in-radius 2 > 1 ] [ setxy random-xcor random-ycor ]
end
to setup-traveler  ;; traveler procedure
  hide-turtle
  set tour-nodes [self] of nodes ;; shuffle not needed, "of" randomizes
  set tour-length length-from-nodes tour-nodes
end

to create-tour-links [node-list]
  clear-links
  let node-list0 sentence (last node-list) (but-last node-list)
  (foreach node-list0 node-list [ask ?1 [create-link-with ?2]])
  ask links [set color red]
end
to-report length-from-nodes [node-list]
  let node-list0 sentence (last node-list) (but-last node-list)
  report sum  (map [[distance ?2] of ?1] node-list0 node-list)
end

to install-best-tour
  while [count travelers > traveler-count] [ ask max-one-of travelers [tour-length] [die] ]
  let old-length best-tour-length
  ask min-one-of travelers [tour-length]
  [ if tour-length < best-tour-length
    [ set best-tour-length tour-length 
      set best-tour-nodes tour-nodes
      set best-tour-tick ticks ] ]
  if old-length != best-tour-length [ create-tour-links best-tour-nodes ]
end
to make-tour ;; traveler procedure
  let nlist ifelse-value (Strategy = "Random") [RandomStrategy] [InversionStrategy]
  let len length-from-nodes nlist
  ifelse GrowPopulation? 
  [ hatch 1 [set tour-nodes nlist set tour-length len] ]
  [ if len < tour-length [ set tour-nodes nlist set tour-length len ] ]
end
to-report InversionStrategy report new-inversion tour-nodes end
to-report RandomStrategy    report shuffle tour-nodes end

to-report new-inversion [nlist]
  let len length nlist
  let i random (len - 1)
  set len 2 + random (len - i - 2)
  report ( sentence sublist nlist 0 i
                    reverse sublist nlist i (i + len)
                    sublist nlist (i + len) length nlist )
end
@#$#@#$#@
GRAPHICS-WINDOW
173
10
674
532
14
14
16.9310345
1
16
1
1
1
0
0
0
1
-14
14
-14
14
1
1
1
ticks
30.0

MONITOR
27
392
99
437
tour length
best-tour-length
0
1
11

SLIDER
4
49
165
82
node-count
node-count
5
100
50
5
1
NIL
HORIZONTAL

SLIDER
4
83
165
116
traveler-count
traveler-count
0
200
100
1
1
NIL
HORIZONTAL

BUTTON
9
10
64
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
68
10
123
43
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
3
118
165
163
Strategy
Strategy
"Random" "Inversion"
1

MONITOR
96
436
166
481
length
;ticks - best-tour-tick\nprecision best-tour-length 1
3
1
11

SWITCH
4
169
165
202
GrowPopulation?
GrowPopulation?
0
1
-1000

TEXTBOX
32
221
143
266
Click on the nodes while \"Go\"ing to move them.
11
0.0
0

PLOT
6
287
166
437
Tour Length
Ticks
Length
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" ""

MONITOR
6
436
71
481
best tick
best-tour-tick
3
1
11

MONITOR
41
482
113
527
tour ticks
ticks - best-tour-tick\n
3
1
11

@#$#@#$#@

## WHAT IS IT?

This is the classic Traveling Salesman problem, a simple genetic algorithm for calculating the shortest closed route between a set of nodes, visiting each node just once.  This is formally a Hamiltonian cycle.

## HOW IT WORKS

Using NetLogo's graph capability, we create circuits on the node set.  The possible number of such circuits is (n-1)!/2.  For example, if we have 100 nodes, this would be 99!/2 or 4.666310772197208e+155, 4.6.. followed by 155 zeros!  Pretty big.

To overcome this huge number of investigations, we use an evolutionary algorithm that gives us a good answer without having to exhaustively try all these possible paths.  This particular algorithm is a form of a genetic algorithm, where the "genome" is the ordered set of nodes in the path, and the evolutionary change on a genome each step is an inversion: we choose a sub-set of the genome and reverse its order.  The algorithm is described in How to Solve It: Modern Heuristics by Zbigniew Michalewicz and David B. Fogel.

We use NetLogo agents to represent our current set of genomes.  Each contains an ordered node list, and each step of the model we invert each agent and choose the best result.

We choose the best in one of two ways: if GrowPopulation? is set true, we simply add a new agent with the new inversion, thus growing the total number of genomes.  If it is false, we simply compare the current inversion created by an agent with its old value, choosing the better of the two.

## HOW TO USE IT

Simply set the number of nodes for the graph size, and the number of agents for the genome population.  Then set GrowPopulation? to true or false depending on whether you want to compare locally (i.e. just improve one genome at a time) or globally (double the population and trim it back to the initial population size according to the genome length).

Notice you can interact with the graph while its running to see how quickly the GA "heals" the change.

## THINGS TO NOTICE

Which works better, GrowPopulation? set to true or false?  Why, do you think?  
Move the nodes around and see how quickly the graph returns to a good tour.  
Set the strategy to random which simply shuffles the current nodes.  Is it OK?

## EXTENDING THE MODEL

Research the GA world and see if you can find more interesting algorithms than this one.  Add a new Strategy using it.

## NETLOGO FEATURES

Note how small the program is due to the built in graph functions and list capabilities.

## CREDITS AND REFERENCES

This is an update of a program Seth Tissue translated from RePast.  The RePast model was an ant algorithm for the TSP which I built a while back.
@#$#@#$#@
default
true
0
Polygon -7566196 true true 150 5 40 250 150 205 260 250

ant
true
0
Polygon -7566196 true true 136 61 129 46 144 30 119 45 124 60 114 82 97 37 132 10 93 36 111 84 127 105 172 105 189 84 208 35 171 11 202 35 204 37 186 82 177 60 180 44 159 32 170 44 165 60
Polygon -7566196 true true 150 95 135 103 139 117 125 149 137 180 135 196 150 204 166 195 161 180 174 150 158 116 164 102
Polygon -7566196 true true 149 186 128 197 114 232 134 270 149 282 166 270 185 232 171 195 149 186
Polygon -7566196 true true 225 66 230 107 159 122 161 127 234 111 236 106
Polygon -7566196 true true 78 58 99 116 139 123 137 128 95 119
Polygon -7566196 true true 48 103 90 147 129 147 130 151 86 151
Polygon -7566196 true true 65 224 92 171 134 160 135 164 95 175
Polygon -7566196 true true 235 222 210 170 163 162 161 166 208 174
Polygon -7566196 true true 249 107 211 147 168 147 168 150 213 150

arrow
true
0
Polygon -7566196 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

bee
true
0
Polygon -256 true false 152 149 77 163 67 195 67 211 74 234 85 252 100 264 116 276 134 286 151 300 167 285 182 278 206 260 220 242 226 218 226 195 222 166
Polygon -16777216 true false 150 149 128 151 114 151 98 145 80 122 80 103 81 83 95 67 117 58 141 54 151 53 177 55 195 66 207 82 211 94 211 116 204 139 189 149 171 152
Polygon -7566196 true true 151 54 119 59 96 60 81 50 78 39 87 25 103 18 115 23 121 13 150 1 180 14 189 23 197 17 210 19 222 30 222 44 212 57 192 58
Polygon -16777216 true false 70 185 74 171 223 172 224 186
Polygon -16777216 true false 67 211 71 226 224 226 225 211 67 211
Polygon -16777216 true false 91 257 106 269 195 269 211 255
Line -1 false 144 100 70 87
Line -1 false 70 87 45 87
Line -1 false 45 86 26 97
Line -1 false 26 96 22 115
Line -1 false 22 115 25 130
Line -1 false 26 131 37 141
Line -1 false 37 141 55 144
Line -1 false 55 143 143 101
Line -1 false 141 100 227 138
Line -1 false 227 138 241 137
Line -1 false 241 137 249 129
Line -1 false 249 129 254 110
Line -1 false 253 108 248 97
Line -1 false 249 95 235 82
Line -1 false 235 82 144 100

bird1
false
0
Polygon -7566196 true true 2 6 2 39 270 298 297 298 299 271 187 160 279 75 276 22 100 67 31 0

bird2
false
0
Polygon -7566196 true true 2 4 33 4 298 270 298 298 272 298 155 184 117 289 61 295 61 105 0 43

boat1
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6524078 true false 150 32 157 162
Polygon -16776961 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7566196 true true 158 33 230 157 182 150 169 151 157 156
Polygon -7566196 true true 149 55 88 143 103 139 111 136 117 139 126 145 130 147 139 147 146 146 149 55

boat2
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6524078 true false 150 32 157 162
Polygon -16776961 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7566196 true true 157 54 175 79 174 96 185 102 178 112 194 124 196 131 190 139 192 146 211 151 216 154 157 154
Polygon -7566196 true true 150 74 146 91 139 99 143 114 141 123 137 126 131 129 132 139 142 136 126 142 119 147 148 147

boat3
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6524078 true false 150 32 157 162
Polygon -16776961 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7566196 true true 158 37 172 45 188 59 202 79 217 109 220 130 218 147 204 156 158 156 161 142 170 123 170 102 169 88 165 62
Polygon -7566196 true true 149 66 142 78 139 96 141 111 146 139 148 147 110 147 113 131 118 106 126 71

box
true
0
Polygon -7566196 true true 45 255 255 255 255 45 45 45

butterfly1
true
0
Polygon -16777216 true false 151 76 138 91 138 284 150 296 162 286 162 91
Polygon -7566196 true true 164 106 184 79 205 61 236 48 259 53 279 86 287 119 289 158 278 177 256 182 164 181
Polygon -7566196 true true 136 110 119 82 110 71 85 61 59 48 36 56 17 88 6 115 2 147 15 178 134 178
Polygon -7566196 true true 46 181 28 227 50 255 77 273 112 283 135 274 135 180
Polygon -7566196 true true 165 185 254 184 272 224 255 251 236 267 191 283 164 276
Line -7566196 true 167 47 159 82
Line -7566196 true 136 47 145 81
Circle -7566196 true true 165 45 8
Circle -7566196 true true 134 45 6
Circle -7566196 true true 133 44 7
Circle -7566196 true true 133 43 8

circle
false
0
Circle -7566196 true true 35 35 230

line
true
0
Line -7566196 true 150 0 150 301

link
true
0
Line -7500403 true 150 0 150 300

link direction
true
0
Line -7500403 true 150 150 30 225
Line -7500403 true 150 150 270 225

person
false
0
Circle -7566196 true true 155 20 63
Rectangle -7566196 true true 158 79 217 164
Polygon -7566196 true true 158 81 110 129 131 143 158 109 165 110
Polygon -7566196 true true 216 83 267 123 248 143 215 107
Polygon -7566196 true true 167 163 145 234 183 234 183 163
Polygon -7566196 true true 195 163 195 233 227 233 206 159

sheep
false
15
Rectangle -1 true true 90 75 270 225
Circle -1 true true 15 75 150
Rectangle -16777216 true false 81 225 134 286
Rectangle -16777216 true false 180 225 238 285
Circle -16777216 true false 1 88 92

spacecraft
true
0
Polygon -7566196 true true 150 0 180 135 255 255 225 240 150 180 75 240 45 255 120 135

thin-arrow
true
0
Polygon -7566196 true true 150 0 0 150 120 150 120 293 180 293 180 150 300 150

truck-down
false
0
Polygon -7566196 true true 225 30 225 270 120 270 105 210 60 180 45 30 105 60 105 30
Polygon -8716033 true false 195 75 195 120 240 120 240 75
Polygon -8716033 true false 195 225 195 180 240 180 240 225

truck-left
false
0
Polygon -7566196 true true 120 135 225 135 225 210 75 210 75 165 105 165
Polygon -8716033 true false 90 210 105 225 120 210
Polygon -8716033 true false 180 210 195 225 210 210

truck-right
false
0
Polygon -7566196 true true 180 135 75 135 75 210 225 210 225 165 195 165
Polygon -8716033 true false 210 210 195 225 180 210
Polygon -8716033 true false 120 210 105 225 90 210

turtle
true
0
Polygon -7566196 true true 138 75 162 75 165 105 225 105 225 142 195 135 195 187 225 195 225 225 195 217 195 202 105 202 105 217 75 225 75 195 105 187 105 135 75 142 75 105 135 105

wolf
false
0
Rectangle -7566196 true true 15 105 105 165
Rectangle -7566196 true true 45 90 105 105
Polygon -7566196 true true 60 90 83 44 104 90
Polygon -16777216 true false 67 90 82 59 97 89
Rectangle -1 true false 48 93 59 105
Rectangle -16777216 true false 51 96 55 101
Rectangle -16777216 true false 0 121 15 135
Rectangle -16777216 true false 15 136 60 151
Polygon -1 true false 15 136 23 149 31 136
Polygon -1 true false 30 151 37 136 43 151
Rectangle -7566196 true true 105 120 263 195
Rectangle -7566196 true true 108 195 259 201
Rectangle -7566196 true true 114 201 252 210
Rectangle -7566196 true true 120 210 243 214
Rectangle -7566196 true true 115 114 255 120
Rectangle -7566196 true true 128 108 248 114
Rectangle -7566196 true true 150 105 225 108
Rectangle -7566196 true true 132 214 155 270
Rectangle -7566196 true true 110 260 132 270
Rectangle -7566196 true true 210 214 232 270
Rectangle -7566196 true true 189 260 210 270
Line -7566196 true 263 127 281 155
Line -7566196 true 281 155 281 192

wolf-left
false
3
Polygon -6524078 true true 117 97 91 74 66 74 60 85 36 85 38 92 44 97 62 97 81 117 84 134 92 147 109 152 136 144 174 144 174 103 143 103 134 97
Polygon -6524078 true true 87 80 79 55 76 79
Polygon -6524078 true true 81 75 70 58 73 82
Polygon -6524078 true true 99 131 76 152 76 163 96 182 104 182 109 173 102 167 99 173 87 159 104 140
Polygon -6524078 true true 107 138 107 186 98 190 99 196 112 196 115 190
Polygon -6524078 true true 116 140 114 189 105 137
Rectangle -6524078 true true 109 150 114 192
Rectangle -6524078 true true 111 143 116 191
Polygon -6524078 true true 168 106 184 98 205 98 218 115 218 137 186 164 196 176 195 194 178 195 178 183 188 183 169 164 173 144
Polygon -6524078 true true 207 140 200 163 206 175 207 192 193 189 192 177 198 176 185 150
Polygon -6524078 true true 214 134 203 168 192 148
Polygon -6524078 true true 204 151 203 176 193 148
Polygon -6524078 true true 207 103 221 98 236 101 243 115 243 128 256 142 239 143 233 133 225 115 214 114

wolf-right
false
3
Polygon -6524078 true true 170 127 200 93 231 93 237 103 262 103 261 113 253 119 231 119 215 143 213 160 208 173 189 187 169 190 154 190 126 180 106 171 72 171 73 126 122 126 144 123 159 123
Polygon -6524078 true true 201 99 214 69 215 99
Polygon -6524078 true true 207 98 223 71 220 101
Polygon -6524078 true true 184 172 189 234 203 238 203 246 187 247 180 239 171 180
Polygon -6524078 true true 197 174 204 220 218 224 219 234 201 232 195 225 179 179
Polygon -6524078 true true 78 167 95 187 95 208 79 220 92 234 98 235 100 249 81 246 76 241 61 212 65 195 52 170 45 150 44 128 55 121 69 121 81 135
Polygon -6524078 true true 48 143 58 141
Polygon -6524078 true true 46 136 68 137
Polygon -6524078 true true 45 129 35 142 37 159 53 192 47 210 62 238 80 237
Line -16777216 false 74 237 59 213
Line -16777216 false 59 213 59 212
Line -16777216 false 58 211 67 192
Polygon -6524078 true true 38 138 66 149
Polygon -6524078 true true 46 128 33 120 21 118 11 123 3 138 5 160 13 178 9 192 0 199 20 196 25 179 24 161 25 148 45 140
Polygon -6524078 true true 67 122 96 126 63 144

@#$#@#$#@
NetLogo 5.0.3
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
