# AgentBase is Free Software, available under GPL v3 or any later version.
# Original AgentScript code @ 2013, 2014 Owen Densmore and RedfishGroup LLC.
# AgentBase (c) 2014, Wybo Wiersma.

# Patch instances represent a rectangle on a grid. They hold variables
# that are in the patches the agents live on. The set of all patches
# (@model.patches) is the world on which the agents live and the model
# runs.
#
class ABM.Patch
  # Unique ID, set by BreedSet create() factory method.
  id: null
  # The BreedSet this agent belongs to.
  breed: null
  # Position on the patch grid, hash with patch coordinates {x: some
  # float, y: float}.
  position: null
  # The color of the agent patch.
  color: u.color.black
  # Whether or not to draw this agent.
  hidden: false
  # Text for a label.
  label: null
  # The color of the label.
  labelColor: u.color.black # text color
  # The x, y offset of the label.
  labelOffset: {x: 0, y: 0}
  # Agents on this patch.
  agents: null

  # New Patch: Just set position {x: some integer, y: some integer}.
  #
  constructor: (@position) ->
    @neighborsCache = {}
    @agents = new ABM.Array

  # Returns a string representation of the patch.
  #
  toString: ->
    "{id: #{@id} position: {x: #{@position.x}, y: #{@position.y}}" +
    ", c: #{@color.join(", ")}}"

  # Returns true if the patch is empty.
  #
  empty: ->
    @agents.empty()

  # Returns true if this patch is on the edge of the grid.
  #
  isOnEdge: ->
    @position.x is @breed.min.x or @position.x is @breed.max.x or \
    @position.y is @breed.min.y or @position.y is @breed.max.y

  # Factory: Create num new agents on this patch. The optional init
  # proc is called on the new agent after inserting in its agentSet.
  #
  sprout: (number = 1, breed = @model.agents, init = ->) ->
    breed.create number, (agent) => # fat arrow so that @ = this patch
      agent.moveTo @position
      init(agent)
      agent

  # Return distance in patch coordinates from me to given agent/patch
  # using patch topology (isTorus).
  #
  # Pass {euclidian: true} for always euclidian distance, and 
  # {dimension: true} for max distance along one dimension.
  #
  distance: (point, options) ->
    u.distance @position, point, @model.patches, options

  # Get neighbors for patch.
  #
  neighbors: (options) ->
    options ?= 1

    if u.isNumber(options)
      options = {range: options}

    if not options.cache? or options.cache
      cacheKey = JSON.stringify(options)
      neighbors = @neighborsCache[cacheKey]

    if not neighbors?
      if options.radius
        square = @neighbors(range: options.radius, meToo: options.meToo,
          cache: options.cache)
        if options.cone
          neighbors = square.inCone(@position, options)
          unless options.cache
            cacheKey = null
            # cone has variable heading, better not cache by default
        else
          neighbors = square.inRadius(@position, options)
      else if options.diamond
        neighbors = @diamondNeighbors(options.diamond, options.meToo)
      else
        neighbors = @breed.patchRectangle(@, options.range, options.range, options.meToo)

      if cacheKey?
        @neighborsCache[cacheKey] = neighbors

    return neighbors

  # Get agents on neigboring patches.
  #
  neighborAgents: (options) ->
    neighbors = new @model.Set
    notAgent = options.not
    delete options.not
    for patch in @neighbors(options)
      for agent in patch.agents
        if agent isnt notAgent
          neighbors.push agent

    return neighbors

  # Not to be used directly, will not cache.
  #
  diamondNeighbors: (range, meToo) ->
    neighbors = @breed.patchRectangleNullPadded @, range, range, true
    diamond = new @model.Set
    counter = 0
    row = 0
    column = -1
    span = range * 2 + 1

    for neighbor in neighbors
      row = counter % span
      if row == 0
        column += 1
      distanceColumn = Math.abs(column - range)
      distanceRow = Math.abs(row - range)
      if distanceRow + distanceColumn <= range and
          (meToo or distanceRow + distanceColumn != 0)
        diamond.push neighbor
      counter += 1

    diamond.remove(null)

    return diamond

  # Draw the patch and its text label if there is one.
  #
  draw: (context) ->
    context.fillStyle = @color.rgbString()
    context.fillRect @position.x - .5, @position.y - .5, 1, 1
    if @label? # REMIND: should be 2nd pass.
      position = @breed.patchXYtoPixelXY @position
      u.contextDrawText context, @label, position.x + @labelOffset.x,
        position.y + @labelOffset.y, @labelColor
