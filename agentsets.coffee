# There are three agentsets and their corresponding 
# agents: Patches/Patch, Agents/Agent, and Links/Link.

# The usual alias for **ABM.util**.
u = ABM.util

# ### Patch and Patches

# Class Patch instances represent a rectangle on a grid with::
#
# * id, hidden: installed by Patches agentset
# * x,y: the x,y position within the grid
# * color: the color of the patch as an RGBA array, A optional.
# * label: text for the patch
# * n/n4: adjacent neighbors: n: 8 patches, n4: N,E,S,W patches.
class ABM.Patch
  # new Patch: set x,y,color. Neighbors set by Patches constructor.
  constructor: (@x, @y, @color = [0,0,0]) ->
    @n = null; @n4 = null #neighbors filled by Patches ctr

  # Return a string representation of the patch.
  toString: ->
    "{id:#{@id} xy:#{u.aToFixed [@x,@y]} c:#{@color}}"

  # Set patch color to `c` scaled by `s`. Usage:
  #
  #     p.scaleColor p.color, .8 # reduce patch color by .8
  #     p.scaleColor @foodColor, p.foodPheromone # ants model
  scaleColor: (c, s) -> @color = u.scaleColor c, s
  
  # Draw the patch and its text label if there is one.
  draw: (ctx) ->
    ctx.fillStyle = u.colorStr @color
    ctx.fillRect @x-.5, @y-.5, 1, 1
    if @label?
      [x,y] = ctx.labelXY
      ctx.save()
      ctx.translate @x, @y # bug: fonts don't scale for size < 1
      ctx.scale 1/ABM.patches.size, -1/ABM.patches.size
      u.canvasDrawText ctx, @label, [x,y], ctx.labelColor
      ctx.restore()
  
  # Return an array of the agents on this patch.
  agentsHere: -> (a for a in agents when a.p is @) #REMIND: keep array per patch
  
  # Returns true if this patch is on the edge of the grid.
  isOnEdge: ->
    @x is ABM.patches.minX or @x is ABM.patches.maxX or \
    @y is ABM.patches.minY or @y is ABM.patches.maxY
  
  # Factory: Create num new agents on this patch.
  # Initialize init(agent) for each new agent, default none.
  sprout: (num = 1, init = ->) ->
    ABM.agents.create num, (a) => # fat arrow so that @ = this patch
      a.setXY @x, @y; init(a); a
  
  # Return a rectangle of patches centered on this patch,
  # dx, dy units to the right/left and up/down. Exclude this
  # patch unless meToo is true, default false.
  patchRect: (dx, dy, meToo=false) ->
    ABM.patches.patchRect @, dx, dy, meToo=false
  

# Class Patches is a singleton 2D matrix of Patch instances, each patch 
# representing a 1x1 square in patch coordinates (via 2D coord transforms).
#
# * size: pixel h/w of each patch.
# * minX/maxX: min/max x coord, each patch being a unit square.
# * numX: total number of patches in x direction, width of grid
# * minY/maxY: min/max y coord.
# * numY: total number of patches in y direction, height of grid.
# * isTorus: topology of patches, see **ABM.util**.
class ABM.Patches extends ABM.AgentSet
  # Constructor: set variables, fill patch neighbor variables, n & n4.
  constructor: (@size, @minX, @maxX, @minY, @maxY, @isTorus = true) ->
    super()
    @numX = @maxX-@minX+1
    @numY = @maxY-@minY+1
    for y in [minY..maxY] by 1
      for x in [minX..maxX] by 1
        @add new ABM.Patch x, y
    for p in @
      p.n = @asOrderedSet @patchRect p, 1, 1
      p.n4 = @asOrderedSet (n for n in p.n when n.x is p.x or n.y is p.y)

# #### Patch grid coord system utilities:

  # Return the patch at matrix position x,y where 
  # x & y are both valid integer patch coordinates.
  patchXY: (x,y) -> @[x-@minX + @numX*(y-@minY)]
  
  # Return x,y float values to be between min/max patch coord values
  clamp: (x,y) -> [u.clamp(x, @minX-.5, @maxX+.5), u.clamp(y, @minY-.5, @maxY+.5)]
  
  # Return x,y float values to be modulo min/max patch coord values.
  wrap: (x,y)  -> [u.wrap(x, @minX-.5, @maxX+.5),  u.wrap(y, @minY-.5, @maxY+.5)]
  
  # Return x,y float values to be between min/max patch values
  # using either clamp/wrap above according to isTorus topology.
  coord: (x,y) -> #returns a valid world coord (real, not int)
    if @isTorus then @wrap x,y else @clamp x,y

  # Return patch at x,y float values according to topology.
  patch: (x,y) -> 
    [x,y]=@coord x,y
    x = u.clamp Math.round(x), @minX, @maxX
    y = u.clamp Math.round(y), @minY, @maxY
    @patchXY x, y
  
  # Return a random valid float x,y point in patch space
  randomPt: -> [u.randomFloat2(@minX-.5,@maxX+.5), u.randomFloat2(@minY-.5,@maxY+.5)]

