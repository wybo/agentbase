# ### Agent
  
# Class Agent instances represent the dynamic, behavioral element of ABM.
# Each agent knows the patch it is on, and interacts with that and other
# patches, as well as other agents.
class ABM.Agent
  # Constructor & Class Variables:
  #
  # * id:          unique identifier, promoted by agentset create() factory method
  # * breed:       the agentset this agent belongs to
  # * x, y:        position on the patch grid, in patch coordinates, default: 0, 0
  # * size:        size of agent, in patch coordinates, default: 1
  # * color:       the color of the agent, default: randomColor
  # * shape:       the shape name of the agent, default: "default"
  # * label:       a text label drawn on my instances
  # * labelColor:  the color of my label text
  # * labelOffset: the x, y offset of my label from my x, y location
  # * heading:     direction of the agent, in radians, from x-axis
  # * hidden:      whether or not to draw this agent
  # * patch:       patch at current x, y location
  # * penDown:     true if agent pen is drawing
  # * penSize:     size in pixels of the pen, default: 1 pixel
  # * sprite:      an image of the agent if non null
  # * links:       array of links in/out of me
  #
  # These class variables are "defaults" and many are "promoted" to instance variables.
  # To have these be set to a constant for all instances, use breed.setDefault.
  # This can be a huge savings in memory.
  id: null              # unique id, promoted by agentset create factory method
  breed: null           # my agentSet, set by the agentSet owning me
  position: null        # my location, has float .x & .y
  patch: null           # the patch I'm on
  size: 1               # my size in patch coordinates
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
  links: null           # array of links to/from me as an endpoint; init by ctor

  constructor: -> # called by agentSets create factory, not user
    @position = {x: 0, y: 0}
    @color = u.randomColor() unless @color? # promote color if default not set
    @heading = u.randomFloat(Math.PI * 2) unless @heading?
    @links = []
    @moveTo @position

  # ### Strings

  # Return a string representation of the agent.
  toString: ->
    "{id: #{@id}, position: {x: #{@position.x.toFixed 2}," +
      " y: #{@position.y.toFixed 2}}, c: #{@color}, h: #{@heading.toFixed 2}}"

  # ### Movement and space
  
  # Place the agent at the given patch/agent location
  #
  # Place the agent at the given point (floats) in patch coordinates using
  # patch topology (isTorus)
  moveTo: (point) ->
    if @penDown
      [x0, y0] = [@position.x, @position.y]

    @position = ABM.patches.coordinate point
    oldPatch = @patch
    @patch = ABM.patches.patch @position

    if oldPatch is not @patch
      u.remove oldPatch.agents, @
    @patch.agents.push @

    if @penDown
      drawing = ABM.drawing
      drawing.strokeStyle = u.colorString @color
      drawing.lineWidth = ABM.patches.fromBits @penSize
      drawing.beginPath()
      drawing.moveTo x0, y0
      drawing.lineTo @position.x, @position.y # REMIND: euclidean
      drawing.stroke()

  # Moves the agent off the grid, making him lose his patch
  moveOff: ->
    u.remove @patch.agents, @
    @patch = @position = null

  # Move forward (along heading) by distance units (patch coordinates),
  # using patch topology (isTorus)
  forward: (distance) ->
    @moveTo(
      x: @position.x + distance * Math.cos(@heading),
      y: @position.y + distance * Math.sin(@heading))
  
  # Change current heading by radians which can be + (left) or - (right)
  rotate: (radians) ->
    @heading = u.wrap @heading + radians, 0, Math.PI * 2 # returns new h
  
  # Set heading towards given agent/patch using patch topology.
  face: (point) ->
    @heading = u.angle @position, point, ABM.patches

  # Return distance in patch coordinates from me to given agent/patch
  # using patch topology (isTorus)
  distance: (point) -> # o any object w/ x, y, patch or agent
    u.distance @position, point, ABM.patches

  # Returns the neighbors (agents) of this agent
  neighbors: (options) ->
    options ?= 1
    if options.radius
      square = @neighbors(options.radius)
      if options.cone
        options.heading ?= @heading
        # adopt heading unless explicitly given
        neighbors = square.inCone(@position, options)
      else
        neighbors = square.inRadius(@position, options)
    else
      neighbors = @breed.from []
      if @patch
        for patch in @patch.neighbors(options)
          for agent in patch.agents
            if agent isnt @
              neighbors.push agent

    neighbors

  # ### Life and death

  # Remove myself from the model. Includes removing myself from the
  # agents agentset and removing any links I may have.
  die: ->
    @breed.remove @
    for link in @links
      link.die()
    @moveOff()
    null

  # Factory: create num new agents at this agents location. The optional init
  # proc is called on the new agent after inserting in its agentSet.
  hatch: (number = 1, breed = ABM.agents, init = ->) ->
    breed.create number, (agent) => # fat arrow so that @ = this agent
      agent.moveTo @position # for side effects like patches.agents
      for own key, value of @ when key isnt "id"
        agent[key] = value
      init(agent) # Important: init called after object inserted in agent set
      agent

  # ### Links

  # Return other end of link from me
  otherEnd: (link) ->
    if link.from is @
      link.to
    else
      link.from
 
  # Return links where I am the "from" agent in links.create
  outLinks: ->
    link for link in @links when link.from is @
 
  # Return links where I am the "to" agent in links.create
  inLinks: ->
    link for link in @links when link.to is @

  # All agents linked to me.
  linkNeighbors: ->
    array = []
    for link in @links
      array.push @otherEnd(link)
    u.uniq(array)
 
  # Other end of myInLinks
  inLinkNeighbors: ->
    array = []
    for link in @inLinks()
      array.push link.from
    u.uniq(array)
 
  # Other end of myOutinks
  outLinkNeighbors: ->
    array = []
    for link in @outLinks()
      array.push link.to
    u.uniq(array)

  # ### Drawing

  # Draw the agent, instanciating a sprite if required
  draw: (context) ->
    if @patch is null
      return
    shape = ABM.shapes[@shape]
    radians = if shape.rotate then @heading else 0 # radians
    if @sprite? or @breed.useSprites
      @setSprite() unless @sprite? # lazy evaluation of useSprites
      ABM.shapes.drawSprite context, @sprite, @position.x, @position.y, @size, radians
    else
      ABM.shapes.draw context, shape, @position.x, @position.y, @size, radians, @color
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
