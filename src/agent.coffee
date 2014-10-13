# AgentBase is Free Software, available under GPL v3 or any later version.
# original AgentScript code @ 2013, 2014 Owen Densmore and RedfishGroup LLC.
# AgentBase (c) 2014, Wybo Wiersma.

# Agent instances represent the dynamic, behavioral element of the ABM. Each agent
# knows the patch it is on, and interacts with that and other patches, as well as
# other agents.
#
class ABM.Agent
  # Unique ID, set by BreedSet create() factory method.
  id: null
  # The BreedSet this agent belongs to.
  breed: null
  # Position on the patch grid, hash with patch coordinates {x: some
  # float, y: float}.
  position: null
  # The patch the agent is on.
  patch: null
  # Agents' size in patch coordinates.
  size: 1
  # The color of the agent, defaults to randomColor.
  color: null
  # Color of the border of the agent.
  strokeColor: null
  # The shape name of the agent.
  shape: "default"
  # Whether or not to draw this agent.
  hidden: false
  # Text for a label.
  label: null
  # The color of the label.
  labelColor: [0, 0, 0]
  # The x, y offset of the label.
  labelOffset: {x: 0, y: 0}
  # If my pen is down, I draw my path between changes in x, y.
  penDown: false
  # The pen thickness in pixels.
  penSize: 1
  # The direction the agent is pointed in, in radians.
  heading: null
  # Sprite image of the agent, for optimized drawing.
  sprite: null
  # Array of links to/from the agent as an endpoint.
  links: null

  # Initializes instance variables.
  #
  # Called by BreedSet create factory, not user.
  #
  constructor: ->
    @position = {x: 0, y: 0}
    @color = u.randomColor() unless @color? # promote color if default not set
    @heading = u.randomFloat(Math.PI * 2) unless @heading?
    @links = new ABM.Array
    @moveTo @position

  # ### Strings

  # Return a string representation of the agent.
  #
  toString: ->
    "{id: #{@id}, position: {x: #{@position.x.toFixed 2}," +
      " y: #{@position.y.toFixed 2}}, c: #{@color}," +
      " h: #{@heading.toFixed 2}/#{Math.round(u.radiansToDegrees(@heading))}}"

  # ### Movement and space

  # Place the agent at the given patch/agent location.
  #
  # Place the agent at the given point (floats) in patch coordinates using
  # patch topology (isTorus).
  #
  moveTo: (point) ->
    if @penDown
      [x0, y0] = [@position.x, @position.y]

    @position = @model.patches.coordinate point
    oldPatch = @patch
    @patch = @model.patches.patch @position

    if oldPatch and oldPatch isnt @patch
      oldPatch.agents.remove @
    @patch.agents.push @

    if @penDown
      drawing = @model.drawing
      drawing.strokeStyle = u.colorString @color
      drawing.lineWidth = @model.patches.fromBits @penSize
      drawing.beginPath()
      drawing.moveTo x0, y0
      drawing.lineTo @position.x, @position.y # REMIND: euclidean
      drawing.stroke()

  # Moves the agent off the grid, making him lose his patch.
  #
  moveOff: ->
    if @patch
      @patch.agents.remove @
    @patch = @position = null

  # Move forward (along heading) by distance units (patch coordinates),
  # using patch topology (isTorus).
  #
  forward: (distance) ->
    @moveTo(
      x: @position.x + distance * Math.cos(@heading),
      y: @position.y + distance * Math.sin(@heading))

  # Change current heading by radians.
  #
  # Pass a number which can be + (left) or - (right).
  #
  # Or pass {left: <number>} or {right: <number>} to specify a
  # direction in a more legible way.
  #
  rotate: (options) ->
    if u.isNumber options
      @heading = u.wrap @heading + options, 0, Math.PI * 2 # returns new h
    else if options['right']
      @rotate options['right'] * -1
    else
      @rotate options['left']

  # Set heading towards given agent/patch using patch topology.
  #
  face: (point) ->
    @heading = u.angle @position, point, @model.patches

  # Return distance in patch coordinates from me to given agent/patch
  # using patch topology (isTorus).
  #
  distance: (point) -> # o any object w/ x, y, patch or agent
    u.distance @position, point, @model.patches

  # Returns the neighbors (agents) of this agent.
  #
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
  #
  die: ->
    @breed.remove @
    for link in @links by -1
      link.die()
    @moveOff()
    null

  # Factory: create num new agents at this agents location. The optional init
  # proc is called on the new agent after inserting in its agentSet.
  #
  hatch: (number = 1, breed = @model.agents, init = ->) ->
    breed.create number, (agent) => # fat arrow so that @ = this agent
      agent.moveTo @position # for side effects like patches.agents
      for own key, value of @ when key isnt "id"
        agent[key] = value
      init(agent) # Important: init called after object inserted in agent set
      agent

  # ### Links

  # Return other end of the link.
  #
  otherEnd: (link) ->
    if link.from is @
      link.to
    else
      link.from

  # Return links where I am the "from" agent in links.create.
  #
  outLinks: ->
    link for link in @links when link.from is @

  # Return links where I am the "to" agent in links.create.
  #
  inLinks: ->
    link for link in @links when link.to is @

  # All agents linked to me.
  #
  linkNeighbors: ->
    array = new ABM.Array
    for link in @links
      array.push @otherEnd(link)
    array.uniq()

  # The other end of myInLinks.
  #
  inLinkNeighbors: ->
    array = new ABM.Array
    for link in @inLinks()
      array.push link.from
    array.uniq()

  # The other end of myOutinks.
  #
  outLinkNeighbors: ->
    array = new ABM.Array
    for link in @outLinks()
      array.push link.to
    array.uniq()

  # ### Drawing

  # Draw the agent, instanciating a sprite if required.
  #
  draw: (context) ->
    if @patch is null
      return

    shape = u.shapes[@shape]

    if shape.rotate
      radians = @heading
    else
      radians = 0

    if @sprite? or @breed.useSprites
      @setSprite() unless @sprite? # lazy evaluation of useSprites
      u.shapes.drawSprite context, @sprite, @position.x, @position.y, @size, radians
    else
      u.shapes.draw context, shape, @position.x, @position.y, @size, radians, @color, @strokeColor
    if @label?
      [x, y] = @model.patches.patchXYtoPixelXY @position.x, @position.y
      u.contextDrawText context, @label, x + @labelOffset.x, y + @labelOffset.y, @labelColor

  # Set an individual agent's sprite, synching its color, shape, size.
  #
  setSprite: (sprite) ->
    if sprite?
      @sprite = sprite
      @color = sprite.color
      @strokeColor = sprite.strokeColor
      @shape = sprite.shape
      @size = sprite.size
    else
      @color = u.randomColor unless @color?
      @sprite = u.shapes.shapeToSprite @shape, @color,
        @model.patches.toBits(@size), @strokeColor

  # Draw the agent on the drawing layer, leaving permanent image.
  #
  stamp: ->
    @draw @model.drawing