# #### Patch metrics

  # Return pixel width/height of patch grid
  bitWidth:  -> @numX*@size # methods, not constants in case resize
  bitHeight: -> @numY*@size
  
  # Convert patch measure to pixels
  patches2Bits: (p) -> p*@size
  # Convert bit measure to patches
  bits2Patches: (b) -> b/@size

# #### Patch utilities

  # Return a rectangle of patches centered on given patch `p`,
  # dx, dy units to the right/left and up/down. Exclude `p`
  # unless meToo is true, default false.
  patchRect: (p, dx, dy, meToo=false) ->
    rect = [];
    for y in [p.y-dy..p.y+dy] by 1 # by 1: perf: avoid bidir JS for loop
      for x in [p.x-dx..p.x+dx] by 1
        if @isTorus or (@minX<=x<=@maxX and @minY<=y<=@maxY)
          pnext = @patch x, y
          rect.push (pnext) if (meToo or p isnt pnext)
    rect
  
  # Diffuse the value of patch variable `p.v` by distributing `rate` percent
  # of each patch's value of `v` to its neighbors. If a color `c` is given,
  # scale the patch's color to be `p.v` of `c`. If the patch has
  # less than 8 neighbors, return the extra to the patch.
  diffuse: (v, rate, c=null) -> # variable name, diffusion rate, max color (optional)
    # zero temp variable if not yet set
    if not @[0]._diffuseNext?
      p._diffuseNext = 0 for p in @
    # pass 1: calculate contribution of all patches to themselves and neighbors
    for p in @
      dv = p[v]*rate; dv8 = dv/8; nn = p.n.length
      p._diffuseNext += p[v] - dv + (8-nn)*dv8
      n._diffuseNext += dv8 for n in p.n
    # pass 2: set new value for all patches, zero temp, modify color if c given
    for p in @
      p[v] = p._diffuseNext
      p._diffuseNext = 0
      p.scaleColor c, p[v] if c # p.color = u.scaleColor c, p[v] if c
    null # avoid returning copy of @  

# ### Agent & Agents

class ABM.Agent
  constructor: ->
    @breed = "default"
    @x = @y = 0
    @color = u.randomColor()
    @heading = u.randomFloat(Math.PI*2) # deg in radians from +x axis REMIND wrap?
    @size = 1
    @shape = ABM.agents.defaultShape
    @p = ABM.patches.patch @x, @y
    @penDown = false
    @penSize = ABM.patches.bits2Patches(1)
  scaleColor: (c, s) -> @color = u.scaleColor c, s
  toString: ->
    "{id:#{@id} xy:#{u.aToFixed [@x,@y]} c:#{@color} h: #{@heading.toFixed 2}}"
  setXY: (x, y) ->
    [x0, y0] = [@x, @y] if @penDown
    [@x, @y] = ABM.patches.coord x, y
    @p = ABM.patches.patch @x, @y
    if @penDown
      drawing = ABM.drawing
      drawing.strokeStyle = u.colorStr @color; drawing.lineWidth = @penSize
      drawing.beginPath()
      # drawing.moveTo x0, y0; drawing.lineTo @x, @y
      drawing.moveTo x0, y0; drawing.lineTo x, y # REMIND: euclidean
      drawing.stroke()
  moveTo: (a) -> @setXY a.x, a.y
  forward: (d) ->
    @setXY @x + d*Math.cos(@heading), @y + d*Math.sin(@heading)
  rotate: (rad) -> @heading = u.wrap @heading + rad, 0, Math.PI*2 # returns new h
  draw: (ctx) ->
    shape = ABM.shapes[@shape]
    ctx.save()
    ctx.fillStyle = u.colorStr @color
    ctx.translate @x, @y; ctx.scale @size, @size;
    ctx.rotate @heading if shape.rotate
    ctx.beginPath()
    shape.draw(ctx)
    ctx.closePath()
    ctx.fill()
    ctx.restore()
      
  stamp: -> @draw ABM.drawing
  distanceXY: (x,y) -> # distance from me to x,y (may want sqDist too)
    if ABM.patches.isTorus
    then u.torusDistance @x, @y, x, y, ABM.patches.numX, ABM.patches.numY
    else u.distance @x, @y, x, y
  distance: (o) -> # o any object w/ x,y, patch or agent
    @distanceXY o.x, o.y
  torusPtXY: (x, y) ->
    u.torusPt @x, @y, x, y, ABM.patches.numX, ABM.patches.numY
  torusPt: (o) ->
    @torusPtXY o.x, o.y
  face: (o) -> @heading = @towards o
  towardsXY: (x, y) ->
    if ABM.patches.isTorus
    then u.torusRadsToward @x, @y, x, y, ABM.patches.numX, ABM.patches.numY
    else u.radsToward @x, @y, x, y
  towards: (o) -> @towardsXY o.x, o.y
  # patchRect: (dx, dy, meToo = false) -> ABM.patches.patchRect @p, dx, dy, meToo
  inCone: (aset, cone, radius, meToo=false) -> 
    # aset.inCone @, @heading, cone, radius, meToo=false # REMIND: @p vs @?
    aset.inCone @p, @heading, cone, radius, meToo=false # REMIND: @p vs @?

  die: ->
    # console.log @,   remove @
    ABM.agents.remove @
    # fails: modifies links: l.die() for l in links when l.end1 is @ or l.end2 is @
    unlink = (l for l in ABM.links when l.end1 is @ or l.end2 is @)
    l.die() for l in unlink
  copy: (a) -> # copy all of my values to a (except id)
    a[k] = v for own k, v of @ when k isnt "id" and k isnt "shape" #and k isnt "breed"
    # should have default shape of breed
  hatch: (num = 1, init = ->) ->
    ABM.agents.create num, (a) => # fat arrow so that @ = this agent
      @copy a; init(a); a
  links: -> # return all links linked to me
    l for l in ABM.links when (l.end1 is @) or (l.end2 is @) # asSet?
  otherEnd: (l) -> if l.end1 is @ then l.end2 else l.end1
  linkNeighbors: -> # return all agents linked to me
    ABM.agents.asSet (@otherEnd l for l in @links())
  

