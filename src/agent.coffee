# ### Agent
  
# Class Agent instances represent the dynamic, behavioral element of ABM.
# Each agent knows the patch it is on, and interacts with that and other
# patches, as well as other agents.
class ABM.Agent
  # Constructor & Class Variables:
  #
  # * id:         unique identifier, promoted by agentset create() factory method
  # * breed:      the agentset this agent belongs to
  # * x,y:        position on the patch grid, in patch coordinates, default: 0, 0
  # * size:       size of agent, in patch coords, default: 1
  # * color:      the color of the agent, default: randomColor
  # * shape:      the shape name of the agent, default: "default"
  # * label:      a text label drawn on my instances
  # * labelColor: the color of my label text
  # * labelOffset:the x, y offset of my label from my x, y location
  # * heading:    direction of the agent, in radians, from x-axis
  # * hidden:     whether or not to draw this agent
  # * patch:      patch at current x, y location
  # * penDown:    true if agent pen is drawing
  # * penSize:    size in pixels of the pen, default: 1 pixel
  # * sprite:     an image of the agent if non null
  # * cacheLinks: if true, keep array of links in/out of me
  # * links:      array of links in/out of me.  Only used if @cacheLinks is true
  #
  # These class variables are "defaults" and many are "promoted" to instance variables.
  # To have these be set to a constant for all instances, use breed.setDefault.
  # This can be a huge savings in memory.
  id: null              # unique id, promoted by agentset create factory method
  breed: null           # my agentSet, set by the agentSet owning me
  x: 0                  # my location
  y: 0
  patch: null           # the patch I'm on
  size: 1               # my size in patch coords
  color: null           # default color, overrides random color if set
  shape: "default"      # my shape
  hidden: false         # draw me?
  label: null           # my text
  labelColor: [0, 0, 0] # its color
  labelOffset: [0, 0]   # its offset from my x, y
  penDown: false        # if my pen is down, I draw my path between changes in x, y
  penSize: 1            # the pen thickness in pixels
  heading: null         # the direction I'm pointed in, in radians
  sprite: null          # an image of me for optimized drawing
  cacheLinks: false     # should I keep links to/from me in links array?.
  links: null           # array of links to/from me as an endpoint; init by ctor

  constructor: -> # called by agentSets create factory, not user
    @x = @y = 0
    @color = u.randomColor() unless @color? # promote color if default not set
    @heading = u.randomFloat(Math.PI * 2) unless @heading?
    @links = [] if @cacheLinks
    @setXY @x, @y

  # Set agent color to `color` scaled by `fraction`. Usage: see patch.fractionOfColor
  fractionOfColor: (color, fraction) ->
    @color = u.clone @color unless @.hasOwnProperty("color")
    u.fractionOfColor color, fraction, @color
  
  # Return a string representation of the agent.
  toString: -> "{id:#{@id} xy:#{u.aToFixed [@x, @y]} c:#{@color} h: #{@heading.toFixed 2}}"
  
  # Place the agent at the given x, y (floats) in patch coords
  # using patch topology (isTorus)
  setXY: (x, y) -> # REMIND GC problem, 2 arrays
    [x0, y0] = [@x, @y] if @penDown
    [@x, @y] = ABM.patches.coord x, y
    oldPatch = @patch
    @patch = ABM.patches.patch @x, @y

    if oldPatch
      u.remove oldPatch.agents, @

    @patch.agents.push @

    if @penDown
      drawing = ABM.drawing
      drawing.strokeStyle = u.colorString @color
      drawing.lineWidth = ABM.patches.fromBits @penSize
      drawing.beginPath()
      drawing.moveTo x0, y0
      drawing.lineTo x, y # REMIND: euclidean
      drawing.stroke()

  losePosition: ->
    u.remove @patch.agents, @
    @patch = null
  
  # Place the agent at the given patch/agent location
  moveTo: (patch) -> @setXY patch.x, patch.y
  
  # Move forward (along heading) d units (patch coords),
  # using patch topology (isTorus)
  forward: (d) ->
    @setXY @x + d * Math.cos(@heading), @y + d * Math.sin(@heading)
  
  # Change current heading by radians which can be + (left) or - (right)
  rotate: (radians) ->
    @heading = u.wrap @heading + radians, 0, Math.PI * 2 # returns new h
  
  # Draw the agent, instanciating a sprite if required
  draw: (context) ->
    if @patch is null
      return
    shape = ABM.shapes[@shape]
    radians = if shape.rotate then @heading else 0 # radians
    if @sprite? or @breed.useSprites
      @setSprite() unless @sprite? # lazy evaluation of useSprites
      ABM.shapes.drawSprite context, @sprite, @x, @y, @size, radians
    else
      ABM.shapes.draw context, shape, @x, @y, @size, radians, @color
    if @label?
      [x, y] = ABM.patches.patchXYtoPixelXY @x, @y
      u.contextDrawText context, @label, x + @labelOffset[0], y + @labelOffset[1], @labelColor
  
  # Set an individual agent's sprite, synching its color, shape, size
  setSprite: (sprite)->
    if (sprite)?
      @sprite = sprite
      @color = sprite.color
      @shape = sprite.shape
      @size = sprite.size
    else
      @color = u.randomColor unless @color?
      @sprite = ABM.shapes.shapeToSprite @shape, @color, @size
    
  # Draw the agent on the drawing layer, leaving permanent image.
  stamp: -> @draw ABM.drawing
  
  # Return the closest torus topology point of given agent/patch 
  # relative to myself. 
  # Used internally to determine how to draw links between two agents.
  # See util.torusPoint.
  closestTorusPoint: (point) ->
    u.closestTorusPoint @, point, ABM.patches.numX, ABM.patches.numY

  # Return angle towards given agent/patch using patch topology.
  angleTowards: (point) ->
    u.radiansToward @, point, ABM.patches

  # Set heading towards given agent/patch using patch topology.
  face: (point) ->
    @heading = @angleTowards point
  
  # Return distance in patch coords from me to given agent/patch
  # using patch topology (isTorus)
  distance: (point) -> # o any object w/ x, y, patch or agent
    u.distance @, point, ABM.patches

  # Returns the neighbors (agents) of this agent
  neighbors: (options) ->
    options ?= 1
    if options.radius
      square = @neighbors(options.radius)
      if options.cone
        neighbors = square.inCone(@, options)
      else
        neighbors = square.inRadius(@, options)
    else
      neighbors = @breed.asSet []
      if @patch
        for patch in @patch.neighbors(options)
          for agent in patch.agents
            if agent isnt @
              neighbors.push agent
    neighbors

  # Remove myself from the model. Includes removing myself from the
  # agents agentset and removing any links I may have.
  die: ->
    @breed.remove @
    for l in @myLinks()
      l.die()
    if @patch.agents?
      u.remove @patch.agents, @
    null

  # Factory: create num new agents at this agents location. The optional init
  # proc is called on the new agent after inserting in its agentSet.
  hatch: (num = 1, breed = ABM.agents, init = ->) ->
    breed.create num, (a) => # fat arrow so that @ = this agent
      a.setXY @x, @y # for side effects like patches.agents
      a[k] = v for own k, v of @ when k isnt "id"
      init(a) # Important: init called after object inserted in agent set
      a

  # Return other end of link from me
  otherEnd: (l) -> if l.end1 is @ then l.end2 else l.end1

  # Return all links linked to me
  myLinks: ->
    @links ? (l for l in ABM.links when (l.end1 is @) or (l.end2 is @))
  
  # Return all agents linked to me.
  linkNeighbors: -> # return all agents linked to me
    @otherEnd l for l in @myLinks()
  
  # Return links where I am the "to" agent in links.create
  myInLinks: ->
    l for l in @myLinks() when l.end2 is @

  # Return other end of myInLinks
  inLinkNeighbors: ->
    l.end1 for l in @myLinks() when l.end2 is @
    
  # Return links where I am the "from" agent in links.create
  myOutLinks: ->
    l for l in @myLinks() when l.end1 is @
  
  # Return other end of myOutinks
  outLinkNeighbors: ->
    l.end2 for l in @myLinks() when l.end1 is @