class ABM.Agents extends ABM.AgentSet
  constructor: ->
    super()
    @defaultShape = "default"
  setDefaultShape: (@defaultShape) ->
  create: (num, init = ->) -> # returns list too
    # NOTE: init must be applied after object inserted in agent set
    # doInit = (a) -> init(a); a # call init and return agent
    # doInit @add new Agent for i in [1..num]
    ((o) -> init(o); o) @add new ABM.Agent for i in [1..num] by 1 # too tricky?
  # clear: -> a.die() for a in @
  breed: (breed) -> @asSet @getWithProp "breed", breed

# ### Link and Links

class ABM.Link
  constructor: (@end1, @end2) ->
    @breed = "default"
    @color = [130, 130, 130] #u.randomColor()
    @thickness = ABM.patches.bits2Patches(2)
  draw: (ctx) ->
    ctx.save()
    ctx.strokeStyle = u.colorStr @color
    ctx.lineWidth = @thickness
    ctx.beginPath()
    if !ABM.patches.isTorus
      ctx.moveTo @end1.x, @end1.y
      ctx.lineTo @end2.x, @end2.y
    else
      pt = @end1.torusPt @end2
      ctx.moveTo @end1.x, @end1.y
      ctx.lineTo pt...
      if pt[0] isnt @end2.x or pt[1] isnt @end2.y
        pt = @end2.torusPt @end1
        ctx.moveTo @end2.x, @end2.y
        ctx.lineTo pt...
    ctx.closePath()
    ctx.stroke()
    ctx.restore()
  die: ->
    ABM.links.remove @ # REMIND: remove from ends too
  bothEnds: -> ABM.links.asSet [@end1, @end2]
  length: -> @end1.distance @end2
  # otherEnd: (a) -> if @end1 is a then @end2 else @end1

class ABM.Links extends ABM.AgentSet
  constructor: ->
    super()
  create: (from, to, init = ->) -> # returns list too
    to = [to] if not to.length?
    ((o) -> init(o); o) @add new ABM.Link from, a for a in to # too tricky?
  # clear: -> a.die() for a in @
  clear: -> @last().die() while @any()
  breed: (breed) -> @getWithProp "breed", breed
  allEnds: -> # all link ends, w/ dups
    n = @asSet []
    n.push l.bothEnds()... for l in @
    n
  nodes: -> # allEnds without dups
    @allEnds().sortById().uniq()
  layoutCircle: (list, radius, startAngle = Math.PI/2, direction = -1) ->
    dTheta = 2*Math.PI/list.length
    for a, i in list
      a.setXY 0, 0
      a.heading = startAngle + direction*dTheta*i
      a.forward radius
      
